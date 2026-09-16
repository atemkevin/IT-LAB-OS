/**
 * lib/learning/practice.ts
 *
 * Practice task submission and attempt persistence.
 * Server-only.
 */
import { getAdminClient } from "@/lib/supabase/admin";
import type { PracticeResult, PracticeSubmission } from "./types";

/**
 * Submit a practice attempt.
 * Saves practice_attempt and mastery_evidence (if passed).
 */
export async function submitPracticeAttempt(
  userId: string,
  taskId: string,
  skillId: string,
  submission: PracticeSubmission
): Promise<PracticeResult> {
  const admin = getAdminClient();

  // Self-assessed: completed = passed at 100, not completed = 50
  const score = submission.completed ? 100 : 50;
  const passed = submission.completed;
  const feedback = passed
    ? "Well done! You confirmed completing the practice task."
    : "Keep practising. Come back when you have completed the steps.";

  const { data: attempt, error } = await admin
    .from("practice_attempts")
    .insert({
      user_id: userId,
      practice_task_id: taskId,
      submission: submission as unknown as import("@/lib/database.types").Json,
      feedback,
      score,
      passed,
    })
    .select("id")
    .single();

  if (error || !attempt) {
    throw new Error("Failed to save practice attempt");
  }

  // Create mastery evidence if passed
  if (passed) {
    await admin.from("mastery_evidence").insert({
      user_id: userId,
      skill_id: skillId,
      evidence_type: "practice",
      source_id: attempt.id,
      score,
      metadata: { task_id: taskId, submission_notes: submission.notes ?? null },
    });
  }

  return { attemptId: attempt.id, passed, score, feedback };
}
