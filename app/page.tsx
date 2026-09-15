import { redirect } from "next/navigation";

/**
 * Root page: redirect unauthenticated users to login,
 * authenticated users land on the dashboard.
 * Actual auth check is in middleware.
 */
export default function RootPage() {
  redirect("/dashboard");
}
