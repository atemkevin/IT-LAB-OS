import { getAdminClient } from "@/lib/supabase/admin";
import { calculateMasteryState, MASTERY_LABELS } from "@/lib/mastery/calculateMastery";
import { createHash } from "crypto";

export interface PublicLearnerProfile {
  id: string;
  displayName: string;
  avatarUrl: string | null;
  primaryGoal: string | null;
  currentStreak: number;
  longestStreak: number;
  memberSince: string;
}

export interface PublicSkillEntry {
  name: string;
  slug: string;
  difficulty: string;
  masteryScore: number;
  masteryState: string;
}

export interface PublicDomainGroup {
  name: string;
  slug: string;
  skills: PublicSkillEntry[];
}

export interface PublicAchievementEntry {
  id: string;
  name: string;
  description: string;
  icon: string | null;
  earnedAt: string;
}

export interface PublicLabEntry {
  title: string;
  slug: string;
  difficulty: string;
  completedAt: string;
}

export interface PublicPortfolioData {
  learner: PublicLearnerProfile;
  metrics: {
    overallMastery: number;
    masteryTier: string;
    totalSkillsLearned: number;
    totalAchievements: number;
    totalLabsSolved: number;
  };
  domains: PublicDomainGroup[];
  achievements: PublicAchievementEntry[];
  labsSolved: PublicLabEntry[];
  verificationSignature: string;
}

export async function getPublicPortfolio(userId: string): Promise<PublicPortfolioData | null> {
  const admin = getAdminClient();

  // 1. Fetch Profile
  const { data: profile, error: profileErr } = await admin
    .from("profiles")
    .select("id, display_name, avatar_url, primary_goal, current_streak, longest_streak, created_at, onboarding_done")
    .eq("id", userId)
    .maybeSingle();

  if (profileErr || !profile) {
    return null;
  }

  // 2. Fetch User Achievements
  const { data: userAchievements } = await admin
    .from("user_achievements")
    .select("achievement_id, earned_at, achievements(id, name, description, icon)")
    .eq("user_id", userId)
    .order("earned_at", { ascending: false });

  // 3. Fetch Skills & Skill Progress
  const [{ data: domains }, { data: skills }, { data: skillProgress }] = await Promise.all([
    admin.from("domains").select("id, name, slug, sort_order").eq("is_published", true).order("sort_order"),
    admin.from("skills").select("id, domain_id, name, slug, difficulty, sort_order").eq("is_published", true).order("sort_order"),
    admin.from("user_skill_progress").select("skill_id, mastery_score, mastery_state").eq("user_id", userId),
  ]);

  // 4. Fetch Solved Troubleshooting Labs
  const { data: solvedAttempts } = await admin
    .from("troubleshooting_attempts")
    .select("completed_at, troubleshooting_scenarios(title, slug, difficulty)")
    .eq("user_id", userId)
    .eq("resolved", true)
    .order("completed_at", { ascending: false });

  // Map progress lookup
  const progressMap = new Map<string, { mastery_score: number; mastery_state: string }>();
  for (const sp of skillProgress || []) {
    progressMap.set(sp.skill_id, {
      mastery_score: sp.mastery_score,
      mastery_state: sp.mastery_state,
    });
  }

  // Group skills by domain
  const domainGroups: PublicDomainGroup[] = [];
  const domainMap = new Map<string, PublicSkillEntry[]>();

  for (const s of skills || []) {
    const p = progressMap.get(s.id);
    const entry: PublicSkillEntry = {
      name: s.name,
      slug: s.slug,
      difficulty: s.difficulty,
      masteryScore: p?.mastery_score ?? 0,
      masteryState: p?.mastery_state ?? "not_started",
    };

    if (!domainMap.has(s.domain_id)) {
      domainMap.set(s.domain_id, []);
    }
    domainMap.get(s.domain_id)!.push(entry);
  }

  for (const d of domains || []) {
    const dSkills = domainMap.get(d.id) || [];
    if (dSkills.length > 0) {
      domainGroups.push({
        name: d.name,
        slug: d.slug,
        skills: dSkills,
      });
    }
  }

  // Format Achievements
  const achievementsList: PublicAchievementEntry[] = [];
  for (const ua of userAchievements || []) {
    const a = ua.achievements as any;
    if (a) {
      achievementsList.push({
        id: a.id,
        name: a.name,
        description: a.description,
        icon: a.icon,
        earnedAt: ua.earned_at,
      });
    }
  }

  // Format Solved Labs
  const labsList: PublicLabEntry[] = [];
  const seenScenarios = new Set<string>();
  for (const att of solvedAttempts || []) {
    const sc = att.troubleshooting_scenarios as any;
    if (sc && !seenScenarios.has(sc.slug)) {
      seenScenarios.add(sc.slug);
      labsList.push({
        title: sc.title,
        slug: sc.slug,
        difficulty: sc.difficulty,
        completedAt: att.completed_at || new Date().toISOString(),
      });
    }
  }

  // Compute Overall Metrics
  const scores = Array.from(progressMap.values()).map((v) => v.mastery_score);
  const totalSkillsLearned = scores.filter((s) => s > 0).length;
  const overallMastery = scores.length > 0 ? Math.round(scores.reduce((a, b) => a + b, 0) / (skills?.length || 1)) : 0;
  const masteryTier = MASTERY_LABELS[calculateMasteryState(overallMastery)];

  // Compute verification signature (SHA-256)
  const rawPayload = `${userId}:${overallMastery}:${totalSkillsLearned}:${achievementsList.length}:${labsList.length}`;
  const verificationSignature = createHash("sha256").update(rawPayload).digest("hex").substring(0, 16).toUpperCase();

  return {
    learner: {
      id: profile.id,
      displayName: profile.display_name || "Anonymous Learner",
      avatarUrl: profile.avatar_url,
      primaryGoal: profile.primary_goal,
      currentStreak: profile.current_streak || 0,
      longestStreak: profile.longest_streak || 0,
      memberSince: profile.created_at,
    },
    metrics: {
      overallMastery,
      masteryTier,
      totalSkillsLearned,
      totalAchievements: achievementsList.length,
      totalLabsSolved: labsList.length,
    },
    domains: domainGroups,
    achievements: achievementsList,
    labsSolved: labsList,
    verificationSignature,
  };
}
