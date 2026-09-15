import { NextResponse, type NextRequest } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { z } from "zod";

const updateProfileSchema = z.object({
  display_name: z.string().min(1).max(50).optional(),
  experience_level: z.string().optional(),
  daily_minutes: z.union([z.literal(30), z.literal(60), z.literal(90), z.literal(120)]).optional(),
  primary_goal: z.string().optional(),
});

export async function GET() {
  try {
    const supabase = await createClient();
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser();

    if (authError || !user) {
      return NextResponse.json(
        { error: { code: "UNAUTHORIZED", message: "Authentication required" } },
        { status: 401 },
      );
    }

    const { data: profile, error: dbError } = await supabase
      .from("profiles")
      .select("*")
      .eq("id", user.id)
      .maybeSingle();

    if (dbError) {
      return NextResponse.json(
        { error: { code: "INTERNAL_ERROR", message: dbError.message } },
        { status: 500 },
      );
    }

    return NextResponse.json({ profile, email: user.email });
  } catch (err: unknown) {
    console.error("GET profile error:", err);
    return NextResponse.json(
      { error: { code: "INTERNAL_ERROR", message: "Failed to load profile" } },
      { status: 500 },
    );
  }
}

export async function PATCH(request: NextRequest) {
  try {
    const supabase = await createClient();
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser();

    if (authError || !user) {
      return NextResponse.json(
        { error: { code: "UNAUTHORIZED", message: "Authentication required" } },
        { status: 401 },
      );
    }

    const json = await request.json();
    const parsed = updateProfileSchema.safeParse(json);

    if (!parsed.success) {
      return NextResponse.json(
        { error: { code: "VALIDATION_ERROR", message: "Invalid profile data", details: parsed.error.format() } },
        { status: 400 },
      );
    }

    const { data: updated, error: updateError } = await supabase
      .from("profiles")
      .update({
        ...parsed.data,
        updated_at: new Date().toISOString(),
      })
      .eq("id", user.id)
      .select()
      .single();

    if (updateError) {
      return NextResponse.json(
        { error: { code: "INTERNAL_ERROR", message: updateError.message } },
        { status: 500 },
      );
    }

    return NextResponse.json({ success: true, profile: updated });
  } catch (err: unknown) {
    console.error("PATCH profile error:", err);
    return NextResponse.json(
      { error: { code: "INTERNAL_ERROR", message: "Failed to update profile" } },
      { status: 500 },
    );
  }
}
