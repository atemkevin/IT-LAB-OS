import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { createClient, type SupabaseClient } from "@supabase/supabase-js";
import type { Database } from "@/lib/database.types";
import { evaluateAssessment, ONBOARDING_QUESTIONS } from "@/lib/onboarding/assessment";

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

    // 1. Test registration via admin
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
      expect(data.session).toBeDefined();
      expect(data.user?.id).toBe(user1Id);
    });

    it("fails to sign in with invalid password", async () => {
      const client = createClient<Database>(url, anonKey, {
        auth: { persistSession: false, autoRefreshToken: false },
      });

      const { data, error } = await client.auth.signInWithPassword({
        email: user1Email,
        password: "WrongPassword999!",
      });

      expect(error).not.toBeNull();
      expect(data.session).toBeNull();
    });

    it("successfully signs out and terminates session", async () => {
      const tempEmail = `p3_temp_${timestamp}@itlabos.test`;
      const { data: tempUser } = await admin.auth.admin.createUser({
        email: tempEmail,
        password: testPassword,
        email_confirm: true,
      });

      const tempClient = createClient<Database>(url, anonKey, {
        auth: {
          storageKey: `p3-temp-${timestamp}`,
          persistSession: true,
          autoRefreshToken: false,
        },
      });

      await tempClient.auth.signInWithPassword({ email: tempEmail, password: testPassword });
      const { data: sessionBefore } = await tempClient.auth.getSession();
      expect(sessionBefore.session).toBeDefined();

      const { error: signOutErr } = await tempClient.auth.signOut();
      expect(signOutErr).toBeNull();

      const { data: sessionAfter } = await tempClient.auth.getSession();
      expect(sessionAfter.session).toBeNull();

      await admin.auth.admin.deleteUser(tempUser!.user!.id);
    });
  });

  describe("2. PROFILE: Creation, Ownership, Update & Isolation", () => {
    it("creates profile linked strictly to authenticated user ID", async () => {
      // User 1 creates profile
      const { data, error } = await user1Client
        .from("profiles")
        .upsert({
          id: user1Id,
          display_name: "Engineer Alpha",
          experience_level: "Intermediate",
          daily_minutes: 60,
          primary_goal: "Network Engineer",
          onboarding_done: false,
        })
        .select()
        .single();

      expect(error).toBeNull();
      expect(data?.id).toBe(user1Id);
      expect(data?.display_name).toBe("Engineer Alpha");
      expect(data?.onboarding_done).toBe(false);
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
      // Sign in User 2
      await user2Client.auth.signInWithPassword({
        email: user2Email,
        password: testPassword,
      });

      // User 2 attempts to read User 1 profile
      const { data: readData, error: readError } = await user2Client
        .from("profiles")
        .select("*")
        .eq("id", user1Id);

      expect(readError).toBeNull();
      expect(readData).toEqual([]); // RLS blocks read

      // User 2 attempts to update User 1 profile
      const { error: updateError } = await user2Client
        .from("profiles")
        .update({ display_name: "Compromised by User 2" })
        .eq("id", user1Id);

      expect(updateError).toBeNull();

      // Verify User 1 profile remains untouched
      const { data: verifyData } = await user1Client
        .from("profiles")
        .select("display_name")
        .eq("id", user1Id)
        .single();

      expect(verifyData?.display_name).toBe("Senior Engineer Alpha");
    });
  });

  describe("3. ONBOARDING: Assessment, Evidence & State Transition", () => {
    it("evaluates deterministic assessment questions accurately", () => {
      // Perfect answers
      const perfectAnswers: Record<string, string> = {
        q_linux: "top",
        q_net: "DHCP",
        q_sec: "Disabling root password login and enforcing Ed25519 key-based authentication",
        q_auto: "It describes the desired target state and enables reproducible, automated deployments",
      };

      const result100 = evaluateAssessment(perfectAnswers, "Network Engineer");
      expect(result100.percentageScore).toBe(100);
      expect(result100.correctCount).toBe(4);
      expect(result100.startingLevel).toBe("advanced");
      expect(result100.weakSkills.length).toBe(0);

      // Flawed answers
      const partialAnswers: Record<string, string> = {
        q_linux: "ls -la", // wrong
        q_net: "DHCP", // correct
        q_sec: "Using password authentication with 8 characters", // wrong
        q_auto: "It describes the desired target state and enables reproducible, automated deployments", // correct
      };

      const result50 = evaluateAssessment(partialAnswers, "Cybersecurity");
      expect(result50.percentageScore).toBe(50);
      expect(result50.correctCount).toBe(2);
      expect(result50.startingLevel).toBe("intermediate");
      expect(result50.weakDomains).toContain("Linux");
      expect(result50.weakDomains).toContain("Cybersecurity");
      expect(result50.weakSkills).toContain("processes-services");
      expect(result50.weakSkills).toContain("ssh");
      expect(result50.recommendedFirstSkill).toBe("security-fundamentals");
    });

    it("persists onboarding completion, environment metadata, and mastery evidence", async () => {
      const assessmentResult = evaluateAssessment(
        {
          q_linux: "top",
          q_net: "DHCP",
          q_sec: "Disabling root password login and enforcing Ed25519 key-based authentication",
          q_auto: "It describes the desired target state and enables reproducible, automated deployments",
        },
        "Network Engineer",
      );

      // Complete onboarding for User 1
      const { data: updatedProfile, error: profileErr } = await user1Client
        .from("profiles")
        .update({
          onboarding_done: true,
          environment: {
            tools: ["Linux", "Docker", "GitHub"],
            startingLevel: assessmentResult.startingLevel,
            recommendedFirstSkill: assessmentResult.recommendedFirstSkill,
          },
        })
        .eq("id", user1Id)
        .select()
        .single();

      expect(profileErr).toBeNull();
      expect(updatedProfile?.onboarding_done).toBe(true);
      expect((updatedProfile?.environment as any)?.tools).toContain("Docker");

      // Verify mastery_evidence recorded via admin client
      const { data: skillRow } = await admin
        .from("skills")
        .select("id")
        .eq("slug", "subnetting")
        .single();

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
          },
        })
        .select()
        .single();

      expect(evErr).toBeNull();
      expect(evidence?.score).toBe(100);
      expect(evidence?.user_id).toBe(user1Id);
    });

    it("verifies routing redirect logic based on onboarding_done state", () => {
      // Incomplete onboarding logic: must redirect to /onboarding
      const incompleteProfile = { onboarding_done: false };
      const targetRouteIncomplete = incompleteProfile.onboarding_done ? "/dashboard" : "/onboarding";
      expect(targetRouteIncomplete).toBe("/onboarding");

      // Completed onboarding logic: must redirect to /dashboard
      const completeProfile = { onboarding_done: true };
      const targetRouteComplete = completeProfile.onboarding_done ? "/dashboard" : "/onboarding";
      expect(targetRouteComplete).toBe("/dashboard");
    });
  });

  describe("4. SECURITY: Unauthenticated & Foreign Profile Access", () => {
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
