SHELL := /bin/bash
PACKAGE := acme-wrapper
VERSION := $(shell cat $(CURDIR)/VERSION)
CURRENT_COMMIT_DATE := $(shell git show --format="%cI" --no-patch HEAD)

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
	@echo "finally, make the (existing) directory"
	@echo "   /var/opt/$(PACKAGE)/www"
	@echo "publicly accessible as"
	@echo "   http://«domain»/.well-known/acme-challenge"
	@echo
	@echo "See the included example conf files."
	@echo

install-crontab:
	install -D -m 0400 "$(CURDIR)/example/crontab.example" "/etc/cron.d/$(PACKAGE)"

.PHONY: package
package: acme-wrapper_$(VERSION).tar.bz2

.PHONY: clean
clean:
	rm -f $(CURDIR)/$(PACKAGE)_$(VERSION).tar.bz2

acme-wrapper_$(VERSION).tar.bz2: clean
	mkdir $(CURDIR)/$(PACKAGE)_$(VERSION)
	cp -pr -t $(CURDIR)/$(PACKAGE)_$(VERSION) \
		bin/ doc/ etc/ example/ install/ lib/ libexec/ share/ var/ \
		LICENSE Makefile README.rst TODO VERSION
	# make tar file reproducible with the following options:
	#   sort, owner, group, numeric-owner, mtime
	tar -C $(CURDIR) --sort=name --owner=0 --group=0 --numeric-owner \
		--mtime "$(CURRENT_COMMIT_DATE)" \
		-cjf $(PACKAGE)_$(VERSION).tar.bz2 \
		$(PACKAGE)_$(VERSION)/
	rm -Rf $(CURDIR)/$(PACKAGE)_$(VERSION)
