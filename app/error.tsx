"use client";

import { useEffect } from "react";

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    // Log to error reporting service in production
    console.error(error);
  }, [error]);

  return (
    <html lang="en" className="dark">
      <body className="antialiased">
        <div className="flex min-h-screen items-center justify-center bg-[#0d0f14]">
          <div className="text-center">
            <p className="text-4xl font-bold text-[#6b7999]">Error</p>
            <h1 className="mt-4 text-xl font-semibold text-[#f0f4ff]">
              Something went wrong
            </h1>
            <p className="mt-2 text-sm text-[#6b7999]">
              An unexpected error occurred. Please try again.
            </p>
            {error.digest && (
              <p className="mt-1 font-mono text-xs text-[#3d4d6b]">
                Error ID: {error.digest}
              </p>
            )}
            <button
              onClick={reset}
              className="mt-6 rounded-lg bg-[#4f8ef7] px-4 py-2 text-sm font-medium text-white transition-colors hover:bg-[#6ba3ff]"
            >
              Try again
            </button>
          </div>
        </div>
      </body>
    </html>
  );
}
