#!/usr/bin/env bash
# Build a .deb package for ufw-cf into ./dist/

set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

version="$(sed -n 's/^VERSION="\(.*\)"/\1/p' bin/ufw-cf)"
[ -n "$version" ] || { echo "could not determine version" >&2; exit 1; }

pkg="ufw-cf-${version}-all"
build="build/$pkg"
out="dist"

rm -rf "build" "$out"
mkdir -p "$out"

stage() {
    local mode="$1" src="$2" dst="$3"
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    chmod "$mode" "$dst"
}

stage 0755 bin/ufw-cf              "$build/usr/local/bin/ufw-cf"
stage 0644 systemd/ufw-cf.service  "$build/etc/systemd/system/ufw-cf.service"
stage 0644 systemd/ufw-cf.timer    "$build/etc/systemd/system/ufw-cf.timer"
stage 0644 systemd/config.example  "$build/etc/ufw-cf/config"
stage 0644 README.md               "$build/usr/share/doc/ufw-cf/README.md"
stage 0644 LICENSE                 "$build/usr/share/doc/ufw-cf/LICENSE"

mkdir -p "$build/DEBIAN"
stage 0644 debian/DEBIAN/control   "$build/DEBIAN/control"
stage 0644 debian/DEBIAN/conffiles "$build/DEBIAN/conffiles"
stage 0755 debian/DEBIAN/postinst  "$build/DEBIAN/postinst"
stage 0755 debian/DEBIAN/prerm     "$build/DEBIAN/prerm"
stage 0755 debian/DEBIAN/postrm    "$build/DEBIAN/postrm"

sed -i.bak "s/^Version: .*/Version: $version/" "$build/DEBIAN/control"
rm -f "$build/DEBIAN/control.bak"

if command -v dpkg-deb >/dev/null; then
    dpkg-deb --root-owner-group --build "$build" "$out/${pkg}.deb"
    echo "built $out/${pkg}.deb"
else
    echo "dpkg-deb not available — staged tree at $build" >&2
    exit 1
fi
