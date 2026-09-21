import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { ProfileEditor } from "@/app/(app)/profile/profile-editor";
import { AchievementsGrid } from "@/components/profile/achievements-grid";

import Link from "next/link";
import { Button } from "@/components/ui/button";
import { ExternalLink } from "lucide-react";

export default async function ProfilePage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect("/login");
  }

  const { data: profile } = await supabase
    .from("profiles")
    .select("*")
    .eq("id", user.id)
    .maybeSingle();

  return (
    <div className="space-y-10 pb-10">
      <div className="space-y-6">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
          <div>
            <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">Learner Profile</h1>
            <p className="text-sm text-[var(--color-text-tertiary)]">
              Manage your learning goals, target pace, and environment preferences.
            </p>
          </div>
          <Link href={`/portfolio/${user.id}`} target="_blank">
            <Button variant="secondary" className="gap-2 text-xs">
              <ExternalLink className="h-3.5 w-3.5" />
              View Public Portfolio
            </Button>
          </Link>
        </div>

        <ProfileEditor initialProfile={profile} email={user.email || ""} />
      </div>

      <div className="space-y-4 pt-6 border-t border-[var(--color-border)]">
        <div>
          <h2 className="text-xl font-bold text-[var(--color-text-primary)]">Achievements</h2>
          <p className="text-sm text-[var(--color-text-tertiary)] mb-4">
            Badges earned through your progress and mastery.
          </p>
        </div>
        <AchievementsGrid userId={user.id} />
      </div>
    </div>
  );
}
