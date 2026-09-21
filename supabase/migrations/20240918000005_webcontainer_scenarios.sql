-- Migration 006: Add webcontainer_fs to scenarios
-- This schema update allows troubleshooting scenarios to define a WebContainer filesystem

ALTER TABLE public.troubleshooting_scenarios
ADD COLUMN IF NOT EXISTS webcontainer_fs jsonb,
ADD COLUMN IF NOT EXISTS runner_type text DEFAULT 'deterministic' CHECK (runner_type IN ('deterministic', 'webcontainer'));

-- Insert a Node server crash scenario that uses WebContainer
INSERT INTO public.troubleshooting_scenarios (
  slug, title, description, difficulty, skill_id,
  initial_state, allowed_commands, states, transitions, hints,
  root_cause, repair_action, verification, scoring_rules, is_published,
  runner_type, webcontainer_fs
) VALUES (
  'node-crash',
  'Node.js Server Crash',
  'An Express application is crashing on startup due to a typo in the server configuration. Use the terminal to inspect the files, find the error, and verify the server starts.',
  'intermediate',
  (select id from public.skills where slug = 'linux-cli' limit 1),
  '"crash"'::jsonb,
  '[]'::jsonb,
  '{}'::jsonb,
  '[]'::jsonb,
  '[
    "Run node server.js to see the crash error.",
    "Look at the error trace carefully; it points to a specific line in server.js.",
    "Use nano or vi to edit server.js.",
    "The port variable is misspelled as ''potr''.",
    "Change ''potr'' to ''port'' and save the file."
  ]'::jsonb,
  'A typo in the server configuration (potr instead of port).',
  'Edit server.js to fix the typo so the server can listen correctly.',
  '"node server.js starts successfully."'::jsonb,
  '{}'::jsonb,
  true,
  'webcontainer',
  '{
    "package.json": {
      "file": {
        "contents": "{\n  \"name\": \"crash-app\",\n  \"dependencies\": {\n    \"express\": \"^4.18.2\"\n  }\n}"
      }
    },
    "server.js": {
      "file": {
        "contents": "const express = require(''express'');\nconst app = express();\n\nconst port = 3000;\n\napp.get(''/'', (req, res) => {\n  res.send(''Hello World'');\n});\n\n// Typo here:\napp.listen(potr, () => {\n  console.log(`Server listening on port ${port}`);\n});\n"
      }
    },
    ".verify.js": {
      "file": {
        "contents": "const fs = require(''fs'');\nconst content = fs.readFileSync(''server.js'', ''utf8'');\nif (content.includes(''app.listen(port'')) {\n  console.log(JSON.stringify({ passed: true, rootCauseIdentified: true }));\n} else {\n  console.log(JSON.stringify({ passed: false, rootCauseIdentified: false }));\n}\n"
      }
    }
  }'::jsonb
) ON CONFLICT (slug) DO UPDATE SET 
  runner_type = EXCLUDED.runner_type,
  webcontainer_fs = EXCLUDED.webcontainer_fs;
