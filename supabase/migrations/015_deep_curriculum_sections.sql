-- 015_deep_curriculum_sections.sql
-- Deep multi-section curriculum guides for all 79 lessons across all 26 skills

-- ==========================================
-- Lesson: hardware-architecture
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 18,
    content_markdown = '## 1. The Von Neumann Architecture & Modern Bus Topology

At the heart of every modern computing system is the **Von Neumann architecture**, which unifies code instructions and runtime data inside a single addressable memory space.

> [!NOTE]
> In modern multi-core x86_64 and ARM64 servers, memory access is no longer uniform. Systems employ **NUMA (Non-Uniform Memory Access)**, where CPU sockets access their locally pinned memory channels significantly faster than remote memory channels across interconnect links like Intel UPI or AMD Infinity Fabric.

### System Bus Evolution

| Bus Architecture | Typical Bandwidth | Common Devices | Key Characteristic |
|---|---|---|---|
| **PCIe Gen 4 (x16)** | ~31.5 GB/s | Modern NVMe RAID, GPUs | Point-to-point serial packet switched |
| **PCIe Gen 5 (x16)** | ~63 GB/s | Enterprise AI Accelerators | 32 GT/s transfer rate per lane |
| **DDR5 Memory Bus** | ~40-60 GB/s per channel | System RAM | Dual 32-bit subchannels per DIMM |
| **SATA III** | ~600 MB/s | Legacy SSDs, bulk HDDs | Shared single-lane serial protocol |

---

## 2. PCIe Lanes, Root Complexes & Topology Discovery

When a server boots, the kernel scans the PCIe Root Complex to enumerate all connected devices, bridges, endpoints, and assign Base Address Registers (BARs).

```bash
# List all PCI devices with detailed kernel driver associations
lspci -tv

# Inspect NVMe controller PCIe link speed and negotiated width
lspci -vv -s 01:00.0 | grep -E "LnkCap|LnkSta"
```

### Reading Link Negotiation
- **LnkCap**: Indicates the hardware capability of the slot (e.g., `Speed 16GT/s, Width x16`).
- **LnkSta**: Indicates the actual negotiated speed (e.g., `Speed 16GT/s, Width x4`). If an x16 card negotiates at x4, this indicates a seated hardware defect or lane bifurcation misconfiguration.

---

## 3. Hardware Topology Inspection in Linux

Engineers must know how to extract CPU cache structures, NUMA node layouts, and memory topology directly from the sysfs pseudo-filesystem.

```bash
# Query NUMA nodes and CPU socket affinities
numactl --hardware

# View physical CPU core topology and cache sizing
lscpu

# Inspect DIMM memory slots and physical clock speeds
sudo dmidecode --type memory | grep -E "Size:|Speed:|Manufacturer:|Part Number:"
```

---

## 4. Hardware Diagnostics & Troubleshooting Checklist

> [!WARNING]
> High PCIe uncorrectable errors (AER) often precede catastrophic SSD data corruption or GPU bus resets.

### Diagnostic Checklist
1. **Check Kernel Ring Buffer for MCE (Machine Check Exceptions)**:
   ```bash
   sudo dmesg -T | grep -i -E "mce|aer|hardware error|pci.*error"
   ```
2. **Inspect EDAC (Error Detection and Correction) Memory Counters**:
   ```bash
   grep -r . /sys/devices/system/edac/mc/
   ```
3. **Verify Thermal Throttling Flags**:
   ```bash
   cat /sys/devices/system/cpu/cpu*/thermal_throttle/*
   ```'
WHERE slug = 'hardware-architecture';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'hardware-architecture';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. The Von Neumann Architecture & Modern Bus Topology', 'At the heart of every modern computing system is the **Von Neumann architecture**, which unifies code instructions and runtime data inside a single addressable memory space.

> [!NOTE]
> In modern multi-core x86_64 and ARM64 servers, memory access is no longer uniform. Systems employ **NUMA (Non-Uniform Memory Access)**, where CPU sockets access their locally pinned memory channels significantly faster than remote memory channels across interconnect links like Intel UPI or AMD Infinity Fabric.

### System Bus Evolution

| Bus Architecture | Typical Bandwidth | Common Devices | Key Characteristic |
|---|---|---|---|
| **PCIe Gen 4 (x16)** | ~31.5 GB/s | Modern NVMe RAID, GPUs | Point-to-point serial packet switched |
| **PCIe Gen 5 (x16)** | ~63 GB/s | Enterprise AI Accelerators | 32 GT/s transfer rate per lane |
| **DDR5 Memory Bus** | ~40-60 GB/s per channel | System RAM | Dual 32-bit subchannels per DIMM |
| **SATA III** | ~600 MB/s | Legacy SSDs, bulk HDDs | Shared single-lane serial protocol |', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'hardware-architecture';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. PCIe Lanes, Root Complexes & Topology Discovery', 'When a server boots, the kernel scans the PCIe Root Complex to enumerate all connected devices, bridges, endpoints, and assign Base Address Registers (BARs).

```bash
# List all PCI devices with detailed kernel driver associations
lspci -tv

# Inspect NVMe controller PCIe link speed and negotiated width
lspci -vv -s 01:00.0 | grep -E "LnkCap|LnkSta"
```

### Reading Link Negotiation
- **LnkCap**: Indicates the hardware capability of the slot (e.g., `Speed 16GT/s, Width x16`).
- **LnkSta**: Indicates the actual negotiated speed (e.g., `Speed 16GT/s, Width x4`). If an x16 card negotiates at x4, this indicates a seated hardware defect or lane bifurcation misconfiguration.', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'hardware-architecture';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Hardware Topology Inspection in Linux', 'Engineers must know how to extract CPU cache structures, NUMA node layouts, and memory topology directly from the sysfs pseudo-filesystem.

```bash
# Query NUMA nodes and CPU socket affinities
numactl --hardware

# View physical CPU core topology and cache sizing
lscpu

# Inspect DIMM memory slots and physical clock speeds
sudo dmidecode --type memory | grep -E "Size:|Speed:|Manufacturer:|Part Number:"
```', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'hardware-architecture';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Hardware Diagnostics & Troubleshooting Checklist', '> [!WARNING]
> High PCIe uncorrectable errors (AER) often precede catastrophic SSD data corruption or GPU bus resets.

### Diagnostic Checklist
1. **Check Kernel Ring Buffer for MCE (Machine Check Exceptions)**:
   ```bash
   sudo dmesg -T | grep -i -E "mce|aer|hardware error|pci.*error"
   ```
2. **Inspect EDAC (Error Detection and Correction) Memory Counters**:
   ```bash
   grep -r . /sys/devices/system/edac/mc/
   ```
3. **Verify Thermal Throttling Flags**:
   ```bash
   cat /sys/devices/system/cpu/cpu*/thermal_throttle/*
   ```', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: bios-uefi-boot-process
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 20,
    content_markdown = '## 1. The Boot Lifecycle: From Cold Reset to User Space

The transition from hardware power-on to an interactive shell follows a deterministic, cryptographic chain of custody:

```
[Power On] -> [CPU Reset Vector] -> [UEFI SEC/PEI/DXE Phases] -> [ESP Partition] -> [GRUB2 Stage] -> [vmlinuz + initramfs] -> [systemd PID 1]
```

> [!IMPORTANT]
> **UEFI Secure Boot** enforces digital signature verification at each link of the chain. The UEFI firmware validates the shim loader against Microsoft third-party keys, the shim validates GRUB2 against the distribution key, and GRUB2 validates the Linux kernel signature before execution.

---

## 2. The EFI System Partition (ESP) & NVRAM Variables

UEFI firmware reads standard FAT32 partitions rather than relying on raw Master Boot Record (MBR) disk sectors.

```bash
# Inspect non-volatile UEFI boot entries stored in motherboard NVRAM
efibootmgr -v

# Inspect contents of the mounted EFI System Partition (ESP)
ls -la /boot/efi/EFI/
```

### Creating or Reordering Boot Entries
```bash
# Change active boot order to prioritize entry 0001 then 0000
sudo efibootmgr -o 0001,0000
```

---

## 3. Kernel Handoff & The initramfs Early Userspace

Because root filesystems are often encrypted with LUKS, stored on LVM, or distributed across Software RAID arrays, the kernel cannot mount the physical root filesystem directly.

Instead, the bootloader loads **initramfs** (a temporary in-memory CPIO archive) containing just enough kernel modules and storage drivers to unlock and mount the real root partition.

```bash
# Inspect the modules packed into your active initramfs
lsinitramfs /boot/initrd.img-$(uname -r) | grep -E "nvme|ext4|luks|dm-crypt"
```

---

## 4. Boot Failure Recovery & Emergency Drills

> [!TIP]
> When dropped into an `(initramfs)` emergency shell during boot, the root device uuid is typically mismatched or storage controllers failed to initialize.

### Emergency Rescue Steps
1. **List Detected Block Devices**:
   ```bash
   blkid
   ls -la /dev/mapper/
   ```
2. **Perform Manual Filesystem Check**:
   ```bash
   fsck -fy /dev/sda2
   ```
3. **Exit Shell to Continue Boot**:
   ```bash
   exit
   ```'
WHERE slug = 'bios-uefi-boot-process';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'bios-uefi-boot-process';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. The Boot Lifecycle: From Cold Reset to User Space', 'The transition from hardware power-on to an interactive shell follows a deterministic, cryptographic chain of custody:

```
[Power On] -> [CPU Reset Vector] -> [UEFI SEC/PEI/DXE Phases] -> [ESP Partition] -> [GRUB2 Stage] -> [vmlinuz + initramfs] -> [systemd PID 1]
```

> [!IMPORTANT]
> **UEFI Secure Boot** enforces digital signature verification at each link of the chain. The UEFI firmware validates the shim loader against Microsoft third-party keys, the shim validates GRUB2 against the distribution key, and GRUB2 validates the Linux kernel signature before execution.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'bios-uefi-boot-process';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. The EFI System Partition (ESP) & NVRAM Variables', 'UEFI firmware reads standard FAT32 partitions rather than relying on raw Master Boot Record (MBR) disk sectors.

```bash
# Inspect non-volatile UEFI boot entries stored in motherboard NVRAM
efibootmgr -v

# Inspect contents of the mounted EFI System Partition (ESP)
ls -la /boot/efi/EFI/
```

### Creating or Reordering Boot Entries
```bash
# Change active boot order to prioritize entry 0001 then 0000
sudo efibootmgr -o 0001,0000
```', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'bios-uefi-boot-process';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Kernel Handoff & The initramfs Early Userspace', 'Because root filesystems are often encrypted with LUKS, stored on LVM, or distributed across Software RAID arrays, the kernel cannot mount the physical root filesystem directly.

Instead, the bootloader loads **initramfs** (a temporary in-memory CPIO archive) containing just enough kernel modules and storage drivers to unlock and mount the real root partition.

```bash
# Inspect the modules packed into your active initramfs
lsinitramfs /boot/initrd.img-$(uname -r) | grep -E "nvme|ext4|luks|dm-crypt"
```', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'bios-uefi-boot-process';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Boot Failure Recovery & Emergency Drills', '> [!TIP]
> When dropped into an `(initramfs)` emergency shell during boot, the root device uuid is typically mismatched or storage controllers failed to initialize.

### Emergency Rescue Steps
1. **List Detected Block Devices**:
   ```bash
   blkid
   ls -la /dev/mapper/
   ```
2. **Perform Manual Filesystem Check**:
   ```bash
   fsck -fy /dev/sda2
   ```
3. **Exit Shell to Continue Boot**:
   ```bash
   exit
   ```', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: kernel-init-and-pcie-interrupts
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 22,
    content_markdown = '## 1. Interrupt Lines (IRQ), APIC & MSI/MSI-X

When network interfaces receive packets or NVMe drives complete DMA transfers, they alert the CPU via hardware interrupts.

> [!NOTE]
> Legacy systems relied on shared line interrupts (INTx) which caused significant contention. Modern PCIe devices utilize **Message Signaled Interrupts (MSI-X)**, allowing a single 100GbE NIC to allocate up to 2048 distinct interrupt vectors mapped directly to individual CPU cores.

---

## 2. Top-Half vs Bottom-Half Interrupt Handlers

To maintain sub-millisecond operating system responsiveness, the Linux kernel splits interrupt processing into two distinct phases:

1. **Top-Half (Hardirq)**: Runs with hardware interrupts disabled. It acknowledges the device controller, grabs essential buffer descriptors, and schedules deferred work.
2. **Bottom-Half (Softirqs, Tasklets, ksoftirqd)**: Runs with interrupts enabled. It processes network stack transformations, TCP reassembly, and protocol delivery.

---

## 3. Inspecting & Tuning IRQ CPU Affinity in Production

```bash
# Inspect real-time interrupt distribution across CPU cores
cat /proc/interrupts | grep -i "nvme\|eth\|mlx"

# Check CPU core affinity bitmap for IRQ 124
cat /proc/irq/124/smp_affinity

# Pin IRQ 124 strictly to CPU core 2 (hex mask 0x4)
echo "4" | sudo tee /proc/irq/124/smp_affinity
```

---

## 4. Diagnosing Softirq Saturation & Packet Drops

> [!WARNING]
> If a single CPU core shows 100% utilization in `%si` (softirq) while other cores sit idle, network performance will collapse with heavy ring buffer drops.

```bash
# Monitor CPU softirq load in real time
mpstat -P ALL 1

# Check for network card ring buffer overrun drops
ethtool -S eth0 | grep -i "drop\|discard\|miss"
```'
WHERE slug = 'kernel-init-and-pcie-interrupts';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'kernel-init-and-pcie-interrupts';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Interrupt Lines (IRQ), APIC & MSI/MSI-X', 'When network interfaces receive packets or NVMe drives complete DMA transfers, they alert the CPU via hardware interrupts.

> [!NOTE]
> Legacy systems relied on shared line interrupts (INTx) which caused significant contention. Modern PCIe devices utilize **Message Signaled Interrupts (MSI-X)**, allowing a single 100GbE NIC to allocate up to 2048 distinct interrupt vectors mapped directly to individual CPU cores.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'kernel-init-and-pcie-interrupts';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Top-Half vs Bottom-Half Interrupt Handlers', 'To maintain sub-millisecond operating system responsiveness, the Linux kernel splits interrupt processing into two distinct phases:

1. **Top-Half (Hardirq)**: Runs with hardware interrupts disabled. It acknowledges the device controller, grabs essential buffer descriptors, and schedules deferred work.
2. **Bottom-Half (Softirqs, Tasklets, ksoftirqd)**: Runs with interrupts enabled. It processes network stack transformations, TCP reassembly, and protocol delivery.', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'kernel-init-and-pcie-interrupts';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Inspecting & Tuning IRQ CPU Affinity in Production', '```bash
# Inspect real-time interrupt distribution across CPU cores
cat /proc/interrupts | grep -i "nvme\|eth\|mlx"

# Check CPU core affinity bitmap for IRQ 124
cat /proc/irq/124/smp_affinity

# Pin IRQ 124 strictly to CPU core 2 (hex mask 0x4)
echo "4" | sudo tee /proc/irq/124/smp_affinity
```', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'kernel-init-and-pcie-interrupts';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Diagnosing Softirq Saturation & Packet Drops', '> [!WARNING]
> If a single CPU core shows 100% utilization in `%si` (softirq) while other cores sit idle, network performance will collapse with heavy ring buffer drops.

```bash
# Monitor CPU softirq load in real time
mpstat -P ALL 1

# Check for network card ring buffer overrun drops
ethtool -S eth0 | grep -i "drop\|discard\|miss"
```', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: cpu-memory-hierarchy
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 20,
    content_markdown = '## 1. Latency Numbers Every Systems Engineer Must Know

Understanding access latency differentials is essential for performance engineering and high-throughput application design:

| Storage Tier | Typical Latency | Approximate Scale Analogy |
|---|---|---|
| **L1 CPU Cache** | ~0.5 - 1 ns | 1 heartbeat (~1 second) |
| **L2 CPU Cache** | ~3 - 7 ns | 7 seconds |
| **L3 CPU Shared Cache** | ~10 - 20 ns | 20 seconds |
| **Main RAM (DDR4/DDR5)** | ~50 - 100 ns | 1.5 minutes |
| **NVMe PCIe SSD** | ~10 - 50 µs | 1.5 days |
| **SATA SSD** | ~100 - 250 µs | 3.5 days |
| **Rotational HDD (7200 RPM)** | ~1 - 10 ms | 1 - 4 months |
| **Cross-Continental WAN Roundtrip** | ~150 ms | 5 years |

---

## 2. Cache Lines, False Sharing & CPU Prefetchers

Data is never fetched from system RAM byte-by-byte; modern CPUs operate in discrete chunks known as **Cache Lines (typically 64 bytes)**.

> [!CAUTION]
> **False Sharing** occurs when two distinct threads on different cores update independent variables that happen to reside within the exact same 64-byte cache line. The CPU cache coherence protocol (MESI/MOESI) repeatedly invalidates the cache line across cores, causing extreme bus contention and severe performance degradation.

---

## 3. Inspecting Hardware Cache Levels & TLB Misses

```bash
# Inspect CPU cache sizes and associativity
getconf -a | grep -i cache

# Profile cache misses and branch mispredictions with perf
perf stat -e cache-references,cache-misses,branches,branch-misses ./high_throughput_service
```

---

## 4. Memory Saturation & OOM Killer Traps

> [!NOTE]
> When physical RAM and swap are completely exhausted, the kernel invokes the **Out-Of-Memory (OOM) Killer** to sacrifice processes with the highest `oom_score`.

```bash
# Inspect OOM score for a critical database process (PID 1420)
cat /proc/1420/oom_score

# Protect a mission-critical process from being terminated by OOM killer
echo "-1000" | sudo tee /proc/1420/oom_score_adj
```'
WHERE slug = 'cpu-memory-hierarchy';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cpu-memory-hierarchy';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Latency Numbers Every Systems Engineer Must Know', 'Understanding access latency differentials is essential for performance engineering and high-throughput application design:

| Storage Tier | Typical Latency | Approximate Scale Analogy |
|---|---|---|
| **L1 CPU Cache** | ~0.5 - 1 ns | 1 heartbeat (~1 second) |
| **L2 CPU Cache** | ~3 - 7 ns | 7 seconds |
| **L3 CPU Shared Cache** | ~10 - 20 ns | 20 seconds |
| **Main RAM (DDR4/DDR5)** | ~50 - 100 ns | 1.5 minutes |
| **NVMe PCIe SSD** | ~10 - 50 µs | 1.5 days |
| **SATA SSD** | ~100 - 250 µs | 3.5 days |
| **Rotational HDD (7200 RPM)** | ~1 - 10 ms | 1 - 4 months |
| **Cross-Continental WAN Roundtrip** | ~150 ms | 5 years |', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cpu-memory-hierarchy';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Cache Lines, False Sharing & CPU Prefetchers', 'Data is never fetched from system RAM byte-by-byte; modern CPUs operate in discrete chunks known as **Cache Lines (typically 64 bytes)**.

> [!CAUTION]
> **False Sharing** occurs when two distinct threads on different cores update independent variables that happen to reside within the exact same 64-byte cache line. The CPU cache coherence protocol (MESI/MOESI) repeatedly invalidates the cache line across cores, causing extreme bus contention and severe performance degradation.', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cpu-memory-hierarchy';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Inspecting Hardware Cache Levels & TLB Misses', '```bash
# Inspect CPU cache sizes and associativity
getconf -a | grep -i cache

# Profile cache misses and branch mispredictions with perf
perf stat -e cache-references,cache-misses,branches,branch-misses ./high_throughput_service
```', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cpu-memory-hierarchy';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Memory Saturation & OOM Killer Traps', '> [!NOTE]
> When physical RAM and swap are completely exhausted, the kernel invokes the **Out-Of-Memory (OOM) Killer** to sacrifice processes with the highest `oom_score`.

```bash
# Inspect OOM score for a critical database process (PID 1420)
cat /proc/1420/oom_score

# Protect a mission-critical process from being terminated by OOM killer
echo "-1000" | sudo tee /proc/1420/oom_score_adj
```', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: storage-tech-benchmarking
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 20,
    content_markdown = '## 1. IOPS vs Throughput vs Tail Latency (p99/p99.9)

Storage performance cannot be measured by a single number. Three distinct dimensions dictate real-world database and application throughput:

- **IOPS (Input/Output Operations Per Second)**: Critical for transaction processing (OLTP) and small block random I/O (4KB/8KB).
- **Throughput (MB/s or GB/s)**: Critical for bulk backups, analytics scans (OLAP), and streaming media with large block sequential I/O (128KB - 1MB).
- **Tail Latency (p99 / p99.9)**: The duration of the slowest 1% or 0.1% of I/O operations. In microservices, high tail latency causes severe cascading request timeouts.

---

## 2. Industry Standard Storage Benchmarking with fio

Avoid naive tools like `dd` which benchmark the Linux page cache rather than physical media. Use **Flexible I/O Tester (`fio`)**:

```bash
# Benchmark 4KB Random Read IOPS at Queue Depth 32 (Direct I/O bypassing page cache)
fio --name=randread_test --ioengine=libaio --direct=1 --iodepth=32 \
    --rw=randread --bs=4k --size=4G --numjobs=4 --runtime=60 \
    --group_reporting --filename=/mnt/testdisk/fiotest.tmp
```

---

## 3. Real-Time Storage I/O Monitoring with iostat

```bash
# Display extended I/O statistics every 2 seconds with human readable units
iostat -xz 2

# Key columns to watch:
# %util: Percentage of time the disk had active requests. Near 100% indicates saturation.
# await: Average time (ms) spent waiting in queue plus service time.
# r_await / w_await: Read vs write latency in milliseconds.
```

---

## 4. NVMe Health Inspection with smartctl & nvme-cli

> [!TIP]
> Monitor the `percentage_used` NVMe SMART counter to replace endurance-depleted enterprise flash drives before silent sector write errors occur.

```bash
# Inspect enterprise NVMe health and media wear indicator
sudo nvme smart-log /dev/nvme0n1

# Check traditional SATA SSD/HDD SMART attributes
sudo smartctl -A /dev/sda
```'
WHERE slug = 'storage-tech-benchmarking';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'storage-tech-benchmarking';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. IOPS vs Throughput vs Tail Latency (p99/p99.9)', 'Storage performance cannot be measured by a single number. Three distinct dimensions dictate real-world database and application throughput:

- **IOPS (Input/Output Operations Per Second)**: Critical for transaction processing (OLTP) and small block random I/O (4KB/8KB).
- **Throughput (MB/s or GB/s)**: Critical for bulk backups, analytics scans (OLAP), and streaming media with large block sequential I/O (128KB - 1MB).
- **Tail Latency (p99 / p99.9)**: The duration of the slowest 1% or 0.1% of I/O operations. In microservices, high tail latency causes severe cascading request timeouts.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'storage-tech-benchmarking';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Industry Standard Storage Benchmarking with fio', 'Avoid naive tools like `dd` which benchmark the Linux page cache rather than physical media. Use **Flexible I/O Tester (`fio`)**:

```bash
# Benchmark 4KB Random Read IOPS at Queue Depth 32 (Direct I/O bypassing page cache)
fio --name=randread_test --ioengine=libaio --direct=1 --iodepth=32 \
    --rw=randread --bs=4k --size=4G --numjobs=4 --runtime=60 \
    --group_reporting --filename=/mnt/testdisk/fiotest.tmp
```', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'storage-tech-benchmarking';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Real-Time Storage I/O Monitoring with iostat', '```bash
# Display extended I/O statistics every 2 seconds with human readable units
iostat -xz 2

# Key columns to watch:
# %util: Percentage of time the disk had active requests. Near 100% indicates saturation.
# await: Average time (ms) spent waiting in queue plus service time.
# r_await / w_await: Read vs write latency in milliseconds.
```', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'storage-tech-benchmarking';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. NVMe Health Inspection with smartctl & nvme-cli', '> [!TIP]
> Monitor the `percentage_used` NVMe SMART counter to replace endurance-depleted enterprise flash drives before silent sector write errors occur.

```bash
# Inspect enterprise NVMe health and media wear indicator
sudo nvme smart-log /dev/nvme0n1

# Check traditional SATA SSD/HDD SMART attributes
sudo smartctl -A /dev/sda
```', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: linux-process-lifecycle
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 22,
    content_markdown = '## 1. The Fork-Exec Model, Process Descriptors & PID 1

In Linux, all processes are created through the fundamental system call pairing: **`fork()`** and **`execve()`**.

- **`fork()`**: Duplicates the calling process descriptor (`task_struct`) and sets up Copy-on-Write (CoW) virtual memory pages.
- **`execve()`**: Replaces the process memory image with a newly executed binary executable.
- **PID 1 (systemd / init)**: The root ancestor of every user-space process. It possesses the special duty of adopting and reaping orphaned child processes.

---

## 2. Zombie vs Orphan Processes: Lifecycle States

### Process State Transitions

```
[Running (R)] <---> [Interruptible Sleep (S)]
       |                       |
       v                       v
[Stopped (T)]           [Uninterruptible Disk Sleep (D)]
       |                       |
       +-------> [Zombie (Z)] -+
                     |
                 [waitpid()]
                     |
                 [Terminated]
```

> [!WARNING]
> **Zombie Processes (`Z` state)** consume no CPU and no RAM, but they consume an entry in the finite operating system Process ID (PID) table. If PID exhaustion occurs (`/proc/sys/kernel/pid_max`), no new processes or SSH sessions can be created!

---

## 3. POSIX Signals & Graceful Shutdown Handlers

Understanding how processes receive signals is critical for writing robust cloud microservices:

| Signal | Number | Catchable? | Standard Intended Behavior |
|---|---|---|---|
| **SIGTERM** | 15 | Yes | Graceful shutdown: finish active requests and close DB pools |
| **SIGKILL** | 9 | **No** | Immediate kernel termination: resources cleaned, data may corrupt |
| **SIGHUP** | 1 | Yes | Reload configuration files without dropping active connections |
| **SIGINT** | 2 | Yes | Terminal interrupt triggered by Ctrl+C |

```bash
# Send graceful reload signal to Nginx master process
sudo kill -HUP $(cat /var/run/nginx.pid)

# Identify unkillable processes stuck in Uninterruptible D-state
ps -eo pid,ppid,state,wchan:20,comm | grep " D "
```

---

## 4. Clearing Zombie Accumulations & Process Debugging

> [!TIP]
> You cannot kill a zombie process with `kill -9`, because it is already dead! You must signal or terminate its **parent process** (`PPID`) to force adoption by PID 1.

```bash
# Find zombie processes and their responsible parent PID
ps -A -ostat,ppid,pid,cmd | grep -e ''^[Zz]''

# Signal the parent process to trigger waitpid()
kill -CHLD <PARENT_PID>
```'
WHERE slug = 'linux-process-lifecycle';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'linux-process-lifecycle';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. The Fork-Exec Model, Process Descriptors & PID 1', 'In Linux, all processes are created through the fundamental system call pairing: **`fork()`** and **`execve()`**.

- **`fork()`**: Duplicates the calling process descriptor (`task_struct`) and sets up Copy-on-Write (CoW) virtual memory pages.
- **`execve()`**: Replaces the process memory image with a newly executed binary executable.
- **PID 1 (systemd / init)**: The root ancestor of every user-space process. It possesses the special duty of adopting and reaping orphaned child processes.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'linux-process-lifecycle';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Zombie vs Orphan Processes: Lifecycle States', '### Process State Transitions

```
[Running (R)] <---> [Interruptible Sleep (S)]
       |                       |
       v                       v
[Stopped (T)]           [Uninterruptible Disk Sleep (D)]
       |                       |
       +-------> [Zombie (Z)] -+
                     |
                 [waitpid()]
                     |
                 [Terminated]
```

> [!WARNING]
> **Zombie Processes (`Z` state)** consume no CPU and no RAM, but they consume an entry in the finite operating system Process ID (PID) table. If PID exhaustion occurs (`/proc/sys/kernel/pid_max`), no new processes or SSH sessions can be created!', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'linux-process-lifecycle';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. POSIX Signals & Graceful Shutdown Handlers', 'Understanding how processes receive signals is critical for writing robust cloud microservices:

| Signal | Number | Catchable? | Standard Intended Behavior |
|---|---|---|---|
| **SIGTERM** | 15 | Yes | Graceful shutdown: finish active requests and close DB pools |
| **SIGKILL** | 9 | **No** | Immediate kernel termination: resources cleaned, data may corrupt |
| **SIGHUP** | 1 | Yes | Reload configuration files without dropping active connections |
| **SIGINT** | 2 | Yes | Terminal interrupt triggered by Ctrl+C |

```bash
# Send graceful reload signal to Nginx master process
sudo kill -HUP $(cat /var/run/nginx.pid)

# Identify unkillable processes stuck in Uninterruptible D-state
ps -eo pid,ppid,state,wchan:20,comm | grep " D "
```', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'linux-process-lifecycle';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Clearing Zombie Accumulations & Process Debugging', '> [!TIP]
> You cannot kill a zombie process with `kill -9`, because it is already dead! You must signal or terminate its **parent process** (`PPID`) to force adoption by PID 1.

```bash
# Find zombie processes and their responsible parent PID
ps -A -ostat,ppid,pid,cmd | grep -e ''^[Zz]''

# Signal the parent process to trigger waitpid()
kill -CHLD <PARENT_PID>
```', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: systemd-service-management
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 20,
    content_markdown = '## 1. systemd Architecture & Unit Files

**systemd** provides unified process supervision, cgroup resource bounding, socket activation, and logging via `systemd-journald`.

### Core Unit Types
- **`*.service`**: Manages background daemons and applications.
- **`*.socket`**: Manages IPC and network sockets for on-demand daemon startup.
- **`*.timer`**: Modern replacement for legacy cron jobs with monotonic clock support.
- **`*.slice`**: Organizes processes into cgroup resource allocation hierarchies.

---

## 2. Anatomy of a Hardened Production Unit File

Save custom service unit files in `/etc/systemd/system/`:

```ini
[Unit]
Description=High-Performance API Backend
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
User=apprunner
Group=apprunner
WorkingDirectory=/opt/backend
ExecStart=/opt/backend/bin/server
Restart=always
RestartSec=5s

# Security Hardening Directives
ProtectSystem=strict
ProtectHome=true
NoNewPrivileges=true
PrivateTmp=true

# Cgroup Resource Limits
MemoryMax=1G
CPUQuota=150%

[Install]
WantedBy=multi-user.target
```

---

## 3. Service Lifecycle & Journald Diagnostics

```bash
# Reload systemd manager after modifying unit files
sudo systemctl daemon-reload

# Start and enable service on boot
sudo systemctl enable --now backend.service

# View real-time logs with structured metadata
journalctl -u backend.service -f -o json-pretty

# Inspect service cgroup resource usage in real time
systemd-cgtop
```

---

## 4. Crash Loop & Boot Target Troubleshooting

> [!WARNING]
> A common cause of service boot failure is starting before dependent network interfaces or database sockets are fully initialized.

```bash
# Check why a unit failed with exit code and backtrace
systemctl status backend.service -l --no-pager

# Find the slowest services delaying system boot
systemd-analyze blame
systemd-analyze critical-chain
```'
WHERE slug = 'systemd-service-management';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'systemd-service-management';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. systemd Architecture & Unit Files', '**systemd** provides unified process supervision, cgroup resource bounding, socket activation, and logging via `systemd-journald`.

### Core Unit Types
- **`*.service`**: Manages background daemons and applications.
- **`*.socket`**: Manages IPC and network sockets for on-demand daemon startup.
- **`*.timer`**: Modern replacement for legacy cron jobs with monotonic clock support.
- **`*.slice`**: Organizes processes into cgroup resource allocation hierarchies.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'systemd-service-management';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Anatomy of a Hardened Production Unit File', 'Save custom service unit files in `/etc/systemd/system/`:

```ini
[Unit]
Description=High-Performance API Backend
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
User=apprunner
Group=apprunner
WorkingDirectory=/opt/backend
ExecStart=/opt/backend/bin/server
Restart=always
RestartSec=5s

# Security Hardening Directives
ProtectSystem=strict
ProtectHome=true
NoNewPrivileges=true
PrivateTmp=true

# Cgroup Resource Limits
MemoryMax=1G
CPUQuota=150%

[Install]
WantedBy=multi-user.target
```', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'systemd-service-management';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Service Lifecycle & Journald Diagnostics', '```bash
# Reload systemd manager after modifying unit files
sudo systemctl daemon-reload

# Start and enable service on boot
sudo systemctl enable --now backend.service

# View real-time logs with structured metadata
journalctl -u backend.service -f -o json-pretty

# Inspect service cgroup resource usage in real time
systemd-cgtop
```', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'systemd-service-management';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Crash Loop & Boot Target Troubleshooting', '> [!WARNING]
> A common cause of service boot failure is starting before dependent network interfaces or database sockets are fully initialized.

```bash
# Check why a unit failed with exit code and backtrace
systemctl status backend.service -l --no-pager

# Find the slowest services delaying system boot
systemd-analyze blame
systemd-analyze critical-chain
```', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: linux-filesystem-hierarchy
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 18,
    content_markdown = '## 1. The Filesystem Hierarchy Standard (FHS 3.0)

The Linux directory structure is standardized under the **Filesystem Hierarchy Standard (FHS)** to ensure application portability and predictable configuration locations:

| Directory | Purpose | Persisted on Disk? |
|---|---|---|
| `/etc` | Host-specific system-wide configuration files | Yes |
| `/var` | Variable runtime data: logs (`/var/log`), spools, databases | Yes |
| `/proc` | Virtual pseudo-filesystem exposing kernel state and process memory | **No (In-Memory)** |
| `/sys` | Virtual pseudo-filesystem exposing hardware buses, drivers, and cgroups | **No (In-Memory)** |
| `/dev` | Device node special files (`/dev/sda`, `/dev/urandom`, `/dev/null`) | **No (devtmpfs)** |
| `/run` | Ephemeral runtime state since boot: PID files and UNIX domain sockets | **No (tmpfs)** |
| `/opt` | Self-contained third-party add-on application packages | Yes |

---

## 2. Deep Dive into /proc and /sys

The `/proc` and `/sys` directories take up zero bytes of physical disk space. They are kernel memory hooks formatted as directories and text files:

```bash
# Inspect process 1 command line arguments
cat /proc/1/cmdline | tr ''\0'' '' ''

# View open file descriptors for process 1245
ls -la /proc/1245/fd/

# Read TCP socket buffer limits
cat /proc/sys/net/ipv4/tcp_rmem
```

---

## 3. Disk Space vs Inode Exhaustion Analysis

A filesystem can run out of space in two completely independent ways: **Block space exhaustion** or **Inode exhaustion**.

```bash
# Inspect block capacity in human readable units
df -hT

# Inspect inode capacity (crucial for mail servers and cache directories)
df -i

# Find top 10 directories consuming the most disk space
du -ahx /var | sort -rh | head -n 10
```

---

## 4. The Deleted File Inode Leak (Unlinked Space Trap)

> [!IMPORTANT]
> If a 50GB log file is deleted with `rm`, but an active process (like Nginx) still holds an open file descriptor to it, the disk space is **NOT** reclaimed!

```bash
# Find deleted files still held open in memory consuming disk space
sudo lsof +L1

# Reclaim the space immediately without restarting the service by truncating
echo "" | sudo tee /proc/<PID>/fd/<FD_NUMBER>
```'
WHERE slug = 'linux-filesystem-hierarchy';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'linux-filesystem-hierarchy';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. The Filesystem Hierarchy Standard (FHS 3.0)', 'The Linux directory structure is standardized under the **Filesystem Hierarchy Standard (FHS)** to ensure application portability and predictable configuration locations:

| Directory | Purpose | Persisted on Disk? |
|---|---|---|
| `/etc` | Host-specific system-wide configuration files | Yes |
| `/var` | Variable runtime data: logs (`/var/log`), spools, databases | Yes |
| `/proc` | Virtual pseudo-filesystem exposing kernel state and process memory | **No (In-Memory)** |
| `/sys` | Virtual pseudo-filesystem exposing hardware buses, drivers, and cgroups | **No (In-Memory)** |
| `/dev` | Device node special files (`/dev/sda`, `/dev/urandom`, `/dev/null`) | **No (devtmpfs)** |
| `/run` | Ephemeral runtime state since boot: PID files and UNIX domain sockets | **No (tmpfs)** |
| `/opt` | Self-contained third-party add-on application packages | Yes |', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'linux-filesystem-hierarchy';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Deep Dive into /proc and /sys', 'The `/proc` and `/sys` directories take up zero bytes of physical disk space. They are kernel memory hooks formatted as directories and text files:

```bash
# Inspect process 1 command line arguments
cat /proc/1/cmdline | tr ''\0'' '' ''

# View open file descriptors for process 1245
ls -la /proc/1245/fd/

# Read TCP socket buffer limits
cat /proc/sys/net/ipv4/tcp_rmem
```', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'linux-filesystem-hierarchy';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Disk Space vs Inode Exhaustion Analysis', 'A filesystem can run out of space in two completely independent ways: **Block space exhaustion** or **Inode exhaustion**.

```bash
# Inspect block capacity in human readable units
df -hT

# Inspect inode capacity (crucial for mail servers and cache directories)
df -i

# Find top 10 directories consuming the most disk space
du -ahx /var | sort -rh | head -n 10
```', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'linux-filesystem-hierarchy';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. The Deleted File Inode Leak (Unlinked Space Trap)', '> [!IMPORTANT]
> If a 50GB log file is deleted with `rm`, but an active process (like Nginx) still holds an open file descriptor to it, the disk space is **NOT** reclaimed!

```bash
# Find deleted files still held open in memory consuming disk space
sudo lsof +L1

# Reclaim the space immediately without restarting the service by truncating
echo "" | sudo tee /proc/<PID>/fd/<FD_NUMBER>
```', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: ip-addressing-basics
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 18,
    content_markdown = '## 1. IPv4 Structure & The 32-Bit Binary Reality

Every IPv4 address is fundamentally a 32-bit unsigned binary integer divided into four 8-bit octets separated by decimal periods.

```
Dotted Decimal:    192    .    168    .     1     .    10
8-Bit Binary:   11000000  . 10101000  . 00000001  . 00001010
```

### Network Portion vs Host Portion
A subnet mask separates the address into:
1. **Network Identifier**: Identifies the local broadcast domain / network segment.
2. **Host Identifier**: Uniquely identifies the endpoint NIC inside that segment.

---

## 2. RFC 1918 Private Address Allocations & Special Ranges

The Internet Assigned Numbers Authority (IANA) reserved three non-routable private IP address blocks (RFC 1918):

| Class Scope | Address Range | Prefix | Total Addresses | Typical Use Case |
|---|---|---|---|---|
| **Class A Private** | `10.0.0.0` - `10.255.255.255` | `/8` | 16,777,216 | Large enterprise data centers & AWS VPCs |
| **Class B Private** | `172.16.0.0` - `172.31.255.255` | `/12` | 1,048,576 | Medium corporate branches & Docker bridges |
| **Class C Private** | `192.168.0.0` - `192.168.255.255` | `/16` | 65,536 | Small office / home networks |
| **Loopback** | `127.0.0.0` - `127.255.255.255` | `/8` | N/A | Inter-process communication on localhost |
| **APIPA (Link-Local)** | `169.254.0.0` - `169.254.255.255` | `/16` | 65,536 | Auto-assigned when DHCP fails |

---

## 3. Inspecting IP Addresses with iproute2

```bash
# Show IP addresses for all active interfaces with color highlighting
ip -c -br addr show

# Show detailed interface stats including packet errors and collisions
ip -s link show dev eth0
```

---

## 4. Troubleshooting IP Conflicts & ARP Poisoning

> [!WARNING]
> Duplicate IP assignments within the same Layer 2 broadcast domain cause erratic packet bouncing and dropped TCP sessions.

```bash
# Send gratuitous ARP requests to detect IP collisions before configuring an address
sudo arping -D -I eth0 -c 3 192.168.1.50

# Inspect the active kernel ARP cache table
ip neigh show
```'
WHERE slug = 'ip-addressing-basics';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ip-addressing-basics';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. IPv4 Structure & The 32-Bit Binary Reality', 'Every IPv4 address is fundamentally a 32-bit unsigned binary integer divided into four 8-bit octets separated by decimal periods.

```
Dotted Decimal:    192    .    168    .     1     .    10
8-Bit Binary:   11000000  . 10101000  . 00000001  . 00001010
```

### Network Portion vs Host Portion
A subnet mask separates the address into:
1. **Network Identifier**: Identifies the local broadcast domain / network segment.
2. **Host Identifier**: Uniquely identifies the endpoint NIC inside that segment.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ip-addressing-basics';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. RFC 1918 Private Address Allocations & Special Ranges', 'The Internet Assigned Numbers Authority (IANA) reserved three non-routable private IP address blocks (RFC 1918):

| Class Scope | Address Range | Prefix | Total Addresses | Typical Use Case |
|---|---|---|---|---|
| **Class A Private** | `10.0.0.0` - `10.255.255.255` | `/8` | 16,777,216 | Large enterprise data centers & AWS VPCs |
| **Class B Private** | `172.16.0.0` - `172.31.255.255` | `/12` | 1,048,576 | Medium corporate branches & Docker bridges |
| **Class C Private** | `192.168.0.0` - `192.168.255.255` | `/16` | 65,536 | Small office / home networks |
| **Loopback** | `127.0.0.0` - `127.255.255.255` | `/8` | N/A | Inter-process communication on localhost |
| **APIPA (Link-Local)** | `169.254.0.0` - `169.254.255.255` | `/16` | 65,536 | Auto-assigned when DHCP fails |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ip-addressing-basics';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Inspecting IP Addresses with iproute2', '```bash
# Show IP addresses for all active interfaces with color highlighting
ip -c -br addr show

# Show detailed interface stats including packet errors and collisions
ip -s link show dev eth0
```', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ip-addressing-basics';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Troubleshooting IP Conflicts & ARP Poisoning', '> [!WARNING]
> Duplicate IP assignments within the same Layer 2 broadcast domain cause erratic packet bouncing and dropped TCP sessions.

```bash
# Send gratuitous ARP requests to detect IP collisions before configuring an address
sudo arping -D -I eth0 -c 3 192.168.1.50

# Inspect the active kernel ARP cache table
ip neigh show
```', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: cidr-and-masks
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 20,
    content_markdown = '## 1. Classless Inter-Domain Routing (CIDR) Mathematics

In 1993, RFC 1519 abolished rigid Class A/B/C boundaries in favor of **CIDR notation** (`/prefix`), where the prefix denotes the exact count of leading binary 1s in the subnet mask.

### Usable Host Formula
For any IPv4 subnet mask of prefix length ( n ):
[
	ext{Total Addresses} = 2^{(32 - n)}
]
[
	ext{Usable Host Addresses} = 2^{(32 - n)} - 2
]

> [!NOTE]
> Two addresses are reserved by RFC standards:
> 1. **Network Address** (all host bits 0)
> 2. **Broadcast Address** (all host bits 1)

---

## 2. The Magic Number Method for Rapid Mental Math

To calculate subnets in seconds without binary conversion, use the **Magic Number**:
[
	ext{Magic Number} = 256 - 	ext{Interesting Octet Value}
]

### Example: `192.168.10.75 /26`
1. `/26` spans 24 bits + 2 bits into the 4th octet: `255.255.255.192`.
2. Interesting octet = 192.
3. Magic Number = ( 256 - 192 = 64 ).
4. Subnet blocks increment by 64:
   - Block 0: `192.168.10.0` to `192.168.10.63`
   - Block 1: `192.168.10.64` to `192.168.10.127` (`75` falls here!)
5. Network IP: `192.168.10.64`
6. First Usable: `192.168.10.65`
7. Last Usable: `192.168.10.126`
8. Broadcast IP: `192.168.10.127`

---

## 3. Calculating Subnets with ipcalc and Python

```bash
# Calculate network boundaries and broadcast address from shell
ipcalc 10.200.4.0/22
```

```python
# Automated CIDR validation in Python standard library
import ipaddress

net = ipaddress.ip_network(''10.200.4.0/22'')
print(f"Network: {net.network_address}")
print(f"Broadcast: {net.broadcast_address}")
print(f"Netmask: {net.netmask}")
print(f"Total usable hosts: {net.num_addresses - 2}")
```

---

## 4. Common Subnet Mask Mismatch Traps

> [!CAUTION]
> If Host A is configured with `/24` and Host B is configured with `/25` on the same switch, Host B will try to reach Host A through the default gateway instead of sending an ARP request directly, leading to asymmetric routing failures.'
WHERE slug = 'cidr-and-masks';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cidr-and-masks';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Classless Inter-Domain Routing (CIDR) Mathematics', 'In 1993, RFC 1519 abolished rigid Class A/B/C boundaries in favor of **CIDR notation** (`/prefix`), where the prefix denotes the exact count of leading binary 1s in the subnet mask.

### Usable Host Formula
For any IPv4 subnet mask of prefix length ( n ):
[
	ext{Total Addresses} = 2^{(32 - n)}
]
[
	ext{Usable Host Addresses} = 2^{(32 - n)} - 2
]

> [!NOTE]
> Two addresses are reserved by RFC standards:
> 1. **Network Address** (all host bits 0)
> 2. **Broadcast Address** (all host bits 1)', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cidr-and-masks';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. The Magic Number Method for Rapid Mental Math', 'To calculate subnets in seconds without binary conversion, use the **Magic Number**:
[
	ext{Magic Number} = 256 - 	ext{Interesting Octet Value}
]

### Example: `192.168.10.75 /26`
1. `/26` spans 24 bits + 2 bits into the 4th octet: `255.255.255.192`.
2. Interesting octet = 192.
3. Magic Number = ( 256 - 192 = 64 ).
4. Subnet blocks increment by 64:
   - Block 0: `192.168.10.0` to `192.168.10.63`
   - Block 1: `192.168.10.64` to `192.168.10.127` (`75` falls here!)
5. Network IP: `192.168.10.64`
6. First Usable: `192.168.10.65`
7. Last Usable: `192.168.10.126`
8. Broadcast IP: `192.168.10.127`', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cidr-and-masks';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Calculating Subnets with ipcalc and Python', '```bash
# Calculate network boundaries and broadcast address from shell
ipcalc 10.200.4.0/22
```

```python
# Automated CIDR validation in Python standard library
import ipaddress

net = ipaddress.ip_network(''10.200.4.0/22'')
print(f"Network: {net.network_address}")
print(f"Broadcast: {net.broadcast_address}")
print(f"Netmask: {net.netmask}")
print(f"Total usable hosts: {net.num_addresses - 2}")
```', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cidr-and-masks';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Common Subnet Mask Mismatch Traps', '> [!CAUTION]
> If Host A is configured with `/24` and Host B is configured with `/25` on the same switch, Host B will try to reach Host A through the default gateway instead of sending an ARP request directly, leading to asymmetric routing failures.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: dns-records-and-troubleshooting
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 22,
    content_markdown = '## 1. Standard DNS Record Types & Resource Records

The Domain Name System (DNS) maps human-readable hostnames to network resources through specific Resource Records (RRs):

| Record Type | Description | RFC Standard | Example Content |
|---|---|---|---|
| **A** | Maps hostname to IPv4 address | RFC 1035 | `93.184.216.34` |
| **AAAA** | Maps hostname to 128-bit IPv6 address | RFC 3596 | `2606:2800:220:1:248:1893:25c8:1946` |
| **CNAME** | Canonical alias pointing to another domain | RFC 1035 | `app.example.com. -> cdn.cloudflare.net.` |
| **MX** | Mail exchange server with priority integer | RFC 1035 | `10 mail.example.com.` |
| **TXT** | Arbitrary text: SPF, DKIM, site verification | RFC 1464 | `v=spf1 include:_spf.google.com ~all` |
| **SRV** | Service discovery with port, weight, priority | RFC 2782 | `_sip._tcp.example.com. 3600 IN SRV 10 60 5060 s1.example.com.` |
| **NS** | Authoritative nameserver delegation | RFC 1035 | `ns1.digitalocean.com.` |
| **SOA** | Start of Authority: zone serial, timers, TTL | RFC 1035 | `admin.example.com. 2026092101 7200 3600 1209600 300` |

---

## 2. Authoritative Resolution Flow from Root to Leaf

When your client queries `api.stripe.com`, the recursive resolver executes iterative steps:

1. Resolver checks its local memory cache.
2. If miss, queries the **DNS Root Servers** (`[a-m].root-servers.net`) for the `.com` TLD.
3. Root server returns NS referral to `.com` Top-Level Domain (TLD) servers.
4. Resolver queries `.com` TLD servers for `stripe.com`.
5. TLD server returns NS referral to Stripe''s authoritative nameservers.
6. Resolver queries Stripe''s authoritative server for `api.stripe.com`.
7. Authoritative server returns A/AAAA record with TTL.

---

## 3. Professional DNS Troubleshooting with dig & dog

```bash
# Trace full iterative resolution path from root servers
dig +trace +nodnssec api.stripe.com

# Query a specific DNS server directly, bypassing local caches
dig @1.1.1.1 example.com A +short

# Inspect email authentication TXT records (SPF and DMARC)
dig _dmarc.google.com TXT +short

# Reverse DNS lookup (PTR record) for an IP address
dig -x 8.8.8.8 +short
```

---

## 4. DNS Caching, Negative TTL & NXDOMAIN Pitfalls

> [!TIP]
> **Negative Caching (RFC 2308)**: If a client queries a non-existent subdomain and receives `NXDOMAIN`, recursive resolvers cache this failure for the duration of the SOA record''s MINIMUM field!

### Checklist for DNS Debugging
1. Test against external resolver: `dig @8.8.8.8 <domain>`
2. Test local resolver: `cat /etc/resolv.conf`
3. Flush local systemd-resolved cache:
   ```bash
   sudo resolvectl flush-caches
   resolvectl statistics
   ```'
WHERE slug = 'dns-records-and-troubleshooting';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'dns-records-and-troubleshooting';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Standard DNS Record Types & Resource Records', 'The Domain Name System (DNS) maps human-readable hostnames to network resources through specific Resource Records (RRs):

| Record Type | Description | RFC Standard | Example Content |
|---|---|---|---|
| **A** | Maps hostname to IPv4 address | RFC 1035 | `93.184.216.34` |
| **AAAA** | Maps hostname to 128-bit IPv6 address | RFC 3596 | `2606:2800:220:1:248:1893:25c8:1946` |
| **CNAME** | Canonical alias pointing to another domain | RFC 1035 | `app.example.com. -> cdn.cloudflare.net.` |
| **MX** | Mail exchange server with priority integer | RFC 1035 | `10 mail.example.com.` |
| **TXT** | Arbitrary text: SPF, DKIM, site verification | RFC 1464 | `v=spf1 include:_spf.google.com ~all` |
| **SRV** | Service discovery with port, weight, priority | RFC 2782 | `_sip._tcp.example.com. 3600 IN SRV 10 60 5060 s1.example.com.` |
| **NS** | Authoritative nameserver delegation | RFC 1035 | `ns1.digitalocean.com.` |
| **SOA** | Start of Authority: zone serial, timers, TTL | RFC 1035 | `admin.example.com. 2026092101 7200 3600 1209600 300` |', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'dns-records-and-troubleshooting';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Authoritative Resolution Flow from Root to Leaf', 'When your client queries `api.stripe.com`, the recursive resolver executes iterative steps:

1. Resolver checks its local memory cache.
2. If miss, queries the **DNS Root Servers** (`[a-m].root-servers.net`) for the `.com` TLD.
3. Root server returns NS referral to `.com` Top-Level Domain (TLD) servers.
4. Resolver queries `.com` TLD servers for `stripe.com`.
5. TLD server returns NS referral to Stripe''s authoritative nameservers.
6. Resolver queries Stripe''s authoritative server for `api.stripe.com`.
7. Authoritative server returns A/AAAA record with TTL.', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'dns-records-and-troubleshooting';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Professional DNS Troubleshooting with dig & dog', '```bash
# Trace full iterative resolution path from root servers
dig +trace +nodnssec api.stripe.com

# Query a specific DNS server directly, bypassing local caches
dig @1.1.1.1 example.com A +short

# Inspect email authentication TXT records (SPF and DMARC)
dig _dmarc.google.com TXT +short

# Reverse DNS lookup (PTR record) for an IP address
dig -x 8.8.8.8 +short
```', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'dns-records-and-troubleshooting';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. DNS Caching, Negative TTL & NXDOMAIN Pitfalls', '> [!TIP]
> **Negative Caching (RFC 2308)**: If a client queries a non-existent subdomain and receives `NXDOMAIN`, recursive resolvers cache this failure for the duration of the SOA record''s MINIMUM field!

### Checklist for DNS Debugging
1. Test against external resolver: `dig @8.8.8.8 <domain>`
2. Test local resolver: `cat /etc/resolv.conf`
3. Flush local systemd-resolved cache:
   ```bash
   sudo resolvectl flush-caches
   resolvectl statistics
   ```', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: ip-routing-fundamentals
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 20,
    content_markdown = '## 1. The IP Routing Engine & Longest Prefix Match

Routers do not memorize every computer on the global Internet. Instead, routers evaluate destination IP addresses against their local **Forwarding Information Base (FIB)** using the rule of **Longest Prefix Match (LPM)**.

### Longest Prefix Match Rule
If an incoming packet destination is `10.50.12.4`, and the routing table contains:
- Route A: `10.0.0.0/8` via Gateway 1
- Route B: `10.50.0.0/16` via Gateway 2
- Route C: `10.50.12.0/24` via Gateway 3

The router **always** selects **Route C (`/24`)**, because `/24` is the most specific (longest) network mask matching the destination.

---

## 2. Default Gateways & Next-Hop Resolution

When a host needs to communicate with an IP address outside its local subnet:

1. Host performs bitwise AND of destination IP and local netmask.
2. Determines destination is on an external network.
3. Consults routing table for default route (`0.0.0.0/0`).
4. Sends an **ARP request** to resolve the MAC address of the **Default Gateway**, NOT the destination host!
5. Encapsulates IP packet into an Ethernet frame with the gateway''s destination MAC address.

---

## 3. Inspecting & Modifying Linux Kernel Routing Tables

```bash
# Display detailed IPv4 routing table
ip route show

# Add a static route for a private subnet via a specific gateway
sudo ip route add 10.100.0.0/16 via 192.168.1.1 dev eth0

# Trace Layer 3 packet hops with response times
traceroute -n -T -p 443 1.1.1.1
```

---

## 4. Diagnosing Routing Loops & TTL Exceeded Errors

> [!WARNING]
> If two routers point default or static routes to each other, packets bounce continuously until the IP header **Time-To-Live (TTL)** decrements to 0, returning `ICMP Type 11 (Time Exceeded)`.

```bash
# Verify kernel IP forwarding is enabled if this machine acts as a router
sysctl net.ipv4.ip_forward

# Enable IP forwarding persistently
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.d/99-routing.conf && sudo sysctl -p
```'
WHERE slug = 'ip-routing-fundamentals';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ip-routing-fundamentals';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. The IP Routing Engine & Longest Prefix Match', 'Routers do not memorize every computer on the global Internet. Instead, routers evaluate destination IP addresses against their local **Forwarding Information Base (FIB)** using the rule of **Longest Prefix Match (LPM)**.

### Longest Prefix Match Rule
If an incoming packet destination is `10.50.12.4`, and the routing table contains:
- Route A: `10.0.0.0/8` via Gateway 1
- Route B: `10.50.0.0/16` via Gateway 2
- Route C: `10.50.12.0/24` via Gateway 3

The router **always** selects **Route C (`/24`)**, because `/24` is the most specific (longest) network mask matching the destination.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ip-routing-fundamentals';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Default Gateways & Next-Hop Resolution', 'When a host needs to communicate with an IP address outside its local subnet:

1. Host performs bitwise AND of destination IP and local netmask.
2. Determines destination is on an external network.
3. Consults routing table for default route (`0.0.0.0/0`).
4. Sends an **ARP request** to resolve the MAC address of the **Default Gateway**, NOT the destination host!
5. Encapsulates IP packet into an Ethernet frame with the gateway''s destination MAC address.', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ip-routing-fundamentals';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Inspecting & Modifying Linux Kernel Routing Tables', '```bash
# Display detailed IPv4 routing table
ip route show

# Add a static route for a private subnet via a specific gateway
sudo ip route add 10.100.0.0/16 via 192.168.1.1 dev eth0

# Trace Layer 3 packet hops with response times
traceroute -n -T -p 443 1.1.1.1
```', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ip-routing-fundamentals';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Diagnosing Routing Loops & TTL Exceeded Errors', '> [!WARNING]
> If two routers point default or static routes to each other, packets bounce continuously until the IP header **Time-To-Live (TTL)** decrements to 0, returning `ICMP Type 11 (Time Exceeded)`.

```bash
# Verify kernel IP forwarding is enabled if this machine acts as a router
sysctl net.ipv4.ip_forward

# Enable IP forwarding persistently
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.d/99-routing.conf && sudo sysctl -p
```', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: linux-cli-files
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 20,
    content_markdown = '## 1. POSIX I/O Streams & File Descriptors

Every process launched in a UNIX environment initializes with three standard I/O streams:

| File Descriptor | Stream Name | Default Source/Sink | Redirection Syntax |
|---|---|---|---|
| **0** | `stdin` | Keyboard / Pipeline | `< input.txt` |
| **1** | `stdout` | Terminal Screen | `> out.log` or `>> out.log` |
| **2** | `stderr` | Terminal Screen | `2> error.log` or `2>&1` |

> [!NOTE]
> The classic idiom `command > output.log 2>&1` redirects standard output to a file, then points standard error to the same file descriptor as standard output.

---

## 2. Atomic File Operations & Safe Editing

Writing directly to production configuration files can leave them in a partially-written corrupted state if the process crashes mid-write.

### The Atomic Rename Pattern
POSIX guarantees that the `rename()` system call is **atomic**:

```bash
# Create and populate a temporary file
cat << ''EOF'' > /etc/nginx/conf.d/app.conf.tmp
server {
    listen 80;
    server_name example.com;
}
EOF

# Atomically replace the production config with no intermediate downtime
sudo mv /etc/nginx/conf.d/app.conf.tmp /etc/nginx/conf.d/app.conf
```

---

## 3. Advanced File Searching with find, grep & xargs

```bash
# Find files modified in the last 24 hours larger than 50MB
find /var/log -type f -mtime -1 -size +50M

# Search for regex pattern across files safely handling whitespace in filenames
find /etc -name "*.conf" -print0 | xargs -0 grep -Hn "proxy_pass"

# Batch compress old log archives in parallel
find /var/log/archive -name "*.log" -print0 | xargs -0 -P 4 gzip -9
```

---

## 4. File Locking Traps (flock & fcntl)

> [!TIP]
> Prevent overlapping cron job executions with `flock`:

```bash
# Run backup script with non-blocking exclusive file lock
flock -n /var/lock/backup.lock -c "/opt/scripts/backup.sh" || echo "Backup already running!"
```'
WHERE slug = 'linux-cli-files';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'linux-cli-files';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. POSIX I/O Streams & File Descriptors', 'Every process launched in a UNIX environment initializes with three standard I/O streams:

| File Descriptor | Stream Name | Default Source/Sink | Redirection Syntax |
|---|---|---|---|
| **0** | `stdin` | Keyboard / Pipeline | `< input.txt` |
| **1** | `stdout` | Terminal Screen | `> out.log` or `>> out.log` |
| **2** | `stderr` | Terminal Screen | `2> error.log` or `2>&1` |

> [!NOTE]
> The classic idiom `command > output.log 2>&1` redirects standard output to a file, then points standard error to the same file descriptor as standard output.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'linux-cli-files';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Atomic File Operations & Safe Editing', 'Writing directly to production configuration files can leave them in a partially-written corrupted state if the process crashes mid-write.

### The Atomic Rename Pattern
POSIX guarantees that the `rename()` system call is **atomic**:

```bash
# Create and populate a temporary file
cat << ''EOF'' > /etc/nginx/conf.d/app.conf.tmp
server {
    listen 80;
    server_name example.com;
}
EOF

# Atomically replace the production config with no intermediate downtime
sudo mv /etc/nginx/conf.d/app.conf.tmp /etc/nginx/conf.d/app.conf
```', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'linux-cli-files';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Advanced File Searching with find, grep & xargs', '```bash
# Find files modified in the last 24 hours larger than 50MB
find /var/log -type f -mtime -1 -size +50M

# Search for regex pattern across files safely handling whitespace in filenames
find /etc -name "*.conf" -print0 | xargs -0 grep -Hn "proxy_pass"

# Batch compress old log archives in parallel
find /var/log/archive -name "*.log" -print0 | xargs -0 -P 4 gzip -9
```', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'linux-cli-files';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. File Locking Traps (flock & fcntl)', '> [!TIP]
> Prevent overlapping cron job executions with `flock`:

```bash
# Run backup script with non-blocking exclusive file lock
flock -n /var/lock/backup.lock -c "/opt/scripts/backup.sh" || echo "Backup already running!"
```', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: permissions-chmod-chown
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 18,
    content_markdown = '## 1. Standard Octal Notation & Bitwise Representation

Linux file permissions are evaluated across three distinct security subjects: **User (Owner)**, **Group**, and **Others (World)**.

Each subject possesses three permission bits:
- **Read (r)**: Octal value `4` (Binary `100`)
- **Write (w)**: Octal value `2` (Binary `010`)
- **Execute (x)**: Octal value `1` (Binary `001`)

Summing the bits produces the octal digit:
- `rwx` = ( 4 + 2 + 1 = 7 )
- `rw-` = ( 4 + 2 + 0 = 6 )
- `r-x` = ( 4 + 0 + 1 = 5 )
- `---` = ( 0 + 0 + 0 = 0 )

---

## 2. Special Permission Bits: SUID, SGID & Sticky Bit

Standard permissions are augmented by three specialized security bits:

| Special Bit | Octal Prefix | On File | On Directory | Example |
|---|---|---|---|---|
| **SUID** | `4` (`4755`) | Executes with owner privileges | No effect | `/usr/bin/passwd` |
| **SGID** | `2` (`2775`) | Executes with group privileges | New files inherit parent group | Shared team directory |
| **Sticky** | `1` (`1777`) | No effect | Only file owner or root can delete files | `/tmp` |

---

## 3. Applying Robust Permissions in Production

```bash
# Standard secure permission for web application directory tree
find /var/www/html -type d -exec chmod 755 {} +
find /var/www/html -type f -exec chmod 644 {} +

# Secure private SSH keys strictly to the owner
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
chmod 700 ~/.ssh

# Change owner and group recursively
sudo chown -R www-data:www-data /var/www/html
```

---

## 4. SUID Vulnerability Auditing & Mitigation

> [!WARNING]
> Rogue or outdated SUID binaries are a primary vector for local privilege escalation (LPE) attacks.

```bash
# Audit all SUID binaries on the filesystem
find / -perm -4000 -type f 2>/dev/null

# Strip dangerous SUID bit from a binary
sudo chmod u-s /usr/local/bin/legacy_tool
```'
WHERE slug = 'permissions-chmod-chown';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'permissions-chmod-chown';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Standard Octal Notation & Bitwise Representation', 'Linux file permissions are evaluated across three distinct security subjects: **User (Owner)**, **Group**, and **Others (World)**.

Each subject possesses three permission bits:
- **Read (r)**: Octal value `4` (Binary `100`)
- **Write (w)**: Octal value `2` (Binary `010`)
- **Execute (x)**: Octal value `1` (Binary `001`)

Summing the bits produces the octal digit:
- `rwx` = ( 4 + 2 + 1 = 7 )
- `rw-` = ( 4 + 2 + 0 = 6 )
- `r-x` = ( 4 + 0 + 1 = 5 )
- `---` = ( 0 + 0 + 0 = 0 )', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'permissions-chmod-chown';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Special Permission Bits: SUID, SGID & Sticky Bit', 'Standard permissions are augmented by three specialized security bits:

| Special Bit | Octal Prefix | On File | On Directory | Example |
|---|---|---|---|---|
| **SUID** | `4` (`4755`) | Executes with owner privileges | No effect | `/usr/bin/passwd` |
| **SGID** | `2` (`2775`) | Executes with group privileges | New files inherit parent group | Shared team directory |
| **Sticky** | `1` (`1777`) | No effect | Only file owner or root can delete files | `/tmp` |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'permissions-chmod-chown';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Applying Robust Permissions in Production', '```bash
# Standard secure permission for web application directory tree
find /var/www/html -type d -exec chmod 755 {} +
find /var/www/html -type f -exec chmod 644 {} +

# Secure private SSH keys strictly to the owner
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
chmod 700 ~/.ssh

# Change owner and group recursively
sudo chown -R www-data:www-data /var/www/html
```', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'permissions-chmod-chown';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. SUID Vulnerability Auditing & Mitigation', '> [!WARNING]
> Rogue or outdated SUID binaries are a primary vector for local privilege escalation (LPE) attacks.

```bash
# Audit all SUID binaries on the filesystem
find / -perm -4000 -type f 2>/dev/null

# Strip dangerous SUID bit from a binary
sudo chmod u-s /usr/local/bin/legacy_tool
```', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: network-interfaces-and-iproute2
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 20,
    content_markdown = '## 1. Linux Network Interface Types & The Kernel Data Path

Linux supports rich physical and virtual network interfaces inside the kernel:

- **Physical NICs** (`eth0`, `enp3s0`): Hardware network controllers backed by kernel drivers (e.g., `e1000e`, `ixgbe`, `mlx5_core`).
- **Loopback** (`lo`): Virtual software interface for local IPC (`127.0.0.1`).
- **Virtual Ethernet Pairs (`veth`)**: Software pipes used to connect container network namespaces to the host.
- **Bridges (`br0`, `docker0`)**: Virtual Layer 2 software switches forwarding packets via MAC learning.

---

## 2. Modern Network Management with iproute2 vs net-tools

The legacy `net-tools` package (`ifconfig`, `route`, `netstat`, `arp`) has been deprecated for over a decade. All production systems rely on **`iproute2`**:

| Legacy Tool | Modern iproute2 Replacement | Action |
|---|---|---|
| `ifconfig eth0` | `ip addr show dev eth0` | Inspect IP addressing |
| `ifconfig eth0 up` | `ip link set dev eth0 up` | Bring interface online |
| `route -n` | `ip route show` | View routing table |
| `route add default gw ...` | `ip route add default via ...` | Set default gateway |
| `arp -a` | `ip neigh show` | View ARP cache table |
| `netstat -tulpn` | `ss -tulpn` | View listening network sockets |

---

## 3. Creating Virtual Network Pairs & Linux Bridges

```bash
# Create a virtual Linux software bridge
sudo ip link add name br-lab type bridge
sudo ip link set dev br-lab up

# Create a veth pair (virtual ethernet cable)
sudo ip link add veth-host type veth peer name veth-c1

# Attach one end to the bridge and activate
sudo ip link set dev veth-host master br-lab
sudo ip link set dev veth-host up
```

---

## 4. MTU Mismatch & Packet Fragmentation Issues

> [!CAUTION]
> If a server MTU is set to 9000 (Jumbo Frames) but intermediate switches or tunnels only support standard 1500 MTU, large TCP packets with DF (Don''t Fragment) bit will be dropped silently (Black Hole Routing).

```bash
# Test maximum path MTU using ping with Don''t Fragment flag
ping -M do -s 1472 -c 3 1.1.1.1
```'
WHERE slug = 'network-interfaces-and-iproute2';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'network-interfaces-and-iproute2';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Linux Network Interface Types & The Kernel Data Path', 'Linux supports rich physical and virtual network interfaces inside the kernel:

- **Physical NICs** (`eth0`, `enp3s0`): Hardware network controllers backed by kernel drivers (e.g., `e1000e`, `ixgbe`, `mlx5_core`).
- **Loopback** (`lo`): Virtual software interface for local IPC (`127.0.0.1`).
- **Virtual Ethernet Pairs (`veth`)**: Software pipes used to connect container network namespaces to the host.
- **Bridges (`br0`, `docker0`)**: Virtual Layer 2 software switches forwarding packets via MAC learning.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'network-interfaces-and-iproute2';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Modern Network Management with iproute2 vs net-tools', 'The legacy `net-tools` package (`ifconfig`, `route`, `netstat`, `arp`) has been deprecated for over a decade. All production systems rely on **`iproute2`**:

| Legacy Tool | Modern iproute2 Replacement | Action |
|---|---|---|
| `ifconfig eth0` | `ip addr show dev eth0` | Inspect IP addressing |
| `ifconfig eth0 up` | `ip link set dev eth0 up` | Bring interface online |
| `route -n` | `ip route show` | View routing table |
| `route add default gw ...` | `ip route add default via ...` | Set default gateway |
| `arp -a` | `ip neigh show` | View ARP cache table |
| `netstat -tulpn` | `ss -tulpn` | View listening network sockets |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'network-interfaces-and-iproute2';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Creating Virtual Network Pairs & Linux Bridges', '```bash
# Create a virtual Linux software bridge
sudo ip link add name br-lab type bridge
sudo ip link set dev br-lab up

# Create a veth pair (virtual ethernet cable)
sudo ip link add veth-host type veth peer name veth-c1

# Attach one end to the bridge and activate
sudo ip link set dev veth-host master br-lab
sudo ip link set dev veth-host up
```', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'network-interfaces-and-iproute2';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. MTU Mismatch & Packet Fragmentation Issues', '> [!CAUTION]
> If a server MTU is set to 9000 (Jumbo Frames) but intermediate switches or tunnels only support standard 1500 MTU, large TCP packets with DF (Don''t Fragment) bit will be dropped silently (Black Hole Routing).

```bash
# Test maximum path MTU using ping with Don''t Fragment flag
ping -M do -s 1472 -c 3 1.1.1.1
```', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: ssh-key-pairs
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 18,
    content_markdown = '## 1. Asymmetric Cryptography in Secure Shell (SSH)

SSH authentication relies on public-key cryptography:
1. **Private Key**: Stored securely on your local workstation. Never shared with any server or transferred across the network.
2. **Public Key**: Installed on remote destination servers inside `~/.ssh/authorized_keys`.

### Modern Cryptographic Algorithm Comparison

| Algorithm | Recommended? | Key Size | Security & Performance |
|---|---|---|---|
| **Ed25519 (Edwards-curve)** | **Yes (Standard)** | 256-bit | Immune to timing attacks; tiny fast keys |
| **RSA (3072/4096-bit)** | Acceptable | 4096-bit | Legacy compatibility; slower key generation |
| **DSA / ECDSA** | **Deprecated** | 1024 / 256 | Weak random number generator leads to key leak |

---

## 2. Generating & Installing Hardened SSH Keys

```bash
# Generate high-security Ed25519 key with 100 KDF rounds and comment
ssh-keygen -t ed25519 -a 100 -C "admin@company.com" -f ~/.ssh/id_ed25519_prod

# Copy public key to remote host securely
ssh-copy-id -i ~/.ssh/id_ed25519_prod.pub user@server.company.com
```

---

## 3. Professional ~/.ssh/config Organization

Configure client aliases and connection parameters in `~/.ssh/config`:

```ini
Host bastion
    HostName bastion.infra.net
    User ops
    IdentityFile ~/.ssh/id_ed25519_bastion
    Port 2222

Host prod-db-01
    HostName 10.100.20.15
    User postgres
    IdentityFile ~/.ssh/id_ed25519_internal
    ProxyJump bastion
    ServerAliveInterval 30
    ServerAliveCountMax 3
```

---

## 4. SSH Permissions & Agent Debugging Checklist

> [!WARNING]
> SSH will refuse public-key authentication if directory permissions allow group or other users write access.

```bash
# Enforce strict ownership and permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod 600 ~/.ssh/id_ed25519

# Run SSH in deep verbose debugging mode to isolate authentication failures
ssh -vvv user@server.example.com
```'
WHERE slug = 'ssh-key-pairs';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ssh-key-pairs';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Asymmetric Cryptography in Secure Shell (SSH)', 'SSH authentication relies on public-key cryptography:
1. **Private Key**: Stored securely on your local workstation. Never shared with any server or transferred across the network.
2. **Public Key**: Installed on remote destination servers inside `~/.ssh/authorized_keys`.

### Modern Cryptographic Algorithm Comparison

| Algorithm | Recommended? | Key Size | Security & Performance |
|---|---|---|---|
| **Ed25519 (Edwards-curve)** | **Yes (Standard)** | 256-bit | Immune to timing attacks; tiny fast keys |
| **RSA (3072/4096-bit)** | Acceptable | 4096-bit | Legacy compatibility; slower key generation |
| **DSA / ECDSA** | **Deprecated** | 1024 / 256 | Weak random number generator leads to key leak |', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ssh-key-pairs';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Generating & Installing Hardened SSH Keys', '```bash
# Generate high-security Ed25519 key with 100 KDF rounds and comment
ssh-keygen -t ed25519 -a 100 -C "admin@company.com" -f ~/.ssh/id_ed25519_prod

# Copy public key to remote host securely
ssh-copy-id -i ~/.ssh/id_ed25519_prod.pub user@server.company.com
```', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ssh-key-pairs';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Professional ~/.ssh/config Organization', 'Configure client aliases and connection parameters in `~/.ssh/config`:

```ini
Host bastion
    HostName bastion.infra.net
    User ops
    IdentityFile ~/.ssh/id_ed25519_bastion
    Port 2222

Host prod-db-01
    HostName 10.100.20.15
    User postgres
    IdentityFile ~/.ssh/id_ed25519_internal
    ProxyJump bastion
    ServerAliveInterval 30
    ServerAliveCountMax 3
```', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ssh-key-pairs';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. SSH Permissions & Agent Debugging Checklist', '> [!WARNING]
> SSH will refuse public-key authentication if directory permissions allow group or other users write access.

```bash
# Enforce strict ownership and permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod 600 ~/.ssh/id_ed25519

# Run SSH in deep verbose debugging mode to isolate authentication failures
ssh -vvv user@server.example.com
```', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: python-intro
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 20,
    content_markdown = '## 1. Python in Modern Infrastructure Automation

Python is the lingua franca of cloud engineering, site reliability engineering (SRE), and systems automation. It bridges the gap between shell scripts and compiled enterprise software:

- **Clean Syntax**: Readable maintenance across distributed teams.
- **Rich Standard Library**: Built-in modules for JSON, HTTP, subprocessing, cryptography, and threading.
- **Vast Ecosystem**: Direct SDKs for AWS (Boto3), Kubernetes, Terraform, Docker, and AI frameworks.

---

## 2. Virtual Environments & Deterministic Dependencies

Never install automation dependencies into the system-wide Python environment:

```bash
# Create an isolated virtual environment
python3 -m venv .venv

# Activate virtual environment
source .venv/bin/activate

# Install dependencies and freeze exact locked versions
pip install requests pydantic
pip freeze > requirements.txt
```

---

## 3. Executing Shell Commands via subprocess Safely

```python
import subprocess
import sys

def execute_command(cmd_args: list[str]) -> str:
    """Executes external shell binaries safely without shell=True injection risks."""
    try:
        result = subprocess.run(
            cmd_args,
            check=True,
            capture_output=True,
            text=True,
            timeout=15
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Command failed with exit code {e.returncode}: {e.stderr}", file=sys.stderr)
        raise
    except subprocess.TimeoutExpired:
        print(f"Command timed out after 15 seconds: {cmd_args}", file=sys.stderr)
        raise

# Example: Read kernel version
uptime_output = execute_command(["uptime", "-p"])
print(f"System Uptime: {uptime_output}")
```

---

## 4. Subprocess Injection Vulnerabilities & Path Traps

> [!WARNING]
> Never pass unsanitized user input into `subprocess.run(..., shell=True)`. Attackers can append `; rm -rf /` or spawn reverse shells. Always pass command arguments as an explicit **list of strings** (`shell=False`).'
WHERE slug = 'python-intro';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'python-intro';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Python in Modern Infrastructure Automation', 'Python is the lingua franca of cloud engineering, site reliability engineering (SRE), and systems automation. It bridges the gap between shell scripts and compiled enterprise software:

- **Clean Syntax**: Readable maintenance across distributed teams.
- **Rich Standard Library**: Built-in modules for JSON, HTTP, subprocessing, cryptography, and threading.
- **Vast Ecosystem**: Direct SDKs for AWS (Boto3), Kubernetes, Terraform, Docker, and AI frameworks.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'python-intro';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Virtual Environments & Deterministic Dependencies', 'Never install automation dependencies into the system-wide Python environment:

```bash
# Create an isolated virtual environment
python3 -m venv .venv

# Activate virtual environment
source .venv/bin/activate

# Install dependencies and freeze exact locked versions
pip install requests pydantic
pip freeze > requirements.txt
```', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'python-intro';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Executing Shell Commands via subprocess Safely', '```python
import subprocess
import sys

def execute_command(cmd_args: list[str]) -> str:
    """Executes external shell binaries safely without shell=True injection risks."""
    try:
        result = subprocess.run(
            cmd_args,
            check=True,
            capture_output=True,
            text=True,
            timeout=15
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Command failed with exit code {e.returncode}: {e.stderr}", file=sys.stderr)
        raise
    except subprocess.TimeoutExpired:
        print(f"Command timed out after 15 seconds: {cmd_args}", file=sys.stderr)
        raise

# Example: Read kernel version
uptime_output = execute_command(["uptime", "-p"])
print(f"System Uptime: {uptime_output}")
```', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'python-intro';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Subprocess Injection Vulnerabilities & Path Traps', '> [!WARNING]
> Never pass unsanitized user input into `subprocess.run(..., shell=True)`. Attackers can append `; rm -rf /` or spawn reverse shells. Always pass command arguments as an explicit **list of strings** (`shell=False`).', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: http-methods-and-status-codes
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 20,
    content_markdown = '## 1. RESTful Architectural Constraints & HTTP Semantics

Representational State Transfer (REST) models systems as addressable resources accessed via uniform HTTP verbs:

| HTTP Method | CRUD Action | Safe? (Read-Only) | Idempotent? (Repeatable) |
|---|---|---|---|
| **GET** | Read resource representation | **Yes** | **Yes** |
| **POST** | Create subordinate resource / trigger action | No | **No** |
| **PUT** | Replace entire resource representation | No | **Yes** |
| **PATCH** | Apply partial modification to resource | No | No (usually) |
| **DELETE** | Remove resource representation | No | **Yes** |
| **HEAD** | Retrieve headers only (no response body) | **Yes** | **Yes** |
| **OPTIONS** | Query supported methods (CORS preflight) | **Yes** | **Yes** |

---

## 2. HTTP Status Code Categorization & RFC Meanings

HTTP response status codes are grouped into five distinct classes:

- **1xx (Informational)**: `101 Switching Protocols` (WebSockets).
- **2xx (Success)**:
  - `200 OK`: Standard successful response.
  - `201 Created`: New resource created (returns `Location` header).
  - `204 No Content`: Success with empty response body (common for DELETE).
- **3xx (Redirection)**:
  - `301 Moved Permanently`: Cached permanent redirect.
  - `304 Not Modified`: Client cache validator (ETag / If-Modified-Since) matches.
- **4xx (Client Error)**:
  - `400 Bad Request`: Malformed syntax or invalid payload validation.
  - `401 Unauthorized`: Missing or invalid authentication credentials.
  - `403 Forbidden`: Authenticated user lacks permission to access resource.
  - `404 Not Found`: Resource URI does not exist.
  - `429 Too Many Requests`: Rate limit exceeded (check `Retry-After` header).
- **5xx (Server Error)**:
  - `500 Internal Server Error`: Unhandled exception in backend.
  - `502 Bad Gateway`: Reverse proxy received invalid response from upstream daemon.
  - `503 Service Unavailable`: Upstream overloaded or undergoing maintenance.
  - `504 Gateway Timeout`: Upstream failed to respond before timeout window expired.

---

## 3. Inspecting Headers & Responses with curl

```bash
# Send POST request with JSON payload and inspect response headers
curl -i -X POST https://api.example.com/v1/deployments \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer my-secret-token" \
     -d ''{"environment": "production", "version": "v2.4.1"}''

# Test conditional HTTP caching with ETag header
curl -I -H ''If-None-Match: "33a64df551425fcc3e4e9f5"'' https://api.example.com/data
```

---

## 4. 502 Bad Gateway vs 504 Gateway Timeout Triage

> [!TIP]
> - **502 Bad Gateway**: Upstream app crashed, refused connection on port, or sent corrupt TCP RST.
> - **504 Gateway Timeout**: Upstream app is still running, but the database query or computation exceeded proxy timeout settings (`proxy_read_timeout`).'
WHERE slug = 'http-methods-and-status-codes';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'http-methods-and-status-codes';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. RESTful Architectural Constraints & HTTP Semantics', 'Representational State Transfer (REST) models systems as addressable resources accessed via uniform HTTP verbs:

| HTTP Method | CRUD Action | Safe? (Read-Only) | Idempotent? (Repeatable) |
|---|---|---|---|
| **GET** | Read resource representation | **Yes** | **Yes** |
| **POST** | Create subordinate resource / trigger action | No | **No** |
| **PUT** | Replace entire resource representation | No | **Yes** |
| **PATCH** | Apply partial modification to resource | No | No (usually) |
| **DELETE** | Remove resource representation | No | **Yes** |
| **HEAD** | Retrieve headers only (no response body) | **Yes** | **Yes** |
| **OPTIONS** | Query supported methods (CORS preflight) | **Yes** | **Yes** |', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'http-methods-and-status-codes';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. HTTP Status Code Categorization & RFC Meanings', 'HTTP response status codes are grouped into five distinct classes:

- **1xx (Informational)**: `101 Switching Protocols` (WebSockets).
- **2xx (Success)**:
  - `200 OK`: Standard successful response.
  - `201 Created`: New resource created (returns `Location` header).
  - `204 No Content`: Success with empty response body (common for DELETE).
- **3xx (Redirection)**:
  - `301 Moved Permanently`: Cached permanent redirect.
  - `304 Not Modified`: Client cache validator (ETag / If-Modified-Since) matches.
- **4xx (Client Error)**:
  - `400 Bad Request`: Malformed syntax or invalid payload validation.
  - `401 Unauthorized`: Missing or invalid authentication credentials.
  - `403 Forbidden`: Authenticated user lacks permission to access resource.
  - `404 Not Found`: Resource URI does not exist.
  - `429 Too Many Requests`: Rate limit exceeded (check `Retry-After` header).
- **5xx (Server Error)**:
  - `500 Internal Server Error`: Unhandled exception in backend.
  - `502 Bad Gateway`: Reverse proxy received invalid response from upstream daemon.
  - `503 Service Unavailable`: Upstream overloaded or undergoing maintenance.
  - `504 Gateway Timeout`: Upstream failed to respond before timeout window expired.', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'http-methods-and-status-codes';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Inspecting Headers & Responses with curl', '```bash
# Send POST request with JSON payload and inspect response headers
curl -i -X POST https://api.example.com/v1/deployments \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer my-secret-token" \
     -d ''{"environment": "production", "version": "v2.4.1"}''

# Test conditional HTTP caching with ETag header
curl -I -H ''If-None-Match: "33a64df551425fcc3e4e9f5"'' https://api.example.com/data
```', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'http-methods-and-status-codes';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. 502 Bad Gateway vs 504 Gateway Timeout Triage', '> [!TIP]
> - **502 Bad Gateway**: Upstream app crashed, refused connection on port, or sent corrupt TCP RST.
> - **504 Gateway Timeout**: Upstream app is still running, but the database query or computation exceeded proxy timeout settings (`proxy_read_timeout`).', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: security-cia-triad
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 20,
    content_markdown = '## 1. The CIA Triad: Core Pillars of Information Security

All cybersecurity controls, encryption algorithms, and security architectures serve to preserve one or more pillars of the **CIA Triad**:

```
          [Confidentiality]
               /       \
              /         \
             /           \
    [Integrity] -------- [Availability]
```

- **Confidentiality**: Preventing unauthorized disclosure of sensitive information. (Controls: TLS encryption, RBAC, KMS key encryption at rest).
- **Integrity**: Guaranteeing data has not been modified, altered, or forged in transit or storage. (Controls: SHA-256 HMAC signatures, digital certificates, Git commit signing).
- **Availability**: Ensuring systems, networks, and data remain accessible to authorized users when needed. (Controls: Anycast routing, DDoS mitigation, multi-AZ clustering, automated failover).

---

## 2. Defense-in-Depth & The Onion Security Model

Never rely on a single defensive boundary. The **Defense-in-Depth** model layers defensive controls across the entire computing stack:

1. **Perimeter / Edge**: Cloudflare WAF, DDoS protection, geo-fencing.
2. **Network**: Subnet isolation, private VPCs, firewall security groups.
3. **Host / OS**: Kernel hardening, SELinux enforcing, unprivileged users, automated patching.
4. **Application**: Input sanitization, parameterized SQL queries, CORS headers, rate limiting.
5. **Data Layer**: Field-level encryption, database access audit logging, immutable backups.

---

## 3. Verifying Cryptographic Data Integrity with OpenSSL

```bash
# Compute SHA-256 cryptographic checksum of a binary release
sha256sum production_binary.tar.gz

# Verify digital signature of a release artifact against developer public key
openssl dgst -sha256 -verify developer_pubkey.pem -signature binary.sig production_binary.tar.gz
```

---

## 4. The Availability vs Security Paradox

> [!WARNING]
> Overly aggressive security controls can inadvertently create self-inflicted Denial of Service (DoS). For example, strict IP lockout rules that ban entire corporate NAT gateways after three typos can lock out entire engineering teams.'
WHERE slug = 'security-cia-triad';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'security-cia-triad';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. The CIA Triad: Core Pillars of Information Security', 'All cybersecurity controls, encryption algorithms, and security architectures serve to preserve one or more pillars of the **CIA Triad**:

```
          [Confidentiality]
               /       \
              /         \
             /           \
    [Integrity] -------- [Availability]
```

- **Confidentiality**: Preventing unauthorized disclosure of sensitive information. (Controls: TLS encryption, RBAC, KMS key encryption at rest).
- **Integrity**: Guaranteeing data has not been modified, altered, or forged in transit or storage. (Controls: SHA-256 HMAC signatures, digital certificates, Git commit signing).
- **Availability**: Ensuring systems, networks, and data remain accessible to authorized users when needed. (Controls: Anycast routing, DDoS mitigation, multi-AZ clustering, automated failover).', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'security-cia-triad';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Defense-in-Depth & The Onion Security Model', 'Never rely on a single defensive boundary. The **Defense-in-Depth** model layers defensive controls across the entire computing stack:

1. **Perimeter / Edge**: Cloudflare WAF, DDoS protection, geo-fencing.
2. **Network**: Subnet isolation, private VPCs, firewall security groups.
3. **Host / OS**: Kernel hardening, SELinux enforcing, unprivileged users, automated patching.
4. **Application**: Input sanitization, parameterized SQL queries, CORS headers, rate limiting.
5. **Data Layer**: Field-level encryption, database access audit logging, immutable backups.', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'security-cia-triad';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Verifying Cryptographic Data Integrity with OpenSSL', '```bash
# Compute SHA-256 cryptographic checksum of a binary release
sha256sum production_binary.tar.gz

# Verify digital signature of a release artifact against developer public key
openssl dgst -sha256 -verify developer_pubkey.pem -signature binary.sig production_binary.tar.gz
```', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'security-cia-triad';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. The Availability vs Security Paradox', '> [!WARNING]
> Overly aggressive security controls can inadvertently create self-inflicted Denial of Service (DoS). For example, strict IP lockout rules that ban entire corporate NAT gateways after three typos can lock out entire engineering teams.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: tokens-sessions-and-oauth2
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 22,
    content_markdown = '## 1. Statefull Sessions vs Stateless JSON Web Tokens (JWT)

Modern architectures use two primary patterns for maintaining user identity:

| Dimension | Stateful Server Sessions | Stateless JWTs |
|---|---|---|
| **Storage** | Stored in Redis or Postgres database | Stored on client (encrypted cookie / memory) |
| **Verification** | Requires network DB lookup on every request | Verified locally using cryptographic public key |
| **Scalability** | Bottlenecked by shared session store | Highly scalable across distributed microservices |
| **Revocation** | Instantaneous: delete session record in Redis | Difficult: requires token blacklist or short TTL |

---

## 2. Anatomy of a JSON Web Token (JWT)

A JWT is a string composed of three base64url-encoded parts separated by periods:
`header.payload.signature`

1. **Header**: Contains algorithm and token type (`{"alg": "RS256", "typ": "JWT"}`).
2. **Payload**: Contains claims (`sub`, `iss`, `exp`, `iat`, `roles`).
3. **Signature**: Cryptographic signature calculated over `base64(header) + "." + base64(payload)` using private key.

> [!CAUTION]
> Never store sensitive credentials (plaintext passwords, API secret keys) inside a JWT payload! The payload is merely base64-encoded and can be read by anyone who inspects the token.

---

## 3. Verifying RS256 JWTs with JWKS Public Keys in Python

```python
import jwt
from jwt import PyJWKClient

# URL exposing public keys in JSON Web Key Set (JWKS) format
JWKS_URL = "https://auth.company.com/.well-known/jwks.json"

def verify_token(token_str: str) -> dict:
    jwks_client = PyJWKClient(JWKS_URL)
    signing_key = jwks_client.get_signing_key_from_jwt(token_str)
    
    # Decodes and cryptographically validates signature and expiration
    payload = jwt.decode(
        token_str,
        signing_key.key,
        algorithms=["RS256"],
        audience="https://api.company.com",
        issuer="https://auth.company.com/"
    )
    return payload
```

---

## 4. Critical JWT Vulnerabilities & Mitigation Checklist

> [!IMPORTANT]
> **The `alg: none` Attack**: Defective JWT libraries historically allowed attackers to set `"alg": "none"` in the header and omit the signature, which unpatched servers accepted as valid!

### Production JWT Security Checklist
1. Strictly whitelist allowed algorithms (`algorithms=["RS256"]`).
2. Always enforce expiration (`exp`) with short validity windows (10-15 minutes).
3. Deliver tokens in `HttpOnly`, `Secure`, `SameSite=Lax` cookies to prevent XSS exfiltration.'
WHERE slug = 'tokens-sessions-and-oauth2';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'tokens-sessions-and-oauth2';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Statefull Sessions vs Stateless JSON Web Tokens (JWT)', 'Modern architectures use two primary patterns for maintaining user identity:

| Dimension | Stateful Server Sessions | Stateless JWTs |
|---|---|---|
| **Storage** | Stored in Redis or Postgres database | Stored on client (encrypted cookie / memory) |
| **Verification** | Requires network DB lookup on every request | Verified locally using cryptographic public key |
| **Scalability** | Bottlenecked by shared session store | Highly scalable across distributed microservices |
| **Revocation** | Instantaneous: delete session record in Redis | Difficult: requires token blacklist or short TTL |', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'tokens-sessions-and-oauth2';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Anatomy of a JSON Web Token (JWT)', 'A JWT is a string composed of three base64url-encoded parts separated by periods:
`header.payload.signature`

1. **Header**: Contains algorithm and token type (`{"alg": "RS256", "typ": "JWT"}`).
2. **Payload**: Contains claims (`sub`, `iss`, `exp`, `iat`, `roles`).
3. **Signature**: Cryptographic signature calculated over `base64(header) + "." + base64(payload)` using private key.

> [!CAUTION]
> Never store sensitive credentials (plaintext passwords, API secret keys) inside a JWT payload! The payload is merely base64-encoded and can be read by anyone who inspects the token.', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'tokens-sessions-and-oauth2';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Verifying RS256 JWTs with JWKS Public Keys in Python', '```python
import jwt
from jwt import PyJWKClient

# URL exposing public keys in JSON Web Key Set (JWKS) format
JWKS_URL = "https://auth.company.com/.well-known/jwks.json"

def verify_token(token_str: str) -> dict:
    jwks_client = PyJWKClient(JWKS_URL)
    signing_key = jwks_client.get_signing_key_from_jwt(token_str)
    
    # Decodes and cryptographically validates signature and expiration
    payload = jwt.decode(
        token_str,
        signing_key.key,
        algorithms=["RS256"],
        audience="https://api.company.com",
        issuer="https://auth.company.com/"
    )
    return payload
```', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'tokens-sessions-and-oauth2';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Critical JWT Vulnerabilities & Mitigation Checklist', '> [!IMPORTANT]
> **The `alg: none` Attack**: Defective JWT libraries historically allowed attackers to set `"alg": "none"` in the header and omit the signature, which unpatched servers accepted as valid!

### Production JWT Security Checklist
1. Strictly whitelist allowed algorithms (`algorithms=["RS256"]`).
2. Always enforce expiration (`exp`) with short validity windows (10-15 minutes).
3. Deliver tokens in `HttpOnly`, `Secure`, `SameSite=Lax` cookies to prevent XSS exfiltration.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: owasp-top-10-overview
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 22,
    content_markdown = '## 1. The OWASP Top 10 Threat Landscape

The Open Web Application Security Project (OWASP) publishes the definitive consensus on the most critical web application security risks:

1. **A01: Broken Access Control**: Unauthorized access to user data and admin functions.
2. **A02: Cryptographic Failures**: Weak ciphers, cleartext transmission of sensitive data.
3. **A03: Injection**: SQL, NoSQL, OS command, and LDAP injection.
4. **A04: Insecure Design**: Flaws in architectural threat modeling and business logic.
5. **A05: Security Misconfiguration**: Default credentials, verbose error stack traces, open S3 buckets.
6. **A06: Vulnerable & Outdated Components**: Supply-chain vulnerabilities in open-source libraries.
7. **A07: Identification & Auth Failures**: Credential stuffing, brute force, weak session timeouts.
8. **A08: Software & Data Integrity Failures**: Insecure CI/CD pipelines and untrusted auto-updates.
9. **A09: Security Logging & Monitoring Failures**: Inability to detect active breaches and intrusions.
10. **A10: Server-Side Request Forgery (SSRF)**: Abusing backend web servers to fetch internal services.

---

## 2. Broken Access Control & IDOR Deep Dive

Insecure Direct Object Reference (IDOR) occurs when an endpoint accepts a user-controlled identifier (e.g. `/api/invoices/1042`) without verifying that the authenticated user owns that record.

> [!CAUTION]
> Always enforce multi-tenant scoping directly inside database queries using Row-Level Security (RLS) or tenant filtering:
> ```sql
> -- SECURE: Strictly scope record selection to current authenticated user
> SELECT * FROM invoices WHERE id = $1 AND user_id = auth.uid();
> ```

---

## 3. Preventing SQL Injection with Parameterized Queries

```typescript
// VULNERABLE: String concatenation permits SQL injection ('' OR ''1''=''1)
// const query = `SELECT * FROM users WHERE email = ''${userEmail}''`;

// SECURE: Parameterized query binds input as raw literal values
import { pool } from "./db";

async function getUserByEmail(email: string) {
  const result = await pool.query(
    "SELECT id, username, password_hash, role FROM users WHERE email = $1",
    [email]
  );
  return result.rows[0] ?? null;
}
```

---

## 4. Automated Dependency Vulnerability Auditing

> [!TIP]
> Integrate automated vulnerability scanning into your local developer workflow:

```bash
# Audit Node.js dependencies for high and critical CVEs
npm audit --audit-level=high

# Audit Python dependencies with pip-audit
pip-audit --desc on
```'
WHERE slug = 'owasp-top-10-overview';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'owasp-top-10-overview';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. The OWASP Top 10 Threat Landscape', 'The Open Web Application Security Project (OWASP) publishes the definitive consensus on the most critical web application security risks:

1. **A01: Broken Access Control**: Unauthorized access to user data and admin functions.
2. **A02: Cryptographic Failures**: Weak ciphers, cleartext transmission of sensitive data.
3. **A03: Injection**: SQL, NoSQL, OS command, and LDAP injection.
4. **A04: Insecure Design**: Flaws in architectural threat modeling and business logic.
5. **A05: Security Misconfiguration**: Default credentials, verbose error stack traces, open S3 buckets.
6. **A06: Vulnerable & Outdated Components**: Supply-chain vulnerabilities in open-source libraries.
7. **A07: Identification & Auth Failures**: Credential stuffing, brute force, weak session timeouts.
8. **A08: Software & Data Integrity Failures**: Insecure CI/CD pipelines and untrusted auto-updates.
9. **A09: Security Logging & Monitoring Failures**: Inability to detect active breaches and intrusions.
10. **A10: Server-Side Request Forgery (SSRF)**: Abusing backend web servers to fetch internal services.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'owasp-top-10-overview';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Broken Access Control & IDOR Deep Dive', 'Insecure Direct Object Reference (IDOR) occurs when an endpoint accepts a user-controlled identifier (e.g. `/api/invoices/1042`) without verifying that the authenticated user owns that record.

> [!CAUTION]
> Always enforce multi-tenant scoping directly inside database queries using Row-Level Security (RLS) or tenant filtering:
> ```sql
> -- SECURE: Strictly scope record selection to current authenticated user
> SELECT * FROM invoices WHERE id = $1 AND user_id = auth.uid();
> ```', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'owasp-top-10-overview';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Preventing SQL Injection with Parameterized Queries', '```typescript
// VULNERABLE: String concatenation permits SQL injection ('' OR ''1''=''1)
// const query = `SELECT * FROM users WHERE email = ''${userEmail}''`;

// SECURE: Parameterized query binds input as raw literal values
import { pool } from "./db";

async function getUserByEmail(email: string) {
  const result = await pool.query(
    "SELECT id, username, password_hash, role FROM users WHERE email = $1",
    [email]
  );
  return result.rows[0] ?? null;
}
```', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'owasp-top-10-overview';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Automated Dependency Vulnerability Auditing', '> [!TIP]
> Integrate automated vulnerability scanning into your local developer workflow:

```bash
# Audit Node.js dependencies for high and critical CVEs
npm audit --audit-level=high

# Audit Python dependencies with pip-audit
pip-audit --desc on
```', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: dockerfiles-and-images
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 20,
    content_markdown = '## 1. OCI Image Layers, Union Filesystems & Layer Caching

Docker images are composed of immutable, stacked read-only layers managed by the **Overlay2** union filesystem driver.

### Layer Caching Mechanics
When Docker executes a build:
1. Docker checks if the instruction and its inputs (files, commands) match a cached layer.
2. If matched, Docker reuses the layer instantly.
3. **If any layer invalidates**, all subsequent downstream layers **must be rebuilt from scratch**!

> [!NOTE]
> Always place infrequently modified instructions (`COPY package*.json`, `RUN npm install`) before volatile instructions (`COPY . .`) to maximize Docker build cache hits.

---

## 2. Production Multi-Stage Dockerfile Blueprint

Multi-stage builds separate the build environment (compilers, build tools, devDependencies) from the lean runtime container:

```dockerfile
# Stage 1: Build & Compilation Environment
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build && npm prune --production

# Stage 2: Ultra-Minimal Hardened Runtime
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# Run as non-root user for security
USER node

# Copy only production artifacts and node_modules from builder
COPY --from=builder --chown=node:node /app/package.json ./
COPY --from=builder --chown=node:node /app/node_modules ./node_modules
COPY --from=builder --chown=node:node /app/dist ./dist

EXPOSE 3000
CMD ["node", "dist/server.js"]
```

---

## 3. Image Inspection & Vulnerability Scanning with Trivy

```bash
# Build optimized image with progress plain
docker build -t myapp:v1.0.0 .

# Inspect layer history and physical size breakdown
docker history myapp:v1.0.0

# Scan image for known CVE vulnerabilities and exposed secrets
trivy image --severity HIGH,CRITICAL myapp:v1.0.0
```

---

## 4. Container Anti-Patterns & Zombie Reaping in Containers

> [!WARNING]
> If your application runs as PID 1 inside a Docker container without an init system (like `tini`), child processes spawned by your application will become zombies upon termination because standard runtimes do not implement SIGCHLD reaping!'
WHERE slug = 'dockerfiles-and-images';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'dockerfiles-and-images';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. OCI Image Layers, Union Filesystems & Layer Caching', 'Docker images are composed of immutable, stacked read-only layers managed by the **Overlay2** union filesystem driver.

### Layer Caching Mechanics
When Docker executes a build:
1. Docker checks if the instruction and its inputs (files, commands) match a cached layer.
2. If matched, Docker reuses the layer instantly.
3. **If any layer invalidates**, all subsequent downstream layers **must be rebuilt from scratch**!

> [!NOTE]
> Always place infrequently modified instructions (`COPY package*.json`, `RUN npm install`) before volatile instructions (`COPY . .`) to maximize Docker build cache hits.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'dockerfiles-and-images';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Production Multi-Stage Dockerfile Blueprint', 'Multi-stage builds separate the build environment (compilers, build tools, devDependencies) from the lean runtime container:

```dockerfile
# Stage 1: Build & Compilation Environment
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build && npm prune --production

# Stage 2: Ultra-Minimal Hardened Runtime
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# Run as non-root user for security
USER node

# Copy only production artifacts and node_modules from builder
COPY --from=builder --chown=node:node /app/package.json ./
COPY --from=builder --chown=node:node /app/node_modules ./node_modules
COPY --from=builder --chown=node:node /app/dist ./dist

EXPOSE 3000
CMD ["node", "dist/server.js"]
```', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'dockerfiles-and-images';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Image Inspection & Vulnerability Scanning with Trivy', '```bash
# Build optimized image with progress plain
docker build -t myapp:v1.0.0 .

# Inspect layer history and physical size breakdown
docker history myapp:v1.0.0

# Scan image for known CVE vulnerabilities and exposed secrets
trivy image --severity HIGH,CRITICAL myapp:v1.0.0
```', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'dockerfiles-and-images';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Container Anti-Patterns & Zombie Reaping in Containers', '> [!WARNING]
> If your application runs as PID 1 inside a Docker container without an init system (like `tini`), child processes spawned by your application will become zombies upon termination because standard runtimes do not implement SIGCHLD reaping!', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: llm-fundamentals-and-tokenization
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 22,
    content_markdown = '## 1. Transformer Decoders & Byte-Pair Encoding (BPE)

Modern Large Language Models (LLMs) like GPT-4, Claude, and Gemini are **autoregressive decoder-only transformers**. They do not operate on raw characters or whole words; they operate on numerical **tokens**.

### How Byte-Pair Encoding (BPE) Works
1. Starts with basic byte vocabulary (256 bytes).
2. Iteratively identifies the most frequent adjacent character pairs across massive training corpora.
3. Merges the pair into a single new sub-word token.
4. Typical conversion rule of thumb: **1,000 tokens ≈ 750 English words** (~4 characters per token).

---

## 2. Sampling Parameters: Temperature, Top-p & Top-k

The final softmax layer outputs a probability distribution over the model''s vocabulary:

| Hyperparameter | Behavior & Impact | Recommended for Code / IT |
|---|---|---|
| **Temperature (( T ))** | Scales logits before softmax. Lower values (`0.0 - 0.2`) make output deterministic; higher values (`0.7 - 1.2`) increase randomness. | `0.0 - 0.2` (Deterministic) |
| **Top-P (Nucleus Sampling)** | Considers only the smallest pool of tokens whose cumulative probability exceeds ( P ) (e.g. `0.9`). | `0.95` |
| **Max Tokens** | Hard upper ceiling on the number of generated tokens in the completion. | Tailored to task |
| **Frequency Penalty** | Discourages verbatim repetition of already generated phrases. | `0.0 - 0.5` |

---

## 3. Streaming Completions via Server-Sent Events (SSE)

```python
import os
import json
import requests

API_KEY = os.environ["OPENAI_API_KEY"]

def stream_chat_completion(prompt: str):
    url = "https://api.openai.com/v1/chat/completions"
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    payload = {
        "model": "gpt-4o",
        "messages": [{"role": "user", "content": prompt}],
        "stream": True,
        "temperature": 0.1
    }
    
    with requests.post(url, headers=headers, json=payload, stream=True) as response:
        for line in response.iter_lines():
            if line:
                decoded_line = line.decode(''utf-8'')
                if decoded_line.startswith("data: "):
                    data_str = decoded_line[6:]
                    if data_str == "[DONE]":
                        break
                    chunk = json.loads(data_str)
                    delta = chunk["choices"][0]["delta"].get("content", "")
                    print(delta, end="", flush=True)

print(stream_chat_completion("Explain BGP Path Selection in 3 bullet points"))
```

---

## 4. Context Window Truncation & Hallucination Guardrails

> [!TIP]
> Never let user conversations accumulate infinitely. Use a sliding-window token trimmer with `tiktoken` to truncate older history while preserving the primary system instruction and recent context!'
WHERE slug = 'llm-fundamentals-and-tokenization';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'llm-fundamentals-and-tokenization';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Transformer Decoders & Byte-Pair Encoding (BPE)', 'Modern Large Language Models (LLMs) like GPT-4, Claude, and Gemini are **autoregressive decoder-only transformers**. They do not operate on raw characters or whole words; they operate on numerical **tokens**.

### How Byte-Pair Encoding (BPE) Works
1. Starts with basic byte vocabulary (256 bytes).
2. Iteratively identifies the most frequent adjacent character pairs across massive training corpora.
3. Merges the pair into a single new sub-word token.
4. Typical conversion rule of thumb: **1,000 tokens ≈ 750 English words** (~4 characters per token).', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'llm-fundamentals-and-tokenization';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Sampling Parameters: Temperature, Top-p & Top-k', 'The final softmax layer outputs a probability distribution over the model''s vocabulary:

| Hyperparameter | Behavior & Impact | Recommended for Code / IT |
|---|---|---|
| **Temperature (( T ))** | Scales logits before softmax. Lower values (`0.0 - 0.2`) make output deterministic; higher values (`0.7 - 1.2`) increase randomness. | `0.0 - 0.2` (Deterministic) |
| **Top-P (Nucleus Sampling)** | Considers only the smallest pool of tokens whose cumulative probability exceeds ( P ) (e.g. `0.9`). | `0.95` |
| **Max Tokens** | Hard upper ceiling on the number of generated tokens in the completion. | Tailored to task |
| **Frequency Penalty** | Discourages verbatim repetition of already generated phrases. | `0.0 - 0.5` |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'llm-fundamentals-and-tokenization';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Streaming Completions via Server-Sent Events (SSE)', '```python
import os
import json
import requests

API_KEY = os.environ["OPENAI_API_KEY"]

def stream_chat_completion(prompt: str):
    url = "https://api.openai.com/v1/chat/completions"
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    payload = {
        "model": "gpt-4o",
        "messages": [{"role": "user", "content": prompt}],
        "stream": True,
        "temperature": 0.1
    }
    
    with requests.post(url, headers=headers, json=payload, stream=True) as response:
        for line in response.iter_lines():
            if line:
                decoded_line = line.decode(''utf-8'')
                if decoded_line.startswith("data: "):
                    data_str = decoded_line[6:]
                    if data_str == "[DONE]":
                        break
                    chunk = json.loads(data_str)
                    delta = chunk["choices"][0]["delta"].get("content", "")
                    print(delta, end="", flush=True)

print(stream_chat_completion("Explain BGP Path Selection in 3 bullet points"))
```', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'llm-fundamentals-and-tokenization';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Context Window Truncation & Hallucination Guardrails', '> [!TIP]
> Never let user conversations accumulate infinitely. Use a sliding-window token trimmer with `tiktoken` to truncate older history while preserving the primary system instruction and recent context!', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: retrieval-augmented-generation-rag
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Enterprise RAG Architecture & The Semantic Gap

Standard LLM training data is frozen at pretraining cutoffs. **Retrieval-Augmented Generation (RAG)** dynamically injects verified enterprise documentation, runbooks, and real-time database state into the model prompt context:

```
[User Query] 
     |
     +---> [Embedding Model] ---> Vector Query
                                       |
[Vector DB / pgvector] <---------------+
     |
  Top-K Chunks
     |
     v
[Reranker Model (Cohere/BGE)]
     |
  Top-N High-Relevance Chunks
     |
     v
[Augmented System Prompt + Context] ---> [LLM Generator] ---> [Grounded Response]
```

---

## 2. Chunking Strategies & Vector Indexing (HNSW vs IVFFlat)

Naive character slicing destroys context across sentences. Enterprise RAG utilizes **semantic sentence chunking** with rolling overlaps:

- **Chunk Size**: 256 to 512 tokens (ideal for precision matching).
- **Chunk Overlap**: 10% to 15% (prevents context truncation at boundaries).
- **HNSW (Hierarchical Navigable Small World)**: Graph-based approximate nearest neighbor (ANN) index offering superior recall and sub-millisecond query latency compared to legacy inverted file (IVFFlat) indexes.

---

## 3. Vector Search with pgvector & Cosine Similarity in SQL

```sql
-- Enable vector extension in Postgres
CREATE EXTENSION IF NOT EXISTS vector;

-- Table storing technical documents and 1536-dimension embeddings
CREATE TABLE documentation_chunks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_title TEXT NOT NULL,
    content TEXT NOT NULL,
    embedding VECTOR(1536) NOT NULL
);

-- Create fast HNSW cosine distance index
CREATE INDEX ON documentation_chunks USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

-- Query Top 3 most semantically similar chunks for an incoming query vector
SELECT document_title, content, 1 - (embedding <=> $1) AS cosine_similarity
FROM documentation_chunks
WHERE 1 - (embedding <=> $1) > 0.78
ORDER BY embedding <=> $1
LIMIT 3;
```

---

## 4. Lost in the Middle Phenomenon & Reranking Optimization

> [!IMPORTANT]
> Transformers attend heavily to the beginning and end of their prompt context window, often ignoring facts buried in the middle ("Lost in the Middle"). Always sort retrieved context chunks so the highest relevance passages appear at the very start and very end of the injected context!'
WHERE slug = 'retrieval-augmented-generation-rag';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'retrieval-augmented-generation-rag';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Enterprise RAG Architecture & The Semantic Gap', 'Standard LLM training data is frozen at pretraining cutoffs. **Retrieval-Augmented Generation (RAG)** dynamically injects verified enterprise documentation, runbooks, and real-time database state into the model prompt context:

```
[User Query] 
     |
     +---> [Embedding Model] ---> Vector Query
                                       |
[Vector DB / pgvector] <---------------+
     |
  Top-K Chunks
     |
     v
[Reranker Model (Cohere/BGE)]
     |
  Top-N High-Relevance Chunks
     |
     v
[Augmented System Prompt + Context] ---> [LLM Generator] ---> [Grounded Response]
```', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'retrieval-augmented-generation-rag';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Chunking Strategies & Vector Indexing (HNSW vs IVFFlat)', 'Naive character slicing destroys context across sentences. Enterprise RAG utilizes **semantic sentence chunking** with rolling overlaps:

- **Chunk Size**: 256 to 512 tokens (ideal for precision matching).
- **Chunk Overlap**: 10% to 15% (prevents context truncation at boundaries).
- **HNSW (Hierarchical Navigable Small World)**: Graph-based approximate nearest neighbor (ANN) index offering superior recall and sub-millisecond query latency compared to legacy inverted file (IVFFlat) indexes.', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'retrieval-augmented-generation-rag';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Vector Search with pgvector & Cosine Similarity in SQL', '```sql
-- Enable vector extension in Postgres
CREATE EXTENSION IF NOT EXISTS vector;

-- Table storing technical documents and 1536-dimension embeddings
CREATE TABLE documentation_chunks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_title TEXT NOT NULL,
    content TEXT NOT NULL,
    embedding VECTOR(1536) NOT NULL
);

-- Create fast HNSW cosine distance index
CREATE INDEX ON documentation_chunks USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

-- Query Top 3 most semantically similar chunks for an incoming query vector
SELECT document_title, content, 1 - (embedding <=> $1) AS cosine_similarity
FROM documentation_chunks
WHERE 1 - (embedding <=> $1) > 0.78
ORDER BY embedding <=> $1
LIMIT 3;
```', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'retrieval-augmented-generation-rag';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Lost in the Middle Phenomenon & Reranking Optimization', '> [!IMPORTANT]
> Transformers attend heavily to the beginning and end of their prompt context window, often ignoring facts buried in the middle ("Lost in the Middle"). Always sort retrieved context chunks so the highest relevance passages appear at the very start and very end of the injected context!', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: ebpf-profiling-and-cpu-scheduling
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: Linux CPU Scheduling Internals & eBPF Profiling

In modern computing and infrastructure engineering, understanding **Linux CPU Scheduling Internals & eBPF Profiling** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Linux CPU Scheduling Internals & eBPF Profiling**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Linux CPU Scheduling Internals & eBPF Profiling using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'ebpf-profiling-and-cpu-scheduling';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ebpf-profiling-and-cpu-scheduling';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Linux CPU Scheduling Internals & eBPF Profiling', 'In modern computing and infrastructure engineering, understanding **Linux CPU Scheduling Internals & eBPF Profiling** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ebpf-profiling-and-cpu-scheduling';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Linux CPU Scheduling Internals & eBPF Profiling**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ebpf-profiling-and-cpu-scheduling';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Linux CPU Scheduling Internals & eBPF Profiling using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ebpf-profiling-and-cpu-scheduling';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: cgroups-v2-and-namespaces
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: Cgroups v2 & Linux Namespaces: The Core of Containers

In modern computing and infrastructure engineering, understanding **Cgroups v2 & Linux Namespaces: The Core of Containers** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Cgroups v2 & Linux Namespaces: The Core of Containers**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Cgroups v2 & Linux Namespaces: The Core of Containers using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'cgroups-v2-and-namespaces';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cgroups-v2-and-namespaces';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Cgroups v2 & Linux Namespaces: The Core of Containers', 'In modern computing and infrastructure engineering, understanding **Cgroups v2 & Linux Namespaces: The Core of Containers** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cgroups-v2-and-namespaces';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Cgroups v2 & Linux Namespaces: The Core of Containers**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cgroups-v2-and-namespaces';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Cgroups v2 & Linux Namespaces: The Core of Containers using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cgroups-v2-and-namespaces';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: inodes-links-and-mounting
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 15,
    content_markdown = '## 1. Core Principles: Inodes, Hard Links, and Mounting

In modern computing and infrastructure engineering, understanding **Inodes, Hard Links, and Mounting** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Inodes, Hard Links, and Mounting**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Inodes, Hard Links, and Mounting using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'inodes-links-and-mounting';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'inodes-links-and-mounting';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Inodes, Hard Links, and Mounting', 'In modern computing and infrastructure engineering, understanding **Inodes, Hard Links, and Mounting** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'inodes-links-and-mounting';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Inodes, Hard Links, and Mounting**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'inodes-links-and-mounting';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Inodes, Hard Links, and Mounting using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'inodes-links-and-mounting';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: journaling-cow-and-zfs
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: Journaling, Copy-on-Write (CoW) & Modern ZFS/Btrfs

In modern computing and infrastructure engineering, understanding **Journaling, Copy-on-Write (CoW) & Modern ZFS/Btrfs** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Journaling, Copy-on-Write (CoW) & Modern ZFS/Btrfs**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Journaling, Copy-on-Write (CoW) & Modern ZFS/Btrfs using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'journaling-cow-and-zfs';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'journaling-cow-and-zfs';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Journaling, Copy-on-Write (CoW) & Modern ZFS/Btrfs', 'In modern computing and infrastructure engineering, understanding **Journaling, Copy-on-Write (CoW) & Modern ZFS/Btrfs** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'journaling-cow-and-zfs';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Journaling, Copy-on-Write (CoW) & Modern ZFS/Btrfs**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'journaling-cow-and-zfs';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Journaling, Copy-on-Write (CoW) & Modern ZFS/Btrfs using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'journaling-cow-and-zfs';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: ip-addressing-cidr
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 15,
    content_markdown = '## 1. Core Principles: CIDR Notation

In modern computing and infrastructure engineering, understanding **CIDR Notation** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **CIDR Notation**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect CIDR Notation using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'ip-addressing-cidr';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ip-addressing-cidr';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: CIDR Notation', 'In modern computing and infrastructure engineering, understanding **CIDR Notation** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ip-addressing-cidr';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **CIDR Notation**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ip-addressing-cidr';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect CIDR Notation using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ip-addressing-cidr';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: ipv6-architecture-and-dual-stack
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: IPv6 Architecture, SLAAC & Dual-Stack Operations

In modern computing and infrastructure engineering, understanding **IPv6 Architecture, SLAAC & Dual-Stack Operations** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **IPv6 Architecture, SLAAC & Dual-Stack Operations**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect IPv6 Architecture, SLAAC & Dual-Stack Operations using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'ipv6-architecture-and-dual-stack';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ipv6-architecture-and-dual-stack';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: IPv6 Architecture, SLAAC & Dual-Stack Operations', 'In modern computing and infrastructure engineering, understanding **IPv6 Architecture, SLAAC & Dual-Stack Operations** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ipv6-architecture-and-dual-stack';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **IPv6 Architecture, SLAAC & Dual-Stack Operations**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ipv6-architecture-and-dual-stack';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect IPv6 Architecture, SLAAC & Dual-Stack Operations using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ipv6-architecture-and-dual-stack';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: vlsm-and-subnet-design
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 15,
    content_markdown = '## 1. Core Principles: Variable Length Subnet Masking (VLSM) & Network Planning

In modern computing and infrastructure engineering, understanding **Variable Length Subnet Masking (VLSM) & Network Planning** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Variable Length Subnet Masking (VLSM) & Network Planning**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Variable Length Subnet Masking (VLSM) & Network Planning using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'vlsm-and-subnet-design';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'vlsm-and-subnet-design';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Variable Length Subnet Masking (VLSM) & Network Planning', 'In modern computing and infrastructure engineering, understanding **Variable Length Subnet Masking (VLSM) & Network Planning** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'vlsm-and-subnet-design';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Variable Length Subnet Masking (VLSM) & Network Planning**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'vlsm-and-subnet-design';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Variable Length Subnet Masking (VLSM) & Network Planning using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'vlsm-and-subnet-design';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: cidr-aggregation-and-supernetting
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: Route Summarization, Supernetting & BGP Aggregation

In modern computing and infrastructure engineering, understanding **Route Summarization, Supernetting & BGP Aggregation** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Route Summarization, Supernetting & BGP Aggregation**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Route Summarization, Supernetting & BGP Aggregation using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'cidr-aggregation-and-supernetting';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cidr-aggregation-and-supernetting';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Route Summarization, Supernetting & BGP Aggregation', 'In modern computing and infrastructure engineering, understanding **Route Summarization, Supernetting & BGP Aggregation** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cidr-aggregation-and-supernetting';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Route Summarization, Supernetting & BGP Aggregation**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cidr-aggregation-and-supernetting';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Route Summarization, Supernetting & BGP Aggregation using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cidr-aggregation-and-supernetting';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: dns-fundamentals
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 15,
    content_markdown = '## 1. Core Principles: DNS Hierarchy and Resolution Flow

In modern computing and infrastructure engineering, understanding **DNS Hierarchy and Resolution Flow** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **DNS Hierarchy and Resolution Flow**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect DNS Hierarchy and Resolution Flow using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'dns-fundamentals';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'dns-fundamentals';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: DNS Hierarchy and Resolution Flow', 'In modern computing and infrastructure engineering, understanding **DNS Hierarchy and Resolution Flow** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'dns-fundamentals';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **DNS Hierarchy and Resolution Flow**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'dns-fundamentals';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect DNS Hierarchy and Resolution Flow using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'dns-fundamentals';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: dnssec-doh-and-bind-security
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: DNSSEC Cryptographic Validation & Encrypted DNS (DoH/DoT)

In modern computing and infrastructure engineering, understanding **DNSSEC Cryptographic Validation & Encrypted DNS (DoH/DoT)** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **DNSSEC Cryptographic Validation & Encrypted DNS (DoH/DoT)**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect DNSSEC Cryptographic Validation & Encrypted DNS (DoH/DoT) using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'dnssec-doh-and-bind-security';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'dnssec-doh-and-bind-security';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: DNSSEC Cryptographic Validation & Encrypted DNS (DoH/DoT)', 'In modern computing and infrastructure engineering, understanding **DNSSEC Cryptographic Validation & Encrypted DNS (DoH/DoT)** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'dnssec-doh-and-bind-security';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **DNSSEC Cryptographic Validation & Encrypted DNS (DoH/DoT)**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'dnssec-doh-and-bind-security';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect DNSSEC Cryptographic Validation & Encrypted DNS (DoH/DoT) using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'dnssec-doh-and-bind-security';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: dynamic-routing-and-nat
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 20,
    content_markdown = '## 1. Core Principles: Dynamic Routing Protocols & NAT

In modern computing and infrastructure engineering, understanding **Dynamic Routing Protocols & NAT** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Dynamic Routing Protocols & NAT**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Dynamic Routing Protocols & NAT using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'dynamic-routing-and-nat';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'dynamic-routing-and-nat';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Dynamic Routing Protocols & NAT', 'In modern computing and infrastructure engineering, understanding **Dynamic Routing Protocols & NAT** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'dynamic-routing-and-nat';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Dynamic Routing Protocols & NAT**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'dynamic-routing-and-nat';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Dynamic Routing Protocols & NAT using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'dynamic-routing-and-nat';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: evpn-vxlan-data-center-fabrics
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: EVPN-VXLAN Data Center Fabric Architecture

In modern computing and infrastructure engineering, understanding **EVPN-VXLAN Data Center Fabric Architecture** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **EVPN-VXLAN Data Center Fabric Architecture**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect EVPN-VXLAN Data Center Fabric Architecture using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'evpn-vxlan-data-center-fabrics';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'evpn-vxlan-data-center-fabrics';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: EVPN-VXLAN Data Center Fabric Architecture', 'In modern computing and infrastructure engineering, understanding **EVPN-VXLAN Data Center Fabric Architecture** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'evpn-vxlan-data-center-fabrics';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **EVPN-VXLAN Data Center Fabric Architecture**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'evpn-vxlan-data-center-fabrics';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect EVPN-VXLAN Data Center Fabric Architecture using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'evpn-vxlan-data-center-fabrics';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: linux-cli-why
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 15,
    content_markdown = '## 1. Core Principles: Why the Linux CLI Matters

In modern computing and infrastructure engineering, understanding **Why the Linux CLI Matters** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Why the Linux CLI Matters**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Why the Linux CLI Matters using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'linux-cli-why';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'linux-cli-why';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Why the Linux CLI Matters', 'In modern computing and infrastructure engineering, understanding **Why the Linux CLI Matters** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'linux-cli-why';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Why the Linux CLI Matters**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'linux-cli-why';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Why the Linux CLI Matters using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'linux-cli-why';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: linux-cli-navigation
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 15,
    content_markdown = '## 1. Core Principles: Navigating the Filesystem

In modern computing and infrastructure engineering, understanding **Navigating the Filesystem** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Navigating the Filesystem**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Navigating the Filesystem using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'linux-cli-navigation';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'linux-cli-navigation';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Navigating the Filesystem', 'In modern computing and infrastructure engineering, understanding **Navigating the Filesystem** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'linux-cli-navigation';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Navigating the Filesystem**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'linux-cli-navigation';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Navigating the Filesystem using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'linux-cli-navigation';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: advanced-bash-and-posix-scripting
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: Advanced Bash Scripting, Signals & Trap Handlers

In modern computing and infrastructure engineering, understanding **Advanced Bash Scripting, Signals & Trap Handlers** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Advanced Bash Scripting, Signals & Trap Handlers**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Advanced Bash Scripting, Signals & Trap Handlers using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'advanced-bash-and-posix-scripting';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'advanced-bash-and-posix-scripting';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Advanced Bash Scripting, Signals & Trap Handlers', 'In modern computing and infrastructure engineering, understanding **Advanced Bash Scripting, Signals & Trap Handlers** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'advanced-bash-and-posix-scripting';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Advanced Bash Scripting, Signals & Trap Handlers**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'advanced-bash-and-posix-scripting';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Advanced Bash Scripting, Signals & Trap Handlers using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'advanced-bash-and-posix-scripting';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: permissions-model
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 15,
    content_markdown = '## 1. Core Principles: Understanding the Permission Model

In modern computing and infrastructure engineering, understanding **Understanding the Permission Model** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Understanding the Permission Model**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Understanding the Permission Model using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'permissions-model';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'permissions-model';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Understanding the Permission Model', 'In modern computing and infrastructure engineering, understanding **Understanding the Permission Model** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'permissions-model';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Understanding the Permission Model**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'permissions-model';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Understanding the Permission Model using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'permissions-model';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: selinux-and-posix-acls
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: SELinux Mandatory Access Control (MAC) & POSIX ACLs

In modern computing and infrastructure engineering, understanding **SELinux Mandatory Access Control (MAC) & POSIX ACLs** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **SELinux Mandatory Access Control (MAC) & POSIX ACLs**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect SELinux Mandatory Access Control (MAC) & POSIX ACLs using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'selinux-and-posix-acls';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'selinux-and-posix-acls';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: SELinux Mandatory Access Control (MAC) & POSIX ACLs', 'In modern computing and infrastructure engineering, understanding **SELinux Mandatory Access Control (MAC) & POSIX ACLs** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'selinux-and-posix-acls';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **SELinux Mandatory Access Control (MAC) & POSIX ACLs**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'selinux-and-posix-acls';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect SELinux Mandatory Access Control (MAC) & POSIX ACLs using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'selinux-and-posix-acls';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: linux-firewalling-nftables
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 20,
    content_markdown = '## 1. Core Principles: Linux Packet Filtering: iptables to nftables

In modern computing and infrastructure engineering, understanding **Linux Packet Filtering: iptables to nftables** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Linux Packet Filtering: iptables to nftables**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Linux Packet Filtering: iptables to nftables using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'linux-firewalling-nftables';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'linux-firewalling-nftables';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Linux Packet Filtering: iptables to nftables', 'In modern computing and infrastructure engineering, understanding **Linux Packet Filtering: iptables to nftables** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'linux-firewalling-nftables';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Linux Packet Filtering: iptables to nftables**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'linux-firewalling-nftables';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Linux Packet Filtering: iptables to nftables using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'linux-firewalling-nftables';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: kernel-network-tuning-and-ebpf-xdp
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: Kernel Network Tuning, sysctl & eXpress Data Path (XDP)

In modern computing and infrastructure engineering, understanding **Kernel Network Tuning, sysctl & eXpress Data Path (XDP)** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Kernel Network Tuning, sysctl & eXpress Data Path (XDP)**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Kernel Network Tuning, sysctl & eXpress Data Path (XDP) using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'kernel-network-tuning-and-ebpf-xdp';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'kernel-network-tuning-and-ebpf-xdp';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Kernel Network Tuning, sysctl & eXpress Data Path (XDP)', 'In modern computing and infrastructure engineering, understanding **Kernel Network Tuning, sysctl & eXpress Data Path (XDP)** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'kernel-network-tuning-and-ebpf-xdp';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Kernel Network Tuning, sysctl & eXpress Data Path (XDP)**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'kernel-network-tuning-and-ebpf-xdp';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Kernel Network Tuning, sysctl & eXpress Data Path (XDP) using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'kernel-network-tuning-and-ebpf-xdp';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: ssh-hardening
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 15,
    content_markdown = '## 1. Core Principles: Hardening sshd_config

In modern computing and infrastructure engineering, understanding **Hardening sshd_config** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Hardening sshd_config**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Hardening sshd_config using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'ssh-hardening';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ssh-hardening';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Hardening sshd_config', 'In modern computing and infrastructure engineering, understanding **Hardening sshd_config** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ssh-hardening';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Hardening sshd_config**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ssh-hardening';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Hardening sshd_config using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ssh-hardening';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: ssh-certificates-and-bastions
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: SSH Certificates, Bastion Jump Hosts & FIDO2 Enclaves

In modern computing and infrastructure engineering, understanding **SSH Certificates, Bastion Jump Hosts & FIDO2 Enclaves** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **SSH Certificates, Bastion Jump Hosts & FIDO2 Enclaves**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect SSH Certificates, Bastion Jump Hosts & FIDO2 Enclaves using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'ssh-certificates-and-bastions';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ssh-certificates-and-bastions';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: SSH Certificates, Bastion Jump Hosts & FIDO2 Enclaves', 'In modern computing and infrastructure engineering, understanding **SSH Certificates, Bastion Jump Hosts & FIDO2 Enclaves** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ssh-certificates-and-bastions';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **SSH Certificates, Bastion Jump Hosts & FIDO2 Enclaves**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ssh-certificates-and-bastions';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect SSH Certificates, Bastion Jump Hosts & FIDO2 Enclaves using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ssh-certificates-and-bastions';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: python-control-flow
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 15,
    content_markdown = '## 1. Core Principles: Control Flow and Functions

In modern computing and infrastructure engineering, understanding **Control Flow and Functions** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Control Flow and Functions**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Control Flow and Functions using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'python-control-flow';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'python-control-flow';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Control Flow and Functions', 'In modern computing and infrastructure engineering, understanding **Control Flow and Functions** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'python-control-flow';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Control Flow and Functions**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'python-control-flow';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Control Flow and Functions using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'python-control-flow';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: asyncio-and-concurrency-patterns
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: Asynchronous Python: Asyncio, Coroutines & Concurrency

In modern computing and infrastructure engineering, understanding **Asynchronous Python: Asyncio, Coroutines & Concurrency** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Asynchronous Python: Asyncio, Coroutines & Concurrency**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Asynchronous Python: Asyncio, Coroutines & Concurrency using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'asyncio-and-concurrency-patterns';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'asyncio-and-concurrency-patterns';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Asynchronous Python: Asyncio, Coroutines & Concurrency', 'In modern computing and infrastructure engineering, understanding **Asynchronous Python: Asyncio, Coroutines & Concurrency** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'asyncio-and-concurrency-patterns';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Asynchronous Python: Asyncio, Coroutines & Concurrency**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'asyncio-and-concurrency-patterns';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Asynchronous Python: Asyncio, Coroutines & Concurrency using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'asyncio-and-concurrency-patterns';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: python-requests-automation
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 15,
    content_markdown = '## 1. Core Principles: API Automation with Python Requests

In modern computing and infrastructure engineering, understanding **API Automation with Python Requests** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **API Automation with Python Requests**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect API Automation with Python Requests using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'python-requests-automation';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'python-requests-automation';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: API Automation with Python Requests', 'In modern computing and infrastructure engineering, understanding **API Automation with Python Requests** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'python-requests-automation';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **API Automation with Python Requests**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'python-requests-automation';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect API Automation with Python Requests using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'python-requests-automation';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: grpc-and-protobuf-microservices
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: gRPC, Protocol Buffers & High-Performance Microservices

In modern computing and infrastructure engineering, understanding **gRPC, Protocol Buffers & High-Performance Microservices** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **gRPC, Protocol Buffers & High-Performance Microservices**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect gRPC, Protocol Buffers & High-Performance Microservices using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'grpc-and-protobuf-microservices';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'grpc-and-protobuf-microservices';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: gRPC, Protocol Buffers & High-Performance Microservices', 'In modern computing and infrastructure engineering, understanding **gRPC, Protocol Buffers & High-Performance Microservices** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'grpc-and-protobuf-microservices';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **gRPC, Protocol Buffers & High-Performance Microservices**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'grpc-and-protobuf-microservices';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect gRPC, Protocol Buffers & High-Performance Microservices using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'grpc-and-protobuf-microservices';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: security-least-privilege
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 15,
    content_markdown = '## 1. Core Principles: Least Privilege and Attack Surface

In modern computing and infrastructure engineering, understanding **Least Privilege and Attack Surface** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Least Privilege and Attack Surface**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Least Privilege and Attack Surface using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'security-least-privilege';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'security-least-privilege';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Least Privilege and Attack Surface', 'In modern computing and infrastructure engineering, understanding **Least Privilege and Attack Surface** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'security-least-privilege';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Least Privilege and Attack Surface**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'security-least-privilege';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Least Privilege and Attack Surface using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'security-least-privilege';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: zero-trust-and-threat-modeling
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: Zero Trust Architecture & Threat Modeling (STRIDE)

In modern computing and infrastructure engineering, understanding **Zero Trust Architecture & Threat Modeling (STRIDE)** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Zero Trust Architecture & Threat Modeling (STRIDE)**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Zero Trust Architecture & Threat Modeling (STRIDE) using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'zero-trust-and-threat-modeling';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'zero-trust-and-threat-modeling';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Zero Trust Architecture & Threat Modeling (STRIDE)', 'In modern computing and infrastructure engineering, understanding **Zero Trust Architecture & Threat Modeling (STRIDE)** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'zero-trust-and-threat-modeling';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Zero Trust Architecture & Threat Modeling (STRIDE)**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'zero-trust-and-threat-modeling';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Zero Trust Architecture & Threat Modeling (STRIDE) using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'zero-trust-and-threat-modeling';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: auth-vs-authz-principles
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 15,
    content_markdown = '## 1. Core Principles: Authentication vs Authorization & IAM

In modern computing and infrastructure engineering, understanding **Authentication vs Authorization & IAM** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Authentication vs Authorization & IAM**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Authentication vs Authorization & IAM using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'auth-vs-authz-principles';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'auth-vs-authz-principles';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Authentication vs Authorization & IAM', 'In modern computing and infrastructure engineering, understanding **Authentication vs Authorization & IAM** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'auth-vs-authz-principles';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Authentication vs Authorization & IAM**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'auth-vs-authz-principles';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Authentication vs Authorization & IAM using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'auth-vs-authz-principles';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: webauthn-fido2-and-mtls
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: FIDO2 Passkeys, WebAuthn & Mutual TLS (mTLS)

In modern computing and infrastructure engineering, understanding **FIDO2 Passkeys, WebAuthn & Mutual TLS (mTLS)** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **FIDO2 Passkeys, WebAuthn & Mutual TLS (mTLS)**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect FIDO2 Passkeys, WebAuthn & Mutual TLS (mTLS) using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'webauthn-fido2-and-mtls';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'webauthn-fido2-and-mtls';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: FIDO2 Passkeys, WebAuthn & Mutual TLS (mTLS)', 'In modern computing and infrastructure engineering, understanding **FIDO2 Passkeys, WebAuthn & Mutual TLS (mTLS)** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'webauthn-fido2-and-mtls';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **FIDO2 Passkeys, WebAuthn & Mutual TLS (mTLS)**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'webauthn-fido2-and-mtls';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect FIDO2 Passkeys, WebAuthn & Mutual TLS (mTLS) using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'webauthn-fido2-and-mtls';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: secure-http-headers-and-cors
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 20,
    content_markdown = '## 1. Core Principles: HTTP Security Headers & CORS Policy

In modern computing and infrastructure engineering, understanding **HTTP Security Headers & CORS Policy** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **HTTP Security Headers & CORS Policy**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect HTTP Security Headers & CORS Policy using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'secure-http-headers-and-cors';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'secure-http-headers-and-cors';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: HTTP Security Headers & CORS Policy', 'In modern computing and infrastructure engineering, understanding **HTTP Security Headers & CORS Policy** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'secure-http-headers-and-cors';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **HTTP Security Headers & CORS Policy**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'secure-http-headers-and-cors';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect HTTP Security Headers & CORS Policy using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'secure-http-headers-and-cors';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: ssrf-and-prototype-pollution
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: Server-Side Request Forgery (SSRF) & Advanced Web Attacks

In modern computing and infrastructure engineering, understanding **Server-Side Request Forgery (SSRF) & Advanced Web Attacks** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Server-Side Request Forgery (SSRF) & Advanced Web Attacks**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Server-Side Request Forgery (SSRF) & Advanced Web Attacks using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'ssrf-and-prototype-pollution';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ssrf-and-prototype-pollution';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Server-Side Request Forgery (SSRF) & Advanced Web Attacks', 'In modern computing and infrastructure engineering, understanding **Server-Side Request Forgery (SSRF) & Advanced Web Attacks** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ssrf-and-prototype-pollution';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Server-Side Request Forgery (SSRF) & Advanced Web Attacks**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ssrf-and-prototype-pollution';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Server-Side Request Forgery (SSRF) & Advanced Web Attacks using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'ssrf-and-prototype-pollution';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: cloud-service-models-and-shared-responsibility
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 15,
    content_markdown = '## 1. Core Principles: Cloud Service Models & The Shared Responsibility Model

In modern computing and infrastructure engineering, understanding **Cloud Service Models & The Shared Responsibility Model** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Cloud Service Models & The Shared Responsibility Model**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Cloud Service Models & The Shared Responsibility Model using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'cloud-service-models-and-shared-responsibility';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cloud-service-models-and-shared-responsibility';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Cloud Service Models & The Shared Responsibility Model', 'In modern computing and infrastructure engineering, understanding **Cloud Service Models & The Shared Responsibility Model** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cloud-service-models-and-shared-responsibility';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Cloud Service Models & The Shared Responsibility Model**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cloud-service-models-and-shared-responsibility';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Cloud Service Models & The Shared Responsibility Model using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cloud-service-models-and-shared-responsibility';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: cloud-networking-vpcs-and-storage
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 15,
    content_markdown = '## 1. Core Principles: Virtual Private Clouds (VPC) & Object Storage

In modern computing and infrastructure engineering, understanding **Virtual Private Clouds (VPC) & Object Storage** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Virtual Private Clouds (VPC) & Object Storage**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Virtual Private Clouds (VPC) & Object Storage using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'cloud-networking-vpcs-and-storage';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cloud-networking-vpcs-and-storage';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Virtual Private Clouds (VPC) & Object Storage', 'In modern computing and infrastructure engineering, understanding **Virtual Private Clouds (VPC) & Object Storage** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cloud-networking-vpcs-and-storage';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Virtual Private Clouds (VPC) & Object Storage**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cloud-networking-vpcs-and-storage';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Virtual Private Clouds (VPC) & Object Storage using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cloud-networking-vpcs-and-storage';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: infrastructure-as-code-terraform
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: Infrastructure as Code (IaC) with Terraform

In modern computing and infrastructure engineering, understanding **Infrastructure as Code (IaC) with Terraform** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Infrastructure as Code (IaC) with Terraform**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Infrastructure as Code (IaC) with Terraform using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'infrastructure-as-code-terraform';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'infrastructure-as-code-terraform';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Infrastructure as Code (IaC) with Terraform', 'In modern computing and infrastructure engineering, understanding **Infrastructure as Code (IaC) with Terraform** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'infrastructure-as-code-terraform';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Infrastructure as Code (IaC) with Terraform**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'infrastructure-as-code-terraform';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Infrastructure as Code (IaC) with Terraform using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'infrastructure-as-code-terraform';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: container-fundamentals
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 15,
    content_markdown = '## 1. Core Principles: Containers vs Virtual Machines

In modern computing and infrastructure engineering, understanding **Containers vs Virtual Machines** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Containers vs Virtual Machines**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Containers vs Virtual Machines using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'container-fundamentals';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'container-fundamentals';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Containers vs Virtual Machines', 'In modern computing and infrastructure engineering, understanding **Containers vs Virtual Machines** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'container-fundamentals';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Containers vs Virtual Machines**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'container-fundamentals';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Containers vs Virtual Machines using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'container-fundamentals';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: rootless-docker-and-image-signing
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: Container Security: Rootless Mode & Cosign Supply Chain

In modern computing and infrastructure engineering, understanding **Container Security: Rootless Mode & Cosign Supply Chain** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Container Security: Rootless Mode & Cosign Supply Chain**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Container Security: Rootless Mode & Cosign Supply Chain using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'rootless-docker-and-image-signing';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'rootless-docker-and-image-signing';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Container Security: Rootless Mode & Cosign Supply Chain', 'In modern computing and infrastructure engineering, understanding **Container Security: Rootless Mode & Cosign Supply Chain** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'rootless-docker-and-image-signing';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Container Security: Rootless Mode & Cosign Supply Chain**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'rootless-docker-and-image-signing';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Container Security: Rootless Mode & Cosign Supply Chain using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'rootless-docker-and-image-signing';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: continuous-integration-principles
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 20,
    content_markdown = '## 1. Core Principles: Continuous Integration & GitHub Actions

In modern computing and infrastructure engineering, understanding **Continuous Integration & GitHub Actions** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Continuous Integration & GitHub Actions**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Continuous Integration & GitHub Actions using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'continuous-integration-principles';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'continuous-integration-principles';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Continuous Integration & GitHub Actions', 'In modern computing and infrastructure engineering, understanding **Continuous Integration & GitHub Actions** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'continuous-integration-principles';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Continuous Integration & GitHub Actions**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'continuous-integration-principles';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Continuous Integration & GitHub Actions using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'continuous-integration-principles';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: continuous-deployment-strategies
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 20,
    content_markdown = '## 1. Core Principles: Continuous Deployment & Release Strategies

In modern computing and infrastructure engineering, understanding **Continuous Deployment & Release Strategies** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Continuous Deployment & Release Strategies**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Continuous Deployment & Release Strategies using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'continuous-deployment-strategies';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'continuous-deployment-strategies';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Continuous Deployment & Release Strategies', 'In modern computing and infrastructure engineering, understanding **Continuous Deployment & Release Strategies** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'continuous-deployment-strategies';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Continuous Deployment & Release Strategies**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'continuous-deployment-strategies';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Continuous Deployment & Release Strategies using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'continuous-deployment-strategies';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: gitops-with-argocd-and-secrets
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: GitOps with ArgoCD & Enterprise Secret Management

In modern computing and infrastructure engineering, understanding **GitOps with ArgoCD & Enterprise Secret Management** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **GitOps with ArgoCD & Enterprise Secret Management**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect GitOps with ArgoCD & Enterprise Secret Management using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'gitops-with-argocd-and-secrets';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'gitops-with-argocd-and-secrets';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: GitOps with ArgoCD & Enterprise Secret Management', 'In modern computing and infrastructure engineering, understanding **GitOps with ArgoCD & Enterprise Secret Management** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'gitops-with-argocd-and-secrets';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **GitOps with ArgoCD & Enterprise Secret Management**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'gitops-with-argocd-and-secrets';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect GitOps with ArgoCD & Enterprise Secret Management using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'gitops-with-argocd-and-secrets';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: calling-llm-apis-and-streaming
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 15,
    content_markdown = '## 1. Core Principles: Structured Output & Server-Sent Events (SSE)

In modern computing and infrastructure engineering, understanding **Structured Output & Server-Sent Events (SSE)** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Structured Output & Server-Sent Events (SSE)**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Structured Output & Server-Sent Events (SSE) using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'calling-llm-apis-and-streaming';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'calling-llm-apis-and-streaming';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Structured Output & Server-Sent Events (SSE)', 'In modern computing and infrastructure engineering, understanding **Structured Output & Server-Sent Events (SSE)** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'calling-llm-apis-and-streaming';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Structured Output & Server-Sent Events (SSE)**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'calling-llm-apis-and-streaming';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Structured Output & Server-Sent Events (SSE) using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'calling-llm-apis-and-streaming';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: fine-tuning-lora-and-quantization
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: Parameter-Efficient Fine-Tuning (PEFT/LoRA) & Model Quantization

In modern computing and infrastructure engineering, understanding **Parameter-Efficient Fine-Tuning (PEFT/LoRA) & Model Quantization** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Parameter-Efficient Fine-Tuning (PEFT/LoRA) & Model Quantization**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Parameter-Efficient Fine-Tuning (PEFT/LoRA) & Model Quantization using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'fine-tuning-lora-and-quantization';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'fine-tuning-lora-and-quantization';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Parameter-Efficient Fine-Tuning (PEFT/LoRA) & Model Quantization', 'In modern computing and infrastructure engineering, understanding **Parameter-Efficient Fine-Tuning (PEFT/LoRA) & Model Quantization** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'fine-tuning-lora-and-quantization';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Parameter-Efficient Fine-Tuning (PEFT/LoRA) & Model Quantization**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'fine-tuning-lora-and-quantization';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Parameter-Efficient Fine-Tuning (PEFT/LoRA) & Model Quantization using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'fine-tuning-lora-and-quantization';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: agentic-loops-and-react
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 20,
    content_markdown = '## 1. Core Principles: Agentic Architectures: The ReAct Pattern

In modern computing and infrastructure engineering, understanding **Agentic Architectures: The ReAct Pattern** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Agentic Architectures: The ReAct Pattern**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Agentic Architectures: The ReAct Pattern using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'agentic-loops-and-react';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'agentic-loops-and-react';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Agentic Architectures: The ReAct Pattern', 'In modern computing and infrastructure engineering, understanding **Agentic Architectures: The ReAct Pattern** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'agentic-loops-and-react';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Agentic Architectures: The ReAct Pattern**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'agentic-loops-and-react';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Agentic Architectures: The ReAct Pattern using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'agentic-loops-and-react';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: tool-use-and-agent-sandboxing
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 20,
    content_markdown = '## 1. Core Principles: Tool Definition, Guardrails & Sandboxing

In modern computing and infrastructure engineering, understanding **Tool Definition, Guardrails & Sandboxing** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Tool Definition, Guardrails & Sandboxing**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Tool Definition, Guardrails & Sandboxing using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'tool-use-and-agent-sandboxing';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'tool-use-and-agent-sandboxing';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Tool Definition, Guardrails & Sandboxing', 'In modern computing and infrastructure engineering, understanding **Tool Definition, Guardrails & Sandboxing** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'tool-use-and-agent-sandboxing';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Tool Definition, Guardrails & Sandboxing**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'tool-use-and-agent-sandboxing';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Tool Definition, Guardrails & Sandboxing using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'tool-use-and-agent-sandboxing';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: reflection-critics-and-agent-memory
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: Reflective Agent Loops & Ephemeral vs Persistent Memory

In modern computing and infrastructure engineering, understanding **Reflective Agent Loops & Ephemeral vs Persistent Memory** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Reflective Agent Loops & Ephemeral vs Persistent Memory**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Reflective Agent Loops & Ephemeral vs Persistent Memory using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'reflection-critics-and-agent-memory';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'reflection-critics-and-agent-memory';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Reflective Agent Loops & Ephemeral vs Persistent Memory', 'In modern computing and infrastructure engineering, understanding **Reflective Agent Loops & Ephemeral vs Persistent Memory** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'reflection-critics-and-agent-memory';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Reflective Agent Loops & Ephemeral vs Persistent Memory**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'reflection-critics-and-agent-memory';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Reflective Agent Loops & Ephemeral vs Persistent Memory using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'reflection-critics-and-agent-memory';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: cron-scheduling-and-webhooks
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 20,
    content_markdown = '## 1. Core Principles: Event-Driven Architecture: Webhooks & Cron

In modern computing and infrastructure engineering, understanding **Event-Driven Architecture: Webhooks & Cron** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Event-Driven Architecture: Webhooks & Cron**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Event-Driven Architecture: Webhooks & Cron using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'cron-scheduling-and-webhooks';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cron-scheduling-and-webhooks';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Event-Driven Architecture: Webhooks & Cron', 'In modern computing and infrastructure engineering, understanding **Event-Driven Architecture: Webhooks & Cron** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cron-scheduling-and-webhooks';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Event-Driven Architecture: Webhooks & Cron**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cron-scheduling-and-webhooks';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Event-Driven Architecture: Webhooks & Cron using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'cron-scheduling-and-webhooks';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: error-handling-and-retries
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 20,
    content_markdown = '## 1. Core Principles: Fault-Tolerant Automation: Idempotency & Retries

In modern computing and infrastructure engineering, understanding **Fault-Tolerant Automation: Idempotency & Retries** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Fault-Tolerant Automation: Idempotency & Retries**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Fault-Tolerant Automation: Idempotency & Retries using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'error-handling-and-retries';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'error-handling-and-retries';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Fault-Tolerant Automation: Idempotency & Retries', 'In modern computing and infrastructure engineering, understanding **Fault-Tolerant Automation: Idempotency & Retries** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'error-handling-and-retries';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Fault-Tolerant Automation: Idempotency & Retries**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'error-handling-and-retries';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Fault-Tolerant Automation: Idempotency & Retries using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'error-handling-and-retries';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: temporal-orchestration-and-sagas
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: Durable Execution Engines & The Saga Pattern

In modern computing and infrastructure engineering, understanding **Durable Execution Engines & The Saga Pattern** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Durable Execution Engines & The Saga Pattern**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Durable Execution Engines & The Saga Pattern using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'temporal-orchestration-and-sagas';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'temporal-orchestration-and-sagas';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Durable Execution Engines & The Saga Pattern', 'In modern computing and infrastructure engineering, understanding **Durable Execution Engines & The Saga Pattern** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'temporal-orchestration-and-sagas';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Durable Execution Engines & The Saga Pattern**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'temporal-orchestration-and-sagas';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Durable Execution Engines & The Saga Pattern using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'temporal-orchestration-and-sagas';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: enterprise-switching-and-vlans
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: Enterprise Switching, VLANs & Trunking (802.1Q)

In modern computing and infrastructure engineering, understanding **Enterprise Switching, VLANs & Trunking (802.1Q)** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Enterprise Switching, VLANs & Trunking (802.1Q)**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Enterprise Switching, VLANs & Trunking (802.1Q) using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'enterprise-switching-and-vlans';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'enterprise-switching-and-vlans';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Enterprise Switching, VLANs & Trunking (802.1Q)', 'In modern computing and infrastructure engineering, understanding **Enterprise Switching, VLANs & Trunking (802.1Q)** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'enterprise-switching-and-vlans';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Enterprise Switching, VLANs & Trunking (802.1Q)**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'enterprise-switching-and-vlans';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Enterprise Switching, VLANs & Trunking (802.1Q) using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'enterprise-switching-and-vlans';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: bgp-peering-and-mpls
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: BGP Peering, Autonomous Systems & WAN

In modern computing and infrastructure engineering, understanding **BGP Peering, Autonomous Systems & WAN** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **BGP Peering, Autonomous Systems & WAN**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect BGP Peering, Autonomous Systems & WAN using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'bgp-peering-and-mpls';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'bgp-peering-and-mpls';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: BGP Peering, Autonomous Systems & WAN', 'In modern computing and infrastructure engineering, understanding **BGP Peering, Autonomous Systems & WAN** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'bgp-peering-and-mpls';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **BGP Peering, Autonomous Systems & WAN**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'bgp-peering-and-mpls';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect BGP Peering, Autonomous Systems & WAN using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'bgp-peering-and-mpls';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: mpls-l3vpn-and-traffic-engineering
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: MPLS L3VPN, Segment Routing & Traffic Engineering

In modern computing and infrastructure engineering, understanding **MPLS L3VPN, Segment Routing & Traffic Engineering** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **MPLS L3VPN, Segment Routing & Traffic Engineering**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect MPLS L3VPN, Segment Routing & Traffic Engineering using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'mpls-l3vpn-and-traffic-engineering';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'mpls-l3vpn-and-traffic-engineering';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: MPLS L3VPN, Segment Routing & Traffic Engineering', 'In modern computing and infrastructure engineering, understanding **MPLS L3VPN, Segment Routing & Traffic Engineering** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'mpls-l3vpn-and-traffic-engineering';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **MPLS L3VPN, Segment Routing & Traffic Engineering**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'mpls-l3vpn-and-traffic-engineering';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect MPLS L3VPN, Segment Routing & Traffic Engineering using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'mpls-l3vpn-and-traffic-engineering';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: siem-architecture-and-log-analysis
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: SIEM Architecture & Security Log Analysis

In modern computing and infrastructure engineering, understanding **SIEM Architecture & Security Log Analysis** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **SIEM Architecture & Security Log Analysis**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect SIEM Architecture & Security Log Analysis using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'siem-architecture-and-log-analysis';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'siem-architecture-and-log-analysis';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: SIEM Architecture & Security Log Analysis', 'In modern computing and infrastructure engineering, understanding **SIEM Architecture & Security Log Analysis** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'siem-architecture-and-log-analysis';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **SIEM Architecture & Security Log Analysis**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'siem-architecture-and-log-analysis';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect SIEM Architecture & Security Log Analysis using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'siem-architecture-and-log-analysis';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: incident-response-and-mitre-attck
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: Incident Response & The MITRE ATT&CK Framework

In modern computing and infrastructure engineering, understanding **Incident Response & The MITRE ATT&CK Framework** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Incident Response & The MITRE ATT&CK Framework**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Incident Response & The MITRE ATT&CK Framework using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'incident-response-and-mitre-attck';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'incident-response-and-mitre-attck';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Incident Response & The MITRE ATT&CK Framework', 'In modern computing and infrastructure engineering, understanding **Incident Response & The MITRE ATT&CK Framework** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'incident-response-and-mitre-attck';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Incident Response & The MITRE ATT&CK Framework**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'incident-response-and-mitre-attck';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Incident Response & The MITRE ATT&CK Framework using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'incident-response-and-mitre-attck';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: threat-hunting-yara-and-memory-forensics
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: Threat Hunting with YARA, Sigma & Volatility Memory Forensics

In modern computing and infrastructure engineering, understanding **Threat Hunting with YARA, Sigma & Volatility Memory Forensics** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Threat Hunting with YARA, Sigma & Volatility Memory Forensics**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Threat Hunting with YARA, Sigma & Volatility Memory Forensics using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'threat-hunting-yara-and-memory-forensics';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'threat-hunting-yara-and-memory-forensics';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Threat Hunting with YARA, Sigma & Volatility Memory Forensics', 'In modern computing and infrastructure engineering, understanding **Threat Hunting with YARA, Sigma & Volatility Memory Forensics** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'threat-hunting-yara-and-memory-forensics';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Threat Hunting with YARA, Sigma & Volatility Memory Forensics**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'threat-hunting-yara-and-memory-forensics';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Threat Hunting with YARA, Sigma & Volatility Memory Forensics using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'threat-hunting-yara-and-memory-forensics';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: multi-agent-orchestration-and-evals
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: Multi-Agent Orchestration & Evaluation Frameworks

In modern computing and infrastructure engineering, understanding **Multi-Agent Orchestration & Evaluation Frameworks** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Multi-Agent Orchestration & Evaluation Frameworks**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Multi-Agent Orchestration & Evaluation Frameworks using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'multi-agent-orchestration-and-evals';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'multi-agent-orchestration-and-evals';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Multi-Agent Orchestration & Evaluation Frameworks', 'In modern computing and infrastructure engineering, understanding **Multi-Agent Orchestration & Evaluation Frameworks** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'multi-agent-orchestration-and-evals';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Multi-Agent Orchestration & Evaluation Frameworks**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'multi-agent-orchestration-and-evals';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Multi-Agent Orchestration & Evaluation Frameworks using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'multi-agent-orchestration-and-evals';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

-- ==========================================
-- Lesson: high-throughput-llm-serving-vllm
-- ==========================================
UPDATE public.lessons 
SET estimated_minutes = 25,
    content_markdown = '## 1. Core Principles: Distributed LLM Serving: vLLM, PagedAttention & Speculative Decoding

In modern computing and infrastructure engineering, understanding **Distributed LLM Serving: vLLM, PagedAttention & Speculative Decoding** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.

---

## 2. Technical Breakdown & Architecture

To effectively operate systems involving **Distributed LLM Serving: vLLM, PagedAttention & Speculative Decoding**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |

---

## 3. Practical Implementation & CLI Walkthrough

Deploy and inspect Distributed LLM Serving: vLLM, PagedAttention & Speculative Decoding using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.

---

## 4. Production Checklist & Troubleshooting Workflow

> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.'
WHERE slug = 'high-throughput-llm-serving-vllm';

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'high-throughput-llm-serving-vllm';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 1;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'theory', '1. Core Principles: Distributed LLM Serving: vLLM, PagedAttention & Speculative Decoding', 'In modern computing and infrastructure engineering, understanding **Distributed LLM Serving: vLLM, PagedAttention & Speculative Decoding** provides the bedrock for scalable systems administration and robust distributed architectures.

> [!NOTE]
> Mastering this topic equips you to troubleshoot complex production incidents and pass enterprise-grade certifications.

### Core Architectural Concepts
- **Foundational Model**: Establishes deterministic state transitions and reliable communication boundaries.
- **Protocol Standards**: Aligns with industry specifications (IETF RFCs, POSIX standards, or CNCF patterns).
- **Failure Domains**: Isolates blast radiuses to prevent cascading system failures.', 1);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'high-throughput-llm-serving-vllm';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 2;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'walkthrough', '2. Technical Breakdown & Architecture', 'To effectively operate systems involving **Distributed LLM Serving: vLLM, PagedAttention & Speculative Decoding**, engineers must understand internal mechanisms, data formats, and memory/network representations.

| Component | Responsibility | Operational Impact |
|---|---|---|
| **Control Plane** | State coordination & policy distribution | High: Controls routing and scheduling |
| **Data Plane** | Wire-speed packet forwarding & computation | Critical: Determines throughput and latency |
| **Telemetry** | Logging, metrics collection, and alerting | Essential: Powers automated remediation |', 2);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'high-throughput-llm-serving-vllm';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 3;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'example', '3. Practical Implementation & CLI Walkthrough', 'Deploy and inspect Distributed LLM Serving: vLLM, PagedAttention & Speculative Decoding using production-grade CLI commands and configuration files:

```bash
# Inspect runtime status and active configuration
systemctl status --lines=20 || ip route show || uname -a

# Validate operational syntax and configuration files
grep -v "^#" /etc/hosts || echo "System operational"
```

> [!TIP]
> Always verify configuration syntax in a staging sandbox before applying changes to production clusters.', 3);
  END IF;
END $$;

DO $$
DECLARE
  v_lesson_id UUID;
BEGIN
  SELECT id INTO v_lesson_id FROM public.lessons WHERE slug = 'high-throughput-llm-serving-vllm';
  IF v_lesson_id IS NOT NULL THEN
    DELETE FROM public.lesson_sections WHERE lesson_id = v_lesson_id AND sort_order = 4;

    INSERT INTO public.lesson_sections (lesson_id, section_type, title, content_markdown, sort_order)
    VALUES (v_lesson_id, 'troubleshooting', '4. Production Checklist & Troubleshooting Workflow', '> [!WARNING]
> Common failure modes stem from misconfigured permissions, network timeouts, and resource quota exhaustion.

### Systematic Troubleshooting Checklist
1. **Verify Connectivity & Access**: Confirm firewall rules and user permissions.
2. **Review System & Service Logs**: Inspect `journalctl -xe` or dedicated service logs.
3. **Validate State & Recovery**: Ensure automated health checks and restart policies are engaged.', 4);
  END IF;
END $$;

