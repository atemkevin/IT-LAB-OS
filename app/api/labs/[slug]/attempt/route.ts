/**
 * /api/labs/[slug]/attempt
 * POST — create or update a troubleshooting attempt
 */
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { createClient } from "@/lib/supabase/server";
import { getAdminClient } from "@/lib/supabase/admin";
import { rateLimit } from "@/lib/rate-limit";

const attemptSchema = z.object({
  commands_run: z.array(z.string()).optional().default([]),
  hints_used: z.number().int().min(0).max(10).optional().default(0),
  diagnosis: z.string().max(500).optional().nullable(),
  attempted_fix: z.string().max(500).optional().nullable(),
  root_cause_identified: z.boolean().optional().default(false),
  resolved: z.boolean().optional().default(false),
  score: z.number().min(0).max(100).optional().nullable(),
  completed: z.boolean().optional().default(false),
});

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ slug: string }> },
) {
  try {
    const { slug } = await params;
    const supabase = await createClient();
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const limit = rateLimit(`lab-attempt:${user.id}`, 10, 60_000);
    if (!limit.success) {
      return NextResponse.json(
        { error: "Rate limit exceeded" },
        { status: 429, headers: { "X-RateLimit-Remaining": String(limit.remaining) } },
      );
    }

    const body = await request.json();
    const parsed = attemptSchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json({ error: "Invalid request" }, { status: 400 });
    }

    // Look up scenario by slug (authoritative)
    const admin = getAdminClient();
    const { data: scenario } = await admin
      .from("troubleshooting_scenarios")
      .select("id")
      .eq("slug", slug)
      .eq("is_published", true)
      .maybeSingle();

    if (!scenario) {
      return NextResponse.json({ error: "Scenario not found" }, { status: 404 });
    }

    // Check for existing active attempt
    const { data: existing } = await supabase
      .from("troubleshooting_attempts")
      .select("*")
      .eq("user_id", user.id)
      .eq("scenario_id", scenario.id)
      .is("completed_at", null)
      .order("started_at", { ascending: false })
      .limit(1)
      .maybeSingle();

    const now = new Date().toISOString();
    const isCompleted = parsed.data.completed || parsed.data.resolved;

    if (existing) {
      // Update existing attempt
      const { data: attempt, error } = await supabase
        .from("troubleshooting_attempts")
        .update({
          commands_run: parsed.data.commands_run,
          hints_used: parsed.data.hints_used,
          diagnosis: parsed.data.diagnosis,
          attempted_fix: parsed.data.attempted_fix,
          root_cause_identified: parsed.data.root_cause_identified,
          resolved: parsed.data.resolved,
          score: parsed.data.score,
          completed_at: isCompleted ? now : null,
        })
        .eq("id", existing.id)
        .select("*")
        .single();

      if (error) {
        console.error("[lab-attempt-update]", error);
        return NextResponse.json({ error: "Failed to update attempt" }, { status: 500 });
      }

      return NextResponse.json({ attempt });
    }

    // Create new attempt
    const { data: attempt, error } = await supabase
      .from("troubleshooting_attempts")
      .insert({
        user_id: user.id,
        scenario_id: scenario.id,
        commands_run: parsed.data.commands_run,
        hints_used: parsed.data.hints_used,
        diagnosis: parsed.data.diagnosis,
        attempted_fix: parsed.data.attempted_fix,
        root_cause_identified: parsed.data.root_cause_identified,
        resolved: parsed.data.resolved,
        score: parsed.data.score,
        started_at: now,
        completed_at: isCompleted ? now : null,
      })
      .select("*")
      .single();

    if (error) {
      console.error("[lab-attempt-create]", error);
      return NextResponse.json({ error: "Failed to create attempt" }, { status: 500 });
    }

    return NextResponse.json({ attempt });
  } catch (err) {
    console.error("[lab-attempt]", err);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}
