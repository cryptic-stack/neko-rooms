param(
    [string]$Distribution = "docker-desktop"
)

$script = @'
set -eu
if ! lsmod 2>/dev/null | grep -q '^kvm'; then
  modprobe kvm_intel 2>/dev/null || modprobe kvm_amd 2>/dev/null || modprobe kvm
fi
if [ -d /dev/kvm ]; then
  rmdir /dev/kvm
fi
if [ ! -e /dev/kvm ]; then
  mknod /dev/kvm c 10 232
fi
chmod 666 /dev/kvm
stat -c '%F %t:%T %a %n' /dev/kvm
'@

wsl -d $Distribution --exec sh -lc $script
