/**
 * GET /api/quiz/[skillSlug] - Return safe quiz questions (no is_correct)
 * POST /api/quiz/[skillSlug] - Grade quiz server-side
 */
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { createClient } from "@/lib/supabase/server";
import { getAdminClient } from "@/lib/supabase/admin";
import { getSafeQuizQuestions, gradeQuiz } from "@/lib/learning/quizzes";
import { upsertSkillProgress } from "@/lib/learning/progress";
import { calculateKnowledgeEvidence } from "@/lib/mastery/knowledge";

const submitSchema = z.object({
  answers: z.record(z.string(), z.array(z.string())),
});

async function getSkillIdBySlug(slug: string): Promise<string | null> {
  const admin = getAdminClient();
  const { data } = await admin
    .from("skills")
    .select("id")
    .eq("slug", slug)
    .maybeSingle();
  return data?.id ?? null;
}

export async function GET(
  _request: NextRequest,
  { params }: { params: Promise<{ skillSlug: string }> }
) {
  try {
    const { skillSlug } = await params;
    const skillId = await getSkillIdBySlug(skillSlug);
    if (!skillId) {
      return NextResponse.json({ error: "Skill not found" }, { status: 404 });
    }

    const questions = await getSafeQuizQuestions(skillId);
    return NextResponse.json({ questions });
  } catch (err) {
    console.error("[quiz-get]", err);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ skillSlug: string }> }
) {
  try {
    const { skillSlug } = await params;

    const supabase = await createClient();
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const skillId = await getSkillIdBySlug(skillSlug);
    if (!skillId) {
      return NextResponse.json({ error: "Skill not found" }, { status: 404 });
    }

    const body = await request.json();
    const parsed = submitSchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json({ error: "Invalid answers format" }, { status: 400 });
    }

    // gradeQuiz will record the attempt and evidence
    const result = await gradeQuiz(skillId, user.id, parsed.data.answers);

    // Recalculate authoritative knowledge score using all evidence
    const knowledgeScore = await calculateKnowledgeEvidence(user.id, skillId);
    await upsertSkillProgress(user.id, skillId, {
      knowledge_score: knowledgeScore,
    });

    return NextResponse.json(result);
  } catch (err) {
    console.error("[quiz-post]", err);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}