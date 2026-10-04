
ifdef PREFIX
	PREFIX := $(PREFIX)
else
	PREFIX := /usr/local
endif
PREFIX_BIN := ${PREFIX}/bin

.PHONY: echo install install_all uninstall clean vanity hooks

echo:
	@echo ${PREFIX}

install: install_all clean

install_all:
	./installer

uninstall:
	@for f in bin/*; do \
		rm -fv "${PREFIX_BIN}/$$(basename $$f)"; \
	done

clean:
	@rm -Rfv build_tmp

vanity:
	@echo "git.io has been retired by GitHub. Use the direct raw GitHub URL in README.md."

hooks:
	sudo mkdir -p /etc/ssshutdown/hooks
	sudo cp -i hooks.example/in.example /etc/ssshutdown/hooks/in
	sudo cp -i hooks.example/out.example /etc/ssshutdown/hooks/out
