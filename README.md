# fcgminer - CGMiner for FreeBSD with Scrypt ASIC Support

CGMiner 4.8.1-freebsd with Zeus, GridSeed, and Lketc Scrypt ASIC driver
support. This is a FreeBSD-focused fork with build fixes and a distinct
user-agent string.

For the full lineage of this codebase, see [FORK-HISTORY.md](FORK-HISTORY.md).

For general CGMiner information refer to doc/README.

## Supported Hardware

- **Zeus / ZeusMiner / GAW Fury** -- Scrypt ASIC (6+ chips, CP2102 USB)
- **GridSeed** -- Dual-mode SHA256+Scrypt ASIC
- **Lketc** -- Budget Scrypt ASIC sticks (CP2103 USB, 1-2 chips)

## Building on FreeBSD

	pkg install autoconf automake libtool pkgconf curl

	git clone https://github.com/tuaris/fcgminer.git
	cd fcgminer

	./autogen.sh
	./configure --enable-scrypt --enable-zeus --without-curses
	gmake

## Usage Examples

Zeus/GAW Fury (6 chips, 328 MHz) via serial:

	./cgminer --scrypt --zeus-chips 6 --zeus-clock 328 \
		--zeus-nocheck-golden \
		--scan-serial zeus:/dev/cuaU0 \
		-o stratum+tcp://pool:port -u wallet.worker -p x

Lketc stick (1 chip, 280 MHz):

	./cgminer --scrypt --lketc-clock 280 \
		--scan-serial lketc:/dev/cuaU0 \
		-o stratum+tcp://pool:port -u wallet.worker -p x

Mixed Zeus + Lketc:

	./cgminer --scrypt --zeus-chips 6 --zeus-clock 328 --lketc-clock 280

## Zeus Driver Options

```
  --zeus-chips <n>        Number of chips per device (default: 6)
  --zeus-clock <MHz>      Chip clock speed in MHz (default: 328)
  --zeus-options <ID>,<chips>,<clock>[;<ID>,<chips>,<clock>...]
                          Per-device chip count and clock settings
  --zeus-nocheck-golden   Skip golden nonce verification during init
  --zeus-debug            Extra driver debug output in verbose mode
```

## Lketc Driver Options

```
  --lketc-clock <MHz>     Default chip clock speed (default: 280)
  --lketc-options <ID>,<chips>,<clock>[;<ID>,<chips>,<clock>...]
                          Per-device chip count and clock settings
  --lketc-nocheck-golden  Skip golden nonce verification during init
  --lketc-debug           Extra driver debug output in verbose mode
```

## Notes

- On FreeBSD, USB serial devices appear as `/dev/cuaU0`, `/dev/cuaU1`, etc.
- The `--zeus-nocheck-golden` flag is recommended for GAW Fury devices
  that fail the golden nonce timing test but mine correctly.
- This fork reports user-agent `cgminer/4.8.1-freebsd` to stratum pools.
