# Usage:
#   export PATH="$(realpath "$(dirname "$(realpath "$(which ccache)")")/../libexec"):${PATH}"
#   make server
#   make client
#   make server-wss
#   make client-wss

CXX=c++
CXXFLAGS=-std=c++14 -fPIC -pthread
LDFLAGS=

# Choose Ice version
# ICE_HOME=/usr/local/Cellar/ice36/3.6.4
ICE_HOME=/Users/asommer/dev/extern/ice/cpp
# ICE_HOME=/Users/asommer/dev/extern/ice-3.7.1/cpp
# ICE_HOME=/tmp/Ice-3.7.1
# ICE_HOME=/tmp/Ice-3.6.4
# ICE_HOME=/usr/local

# `include/generated` is for source builds
CXXFLAGS+= -I$(ICE_HOME)/include -I$(ICE_HOME)/include/generated -I/usr/local/include -I.
LDFLAGS+= -L$(ICE_HOME)/lib -lIce -lIceBox -Wl,-rpath,$(ICE_HOME)/lib:.

ifneq (,$(wildcard $(ICE_HOME)/lib/libIceUtil*))
LDFLAGS+= -lIceUtil
endif

slice:
	$(ICE_HOME)/bin/slice2cpp Demo.ice

build-server: slice
	$(CXX) $(CXXFLAGS) $(LDFLAGS) Demo.cpp DemoServiceI.cpp -shared -o libDemoService.so

build-client: slice
	$(CXX) $(CXXFLAGS) $(LDFLAGS) DemoClientApp.cpp Demo.cpp -o DemoClientApp

client: build-client
	@echo "Starting client (WS)"
	@DYLD_PRINT_LIBRARIES=YES LD_LIBRARY_PATH=.:$(ICE_HOME)/lib ./DemoClientApp --Ice.Config=config.client

client-wss: build-client
	@echo "Starting client (WSS)"
	@DYLD_PRINT_LIBRARIES=YES LD_LIBRARY_PATH=.:$(ICE_HOME)/lib ./DemoClientApp --Ice.Config=config.client,config.client-wss

server: kill build-server
	@echo "Starting server (WS)"
	@DYLD_PRINT_LIBRARIES=YES LD_LIBRARY_PATH=.:$(ICE_HOME)/lib $(ICE_HOME)/bin/icebox --Ice.Config=config.icebox

server-wss: kill build-server
	@echo "Starting server (WSS)"
	@DYLD_PRINT_LIBRARIES=YES LD_LIBRARY_PATH=.:$(ICE_HOME)/lib $(ICE_HOME)/bin/icebox --Ice.Config=config.icebox,config.icebox-wss

kill:
	@echo "Kill all"
	@-killall icebox

clean:
	@echo "Remove all generated files"
	@rm -vf Demo.h Demo.cpp libDemoService.so DemoClientApp *~

.PHONY: slice build-server build-client client client-wss server server-wss kill clean
