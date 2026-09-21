-- 014_advanced_curriculum_expansion.sql
-- Comprehensive Advanced modules for all 26 skills

-- Skill: computer-basics
WITH s AS (SELECT id FROM public.skills WHERE slug = 'computer-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'kernel-init-and-pcie-interrupts', 'Kernel Initialization, Interrupts & Device Drivers', 'Explore hardware interrupts (IRQs), MSI-X, DMA channels, and kernel device driver interfaces.', '# Kernel Initialization, Interrupts & Device Drivers

At the enterprise hardware boundary, the operating system interacts with physical circuits via hardware interrupts, memory-mapped I/O, and Direct Memory Access (DMA).

## Hardware Interrupts (IRQs) & MSI-X

When a Network Interface Card (NIC) or NVMe controller receives data, it signals the CPU using an **Interrupt Request (IRQ)**:

- **Legacy Line Interrupts**: Shared physical interrupt lines (pin-based IRQ 0-15); high latency and collision prone.
- **MSI / MSI-X (Message Signaled Interrupts)**: Writes a small message to a specific host memory address over PCIe, generating dedicated per-core interrupt vectors (up to 2,048 distinct vectors per device).

## Direct Memory Access (DMA)

CPU cycles are too precious to spend copying individual packet bytes from network cards into RAM:

- **Bus Master DMA**: The peripheral device controller writes packets directly into pre-allocated ring buffers in physical host RAM without interrupting the CPU until a batch is ready.
- **IOMMU (I/O Memory Management Unit)**: Translates device virtual addresses to physical addresses, providing memory protection and enabling secure SR-IOV device passthrough to virtual machines.

## Enterprise Hardware Diagnostics

```bash
# Inspect real-time interrupt distribution across all CPU cores
cat /proc/interrupts | head -n 30

# Check PCI device capabilities (MSI-X vectors, link speed)
sudo lspci -vvv -s 00:03.0 | grep -i -E "msi-x|lnkcap"

# View kernel driver bindings
lspci -k
```', 'advanced', 35, 3, true
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
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'computer-basics';
  IF v_skill_id IS NOT NULL THEN
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'How does Direct Memory Access (DMA) improve computer system throughput?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'How does Direct Memory Access (DMA) improve computer system throughput?', 'single', 'DMA allows high-speed peripheral devices (NICs, NVMe drives) to read and write directly to host RAM without consuming CPU cycles for every byte.', 10 + 0, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It doubles the CPU clock frequency', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It allows peripherals to transfer data directly to/from RAM without CPU intervention', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It bypasses hardware power supplies', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It encrypts all network packets in hardware', false, 4);
    END IF;
  END IF;
END $$;

-- Skill: cpu-memory-storage
WITH s AS (SELECT id FROM public.skills WHERE slug = 'cpu-memory-storage')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'ebpf-profiling-and-cpu-scheduling', 'Linux CPU Scheduling Internals & eBPF Profiling', 'Master CFS scheduler dynamics, CPU pinning, NUMA affinity, and off-CPU profiling with BCC/bpftrace.', '# Linux CPU Scheduling Internals & eBPF Profiling

High-throughput database engines and low-latency financial systems demand granular control over how the Linux kernel schedules threads onto physical CPU cores.

## The Completely Fair Scheduler (CFS)

The Linux kernel implements the **Completely Fair Scheduler (CFS)** using a red-black tree indexed by `vruntime` (virtual runtime):

- **Virtual Runtime (`vruntime`)**: Measures the amount of CPU execution time spent by each process, weighted by its `nice` value (-20 highest priority to +19 lowest priority).
- The scheduler always picks the process with the smallest `vruntime` sitting at the leftmost node of the red-black tree.

## Non-Uniform Memory Access (NUMA) Topology

Multi-socket servers group CPU cores and physical RAM channels into **NUMA nodes**:

- **Local Memory Access**: A CPU accessing RAM physically attached to its own socket (~60ns latency).
- **Remote Memory Access**: A CPU accessing RAM attached to another socket across the Ultra Path Interconnect (UPI) bus (~100-140ns latency).

```bash
# View NUMA nodes and core layout
numactl --hardware

# Bind a high-performance database process to NUMA Node 0
numactl --cpunodebind=0 --membind=0 /usr/bin/clickhouse-server
```

## Deep Observability with eBPF and `bpftrace`

Extended Berkeley Packet Filter (**eBPF**) executes sandboxed bytecode in the Linux kernel without recompiling the kernel or loading kernel modules.

```bash
# Profile CPU on-stack execution time (flame graphs)
sudo bpftrace -e ''profile:hz:99 { @[kstack] = count(); }''

# Measure time processes spend waiting in run-queues (scheduling latency)
sudo runqlat-bpfcc 1 10
```', 'advanced', 40, 3, true
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
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'In a multi-socket server, what is the performance penalty of accessing Remote NUMA memory compared to Local NUMA memory?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'In a multi-socket server, what is the performance penalty of accessing Remote NUMA memory compared to Local NUMA memory?', 'single', 'Remote NUMA access must traverse inter-socket interconnects (UPI/Infinity Fabric), resulting in roughly 1.5x to 2x higher latency.', 10 + 0, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Remote memory access has identical latency', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Remote access incurs significantly higher latency and bus contention', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Remote memory is 10x faster', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Remote access is forbidden by hardware', false, 4);
    END IF;
  END IF;
END $$;

-- Skill: processes-services
WITH s AS (SELECT id FROM public.skills WHERE slug = 'processes-services')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'cgroups-v2-and-namespaces', 'Cgroups v2 & Linux Namespaces: The Core of Containers', 'Deep dive into cgroups v2 resource controllers (cpu.max, memory.max) and the 8 Linux namespaces.', '# Cgroups v2 & Linux Namespaces: The Core of Containers

Containers are not real physical machines; they are standard Linux processes isolated by **Namespaces** and throttled by **Control Groups (cgroups)**.

## The 8 Linux Kernel Namespaces

Namespaces isolate global system resources per process:

1. **PID**: Isolates process IDs (container process sees itself as PID 1).
2. **NET**: Isolates network devices, IP routing tables, and firewall rules.
3. **MNT**: Isolates filesystem mount points (creates private root filesystem).
4. **IPC**: Isolates System V IPC and POSIX message queues.
5. **UTS**: Isolates hostname and domain name.
6. **USER**: Maps container user UID 0 (root) to an unprivileged UID (10001) on the host.
7. **CGROUP**: Isolates cgroup root hierarchy view.
8. **TIME**: Isolates monotonic and boot clocks.

## Cgroups v2: Unified Resource Control

In modern Linux kernels, `cgroups v2` provides a single unified hierarchy mounted at `/sys/fs/cgroup`:

```bash
# Create a new control group
sudo mkdir /sys/fs/cgroup/production_db

# Restrict group to 2 CPU cores (200,000 microseconds per 100,000 period)
echo "200000 100000" | sudo tee /sys/fs/cgroup/production_db/cpu.max

# Restrict group to 4GB of physical RAM
echo "4294967296" | sudo tee /sys/fs/cgroup/production_db/memory.max

# Attach a running process to the cgroup
echo <PID> | sudo tee /sys/fs/cgroup/production_db/cgroup.procs
```

## Exploring Namespaces with `nsenter` and `unshare`

```bash
# Spawn a new shell inside an isolated network and UTS namespace
sudo unshare --net --uts /bin/bash

# Enter the network namespace of a running Docker container
sudo nsenter -t <CONTAINER_PID> -n ip addr
```', 'advanced', 40, 3, true
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
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Which Linux kernel feature is responsible for limiting and throttling CPU, memory, and I/O consumption for a group of processes?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Which Linux kernel feature is responsible for limiting and throttling CPU, memory, and I/O consumption for a group of processes?', 'single', 'Control Groups (cgroups) allocate, meter, and throttle hardware resources among processes.', 10 + 0, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Namespaces', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Control Groups (cgroups)', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'SELinux', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'SysV Init', false, 4);
    END IF;
  END IF;
END $$;

-- Skill: filesystem-basics
WITH s AS (SELECT id FROM public.skills WHERE slug = 'filesystem-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'journaling-cow-and-zfs', 'Journaling, Copy-on-Write (CoW) & Modern ZFS/Btrfs', 'Understand crash consistency, ext4 writeback vs ordered journaling, and ZFS snapshot mechanics.', '# Journaling, Copy-on-Write (CoW) & Modern ZFS/Btrfs

When power fails mid-write, traditional filesystems become corrupted. Modern storage architectures ensure transactional crash consistency.

## Journaling Architectures (ext4 / XFS)

A journal is a dedicated circular log area on disk:

1. **Transaction Written to Journal**: Metadata and data changes are committed sequentially to the journal.
2. **Commit Record**: A cryptographic checksum marker commits the atomic transaction.
3. **Checkpoint to In-Place Blocks**: Data is written to final disk blocks.
4. **Crash Recovery**: Upon reboot, `fsck` replays incomplete journal entries in milliseconds rather than scanning petabytes of storage.

## Copy-on-Write (CoW) Filesystems: ZFS & Btrfs

CoW filesystems **never overwrite active data blocks in place**:

- When a block is modified, the new version is written to a **new, empty block**.
- Pointer metadata is updated up the Merkle tree to point to the new block.
- **Zero-Cost Instant Snapshots**: A snapshot simply preserves the root pointer; no data is copied.
- **Self-Healing Silent Data Corruption (Bit Rot)**: Every block stores a 256-bit checksum (SHA-256 or BLAKE3). When reading, if the checksum fails, ZFS repairs the damaged block automatically from redundant RAID-Z mirror copies.

## ZFS Enterprise Commands

```bash
# Create a mirrored storage pool across two NVMe drives
sudo zpool create -f tank mirror /dev/nvme0n1 /dev/nvme1n1

# Take an instant snapshot of the database filesystem
sudo zfs snapshot tank/data@backup_2026

# List all snapshots with space consumption
zfs list -t snapshot
```', 'advanced', 35, 3, true
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
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Why do Copy-on-Write (CoW) filesystems like ZFS enable instantaneous, zero-storage snapshots?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Why do Copy-on-Write (CoW) filesystems like ZFS enable instantaneous, zero-storage snapshots?', 'single', 'CoW never overwrites data blocks in place; taking a snapshot merely pins existing pointers without copying physical data until changes occur.', 10 + 0, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'They compress all files with ZIP algorithms', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'They freeze block pointers without duplicating data blocks', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'They write data to cloud buckets', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'They shut down disk read heads', false, 4);
    END IF;
  END IF;
END $$;

-- Skill: ip-addressing
WITH s AS (SELECT id FROM public.skills WHERE slug = 'ip-addressing')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'ipv6-architecture-and-dual-stack', 'IPv6 Architecture, SLAAC & Dual-Stack Operations', 'Master 128-bit IPv6 address structure, Stateless Address Autoconfiguration (SLAAC), and enterprise dual-stack.', '# IPv6 Architecture, SLAAC & Dual-Stack Operations

With the complete exhaustion of IPv4 address pools, enterprise infrastructure requires robust IPv6 engineering.

## IPv6 Address Structure (128 Bits)

IPv6 addresses are written as 8 groups of 4 hexadecimal digits separated by colons:

```
2001:0db8:85a3:0000:0000:8a2e:0370:7334
```

Compression Rules:
1. **Omit Leading Zeros**: `0000` -> `0`, `0db8` -> `db8`.
2. **Double Colon (`::`)**: Replace consecutive groups of zeros once per address:
   ```
   2001:db8:85a3::8a2e:370:7334
   ```

## IPv6 Address Scopes

- **Global Unicast (`2000::/3`)**: Globally routable on the public Internet.
- **Link-Local (`fe80::/10`)**: Mandatory on every interface; auto-configured and strictly non-routable beyond the local physical wire.
- **Loopback (`::1/128`)**: Localhost equivalent of `127.0.0.1`.
- **Multicast (`ff00::/8`)**: Replaces broadcast entirely (IPv6 has no broadcast addresses).

## Stateless Address Autoconfiguration (SLAAC)

IPv6 devices configure themselves without a stateful DHCP server:

1. Host brings up link-local address (`fe80::/64`).
2. Host multicasts a **Router Solicitation (RS)** packet to `ff02::2`.
3. Local router replies with a **Router Advertisement (RA)** containing the global network prefix (`2001:db8:1::/64`).
4. Host generates its interface identifier (using EUI-64 or randomized privacy extensions) and performs Duplicate Address Detection (DAD).

```bash
# View IPv6 addresses and neighbors
ip -6 addr show
ip -6 neigh show

# Ping IPv6 Google DNS
ping6 2001:4860:4860::8888
```', 'advanced', 35, 3, true
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
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'ip-addressing';
  IF v_skill_id IS NOT NULL THEN
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Which IPv6 address prefix designates mandatory Link-Local addresses used strictly within a single local network segment?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Which IPv6 address prefix designates mandatory Link-Local addresses used strictly within a single local network segment?', 'single', 'fe80::/10 is the reserved prefix for IPv6 Link-Local unicast addresses, communicating within a single Layer 2 broadcast domain.', 10 + 0, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '::1/128', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'fe80::/10', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '2000::/3', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'ff02::1', false, 4);
    END IF;
  END IF;
END $$;

-- Skill: subnetting
WITH s AS (SELECT id FROM public.skills WHERE slug = 'subnetting')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'cidr-aggregation-and-supernetting', 'Route Summarization, Supernetting & BGP Aggregation', 'Aggregate multiple contiguous subnets into summary prefixes to shrink global routing tables.', '# Route Summarization, Supernetting & BGP Aggregation

Without route summarization (supernetting), core Internet and enterprise routers would exhaust memory and CPU attempting to track millions of individual subnets.

## What is Supernetting?

Supernetting combines multiple smaller, contiguous network prefixes into a single, broader summary prefix by moving the subnet boundary to the left.

### Aggregation Example:

Suppose an ISP router manages four contiguous `/24` subnets:
- `192.168.0.0/24` = `11000000.10101000.00000000.00000000`
- `192.168.1.0/24` = `11000000.10101000.00000001.00000000`
- `192.168.2.0/24` = `11000000.10101000.00000010.00000000`
- `192.168.3.0/24` = `11000000.10101000.00000011.00000000`

Observe the 3rd octet binary representation:
The first 6 bits of the 3rd octet are identical (`000000`).
- Common prefix length: $16 + 6 = 22$ bits.
- **Summarized Supernet Route**: `192.168.0.0/22` (encompassing all 4 subnets in a single routing table entry).

## Prerequisites for Successful Summarization

1. The network blocks must be strictly **contiguous** in address space.
2. The number of subnets must equal a power of 2 ($2, 4, 8, 16, \dots$).
3. The summary prefix must begin on a mathematically valid binary boundary.
```', 'advanced', 35, 3, true
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
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'What single summarized prefix encompasses the four contiguous subnets 10.0.0.0/24, 10.0.1.0/24, 10.0.2.0/24, and 10.0.3.0/24?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'What single summarized prefix encompasses the four contiguous subnets 10.0.0.0/24, 10.0.1.0/24, 10.0.2.0/24, and 10.0.3.0/24?', 'single', 'Borrowing 2 bits from the third octet reduces prefix length from /24 to /22, summarizing all 4 contiguous /24 networks into 10.0.0.0/22.', 10 + 0, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '10.0.0.0/16', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '10.0.0.0/22', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '10.0.0.0/20', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '10.0.0.0/23', false, 4);
    END IF;
  END IF;
END $$;

-- Skill: dns
WITH s AS (SELECT id FROM public.skills WHERE slug = 'dns')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'dnssec-doh-and-bind-security', 'DNSSEC Cryptographic Validation & Encrypted DNS (DoH/DoT)', 'Prevent DNS cache poisoning with cryptographic RRSIG validation and secure recursive resolvers.', '# DNSSEC Cryptographic Validation & Encrypted DNS (DoH/DoT)

Traditional DNS transmits queries in plaintext over UDP port 53 without authentication, enabling Man-in-the-Middle (MitM) cache poisoning attacks.

## DNSSEC: Cryptographic Authenticity

**DNS Security Extensions (DNSSEC)** adds cryptographic signatures to DNS records using public-key cryptography:

- **RRSIG (Resource Record Signature)**: Digital signature over a record set (RRset) signed by the Zone-Signing Key (ZSK).
- **DNSKEY**: Public key used by resolvers to verify RRSIG signatures.
- **DS (Delegation Signer)**: A hash of the child zone''s Key-Signing Key (KSK) placed in the parent zone (e.g. `.com`), forming an unbroken **Chain of Trust** back to the ICANN Root Key.
- **NSEC3**: Cryptographically proves that a requested domain name does not exist without permitting zone enumeration (zone walking).

## Encrypted DNS Protocols

| Protocol | Port | Transport | Privacy Protection |
|---|---|---|---|
| Traditional DNS | 53 | Plaintext UDP/TCP | None (ISP/snoopers see all queries) |
| **DoT (DNS over TLS)** | 853 | TLS wrapper | Encrypted; distinct port easily filtered |
| **DoH (DNS over HTTPS)** | 443 | HTTPS / HTTP/2 | Encrypted; blends with standard web traffic |

## Inspecting DNSSEC Signatures with `dig`

```bash
# Query with DNSSEC OK (+dnssec) flag and check for Authenticated Data (ad) flag
dig @8.8.8.8 cloudflare.com +dnssec +multiline
```', 'advanced', 35, 3, true
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
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'In DNSSEC, what flag in the DNS response header confirms that the resolver successfully verified cryptographic signatures back to the root trust anchor?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'In DNSSEC, what flag in the DNS response header confirms that the resolver successfully verified cryptographic signatures back to the root trust anchor?', 'single', 'The "ad" (Authenticated Data) flag in the header indicates that the recursive resolver validated all cryptographic RRSIG and DS records.', 10 + 0, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'qr flag', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'aa flag', false, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'ad (Authenticated Data) flag', true, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'tc flag', false, 4);
    END IF;
  END IF;
END $$;

-- Skill: routing
WITH s AS (SELECT id FROM public.skills WHERE slug = 'routing')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'evpn-vxlan-data-center-fabrics', 'EVPN-VXLAN Data Center Fabric Architecture', 'Scale multi-tenant clouds using Virtual Extensible LAN (VXLAN) overlays and MP-BGP EVPN.', '# EVPN-VXLAN Data Center Fabric Architecture

Modern cloud data centers discard legacy Spanning Tree switching in favor of routed Layer 3 **Leaf-Spine fabrics** using **VXLAN overlays**.

## The Limitations of VLANs in Cloud

- VLANs use a 12-bit ID, limiting data centers to a maximum of 4,094 networks.
- Spanning Tree blocks redundant links to prevent loops, wasting 50% of available switch bandwidth.

## VXLAN (Virtual Extensible LAN) Encapsulation

VXLAN encapsulates Layer 2 Ethernet frames inside standard Layer 3 **UDP packets** (destination UDP port **4789**):

- **VNI (VXLAN Network Identifier)**: 24-bit identifier supporting **16 million virtual overlay networks**.
- **Underlay**: An all-routed Equal-Cost Multi-Path (ECMP) IP network connecting Spine and Leaf switches.
- **Overlay**: The virtual Layer 2 domain stretched transparently across the routed underlay.
- **VTEP (VXLAN Tunnel Endpoint)**: Switch hardware that encapsulates/decapsulates packets entering/leaving the fabric.

## MP-BGP EVPN Control Plane

Instead of using flood-and-learn multicast, **Ethernet VPN (EVPN)** uses Multi-Protocol BGP to distribute MAC and IP reachability data deterministically across VTEPs.
```', 'advanced', 40, 3, true
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
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'How many distinct virtual overlay networks does VXLAN support with its 24-bit VXLAN Network Identifier (VNI)?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'How many distinct virtual overlay networks does VXLAN support with its 24-bit VXLAN Network Identifier (VNI)?', 'single', '2^24 = 16,777,216 distinct virtual broadcast domains, solving the 4,094 VLAN limit.', 10 + 0, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '4,096', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '65,536', false, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Over 16 million (16,777,216)', true, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '1,024', false, 4);
    END IF;
  END IF;
END $$;

-- Skill: linux-cli
WITH s AS (SELECT id FROM public.skills WHERE slug = 'linux-cli')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'advanced-bash-and-posix-scripting', 'Advanced Bash Scripting, Signals & Trap Handlers', 'Write robust, defensive shell automation with strict mode, subshells, arrays, and signals.', '# Advanced Bash Scripting, Signals & Trap Handlers

Enterprise shell scripts require strict error handling, signal interceptors, and atomic lock files to avoid silent corruption.

## Unofficial Bash Strict Mode

Always begin production Bash scripts with:

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$''\n\t''
```

- **`set -e`**: Exit immediately if any command returns a non-zero exit status.
- **`set -u`**: Treat unset variables as an error and exit immediately.
- **`set -o pipefail`**: A pipeline produces a failure return code if *any* command in the pipeline fails (not just the last one).
- **`IFS=$''\n\t''`**: Prevents word-splitting bugs on spaces.

## Graceful Cleanup with `trap`

When an administrator cancels a script with `Ctrl+C` (SIGINT) or the script terminates, temporary lock files must be cleaned up:

```bash
LOCKFILE="/tmp/myscript.lock"

cleanup() {
  echo "Caught exit signal — cleaning up resources..."
  rm -f "$LOCKFILE"
}

# Trap EXIT, SIGINT (2), and SIGTERM (15)
trap cleanup EXIT INT TERM

# Create exclusive lockfile using noclobber
if ! (set -o noclobber; echo "$$" > "$LOCKFILE") 2>/dev/null; then
  echo "Error: Another instance is already running!" >&2
  exit 1
fi
```', 'advanced', 35, 4, true
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
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'linux-cli';
  IF v_skill_id IS NOT NULL THEN
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'What is the effect of "set -o pipefail" in a Bash script?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'What is the effect of "set -o pipefail" in a Bash script?', 'single', 'pipefail ensures the pipeline returns the exit code of the last failing command, rather than always reporting the exit code of the final command in the pipeline.', 10 + 0, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It compresses pipeline outputs with gzip', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It causes the pipeline to return a non-zero exit code if any command in the chain fails', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It suppresses all standard error output', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It disables pipes entirely', false, 4);
    END IF;
  END IF;
END $$;

-- Skill: linux-permissions
WITH s AS (SELECT id FROM public.skills WHERE slug = 'linux-permissions')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'selinux-and-posix-acls', 'SELinux Mandatory Access Control (MAC) & POSIX ACLs', 'Enforce type enforcement, security contexts, audit2allow, and setfacl extended permissions.', '# SELinux Mandatory Access Control (MAC) & POSIX ACLs

Standard Linux permissions (DAC) fail when a compromised root process can read any file. **Security-Enhanced Linux (SELinux)** enforces mandatory policy across all subjects and objects.

## Discretionary (DAC) vs Mandatory Access Control (MAC)

- **DAC (chmod/chown)**: Process running as UID 0 (`root`) bypasses all file permissions.
- **MAC (SELinux)**: Even `root` cannot access a file unless the explicit compiled SELinux policy allows it.

## SELinux Security Contexts

Every process and file has a security label formatted as `user:role:type:level`:

```bash
# View process security context
ps -eZ | grep nginx
# system_u:system_r:httpd_t:s0

# View file security label
ls -laZ /var/www/html/
# unconfined_u:object_r:httpd_sys_content_t:s0
```

If Nginx (`httpd_t`) attempts to read a database file labeled `mysqld_db_t`, the Linux kernel denies access, even if Nginx runs as root!

## Troubleshooting SELinux Denials

```bash
# Check current SELinux enforcement mode (Enforcing / Permissive / Disabled)
getenforce

# View AVC denials in real-time
sudo ausearch -m avc -ts recent

# Restore default SELinux context on a directory tree
sudo restorecon -Rv /var/www/html/
```

## Granular POSIX ACLs (`setfacl`)

When multiple groups need distinct read/write access:

```bash
# Grant user bob read/write access without changing primary group
sudo setfacl -m u:bob:rw- /data/shared.csv

# View active Access Control Lists
getfacl /data/shared.csv
```', 'advanced', 40, 3, true
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
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'linux-permissions';
  IF v_skill_id IS NOT NULL THEN
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'In SELinux, what component of the security context label (user:role:type:level) is evaluated for Type Enforcement access decisions?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'In SELinux, what component of the security context label (user:role:type:level) is evaluated for Type Enforcement access decisions?', 'single', 'Type Enforcement evaluates the "type" attribute (e.g. httpd_t, httpd_sys_content_t) to govern permissions between processes and objects.', 10 + 0, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'User', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Role', false, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Type', true, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Level', false, 4);
    END IF;
  END IF;
END $$;

-- Skill: linux-networking
WITH s AS (SELECT id FROM public.skills WHERE slug = 'linux-networking')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'kernel-network-tuning-and-ebpf-xdp', 'Kernel Network Tuning, sysctl & eXpress Data Path (XDP)', 'Optimize TCP buffer sizes, conntrack limits, and process 10Gbps+ packet filtering with eBPF/XDP.', '# Kernel Network Tuning, sysctl & eXpress Data Path (XDP)

Default Linux kernel network parameters are tuned for desktop workloads. High-concurrency reverse proxies and edge routers require custom kernel tuning.

## Essential Network Sysctl Tuning (`/etc/sysctl.d/99-network.conf`)

```ini
# Maximize socket listen backlog for high connection spikes
net.core.somaxconn = 65535

# Increase connection tracking table capacity (prevents dropped connections)
net.netfilter.nf_conntrack_max = 1048576

# Enable TCP BBR congestion control algorithm (significantly improves throughput)
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# Enlarge TCP read/write buffer windows (Bandwidth-Delay Product)
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

# Enable TCP SYN Cookies to survive SYN Flood attacks
net.ipv4.tcp_syncookies = 1
```

Apply changes immediately:
```bash
sudo sysctl --system
```

## High-Speed Filtering with XDP (eXpress Data Path)

Standard Linux packet filtering (iptables/nftables) operates after the kernel allocates an `sk_buff` data structure in RAM (~few million packets/sec).

**XDP** attaches eBPF bytecode directly inside the network card driver before `sk_buff` allocation:
- Drops malicious DDoS packets in nanoseconds (**XDP_DROP**).
- Achieves line-rate packet processing (**24+ million packets/sec** per core).
```', 'advanced', 40, 3, true
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
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Why does eXpress Data Path (XDP) achieve line-rate 10GbE/40GbE packet filtering compared to standard iptables firewalls?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Why does eXpress Data Path (XDP) achieve line-rate 10GbE/40GbE packet filtering compared to standard iptables firewalls?', 'single', 'XDP runs eBPF programs directly inside the network driver layer before the Linux kernel allocates expensive sk_buff socket buffers.', 10 + 0, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It converts IPv4 packets to IPv6', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It runs before the kernel allocates sk_buff memory buffers', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It uses GPU acceleration only', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It disables TCP checksum validation', false, 4);
    END IF;
  END IF;
END $$;

-- Skill: ssh
WITH s AS (SELECT id FROM public.skills WHERE slug = 'ssh')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'ssh-certificates-and-bastions', 'SSH Certificates, Bastion Jump Hosts & FIDO2 Enclaves', 'Replace fragile authorized_keys files with cryptographic SSH Certificate Authorities and hardware security tokens.', '# SSH Certificates, Bastion Jump Hosts & FIDO2 Enclaves

Managing thousands of individual public keys in `~/.ssh/authorized_keys` across hundreds of servers does not scale and introduces severe credential sprawl.

## SSH Certificate Authorities (SSH CA)

Instead of trusting individual user keys, servers trust a single **Certificate Authority (CA) public key**:

1. Security team operates a CA root key (`ca-user-key`).
2. Learner/engineer generates standard SSH key pair.
3. CA signs user public key, issuing a short-lived **SSH Certificate** (`id_ed25519-cert.pub`) with validity constraints (e.g. valid for 8 hours, principal `ops-team`).
4. Servers configure `/etc/ssh/sshd_config`:
   ```
   TrustedUserCAKeys /etc/ssh/ca-user-key.pub
   ```
5. Any valid certificate signed by the CA is accepted instantly without modifying the server.

## Bastion / Jump Host Proxying (`ProxyJump`)

Never expose private backend database nodes directly to the Internet. Connect through a hardened Bastion host using `~/.ssh/config`:

```ssh-config
Host bastion
    HostName bastion.example.com
    User admin
    IdentityFile ~/.ssh/id_ed25519

Host db-internal
    HostName 10.0.2.50
    User dbadmin
    ProxyJump bastion
```

Now connect seamlessly with:
```bash
ssh db-internal
```

## Hardware-Backed Keys with FIDO2 / YubiKey

Generate keys that physically require hardware touch:
```bash
ssh-keygen -t ed25519-sk -O resident
```', 'advanced', 35, 3, true
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
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'ssh';
  IF v_skill_id IS NOT NULL THEN
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'What is the primary operational advantage of SSH Certificate Authorities over traditional authorized_keys deployment?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'What is the primary operational advantage of SSH Certificate Authorities over traditional authorized_keys deployment?', 'single', 'Servers only need to trust the CA public key; short-lived user certificates grant access without adding or revoking keys on individual host machines.', 10 + 0, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Passwords can be reused on every server', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Servers trust the CA signature, eliminating the need to sync keys to every server', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It eliminates SSH encryption overhead', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It allows telnet connections over port 22', false, 4);
    END IF;
  END IF;
END $$;

-- Skill: python-basics
WITH s AS (SELECT id FROM public.skills WHERE slug = 'python-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'asyncio-and-concurrency-patterns', 'Asynchronous Python: Asyncio, Coroutines & Concurrency', 'Master async/await, event loops, aiohttp, and parallel task gathering in Python.', '# Asynchronous Python: Asyncio, Coroutines & Concurrency

Synchronous scripts waste CPU time waiting on network sockets and database queries. `asyncio` enables high-throughput single-threaded cooperative multitasking.

## The Async Event Loop Model

- **Synchronous**: Each HTTP request blocks execution until the server replies (10 requests * 1 sec = 10 seconds).
- **Asynchronous**: When an I/O operation starts, the coroutine yields control back to the event loop, allowing hundreds of other tasks to execute concurrently (10 requests * 1 sec = ~1 second).

## Practical Asyncio with `asyncio.gather`

```python
import asyncio
import aiohttp

async def fetch_status(session, url):
    try:
        async with session.get(url, timeout=5) as response:
            return url, response.status
    except Exception as e:
        return url, str(e)

async def check_all_endpoints():
    urls = [
        "https://api.github.com",
        "https://httpbin.org/status/200",
        "https://httpbin.org/status/404"
    ]
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_status(session, url) for url in urls]
        results = await asyncio.gather(*tasks)
        for url, status in results:
            print(f"[{status}] {url}")

# Run event loop
asyncio.run(check_all_endpoints())
```

## Threading vs Multiprocessing vs Asyncio

- **Asyncio**: Best for I/O-bound network/database tasks.
- **Multiprocessing**: Bypasses the Global Interpreter Lock (GIL) for CPU-bound computations (data science, cryptography).
```', 'advanced', 35, 3, true
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
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'python-basics';
  IF v_skill_id IS NOT NULL THEN
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'When should you choose asyncio over multiprocessing in Python software development?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'When should you choose asyncio over multiprocessing in Python software development?', 'single', 'Asyncio is designed for high-concurrency I/O-bound operations (networking, APIs, file reads), while multiprocessing is for CPU-heavy tasks that need multiple cores.', 10 + 0, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'When performing heavy mathematical calculations on 16 CPU cores', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'When managing many concurrent I/O-bound network connections or API requests', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'When compiling C code', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Only when running on Windows', false, 4);
    END IF;
  END IF;
END $$;

-- Skill: api-basics
WITH s AS (SELECT id FROM public.skills WHERE slug = 'api-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'grpc-and-protobuf-microservices', 'gRPC, Protocol Buffers & High-Performance Microservices', 'Compare REST/JSON with binary gRPC, HTTP/2 multiplexing, and schema contracts.', '# gRPC, Protocol Buffers & High-Performance Microservices

While REST with JSON is ideal for public web APIs, inter-service microservice communication in enterprise architectures often adopts **gRPC**.

## Limitations of REST + JSON at Scale

- **Verbose Text Serialization**: JSON requires parsing strings, braces, and keys for every single message.
- **HTTP/1.1 Head-of-Line Blocking**: Requires opening multiple parallel TCP connections.
- **Unenforced Schemas**: Clients and servers can easily drift out of synchronization without compile-time contracts.

## The gRPC Architecture

1. **Protocol Buffers (`.proto`)**: Strongly typed binary serialization mechanism:
   ```protobuf
   syntax = "proto3";

   service TelemetryService {
     rpc SendMetric (MetricRequest) returns (MetricResponse);
   }

   message MetricRequest {
     string host_id = 1;
     int64 timestamp = 2;
     double cpu_usage = 3;
   }
   ```
2. **HTTP/2 Transport**:
   - Single TCP connection multiplexing bidirectional streams simultaneously.
   - HPACK binary header compression.
3. **Performance**: Binary serialization is up to **7x faster** than JSON with 30-50% smaller payload sizes.
```', 'advanced', 35, 3, true
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
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'What underlying transport protocol does gRPC utilize to enable multiplexed, bidirectional streaming over a single TCP connection?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'What underlying transport protocol does gRPC utilize to enable multiplexed, bidirectional streaming over a single TCP connection?', 'single', 'gRPC relies on HTTP/2 for bidirectional streaming, multiplexing, and binary framing.', 10 + 0, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'HTTP/1.0', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'HTTP/2', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Telnet', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'FTP', false, 4);
    END IF;
  END IF;
END $$;

-- Skill: security-fundamentals
WITH s AS (SELECT id FROM public.skills WHERE slug = 'security-fundamentals')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'zero-trust-and-threat-modeling', 'Zero Trust Architecture & Threat Modeling (STRIDE)', 'Deconstruct perimeter defense flaws, enforce Zero Trust verification, and map threats with STRIDE.', '# Zero Trust Architecture & Threat Modeling (STRIDE)

Traditional network security relied on the **Castle-and-Moat** perimeter model: anything inside the corporate VPN was implicitly trusted.

## The Zero Trust Model (NIST SP 800-207)

Core Tenet: **"Never Trust, Always Verify."**

1. **Explicit Verification**: Always authenticate and authorize based on all available data points (identity, location, device health, service context).
2. **Least Privilege Access**: Limit user access with Just-In-Time (JIT) and Just-Enough-Access (JEA).
3. **Assume Breach**: Segment network access, encrypt all internal traffic (mTLS), and continuously log and inspect behavior.

## Threat Modeling: The STRIDE Methodology

Developed by Microsoft to systematically discover vulnerabilities during architecture design:

| Threat | Security Property Violated | Example Mitigation |
|---|---|---|
| **S**poofing | Authenticity | Mutual TLS, PKI certificates, MFA |
| **T**ampering | Integrity | Cryptographic HMACs, digital signatures |
| **R**epudiation | Non-repudiation | Append-only tamper-proof audit logs |
| **I**nformation Disclosure | Confidentiality | AES-256-GCM encryption at rest and in transit |
| **D**enial of Service | Availability | Rate limiting, Cloudflare DDoS shielding |
| **E**levation of Privilege | Authorization | Strict RBAC, least privilege policies |
```', 'advanced', 40, 3, true
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
  SELECT id INTO v_skill_id FROM public.skills WHERE slug = 'security-fundamentals';
  IF v_skill_id IS NOT NULL THEN
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'In the STRIDE threat modeling framework, what security property is violated by Tampering?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'In the STRIDE threat modeling framework, what security property is violated by Tampering?', 'single', 'Tampering violates Integrity, involving unauthorized alteration or modification of data.', 10 + 0, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Confidentiality', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Integrity', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Availability', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Anonymity', false, 4);
    END IF;
  END IF;
END $$;

-- Skill: authentication-authorization
WITH s AS (SELECT id FROM public.skills WHERE slug = 'authentication-authorization')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'webauthn-fido2-and-mtls', 'FIDO2 Passkeys, WebAuthn & Mutual TLS (mTLS)', 'Eliminate credential stuffing with phishing-resistant public key cryptography and client certificates.', '# FIDO2 Passkeys, WebAuthn & Mutual TLS (mTLS)

Passwords and SMS codes are vulnerable to real-time reverse proxy phishing attacks (e.g. Evilginx). Modern defense requires cryptographic hardware binding.

## WebAuthn & FIDO2 Passkeys

WebAuthn uses asymmetric public-key cryptography bound strictly to the browser''s origin:

1. **Registration**:
   - The user''s device (TouchID, Windows Hello, YubiKey) generates a unique key pair.
   - The public key is sent to the server. The private key never leaves the hardware secure enclave.
2. **Authentication**:
   - Server issues a random cryptographic **Challenge**.
   - Authenticator prompts for local biometric/PIN, signs the challenge + origin with private key.
   - **Phishing Proof**: Even if an attacker lures a user to `evil-phish.com`, the browser signs `evil-phish.com`, which the real server rejects!

## Mutual TLS (mTLS) for Zero Trust Microservices

Standard TLS authenticates only the server to the client. **Mutual TLS (mTLS)** mandates that both client and server present cryptographic X.509 certificates to each other:

- Protects inter-service communication in Kubernetes Service Meshes (Istio, Linkerd).
- Renders stolen bearer tokens useless without the accompanying client private key certificate.
```', 'advanced', 35, 3, true
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
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Why are FIDO2 / WebAuthn passkeys mathematically immune to real-time phishing proxy attacks?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Why are FIDO2 / WebAuthn passkeys mathematically immune to real-time phishing proxy attacks?', 'single', 'The browser binds the cryptographic signature strictly to the origin domain in the address bar, rendering signatures captured by phishing domains invalid on the genuine domain.', 10 + 0, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Because passwords are 64 characters long', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'The browser cryptographically binds the challenge signature to the exact origin domain', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Because they disable JavaScript', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'They only work on private internal networks', false, 4);
    END IF;
  END IF;
END $$;

-- Skill: web-security-basics
WITH s AS (SELECT id FROM public.skills WHERE slug = 'web-security-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'ssrf-and-prototype-pollution', 'Server-Side Request Forgery (SSRF) & Advanced Web Attacks', 'Prevent cloud metadata exfiltration (169.254.169.254) and prototype pollution vulnerabilities.', '# Server-Side Request Forgery (SSRF) & Advanced Web Attacks

When a web application fetches a URL supplied by a user (e.g. webhook validation or image preview import), attackers can target internal cloud infrastructure.

## Server-Side Request Forgery (SSRF)

An attacker inputs a URL targeting internal private loopback or metadata endpoints:

```
http://169.254.169.254/latest/meta-data/iam/security-credentials/
```

If the vulnerable backend server issues an HTTP GET to this address, the internal cloud metadata service returns temporary IAM credentials, leading to total cloud account compromise (the root cause of the infamous Capital One breach).

### Defending Against SSRF

1. **Disable Cloud IMDSv1**: Enforce AWS IMDSv2 (requires session token header `X-aws-ec2-metadata-token`).
2. **Resolve DNS Before Requesting**: Resolve the hostname to an IP address and verify it does NOT belong to:
   - `127.0.0.0/8` (Loopback)
   - `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16` (RFC 1918 Private)
   - `169.254.169.254` (Link-Local Metadata)
3. **Block DNS Rebinding**: Re-verify IP immediately prior to establishing the TCP socket.
```', 'advanced', 40, 3, true
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
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'What IP address is commonly targeted by attackers via SSRF to steal cloud instance IAM credentials in AWS environments?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'What IP address is commonly targeted by attackers via SSRF to steal cloud instance IAM credentials in AWS environments?', 'single', '169.254.169.254 is the link-local IPv4 address for the Instance Metadata Service (IMDS) across major cloud providers.', 10 + 0, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '127.0.0.1', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '169.254.169.254', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '192.168.1.1', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '8.8.8.8', false, 4);
    END IF;
  END IF;
END $$;

-- Skill: cloud-fundamentals
WITH s AS (SELECT id FROM public.skills WHERE slug = 'cloud-fundamentals')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'infrastructure-as-code-terraform', 'Infrastructure as Code (IaC) with Terraform', 'Manage reproducible cloud infrastructure using declarative HCL, state files, and drift detection.', '# Infrastructure as Code (IaC) with Terraform

Manual creation of cloud resources in web consoles creates configuration drift and unrepeatable snowflake environments.

## Declarative Infrastructure with HCL

HashiCorp Configuration Language (HCL) describes the desired state:

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Environment = "production"
  }
}
```

## The 3-Step Terraform Lifecycle

1. **`terraform init`**: Downloads provider plugins and initializes remote backend.
2. **`terraform plan`**: Compares current real-world state against code and previews execution steps.
3. **`terraform apply`**: Executes API calls to create or modify resources.

## Terraform State Management

- **Remote State Locking**: State files (`terraform.tfstate`) store resource IDs and metadata. In team environments, state is stored in S3 with DynamoDB state locking to prevent simultaneous conflicting mutations.
```', 'advanced', 35, 3, true
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
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'Why must Terraform state files be secured and locked during team operations?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'Why must Terraform state files be secured and locked during team operations?', 'single', 'State files map declared code to real cloud IDs and may contain sensitive credentials; locking prevents concurrent runs from corrupting infrastructure state.', 10 + 0, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'To speed up internet connection speeds', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'To prevent concurrent execution conflicts and protect sensitive resource metadata', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Because AWS bans unlocked accounts', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'To compile Go binaries', false, 4);
    END IF;
  END IF;
END $$;

-- Skill: docker-basics
WITH s AS (SELECT id FROM public.skills WHERE slug = 'docker-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'rootless-docker-and-image-signing', 'Container Security: Rootless Mode & Cosign Supply Chain', 'Run containers without daemon root privileges and verify cryptographic image signatures with Cosign.', '# Container Security: Rootless Mode & Cosign Supply Chain

Traditional Docker runs the daemon (`dockerd`) as host UID 0 (`root`), meaning a container breakout vulnerability grants full host root access.

## Rootless Docker

Rootless mode executes the Docker daemon and containers entirely inside a user namespace without root privileges:

- If a malicious process escapes the container, it remains an unprivileged user on the host OS.
- Eliminates the security risk of adding developers to the `docker` group (which is equivalent to passwordless sudo).

## Container Supply Chain Security: Cosign & Sigstore

Before deploying a container to production Kubernetes or cloud clusters, verify that the image was built by your verified CI pipeline and has not been tampered with:

```bash
# Sign container image using keyless OIDC authentication
cosign sign --yes ghcr.io/myorg/myapp:v1.0

# Verify signature before starting container
cosign verify \
  --certificate-identity-regexp "https://github.com/myorg/myapp" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  ghcr.io/myorg/myapp:v1.0
```', 'advanced', 35, 3, true
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
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'What security risk is mitigated by running Docker in Rootless mode?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'What security risk is mitigated by running Docker in Rootless mode?', 'single', 'If an attacker achieves a container breakout, rootless mode ensures they remain an unprivileged user on the host system.', 10 + 0, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Prevents container breakouts from gaining host root privileges', true, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Decreases container RAM usage to zero', false, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Eliminates network latency', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Allows containers to run on MS-DOS', false, 4);
    END IF;
  END IF;
END $$;

-- Skill: ci-cd-basics
WITH s AS (SELECT id FROM public.skills WHERE slug = 'ci-cd-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'gitops-with-argocd-and-secrets', 'GitOps with ArgoCD & Enterprise Secret Management', 'Synchronize desired cluster state using Git as single source of truth and Vault secret injection.', '# GitOps with ArgoCD & Enterprise Secret Management

Traditional CI pipelines push updates to clusters using high-privilege credentials stored in CI runners. **GitOps** reverses this pattern: an in-cluster operator pulls changes automatically.

## The GitOps Principles

1. **Declarative Descriptions**: Entire system state declared in Git (Kubernetes manifests, Helm charts).
2. **Versioned & Immutable**: Every deployment is an auditable git commit.
3. **Automated Pull Reconciliation**: Agents (like ArgoCD) continuously compare running cluster state against Git:
   - If drift occurs (e.g. someone manually edits a production replica count), ArgoCD auto-corrects it back to Git specifications.

## Enterprise Secret Management: HashiCorp Vault

Never commit plaintext API keys or database passwords to Git:
- Store secrets centrally in **HashiCorp Vault**.
- Use the **Vault Secrets Operator** to dynamically inject short-lived credentials into pods at runtime as in-memory volumes.
```', 'advanced', 35, 3, true
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
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'In a GitOps workflow managed by tools like ArgoCD, how is configuration drift resolved?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'In a GitOps workflow managed by tools like ArgoCD, how is configuration drift resolved?', 'single', 'The in-cluster controller continuously reconciles real-world state against the declarative manifests in Git, overriding manual drift.', 10 + 0, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'The cluster shuts down', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'The controller automatically reconciles cluster state back to the Git source of truth', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'A Slack notification is sent and changes are accepted', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Git is overwritten by the cluster', false, 4);
    END IF;
  END IF;
END $$;

-- Skill: llm-api-basics
WITH s AS (SELECT id FROM public.skills WHERE slug = 'llm-api-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'fine-tuning-lora-and-quantization', 'Parameter-Efficient Fine-Tuning (PEFT/LoRA) & Model Quantization', 'Adapt open-weights models with Low-Rank Adaptation (LoRA) and 4-bit quantization.', '# Parameter-Efficient Fine-Tuning (PEFT/LoRA) & Model Quantization

Full fine-tuning of multi-billion parameter models requires hundreds of gigabytes of GPU VRAM. **LoRA** and **Quantization** enable fine-tuning on consumer hardware.

## Low-Rank Adaptation (LoRA)

LoRA freezes the base model weights $W_0$ and injects trainable rank-decomposition matrices $A$ and $B$:

$$\Delta W = B \times A$$

- Instead of updating 70 billion parameters, LoRA trains only **0.1% to 1%** of parameters.
- Reduces GPU VRAM requirements by over 70%.
- Resulting LoRA adapters are lightweight (~50MB to 200MB) and can be swapped dynamically at inference time.

## Weight Quantization: FP16 to INT4

- **FP16 (16-bit Floating Point)**: 2 bytes per parameter (7B model requires 14GB VRAM just to load).
- **INT4 (4-bit Integer - AWQ / GGUF)**: 0.5 bytes per parameter (7B model fits into 4GB VRAM on a laptop).
- Modern quantization techniques preserve over 98% of baseline perplexity while cutting memory by 75%.
```', 'advanced', 40, 3, true
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
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'What is the primary technical advantage of Low-Rank Adaptation (LoRA) over full model fine-tuning?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'What is the primary technical advantage of Low-Rank Adaptation (LoRA) over full model fine-tuning?', 'single', 'LoRA freezes base weights and trains small low-rank adapter matrices, drastically reducing GPU VRAM needs while preserving the core model.', 10 + 0, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It converts LLMs into SQL databases', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It freezes base weights and trains only low-rank matrices, saving massive GPU VRAM', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It guarantees zero hallucinations', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It eliminates the need for training data', false, 4);
    END IF;
  END IF;
END $$;

-- Skill: ai-agents-basics
WITH s AS (SELECT id FROM public.skills WHERE slug = 'ai-agents-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'reflection-critics-and-agent-memory', 'Reflective Agent Loops & Ephemeral vs Persistent Memory', 'Implement Actor-Critic evaluation patterns, vector memory buffers, and long-term agent persistence.', '# Reflective Agent Loops & Ephemeral vs Persistent Memory

First-pass agent outputs often contain bugs or suboptimal plans. Autonomous systems use **Reflective Loops** to review and critique their own work.

## The Actor-Critic Reflection Pattern

1. **Actor Agent**: Generates initial plan or code draft.
2. **Critic Agent**: Evaluates the output against strict rubrics (security standards, edge case handling, performance).
3. **Refinement**: If the Critic identifies deficiencies, feedback is routed back to the Actor for iterative improvement.

## The 3 Tiers of Agent Memory

- **Working Memory**: Active token context window (scratchpad, tool observations from the current session).
- **Short-Term Memory**: Conversation transcript persisted across turns in JSONL or relational databases.
- **Long-Term Memory**: Vector embeddings stored in a vector database, retrieved via semantic similarity to recall past user preferences, corrections, and completed workflows.
```', 'advanced', 40, 3, true
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
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'In autonomous AI engineering systems, what is the role of the Critic in the Actor-Critic pattern?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'In autonomous AI engineering systems, what is the role of the Critic in the Actor-Critic pattern?', 'single', 'The Critic evaluates the Actor generated output against objective rubrics and provides structured feedback for iterative refinement.', 10 + 0, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'To delete code files', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'To evaluate candidate outputs and provide structured feedback for refinement', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'To calculate API billing costs', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'To terminate the operating system', false, 4);
    END IF;
  END IF;
END $$;

-- Skill: automation-workflows
WITH s AS (SELECT id FROM public.skills WHERE slug = 'automation-workflows')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'temporal-orchestration-and-sagas', 'Durable Execution Engines & The Saga Pattern', 'Build crash-resilient distributed workflows using Temporal, durable state machines, and compensation steps.', '# Durable Execution Engines & The Saga Pattern

When an automated workflow coordinates actions across multiple services (e.g. provision cloud server, configure DNS, issue TLS certificate, bill customer), an error midway requires clean recovery.

## What is Durable Execution?

Traditional scripts crash if the process dies or the server reboots. **Durable Execution** engines (like Temporal or Cadence) persist execution event logs:
- If a server crashes mid-workflow, execution resumes automatically on another worker from the exact line of code that was executing.

## The Saga Pattern for Distributed Transactions

Because distributed microservices cannot use two-phase commit (2PC) database locks, workflows use **Sagas** with **Compensating Transactions**:

```mermaid
flowchart LR
    A[Step 1: Create VM] -->|Success| B[Step 2: Allocate Elastic IP]
    B -->|Fails!| C[Compensate 1: Destroy VM]
```

- For every forward action (e.g. `reserveCompute()`), define a compensating backward action (e.g. `releaseCompute()`).
- If any step fails after retries, the orchestrator invokes all previous compensating steps in reverse order, leaving zero orphaned cloud resources.
```', 'advanced', 40, 3, true
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
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'In the Saga pattern for distributed workflows, what is the purpose of a Compensating Transaction?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'In the Saga pattern for distributed workflows, what is the purpose of a Compensating Transaction?', 'single', 'Compensating transactions undo previous successful actions in reverse order when a subsequent step in the workflow fails permanently.', 10 + 0, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'To pay cloud bills automatically', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'To undo earlier successful steps when a downstream workflow step fails', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'To double the allocated CPU resources', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'To bypass firewall rules', false, 4);
    END IF;
  END IF;
END $$;

-- Skill: network-engineering-path
WITH s AS (SELECT id FROM public.skills WHERE slug = 'network-engineering-path')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'mpls-l3vpn-and-traffic-engineering', 'MPLS L3VPN, Segment Routing & Traffic Engineering', 'Label switching architectures, MPLS VPNs, and software-defined WAN traffic engineering.', '# MPLS L3VPN, Segment Routing & Traffic Engineering

Service providers and global enterprises transport isolated customer traffic over shared backbones using **Multiprotocol Label Switching (MPLS)**.

## Label Switching Mechanics

Traditional IP routing requires every router to inspect packet headers and search large routing tables. MPLS swaps fixed-length 32-bit labels:
- **Ingress Label Edge Router (LER)**: Adds an MPLS label (**Push**).
- **Label Switch Router (LSR)**: Swaps incoming label for outgoing label based on LFIB (**Swap**).
- **Egress LER**: Removes label and forwards native IP packet (**Pop**).

## Modern Segment Routing (SRv6)

Segment Routing eliminates the complexity of LDP and RSVP-TE protocols by encoding instructions directly into IPv6 packet extension headers, simplifying traffic steering and path optimization.
```', 'advanced', 45, 3, true
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
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'What fixed-length identifier does an MPLS router evaluate to forward packets without performing full IP routing table lookups?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'What fixed-length identifier does an MPLS router evaluate to forward packets without performing full IP routing table lookups?', 'single', 'MPLS routers inspect a 32-bit MPLS label shim header to swap and forward packets along label-switched paths.', 10 + 0, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'BGP Community string', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, '32-bit MPLS label', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'TCP Window size', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'Ethernet MAC address', false, 4);
    END IF;
  END IF;
END $$;

-- Skill: soc-fundamentals-path
WITH s AS (SELECT id FROM public.skills WHERE slug = 'soc-fundamentals-path')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'threat-hunting-yara-and-memory-forensics', 'Threat Hunting with YARA, Sigma & Volatility Memory Forensics', 'Detect in-memory fileless malware, author YARA rules, and extract injected DLLs with Volatility 3.', '# Threat Hunting with YARA, Sigma & Volatility Memory Forensics

Advanced persistent threats (APTs) often operate "fileless" inside RAM (process hollowing, reflective DLL injection), bypassing traditional disk antivirus scanners.

## Memory Forensics with Volatility 3

Acquire an image of physical RAM and analyze running memory structures:

```bash
# List processes from RAM dump
python3 vol.py -f memory.dmp windows.pslist

# Scan for hidden, unlinked processes (DKOM rootkits)
python3 vol.py -f memory.dmp windows.psscan

# Detect memory injection and hollowed processes
python3 vol.py -f memory.dmp windows.malfind

# Dump injected shellcode from suspicious process
python3 vol.py -f memory.dmp -o /tmp/dump windows.dumpfiles --pid 1340
```

## Authoring YARA Detection Rules

YARA identifies malware patterns across files and raw memory dumps:

```yara
rule Suspicious_CobaltStrike_Beacon {
  meta:
    description = "Detects Cobalt Strike Beacon memory artifacts"
    author = "SOC Analyst"
  strings:
    $beacon_str = "%02d/%02d/%02d %02d:%02d:%02d" ascii
    $named_pipe = "\\.\pipe\msagent_" ascii
  condition:
    all of them
}
```', 'advanced', 45, 3, true
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
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'In Volatility memory forensics, which plugin detects unlinked processes and process hollowing by scanning for executable memory pages with PAGE_EXECUTE_READWRITE permissions?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'In Volatility memory forensics, which plugin detects unlinked processes and process hollowing by scanning for executable memory pages with PAGE_EXECUTE_READWRITE permissions?', 'single', 'windows.malfind scans process memory descriptors for suspicious executable and writable memory regions characteristic of injected shellcode.', 10 + 0, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'windows.netstat', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'windows.malfind', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'windows.hashdump', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'windows.cmdline', false, 4);
    END IF;
  END IF;
END $$;

-- Skill: ai-automation-engineering-path
WITH s AS (SELECT id FROM public.skills WHERE slug = 'ai-automation-engineering-path')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'high-throughput-llm-serving-vllm', 'Distributed LLM Serving: vLLM, PagedAttention & Speculative Decoding', 'Maximize GPU inference throughput with PagedAttention, continuous batching, and tensor parallelism.', '# Distributed LLM Serving: vLLM, PagedAttention & Speculative Decoding

In enterprise deployments, serving LLMs via vanilla PyTorch causes massive GPU VRAM waste and sluggish throughput.

## PagedAttention: The vLLM Revolution

During LLM generation, Key-Value (KV) cache memory is dynamic and unpredictable. Traditional engines pre-allocated contiguous memory chunks, wasting 60-80% of GPU VRAM due to internal and external fragmentation.

- **PagedAttention** borrows virtual memory paging from operating systems:
- Divides KV cache into discrete fixed-size pages.
- Allows physical KV blocks to reside in non-contiguous VRAM locations.
- Enables **continuous batching**, boosting serving throughput by **2x to 4x**.

## Speculative Decoding

Generating tokens autoregressively is strictly memory-bandwidth bound. **Speculative Decoding** uses a tiny draft model (e.g. 1B) to predict $K$ tokens in parallel, which the large target model (e.g. 70B) validates in a single forward pass, doubling inference speed.
```', 'advanced', 45, 3, true
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
    SELECT id INTO v_q_id FROM public.quiz_questions WHERE skill_id = v_skill_id AND prompt = 'How does PagedAttention in vLLM drastically increase GPU serving throughput for Large Language Models?';
    IF v_q_id IS NULL THEN
      INSERT INTO public.quiz_questions (skill_id, prompt, question_type, explanation, sort_order, is_published)
      VALUES (v_skill_id, 'How does PagedAttention in vLLM drastically increase GPU serving throughput for Large Language Models?', 'single', 'PagedAttention manages KV cache memory in non-contiguous pages like OS virtual memory, eliminating memory fragmentation and allowing larger continuous batch sizes.', 10 + 0, true)
      RETURNING id INTO v_q_id;

      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It converts neural networks into C++ templates', false, 1);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It manages KV cache in non-contiguous pages like OS virtual memory, eliminating fragmentation', true, 2);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It runs LLMs exclusively on CPUs', false, 3);
      INSERT INTO public.quiz_options (question_id, option_text, is_correct, sort_order)
      VALUES (v_q_id, 'It removes attention mechanisms entirely', false, 4);
    END IF;
  END IF;
END $$;

