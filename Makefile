all: embed clean build

build:
	$(MAKE) -C zfsbootmenu $@
.PHONY: build

clean:
	$(MAKE) -C zfsbootmenu $@
.PHONY: clean

embed:
	./hack/embed.sh ./sbin ./docs/make.sh
	./hack/embed.sh ./sbin ./zfsbootmenu/hooks/boot-sel.d/10-patch-initrd.sh '\'
.PHONY: embed

serve:
	python3 -m 'http.server'
.PHONY: serve

zfsbootmenu/%:
	$(MAKE) -C zfsbootmenu $(@:zfsbootmenu/%=%)
.PHONY: zfsbootmenu/%
