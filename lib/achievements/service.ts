import { createNotification } from "@/lib/notifications/service";
import { SupabaseClient } from "@supabase/supabase-js";

export async function evaluateAchievements(supabase: SupabaseClient, userId: string) {

  // 1. Fetch current achievements
  const { data: userAchievements } = await supabase
    .from("user_achievements")
    .select("achievement_id")
    .eq("user_id", userId);

  const earnedSet = new Set(userAchievements?.map((a) => a.achievement_id) || []);
  const newlyEarned: string[] = [];

  // 2. Fetch user stats for evaluation
  const { data: profile } = await supabase
    .from("profiles")
    .select("current_streak, longest_streak")
    .eq("id", userId)
    .single();

  const { data: progress } = await supabase
    .from("user_skill_progress")
    .select("troubleshooting_score, mastery_score")
    .eq("user_id", userId);

  // Stats aggregation
  const totalTroubleshooting = progress?.reduce((acc, curr) => acc + curr.troubleshooting_score, 0) || 0;
  const totalMastery = progress?.reduce((acc, curr) => acc + curr.mastery_score, 0) || 0;
  const currentStreak = profile?.current_streak || 0;

  // 3. Evaluate criteria
  
  // 'first_lab': Earned if they have any troubleshooting score
  if (!earnedSet.has("first_lab") && totalTroubleshooting > 0) {
    newlyEarned.push("first_lab");
  }

  // 'streak_3': 3 day streak
  if (!earnedSet.has("streak_3") && currentStreak >= 3) {
    newlyEarned.push("streak_3");
  }

  // 'streak_7': 7 day streak
  if (!earnedSet.has("streak_7") && currentStreak >= 7) {
    newlyEarned.push("streak_7");
  }

  // 'mastery_10': Total mastery > 10
  if (!earnedSet.has("mastery_10") && totalMastery >= 10) {
    newlyEarned.push("mastery_10");
  }

  // 4. Grant new achievements
  if (newlyEarned.length > 0) {
    const inserts = newlyEarned.map((id) => ({
      user_id: userId,
      achievement_id: id,
    }));

    const { error } = await supabase.from("user_achievements").insert(inserts);

    if (!error) {
      // 5. Fetch names and notify user
      const { data: achievements } = await supabase
        .from("achievements")
        .select("id, name")
        .in("id", newlyEarned);

      for (const ach of achievements || []) {
        await createNotification(
          supabase,
          userId,
          "achievement",
          `Achievement Unlocked: ${ach.name}`,
          "Check out your profile to view your new badge!",
          "/profile"
        );
      }
    }
  }
}
