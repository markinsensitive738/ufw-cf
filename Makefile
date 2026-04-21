PREFIX      ?= /usr/local
BINDIR      ?= $(PREFIX)/bin
SYSCONFDIR  ?= /etc
SYSTEMDDIR  ?= /etc/systemd/system
DESTDIR     ?=

VERSION := $(shell sed -n 's/^VERSION="\(.*\)"/\1/p' bin/ufw-cf)
PKG     := ufw-cf-$(VERSION)-all

.PHONY: all install uninstall test lint deb clean help

all: help

help:
	@echo "Targets:"
	@echo "  make install       Install ufw-cf to $(PREFIX)"
	@echo "  make uninstall     Remove ufw-cf"
	@echo "  make test          Run bats tests"
	@echo "  make lint          Run shellcheck"
	@echo "  make deb           Build a .deb package in ./dist"
	@echo "  make clean         Remove build artifacts"

install:
	install -Dm0755 bin/ufw-cf              $(DESTDIR)$(BINDIR)/ufw-cf
	install -Dm0644 systemd/ufw-cf.service  $(DESTDIR)$(SYSTEMDDIR)/ufw-cf.service
	install -Dm0644 systemd/ufw-cf.timer    $(DESTDIR)$(SYSTEMDDIR)/ufw-cf.timer
	install -d -m0755 $(DESTDIR)$(SYSCONFDIR)/ufw-cf
	[ -e $(DESTDIR)$(SYSCONFDIR)/ufw-cf/config ] || \
		install -Dm0644 systemd/config.example $(DESTDIR)$(SYSCONFDIR)/ufw-cf/config
	install -d -m0755 $(DESTDIR)/var/lib/ufw-cf

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/ufw-cf
	rm -f $(DESTDIR)$(SYSTEMDDIR)/ufw-cf.service
	rm -f $(DESTDIR)$(SYSTEMDDIR)/ufw-cf.timer

test:
	bats tests

lint:
	shellcheck bin/ufw-cf install.sh uninstall.sh scripts/*.sh

deb:
	scripts/build-deb.sh

clean:
	rm -rf dist build
