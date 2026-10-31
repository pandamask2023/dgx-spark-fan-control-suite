# DGX Spark 风扇控制套件

[English](README.md) | [简体中文](README.zh-CN.md)

提供 Web、鉴权 API、CLI、真实风扇 RPM 和最高物理温度。0.2.0 起，专有用户态的全速／性能控速使用付费激活码；用户态实现以 ARM64 原生二进制发行。公开仓库保留文档、最小安装入口和 GPL 要求的内核对应源码。

## 一条命令下载安装

```sh
curl -fsSL https://github.com/pandamask2023/dgx-spark-fan-control-suite/releases/download/v0.2.0/install.sh | sudo sh
```

交互式向导支持中英文、初始模式和本机 CLI 账户。默认原厂自动模式；未激活可监测和自检，也可随时交回自动温控。入口验证 SHA256，APT 负责依赖安装。不重启、不刷固件、不自动修改安全引导。

```sh
# 只预览，不下载主包、不安装、不切换模式
curl -fsSL https://github.com/pandamask2023/dgx-spark-fan-control-suite/releases/download/v0.2.0/install.sh | sudo sh -s -- --lang zh --dry-run
```

升级前须确认已有本套件处于自动模式，无覆盖、无未决操作；保留配置、访问令牌和授权。旧独立控制器会被保护，见[迁移说明](docs/MIGRATION.md)。

## 激活与账户

账户与授权中心：**[us.privetm.com/sparkfan](https://us.privetm.com/sparkfan/)**。通过邮箱验证码注册／登录，绑定已有购买码；管理员可设置每码有效天数、发码并查看在线上报状态。支付接口已预留，尚未接入付款渠道或公布售价。

1. 安装后打开本机 Web，登录并输入购买的 `SFA1-...` 激活码，或使用 CLI。
2. **首次激活必须联网。联网时约每 15 秒同步一次使用状态；离线后可继续用到签名授权的有效期。** 重启不要求重新联网。
3. 换机时旧设备必须在线。用户确认踢出后，旧设备先保存撤销记录、释放控速并确认，服务器随后才授权新设备。旧设备离线或未确认退出时，新设备不能抢占。

```sh
sudo sparkfan license status
sudo sparkfan license activate
# 无交互方式，避免激活码进入命令历史；购买码文件请 chmod 600
sudo sparkfan license activate --file /path/to/purchase-code.txt
```

仅发送派生设备码、设备公钥、软件版本、控速模式和心跳；原始序列号／UUID、模型数据和本机 API 令牌不上传。网站对离线设备显示最后上报时间，在线控速时长按连续心跳估算，不补算离线使用。授权到期或设备被踢出后保留真实读数和原厂自动散热。

授权凭证与本机设备私钥共同绑定安装。重装／清除配置前，应安全备份 `/var/lib/dgx-spark-fan-control/`；仅 `apt purge` 会清理保存状态。丢失设备私钥不能仅凭公开设备码冒充旧机。详见[激活与换机](docs/ACTIVATION.md)。

## 控制、读数和自检

```sh
sudo sparkfan status
sudo sparkfan full         # 需有效授权
sudo sparkfan auto         # 随时释放覆盖
sudo sparkfan performance  # 还需另行提供的私有组件
sudo sparkfan self-test --json
sudo sparkfan doctor
```

Web 默认 **`http://127.0.0.1:8797/`**，仅本机监听。`sudo sparkfan token` 查看访问令牌；访问令牌用于登录，购买码用于激活，二者不同。Web/API/CLI 和后台控制器统一检查授权，激活本身不切换模式。[API 文档](docs/API.md)。

逐只返回 RPM、来源、有效性、采样时间和物理传感器最高温度；不可读取的数据返回空值。受理请求不等于目标已生效，必须等实际反馈。默认自检只读，不加载模块、不切换模式；见[自检说明](docs/SELFTEST.md)。

## 兼容性和许可

独立实验性实现，非 NVIDIA 官方产品。硬件要求 DGX Spark P4242、Linux ARM64、APT/systemd、标准 CPython 3.10+；不支持 free-threaded Python。DKMS 使用当前内核 headers，主动控速仍核验 EC `3.13.7`／SoC `2.158.15` 和协议；历史 EC 只监测。安全引导开启时，控速需内核认可的可信模块。

前版 ABI 及内核兼容证据继续保留；0.2.0 的授权功能以本版实测回归为准，不把前版测试数量当成本版结果。见[兼容详情](docs/COMPATIBILITY.md)。不承诺通用硬件、绝对防破解、满载性能或长期寿命已经验证。

私有性能算法和组件不在 GitHub。GPL 内核组件的对应源码、构建文件与许可证随 kernel-source 归档和 DKMS 包提供；旧版已授予的许可不变。[许可](LICENSE)。

[下载 Releases](https://github.com/pandamask2023/dgx-spark-fan-control-suite/releases) · [反馈 Issues](https://github.com/pandamask2023/dgx-spark-fan-control-suite/issues)。卸载：`sudo apt remove dgx-spark-fan-control`。
