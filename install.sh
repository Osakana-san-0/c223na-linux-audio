#!/bin/bash
# Enable speakers/headphones/mic on Acer Chromebook C223NA (Google Babymega)
# under Debian with the Intel AVS driver.
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
KVER="$(uname -r)"
KDIR="/lib/modules/${KVER}/build"
UCM="/usr/share/alsa/ucm2"

if [ "$(id -u)" -ne 0 ]; then
  exec sudo "$0" "$@"
fi

if [ ! -e "$KDIR/Makefile" ]; then
  echo "Install kernel headers first:"
  echo "  apt-get install -y linux-headers-${KVER}"
  exit 1
fi

echo "Building snd-soc-avs-max98357a for ${KVER}"
if ! make -C "$KDIR" M="$SRC" modules CONFIG_DEBUG_INFO_BTF_MODULES=n; then
  mkdir -p /tmp/fakebin
  printf '%s\n' '#!/bin/sh' 'exit 0' > /tmp/fakebin/pahole
  chmod +x /tmp/fakebin/pahole
  PATH="/tmp/fakebin:${PATH}" make -C "$KDIR" M="$SRC" modules
fi

install -D -m 644 "$SRC/snd-soc-avs-max98357a.ko" \
  "/lib/modules/${KVER}/updates/snd-soc-avs-max98357a.ko"
depmod -a "$KVER"
modprobe snd-soc-avs-max98357a

install -D -m 644 "$SRC/conf/snd-avs-c223na.conf" /etc/modprobe.d/snd-avs-c223na.conf
install -D -m 644 "$SRC/conf/snd-soc-avs-max98357a.conf" \
  /etc/modules-load.d/snd-soc-avs-max98357a.conf

if [ -d "$UCM/conf.d/avs_da7219" ]; then
  ln -sfn ../../Intel/avs/avs_da7219/avs_da7219.conf \
    "$UCM/conf.d/avs_da7219/Google-Babymega-rev5.conf"
  ln -sfn ../../Intel/avs/avs_da7219/avs_da7219.conf \
    "$UCM/conf.d/avs_da7219/avs_da7219.conf"
fi
if [ -d "$UCM/conf.d/avs_dmic" ]; then
  ln -sfn ../../Intel/avs/avs_dmic/DMIC-2ch.conf \
    "$UCM/conf.d/avs_dmic/Google-Babymega-rev5.conf"
  ln -sfn ../../Intel/avs/avs_dmic/DMIC-2ch.conf \
    "$UCM/conf.d/avs_dmic/avs_dmic.conf"
fi
if [ -d "$UCM/conf.d/avs_max98357a" ]; then
  ln -sfn ../../Intel/avs/avs_max98357a/avs_max98357a.conf \
    "$UCM/conf.d/avs_max98357a/Google-Babymega-rev5.conf"
  ln -sfn ../../Intel/avs/avs_max98357a/avs_max98357a.conf \
    "$UCM/conf.d/avs_max98357a/avs_max98357a.conf"
fi

echo
echo "Installed. Reboot, or restart PipeWire as your user:"
echo "  systemctl --user restart pipewire wireplumber pipewire-pulse"
echo
echo "WARNING: The MAX98357A speaker amp has no hardware volume limiter."
echo "Keep software volume around 20-40%. 100% can damage the speakers."
aplay -l
