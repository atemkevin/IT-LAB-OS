import { notFound } from "next/navigation";
import { getPublicPortfolio } from "@/lib/portfolio/service";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Badge, MasteryBadge } from "@/components/ui/badge";
import { PortfolioActions } from "./portfolio-actions";
import {
  ShieldCheck,
  Trophy,
  Flame,
  Terminal,
  Layers,
  Award,
  Calendar,
  Sparkles,
} from "lucide-react";
import type { MasteryState } from "@/lib/database.types";

interface Props {
  params: Promise<{ userId: string }>;
}

export default async function PublicPortfolioPage({ params }: Props) {
  const { userId } = await params;
  const portfolio = await getPublicPortfolio(userId);

  if (!portfolio) {
    notFound();
  }

  const { learner, metrics, domains, achievements, labsSolved, verificationSignature } = portfolio;

  return (
    <div className="min-h-screen bg-[var(--color-surface-base)] text-[var(--color-text-primary)]">
      {/* Top Banner Navigation */}
      <header className="border-b border-[var(--color-border)] bg-[var(--color-surface)] py-4 px-6">
        <div className="max-w-5xl mx-auto flex items-center justify-between">
          <div className="flex items-center gap-2">
            <span className="flex h-8 w-8 items-center justify-center rounded-lg bg-[var(--color-brand)] text-white font-bold text-sm">
              IT
            </span>
            <span className="font-bold text-base tracking-tight">IT Lab OS</span>
            <Badge variant="default" className="text-[10px] ml-1">
              Verified Learner Portfolio
            </Badge>
          </div>
          <div className="flex items-center gap-2">
            <PortfolioActions portfolio={portfolio} />
          </div>
        </div>
      </header>

      <main className="max-w-5xl mx-auto py-8 px-4 sm:px-6 space-y-6">
        {/* Profile Header Card */}
        <Card className="border-[var(--color-border)] bg-[var(--color-surface)] overflow-hidden shadow-sm">
          <CardContent className="p-6 sm:p-8">
            <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-6">
              <div className="flex items-center gap-4">
                <div className="flex h-16 w-16 shrink-0 items-center justify-center rounded-2xl bg-gradient-to-br from-[var(--color-brand)] to-indigo-600 text-white font-bold text-2xl shadow-inner">
                  {learner.displayName.charAt(0).toUpperCase()}
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">
                      {learner.displayName}
                    </h1>
                    <span title="Verified Learner Record" className="text-[var(--color-brand)]">
                      <ShieldCheck className="h-5 w-5" />
                    </span>
                  </div>
                  {learner.primaryGoal && (
                    <p className="text-sm text-[var(--color-text-secondary)] mt-0.5">
                      Target: {learner.primaryGoal}
                    </p>
                  )}
                  <p className="text-xs text-[var(--color-text-tertiary)] mt-1 flex items-center gap-1.5">
                    <Calendar className="h-3.5 w-3.5" />
                    Member since {new Date(learner.memberSince).toLocaleDateString(undefined, { month: "short", year: "numeric" })}
                  </p>
                </div>
              </div>

              {/* Cryptographic Verification Badge */}
              <div className="flex flex-col sm:items-end bg-[var(--color-surface-raised)] border border-[var(--color-border)] rounded-xl p-3 text-xs">
                <span className="text-[10px] uppercase font-semibold text-[var(--color-text-tertiary)] tracking-wider">
                  Verification Signature
                </span>
                <span className="font-mono text-xs text-[var(--color-brand)] font-bold mt-0.5 tracking-wider">
                  {verificationSignature}
                </span>
                <span className="text-[10px] text-[var(--color-text-tertiary)] mt-0.5 flex items-center gap-1">
                  <Sparkles className="h-2.5 w-2.5 text-[var(--color-warning)]" />
                  Evidence Cryptographically Verified
                </span>
              </div>
            </div>

            {/* Metrics Overview Grid */}
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mt-8 pt-6 border-t border-[var(--color-border)]">
              <div className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-raised)] p-3.5">
                <div className="flex items-center gap-1.5 text-xs text-[var(--color-text-tertiary)]">
                  <Award className="h-3.5 w-3.5 text-[var(--color-brand)]" />
                  Overall Mastery
                </div>
                <div className="text-2xl font-bold text-[var(--color-text-primary)] mt-1">
                  {metrics.overallMastery}%
                </div>
                <div className="text-[11px] text-[var(--color-brand)] font-medium mt-0.5">
                  Tier: {metrics.masteryTier}
                </div>
              </div>

              <div className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-raised)] p-3.5">
                <div className="flex items-center gap-1.5 text-xs text-[var(--color-text-tertiary)]">
                  <Flame className="h-3.5 w-3.5 text-orange-400" />
                  Study Streak
                </div>
                <div className="text-2xl font-bold text-[var(--color-text-primary)] mt-1">
                  {learner.currentStreak} <span className="text-xs font-normal text-[var(--color-text-tertiary)]">days</span>
                </div>
                <div className="text-[11px] text-[var(--color-text-tertiary)] mt-0.5">
                  Record: {learner.longestStreak} days
                </div>
              </div>

              <div className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-raised)] p-3.5">
                <div className="flex items-center gap-1.5 text-xs text-[var(--color-text-tertiary)]">
                  <Terminal className="h-3.5 w-3.5 text-emerald-400" />
                  Labs Solved
                </div>
                <div className="text-2xl font-bold text-[var(--color-text-primary)] mt-1">
                  {metrics.totalLabsSolved}
                </div>
                <div className="text-[11px] text-[var(--color-text-tertiary)] mt-0.5">
                  Container Drills
                </div>
              </div>

              <div className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-raised)] p-3.5">
                <div className="flex items-center gap-1.5 text-xs text-[var(--color-text-tertiary)]">
                  <Trophy className="h-3.5 w-3.5 text-yellow-400" />
                  Achievements
                </div>
                <div className="text-2xl font-bold text-[var(--color-text-primary)] mt-1">
                  {metrics.totalAchievements}
                </div>
                <div className="text-[11px] text-[var(--color-text-tertiary)] mt-0.5">
                  Verified Badges
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* 2-Column Section: Domain Mastery & Solved Incident Labs */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Left Column (2/3): Skill Domain Breakdown */}
          <div className="lg:col-span-2 space-y-6">
            <Card className="border-[var(--color-border)] bg-[var(--color-surface)]">
              <CardHeader className="pb-3">
                <CardTitle className="text-base flex items-center gap-2">
                  <Layers className="h-4 w-4 text-[var(--color-brand)]" />
                  Verified Skill Domains &amp; Competencies
                </CardTitle>
                <CardDescription>
                  5-dimensional evidence-backed evaluation across theory, labs, and retention.
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-6 pt-0">
                {domains.map((domain) => (
                  <div key={domain.slug} className="space-y-2.5">
                    <h3 className="text-xs font-semibold text-[var(--color-text-secondary)] uppercase tracking-wider">
                      {domain.name}
                    </h3>
                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                      {domain.skills.map((skill) => (
                        <div
                          key={skill.slug}
                          className="flex items-center justify-between p-2.5 rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-raised)]"
                        >
                          <div>
                            <span className="text-xs font-medium text-[var(--color-text-primary)] block">
                              {skill.name}
                            </span>
                            <span className="text-[10px] text-[var(--color-text-tertiary)] capitalize">
                              {skill.difficulty}
                            </span>
                          </div>
                          <div className="text-right">
                            <MasteryBadge state={skill.masteryState as MasteryState} />
                            <span className="text-[10px] text-[var(--color-text-tertiary)] font-mono block mt-0.5">
                              {skill.masteryScore}%
                            </span>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                ))}
              </CardContent>
            </Card>

            {/* Solved Incidents & Labs */}
            <Card className="border-[var(--color-border)] bg-[var(--color-surface)]">
              <CardHeader className="pb-3">
                <CardTitle className="text-base flex items-center gap-2">
                  <Terminal className="h-4 w-4 text-[var(--color-positive)]" />
                  Incident Response Drills Solved
                </CardTitle>
                <CardDescription>
                  Real troubleshooting scenarios resolved in isolated container environments.
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-2 pt-0">
                {labsSolved.length === 0 ? (
                  <p className="text-xs text-[var(--color-text-tertiary)] py-4 text-center">
                    No troubleshooting drills logged yet.
                  </p>
                ) : (
                  labsSolved.map((lab) => (
                    <div
                      key={lab.slug}
                      className="flex items-center justify-between p-3 rounded-lg border border-[var(--color-border)] bg-[var(--color-surface-raised)]"
                    >
                      <div className="flex items-center gap-2.5">
                        <div className="flex h-7 w-7 items-center justify-center rounded-md bg-emerald-500/10 text-emerald-400">
                          <Terminal className="h-3.5 w-3.5" />
                        </div>
                        <div>
                          <span className="text-xs font-semibold text-[var(--color-text-primary)] block">
                            {lab.title}
                          </span>
                          <span className="text-[10px] text-[var(--color-text-tertiary)]">
                            Solved on {new Date(lab.completedAt).toLocaleDateString()}
                          </span>
                        </div>
                      </div>
                      <Badge variant="positive" className="text-[10px]">
                        Resolved
                      </Badge>
                    </div>
                  ))
                )}
              </CardContent>
            </Card>
          </div>

          {/* Right Column (1/3): Badges & Achievements */}
          <div className="space-y-6">
            <Card className="border-[var(--color-border)] bg-[var(--color-surface)]">
              <CardHeader className="pb-3">
                <CardTitle className="text-base flex items-center gap-2">
                  <Trophy className="h-4 w-4 text-yellow-400" />
                  Earned Badges
                </CardTitle>
                <CardDescription>
                  Milestones and accomplishments.
                </CardDescription>
              </CardHeader>
              <CardContent className="space-y-3 pt-0">
                {achievements.length === 0 ? (
                  <p className="text-xs text-[var(--color-text-tertiary)] py-4 text-center">
                    No achievements unlocked yet.
                  </p>
                ) : (
                  achievements.map((ach) => (
                    <div
                      key={ach.id}
                      className="flex items-start gap-3 p-3 rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-raised)]"
                    >
                      <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-yellow-500/10 text-yellow-400 text-lg">
                        {ach.icon || "🏆"}
                      </div>
                      <div className="flex-1 min-w-0">
                        <span className="text-xs font-semibold text-[var(--color-text-primary)] block truncate">
                          {ach.name}
                        </span>
                        <span className="text-[11px] text-[var(--color-text-secondary)] block line-clamp-2 mt-0.5">
                          {ach.description}
                        </span>
                        <span className="text-[10px] text-[var(--color-text-tertiary)] block mt-1">
                          Earned {new Date(ach.earnedAt).toLocaleDateString()}
                        </span>
                      </div>
                    </div>
                  ))
                )}
              </CardContent>
            </Card>
          </div>
        </div>
      </main>

      {/* Public Footer */}
      <footer className="border-t border-[var(--color-border)] py-8 px-6 mt-12 text-center text-xs text-[var(--color-text-tertiary)]">
        <p>
          Verified Skill Portfolio generated by <strong>IT Lab OS</strong>. Learn → Practice → Test → Troubleshoot → Build.
        </p>
      </footer>
    </div>
  );
}
