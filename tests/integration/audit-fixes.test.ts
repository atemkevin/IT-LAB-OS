import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { createClient, type SupabaseClient } from "@supabase/supabase-js";
import type { Database } from "@/lib/database.types";
import { startAttempt, runCommand } from "@/lib/troubleshooting/engine";

const url = process.env.NEXT_PUBLIC_SUPABASE_URL || "";
const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "";
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY || "";

describe("Audit Fixes Verification", () => {
  let admin: SupabaseClient<Database>;
  let userAClient: SupabaseClient<Database>;
  let userAId: string;

  beforeAll(async () => {
    admin = createClient<Database>(url, serviceRoleKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    const timestamp = Date.now();
    const emailA = `test_audit_fix_${timestamp}@itlabos.test`;
    const password = "Password123!Secure";

    const { data: userARes } = await admin.auth.admin.createUser({
      email: emailA,
      password,
      email_confirm: true,
    });
    userAId = userARes!.user!.id;

    userAClient = createClient<Database>(url, anonKey, {
      auth: {
        storageKey: `user-audit-storage-${timestamp}`,
        persistSession: true,
        autoRefreshToken: false,
      },
    });
    await userAClient.auth.signInWithPassword({ email: emailA, password });
  });

  afterAll(async () => {
    if (userAId) await admin.auth.admin.deleteUser(userAId);
  });

  it("1. Troubleshooting runCommand executes successfully against active attempt", async () => {
    const { data: scenarios } = await admin
      .from("troubleshooting_scenarios")
      .select("slug, allowed_commands")
      .eq("is_published", true)
      .limit(1);

    expect(scenarios?.length).toBeGreaterThan(0);
    const scenario = scenarios![0];
    const allowedCommands = Array.isArray(scenario.allowed_commands)
      ? (scenario.allowed_commands as string[])
      : [];
    expect(allowedCommands.length).toBeGreaterThan(0);

    // Start attempt
    const started = await startAttempt(userAId, scenario.slug);
    expect(started).not.toBeNull();
    expect(started?.attemptId).toBeDefined();

    // Execute first allowed command
    const cmd = allowedCommands[0];
    const runRes = await runCommand({
      userId: userAId,
      attemptId: started!.attemptId,
      command: cmd,
    });

    expect(runRes).not.toBeNull();
    expect(runRes?.result).toBeDefined();
    expect(runRes?.result.status).toBeDefined();
    expect(runRes?.result.output).toBeDefined();
    expect(runRes?.attemptId).toBe(started!.attemptId);
  });

  it("2. Troubleshooting runCommand denies access to attempts owned by other users", async () => {
    const { data: scenarios } = await admin
      .from("troubleshooting_scenarios")
      .select("slug, allowed_commands")
      .eq("is_published", true)
      .limit(1);

    const scenario = scenarios![0];
    const started = await startAttempt(userAId, scenario.slug);

    // Attempt to run command as a different user
    const fakeOtherUserId = "00000000-0000-0000-0000-000000000000";
    const runRes = await runCommand({
      userId: fakeOtherUserId,
      attemptId: started!.attemptId,
      command: "ls",
    });

    expect(runRes).toBeNull();
  });
});
