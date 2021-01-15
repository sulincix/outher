#!/usr/bin/env bash
set -euo pipefail
mkdir -p /tmp/bubble-$USER/ 2>/dev/null || true
xhost + &>/dev/null
exec bwrap --ro-bind /usr /usr \
      --ro-bind /lib /lib \
      --ro-bind /lib32 /lib32 \
      --ro-bind /bin /bin \
      --ro-bind /etc /etc \
      --ro-bind /sbin /sbin \
      --ro-bind /sys /sys \
      --dev-bind /dev/dri /dev/dri \
      --ro-bind /sys/dev/char /sys/dev/char \
      --ro-bind /sys/devices/pci0000:00 /sys/devices/pci0000:00 \
      --bind /tmp/bubble-$USER /root \
      --dir /tmp \
      --ro-bind /var /var \
      --dir /run \
      --bind /run/media /media \
      --proc /proc \
      --dev /dev \
      --ro-bind /etc/resolv.conf /etc/resolv.conf \
      --chdir / \
      --share-net \
      --die-with-parent \
      --dir /run/user/$(id -u) \
      --setenv XDG_RUNTIME_DIR "/run/user/`id -u`" \
      --setenv DISPLAY "$DISPLAY" \
      --setenv HOME "/root" \
      --uid 0 --gid 0  --setenv USER "root" \
      --unshare-pid --unshare-ipc --unshare-cgroup --unshare-uts \
      --as-pid-1 \
      --new-session \
      -- $@
