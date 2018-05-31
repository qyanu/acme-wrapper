SHELL := /bin/bash
PACKAGE := acme-wrapper
VERSION := $(shell cat $(CURDIR)/VERSION)

all:
	@echo "done"

.PHONY: install
install:
	"$(CURDIR)/install/adduser.sh" "$(PACKAGE)"
	"$(CURDIR)/install/copyfiles.sh" "$(CURDIR)" "$(PACKAGE)"
	@echo
	@echo "recommended additional command:"
	@echo
	@echo "   make install-crontab"
	@echo
	@echo "recommended additional command on debian:"
	@echo
	@echo "   apt-get install coreutils curl openssl sed python"
	@echo
	@echo "finally, the make the directory"
	@echo "   /var/opt/$(PACKAGE)/www"
	@echo "publicly accessible as"
	@echo "   http://«domain»/.well-known/acme-challenge"
	@echo "see the included example conf files."
	@echo

install-crontab:
	install -D -m 0400 "$(CURDIR)/example/crontab.example" "/etc/cron.d/$(PACKAGE)"

.PHONY: package
package:
	mkdir $(CURDIR)/$(PACKAGE)_$(VERSION)
	cp -pr -t $(CURDIR)/$(PACKAGE)_$(VERSION) bin/ doc/ etc/ example/ install/ lib/ libexec/ share/ var/ LICENSE Makefile README.rst TODO VERSION
	tar -C $(CURDIR) --numeric-owner -cjf $(PACKAGE)_$(VERSION).tar.bz2 $(PACKAGE)_$(VERSION)
	rm -Rf $(CURDIR)/$(PACKAGE)_$(VERSION)
