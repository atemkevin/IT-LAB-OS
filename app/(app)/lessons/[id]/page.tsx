import { notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { getLessonById } from "@/lib/learning/lessons";
import { Card, CardContent } from "@/components/ui/card";
import { DifficultyBadge } from "@/components/ui/badge";
import type { Difficulty } from "@/lib/database.types";
import Link from "next/link";
import {
  ArrowLeft,
  ArrowRight,
  BookOpen,
  Terminal,
  Code2,
  Wrench,
  AlertTriangle,
  Clock,
  CheckCircle2,
  HelpCircle,
  FileCode2,
  Layers,
  Bookmark,
  Sparkles,
} from "lucide-react";
import LessonProgressClient from "./lesson-progress-client";

export default async function LessonPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const lesson = await getLessonById(id);
  if (!lesson) notFound();

  // 1. Get skill for context
  const { data: skill } = await supabase
    .from("skills")
    .select("id, name, slug, description")
    .eq("id", lesson.skill_id)
    .maybeSingle();

  // 2. Query sibling lessons in this skill for navigation and order indicator
  const { data: rawSiblings } = await supabase
    .from("lessons")
    .select("id, slug, title, difficulty, sort_order, estimated_minutes")
    .eq("skill_id", lesson.skill_id)
    .eq("is_published", true)
    .order("sort_order");

  const siblings = rawSiblings ?? [];
  const currentIndex = siblings.findIndex((s) => s.id === id);
  const prevLesson = currentIndex > 0 ? siblings[currentIndex - 1] : null;
  const nextLesson =
    currentIndex >= 0 && currentIndex < siblings.length - 1
      ? siblings[currentIndex + 1]
      : null;
  const lessonNumber = currentIndex >= 0 ? currentIndex + 1 : lesson.sort_order;
  const totalLessons = siblings.length || 1;

  // 3. Query practice tasks & quiz questions for the skill
  const [taskResult, quizResult] = await Promise.all([
    supabase
      .from("practice_tasks")
      .select("id, title, objective")
      .eq("skill_id", lesson.skill_id)
      .eq("is_published", true)
      .limit(1)
      .maybeSingle(),
    supabase
      .from("quiz_questions")
      .select("id")
      .eq("skill_id", lesson.skill_id),
  ]);

  const practiceTask = taskResult.data;
  const quizCount = quizResult.data?.length ?? 0;

  // 4. Get user progress for this lesson
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
    <div className="space-y-8 max-w-4xl mx-auto pb-16">
      {/* Top Header & Breadcrumbs */}
      <div className="space-y-4">
        <div className="flex flex-wrap items-center justify-between gap-3 text-xs text-[var(--color-text-tertiary)]">
          {skill && (
            <Link
              href={`/skills/${skill.slug}`}
              className="inline-flex items-center gap-1.5 hover:text-[var(--color-text-primary)] transition-colors"
            >
              <ArrowLeft className="h-3.5 w-3.5" />
              <span>Back to {skill.name}</span>
            </Link>
          )}

          <div className="flex items-center gap-2">
            <span className="px-2 py-0.5 rounded bg-[var(--color-surface-elevated)] border border-[var(--color-border)] text-[11px] font-mono">
              Lesson {lessonNumber} of {totalLessons}
            </span>
            <Link
              href="/lessons"
              className="hover:text-[var(--color-text-primary)] transition-colors underline underline-offset-2"
            >
              All Lessons
            </Link>
          </div>
        </div>

        {/* Lesson Title & Badges */}
        <div className="space-y-2 border-b border-[var(--color-border)] pb-5">
          <div className="flex flex-wrap items-center gap-2.5">
            <span className="inline-flex items-center gap-1.5 text-xs font-semibold uppercase tracking-wider text-[var(--color-brand)] bg-[var(--color-brand)]/10 px-2.5 py-0.5 rounded-full">
              <BookOpen className="h-3.5 w-3.5" />
              {skill?.name ?? "Skill"}
            </span>
            <DifficultyBadge difficulty={lesson.difficulty as Difficulty} />
            <span className="inline-flex items-center gap-1 text-xs text-[var(--color-text-tertiary)]">
              <Clock className="h-3.5 w-3.5" />
              ~{lesson.estimated_minutes} min read
            </span>
            {lesson.sections.length > 0 && (
              <span className="inline-flex items-center gap-1 text-xs text-[var(--color-text-tertiary)]">
                <Layers className="h-3.5 w-3.5" />
                {lesson.sections.length} sections
              </span>
            )}
          </div>

          <h1 className="text-2xl sm:text-3xl font-bold tracking-tight text-[var(--color-text-primary)]">
            {lesson.title}
          </h1>

          {lesson.summary && (
            <p className="text-sm sm:text-base leading-relaxed text-[var(--color-text-secondary)]">
              {lesson.summary}
            </p>
          )}
        </div>
      </div>

      {/* Quick Section Jump Navigation */}
      {lesson.sections.length > 1 && (
        <div className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface-elevated)]/50 p-3.5 text-xs">
          <div className="flex items-center gap-2 mb-2 font-medium text-[var(--color-text-secondary)]">
            <Bookmark className="h-3.5 w-3.5 text-[var(--color-brand)]" />
            <span>Table of Contents</span>
          </div>
          <div className="flex flex-wrap gap-2">
            {lesson.sections.map((section, idx) => (
              <a
                key={section.id}
                href={`#section-${idx + 1}`}
                className="px-2.5 py-1 rounded bg-[var(--color-surface)] border border-[var(--color-border)] hover:border-[var(--color-brand)] text-[var(--color-text-secondary)] hover:text-[var(--color-text-primary)] transition-all flex items-center gap-1.5"
              >
                <span className="font-mono text-[10px] text-[var(--color-brand)]">{idx + 1}</span>
                <span className="truncate max-w-[200px]">{section.title || `Section ${idx + 1}`}</span>
              </a>
            ))}
          </div>
        </div>
      )}

      {/* Lesson Sections or Single Markdown Content */}
      <div className="space-y-6">
        {lesson.sections.length > 0 ? (
          lesson.sections.map((section, idx) => {
            const sectionMeta = getSectionMeta(section.section_type);
            const Icon = sectionMeta.icon;

            return (
              <div
                key={section.id}
                id={`section-${idx + 1}`}
                className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface)] overflow-hidden shadow-sm"
              >
                {/* Section Header */}
                <div className="flex items-center justify-between px-5 py-3 border-b border-[var(--color-border)] bg-[var(--color-surface-elevated)]/60">
                  <div className="flex items-center gap-2.5">
                    <span className={`p-1.5 rounded-md ${sectionMeta.iconBg} ${sectionMeta.iconColor}`}>
                      <Icon className="h-4 w-4" />
                    </span>
                    <div>
                      <span className="text-[10px] font-mono uppercase tracking-wider text-[var(--color-text-tertiary)] font-semibold">
                        {sectionMeta.label}
                      </span>
                      {section.title && (
                        <h2 className="text-sm font-semibold text-[var(--color-text-primary)]">
                          {section.title}
                        </h2>
                      )}
                    </div>
                  </div>
                  <span className="text-xs font-mono text-[var(--color-text-tertiary)] bg-[var(--color-surface)] px-2 py-0.5 rounded border border-[var(--color-border)]">
                    § {idx + 1}
                  </span>
                </div>

                {/* Section Body */}
                {section.content_markdown && (
                  <div
                    className="p-5 text-sm leading-relaxed text-[var(--color-text-secondary)]"
                    dangerouslySetInnerHTML={{
                      __html: markdownToHtml(section.content_markdown),
                    }}
                  />
                )}
              </div>
            );
          })
        ) : (
          /* Single full content fallback */
          lesson.content_markdown && (
            <Card>
              <CardContent className="p-6">
                <div
                  className="text-sm leading-relaxed text-[var(--color-text-secondary)]"
                  dangerouslySetInnerHTML={{
                    __html: markdownToHtml(lesson.content_markdown),
                  }}
                />
              </CardContent>
            </Card>
          )
        )}
      </div>

      {/* Progress tracking client component */}
      {user && skill && (
        <LessonProgressClient
          lessonId={id}
          skillId={skill.id}
          initialStatus={currentStatus}
          skillSlug={skill.slug}
          nextLesson={nextLesson ? { id: nextLesson.id, title: nextLesson.title } : null}
        />
      )}

      {!user && (
        <Card className="border-[var(--color-brand)]/30 bg-[var(--color-brand)]/5">
          <CardContent className="p-5 text-center space-y-2">
            <p className="text-sm font-medium text-[var(--color-text-primary)]">
              Sign in to save your completion progress and build skill mastery
            </p>
            <Link
              href="/login"
              className="inline-flex items-center gap-1.5 text-xs text-[var(--color-brand)] font-semibold hover:underline"
            >
              Sign in to IT Lab OS →
            </Link>
          </CardContent>
        </Card>
      )}

      {/* Sibling Lesson Navigation (Previous & Next) */}
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-2">
        {prevLesson ? (
          <Link
            href={`/lessons/${prevLesson.id}`}
            className="flex flex-col justify-between p-4 rounded-xl border border-[var(--color-border)] bg-[var(--color-surface)] hover:border-[var(--color-brand)] hover:bg-[var(--color-surface-elevated)] transition-all group"
          >
            <span className="inline-flex items-center gap-1 text-[11px] text-[var(--color-text-tertiary)] uppercase tracking-wider font-semibold">
              <ArrowLeft className="h-3 w-3 group-hover:-translate-x-0.5 transition-transform" />
              Previous Lesson
            </span>
            <div className="mt-2 space-y-1">
              <p className="text-sm font-medium text-[var(--color-text-primary)] group-hover:text-[var(--color-brand)] transition-colors line-clamp-1">
                {prevLesson.title}
              </p>
              <div className="flex items-center gap-2">
                <DifficultyBadge difficulty={prevLesson.difficulty as Difficulty} />
                <span className="text-[11px] text-[var(--color-text-tertiary)] font-mono">
                  ~{prevLesson.estimated_minutes} min
                </span>
              </div>
            </div>
          </Link>
        ) : (
          <div className="hidden sm:block" />
        )}

        {nextLesson ? (
          <Link
            href={`/lessons/${nextLesson.id}`}
            className="flex flex-col justify-between p-4 rounded-xl border border-[var(--color-border)] bg-[var(--color-surface)] hover:border-[var(--color-brand)] hover:bg-[var(--color-surface-elevated)] transition-all text-right group"
          >
            <span className="inline-flex items-center justify-end gap-1 text-[11px] text-[var(--color-brand)] uppercase tracking-wider font-semibold">
              Next Lesson
              <ArrowRight className="h-3 w-3 group-hover:translate-x-0.5 transition-transform" />
            </span>
            <div className="mt-2 space-y-1">
              <p className="text-sm font-medium text-[var(--color-text-primary)] group-hover:text-[var(--color-brand)] transition-colors line-clamp-1">
                {nextLesson.title}
              </p>
              <div className="flex items-center justify-end gap-2">
                <span className="text-[11px] text-[var(--color-text-tertiary)] font-mono">
                  ~{nextLesson.estimated_minutes} min
                </span>
                <DifficultyBadge difficulty={nextLesson.difficulty as Difficulty} />
              </div>
            </div>
          </Link>
        ) : skill ? (
          <Link
            href={`/skills/${skill.slug}`}
            className="flex flex-col justify-between p-4 rounded-xl border border-[var(--color-border)] bg-[var(--color-surface)] hover:border-[var(--color-brand)] hover:bg-[var(--color-surface-elevated)] transition-all text-right group"
          >
            <span className="inline-flex items-center justify-end gap-1 text-[11px] text-emerald-400 uppercase tracking-wider font-semibold">
              Skill Overview
              <ArrowRight className="h-3 w-3 group-hover:translate-x-0.5 transition-transform" />
            </span>
            <p className="mt-2 text-sm font-medium text-[var(--color-text-primary)]">
              Complete {skill.name} Assessment →
            </p>
          </Link>
        ) : null}
      </div>

      {/* Next Steps: Hands-on Practice Lab & Knowledge Quiz */}
      {(practiceTask || quizCount > 0) && (
        <div className="border-t border-[var(--color-border)] pt-8 space-y-4">
          <div className="flex items-center gap-2">
            <Sparkles className="h-4 w-4 text-[var(--color-brand)]" />
            <h3 className="text-sm font-semibold uppercase tracking-wider text-[var(--color-text-primary)]">
              Put Your Knowledge into Practice
            </h3>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            {practiceTask && skill && (
              <div className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface)] p-4 flex flex-col justify-between space-y-3">
                <div className="space-y-1.5">
                  <div className="flex items-center justify-between">
                    <span className="inline-flex items-center gap-1 text-[11px] font-semibold uppercase tracking-wider text-emerald-400">
                      <Terminal className="h-3.5 w-3.5" />
                      Hands-on Lab
                    </span>
                    <span className="text-[10px] uppercase font-mono px-2 py-0.5 rounded bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 font-semibold">
                      Interactive
                    </span>
                  </div>
                  <h4 className="text-sm font-semibold text-[var(--color-text-primary)]">
                    {practiceTask.title}
                  </h4>
                  <p className="text-xs text-[var(--color-text-tertiary)] line-clamp-2">
                    {practiceTask.objective ?? "Apply these concepts directly in a terminal sandbox with automated grading."}
                  </p>
                </div>
                <Link
                  href={`/skills/${skill.slug}/practice/${practiceTask.id}`}
                  className="inline-flex items-center justify-center gap-1.5 w-full px-3 py-2 rounded-lg bg-[var(--color-surface-elevated)] border border-[var(--color-border)] text-xs font-medium text-[var(--color-text-primary)] hover:border-[var(--color-brand)] hover:text-[var(--color-brand)] transition-all"
                >
                  <Terminal className="h-3.5 w-3.5" />
                  Launch Practice Task
                </Link>
              </div>
            )}

            {quizCount > 0 && skill && (
              <div className="rounded-xl border border-[var(--color-border)] bg-[var(--color-surface)] p-4 flex flex-col justify-between space-y-3">
                <div className="space-y-1.5">
                  <div className="flex items-center justify-between">
                    <span className="inline-flex items-center gap-1 text-[11px] font-semibold uppercase tracking-wider text-sky-400">
                      <HelpCircle className="h-3.5 w-3.5" />
                      Skill Quiz
                    </span>
                    <span className="text-xs font-mono text-[var(--color-text-tertiary)]">
                      {quizCount} questions
                    </span>
                  </div>
                  <h4 className="text-sm font-semibold text-[var(--color-text-primary)]">
                    {skill.name} Knowledge Check
                  </h4>
                  <p className="text-xs text-[var(--color-text-tertiary)]">
                    Verify your conceptual mastery and earn verified skill points.
                  </p>
                </div>
                <Link
                  href={`/skills/${skill.slug}#quiz`}
                  className="inline-flex items-center justify-center gap-1.5 w-full px-3 py-2 rounded-lg bg-[var(--color-surface-elevated)] border border-[var(--color-border)] text-xs font-medium text-[var(--color-text-primary)] hover:border-[var(--color-brand)] hover:text-[var(--color-brand)] transition-all"
                >
                  <CheckCircle2 className="h-3.5 w-3.5" />
                  Take Skill Quiz
                </Link>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

/**
 * Returns icon, label and styles based on section_type.
 */
function getSectionMeta(sectionType: string) {
  switch (sectionType) {
    case "theory":
      return {
        icon: BookOpen,
        label: "Conceptual Core & Architecture",
        iconBg: "bg-sky-500/10",
        iconColor: "text-sky-400",
      };
    case "walkthrough":
      return {
        icon: Terminal,
        label: "Step-by-Step Walkthrough",
        iconBg: "bg-purple-500/10",
        iconColor: "text-purple-400",
      };
    case "example":
      return {
        icon: Code2,
        label: "Real-World Code & Configuration",
        iconBg: "bg-amber-500/10",
        iconColor: "text-amber-400",
      };
    case "exercise":
      return {
        icon: Wrench,
        label: "Hands-on Exercise & Checklist",
        iconBg: "bg-emerald-500/10",
        iconColor: "text-emerald-400",
      };
    case "troubleshooting":
      return {
        icon: AlertTriangle,
        label: "Traps & Troubleshooting",
        iconBg: "bg-rose-500/10",
        iconColor: "text-rose-400",
      };
    default:
      return {
        icon: FileCode2,
        label: "Lesson Content",
        iconBg: "bg-[var(--color-surface-elevated)]",
        iconColor: "text-[var(--color-brand)]",
      };
  }
}

function escapeHtml(s: string): string {
  return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

/**
 * Robust markdown-to-HTML converter supporting:
 * - Code blocks with uppercase language headers
 * - GitHub alert callouts (> [!NOTE], > [!TIP], > [!IMPORTANT], > [!WARNING], > [!CAUTION])
 * - Responsive styled tables
 * - Headers, lists, bold, italics, inline code, and links
 * - XSS protection via HTML escaping
 */
function markdownToHtml(md: string): string {
  // 1. Extract code blocks to avoid double escaping
  const codeBlocks: string[] = [];
  let processed = md.replace(/```([a-zA-Z0-9_-]+)?\r?\n([\s\S]*?)```/g, (_, lang, code) => {
    const idx = codeBlocks.length;
    const displayLang = (lang || "code").toUpperCase();
    codeBlocks.push(
      `<div class="my-4 rounded-lg border border-[var(--color-border)] overflow-hidden bg-[var(--color-surface-elevated)] shadow-sm">
        <div class="flex items-center justify-between px-3.5 py-1.5 bg-[var(--color-surface)] border-b border-[var(--color-border)] text-[11px] font-mono font-medium text-[var(--color-brand)] tracking-wider">
          <span>${escapeHtml(displayLang)}</span>
          <span class="text-[10px] text-[var(--color-text-tertiary)] lowercase font-sans">terminal / code</span>
        </div>
        <pre class="p-3.5 overflow-x-auto text-xs font-mono leading-relaxed text-[var(--color-text-primary)]"><code>${escapeHtml(code.trim())}</code></pre>
      </div>`
    );
    return `\n___CODE_BLOCK_${idx}___\n`;
  });

  // 2. Escape raw HTML characters to prevent XSS
  processed = escapeHtml(processed);

  // 3. GitHub alert callouts
  const calloutStyles: Record<string, { border: string; label: string; badge: string }> = {
    NOTE: {
      border: "border-sky-500/40 bg-sky-500/10 text-sky-300",
      label: "Note",
      badge: "bg-sky-500/20 text-sky-300",
    },
    TIP: {
      border: "border-emerald-500/40 bg-emerald-500/10 text-emerald-300",
      label: "Pro Tip",
      badge: "bg-emerald-500/20 text-emerald-300",
    },
    IMPORTANT: {
      border: "border-purple-500/40 bg-purple-500/10 text-purple-300",
      label: "Important",
      badge: "bg-purple-500/20 text-purple-300",
    },
    WARNING: {
      border: "border-amber-500/40 bg-amber-500/10 text-amber-300",
      label: "Warning",
      badge: "bg-amber-500/20 text-amber-300",
    },
    CAUTION: {
      border: "border-rose-500/40 bg-rose-500/10 text-rose-300",
      label: "Caution",
      badge: "bg-rose-500/20 text-rose-300",
    },
  };

  processed = processed.replace(
    /(?:^|\n)&gt;\s*\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]\s*\r?\n((?:&gt;[^\r\n]*(?:\r?\n)?)+)/gi,
    (_, rawType: string, body: string) => {
      const type = rawType.toUpperCase();
      const style = calloutStyles[type] || calloutStyles.NOTE;
      const cleanBody = body
        .split(/\r?\n/)
        .map((l) => l.replace(/^&gt;\s?/, "").trim())
        .filter(Boolean)
        .join("<br/>");
      return `\n<div class="my-4 rounded-lg border ${style.border} p-3.5 space-y-1.5"><div class="inline-flex items-center text-[11px] font-semibold uppercase tracking-wider px-2 py-0.5 rounded ${style.badge}">${style.label}</div><div class="text-xs leading-relaxed text-[var(--color-text-secondary)]">${cleanBody}</div></div>\n`;
    }
  );

  // 4. Tables
  processed = processed.replace(
    /(?:^|\n)(\|(?:[^\r\n]+)\|\r?\n(?:\|[ :-|-]+\|\r?\n)(?:\|[^\r\n]+\|\r?\n?)+)/g,
    (match) => {
      const lines = match.trim().split(/\r?\n/).map((l) => l.trim());
      if (lines.length < 2) return match;
      const headerCells = lines[0]
        .split("|")
        .slice(1, -1)
        .map((c) => c.trim());
      const bodyRows = lines.slice(2);

      const thead = `<thead class="bg-[var(--color-surface-elevated)] border-b border-[var(--color-border)] text-[var(--color-text-primary)]"><tr>${headerCells
        .map((c) => `<th class="px-3.5 py-2 text-left font-semibold text-xs">${c}</th>`)
        .join("")}</tr></thead>`;

      const tbody = `<tbody class="divide-y divide-[var(--color-border)]">${bodyRows
        .map((row) => {
          const cells = row
            .split("|")
            .slice(1, -1)
            .map((c) => c.trim());
          return `<tr class="hover:bg-[var(--color-surface-elevated)]/40 transition-colors">${cells
            .map((c) => `<td class="px-3.5 py-2 text-xs text-[var(--color-text-secondary)]">${c}</td>`)
            .join("")}</tr>`;
        })
        .join("")}</tbody>`;

      return `\n<div class="my-4 overflow-x-auto rounded-lg border border-[var(--color-border)]"><table class="w-full text-left text-xs border-collapse">${thead}${tbody}</table></div>\n`;
    }
  );

  // 5. Typography and inline markdown
  processed = processed
    .replace(/^### (.+)$/gm, '<h3 class="text-sm font-semibold text-[var(--color-text-primary)] mt-5 mb-2">$1</h3>')
    .replace(/^## (.+)$/gm, '<h2 class="text-base font-semibold text-[var(--color-text-primary)] mt-6 mb-2.5 pb-1 border-b border-[var(--color-border)]/50">$1</h2>')
    .replace(/^# (.+)$/gm, '<h1 class="text-lg font-bold text-[var(--color-text-primary)] mt-6 mb-3">$1</h1>')
    .replace(/\*\*(.+?)\*\*/g, '<strong class="font-semibold text-[var(--color-text-primary)]">$1</strong>')
    .replace(/\*([^*\n]+)\*/g, '<em class="italic text-[var(--color-text-secondary)]">$1</em>')
    .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" class="text-[var(--color-brand)] underline hover:text-[var(--color-brand-hover)]" target="_blank" rel="noopener noreferrer">$1</a>')
    .replace(/`([^`]+)`/g, '<code class="bg-[var(--color-surface-elevated)] px-1.5 py-0.5 rounded text-xs font-mono text-[var(--color-text-primary)] border border-[var(--color-border)]">$1</code>')
    .replace(/^-\s+(.+)$/gm, '<li class="ml-4 list-disc text-sm text-[var(--color-text-secondary)] my-1">$1</li>')
    .replace(/^(\d+)\.\s+(.+)$/gm, '<li class="ml-4 list-decimal text-sm text-[var(--color-text-secondary)] my-1"><span class="font-medium text-[var(--color-text-primary)]">$1.</span> $2</li>');

  // 6. Paragraphs
  const blocks = processed.split(/\r?\n\r?\n/);
  const formattedBlocks = blocks.map((block) => {
    const trimmed = block.trim();
    if (!trimmed) return "";
    if (
      trimmed.startsWith("<div") ||
      trimmed.startsWith("<table") ||
      trimmed.startsWith("<h1") ||
      trimmed.startsWith("<h2") ||
      trimmed.startsWith("<h3") ||
      trimmed.startsWith("<li") ||
      trimmed.startsWith("___CODE_BLOCK_")
    ) {
      return trimmed;
    }
    return `<p class="text-sm my-2.5 leading-relaxed text-[var(--color-text-secondary)]">${trimmed}</p>`;
  });

  let html = formattedBlocks.join("\n\n");

  // 7. Restore code blocks
  html = html.replace(/___CODE_BLOCK_(\d+)___/g, (_, idx) => codeBlocks[Number(idx)] || "");

  return html;
}