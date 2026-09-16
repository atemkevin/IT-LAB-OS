/**
 * lib/learning/prerequisites.ts
 *
 * Prerequisite resolution and skill access state calculation.
 * Server-only (uses admin Supabase client for efficiency).
 */
import type { UserSkillProgress } from "@/lib/database.types";
import type { SkillAccessState, PrerequisiteStatus } from "./types";
import { calculateMasteryState } from "@/lib/mastery/calculateMastery";

/**
 * Determine skill access state from user progress and whether prerequisites are met.
 */
export function getSkillAccessState(
  skillId: string,
  userProgress: UserSkillProgress | null,
  prerequisitesMet: boolean
): SkillAccessState {
  if (!prerequisitesMet) return "locked";

  if (!userProgress || userProgress.mastery_score === 0) {
    return "available";
  }

  const state = calculateMasteryState(Number(userProgress.mastery_score));
  switch (state) {
    case "strong":
      return "strong";
    case "proficient":
      return "proficient";
    case "practicing":
      return "practicing";
    case "developing":
      return "in_progress";
    default:
      return "available";
  }
}

/**
 * Check if all prerequisites for a skill are met given a user progress map.
 *
 * @param prerequisiteRows - The skill_prerequisites rows for this skill
 * @param progressMap - Map of skill_id to UserSkillProgress
 */
export function arePrerequisitesMet(
  prerequisiteRows: Array<{ prerequisite_skill_id: string; required_mastery: number | string }>,
  progressMap: Map<string, UserSkillProgress>
): boolean {
  for (const prereq of prerequisiteRows) {
    const progress = progressMap.get(prereq.prerequisite_skill_id);
    const currentMastery = progress ? Number(progress.mastery_score) : 0;
    const required = Number(prereq.required_mastery);
    if (currentMastery < required) return false;
  }
  return true;
}

/**
 * Build PrerequisiteStatus array for display on skill detail page.
 */
export function buildPrerequisiteStatuses(
  prerequisiteRows: Array<{
    prerequisite_skill_id: string;
    required_mastery: number | string;
  }>,
  skillMap: Map<string, { id: string; name: string; slug: string; domain_id: string; description: string | null; why_it_matters: string | null; difficulty: string; estimated_minutes: number; learning_objectives: unknown; tags: unknown; sort_order: number; is_published: boolean; created_at: string }>,
  domainMap: Map<string, { id: string; slug: string; name: string; description: string | null; sort_order: number; icon: string | null; is_published: boolean; created_at: string }>,
  progressMap: Map<string, UserSkillProgress>
): PrerequisiteStatus[] {
  return prerequisiteRows.map((prereq) => {
    const skill = skillMap.get(prereq.prerequisite_skill_id);
    const domain = skill ? domainMap.get(skill.domain_id) : undefined;
    const progress = progressMap.get(prereq.prerequisite_skill_id);
    const currentMastery = progress ? Number(progress.mastery_score) : 0;
    const required = Number(prereq.required_mastery);

    return {
      skill: skill as PrerequisiteStatus["skill"],
      domain: domain as PrerequisiteStatus["domain"],
      isMet: currentMastery >= required,
      requiredMastery: required,
      currentMastery,
    };
  });
}
