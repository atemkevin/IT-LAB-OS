import Link from "next/link";
import { Menu } from "lucide-react";
import { SignOutButton } from "@/components/layout/sign-out-button";

interface TopbarProps {
  email?: string | null;
}

export function Topbar({ email }: TopbarProps) {
  return (
    <header
      className="fixed inset-x-0 top-0 z-20 flex h-[var(--topbar-height)] items-center border-b border-[var(--color-border)] bg-[var(--color-surface)] px-4 lg:left-[var(--sidebar-width)]"
      role="banner"
    >
      {/* Mobile logo — shown only on mobile */}
      <div className="flex items-center gap-2 lg:hidden">
        <div className="flex h-7 w-7 items-center justify-center rounded-lg bg-[var(--color-brand)]">
          <span className="text-xs font-bold text-white">IT</span>
        </div>
        <span className="text-sm font-semibold text-[var(--color-text-primary)]">
          IT Lab OS
        </span>
      </div>

      <div className="ml-auto flex items-center gap-3">
        {email && (
          <Link
            href="/profile"
            className="hidden text-xs text-[var(--color-text-secondary)] hover:text-[var(--color-brand)] transition-colors sm:block"
          >
            {email}
          </Link>
        )}
        <SignOutButton />
      </div>
    </header>
  );
}
