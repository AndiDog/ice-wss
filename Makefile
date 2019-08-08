# Usage:
#   export PATH="$(realpath "$(dirname "$(realpath "$(which ccache)")")/../libexec"):${PATH}"
#   make server
#   make client

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
	@echo "Starting client"
	@./DemoClientApp --Ice.Config=config.client

server: kill build
	@echo "Starting server"
	@icebox --Ice.Config=config.icebox

kill:
	@echo "Kill all"
	@-killall icebox

clean: kill
	@echo "Remove all generated files"
	@rm -vf Demo.h Demo.cpp libDemoService.so DemoClientApp *~
