/* eslint-disable no-console */
export {};
const token = process.env.SUPABASE_ACCESS_TOKEN;
const ref = "cwsqgfvyqkqmgrqdjeoi";

async function query(sql: string) {
  const res = await fetch(`https://api.supabase.com/v1/projects/${ref}/database/query`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ query: sql }),
  });
  if (!res.ok) {
    throw new Error(`Query failed: ${res.statusText} - ${await res.text()}`);
  }
  return res.json();
}

async function verify() {
  console.log("🔍 === Comprehensive Database Verification ===");

  // 1. Tables
  const tables = await query(`
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    ORDER BY table_name;
  `);
  console.log(`\n1. Tables (${tables.length} found):`);
  console.log(tables.map((t: { table_name: string }) => t.table_name).join(", "));

  // 2. Enums / Check constraints
  const checks = await query(`
    SELECT conname, relname, pg_get_constraintdef(c.oid) as def
    FROM pg_constraint c
    JOIN pg_class r ON r.oid = c.conrelid
    JOIN pg_namespace n ON n.oid = r.relnamespace
    WHERE n.nspname = 'public' AND c.contype = 'c'
    ORDER BY relname, conname;
  `);
  console.log(`\n2. Check Constraints (${checks.length} found):`);
  checks.forEach((c: { conname: string; relname: string; def: string }) => {
    console.log(`  - [${c.relname}] ${c.conname}: ${c.def}`);
  });

  // 3. Foreign Keys
  const fks = await query(`
    SELECT
      tc.table_name, 
      kcu.column_name, 
      ccu.table_name AS foreign_table_name,
      ccu.column_name AS foreign_column_name 
    FROM information_schema.table_constraints AS tc 
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
    WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_schema = 'public'
    ORDER BY tc.table_name, kcu.column_name;
  `);
  console.log(`\n3. Foreign Keys (${fks.length} found):`);
  fks.forEach((f: { table_name: string; column_name: string; foreign_table_name: string; foreign_column_name: string }) => {
    console.log(`  - ${f.table_name}.${f.column_name} -> ${f.foreign_table_name}.${f.foreign_column_name}`);
  });

  // 4. Indexes
  const indexes = await query(`
    SELECT tablename, indexname, indexdef
    FROM pg_indexes
    WHERE schemaname = 'public'
    ORDER BY tablename, indexname;
  `);
  console.log(`\n4. Indexes (${indexes.length} found):`);
  indexes.forEach((i: { tablename: string; indexname: string }) => {
    console.log(`  - ${i.tablename}: ${i.indexname}`);
  });

  // 5. Triggers
  const triggers = await query(`
    SELECT event_object_table as table_name, trigger_name, action_timing, event_manipulation
    FROM information_schema.triggers
    WHERE trigger_schema = 'public'
    ORDER BY event_object_table, trigger_name;
  `);
  console.log(`\n5. Triggers (${triggers.length} found):`);
  triggers.forEach((t: { table_name: string; trigger_name: string; action_timing: string; event_manipulation: string }) => {
    console.log(`  - [${t.table_name}] ${t.trigger_name} (${t.action_timing} ${t.event_manipulation})`);
  });

  // 6. RLS & Policies
  const rls = await query(`
    SELECT 
      c.relname as table_name,
      c.relrowsecurity as rls_enabled,
      COUNT(p.polname) as policy_count
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    LEFT JOIN pg_policy p ON p.polrelid = c.oid
    WHERE n.nspname = 'public' AND c.relkind = 'r'
    GROUP BY c.relname, c.relrowsecurity
    ORDER BY c.relname;
  `);
  console.log(`\n6. RLS & Policies (${rls.length} tables):`);
  const allRls = rls.every((r: { rls_enabled: boolean }) => r.rls_enabled);
  console.log(`  - All tables RLS enabled: ${allRls ? "YES" : "NO"}`);
  console.log(`  - Total policies across public schema: ${rls.reduce((sum: number, r: { policy_count: string }) => sum + parseInt(r.policy_count, 10), 0)}`);

  console.log("\n✅ Database deep verification completed!");
}

verify().catch(console.error);
