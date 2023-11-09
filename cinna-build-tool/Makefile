PREFIX = /usr

install:
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	@cp -p cinna-build $(DESTDIR)$(PREFIX)/bin/cinna-build
	@chmod 755 $(DESTDIR)$(PREFIX)/bin/cinna-build
	@echo "Installed Cinna Build Tool."

uninstall:
	@rm -rf $(DESTDIR)$(PREFIX)/bin/cinna-build
	@echo "Uninstalled Cinna Build Tool. Goodbye!"