# Usage:
#   export PATH="$(realpath "$(dirname "$(realpath "$(which ccache)")")/../libexec"):${PATH}"
#   make server
#   make client
#   make server-wss
#   make client-wss

CXX=c++
CXXFLAGS=-std=c++14 -I/usr/local/include -I. -fPIC -pthread -I/usr/local/Cellar/ice36/3.6.4/include
LDFLAGS=-L/usr/local/lib -lIce -lIceBox -lIceUtil -L/usr/local/Cellar/ice36/3.6.4/lib

build:
	@echo "Building..."
	@if [ ! -e Demo.ice.sum ] || [ "$(shasum Demo.ice)" != "$(cat Demo.ice.sum)" ]; then \
		slice2cpp Demo.ice; \
		shasum Demo.ice >Demo.ice.sum; \
	fi
	@$(CXX) $(CXXFLAGS) $(LDFLAGS) Demo.cpp DemoServiceI.cpp -shared -o libDemoService.so
	@$(CXX) $(CXXFLAGS) $(LDFLAGS) DemoClientApp.cpp Demo.cpp -o DemoClientApp

client: build
	@echo "Starting client (WS)"
	@./DemoClientApp --Ice.Config=config.client

client-wss: build
	@echo "Starting client (WSS)"
	@./DemoClientApp --Ice.Config=config.client,config.client-wss

server: kill build
	@echo "Starting server (WS)"
	@icebox --Ice.Config=config.icebox

server-wss: kill build
	@echo "Starting server (WSS)"
	@icebox --Ice.Config=config.icebox,config.icebox-wss

kill:
	@echo "Kill all"
	@-killall icebox

clean: kill
	@echo "Remove all generated files"
	@rm -vf Demo.h Demo.cpp libDemoService.so DemoClientApp *~
