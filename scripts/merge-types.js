/* eslint-disable no-console */
/**
 * scripts/merge-types.js
 *
 * Merges the auto-generated Supabase schema types with this project's
 * hand-maintained type aliases.
 *
 * Inputs:
 *   lib/database.types.ts.gen   — output of `supabase gen types typescript`
 *   scripts/db-type-aliases.txt — the project's enums + Row aliases
 *
 * Output:
 *   lib/database.types.ts       — generated schema + aliases, in that order
 *
 * Why: `supabase gen types` overwrites the whole file, so hand-written
 * aliases must live outside it and be re-appended on every regeneration.
 * Keeping the fragment in its own file means regeneration can never
 * silently drop the enums again.
 */
const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const generatedPath = path.join(root, "lib/database.types.ts.gen");
const fragmentPath = path.join(root, "scripts/db-type-aliases.txt");
const outPath = path.join(root, "lib/database.types.ts");

const generated = fs.readFileSync(generatedPath, "utf8");
const fragment = fs.readFileSync(fragmentPath, "utf8").trim();

// The generated file ends with `export const Constants = { ... } as const`.
const endMarker = "} as const";
const endIdx = generated.lastIndexOf(endMarker);
if (endIdx === -1) throw new Error("Cannot find end marker in generated types");

const prefix = generated.slice(0, endIdx + endMarker.length);
const merged = `${prefix}\n\n${fragment}\n`;

// Guard against the regression that prompted this rewrite.
for (const required of [
  "export type MasteryState",
  "export type Difficulty",
  "export type Note",
  "export type AIMessage",
]) {
  if (!merged.includes(required)) {
    throw new Error(`Merge would drop required declaration: ${required}`);
  }
}

fs.writeFileSync(outPath, merged);
console.log(`Merged types -> lib/database.types.ts (${merged.length} bytes)`);
