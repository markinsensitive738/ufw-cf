#!/usr/bin/env bash
# Remove ufw-cf from the local system.

set -euo pipefail

PREFIX="${PREFIX:-/usr/local}"
SYSCONFDIR="${SYSCONFDIR:-/etc}"
SYSTEMD_DIR="${SYSTEMD_DIR:-/etc/systemd/system}"

if [ "$(id -u)" -ne 0 ]; then
    if command -v sudo >/dev/null; then
        exec sudo -E "$0" "$@"
    fi
    echo "uninstall.sh must be run as root" >&2
    exit 1
fi

if command -v systemctl >/dev/null; then
    systemctl disable --now ufw-cf.timer 2>/dev/null || true
fi

if [ -x "$PREFIX/bin/ufw-cf" ]; then
    "$PREFIX/bin/ufw-cf" clean || true
fi

rm -f "$PREFIX/bin/ufw-cf"
rm -f "$SYSTEMD_DIR/ufw-cf.service"
rm -f "$SYSTEMD_DIR/ufw-cf.timer"

if command -v systemctl >/dev/null; then
    systemctl daemon-reload || true
fi

case "${1:-}" in
    --purge)
        rm -rf "$SYSCONFDIR/ufw-cf" /var/lib/ufw-cf
        echo "Removed config and state."
        ;;
esac

echo "ufw-cf uninstalled."
