SHELL := /bin/bash
MAKEFLAGS=--warn-undefined-variables
PROJECT := acme-wrapper
VERSION := $(shell dpkg-parsechangelog --show-field Version)

all:

install:
	install --verbose \
	    --directory \
	    $(DESTDIR)/usr/bin/ \
	    $(DESTDIR)/usr/lib/acme-wrapper/ \
	    $(DESTDIR)/etc/acme-wrapper/ \
	    #
	install --verbose \
	    --target-directory=$(DESTDIR)/usr/bin/ \
	    src/acme-wrapper \
	    #
	install --verbose \
	    --target-directory=$(DESTDIR)/etc/acme-wrapper/ \
	    --mode=0644 \
	    src/acme-wrapper.conf \
	    src/domains.list \
	    #
	install --verbose \
	    --target-directory=$(DESTDIR)/usr/lib/acme-wrapper/ \
	    --mode=0644 \
	    src/openssl.cnf \
	    #

.PHONY: test
test:
	PROJECT=$(PROJECT) \
	VERSION=$(VERSION) \
	$(MAKE) \
	    -C test \
	    test


clean:
	$(MAKE) -C test clean
