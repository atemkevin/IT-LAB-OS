/* eslint-disable no-console */
import fs from "node:fs";
import path from "node:path";

const token = process.env.SUPABASE_ACCESS_TOKEN;
const ref = "cwsqgfvyqkqmgrqdjeoi";

if (!token) {
  console.error("SUPABASE_ACCESS_TOKEN is missing from environment");
  process.exit(1);
}

const migrationPath = path.resolve(process.cwd(), "supabase/migrations/001_core_schema.sql");
const sql = fs.readFileSync(migrationPath, "utf-8");

async function runMigration() {
  console.log("🚀 Executing 001_core_schema.sql on Supabase project:", ref);
  console.log(`Payload size: ${sql.length} bytes`);

  const response = await fetch(`https://api.supabase.com/v1/projects/${ref}/database/query`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ query: sql }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    console.error(`❌ Migration failed with status ${response.status} (${response.statusText}):`);
    console.error(errorText);
    process.exit(1);
  }

  const result = await response.json();
  console.log("✅ Migration applied successfully!");
  console.log("Response summary:", result);
}

runMigration().catch((err) => {
  console.error("Fatal error during migration:", err);
  process.exit(1);
});
