import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { ProfileEditor } from "@/app/(app)/profile/profile-editor";

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
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">Learner Profile</h1>
        <p className="text-sm text-[var(--color-text-tertiary)]">
          Manage your learning goals, target pace, and environment preferences.
        </p>
      </div>

      <ProfileEditor initialProfile={profile} email={user.email || ""} />
    </div>
  );
}
