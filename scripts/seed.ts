/* eslint-disable no-console */
import fs from "node:fs";
import path from "node:path";
import { createClient } from "@supabase/supabase-js";
import type { Database } from "../lib/database.types";

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !serviceRoleKey) {
  console.error("Missing NEXT_PUBLIC_SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY in environment");
  process.exit(1);
}

const supabase = createClient<Database>(supabaseUrl, serviceRoleKey, {
  auth: { autoRefreshToken: false, persistSession: false },
});

const curriculumPath = path.resolve(
  process.cwd(),
  "IT_Lab_OS_Antigravity_Build_Package_v2/content/CURRICULUM.json",
);
const scenariosPath = path.resolve(
  process.cwd(),
  "IT_Lab_OS_Antigravity_Build_Package_v2/content/troubleshooting/scenarios.json",
);

const curriculumData = JSON.parse(fs.readFileSync(curriculumPath, "utf-8"));
const scenariosData = JSON.parse(fs.readFileSync(scenariosPath, "utf-8"));

async function seed() {
  console.log("🌱 Starting IT Lab OS database seeding...");

  // 1. Seed Domains
  console.log(`Seeding ${curriculumData.domains.length} curriculum domains...`);
  const domainMap = new Map<string, string>(); // slug -> id

  for (const domain of curriculumData.domains) {
    const { data, error } = await supabase
      .from("domains")
      .upsert(
        {
          slug: domain.slug,
          name: domain.name,
          sort_order: domain.sortOrder,
          is_published: true,
        },
        { onConflict: "slug" },
      )
      .select("id, slug")
      .single();

    if (error) {
      console.error(`Error inserting domain ${domain.slug}:`, error.message);
    } else if (data) {
      domainMap.set(data.slug, data.id);
    }
  }
  console.log(`✓ Domains seeded. Total registered: ${domainMap.size}`);

  // 2. Seed Skills
  console.log(`Seeding ${curriculumData.starterSkills.length} starter skills...`);
  let skillCount = 0;

  for (let i = 0; i < curriculumData.starterSkills.length; i++) {
    const skill = curriculumData.starterSkills[i];
    const domainId = domainMap.get(skill.domain);

    if (!domainId) {
      console.warn(`Domain ${skill.domain} not found for skill ${skill.slug}`);
      continue;
    }

    const { error } = await supabase
      .from("skills")
      .upsert(
        {
          domain_id: domainId,
          slug: skill.slug,
          name: skill.name,
          difficulty: skill.difficulty as "beginner" | "intermediate" | "advanced",
          estimated_minutes: skill.estimatedMinutes,
          sort_order: i + 1,
          is_published: true,
        },
        { onConflict: "slug" },
      );

    if (error) {
      console.error(`Error inserting skill ${skill.slug}:`, error.message);
    } else {
      skillCount++;
    }
  }
  console.log(`✓ Starter skills seeded: ${skillCount}`);

  // 3. Seed Troubleshooting Scenarios
  console.log(`Seeding ${scenariosData.length} troubleshooting scenarios...`);
  let scenarioCount = 0;

  for (const scenario of scenariosData) {
    const { error } = await supabase
      .from("troubleshooting_scenarios")
      .upsert(
        {
          slug: scenario.slug,
          title: scenario.title,
          difficulty: scenario.difficulty as "beginner" | "intermediate" | "advanced",
          initial_state: scenario.initialState,
          allowed_commands: scenario.allowedCommands,
          root_cause: scenario.rootCause,
          repair_action: scenario.repairAction,
          verification: { description: scenario.verification },
          states: {},
          transitions: {},
          hints: [],
          scoring_rules: {},
          is_published: true,
        },
        { onConflict: "slug" },
      );

    if (error) {
      console.error(`Error inserting scenario ${scenario.slug}:`, error.message);
    } else {
      scenarioCount++;
    }
  }
  console.log(`✓ Troubleshooting scenarios seeded: ${scenarioCount}`);
  console.log("🎉 Seeding complete!");
}

seed().catch((err) => {
  console.error("Fatal seeding error:", err);
  process.exit(1);
});
