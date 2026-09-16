"use client";

import { useEffect } from "react";

/**
 * Error boundary for authenticated app routes.
 * Renders inside the app shell context with a retry action.
 */
export default function AppError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error("[app-error]", error);
  }, [error]);

  return (
    <div className="flex min-h-[60vh] flex-col items-center justify-center rounded-lg border border-[var(--color-border)] bg-[var(--color-surface)] p-8 text-center">
      <div className="flex h-12 w-12 items-center justify-center rounded-full bg-[var(--color-negative-soft)] text-[var(--color-negative)]">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="24"
          height="24"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
          aria-hidden="true"
        >
          <circle cx="12" cy="12" r="10" />
          <line x1="12" x2="12" y1="8" y2="12" />
          <line x1="12" x2="12.01" y1="16" y2="16" />
        </svg>
      </div>
      <h2 className="mt-4 text-lg font-semibold text-[var(--color-text-primary)]">
        Something went wrong
      </h2>
      <p className="mt-1 text-sm text-[var(--color-text-tertiary)]">
        An unexpected error occurred while loading this page.
      </p>
      {error.digest && (
        <p className="mt-2 font-mono text-xs text-[var(--color-text-disabled)]">
          Error ID: {error.digest}
        </p>
      )}
      <div className="mt-6 flex items-center gap-3">
        <button
          onClick={reset}
          className="rounded-lg bg-[var(--color-brand)] px-4 py-2 text-sm font-medium text-white transition-colors hover:bg-[var(--color-brand-hover)]"
        >
          Try again
        </button>
        <a
          href="/dashboard"
          className="rounded-lg border border-[var(--color-border)] px-4 py-2 text-sm font-medium text-[var(--color-text-secondary)] transition-colors hover:bg-[var(--color-surface-raised)]"
        >
          Go to Dashboard
        </a>
      </div>
    </div>
  );
}
