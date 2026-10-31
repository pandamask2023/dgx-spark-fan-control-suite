# Web 总面板与自定义转速 / Web panel and custom RPM

需要 0.3.0 或更新版本。主页、账户、Web 总面板、本机 Web 分别独立；沿用液态玻璃界面。

- 网站：[Web 总面板](https://us.privetm.com/sparkfan/panel) · [配对指引](https://us.privetm.com/sparkfan/pairing)
- 设备激活后默认不连接 Web 总面板。已激活的本机 CLI、Web 和 API 可以独立使用。
- 登录网站，将购买码绑定到账户，在总面板为该授权生成一次性配对码。配对码有效期 5 分钟，只能用一次。
- 在设备上运行 `sudo sparkfan web-panel pair`，明确同意查看真实读数和远程控速，再输入配对码。本机 Web 也有同意复选框及配对表单。
- 设备通过签名 HTTPS 主动连接，不开放设备入站端口，不以 SSH 作为产品通信方式。

```sh
sudo sparkfan web-panel pair
sudo sparkfan web-panel status
sudo sparkfan web-panel disconnect
```

网站可控制原厂自动、性能、全速和自定义转速模式，显示两只风扇的真实 RPM、可读物理传感器最高温度及数据时效。设备离线时禁用远程指令，并隐藏过期读数；未及时收到的指令过期，不会在未来突然执行。断开配对保留当前本机模式。

## 转速标定与滑块

```sh
sudo sparkfan calibrate-rpm
sudo sparkfan rpm 3300
sudo sparkfan performance
sudo sparkfan full
sudo sparkfan auto
```

自定义转速需要有效授权和本机标定。标定约 6 分钟，会临时改变风扇转速，完成或失败后恢复之前模式；不重启，不改固件。标定只允许在设备较凉且反馈正常时开始。

滑块以**两只风扇的实测平均 RPM**为目标，同时分别显示两只风扇的读数。当前目标范围由本机标定决定，限制在 2500–4300 RPM；步进 50 RPM。原生档位附近可能使用最近可达稳定转速，API 同时提供请求值及实际有效目标。220 RPM 是平均值的稳定判定容差，不是每只风扇的绝对误差保证。只有持续收到真实反馈后才显示稳定。

反馈闭环在设备本地运行；断网后继续运行至授权有效期，高温保护可以提高转速。独立本地守护在控制器心跳或有效反馈丢失时释放本套件覆盖，交回原厂温控。物理温度读数不会被改写。这里没有公开私有策略的计算方式或内部输入。

DGX04 已验证四个目标及真实网站指令；这些是低负载条件下的有限时间测试，不代表满载性能、所有目标或长期寿命已经验证。

## English

Version 0.3.0 adds a separate, optional account Web panel. Activate locally, claim the purchase code in your account, create a five-minute one-use pairing code, then run `sudo sparkfan web-panel pair` on the device and explicitly consent. Pairing is off by default. Devices make signed outbound HTTPS requests; no inbound port or SSH product transport is used. Disconnecting the Web panel preserves local mode. Offline devices cannot receive commands; stale readings are hidden and pending commands expire.

Modes: native automatic, performance, full speed, and calibrated custom RPM. Run `sudo sparkfan calibrate-rpm` before using the slider. Calibration takes about six minutes, temporarily changes fan speed and restores the previous mode. Each device's qualified range is constrained to 2500–4300 RPM. The target is the measured mean of two fans, with individual tachometers shown separately. A nearby native level may be selected; `effective_target_rpm` reports it. The 220 RPM stability tolerance applies to the mean, not an absolute per-fan guarantee.

Feedback runs locally and continues offline until license expiry. Thermal protection may exceed the requested speed; an independent liveness guard releases the owned override if controller feedback is lost. Physical temperature readings remain unchanged. DGX04 qualification used bounded low-load tests, not full-load or lifetime certification. Private policy source and components are excluded from public GitHub assets.
