# DGX Spark 风扇控制套件

[English](README.md) | [简体中文](README.zh-CN.md)

提供 Web、鉴权 API、CLI 和 mTLS 持久管理通道。公开仓库仅放使用说明和最小安装入口；Web/API/CLI、安装向导以 ARM64 原生二进制发行，不在仓库公开实现源码。内核驱动仅提供 GPL 要求的对应源码。

## 一条命令下载安装

在受支持的 DGX Spark 上执行：

```sh
curl -fsSL https://github.com/pandamask2023/dgx-spark-fan-control-suite/releases/download/v0.1.2/install.sh | sudo sh
```

进入交互式向导后，可选中英文、初始风扇模式和本机 CLI 账户；通过兼容性检查、展示安装计划并确认后才安装。**默认自动模式。** 键盘输入从终端读取，管道下载不会吞掉选项。入口先核对原生安装向导 SHA256，向导再验证软件包后交给 APT。

只预览、不安装：

```sh
curl -fsSL https://github.com/pandamask2023/dgx-spark-fan-control-suite/releases/download/v0.1.2/install.sh | sudo sh -s -- --lang zh --dry-run
```

预览不会下载主软件包、安装或切换模式。本套件可在已确认自动模式且无未决操作时升级，保留配置和令牌；正在控速或旧控制器会被保护，见[迁移说明](docs/MIGRATION.md)；缺少匹配内核 headers 时会在计划中说明并一并安装。不重启、不刷固件、不修改安全引导。APT 需要能访问系统配置的官方软件源。

## 控制与读数

- **自动模式**：释放覆盖，交回原厂温控。
- **全速模式**：请求最高目标，以真实反馈确认。
- **性能模式**：需要另行提供的本地私有组件；其源码和二进制均不在公开仓库或 Release 中。

```sh
sudo sparkfan status
sudo sparkfan full
sudo sparkfan auto
sudo sparkfan performance   # 需要私有组件
sudo sparkfan doctor
```

回传逐只风扇真实 RPM、Linux thermal 框架中可读物理传感器最高温度，以及来源、有效性和采样时间。切换模式不掩盖仍可读取的转速；读不到时返回空值。受理请求不等于目标已生效，必须等待实际确认。

Web 默认 `http://127.0.0.1:8797/`，仅本机监听。运行 `sudo sparkfan token` 查看访问令牌，安装器不会自动打印令牌。[API 文档](docs/API.md)。

## 支持范围与许可

独立实验性实现，不是 NVIDIA 官方产品。硬件仍要求 NVIDIA DGX Spark P4242、Linux ARM64、APT/systemd，但不再卡死某个 BIOS、内核或 Python 小版本。

- **Python**：同一套原生 `abi3` 模块已在 CPython 3.10、3.11、3.12、3.13、3.14 验证，覆盖旧版系统网络库。要求标准 CPython 3.10+；不支持 free-threaded 版本，未测试的新小版本只开放监测。
- **内核**：已在 NVIDIA `6.11.0-1014`、`6.17.0-1014`、`7.0.0-1019` 编译通过。DKMS 根据当前内核构建，写入任何控制策略前先做协议自检；不把编译通过当作每个内核都已实机全速验证。
- **BIOS**：按本机识别并在加载时绑定，不再固定 `5.36_0ACUM028`。
- **EC/SoC**：目前主动控速仍核验 EC `3.13.7`／SoC `2.158.15` 及对应 FF-A 协议；其他或无法读取的固件版本可以安装监测，但不开放未知协议写入。
- **安全引导／签名**：不再阻止安装监测；主动控速须使用内核认可的可信模块，不会自动关安全引导或注册密钥。

[兼容详情](docs/COMPATIBILITY.md)。必要硬件或原生 ABI 不匹配仍会停止安装；控速未通过检查时保留监测，不承诺通用硬件、满载性能或长期寿命验证。

用户态二进制闭源发行。GPL-2.0-only 内核驱动的源码、构建文件和许可证按要求随 Release 的 kernel-source 归档及 DKMS 包提供。第三方许可、旧版已授予的开源许可不受影响。见[许可说明](LICENSE)。

安装包与校验文件见 [Releases](https://github.com/pandamask2023/dgx-spark-fan-control-suite/releases)；问题与建议请提交 [Issues](https://github.com/pandamask2023/dgx-spark-fan-control-suite/issues)。卸载用 `sudo apt remove dgx-spark-fan-control`，仅 `apt purge` 会清理保存的配置。
