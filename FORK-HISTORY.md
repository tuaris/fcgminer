# Fork Chain Audit: cgminer to fcgminer

This document traces the code evolution from the original cgminer through
each descendant fork to this repository (fcgminer).

## 1. ckolivas/cgminer v4.8.0 (Base)

The original cgminer by Con Kolivas. SHA256/Bitcoin-only ASIC miner.

- **Version**: `4.8.0`
- **Algorithm**: SHA256d only, no Scrypt support
- **Drivers**: Antminer S1/S2, Avalon, Avalon2, BAB, BFLSC, BitForce,
  BitFury, Bitmine A1, BlockErupter, Cointerra, Drillbit, Hashfast,
  Hashratio, Icarus, Klondike, KnC, Minion, ModMiner, SP10, SP30
- No GridSeed, Zeus, or Lketc drivers
- No `--enable-scrypt` configure flag
- No FreeBSD case in `configure.ac` target detection

## 2. csa402/cgminer-dmaxl (First Scrypt Fork)

The foundational Scrypt fork. Backported to cgminer v4.3.5 (not v4.8.0),
adds Scrypt algorithm and Zeus/GridSeed ASIC drivers.

- **Version**: `4.3.5-scrypt.2`
- **Key additions**:
  - `--enable-scrypt` configure flag with `USE_SCRYPT` define
  - `scrypt.c` / `scrypt.h` -- Scrypt hashing implementation
  - `driver-zeus.c` / `driver-zeus.h` -- Zeus/ZeusMiner ASIC driver
    (CP2102 + FT232R USB-UART)
  - `driver-gridseed.c` / `driver-gridseed.h` -- GridSeed dual-mode
    (SHA256+Scrypt) ASIC driver
  - Both drivers support USB (libusb) and serial detection paths
  - Golden nonce calibration for timing (speed per core calculation)
  - `--zeus-chips`, `--zeus-clk`, `--zeus-options`,
    `--zeus-nocheck-golden` CLI flags
- **Zeus driver constants**:
  - `ZEUS_CLK_MIN = 2` (very permissive minimum)
  - `ZEUS_CLK_MAX = 382`
  - `ZEUS_MIN_CHIPS = 6`
  - `ZEUS_MAX_CHIPS = 1024`
- Drivers default to enabled (`gridseed="yes"`, `zeus="yes"`)

## 3. wareck/cgminer-lketc (Lketc + v4.8.0 Rebase)

Major rebase to cgminer v4.8.0 plus addition of the Lketc driver. This
is the most significant fork in the chain.

- **Version**: `4.8.0-scrypt-wrk`
- **Key changes from csa402**:
  - Rebased onto cgminer v4.8.0 (from 4.3.5), bringing all upstream
    improvements, API changes, and build system updates
  - Added `driver-lketc.c` / `driver-lketc.h` -- separate driver for
    cheaper Lketc USB Scrypt ASIC clones
  - Added FreeBSD support in `configure.ac` target case:
    `*-*-freebsd*)` with `PTHREAD_FLAGS=""`, `DLOPEN_FLAGS=""`,
    `RT_LIBS=""`
  - Added `-fcommon` CFLAGS for GCC 10+ (Raspberry Pi Bullseye compat)
  - Commented out `_WIN32_WINNT` define (was causing issues)
  - Added `--enable-lketc` configure flag (default enabled)
- **Lketc vs Zeus driver differences**:
  - `LKETC_MIN_CHIPS = 1` (vs Zeus `6`) -- single-chip devices
  - `LKETC_MAX_CHIPS = 2` (vs Zeus `1024`) -- smaller devices
  - `LKETC_CLK_MIN = 200`, `LKETC_CLK_MAX = 320` -- different range
  - `LKETC_USB_ID_MODEL_STR1 = "CP2103..."` (CP2103, not CP2102)
- **Zeus driver constant change**: `ZEUS_CLK_MIN` raised from `2` to
  `328` (more realistic default for GAW Fury hardware)
- **Commit history**: wareck's first commit (Nov 9, 2022) was a squashed
  import of the full rebased codebase, followed by incremental fixes
  through Jan 2023 (bump to 4.8.0) and many README updates

## 4. TheRetroMike/cgminer-zeus (RPi Installer)

Minimal changes, purely an RPi convenience layer by user 05sonicblue
(Aug 23, 2024).

- **Version**: Same `4.8.0-scrypt-wrk` (no version change)
- **Only 2 changes**:
  1. Added `rpi-installer.sh` -- shell script that installs deps and
     builds on Raspberry Pi
  2. Updated `README.md` -- added "Quick RPI Installation" section with
     curl one-liner
- No code changes to any C source, headers, configure.ac, or Makefile.am
- No functional differences from wareck/cgminer-lketc

## 5. tuaris/fcgminer (FreeBSD Fork)

Built on top of TheRetroMike's fork. Our changes:

- **Version**: `4.8.1-freebsd`
- **Changes**:
  1. Removed RPi-specific files (`rpi-installer.sh`, README Quick Install
     section)
  2. Fixed FreeBSD build bug in `util.c`: `tv->tv_sec` changed to
     `tv.tv_sec` (struct member access, not pointer dereference)
  3. Bumped version to `4.8.1-freebsd` for distinct user-agent
     identification

## Summary

| Fork | Base | Version | Key Contribution |
|------|------|---------|-----------------|
| ckolivas | -- | 4.8.0 | Original SHA256 miner |
| csa402 | cgminer 4.3.5 | 4.3.5-scrypt.2 | +Scrypt, +Zeus, +GridSeed |
| wareck | cgminer 4.8.0 | 4.8.0-scrypt-wrk | Rebase to 4.8.0, +Lketc, +FreeBSD case, +GCC10 fix |
| TheRetroMike | wareck | 4.8.0-scrypt-wrk | +RPi installer script only |
| tuaris/fcgminer | TheRetroMike | 4.8.1-freebsd | -RPi files, +FreeBSD build fix, +version bump |

The real heavy lifting was done by csa402 (Scrypt + Zeus + GridSeed) and
wareck (v4.8.0 rebase + Lketc + FreeBSD configure support). TheRetroMike
added nothing functional.
