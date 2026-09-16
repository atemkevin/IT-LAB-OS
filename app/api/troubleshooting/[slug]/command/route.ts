/**
 * POST /api/troubleshooting/[slug]/start
 * Begin a new troubleshooting attempt for a scenario slug.
 * Returns the attemptId and an empty live state.
 */
import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { startAttempt } from "@/lib/troubleshooting/engine";

export async function POST(
  _request: NextRequest,
  { params }: { params: Promise<{ slug: string }> },
) {
  try {
    const { slug } = await params;
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const started = await startAttempt(user.id, slug);
    if (!started) {
      return NextResponse.json({ error: "Scenario not found" }, { status: 404 });
    }

    return NextResponse.json({
      attemptId: started.attemptId,
      state: started.state,
      allowedCommands: started.scenario.allowedCommands,
      scenario: {
        slug: started.scenario.slug,
        title: started.scenario.title,
        description: started.scenario.description,
        difficulty: started.scenario.difficulty,
      },
    });
  } catch (err) {
    console.error("[troubleshooting:start]", err);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}
