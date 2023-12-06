#!/bin/env bash
set -e

export KERNEL_dir=$(pwd)
if test -d "$KERNEL_DIR/common/drivers"; then
     DRIVER_DIR="$KERNEL_DIR/common/drivers"
elif test -d "$KERNEL_DIR/drivers"; then
     DRIVER_DIR="$KERNEL_DIR/drivers"
else
     echo  'Error: "drivers/" directory is not found.'
     exit 127
fi

test -f "DRIVER_DIR/kernelsu" || git clone https://github.com/tiann/KernelSU "$KERNEL_DIR/KernelSU"

cd "$DRIVER_DIR"
if test -d "$GKI_ROOT/common/drivers"; then
     ln -sf "../../KernelSU/kernel" "kernelsu"
elif test -d "$GKI_ROOT/drivers"; then
     ln -sf "../KernelSU/kernel" "kernelsu"
fi
cd "$KERNEL_DIR"

export DRIVER_MAKEFILE="$DRIVER_DIR/Makefile"
export DRIVER_KCONFIG="$DRIVER_DIR/Kconfig"
grep -q "kernelsu" "$DRIVER_MAKEFILE" || printf "obj-\$(CONFIG_KSU) += kernelsu/\n" >> "$DRIVER_MAKEFILE"
grep -q "kernelsu" "$DRIVER_KCONFIG" || sed -i "/endmenu/i\\source \"drivers/kernelsu/Kconfig\"" "$DRIVER_KCONFIG"

export  DARCH=$(arch)
case ${DARCH} in
    armel) export CARCH="armel" ;;
    armv7* | armv8l | armhf | arm) export CARCH="armhf" ;;
    aarch64 | arm64* | armv8* | arm*) export CARCH="arm64" ;;
    i*86 | x86) export CARCH="i386" ;;
    x86_64 | amd64) export CARCH="amd64" ;;
    *) echo -e "\033[31m$(${GETTEXT} "Unknow cpu architecture for this device !")\033[0m"&&exit 1 ;;
esac
return 0

test -f hook-414.patch || wget https://github.com/dpkg123/kpatch/raw/main/hook.patch

KERNEL_CONFIG="$(pwd)/arch/$CARCH/configs/$1"
grep -q "CONFIG_KPROBES=y" "KERNEL_CONFIG" || git apply hook.patch
rm -rf hook.patch

echo "Done."
