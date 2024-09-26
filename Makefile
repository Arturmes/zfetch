SHELL = /bin/sh

INSTALL_DIR = /usr/bin/
IN_NAME = zfetch.sh
OUT_NAME = zfetch

help:
	@echo "make install      Install zfetch."
	@echo "make uninstall    Remove zfetch."

install:
	cp ${IN_NAME} ${INSTALL_DIR}${OUT_NAME}

uninstall:
	rm ${INSTALL_DIR}${OUT_NAME}
