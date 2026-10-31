# Activation, offline validity and device transfer

English | 简体中文

Account portal: https://us.privetm.com/sparkfan/

Version 0.2.0 requires a purchased code for proprietary full-speed/performance controls. Monitor, diagnostics, native automatic cooling and GPL kernel rights remain available without purchase. Payment integration is not enabled.

首次联网激活。联网时每约15秒上报设备状态；断网可继续使用到签名凭证的有效期。原厂自动温控和读数不依赖付费授权。每码天数由管理员发码时设置，首次激活开始计算；重新兑换、重启和换机不延长原有效期。

## API and CLI

```text
GET  /api/v1/license
POST /api/v1/license/activate
{"activation_code":"SFA1-<purchased-code>"}
```

Use the existing local bearer token or cookie/CSRF authentication. This application access credential differs from the purchased activation code. A conflict returns `TRANSFER_CONFIRM_REQUIRED` when the old installation is online, or `OLD_DEVICE_OFFLINE` when it cannot transfer. After explicit confirmation:

```text
POST /api/v1/license/activate
{"activation_code":"SFA1-<purchased-code>","confirm_transfer":true}
```

An `ok` response with `license.transfer_pending: true` only means that transfer is waiting; it does not unlock control. Retry to obtain the new credential after the old device acknowledges. The Web UI and interactive CLI ask for confirmation and wait for this process.

```sh
sudo sparkfan license device
sudo sparkfan license status
sudo sparkfan license activate
sudo sparkfan license activate --file /path/to/purchase-code.txt
```

CLI supports secure terminal prompts and owner-only input files. No purchase code or full signed credential is echoed. Activation does not switch the fan mode.

## Transfer protocol / 换机

1. The new device proves possession of its installation key and presents the purchase code online.
2. The server checks a fresh, signed heartbeat from the old installation. A copied public fingerprint cannot mark that device online.
3. The user confirms signing out the old device. The server creates a pending transfer without issuing a new credential.
4. The old installation durably records revocation, stops proprietary control and verifies native automatic cooling. It then signs an acknowledgement with its installation key.
5. Only after the server commits this acknowledgement does it issue a higher-generation entitlement for the new installation, with the original expiry.

旧设备失联、释放控速失败、未持久化撤销或未确认时，新设备保持未激活。心跳和确认携带随机nonce及时间戳签名，服务器拒绝重放。授权转移在数据库事务内处理，防止并发双发。

## Local data and limitations / 本地数据与边界

Back up the entire `/var/lib/dgx-spark-fan-control/` securely before reinstall/purge: it contains the signed credential, installation private key and durable revocation/time state. These are mode 0600; the private key never leaves the device. The server has a separate private signing key and stores only a hash of each random purchase code. Losing the device key is not a reason to bypass the old-device-online transfer requirement.

网站使用邮箱验证码注册/登录。管理员账号为部署时指定的邮箱，只有验证该邮箱后才能访问发码面板。客户只能查看绑定自己账户的授权；完整购买码发放时仅显示一次。在线控速时长按连续心跳估算，离线间隔不计入；离线设备只显示最后上报，无法实时观测。

The signed expiry is enforced locally even without a network. Running processes use a monotonic time anchor and saved server-time floor to resist casual clock rollback. Full privileged state rollback, modified binaries, copied device secrets or spoofed hardware/RTC cannot be absolutely prevented without a stronger trusted-hardware design. Do not promise root-resistant DRM or immediate revocation of a device that never receives a transfer command.

At expiry/revocation, the suite releases its override through the existing verified native-auto path. Firmware thermal protection remains active. Unknown firmware stays monitoring-only; licensing never bypasses compatibility or signature checks.
