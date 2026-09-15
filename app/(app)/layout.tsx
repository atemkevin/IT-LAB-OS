import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { AppShell } from "@/components/layout/app-shell";

/**
 * Layout for all authenticated routes under (app)/.
 * Reads the user from the server session and verifies onboarding completion.
 */
export default async function AuthenticatedLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect("/login");
  }

  // Verify onboarding status
  const { data: profile } = await supabase
    .from("profiles")
    .select("onboarding_done, display_name")
    .eq("id", user.id)
    .maybeSingle();

  if (!profile || !profile.onboarding_done) {
    redirect("/onboarding");
  }

  return (
    <AppShell email={profile.display_name || user.email}>
      {children}
    </AppShell>
  );
}
