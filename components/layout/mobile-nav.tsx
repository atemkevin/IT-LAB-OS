"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { MoreHorizontal } from "lucide-react";
import { useState } from "react";
import { cn } from "@/lib/utils";
import { mobileBottomNav, primaryNav, secondaryNav } from "@/lib/nav-data";

export function MobileNav() {
  const pathname = usePathname();
  const [moreOpen, setMoreOpen] = useState(false);

  function isActive(href: string) {
    if (href === "/dashboard") return pathname === href;
    return pathname.startsWith(href);
  }

  // Items in "More" drawer — everything not in the bottom 4
  const bottomHrefs = new Set(mobileBottomNav.map((n) => n.href));
  const moreItems = [...primaryNav, ...secondaryNav].filter(
    (n) => !bottomHrefs.has(n.href),
  );

  return (
    <>
      {/* Bottom nav bar */}
      <nav
        className="fixed bottom-0 inset-x-0 z-30 flex h-16 border-t border-[var(--color-border)] bg-[var(--color-surface)] lg:hidden"
        aria-label="Mobile navigation"
      >
        {mobileBottomNav.map((item) => {
          const Icon = item.icon;
          const active = isActive(item.href);
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "flex flex-1 flex-col items-center justify-center gap-1 text-xs transition-colors",
                active
                  ? "text-[var(--color-brand)]"
                  : "text-[var(--color-text-tertiary)]",
              )}
              aria-current={active ? "page" : undefined}
            >
              <Icon className="h-5 w-5" aria-hidden="true" />
              <span>{item.label}</span>
            </Link>
          );
        })}

        {/* More button */}
        <button
          onClick={() => setMoreOpen(true)}
          className="flex flex-1 flex-col items-center justify-center gap-1 text-xs text-[var(--color-text-tertiary)] transition-colors hover:text-[var(--color-text-primary)]"
          aria-label="More navigation options"
          aria-haspopup="dialog"
          aria-expanded={moreOpen}
        >
          <MoreHorizontal className="h-5 w-5" aria-hidden="true" />
          <span>More</span>
        </button>
      </nav>

      {/* More drawer overlay */}
      {moreOpen && (
        <>
          <div
            className="fixed inset-0 z-40 bg-black/60 lg:hidden"
            aria-hidden="true"
            onClick={() => setMoreOpen(false)}
          />
          <div
            role="dialog"
            aria-modal="true"
            aria-label="More navigation options"
            className="fixed inset-x-0 bottom-0 z-50 rounded-t-2xl border-t border-[var(--color-border)] bg-[var(--color-surface-raised)] p-4 pb-8 lg:hidden"
          >
            <div className="mx-auto mb-4 h-1 w-12 rounded-full bg-[var(--color-border)]" />
            <ul className="grid grid-cols-3 gap-2" role="list">
              {moreItems.map((item) => {
                const Icon = item.icon;
                const active = isActive(item.href);
                return (
                  <li key={item.href}>
                    <Link
                      href={item.href}
                      onClick={() => setMoreOpen(false)}
                      className={cn(
                        "flex flex-col items-center gap-1.5 rounded-xl p-3 text-center text-xs transition-colors",
                        active
                          ? "bg-[var(--color-brand-soft)] text-[var(--color-brand)]"
                          : "text-[var(--color-text-secondary)] hover:bg-[var(--color-surface-overlay)]",
                      )}
                    >
                      <Icon className="h-5 w-5" aria-hidden="true" />
                      <span>{item.label}</span>
                    </Link>
                  </li>
                );
              })}
            </ul>
          </div>
        </>
      )}
    </>
  );
}
