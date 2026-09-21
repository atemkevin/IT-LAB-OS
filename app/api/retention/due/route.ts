import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import {
  getDueSkillReviews,
  getSpacedRepetitionSummary,
} from "@/lib/spaced-repetition/service";

export async function GET() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  try {
    const [dueReviews, summary] = await Promise.all([
      getDueSkillReviews(user.id),
      getSpacedRepetitionSummary(user.id),
    ]);

    return NextResponse.json({
      dueReviews,
      summary,
    });
  } catch (err: unknown) {
    console.error("Error in /api/retention/due:", err);
    return NextResponse.json(
      { error: "Failed to fetch due reviews" },
      { status: 500 }
    );
  }
}
