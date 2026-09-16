/**
 * POST /api/troubleshooting/[slug]/hint
 * Body: { attemptId: string }
 *
 * Returns the next hint on the 5-step ladder and increments hintsUsed.
 */
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { createClient } from "@/lib/supabase/server";
import { rateLimit } from "@/lib/rate-limit";
import { requestHint } from "@/lib/troubleshooting/engine";

const bodySchema = z.object({
  attemptId: z.string().uuid(),
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

    const limit = rateLimit(`ts-hint:${user.id}`, 20, 60_000);
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

    const hint = await requestHint({
      userId: user.id,
      attemptId: parsed.data.attemptId,
    });

    if (!hint) {
      return NextResponse.json({ error: "Attempt not found" }, { status: 404 });
    }

    return NextResponse.json({ hint });
  } catch (err) {
    console.error("[troubleshooting:hint]", err);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}
