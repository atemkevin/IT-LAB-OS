import { describe, it, expect } from "vitest";
import { createClient } from "@supabase/supabase-js";
import type { Database } from "@/lib/database.types";

const url = process.env.NEXT_PUBLIC_SUPABASE_URL || "https://cwsqgfvyqkqmgrqdjeoi.supabase.co";
const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN3c3FnZnZ5cWtxbWdycWRqZW9pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk0NTExNzYsImV4cCI6MjEwNTAyNzE3Nn0.nBdEuHICmXmvBCUZiqIgjK4vnLA4EKuNXYZ4T08zKWI";
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY || "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN3c3FnZnZ5cWtxbWdycWRqZW9pIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4OTQ1MTE3NiwiZXhwIjoyMTA1MDI3MTc2fQ.b77huc0BWekluVXwwPbyPAesZ-0WcF7xY8fN3k4v8Ps";

describe("Database & RLS Integration Verification (Phase 2)", () => {
  it("allows anonymous clients to read published domains", async () => {
    const anon = createClient<Database>(url, anonKey);
    const { data, error } = await anon
      .from("domains")
      .select("slug, name, sort_order")
      .order("sort_order", { ascending: true });

    expect(error).toBeNull();
    expect(data).toBeDefined();
    expect(data!.length).toBe(12);
    expect(data![0].slug).toBe("computer-fundamentals");
    expect(data![11].slug).toBe("specialization");
  });

  it("allows anonymous clients to read published skills", async () => {
    const anon = createClient<Database>(url, anonKey);
    const { data, error } = await anon
      .from("skills")
      .select("slug, name, difficulty")
      .order("sort_order", { ascending: true });

    expect(error).toBeNull();
    expect(data).toBeDefined();
    expect(data!.length).toBe(26);
  });

  it("allows anonymous clients to read published troubleshooting scenarios", async () => {
    const anon = createClient<Database>(url, anonKey);
    const { data, error } = await anon
      .from("troubleshooting_scenarios")
      .select("slug, title, difficulty");

    expect(error).toBeNull();
    expect(data).toBeDefined();
    expect(data!.length).toBe(5);
  });

  it("enforces RLS: anonymous clients receive empty result from quiz_options", async () => {
    // quiz_options has NO SELECT policy for regular users/anon
    const anon = createClient<Database>(url, anonKey);
    const { data, error } = await anon.from("quiz_options").select("*");

    expect(error).toBeNull();
    expect(data).toEqual([]); // Empty array due to RLS blocking unauthorized reads
  });

  it("service role client has administrative access across tables", async () => {
    const admin = createClient<Database>(url, serviceRoleKey);
    const { count, error } = await admin
      .from("domains")
      .select("*", { count: "exact", head: true });

    expect(error).toBeNull();
    expect(count).toBeGreaterThanOrEqual(12);
  });
});
