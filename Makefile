CMDSEP = ;

# Destination directory
INSTALL_DIR ?= /usr/local/share/bpm-tests
FOLDERS = \
	archiver  \
	misc  \
	site_specific  \
	utils

FILES = \
	COPYING \
	initbpmtests.m \
	README.md

install:
	mkdir -p $(INSTALL_DIR)
	$(foreach folder, $(FOLDERS), rsync -avzrp $(folder) $(INSTALL_DIR)/ $(CMDSEP))
	$(foreach file, $(FILES), rsync -avzrp $(file) $(INSTALL_DIR)/ $(CMDSEP))

uninstall:
	$(foreach file, $(FILES), rm -rf $(INSTALL_DIR)/$(file) $(CMDSEP))
	$(foreach folder, $(FOLDERS), rm -rf $(INSTALL_DIR)/$(folder) $(CMDSEP))
	rmdir $(INSTALL_DIR)
