/* eslint-disable no-console */
export {};
const token = process.env.SUPABASE_ACCESS_TOKEN;
const ref = "cwsqgfvyqkqmgrqdjeoi";

async function inspect() {
  const res = await fetch(`https://api.supabase.com/v1/projects/${ref}/database/query`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      query: "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;",
    }),
  });

  const data = await res.json();
  console.log("Public tables count:", data.length);
  console.log("Tables list:", data.map((r: { table_name: string }) => r.table_name));
}

inspect().catch(console.error);
