-- 013_complete_remaining_skills.sql

-- Skill: dns
WITH s AS (SELECT id FROM public.skills WHERE slug = 'dns')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'dns-records-and-troubleshooting', 'DNS Record Types & Troubleshooting Workflow', 'Deep dive into CNAME, MX, TXT, SOA records, TTL, and cache poisoning defenses.', '# DNS Record Types & Troubleshooting Workflow

DNS records tell client resolvers how to reach services and verify domain authority.

## Critical DNS Record Types

- **CNAME (Canonical Name)**: An alias pointing one hostname to another canonical hostname (e.g. `www.example.com -> example.com`).
  > **RFC Rule**: A CNAME record cannot coexist with any other record type for the same name, which is why root apex domains (`example.com`) typically cannot use CNAME (use ALIAS or ANAME instead).
- **MX (Mail Exchanger)**: Specifies mail servers with preference numbers (lower numbers = higher priority).
- **TXT (Text)**: Holds machine-readable data:
  - **SPF (Sender Policy Framework)**: `v=spf1 include:_spf.google.com ~all`
  - **DKIM & DMARC**: Cryptographic email authentication policies.
- **SOA (Start of Authority)**: Contains primary nameserver, admin email, serial number, and refresh/expire timers.

## Time-to-Live (TTL) & Caching

Resolvers cache DNS responses for the duration specified by the record''s **TTL (Time to Live)** in seconds.
- **High TTL (86400 = 24 hrs)**: Reduces DNS query traffic; slow to propagate changes.
- **Low TTL (300 = 5 mins)**: Enables rapid IP failover during migrations or incidents.

## Enterprise DNS Troubleshooting

```bash
# Query specific record type
dig example.com MX +short

# Verify authoritative nameservers
dig example.com NS +noall +answer

# Clear local systemd-resolved DNS cache
sudo resolvectl flush-caches
```', 'beginner', 25, 2, true
FROM s ON CONFLICT (skill_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  summary = EXCLUDED.summary,
  content_markdown = EXCLUDED.content_markdown,
  difficulty = EXCLUDED.difficulty,
  estimated_minutes = EXCLUDED.estimated_minutes,
  sort_order = EXCLUDED.sort_order;

DO $$
DECLARE
  v_skill_id UUID;
  v_q_id UUID;
BEGIN
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'dns';
  IF v_skill_id IS NOT NULL THEN
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Which DNS record type specifies mail servers responsible for accepting incoming email on behalf of a domain?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Which DNS record type specifies mail servers responsible for accepting incoming email on behalf of a domain?', 'single', 'MX (Mail Exchanger) records direct email to the responsible receiving mail servers for the domain.', 1, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'A Record', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'MX Record', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'PTR Record', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'CNAME Record', false, 4);
    END IF;
  END IF;
END $$;

DO $$
DECLARE
  v_skill_id UUID;
  v_q_id UUID;
BEGIN
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'dns';
  IF v_skill_id IS NOT NULL THEN
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'What happens when a DNS record has a TTL of 300 seconds?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'What happens when a DNS record has a TTL of 300 seconds?', 'single', 'Resolvers will cache the DNS response for at most 300 seconds (5 minutes) before re-querying authoritative nameservers.', 2, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'The domain expires in 300 seconds', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Resolvers cache the answer for 5 minutes before querying again', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'The DNS server shuts down after 300 requests', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Queries time out after 300 milliseconds', false, 4);
    END IF;
  END IF;
END $$;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'dns')
INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published, evidence_keys)
SELECT s.id, 'Diagnose Domain Resolution with dig and host', 'Query A, CNAME, and MX records and inspect TTL values.', 'Troubleshoot a reported website and email delivery failure.',
  '["Run dig to inspect A and MX records","Inspect TTL values on responses"]'::jsonb, '["DNS records extracted","TTL examined"]'::jsonb, '["dig @nameserver queries a specific DNS server directly"]'::jsonb, true,
  '["req_1", "req_2"]'::jsonb
FROM s
WHERE NOT EXISTS (
  SELECT 1 FROM public.practice_tasks pt WHERE pt.skill_id = s.id AND pt.title = 'Diagnose Domain Resolution with dig and host'
);

-- Skill: docker-basics
WITH s AS (SELECT id FROM public.skills WHERE slug = 'docker-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'dockerfiles-and-images', 'Building Production Docker Images & Multi-Stage Builds', 'Write optimized Dockerfiles, layer caching, and multi-stage builds.', '# Building Production Docker Images & Multi-Stage Builds

A **Dockerfile** is a text script containing instructions to assemble a container image layer by layer.

## Best Practices for Dockerfiles

1. **Use Minimal Base Images**: Choose `alpine` or `distroless` rather than full Ubuntu/Debian images to reduce vulnerabilities and image size.
2. **Order Matters for Layer Caching**: Place commands that change rarely (e.g. `COPY package*.json`, `RUN npm install`) before commands that change frequently (`COPY . .`).
3. **Never Run as Root**: Create an unprivileged user (`USER node` or `USER 1001`).

## Multi-Stage Build Pattern

Multi-stage builds separate the compile-time dependencies from the final lightweight production image:

```dockerfile
# Stage 1: Build & compile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Production runtime (no dev tools or raw source)
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
RUN addgroup --system --gid 1001 nodejs && adduser --system --uid 1001 nextjs
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/public ./public
USER nextjs
EXPOSE 3000
CMD ["node", "server.js"]
```

## Managing Images & Pruning

```bash
# Build an image with a tag
docker build -t my-app:v1.0 .

# Remove dangling unused images and build cache
docker system prune -af
```', 'beginner', 30, 2, true
FROM s ON CONFLICT (skill_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  summary = EXCLUDED.summary,
  content_markdown = EXCLUDED.content_markdown,
  difficulty = EXCLUDED.difficulty,
  estimated_minutes = EXCLUDED.estimated_minutes,
  sort_order = EXCLUDED.sort_order;

DO $$
DECLARE
  v_skill_id UUID;
  v_q_id UUID;
BEGIN
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'docker-basics';
  IF v_skill_id IS NOT NULL THEN
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'What is the primary benefit of using Multi-Stage Builds in Dockerfiles?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'What is the primary benefit of using Multi-Stage Builds in Dockerfiles?', 'single', 'Multi-stage builds allow you to compile code in a heavy build stage and copy only the final binary to an ultra-lightweight, secure runtime image.', 1, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It allows containers to run without Docker installed', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It produces significantly smaller, more secure production images by excluding build tools', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It speeds up container CPU execution by 10x', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It bypasses Linux kernel cgroups', false, 4);
    END IF;
  END IF;
END $$;

DO $$
DECLARE
  v_skill_id UUID;
  v_q_id UUID;
BEGIN
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'docker-basics';
  IF v_skill_id IS NOT NULL THEN
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Why should you COPY package.json and run npm install before copying the rest of your application code in a Dockerfile?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Why should you COPY package.json and run npm install before copying the rest of your application code in a Dockerfile?', 'single', 'Docker caches layers sequentially. If application code changes but package.json does not, Docker reuses the cached npm install layer, speeding up builds.', 2, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Docker will crash if package.json is copied later', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'To leverage Docker layer caching and avoid re-downloading dependencies on every code edit', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'npm requires root access', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Because Linux cannot read JSON files after source files', false, 4);
    END IF;
  END IF;
END $$;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'docker-basics')
INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published, evidence_keys)
SELECT s.id, 'Build and Run a Containerized Web Application', 'Build a Docker container, map host ports, and inspect running container health.', 'Package a static web application into a Docker container and run it on port 8080.',
  '["Inspect container runtime state with docker ps","Verify mapped port access"]'::jsonb, '["Container running state verified","Port mapping verified"]'::jsonb, '["docker run -d runs containers in detached background mode","-p host:container maps ports"]'::jsonb, true,
  '["req_1", "req_2"]'::jsonb
FROM s
WHERE NOT EXISTS (
  SELECT 1 FROM public.practice_tasks pt WHERE pt.skill_id = s.id AND pt.title = 'Build and Run a Containerized Web Application'
);

-- Skill: subnetting
WITH s AS (SELECT id FROM public.skills WHERE slug = 'subnetting')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'vlsm-and-subnet-design', 'Variable Length Subnet Masking (VLSM) & Network Planning', 'Design optimal address schemes without wasted IP addresses using VLSM.', '# Variable Length Subnet Masking (VLSM) & Network Planning

Classful subnetting allocated identical subnet sizes regardless of need, leading to massive IPv4 address exhaustion. **Variable Length Subnet Masking (VLSM)** allocates subnets sized specifically to the number of hosts required.

## VLSM Design Steps

Always allocate subnets **from largest host requirement to smallest**:

Suppose an organization is assigned `192.168.10.0/24` (256 addresses) and needs:
1. **Engineering**: 60 hosts
2. **Sales**: 25 hosts
3. **Management**: 10 hosts
4. **Router WAN Links**: 2 point-to-point links (2 hosts each)

### Allocation Breakdown:

1. **Engineering (60 hosts)**:
   - Next power of 2: $2^6 = 64$ ($64 - 2 = 62$ usable). Prefix: **/26**.
   - Subnet: `192.168.10.0/26` (Range: `.0` to `.63`, Usable: `.1` to `.62`).
2. **Sales (25 hosts)**:
   - Next power of 2: $2^5 = 32$ ($32 - 2 = 30$ usable). Prefix: **/27**.
   - Subnet: `192.168.10.64/27` (Range: `.64` to `.95`, Usable: `.65` to `.94`).
3. **Management (10 hosts)**:
   - Next power of 2: $2^4 = 16$ ($16 - 2 = 14$ usable). Prefix: **/28**.
   - Subnet: `192.168.10.96/28` (Range: `.96` to `.111`, Usable: `.97` to `.110`).
4. **WAN Link 1 (2 hosts)**:
   - Next power of 2: $2^2 = 4$ ($4 - 2 = 2$ usable). Prefix: **/30**.
   - Subnet: `192.168.10.112/30` (Range: `.112` to `.115`, Usable: `.113`, `.114`).
5. **WAN Link 2 (2 hosts)**:
   - Prefix: **/30**.
   - Subnet: `192.168.10.116/30` (Range: `.116` to `.119`, Usable: `.117`, `.118`).

## Address Planning Rule of Thumb
- Never assign the **Network ID** (first address) or **Broadcast Address** (last address) to an endpoint host interface.
```', 'beginner', 30, 2, true
FROM s ON CONFLICT (skill_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  summary = EXCLUDED.summary,
  content_markdown = EXCLUDED.content_markdown,
  difficulty = EXCLUDED.difficulty,
  estimated_minutes = EXCLUDED.estimated_minutes,
  sort_order = EXCLUDED.sort_order;

DO $$
DECLARE
  v_skill_id UUID;
  v_q_id UUID;
BEGIN
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'subnetting';
  IF v_skill_id IS NOT NULL THEN
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Which subnet mask prefix is optimal for a point-to-point router link that requires exactly 2 usable host IP addresses?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Which subnet mask prefix is optimal for a point-to-point router link that requires exactly 2 usable host IP addresses?', 'single', 'A /30 prefix provides 4 total addresses: 1 network ID, 2 usable host IPs, and 1 broadcast address, with zero wasted IPs.', 1, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '/28', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '/30', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '/31', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '/24', false, 4);
    END IF;
  END IF;
END $$;

DO $$
DECLARE
  v_skill_id UUID;
  v_q_id UUID;
BEGIN
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'subnetting';
  IF v_skill_id IS NOT NULL THEN
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'In VLSM network planning, in what order should subnets be allocated from a parent IP block?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'In VLSM network planning, in what order should subnets be allocated from a parent IP block?', 'single', 'Subnets must always be allocated starting from the largest host requirement down to the smallest to prevent address fragmentation.', 2, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Randomly', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Smallest requirement first', false, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Largest requirement first', true, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Alphabetical by department name', false, 4);
    END IF;
  END IF;
END $$;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'subnetting')
INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published, evidence_keys)
SELECT s.id, 'Calculate VLSM Subnet Boundaries', 'Calculate valid network, broadcast, and host range boundaries for multiple subnets.', 'Plan an IPv4 addressing layout for three department subnets.',
  '["Determine subnet mask and CIDR for 50 hosts","Calculate broadcast address and usable host range"]'::jsonb, '["Usable range and broadcast address calculated correctly"]'::jsonb, '["A subnet for 50 hosts requires at least 64 addresses (/26)"]'::jsonb, true,
  '["req_1", "req_2"]'::jsonb
FROM s
WHERE NOT EXISTS (
  SELECT 1 FROM public.practice_tasks pt WHERE pt.skill_id = s.id AND pt.title = 'Calculate VLSM Subnet Boundaries'
);

-- Skill: ip-addressing
WITH s AS (SELECT id FROM public.skills WHERE slug = 'ip-addressing')
INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published, evidence_keys)
SELECT s.id, 'Configure and Verify Network IP Addressing', 'Inspect interface IP configuration, verify gateway reachability, and inspect subnet masks.', 'Verify the IP address and network mask configuration on an enterprise workstation.',
  '["Run ip -br addr to display IP addresses and CIDR notation","Test default gateway reachability using ping -c 3"]'::jsonb, '["IP configuration verified","Gateway connectivity validated"]'::jsonb, '["ip -br addr prints compact interface and IP address lists"]'::jsonb, true,
  '["req_1", "req_2"]'::jsonb
FROM s
WHERE NOT EXISTS (
  SELECT 1 FROM public.practice_tasks pt WHERE pt.skill_id = s.id AND pt.title = 'Configure and Verify Network IP Addressing'
);

