/**
 * GET /api/integrations/progress
 *
 * Returns the learner's mastery snapshot for n8n/Hermes/Telegram bridges.
 *
 * Auth: INTEGRATION_API_KEY via X-Integration-Key header.
 * Requires ?userId= query param.
 */
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { getAdminClient } from "@/lib/supabase/admin";
import { verifyIntegrationKey } from "@/lib/api/integration-auth";

const querySchema = z.object({
  userId: z.string().uuid(),
});

export async function GET(request: NextRequest) {
  const authError = verifyIntegrationKey(request.headers.get("x-integration-key"));
  if (authError) return authError;

  const parsed = querySchema.safeParse({
    userId: new URL(request.url).searchParams.get("userId"),
  });
  if (!parsed.success) {
    return NextResponse.json(
      { error: { code: "VALIDATION_ERROR", message: "userId query param is required and must be a UUID" } },
      { status: 400 },
    );
  }

  const admin = getAdminClient();

  const [progressRes, skillsRes] = await Promise.all([
    admin
      .from("user_skill_progress")
      .select("skill_id, mastery_score, mastery_state, attempt_count, last_activity_at")
      .eq("user_id", parsed.data.userId),
    admin.from("skills").select("id, name, slug").eq("is_published", true),
  ]);

  const skillsMap = new Map((skillsRes.data ?? []).map((s: { id: string; name: string; slug: string }) => [s.id, s]));
  const rows = progressRes.data ?? [];

  const overallMastery =
    rows.length > 0
      ? Math.round(rows.reduce((sum, r) => sum + (Number(r.mastery_score) || 0), 0) / rows.length)
      : 0;

  return NextResponse.json({
    overallMastery,
    skillCount: rows.length,
    skills: rows.map((r) => ({
      skill: skillsMap.get(r.skill_id) ?? null,
      masteryScore: Number(r.mastery_score) || 0,
      masteryState: r.mastery_state,
      attemptCount: r.attempt_count,
      lastActivityAt: r.last_activity_at,
    })),
  });
}
