# DGX Spark Fan Control Suite

[English](README.md) | [简体中文](README.zh-CN.md)

Web, authenticated API and CLI with actual fan RPM and maximum physical temperature. Version 0.2.0 introduces paid activation for proprietary user-space full-speed/performance controls. User-space implementation ships as ARM64 native binaries; this public repository contains documentation, the minimum installation entry, and required GPL kernel corresponding source.

## One-command installation

```sh
curl -fsSL https://github.com/pandamask2023/dgx-spark-fan-control-suite/releases/download/v0.2.0/install.sh | sudo sh
```

The bilingual interactive installer reviews compatibility, initial mode and local CLI access before installation. Native automatic cooling is the default. Monitoring, diagnostics and restoration of native cooling remain available without activation. The bootstrap verifies SHA256 and APT installs dependencies. No reboot, firmware flash or automatic Secure Boot changes.

```sh
curl -fsSL https://github.com/pandamask2023/dgx-spark-fan-control-suite/releases/download/v0.2.0/install.sh | sudo sh -s -- --lang en --dry-run
```

Owned upgrades require verified automatic mode with no override/pending operation; settings, token and authorization are preserved. Legacy controllers are protected. See [migration](docs/MIGRATION.md).

## Accounts and activation

**[Account and license portal](https://us.privetm.com/sparkfan/)**: register/sign in using an emailed verification code, claim purchase codes, and view reported status. Administrators set each code's duration, issue codes and inspect online usage. Payment integration is reserved but not enabled; pricing is arranged separately.

1. Sign in to the local Web UI and enter the purchased `SFA1-...` code, or use the CLI.
2. **First activation requires Internet. Connected devices synchronize usage status about every 15 seconds; disconnected devices continue until the signed authorization expires.** Reboots do not require another connection.
3. To transfer a used code, the old device must be online and the user must explicitly confirm signing it out. The old installation durably revokes its credential and verifies release to native cooling before the server issues the new credential. An offline or unacknowledged old installation blocks transfer.

```sh
sudo sparkfan license status
sudo sparkfan license activate
sudo sparkfan license activate --file /path/to/purchase-code.txt
```

Keep code files owner-only (`chmod 600`). The service receives a derived device fingerprint, installation public key, software version, control mode and heartbeats. Raw serial/UUID, model data and the local API token are not uploaded. Offline devices show their last report; sampled online control time excludes offline gaps.

Credentials bind both hardware and an installation key. Securely back up `/var/lib/dgx-spark-fan-control/` before reinstalling or purging. Normal upgrades retain it; `apt purge` removes saved state. A public fingerprint alone cannot impersonate the old device. See [activation and transfer](docs/ACTIVATION.md).

## Control, telemetry and self-check

```sh
sudo sparkfan status
sudo sparkfan full         # valid entitlement required
sudo sparkfan auto         # always permits release
sudo sparkfan performance  # also needs the separate private companion
sudo sparkfan self-test --json
sudo sparkfan doctor
```

The Web UI defaults to `http://127.0.0.1:8797/`, loopback only. Use `sudo sparkfan token` for the application access token; this differs from a purchase activation code. Web/API/CLI and direct controller startup enforce authorization. Activation itself does not change the mode. See [API](docs/API.md).

Telemetry includes per-fan RPM, source, validity and sample time, plus the highest readable physical temperature. Missing readings are null. Accepted requests require real feedback before being reported successful. Default self-check is read-only and loads no modules or modes; see [self-check](docs/SELFTEST.md).

## Compatibility and licensing

Independent experimental software, not an NVIDIA product. Requires DGX Spark P4242, Linux ARM64, APT/systemd and standard CPython 3.10+; free-threaded Python is unsupported. DKMS builds against matching headers. Active control still checks EC `3.13.7` / SoC `2.158.15` and protocol; historical firmware remains monitoring-only. Secure Boot control requires a trusted module.

Earlier ABI/kernel qualification remains recorded; version 0.2.0 licensing is assessed by its own regression evidence, not the preceding release's test count. See [compatibility](docs/COMPATIBILITY.md). Universal hardware, root-resistant DRM, full-load performance and long-term durability are not certified.

The private performance algorithm and companion stay absent from GitHub. Kernel GPL rights, corresponding source/build files and earlier granted licenses remain unchanged. See [LICENSE](LICENSE).

[Releases](https://github.com/pandamask2023/dgx-spark-fan-control-suite/releases) · [Issues](https://github.com/pandamask2023/dgx-spark-fan-control-suite/issues). Remove with `sudo apt remove dgx-spark-fan-control`.
