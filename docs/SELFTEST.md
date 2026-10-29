# Self-checks / 自检

Version 0.1.3 is an experimental preview. Self-checks report evidence at distinct levels; a pass is not a full-load or lifespan guarantee.

| Command / 入口 | Action / 行为 |
| --- | --- |
| `sudo sparkfan self-test [--json]` | Read-only environment, identity, token-permission, API and fresh sensor checks; does not load modules or change modes |
| Web “只读自检 / Read-only self-check” | Authenticated status, freshness, firmware evidence and control eligibility; no root configuration/token inspection |
| `GET /api/v1/self-test` | Same authenticated read-only Web checks; no probe/control query flag is accepted as an action |
| `sudo sparkfan self-test --probe --json` | Explicit temporary read-only protocol module: capability/upper/lower queries only; requires a recognized profile, matching identity, a trusted usable module, verified automatic mode, no active override or pending operation; unloads its own probe afterwards |
| `sudo sparkfan self-test --control --json` | Explicit bounded full-speed test, with independent restoration guardian, fresh RPM/duty/physical-temperature checks and automatic restoration; current qualified EC/SoC only; starts only from verified automatic mode |

Default self-checks preserve the mode. `--probe` and `--control` cannot be combined. The controlled test asks for confirmation; unattended use requires `--yes`. Hold duration defaults to 3 seconds and is bounded to 1–10 seconds using `--seconds`. Transitions and cleanup take additional time. A systemd guardian is armed before the full-speed request and disables/stops the owned full-speed unit after 75 seconds if cleanup is interrupted. Active full/performance modes, legacy controllers and unqualified combinations are refused. No firmware, power, clocks, keys or boot settings are changed.

`--control` is an opt-in hardware operation, not part of installation or default diagnostics. This release tests its success and failure handling using isolated fixtures; it does not claim a new live full-speed cycle on each firmware/kernel or any production fleet upgrade.

JSON reports include `kind`, `policy_write_performed`, `monitoring_checks_passed`, `control_test_verified`, `checks` and `firmware_evidence`. Controlled reports separately include `restoration_verified` and guardian state. Diagnostics redact device identities and never read or return token contents. CLI exit status is 0 for passing checks (warnings can remain), 2 for failed checks, 1 for execution/refusal errors. A warning/skip is not hardware-control certification.

新增识别的六个历史 EC 版本仅具备官方签名镜像与离线指令回放证据，RAM/主机路径和 RPM 可信度尚未实机资格验证。只读探测匹配也不会自动解锁控速。历史回报有估算分支，不能用软件回报自行证明真实机械 RPM。未知 EC 不进行探测或控制写入，仍可监测系统可用传感器。

可以在安装前只做环境诊断：将一键命令末尾改为 `| sudo sh -s -- --self-test`。此命令仍需下载已校验原生诊断程序，但不安装主软件包；未配置设备会明确跳过 API/身份/令牌检查。
