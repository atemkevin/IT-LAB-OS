/**
 * lib/learning/skills.ts
 *
 * Skill data fetching with user progress enrichment.
 * Server-only.
 */
import { createClient } from "@/lib/supabase/server";
import { getAdminClient } from "@/lib/supabase/admin";
import { getSkillAccessState, arePrerequisitesMet, buildPrerequisiteStatuses } from "./prerequisites";
import type { DomainWithSkills, SkillDetail, SkillWithDomain } from "./types";

/**
 * Get all published skills grouped by domain, enriched with user access state.
 * Pass null userId for unauthenticated views (all skills show as locked/available based on prereqs).
 */
export async function getDomainsWithSkills(userId: string | null): Promise<DomainWithSkills[]> {
  const supabase = await createClient();

  // Fetch domains
  const { data: domains, error: domainErr } = await supabase
    .from("domains")
    .select("*")
    .eq("is_published", true)
    .order("sort_order");

  if (domainErr || !domains) return [];

  // Fetch skills
  const { data: skills, error: skillErr } = await supabase
    .from("skills")
    .select("*")
    .eq("is_published", true)
    .order("sort_order");

  if (skillErr || !skills) return [];

  // Fetch prerequisites
  const { data: prereqs } = await supabase.from("skill_prerequisites").select("*");

  // Fetch user progress (if authenticated)
  let progressMap = new Map<string, import("@/lib/database.types").UserSkillProgress>();
  if (userId) {
    const { data: progressRows } = await supabase
      .from("user_skill_progress")
      .select("*")
      .eq("user_id", userId);
    if (progressRows) {
      for (const p of progressRows) {
        progressMap.set(p.skill_id, p);
      }
    }
  }

  // Build prereq map: skill_id -> list of prerequisite rows
  const prereqMap = new Map<string, Array<{ prerequisite_skill_id: string; required_mastery: number | string }>>();
  for (const p of prereqs ?? []) {
    const list = prereqMap.get(p.skill_id) ?? [];
    list.push(p);
    prereqMap.set(p.skill_id, list);
  }

  // Build skill map for domain lookup
  const domainMap = new Map(domains.map((d) => [d.id, d]));

  // Enrich skills
  const enrichedSkills: SkillWithDomain[] = skills.map((skill) => {
    const skillPrereqs = prereqMap.get(skill.id) ?? [];
    const prerequisitesMet = arePrerequisitesMet(skillPrereqs, progressMap);
    const userProgress = progressMap.get(skill.id) ?? null;
    const accessState = getSkillAccessState(skill.id, userProgress, prerequisitesMet);
    const domain = domainMap.get(skill.domain_id)!;

    return { ...skill, domain, accessState, userProgress };
  });

  // Group by domain
  return domains.map((domain) => {
    const domainSkills = enrichedSkills.filter((s) => s.domain_id === domain.id);
    const completedSkills = domainSkills.filter(
      (s) => s.accessState === "proficient" || s.accessState === "strong"
    ).length;
    const progressPercent =
      domainSkills.length > 0
        ? Math.round((completedSkills / domainSkills.length) * 100)
        : 0;

    return {
      domain,
      skills: domainSkills,
      totalSkills: domainSkills.length,
      completedSkills,
      progressPercent,
    };
  });
}

/**
 * Get full skill detail for /skills/[slug] page.
 */
export async function getSkillDetail(
  slug: string,
  userId: string | null
): Promise<SkillDetail | null> {
  const supabase = await createClient();
  const admin = getAdminClient();

  // Fetch skill
  const { data: skill, error } = await supabase
    .from("skills")
    .select("*")
    .eq("slug", slug)
    .eq("is_published", true)
    .maybeSingle();

  if (error || !skill) return null;

  // Fetch domain
  const { data: domain } = await supabase
    .from("domains")
    .select("*")
    .eq("id", skill.domain_id)
    .maybeSingle();

  if (!domain) return null;

  // Fetch prerequisites for this skill
  const { data: prereqRows } = await supabase
    .from("skill_prerequisites")
    .select("*")
    .eq("skill_id", skill.id);

  // Fetch all skills for prereq lookup
  const { data: allSkills } = await supabase.from("skills").select("*");
  const { data: allDomains } = await supabase.from("domains").select("*");
  const skillMap = new Map((allSkills ?? []).map((s) => [s.id, s]));
  const domainMap = new Map((allDomains ?? []).map((d) => [d.id, d]));

  // Fetch user progress
  let progressMap = new Map<string, import("@/lib/database.types").UserSkillProgress>();
  let userProgress = null;
  if (userId) {
    const { data: progressRows } = await supabase
      .from("user_skill_progress")
      .select("*")
      .eq("user_id", userId);
    if (progressRows) {
      for (const p of progressRows) progressMap.set(p.skill_id, p);
    }
    userProgress = progressMap.get(skill.id) ?? null;
  }

  // Build prereq statuses
  const prerequisites = buildPrerequisiteStatuses(
    prereqRows ?? [],
    skillMap,
    domainMap,
    progressMap
  );
  const prerequisitesMet = prerequisites.every((p) => p.isMet);
  const accessState = getSkillAccessState(skill.id, userProgress, prerequisitesMet);

  // Fetch lessons with user progress
  const { data: lessons } = await supabase
    .from("lessons")
    .select("*")
    .eq("skill_id", skill.id)
    .eq("is_published", true)
    .order("sort_order");

  let lessonProgressMap = new Map<string, import("@/lib/database.types").UserLessonProgress>();
  if (userId && lessons?.length) {
    const { data: lpRows } = await supabase
      .from("user_lesson_progress")
      .select("*")
      .eq("user_id", userId)
      .in("lesson_id", lessons.map((l) => l.id));
    if (lpRows) {
      for (const lp of lpRows) lessonProgressMap.set(lp.lesson_id, lp);
    }
  }

  const lessonsWithProgress = (lessons ?? []).map((l) => ({
    ...l,
    progress: lessonProgressMap.get(l.id) ?? null,
  }));

  // Fetch practice tasks (published, no content leaking)
  const { data: practiceTasks } = await supabase
    .from("practice_tasks")
    .select("*")
    .eq("skill_id", skill.id)
    .eq("is_published", true);

  // Fetch quiz question count (using admin to bypass the no-select-on-quiz-options restriction)
  const { count: quizCount } = await admin
    .from("quiz_questions")
    .select("*", { count: "exact", head: true })
    .eq("skill_id", skill.id)
    .eq("is_published", true);

  return {
    ...skill,
    domain,
    accessState,
    userProgress,
    prerequisites,
    lessons: lessonsWithProgress,
    practiceTasks: practiceTasks ?? [],
    quizQuestionCount: quizCount ?? 0,
  };
}
