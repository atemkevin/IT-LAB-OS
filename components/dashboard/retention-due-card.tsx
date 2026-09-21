import { Brain, ArrowRight, CheckCircle2, Clock, RotateCcw } from "lucide-react";
import Link from "next/link";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Badge, DifficultyBadge } from "@/components/ui/badge";
import { getDueSkillReviews, getSpacedRepetitionSummary } from "@/lib/spaced-repetition/service";

export async function RetentionDueCard({ userId }: { userId: string }) {
  const [dueReviews, summary] = await Promise.all([
    getDueSkillReviews(userId, 3),
    getSpacedRepetitionSummary(userId),
  ]);

  if (summary.totalTracked === 0) {
    return null; // Learner hasn't completed any reviewable skills yet
  }

  return (
    <Card className="border-[var(--color-border)]">
      <CardHeader className="flex flex-row items-center justify-between pb-2">
        <div className="space-y-1">
          <div className="flex items-center gap-2">
            <div className="flex h-7 w-7 items-center justify-center rounded-md bg-[var(--color-brand-soft)] text-[var(--color-brand)]">
              <Brain className="h-4 w-4" />
            </div>
            <CardTitle className="text-base">Spaced Repetition (SM-2)</CardTitle>
          </div>
          <CardDescription className="text-xs">
            Counteract forgetting curves through scientifically timed reviews.
          </CardDescription>
        </div>
        <div className="flex items-center gap-2">
          <Badge variant={summary.dueCount > 0 ? "warning" : "positive"}>
            {summary.dueCount > 0 ? `${summary.dueCount} Due` : "100% Up to Date"}
          </Badge>
          <span className="text-xs font-semibold text-[var(--color-text-secondary)] tabular">
            Avg Recall: {summary.averageRetention}%
          </span>
        </div>
      </CardHeader>

      <CardContent className="space-y-3 pt-2">
        {dueReviews.length === 0 ? (
          <div className="flex items-center gap-3 rounded-lg border border-[var(--color-positive-soft)] bg-[var(--color-positive-soft)]/20 p-3 text-xs text-[var(--color-text-primary)]">
            <CheckCircle2 className="h-5 w-5 text-[var(--color-positive)] shrink-0" />
            <div>
              <p className="font-semibold text-[var(--color-positive)]">Memory Consolidating</p>
              <p className="text-[var(--color-text-tertiary)]">
                All reviewed concepts are currently within their target retention intervals.
              </p>
            </div>
          </div>
        ) : (
          <div className="space-y-2">
            {dueReviews.map((item) => (
              <div
                key={item.id}
                className="flex items-center justify-between rounded-lg border border-[var(--color-border-subtle)] bg-[var(--color-surface-raised)] p-3 transition-colors hover:border-[var(--color-brand-soft)]"
              >
                <div className="space-y-1">
                  <div className="flex items-center gap-2">
                    <span className="font-medium text-sm text-[var(--color-text-primary)]">
                      {item.skillName}
                    </span>
                    <DifficultyBadge difficulty={item.difficulty as import("@/lib/database.types").Difficulty} />
                  </div>
                  <div className="flex items-center gap-3 text-xs text-[var(--color-text-tertiary)]">
                    <span className="flex items-center gap-1">
                      <Clock className="h-3 w-3" /> Interval: {item.intervalDays}d
                    </span>
                    <span className="tabular">
                      Repetition: #{item.repetitionCount}
                    </span>
                    <span className="tabular text-[var(--color-warning)] font-medium">
                      Est. Retention: {item.currentRetention}%
                    </span>
                  </div>
                </div>

                <Link
                  href={`/skills/${item.skillSlug}/quiz`}
                  className="flex items-center gap-1 rounded-md bg-[var(--color-brand-soft)] px-3 py-1.5 text-xs font-semibold text-[var(--color-brand)] transition-colors hover:bg-[var(--color-brand)] hover:text-white"
                >
                  <RotateCcw className="h-3.5 w-3.5" />
                  Review Quiz
                </Link>
              </div>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  );
}
