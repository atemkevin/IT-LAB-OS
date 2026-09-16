/**
 * /api/notes
 * GET  — list notes for authenticated user (with optional ?q=search)
 * POST — create a new note
 */
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { createClient } from "@/lib/supabase/server";
import { rateLimit } from "@/lib/rate-limit";

const createSchema = z.object({
  title: z.string().min(1).max(200),
  content_markdown: z.string().max(50000).optional().default(""),
  tags: z.array(z.string().max(50)).max(10).optional().default([]),
  pinned: z.boolean().optional().default(false),
  skill_id: z.string().uuid().optional().nullable(),
});

export async function GET(request: NextRequest) {
  try {
    const supabase = await createClient();
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const limit = rateLimit(`notes-list:${user.id}`, 30, 60_000);
    if (!limit.success) {
      return NextResponse.json(
        { error: "Rate limit exceeded" },
        { status: 429, headers: { "X-RateLimit-Remaining": String(limit.remaining) } },
      );
    }

    const { searchParams } = new URL(request.url);
    const q = searchParams.get("q")?.trim();

    let query = supabase
      .from("notes")
      .select("id, title, content_markdown, tags, pinned, skill_id, created_at, updated_at")
      .eq("user_id", user.id)
      .order("pinned", { ascending: false })
      .order("updated_at", { ascending: false });

    if (q) {
      query = query.or(`title.ilike.%${q}%,content_markdown.ilike.%${q}%`);
    }

    const { data: notes, error } = await query;

    if (error) {
      console.error("[notes-list]", error);
      return NextResponse.json({ error: "Failed to fetch notes" }, { status: 500 });
    }

    return NextResponse.json({ notes });
  } catch (err) {
    console.error("[notes-list]", err);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}

export async function POST(request: NextRequest) {
  try {
    const supabase = await createClient();
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const limit = rateLimit(`notes-create:${user.id}`, 20, 60_000);
    if (!limit.success) {
      return NextResponse.json(
        { error: "Rate limit exceeded" },
        { status: 429, headers: { "X-RateLimit-Remaining": String(limit.remaining) } },
      );
    }

    const body = await request.json();
    const parsed = createSchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json({ error: "Invalid request", details: parsed.error.flatten() }, { status: 400 });
    }

    const { data: note, error } = await supabase
      .from("notes")
      .insert({
        user_id: user.id,
        title: parsed.data.title,
        content_markdown: parsed.data.content_markdown,
        tags: parsed.data.tags,
        pinned: parsed.data.pinned,
        skill_id: parsed.data.skill_id ?? null,
      })
      .select("id, title, content_markdown, tags, pinned, skill_id, created_at, updated_at")
      .single();

    if (error) {
      console.error("[notes-create]", error);
      return NextResponse.json({ error: "Failed to create note" }, { status: 500 });
    }

    return NextResponse.json({ note });
  } catch (err) {
    console.error("[notes-create]", err);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}
