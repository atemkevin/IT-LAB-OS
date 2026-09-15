import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { AppShell } from "@/components/layout/app-shell";

/**
 * Layout for all authenticated routes under (app)/.
 * Reads the user from the server session.
 * Middleware already guards this layout — this is a secondary safety check.
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

  return <AppShell email={user.email}>{children}</AppShell>;
}
