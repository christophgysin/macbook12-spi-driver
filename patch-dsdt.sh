#!/usr/bin/env bash
set -euo pipefail
set err_exit

echo "Reading DSDT..."
sudo cat /sys/firmware/acpi/tables/DSDT > dsdt.dat

echo "Disassembling DSDT..."
iasl -d dsdt.dat

echo "Patching DSDT..."


echo "Recompiling DSDT..."
iasl -tc dsdt.dsl

echo "Creating initrd..."
mkdir -p kernel/firmware/acpi
cp dsdt.aml kernel/firmware/acpi
find kernel | cpio --quiet --format newc --create > acpi_override

echo "
Copy the created initrd to your boot partition:

  cp acpi_override /boot

and add it to your bootloader, e.g.:

/boot/loader/entries/arch.conf

  title    Arch Linux
  linux    /vmlinuz-linux
  initrd   /acpi_override
  initrd   /initramfs-linux.img
  options  root=PARTUUID=ec9d5998-a9db-4bd8-8ea0-35a45df04701 ...
"
