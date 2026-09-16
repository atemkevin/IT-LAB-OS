/**
 * lib/learning/lessons.ts
 *
 * Lesson data fetching and progress management.
 * Server-only.
 */
import { createClient } from "@/lib/supabase/server";
import { getAdminClient } from "@/lib/supabase/admin";
import type { LessonWithSections } from "./types";

/**
 * Get a single lesson with all sections ordered by sort_order.
 */
export async function getLessonById(lessonId: string): Promise<LessonWithSections | null> {
  const supabase = await createClient();

  const { data: lesson, error } = await supabase
    .from("lessons")
    .select("*")
    .eq("id", lessonId)
    .eq("is_published", true)
    .maybeSingle();

  if (error || !lesson) return null;

  const { data: sections } = await supabase
    .from("lesson_sections")
    .select("*")
    .eq("lesson_id", lessonId)
    .order("sort_order");

  return { ...lesson, sections: sections ?? [] };
}

/**
 * Start a lesson — create user_lesson_progress if not exists.
 * Idempotent: does nothing if already started or completed.
 */
export async function startLesson(userId: string, lessonId: string): Promise<void> {
  const admin = getAdminClient();

  const { data: existing } = await admin
    .from("user_lesson_progress")
    .select("status")
    .eq("user_id", userId)
    .eq("lesson_id", lessonId)
    .maybeSingle();

  if (existing) return; // Already tracked

  await admin.from("user_lesson_progress").insert({
    user_id: userId,
    lesson_id: lessonId,
    status: "in_progress",
    progress: 0,
    started_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  });
}

/**
 * Complete a lesson — update progress to 100%, status to completed,
 * then create mastery_evidence for the lesson.
 *
 * @returns whether this was a new completion (false if already completed before)
 */
export async function completeLesson(
  userId: string,
  lessonId: string,
  skillId: string
): Promise<boolean> {
  const admin = getAdminClient();

  // Check if already completed
  const { data: existing } = await admin
    .from("user_lesson_progress")
    .select("status")
    .eq("user_id", userId)
    .eq("lesson_id", lessonId)
    .maybeSingle();

  if (existing?.status === "completed") return false;

  const now = new Date().toISOString();

  await admin.from("user_lesson_progress").upsert(
    {
      user_id: userId,
      lesson_id: lessonId,
      status: "completed",
      progress: 100,
      started_at: existing ? undefined : now,
      completed_at: now,
      updated_at: now,
    },
    { onConflict: "user_id,lesson_id" }
  );

  // Create mastery evidence for lesson completion
  await admin.from("mastery_evidence").insert({
    user_id: userId,
    skill_id: skillId,
    evidence_type: "lesson",
    source_id: lessonId,
    score: 100,
    metadata: { lesson_id: lessonId, completed_at: now },
  });

  return true;
}
