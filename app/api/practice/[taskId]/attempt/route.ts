/**
 * POST /api/practice/[taskId]/attempt
 * Submit a practice attempt. Authenticated endpoint.
 */
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { createClient } from "@/lib/supabase/server";
import { getAdminClient } from "@/lib/supabase/admin";
import { submitPracticeAttempt } from "@/lib/learning/practice";
import { upsertSkillProgress } from "@/lib/learning/progress";

const bodySchema = z.object({
  skillId: z.string().uuid(),
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

    // Verify task exists
    const admin = getAdminClient();
    const { data: task } = await admin
      .from("practice_tasks")
      .select("id, skill_id")
      .eq("id", taskId)
      .maybeSingle();

    if (!task) {
      return NextResponse.json({ error: "Practice task not found" }, { status: 404 });
    }

    const body = await request.json();
    const parsed = bodySchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json({ error: "Invalid request" }, { status: 400 });
    }

    const result = await submitPracticeAttempt(
      user.id,
      taskId,
      parsed.data.skillId,
      { notes: parsed.data.notes, completed: parsed.data.completed }
    );

    // Update practice score if passed
    if (result.passed) {
      await upsertSkillProgress(user.id, parsed.data.skillId, {
        practice_score: result.score,
      });
    }

    return NextResponse.json(result);
  } catch (err) {
    console.error("[practice-attempt]", err);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}