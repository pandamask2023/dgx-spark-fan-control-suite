# Compatibility / 兼容说明

The application, kernel build and active-control protocol are independent checks. A different software version does not automatically reject the whole application.

| Layer | Installation/monitoring | Active control |
| --- | --- | --- |
| Hardware | NVIDIA DGX Spark P4242, Linux ARM64, local DMI identity | Identity must match again before control |
| Python | Regular CPython 3.10+, native stable ABI; tested 3.10–3.14 | Untested future minors remain monitoring-only |
| OS | APT/systemd with compatible distribution dependencies | No OS-brand version allowlist |
| Linux | Matching headers are used when building control | Driver must build and pass its read-only protocol checks before applying a target |
| BIOS | Locally observed identity, no fixed BIOS revision | Identity bound to that load; firmware protocol still checked |
| EC/SoC | Unknown/missing entries allow monitoring | Current adapter: EC 3.13.7 / SoC 2.158.15; other protocols are not qualified |
| Module signing | Security enforcement does not block monitoring | Kernel must accept the module; a signer string alone is not proof of trust |

The same ABI3 binaries were exercised on Python 3.10.22 / 3.11.18 / 3.12.3 / 3.13.18 / 3.14.10. Networking-library checks include aiohttp 3.8.1 / 3.8.4 / 3.9.1 and current 3.x, with websocket-client 1.2.3 / 1.7.0 and current 1.x. This does not claim every distribution or every dependency combination was boot-tested.

Kernel builds: 6.11.0-1014-nvidia, 6.17.0-1014-nvidia, 7.0.0-1019-nvidia. The 6.11 header-path difference is handled by feature detection. Only the running 7.0 target received the additional inactive hardware probe: identity rejection, actual tachometers, inactive override and clean unload; no policy was written and the production mode/process/boot were preserved. No full-speed switch or reboot was used for this release qualification.

`sudo sparkfan doctor` reports `monitor_supported`, `control_available`, `control_reasons`, the running kernel and module readiness. `control_available` means an operation may attempt protocol verification; actual application is still determined by the operation result and `control_verified`.

Unknown firmware does not trigger an experimental write, a downgrade, a reboot, or changes to GPU power/clocks. Real RPM/temperature reads continue independently. Failed reads remain null. Submit redacted version information through Issues if an adapter is missing; do not include tokens, passwords, private keys, serials or UUIDs.

已有本套件：仅在已确认自动模式、未加载覆盖且无未决请求时允许升级，保留令牌与设置；全速/性能运行中不会擅自切模式。旧的独立控制器仍按迁移说明保护退出。四台现有生产设备未被本发行替换或重启。
