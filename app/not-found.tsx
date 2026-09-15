export default function NotFound() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-[var(--color-base)]">
      <div className="text-center">
        <p className="text-5xl font-bold text-[var(--color-text-disabled)]">404</p>
        <h1 className="mt-4 text-xl font-semibold text-[var(--color-text-primary)]">
          Page not found
        </h1>
        <p className="mt-2 text-sm text-[var(--color-text-tertiary)]">
          The page you are looking for does not exist.
        </p>
        <a
          href="/dashboard"
          className="mt-6 inline-block rounded-lg bg-[var(--color-brand)] px-4 py-2 text-sm font-medium text-white transition-colors hover:bg-[var(--color-brand-hover)]"
        >
          Go to Dashboard
        </a>
      </div>
    </div>
  );
}
