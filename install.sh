#!/bin/sh
# Downloads the versioned installer and verifies its published SHA256 before execution.
set -eu
case "${1:-}" in
    -h|--help) printf '%s\n' 'DGX Spark interactive installer / 交互式安装' 'sudo sh install.sh [--lang zh|en] [--dry-run] [--yes] [--mode auto|full|performance]' 'Requires Linux ARM64, Python 3.12, curl and sha256sum. Default mode: native automatic.'; exit 0 ;;
esac
[ "$(uname -s)" = Linux ] || { echo 'Requires Ubuntu / DGX OS Linux' >&2; exit 1; }
case "$(uname -m)" in aarch64|arm64) ;; *) echo 'Requires ARM64' >&2; exit 1 ;; esac
[ "$(id -u)" -eq 0 ] || { echo 'Run with sudo' >&2; exit 1; }
for command in python3 curl sha256sum mktemp; do command -v "$command" >/dev/null || { echo "Missing: $command" >&2; exit 1; }; done
python3 -c 'import sys; assert sys.version_info[:2]==(3,12), "Python 3.12 is required"'
version=0.1.1
base="https://github.com/pandamask2023/dgx-spark-fan-control-suite/releases/download/v$version"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT HUP INT TERM
curl --fail --location --silent --show-error --proto '=https' --proto-redir '=https' "$base/SHA256SUMS" -o "$work/SHA256SUMS"
printf '%s\n' 'Downloading verified installer / 正在下载并校验安装向导'
curl --fail --location --progress-bar --show-error --proto '=https' --proto-redir '=https' "$base/sparkfan-install" -o "$work/sparkfan-install"
(cd "$work"; python3 -c 'import hashlib,re,pathlib; lines=pathlib.Path("SHA256SUMS").read_text().splitlines(); hashes=[m[1].lower() for line in lines if (m:=re.fullmatch(r"([0-9a-fA-F]{64}) [ *]sparkfan-install",line))]; assert len(hashes)==1 and hashlib.sha256(pathlib.Path("sparkfan-install").read_bytes()).hexdigest()==hashes[0], "Installer SHA256 mismatch"')
chmod 700 "$work/sparkfan-install"
"$work/sparkfan-install" "$@"
