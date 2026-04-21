#!/usr/bin/env bash
# Install ufw-cf from the latest GitHub release.
# Usage:
#   curl -sSL https://ufw-cf.sdev.lk/install.sh | sudo bash
#   curl -sSL https://github.com/Malith-Rukshan/ufw-cf/releases/latest/download/install.sh | sudo bash

set -euo pipefail

REPO="${UFW_CF_REPO:-Malith-Rukshan/ufw-cf}"
API="https://api.github.com/repos/${REPO}/releases/latest"
RELEASES="https://github.com/${REPO}/releases"

err() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
info() { printf '==> %s\n' "$*"; }

command -v curl >/dev/null || err "curl is required"

if [ "$(id -u)" -ne 0 ]; then
    if command -v sudo >/dev/null; then
        exec sudo -E bash "$0" "$@"
    fi
    err "this installer must run as root"
fi

info "Looking up the latest ufw-cf release…"
tag="$(curl -fsSL "$API" \
    | sed -nE 's/.*"tag_name":[[:space:]]*"([^"]+)".*/\1/p' \
    | head -n1)"
[ -n "$tag" ] || err "could not find the latest release at $RELEASES"
# Strip any leading non-digit prefix (handles "v1.0.0", "v.1.0.0", "release-1.0.0", etc).
version="$(printf '%s' "$tag" | sed -E 's/^[^0-9]+//')"
[ -n "$version" ] || err "could not parse version from tag: $tag"

deb_name="ufw-cf-${version}-all.deb"
deb_url="${RELEASES}/download/${tag}/${deb_name}"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

info "Downloading $deb_name"
curl -fL -o "$tmp/$deb_name" "$deb_url" || err "download failed: $deb_url"

info "Installing with apt…"
if command -v apt >/dev/null; then
    apt install -y "$tmp/$deb_name"
elif command -v dpkg >/dev/null; then
    dpkg -i "$tmp/$deb_name" || apt-get -f install -y || true
else
    err "apt/dpkg not found — this installer only supports Debian/Ubuntu. Install from source: ${RELEASES}/latest"
fi

cat <<EOF

ufw-cf $tag installed.

  sudo ufw-cf sync       # add Cloudflare rules now
  sudo ufw-cf enable     # enable daily auto-update
  ufw-cf status          # show current state

Docs: https://github.com/${REPO}
EOF
