/**
 * /api/notes/[id]
 * PATCH  — update note (title, content, tags, pinned)
 * DELETE — remove note
 */
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { createClient } from "@/lib/supabase/server";
import { rateLimit } from "@/lib/rate-limit";
import type { TablesUpdate } from "@/lib/database.types";

const updateSchema = z.object({
  title: z.string().min(1).max(200).optional(),
  content_markdown: z.string().max(50000).optional(),
  tags: z.array(z.string().max(50)).max(10).optional(),
  pinned: z.boolean().optional(),
  skill_id: z.string().uuid().nullable().optional(),
});

export async function PATCH(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> },
) {
  try {
    const { id } = await params;
    const supabase = await createClient();
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const limit = rateLimit(`notes-update:${user.id}`, 20, 60_000);
    if (!limit.success) {
      return NextResponse.json(
        { error: "Rate limit exceeded" },
        { status: 429, headers: { "X-RateLimit-Remaining": String(limit.remaining) } },
      );
    }

    const body = await request.json();
    const parsed = updateSchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json({ error: "Invalid request" }, { status: 400 });
    }

    const updateData: TablesUpdate<"notes"> = { updated_at: new Date().toISOString() };
    if (parsed.data.title !== undefined) updateData.title = parsed.data.title;
    if (parsed.data.content_markdown !== undefined) updateData.content_markdown = parsed.data.content_markdown;
    if (parsed.data.tags !== undefined) updateData.tags = parsed.data.tags;
    if (parsed.data.pinned !== undefined) updateData.pinned = parsed.data.pinned;
    if (parsed.data.skill_id !== undefined) updateData.skill_id = parsed.data.skill_id;

    const { data: note, error } = await supabase
      .from("notes")
      .update(updateData)
      .eq("id", id)
      .eq("user_id", user.id)
      .select("id, title, content_markdown, tags, pinned, skill_id, created_at, updated_at")
      .single();

    if (error) {
      console.error("[notes-update]", error);
      return NextResponse.json({ error: "Failed to update note" }, { status: 500 });
    }

    if (!note) {
      return NextResponse.json({ error: "Note not found" }, { status: 404 });
    }

    return NextResponse.json({ note });
  } catch (err) {
    console.error("[notes-update]", err);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}

export async function DELETE(
  _request: NextRequest,
  { params }: { params: Promise<{ id: string }> },
) {
  try {
    const { id } = await params;
    const supabase = await createClient();
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const limit = rateLimit(`notes-delete:${user.id}`, 20, 60_000);
    if (!limit.success) {
      return NextResponse.json(
        { error: "Rate limit exceeded" },
        { status: 429, headers: { "X-RateLimit-Remaining": String(limit.remaining) } },
      );
    }

    const { error } = await supabase
      .from("notes")
      .delete()
      .eq("id", id)
      .eq("user_id", user.id);

    if (error) {
      console.error("[notes-delete]", error);
      return NextResponse.json({ error: "Failed to delete note" }, { status: 500 });
    }

    return NextResponse.json({ success: true });
  } catch (err) {
    console.error("[notes-delete]", err);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}
