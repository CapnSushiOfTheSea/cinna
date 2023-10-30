PREFIX = /usr

install:
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	@cp -p cinna $(DESTDIR)$(PREFIX)/bin/cinna
	@chmod 755 $(DESTDIR)$(PREFIX)/bin/cinna
	@echo "Installed Cinna."

uninstall:
	@rm -rf $(DESTDIR)$(PREFIX)/bin/cinna
	@echo "Uninstalled Cinna. Goodbye!"