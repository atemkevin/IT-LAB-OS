"use client";

import { useRouter } from "next/navigation";
import { LogOut } from "lucide-react";
import { createClient } from "@/lib/supabase/client";

export function SignOutButton() {
  const router = useRouter();

  async function handleSignOut() {
    const supabase = createClient();
    await supabase.auth.signOut();
    router.push("/login");
    router.refresh();
  }

  return (
    <button
      onClick={handleSignOut}
      className="flex items-center gap-1.5 rounded-lg px-2.5 py-1.5 text-xs text-[var(--color-text-tertiary)] transition-colors hover:bg-[var(--color-surface-raised)] hover:text-[var(--color-text-primary)]"
      aria-label="Sign out"
    >
      <LogOut className="h-3.5 w-3.5" aria-hidden="true" />
      <span className="hidden sm:inline">Sign out</span>
    </button>
  );
}
