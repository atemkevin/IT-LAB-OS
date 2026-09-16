"use client";

import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { CheckCircle2, XCircle } from "lucide-react";
import Link from "next/link";

interface Props {
  taskId: string;
  skillId: string;
  skillSlug: string;
  requirements: string[];
  evidenceKeys: string[];
}

interface PracticeResult {
  passed: boolean;
  score: number;
  feedback: string;
  requirementResults?: Record<string, boolean>;
}

export default function PracticeClient({ taskId, skillId, skillSlug, requirements, evidenceKeys }: Props) {
  const [responses, setResponses] = useState<Record<string, string>>({});
  const [notes, setNotes] = useState("");
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<PracticeResult | null>(null);
  const [error, setError] = useState<string | null>(null);

  const handleResponseChange = (key: string, value: string) => {
    setResponses((prev) => ({ ...prev, [key]: value }));
  };

  async function handleSubmit() {
    setLoading(true);
    setError(null);
    try {
      const res = await fetch(`/api/practice/${taskId}/attempt`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ 
          skillId, 
          responses, 
          notes, 
          completed: true 
        }),
      });
      if (!res.ok) {
        const errorData = await res.json().catch(() => ({}));
        throw new Error(errorData.feedback || errorData.error || "Submission failed");
      }
      const data = await res.json();
      setResult(data);
    } catch (err: any) {
      setError(err.message || "Failed to submit. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  if (result) {
    return (
      <Card className={result.passed ? "border-green-500/50" : "border-yellow-500/50"}>
        <CardContent className="pt-4 space-y-4">
          <div className="flex flex-col gap-2">
            <div className="flex items-center gap-2">
              {result.passed ? (
                <CheckCircle2 className="h-6 w-6 text-green-400" />
              ) : (
                <XCircle className="h-6 w-6 text-yellow-400" />
              )}
              <h2 className="text-lg font-semibold text-[var(--color-text-primary)]">
                Score: {result.score}%
              </h2>
            </div>
            <p className="text-sm font-medium text-[var(--color-text-primary)]">
              {result.passed ? "Practice recorded successfully!" : "Keep practising"}
            </p>
            <p className="text-sm text-[var(--color-text-secondary)]">{result.feedback}</p>
          </div>

          {result.requirementResults && Object.keys(result.requirementResults).length > 0 && evidenceKeys.length > 0 && (
            <div className="space-y-2 mt-4 pt-4 border-t border-[var(--color-border)]">
              <h3 className="text-sm font-medium text-[var(--color-text-primary)]">Requirement Results</h3>
              <ul className="space-y-2">
                {evidenceKeys.map((key, i) => {
                  const reqPassed = result.requirementResults![key];
                  return (
                    <li key={key} className="flex items-start gap-2 text-sm">
                      {reqPassed ? (
                        <CheckCircle2 className="h-4 w-4 shrink-0 text-green-400 mt-0.5" />
                      ) : (
                        <XCircle className="h-4 w-4 shrink-0 text-red-400 mt-0.5" />
                      )}
                      <span className={reqPassed ? "text-[var(--color-text-secondary)]" : "text-[var(--color-text-primary)]"}>
                        {requirements[i] || "Requirement "}
                      </span>
                    </li>
                  );
                })}
              </ul>
            </div>
          )}

          <div className="pt-4">
            {result.passed ? (
              <Link href={`/skills/${skillSlug}`}>
                <Button className="w-full">Return to Skill</Button>
              </Link>
            ) : (
              <Button variant="outline" onClick={() => setResult(null)} className="w-full">
                Try Again
              </Button>
            )}
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="text-sm">Submit Evidence</CardTitle>
      </CardHeader>
      <CardContent className="space-y-6">
        
        {requirements.length > 0 ? (
          <div className="space-y-4">
            {evidenceKeys.map((key, i) => (
              <div key={key} className="space-y-2">
                <label className="block text-sm font-medium text-[var(--color-text-primary)] flex gap-2">
                  <span className="text-[var(--color-brand)] font-mono text-xs mt-0.5">{i + 1}.</span>
                  {requirements[i] || "Requirement "}
                </label>
                <textarea
                  className="w-full rounded-md border border-[var(--color-border)] bg-[var(--color-surface-elevated)] p-2 text-sm text-[var(--color-text-secondary)] placeholder:text-[var(--color-text-tertiary)] focus:outline-none focus:border-[var(--color-brand)] min-h-[60px]"
                  placeholder="Provide output, commands, or explanation..."
                  value={responses[key] || ""}
                  onChange={(e) => handleResponseChange(key, e.target.value)}
                />
              </div>
            ))}
          </div>
        ) : (
          <p className="text-sm text-[var(--color-text-secondary)]">This task has no specific requirements to validate.</p>
        )}

        <div className="space-y-2 pt-4 border-t border-[var(--color-border)]">
          <label className="text-sm font-medium text-[var(--color-text-primary)]">
            Additional Notes
          </label>
          <textarea
            className="w-full rounded-md border border-[var(--color-border)] bg-[var(--color-surface-elevated)] p-2 text-sm text-[var(--color-text-secondary)] placeholder:text-[var(--color-text-tertiary)] focus:outline-none focus:border-[var(--color-brand)] min-h-[80px]"
            placeholder="Optional: general notes on what you did, issues you encountered..."
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
          />
        </div>

        {error && <p className="text-xs text-red-400 font-medium">{error}</p>}

        <Button onClick={handleSubmit} disabled={loading} className="w-full">
          {loading ? "Submitting..." : "Submit Evidence"}
        </Button>
      </CardContent>
    </Card>
  );
}