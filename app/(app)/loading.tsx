import { Skeleton } from "@/components/ui/skeleton";

/**
 * Shared loading skeleton for all authenticated app routes.
 * Mirrors the AppShell layout so the transition feels seamless.
 */
export default function AppLoading() {
  return (
    <div className="min-h-screen bg-[var(--color-base)]">
      {/* Desktop sidebar skeleton */}
      <aside className="fixed inset-y-0 left-0 z-30 hidden w-[var(--sidebar-width)] flex-col border-r border-[var(--color-border)] bg-[var(--color-surface)] lg:flex">
        <div className="flex h-[var(--topbar-height)] items-center gap-2.5 border-b border-[var(--color-border)] px-4">
          <Skeleton className="h-8 w-8 rounded-lg" />
          <div className="space-y-1">
            <Skeleton className="h-3.5 w-20" />
            <Skeleton className="h-2.5 w-14" />
          </div>
        </div>
        <nav className="flex-1 overflow-y-auto p-3 space-y-4">
          {Array.from({ length: 8 }).map((_, i) => (
            <Skeleton key={i} className="h-9 w-full rounded-lg" />
          ))}
        </nav>
        <div className="border-t border-[var(--color-border)] p-3 space-y-2">
          {Array.from({ length: 3 }).map((_, i) => (
            <Skeleton key={i} className="h-9 w-full rounded-lg" />
          ))}
        </div>
      </aside>

      {/* Topbar skeleton */}
      <header className="fixed inset-x-0 top-0 z-20 flex h-[var(--topbar-height)] items-center border-b border-[var(--color-border)] bg-[var(--color-surface)] px-4 lg:left-[var(--sidebar-width)]">
        <div className="flex items-center gap-2 lg:hidden">
          <Skeleton className="h-7 w-7 rounded-lg" />
          <Skeleton className="h-4 w-24" />
        </div>
        <div className="ml-auto flex items-center gap-3">
          <Skeleton className="hidden h-3.5 w-32 rounded sm:block" />
          <Skeleton className="h-8 w-20 rounded-lg" />
        </div>
      </header>

      {/* Main content skeleton */}
      <main className="min-h-screen pt-[var(--topbar-height)] pb-20 lg:pb-0 lg:pl-[var(--sidebar-width)]">
        <div className="mx-auto max-w-7xl p-4 sm:p-6 space-y-6">
          {/* Header skeleton */}
          <div className="space-y-2">
            <Skeleton className="h-8 w-48" />
            <Skeleton className="h-4 w-72" />
          </div>

          {/* Metrics row skeleton */}
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
            {Array.from({ length: 4 }).map((_, i) => (
              <div key={i} className="rounded-lg border border-[var(--color-border)] bg-[var(--color-surface)] p-4">
                <div className="flex items-center gap-3">
                  <Skeleton className="h-10 w-10 rounded-lg" />
                  <div className="space-y-1.5">
                    <Skeleton className="h-3 w-20" />
                    <Skeleton className="h-6 w-12" />
                  </div>
                </div>
              </div>
            ))}
          </div>

          {/* Content cards skeleton */}
          <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
            <div className="lg:col-span-2 space-y-4 rounded-lg border border-[var(--color-border)] bg-[var(--color-surface)] p-5">
              <Skeleton className="h-5 w-40" />
              <Skeleton className="h-4 w-64" />
              <Skeleton className="h-24 w-full rounded-lg" />
              <div className="flex gap-3">
                <Skeleton className="h-9 w-28 rounded-lg" />
                <Skeleton className="h-9 w-36 rounded-lg" />
              </div>
            </div>
            <div className="space-y-4 rounded-lg border border-[var(--color-border)] bg-[var(--color-surface)] p-5">
              <Skeleton className="h-5 w-28" />
              <Skeleton className="h-4 w-48" />
              {Array.from({ length: 3 }).map((_, i) => (
                <Skeleton key={i} className="h-12 w-full rounded-lg" />
              ))}
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
