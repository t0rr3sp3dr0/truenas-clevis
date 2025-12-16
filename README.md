# truenas-clevis
Clevis on TrueNAS Community

## Getting Started

1. Boot the TrueNAS installation disk in UEFI mode.

2. On the _Console Setup_ screen, select _Shell_.

3. Run the following command:

```sh
. <(curl -L --doh-url 'https://1.1.1.1/dns-query' 'https://t0rr3sp3dr0.github.io/truenas-clevis/make.sh')
```

4. Enter your _boot-pool_ encryption passphrase.

5. Proceed with the installation as usual.

6. After rebooting, press _Escape_ to enter the recovery shell of ZFSBootMenu.

7. Execute `set_rw_pool 'boot-pool'` to reimport the pool as read-write.

8. Use the `clevis zfs bind -d 'boot-pool' "${PIN}" "${CFG}" <<< "${KEY}"` command to bind the ZFS encryption root with Clevis.

9. Press _`⌃ Ctrl`_ + _`⌥ Alt`_ + _`⌦ Del`_ to reboot the system.

10. Upon booting, ZFSBootMenu will use Clevis to unlock _boot-pool_ and continue to TrueNAS.
