-- Migration 003: Curriculum content seed
-- Adds: skill descriptions, prerequisites, lessons, practice tasks, quiz questions
-- Idempotent: uses ON CONFLICT DO NOTHING / DO UPDATE

-- 1. SKILL DESCRIPTIONS & OBJECTIVES

UPDATE public.skills SET
  description = 'Understand the physical and logical components that make up a computer system.',
  why_it_matters = 'Every IT role requires you to understand what is inside the machines you configure, troubleshoot, and secure.',
  learning_objectives = '["Identify CPU, RAM, and storage roles", "Distinguish volatile and non-volatile memory", "Explain the motherboard and bus architecture", "Describe common I/O interfaces (USB, PCIe, SATA)"]'::jsonb
WHERE slug = 'computer-basics';

UPDATE public.skills SET
  description = 'Deep dive into CPU architectures, memory hierarchies, and storage technologies.',
  why_it_matters = 'Performance bottlenecks trace back to CPU, RAM, and storage. Knowing how they interact lets you diagnose slow systems.',
  learning_objectives = '["Explain CPU cores, threads, and clock speed", "Describe L1/L2/L3 cache hierarchy", "Compare HDD, SSD, and NVMe storage", "Interpret top/htop CPU and memory metrics"]'::jsonb
WHERE slug = 'cpu-memory-storage';

UPDATE public.skills SET
  description = 'Learn IPv4 and IPv6 addressing, notation, and practical configuration.',
  why_it_matters = 'IP addressing is the language of networking. You cannot configure routers, firewalls, or cloud VPCs without understanding it.',
  learning_objectives = '["Write and read IPv4 addresses in dotted-decimal", "Explain public vs private address spaces", "Calculate host and network portions of an address", "Configure a static IP on Linux"]'::jsonb
WHERE slug = 'ip-addressing';

UPDATE public.skills SET
  description = 'Navigate the Linux command line with confidence: paths, files, pipes, and redirection.',
  why_it_matters = 'The Linux CLI is the universal control surface of servers, containers, and cloud instances. Every other Linux skill builds on it.',
  learning_objectives = '["Navigate the filesystem with cd, ls, pwd", "Manage files with cp, mv, rm, mkdir", "Read files with cat, less, head, tail", "Chain commands with pipes and redirect output"]'::jsonb
WHERE slug = 'linux-cli';

UPDATE public.skills SET
  description = 'Understand and manage Linux file permissions, ownership, and access control.',
  why_it_matters = 'Misconfigured permissions are one of the most common causes of security breaches and broken deployments.',
  learning_objectives = '["Read rwx permission notation and octal mode", "Change file permissions with chmod", "Change file ownership with chown and chgrp", "Understand setuid, setgid, and sticky bit"]'::jsonb
WHERE slug = 'linux-permissions';

UPDATE public.skills SET
  description = 'Set up and secure SSH connections using key-based authentication.',
  why_it_matters = 'SSH is the primary way engineers access remote servers. Weak SSH configuration is an attacker target.',
  learning_objectives = '["Generate ed25519 key pairs with ssh-keygen", "Copy public keys with ssh-copy-id", "Configure sshd_config for hardened access", "Disable password authentication"]'::jsonb
WHERE slug = 'ssh';

UPDATE public.skills SET
  description = 'Learn Python fundamentals: variables, control flow, functions, and file I/O.',
  why_it_matters = 'Python is the dominant automation language in IT, networking, and security.',
  learning_objectives = '["Write Python scripts with variables and data types", "Use if/else, for, and while control flow", "Define and call functions with parameters", "Read and write files using open()"]'::jsonb
WHERE slug = 'python-basics';

UPDATE public.skills SET
  description = 'Understand core security principles: CIA triad, threats, and controls.',
  why_it_matters = 'Security thinking must permeate every IT decision. Understanding fundamentals helps you identify risks.',
  learning_objectives = '["Explain the CIA triad", "Describe common threat categories", "Apply the principle of least privilege", "Identify differences between authentication and authorization"]'::jsonb
WHERE slug = 'security-fundamentals';

-- 2. SKILL PREREQUISITES

INSERT INTO public.skill_prerequisites (skill_id, prerequisite_skill_id, required_mastery)
SELECT s.id, p.id, 50 FROM public.skills s, public.skills p
WHERE s.slug = 'cpu-memory-storage' AND p.slug = 'computer-basics' ON CONFLICT DO NOTHING;

INSERT INTO public.skill_prerequisites (skill_id, prerequisite_skill_id, required_mastery)
SELECT s.id, p.id, 50 FROM public.skills s, public.skills p
WHERE s.slug = 'subnetting' AND p.slug = 'ip-addressing' ON CONFLICT DO NOTHING;

INSERT INTO public.skill_prerequisites (skill_id, prerequisite_skill_id, required_mastery)
SELECT s.id, p.id, 50 FROM public.skills s, public.skills p
WHERE s.slug = 'dns' AND p.slug = 'ip-addressing' ON CONFLICT DO NOTHING;

INSERT INTO public.skill_prerequisites (skill_id, prerequisite_skill_id, required_mastery)
SELECT s.id, p.id, 50 FROM public.skills s, public.skills p
WHERE s.slug = 'routing' AND p.slug = 'subnetting' ON CONFLICT DO NOTHING;

INSERT INTO public.skill_prerequisites (skill_id, prerequisite_skill_id, required_mastery)
SELECT s.id, p.id, 50 FROM public.skills s, public.skills p
WHERE s.slug = 'linux-permissions' AND p.slug = 'linux-cli' ON CONFLICT DO NOTHING;

INSERT INTO public.skill_prerequisites (skill_id, prerequisite_skill_id, required_mastery)
SELECT s.id, p.id, 50 FROM public.skills s, public.skills p
WHERE s.slug = 'linux-networking' AND p.slug = 'linux-cli' ON CONFLICT DO NOTHING;

INSERT INTO public.skill_prerequisites (skill_id, prerequisite_skill_id, required_mastery)
SELECT s.id, p.id, 50 FROM public.skills s, public.skills p
WHERE s.slug = 'linux-networking' AND p.slug = 'ip-addressing' ON CONFLICT DO NOTHING;

INSERT INTO public.skill_prerequisites (skill_id, prerequisite_skill_id, required_mastery)
SELECT s.id, p.id, 50 FROM public.skills s, public.skills p
WHERE s.slug = 'ssh' AND p.slug = 'linux-cli' ON CONFLICT DO NOTHING;

INSERT INTO public.skill_prerequisites (skill_id, prerequisite_skill_id, required_mastery)
SELECT s.id, p.id, 50 FROM public.skills s, public.skills p
WHERE s.slug = 'api-basics' AND p.slug = 'python-basics' ON CONFLICT DO NOTHING;

INSERT INTO public.skill_prerequisites (skill_id, prerequisite_skill_id, required_mastery)
SELECT s.id, p.id, 50 FROM public.skills s, public.skills p
WHERE s.slug = 'authentication-authorization' AND p.slug = 'security-fundamentals' ON CONFLICT DO NOTHING;

INSERT INTO public.skill_prerequisites (skill_id, prerequisite_skill_id, required_mastery)
SELECT s.id, p.id, 50 FROM public.skills s, public.skills p
WHERE s.slug = 'web-security-basics' AND p.slug = 'authentication-authorization' ON CONFLICT DO NOTHING;

INSERT INTO public.skill_prerequisites (skill_id, prerequisite_skill_id, required_mastery)
SELECT s.id, p.id, 50 FROM public.skills s, public.skills p
WHERE s.slug = 'docker-basics' AND p.slug = 'linux-cli' ON CONFLICT DO NOTHING;

INSERT INTO public.skill_prerequisites (skill_id, prerequisite_skill_id, required_mastery)
SELECT s.id, p.id, 50 FROM public.skills s, public.skills p
WHERE s.slug = 'ci-cd-basics' AND p.slug = 'docker-basics' ON CONFLICT DO NOTHING;

INSERT INTO public.skill_prerequisites (skill_id, prerequisite_skill_id, required_mastery)
SELECT s.id, p.id, 50 FROM public.skills s, public.skills p
WHERE s.slug = 'llm-api-basics' AND p.slug = 'api-basics' ON CONFLICT DO NOTHING;

INSERT INTO public.skill_prerequisites (skill_id, prerequisite_skill_id, required_mastery)
SELECT s.id, p.id, 50 FROM public.skills s, public.skills p
WHERE s.slug = 'ai-agents-basics' AND p.slug = 'llm-api-basics' ON CONFLICT DO NOTHING;

INSERT INTO public.skill_prerequisites (skill_id, prerequisite_skill_id, required_mastery)
SELECT s.id, p.id, 50 FROM public.skills s, public.skills p
WHERE s.slug = 'automation-workflows' AND p.slug = 'api-basics' ON CONFLICT DO NOTHING;

INSERT INTO public.skill_prerequisites (skill_id, prerequisite_skill_id, required_mastery)
SELECT s.id, p.id, 50 FROM public.skills s, public.skills p
WHERE s.slug = 'cloud-fundamentals' AND p.slug = 'ip-addressing' ON CONFLICT DO NOTHING;

-- 3. LESSONS

-- Linux CLI lessons
WITH skill AS (SELECT id FROM public.skills WHERE slug = 'linux-cli')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT skill.id, 'linux-cli-why', 'Why the Linux CLI Matters',
  'Understand why every IT engineer needs the command line.',
  '# Why the Linux CLI Matters

The Linux command-line interface is the universal control surface for servers, containers, cloud instances, and network devices.

## The Shell

The shell reads your commands and executes them. The most common shell is bash.

## Why It Matters for IT

- Network engineers configure routers via CLI
- Security analysts parse logs with grep and awk
- DevOps engineers automate deployments with bash scripts
- AI automation uses Python scripts from the CLI',
  'beginner', 15, 1, true
FROM skill ON CONFLICT (skill_id, slug) DO NOTHING;

WITH skill AS (SELECT id FROM public.skills WHERE slug = 'linux-cli')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT skill.id, 'linux-cli-navigation', 'Navigating the Filesystem',
  'Move around the Linux filesystem using cd, ls, and pwd.',
  '# Navigating the Filesystem

## Key Commands

| Command | What It Does |
|---------|-------------|
| pwd | Print working directory |
| ls | List files |
| ls -la | Long listing with hidden files |
| cd /path | Change to absolute path |
| cd .. | Go up one level |
| cd ~ | Go to home directory |

## The Filesystem Tree

Linux organizes everything under / (root):
- /etc - Configuration files
- /var - Variable data (logs)
- /home - User home directories
- /usr - User programs
- /tmp - Temporary files

## Practice

`ash
pwd
ls -la
cd /etc && ls
cd ~
`',
  'beginner', 20, 2, true
FROM skill ON CONFLICT (skill_id, slug) DO NOTHING;

WITH skill AS (SELECT id FROM public.skills WHERE slug = 'linux-cli')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT skill.id, 'linux-cli-files', 'File Operations',
  'Create, copy, move, and delete files and directories safely.',
  '# File Operations

## Core Commands

`ash
mkdir projects
touch notes.txt
echo "Hello" > hello.txt
cp hello.txt backup.txt
mv hello.txt greeting.txt
rm backup.txt
rm -r projects/
`

## Reading Files

`ash
cat notes.txt
less notes.txt
head -n 5 notes.txt
tail -n 10 notes.txt
tail -f /var/log/syslog
`

## Safety Rule

Never run rm -rf / -- it deletes everything.',
  'beginner', 20, 3, true
FROM skill ON CONFLICT (skill_id, slug) DO NOTHING;

-- Linux Permissions lessons
WITH skill AS (SELECT id FROM public.skills WHERE slug = 'linux-permissions')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT skill.id, 'permissions-model', 'Understanding the Permission Model',
  'Read and interpret Linux file permissions in rwx and octal notation.',
  '# Understanding the Permission Model

## Reading Permissions

`
-rwxr-xr--  1 alice devs 4096 Jan 10 script.sh
`

| Part | Meaning |
|------|---------|
| - | File type |
| rwx | Owner permissions |
| r-x | Group permissions |
| r-- | Other permissions |

## Octal Notation

| Octal | Binary | Permissions |
|-------|--------|-------------|
| 7 | 111 | rwx |
| 6 | 110 | rw- |
| 5 | 101 | r-x |
| 4 | 100 | r-- |

chmod 755 = owner:rwx, group:r-x, other:r-x',
  'beginner', 15, 1, true
FROM skill ON CONFLICT (skill_id, slug) DO NOTHING;

WITH skill AS (SELECT id FROM public.skills WHERE slug = 'linux-permissions')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT skill.id, 'permissions-chmod-chown', 'chmod and chown',
  'Change file permissions and ownership from the command line.',
  '# chmod and chown

## chmod

`ash
chmod u+x script.sh
chmod 755 script.sh
chmod 644 config.txt
chmod 600 private.key
chmod -R 755 /var/www/
`

## chown

`ash
chown alice file.txt
chown alice:devs file.txt
chown -R www-data:www-data /var/www/
`

## Common Permission Values

| File Type | Permission |
|-----------|-----------|
| SSH private key | 600 |
| Web server files | 644 |
| Shell scripts | 755 |
| Config with secrets | 600 |',
  'beginner', 20, 2, true
FROM skill ON CONFLICT (skill_id, slug) DO NOTHING;

-- IP Addressing lessons
WITH skill AS (SELECT id FROM public.skills WHERE slug = 'ip-addressing')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT skill.id, 'ip-addressing-basics', 'IP Addressing Fundamentals',
  'Understand IPv4 addresses and the public vs private distinction.',
  '# IP Addressing Fundamentals

An IP address is a numeric label assigned to every device on a network. IPv4 uses 32-bit addresses as four octets (0-255).

## Public vs Private Addresses

| Range | Description |
|-------|-------------|
| 10.0.0.0/8 | Private (Class A) |
| 172.16.0.0/12 | Private (Class B) |
| 192.168.0.0/16 | Private (Class C) |
| Everything else | Public |

## View and Set IP on Linux

`ash
ip addr show
sudo ip addr add 192.168.1.50/24 dev eth0
`',
  'beginner', 20, 1, true
FROM skill ON CONFLICT (skill_id, slug) DO NOTHING;

WITH skill AS (SELECT id FROM public.skills WHERE slug = 'ip-addressing')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT skill.id, 'ip-addressing-cidr', 'CIDR Notation',
  'Read and write CIDR notation and calculate host ranges.',
  '# CIDR Notation

CIDR uses a prefix length to define the network boundary.

## Common Prefix Lengths

| Prefix | Subnet Mask | Hosts |
|--------|------------|-------|
| /24 | 255.255.255.0 | 254 |
| /25 | 255.255.255.128 | 126 |
| /30 | 255.255.255.252 | 2 |
| /16 | 255.255.0.0 | 65,534 |

## Example: 192.168.1.0/24

- Network: 192.168.1.0
- First host: 192.168.1.1
- Last host: 192.168.1.254
- Broadcast: 192.168.1.255
- Usable hosts: 254',
  'beginner', 20, 2, true
FROM skill ON CONFLICT (skill_id, slug) DO NOTHING;

-- SSH lessons
WITH skill AS (SELECT id FROM public.skills WHERE slug = 'ssh')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT skill.id, 'ssh-key-pairs', 'SSH Key Pairs',
  'Generate ed25519 key pairs and use them for passwordless authentication.',
  '# SSH Key Pairs

## Generating a Key Pair

`ash
ssh-keygen -t ed25519 -C "your@email.com"
`

This creates:
- ~/.ssh/id_ed25519 -- private key (chmod 600)
- ~/.ssh/id_ed25519.pub -- public key

## Installing on a Server

`ash
ssh-copy-id user@server-ip
`

## Connecting

`ash
ssh user@192.168.1.10
ssh -p 2222 user@server
ssh -i ~/.ssh/other_key user@host
`',
  'beginner', 20, 1, true
FROM skill ON CONFLICT (skill_id, slug) DO NOTHING;

WITH skill AS (SELECT id FROM public.skills WHERE slug = 'ssh')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT skill.id, 'ssh-hardening', 'Hardening sshd_config',
  'Configure the SSH daemon for production-grade security.',
  '# Hardening sshd_config

Edit /etc/ssh/sshd_config:

`
PermitRootLogin no
PasswordAuthentication no
AllowUsers alice bob
MaxAuthTries 3
X11Forwarding no
`

## Apply Changes

`ash
sudo sshd -t
sudo systemctl restart sshd
`

Test from another terminal before closing your session.',
  'beginner', 20, 2, true
FROM skill ON CONFLICT (skill_id, slug) DO NOTHING;

-- Python Basics lessons
WITH skill AS (SELECT id FROM public.skills WHERE slug = 'python-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT skill.id, 'python-intro', 'Python for IT Automation',
  'Why Python matters for IT and the core syntax to get started.',
  '# Python for IT Automation

## Your First Script

`python
print("IT Lab OS -- Python is running!")
hostname = "server01"
print(f"Welcome from {hostname}")
`

## Variables and Data Types

`python
port = 22
ip = "192.168.1.10"
is_active = True
servers = ["web01", "db01", "cache01"]
config = {"host": "192.168.1.10", "port": 22}
`',
  'beginner', 20, 1, true
FROM skill ON CONFLICT (skill_id, slug) DO NOTHING;

WITH skill AS (SELECT id FROM public.skills WHERE slug = 'python-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT skill.id, 'python-control-flow', 'Control Flow and Functions',
  'Write conditional logic, loops, and reusable functions.',
  '# Control Flow and Functions

## Conditionals

`python
status = 404
if status == 200:
    print("OK")
elif status == 404:
    print("Not Found")
else:
    print(f"Status: {status}")
`

## Loops

`python
for server in ["web01", "db01"]:
    print(f"Checking {server}")
`

## Functions

`python
def check_port(host: str, port: int) -> bool:
    import socket
    try:
        with socket.create_connection((host, port), timeout=2):
            return True
    except OSError:
        return False

if check_port("192.168.1.10", 22):
    print("SSH is open")
`',
  'beginner', 20, 2, true
FROM skill ON CONFLICT (skill_id, slug) DO NOTHING;

-- Security Fundamentals lessons
WITH skill AS (SELECT id FROM public.skills WHERE slug = 'security-fundamentals')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT skill.id, 'security-cia-triad', 'The CIA Triad',
  'Understand the three pillars of information security.',
  '# The CIA Triad

## Confidentiality
Ensuring information is accessible only to those authorised to see it.
- Examples: encryption, TLS, access control lists
- Threat: data breach, eavesdropping

## Integrity
Ensuring data is not modified in an unauthorised way.
- Examples: file hashing, digital signatures, audit logs
- Threat: man-in-the-middle, log tampering

## Availability
Ensuring systems are accessible when needed.
- Examples: redundancy, backups, DDoS mitigation
- Threat: ransomware, DDoS, hardware failure

## Applying the Triad

Ask for each system component:
1. C: Who should read this? How do we prevent others?
2. I: How do we detect unauthorised changes?
3. A: What is our recovery plan?',
  'beginner', 20, 1, true
FROM skill ON CONFLICT (skill_id, slug) DO NOTHING;

WITH skill AS (SELECT id FROM public.skills WHERE slug = 'security-fundamentals')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT skill.id, 'security-least-privilege', 'Least Privilege and Attack Surface',
  'Apply the principle of least privilege to reduce your attack surface.',
  '# Least Privilege and Attack Surface

## The Principle of Least Privilege

Every user and process should have only the minimum permissions needed.

`ash
# BAD: web server running as root
sudo python3 -m http.server 80

# GOOD: dedicated non-root user
sudo useradd -r -s /sbin/nologin webserver
`

## Reducing Attack Surface

- Disable unused services
- Close unused ports
- Remove unused software
- Set minimal file permissions

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Root SSH enabled | PermitRootLogin no |
| World-writable files | chmod o-w file |
| Services as root | Dedicated service users |',
  'beginner', 20, 2, true
FROM skill ON CONFLICT (skill_id, slug) DO NOTHING;

-- 4. PRACTICE TASKS

INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published)
SELECT s.id, 'Navigate the Linux Filesystem', 'Practice pwd, ls, and cd.',
  'Open a Linux terminal. Navigate to /etc, list its contents, then return home.',
  '["Run pwd to confirm starting directory", "cd /etc and run ls -la", "cd ~ to return home"]'::jsonb,
  '["You can see hidden files in ls -la output", "You returned to your home directory"]'::jsonb,
  '["~ always means your home directory", "Tab completion works with cd /e then Tab"]'::jsonb, true
FROM public.skills s WHERE s.slug = 'linux-cli' ON CONFLICT DO NOTHING;

INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published)
SELECT s.id, 'Create and Manage Files', 'Create directories and files, copy, and delete.',
  'In your home directory, create a practice environment then clean up.',
  '["mkdir lab-practice", "echo Hello > lab-practice/notes.txt", "cp notes.txt notes-backup.txt", "rm lab-practice/notes.txt", "rm -r lab-practice"]'::jsonb,
  '["lab-practice directory was created", "notes-backup.txt exists", "Directory was removed"]'::jsonb,
  '["Use ls to verify after each step", "rm -r removes directories recursively"]'::jsonb, true
FROM public.skills s WHERE s.slug = 'linux-cli' ON CONFLICT DO NOTHING;

INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published)
SELECT s.id, 'Fix File Permissions', 'Set correct permissions on files with chmod.',
  'Create files and set them to the correct security permissions.',
  '["touch secret.key && chmod 600 secret.key", "touch public.html && chmod 644 public.html", "ls -la to verify"]'::jsonb,
  '["secret.key shows -rw------- in ls -la", "public.html shows -rw-r--r--"]'::jsonb,
  '["chmod 600 = rw for owner only", "chmod 644 = rw owner, r for group and others"]'::jsonb, true
FROM public.skills s WHERE s.slug = 'linux-permissions' ON CONFLICT DO NOTHING;

INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published)
SELECT s.id, 'Generate an SSH Key Pair', 'Create an ed25519 key pair and inspect the files.',
  'Generate a key pair and verify the correct permissions.',
  '["ssh-keygen -t ed25519", "ls -la ~/.ssh/ to verify permissions", "cat ~/.ssh/id_ed25519.pub"]'::jsonb,
  '["id_ed25519 exists with permissions 600", "id_ed25519.pub starts with ssh-ed25519"]'::jsonb,
  '["The private key must be 600 or SSH refuses to use it"]'::jsonb, true
FROM public.skills s WHERE s.slug = 'ssh' ON CONFLICT DO NOTHING;

INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published)
SELECT s.id, 'Write a Python Port Checker', 'Write a function that checks if a TCP port is open.',
  'Use Python socket module to test connectivity.',
  '["Create portcheck.py", "Write check_port(host, port) returning True/False", "Test against localhost:22 and a closed port"]'::jsonb,
  '["portcheck.py runs without errors", "Returns True for open port, False for closed"]'::jsonb,
  '["Use socket.create_connection((host, port), timeout=2)", "Wrap in try/except OSError"]'::jsonb, true
FROM public.skills s WHERE s.slug = 'python-basics' ON CONFLICT DO NOTHING;

INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published)
SELECT s.id, 'Classify CIA Triad Violations', 'Identify which CIA property each incident violates.',
  'Review three incident descriptions and classify each.',
  '["Scenario A: Employee emails customer data to personal Gmail", "Scenario B: Attacker modifies log files", "Scenario C: DDoS takes down checkout system"]'::jsonb,
  '["Scenario A = Confidentiality violation", "Scenario B = Integrity violation", "Scenario C = Availability violation"]'::jsonb,
  '["Confidentiality = unauthorised disclosure", "Integrity = unauthorised modification", "Availability = system inaccessible"]'::jsonb, true
FROM public.skills s WHERE s.slug = 'security-fundamentals' ON CONFLICT DO NOTHING;

-- 5. QUIZ QUESTIONS + OPTIONS

-- Linux CLI: Q1
DO $$
DECLARE qid uuid;
BEGIN
  INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
  SELECT s.id, 'Which command shows your current directory in Linux?', 'single',
    'pwd (print working directory) outputs the full path of your current location.',
    1, true
  FROM public.skills s WHERE s.slug = 'linux-cli'
  ON CONFLICT DO NOTHING
  RETURNING id INTO qid;
  IF qid IS NOT NULL THEN
    INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order) VALUES
      (qid, 'ls', false, 1), (qid, 'pwd', true, 2), (qid, 'cd', false, 3), (qid, 'dir', false, 4);
  END IF;
END $$;

-- Linux CLI: Q2
DO $$
DECLARE qid uuid;
BEGIN
  INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
  SELECT s.id, 'Which command lists files including hidden files?', 'single',
    'ls -la includes -a (all files, including hidden) and -l for long format.',
    2, true
  FROM public.skills s WHERE s.slug = 'linux-cli'
  ON CONFLICT DO NOTHING
  RETURNING id INTO qid;
  IF qid IS NOT NULL THEN
    INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order) VALUES
      (qid, 'ls -l', false, 1), (qid, 'ls -h', false, 2), (qid, 'ls -la', true, 3), (qid, 'ls --all', false, 4);
  END IF;
END $$;

-- Linux CLI: Q3
DO $$
DECLARE qid uuid;
BEGIN
  INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
  SELECT s.id, 'What does "tail -f /var/log/syslog" do?', 'single',
    'tail -f follows the file in real time, printing new lines as they are appended.',
    3, true
  FROM public.skills s WHERE s.slug = 'linux-cli'
  ON CONFLICT DO NOTHING
  RETURNING id INTO qid;
  IF qid IS NOT NULL THEN
    INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order) VALUES
      (qid, 'Prints the first 10 lines', false, 1),
      (qid, 'Deletes old log entries', false, 2),
      (qid, 'Follows the file in real time, printing new lines', true, 3),
      (qid, 'Searches for errors in syslog', false, 4);
  END IF;
END $$;

-- Linux Permissions: Q1
DO $$
DECLARE qid uuid;
BEGIN
  INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
  SELECT s.id, 'What permissions does chmod 644 set?', 'single',
    '644: owner=rw (6), group=r (4), other=r (4). Standard for web server files.',
    1, true
  FROM public.skills s WHERE s.slug = 'linux-permissions'
  ON CONFLICT DO NOTHING
  RETURNING id INTO qid;
  IF qid IS NOT NULL THEN
    INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order) VALUES
      (qid, 'Owner: rwx, Group: r--, Other: r--', false, 1),
      (qid, 'Owner: rw-, Group: r--, Other: r--', true, 2),
      (qid, 'Owner: rw-, Group: rw-, Other: rw-', false, 3),
      (qid, 'Owner: r--, Group: r--, Other: r--', false, 4);
  END IF;
END $$;

-- Linux Permissions: Q2
DO $$
DECLARE qid uuid;
BEGIN
  INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
  SELECT s.id, 'What permission should an SSH private key have?', 'single',
    'SSH refuses to use a private key readable by others. 600 means only the owner can read/write it.',
    2, true
  FROM public.skills s WHERE s.slug = 'linux-permissions'
  ON CONFLICT DO NOTHING
  RETURNING id INTO qid;
  IF qid IS NOT NULL THEN
    INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order) VALUES
      (qid, '644', false, 1), (qid, '755', false, 2), (qid, '600', true, 3), (qid, '777', false, 4);
  END IF;
END $$;

-- IP Addressing: Q1
DO $$
DECLARE qid uuid;
BEGIN
  INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
  SELECT s.id, 'Which of the following is a private IPv4 address?', 'single',
    'RFC 1918 defines private ranges: 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16. 8.8.8.8 is public Google DNS.',
    1, true
  FROM public.skills s WHERE s.slug = 'ip-addressing'
  ON CONFLICT DO NOTHING
  RETURNING id INTO qid;
  IF qid IS NOT NULL THEN
    INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order) VALUES
      (qid, '8.8.8.8', false, 1), (qid, '192.168.1.100', true, 2), (qid, '1.1.1.1', false, 3), (qid, '54.230.0.1', false, 4);
  END IF;
END $$;

-- IP Addressing: Q2
DO $$
DECLARE qid uuid;
BEGIN
  INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
  SELECT s.id, 'How many usable host addresses does a /24 network provide?', 'single',
    'A /24 has 256 addresses. Subtract 1 network address and 1 broadcast = 254 usable hosts.',
    2, true
  FROM public.skills s WHERE s.slug = 'ip-addressing'
  ON CONFLICT DO NOTHING
  RETURNING id INTO qid;
  IF qid IS NOT NULL THEN
    INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order) VALUES
      (qid, '256', false, 1), (qid, '255', false, 2), (qid, '254', true, 3), (qid, '128', false, 4);
  END IF;
END $$;

-- SSH: Q1
DO $$
DECLARE qid uuid;
BEGIN
  INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
  SELECT s.id, 'Which key type is recommended for new SSH key generation?', 'single',
    'ed25519 is an elliptic curve algorithm that is faster, smaller, and more secure than RSA-2048.',
    1, true
  FROM public.skills s WHERE s.slug = 'ssh'
  ON CONFLICT DO NOTHING
  RETURNING id INTO qid;
  IF qid IS NOT NULL THEN
    INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order) VALUES
      (qid, 'RSA-1024', false, 1), (qid, 'DSA', false, 2), (qid, 'ed25519', true, 3), (qid, 'ECDSA-256', false, 4);
  END IF;
END $$;

-- SSH: Q2
DO $$
DECLARE qid uuid;
BEGIN
  INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
  SELECT s.id, 'Which sshd_config directive disables password authentication?', 'single',
    'PasswordAuthentication no disables password login. Without it, key-based auth alone does not block password attacks.',
    2, true
  FROM public.skills s WHERE s.slug = 'ssh'
  ON CONFLICT DO NOTHING
  RETURNING id INTO qid;
  IF qid IS NOT NULL THEN
    INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order) VALUES
      (qid, 'DisablePassword yes', false, 1),
      (qid, 'PasswordAuthentication no', true, 2),
      (qid, 'AuthMethod keys-only', false, 3),
      (qid, 'KeysOnly yes', false, 4);
  END IF;
END $$;

-- Python Basics: Q1
DO $$
DECLARE qid uuid;
BEGIN
  INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
  SELECT s.id, 'What does "for s in servers: print(s)" do when servers = ["web01", "db01"]?', 'single',
    'The for loop iterates the list, printing each element on its own line.',
    1, true
  FROM public.skills s WHERE s.slug = 'python-basics'
  ON CONFLICT DO NOTHING
  RETURNING id INTO qid;
  IF qid IS NOT NULL THEN
    INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order) VALUES
      (qid, 'Prints web01 db01 on one line', false, 1),
      (qid, 'Prints web01 then db01 on separate lines', true, 2),
      (qid, 'Prints [''web01'', ''db01'']', false, 3),
      (qid, 'Nothing -- syntax error', false, 4);
  END IF;
END $$;

-- Python Basics: Q2
DO $$
DECLARE qid uuid;
BEGIN
  INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
  SELECT s.id, 'Which is the correct way to safely read a file in Python?', 'single',
    'The "with open()" context manager automatically closes the file when the block exits.',
    2, true
  FROM public.skills s WHERE s.slug = 'python-basics'
  ON CONFLICT DO NOTHING
  RETURNING id INTO qid;
  IF qid IS NOT NULL THEN
    INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order) VALUES
      (qid, 'f = open("file.txt") then f.read()', false, 1),
      (qid, 'with open("file.txt", "r") as f: content = f.read()', true, 2),
      (qid, 'read_file("file.txt")', false, 3),
      (qid, 'import file; file.read("file.txt")', false, 4);
  END IF;
END $$;

-- Security Fundamentals: Q1
DO $$
DECLARE qid uuid;
BEGIN
  INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
  SELECT s.id, 'A ransomware attack encrypts all files making them inaccessible. Which CIA property is primarily violated?', 'single',
    'Ransomware primarily attacks Availability -- legitimate users cannot access their data.',
    1, true
  FROM public.skills s WHERE s.slug = 'security-fundamentals'
  ON CONFLICT DO NOTHING
  RETURNING id INTO qid;
  IF qid IS NOT NULL THEN
    INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order) VALUES
      (qid, 'Confidentiality', false, 1), (qid, 'Integrity', false, 2), (qid, 'Availability', true, 3), (qid, 'Authentication', false, 4);
  END IF;
END $$;

-- Security Fundamentals: Q2
DO $$
DECLARE qid uuid;
BEGIN
  INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
  SELECT s.id, 'What is the principle of least privilege?', 'single',
    'Least privilege means every user and process gets only the minimum access needed -- nothing more.',
    2, true
  FROM public.skills s WHERE s.slug = 'security-fundamentals'
  ON CONFLICT DO NOTHING
  RETURNING id INTO qid;
  IF qid IS NOT NULL THEN
    INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order) VALUES
      (qid, 'All users should have admin rights for efficiency', false, 1),
      (qid, 'Users and processes should have only the minimum access they need', true, 2),
      (qid, 'Privileges should be granted on first request', false, 3),
      (qid, 'Privileges should be reduced only after an incident', false, 4);
  END IF;
END $$;
