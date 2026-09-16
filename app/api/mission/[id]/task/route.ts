/**
 * /api/mission/[id]/task
 * POST — toggle a mission task's completion status
 */
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { createClient } from "@/lib/supabase/server";
import { getAdminClient } from "@/lib/supabase/admin";
import { rateLimit } from "@/lib/rate-limit";

const taskSchema = z.object({
  taskKey: z.string().min(1).max(100),
  completed: z.boolean(),
  notes: z.string().max(2000).optional().nullable(),
});

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> },
) {
  try {
    const { id: missionId } = await params;
    const supabase = await createClient();
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const limit = rateLimit(`mission-task:${user.id}`, 10, 60_000);
    if (!limit.success) {
      return NextResponse.json(
        { error: "Rate limit exceeded" },
        { status: 429, headers: { "X-RateLimit-Remaining": String(limit.remaining) } },
      );
    }

    const body = await request.json();
    const parsed = taskSchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json({ error: "Invalid request" }, { status: 400 });
    }

    const { taskKey, completed, notes } = parsed.data;

    // Verify mission belongs to user
    const { data: mission } = await supabase
      .from("daily_missions")
      .select("id, user_id, tasks")
      .eq("id", missionId)
      .eq("user_id", user.id)
      .maybeSingle();

    if (!mission) {
      return NextResponse.json({ error: "Mission not found" }, { status: 404 });
    }

    // Upsert task progress (RLS allows own mission_task_progress)
    const { data: taskProgress, error: progressError } = await supabase
      .from("mission_task_progress")
      .upsert(
        {
          user_id: user.id,
          mission_id: missionId,
          task_key: taskKey,
          completed,
          notes: notes ?? null,
          completed_at: completed ? new Date().toISOString() : null,
        },
        { onConflict: "user_id,mission_id,task_key" },
      )
      .select("*")
      .single();

    if (progressError) {
      console.error("[mission-task]", progressError);
      return NextResponse.json({ error: "Failed to update task" }, { status: 500 });
    }

    // Check if all tasks are completed — if so, update mission status
    const tasks = Array.isArray(mission.tasks) ? (mission.tasks as Array<Record<string, unknown>>) : [];
    const taskKeys = tasks.map((t) => t.key).filter(Boolean) as string[];

    if (taskKeys.length > 0) {
      const { data: allProgress } = await supabase
        .from("mission_task_progress")
        .select("task_key, completed")
        .eq("user_id", user.id)
        .eq("mission_id", missionId);

      const completedCount = (allProgress ?? []).filter((p: { completed: boolean }) => p.completed).length;
      const allDone = completedCount >= taskKeys.length;

      if (allDone) {
        // Use admin client to update daily_missions (no UPDATE RLS policy)
        const admin = getAdminClient();
        await admin
          .from("daily_missions")
          .update({ status: "completed" })
          .eq("id", missionId)
          .eq("user_id", user.id);
      } else if (completed === true) {
        // At least one task done — mark in_progress
        const admin = getAdminClient();
        await admin
          .from("daily_missions")
          .update({ status: "in_progress" })
          .eq("id", missionId)
          .eq("user_id", user.id)
          .eq("status", "not_started");
      }
    }

    return NextResponse.json({ taskProgress });
  } catch (err) {
    console.error("[mission-task]", err);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}
