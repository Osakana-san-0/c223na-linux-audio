#!/bin/bash
# Rebuild snd-soc-avs-max98357a for the running kernel after a kernel update.
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"
KVER="$(uname -r)"
KDIR="/lib/modules/${KVER}/build"

if [ ! -e "$KDIR/Makefile" ]; then
  echo "Install headers first: sudo apt-get install -y linux-headers-${KVER}"
  exit 1
fi

make -C "$KDIR" M="$SRC" modules CONFIG_DEBUG_INFO_BTF_MODULES=n || {
  mkdir -p /tmp/fakebin
  printf '%s\n' '#!/bin/sh' 'exit 0' > /tmp/fakebin/pahole
  chmod +x /tmp/fakebin/pahole
  PATH="/tmp/fakebin:${PATH}" make -C "$KDIR" M="$SRC" modules
}

sudo install -D -m 644 "$SRC/snd-soc-avs-max98357a.ko" \
  "/lib/modules/${KVER}/updates/snd-soc-avs-max98357a.ko"
sudo depmod -a "$KVER"
sudo modprobe snd-soc-avs-max98357a
echo "Loaded snd-soc-avs-max98357a for ${KVER}"
aplay -l
