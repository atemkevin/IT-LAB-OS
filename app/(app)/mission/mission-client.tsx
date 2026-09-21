"use client";

import { useState } from "react";
import Link from "next/link";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { CheckCircle2, Clock, Target, AlertCircle, Lightbulb, Loader2 } from "lucide-react";
import type { MissionData } from "@/lib/learning/missions";
import type { MissionTaskProgress } from "@/lib/database.types";

interface MissionClientProps {
  mission: MissionData | null;
  taskProgress: MissionTaskProgress[];
}

export default function MissionClient({ mission, taskProgress }: MissionClientProps) {
  const [tasks, setTasks] = useState<MissionTaskProgress[]>(taskProgress);
  const [loading, setLoading] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  if (!mission) {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">Daily Mission</h1>
          <p className="text-sm text-[var(--color-text-tertiary)]">
            A single, high-leverage objective tailored to your target mastery rate.
          </p>
        </div>
        <Card>
          <CardContent className="py-8 text-center">
            <Target className="h-12 w-12 text-[var(--color-text-disabled)] mx-auto mb-3" />
            <p className="text-sm text-[var(--color-text-tertiary)]">
              Unable to generate a mission. Please ensure skills are available.
            </p>
          </CardContent>
        </Card>
      </div>
    );
  }

  const completedCount = tasks.filter((t) => t.completed).length;
  const allDone = completedCount >= mission.tasks.length;
  const isCompleted = mission.status === "completed" || allDone;

  function getTaskProgress(taskKey: string): MissionTaskProgress | undefined {
    return tasks.find((t) => t.task_key === taskKey);
  }

  async function toggleTask(taskKey: string) {
    const existing = getTaskProgress(taskKey);
    const newCompleted = !existing?.completed;

    setLoading(taskKey);
    setError(null);
    try {
      const res = await fetch(`/api/mission/${mission!.id}/task`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ taskKey, completed: newCompleted }),
      });
      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw new Error(err.error || "Failed to update task");
      }
      const data = await res.json();

      setTasks((prev) => {
        const idx = prev.findIndex((t) => t.task_key === taskKey);
        if (idx >= 0) {
          const updated = [...prev];
          updated[idx] = data.taskProgress;
          return updated;
        }
        return [...prev, data.taskProgress];
      });
    } catch (err: any) {
      setError(err.message || "Failed to update task");
    } finally {
      setLoading(null);
    }
  }

  function getTaskLink(task: MissionData["tasks"][0]): string | null {
    const slug = task.skill_slug;
    switch (task.type) {
      case "lesson":
        return task.ref_id ? `/lessons/${task.ref_id}` : null;
      case "practice":
        if (slug && task.ref_id) {
          return `/skills/${slug}/practice/${task.ref_id}`;
        }
        return slug ? `/skills/${slug}` : null;
      case "quiz":
        return slug ? `/skills/${slug}/quiz` : null;
      default:
        return null;
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">Daily Mission</h1>
          <p className="text-sm text-[var(--color-text-tertiary)]">
            A single, high-leverage objective tailored to your target mastery rate.
          </p>
        </div>
        <div className="flex items-center gap-2">
          <Badge variant={isCompleted ? "positive" : "brand"}>
            {isCompleted ? "Completed" : mission.status === "in_progress" ? "In Progress" : "Active Mission"}
          </Badge>
          <span className="inline-flex items-center gap-1 text-xs text-[var(--color-text-tertiary)]">
            <Clock className="h-3.5 w-3.5" />
            {mission.durationMinutes} min
          </span>
        </div>
      </div>

      {/* Progress bar */}
      {mission.tasks.length > 0 && (
        <div className="flex items-center gap-3">
          <div className="h-2 flex-1 rounded-full bg-[var(--color-surface-raised)]">
            <div
              className="h-2 rounded-full bg-[var(--color-brand)] transition-all"
              style={{ width: `${(completedCount / mission.tasks.length) * 100}%` }}
            />
          </div>
          <span className="text-xs font-medium text-[var(--color-text-secondary)]">
            {completedCount}/{mission.tasks.length}
          </span>
        </div>
      )}

      <Card>
        <CardHeader>
          <div className="flex items-center gap-2">
            <Target className="h-5 w-5 text-[var(--color-brand)]" />
            <div>
              <CardTitle>{mission.title}</CardTitle>
              <CardDescription>{mission.objective}</CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* Context */}
          {mission.context && (
            <div className="rounded-lg bg-[var(--color-surface)] p-3">
              <p className="text-xs text-[var(--color-text-secondary)]">{mission.context}</p>
            </div>
          )}

          {/* Tasks */}
          <div className="space-y-3">
            <h4 className="text-xs font-semibold uppercase tracking-wider text-[var(--color-text-tertiary)]">
              Tasks
            </h4>
            <div className="space-y-2">
              {mission.tasks.map((task, i) => {
                const progress = getTaskProgress(task.key);
                const done = progress?.completed ?? false;
                const link = getTaskLink(task);
                return (
                  <div
                    key={task.key}
                    className={`flex items-start gap-3 rounded-lg border p-3 transition-colors ${
                      done
                        ? "border-[var(--color-positive)]/30 bg-[var(--color-positive)]/5"
                        : "border-[var(--color-border)] bg-[var(--color-surface)]"
                    }`}
                  >
                    <button
                      onClick={() => toggleTask(task.key)}
                      disabled={loading === task.key}
                      className="mt-0.5 shrink-0"
                    >
                      {loading === task.key ? (
                        <Loader2 className="h-4 w-4 animate-spin text-[var(--color-text-tertiary)]" />
                      ) : done ? (
                        <CheckCircle2 className="h-4 w-4 text-[var(--color-positive)]" />
                      ) : (
                        <div className="h-4 w-4 rounded-full border-2 border-[var(--color-text-disabled)]" />
                      )}
                    </button>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2">
                        <p className={`text-xs font-medium ${done ? "text-[var(--color-text-tertiary)] line-through" : "text-[var(--color-text-primary)]"}`}>
                          Task {i + 1}: {task.title}
                        </p>
                        {link && !done && (
                          <Link href={link} className="text-[10px] text-[var(--color-brand)] hover:underline">
                            Open →
                          </Link>
                        )}
                      </div>
                      <p className="text-xs text-[var(--color-text-tertiary)] mt-0.5">
                        {task.description}
                      </p>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Hints */}
          {mission.hints.length > 0 && (
            <div className="space-y-2">
              <h4 className="text-xs font-semibold uppercase tracking-wider text-[var(--color-text-tertiary)]">
                Hints
              </h4>
              <div className="space-y-1.5">
                {mission.hints.map((hint, i) => (
                  <div key={i} className="flex items-start gap-2">
                    <Lightbulb className="mt-0.5 h-3.5 w-3.5 shrink-0 text-[var(--color-warning)]" />
                    <p className="text-xs text-[var(--color-text-secondary)]">{hint}</p>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Success Criteria */}
          {mission.successCriteria.length > 0 && (
            <div className="space-y-2">
              <h4 className="text-xs font-semibold uppercase tracking-wider text-[var(--color-text-tertiary)]">
                Success Criteria
              </h4>
              <ul className="space-y-1">
                {mission.successCriteria.map((c, i) => (
                  <li key={i} className="flex items-start gap-2">
                    <CheckCircle2 className="mt-0.5 h-3.5 w-3.5 shrink-0 text-[var(--color-text-disabled)]" />
                    <span className="text-xs text-[var(--color-text-secondary)]">{c}</span>
                  </li>
                ))}
              </ul>
            </div>
          )}

          {/* Recommendation Reason */}
          {mission.recommendationReason && (
            <div className="flex items-start gap-2 border-t border-[var(--color-border)] pt-4">
              <AlertCircle className="mt-0.5 h-4 w-4 shrink-0 text-[var(--color-info)]" />
              <p className="text-xs text-[var(--color-text-tertiary)]">{mission.recommendationReason}</p>
            </div>
          )}

          {/* Footer */}
          {error && <p className="text-xs text-red-400 font-medium">{error}</p>}
          <div className="flex items-center justify-between border-t border-[var(--color-border)] pt-4">
            <div className="flex items-center gap-2 text-xs text-[var(--color-text-tertiary)]">
              <AlertCircle className="h-4 w-4 text-[var(--color-warning)]" />
              <span>Completing daily missions sustains streak and boosts retention score.</span>
            </div>
            {isCompleted ? (
              <Badge variant="positive" className="px-4 py-2">
                <CheckCircle2 className="h-4 w-4" />
                Mission Complete!
              </Badge>
            ) : (
              <Button
                onClick={() => {
                  // Mark all tasks as complete
                  const incomplete = mission.tasks.filter((t) => !getTaskProgress(t.key)?.completed);
                  incomplete.forEach((t) => toggleTask(t.key));
                }}
                disabled={loading !== null}
              >
                {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : null}
                Complete All Tasks
              </Button>
            )}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
