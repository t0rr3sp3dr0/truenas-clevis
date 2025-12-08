#!/bin/sh
set -e

D='/run/zfs'
mkdir -p "${D}"

F="${D}/boot-pool.key"
echo -n 'nimda_saneurt' > "${F}"

F='/usr/lib/python3/dist-packages/truenas_installer/install.py'
sed -Ei 's|"compatibility=grub2"|"compatibility=grub2",\n            "-o", "feature@encryption=enabled"|' "${F}"
sed -Ei 's|"-O", "devices=off"|"-O", "devices=off",\n            "-O", "encryption=on",\n            "-O", "keyformat=passphrase",\n            "-O", f"keylocation=file:///run/zfs/{BOOT_POOL}.key"|' "${F}"

F='/usr/local/sbin/chroot'
echo '#!/bin/bash -e' > "${F}"
echo '[[ "${2}" = "grub-install" ]] && mkdir -p "${1}/boot/efi/EFI/debian" && curl -Lo "${1}/boot/efi/EFI/debian/grubx64.efi" --doh-url "https://'"${DNS:-1.1.1.1}"'/dns-query" "https://github.com/t0rr3sp3dr0/truenas-clevis/releases/'"${RELEASE:-latest}"'/download/BOOTx64.EFI" && exec /usr/sbin/chroot "${1}" grub-install --version || exec /usr/sbin/chroot "${@}"' >> "${F}"
chmod +x "${F}"

exit
