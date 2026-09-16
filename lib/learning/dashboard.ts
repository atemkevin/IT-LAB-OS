/**
 * lib/learning/dashboard.ts
 *
 * Dashboard metrics fetching. Server-only.
 */
import { createClient } from "@/lib/supabase/server";
import { todayString } from "@/lib/utils";

export interface DashboardMetrics {
  overallMastery: number;
  skillsInProgress: number;
  totalSkills: number;
  dailyMission: {
    title: string;
    objective: string;
    durationMinutes: number;
    status: string;
  } | null;
  learningTimeMinutes: number;
  recommendedSkill: string | null;
}

/**
 * Fetch real dashboard metrics for the authenticated user.
 */
export async function getDashboardMetrics(userId: string): Promise<DashboardMetrics> {
  const supabase = await createClient();

  // Parallel fetch of all metric sources
  const [
    { data: skillProgress },
    { data: todayMission },
    { data: sessions },
    { data: profile },
    { data: allPublishedSkills },
  ] = await Promise.all([
    supabase.from("user_skill_progress").select("mastery_score, mastery_state").eq("user_id", userId),
    supabase
      .from("daily_missions")
      .select("title, objective, duration_minutes, status")
      .eq("user_id", userId)
      .eq("mission_date", todayString())
      .maybeSingle(),
    supabase.from("learning_sessions").select("duration_seconds").eq("user_id", userId),
    supabase.from("profiles").select("environment").eq("id", userId).maybeSingle(),
    supabase.from("skills").select("id").eq("is_published", true),
  ]);

  const progressRows = skillProgress ?? [];
  const totalSkills = allPublishedSkills?.length ?? 0;

  // Overall mastery: average of all skill mastery scores
  const overallMastery =
    progressRows.length > 0
      ? Math.round(
          progressRows.reduce((sum, r) => sum + (r.mastery_score ?? 0), 0) / progressRows.length
        )
      : 0;

  // Skills actively in progress (not not_started)
  const skillsInProgress = progressRows.filter(
    (r) => r.mastery_state && r.mastery_state !== "not_started"
  ).length;

  // Learning time: sum of all completed sessions (minutes)
  const learningTimeMinutes =
    (sessions ?? []).reduce((sum, s) => sum + (s.duration_seconds ?? 0), 0) / 60;

  // Recommended skill from onboarding profile
  const recommendedSkill =
    profile?.environment && typeof profile.environment === "object"
      ? (profile.environment as Record<string, unknown>).recommendedFirstSkill?.toString() ?? null
      : null;

  return {
    overallMastery,
    skillsInProgress,
    totalSkills,
    dailyMission: todayMission
      ? {
          title: todayMission.title,
          objective: todayMission.objective ?? "",
          durationMinutes: todayMission.duration_minutes,
          status: todayMission.status,
        }
      : null,
    learningTimeMinutes: Math.round(learningTimeMinutes),
    recommendedSkill,
  };
}

export interface MasteryDistribution {
  strong: number;
  proficient: number;
  practicing: number;
  developing: number;
  notStarted: number;
}

export interface ProgressMetrics {
  knowledgeAvg: number;
  practiceAvg: number;
  troubleshootingAvg: number;
  projectAvg: number;
  retentionAvg: number;
  distribution: MasteryDistribution;
}

/**
 * Fetch progress analytics for the authenticated user.
 */
export async function getProgressMetrics(userId: string): Promise<ProgressMetrics> {
  const supabase = await createClient();

  const { data: progressRows } = await supabase
    .from("user_skill_progress")
    .select("knowledge_score, practice_score, troubleshooting_score, project_score, retention_score, mastery_state")
    .eq("user_id", userId);

  const rows = progressRows ?? [];

  const avg = (key: keyof typeof rows[number]) =>
    rows.length > 0
      ? Math.round(rows.reduce((sum, r) => sum + ((r[key] as number) ?? 0), 0) / rows.length)
      : 0;

  const distribution: MasteryDistribution = {
    strong: rows.filter((r) => r.mastery_state === "strong").length,
    proficient: rows.filter((r) => r.mastery_state === "proficient").length,
    practicing: rows.filter((r) => r.mastery_state === "practicing").length,
    developing: rows.filter((r) => r.mastery_state === "developing").length,
    notStarted: rows.filter((r) => !r.mastery_state || r.mastery_state === "not_started").length,
  };

  return {
    knowledgeAvg: avg("knowledge_score"),
    practiceAvg: avg("practice_score"),
    troubleshootingAvg: avg("troubleshooting_score"),
    projectAvg: avg("project_score"),
    retentionAvg: avg("retention_score"),
    distribution,
  };
}
