"use client";

import { useOptimistic, useTransition } from "react";
import { useRouter } from "next/navigation";
import { BookOpen, CheckCircle2, Loader2 } from "lucide-react";

interface Props {
  lessonId: string;
  initialStatus: "not_started" | "in_progress" | "completed";
}

/**
 * Client component that optimistically updates lesson status
 * when the user starts or continues a lesson.
 */
export function LessonProgressButton({ lessonId, initialStatus }: Props) {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();
  const [optimisticStatus, setOptimisticStatus] = useOptimistic(
    initialStatus,
    (_state, newStatus: "not_started" | "in_progress" | "completed") => newStatus
  );

  const isCompleted = optimisticStatus === "completed";
  const isInProgress = optimisticStatus === "in_progress";

  const label = isCompleted ? "Review" : isInProgress ? "Continue" : "Start";
  const icon = isCompleted ? (
    <CheckCircle2 className="h-3 w-3" />
  ) : (
    <BookOpen className="h-3 w-3" />
  );

  async function handleClick() {
    if (isPending) return;

    startTransition(async () => {
      // Optimistically mark as in_progress (if not already completed)
      if (!isCompleted) {
        setOptimisticStatus("in_progress");
      }

      try {
        const res = await fetch(`/api/lessons/${lessonId}/progress`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ action: "start" }),
        });

        if (res.status === 429) {
          // Revert on rate limit
          setOptimisticStatus(initialStatus);
          return;
        }

        if (!res.ok) {
          setOptimisticStatus(initialStatus);
          return;
        }

        // Navigate to lesson after successful start
        router.push(`/lessons/${lessonId}`);
      } catch {
        setOptimisticStatus(initialStatus);
      }
    });
  }

  return (
    <button
      onClick={handleClick}
      disabled={isPending}
      className="text-xs text-[var(--color-brand)] hover:underline flex items-center gap-1 disabled:opacity-50"
    >
      {isPending ? <Loader2 className="h-3 w-3 animate-spin" /> : icon}
      {isPending ? "Loading..." : label}
    </button>
  );
}
