import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { getAdminClient } from "@/lib/supabase/admin";
import Link from "next/link";
import { ArrowLeft, CheckCircle2 } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import PracticeClient from "./practice-client";

export default async function PracticeTaskPage({
  params,
}: {
  params: Promise<{ slug: string; taskId: string }>;
}) {
  const { slug, taskId } = await params;
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  const admin = getAdminClient();
  const { data: task } = await admin
    .from("practice_tasks")
    .select("*")
    .eq("id", taskId)
    .maybeSingle();

  if (!task) notFound();

  const { data: skill } = await admin
    .from("skills")
    .select("id, name, slug")
    .eq("id", task.skill_id)
    .maybeSingle();

  return (
    <div className="space-y-6 max-w-2xl mx-auto">
      <Link
        href={`/skills/${slug}`}
        className="inline-flex items-center gap-1.5 text-xs text-[var(--color-text-tertiary)] hover:text-[var(--color-text-primary)]"
      >
        <ArrowLeft className="h-3.5 w-3.5" />
        Back to {skill?.name ?? "Skill"}
      </Link>

      <div>
        <h1 className="text-xl font-bold text-[var(--color-text-primary)]">{task.title}</h1>
        {task.objective && (
          <p className="text-sm text-[var(--color-text-secondary)] mt-1">{task.objective}</p>
        )}
      </div>

      {task.context && (
        <Card>
          <CardHeader>
            <CardTitle className="text-sm">Context</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-[var(--color-text-secondary)]">{task.context}</p>
          </CardContent>
        </Card>
      )}

      {Array.isArray(task.requirements) && (task.requirements as string[]).length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle className="text-sm">Requirements</CardTitle>
          </CardHeader>
          <CardContent>
            <ol className="space-y-2">
              {(task.requirements as string[]).map((req, i) => (
                <li key={i} className="flex items-start gap-2 text-sm text-[var(--color-text-secondary)]">
                  <span className="text-[var(--color-brand)] font-mono text-xs mt-0.5">{i + 1}.</span>
                  {req}
                </li>
              ))}
            </ol>
          </CardContent>
        </Card>
      )}

      {Array.isArray(task.hints) && (task.hints as string[]).length > 0 && (
        <Card className="border-[var(--color-brand)]/20">
          <CardHeader>
            <CardTitle className="text-sm text-[var(--color-brand)]">Hints</CardTitle>
          </CardHeader>
          <CardContent>
            <ul className="space-y-1">
              {(task.hints as string[]).map((hint, i) => (
                <li key={i} className="text-xs text-[var(--color-text-tertiary)]">💡 {hint}</li>
              ))}
            </ul>
          </CardContent>
        </Card>
      )}

      {Array.isArray(task.success_criteria) && (task.success_criteria as string[]).length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle className="text-sm">Success Criteria</CardTitle>
            <CardDescription className="text-xs">Check these off when done</CardDescription>
          </CardHeader>
          <CardContent>
            <ul className="space-y-2">
              {(task.success_criteria as string[]).map((criterion, i) => (
                <li key={i} className="flex items-start gap-2 text-sm text-[var(--color-text-secondary)]">
                  <CheckCircle2 className="h-4 w-4 shrink-0 text-[var(--color-text-tertiary)] mt-0.5" />
                  {criterion}
                </li>
              ))}
            </ul>
          </CardContent>
        </Card>
      )}

      {user && skill ? (
        <PracticeClient taskId={taskId} skillId={skill.id} skillSlug={slug} />
      ) : (
        <Card>
          <CardContent className="pt-4 text-center">
            <p className="text-sm text-[var(--color-text-secondary)]">
              <Link href="/login" className="text-[var(--color-brand)] hover:underline">Sign in</Link> to record your progress.
            </p>
          </CardContent>
        </Card>
      )}
    </div>
  );
}