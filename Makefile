PREFIX:=/usr/local
PREFIX_BIN:=/usr/local/bin

install: install_all clean

install_all: build/RRReboot build/SSShutdown build/UUUpdateAndShutdown build/UpdateOnly
	@echo "Warning you will need the correct permission to put files in ${PREFIX}"
	@mkdir -p ${PREFIX}/SSShutdown
	@cp -av lib ${PREFIX}/SSShutdown/
	@install -v -m 0755 -o ${USER} -g ${USER} build_tmp/RRReboot ${PREFIX_BIN}/RRReboot
	@install -v -m 0755 -o ${USER} -g ${USER} build_tmp/SSShutdown ${PREFIX_BIN}/SSShutdown
	@install -v -m 0755 -o ${USER} -g ${USER} build_tmp/UUUpdateAndShutdown ${PREFIX_BIN}/UUUpdateAndShutdown
	@install -v -m 0755 -o ${USER} -g ${USER} build_tmp/UpdateOnly ${PREFIX_BIN}/UpdateOnly

build_tmp:
	mkdir -p build_tmp

build/RRReboot: build_tmp
	@REPLACE_PREFIX_REPLACE=${PREFIX} \
	envsubst < RRReboot > build_tmp/RRReboot

build/SSShutdown: build_tmp
	@REPLACE_PREFIX_REPLACE=${PREFIX} \
	envsubst < SSShutdown > build_tmp/SSShutdown

build/UUUpdateAndShutdown: build_tmp
	@REPLACE_PREFIX_REPLACE=${PREFIX} \
	envsubst < UUUpdateAndShutdown > build_tmp/UUUpdateAndShutdown

build/UpdateOnly: build_tmp
	@REPLACE_PREFIX_REPLACE=${PREFIX} \
	envsubst < UpdateOnly > build_tmp/UpdateOnly

clean:
	@rm -Rfv build_tmp

echo:
	echo ${USER}
