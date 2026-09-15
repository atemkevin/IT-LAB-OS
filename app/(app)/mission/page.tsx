import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { CheckCircle2, Clock, Target, AlertCircle } from "lucide-react";

export default function DailyMissionPage() {
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
          <Badge variant="brand">Active Mission</Badge>
          <span className="inline-flex items-center gap-1 text-xs text-[var(--color-text-tertiary)]">
            <Clock className="h-3.5 w-3.5" />
            30 min
          </span>
        </div>
      </div>

      <Card>
        <CardHeader>
          <div className="flex items-center gap-2">
            <Target className="h-5 w-5 text-[var(--color-brand)]" />
            <div>
              <CardTitle>Linux Terminal Permissions & Ownership Drill</CardTitle>
              <CardDescription>
                Strengthen practical understanding of octal permissions and suid/sgid bits.
              </CardDescription>
            </div>
          </div>
        </CardHeader>
        <CardContent className="space-y-6">
          <div className="space-y-3">
            <h4 className="text-xs font-semibold uppercase tracking-wider text-[var(--color-text-tertiary)]">
              Tasks
            </h4>
            <div className="space-y-2">
              <div className="flex items-start gap-3 rounded-lg border border-[var(--color-border)] bg-[var(--color-surface)] p-3">
                <CheckCircle2 className="mt-0.5 h-4 w-4 text-[var(--color-text-disabled)]" />
                <div className="flex-1">
                  <p className="text-xs font-medium text-[var(--color-text-primary)]">
                    Task 1: Review chmod octal notation
                  </p>
                  <p className="text-xs text-[var(--color-text-tertiary)]">
                    Calculate permissions for 755, 644, and 700.
                  </p>
                </div>
              </div>

              <div className="flex items-start gap-3 rounded-lg border border-[var(--color-border)] bg-[var(--color-surface)] p-3">
                <CheckCircle2 className="mt-0.5 h-4 w-4 text-[var(--color-text-disabled)]" />
                <div className="flex-1">
                  <p className="text-xs font-medium text-[var(--color-text-primary)]">
                    Task 2: Solve simulated permissions repair lab
                  </p>
                  <p className="text-xs text-[var(--color-text-tertiary)]">
                    Fix an unreachable web server directory without opening it to 777.
                  </p>
                </div>
              </div>
            </div>
          </div>

          <div className="flex items-center justify-between border-t border-[var(--color-border)] pt-4">
            <div className="flex items-center gap-2 text-xs text-[var(--color-text-tertiary)]">
              <AlertCircle className="h-4 w-4 text-[var(--color-warning)]" />
              <span>Completing daily missions sustains streak and boosts retention score.</span>
            </div>
            <Button>Complete Mission Tasks</Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
