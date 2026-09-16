"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Play, CheckCircle2, Loader2 } from "lucide-react";

interface Props {
  slug: string;
  currentStatus: string;
  currentProgress: number;
  requirementsCount: number;
}

export default function ProjectActionClient({
  slug,
  currentStatus,
  currentProgress,
  requirementsCount,
}: Props) {
  const [status, setStatus] = useState(currentStatus);
  const [progress, setProgress] = useState(currentProgress);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function updateProgress(newStatus: string, newProgress: number) {
    setLoading(true);
    setError(null);
    try {
      const res = await fetch(`/api/projects/${slug}/progress`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ status: newStatus, progress: newProgress }),
      });
      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw new Error(err.error || "Failed to update");
      }
      setStatus(newStatus);
      setProgress(newProgress);
    } catch (err: any) {
      setError(err.message || "Failed to update progress");
    } finally {
      setLoading(false);
    }
  }

  function handleStart() {
    updateProgress("in_progress", 10);
  }

  function handleProgress() {
    const stepProgress = Math.min(progress + Math.ceil(100 / Math.max(requirementsCount, 1)), 90);
    updateProgress("in_progress", stepProgress);
  }

  function handleComplete() {
    updateProgress("completed", 100);
  }

  return (
    <div className="space-y-3">
      {error && <p className="text-xs text-red-400 font-medium">{error}</p>}
      <div className="flex items-center gap-3">
        {status === "not_started" && (
          <Button onClick={handleStart} disabled={loading}>
            {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <Play className="h-4 w-4" />}
            Start Project
          </Button>
        )}
        {status === "in_progress" && progress < 100 && (
          <>
            <Button onClick={handleProgress} disabled={loading} variant="outline">
              {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : <CheckCircle2 className="h-4 w-4" />}
              Mark Requirement Done
            </Button>
            <Button onClick={handleComplete} disabled={loading} variant="secondary">
              Submit Project
            </Button>
          </>
        )}
        {status === "completed" && (
          <Badge variant="positive" className="px-4 py-2">
            <CheckCircle2 className="h-4 w-4" />
            Project Completed!
          </Badge>
        )}
      </div>
    </div>
  );
}
