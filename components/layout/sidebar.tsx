"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { cn } from "@/lib/utils";
import { primaryNav, secondaryNav } from "@/lib/nav-data";

export function Sidebar() {
  const pathname = usePathname();

  function isActive(href: string) {
    if (href === "/dashboard") return pathname === href;
    return pathname.startsWith(href);
  }

  return (
    <aside
      className="fixed inset-y-0 left-0 z-30 hidden w-[var(--sidebar-width)] flex-col border-r border-[var(--color-border)] bg-[var(--color-surface)] lg:flex"
      aria-label="Primary navigation"
    >
      {/* Logo */}
      <div className="flex h-[var(--topbar-height)] items-center gap-2.5 border-b border-[var(--color-border)] px-4">
        <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-[var(--color-brand)]">
          <span className="text-sm font-bold text-white">IT</span>
        </div>
        <div>
          <p className="text-sm font-semibold text-[var(--color-text-primary)]">
            IT Lab OS
          </p>
          <p className="text-[10px] text-[var(--color-text-tertiary)]">
            Learning System
          </p>
        </div>
      </div>

      {/* Primary nav */}
      <nav className="flex-1 overflow-y-auto p-3">
        <ul className="space-y-0.5" role="list">
          {primaryNav.map((item) => {
            const Icon = item.icon;
            const active = isActive(item.href);
            return (
              <li key={item.href}>
                <Link
                  href={item.href}
                  className={cn(
                    "flex items-center gap-2.5 rounded-lg px-3 py-2 text-sm transition-colors",
                    active
                      ? "bg-[var(--color-brand-soft)] text-[var(--color-brand)] font-medium"
                      : "text-[var(--color-text-secondary)] hover:bg-[var(--color-surface-raised)] hover:text-[var(--color-text-primary)]",
                  )}
                  aria-current={active ? "page" : undefined}
                >
                  <Icon
                    className="h-4 w-4 shrink-0"
                    aria-hidden="true"
                  />
                  {item.label}
                </Link>
              </li>
            );
          })}
        </ul>
      </nav>

      {/* Secondary nav */}
      <div className="border-t border-[var(--color-border)] p-3">
        <ul className="space-y-0.5" role="list">
          {secondaryNav.map((item) => {
            const Icon = item.icon;
            const active = isActive(item.href);
            return (
              <li key={item.href}>
                <Link
                  href={item.href}
                  className={cn(
                    "flex items-center gap-2.5 rounded-lg px-3 py-2 text-sm transition-colors",
                    active
                      ? "bg-[var(--color-brand-soft)] text-[var(--color-brand)] font-medium"
                      : "text-[var(--color-text-tertiary)] hover:bg-[var(--color-surface-raised)] hover:text-[var(--color-text-primary)]",
                  )}
                  aria-current={active ? "page" : undefined}
                >
                  <Icon className="h-4 w-4 shrink-0" aria-hidden="true" />
                  {item.label}
                </Link>
              </li>
            );
          })}
        </ul>
      </div>
    </aside>
  );
}
