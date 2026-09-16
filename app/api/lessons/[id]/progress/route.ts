/**
 * POST /api/lessons/[id]/progress
 * Start or complete a lesson. Authenticated endpoint.
 */
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { createClient } from "@/lib/supabase/server";
import { getAdminClient } from "@/lib/supabase/admin";
import { startLesson, completeLesson } from "@/lib/learning/lessons";
import { upsertSkillProgress } from "@/lib/learning/progress";
import { calculateKnowledgeEvidence } from "@/lib/mastery/knowledge";

const bodySchema = z.object({
  action: z.enum(["start", "complete"]),
  // We keep skillId in schema for backward compatibility, but we will override it with the authoritative one
  skillId: z.string().uuid().optional(), 
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

    const { action } = parsed.data;

    // Load lesson to get authoritative skill_id
    const admin = getAdminClient();
    const { data: lesson } = await admin
      .from("lessons")
      .select("skill_id")
      .eq("id", lessonId)
      .maybeSingle();

    if (!lesson) {
      return NextResponse.json({ error: "Lesson not found" }, { status: 404 });
    }

    const authoritativeSkillId = lesson.skill_id;

    if (action === "start") {
      await startLesson(user.id, lessonId);
      return NextResponse.json({ success: true, status: "in_progress" });
    }

    const wasNew = await completeLesson(user.id, lessonId, authoritativeSkillId);

    if (wasNew) {
      // Recalculate authoritative knowledge score for this skill
      const knowledgeScore = await calculateKnowledgeEvidence(user.id, authoritativeSkillId);
      await upsertSkillProgress(user.id, authoritativeSkillId, { knowledge_score: knowledgeScore });
    }

    return NextResponse.json({ success: true, status: "completed", wasNew });
  } catch (err) {
    console.error("[lesson-progress]", err);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}