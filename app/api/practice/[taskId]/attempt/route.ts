/**
 * POST /api/practice/[taskId]/attempt
 * Submit a practice attempt. Authenticated endpoint.
 */
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { createClient } from "@/lib/supabase/server";
import { getAdminClient } from "@/lib/supabase/admin";
import { evaluatePracticeEvidence } from "@/lib/learning/practice";
import { upsertSkillProgress } from "@/lib/learning/progress";
import { rateLimit } from "@/lib/rate-limit";

const bodySchema = z.object({
  // skillId is deprecated from client, but we keep it optional so we don't break the payload contract
  skillId: z.string().uuid().optional(),
  responses: z.record(z.string(), z.string()).optional().default({}),
  notes: z.string().optional(),
  completed: z.boolean(),
});

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ taskId: string }> }
) {
  try {
    const { taskId } = await params;

    const supabase = await createClient();
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    // Rate limit: 10 practice submissions per minute per user
    const limit = rateLimit(`practice:${user.id}`, 10, 60_000);
    if (!limit.success) {
      return NextResponse.json(
        { error: "Rate limit exceeded. Please wait before submitting another practice attempt." },
        { status: 429, headers: { "X-RateLimit-Remaining": String(limit.remaining), "X-RateLimit-Reset": String(limit.resetAt) } }
      );
    }

    // Verify task exists and load its true skill_id
    const admin = getAdminClient();
    const { data: task } = await admin
      .from("practice_tasks")
      .select("id, skill_id")
      .eq("id", taskId)
      .maybeSingle();

    if (!task) {
      return NextResponse.json({ error: "Practice task not found" }, { status: 404 });
    }

    const authoritativeSkillId = task.skill_id;

    const body = await request.json();
    const parsed = bodySchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json({ error: "Invalid request" }, { status: 400 });
    }

    // Do not reject just because completed=false; evaluate what they sent
    if (!parsed.data.responses && !parsed.data.notes && parsed.data.completed) {
       // Minimal check to avoid completely empty submissions masquerading as complete
       return NextResponse.json({ passed: false, score: 0, feedback: "You must provide evidence to complete the task requirements." }, { status: 400 });
    }

    const result = await evaluatePracticeEvidence(
      user.id,
      taskId,
      authoritativeSkillId,
      { 
        responses: parsed.data.responses,
        notes: parsed.data.notes, 
        completed: parsed.data.completed 
      }
    );

    // Update practice score (keep the highest score they've achieved)
    // Wait, progress.ts upsertSkillProgress does NOT calculate the best practice score natively right now.
    // It accepts the score passed in. We should only update if the new score is better than the existing.
    // Let's get the user's current progress first.
    const { data: progress } = await admin
      .from("user_skill_progress")
      .select("practice_score")
      .eq("user_id", user.id)
      .eq("skill_id", authoritativeSkillId)
      .maybeSingle();
      
    const currentScore = Number(progress?.practice_score ?? 0);
    const newScore = Math.max(currentScore, result.score);

    if (newScore > currentScore) {
      await upsertSkillProgress(user.id, authoritativeSkillId, {
        practice_score: newScore,
      });
    }

    if (result.passed) {
      const { logActivity } = await import("@/lib/learning/activity");
      await logActivity(user.id, "practice_completed", { taskId, skillId: authoritativeSkillId, score: result.score });
    }

    return NextResponse.json(result);
  } catch (err) {
    console.error("[practice-attempt]", err);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}