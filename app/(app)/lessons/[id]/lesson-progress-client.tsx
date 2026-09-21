"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { CheckCircle2, PlayCircle } from "lucide-react";
import Link from "next/link";

interface Props {
  lessonId: string;
  skillId: string;
  initialStatus: string;
  skillSlug: string;
  nextLesson?: {
    id: string;
    title: string;
  } | null;
}

export default function LessonProgressClient({
  lessonId,
  skillId,
  initialStatus,
  skillSlug,
  nextLesson,
}: Props) {
  const [status, setStatus] = useState(initialStatus);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleAction(action: "start" | "complete") {
    setLoading(true);
    setError(null);
    try {
      const res = await fetch(`/api/lessons/${lessonId}/progress`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ action, skillId }),
      });
      if (!res.ok) throw new Error("Failed to update progress");
      const data = await res.json();
      setStatus(data.status);
    } catch (e) {
      setError("Failed to update progress. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface)] p-4 space-y-3 shadow-sm">
      <div className="flex items-center justify-between">
        <p className="text-xs text-[var(--color-text-tertiary)] uppercase tracking-wider font-semibold">
          Lesson Progress
        </p>
        <span className="text-xs text-[var(--color-text-tertiary)]">
          {status === "completed" ? "Mastery recorded" : status === "in_progress" ? "In progress" : "Not yet started"}
        </span>
      </div>

      {status === "not_started" && (
        <div className="flex items-center justify-between pt-1">
          <Button onClick={() => handleAction("start")} disabled={loading} size="sm">
            <PlayCircle className="h-4 w-4 mr-2" />
            {loading ? "Starting..." : "Start Lesson"}
          </Button>
          <span className="text-xs text-[var(--color-text-tertiary)]">Track your reading time and progress</span>
        </div>
      )}

      {status === "in_progress" && (
        <div className="flex items-center justify-between pt-1">
          <Button onClick={() => handleAction("complete")} disabled={loading} size="sm" className="bg-emerald-600 hover:bg-emerald-500 text-white">
            <CheckCircle2 className="h-4 w-4 mr-2" />
            {loading ? "Saving..." : "Mark Lesson as Complete"}
          </Button>
          <span className="text-xs text-[var(--color-text-tertiary)]">Complete all sections before marking</span>
        </div>
      )}

      {status === "completed" && (
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 pt-1">
          <div className="flex items-center gap-2">
            <CheckCircle2 className="h-5 w-5 text-emerald-500 shrink-0" />
            <span className="text-sm font-medium text-[var(--color-text-primary)]">Lesson Completed!</span>
          </div>
          <div className="flex items-center gap-3 w-full sm:w-auto justify-between sm:justify-end">
            <Link
              href={`/skills/${skillSlug}`}
              className="text-xs text-[var(--color-text-tertiary)] hover:text-[var(--color-text-primary)] hover:underline"
            >
              Back to skill
            </Link>
            {nextLesson && (
              <Link
                href={`/lessons/${nextLesson.id}`}
                className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-md bg-[var(--color-brand)] text-white text-xs font-medium hover:bg-[var(--color-brand-hover)] transition-colors shadow-sm"
              >
                <span>Next: {nextLesson.title}</span>
                <span aria-hidden="true">&rarr;</span>
              </Link>
            )}
          </div>
        </div>
      )}

      {error && (
        <p className="text-xs text-red-400">{error}</p>
      )}
    </div>
  );
}