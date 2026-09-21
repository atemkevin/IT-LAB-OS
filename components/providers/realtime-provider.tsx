"use client";

import { useEffect } from "react";
import { createClient } from "@/lib/supabase/client";
import { toast, Toaster } from "@/components/ui/toast";
import { Trophy, Zap, Bell, CheckCircle2 } from "lucide-react";

export function RealtimeProvider({ children }: { children: React.ReactNode }) {
  useEffect(() => {
    const supabase = createClient();

    let isMounted = true;
    let channel: ReturnType<typeof supabase.channel> | null = null;

    async function setupRealtime() {
      const {
        data: { session },
      } = await supabase.auth.getSession();
      if (!session || !isMounted) return;

      const userId = session.user.id;

      channel = supabase
        .channel(`user-realtime-${userId}`)
        .on(
          "postgres_changes",
          {
            event: "INSERT",
            schema: "public",
            table: "notifications",
            filter: `user_id=eq.${userId}`,
          },
          (payload) => {
            const notif = payload.new as {
              title: string;
              message: string;
              type?: string;
              link?: string;
            };

            const isAchievement = notif.type === "achievement";
            const isStreak = notif.type === "streak";

            toast({
              title: (
                <div className="flex items-center gap-1.5 font-bold">
                  {isAchievement ? (
                    <Trophy className="h-4 w-4 text-[var(--color-warning)] shrink-0" />
                  ) : isStreak ? (
                    <Zap className="h-4 w-4 text-[var(--color-brand)] shrink-0" />
                  ) : (
                    <Bell className="h-4 w-4 text-[var(--color-positive)] shrink-0" />
                  )}
                  <span>{notif.title}</span>
                </div>
              ),
              description: notif.message,
              variant: isAchievement ? "brand" : isStreak ? "positive" : "default",
              duration: 6000,
            });
          },
        )
        .on(
          "postgres_changes",
          {
            event: "UPDATE",
            schema: "public",
            table: "profiles",
            filter: `id=eq.${userId}`,
          },
          (payload) => {
            const oldProfile = payload.old as { current_streak?: number };
            const newProfile = payload.new as { current_streak?: number };

            if (
              typeof newProfile?.current_streak === "number" &&
              typeof oldProfile?.current_streak === "number" &&
              newProfile.current_streak > oldProfile.current_streak
            ) {
              toast({
                title: (
                  <div className="flex items-center gap-1.5 font-bold text-[var(--color-brand)]">
                    <Zap className="h-4 w-4 text-[var(--color-warning)] shrink-0" />
                    <span>Streak Extended! 🔥</span>
                  </div>
                ),
                description: `You are now on a ${newProfile.current_streak}-day study streak! Keep up the momentum.`,
                variant: "brand",
                duration: 5000,
              });
            }
          },
        )
        .subscribe();

      if (!isMounted && channel) {
        supabase.removeChannel(channel);
      }
    }

    setupRealtime();

    return () => {
      isMounted = false;
      if (channel) {
        supabase.removeChannel(channel);
      }
    };
  }, []);

  return (
    <>
      {children}
      <Toaster />
    </>
  );
}
