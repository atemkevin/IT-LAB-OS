/**
 * POST /api/integrations/events
 *
 * Generic event ingestion endpoint for n8n/Hermes (or any bridge) to log
 * learner activity that happened outside the app — e.g. a Telegram-bot
 * session, a flashcard review, a paper handwritten note.
 *
 * Auth: INTEGRATION_API_KEY via X-Integration-Key header.
 *
 * Body: { userId: UUID, activityType: string, details?: object }
 *
 * Writes to user_activity_logs (same table the in-app activity module uses).
 */
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { getAdminClient } from "@/lib/supabase/admin";
import { todayString } from "@/lib/utils";
import { verifyIntegrationKey } from "@/lib/api/integration-auth";
import type { Json } from "@/lib/database.types";

const bodySchema = z.object({
  userId: z.string().uuid(),
  activityType: z.string().min(1).max(50),
  details: z.record(z.string(), z.unknown()).optional().default({}),
  activityDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
});

export async function POST(request: NextRequest) {
  const authError = verifyIntegrationKey(request.headers.get("x-integration-key"));
  if (authError) return authError;

  let body: unknown;
  try {
    body = await request.json();
  } catch {
    return NextResponse.json(
      { error: { code: "VALIDATION_ERROR", message: "Invalid JSON body" } },
      { status: 400 },
    );
  }

  const parsed = bodySchema.safeParse(body);
  if (!parsed.success) {
    return NextResponse.json(
      { error: { code: "VALIDATION_ERROR", message: "userId (UUID), activityType (string), optional details required" } },
      { status: 400 },
    );
  }

  const admin = getAdminClient();
  const { data, error } = await admin
    .from("user_activity_logs")
    .insert({
      user_id: parsed.data.userId,
      activity_type: `bridge:${parsed.data.activityType}`,
      details: parsed.data.details as Json,
      activity_date: parsed.data.activityDate ?? todayString(),
    })
    .select("id, activity_date")
    .single();

  if (error) {
    console.error("[integrations:events]", error);
    return NextResponse.json(
      { error: { code: "INTERNAL_ERROR", message: "Failed to log event" } },
      { status: 500 },
    );
  }

  return NextResponse.json({ logged: data }, { status: 201 });
}
