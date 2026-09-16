/**
 * lib/learning/practice.ts
 *
 * Practice task submission and evidence evaluation.
 * Server-only.
 */
import { getAdminClient } from "@/lib/supabase/admin";
import type { PracticeResult, PracticeSubmission } from "./types";

/**
 * Evaluate structured practice evidence.
 * 
 * Determines score deterministically based on provided non-empty responses
 * corresponding to the task's evidence_keys.
 */
export async function evaluatePracticeEvidence(
  userId: string,
  taskId: string,
  skillId: string,
  submission: PracticeSubmission
): Promise<PracticeResult> {
  const admin = getAdminClient();

  // 1. Load authoritative practice task to get evidence keys
  const { data: task, error: taskError } = await admin
    .from("practice_tasks")
    .select("evidence_keys")
    .eq("id", taskId)
    .single();

  if (taskError || !task) {
    throw new Error("Practice task not found");
  }

  const evidenceKeys = task.evidence_keys as string[] ?? [];
  const responses = submission.responses ?? {};
  
  // 2. Validate and score
  let satisfiedCount = 0;
  const requirementResults: Record<string, boolean> = {};

  if (evidenceKeys.length === 0) {
    // Fallback for tasks with no evidence keys: 
    // They pass automatically if submitted (for legacy/simple tasks)
    satisfiedCount = 1;
    requirementResults["default"] = true;
  } else {
    for (const key of evidenceKeys) {
      const response = responses[key];
      // A requirement is considered satisfied if a non-empty string is provided.
      // This is the MVP evaluation mechanism.
      const isSatisfied = typeof response === "string" && response.trim().length > 0;
      requirementResults[key] = isSatisfied;
      if (isSatisfied) {
        satisfiedCount++;
      }
    }
  }

  const totalRequirements = Math.max(evidenceKeys.length, 1);
  const score = Math.round((satisfiedCount / totalRequirements) * 100);
  const passed = score >= 100; // Require all for 'passed' in this MVP? Let's say yes.

  let feedback = "Keep practising. Ensure all requirements have evidence provided.";
  if (passed) {
    feedback = "Well done! All evidence requirements were satisfied.";
  } else if (score > 0) {
    feedback = "Good progress, but some requirements are still missing evidence.";
  } else if (evidenceKeys.length > 0 && satisfiedCount === 0) {
    feedback = "No valid evidence was provided.";
  }

  // 3. Record the attempt
  const { data: attempt, error: attemptError } = await admin
    .from("practice_attempts")
    .insert({
      user_id: userId,
      practice_task_id: taskId,
      skill_id: skillId,
      submission: submission as unknown as import("@/lib/database.types").Json,
      feedback,
      score,
      passed,
    })
    .select("id")
    .single();

  if (attemptError || !attempt) {
    throw new Error("Failed to save practice attempt");
  }

  // 4. Create mastery evidence
  // We record mastery evidence regardless of pass/fail if score > 0, 
  // but let's stick to recording it if passed for now, or just record the attempt score.
  // Actually, practice score should just take the best score from attempts in knowledge recalculation, 
  // but currently we explicitly insert mastery_evidence if passed. Let's keep that.
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

  return { 
    attemptId: attempt.id, 
    passed, 
    score, 
    feedback,
    requirementResults
  };
}