import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { getSafeQuizQuestions } from "@/lib/learning/quizzes";
import { getAdminClient } from "@/lib/supabase/admin";
import Link from "next/link";
import { ArrowLeft } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import QuizClient from "./quiz-client";

export default async function QuizPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;

  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return (
      <div className="space-y-4 max-w-2xl mx-auto">
        <Card>
          <CardContent className="pt-4 text-center">
            <p className="text-sm text-[var(--color-text-secondary)]">
              Please <Link href="/login" className="text-[var(--color-brand)] hover:underline">sign in</Link> to take the quiz.
            </p>
          </CardContent>
        </Card>
      </div>
    );
  }

  const admin = getAdminClient();
  const { data: skill } = await admin
    .from("skills")
    .select("id, name, slug")
    .eq("slug", slug)
    .maybeSingle();

  if (!skill) notFound();

  const questions = await getSafeQuizQuestions(skill.id);

  if (questions.length === 0) {
    return (
      <div className="space-y-4 max-w-2xl mx-auto">
        <Link
          href={`/skills/${slug}`}
          className="inline-flex items-center gap-1.5 text-xs text-[var(--color-text-tertiary)] hover:text-[var(--color-text-primary)]"
        >
          <ArrowLeft className="h-3.5 w-3.5" />
          Back to {skill.name}
        </Link>
        <Card>
          <CardContent className="pt-4">
            <p className="text-sm text-[var(--color-text-tertiary)]">No quiz questions available yet.</p>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="space-y-6 max-w-2xl mx-auto">
      <Link
        href={`/skills/${slug}`}
        className="inline-flex items-center gap-1.5 text-xs text-[var(--color-text-tertiary)] hover:text-[var(--color-text-primary)]"
      >
        <ArrowLeft className="h-3.5 w-3.5" />
        Back to {skill.name}
      </Link>

      <div>
        <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">{skill.name} Quiz</h1>
        <p className="text-sm text-[var(--color-text-secondary)]">
          {questions.length} question{questions.length !== 1 ? "s" : ""} · Score 70%+ to pass and earn mastery evidence.
        </p>
      </div>

      <QuizClient questions={questions} skillSlug={slug} />
    </div>
  );
}