"use client";

import { useState } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { CheckCircle2 } from "lucide-react";
import Link from "next/link";

interface Props {
  taskId: string;
  skillId: string;
  skillSlug: string;
}

export default function PracticeClient({ taskId, skillId, skillSlug }: Props) {
  const [completed, setCompleted] = useState(false);
  const [notes, setNotes] = useState("");
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<{ passed: boolean; feedback: string } | null>(null);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit() {
    setLoading(true);
    setError(null);
    try {
      const res = await fetch(`/api/practice/${taskId}/attempt`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ skillId, completed, notes }),
      });
      if (!res.ok) throw new Error("Submission failed");
      const data = await res.json();
      setResult(data);
    } catch {
      setError("Failed to submit. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  if (result) {
    return (
      <Card className={result.passed ? "border-green-500/50" : "border-yellow-500/50"}>
        <CardContent className="pt-4 space-y-3">
          <div className="flex items-center gap-2">
            <CheckCircle2 className={`h-5 w-5 ${result.passed ? "text-green-400" : "text-yellow-400"}`} />
            <p className="text-sm font-semibold text-[var(--color-text-primary)]">
              {result.passed ? "Practice recorded!" : "Keep practising"}
            </p>
          </div>
          <p className="text-sm text-[var(--color-text-secondary)]">{result.feedback}</p>
          <Link href={`/skills/${skillSlug}`}>
            <Button variant="outline" size="sm">Back to Skill</Button>
          </Link>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardContent className="pt-4 space-y-4">
        <p className="text-sm font-medium text-[var(--color-text-primary)]">
          Mark your completion
        </p>

        <textarea
          className="w-full rounded-md border border-[var(--color-border)] bg-[var(--color-surface-elevated)] p-2 text-sm text-[var(--color-text-secondary)] placeholder:text-[var(--color-text-tertiary)] focus:outline-none focus:border-[var(--color-brand)] min-h-[80px]"
          placeholder="Optional: notes on what you did, issues you encountered..."
          value={notes}
          onChange={(e) => setNotes(e.target.value)}
        />

        <label className="flex items-center gap-2 cursor-pointer">
          <input
            type="checkbox"
            checked={completed}
            onChange={(e) => setCompleted(e.target.checked)}
            className="rounded"
          />
          <span className="text-sm text-[var(--color-text-secondary)]">
            I completed all the requirements above
          </span>
        </label>

        {error && <p className="text-xs text-red-400">{error}</p>}

        <Button onClick={handleSubmit} disabled={loading} className="w-full">
          {loading ? "Submitting..." : "Submit Practice"}
        </Button>
      </CardContent>
    </Card>
  );
}