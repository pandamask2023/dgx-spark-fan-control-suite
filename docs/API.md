# API v1

## Local Web / REST

Default: `http://127.0.0.1:8797`, loopback only. Every API request needs a bearer token or an authenticated browser cookie. Browser writes also require the CSRF value returned by `/api/v1/session`.

| Method | Path | Purpose |
|---|---|---|
| GET | `/api/v1/status` | Verified current mode, operation and measured telemetry |
| GET | `/api/v1/profile` | Supported-profile/module availability |
| POST | `/api/v1/mode` | `{mode, request_id}`; asynchronous accepted response |
| POST | `/api/v1/session` | `{token}`; HttpOnly session + CSRF |
| POST | `/api/v1/logout` | Revoke browser session |

Modes are `full`, `performance`, `auto`. Performance requires a separate private component; its computation, binaries and internal values are not distributed through this project.

Important status fields:

```json
{
  "effective_mode": "auto",
  "control_verified": true,
  "telemetry_valid": true,
  "fan_speeds_rpm": [2100, 2200],
  "max_system_temperature_c": 42.5,
  "max_system_temperature_sensor": {"zone": "thermal_zone0", "type": "SoC"},
  "temperature_valid": true,
  "temperature_sampled_at": 1700000000
}
```

The maximum is taken only from available physical Linux thermal sensors. Missing sensors are not claimed covered. No EC strategy input is used as a measured temperature. Failed readings are `null`, never a made-up zero.

An accepted write is not an applied write. Poll the operation with the same request ID until `succeeded`, then verify that `effective_mode` matches the desired mode and `control_verified` is true. Other terminal states are `failed` and `interrupted`. An in-flight request can return `BUSY`; reuse a UUID only when retrying that same action.

## Root broker

The privileged broker listens on `/run/dgx-spark-fan-control/control.sock`. It accepts one JSON line and returns one JSON line. Linux peer credentials and filesystem permissions restrict its callers. The Web/channel agents run without root and cannot submit arbitrary shell commands, paths, temperatures or PWM registers.

Requests include `v:1`, `action:status|set_mode`, and the local `node`, `serial`, `uuid` generated during configuration. Writes also include `mode` and `request_id`. Hardware identity is rechecked before action. The serial/UUID belongs in local configuration, not a public repository.

## Persistent channel

Protocol: WebSocket over TLS1.3 with a required client certificate. The hub pins each client certificate SHA256 to a device identity. The device agent also verifies the hub certificate/hostname. No plaintext or SSH fallback exists.

Hub private config schema:

```json
{
  "listen": "0.0.0.0", "port": 18896,
  "ca": "/private/ca.crt", "certificate": "/private/hub.crt", "key": "/private/hub.key",
  "unix_socket": "/private/hub.sock",
  "devices": {
    "spark-example": {
      "serial": "READ_FROM_DEVICE", "uuid": "READ_FROM_DEVICE",
      "certificate_sha256": "SHA256_OF_THAT_DEVICES_CERTIFICATE"
    }
  }
}
```

Device `/etc/dgx-spark-fan-control/channel.json`:

```json
{
  "identity": {"node":"spark-example", "serial":"READ_FROM_DEVICE", "uuid":"READ_FROM_DEVICE"},
  "fan_socket":"/run/dgx-spark-fan-control/control.sock",
  "urls":["wss://manager.example:18896/v1/fan-channel"],
  "ca":"/private/ca.crt", "certificate":"/private/device.crt", "key":"/private/device.key"
}
```

Provision a separate device certificate for each machine. CA certificates need proper v3 CA/basicConstraints/keyUsage/SKI/AKI; endpoint certificates need the intended clientAuth/serverAuth usage and the hub's DNS/IP SAN. Keep private keys owner-readable only, or group-readable only by the dedicated agent user. Never disable certificate validation to work around provisioning errors.

After the authenticated `hello` identity/boot handshake, the agent pushes sequenced `telemetry` frames every0.5s. The hub rejects non-increasing sequence numbers, duplicate JSON keys, non-finite numbers, wrong identities and stale telemetry. It expires disconnected/stale links instead of presenting them as current state. RPC request/reply correlation belongs to the active connection; pending commands fail on disconnect, and the caller can retry the original request UUID through a new connection.

The hub exposes a mode0600 local Unix API for management applications:

```json
{"v":1,"action":"status","host":"spark-example"}
```

Writes use `{v:1,action:"rpc",host,payload:<the identity-bound broker request>}`. Replies are `{v:1,ok:true,value:<broker reply>}` or a structured offline/protocol error. Python applications can use `dgx_fan.hub_client.status` and `set_mode`. Runtime reads and commands never spawn SSH. Setup/deployment tools are separate administrative operations.

The same measured RPM/maximum-temperature fields appear in local REST, CLI, Unix RPC and the persistent telemetry stream. Internal private-policy values are filtered recursively from public replies, including nested operation results.

API 1.3.1 reports tachometers independently of mode verification: a motor can have a fresh RPM reading while `effective_mode` is `unknown` during its normal ramp. `fan_speed_sensors` contains one entry per fan with `fan`, `rpm`, `valid`, `source` (`controller_ec_tachometer` or `acpi_tachometer`), `sampled_at` and `age_s`. `fan_speed_sampled_at` is the oldest available fan sample; `telemetry_valid` means both fan readings are valid. A partial result retains the valid fan and returns null for an unavailable one. No cached value is relabelled as a new measurement, and these fields never imply that a mode change succeeded.


## API 1.3.2 compatibility capabilities

Status adds a root-attested `capabilities` report: `monitor_supported`, `control_candidate`, `control_available`, `monitor_only`, `control_reasons`, `kernel`, `python_version`, module readiness and firmware profile. The Web profile endpoint uses this report, rather than authorizing control from a cached installation kernel number. A compiled module is checked by the kernel and the driver's inactive protocol/canary transaction before any policy is applied. `control_verified` remains the actual mode-feedback result, independent of compatibility and sensor validity. Local/REST/CLI/mTLS authentication and request idempotency are unchanged; runtime commands never fall back to SSH.
