/**
 * POST /api/troubleshooting/[slug]/finish
 * Body: { attemptId: string, diagnosis?: string, attemptedFix?: string }
 *
 * Closes the attempt, scores it deterministically, and writes
 * mastery_evidence + user_skill_progress.troubleshooting_score.
 */
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { createClient } from "@/lib/supabase/server";
import { rateLimit } from "@/lib/rate-limit";
import { finishAttempt } from "@/lib/troubleshooting/engine";

const bodySchema = z.object({
  attemptId: z.string().uuid(),
  diagnosis: z.string().max(2000).optional(),
  attemptedFix: z.string().max(2000).optional(),
  clientVerificationResult: z.object({
    passed: z.boolean(),
    rootCauseIdentified: z.boolean(),
  }).optional(),
});

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ slug: string }> },
) {
  try {
    await params;
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const limit = rateLimit(`ts-finish:${user.id}`, 5, 60_000);
    if (!limit.success) {
      return NextResponse.json(
        { error: "Rate limit exceeded." },
        { status: 429 },
      );
    }

    const body = await request.json();
    const parsed = bodySchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json({ error: "Invalid request" }, { status: 400 });
    }

    const result = await finishAttempt({
      userId: user.id,
      attemptId: parsed.data.attemptId,
      diagnosis: parsed.data.diagnosis,
      attemptedFix: parsed.data.attemptedFix,
      clientVerificationResult: parsed.data.clientVerificationResult,
    });

    if (!result) {
      return NextResponse.json({ error: "Attempt not found" }, { status: 404 });
    }

    return NextResponse.json(result);
  } catch (err) {
    console.error("[troubleshooting:finish]", err);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}
