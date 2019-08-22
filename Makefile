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
# ICE_HOME=/Users/asommer/dev/extern/ice-3.6.3/cpp
# ICE_HOME=/Users/asommer/dev/extern/ice-3.6.4/cpp
# ICE_HOME=/tmp/Ice-3.7.1
# ICE_HOME=/tmp/Ice-3.6.4
# ICE_HOME=/tmp/Ice-3.6.3
# ICE_HOME=/usr/local

# `include/generated` is for source builds
CXXFLAGS+= -I$(ICE_HOME)/include -I$(ICE_HOME)/include/generated -I/usr/local/include -I.
LDFLAGS+= -L$(ICE_HOME)/lib -lIce -lIceBox -Wl,-rpath,$(ICE_HOME)/lib:.

JAVA_ICE_CLASSPATH:=	$(shell ls $(ICE_HOME)/../java/lib/{ice,icessl}-3.[0-9].[0-9].jar | tr '\n' ':')

ifneq (,$(wildcard $(ICE_HOME)/lib/libIceUtil*))
LDFLAGS+= -lIceUtil
endif

slice-cpp:
	@$(ICE_HOME)/bin/slice2cpp Demo.ice

slice-java:
	@$(ICE_HOME)/bin/slice2java --output-dir java Demo.ice

build-server: slice-cpp
	@$(CXX) $(CXXFLAGS) $(LDFLAGS) Demo.cpp DemoServiceI.cpp -shared -o libDemoService.so

build-client-cpp: slice-cpp
	@$(CXX) $(CXXFLAGS) $(LDFLAGS) DemoClientApp.cpp Demo.cpp -o DemoClientApp

build-client-java: slice-java
	@cd java \
		&& javac -cp $(JAVA_ICE_CLASSPATH) Client/*.java DemoModule/*.java \
		&& jar -cf App.jar Client/*.class DemoModule/*.class

client: build-client-cpp
	@echo "Starting client (WS)"
	@DYLD_PRINT_LIBRARIES=YES LD_LIBRARY_PATH=.:$(ICE_HOME)/lib ./DemoClientApp --Ice.Config=config.client

client-wss: build-client-cpp
	@echo "Starting client (WSS)"
	@DYLD_PRINT_LIBRARIES=YES LD_LIBRARY_PATH=.:$(ICE_HOME)/lib ./DemoClientApp --Ice.Config=config.client,config.client-wss

client-wss-java: build-client-java
	@echo "Starting client (WSS, Java)"
	@DYLD_PRINT_LIBRARIES=YES java -cp java/App.jar:$(JAVA_ICE_CLASSPATH) Client.App -- --Ice.Config=config.client,config.client-wss,config.client-wss-java

server: kill build-server
	@echo "Starting server (WS)"
	@DYLD_PRINT_LIBRARIES=YES LD_LIBRARY_PATH=.:$(ICE_HOME)/lib $(ICE_HOME)/bin/icebox --Ice.Config=config.icebox

server-wss: kill build-server
	@echo "Starting server (WSS)"
	@DYLD_PRINT_LIBRARIES=YES LD_LIBRARY_PATH=.:$(ICE_HOME)/lib $(ICE_HOME)/bin/icebox --Ice.Config=config.icebox,config.icebox-wss

hosts-entry:
	@grep -wq the-server /etc/hosts || printf "\n# From %s\n127.0.0.1 the-server\n" "$$(pwd)" | sudo tee -a /etc/hosts

kill:
	@echo "Kill all"
	@-killall icebox

clean:
	@echo "Remove all generated files"
	@rm -vf Demo.h Demo.cpp libDemoService.so DemoClientApp *~
	@cd java && rm -vrf DemoModule && find . -name \*.class -exec rm -v {} \;

.PHONY: build-client-cpp
.PHONY: build-client-java
.PHONY: build-server
.PHONY: clean
.PHONY: client
.PHONY: client-wss
.PHONY: hosts-entry
.PHONY: kill
.PHONY: server
.PHONY: server-wss
.PHONY: slice-cpp
.PHONY: slice-java
