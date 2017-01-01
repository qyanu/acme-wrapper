SHELL := /bin/bash
PACKAGE := acme-wrapper

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
	@echo "   apt-get install coreutils curl openssl sed"
	@echo
	@echo "finally, the make the directory"
	@echo "   /var/opt/$(PACKAGE)/www"
	@echo "publicly accessible as"
	@echo "   http://«domain»/.well-known/acme-challenge"
	@echo "see the included example conf files."
	@echo

install-crontab:
	install -D -m 0400 "$(CURDIR)/example/crontab.example" "/etc/cron.d/$(PACKAGE)"
