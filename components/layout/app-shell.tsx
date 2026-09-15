import { Sidebar } from "@/components/layout/sidebar";
import { Topbar } from "@/components/layout/topbar";
import { MobileNav } from "@/components/layout/mobile-nav";

interface AppShellProps {
  children: React.ReactNode;
  email?: string | null;
}

/**
 * AppShell — wraps all authenticated pages.
 * Layout: fixed sidebar (desktop) + fixed topbar + scrollable main content.
 * Mobile: no sidebar, fixed bottom navigation instead.
 */
export function AppShell({ children, email }: AppShellProps) {
  return (
    <div className="min-h-screen bg-[var(--color-base)]">
      {/* Desktop sidebar */}
      <Sidebar />

      {/* Topbar */}
      <Topbar email={email} />

      {/* Main content area */}
      <main
        className="min-h-screen pt-[var(--topbar-height)] pb-20 lg:pb-0 lg:pl-[var(--sidebar-width)]"
        id="main-content"
        tabIndex={-1}
      >
        <div className="mx-auto max-w-7xl p-4 sm:p-6">{children}</div>
      </main>

      {/* Mobile bottom nav */}
      <MobileNav />
    </div>
  );
}
