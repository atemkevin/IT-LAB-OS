import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";

/**
 * Onboarding Layout:
 * - Guards against unauthenticated access (redirects to /login)
 * - Guards against completed users re-entering onboarding (redirects to /dashboard)
 */
export default async function OnboardingLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect("/login?redirectTo=/onboarding");
  }

  const { data: profile } = await supabase
    .from("profiles")
    .select("onboarding_done")
    .eq("id", user.id)
    .maybeSingle();

  if (profile?.onboarding_done) {
    redirect("/dashboard");
  }

  return <div className="min-h-screen bg-[var(--color-base)]">{children}</div>;
}
