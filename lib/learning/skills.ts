/**
 * lib/learning/skills.ts
 *
 * Skill data fetching with user progress enrichment.
 * Server-only.
 */
import { cache } from "react";
import { createClient } from "@/lib/supabase/server";
import { getAdminClient } from "@/lib/supabase/admin";
import { getSkillAccessState, arePrerequisitesMet, buildPrerequisiteStatuses } from "./prerequisites";
import type { DomainWithSkills, SkillDetail, SkillWithDomain } from "./types";

/**
 * Get all published skills grouped by domain, enriched with user access state.
 * Pass null userId for unauthenticated views (all skills show as locked/available based on prereqs).
 *
 * Cached per request to avoid duplicate fetches when used by multiple components.
 */
export const getDomainsWithSkills = cache(async function (
  userId: string | null,
): Promise<DomainWithSkills[]> {
  const supabase = await createClient();

  // Parallel fetch of independent base data
  const [
    { data: domains, error: domainErr },
    { data: skills, error: skillErr },
    { data: prereqs },
    { data: progressRows },
  ] = await Promise.all([
    supabase.from("domains").select("*").eq("is_published", true).order("sort_order"),
    supabase.from("skills").select("*").eq("is_published", true).order("sort_order"),
    supabase.from("skill_prerequisites").select("*"),
    userId
      ? supabase.from("user_skill_progress").select("*").eq("user_id", userId)
      : Promise.resolve({ data: null }),
  ]);

  if (domainErr || !domains) return [];
  if (skillErr || !skills) return [];

  // Build lookup maps
  const progressMap = new Map<string, import("@/lib/database.types").UserSkillProgress>();
  if (progressRows) {
    for (const p of progressRows) progressMap.set(p.skill_id, p);
  }

  const prereqMap = new Map<
    string,
    Array<{ prerequisite_skill_id: string; required_mastery: number | string }>
  >();
  for (const p of prereqs ?? []) {
    const list = prereqMap.get(p.skill_id) ?? [];
    list.push(p);
    prereqMap.set(p.skill_id, list);
  }

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
      (s) => s.accessState === "proficient" || s.accessState === "strong",
    ).length;
    const progressPercent =
      domainSkills.length > 0 ? Math.round((completedSkills / domainSkills.length) * 100) : 0;

    return {
      domain,
      skills: domainSkills,
      totalSkills: domainSkills.length,
      completedSkills,
      progressPercent,
    };
  });
});

/**
 * Get full skill detail for /skills/[slug] page.
 *
 * Cached per request to avoid duplicate fetches.
 */
export const getSkillDetail = cache(async function (
  slug: string,
  userId: string | null,
): Promise<SkillDetail | null> {
  const supabase = await createClient();
  const admin = getAdminClient();

  // Fetch skill first (needed for all subsequent queries)
  const { data: skill, error } = await supabase
    .from("skills")
    .select("*")
    .eq("slug", slug)
    .eq("is_published", true)
    .maybeSingle();

  if (error || !skill) return null;

  // Parallel fetch of domain, prereqs, all skills/domains maps, user progress, lessons
  const [
    { data: domain },
    { data: prereqRows },
    { data: allSkills },
    { data: allDomains },
    { data: progressRows },
    { data: lessons },
  ] = await Promise.all([
    supabase.from("domains").select("*").eq("id", skill.domain_id).maybeSingle(),
    supabase.from("skill_prerequisites").select("*").eq("skill_id", skill.id),
    supabase.from("skills").select("*"),
    supabase.from("domains").select("*"),
    userId
      ? supabase.from("user_skill_progress").select("*").eq("user_id", userId)
      : Promise.resolve({ data: null }),
    supabase.from("lessons").select("*").eq("skill_id", skill.id).eq("is_published", true).order("sort_order"),
  ]);

  if (!domain) return null;

  const progressMap = new Map<string, import("@/lib/database.types").UserSkillProgress>();
  if (progressRows) {
    for (const p of progressRows) progressMap.set(p.skill_id, p);
  }
  const userProgress = progressMap.get(skill.id) ?? null;

  const skillMap = new Map((allSkills ?? []).map((s) => [s.id, s]));
  const domainMap = new Map((allDomains ?? []).map((d) => [d.id, d]));

  const prerequisites = buildPrerequisiteStatuses(prereqRows ?? [], skillMap, domainMap, progressMap);
  const prerequisitesMet = prerequisites.every((p) => p.isMet);
  const accessState = getSkillAccessState(skill.id, userProgress, prerequisitesMet);

  // Lesson progress + practice tasks + quiz count (parallel)
  const lessonIds = lessons?.map((l) => l.id) ?? [];
  const [
    { data: lessonProgressRows },
    { data: practiceTasks },
    { count: quizCount },
  ] = await Promise.all([
    userId && lessonIds.length > 0
      ? supabase.from("user_lesson_progress").select("*").eq("user_id", userId).in("lesson_id", lessonIds)
      : Promise.resolve({ data: null }),
    supabase.from("practice_tasks").select("*").eq("skill_id", skill.id).eq("is_published", true),
    admin
      .from("quiz_questions")
      .select("*", { count: "exact", head: true })
      .eq("skill_id", skill.id)
      .eq("is_published", true),
  ]);

  const lessonProgressMap = new Map<string, import("@/lib/database.types").UserLessonProgress>();
  if (lessonProgressRows) {
    for (const lp of lessonProgressRows) lessonProgressMap.set(lp.lesson_id, lp);
  }

  const lessonsWithProgress = (lessons ?? []).map((l) => ({
    ...l,
    progress: lessonProgressMap.get(l.id) ?? null,
  }));

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
});
