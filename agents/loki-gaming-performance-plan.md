# Loki Gaming Performance and Stability Plan

**Audit date:** 2026-09-19  
**Host:** `loki`  
**Status:** Findings and recommendations only; no configuration changes have been implemented yet.

## Goals

Improve gaming responsiveness, frame-time consistency, and system stability without relying on unmeasured, cargo-cult kernel tuning. Make one meaningful change at a time and benchmark before and after so regressions can be attributed and rolled back.

## Executive Summary

The highest-impact opportunities are straightforward hardware and platform corrections rather than obscure kernel parameters:

1. **Completed:** The 165 Hz display now runs at 164.056 Hz, with VRR enabled on demand to avoid desktop flicker.
2. **Completed, validation pending:** The DDR4-3200 memory kit now runs at its rated 3200 MT/s; stability testing remains outstanding.
3. **Completed:** The motherboard BIOS has been updated from the April 2020 `H.60` release to `H.P3`, and Resizable BAR is active.
4. Loki has no swap or zram and has already suffered repeated global OOM kills.
5. PipeWire cannot obtain realtime scheduling through RTKit, which can hurt audio stability under load.
6. **Completed:** The firmware update restored valid CPPC data; `amd-pstate-epp` is active and the Balanced profile uses the `powersave` governor with `balance_performance` EPP.

The GPU, NVMe, temperatures, and retained hardware-error logs otherwise look healthy.

## Observed Hardware and Runtime State

| Component | Finding |
| --- | --- |
| CPU | AMD Ryzen 5 3600X, 6 cores / 12 threads |
| Motherboard | MSI B450 GAMING PLUS MAX, MS-7B86 |
| BIOS | `H.P3`, dated 2026-08-17 (updated from `H.60`, dated 2020-04-18) |
| Memory | 32 GiB, 2×16 GiB Corsair `CMK32GX4M2E3200C16` |
| Memory speed | **Configured at 3200 MT/s** after enabling MSI A-XMP |
| GPU | Gigabyte NVIDIA GeForce RTX 4070, 12 GiB |
| NVIDIA driver | `595.84`, open kernel module, DRM modesetting active |
| GPU bus | PCIe 3.0 ×16; Gen1 while idle is normal power management behavior |
| Resizable BAR | **Enabled:** NVIDIA reports a 16,384 MiB BAR1 aperture |
| Display | Dell S3220DGF, 2560×1440 |
| Refresh rate | **164.056 Hz active** |
| Variable refresh rate | Supported and configured on demand; disabled on the desktop as expected |
| Main storage | Samsung 970 EVO Plus 2 TB, encrypted ext4 root |
| Storage health | SMART passed, 1% wear, zero media/data-integrity errors, healthy temperatures |
| RAM pressure protection | 32 GiB RAM, **no swap or zram** |
| Kernel | Linux Zen 7.1.10 |
| CPU scaling | **Fixed after the firmware update:** `amd-pstate-epp` is active; Balanced uses `powersave` with `balance_performance` EPP, and boost is enabled |
| GameMode | Installed and configured to request `performance` while active and restore the `powersave` governor afterward |
| Audio realtime scheduling | RTKit absent; PipeWire logs fallback behavior |
| Failed units | None currently |
| Recent hardware failures | No NVIDIA Xid, GPU-falloff, NVMe reset, ext4, or machine-check failures found |

### Storage notes

The NVMe reports:

- SMART overall health: passed
- 1% used
- Approximately 41.2 TB read and 40.1 TB written
- Zero media and data-integrity errors
- 46 unsafe shutdowns
- 9,066 error-log entries reporting `Invalid Field in Command`

Given the clean media counters and SMART result, the invalid-command entries appear more consistent with unsupported management commands than flash failure. The unsafe-shutdown count should be monitored, but there is no current evidence that the drive is failing.

## Implementation Plan

### Phase 0: Establish a repeatable baseline

- [ ] Select representative workloads:
  - At least one CPU-bound/high-refresh game
  - At least one GPU-bound 1440p game
  - A game known to exhibit stutter or instability, if applicable
  - Sunshine streaming, if it is an important workload
- [ ] Record fixed graphics settings and a repeatable test route or benchmark scene.
- [ ] Capture with MangoHud:
  - Average FPS
  - 1% lows or equivalent low-percentile metric
  - Frame-time graph and spikes
  - CPU/GPU utilization
  - CPU/GPU clocks
  - GPU power and temperature
  - VRAM and system-memory use
- [ ] Record whether GameMode is active during each test.
- [ ] Preserve the baseline results alongside the implementation work.

Success should be judged primarily by frame-time consistency and stability, not average FPS alone.

### Phase 1: Correct the display path

**Priority:** Highest  
**Risk:** Low  
**Expected impact:** Very high for latency, motion clarity, and responsiveness

Configure the Dell S3220DGF for:

- `2560×1440 @ 164.056 Hz`
- Variable refresh rate, preferably with an on-demand or fullscreen-oriented policy
- Adaptive Sync enabled in the monitor OSD, if it is currently disabled

Going from 60 Hz to 164 Hz reduces the display refresh interval from approximately 16.7 ms to 6.1 ms. This is a much larger responsiveness improvement than any likely scheduler or sysctl adjustment.

Initial VRR policy:

- [ ] Cap games around 160–162 FPS so presentation remains below the 164 Hz ceiling.
- [x] Test for dark-scene brightness flicker, which can occur on some high-refresh VA displays. Always-on VRR caused desktop flicker.
- [x] If flicker is objectionable, keep 164 Hz but use fixed refresh, or enable VRR only for games where it behaves well. Niri now uses `on-demand=true`.
- [x] Verify the active mode and VRR state using `niri msg outputs` after implementation. It reports 2560×1440 at 164.056 Hz, with VRR supported and inactive on the desktop as expected for the on-demand policy.

The current Niri configuration contains no explicit output mode, so it accepts the monitor's EDID-preferred 60 Hz mode.

### Phase 2: Update motherboard firmware

**Priority:** Very high  
**Risk:** Moderate; requires a carefully managed firmware update

At the initial audit, the installed BIOS was `H.60` from 2020-04-18. Research found a substantially newer MSI package for this exact board:

- Board: B450 GAMING PLUS MAX / MS-7B86
- Package: `7B86vHO`
- Date found during research: 2025-09-11
- AGESA: ComboAM4v2PI `1.2.0.F`

MSI's support site blocked automated access during the audit. Before flashing, manually confirm that this remains the latest appropriate non-beta release:

- [MSI B450 GAMING PLUS MAX support](https://www.msi.com/Motherboard/B450-GAMING-PLUS-MAX/support)
- [Direct `7B86vHO` package found during research](https://download.msi.com/bos_exe/mb/7B86vHO.zip)

Reasons to update:

- Newer AGESA and platform fixes
- Security updates
- Ryzen 5000/X3D support
- Resizable BAR support added in intervening releases
- Possible correction of the invalid CPPC data preventing `amd_pstate` initialization

The available release notes did not explicitly promise a CPPC fix. Restoring `amd_pstate` is therefore a possible benefit, not a guarantee.

Safe sequence:

1. [x] Confirm the board is exactly MSI B450 GAMING PLUS MAX / MS-7B86.
2. [ ] Record current UEFI settings and fan curves.
3. [ ] Keep disk-encryption recovery information available.
4. [x] Flash using MSI M-FLASH with the existing Ryzen 5 3600X installed and stable power available. The running firmware is now `H.P3`, dated 2026-08-17.
5. [ ] Boot once using firmware defaults.
6. [ ] Verify boot, storage, networking, temperatures, and basic stability.
7. [ ] Reconfigure UEFI settings one category at a time.
8. [ ] Keep the 3600X installed until the firmware update and all critical settings are validated.

Do not combine the BIOS flash, XMP activation, ReBAR activation, and a CPU replacement into a single change.

### Phase 3: Restore memory performance and validate stability

**Priority:** Very high  
**Risk:** Moderate; XMP is still a memory overclock/profile and must be tested

At the initial audit, the installed Corsair kit was running at JEDEC DDR4-2133 and 1.2 V despite being rated for DDR4-3200. MSI A-XMP is now enabled and SMBIOS reports 3200 MT/s; stability testing remains pending.

After the firmware update is known stable:

1. [x] Enable MSI A-XMP/Profile 1 for DDR4-3200. SMBIOS reports both installed DIMMs configured at 3200 MT/s.
2. [ ] Confirm the resulting memory clock, timings, voltage, and fabric clock. The 3200 MT/s memory speed is confirmed, but timings, operating voltage, and fabric clock still need independent verification.
3. [ ] Run a boot-time memory test such as Memtest86+.
4. [ ] Run a sustained mixed memory/CPU workload.
5. [ ] Run the representative game benchmark set.
6. [ ] Inspect the journal for MCE, EDAC, general-protection, or application-crash errors.
7. [ ] Retain the profile only if it is error-free.

Theoretical memory bandwidth rises substantially from 2133 to 3200 MT/s, but gaming performance should not be assumed to improve by the same percentage. Measure the real effect, especially on low-percentile frame times.

### Phase 4: Add memory-pressure protection

**Priority:** High for stability  
**Risk:** Low when implemented conservatively

Loki has no swap. `systemd-oomd` reports degraded pressure handling, and retained logs show several global OOM kills on 2026-08-23.

Recommended design:

- Approximately 8 GiB of high-priority compressed zram swap
- Optionally 8–16 GiB of lower-priority disk-backed swap as an emergency fallback

The intent is not to let games page heavily. Zram should absorb short bursts without storage I/O, while lower-priority disk swap can prevent abrupt process termination under sustained or poorly compressible pressure.

Validation:

- [ ] Confirm both swap tiers and their priorities.
- [ ] Generate controlled memory pressure.
- [ ] Verify zram is used before disk swap.
- [ ] Confirm the desktop remains responsive and arbitrary processes are not killed.
- [ ] Check zram compression and memory-use statistics after the test.

Reference: [Linux kernel zram documentation](https://docs.kernel.org/admin-guide/blockdev/zram.html)

### Phase 5: Restore policy-controlled realtime audio scheduling

**Priority:** Medium-high for audio stability and latency  
**Risk:** Low

PipeWire and WirePlumber currently report that RTKit is unavailable. The user session has a realtime-priority limit of zero, so PipeWire falls back rather than receiving the normal policy-controlled realtime scheduling used by desktop audio systems.

Plan:

- [ ] Enable RTKit.
- [ ] Confirm the PipeWire and WirePlumber warnings disappear.
- [ ] Inspect the actual scheduling policy and priority of relevant audio threads.
- [ ] Test for audio crackling or xruns during CPU- and I/O-heavy gaming workloads.

This is primarily an audio stability and latency improvement, not an average-FPS optimization. Do not grant whole games unrestricted `SCHED_FIFO` priority.

Reference: [PipeWire realtime module](https://docs.pipewire.org/page_module_rt.html)

### Phase 6: Validate GameMode and Proton behavior

#### GameMode

GameMode is installed and configured to:

- Request the performance CPU governor
- Renice the game
- Attempt soft realtime behavior
- Restore the `amd-pstate-epp`-compatible `powersave` governor afterward

Its inactive state during the audit was normal because no game was requesting it.

Plan:

- [ ] Run `gamemoded -t`.
- [ ] Verify representative Steam games actually activate GameMode.
- [ ] Use `gamemoderun %command%` for games without native integration.
- [ ] Confirm the CPU governor changes while a game is running and restores afterward.
- [ ] Verify whether the requested process niceness is applied.
- [ ] Treat `softrealtime` as unverified unless runtime inspection proves that the intended scheduler policy is active on the current kernel.

Reference: [Feral GameMode 1.8.2](https://github.com/FeralInteractive/gamemode/blob/1.8.2/README.md)

#### Proton and memory mappings

The current value is:

```text
vm.max_map_count = 1048576
```

This is already far above the traditional kernel default and is probably sufficient for most games. Valve's broad compatibility recommendation is `2147483642`.

This setting is a compatibility ceiling, not an FPS optimization, and does not preallocate memory.

Reference: [Valve Proton requirements](https://github.com/ValveSoftware/Proton/wiki/Requirements)

#### Global vkd3d-proton override

The current Steam environment globally sets:

```text
VKD3D_CONFIG=dxr,dxr11
```

Before retaining it permanently:

- [ ] Check the current vkd3d-proton documentation and Proton behavior.
- [ ] Determine whether current versions expose the required ray-tracing features automatically.
- [ ] Prefer per-title compatibility overrides unless the global setting remains justified.

### Phase 7: Enable and benchmark Resizable BAR

**Priority:** Medium  
**Risk:** Low to moderate after the BIOS is stable

At the initial audit, the RTX 4070 exposed only a 256 MiB BAR1 aperture. After enabling Above 4G Decoding and Re-Size BAR in firmware, NVIDIA now reports a 16,384 MiB BAR1 aperture.

After the firmware and memory settings are stable:

1. [x] Confirm UEFI boot and disable CSM if required. Linux is booted in UEFI mode.
2. [x] Enable Above 4G Decoding. The GPU's 16 GiB BAR is mapped above 4 GiB.
3. [x] Enable Re-Size BAR support.
4. [x] Verify Linux and the NVIDIA driver report a substantially larger mapped BAR or explicit ReBAR activation. NVIDIA reports 16,384 MiB BAR1, increased from 256 MiB.
5. [ ] Benchmark before and after using the established workload set.

Expected impact is modest and title-dependent. It is worth enabling on supported hardware but should not be expected to transform performance.

### Phase 8: Re-evaluate CPU frequency management

Before the firmware update, `amd_pstate` failed because the firmware reported zero or invalid minimum, maximum, and nominal CPPC values, so Linux fell back to `acpi-cpufreq`.

After the firmware update, `amd-pstate-epp` initializes in active mode with valid CPPC performance values. The Balanced desktop profile now provides:

- The `powersave` scaling governor with `balance_performance` EPP
- CPU boost enabled
- A performance governor that GameMode can request, with `powersave` restored afterward

- [ ] Look for CPPC and Preferred Cores settings in UEFI.
- [x] Check whether `amd_pstate` initializes without errors. `/sys/devices/system/cpu/amd_pstate/status` reports `active`.
- [x] Confirm the active scaling driver and policy. All CPU policies use `amd-pstate-epp`; Balanced selects `powersave` with `balance_performance` EPP.
- [ ] Benchmark the available modes rather than assuming the newer driver is faster.
- [x] Check whether the firmware still supplies invalid CPPC values. The values are now valid, so retaining the `acpi-cpufreq` fallback is unnecessary.

Reference: [Linux kernel `amd_pstate` documentation](https://docs.kernel.org/admin-guide/pm/amd-pstate.html)

### Phase 9: Compare the Zen and standard kernels only if useful

**Priority:** Optional  
**Risk:** Low if a known-good boot generation is preserved

Loki already uses the Zen kernel. Its latency-oriented configuration may help some workloads, but it is not universally faster or more stable.

Keep a standard NixOS kernel generation available and compare:

- Average FPS
- Low-percentile frame times
- Frame-time spikes
- Audio xruns
- Game crashes
- Suspend/resume behavior
- NVIDIA behavior

If Zen produces no measurable benefit, the standard kernel may be the simpler stability baseline. It is also useful when isolating regressions.

### Phase 10: Consider an AM4 CPU upgrade

**Priority:** Optional hardware investment

After completing the free and low-cost fixes, the strongest practical AM4 gaming upgrade is likely a Ryzen 7 5700X3D.

Why:

- The RTX 4070 can expose the 3600X's limits in CPU-heavy and high-refresh games.
- The 3D V-Cache parts tend to improve low-percentile frame times and CPU-limited performance.
- The 5700X3D is generally close enough to the 5800X3D that it is the better value unless the latter is similarly priced.

Expected result at 1440p:

- Larger gains in simulation, strategy, open-world, competitive/high-refresh, and otherwise CPU-heavy titles
- Better minimums and reduced stutter
- Smaller gains in fully GPU-bound 1440p high/ultra workloads

Before purchasing:

- [ ] Verify the exact CPU-support table and minimum BIOS for this motherboard.
- [ ] Verify cooler capacity and case airflow.
- [ ] Compare current local prices for the 5700X3D and 5800X3D.
- [ ] Update and validate the BIOS with the 3600X before replacing the processor.

## Secondary Issues to Investigate if Relevant

### Sunshine and portals

The journal contains portal errors involving Sunshine's RemoteDesktop session. If Sunshine streaming is unreliable:

- [ ] Verify that the selected portal backend exposes the interfaces Sunshine needs.
- [ ] Test local gaming separately from streaming.
- [ ] Measure whether Sunshine causes frame-time, capture, or idle-power issues.

Sunshine was using NVENC-capable GPU resources but had no active encoder session during inspection.

### Broadcom wireless adapter

The Broadcom BCM4360 adapter loads `b43`, but the driver reports an unsupported AC PHY and fails probing. This is irrelevant when Loki uses wired Ethernet, but should be corrected or disabled if wireless gaming is expected.

For latency-sensitive gaming and streaming, the existing wired Realtek gigabit Ethernet path is preferable.

### Secondary SATA SSD

If the Samsung 850 EVO 120 GB stores games or active data:

- [ ] Collect its SMART health report.
- [ ] Check media errors, wear, CRC errors, and unsafe shutdowns.

Only the main NVMe was health-checked during this audit.

### Load thermals and power delivery

Idle temperatures were healthy:

- CPU approximately 45–47 °C
- GPU approximately 31–35 °C
- NVMe approximately 37–43 °C

This does not establish load behavior. During baseline benchmarking:

- [ ] Record sustained CPU and GPU temperatures.
- [ ] Check for thermal, power, or voltage-reliability throttling.
- [ ] Identify the PSU and CPU cooler if stability problems occur under combined load.

## Avoid Unmeasured Cargo-Cult Tuning

Do not apply generic gaming-tuning bundles involving:

- Disabling CPU security mitigations
- Disabling SMT
- Static CPU isolation or IRQ pinning
- Forcing HPET or clocksource parameters
- Whole-game realtime scheduling
- Static HugeTLB reservations
- Globally disabling Transparent Huge Pages
- Periodic `drop_caches`
- Arbitrary dirty ratios, watermarks, or scheduler values
- Forcing BFQ or another scheduler on the NVMe
- Raising the RTX 4070 power limit
- GPU overclocking or undervolting while diagnosing stability
- Combining several firmware and hardware changes before testing

The current Transparent Huge Page policy is already the sensible `madvise` setting. There is no evidence of GPU thermal throttling, NVIDIA hardware failure, or NVMe media failure.

## Recommended Execution Order

1. [ ] Establish and save the benchmark baseline.
2. [x] Configure 1440p at 164 Hz.
3. [x] Enable and test VRR using the on-demand policy.
4. [x] Update the BIOS.
5. [x] Enable DDR4-3200 A-XMP.
   - [ ] Stress-test it.
6. [ ] Add zram and optional emergency disk swap.
7. [ ] Enable RTKit and verify PipeWire realtime scheduling.
8. [ ] Test GameMode activation per launcher/title.
9. [x] Enable Resizable BAR.
   - [ ] Benchmark it.
10. [x] Recheck `amd_pstate` after the firmware update.
11. [ ] A/B test Zen versus the standard kernel only if useful.
12. [ ] Consider a 5700X3D if CPU-limited performance remains unsatisfactory.

## Research Questions for the Implementation Session

Keep follow-up research narrowly scoped to the specific implementation step:

- Exact Niri output-mode and VRR configuration and validation
- Appropriate NixOS zram and optional swap design
- RTKit and PipeWire integration
- GameMode testing and Steam invocation
- Resizable BAR and `amd_pstate` verification commands
- Whether to retain the Zen kernel
- Whether the global vkd3d-proton override remains appropriate
- Sunshine portal integration if streaming is unreliable
- Load temperatures and clocks under controlled benchmarks
- SMART health of the secondary SATA SSD if it is in active use

Do not fetch broad NixOS option indexes. Query only the exact options needed for the current implementation phase.
