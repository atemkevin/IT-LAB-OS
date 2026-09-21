-- 012_comprehensive_curriculum.sql
-- Seeds complete, detailed lessons, quiz questions, and practice tasks for all skills across IT-Lab-OS

-- ==========================================================================
-- Skill: cpu-memory-storage
-- ==========================================================================

WITH s AS (SELECT id FROM public.skills WHERE slug = 'cpu-memory-storage')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'storage-tech-benchmarking', 'Storage Technologies & Performance Benchmarking', 'Compare HDD, SATA SSD, and NVMe architecture and measure IOPS.', '# Storage Technologies & Performance Benchmarking

In enterprise IT, storage performance dictates database throughput, container launch latency, and virtual machine density.

## Storage Media Architectures

### 1. Hard Disk Drives (HDD)
- **Mechanism**: Rotating magnetic platters (5400 to 15000 RPM) with physical read/write actuator heads.
- **Latency**: 4 to 15 milliseconds (mechanical seek time).
- **IOPS (Input/Output Operations Per Second)**: ~75 to 200 IOPS.
- **Use Case**: Cold archival storage, video surveillance logs, bulk backup targets.

### 2. SATA Solid State Drives (SSD)
- **Mechanism**: NAND flash memory chips communicating over the legacy SATA 3.0 controller bus.
- **Throughput Limit**: ~550 MB/s (limited by 6 Gbps SATA bus).
- **IOPS**: Up to ~90,000 IOPS.
- **Latency**: ~50 to 100 microseconds.

### 3. NVMe PCIe SSDs
- **Mechanism**: Direct communication over high-speed PCIe lanes (PCIe Gen 4 / Gen 5) using the Non-Volatile Memory Express protocol.
- **Throughput**: 3,500 to 14,000+ MB/s.
- **IOPS**: 500,000 to 1,500,000+ IOPS.
- **Latency**: 10 to 20 microseconds. Parallel queuing with up to 64,000 queues of 64,000 commands each.

## Measuring Disk Performance with FIO

In Linux environments, `fio` is the industry gold standard for synthetic storage benchmarking:

```bash
# Install fio on Debian/Ubuntu
sudo apt-get install -y fio

# Benchmark random 4K read IOPS (simulating transactional database workload)
fio --name=random-read --ioengine=libaio --rw=randread --bs=4k \
    --numjobs=4 --size=1G --runtime=30 --time_based --group_reporting

# Benchmark sequential 1M write throughput (simulating large file ingest)
fio --name=seq-write --ioengine=libaio --rw=write --bs=1M \
    --numjobs=1 --size=2G --runtime=30 --time_based --group_reporting
```

## Monitoring Live Disk I/O

```bash
# Real-time disk utilization statistics (%util, await, r/s, w/s)
iostat -xz 1 10
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
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'cpu-memory-storage';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Which storage technology connects directly to PCIe lanes to bypass the SATA controller bottleneck?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Which storage technology connects directly to PCIe lanes to bypass the SATA controller bottleneck?', 'single', 'NVMe (Non-Volatile Memory Express) communicates directly over the PCIe bus, achieving gigabytes-per-second throughput and massive parallel queuing.', 1, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'SAS HDD', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'SATA SSD', false, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'NVMe SSD', true, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'eMMC', false, 4);
    END IF;
  END IF;
END $$;

DO $$
DECLARE
  v_skill_id UUID;
  v_q_id UUID;
BEGIN
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'cpu-memory-storage';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'What metric represents the number of read or write operations a storage device can handle per second?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'What metric represents the number of read or write operations a storage device can handle per second?', 'single', 'IOPS stands for Input/Output Operations Per Second, measuring storage transaction speed especially for small random blocks.', 2, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'IOPS', true, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Baud rate', false, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Clock frequency', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'CAS Latency', false, 4);
    END IF;
  END IF;
END $$;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'cpu-memory-storage')
INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published, evidence_keys)
SELECT s.id, 'Analyze Storage I/O Metrics', 'Inspect connected block devices and identify throughput characteristics.', 'You are provisioning a database server and must verify attached storage devices and partition topologies.',
  '["Run lsblk -o NAME,SIZE,TYPE,MOUNTPOINT","Inspect disk latency with iostat -xz 1 3"]'::jsonb, '["Storage topology verified","Disk I/O latency recorded"]'::jsonb, '["lsblk displays hierarchical block device layout","iostat requires sysstat package"]'::jsonb, true,
  '["req_1", "req_2"]'::jsonb
FROM s
WHERE NOT EXISTS (
  SELECT 1 FROM public.practice_tasks pt WHERE pt.skill_id = s.id AND pt.title = 'Analyze Storage I/O Metrics'
);

-- ==========================================================================
-- Skill: computer-basics
-- ==========================================================================

DO $$
DECLARE
  v_skill_id UUID;
  v_q_id UUID;
BEGIN
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'computer-basics';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Which component in the Von Neumann architecture holds volatile memory that is cleared when the computer powers off?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Which component in the Von Neumann architecture holds volatile memory that is cleared when the computer powers off?', 'single', 'RAM (Random Access Memory) is volatile storage used by active processes; its contents disappear when power is lost.', 1, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'NVMe SSD', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'RAM', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'ROM BIOS', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Hard Disk Drive', false, 4);
    END IF;
  END IF;
END $$;

DO $$
DECLARE
  v_skill_id UUID;
  v_q_id UUID;
BEGIN
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'computer-basics';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'What is the first software routine executed by the CPU upon power-on in modern PC and server hardware?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'What is the first software routine executed by the CPU upon power-on in modern PC and server hardware?', 'single', 'The UEFI (or legacy BIOS) firmware performs POST (Power-On Self-Test) and hands execution off to the bootloader.', 2, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Kernel init process', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'UEFI / BIOS firmware', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'systemd', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Display manager', false, 4);
    END IF;
  END IF;
END $$;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'computer-basics')
INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published, evidence_keys)
SELECT s.id, 'Inspect System Hardware Architecture', 'Identify CPU model, memory capacity, and attached block devices via Linux CLI.', 'Perform an inventory of a newly racked bare-metal Linux server.',
  '["Run lscpu to identify CPU cores and architecture","Run free -h to check physical RAM","Run lsblk to inspect storage drives"]'::jsonb, '["Captured CPU core count","Captured total system memory","Identified primary root disk"]'::jsonb, '["lscpu prints CPU model and socket info","free -h shows memory in human-readable gigabytes"]'::jsonb, true,
  '["req_1", "req_2"]'::jsonb
FROM s
WHERE NOT EXISTS (
  SELECT 1 FROM public.practice_tasks pt WHERE pt.skill_id = s.id AND pt.title = 'Inspect System Hardware Architecture'
);

-- ==========================================================================
-- Skill: processes-services
-- ==========================================================================

WITH s AS (SELECT id FROM public.skills WHERE slug = 'processes-services')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'linux-process-lifecycle', 'The Linux Process Lifecycle & Signals', 'Understand PID 1, fork/exec, process states, and POSIX signals.', '# The Linux Process Lifecycle & Signals

In Unix-like operating systems, everything that executes in user space runs as a **process**.

## Process Creation: Fork & Exec

Processes form a strict hierarchy originating from PID 1 (`systemd` or `init`):

1. **`fork()`**: A parent process creates an exact duplicate of itself (child process) with a new Process ID (PID).
2. **`execve()`**: The child process replaces its memory space with a new executable program binary.

## Process States

- **R (Running / Runnable)**: Either currently executing on a CPU core or sitting in the OS scheduler queue.
- **S (Interruptible Sleep)**: Waiting for an event or I/O operation (e.g. disk read or network socket).
- **D (Uninterruptible Sleep)**: Waiting directly on hardware device drivers; cannot be killed with SIGKILL until I/O completes.
- **Z (Zombie / Defunct)**: Process has terminated, but the parent has not yet read its exit status code via `wait()`.
- **T (Stopped)**: Suspended via signal (e.g. `Ctrl+Z` or `SIGSTOP`).

## Essential POSIX Signals

| Signal | Number | Default Action | Can Be Blocked? |
|---|---|---|---|
| SIGHUP | 1 | Reload configuration | Yes |
| SIGINT | 2 | Interrupt (`Ctrl+C`) | Yes |
| SIGKILL | 9 | Immediate forced termination | **No** |
| SIGTERM | 15 | Graceful termination request | Yes |

## Command-Line Process Management

```bash
# View active process tree
ps auxf

# Search for a process by name
pgrep -l nginx

# Gracefully terminate a process (sends SIGTERM)
kill -15 <PID>

# Force kill unresponsive process (sends SIGKILL)
kill -9 <PID>
```', 'beginner', 25, 1, true
FROM s ON CONFLICT (skill_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  summary = EXCLUDED.summary,
  content_markdown = EXCLUDED.content_markdown,
  difficulty = EXCLUDED.difficulty,
  estimated_minutes = EXCLUDED.estimated_minutes,
  sort_order = EXCLUDED.sort_order;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'processes-services')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'systemd-service-management', 'Managing System Services with systemd', 'Control background daemons, unit files, and journal logs with systemctl.', '# Managing System Services with systemd

`systemd` is the standard service manager and init system in modern enterprise Linux distributions (RHEL, Ubuntu, Debian, Rocky Linux).

## What is a Unit File?

A unit configuration file describes a service, socket, or timer. Service units reside in:
- `/lib/systemd/system/` (System default packages)
- `/etc/systemd/system/` (Administrator overrides and custom services)

Example Service Unit (`/etc/systemd/system/myapp.service`):

```ini
[Unit]
Description=My Node.js Application
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/var/www/myapp
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

## Essential `systemctl` Commands

```bash
# Check service status and recent error logs
sudo systemctl status nginx

# Start, stop, and restart a service
sudo systemctl start nginx
sudo systemctl stop nginx
sudo systemctl restart nginx

# Enable service to automatically start on boot
sudo systemctl enable nginx

# Reload service configuration without downtime
sudo systemctl reload nginx

# Reload systemd daemon after modifying unit files
sudo systemctl daemon-reload
```

## Reading Service Logs with `journalctl`

```bash
# Tail real-time logs for a specific unit
sudo journalctl -u nginx -f

# View errors only from the current boot
sudo journalctl -u nginx -b -p err
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
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'processes-services';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Which signal number corresponds to SIGKILL, which cannot be caught or ignored by a process?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Which signal number corresponds to SIGKILL, which cannot be caught or ignored by a process?', 'single', 'SIGKILL is Signal 9. The kernel immediately terminates the process without allowing it to execute cleanup handlers.', 1, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '1 (SIGHUP)', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '9 (SIGKILL)', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '15 (SIGTERM)', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '2 (SIGINT)', false, 4);
    END IF;
  END IF;
END $$;

DO $$
DECLARE
  v_skill_id UUID;
  v_q_id UUID;
BEGIN
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'processes-services';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Which command configures a systemd service to start automatically during system boot?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Which command configures a systemd service to start automatically during system boot?', 'single', 'systemctl enable creates the necessary symbolic links in /etc/systemd/system to trigger service start at boot target.', 2, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'systemctl start', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'systemctl enable', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'systemctl trigger', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'systemctl boot', false, 4);
    END IF;
  END IF;
END $$;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'processes-services')
INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published, evidence_keys)
SELECT s.id, 'Inspect and Manage System Services', 'Audit running background services, verify listening sockets, and inspect logs.', 'Verify that the web server daemon is active and running under systemd.',
  '["Run systemctl status ssh or sshd","Inspect system logs with journalctl -n 20"]'::jsonb, '["Service operational state identified","Recent journal events analyzed"]'::jsonb, '["systemctl status displays PID, memory, and status line","journalctl -n limits output lines"]'::jsonb, true,
  '["req_1", "req_2"]'::jsonb
FROM s
WHERE NOT EXISTS (
  SELECT 1 FROM public.practice_tasks pt WHERE pt.skill_id = s.id AND pt.title = 'Inspect and Manage System Services'
);

-- ==========================================================================
-- Skill: filesystem-basics
-- ==========================================================================

WITH s AS (SELECT id FROM public.skills WHERE slug = 'filesystem-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'linux-filesystem-hierarchy', 'The Filesystem Hierarchy Standard (FHS)', 'Explore the purpose and structure of root directories in Linux.', '# The Filesystem Hierarchy Standard (FHS)

Linux organizes all storage, virtual devices, and kernel hooks under a single hierarchical root tree represented by `/`.

## FHS Standard Directory Layout

- `/bin` and `/sbin`: Essential system binaries (now typically symlinks to `/usr/bin`).
- `/boot`: Linux kernel image (`vmlinuz`), initial RAM disk (`initrd`), and GRUB configuration.
- `/dev`: Special device files representing hardware (e.g. `/dev/sda` disk, `/dev/urandom` RNG, `/dev/null`).
- `/etc`: System-wide configuration files (networking, users, services).
- `/home`: User home directories (`/home/alice`).
- `/root`: Home directory for the superuser `root`.
- `/proc`: Pseudo-filesystem exposing kernel runtime data, process structures, and hardware states.
- `/sys`: Modern sysfs virtual filesystem exposing device drivers and kernel subsystem parameters.
- `/tmp`: Temporary files, often wiped upon system reboot.
- `/var`: Variable data: logs (`/var/log`), mail spools, databases (`/var/lib`), and web files (`/var/www`).

## File Types in Linux

Every entry in a Linux directory is designated by a type character:
- `-`: Regular file
- `d`: Directory
- `l`: Symbolic link
- `c`: Character device (e.g. terminal /dev/tty)
- `b`: Block device (e.g. hard disk /dev/nvme0n1)
- `s`: Unix domain socket

## Inspecting Mounts & Disk Free Space

```bash
# Display disk space usage in human-readable format
df -h

# Check directory size (summarize top-level entries)
du -sh /var/* | sort -hr | head -n 10
```', 'beginner', 25, 1, true
FROM s ON CONFLICT (skill_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  summary = EXCLUDED.summary,
  content_markdown = EXCLUDED.content_markdown,
  difficulty = EXCLUDED.difficulty,
  estimated_minutes = EXCLUDED.estimated_minutes,
  sort_order = EXCLUDED.sort_order;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'filesystem-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'inodes-links-and-mounting', 'Inodes, Hard Links, and Mounting', 'Understand inode structures, soft vs hard links, and filesystem mounting.', '# Inodes, Hard Links, and Mounting

In Linux filesystems (ext4, XFS), a file name is merely an entry in a directory pointing to a metadata structure called an **inode**.

## What is an Inode?

An inode contains all file metadata **except** the filename and the actual content data:
- File size, permissions, and owner/group IDs
- Timestamps (Access `atime`, Modify `mtime`, Change `ctime`)
- Pointers to data blocks on the disk

> **Warning**: A disk can run out of storage space even with gigabytes of free disk space if all available inodes are exhausted by millions of tiny files.

Check inode consumption:
```bash
df -i
```

## Hard Links vs Symbolic (Soft) Links

### Hard Links (`ln target linkname`)
- Points directly to the same inode number.
- If the original file is deleted, the data remains accessible through the hard link until link count drops to 0.
- Cannot span across different filesystems or partitions.

### Soft / Symbolic Links (`ln -s target linkname`)
- A separate file with its own inode that stores the text path of the target file.
- If the target file is removed, the symlink breaks ("dangling link").
- Can cross filesystems and directories.

## Mounting Filesystems

```bash
# Mount a partition to a directory mount point
sudo mount /dev/sdb1 /mnt/data

# Unmount filesystem
sudo umount /mnt/data

# Persistent mounts configuration file
cat /etc/fstab
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
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'filesystem-basics';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'What happens if you delete the original file that has an existing hard link pointing to it?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'What happens if you delete the original file that has an existing hard link pointing to it?', 'single', 'Hard links point to the same inode number. The data blocks remain on disk and accessible until all hard links pointing to that inode are deleted.', 1, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'The hard link breaks immediately', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'The data remains intact and accessible via the hard link', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'The filesystem marks the inode as corrupted', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'The kernel forces a reboot', false, 4);
    END IF;
  END IF;
END $$;

DO $$
DECLARE
  v_skill_id UUID;
  v_q_id UUID;
BEGIN
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'filesystem-basics';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Which virtual directory provides real-time information about running processes and kernel parameters directly from memory?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Which virtual directory provides real-time information about running processes and kernel parameters directly from memory?', 'single', '/proc is a pseudo-filesystem generated by the Linux kernel in RAM, providing process metrics and system tuneables.', 2, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '/var', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '/proc', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '/etc', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '/opt', false, 4);
    END IF;
  END IF;
END $$;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'filesystem-basics')
INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published, evidence_keys)
SELECT s.id, 'Analyze Inodes and Filesystem Mounts', 'Inspect filesystem inode usage, mount options, and create symbolic links.', 'Troubleshoot a system reporting file creation failures despite available disk capacity.',
  '["Run df -h and df -i to inspect storage and inode usage","Create a symbolic link using ln -s"]'::jsonb, '["Inodes verified","Symlink created and verified with ls -l"]'::jsonb, '["df -i shows inode percentages","ls -l displays symlink targets with ->"]'::jsonb, true,
  '["req_1", "req_2"]'::jsonb
FROM s
WHERE NOT EXISTS (
  SELECT 1 FROM public.practice_tasks pt WHERE pt.skill_id = s.id AND pt.title = 'Analyze Inodes and Filesystem Mounts'
);

-- ==========================================================================
-- Skill: routing
-- ==========================================================================

WITH s AS (SELECT id FROM public.skills WHERE slug = 'routing')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'ip-routing-fundamentals', 'IP Routing & Default Gateways', 'Understand packet forwarding, routing tables, and hop-by-hop decisions.', '# IP Routing & Default Gateways

Routing is the process by which Layer 3 network devices (routers, Layer 3 switches, and Linux hosts) determine where to forward an IP packet across interconnected networks.

## How a Host Makes a Forwarding Decision

When a host wants to send a packet to destination IP `D`:

1. **Local Subnet Check**: The host compares `D` against its own IP and subnet mask.
   - If `D` is on the **same local subnet**, the host sends an ARP request for the destination MAC address and transmits directly over Layer 2.
   - If `D` is on a **remote network**, the host must forward the packet to its **Default Gateway**.
2. **Default Gateway Lookup**: The default gateway is the local router IP (e.g. `192.168.1.1`). The host ARPs for the gateway''s MAC address and encapsulates the packet.

## The Linux Routing Table

```bash
# Display the kernel routing table
ip route show

# Example output:
# default via 192.168.1.1 dev eth0 proto dhcp metric 100
# 192.168.1.0/24 dev eth0 proto kernel scope link src 192.168.1.50
# 10.0.0.0/8 via 192.168.1.254 dev eth0
```

## Longest Prefix Match Rule

When multiple routing entries match a destination IP, the router **always** selects the most specific route (the one with the largest subnet mask / longest prefix length).

For example, to reach `10.1.2.5`:
- Match 1: `0.0.0.0/0` (Default route: prefix length /0)
- Match 2: `10.0.0.0/8` (prefix length /8)
- Match 3: `10.1.2.0/24` (prefix length /24)
- **Winner**: `10.1.2.0/24` is selected because /24 is the longest match.

## Adding Routes on Linux

```bash
# Add a static route to a remote subnet
sudo ip route add 172.16.0.0/16 via 192.168.1.254 dev eth0

# Delete a route
sudo ip route del 172.16.0.0/16
```', 'intermediate', 30, 1, true
FROM s ON CONFLICT (skill_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  summary = EXCLUDED.summary,
  content_markdown = EXCLUDED.content_markdown,
  difficulty = EXCLUDED.difficulty,
  estimated_minutes = EXCLUDED.estimated_minutes,
  sort_order = EXCLUDED.sort_order;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'routing')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'dynamic-routing-and-nat', 'Dynamic Routing Protocols & NAT', 'Compare OSPF, BGP, and understand Network Address Translation.', '# Dynamic Routing Protocols & NAT

Large networks cannot rely on static routes. Routing protocols exchange network topology data dynamically.

## Interior vs Exterior Routing Protocols

### 1. Interior Gateway Protocols (IGP) - Inside an Autonomous System (AS)
- **OSPF (Open Shortest Path First)**: Link-state protocol using Dijkstra''s algorithm. Fast convergence, scales within enterprise campus networks.
- **EIGRP**: Advanced distance-vector protocol.

### 2. Exterior Gateway Protocols (EGP) - Between Autonomous Systems
- **BGP (Border Gateway Protocol)**: Path-vector protocol that runs the global Internet. Routes traffic based on AS path, policies, and peering agreements.

## Network Address Translation (NAT)

IPv4 addresses are scarce. NAT allows multiple private hosts (`RFC 1918`) to share one public routable IP address:

- **PAT (Port Address Translation / NAT Overload)**: Maps internal `(IP:Port)` sockets to unique external ports on the public interface.
- **DNAT (Destination NAT / Port Forwarding)**: Directs incoming public traffic on a specific port to an internal server.

## Troubleshooting Network Paths with Traceroute

```bash
# Trace network hops to a remote host (ICMP / UDP)
traceroute -n 8.8.8.8

# Modern interactive diagnostic tool combining ping and traceroute
mtr 8.8.8.8
```', 'intermediate', 35, 2, true
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
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'routing';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'According to the Longest Prefix Match rule, which route will a router choose for destination IP 192.168.10.55?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'According to the Longest Prefix Match rule, which route will a router choose for destination IP 192.168.10.55?', 'single', '192.168.10.0/24 has a 24-bit prefix match, which is longer and more specific than /16 or /0.', 1, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '0.0.0.0/0', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '192.168.0.0/16', false, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '192.168.10.0/24', true, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '192.0.0.0/8', false, 4);
    END IF;
  END IF;
END $$;

DO $$
DECLARE
  v_skill_id UUID;
  v_q_id UUID;
BEGIN
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'routing';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Which routing protocol is the standard exterior gateway protocol powering routing across the global Internet?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Which routing protocol is the standard exterior gateway protocol powering routing across the global Internet?', 'single', 'BGP (Border Gateway Protocol) exchanges routing and reachability information among autonomous systems (AS) on the Internet.', 2, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'OSPF', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'RIP', false, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'BGP', true, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'STP', false, 4);
    END IF;
  END IF;
END $$;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'routing')
INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published, evidence_keys)
SELECT s.id, 'Analyze Linux Kernel Routing Tables', 'Inspect default gateways, route metrics, and trace network path hops.', 'A server cannot communicate with a specific database cluster on a different subnet.',
  '["Run ip route show to display active routing table","Identify the default gateway interface"]'::jsonb, '["Default route identified","Route interface validated"]'::jsonb, '["ip route show shows default via <gateway>","metric defines route precedence"]'::jsonb, true,
  '["req_1", "req_2"]'::jsonb
FROM s
WHERE NOT EXISTS (
  SELECT 1 FROM public.practice_tasks pt WHERE pt.skill_id = s.id AND pt.title = 'Analyze Linux Kernel Routing Tables'
);

-- ==========================================================================
-- Skill: linux-networking
-- ==========================================================================

WITH s AS (SELECT id FROM public.skills WHERE slug = 'linux-networking')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'network-interfaces-and-iproute2', 'Linux Network Interfaces & iproute2', 'Configure interfaces, IP addresses, MTU, and link states with ip.', '# Linux Network Interfaces & iproute2

Legacy tools like `ifconfig` and `netstat` are deprecated. Modern Linux administration relies on the **`iproute2`** suite.

## Modern `ip` Command Replacements

| Legacy Command | Modern Replacement | Purpose |
|---|---|---|
| `ifconfig -a` | `ip link show` / `ip addr show` | Display interfaces and addresses |
| `ifconfig eth0 up` | `ip link set eth0 up` | Bring interface online |
| `route -n` | `ip route show` | View routing table |
| `arp -n` | `ip neigh show` | View ARP cache |

## Managing IP Addresses

```bash
# Add a secondary IP address to an interface
sudo ip addr add 192.168.1.150/24 dev eth0

# Remove an assigned IP address
sudo ip addr del 192.168.1.150/24 dev eth0

# Flush all IP addresses on an interface
sudo ip addr flush dev eth0
```

## Viewing Socket Connections with `ss`

The modern alternative to `netstat` is `ss` (Socket Statistics):

```bash
# List all listening TCP and UDP sockets with numeric ports and process names
sudo ss -tulnp

# Filter for active HTTPS connections
ss -t state established ''( dport = :443 or sport = :443 )''
```', 'intermediate', 30, 1, true
FROM s ON CONFLICT (skill_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  summary = EXCLUDED.summary,
  content_markdown = EXCLUDED.content_markdown,
  difficulty = EXCLUDED.difficulty,
  estimated_minutes = EXCLUDED.estimated_minutes,
  sort_order = EXCLUDED.sort_order;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'linux-networking')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'linux-firewalling-nftables', 'Linux Packet Filtering: iptables to nftables', 'Understand packet filtering hooks, chains, and ufw / nftables rules.', '# Linux Packet Filtering: iptables to nftables

The Linux kernel contains the **Netfilter** framework, enabling stateful firewall inspection, NAT, and packet mangling.

## Netfilter Hooks

As network packets traverse the Linux network stack, they hit 5 core hooks:

1. **PREROUTING**: Incoming packets before a routing decision is made.
2. **INPUT**: Packets addressed to the local machine processes.
3. **FORWARD**: Packets destined for another host (routing/gateway mode).
4. **OUTPUT**: Packets generated by local processes on this machine.
5. **POSTROUTING**: Packets about to leave the physical network interface (ideal for SNAT/Masquerade).

## Simple Host Firewall Management with `ufw`

On Ubuntu/Debian, the Uncomplicated Firewall (`ufw`) simplifies packet rule management:

```bash
# Check firewall status
sudo ufw status verbose

# Allow SSH and HTTPS
sudo ufw allow 22/tcp
sudo ufw allow 443/tcp

# Deny all incoming traffic by default
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Enable the firewall
sudo ufw enable
```

## Packet Capture with `tcpdump`

```bash
# Capture 10 DNS queries on eth0 in ASCII and Hex
sudo tcpdump -i eth0 -nn -c 10 port 53

# Capture HTTP traffic and write to a pcap file for Wireshark analysis
sudo tcpdump -i eth0 -w /tmp/capture.pcap port 80
```', 'intermediate', 35, 2, true
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
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'linux-networking';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Which modern command replaces netstat -tulnp for listing listening network sockets and their process IDs in Linux?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Which modern command replaces netstat -tulnp for listing listening network sockets and their process IDs in Linux?', 'single', 'ss -tulnp provides faster socket statistics directly from kernel memory without parsing /proc files.', 1, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'ip link', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'ss -tulnp', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'curl -v', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'lsof -i', false, 4);
    END IF;
  END IF;
END $$;

DO $$
DECLARE
  v_skill_id UUID;
  v_q_id UUID;
BEGIN
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'linux-networking';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'At which Netfilter hook does Source NAT (SNAT / Masquerade) take place just before a packet exits the network interface?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'At which Netfilter hook does Source NAT (SNAT / Masquerade) take place just before a packet exits the network interface?', 'single', 'POSTROUTING occurs after routing has determined the egress interface, right before physical transmission.', 2, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'PREROUTING', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'INPUT', false, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'FORWARD', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'POSTROUTING', true, 4);
    END IF;
  END IF;
END $$;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'linux-networking')
INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published, evidence_keys)
SELECT s.id, 'Inspect Listening Sockets and Active Connections', 'Verify listening ports, protocols, and network interfaces using ip and ss.', 'Audit a server to determine if unintended services are exposed to the network.',
  '["Run ip -br addr to view network interfaces","Run ss -tulnp to identify listening ports"]'::jsonb, '["Network interfaces listed","Open ports identified"]'::jsonb, '["-t shows TCP, -u shows UDP, -l shows listening","-n prints numeric ports"]'::jsonb, true,
  '["req_1", "req_2"]'::jsonb
FROM s
WHERE NOT EXISTS (
  SELECT 1 FROM public.practice_tasks pt WHERE pt.skill_id = s.id AND pt.title = 'Inspect Listening Sockets and Active Connections'
);

-- ==========================================================================
-- Skill: api-basics
-- ==========================================================================

WITH s AS (SELECT id FROM public.skills WHERE slug = 'api-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'http-methods-and-status-codes', 'RESTful Architecture & HTTP Semantics', 'Master HTTP verbs, request/response headers, and status code families.', '# RESTful Architecture & HTTP Semantics

Web applications, microservices, and automation pipelines communicate via **HTTP** (Hypertext Transfer Protocol).

## HTTP Methods (Verbs)

- **GET**: Retrieve a resource. Safe and idempotent (does not modify server state).
- **POST**: Create a new subordinate resource. Non-idempotent.
- **PUT**: Replace a resource entirely or create if non-existent. Idempotent.
- **PATCH**: Apply partial modifications to an existing resource.
- **DELETE**: Remove a resource. Idempotent.

## HTTP Status Code Families

- **1xx (Informational)**: `101 Switching Protocols` (e.g. WebSocket upgrade).
- **2xx (Success)**:
  - `200 OK`: Standard successful response.
  - `201 Created`: Resource created successfully.
  - `204 No Content`: Success with no return body.
- **3xx (Redirection)**:
  - `301 Moved Permanently`: Resource permanently shifted.
  - `304 Not Modified`: Client cache is fresh.
- **4xx (Client Error)**:
  - `400 Bad Request`: Malformed syntax or payload.
  - `401 Unauthorized`: Missing or invalid authentication token.
  - `403 Forbidden`: Authenticated, but lacks permissions (authorization).
  - `404 Not Found`: Resource does not exist.
  - `429 Too Many Requests`: Rate limit exceeded.
- **5xx (Server Error)**:
  - `500 Internal Server Error`: Unhandled server crash.
  - `502 Bad Gateway`: Reverse proxy upstream failure.
  - `503 Service Unavailable`: Temporary overload or maintenance.
  - `504 Gateway Timeout`: Upstream took too long to respond.

## Testing APIs with `curl`

```bash
# Send an authenticated POST request with JSON payload
curl -X POST https://api.example.com/v1/devices \
     -H "Authorization: Bearer my_secret_token" \
     -H "Content-Type: application/json" \
     -d ''{"hostname": "router-01", "ip": "10.0.0.1"}'' -i
```', 'beginner', 25, 1, true
FROM s ON CONFLICT (skill_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  summary = EXCLUDED.summary,
  content_markdown = EXCLUDED.content_markdown,
  difficulty = EXCLUDED.difficulty,
  estimated_minutes = EXCLUDED.estimated_minutes,
  sort_order = EXCLUDED.sort_order;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'api-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'python-requests-automation', 'API Automation with Python Requests', 'Automate REST API calls, error handling, and JSON parsing in Python.', '# API Automation with Python Requests

Python''s `requests` library provides an intuitive API for interacting with HTTP endpoints.

## Making API Requests

```python
import requests

url = "https://jsonplaceholder.typicode.com/posts/1"
headers = {"Accept": "application/json"}

try:
    response = requests.get(url, headers=headers, timeout=5)
    # Raise exception for 4xx or 5xx responses
    response.raise_for_status()
    
    data = response.json()
    print(f"Post Title: {data[''title'']}")
except requests.exceptions.Timeout:
    print("Request timed out")
except requests.exceptions.HTTPError as err:
    print(f"HTTP error occurred: {err}")
except Exception as e:
    print(f"Unexpected error: {e}")
```

## Best Practices for API Automation

1. **Always Set Timeouts**: Never call `requests.get()` without a `timeout=(connect_sec, read_sec)` parameter to prevent thread hangs.
2. **Handle Rate Limits (429)**: Implement exponential backoff when encountering `429 Too Many Requests`.
3. **Use Session Objects**: `requests.Session()` reuses TCP connections via HTTP Keep-Alive, significantly reducing latency across multiple calls.
4. **Environment Variables**: Store sensitive API keys in environment variables (`os.getenv(''API_KEY'')`), never hardcoded in source files.
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
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'api-basics';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Which HTTP status code indicates that the request was successful and a new resource was created on the server?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Which HTTP status code indicates that the request was successful and a new resource was created on the server?', 'single', '201 Created indicates the request succeeded and resulted in the creation of a new resource.', 1, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '200 OK', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '201 Created', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '204 No Content', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '302 Found', false, 4);
    END IF;
  END IF;
END $$;

DO $$
DECLARE
  v_skill_id UUID;
  v_q_id UUID;
BEGIN
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'api-basics';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'What is the primary difference between a 401 Unauthorized and a 403 Forbidden status code?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'What is the primary difference between a 401 Unauthorized and a 403 Forbidden status code?', 'single', '401 means authentication is missing or invalid; 403 means the identity is known, but lacks permission to access the resource.', 2, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '401 is a server error, 403 is a client error', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '401 is authentication failure; 403 is authorization/permission denial', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '403 is temporary, 401 is permanent', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'There is no difference', false, 4);
    END IF;
  END IF;
END $$;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'api-basics')
INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published, evidence_keys)
SELECT s.id, 'Query and Inspect REST API Endpoints with curl', 'Perform HTTP GET/POST requests and inspect status codes and response headers.', 'Verify the health and API response of an internal microservice.',
  '["Use curl -I to inspect response headers","Parse JSON response structure"]'::jsonb, '["HTTP status code inspected","Headers analyzed"]'::jsonb, '["curl -I sends a HEAD request","curl -s silences progress meters"]'::jsonb, true,
  '["req_1", "req_2"]'::jsonb
FROM s
WHERE NOT EXISTS (
  SELECT 1 FROM public.practice_tasks pt WHERE pt.skill_id = s.id AND pt.title = 'Query and Inspect REST API Endpoints with curl'
);

-- ==========================================================================
-- Skill: authentication-authorization
-- ==========================================================================

WITH s AS (SELECT id FROM public.skills WHERE slug = 'authentication-authorization')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'auth-vs-authz-principles', 'Authentication vs Authorization & IAM', 'Distinguish Who You Are (AuthN) from What You Can Do (AuthZ).', '# Authentication vs Authorization & IAM

Security systems depend on two distinct pillars: **Authentication (AuthN)** and **Authorization (AuthZ)**.

## Core Definitions

| Dimension | Authentication (AuthN) | Authorization (AuthZ) |
|---|---|---|
| Question | "Who are you?" | "What are you allowed to do?" |
| Verification | Passwords, Biometrics, MFA tokens, SSH keys | RBAC policies, ACLs, Scopes, Claims |
| Failure Code | `401 Unauthorized` | `403 Forbidden` |
| Execution Order | Always evaluates first | Evaluates after identity is confirmed |

## Multi-Factor Authentication (MFA) Factors

True MFA requires **two or more distinct factor types**:

1. **Something You Know**: Password, PIN, security question.
2. **Something You Have**: TOTP smartphone app, hardware security key (YubiKey), SMS code.
3. **Something You Are**: Fingerprint, retinal scan, facial recognition.

> **Security Note**: Using a password and a PIN is **not** MFA; both belong to the same factor category (Something You Know).

## Identity and Access Management (IAM) Models

- **Discretionary Access Control (DAC)**: The owner of the file sets permissions (e.g. standard Linux chmod).
- **Role-Based Access Control (RBAC)**: Permissions are assigned to roles, and users are assigned to roles (standard in Kubernetes, AWS, and enterprise web apps).
- **Attribute-Based Access Control (ABAC)**: Access decisions evaluate attributes of the user, resource, environment, and time (e.g. "allow if employee is in Engineering and IP is on corporate VPN").
```', 'beginner', 25, 1, true
FROM s ON CONFLICT (skill_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  summary = EXCLUDED.summary,
  content_markdown = EXCLUDED.content_markdown,
  difficulty = EXCLUDED.difficulty,
  estimated_minutes = EXCLUDED.estimated_minutes,
  sort_order = EXCLUDED.sort_order;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'authentication-authorization')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'tokens-sessions-and-oauth2', 'OAuth 2.0, OpenID Connect & JWTs', 'Understand modern token authentication, OAuth grant flows, and JWT signing.', '# OAuth 2.0, OpenID Connect & JWTs

Modern web and mobile applications use token-based authentication standards to enable federated single sign-on (SSO).

## OAuth 2.0 vs OpenID Connect (OIDC)

- **OAuth 2.0**: An **authorization** framework that enables third-party applications to obtain limited access to an HTTP service on behalf of a resource owner. Issues **Access Tokens**.
- **OpenID Connect (OIDC)**: An **identity** layer built on top of OAuth 2.0 that provides user authentication. Issues an **ID Token** containing user profile claims.

## Anatomy of a JSON Web Token (JWT)

A JWT is a compact, URL-safe token formatted into three Base64URL-encoded segments separated by dots:

```
header.payload.signature
```

1. **Header**: Declares the algorithm (`alg: "HS256"` or `"RS256"`) and token type (`typ: "JWT"`).
2. **Payload (Claims)**: Contains statements about the user and metadata:
   - `sub`: Subject (User ID)
   - `iss`: Issuer
   - `exp`: Expiration timestamp
   - `role`: User access role
3. **Signature**: Cryptographic signature proving the token was issued by the trusted server and was not tampered with.

## Token Storage Security Best Practices

- **Never store access tokens in `localStorage`**: Vulnerable to Cross-Site Scripting (XSS).
- **Use `HttpOnly`, `Secure`, `SameSite=Lax` cookies**: Prevents client JavaScript from reading session tokens while protecting against Cross-Site Request Forgery (CSRF).
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
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'authentication-authorization';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Which combination qualifies as valid Multi-Factor Authentication (MFA)?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Which combination qualifies as valid Multi-Factor Authentication (MFA)?', 'single', 'A password is Something You Know, while a hardware FIDO2 security key is Something You Have, satisfying two independent factor types.', 1, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'A password and a PIN', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'A password and a hardware security key (YubiKey)', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'A password and a secret security question', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'A fingerprint and facial scan', false, 4);
    END IF;
  END IF;
END $$;

DO $$
DECLARE
  v_skill_id UUID;
  v_q_id UUID;
BEGIN
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'authentication-authorization';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Which standard extends OAuth 2.0 to provide user identity authentication via ID Tokens?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Which standard extends OAuth 2.0 to provide user identity authentication via ID Tokens?', 'single', 'OpenID Connect (OIDC) is an identity layer built on top of OAuth 2.0 to provide authenticated user identity.', 2, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'SAML 1.0', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'OpenID Connect (OIDC)', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'RADIUS', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'LDAP', false, 4);
    END IF;
  END IF;
END $$;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'authentication-authorization')
INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published, evidence_keys)
SELECT s.id, 'Analyze JWT Claims and Signatures', 'Decode JWT tokens, inspect header algorithms, and verify expiration timestamps.', 'Debug an expired session issue in an API integration.',
  '["Decode header and payload of a test JWT token","Identify sub, exp, and iat claims"]'::jsonb, '["JWT structure validated","Expiration date verified"]'::jsonb, '["JWTs consist of three dot-separated base64url segments","exp is in Unix epoch seconds"]'::jsonb, true,
  '["req_1", "req_2"]'::jsonb
FROM s
WHERE NOT EXISTS (
  SELECT 1 FROM public.practice_tasks pt WHERE pt.skill_id = s.id AND pt.title = 'Analyze JWT Claims and Signatures'
);

-- ==========================================================================
-- Skill: web-security-basics
-- ==========================================================================

WITH s AS (SELECT id FROM public.skills WHERE slug = 'web-security-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'owasp-top-10-overview', 'OWASP Top 10: Injections & Broken Access Control', 'Understand SQL injection, Cross-Site Scripting (XSS), and IDOR vulnerabilities.', '# OWASP Top 10: Injections & Broken Access Control

The Open Worldwide Application Security Project (OWASP) maintains the authoritative index of critical web security risks.

## 1. Broken Access Control (OWASP #1)

Occurs when authorization checks are missing or improperly enforced:
- **Insecure Direct Object Reference (IDOR)**: An attacker changes an ID parameter in a URL (`/api/users/102`) to view another user''s profile (`/api/users/103`).
- **Mitigation**: Enforce server-authoritative ownership validation using session user ID (e.g. Supabase Row Level Security `auth.uid() = user_id`).

## 2. Injection Flaws (SQLi)

Occurs when untrusted user input is concatenated directly into database queries:

```sql
-- Vulnerable direct concatenation
SELECT * FROM users WHERE username = ''admin'' AND password = '''' OR ''1''=''1'';
```

- **Mitigation**: Always use parameterized queries or prepared statements:
```typescript
// Safe parameterized query
const { data } = await db.query(''SELECT * FROM users WHERE id = $1'', [userId]);
```

## 3. Cross-Site Scripting (XSS)

Injecting malicious JavaScript into web pages viewed by other users:
- **Stored XSS**: Payload is saved in the database (e.g. a blog comment) and served to all readers.
- **Reflected XSS**: Payload is reflected off the server response via query parameters.
- **Mitigation**: Contextual output encoding, escaping HTML entities (`&lt;`, `&gt;`, `&amp;`), and enforcing a strong Content Security Policy (CSP).
```', 'intermediate', 30, 1, true
FROM s ON CONFLICT (skill_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  summary = EXCLUDED.summary,
  content_markdown = EXCLUDED.content_markdown,
  difficulty = EXCLUDED.difficulty,
  estimated_minutes = EXCLUDED.estimated_minutes,
  sort_order = EXCLUDED.sort_order;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'web-security-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'secure-http-headers-and-cors', 'HTTP Security Headers & CORS Policy', 'Configure CSP, HSTS, X-Frame-Options, and Cross-Origin Resource Sharing.', '# HTTP Security Headers & CORS Policy

Hardening HTTP response headers is one of the most cost-effective defenses against client-side exploitation.

## Essential Security Headers

- **`Content-Security-Policy (CSP)`**: Restricts where scripts, styles, images, and frames can be loaded from, neutralizing most XSS attacks.
- **`Strict-Transport-Security (HSTS)`**: Forces browsers to communicate exclusively over HTTPS:
  ```
  Strict-Transport-Security: max-age=63072000; includeSubDomains; preload
  ```
- **`X-Frame-Options: DENY`**: Prevents clickjacking by forbidding embedding inside `<iframe>` elements.
- **`X-Content-Type-Options: nosniff`**: Disables MIME-type sniffing by browsers.
- **`Referrer-Policy: strict-origin-when-cross-origin`**: Prevents leaking confidential path query data to external domains.

## Demystifying CORS (Cross-Origin Resource Sharing)

> **Crucial Concept**: CORS is a browser security mechanism designed to **relax** the Same-Origin Policy (SOP), not a firewall to block attackers.

- An origin is defined by: **Scheme + Hostname + Port** (`https://example.com:443`).
- When a browser makes a cross-origin request (e.g. from `app.com` to `api.com`), the browser sends an `Origin` header.
- For non-simple requests (methods like PUT/DELETE or custom headers), the browser sends an `OPTIONS` preflight request:

```http
OPTIONS /v1/data HTTP/1.1
Origin: https://app.example.com
Access-Control-Request-Method: POST
Access-Control-Request-Headers: Authorization, Content-Type
```

The server must reply with:
```http
Access-Control-Allow-Origin: https://app.example.com
Access-Control-Allow-Methods: POST, GET, OPTIONS
Access-Control-Allow-Headers: Authorization, Content-Type
```
```', 'intermediate', 30, 2, true
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
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'web-security-basics';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'What primary defense completely eliminates SQL injection vulnerabilities in database operations?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'What primary defense completely eliminates SQL injection vulnerabilities in database operations?', 'single', 'Parameterized queries (prepared statements) ensure user input is treated strictly as data parameters, never interpreted as SQL syntax.', 1, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Client-side form validation', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Parameterized queries / prepared statements', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Web Application Firewall (WAF) only', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Base64 encoding input', false, 4);
    END IF;
  END IF;
END $$;

DO $$
DECLARE
  v_skill_id UUID;
  v_q_id UUID;
BEGIN
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'web-security-basics';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'What is the purpose of the HTTP Strict-Transport-Security (HSTS) header?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'What is the purpose of the HTTP Strict-Transport-Security (HSTS) header?', 'single', 'HSTS instructs the browser to always connect to the domain using secure HTTPS, preventing SSL stripping attacks.', 2, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Forces the browser to connect exclusively over HTTPS', true, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Enforces Cross-Origin Resource Sharing', false, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Prevents SQL injection', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Encrypts database tables', false, 4);
    END IF;
  END IF;
END $$;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'web-security-basics')
INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published, evidence_keys)
SELECT s.id, 'Inspect HTTP Security Headers with curl', 'Audit web server response headers for security compliance.', 'Verify that an API or web application presents necessary security hardening headers.',
  '["Run curl -I to check for Content-Security-Policy or Strict-Transport-Security headers"]'::jsonb, '["Security headers identified and reviewed"]'::jsonb, '["curl -I sends a HEAD request to display headers only"]'::jsonb, true,
  '["req_1", "req_2"]'::jsonb
FROM s
WHERE NOT EXISTS (
  SELECT 1 FROM public.practice_tasks pt WHERE pt.skill_id = s.id AND pt.title = 'Inspect HTTP Security Headers with curl'
);

-- ==========================================================================
-- Skill: cloud-fundamentals
-- ==========================================================================

WITH s AS (SELECT id FROM public.skills WHERE slug = 'cloud-fundamentals')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'cloud-service-models-and-shared-responsibility', 'Cloud Service Models & The Shared Responsibility Model', 'Compare IaaS, PaaS, and SaaS, and understand security boundaries in the cloud.', '# Cloud Service Models & The Shared Responsibility Model

Cloud computing delivers on-demand compute, storage, and networking over the internet with pay-as-you-go pricing.

## The 3 Primary Service Models

1. **Infrastructure as a Service (IaaS)**:
   - Provides fundamental compute (VMs), storage, and networking.
   - Examples: AWS EC2, Google Compute Engine, Azure VMs.
   - You manage: OS installation, patching, security configurations, and applications.
2. **Platform as a Service (PaaS)**:
   - Provides an execution environment without managing underlying servers or OS.
   - Examples: Vercel, AWS Elastic Beanstalk, Heroku.
   - You manage: Application code and database data.
3. **Software as a Service (SaaS)**:
   - Fully managed end-user software delivered over the web.
   - Examples: Google Workspace, Microsoft 365, GitHub.

## The Shared Responsibility Model

Security in the cloud is a shared partnership between the cloud provider and the customer:

- **Security OF the Cloud (Provider Responsibility)**:
  - Physical data center security and power.
  - Hardware host virtualization and host OS patching.
  - Physical cabling and global network infrastructure.
- **Security IN the Cloud (Customer Responsibility)**:
  - Customer data and database encryption.
  - User IAM policies and credential rotation.
  - Guest OS patching (in IaaS).
  - Network firewall security groups and ACLs.
```', 'beginner', 25, 1, true
FROM s ON CONFLICT (skill_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  summary = EXCLUDED.summary,
  content_markdown = EXCLUDED.content_markdown,
  difficulty = EXCLUDED.difficulty,
  estimated_minutes = EXCLUDED.estimated_minutes,
  sort_order = EXCLUDED.sort_order;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'cloud-fundamentals')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'cloud-networking-vpcs-and-storage', 'Virtual Private Clouds (VPC) & Object Storage', 'Understand cloud subnets, Internet Gateways, and S3-compatible object storage.', '# Virtual Private Clouds (VPC) & Object Storage

Cloud providers isolate each customer''s resources inside logically isolated virtual software-defined networks.

## Anatomy of a Virtual Private Cloud (VPC)

A VPC encompasses:
- **CIDR Block**: The private IPv4 address space allocated to the virtual network (e.g. `10.0.0.0/16`).
- **Public Subnet**: Connected to an **Internet Gateway (IGW)**, allowing instances with public IPs to route traffic directly to the Internet.
- **Private Subnet**: Isolated from direct Internet ingress. Outbound traffic routes through a **NAT Gateway**. Databases and backend application servers should always reside in private subnets.
- **Security Groups**: Stateful virtual firewalls operating at the instance level.
- **Network Access Control Lists (NACLs)**: Stateless subnet-level boundary firewalls.

## Object Storage (AWS S3 / Cloudflare R2 / MinIO)

Object storage stores unstructured data as objects consisting of:
- The data payload (images, videos, backups).
- Metadata key-value pairs.
- A globally unique identifier (URI).

Characteristics:
- Massive scalability (exabytes) with 99.999999999% (11 9s) durability.
- Accessed via REST APIs (`GET /bucket/object.png`) rather than mounted block filesystems.
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
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'cloud-fundamentals';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'In the Cloud Shared Responsibility Model, which duty belongs exclusively to the cloud provider in an IaaS setup?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'In the Cloud Shared Responsibility Model, which duty belongs exclusively to the cloud provider in an IaaS setup?', 'single', 'Physical data center facilities, cooling, power, and physical host hardware are the sole responsibility of the cloud provider.', 1, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Guest OS security patching', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Physical data center and host hardware security', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Application database backup', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Customer IAM role permissions', false, 4);
    END IF;
  END IF;
END $$;

DO $$
DECLARE
  v_skill_id UUID;
  v_q_id UUID;
BEGIN
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'cloud-fundamentals';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Where should production database servers be deployed inside a Virtual Private Cloud (VPC)?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Where should production database servers be deployed inside a Virtual Private Cloud (VPC)?', 'single', 'Private subnets have no direct route from the internet, protecting databases from external scanning and direct attacks.', 2, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'In a public subnet with port 3306 open', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'In a private subnet without direct internet ingress', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'On the Internet Gateway directly', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'In the DMZ zone', false, 4);
    END IF;
  END IF;
END $$;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'cloud-fundamentals')
INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published, evidence_keys)
SELECT s.id, 'Audit Cloud VPC Subnet Configurations', 'Calculate VPC CIDR allocations and plan public vs private subnet topologies.', 'Design a high-availability VPC layout across multiple availability zones.',
  '["Divide 10.0.0.0/16 into four /24 subnets","Designate two public and two private subnets"]'::jsonb, '["Subnet CIDR blocks calculated correctly without overlaps"]'::jsonb, '["A /24 subnet provides 256 addresses (e.g. 10.0.1.0/24, 10.0.2.0/24)"]'::jsonb, true,
  '["req_1", "req_2"]'::jsonb
FROM s
WHERE NOT EXISTS (
  SELECT 1 FROM public.practice_tasks pt WHERE pt.skill_id = s.id AND pt.title = 'Audit Cloud VPC Subnet Configurations'
);

-- ==========================================================================
-- Skill: ci-cd-basics
-- ==========================================================================

WITH s AS (SELECT id FROM public.skills WHERE slug = 'ci-cd-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'continuous-integration-principles', 'Continuous Integration & GitHub Actions', 'Automate linting, testing, and artifact building on every commit.', '# Continuous Integration & GitHub Actions

Continuous Integration (CI) is the software development practice where developers merge code changes frequently into a shared branch, triggering automated build and test suites.

## Core Pillars of CI

1. **Automated Builds**: Compile and bundle code immediately upon push.
2. **Automated Testing**: Run unit, integration, and security checks before code reaches production.
3. **Fast Feedback**: Developers learn within minutes if their commit caused a regression.

## Anatomy of a GitHub Actions Workflow (`.github/workflows/ci.yml`)

```yaml
name: CI Pipeline

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Set up Node.js runtime
      uses: actions/setup-node@v4
      with:
        node-version: 20
        cache: ''npm''

    - name: Install dependencies
      run: npm ci

    - name: Run TypeScript typecheck
      run: npm run typecheck

    - name: Run Linter
      run: npm run lint

    - name: Run Automated Tests
      run: npm run test
```

## Key Commands in CI

- `npm ci`: Clean install that strictly respects `package-lock.json`, ideal for reproducible CI runners.
```', 'intermediate', 25, 1, true
FROM s ON CONFLICT (skill_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  summary = EXCLUDED.summary,
  content_markdown = EXCLUDED.content_markdown,
  difficulty = EXCLUDED.difficulty,
  estimated_minutes = EXCLUDED.estimated_minutes,
  sort_order = EXCLUDED.sort_order;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'ci-cd-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'continuous-deployment-strategies', 'Continuous Deployment & Release Strategies', 'Compare Blue-Green, Canary, and Rolling deployment methodologies.', '# Continuous Deployment & Release Strategies

Continuous Deployment (CD) automates releasing validated build artifacts directly into production environments with minimal downtime.

## Modern Deployment Strategies

### 1. Rolling Deployment
- Updates instances incrementally in batches behind a load balancer.
- **Advantage**: No extra infrastructure required; zero downtime.
- **Drawback**: During deployment, both old and new versions run simultaneously, requiring backward-compatible database schemas.

### 2. Blue-Green Deployment
- Maintains two identical production environments: **Blue** (active traffic) and **Green** (new release idle).
- When Green passes smoke tests, the router/load balancer switches all traffic to Green instantly.
- **Advantage**: Instant rollback by switching the router back to Blue.

### 3. Canary Deployment
- Routes a small percentage (e.g. 5%) of real production user traffic to the new version.
- Monitors error rates and performance metrics; if healthy, increases traffic to 100%.

## Health Check Endpoints

Automated deploy platforms (Vercel, Kubernetes, AWS ECS) rely on health endpoints (like `/api/health`) to determine if a newly spawned container is ready to accept traffic before shutting down the old instance.
```', 'intermediate', 30, 2, true
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
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'ci-cd-basics';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Why is npm ci preferred over npm install in automated CI/CD build environments?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Why is npm ci preferred over npm install in automated CI/CD build environments?', 'single', 'npm ci strictly installs the exact versions locked in package-lock.json without modifying it, guaranteeing reproducible builds.', 1, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'npm ci compiles C++ faster', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'npm ci installs strictly from package-lock.json without mutating it', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'npm ci skips devDependencies', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'npm ci does not require internet access', false, 4);
    END IF;
  END IF;
END $$;

DO $$
DECLARE
  v_skill_id UUID;
  v_q_id UUID;
BEGIN
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'ci-cd-basics';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Which deployment strategy routes a small percentage of real user traffic to a new version to monitor metrics before full rollout?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Which deployment strategy routes a small percentage of real user traffic to a new version to monitor metrics before full rollout?', 'single', 'Canary deployments release to a small subset of users to catch real-world regressions before wider exposure.', 2, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Blue-Green Deployment', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Canary Deployment', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Recreate Deployment', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Shadow Deployment', false, 4);
    END IF;
  END IF;
END $$;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'ci-cd-basics')
INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published, evidence_keys)
SELECT s.id, 'Analyze GitHub Actions Workflow Configuration', 'Inspect workflow triggers, runner definitions, and step execution order.', 'Verify a continuous deployment workflow for automated testing.',
  '["Review workflow file syntax and dependencies","Identify test and lint execution steps"]'::jsonb, '["CI steps verified for reproducibility"]'::jsonb, '["GitHub Actions workflows are stored in .github/workflows/*.yml"]'::jsonb, true,
  '["req_1", "req_2"]'::jsonb
FROM s
WHERE NOT EXISTS (
  SELECT 1 FROM public.practice_tasks pt WHERE pt.skill_id = s.id AND pt.title = 'Analyze GitHub Actions Workflow Configuration'
);

-- ==========================================================================
-- Skill: llm-api-basics
-- ==========================================================================

WITH s AS (SELECT id FROM public.skills WHERE slug = 'llm-api-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'llm-fundamentals-and-tokenization', 'LLM Architectures & Tokenization', 'Understand Transformer models, token economics, context windows, and embeddings.', '# LLM Architectures & Tokenization

Large Language Models (LLMs) are probabilistic neural networks trained to predict the next most likely token in a sequence.

## Tokenization Mechanics

Models do not process raw text directly; text is broken into chunks called **tokens** using algorithms like Byte-Pair Encoding (BPE):
- 1 token is roughly equivalent to ~0.75 English words or ~4 characters.
- Pricing and rate limits on commercial APIs (Google Gemini, OpenAI) are billed per 1,000 or 1,000,000 tokens.

## Context Windows

The context window is the maximum number of tokens (prompt input + generated output) the model can hold in attention at one time.
- Gemini 1.5 Pro: Up to 1,000,000 to 2,000,000 tokens.
- Exceeding the context window causes older context to be truncated.

## Key Hyperparameters

- **Temperature (0.0 to 2.0)**:
  - `0.0`: Deterministic, focused, and repeatable (ideal for code generation and factual extraction).
  - `0.7 - 1.0`: Creative, varied, and conversational.
- **Top_P (Nucleus Sampling)**: Dynamically selects tokens from the smallest set whose cumulative probability exceeds P.
```', 'beginner', 25, 1, true
FROM s ON CONFLICT (skill_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  summary = EXCLUDED.summary,
  content_markdown = EXCLUDED.content_markdown,
  difficulty = EXCLUDED.difficulty,
  estimated_minutes = EXCLUDED.estimated_minutes,
  sort_order = EXCLUDED.sort_order;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'llm-api-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'calling-llm-apis-and-streaming', 'Structured Output & Server-Sent Events (SSE)', 'Call LLM APIs with system prompts, function calling, and streaming tokens.', '# Structured Output & Server-Sent Events (SSE)

Production LLM integrations require low latency streaming and deterministic JSON schemas.

## Real-time Token Streaming via SSE

Instead of waiting 10 seconds for a full completion to finish generating, servers stream partial tokens as they are predicted using HTTP Server-Sent Events (`text/event-stream`):

```typescript
// Streaming reader pattern in modern TypeScript
const response = await fetch(''/api/ai/chat'', {
  method: ''POST'',
  body: JSON.stringify({ prompt }),
});

const reader = response.body.getReader();
const decoder = new TextDecoder();

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  const chunk = decoder.decode(value);
  // Append chunk to UI state
}
```

## Structured JSON Generation

Using function calling / schema constraints ensures that the model outputs strictly typed JSON matching your database or API schemas:

```json
{
  "response_mime_type": "application/json",
  "response_schema": {
    "type": "object",
    "properties": {
      "summary": { "type": "string" },
      "action_items": { "type": "array", "items": { "type": "string" } }
    },
    "required": ["summary", "action_items"]
  }
}
```
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
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'llm-api-basics';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Which temperature setting is best suited for deterministic, factual tasks such as generating code or parsing data?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Which temperature setting is best suited for deterministic, factual tasks such as generating code or parsing data?', 'single', 'A temperature near 0.0 minimizes randomness and makes the model select the highest probability tokens deterministically.', 1, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '0.0 to 0.2', true, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '0.8 to 1.0', false, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '1.5 to 2.0', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Temperature does not affect output', false, 4);
    END IF;
  END IF;
END $$;

DO $$
DECLARE
  v_skill_id UUID;
  v_q_id UUID;
BEGIN
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'llm-api-basics';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'What HTTP protocol format is standard for streaming real-time tokens from an LLM API to a frontend UI?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'What HTTP protocol format is standard for streaming real-time tokens from an LLM API to a frontend UI?', 'single', 'Server-Sent Events (SSE) using Content-Type: text/event-stream allows one-way text streaming from server to client over HTTP.', 2, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'GraphQL Subscriptions only', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Server-Sent Events (text/event-stream)', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Raw UDP packets', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'SOAP XML polling', false, 4);
    END IF;
  END IF;
END $$;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'llm-api-basics')
INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published, evidence_keys)
SELECT s.id, 'Analyze LLM Tokenization and Streaming Responses', 'Understand token consumption, stream parsing, and structured output formatting.', 'Configure a streaming client connecting to an AI assistant endpoint.',
  '["Inspect streaming event chunks in /api/ai/chat","Verify token buffering logic"]'::jsonb, '["SSE stream format understood and verified"]'::jsonb, '["SSE frames start with data: and terminate with double newlines"]'::jsonb, true,
  '["req_1", "req_2"]'::jsonb
FROM s
WHERE NOT EXISTS (
  SELECT 1 FROM public.practice_tasks pt WHERE pt.skill_id = s.id AND pt.title = 'Analyze LLM Tokenization and Streaming Responses'
);

-- ==========================================================================
-- Skill: ai-agents-basics
-- ==========================================================================

WITH s AS (SELECT id FROM public.skills WHERE slug = 'ai-agents-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'agentic-loops-and-react', 'Agentic Architectures: The ReAct Pattern', 'Learn how AI agents reason, plan, invoke tools, and observe feedback loops.', '# Agentic Architectures: The ReAct Pattern

Unlike simple text completion, an **AI Agent** possesses agency: it can plan multi-step tasks, call tools, inspect environmental feedback, and adjust its execution until a goal is achieved.

## The ReAct (Reason + Act) Loop

1. **Thought (Reasoning)**: The agent analyzes the user prompt and previous observations to decide what needs to happen next.
2. **Action (Tool Invocation)**: The agent emits a structured tool call (e.g. `grep_search`, `run_command`, `read_file`).
3. **Observation**: The runtime executes the tool and injects the output back into the agent''s context window.
4. **Repeat**: The loop continues until the agent determines the task is fully completed and outputs a final answer.

```mermaid
flowchart TD
    A[User Request] --> B[LLM Reasoning / Thought]
    B --> C{Tool Call Required?}
    C -- Yes --> D[Execute Tool]
    D --> E[Inject Observation into Context]
    E --> B
    C -- No --> F[Final Answer to User]
```

## Key Challenges in Agentic Systems

- **Infinite Loops**: Agents repeating the same failing action without course correction. Requires max-turn limits.
- **Context Bloat**: Large tool outputs exhausting the context window. Requires truncation and targeted tool design.
- **Hallucinated Tools**: Attempting to invoke tools not declared in the model schema.
```', 'intermediate', 30, 1, true
FROM s ON CONFLICT (skill_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  summary = EXCLUDED.summary,
  content_markdown = EXCLUDED.content_markdown,
  difficulty = EXCLUDED.difficulty,
  estimated_minutes = EXCLUDED.estimated_minutes,
  sort_order = EXCLUDED.sort_order;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'ai-agents-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'tool-use-and-agent-sandboxing', 'Tool Definition, Guardrails & Sandboxing', 'Design secure tool schemas and execute actions inside sandboxed environments.', '# Tool Definition, Guardrails & Sandboxing

Allowing an AI agent to execute actions on computer systems introduces significant security and stability considerations.

## Designing Clear Tool Schemas

Models perform significantly better when tools have precise descriptions, required parameters, and strict typing:

```json
{
  "name": "view_file",
  "description": "Reads contents of a file from disk within specified line ranges.",
  "parameters": {
    "type": "object",
    "properties": {
      "path": { "type": "string", "description": "Absolute filesystem path" },
      "start_line": { "type": "integer" },
      "end_line": { "type": "integer" }
    },
    "required": ["path"]
  }
}
```

## Security Guardrails: Sandboxing

Never give an autonomous agent unconstrained root access to production hosts:

1. **Container Isolation**: Run code execution inside ephemeral Docker containers or WebContainer browser sandboxes.
2. **Read-Only Defaults**: Give agents read-only tools by default; require explicit approval before modifying production data.
3. **Command Whitelisting**: Restrict execution to safe diagnostic commands (`ls`, `cat`, `grep`, `dig`).
```', 'intermediate', 35, 2, true
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
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'ai-agents-basics';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'In the ReAct pattern for AI agents, what step occurs immediately after the environment executes a tool call?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'In the ReAct pattern for AI agents, what step occurs immediately after the environment executes a tool call?', 'single', 'The Observation (tool result) is injected back into the LLM context so the agent can reason about the outcome.', 1, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'The agent terminates immediately', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'The tool output is returned to the agent as an Observation', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'The agent memory is wiped clean', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'The user session is locked', false, 4);
    END IF;
  END IF;
END $$;

DO $$
DECLARE
  v_skill_id UUID;
  v_q_id UUID;
BEGIN
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'ai-agents-basics';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Why should autonomous AI agents execute terminal commands inside ephemeral container sandboxes?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Why should autonomous AI agents execute terminal commands inside ephemeral container sandboxes?', 'single', 'Sandboxing prevents destructive actions, unauthorized network access, or accidental data loss on production host environments.', 2, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'To prevent destructive commands and isolate the execution environment', true, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Because LLMs cannot run on bare metal', false, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'To reduce API token costs', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Containers make code run at 100x speed', false, 4);
    END IF;
  END IF;
END $$;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'ai-agents-basics')
INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published, evidence_keys)
SELECT s.id, 'Analyze Agentic Tool Definitions and Guardrails', 'Inspect tool schemas, input parameters, and execution constraints.', 'Audit the tool definitions exposed to an AI engineering assistant.',
  '["Review tool schema structure","Verify required vs optional parameters"]'::jsonb, '["Tool parameters and validation rules confirmed"]'::jsonb, '["Well-formed tool schemas use JSON Schema standards"]'::jsonb, true,
  '["req_1", "req_2"]'::jsonb
FROM s
WHERE NOT EXISTS (
  SELECT 1 FROM public.practice_tasks pt WHERE pt.skill_id = s.id AND pt.title = 'Analyze Agentic Tool Definitions and Guardrails'
);

-- ==========================================================================
-- Skill: automation-workflows
-- ==========================================================================

WITH s AS (SELECT id FROM public.skills WHERE slug = 'automation-workflows')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'cron-scheduling-and-webhooks', 'Event-Driven Architecture: Webhooks & Cron', 'Automate system triggers using webhooks, event buses, and cron expressions.', '# Event-Driven Architecture: Webhooks & Cron

Modern IT automation transitions systems from synchronous polling to reactive, event-driven workflows.

## Cron Expression Syntax

Cron runs scheduled jobs at periodic intervals. A standard 5-field cron expression:

```
┌───────────── Minute (0 - 59)
│ ┌───────────── Hour (0 - 23)
│ │ ┌───────────── Day of Month (1 - 31)
│ │ │ ┌───────────── Month (1 - 12)
│ │ │ │ ┌───────────── Day of Week (0 - 6, 0 = Sunday)
│ │ │ │ │
* * * * *
```

### Common Cron Examples
- `*/15 * * * *`: Run every 15 minutes.
- `0 2 * * *`: Run daily at 02:00 AM.
- `0 0 * * 0`: Run weekly at midnight on Sunday.

## Webhooks: Push vs Pull

- **Polling (Pull)**: A client queries an endpoint every 60 seconds asking "Do you have new data?" Wastes bandwidth and compute.
- **Webhooks (Push)**: The source system sends an HTTP POST request to the receiver''s endpoint the instant an event occurs.

### Securing Webhooks with HMAC Signatures

To ensure incoming webhooks originate from the authentic provider and were not forged:

```typescript
import crypto from ''crypto'';

function verifyWebhook(payload: string, signature: string, secret: string): boolean {
  const hmac = crypto.createHmac(''sha256'', secret);
  const digest = ''sha256='' + hmac.update(payload).digest(''hex'');
  return crypto.timingSafeEqual(Buffer.from(digest), Buffer.from(signature));
}
```
```', 'intermediate', 30, 1, true
FROM s ON CONFLICT (skill_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  summary = EXCLUDED.summary,
  content_markdown = EXCLUDED.content_markdown,
  difficulty = EXCLUDED.difficulty,
  estimated_minutes = EXCLUDED.estimated_minutes,
  sort_order = EXCLUDED.sort_order;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'automation-workflows')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'error-handling-and-retries', 'Fault-Tolerant Automation: Idempotency & Retries', 'Implement exponential backoff, dead-letter queues, and idempotent workers.', '# Fault-Tolerant Automation: Idempotency & Retries

Networks are inherently unreliable. Distributed automation pipelines must survive transient outages without duplicating operations.

## The Idempotency Imperative

> **An operation is idempotent** if executing it multiple times produces the exact same result as executing it once.

For example:
- `SET balance = 100` is **idempotent**.
- `ADD balance, 10` is **not idempotent**.

In database writes, use unique constraints with `ON CONFLICT DO NOTHING` or idempotency keys to ensure repeated webhook deliveries do not create duplicate records.

## Exponential Backoff with Jitter

When an external service is down, retrying immediately at full speed can cause a self-inflicted Distributed Denial of Service (**Thundering Herd** problem):

```typescript
async function retryWithBackoff<T>(fn: () => Promise<T>, maxRetries = 5): Promise<T> {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await fn();
    } catch (err) {
      if (attempt === maxRetries - 1) throw err;
      // Exponential delay: 2^attempt * 1000ms + random jitter
      const jitter = Math.random() * 500;
      const delay = Math.pow(2, attempt) * 1000 + jitter;
      await new Promise(r => setTimeout(r, delay));
    }
  }
  throw new Error(''Unreachable'');
}
```
```', 'intermediate', 30, 2, true
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
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'automation-workflows';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'What does the cron expression "0 3 * * *" mean?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'What does the cron expression "0 3 * * *" mean?', 'single', 'Minute 0, Hour 3, every day of month, month, and day of week translates to "Run daily at 3:00 AM".', 1, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Run every 3 minutes', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Run every day at 3:00 AM', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Run every 3 hours', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Run on the 3rd day of every month', false, 4);
    END IF;
  END IF;
END $$;

DO $$
DECLARE
  v_skill_id UUID;
  v_q_id UUID;
BEGIN
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'automation-workflows';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Why is adding random "jitter" recommended when implementing exponential backoff retries?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Why is adding random "jitter" recommended when implementing exponential backoff retries?', 'single', 'Jitter prevents all failed clients from retrying simultaneously at the exact same second, avoiding thundering herd spikes.', 2, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It prevents synchronized retry spikes (thundering herd problem)', true, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It encrypts the payload', false, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It reduces CPU temperature', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It bypasses API authentication', false, 4);
    END IF;
  END IF;
END $$;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'automation-workflows')
INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published, evidence_keys)
SELECT s.id, 'Design an Idempotent Webhook Processing Flow', 'Implement deduplication logic using idempotency keys and error handling.', 'Process external payment and enrollment event webhooks safely.',
  '["Inspect webhook signature verification pattern","Validate idempotency constraint handling"]'::jsonb, '["Idempotency checks confirmed"]'::jsonb, '["Use unique idempotency keys stored in the database"]'::jsonb, true,
  '["req_1", "req_2"]'::jsonb
FROM s
WHERE NOT EXISTS (
  SELECT 1 FROM public.practice_tasks pt WHERE pt.skill_id = s.id AND pt.title = 'Design an Idempotent Webhook Processing Flow'
);

-- ==========================================================================
-- Skill: network-engineering-path
-- ==========================================================================

WITH s AS (SELECT id FROM public.skills WHERE slug = 'network-engineering-path')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'enterprise-switching-and-vlans', 'Enterprise Switching, VLANs & Trunking (802.1Q)', 'Segment broadcast domains using VLANs, 802.1Q tagging, and Spanning Tree.', '# Enterprise Switching, VLANs & Trunking (802.1Q)

Enterprise campus networks rely on Layer 2 switching to interconnect endpoints, servers, and wireless access points.

## Broadcast Domains & VLANs

A **Virtual Local Area Network (VLAN)** logically partitions a physical switch into multiple isolated broadcast domains:
- **Default VLAN 1**: Default native VLAN on enterprise switches.
- **Traffic Isolation**: Devices on VLAN 10 cannot communicate with devices on VLAN 20 without a Layer 3 router.

## Access Ports vs Trunk Ports (IEEE 802.1Q)

- **Access Port**: Carries traffic for a single untagged VLAN (typically connects to end-user PCs or printers).
- **Trunk Port**: Carries traffic for multiple VLANs across switches or to routers by inserting an **802.1Q tag** (4 bytes, including 12-bit VLAN ID) into the Ethernet frame header.

## Spanning Tree Protocol (STP / RSTP - 802.1w)

Physical redundant links between switches cause fatal **switching loops** and **broadcast storms** (frames circulating forever because Ethernet lacks a TTL field).
- **RSTP (Rapid Spanning Tree Protocol)**: Dynamically elects a Root Bridge and places redundant backup ports in a **Blocking** state, unblocking them in milliseconds if the primary link fails.
```', 'advanced', 35, 1, true
FROM s ON CONFLICT (skill_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  summary = EXCLUDED.summary,
  content_markdown = EXCLUDED.content_markdown,
  difficulty = EXCLUDED.difficulty,
  estimated_minutes = EXCLUDED.estimated_minutes,
  sort_order = EXCLUDED.sort_order;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'network-engineering-path')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'bgp-peering-and-mpls', 'BGP Peering, Autonomous Systems & WAN', 'Understand eBGP vs iBGP, Autonomous System Numbers (ASN), and WAN routing.', '# BGP Peering, Autonomous Systems & WAN

At carrier and enterprise cloud scales, Wide Area Network (WAN) routing is managed by the Border Gateway Protocol (**BGP**).

## Autonomous Systems (AS)

An **Autonomous System (AS)** is a collection of IP routing networks under the control of a single administrative entity (e.g. Google, Cloudflare, an ISP).
- Each AS is identified by a unique **ASN** (16-bit or 32-bit integer, e.g. AS15169 for Google).

## eBGP vs iBGP

- **eBGP (External BGP)**: Runs between routers in **different** Autonomous Systems (peering across the public Internet).
  - Default TTL = 1 (peers must typically be directly connected).
- **iBGP (Internal BGP)**: Runs between routers inside the **same** Autonomous System to distribute exterior routes across the internal backbone.

## Path Attributes & Routing Decisions

BGP is a path-vector protocol. When choosing the best path, BGP evaluates attributes in strict sequence:
1. **Weight** (Cisco proprietary, local to router; highest wins)
2. **Local Preference** (Global within AS; highest wins)
3. **Locally Originated Routes**
4. **Shortest AS_PATH** (Fewest Autonomous Systems traversed)
5. **Origin Code** (IGP < EGP < Incomplete)
6. **Lowest MED** (Multi-Exit Discriminator)
7. **eBGP over iBGP**
```', 'advanced', 40, 2, true
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
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'network-engineering-path';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'What IEEE standard defines VLAN tagging on Ethernet trunk links?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'What IEEE standard defines VLAN tagging on Ethernet trunk links?', 'single', 'IEEE 802.1Q defines the 4-byte tagging format inserted into Ethernet headers to distinguish traffic from multiple VLANs.', 1, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'IEEE 802.3', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'IEEE 802.11', false, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'IEEE 802.1Q', true, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'IEEE 802.1X', false, 4);
    END IF;
  END IF;
END $$;

DO $$
DECLARE
  v_skill_id UUID;
  v_q_id UUID;
BEGIN
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'network-engineering-path';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Why is Spanning Tree Protocol (STP) necessary on Layer 2 switched networks with redundant links?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Why is Spanning Tree Protocol (STP) necessary on Layer 2 switched networks with redundant links?', 'single', 'Ethernet frames have no TTL (Time-To-Live) field. Redundant links cause infinite switching loops and broadcast storms without STP.', 2, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'To prevent infinite switching loops and broadcast storms', true, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'To encrypt Ethernet frames', false, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'To allocate IP addresses', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'To throttle bandwidth', false, 4);
    END IF;
  END IF;
END $$;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'network-engineering-path')
INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published, evidence_keys)
SELECT s.id, 'Design an Enterprise VLAN and Subnet Scheme', 'Segment corporate campus networks into isolated Management, Voice, and User VLANs.', 'Architect the Layer 2 and Layer 3 boundary for a new regional office.',
  '["Allocate VLAN IDs and corresponding CIDR subnets","Plan 802.1Q trunk interconnects"]'::jsonb, '["VLAN and IP scheme validated without conflicts"]'::jsonb, '["Common convention: match VLAN ID with third octet (e.g. VLAN 10 -> 10.0.10.0/24)"]'::jsonb, true,
  '["req_1", "req_2"]'::jsonb
FROM s
WHERE NOT EXISTS (
  SELECT 1 FROM public.practice_tasks pt WHERE pt.skill_id = s.id AND pt.title = 'Design an Enterprise VLAN and Subnet Scheme'
);

-- ==========================================================================
-- Skill: soc-fundamentals-path
-- ==========================================================================

WITH s AS (SELECT id FROM public.skills WHERE slug = 'soc-fundamentals-path')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'siem-architecture-and-log-analysis', 'SIEM Architecture & Security Log Analysis', 'Ingest and correlate Windows Event Logs, Syslog, and identify indicators of attack.', '# SIEM Architecture & Security Log Analysis

A **Security Operations Center (SOC)** monitors, detects, and responds to cybersecurity incidents across an enterprise.

## What is a SIEM?

A **Security Information and Event Management (SIEM)** system (e.g. Splunk, Microsoft Sentinel, Elastic SIEM) aggregates logs from endpoints, servers, firewalls, and clouds.

Core capabilities:
1. **Centralized Ingestion**: Syslog, Windows Event Forwarding (WEF), and cloud APIs.
2. **Correlation Rules**: Detect patterns across independent sources (e.g. 5 failed logins on a workstation followed immediately by a successful login on the domain controller).
3. **Alerting & Dashboards**: Surfaces high-fidelity incidents to Tier 1 SOC analysts.

## Critical Windows Event IDs to Monitor

- **Event 4624**: Successful logon (Logon Type 10 = Remote Desktop, Logon Type 3 = Network share).
- **Event 4625**: Failed logon attempt (monitored for brute force and password spraying).
- **Event 4672**: Special privileges assigned to new logon (Admin rights).
- **Event 4688**: A new process was created (vital for detecting `powershell.exe` or `cmd.exe` spawned by web servers).
- **Event 7045**: A new service was installed (common persistence mechanism).
```', 'advanced', 35, 1, true
FROM s ON CONFLICT (skill_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  summary = EXCLUDED.summary,
  content_markdown = EXCLUDED.content_markdown,
  difficulty = EXCLUDED.difficulty,
  estimated_minutes = EXCLUDED.estimated_minutes,
  sort_order = EXCLUDED.sort_order;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'soc-fundamentals-path')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'incident-response-and-mitre-attck', 'Incident Response & The MITRE ATT&CK Framework', 'Map threat actor tactics, techniques, and procedures (TTPs) and execute IR playbooks.', '# Incident Response & The MITRE ATT&CK Framework

The **MITRE ATT&CK** (Adversarial Tactics, Techniques, and Common Knowledge) framework categorizes real-world threat actor behaviors.

## The 14 MITRE Tactics

From initial breach to objective:
1. **Reconnaissance**
2. **Resource Development**
3. **Initial Access** (Phishing, Exploit public-facing app)
4. **Execution** (PowerShell, Command interpreter)
5. **Persistence** (Scheduled task, Registry run keys)
6. **Privilege Escalation** (Exploitation for privilege)
7. **Defense Evasion** (Disabling antivirus, Masquerading)
8. **Credential Access** (LSASS dumping, Brute force)
9. **Discovery** (Network service scanning)
10. **Lateral Movement** (Remote Services, Pass the Hash)
11. **Collection** (Data from local system)
12. **Command and Control (C2)** (Application layer protocol)
13. **Exfiltration** (Exfiltration over C2 channel)
14. **Impact** (Data encrypted for impact / Ransomware)

## SANS 6-Phase Incident Response Lifecycle

1. **Preparation**: Hardening defenses, training staff, deploying EDR agents.
2. **Identification**: Detecting an anomaly and confirming it is a true positive security incident.
3. **Containment**: Isolating compromised endpoints from the network (quarantining).
4. **Eradication**: Removing malware, terminating backdoor processes, resetting credentials.
5. **Recovery**: Restoring systems from known-clean backups and monitoring for re-infection.
6. **Lessons Learned**: Writing a Post-Incident Report and tuning correlation rules.
```', 'advanced', 40, 2, true
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
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'soc-fundamentals-path';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Which Windows Security Event ID records failed account logon attempts, commonly monitored to detect brute force attacks?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Which Windows Security Event ID records failed account logon attempts, commonly monitored to detect brute force attacks?', 'single', 'Event 4625 is generated on Windows whenever an account fails to log on.', 1, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Event 4624', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Event 4625', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Event 1102', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Event 7045', false, 4);
    END IF;
  END IF;
END $$;

DO $$
DECLARE
  v_skill_id UUID;
  v_q_id UUID;
BEGIN
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'soc-fundamentals-path';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'In the SANS Incident Response lifecycle, what phase immediately follows the Identification of a verified breach?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'In the SANS Incident Response lifecycle, what phase immediately follows the Identification of a verified breach?', 'single', 'Containment must be executed immediately to prevent lateral movement and data exfiltration while preserving forensic evidence.', 2, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Lessons Learned', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Containment', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Recovery', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Preparation', false, 4);
    END IF;
  END IF;
END $$;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'soc-fundamentals-path')
INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published, evidence_keys)
SELECT s.id, 'Analyze Authentication Logs and Incident Triage', 'Triage security event logs to differentiate benign anomalies from malicious intrusions.', 'Review an alert reporting unusual off-hours administrator logins.',
  '["Inspect authentication event codes and logon types","Map observed activities to MITRE ATT&CK techniques"]'::jsonb, '["Logon anomalies identified","Tactics mapped correctly"]'::jsonb, '["Logon Type 10 represents Remote Desktop (RDP) connections"]'::jsonb, true,
  '["req_1", "req_2"]'::jsonb
FROM s
WHERE NOT EXISTS (
  SELECT 1 FROM public.practice_tasks pt WHERE pt.skill_id = s.id AND pt.title = 'Analyze Authentication Logs and Incident Triage'
);

-- ==========================================================================
-- Skill: ai-automation-engineering-path
-- ==========================================================================

WITH s AS (SELECT id FROM public.skills WHERE slug = 'ai-automation-engineering-path')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'retrieval-augmented-generation-rag', 'Enterprise RAG Architecture & Vector Databases', 'Build Retrieval-Augmented Generation pipelines using embeddings and vector search.', '# Enterprise RAG Architecture & Vector Databases

Retrieval-Augmented Generation (**RAG**) grounds Large Language Models on private enterprise documentation without expensive fine-tuning.

## The 4 Stages of a RAG Pipeline

```mermaid
flowchart LR
    A[Document Ingestion] --> B[Chunking]
    B --> C[Vector Embedding Model]
    C --> D[(Vector Database)]
    E[User Query] --> F[Query Embedding]
    F --> G[Cosine Similarity Search]
    D --> G
    G --> H[Context Injection + LLM Generation]
    H --> I[Grounded Answer]
```

1. **Chunking**: Documents (PDFs, Markdown, database rows) are split into semantically coherent segments (e.g. 500 tokens with 50-token overlap).
2. **Embedding**: A specialized model converts each text chunk into a high-dimensional vector of floating-point numbers (e.g. 768 or 1536 dimensions) capturing semantic meaning.
3. **Vector Indexing & Retrieval**: Vectors are indexed in vector databases (pgvector, Pinecone, Qdrant) using approximate nearest neighbor (ANN) algorithms (like HNSW).
4. **Augmented Generation**: The top-$k$ most similar document chunks are injected directly into the LLM system prompt as verified context.

## Using PostgreSQL with `pgvector`

```sql
-- Enable the vector extension in Supabase/PostgreSQL
CREATE EXTENSION IF NOT EXISTS vector;

-- Create table with vector column
CREATE TABLE knowledge_chunks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  content TEXT NOT NULL,
  embedding vector(1536)
);

-- Search using cosine distance operator (<=>)
SELECT content, 1 - (embedding <=> query_vector) AS similarity
FROM knowledge_chunks
WHERE 1 - (embedding <=> query_vector) > 0.8
ORDER BY similarity DESC
LIMIT 5;
```
```', 'advanced', 40, 1, true
FROM s ON CONFLICT (skill_id, slug) DO UPDATE SET
  title = EXCLUDED.title,
  summary = EXCLUDED.summary,
  content_markdown = EXCLUDED.content_markdown,
  difficulty = EXCLUDED.difficulty,
  estimated_minutes = EXCLUDED.estimated_minutes,
  sort_order = EXCLUDED.sort_order;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'ai-automation-engineering-path')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'multi-agent-orchestration-and-evals', 'Multi-Agent Orchestration & Evaluation Frameworks', 'Orchestrate collaborative agent teams and measure output quality with automated evaluations.', '# Multi-Agent Orchestration & Evaluation Frameworks

Complex enterprise workflows exceed the capacity of a single prompt or monolithic agent, requiring coordinated teams of specialized agents.

## Multi-Agent Topologies

- **Hierarchical (Supervisor Pattern)**: A lead planner agent receives the high-level objective, breaks it into subtasks, delegates to specialized worker agents (e.g. Research Agent, Coder Agent, Security Auditor), and synthesizes results.
- **Collaborative (Peer-to-Peer)**: Agents pass intermediate artifacts along a predefined state graph with clear transition conditions.

## The Evaluation (Evals) Framework

You cannot reliably improve an AI system without quantitative evaluation benchmarks:

1. **Deterministic Assertions**:
   - Schema validation (does the output parse as valid JSON conforming to the schema?).
   - Unit test pass rates (does generated code compile and pass automated tests?).
2. **Model-Graded Evals (LLM-as-a-Judge)**:
   - Use an advanced frontier model (like Gemini 1.5 Pro) with a structured rubric to evaluate faithfulness, toxicity, and relevance on a 1-5 scale.
3. **Regression Testing**:
   - Run benchmark test suites on every prompt change or model version upgrade to catch regressions.
```', 'advanced', 45, 2, true
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
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'ai-automation-engineering-path';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'In a Retrieval-Augmented Generation (RAG) system, what mathematical measurement is commonly used to find the most relevant document chunks for a query embedding?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'In a Retrieval-Augmented Generation (RAG) system, what mathematical measurement is commonly used to find the most relevant document chunks for a query embedding?', 'single', 'Cosine similarity (or cosine distance) measures the angle between high-dimensional embedding vectors, indicating semantic similarity.', 1, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Hamming distance', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Cosine similarity', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Fourier transform', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'MD5 hash matching', false, 4);
    END IF;
  END IF;
END $$;

DO $$
DECLARE
  v_skill_id UUID;
  v_q_id UUID;
BEGIN
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'ai-automation-engineering-path';
  IF v_skill_id IS NOT NULL THEN
    -- Check if question already exists
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'What is the primary advantage of the Hierarchical Supervisor pattern in multi-agent systems?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'What is the primary advantage of the Hierarchical Supervisor pattern in multi-agent systems?', 'single', 'A supervisor agent breaks complex goals into manageable sub-goals, delegates to specialized agents, and prevents context exhaustion.', 2, true)
      RETURNING id INTO v_q_id;

      -- Insert options
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It eliminates the need for tool definitions', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It structures task decomposition and coordinates specialized subagents', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It reduces all latency to 0ms', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It bypasses LLM token limits entirely', false, 4);
    END IF;
  END IF;
END $$;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'ai-automation-engineering-path')
INSERT INTO public.practice_tasks (skill_id, title, objective, context, requirements, success_criteria, hints, is_published, evidence_keys)
SELECT s.id, 'Design a Multi-Agent RAG Pipeline', 'Define chunking parameters, vector similarity queries, and multi-agent coordination steps.', 'Architect an enterprise internal documentation question-answering agent.',
  '["Define embedding dimensions and chunk size with overlap","Draft supervisor agent delegation flow"]'::jsonb, '["RAG architecture and agent topology documented"]'::jsonb, '["Chunk sizes between 256 and 512 tokens with 10% overlap provide good balance"]'::jsonb, true,
  '["req_1", "req_2"]'::jsonb
FROM s
WHERE NOT EXISTS (
  SELECT 1 FROM public.practice_tasks pt WHERE pt.skill_id = s.id AND pt.title = 'Design a Multi-Agent RAG Pipeline'
);

