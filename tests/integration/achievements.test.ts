import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { createClient, SupabaseClient } from "@supabase/supabase-js";
import { randomUUID } from "crypto";
import { evaluateAchievements } from "@/lib/achievements/service";

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || "http://127.0.0.1:54321";
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY || "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRlc3QiLCJyb2xlIjoic2VydmljZV9yb2xlIiwiaWF0IjoxNzA0MDY3MjAwLCJleHAiOjE4NjE4NDMyMDB9.SERVICE_KEY";

const serviceClient = createClient(supabaseUrl, supabaseServiceKey);

describe("Achievements Engine", () => {
  let userId: string;
  let userEmail: string;

  beforeAll(async () => {
    userId = randomUUID();
    userEmail = `achiever-${Date.now()}@example.com`;

    // 1. Create a user
    await serviceClient.auth.admin.createUser({
      id: userId,
      email: userEmail,
      password: "Password123!",
      email_confirm: true,
    });

    // 2. Wait for profile trigger and set stats
    await new Promise(r => setTimeout(r, 1000));
    const { error: pError } = await serviceClient.from("profiles").update({ current_streak: 3 }).eq("id", userId);
    if (pError) console.error("PROFILE UPDATE ERROR:", pError);
  });

  afterAll(async () => {
    // Cleanup
    await serviceClient.auth.admin.deleteUser(userId);
  });

  it("should unlock the streak_3 achievement when criteria is met", async () => {
    // Run the engine
    await evaluateAchievements(serviceClient, userId);

    // Verify it unlocked
    const { data: userAchievements, error: uaError } = await serviceClient
      .from("user_achievements")
      .select("*")
      .eq("user_id", userId);
    
    expect(uaError).toBeNull();
    expect(userAchievements?.length).toBe(1);
    expect(userAchievements?.[0].achievement_id).toBe("streak_3");

    // Verify a notification was created
    const { data: notifications, error: nError } = await serviceClient
      .from("notifications")
      .select("*")
      .eq("user_id", userId);
    
    expect(nError).toBeNull();
    expect(notifications?.length).toBe(1);
    expect(notifications?.[0].title).toContain("On a Roll");
  });

  it("should not unlock duplicates if run again", async () => {
    // Run the engine again
    await evaluateAchievements(serviceClient, userId);

    // Verify it's still just 1 achievement
    const { data: userAchievements } = await serviceClient
      .from("user_achievements")
      .select("*")
      .eq("user_id", userId);
    
    expect(userAchievements?.length).toBe(1);

    // Verify no new notifications were created
    const { data: notifications } = await serviceClient
      .from("notifications")
      .select("*")
      .eq("user_id", userId);
    
    expect(notifications?.length).toBe(1);
  });
});
