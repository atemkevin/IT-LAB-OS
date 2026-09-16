/**
 * POST /api/lessons/[id]/progress
 * Start or complete a lesson. Authenticated endpoint.
 */
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { createClient } from "@/lib/supabase/server";
import { startLesson, completeLesson } from "@/lib/learning/lessons";
import { upsertSkillProgress } from "@/lib/learning/progress";

const bodySchema = z.object({
  action: z.enum(["start", "complete"]),
  skillId: z.string().uuid(),
});

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id: lessonId } = await params;
    const supabase = await createClient();
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const body = await request.json();
    const parsed = bodySchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json({ error: "Invalid request" }, { status: 400 });
    }

    const { action, skillId } = parsed.data;

    if (action === "start") {
      await startLesson(user.id, lessonId);
      return NextResponse.json({ success: true, status: "in_progress" });
    }

    const wasNew = await completeLesson(user.id, lessonId, skillId);

    if (wasNew) {
      const { count: totalLessons } = await supabase
        .from("lessons")
        .select("*", { count: "exact", head: true })
        .eq("skill_id", skillId)
        .eq("is_published", true);

      const { count: completedLessons } = await supabase
        .from("user_lesson_progress")
        .select("*", { count: "exact", head: true })
        .eq("user_id", user.id)
        .eq("status", "completed");

      const knowledgeScore = Math.min(
        Math.round(((completedLessons ?? 1) / (totalLessons ?? 1)) * 100),
        100
      );
      await upsertSkillProgress(user.id, skillId, { knowledge_score: knowledgeScore });
    }

    return NextResponse.json({ success: true, status: "completed", wasNew });
  } catch (err) {
    console.error("[lesson-progress]", err);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}