/* eslint-disable no-console */
export {};
const token = process.env.SUPABASE_ACCESS_TOKEN;
const ref = "cwsqgfvyqkqmgrqdjeoi";

async function verifyRLS() {
  const query = `
    SELECT 
      c.relname as table_name,
      c.relrowsecurity as rls_enabled,
      c.relforcerowsecurity as rls_forced,
      COUNT(p.polname) as policy_count
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    LEFT JOIN pg_policy p ON p.polrelid = c.oid
    WHERE n.nspname = 'public' AND c.relkind = 'r'
    GROUP BY c.relname, c.relrowsecurity, c.relforcerowsecurity
    ORDER BY c.relname;
  `;

  const res = await fetch(`https://api.supabase.com/v1/projects/${ref}/database/query`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ query }),
  });

  const tables = await res.json();
  console.log("🔒 Row-Level Security Status across all tables:");
  let allEnabled = true;

  for (const t of tables) {
    const status = t.rls_enabled ? "✅ ENABLED" : "❌ DISABLED";
    console.log(`- ${t.table_name.padEnd(28)}: ${status} (${t.policy_count} policies)`);
    if (!t.rls_enabled) allEnabled = false;
  }

  if (allEnabled) {
    console.log("\n🛡️  ALL public tables have Row-Level Security enabled!");
  } else {
    console.warn("\n⚠️  Some tables do NOT have RLS enabled.");
  }
}

verifyRLS().catch(console.error);
