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

6. After rebooting, press _`⎋ Esc`_ in the ZFSBootMenu screen.

7. Enter the passphrase you set for _boot-pool_.

8. Press _`⌃ Ctrl`_ + _`R`_ to enter the recovery shell.

9. Execute `set_rw_pool 'boot-pool'` to reimport the pool as read-write.

10. Use the `clevis zfs bind -d 'boot-pool' "${PIN}" "${CFG}" <<< "${KEY}"` command to bind the ZFS encryption root with Clevis.

11. Press _`⌃ Ctrl`_ + _`⌥ Alt`_ + _`⌦ Del`_ to reboot the system.

12. Upon booting, ZFSBootMenu will use Clevis to unlock _boot-pool_ and continue to TrueNAS.

## Compromised PINs

The [`zfs change-key` man page](https://openzfs.github.io/openzfs-docs/man/master/8/zfs-change-key.8.html) states the following:

> If the user's key is compromised, `zfs change-key` does not necessarily protect existing or newly-written data from attack. Newly-written data will continue to be encrypted with the same master key as the existing data. The master key is compromised if an attacker obtains a user key and the corresponding wrapped master key. Currently, `zfs change-key` does not overwrite the previous wrapped master key on disk, so it is accessible via forensic analysis for an indeterminate length of time.
>
> In the event of a master key compromise, ideally the drives should be securely erased to remove all the old data (which is readable using the compromised master key), a new pool created, and the data copied back. This can be approximated in place by creating new datasets, copying the data (e.g. using `zfs send` | `zfs recv`), and then clearing the free space with `zpool trim --secure` if supported by your hardware, otherwise `zpool initialize`.

This caveat similarly applies to Clevis bindings. If a Clevis PIN is compromised, `clevis zfs unbind` does not necessarily protect existing or newly written data from attacks as it does not overwrite the previously bound PIN on disk and it remains accessible via forensic analysis for an indeterminate period. Ideally, the drives should be securely erased to remove all the old data, a new pool created, and the data copied back.
