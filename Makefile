PREFIX:=/usr/local
PREFIX_BIN:=${PREFIX}/bin

install: install_all clean

install_all: build/RRReboot build/sssuspend build/SSShutdown build/FFForceUpdateAndShutdown build/UUUpdateAndShutdown build/UpdateOnly
	@echo "Warning you will need the correct permission to put files in ${PREFIX}, or use sudo make install"
	mkdir -p ${PREFIX}/SSShutdown/lib
	install -v -m 0755 -o ${USER} -g ${USER} lib/util.bash ${PREFIX}/SSShutdown/lib/util.bash
	install -v -m 0755 -o ${USER} -g ${USER} build_tmp/RRReboot ${PREFIX_BIN}/RRReboot
	install -v -m 0755 -o ${USER} -g ${USER} build_tmp/SSShutdown ${PREFIX_BIN}/SSShutdown
	install -v -m 0755 -o ${USER} -g ${USER} build_tmp/sssuspend ${PREFIX_BIN}/sssuspend
	install -v -m 0755 -o ${USER} -g ${USER} build_tmp/UUUpdateAndShutdown ${PREFIX_BIN}/UUUpdateAndShutdown
	install -v -m 0755 -o ${USER} -g ${USER} build_tmp/FFForceUpdateAndShutdown ${PREFIX_BIN}/FFForceUpdateAndShutdown
	install -v -m 0755 -o ${USER} -g ${USER} build_tmp/UpdateOnly ${PREFIX_BIN}/UpdateOnly

build_tmp:
	@echo 'making build_tmp'
	mkdir -p build_tmp

build/RRReboot: build_tmp
	REPLACE_PREFIX_REPLACE=${PREFIX} \
	envsubst < RRReboot > build_tmp/RRReboot
	@echo 'made RRREboot'

build/sssuspend: build_tmp
	@REPLACE_PREFIX_REPLACE=${PREFIX} \
	envsubst < sssuspend > build_tmp/sssuspend
	@echo 'made sssuspend'

build/SSShutdown: build_tmp
	@REPLACE_PREFIX_REPLACE=${PREFIX} \
	envsubst < SSShutdown > build_tmp/SSShutdown
	@echo 'made SSShutdown'

build/UUUpdateAndShutdown: build_tmp
	@REPLACE_PREFIX_REPLACE=${PREFIX} \
	envsubst < UUUpdateAndShutdown > build_tmp/UUUpdateAndShutdown
	@echo 'made UUUpdateAndShutdown'

build/FFForceUpdateAndShutdown: build_tmp
	@REPLACE_PREFIX_REPLACE=${PREFIX} \
	envsubst < FFForceUpdateAndShutdown > build_tmp/FFForceUpdateAndShutdown
	@echo 'made FFForceUpdateAndShutdown'

build/UpdateOnly: build_tmp
	@REPLACE_PREFIX_REPLACE=${PREFIX} \
	envsubst < UpdateOnly > build_tmp/UpdateOnly
	@echo 'made UpdateOnly'

clean:
	@rm -Rfv build_tmp

vanity:
	curl -i https://git.io -F "url=https://raw.githubusercontent.com/joshuacox/SSShutdown/master/bootstrap" -F "code=ssshutdown"

hooks:
	sudo mkdir -p /etc/ssshutdown/hooks
	sudo cp -i hooks.example/in.example /etc/ssshutdown/hooks/in
	sudo cp -i hooks.example/out.example /etc/ssshutdown/hooks/out
