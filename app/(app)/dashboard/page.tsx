import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { getDashboardMetrics } from "@/lib/learning/dashboard";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Target, Zap, Clock, Trophy, ArrowRight, BookOpen } from "lucide-react";
import Link from "next/link";
import { RetentionDueCard } from "@/components/dashboard/retention-due-card";

export default async function DashboardPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const metrics = await getDashboardMetrics(user.id);

  const missionStatusLabel =
    metrics.dailyMission?.status === "completed"
      ? "Completed"
      : metrics.dailyMission?.status === "in_progress"
        ? "In Progress"
        : "Ready";

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">
          Dashboard
        </h1>
        <p className="text-sm text-[var(--color-text-tertiary)]">
          Welcome back. Continue your technical learning journey.
        </p>
      </div>

      {/* Metrics Row */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardContent className="flex items-center gap-3 pt-4">
            <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-[var(--color-brand-soft)] text-[var(--color-brand)]">
              <Zap className="h-5 w-5" />
            </div>
            <div>
              <p className="text-xs text-[var(--color-text-tertiary)]">Overall Mastery</p>
              <p className="text-xl font-bold text-[var(--color-text-primary)]">{metrics.overallMastery}%</p>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="flex items-center gap-3 pt-4">
            <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-[var(--color-positive-soft)] text-[var(--color-positive)]">
              <Trophy className="h-5 w-5" />
            </div>
            <div>
              <p className="text-xs text-[var(--color-text-tertiary)]">Skills In Progress</p>
              <p className="text-xl font-bold text-[var(--color-text-primary)]">{metrics.skillsInProgress}</p>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="flex items-center gap-3 pt-4">
            <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-[var(--color-warning-soft)] text-[var(--color-warning)]">
              <Target className="h-5 w-5" />
            </div>
            <div>
              <p className="text-xs text-[var(--color-text-tertiary)]">Daily Mission</p>
              <p className="text-xl font-bold text-[var(--color-text-primary)]">{missionStatusLabel}</p>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="flex items-center gap-3 pt-4">
            <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-[var(--color-info-soft)] text-[var(--color-info)]">
              <Clock className="h-5 w-5" />
            </div>
            <div>
              <p className="text-xs text-[var(--color-text-tertiary)]">Learning Time</p>
              <p className="text-xl font-bold text-[var(--color-text-primary)]">
                {metrics.learningTimeMinutes >= 60
                  ? `${Math.floor(metrics.learningTimeMinutes / 60)}h ${metrics.learningTimeMinutes % 60}m`
                  : `${metrics.learningTimeMinutes}m`}
              </p>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Spaced Repetition (SM-2) Retention Tracker */}
      <RetentionDueCard userId={user.id} />

      {/* Main Sections */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        {/* Today's Focus / Daily Mission */}
        <Card className="lg:col-span-2">
          <CardHeader>
            <div>
              <CardTitle>Today&apos;s Mission</CardTitle>
              <CardDescription>Your recommended next learning action</CardDescription>
            </div>
            <Badge variant="brand">Daily Target</Badge>
          </CardHeader>
          <CardContent>
            {metrics.dailyMission ? (
              <div className="rounded-lg border border-[var(--color-border)] bg-[var(--color-surface)] p-4">
                <h4 className="text-sm font-semibold text-[var(--color-text-primary)]">
                  {metrics.dailyMission.title}
                </h4>
                <p className="mt-1 text-xs text-[var(--color-text-tertiary)]">
                  {metrics.dailyMission.objective}
                </p>
                <div className="mt-3 flex items-center gap-2 text-xs text-[var(--color-text-tertiary)]">
                  <Clock className="h-3.5 w-3.5" />
                  <span>{metrics.dailyMission.durationMinutes} min</span>
                </div>
                <div className="mt-4 flex items-center gap-3">
                  <Link
                    href="/mission"
                    className="rounded-lg bg-[var(--color-brand)] px-4 py-2 text-xs font-medium text-white transition-colors hover:bg-[var(--color-brand-hover)]"
                  >
                    Start Mission
                  </Link>
                  <Link
                    href="/learn"
                    className="rounded-lg border border-[var(--color-border)] px-4 py-2 text-xs font-medium text-[var(--color-text-secondary)] transition-colors hover:bg-[var(--color-surface-raised)]"
                  >
                    View Learning Path
                  </Link>
                </div>
              </div>
            ) : (
              <div className="rounded-lg border border-[var(--color-border)] bg-[var(--color-surface)] p-4">
                <h4 className="text-sm font-semibold text-[var(--color-text-primary)]">
                  {metrics.recommendedSkill
                    ? `Continue with ${metrics.recommendedSkill}`
                    : "Start with Linux Fundamentals"}
                </h4>
                <p className="mt-1 text-xs text-[var(--color-text-tertiary)]">
                  Master core terminal navigation, permissions, and file management to unlock advanced networking and systems administration.
                </p>
                <div className="mt-4 flex items-center gap-3">
                  <Link
                    href="/mission"
                    className="rounded-lg bg-[var(--color-brand)] px-4 py-2 text-xs font-medium text-white transition-colors hover:bg-[var(--color-brand-hover)]"
                  >
                    Start Mission
                  </Link>
                  <Link
                    href="/learn"
                    className="rounded-lg border border-[var(--color-border)] px-4 py-2 text-xs font-medium text-[var(--color-text-secondary)] transition-colors hover:bg-[var(--color-surface-raised)]"
                  >
                    View Learning Path
                  </Link>
                </div>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Quick Actions */}
        <Card>
          <CardHeader>
            <CardTitle>Quick Access</CardTitle>
            <CardDescription>Jump straight to practice</CardDescription>
          </CardHeader>
          <CardContent className="space-y-2">
            <Link
              href="/labs"
              className="flex items-center justify-between rounded-lg border border-[var(--color-border)] p-3 text-xs transition-colors hover:bg-[var(--color-surface-raised)]"
            >
              <span className="font-medium text-[var(--color-text-primary)]">Troubleshooting Labs</span>
              <span className="text-[var(--color-brand)]">Open →</span>
            </Link>
            <Link
              href="/projects"
              className="flex items-center justify-between rounded-lg border border-[var(--color-border)] p-3 text-xs transition-colors hover:bg-[var(--color-surface-raised)]"
            >
              <span className="font-medium text-[var(--color-text-primary)]">Hands-on Projects</span>
              <span className="text-[var(--color-brand)]">Open →</span>
            </Link>
            <Link
              href="/ai"
              className="flex items-center justify-between rounded-lg border border-[var(--color-border)] p-3 text-xs transition-colors hover:bg-[var(--color-surface-raised)]"
            >
              <span className="font-medium text-[var(--color-text-primary)]">Ask AI Mentor</span>
              <span className="text-[var(--color-brand)]">Open →</span>
            </Link>
            <Link
              href="/progress"
              className="flex items-center justify-between rounded-lg border border-[var(--color-border)] p-3 text-xs transition-colors hover:bg-[var(--color-surface-raised)]"
            >
              <span className="font-medium text-[var(--color-text-primary)]">View Progress</span>
              <ArrowRight className="h-3.5 w-3.5 text-[var(--color-brand)]" />
            </Link>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
