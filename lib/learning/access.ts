/**
 * lib/learning/access.ts
 *
 * Full skill access state map — used by /learn page.
 * Server-only.
 */
import { createClient } from "@/lib/supabase/server";
import { getSkillAccessState, arePrerequisitesMet } from "./prerequisites";
import type { SkillAccessState } from "./types";

/**
 * Returns a map of skill_id -> SkillAccessState for all published skills.
 * Efficient: single query for prereqs + single query for progress.
 */
export async function getSkillAccessMap(
  userId: string | null
): Promise<Map<string, SkillAccessState>> {
  const supabase = await createClient();

  const { data: skills } = await supabase
    .from("skills")
    .select("id")
    .eq("is_published", true);

  if (!skills?.length) return new Map();

  const { data: prereqs } = await supabase.from("skill_prerequisites").select("*");

  let progressMap = new Map<string, import("@/lib/database.types").UserSkillProgress>();
  if (userId) {
    const { data: progressRows } = await supabase
      .from("user_skill_progress")
      .select("*")
      .eq("user_id", userId);
    if (progressRows) {
      for (const p of progressRows) progressMap.set(p.skill_id, p);
    }
  }

  // Group prereqs by skill_id
  const prereqMap = new Map<string, Array<{ prerequisite_skill_id: string; required_mastery: number | string }>>();
  for (const p of prereqs ?? []) {
    const list = prereqMap.get(p.skill_id) ?? [];
    list.push(p);
    prereqMap.set(p.skill_id, list);
  }

  const accessMap = new Map<string, SkillAccessState>();
  for (const skill of skills) {
    const skillPrereqs = prereqMap.get(skill.id) ?? [];
    const met = arePrerequisitesMet(skillPrereqs, progressMap);
    const progress = progressMap.get(skill.id) ?? null;
    accessMap.set(skill.id, getSkillAccessState(skill.id, progress, met));
  }

  return accessMap;
}
