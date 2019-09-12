include platform.mk

SKYNET_PATH ?= ../skynet
LUALIB_PATH ?= lualib
LUACLIB_PATH ?= luaclib
SERVICE_PATH ?= service
CSERVICE_PATH ?= cservice

LUA_INC ?= $(SKYNET_PATH)/3rd/lua
LUA_LIB ?= $(SKYNET_PATH)/3rd/lua/liblua.a
CFLAGS = -g -O2 -Wall -I$(LUA_INC)

$(LUALIB_PATH):
	mkdir -p $(LUALIB_PATH)

$(LUACLIB_PATH):
	mkdir -p $(LUACLIB_PATH)

$(SERVICE_PATH):
	mkdir -p $(SERVICE_PATH)

$(CSERVICE_PATH):
	mkdir -p $(CSERVICE_PATH)

# cjson
$(LUACLIB_PATH)/cjson.so : lua-cjson/strbuf.c lua-cjson/fpconv.c lua-cjson/lua_cjson.c
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@

# filesystem
$(LUACLIB_PATH)/lfs.so : lua-filesystem/src/lfs.c
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@

# pb
$(LUACLIB_PATH)/pb.so : lua-protobuf/pb.c
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@

LUALIB =
LUACLIB = cjson.so pb.so lfs.so
SERVICE =
CSERVICE =

all : $(LUALIB_PATH) $(LUACLIB_PATH) $(SERVICE_PATH) $(CSERVICE_PATH) \
	$(foreach v, $(LUALIB),$(LUALIB_PATH)/$(v)) \
	$(foreach v, $(LUACLIB),$(LUACLIB_PATH)/$(v)) \
	$(foreach v, $(SERVICE),$(SERVICE_PATH)/$(v)) \
	$(foreach v, $(CSERVICE),$(CSERVICE_PATH)/$(v))

clean :
	rm -rf $(LUALIB_PATH)/*
	rm -rf $(LUACLIB_PATH)/*
	rm -rf $(SERVICE_PATH)/*
	rm -rf $(CSERVICE_PATH)/*
