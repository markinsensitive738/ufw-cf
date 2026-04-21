#!/usr/bin/env bash
# Install ufw-cf from this repository onto the local system.

set -euo pipefail

PREFIX="${PREFIX:-/usr/local}"
SYSCONFDIR="${SYSCONFDIR:-/etc}"
SYSTEMD_DIR="${SYSTEMD_DIR:-/etc/systemd/system}"

src_dir="$(cd "$(dirname "$0")" && pwd)"

if [ "$(id -u)" -ne 0 ]; then
    if command -v sudo >/dev/null; then
        exec sudo -E "$0" "$@"
    fi
    echo "install.sh must be run as root" >&2
    exit 1
fi

command -v ufw >/dev/null || { echo "ufw is not installed" >&2; exit 1; }
command -v curl >/dev/null || { echo "curl is not installed" >&2; exit 1; }

install -Dm0755 "$src_dir/bin/ufw-cf"              "$PREFIX/bin/ufw-cf"
install -Dm0644 "$src_dir/systemd/ufw-cf.service"  "$SYSTEMD_DIR/ufw-cf.service"
install -Dm0644 "$src_dir/systemd/ufw-cf.timer"    "$SYSTEMD_DIR/ufw-cf.timer"

if [ ! -e "$SYSCONFDIR/ufw-cf/config" ]; then
    install -Dm0644 "$src_dir/systemd/config.example" "$SYSCONFDIR/ufw-cf/config"
fi

install -d -m0755 /var/lib/ufw-cf

if command -v systemctl >/dev/null; then
    systemctl daemon-reload
fi

echo "ufw-cf installed to $PREFIX/bin/ufw-cf"
echo "Next steps:"
echo "  sudo ufw-cf sync       # add Cloudflare rules now"
echo "  sudo ufw-cf enable     # enable daily auto-update"
echo "  ufw-cf status          # show current state"
