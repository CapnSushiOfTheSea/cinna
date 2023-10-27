PREFIX = /usr

install:
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	@cp -p parcel $(DESTDIR)$(PREFIX)/bin/parcel
	@chmod 755 $(DESTDIR)$(PREFIX)/bin/parcel

uninstall:
	@rm -rf $(DESTDIR)$(PREFIX)/bin/parcel