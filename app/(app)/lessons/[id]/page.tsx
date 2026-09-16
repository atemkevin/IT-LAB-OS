import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { getLessonById } from "@/lib/learning/lessons";
import { Card, CardContent } from "@/components/ui/card";
import Link from "next/link";
import { ArrowLeft, ArrowRight, BookOpen } from "lucide-react";
import LessonProgressClient from "./lesson-progress-client";

export default async function LessonPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  const lesson = await getLessonById(id);
  if (!lesson) notFound();

  // Get skill for context
  const { data: skill } = await supabase
    .from("skills")
    .select("id, name, slug")
    .eq("id", lesson.skill_id)
    .maybeSingle();

  // Get user progress for this lesson
  let currentStatus = "not_started";
  if (user) {
    const { data: progress } = await supabase
      .from("user_lesson_progress")
      .select("status")
      .eq("user_id", user.id)
      .eq("lesson_id", id)
      .maybeSingle();
    currentStatus = progress?.status ?? "not_started";
  }

  return (
    <div className="space-y-6 max-w-3xl mx-auto">
      {/* Back navigation */}
      {skill && (
        <Link
          href={`/skills/${skill.slug}`}
          className="inline-flex items-center gap-1.5 text-xs text-[var(--color-text-tertiary)] hover:text-[var(--color-text-primary)]"
        >
          <ArrowLeft className="h-3.5 w-3.5" />
          Back to {skill.name}
        </Link>
      )}

      {/* Lesson header */}
      <div className="space-y-1">
        <div className="flex items-center gap-2">
          <BookOpen className="h-4 w-4 text-[var(--color-brand)]" />
          <span className="text-xs text-[var(--color-brand)] font-medium">{skill?.name ?? "Lesson"}</span>
        </div>
        <h1 className="text-2xl font-bold text-[var(--color-text-primary)]">{lesson.title}</h1>
        {lesson.summary && (
          <p className="text-sm text-[var(--color-text-secondary)]">{lesson.summary}</p>
        )}
        <p className="text-xs text-[var(--color-text-tertiary)]">~{lesson.estimated_minutes} min</p>
      </div>

      {/* Lesson sections */}
      {lesson.sections.length > 0 ? (
        <div className="space-y-4">
          {lesson.sections.map((section) => (
            <Card key={section.id}>
              <CardContent className="pt-4">
                {section.title && (
                  <h3 className="text-sm font-semibold text-[var(--color-text-primary)] mb-2 uppercase tracking-wide">
                    {section.title}
                  </h3>
                )}
                {section.content_markdown && (
                  <div
                    className="prose prose-sm prose-invert max-w-none text-[var(--color-text-secondary)]"
                    dangerouslySetInnerHTML={{ __html: markdownToHtml(section.content_markdown) }}
                  />
                )}
              </CardContent>
            </Card>
          ))}
        </div>
      ) : (
        /* Full content_markdown lesson (no sections) */
        lesson.content_markdown && (
          <Card>
            <CardContent className="pt-4">
              <div
                className="prose prose-sm prose-invert max-w-none text-[var(--color-text-secondary)]"
                dangerouslySetInnerHTML={{ __html: markdownToHtml(lesson.content_markdown) }}
              />
            </CardContent>
          </Card>
        )
      )}

      {/* Progress tracking client component */}
      {user && skill && (
        <LessonProgressClient
          lessonId={id}
          skillId={skill.id}
          initialStatus={currentStatus}
          skillSlug={skill.slug}
        />
      )}

      {!user && (
        <Card className="border-[var(--color-brand)]/30">
          <CardContent className="pt-4 text-center space-y-2">
            <p className="text-sm text-[var(--color-text-secondary)]">
              Sign in to track your progress
            </p>
            <Link href="/login" className="text-[var(--color-brand)] text-sm hover:underline">
              Sign in →
            </Link>
          </CardContent>
        </Card>
      )}
    </div>
  );
}

/**
 * Minimal markdown-to-HTML converter.
 * For production, replace with a proper library (marked, remark, etc.).
 */
function markdownToHtml(md: string): string {
  let html = md
    // Code blocks
    .replace(/```(\w+)?\n([\s\S]*?)```/g, (_, lang, code) =>
      `<pre class="bg-[var(--color-surface-elevated)] rounded p-4 overflow-x-auto text-xs font-mono my-3"><code>${escapeHtml(code.trim())}</code></pre>`
    )
    // Inline code
    .replace(/`([^`]+)`/g, '<code class="bg-[var(--color-surface-elevated)] px-1 rounded text-xs font-mono">$1</code>')
    // Headers
    .replace(/^### (.+)$/gm, '<h3 class="text-sm font-semibold text-[var(--color-text-primary)] mt-4 mb-2">$1</h3>')
    .replace(/^## (.+)$/gm, '<h2 class="text-base font-semibold text-[var(--color-text-primary)] mt-5 mb-2">$1</h2>')
    .replace(/^# (.+)$/gm, '<h1 class="text-lg font-bold text-[var(--color-text-primary)] mt-6 mb-3">$1</h1>')
    // Bold
    .replace(/\*\*(.+?)\*\*/g, '<strong class="font-semibold text-[var(--color-text-primary)]">$1</strong>')
    // Tables — basic
    .replace(/\|(.+)\|/g, (match) => {
      const cells = match.split("|").filter((c) => c.trim());
      return `<tr>${cells.map((c) => `<td class="border border-[var(--color-border)] px-2 py-1 text-xs">${c.trim()}</td>`).join("")}</tr>`;
    })
    // Lists
    .replace(/^- (.+)$/gm, '<li class="ml-4 list-disc text-sm">$1</li>')
    // Paragraphs
    .replace(/\n\n(.+)/g, '<p class="text-sm my-2">$1</p>');

  return html;
}

function escapeHtml(s: string): string {
  return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}