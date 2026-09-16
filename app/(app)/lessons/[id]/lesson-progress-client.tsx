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
}

export default function LessonProgressClient({
  lessonId,
  skillId,
  initialStatus,
  skillSlug,
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
    <div className="rounded-lg border border-[var(--color-border)] p-4 space-y-3">
      <p className="text-xs text-[var(--color-text-tertiary)] uppercase tracking-wide font-medium">
        Your Progress
      </p>

      {status === "not_started" && (
        <Button onClick={() => handleAction("start")} disabled={loading}>
          <PlayCircle className="h-4 w-4 mr-2" />
          {loading ? "Starting..." : "Start Lesson"}
        </Button>
      )}

      {status === "in_progress" && (
        <div className="flex gap-3">
          <Button onClick={() => handleAction("complete")} disabled={loading}>
            <CheckCircle2 className="h-4 w-4 mr-2" />
            {loading ? "Saving..." : "Mark as Complete"}
          </Button>
        </div>
      )}

      {status === "completed" && (
        <div className="flex items-center gap-2">
          <CheckCircle2 className="h-5 w-5 text-green-500" />
          <span className="text-sm text-[var(--color-text-secondary)]">Lesson completed!</span>
          <Link
            href={`/skills/${skillSlug}`}
            className="ml-auto text-xs text-[var(--color-brand)] hover:underline"
          >
            Back to skill →
          </Link>
        </div>
      )}

      {error && (
        <p className="text-xs text-red-400">{error}</p>
      )}
    </div>
  );
}