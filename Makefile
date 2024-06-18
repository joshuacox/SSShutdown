ifdef PREFIX
	PREFIX := $(PREFIX)
else
  PREFIX:=/usr/local
endif
PREFIX_BIN:=${PREFIX}/bin

install: install_all clean

install_all:
	./installer

echo:
	echo ${PREFIX}

clean:
	@rm -Rfv build_tmp

vanity:
	curl -i https://git.io -F "url=https://raw.githubusercontent.com/joshuacox/SSShutdown/master/bootstrap" -F "code=ssshutdown"

hooks:
	sudo mkdir -p /etc/ssshutdown/hooks
	sudo cp -i hooks.example/in.example /etc/ssshutdown/hooks/in
	sudo cp -i hooks.example/out.example /etc/ssshutdown/hooks/out
