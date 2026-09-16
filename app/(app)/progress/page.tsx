import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { getProgressMetrics } from "@/lib/learning/dashboard";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";

export default async function ProgressPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const metrics = await getProgressMetrics(user.id);

  const dimensions = [
    { label: "Knowledge (Quizzes & Reading)", value: metrics.knowledgeAvg, weight: 30, color: "var(--color-brand)" },
    { label: "Hands-on Practice Tasks", value: metrics.practiceAvg, weight: 20, color: "var(--color-positive)" },
    { label: "Incident & Lab Scenarios", value: metrics.troubleshootingAvg, weight: 25, color: "var(--color-warning)" },
    { label: "Capstone & Applied Projects", value: metrics.projectAvg, weight: 15, color: "var(--color-info)" },
    { label: "Spaced Repetition & Retention", value: metrics.retentionAvg, weight: 10, color: "var(--color-mastery-strong)" },
  ] as const;

  const distribution = [
    { label: "Strong (85-100%)", count: metrics.distribution.strong, color: "var(--color-mastery-strong)" },
    { label: "Proficient (70-84%)", count: metrics.distribution.proficient, color: "var(--color-mastery-proficient)" },
    { label: "Practicing (50-69%)", count: metrics.distribution.practicing, color: "var(--color-mastery-practicing)" },
    { label: "Developing (30-49%)", count: metrics.distribution.developing, color: "var(--color-mastery-developing)" },
    { label: "Not Started (0-29%)", count: metrics.distribution.notStarted, color: "var(--color-mastery-not-started)" },
  ] as const;

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
            {dimensions.map((dim) => (
              <div key={dim.label}>
                <div className="flex justify-between text-xs mb-1">
                  <span className="text-[var(--color-text-secondary)]">{dim.label}</span>
                  <span className="font-mono text-[var(--color-text-primary)]">{dim.weight}%</span>
                </div>
                <Progress value={dim.value} />
                <p className="mt-0.5 text-right text-[10px] text-[var(--color-text-tertiary)]">
                  Avg {dim.value}%
                </p>
              </div>
            ))}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Mastery Distribution</CardTitle>
            <CardDescription>Skill count across proficiency tiers</CardDescription>
          </CardHeader>
          <CardContent className="space-y-3 text-xs">
            {distribution.map((tier, i) => (
              <div
                key={tier.label}
                className={`flex items-center justify-between ${i < distribution.length - 1 ? "border-b border-[var(--color-border)] pb-2" : ""}`}
              >
                <span className="font-semibold" style={{ color: tier.color }}>
                  {tier.label}
                </span>
                <span className="font-mono">{tier.count} skills</span>
              </div>
            ))}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
