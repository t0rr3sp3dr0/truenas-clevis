REF ?= refs/tags/v3.0.1
TAG ?= 20250129

build: build/vmlinuz.EFI
.PHONY: build

clean:
	git clean -Xdf -- .
.PHONY: clean

zbm-builder.sh:
	curl -LO --output-dir '$(dir $@)' 'https://github.com/zbm-dev/zfsbootmenu/raw/$(REF)/$@'
	chmod +x $@

dracut.conf.d/recovery.conf:
	curl -LO --output-dir '$(dir $@)' 'https://github.com/zbm-dev/zfsbootmenu/raw/$(REF)/etc/zfsbootmenu/recovery.conf.d/$(@:dracut.conf.d/%=%)'

dracut.conf.d/common.conf:
	curl -LO --output-dir '$(dir $@)' 'https://github.com/zbm-dev/zfsbootmenu/raw/$(REF)/etc/zfsbootmenu/release.conf.d/$(@:dracut.conf.d/%=%)'

%:
	curl -LO --output-dir '$(dir $@)' 'https://github.com/zbm-dev/zfsbootmenu/raw/$(REF)/etc/zfsbootmenu/$@'

build/vmlinuz.EFI: dracut.conf.d/common.conf dracut.conf.d/omit-drivers.conf dracut.conf.d/recovery.conf dracut.conf.d/zfsbootmenu.conf zbm-builder.sh
	./zbm-builder.sh -i 'ghcr.io/zbm-dev/zbm-builder:$(TAG)'
