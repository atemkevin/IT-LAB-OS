import { NextResponse, type NextRequest } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { getAdminClient } from "@/lib/supabase/admin";
import { onboardingSchema } from "@/lib/auth/schemas";
import { evaluateAssessment } from "@/lib/onboarding/assessment";

export async function POST(request: NextRequest) {
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
    const parsed = onboardingSchema.safeParse(json);

    if (!parsed.success) {
      return NextResponse.json(
        {
          error: {
            code: "VALIDATION_ERROR",
            message: "Invalid onboarding payload",
            details: parsed.error.format(),
          },
        },
        { status: 400 },
      );
    }

    const { experience_level, primary_goal, daily_minutes, environment, assessmentAnswers } =
      parsed.data;

    // 1. Deterministically grade assessment
    const assessmentResult = evaluateAssessment(assessmentAnswers, primary_goal);

    // 2. Prepare environment and profile metadata
    const environmentData: import("@/lib/auth/schemas").UserEnvironment = {
      tools: environment,
      startingLevel: assessmentResult.startingLevel,
      weakDomains: assessmentResult.weakDomains,
      weakSkills: assessmentResult.weakSkills,
      recommendedFirstSkill: assessmentResult.recommendedFirstSkill,
      assessmentScore: assessmentResult.percentageScore,
      completedAt: new Date().toISOString(),
    };

    // 3. Persist the profile with the trusted server client.
    //
    // `environment` (assessment results) and `onboarding_done` are
    // server-authoritative columns: migration 008 revokes learner UPDATE on
    // them so onboarding cannot be forged through PostgREST. user.id is taken
    // from the verified session above — it is never client-supplied.
    const admin = getAdminClient();
    const displayName =
      user.user_metadata?.display_name || user.email?.split("@")[0] || "Learner";

    const { error: profileError } = await admin
      .from("profiles")
      .upsert(
        {
          id: user.id,
          display_name: displayName,
          experience_level,
          primary_goal,
          daily_minutes,
          environment: environmentData as unknown as import("@/lib/database.types").Json,
          onboarding_done: true,
          updated_at: new Date().toISOString(),
        },
        { onConflict: "id" },
      );

    if (profileError) {
      console.error("Failed to update profile:", profileError);
      return NextResponse.json(
        { error: { code: "INTERNAL_ERROR", message: "Failed to persist onboarding profile" } },
        { status: 500 },
      );
    }

    // 4. Record assessment evidence in mastery_evidence (idempotent baseline evidence)

    // Look up ID for the recommended skill if available
    const { data: skillRow } = await admin
      .from("skills")
      .select("id")
      .eq("slug", assessmentResult.recommendedFirstSkill)
      .maybeSingle();

    if (skillRow) {
      // Check for existing baseline onboarding assessment evidence to prevent duplicate rows on repeated submissions
      const { data: existingEvidence } = await admin
        .from("mastery_evidence")
        .select("id")
        .eq("user_id", user.id)
        .eq("evidence_type", "quiz")
        .contains("metadata", { source: "onboarding_assessment" })
        .maybeSingle();

      const evidencePayload = {
        user_id: user.id,
        skill_id: skillRow.id,
        evidence_type: "quiz",
        score: assessmentResult.percentageScore,
        metadata: {
          source: "onboarding_assessment",
          correctCount: assessmentResult.correctCount,
          totalQuestions: assessmentResult.totalQuestions,
          startingLevel: assessmentResult.startingLevel,
          weakSkills: assessmentResult.weakSkills,
          updatedAt: new Date().toISOString(),
        },
      };

      if (existingEvidence) {
        await admin
          .from("mastery_evidence")
          .update(evidencePayload)
          .eq("id", existingEvidence.id);
      } else {
        await admin.from("mastery_evidence").insert(evidencePayload);
      }
    }

    return NextResponse.json({
      success: true,
      assessmentResult,
      redirectTo: "/dashboard",
    });
  } catch (err: unknown) {
    console.error("Onboarding submission error:", err);
    return NextResponse.json(
      { error: { code: "INTERNAL_ERROR", message: "An unexpected error occurred" } },
      { status: 500 },
    );
  }
}
