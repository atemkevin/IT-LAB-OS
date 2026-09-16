/**
 * POST /api/troubleshooting/[slug]/command
 * Body: { attemptId: string, command: string }
 *
 * Runs a command on the live deterministic simulator and appends it to the
 * attempt's command history. Never executes real shell commands.
 */
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { createClient } from "@/lib/supabase/server";
import { rateLimit } from "@/lib/rate-limit";
import { runCommand } from "@/lib/troubleshooting/engine";

const bodySchema = z.object({
  attemptId: z.string().uuid(),
  command: z.string().min(1).max(256),
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

    // 30 commands/min — generous, since this is an interactive terminal
    const limit = rateLimit(`ts-command:${user.id}`, 30, 60_000);
    if (!limit.success) {
      return NextResponse.json(
        { error: "Rate limit exceeded. Slow down." },
        {
          status: 429,
          headers: {
            "X-RateLimit-Remaining": String(limit.remaining),
            "X-RateLimit-Reset": String(limit.resetAt),
          },
        },
      );
    }

    const body = await request.json();
    const parsed = bodySchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json({ error: "Invalid request" }, { status: 400 });
    }

    const result = await runCommand({
      userId: user.id,
      attemptId: parsed.data.attemptId,
      command: parsed.data.command,
    });

    if (!result) {
      return NextResponse.json({ error: "Attempt not found" }, { status: 404 });
    }

    return NextResponse.json(result);
  } catch (err) {
    console.error("[troubleshooting:command]", err);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}
