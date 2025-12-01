# truenas-clevis
Clevis on TrueNAS Community

## Getting Started

1. Boot the TrueNAS installation disk in UEFI mode.

2. On the _Console Setup_ screen, select _Shell_.

3. Run the following command:

```sh
. <(curl -L --doh-url 'https://1.1.1.1/dns-query' 'https://t0rr3sp3dr0.github.io/truenas-clevis/make.sh')
```

4. Proceed the installation as usual. Your boot pool will be encrypted with the `nimda_saneurt` passphrase.
