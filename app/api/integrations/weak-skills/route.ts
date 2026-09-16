/**
 * GET /api/integrations/weak-skills
 *
 * Returns the user's three lowest-mastery skills (excluding `not_started`).
 * Used by external integrations to recommend next study actions.
 *
 * Auth: INTEGRATION_API_KEY via X-Integration-Key header.
 * Requires ?userId= query param. Optional ?limit= (default 3, max 10).
 */
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { getAdminClient } from "@/lib/supabase/admin";
import { verifyIntegrationKey } from "@/lib/api/integration-auth";

const querySchema = z.object({
  userId: z.string().uuid(),
  limit: z.coerce.number().int().min(1).max(10).optional().default(3),
});

export async function GET(request: NextRequest) {
  const authError = verifyIntegrationKey(request.headers.get("x-integration-key"));
  if (authError) return authError;

  const params = Object.fromEntries(new URL(request.url).searchParams);
  const parsed = querySchema.safeParse({
    userId: params.userId,
    limit: params.limit ? Number(params.limit) : undefined,
  });
  if (!parsed.success) {
    return NextResponse.json(
      { error: { code: "VALIDATION_ERROR", message: "userId (UUID) required; limit must be 1-10" } },
      { status: 400 },
    );
  }

  const admin = getAdminClient();

  const [progressRes, skillsRes] = await Promise.all([
    admin
      .from("user_skill_progress")
      .select("skill_id, mastery_score, mastery_state")
      .eq("user_id", parsed.data.userId)
      .neq("mastery_state", "not_started")
      .order("mastery_score", { ascending: true })
      .limit(parsed.data.limit),
    admin.from("skills").select("id, name, slug").eq("is_published", true),
  ]);

  const skillsMap = new Map((skillsRes.data ?? []).map((s: { id: string; name: string; slug: string }) => [s.id, s]));
  const rows = progressRes.data ?? [];

  return NextResponse.json({
    weakSkills: rows.map((r) => ({
      skill: skillsMap.get(r.skill_id) ?? null,
      masteryScore: Number(r.mastery_score) || 0,
      masteryState: r.mastery_state,
    })),
  });
}
