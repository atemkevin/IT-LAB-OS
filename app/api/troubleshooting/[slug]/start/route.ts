import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { rateLimit } from "@/lib/rate-limit";
import { startAttempt } from "@/lib/troubleshooting/engine";

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ slug: string }> },
) {
  try {
    const p = await params;
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const limit = rateLimit(`ts-start:${user.id}`, 10, 60_000);
    if (!limit.success) {
      return NextResponse.json({ error: "Rate limit exceeded." }, { status: 429 });
    }

    const result = await startAttempt(user.id, p.slug);
    if (!result) {
      return NextResponse.json({ error: "Scenario not found" }, { status: 404 });
    }

    return NextResponse.json(result);
  } catch (err) {
    console.error("[troubleshooting:start]", err);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}
