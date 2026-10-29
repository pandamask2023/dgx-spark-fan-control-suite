# DGX Spark Fan Control Suite

[English](README.md) | [简体中文](README.zh-CN.md)

Installable DGX Spark fan control with Web, authenticated API, CLI and persistent mTLS management. This public repository contains documentation and a small installation entry point. User-space components are distributed as native ARM64 binaries; their implementation source is not published here. Only the kernel driver's required GPL source is supplied separately.

## One-command installation

Run on a supported DGX Spark:

```sh
curl -fsSL https://github.com/pandamask2023/dgx-spark-fan-control-suite/releases/download/v0.1.3/install.sh | sudo sh
```

The interactive terminal wizard offers English/Chinese, verifies compatibility, shows the selected mode and local CLI account, and asks before installing. **Automatic is the default.** Input comes from the terminal, so piping the command does not consume your menu answers. The entry point verifies the native installer's SHA256; the installer verifies the package before APT runs.

To preview only:

```sh
curl -fsSL https://github.com/pandamask2023/dgx-spark-fan-control-suite/releases/download/v0.1.3/install.sh | sudo sh -s -- --lang en --dry-run
```

Preview does not download the core package, install it or change fan modes. An existing owned suite can upgrade while verified in automatic mode with no pending transition; settings and token are preserved. Active or legacy controllers are protected; see [migration guidance](docs/MIGRATION.md). Missing matching kernel headers are included in the reviewed installation plan. No reboot, firmware flash or Secure Boot change is performed. APT needs access to the official configured system repositories.

## Self-checks

The installer runs a read-only self-check after setup. The authenticated Web dashboard also has a **Read-only self-check** button.

```sh
sudo sparkfan self-test
sudo sparkfan self-test --json
```

Checks environment, firmware evidence, configured identity, token permissions, authenticated API and reading freshness. It does not load a module or switch modes. Firmware 3.5.8, 3.3.2, 2.78.24, 2.78.18, 2.75.3 and 2.66.3 are recognized from signed vendor-image analysis, and remain monitoring-only. Historical firmware can report estimated RPM; those readings are not certified as mechanical tachometer measurements. See [self-check levels and explicit tests](docs/SELFTEST.md).

## Controls and readings

- **Automatic:** releases the override and returns cooling to firmware.
- **Full speed:** requests the maximum target and verifies actual feedback.
- **Performance:** available only with a separately supplied private local companion. Neither its source nor its binary is in this public repository or release.

```sh
sudo sparkfan status
sudo sparkfan full
sudo sparkfan auto
sudo sparkfan performance   # requires the private companion
sudo sparkfan doctor
```

Reports actual per-fan RPM and the maximum available physical Linux thermal reading, with source, validity and sample time. A mode transition does not hide an otherwise valid tachometer reading. Missing readings are null. An accepted request is not reported as physically applied until confirmation succeeds.

Web: `http://127.0.0.1:8797/`, loopback only. Run `sudo sparkfan token` locally to view the access token; the installer does not print it automatically. [API documentation](docs/API.md).

## Scope and license

Experimental, independent software; not an NVIDIA product. Hardware remains NVIDIA DGX Spark P4242 on Linux ARM64 with APT/systemd. The installer no longer requires one exact BIOS, kernel or Python minor version.

- **CPython:** 3.10–3.14 tested using the same native `abi3` modules, including older distribution networking libraries. Regular CPython 3.10+ is required; free-threaded builds are not supported. Future untested minors are monitoring-only.
- **Kernel:** compiled for NVIDIA `6.11.0-1014`, `6.17.0-1014`, and `7.0.0-1019`; DKMS builds for the running kernel, rather than an exact-version allowlist. Protocol self-checks precede any control write. Compilation is not a full-speed hardware test on each kernel.
- **BIOS:** its identity is captured locally and bound when loading; it is not hardcoded to `5.36_0ACUM028`.
- **EC/SoC:** active control currently qualifies EC `3.13.7` / SoC `2.158.15` and the expected FF-A protocol. Other/missing firmware versions remain installable for monitoring, with control disabled.
- **Secure Boot/signatures:** monitoring can install without disabling security. Active control requires an accepted trusted module; the installer does not enroll keys or change Secure Boot.

[Compatibility details](docs/COMPATIBILITY.md). No full-load or long-term lifespan guarantee is made.

User-space binaries are proprietary. The GPL-2.0-only kernel source/build files and license are provided in the Release's kernel-source archive and in the DKMS package as required. Third-party licenses and permissions granted by earlier source releases remain unaffected. See [license notices](LICENSE).

Download packages and checksums from [Releases](https://github.com/pandamask2023/dgx-spark-fan-control-suite/releases). Report problems or request features in [Issues](https://github.com/pandamask2023/dgx-spark-fan-control-suite/issues). Remove with `sudo apt remove dgx-spark-fan-control`; saved configuration is removed only by `apt purge`.
