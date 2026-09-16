/**
 * /labs/[slug] — Scenario detail page (server component).
 * Loads the published scenario, then delegates interaction to the client.
 */
import { notFound, redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Card, CardContent } from "@/components/ui/card";
import { Badge, DifficultyBadge } from "@/components/ui/badge";
import { Terminal } from "lucide-react";
import LabClient from "./lab-client";
import type { Difficulty } from "@/lib/database.types";

interface Props {
  params: Promise<{ slug: string }>;
}

export default async function LabPage({ params }: Props) {
  const { slug } = await params;
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  const { data: row, error } = await supabase
    .from("troubleshooting_scenarios")
    .select(
      "id, slug, title, description, difficulty, allowed_commands, hints, root_cause, repair_action, verification",
    )
    .eq("slug", slug)
    .eq("is_published", true)
    .maybeSingle();

  if (error || !row) notFound();

  const allowedCommands = Array.isArray(row.allowed_commands)
    ? (row.allowed_commands as unknown as string[])
    : [];
  const hints = Array.isArray(row.hints)
    ? (row.hints as unknown as string[])
    : [];
  const verification =
    typeof row.verification === "string"
      ? row.verification
      : "Verification will run automatically when the scenario is in a 'resolved' state.";

  return (
    <div className="space-y-4">
      <div className="flex items-start justify-between">
        <div>
          <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">
            {row.title}
          </h1>
          <p className="mt-1 max-w-2xl text-sm text-[var(--color-text-tertiary)]">
            {row.description}
          </p>
        </div>
        <DifficultyBadge difficulty={(row.difficulty as Difficulty) ?? "beginner"} />
      </div>

      <Card>
        <CardContent className="space-y-3 pt-4 text-sm">
          <div className="flex items-center gap-2">
            <Terminal className="h-4 w-4 text-[var(--color-brand)]" />
            <span className="font-semibold text-[var(--color-text-primary)]">
              Verification
            </span>
            <Badge variant="default">Server-authoritative</Badge>
          </div>
          <p className="text-[var(--color-text-secondary)]">{verification}</p>
          <p className="text-xs text-[var(--color-text-tertiary)]">
            Allowed commands (commands outside this list are rejected by the
            simulator):
          </p>
          <div className="flex flex-wrap gap-1.5">
            {allowedCommands.length === 0 ? (
              <span className="text-xs text-[var(--color-text-tertiary)]">
                (none declared)
              </span>
            ) : (
              allowedCommands.map((c) => (
                <code
                  key={c}
                  className="rounded bg-[var(--color-surface-raised)] px-2 py-0.5 text-xs font-mono"
                >
                  {c}
                </code>
              ))
            )}
          </div>
        </CardContent>
      </Card>

      <LabClient
        slug={row.slug}
        title={row.title}
        initialHints={hints}
        rootCause={row.root_cause ?? ""}
        repairAction={row.repair_action ?? ""}
      />
    </div>
  );
}
