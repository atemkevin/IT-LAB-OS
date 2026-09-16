"use client";

import { useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { CheckCircle2, XCircle, HelpCircle } from "lucide-react";
import Link from "next/link";
import type { SafeQuizQuestion, QuizResult } from "@/lib/learning/types";

interface Props {
  questions: SafeQuizQuestion[];
  skillSlug: string;
}

export default function QuizClient({ questions, skillSlug }: Props) {
  const [answers, setAnswers] = useState<Record<string, string[]>>({});
  const [result, setResult] = useState<QuizResult | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  function toggleOption(questionId: string, optionId: string, isSingle: boolean) {
    setAnswers((prev) => {
      const current = prev[questionId] ?? [];
      if (isSingle) {
        return { ...prev, [questionId]: [optionId] };
      }
      // Multi-select toggle
      if (current.includes(optionId)) {
        return { ...prev, [questionId]: current.filter((id) => id !== optionId) };
      }
      return { ...prev, [questionId]: [...current, optionId] };
    });
  }

  const allAnswered = questions.every((q) => (answers[q.id] ?? []).length > 0);

  async function handleSubmit() {
    if (!allAnswered) return;
    setLoading(true);
    setError(null);
    try {
      const res = await fetch(`/api/quiz/${skillSlug}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ answers }),
      });
      if (res.status === 429) {
        const data = await res.json().catch(() => ({}));
        setError(data.error || "Too many attempts. Please wait a minute before trying again.");
        return;
      }
      if (!res.ok) throw new Error("Failed to submit quiz");
      const data: QuizResult = await res.json();
      setResult(data);
    } catch (e) {
      setError("Failed to submit. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  // Show results
  if (result) {
    return (
      <div className="space-y-4">
        {/* Score summary */}
        <Card className={result.passed ? "border-green-500/50" : "border-red-500/50"}>
          <CardContent className="pt-4 text-center space-y-2">
            <div className="text-4xl font-bold text-[var(--color-text-primary)]">
              {result.score.toFixed(0)}%
            </div>
            <p className={`text-sm font-semibold ${result.passed ? "text-green-400" : "text-red-400"}`}>
              {result.passed ? "✓ Passed!" : "✗ Not passed"}
            </p>
            <p className="text-xs text-[var(--color-text-tertiary)]">
              {result.correctCount}/{result.questionCount} correct
              {result.masteryEvidenceCreated && " · Mastery evidence recorded"}
            </p>
            <div className="flex gap-3 justify-center pt-2">
              <Link href={`/skills/${skillSlug}`}>
                <Button variant="outline" size="sm">Back to Skill</Button>
              </Link>
            </div>
          </CardContent>
        </Card>

        {/* Per-question results */}
        {result.results.map((r, i) => (
          <Card key={r.questionId} className={r.isCorrect ? "border-green-500/30" : "border-red-500/30"}>
            <CardContent className="pt-4 space-y-2">
              <div className="flex items-start gap-2">
                {r.isCorrect ? (
                  <CheckCircle2 className="h-4 w-4 text-green-400 shrink-0 mt-0.5" />
                ) : (
                  <XCircle className="h-4 w-4 text-red-400 shrink-0 mt-0.5" />
                )}
                <p className="text-sm text-[var(--color-text-primary)] font-medium">
                  Q{i + 1}: {r.prompt}
                </p>
              </div>
              {r.explanation && (
                <p className="text-xs text-[var(--color-text-secondary)] ml-6">{r.explanation}</p>
              )}
            </CardContent>
          </Card>
        ))}
      </div>
    );
  }

  // Show quiz form
  return (
    <div className="space-y-4">
      {questions.map((question, qi) => {
        const isSingle = question.questionType === "single";
        const selectedOptions = answers[question.id] ?? [];

        return (
          <Card key={question.id}>
            <CardHeader>
              <CardTitle className="text-sm font-medium">
                <span className="text-[var(--color-brand)] mr-2">Q{qi + 1}.</span>
                {question.prompt}
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-2">
              {question.options.map((option) => {
                const isSelected = selectedOptions.includes(option.id);
                return (
                  <button
                    key={option.id}
                    type="button"
                    aria-pressed={isSelected}
                    onClick={() => toggleOption(question.id, option.id, isSingle)}
                    className={`w-full text-left rounded-md border px-3 py-2.5 text-sm transition-colors ${
                      isSelected
                        ? "border-[var(--color-brand)] bg-[var(--color-brand)]/10 text-[var(--color-text-primary)]"
                        : "border-[var(--color-border)] text-[var(--color-text-secondary)] hover:border-[var(--color-brand)]/50"
                    }`}
                  >
                    {option.optionText}
                  </button>
                );
              })}
            </CardContent>
          </Card>
        );
      })}

      {error && <p className="text-xs text-red-400">{error}</p>}

      <Button
        onClick={handleSubmit}
        disabled={!allAnswered || loading}
        className="w-full"
      >
        {loading ? "Grading..." : allAnswered ? "Submit Quiz" : `Answer all ${questions.length} questions to submit`}
      </Button>
    </div>
  );
}