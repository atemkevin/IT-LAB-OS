import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { createClient, type SupabaseClient } from "@supabase/supabase-js";
import type { Database } from "@/lib/database.types";
import { evaluateAssessment, ONBOARDING_QUESTIONS } from "@/lib/onboarding/assessment";
import {
  onboardingSchema,
  EXPERIENCE_LEVELS,
  PRIMARY_GOALS,
  type ExperienceLevel,
  type PrimaryGoal,
} from "@/lib/auth/schemas";

const url = process.env.NEXT_PUBLIC_SUPABASE_URL || "";
const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "";
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY || "";

describe("Phase 3 — Authentication, Profile & Onboarding Integration Tests", () => {
  let admin: SupabaseClient<Database>;
  let user1Client: SupabaseClient<Database>;
  let user2Client: SupabaseClient<Database>;
  let user1Id: string;
  let user2Id: string;
  const timestamp = Date.now();
  const user1Email = `p3_tester1_${timestamp}@itlabos.test`;
  const user2Email = `p3_tester2_${timestamp}@itlabos.test`;
  const testPassword = "Password123!Secure";

  beforeAll(async () => {
    admin = createClient<Database>(url, serviceRoleKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    // 1. Create test users via admin
    const { data: u1 } = await admin.auth.admin.createUser({
      email: user1Email,
      password: testPassword,
      email_confirm: true,
    });
    user1Id = u1!.user!.id;

    const { data: u2 } = await admin.auth.admin.createUser({
      email: user2Email,
      password: testPassword,
      email_confirm: true,
    });
    user2Id = u2!.user!.id;

    // 2. Authenticate clients with isolated storage keys
    user1Client = createClient<Database>(url, anonKey, {
      auth: {
        storageKey: `p3-user1-${timestamp}`,
        persistSession: true,
        autoRefreshToken: false,
      },
    });

    user2Client = createClient<Database>(url, anonKey, {
      auth: {
        storageKey: `p3-user2-${timestamp}`,
        persistSession: true,
        autoRefreshToken: false,
      },
    });
  });

  afterAll(async () => {
    if (user1Id) await admin.auth.admin.deleteUser(user1Id);
    if (user2Id) await admin.auth.admin.deleteUser(user2Id);
  });

  describe("1. AUTH: Sign In, Session & Sign Out", () => {
    it("successfully signs in with valid credentials", async () => {
      const { data, error } = await user1Client.auth.signInWithPassword({
        email: user1Email,
        password: testPassword,
      });

      expect(error).toBeNull();
      expect(data.user).toBeDefined();
      expect(data.user?.email).toBe(user1Email);
      expect(data.session?.access_token).toBeDefined();
    });

    it("fails to sign in with invalid password", async () => {
      const tempClient = createClient<Database>(url, anonKey, {
        auth: { persistSession: false, autoRefreshToken: false },
      });

      const { data, error } = await tempClient.auth.signInWithPassword({
        email: user1Email,
        password: "WrongPassword!456",
      });

      expect(error).not.toBeNull();
      expect(data.user).toBeNull();
      expect(error?.message).toMatch(/invalid login credentials/i);
    });

    it("successfully signs out and terminates session", async () => {
      const tempEmail = `temp_signout_${Date.now()}@itlabos.test`;
      const { data: tempUser } = await admin.auth.admin.createUser({
        email: tempEmail,
        password: testPassword,
        email_confirm: true,
      });

      const tempClient = createClient<Database>(url, anonKey, {
        auth: {
          storageKey: `p3-temp-${Date.now()}`,
          persistSession: true,
          autoRefreshToken: false,
        },
      });

      await tempClient.auth.signInWithPassword({
        email: tempEmail,
        password: testPassword,
      });

      const { data: sessionBefore } = await tempClient.auth.getSession();
      expect(sessionBefore.session).not.toBeNull();

      const { error: signOutErr } = await tempClient.auth.signOut();
      expect(signOutErr).toBeNull();

      const { data: sessionAfter } = await tempClient.auth.getSession();
      expect(sessionAfter.session).toBeNull();

      await admin.auth.admin.deleteUser(tempUser!.user!.id);
    });
  });

  describe("2. PROFILE: Creation, Ownership, Update & Isolation", () => {
    it("creates profile linked strictly to authenticated user ID", async () => {
      // The profile row is provisioned by the handle_new_user trigger on
      // signup, so the learner updates rather than inserts. Only
      // learner-editable columns are writable (migration 008).
      const { data, error } = await user1Client
        .from("profiles")
        .update({
          display_name: "Engineer Alpha",
          experience_level: "Intermediate",
          daily_minutes: 60,
          primary_goal: "Network Engineer",
        })
        .eq("id", user1Id)
        .select()
        .single();

      expect(error).toBeNull();
      expect(data?.id).toBe(user1Id);
      expect(data?.display_name).toBe("Engineer Alpha");
      expect(data?.experience_level).toBe("Intermediate");
      expect(data?.primary_goal).toBe("Network Engineer");
      // onboarding_done is server-authoritative; still at its signup default.
      expect(data?.onboarding_done).toBe(false);
    });

    it("rejects learner attempts to forge server-authoritative profile columns", async () => {
      const forgedEnvironment = { recommendedFirstSkill: "hacked", assessmentScore: 100 };

      const streakForge = await user1Client
        .from("profiles")
        .update({ current_streak: 999 })
        .eq("id", user1Id)
        .select();

      const onboardingForge = await user1Client
        .from("profiles")
        .update({ onboarding_done: true })
        .eq("id", user1Id)
        .select();

      const environmentForge = await user1Client
        .from("profiles")
        .update({ environment: forgedEnvironment })
        .eq("id", user1Id)
        .select();

      // 42501 = insufficient_privilege
      expect(streakForge.error?.code).toBe("42501");
      expect(onboardingForge.error?.code).toBe("42501");
      expect(environmentForge.error?.code).toBe("42501");

      // Confirm nothing was actually written.
      const { data: after } = await admin
        .from("profiles")
        .select("current_streak, onboarding_done, environment")
        .eq("id", user1Id)
        .single();

      expect(after?.current_streak).toBe(0);
      expect(after?.onboarding_done).toBe(false);
      expect((after?.environment as Record<string, unknown>)?.recommendedFirstSkill).toBeUndefined();
    });

    it("allows user to update their own profile", async () => {
      const { data, error } = await user1Client
        .from("profiles")
        .update({ display_name: "Senior Engineer Alpha", daily_minutes: 90 })
        .eq("id", user1Id)
        .select()
        .single();

      expect(error).toBeNull();
      expect(data?.display_name).toBe("Senior Engineer Alpha");
      expect(data?.daily_minutes).toBe(90);
    });

    it("enforces user isolation: User 2 cannot read or modify User 1's profile", async () => {
      await user2Client.auth.signInWithPassword({
        email: user2Email,
        password: testPassword,
      });

      const { data: user1ProfileFromUser2 } = await user2Client
        .from("profiles")
        .select("*")
        .eq("id", user1Id)
        .maybeSingle();

      expect(user1ProfileFromUser2).toBeNull();

      const { error: updateError } = await user2Client
        .from("profiles")
        .update({ display_name: "Hacked Alpha" })
        .eq("id", user1Id);

      expect(updateError).toBeNull();

      const { data: pristineUser1 } = await user1Client
        .from("profiles")
        .select("display_name")
        .eq("id", user1Id)
        .single();

      expect(pristineUser1?.display_name).toBe("Senior Engineer Alpha");
    });
  });

  describe("3. PRODUCT ALIGNMENT: Experience Levels & Primary Goals", () => {
    it("validates all four canonical experience levels in schema", () => {
      EXPERIENCE_LEVELS.forEach((level) => {
        const result = onboardingSchema.safeParse({
          experience_level: level,
          primary_goal: "Network Engineer",
          daily_minutes: 60,
          environment: ["Linux", "Docker"],
        });
        expect(result.success).toBe(true);
      });
    });

    it("validates all four canonical primary goals in schema", () => {
      PRIMARY_GOALS.forEach((goal) => {
        const result = onboardingSchema.safeParse({
          experience_level: "Intermediate",
          primary_goal: goal,
          daily_minutes: 60,
          environment: ["Linux"],
        });
        expect(result.success).toBe(true);
      });
    });

    it("rejects legacy goal values in schema", () => {
      const legacyGoals = ["DevOps", "Cloud Architect", "Systems Admin", "Security"];
      legacyGoals.forEach((legacyGoal) => {
        const result = onboardingSchema.safeParse({
          experience_level: "Intermediate",
          primary_goal: legacyGoal,
          daily_minutes: 60,
          environment: ["Linux"],
        });
        expect(result.success).toBe(false);
      });
    });

    it("rejects legacy experience level values in schema", () => {
      const legacyLevels = ["Advanced", "Beginner", "foundational"];
      legacyLevels.forEach((legacyLevel) => {
        const result = onboardingSchema.safeParse({
          experience_level: legacyLevel,
          primary_goal: "Cybersecurity",
          daily_minutes: 60,
          environment: ["Linux"],
        });
        expect(result.success).toBe(false);
      });
    });
  });

  describe("4. ASSESSMENT: 6 Foundation Domains & Evaluation Engine", () => {
    it("contains exactly 6 questions mapping to the foundation curriculum domains and skills", () => {
      expect(ONBOARDING_QUESTIONS.length).toBe(6);

      const expectedDomains = [
        "Computer / IT Fundamentals",
        "Operating Systems",
        "Networking",
        "Linux",
        "Cybersecurity",
        "Automation / scripting",
      ];

      const questionDomains = ONBOARDING_QUESTIONS.map((q) => q.domain);
      expectedDomains.forEach((domain) => {
        expect(questionDomains).toContain(domain);
      });

      const questionSkills = ONBOARDING_QUESTIONS.map((q) => q.skillSlug);
      expect(questionSkills).toContain("cpu-memory-storage");
      expect(questionSkills).toContain("processes-services");
      expect(questionSkills).toContain("ip-addressing");
      expect(questionSkills).toContain("linux-permissions");
      expect(questionSkills).toContain("authentication-authorization");
      expect(questionSkills).toContain("python-basics");
    });

    it("evaluates deterministic score and maps to 4-level experience model", () => {
      // 1. Perfect score: 6/6 -> 100%, Experienced
      const perfectAnswers: Record<string, string> = {
        q_comp: "Random Access Memory (RAM)",
        q_os: "Service (or Daemon)",
        q_net: "DHCP",
        q_linux: "744",
        q_sec: "Authentication verifies who you are; Authorization determines what resources you are allowed to access",
        q_auto: "List",
      };

      const result100 = evaluateAssessment(perfectAnswers, "Network Engineer");
      expect(result100.percentageScore).toBe(100);
      expect(result100.correctCount).toBe(6);
      expect(result100.startingLevel).toBe("Experienced");
      expect(result100.weakSkills.length).toBe(0);
      expect(result100.recommendedFirstSkill).toBe("subnetting");

      // 2. Intermediate score: 3/6 -> 50%, Intermediate
      const intermediateAnswers: Record<string, string> = {
        q_comp: "Random Access Memory (RAM)", // correct
        q_os: "Foreground job", // wrong
        q_net: "DHCP", // correct
        q_linux: "777", // wrong
        q_sec: "Authentication verifies who you are; Authorization determines what resources you are allowed to access", // correct
        q_auto: "Dictionary", // wrong
      };

      const result50 = evaluateAssessment(intermediateAnswers, "Cybersecurity");
      expect(result50.percentageScore).toBe(50);
      expect(result50.correctCount).toBe(3);
      expect(result50.startingLevel).toBe("Intermediate");
      expect(result50.weakDomains).toContain("Operating Systems");
      expect(result50.weakDomains).toContain("Linux");
      expect(result50.weakDomains).toContain("Automation / scripting");

      // 3. Basic score: 2/6 -> 33%, Some basic knowledge
      const basicAnswers: Record<string, string> = {
        q_comp: "Random Access Memory (RAM)", // correct
        q_os: "Foreground job", // wrong
        q_net: "DHCP", // correct
        q_linux: "777", // wrong
        q_sec: "Wrong", // wrong
        q_auto: "Wrong", // wrong
      };

      const result33 = evaluateAssessment(basicAnswers, "AI Automation");
      expect(result33.percentageScore).toBe(33);
      expect(result33.correctCount).toBe(2);
      expect(result33.startingLevel).toBe("Some basic knowledge");
      expect(result33.weakSkills).toContain("python-basics");
      expect(result33.recommendedFirstSkill).toBe("python-basics");

      // 4. Zero score: 0/6 -> 0%, Complete beginner
      const result0 = evaluateAssessment({}, "General IT / Infrastructure");
      expect(result0.percentageScore).toBe(0);
      expect(result0.correctCount).toBe(0);
      expect(result0.startingLevel).toBe("Complete beginner");
      expect(result0.weakSkills).toContain("cpu-memory-storage");
      expect(result0.recommendedFirstSkill).toBe("computer-basics");
    });
  });

  describe("5. ONBOARDING: Persistence & Idempotency", () => {
    it("persists onboarding completion, environment metadata, and baseline mastery evidence", async () => {
      const assessmentResult = evaluateAssessment(
        {
          q_comp: "Random Access Memory (RAM)",
          q_os: "Service (or Daemon)",
          q_net: "DHCP",
          q_linux: "744",
          q_sec: "Authentication verifies who you are; Authorization determines what resources you are allowed to access",
          q_auto: "List",
        },
        "Network Engineer",
      );

      // Complete onboarding for User 1.
      // `onboarding_done` and `environment` are server-authoritative
      // (migration 008 revokes learner UPDATE on them), so this mirrors what
      // the trusted /api/onboarding route does: it writes them with the
      // service-role client after deriving user.id from the session.
      const environmentData = {
        tools: ["Linux", "Docker", "GitHub"],
        startingLevel: assessmentResult.startingLevel,
        recommendedFirstSkill: assessmentResult.recommendedFirstSkill,
        assessmentScore: assessmentResult.percentageScore,
        completedAt: new Date().toISOString(),
      };

      const { data: updatedProfile, error: profileErr } = await admin
        .from("profiles")
        .update({
          onboarding_done: true,
          experience_level: "Experienced",
          primary_goal: "Network Engineer",
          environment: environmentData,
        })
        .eq("id", user1Id)
        .select()
        .single();

      expect(profileErr).toBeNull();
      expect(updatedProfile?.onboarding_done).toBe(true);
      expect(updatedProfile?.experience_level).toBe("Experienced");
      expect(updatedProfile?.primary_goal).toBe("Network Engineer");
      expect((updatedProfile?.environment as any)?.tools).toContain("Docker");

      // Look up target skill for evidence
      const { data: skillRow } = await admin
        .from("skills")
        .select("id")
        .eq("slug", "subnetting")
        .single();

      // Write baseline evidence via admin client
      const { data: evidence, error: evErr } = await admin
        .from("mastery_evidence")
        .insert({
          user_id: user1Id,
          skill_id: skillRow!.id,
          evidence_type: "quiz",
          score: assessmentResult.percentageScore,
          metadata: {
            source: "onboarding_assessment",
            startingLevel: assessmentResult.startingLevel,
            correctCount: assessmentResult.correctCount,
            totalQuestions: assessmentResult.totalQuestions,
          },
        })
        .select()
        .single();

      expect(evErr).toBeNull();
      expect(evidence?.score).toBe(100);
      expect(evidence?.user_id).toBe(user1Id);
    });

    it("verifies idempotency: repeated onboarding submission does not create duplicate evidence", async () => {
      // Query baseline evidence count for user1Id before repeat
      const { data: initialEvidenceList } = await admin
        .from("mastery_evidence")
        .select("id")
        .eq("user_id", user1Id)
        .eq("evidence_type", "quiz")
        .contains("metadata", { source: "onboarding_assessment" });

      expect(initialEvidenceList?.length).toBe(1);
      const originalEvidenceId = initialEvidenceList![0].id;

      // Simulate second submission using the idempotent logic implemented in /api/onboarding
      const newAssessmentResult = evaluateAssessment(
        {
          q_comp: "Random Access Memory (RAM)",
          q_os: "Service (or Daemon)",
        },
        "Network Engineer",
      );

      // 1. Idempotent profile update via the trusted server path
      //    (server-authoritative columns are not learner-writable).
      await admin
        .from("profiles")
        .update({
          display_name: "Senior Engineer Alpha",
          experience_level: newAssessmentResult.startingLevel,
          primary_goal: "Network Engineer",
          daily_minutes: 60,
          onboarding_done: true,
          environment: {
            tools: ["Linux", "Docker"],
            startingLevel: newAssessmentResult.startingLevel,
            assessmentScore: newAssessmentResult.percentageScore,
            completedAt: new Date().toISOString(),
          },
        })
        .eq("id", user1Id);

      // 2. Idempotent evidence update: check existing record and update in place
      const { data: existingEvidence } = await admin
        .from("mastery_evidence")
        .select("id")
        .eq("user_id", user1Id)
        .eq("evidence_type", "quiz")
        .contains("metadata", { source: "onboarding_assessment" })
        .maybeSingle();

      expect(existingEvidence?.id).toBe(originalEvidenceId);

      await admin
        .from("mastery_evidence")
        .update({
          score: newAssessmentResult.percentageScore,
          metadata: {
            source: "onboarding_assessment",
            correctCount: newAssessmentResult.correctCount,
            totalQuestions: newAssessmentResult.totalQuestions,
            startingLevel: newAssessmentResult.startingLevel,
            updatedAt: new Date().toISOString(),
          },
        })
        .eq("id", existingEvidence!.id);

      // Verify no duplicate evidence rows exist for onboarding_assessment
      const { data: finalEvidenceList } = await admin
        .from("mastery_evidence")
        .select("id, score")
        .eq("user_id", user1Id)
        .eq("evidence_type", "quiz")
        .contains("metadata", { source: "onboarding_assessment" });

      expect(finalEvidenceList?.length).toBe(1);
      expect(finalEvidenceList![0].id).toBe(originalEvidenceId);
      expect(finalEvidenceList![0].score).toBe(newAssessmentResult.percentageScore);

      // Verify profiles row count remains exactly 1 for user1
      const { data: user1Profiles } = await admin
        .from("profiles")
        .select("id")
        .eq("id", user1Id);

      expect(user1Profiles?.length).toBe(1);
    });
  });

  describe("6. SECURITY: Unauthenticated & Foreign Profile Access", () => {
    it("prevents unauthenticated clients from reading private profile data", async () => {
      const anonClient = createClient<Database>(url, anonKey, {
        auth: { persistSession: false, autoRefreshToken: false },
      });

      const { data, error } = await anonClient.from("profiles").select("*");
      expect(error).toBeNull();
      expect(data).toEqual([]); // RLS returns empty
    });
  });
});
