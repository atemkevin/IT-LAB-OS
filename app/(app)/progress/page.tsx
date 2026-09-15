import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";

export default function ProgressPage() {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">Progress & Analytics</h1>
        <p className="text-sm text-[var(--color-text-tertiary)]">
          Continuous tracking of your weighted skill mastery and retention curves.
        </p>
      </div>

      <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Mastery Formula Breakdown</CardTitle>
            <CardDescription>
              Balanced 5-pillar score evaluated server-side.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <div className="flex justify-between text-xs mb-1">
                <span className="text-[var(--color-text-secondary)]">Knowledge (Quizzes & Reading)</span>
                <span className="font-mono text-[var(--color-text-primary)]">30%</span>
              </div>
              <Progress value={0} />
            </div>

            <div>
              <div className="flex justify-between text-xs mb-1">
                <span className="text-[var(--color-text-secondary)]">Hands-on Practice Tasks</span>
                <span className="font-mono text-[var(--color-text-primary)]">20%</span>
              </div>
              <Progress value={0} />
            </div>

            <div>
              <div className="flex justify-between text-xs mb-1">
                <span className="text-[var(--color-text-secondary)]">Incident & Lab Scenarios</span>
                <span className="font-mono text-[var(--color-text-primary)]">25%</span>
              </div>
              <Progress value={0} />
            </div>

            <div>
              <div className="flex justify-between text-xs mb-1">
                <span className="text-[var(--color-text-secondary)]">Capstone & Applied Projects</span>
                <span className="font-mono text-[var(--color-text-primary)]">15%</span>
              </div>
              <Progress value={0} />
            </div>

            <div>
              <div className="flex justify-between text-xs mb-1">
                <span className="text-[var(--color-text-secondary)]">Spaced Repetition & Retention</span>
                <span className="font-mono text-[var(--color-text-primary)]">10%</span>
              </div>
              <Progress value={0} />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Mastery Distribution</CardTitle>
            <CardDescription>Skill count across proficiency tiers</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3 text-xs">
            <div className="flex items-center justify-between border-b border-[var(--color-border)] pb-2">
              <span className="text-[var(--color-mastery-strong)] font-semibold">Strong (85-100%)</span>
              <span className="font-mono">0 skills</span>
            </div>
            <div className="flex items-center justify-between border-b border-[var(--color-border)] pb-2">
              <span className="text-[var(--color-mastery-proficient)] font-semibold">Proficient (70-84%)</span>
              <span className="font-mono">0 skills</span>
            </div>
            <div className="flex items-center justify-between border-b border-[var(--color-border)] pb-2">
              <span className="text-[var(--color-mastery-practicing)] font-semibold">Practicing (50-69%)</span>
              <span className="font-mono">0 skills</span>
            </div>
            <div className="flex items-center justify-between border-b border-[var(--color-border)] pb-2">
              <span className="text-[var(--color-mastery-developing)] font-semibold">Developing (30-49%)</span>
              <span className="font-mono">0 skills</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-[var(--color-mastery-not-started)] font-semibold">Not Started (0-29%)</span>
              <span className="font-mono">26 skills</span>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
