#!/bin/sh
set -e

D='/run/zfs'
mkdir -m '0700' -p "${D}"

F="${D}/boot-pool.key"
echo -n 'nimda_saneurt' > "${F}"

F='/usr/lib/python3/dist-packages/truenas_installer/install.py'
sed -Ei 's|"compatibility=grub2"|"compatibility=grub2",\n            "-o", "feature@encryption=enabled"|' "${F}"
sed -Ei 's|"-O", "devices=off"|"-O", "devices=off",\n            "-O", "encryption=on",\n            "-O", "keyformat=passphrase",\n            "-O", f"keylocation=file:///run/zfs/{BOOT_POOL}.key"|' "${F}"

D='/usr/local/sbin'
mkdir -p "${D}"

# --- EMBED

F="${D}/chroot"
echo -n 'IyEvYmluL2Jhc2ggLWUKCmNhc2UgIiR7Mn0iIGluCiAgICBncnViLWluc3RhbGwpCiAgICAgICAgLiBncnViLWluc3RhbGwKICAgICAgICA7OwoKICAgIHVwZGF0ZS1ncnViKQogICAgICAgIC4gdXBkYXRlLWdydWIKICAgICAgICA7OwoKICAgICopCiAgICAgICAgZXhlYyAvdXNyL3NiaW4vY2hyb290ICIke0B9IgogICAgICAgIDs7CmVzYWMK' | base64 -d > "${F}"
chmod +x "${F}"

F="${D}/grub-install"
echo -n 'IyEvYmluL2Jhc2ggLWUKCmlmIFsgIiR7MCMjKi99IiAhPSAnY2hyb290JyBdCnRoZW4KICAgIGV4ZWMgL3Vzci9zYmluL2dydWItaW5zdGFsbCAtLXZlcnNpb24KZmkKCm1rZGlyIC1wICIkezF9L2Jvb3QvZWZpL0VGSS9kZWJpYW4iCmN1cmwgLUxvICIkezF9L2Jvb3QvZWZpL0VGSS9kZWJpYW4vZ3J1Yng2NC5lZmkiIC0tZG9oLXVybCAiJHtUUlVFTkFTX0NMRVZJU19ET0hfVVJMOi1odHRwczovLzEuMS4xLjEvZG5zLXF1ZXJ5fSIgIiR7VFJVRU5BU19DTEVWSVNfRUZJX1VSTDotaHR0cHM6Ly9naXRodWIuY29tL3QwcnIzc3AzZHIwL3RydWVuYXMtY2xldmlzL3JlbGVhc2VzL2xhdGVzdC9kb3dubG9hZC9CT09UeDY0LkVGSX0iCgpleGVjIC91c3Ivc2Jpbi9jaHJvb3QgIiR7MX0iIGdydWItaW5zdGFsbCAtLXZlcnNpb24K' | base64 -d > "${F}"
chmod +x "${F}"

F="${D}/update-grub"
echo -n 'IyEvYmluL2Jhc2ggLWUKCmlmIFsgIiR7MCMjKi99IiA9ICdjaHJvb3QnIF0KdGhlbgogICAgTU5UPSIkezF9IgoKICAgIC91c3Ivc2Jpbi9jaHJvb3QgIiR7QH0iCmVsc2UKICAgIC91c3Ivc2Jpbi91cGRhdGUtZ3J1YiAiJHtAfSIKZmkKClBPT0w9IiQoZmluZG1udCAtbiAtbyAnU09VUkNFJyAtTSAiJHtNTlR9L2Jvb3QvZ3J1YiIpIgpQT09MPSIke1BPT0wlJS8qfSIKClJPV1M9IiQoemZzIGdldCAtSCAtbyAnbmFtZSx2YWx1ZScgLXMgJ2xvY2FsJyAndHJ1ZW5hczprZXJuZWxfdmVyc2lvbicgMj4vZGV2L251bGwpIgpST1dTPSIkKGF3ayAtdiAicmU9XiR7UE9PTH0vIiAnJDEgfiByZSB7IHByaW50ICQxICI7IiAkMjsgfTsnIDw8PCAiJHtST1dTfSIpIgoKZm9yIFJPVyBpbiAke1JPV1N9CmRvCiAgICBLREVWPSIke1JPVyUlOyp9IgogICAgS1ZFUj0iJHtST1cjIyo7fSIKCiAgICBQUkVGPSIkKGF3ayAneyBnc3ViKC9bKy5dLywgIlsmXSIpOyBwcmludDsgfScgPDw8ICIke0tERVYvJHtQT09MfX0iKSIKICAgIFNVRkY9IiQoYXdrICd7IGdzdWIoL1srLl0vLCAiWyZdIik7IHByaW50OyB9JyA8PDwgIiR7S1ZFUn0iKSIKICAgIENNRFM9IiQoYXdrIC12ICJyZT1eJHtQUkVGfUAvListJHtTVUZGfSQiICckMSA9PSAibGludXgiICYmICQyIH4gcmUgeyAkMSA9ICIiOyAkMiA9ICIiOyBzdWIoIl4iIEZTICIrIiwgIiIpOyBwcmludDsgfScgPCAiJHtNTlR9L2Jvb3QvZ3J1Yi9ncnViLmNmZyIpIgoKICAgIHpmcyBzZXQgJ29yZy56ZnNib290bWVudTphY3RpdmU9b24nICIke0tERVZ9IgogICAgemZzIHNldCAib3JnLnpmc2Jvb3RtZW51OmNvbW1hbmRsaW5lPSR7Q01EU30iICIke0tERVZ9IgogICAgemZzIHNldCAib3JnLnpmc2Jvb3RtZW51Omtlcm5lbD0ke0tWRVJ9IiAiJHtLREVWfSIKZG9uZQo=' | base64 -d > "${F}"
chmod +x "${F}"

# ... EMBED

if [ -n "${TRUENAS_CLEVIS_DOH_URL}" ]
then
    echo "TRUENAS_CLEVIS_DOH_URL=${TRUENAS_CLEVIS_DOH_URL}" >> /etc/environment
fi

if [ -n "${TRUENAS_CLEVIS_EFI_URL}" ]
then
    echo "TRUENAS_CLEVIS_EFI_URL=${TRUENAS_CLEVIS_EFI_URL}" >> /etc/environment
fi

exec login -f "${USER}"
