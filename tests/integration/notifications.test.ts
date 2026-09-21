import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { createClient, SupabaseClient } from "@supabase/supabase-js";
import { randomUUID } from "crypto";

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || "http://127.0.0.1:54321";
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRlc3QiLCJyb2xlIjoic2VydmljZV9yb2xlIiwiaWF0IjoxNzA0MDY3MjAwLCJleHAiOjE4NjE4NDMyMDB9.SERVICE_KEY";

const serviceClient = createClient(supabaseUrl, supabaseServiceKey);

describe("Notifications RLS and Integration", () => {
  let userA: { id: string; email: string };
  let userB: { id: string; email: string };
  let clientA: SupabaseClient;
  let clientB: SupabaseClient;
  let notifA1: string;

  beforeAll(async () => {
    // 1. Create two test users
    userA = { id: randomUUID(), email: `test-a-${Date.now()}@example.com` };
    userB = { id: randomUUID(), email: `test-b-${Date.now()}@example.com` };

    await serviceClient.auth.admin.createUser({
      id: userA.id,
      email: userA.email,
      password: "Password123!",
      email_confirm: true,
    });
    
    await serviceClient.auth.admin.createUser({
      id: userB.id,
      email: userB.email,
      password: "Password123!",
      email_confirm: true,
    });

    // 2. Setup authenticated clients
    clientA = createClient(supabaseUrl, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "anon", {
      auth: { autoRefreshToken: false, persistSession: false },
    });
    await clientA.auth.signInWithPassword({ email: userA.email, password: "Password123!" });

    clientB = createClient(supabaseUrl, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "anon", {
      auth: { autoRefreshToken: false, persistSession: false },
    });
    await clientB.auth.signInWithPassword({ email: userB.email, password: "Password123!" });

    // 3. Seed notifications
    const { data, error } = await serviceClient.from("notifications").insert([
      { user_id: userA.id, type: "system", title: "Welcome A", message: "Hello A" },
      { user_id: userB.id, type: "system", title: "Welcome B", message: "Hello B" },
    ]).select("id");
    
    if (error) throw error;
    notifA1 = data[0].id;
  });

  afterAll(async () => {
    // Cleanup
    await serviceClient.auth.admin.deleteUser(userA.id);
    await serviceClient.auth.admin.deleteUser(userB.id);
  });

  it("User A should only see their own notifications", async () => {
    const { data, error } = await clientA.from("notifications").select("*");
    expect(error).toBeNull();
    expect(data?.length).toBe(1);
    expect(data?.[0].user_id).toBe(userA.id);
  });

  it("User A cannot update User B's notifications", async () => {
    const { error } = await clientA.from("notifications").update({ is_read: true }).eq("user_id", userB.id);
    // Supposed to fail or silently update 0 rows
    const { data: verifyB } = await serviceClient.from("notifications").select("is_read").eq("user_id", userB.id).single();
    expect(verifyB?.is_read).toBe(false);
  });

  it("User A can mark their own notification as read", async () => {
    const { error } = await clientA.from("notifications").update({ is_read: true }).eq("id", notifA1);
    expect(error).toBeNull();

    const { data: verifyA } = await serviceClient.from("notifications").select("is_read").eq("id", notifA1).single();
    expect(verifyA?.is_read).toBe(true);
  });
});
