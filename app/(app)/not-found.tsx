import Link from "next/link";
import { ArrowLeft } from "lucide-react";

/**
 * Not found page for authenticated app routes.
 * Rendered inside the AppShell via the (app) layout.
 */
export default function AppNotFound() {
  return (
    <div className="flex min-h-[60vh] flex-col items-center justify-center rounded-lg border border-[var(--color-border)] bg-[var(--color-surface)] p-8 text-center">
      <p className="text-6xl font-bold text-[var(--color-text-disabled)]">404</p>
      <h1 className="mt-4 text-xl font-semibold text-[var(--color-text-primary)]">
        Page not found
      </h1>
      <p className="mt-2 max-w-sm text-sm text-[var(--color-text-tertiary)]">
        The page you are looking for does not exist or may have been moved.
      </p>
      <div className="mt-6 flex items-center gap-3">
        <Link
          href="/dashboard"
          className="inline-flex items-center gap-1.5 rounded-lg bg-[var(--color-brand)] px-4 py-2 text-sm font-medium text-white transition-colors hover:bg-[var(--color-brand-hover)]"
        >
          <ArrowLeft className="h-4 w-4" />
          Back to Dashboard
        </Link>
      </div>
    </div>
  );
}
