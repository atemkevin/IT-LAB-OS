/**
 * /labs — Troubleshooting Labs
 * Server Component. Fetches published troubleshooting scenarios.
 */
import Link from "next/link";
import { createClient } from "@/lib/supabase/server";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Badge, DifficultyBadge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Terminal, CheckCircle2 } from "lucide-react";
import type { TroubleshootingScenario, Difficulty, TroubleshootingAttempt } from "@/lib/database.types";

export default async function LabsPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  const [scenariosRes, attemptsRes] = await Promise.all([
    supabase
      .from("troubleshooting_scenarios")
      .select("id, slug, title, description, difficulty")
      .eq("is_published", true)
      .order("difficulty", { ascending: true }),
    user
      ? supabase
          .from("troubleshooting_attempts")
          .select("scenario_id, resolved, completed_at")
          .eq("user_id", user.id)
          .eq("resolved", true)
      : Promise.resolve({ data: null, error: null }),
  ]);

  const scenarios = (scenariosRes.data ?? []) as Pick<
    TroubleshootingScenario,
    "id" | "slug" | "title" | "description" | "difficulty"
  >[];
  const completedSet = new Set(
    (attemptsRes.data ?? []).map((a: Pick<TroubleshootingAttempt, "scenario_id">) => a.scenario_id),
  );

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">Troubleshooting Labs</h1>
        <p className="text-sm text-[var(--color-text-tertiary)]">
          Deterministic incident response drills. Simulated environments, zero infrastructure risk.
        </p>
      </div>

      {scenarios.length === 0 ? (
        <div className="text-center py-12">
          <Terminal className="h-12 w-12 text-[var(--color-text-disabled)] mx-auto mb-3" />
          <p className="text-sm text-[var(--color-text-tertiary)]">No lab scenarios published yet.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3">
          {scenarios.map((s) => {
            const completed = completedSet.has(s.id);
            return (
              <Card key={s.slug} className="flex flex-col justify-between">
                <CardHeader>
                  <div className="flex items-center justify-between">
                    <DifficultyBadge difficulty={(s.difficulty as Difficulty) ?? "beginner"} />
                    {completed ? (
                      <Badge variant="positive">
                        <CheckCircle2 className="h-3 w-3" />
                        Solved
                      </Badge>
                    ) : (
                      <Badge variant="default">Simulated</Badge>
                    )}
                  </div>
                  <CardTitle className="mt-3 text-base">{s.title}</CardTitle>
                  <CardDescription>{s.description}</CardDescription>
                </CardHeader>
                <CardContent className="pt-2">
                  <Link href={`/labs/${s.slug}`}>
                    <Button variant="secondary" className="w-full">
                      <Terminal className="h-4 w-4" />
                      {completed ? "Retry Lab" : "Launch Terminal"}
                    </Button>
                  </Link>
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}
