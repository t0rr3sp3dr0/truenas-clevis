#!/bin/sh
set -e

F='/usr/lib/python3/dist-packages/truenas_installer/install.py'
sed -Ei 's|"compatibility=grub2"|"compatibility=grub2",\n            "-o", "feature@encryption=enabled"|' "${F}"
sed -Ei 's|"-O", "devices=off"|"-O", "devices=off",\n            "-O", "encryption=on",\n            "-O", "keyformat=passphrase",\n            "-O", f"keylocation=file:///run/{BOOT_POOL}.key"|' "${F}"
sed -Ei 's|(\["zfs", "create",.+f"\{BOOT_POOL\}/ROOT"\])|["zfs", "set", "keylocation=prompt", f"{BOOT_POOL}"])\n    await run(\1|' "${F}"

F='/usr/local/sbin/chroot'
echo '#!/bin/bash -e' > "${F}"
echo '[[ "${2}" = "grub-install" ]] && mkdir -p "${1}/boot/efi/EFI/debian" && curl -Lo "${1}/boot/efi/EFI/debian/grubx64.efi" "https://github.com/t0rr3sp3dr0/truenas-clevis/releases/'"${RELEASE:-latest}"'/download/BOOTx64.EFI" && exec /usr/sbin/chroot "${1}" grub-install --version || exec /usr/sbin/chroot "${@}"' >> "${F}"
chmod +x "${F}"

F='/run/boot-pool.key'
echo -n 'nimda_saneurt' > "${F}"

exit
