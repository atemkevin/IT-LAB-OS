import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { getSkillDetail } from "@/lib/learning/skills";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Badge, MasteryBadge, DifficultyBadge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import Link from "next/link";
import { ArrowLeft, BookOpen, CheckCircle2, Clock, HelpCircle, Lock, Terminal, Zap } from "lucide-react";
import { LessonProgressButton } from "@/components/lesson-progress-button";

const MASTERY_WEIGHT_LABELS = [
  { key: "knowledge_score", label: "Knowledge", weight: "30%" },
  { key: "practice_score", label: "Practice", weight: "20%" },
  { key: "troubleshooting_score", label: "Troubleshoot", weight: "25%" },
  { key: "project_score", label: "Project", weight: "15%" },
  { key: "retention_score", label: "Retention", weight: "10%" },
] as const;

export default async function SkillDetailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  const skill = await getSkillDetail(slug, user?.id ?? null);
  if (!skill) notFound();

  const masteryState = skill.userProgress?.mastery_state ?? "not_started";
  const masteryScore = Number(skill.userProgress?.mastery_score ?? 0);

  return (
    <div className="space-y-6">
      {/* Back link */}
      <Link
        href="/skills"
        className="inline-flex items-center gap-1.5 text-xs text-[var(--color-text-tertiary)] hover:text-[var(--color-text-primary)]"
      >
        <ArrowLeft className="h-3.5 w-3.5" />
        Back to Skills
      </Link>

      {/* Header */}
      <div className="flex flex-col gap-2 sm:flex-row sm:items-start sm:justify-between">
        <div className="space-y-1">
          <div className="flex items-center gap-2 flex-wrap">
            <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">{skill.name}</h1>
            <DifficultyBadge difficulty={skill.difficulty as "beginner" | "intermediate" | "advanced"} />
          </div>
          <p className="text-xs text-[var(--color-brand)]">{skill.domain.name}</p>
          {skill.description && (
            <p className="text-sm text-[var(--color-text-secondary)] max-w-2xl">{skill.description}</p>
          )}
          <p className="text-xs text-[var(--color-text-tertiary)]">
            <Clock className="inline h-3 w-3 mr-1" />
            ~{skill.estimated_minutes} min to complete
          </p>
        </div>
        <div className="flex flex-col items-end gap-2">
          <MasteryBadge state={masteryState as "not_started" | "developing" | "practicing" | "proficient" | "strong"} />
          <span className="text-2xl font-bold text-[var(--color-text-primary)]">{masteryScore.toFixed(0)}%</span>
        </div>
      </div>

      {/* Why it matters */}
      {skill.why_it_matters && (
        <Card className="border-[var(--color-brand)]/30 bg-[var(--color-brand)]/5">
          <CardContent className="pt-4">
            <p className="text-xs font-semibold text-[var(--color-brand)] uppercase tracking-wide mb-1">Why It Matters</p>
            <p className="text-sm text-[var(--color-text-secondary)]">{skill.why_it_matters}</p>
          </CardContent>
        </Card>
      )}

      {/* Mastery Breakdown */}
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-5">
        {MASTERY_WEIGHT_LABELS.map(({ key, label, weight }) => {
          const score = Number(skill.userProgress?.[key] ?? 0);
          return (
            <Card key={key} className="p-3 text-center">
              <p className="text-xs text-[var(--color-text-tertiary)]">{label}</p>
              <p className="text-xs text-[var(--color-text-tertiary)]">({weight})</p>
              <p className="text-lg font-bold text-[var(--color-text-primary)] mt-1">{score.toFixed(0)}%</p>
            </Card>
          );
        })}
      </div>

      {/* Learning objectives */}
      {Array.isArray(skill.learning_objectives) && (skill.learning_objectives as string[]).length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle className="text-sm">Learning Objectives</CardTitle>
          </CardHeader>
          <CardContent>
            <ul className="space-y-2">
              {(skill.learning_objectives as string[]).map((obj, i) => (
                <li key={i} className="flex items-start gap-2 text-sm text-[var(--color-text-secondary)]">
                  <CheckCircle2 className="h-4 w-4 shrink-0 text-[var(--color-brand)] mt-0.5" />
                  {obj}
                </li>
              ))}
            </ul>
          </CardContent>
        </Card>
      )}

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        {/* Prerequisites */}
        {skill.prerequisites.length > 0 && (
          <Card className="lg:col-span-1">
            <CardHeader>
              <CardTitle className="text-sm">Prerequisites</CardTitle>
            </CardHeader>
            <CardContent className="space-y-2">
              {skill.prerequisites.map((p) => (
                <div key={p.skill.id} className="flex items-center justify-between text-xs">
                  <div className="flex items-center gap-1.5">
                    {p.isMet ? (
                      <CheckCircle2 className="h-3.5 w-3.5 text-green-500" />
                    ) : (
                      <Lock className="h-3.5 w-3.5 text-[var(--color-text-tertiary)]" />
                    )}
                    <Link href={`/skills/${p.skill.slug}`} className="hover:underline text-[var(--color-text-secondary)]">
                      {p.skill.name}
                    </Link>
                  </div>
                  <span className="text-[var(--color-text-tertiary)]">{p.currentMastery.toFixed(0)}%/{p.requiredMastery}%</span>
                </div>
              ))}
            </CardContent>
          </Card>
        )}

        {/* Lessons */}
        <Card className={skill.prerequisites.length > 0 ? "lg:col-span-2" : "lg:col-span-3"}>
          <CardHeader>
            <CardTitle className="text-sm">Lessons</CardTitle>
            <CardDescription className="text-xs">
              {skill.lessons.length} lesson{skill.lessons.length !== 1 ? "s" : ""} · Core concepts, examples, and exercises
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-2">
            {skill.lessons.length === 0 ? (
              <p className="text-xs text-[var(--color-text-tertiary)]">Lessons coming soon.</p>
            ) : (
              skill.lessons.map((lesson, i) => {
                const status = lesson.progress?.status ?? "not_started";
                return (
                  <div key={lesson.id} className="flex items-center justify-between rounded-md border border-[var(--color-border)] px-3 py-2">
                    <div className="flex items-center gap-2 text-sm">
                      <span className="text-xs font-mono text-[var(--color-text-tertiary)] w-5">{i + 1}.</span>
                      <span className="text-[var(--color-text-secondary)]">{lesson.title}</span>
                      {status === "completed" && <CheckCircle2 className="h-3.5 w-3.5 text-green-500" />}
                      {status === "in_progress" && <span className="text-xs text-[var(--color-brand)]">In Progress</span>}
                    </div>
                    <LessonProgressButton
                      lessonId={lesson.id}
                      initialStatus={status as "not_started" | "in_progress" | "completed"}
                    />
                  </div>
                );
              })
            )}
          </CardContent>
        </Card>
      </div>

      {/* Practice Tasks + Quiz */}
      <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
        {/* Practice */}
        <Card>
          <CardHeader>
            <CardTitle className="text-sm flex items-center gap-2">
              <Terminal className="h-4 w-4" />
              Practice Tasks
            </CardTitle>
            <CardDescription className="text-xs">
              {skill.practiceTasks.length} task{skill.practiceTasks.length !== 1 ? "s" : ""} · Hands-on application
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-2">
            {skill.practiceTasks.length === 0 ? (
              <p className="text-xs text-[var(--color-text-tertiary)]">Practice tasks coming soon.</p>
            ) : (
              skill.practiceTasks.map((task) => (
                <div key={task.id} className="rounded-md border border-[var(--color-border)] p-3 space-y-1">
                  <p className="text-sm font-medium text-[var(--color-text-primary)]">{task.title}</p>
                  {task.objective && (
                    <p className="text-xs text-[var(--color-text-tertiary)]">{task.objective}</p>
                  )}
                  <Link href={`/skills/${skill.slug}/practice/${task.id}`}>
                    <Button size="sm" variant="outline" className="mt-1 h-7 text-xs">
                      <Zap className="h-3 w-3 mr-1" />
                      Start Task
                    </Button>
                  </Link>
                </div>
              ))
            )}
          </CardContent>
        </Card>

        {/* Quiz */}
        <Card>
          <CardHeader>
            <CardTitle className="text-sm flex items-center gap-2">
              <HelpCircle className="h-4 w-4" />
              Knowledge Quiz
            </CardTitle>
            <CardDescription className="text-xs">
              {skill.quizQuestionCount} question{skill.quizQuestionCount !== 1 ? "s" : ""} · Server-graded
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-3">
            {skill.quizQuestionCount === 0 ? (
              <p className="text-xs text-[var(--color-text-tertiary)]">Quiz coming soon.</p>
            ) : (
              <>
                <p className="text-xs text-[var(--color-text-secondary)]">
                  Test your understanding. You need 70% to pass and earn mastery evidence.
                </p>
                {skill.accessState === "locked" ? (
                  <p className="text-xs text-[var(--color-text-tertiary)]">🔒 Complete prerequisites first.</p>
                ) : (
                  <Link href={`/skills/${skill.slug}/quiz`}>
                    <Button className="w-full">
                      <HelpCircle className="h-4 w-4 mr-2" />
                      Take Quiz
                    </Button>
                  </Link>
                )}
              </>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}