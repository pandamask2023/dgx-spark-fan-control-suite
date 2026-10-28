# DGX Spark Fan Control Suite

[English](README.md) | [简体中文](README.zh-CN.md)

Installable DGX Spark fan control with Web, authenticated API, CLI and persistent mTLS management. This public repository contains documentation and a small installation entry point. User-space components are distributed as native ARM64 binaries; their implementation source is not published here. Only the kernel driver's required GPL source is supplied separately.

## One-command installation

Run on a supported DGX Spark:

```sh
curl -fsSL https://github.com/pandamask2023/dgx-spark-fan-control-suite/releases/download/v0.1.1/install.sh | sudo sh
```

The interactive terminal wizard offers English/Chinese, verifies compatibility, shows the selected mode and local CLI account, and asks before installing. **Automatic is the default.** Input comes from the terminal, so piping the command does not consume your menu answers. The entry point verifies the native installer's SHA256; the installer verifies the package before APT runs.

To preview only:

```sh
curl -fsSL https://github.com/pandamask2023/dgx-spark-fan-control-suite/releases/download/v0.1.1/install.sh | sudo sh -s -- --lang en --dry-run
```

Preview does not download the core package, install it or change fan modes. Existing/legacy installations are left unchanged; see [migration guidance](docs/MIGRATION.md). Missing matching kernel headers are included in the reviewed installation plan. No reboot, firmware flash or Secure Boot change is performed. APT needs access to the official configured system repositories.

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

Experimental, independent software; not an NVIDIA product. Supported profile: NVIDIA DGX Spark P4242, BIOS `5.36_0ACUM028`, EC `3.13.7`, SoC `2.158.15`, NVIDIA ARM64 kernel `7.0.0-1019-nvidia`, Ubuntu/DGX OS with Python 3.12. Other profiles are rejected. No full-load or long-term lifespan guarantee is made.

User-space binaries are proprietary. The GPL-2.0-only kernel source/build files and license are provided in the Release's kernel-source archive and in the DKMS package as required. Third-party licenses and permissions granted by earlier source releases remain unaffected. See [license notices](LICENSE).

Download packages and checksums from [Releases](https://github.com/pandamask2023/dgx-spark-fan-control-suite/releases). Report problems or request features in [Issues](https://github.com/pandamask2023/dgx-spark-fan-control-suite/issues). Remove with `sudo apt remove dgx-spark-fan-control`; saved configuration is removed only by `apt purge`.
