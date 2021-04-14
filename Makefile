PREFIX=/usr/local
INSTALL_DIR=$(PREFIX)/bin

OUT_DIR=$(CURDIR)/bin

APP=crcache

all: build

build: $(APP)

lib:
	shards install

$(APP): lib $(APP_SOURCES) | $(OUT_DIR)
	@echo "Building $(APP) in $@"
	@crystal build -o $(OUT_DIR)/$(APP) src/$(APP).cr -p --no-debug

$(OUT_DIR) $(INSTALL_DIR):
	 @mkdir -p $@

run:
	$(BIN)/$(APP)

install: build | $(INSTALL_DIR)
	@cp $(APP) $(INSTALL_DIR)

clean:
	rm -rf $(OUT_DIR)

distclean:
	rm -rf $(OUT_DIR) .crystal .shards libs lib


