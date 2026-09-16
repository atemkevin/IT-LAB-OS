/**
 * /api/projects/[slug]/progress
 * POST — upsert user_project_progress (start or update project status)
 */
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { createClient } from "@/lib/supabase/server";
import { getAdminClient } from "@/lib/supabase/admin";
import { rateLimit } from "@/lib/rate-limit";
import type { TablesInsert } from "@/lib/database.types";

const progressSchema = z.object({
  status: z.enum(["not_started", "in_progress", "submitted", "completed"]).optional(),
  progress: z.number().min(0).max(100).optional(),
  submission: z.any().optional(),
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

    const limit = rateLimit(`project-progress:${user.id}`, 10, 60_000);
    if (!limit.success) {
      return NextResponse.json(
        { error: "Rate limit exceeded" },
        { status: 429, headers: { "X-RateLimit-Remaining": String(limit.remaining) } },
      );
    }

    const body = await request.json();
    const parsed = progressSchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json({ error: "Invalid request" }, { status: 400 });
    }

    // Look up project by slug (authoritative)
    const admin = getAdminClient();
    const { data: project } = await admin
      .from("projects")
      .select("id")
      .eq("slug", slug)
      .eq("is_published", true)
      .maybeSingle();

    if (!project) {
      return NextResponse.json({ error: "Project not found" }, { status: 404 });
    }

    const updateData: TablesInsert<"user_project_progress"> = {
      user_id: user.id,
      project_id: project.id,
      updated_at: new Date().toISOString(),
    };
    if (parsed.data.status !== undefined) updateData.status = parsed.data.status;
    if (parsed.data.progress !== undefined) updateData.progress = parsed.data.progress;
    if (parsed.data.submission !== undefined) updateData.submission = parsed.data.submission;

    const { data: progress, error } = await supabase
      .from("user_project_progress")
      .upsert(updateData, { onConflict: "user_id,project_id" })
      .select("*")
      .single();

    if (error) {
      console.error("[project-progress]", error);
      return NextResponse.json({ error: "Failed to update progress" }, { status: 500 });
    }

    return NextResponse.json({ progress });
  } catch (err) {
    console.error("[project-progress]", err);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}
