#!/bin/bash
# Build the KDE Plasma 6 rootfs image for OnePlus Pad 3 (erhai)
# Mirrors build-root.sh with DESKTOP=kde
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
export DESKTOP=kde
exec "$HERE/build-root.sh" "$@"
