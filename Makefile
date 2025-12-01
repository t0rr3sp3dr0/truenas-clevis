build:
	$(MAKE) -C zfsbootmenu $@
.PHONY: build

clean:
	$(MAKE) -C zfsbootmenu $@
.PHONY: clean

serve:
	python3 -m 'http.server'
.PHONY: serve

truenas/%:
	$(MAKE) -C truenas $(@:truenas/%=%)
.PHONY: truenas/%

zfsbootmenu/%:
	$(MAKE) -C zfsbootmenu $(@:zfsbootmenu/%=%)
.PHONY: zfsbootmenu/%
