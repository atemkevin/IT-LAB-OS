-- 011_seed_core_lessons.sql
-- Curriculum expansion: Seeds lessons for foundational IT and networking skills

-- Computer Basics Lessons
WITH s AS (SELECT id FROM public.skills WHERE slug = 'computer-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'hardware-architecture', 'Computer Hardware Architecture',
  'Master the core hardware components of modern computing systems.',
  '# Computer Hardware Architecture

Understanding the physical components of computer hardware is essential for diagnosing system failures, optimizing performance, and sizing server workloads.

## The Von Neumann Architecture

Modern computers are built around the **Von Neumann Architecture**, which defines four core subsystems:

1. **Central Processing Unit (CPU)**: Performs arithmetic calculations and control logic.
2. **Memory (RAM)**: Stores volatile working state and running code.
3. **Storage (Disk/SSD)**: Persists non-volatile files and operating system images.
4. **Input/Output (I/O)**: Communicates with human operators and network peripherals.

## Motherboard & Buses

All components interface through the **motherboard**:

- **PCIe (PCI Express)**: High-speed serial bus connecting GPUs, NVMe SSDs, and 10GbE network interfaces.
- **SATA**: Legacy storage interface running at 6 Gbps.
- **DMI / Chipset Bus**: Interconnect between the CPU and peripheral chipset.

## Hardware Diagnostics Commands

On Linux systems, IT engineers use these CLI utilities to inspect physical hardware:

```bash
# Display CPU architecture and features
lscpu

# Inspect PCI devices (NICs, RAID controllers, GPUs)
lspci

# List block devices (SSDs, NVMe drives, USB disks)
lsblk

# Print motherboard and BIOS information
sudo dmidecode -t baseboard
```

## Key Takeaway

Always verify physical connectivity and hardware health before troubleshooting higher-level software or networking failures.',
  'beginner', 15, 1, true
FROM s ON CONFLICT (skill_id, slug) DO NOTHING;

WITH s AS (SELECT id FROM public.skills WHERE slug = 'computer-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'bios-uefi-boot-process', 'BIOS, UEFI and the Boot Process',
  'Learn how computers boot from power-on through firmware to OS initialization.',
  '# BIOS, UEFI and the Boot Process

Every server, workstation, and VM undergoes an initialization sequence before the operating system takes control.

## BIOS vs UEFI

| Feature | Legacy BIOS | Modern UEFI |
|---|---|---|
| Architecture | 16-bit real mode | 32-bit or 64-bit |
| Partition Scheme | MBR (Max 2TB drives) | GPT (Supports Exabytes) |
| Security | None | Secure Boot with cryptographic signing |
| Boot Speed | Slow hardware probe | Fast parallel driver init |

## The 4 Boot Phases

1. **Power-On Self-Test (POST)**: Motherboard firmware tests CPU registers, RAM integrity, and detects primary video output.
2. **Firmware Hand-off**: UEFI loads EFI System Partition (`/boot/efi`) and executes the bootloader.
3. **Bootloader (GRUB/systemd-boot)**: Prompts for kernel selection, loads the Linux kernel into RAM, and initializes initramfs.
4. **Init Process (systemd)**: PID 1 mounts the root filesystem (`/`) and starts networking, system services, and login prompts.

## Troubleshooting Boot Failures

```bash
# Check boot logs and system initialization time
systemd-analyze

# Inspect critical boot messages from the kernel ring buffer
dmesg | grep -i -E "error|fail|warn"

# View system journal for previous boot
journalctl -b -1 -p err
```',
  'beginner', 20, 2, true
FROM s ON CONFLICT (skill_id, slug) DO NOTHING;

-- CPU, Memory and Storage Lessons
WITH s AS (SELECT id FROM public.skills WHERE slug = 'cpu-memory-storage')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'cpu-memory-hierarchy', 'The Memory Hierarchy & Caching',
  'Understand CPU caches, RAM latency, and virtual memory swapping.',
  '# The Memory Hierarchy & Caching

The memory hierarchy is designed to balance speed, cost, and capacity across storage media.

## The Pyramid of Speed

From fastest to slowest:

1. **CPU Registers**: 0.5 nanoseconds, single cycle access.
2. **L1 Cache**: ~1 nanosecond, 32KB to 64KB per core.
3. **L2 Cache**: ~3-5 nanoseconds, 512KB to 1MB per core.
4. **L3 Cache**: ~10-20 nanoseconds, shared across all cores (16MB-64MB+).
5. **Main Memory (DDR4/DDR5 RAM)**: ~60-80 nanoseconds.
6. **NVMe PCIe SSD**: ~10-25 microseconds.
7. **SATA SSD**: ~50-100 microseconds.
8. **Mechanical HDD**: ~5-10 milliseconds (seek time).

## Virtual Memory & Swapping

When physical RAM fills up, the Linux kernel transfers idle memory pages to secondary storage (**Swap**):

- **Page Fault**: The CPU attempts to access a memory address currently residing in swap.
- **Thrashing**: The OS spends more time swapping pages in and out of disk than executing user instructions.

## Monitoring Commands

```bash
# Live system resource monitor
htop

# Memory breakdown in human-readable format
free -h

# Virtual memory statistics (run every 2 seconds)
vmstat 2 5
```',
  'intermediate', 20, 1, true
FROM s ON CONFLICT (skill_id, slug) DO NOTHING;

-- DNS Lessons
WITH s AS (SELECT id FROM public.skills WHERE slug = 'dns')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'dns-fundamentals', 'DNS Hierarchy and Resolution Flow',
  'Learn how the Domain Name System resolves human-friendly hostnames to IP addresses.',
  '# DNS Hierarchy and Resolution Flow

The Domain Name System (DNS) is the distributed database that translates human-readable hostnames (`example.com`) into routable IP addresses (`93.184.216.34`).

## The Resolution Hierarchy

When you request `api.sub.example.com`, resolution proceeds top-down:

1. **Root Nameservers (`.`)**: 13 logical root server identities directing traffic to TLD authorities.
2. **Top-Level Domain (TLD) Nameservers**: Manages `.com`, `.org`, `.net`, etc.
3. **Authoritative Nameservers**: The specific DNS servers holding the master zone records for `example.com`.

## Common Resource Record Types

- **A**: Maps a hostname to an IPv4 address (`192.0.2.1`).
- **AAAA**: Maps a hostname to an IPv6 address (`2001:db8::1`).
- **CNAME**: Canonical name; aliases one domain to another.
- **MX**: Mail exchange records pointing to incoming email servers.
- **TXT**: Arbitrary text records used for domain verification, SPF, and DKIM.

## Practical DNS Diagnostics

```bash
# Query an A record directly against Google Public DNS
dig @8.8.8.8 example.com A +noall +answer

# Trace full recursive delegation from root to authoritative
dig example.com +trace

# Fast reverse lookup on an IP address
host 8.8.8.8
```',
  'beginner', 20, 1, true
FROM s ON CONFLICT (skill_id, slug) DO NOTHING;

-- Subnetting Lessons
WITH s AS (SELECT id FROM public.skills WHERE slug = 'subnetting')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'cidr-and-masks', 'CIDR Notation and Subnet Masks',
  'Master IPv4 subnet calculation, CIDR blocks, and address planning.',
  '# CIDR Notation and Subnet Masks

Subnetting divides a large network into smaller, manageable, and secure sub-networks.

## Subnet Mask Breakdown

An IPv4 address consists of 32 bits divided into:
- **Network Bits**: Identifies the specific network segment.
- **Host Bits**: Identifies the individual device on that network.

## Common CIDR Prefix Reference

| CIDR | Subnet Mask | Total IPs | Usable Hosts |
|---|---|---|---|
| /24 | 255.255.255.0 | 256 | 254 |
| /25 | 255.255.255.128 | 128 | 126 |
| /26 | 255.255.255.192 | 64 | 62 |
| /27 | 255.255.255.224 | 32 | 30 |
| /28 | 255.255.255.240 | 16 | 14 |
| /30 | 255.255.255.252 | 4 | 2 (Point-to-Point) |

## The Golden Formula

For any subnet with n host bits:
- **Total Addresses**: 2^n
- **Usable Host Addresses**: 2^n - 2 (Subtracting Network ID and Broadcast Address)

## Linux Network Inspection

```bash
# Display assigned IP addresses and CIDR prefixes
ip -br addr

# View routing table and default gateway
ip route show
```',
  'intermediate', 25, 1, true
FROM s ON CONFLICT (skill_id, slug) DO NOTHING;

-- Docker Basics Lessons
WITH s AS (SELECT id FROM public.skills WHERE slug = 'docker-basics')
INSERT INTO public.lessons (skill_id, slug, title, summary, content_markdown, difficulty, estimated_minutes, sort_order, is_published)
SELECT s.id, 'container-fundamentals', 'Containers vs Virtual Machines',
  'Understand Docker architecture, namespaces, cgroups, and container images.',
  '# Containers vs Virtual Machines

Containers package application code, runtime, and system libraries into isolated execution units that run uniformly across any Linux machine.

## Containers vs VMs

- **Virtual Machines**: Emulate physical hardware with a Hypervisor (Type 1 or Type 2). Each VM runs a complete guest OS kernel, consuming gigabytes of RAM.
- **Containers**: Share the host Linux kernel. Isolation is achieved via Linux kernel primitives:
  - **Namespaces**: Isolates processes (`pid`), network interfaces (`net`), and mounts (`mnt`).
  - **Control Groups (cgroups)**: Limits CPU, memory, and I/O consumption.

## The Docker Architecture

1. **Docker Client**: CLI command interface (`docker run`, `docker build`).
2. **Docker Daemon (`dockerd`)**: Background daemon managing container lifecycles.
3. **Container Registry**: Remote storage for container images (Docker Hub, GitHub Container Registry).

## Essential Docker Commands

```bash
# Pull and run an Nginx web server in detached mode
docker run -d -p 8080:80 --name my-web nginx:alpine

# List active containers
docker ps

# Stream container logs
docker logs -f my-web

# Execute a bash shell inside a running container
docker exec -it my-web /bin/sh

# Stop and remove container
docker stop my-web && docker rm my-web
```',
  'beginner', 20, 1, true
FROM s ON CONFLICT (skill_id, slug) DO NOTHING;
