-- Migration 007: Expand WebContainer Lab Catalog
-- Adds 3 interactive, browser-isolated WebContainer troubleshooting scenarios

-- 1. log-triage
INSERT INTO public.troubleshooting_scenarios (
  slug, title, description, difficulty, skill_id,
  initial_state, allowed_commands, states, transitions, hints,
  root_cause, repair_action, verification, scoring_rules, is_published,
  runner_type, webcontainer_fs
) VALUES (
  'log-triage',
  'Emergency Log Storage Triage',
  'A runaway application logging loop has filled the log volume, causing write alerts. Locate the bloating log, inspect the error pattern, and truncate the offending file.',
  'intermediate',
  (SELECT id FROM public.skills WHERE slug = 'linux-cli' LIMIT 1),
  '"ready"'::jsonb,
  '[]'::jsonb,
  '{}'::jsonb,
  '[]'::jsonb,
  '[
    "Inspect disk usage in the var/log directory using ls -lh var/log or du -sh var/log/*.",
    "Notice that var/log/app-error.log is consuming massive space compared to other logs.",
    "Inspect the last few lines using tail -n 20 var/log/app-error.log to understand what flooded it.",
    "Do not delete critical system files like syslog; only truncate or clear app-error.log.",
    "Use > var/log/app-error.log or truncate -s 0 var/log/app-error.log to empty the file."
  ]'::jsonb,
  'A runaway logging loop in var/log/app-error.log filled the volume.',
  'Locate and truncate var/log/app-error.log to 0 bytes while preserving other system logs.',
  '"app-error.log is truncated below 1KB and system logs remain intact."'::jsonb,
  '{}'::jsonb,
  true,
  'webcontainer',
  '{
    "var": {
      "directory": {
        "log": {
          "directory": {
            "app-error.log": {
              "file": {
                "contents": "[2026-09-18 10:00:01] CRITICAL: DB connection reset by peer in worker thread 4\n[2026-09-18 10:00:02] CRITICAL: Retrying connection attempt 1...\n[2026-09-18 10:00:03] CRITICAL: Retrying connection attempt 2...\n[2026-09-18 10:00:04] CRITICAL: Buffer overflow writing to spooler\n[2026-09-18 10:00:05] CRITICAL: Retrying connection attempt 3...\n[2026-09-18 10:00:06] CRITICAL: Retrying connection attempt 4...\n[2026-09-18 10:00:07] CRITICAL: Emergency dump buffer exhausted\n[2026-09-18 10:00:08] CRITICAL: Retrying connection attempt 5...\n[2026-09-18 10:00:09] CRITICAL: Retrying connection attempt 6...\n[2026-09-18 10:00:10] CRITICAL: Retrying connection attempt 7...\n[2026-09-18 10:00:11] CRITICAL: Retrying connection attempt 8...\n[2026-09-18 10:00:12] CRITICAL: Retrying connection attempt 9...\n[2026-09-18 10:00:13] CRITICAL: Retrying connection attempt 10...\n[2026-09-18 10:00:14] CRITICAL: Retrying connection attempt 11...\n[2026-09-18 10:00:15] CRITICAL: Retrying connection attempt 12...\n[2026-09-18 10:00:16] CRITICAL: Retrying connection attempt 13...\n[2026-09-18 10:00:17] CRITICAL: Retrying connection attempt 14...\n[2026-09-18 10:00:18] CRITICAL: Retrying connection attempt 15...\n[2026-09-18 10:00:19] CRITICAL: Retrying connection attempt 16...\n[2026-09-18 10:00:20] CRITICAL: Retrying connection attempt 17..."
              }
            },
            "syslog": {
              "file": {
                "contents": "Sep 18 09:15:01 host CRON[112]: (root) CMD (test -x /usr/sbin/anacron || { cd / && run-parts --report /etc/cron.daily; })\nSep 18 09:20:00 host kernel: [ 412.192] eth0: link up, 1000Mbps, full-duplex\nSep 18 09:30:12 host systemd[1]: Starting Daily apt download activities...\nSep 18 09:30:15 host systemd[1]: apt-daily.service: Deactivated successfully."
              }
            },
            "auth.log": {
              "file": {
                "contents": "Sep 18 08:45:10 host sshd[401]: Accepted publickey for learner from 192.168.1.50 port 52210 ssh2: ED25519\nSep 18 08:45:10 host sshd[401]: pam_unix(sshd:session): session opened for user learner(uid=1000) by (uid=0)"
              }
            }
          }
        }
      }
    },
    ".verify.js": {
      "file": {
        "contents": "const fs = require(''fs'');\ntry {\n  if (!fs.existsSync(''var/log/app-error.log'')) {\n    const syslogExists = fs.existsSync(''var/log/syslog'');\n    console.log(JSON.stringify({ passed: syslogExists, rootCauseIdentified: true }));\n  } else {\n    const stats = fs.statSync(''var/log/app-error.log'');\n    const syslogExists = fs.existsSync(''var/log/syslog'');\n    const passed = stats.size < 500 && syslogExists;\n    console.log(JSON.stringify({ passed, rootCauseIdentified: passed }));\n  }\n} catch (e) {\n  console.log(JSON.stringify({ passed: false, rootCauseIdentified: false }));\n}\n"
      }
    }
  }'::jsonb
) ON CONFLICT (slug) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  difficulty = EXCLUDED.difficulty,
  skill_id = EXCLUDED.skill_id,
  initial_state = EXCLUDED.initial_state,
  hints = EXCLUDED.hints,
  root_cause = EXCLUDED.root_cause,
  repair_action = EXCLUDED.repair_action,
  verification = EXCLUDED.verification,
  runner_type = EXCLUDED.runner_type,
  webcontainer_fs = EXCLUDED.webcontainer_fs,
  is_published = true;

-- 2. api-cors-error
INSERT INTO public.troubleshooting_scenarios (
  slug, title, description, difficulty, skill_id,
  initial_state, allowed_commands, states, transitions, hints,
  root_cause, repair_action, verification, scoring_rules, is_published,
  runner_type, webcontainer_fs
) VALUES (
  'api-cors-error',
  'API Gateway CORS Preflight Failure',
  'Frontend clients on https://client.internal-lab.net are receiving CORS errors when calling the API gateway. Inspect server.js, fix the allowed origin configuration, and verify the preflight response.',
  'intermediate',
  (SELECT id FROM public.skills WHERE slug = 'web-security-basics' LIMIT 1),
  '"ready"'::jsonb,
  '[]'::jsonb,
  '{}'::jsonb,
  '[]'::jsonb,
  '[
    "Inspect server.js to examine the HTTP headers being sent on incoming requests.",
    "Look at the Access-Control-Allow-Origin header value currently set in the middleware.",
    "The header is locked to https://wrong-domain.com instead of https://client.internal-lab.net.",
    "Update the origin string in server.js to match https://client.internal-lab.net or wildcard *.",
    "Run node .verify.js to test whether your changes satisfy CORS requirements."
  ]'::jsonb,
  'Access-Control-Allow-Origin is set to https://wrong-domain.com instead of https://client.internal-lab.net.',
  'Update server.js so Access-Control-Allow-Origin matches https://client.internal-lab.net or wildcard *.',
  '"Preflight requests permit origin https://client.internal-lab.net."'::jsonb,
  '{}'::jsonb,
  true,
  'webcontainer',
  '{
    "package.json": {
      "file": {
        "contents": "{\n  \"name\": \"api-gateway\",\n  \"version\": \"1.0.0\",\n  \"main\": \"server.js\"\n}"
      }
    },
    "server.js": {
      "file": {
        "contents": "const http = require(''http'');\n\nconst server = http.createServer((req, res) => {\n  // BUG: Disallowing client.internal-lab.net\n  res.setHeader(''Access-Control-Allow-Origin'', ''https://wrong-domain.com'');\n  res.setHeader(''Access-Control-Allow-Methods'', ''GET, POST, OPTIONS'');\n  res.setHeader(''Access-Control-Allow-Headers'', ''Content-Type, Authorization'');\n\n  if (req.method === ''OPTIONS'') {\n    res.writeHead(204);\n    return res.end();\n  }\n\n  if (req.url === ''/api/v1/user'') {\n    res.writeHead(200, { ''Content-Type'': ''application/json'' });\n    return res.end(JSON.stringify({ id: 1, role: ''engineer'' }));\n  }\n\n  res.writeHead(404);\n  res.end();\n});\n\nif (require.main === module) {\n  server.listen(4000, () => console.log(''Gateway listening on port 4000''));\n}\n\nmodule.exports = server;\n"
      }
    },
    ".verify.js": {
      "file": {
        "contents": "const fs = require(''fs'');\ntry {\n  const code = fs.readFileSync(''server.js'', ''utf8'');\n  const hasCorrectOrigin = code.includes(''https://client.internal-lab.net'') || code.includes(''*'');\n  const notWrongDomainOnly = !code.includes(\"''Access-Control-Allow-Origin'', ''https://wrong-domain.com''\");\n  const passed = Boolean(hasCorrectOrigin && notWrongDomainOnly);\n  console.log(JSON.stringify({ passed, rootCauseIdentified: passed }));\n} catch (e) {\n  console.log(JSON.stringify({ passed: false, rootCauseIdentified: false }));\n}\n"
      }
    }
  }'::jsonb
) ON CONFLICT (slug) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  difficulty = EXCLUDED.difficulty,
  skill_id = EXCLUDED.skill_id,
  initial_state = EXCLUDED.initial_state,
  hints = EXCLUDED.hints,
  root_cause = EXCLUDED.root_cause,
  repair_action = EXCLUDED.repair_action,
  verification = EXCLUDED.verification,
  runner_type = EXCLUDED.runner_type,
  webcontainer_fs = EXCLUDED.webcontainer_fs,
  is_published = true;

-- 3. env-config-crash
INSERT INTO public.troubleshooting_scenarios (
  slug, title, description, difficulty, skill_id,
  initial_state, allowed_commands, states, transitions, hints,
  root_cause, repair_action, verification, scoring_rules, is_published,
  runner_type, webcontainer_fs
) VALUES (
  'env-config-crash',
  'Database Environment Config Failure',
  'A microservice crashes immediately upon boot due to invalid database parameters in .env. Review .env.example, identify the malformed variable, and restore clean startup.',
  'beginner',
  (SELECT id FROM public.skills WHERE slug = 'docker-basics' LIMIT 1),
  '"ready"'::jsonb,
  '[]'::jsonb,
  '{}'::jsonb,
  '[]'::jsonb,
  '[
    "Run node index.js to observe the exact error message on boot.",
    "Notice the error output: either missing DB_HOST or invalid DB_PORT.",
    "Compare .env with .env.example to inspect variable names and formatting.",
    "Fix the DB_HOST variable name (correct any typo) and ensure DB_PORT is a valid number like 5432.",
    "Run node index.js again to confirm successful database connection."
  ]'::jsonb,
  'In .env, DB_HOST has a typo (DB_HOSTT) and DB_PORT is set to non-numeric string "default".',
  'Correct .env so DB_HOST=localhost and DB_PORT=5432.',
  '"node index.js starts and connects to database at localhost:5432."'::jsonb,
  '{}'::jsonb,
  true,
  'webcontainer',
  '{
    ".env.example": {
      "file": {
        "contents": "DB_HOST=localhost\nDB_PORT=5432\nDB_NAME=production_db\n"
      }
    },
    ".env": {
      "file": {
        "contents": "DB_HOSTT=localhost\nDB_PORT=default\nDB_NAME=production_db\n"
      }
    },
    "index.js": {
      "file": {
        "contents": "const fs = require(''fs'');\n\nfunction loadEnv() {\n  const env = {};\n  if (fs.existsSync(''.env'')) {\n    const lines = fs.readFileSync(''.env'', ''utf8'').split(''\\n'');\n    for (const line of lines) {\n      const match = line.match(/^\\s*([\\w.-]+)\\s*=\\s*(.*)?\\s*$/);\n      if (match) {\n        env[match[1]] = (match[2] || '''').trim();\n      }\n    }\n  }\n  return env;\n}\n\nconst env = loadEnv();\nconst host = env.DB_HOST;\nconst port = parseInt(env.DB_PORT, 10);\n\nif (!host) {\n  console.error(''Fatal: Missing DB_HOST in configuration (check spelling)'');\n  process.exit(1);\n}\n\nif (isNaN(port) || port <= 0) {\n  console.error(`Fatal: Invalid DB_PORT: \"${env.DB_PORT}\". Must be a valid positive number.`);\n  process.exit(1);\n}\n\nconsole.log(`Connected to database at ${host}:${port}`);\n"
      }
    },
    ".verify.js": {
      "file": {
        "contents": "const { execSync } = require(''child_process'');\ntry {\n  const out = execSync(''node index.js'', { encoding: ''utf8'' });\n  const passed = out.includes(''Connected to database'') && out.includes(''5432'');\n  console.log(JSON.stringify({ passed, rootCauseIdentified: passed }));\n} catch (e) {\n  console.log(JSON.stringify({ passed: false, rootCauseIdentified: false }));\n}\n"
      }
    }
  }'::jsonb
) ON CONFLICT (slug) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  difficulty = EXCLUDED.difficulty,
  skill_id = EXCLUDED.skill_id,
  initial_state = EXCLUDED.initial_state,
  hints = EXCLUDED.hints,
  root_cause = EXCLUDED.root_cause,
  repair_action = EXCLUDED.repair_action,
  verification = EXCLUDED.verification,
  runner_type = EXCLUDED.runner_type,
  webcontainer_fs = EXCLUDED.webcontainer_fs,
  is_published = true;
