/**
 * lib/ai/context.ts
 *
 * Builds the structured learner context block injected into the AI system prompt.
 * Fetches mastery data, profile info, recent activity, and today's mission.
 * Server-only.
 */
import { createClient } from "@/lib/supabase/server";
import { todayString } from "@/lib/utils";

export interface SkillSnapshot {
  name: string;
  masteryScore: number;
  masteryState: string;
}

export interface ActivitySnapshot {
  type: string;
  skillName: string;
  score: number;
  createdAt: string;
}

export interface UserContext {
  hasProfile: boolean;
  experienceLevel: string;
  primaryGoal: string;
  dailyMinutes: number;
  overallMastery: number;
  skillsInProgress: number;
  totalSkills: number;
  recommendedSkill: string | null;
  weakSkills: SkillSnapshot[];
  strongSkills: SkillSnapshot[];
  todayMission: { title: string; status: string } | null;
  recentActivity: ActivitySnapshot[];
}

/**
 * Load structured learner context for the AI system prompt.
 * Returns a safe empty context if the user has no profile yet.
 */
export async function loadUserContext(userId: string): Promise<UserContext> {
  const supabase = await createClient();

  const [
    profileRes,
    skillProgressRes,
    skillsRes,
    missionRes,
    activityRes,
  ] = await Promise.all([
    supabase
      .from("profiles")
      .select("experience_level, primary_goal, daily_minutes, environment, onboarding_done")
      .eq("id", userId)
      .maybeSingle(),
    supabase
      .from("user_skill_progress")
      .select("skill_id, mastery_score, mastery_state")
      .eq("user_id", userId),
    supabase.from("skills").select("id, name").eq("is_published", true),
    supabase
      .from("daily_missions")
      .select("title, status")
      .eq("user_id", userId)
      .eq("mission_date", todayString())
      .maybeSingle(),
    supabase
      .from("mastery_evidence")
      .select("evidence_type, score, skill_id, created_at")
      .eq("user_id", userId)
      .order("created_at", { ascending: false })
      .limit(10),
  ]);

  const profile = profileRes.data;
  if (!profile?.onboarding_done) {
    return emptyContext();
  }

  const env =
    profile.environment && typeof profile.environment === "object"
      ? (profile.environment as Record<string, unknown>)
      : {};

  const progressRows = skillProgressRes.data ?? [];
  const skillsMap = new Map((skillsRes.data ?? []).map((s: { id: string; name: string }) => [s.id, s.name]));

  // Enrich progress with skill names
  const enriched = progressRows.map((r) => ({
    name: skillsMap.get(r.skill_id) ?? "Unknown Skill",
    masteryScore: Math.round(Number(r.mastery_score) ?? 0),
    masteryState: r.mastery_state ?? "not_started",
  }));

  // Sort by mastery score
  const sorted = [...enriched].sort((a, b) => a.masteryScore - b.masteryScore);
  const weakSkills = sorted.filter((s) => s.masteryState !== "not_started").slice(0, 5);
  const strongSkills = [...enriched]
    .filter((s) => s.masteryState === "proficient" || s.masteryState === "strong")
    .sort((a, b) => b.masteryScore - a.masteryScore)
    .slice(0, 3);

  const overallMastery =
    enriched.length > 0
      ? Math.round(enriched.reduce((sum, s) => sum + s.masteryScore, 0) / enriched.length)
      : 0;

  // Map activity to snapshots
  const activityRows = (activityRes.data ?? []) as Array<{
    evidence_type: string;
    score: number;
    skill_id: string;
    created_at: string;
  }>;
  const recentActivity: ActivitySnapshot[] = activityRows.map((a) => ({
    type: a.evidence_type,
    skillName: skillsMap.get(a.skill_id) ?? "Unknown Skill",
    score: Math.round(Number(a.score) ?? 0),
    createdAt: a.created_at,
  }));

  const todayMission = missionRes.data
    ? { title: missionRes.data.title, status: missionRes.data.status }
    : null;

  return {
    hasProfile: true,
    experienceLevel: profile.experience_level ?? "unknown",
    primaryGoal: profile.primary_goal ?? "general",
    dailyMinutes: profile.daily_minutes ?? 60,
    overallMastery,
    skillsInProgress: enriched.filter((s) => s.masteryState !== "not_started").length,
    totalSkills: (skillsRes.data ?? []).length,
    recommendedSkill: (env.recommendedFirstSkill as string) ?? null,
    weakSkills,
    strongSkills,
    todayMission,
    recentActivity,
  };
}

function emptyContext(): UserContext {
  return {
    hasProfile: false,
    experienceLevel: "unknown",
    primaryGoal: "unknown",
    dailyMinutes: 60,
    overallMastery: 0,
    skillsInProgress: 0,
    totalSkills: 0,
    recommendedSkill: null,
    weakSkills: [],
    strongSkills: [],
    todayMission: null,
    recentActivity: [],
  };
}
