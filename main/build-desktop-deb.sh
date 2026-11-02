#!/bin/bash
# Build oneplus-erhai-desktop_<version>_all.deb from the
# oneplus-erhai-desktop/ staging tree.
#
#   ./build-desktop-deb.sh -> debs/oneplus-erhai-desktop_<version>_all.deb
#
# Plain binary-package layout like build-bluetooth-deb.sh: DEBIAN/control +
# DEBIAN/postinst, erhai-user-groups.service (+ script) that puts the first
# real user into the hardware groups (video/i2c/audio/...), touchscreen
# bring-up unit + rebind script, power-key REAL panel power cycle
# (erhai-power-watch.py -> erhai-panel-power.sh), pogo attach ->
# OSK unit, folio-fold watcher (+ its gate unit and the calibration probe),
# greeter helpers, and the FIXED gjs-osk on-screen keyboard as a system-wide
# GNOME Shell extension (see the gjs-osk block below).
# Staged into root-setup-files/packages/ for build-root.sh.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/../ppa-common.sh"
SRC="$HERE/oneplus-erhai-desktop"
SETUP="$HERE/root-setup"
PKG=$(awk '/^Package:/ {print $2}' "$SRC/DEBIAN/control")
VER=$(awk '/^Version:/ {print $2}' "$SRC/DEBIAN/control")

for f in usr/local/sbin/erhai-user-groups.sh 	 usr/local/sbin/erhai-keyring-unlock.sh 	 usr/local/sbin/erhai-touch-rebind.sh 	 usr/local/sbin/erhai-display-toggle.sh 	 usr/local/sbin/erhai-panel-power.sh 	 usr/local/sbin/erhai-panel-state-migrate.sh 	 usr/local/sbin/erhai-power-watch.py 	 usr/local/sbin/erhai-suspend-s2idle.sh 	 usr/local/sbin/erhai-suspend-wlan-guard.sh 	 etc/systemd/system/systemd-suspend.service.d/erhai-s2idle.conf 	 usr/local/sbin/erhai-folio-fold.py 	 usr/local/sbin/erhai-folio-gate.sh 	 usr/local/sbin/erhai-folio-unblank.sh 	 usr/local/sbin/erhai-gpu-pin-once.sh 	 etc/systemd/system/erhai-gpu-pin-once.service 	 etc/erhai/gpu-pin.conf 	 etc/erhai/display.conf 	 etc/xdg/powerdevilrc 	 etc/xdg/QtProject/qtlogging.ini 	 usr/local/sbin/erhai-gpu-external-pin.sh 	 etc/udev/rules.d/72-erhai-gpu-external.rules 	 usr/local/sbin/erhai-folio-calibrate 	 usr/local/sbin/erhai-folio-probe.py 	 etc/udev/rules.d/71-erhai-folio-udev.rules 	 usr/local/sbin/erhai-backlight-fixed.sh 	 etc/systemd/system/erhai-backlight.service 	 usr/local/sbin/erhai-rtc-sync.py 	 etc/systemd/system/erhai-rtc-sync.service 	 etc/systemd/system/erhai-rtc-sync.timer 	 usr/local/sbin/erhai-bypass-charge.sh 	 etc/default/erhai-charge 	 etc/systemd/system/erhai-bypass-charge.service 	 etc/systemd/system/erhai-bypass-charge@.service 	 etc/polkit-1/rules.d/50-erhai-bypass-charge.rules 	 usr/share/oneplus-erhai-desktop/README.md 	 usr/share/glib-2.0/schemas/99-erhai-no-gsd-ambient.gschema.override 	 usr/local/sbin/erhai-audio-greeter-guard.sh 	 usr/lib/systemd/user/pipewire.service.d/50-erhai-wait-greeter.conf 	 usr/lib/systemd/user/wireplumber.service.d/50-erhai-session.conf 	 usr/lib/systemd/user/pipewire-pulse.service.d/50-erhai-session.conf 	 usr/lib/systemd/user/filter-chain.service.d/50-erhai-session.conf; do
	[ -f "$SRC/$f" ] || { echo "missing $f in $SRC" >&2; exit 1; }
done

# Panel click sounds (deterministic, regenerated on every build — same pattern
# as build-sensors-deb.sh compiling its gschemas into the staging tree).
mkdir -p "$SRC/usr/share/sounds/erhai"
"$HERE/../gen-panel-click.py" "$SRC/usr/share/sounds/erhai/panel-off.wav" off \
	>/dev/null
"$HERE/../gen-panel-click.py" "$SRC/usr/share/sounds/erhai/panel-on.wav" on \
	>/dev/null
for f in usr/share/sounds/erhai/panel-off.wav usr/share/sounds/erhai/panel-on.wav; do
	[ -s "$SRC/$f" ] || { echo "missing $f in $SRC" >&2; exit 1; }
done

# Pre-pack guard: a Python bytecode cache is NOT payload.  A test that imports a
# script from this tree (importlib over usr/local/sbin/erhai-*.py) writes
# __pycache__ next to it, and a .pyc shipped in the deb would be a stale,
# root-owned copy of the script that dpkg -V cannot check against the source.
if find "$SRC" \( -name __pycache__ -o -name '*.pyc' \) -print -quit | grep -q .; then
	echo "refusing to pack: Python bytecode cache inside $SRC" >&2
	find "$SRC" \( -name __pycache__ -o -name '*.pyc' \) >&2
	exit 1
fi

find "$SRC" -type d -exec chmod 755 {} \;
chmod 755 "$SRC"/DEBIAN/postinst
if [ -f "$SRC"/DEBIAN/postrm ]; then chmod 755 "$SRC"/DEBIAN/postrm; fi
# everything in sbin/ is executable — .sh AND .py (pogo-osk regression 2026-09-09)
find "$SRC/usr/local/sbin" -type f -exec chmod 755 {} \;
# the rest of the payload is plain data (units, udev rules, dconf, schemas,
# sounds, the gjs-osk tree): root:root 0644, never group-writable.
find "$SRC" -type f ! -path "$SRC/DEBIAN/*" ! -path "$SRC/usr/local/sbin/*" \
	-exec chmod 644 {} +

# md5sums for every payload file (DEBIAN/ excluded), sorted so the manifest is
# deterministic and `dpkg -V` has something to verify against.  The 2.1 build
# shipped no md5sums member at all.
rm -f "$SRC/DEBIAN/md5sums"
( cd "$SRC" && find . -path ./DEBIAN -prune -o -type f -print0 |
	sed -z 's|^\./||' | sort -z | xargs -0 -r md5sum > DEBIAN/md5sums )
chmod 644 "$SRC/DEBIAN/md5sums"
echo "==> md5sums: $(grep -c '' "$SRC/DEBIAN/md5sums") files"
dpkg-deb --build --root-owner-group "$SRC" "$DEB_DIR/${PKG}_${VER}_all.deb"

# NO_PPA=1 builds locally without publishing (in-development iterations;
# release policy: publish to the PPA only when the owner asks for it).
if [ "${NO_PPA:-0}" != 1 ]; then
	ppa_copy "$DEB_DIR/${PKG}_${VER}_all.deb"
fi
echo "built ${PKG}_${VER}_all.deb"
