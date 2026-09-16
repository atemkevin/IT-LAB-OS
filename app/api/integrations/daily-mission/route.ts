/**
 * GET /api/integrations/daily-mission
 *
 * Returns today's mission summary for an arbitrary authenticated user.
 * Designed for n8n/Hermes/Telegram bridge flows.
 *
 * Auth: INTEGRATION_API_KEY via X-Integration-Key header.
 * Requires ?userId= query param.
 */
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { getAdminClient } from "@/lib/supabase/admin";
import { todayString } from "@/lib/utils";
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
  const { data: mission } = await admin
    .from("daily_missions")
    .select("id, title, objective, status, duration_minutes, mission_date, tasks, success_criteria")
    .eq("user_id", parsed.data.userId)
    .eq("mission_date", todayString())
    .maybeSingle();

  if (!mission) {
    return NextResponse.json({ mission: null });
  }

  return NextResponse.json({
    mission: {
      id: mission.id,
      title: mission.title,
      objective: mission.objective ?? "",
      status: mission.status,
      durationMinutes: mission.duration_minutes,
      tasks: Array.isArray(mission.tasks) ? mission.tasks : [],
      successCriteria: Array.isArray(mission.success_criteria)
        ? mission.success_criteria
        : [],
    },
  });
}
