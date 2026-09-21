/**
 * POST /api/troubleshooting/[slug]/command
 * Run a command against the troubleshooting simulator state machine.
 * Body: { attemptId: string, command: string }
 */
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { createClient } from "@/lib/supabase/server";
import { rateLimit } from "@/lib/rate-limit";
import { runCommand } from "@/lib/troubleshooting/engine";

const bodySchema = z.object({
  attemptId: z.string().uuid(),
  command: z.string().min(1).max(500),
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

    const limit = rateLimit(`ts-cmd:${user.id}`, 30, 60_000);
    if (!limit.success) {
      return NextResponse.json(
        { error: "Rate limit exceeded. Please slow down." },
        { status: 429 },
      );
    }

    const body = await request.json();
    const parsed = bodySchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json({ error: "Invalid request body" }, { status: 400 });
    }

    const response = await runCommand({
      userId: user.id,
      attemptId: parsed.data.attemptId,
      command: parsed.data.command,
    });

    if (!response) {
      return NextResponse.json({ error: "Attempt not found" }, { status: 404 });
    }

    return NextResponse.json({
      attemptId: response.attemptId,
      result: response.result,
    });
  } catch (err) {
    console.error("[troubleshooting:command]", err);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}
