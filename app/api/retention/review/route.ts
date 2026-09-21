import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { recordSkillReview } from "@/lib/spaced-repetition/service";

export async function POST(request: Request) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  try {
    const body = await request.json();
    const { skillId, grade, isPercentage } = body;

    if (!skillId || typeof grade !== "number") {
      return NextResponse.json(
        { error: "skillId and numeric grade are required" },
        { status: 400 }
      );
    }

    const result = await recordSkillReview(user.id, skillId, grade, !!isPercentage);

    return NextResponse.json({
      success: true,
      result: {
        repetitionCount: result.repetitionCount,
        intervalDays: result.intervalDays,
        easinessFactor: result.easinessFactor,
        retentionScore: result.retentionScore,
        nextReviewDue: result.nextReviewDue.toISOString(),
      },
    });
  } catch (err: unknown) {
    console.error("Error in /api/retention/review:", err);
    return NextResponse.json(
      { error: "Failed to record spaced repetition review" },
      { status: 500 }
    );
  }
}
