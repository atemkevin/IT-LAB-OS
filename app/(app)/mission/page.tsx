/**
 * /mission — Daily Mission
 * Server Component. Fetches or generates today's mission.
 */
import { createClient } from "@/lib/supabase/server";
import { getTodayMissionWithProgress } from "@/lib/learning/missions";
import MissionClient from "./mission-client";
import type { MissionData, MissionTask } from "@/lib/learning/missions";
import type { MissionTaskProgress } from "@/lib/database.types";

export default async function DailyMissionPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">Daily Mission</h1>
          <p className="text-sm text-[var(--color-text-tertiary)]">
            Sign in to receive your personalized daily mission.
          </p>
        </div>
      </div>
    );
  }

  const { mission, taskProgress } = await getTodayMissionWithProgress(user.id);

  return (
    <MissionClient
      mission={mission}
      taskProgress={taskProgress as MissionTaskProgress[]}
    />
  );
}

// Re-export type for client component
export type { MissionData, MissionTask };
