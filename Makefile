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

JENV_JAVA_VERSION_COMPAT=	1.7
JAVA_ICE_COMPAT_CLASSPATH:=	$(shell ls $(ICE_HOME)/../java-compat/lib/ice-compat-3.[0-9].[0-9].jar | tr '\n' ':')

ifneq (,$(wildcard $(ICE_HOME)/lib/libIceUtil*))
LDFLAGS+= -lIceUtil
endif

slice-cpp:
	@$(ICE_HOME)/bin/slice2cpp --output-dir cpp Demo.ice

slice-csharp:
	@$(ICE_HOME)/bin/slice2cs --output-dir csharp Demo.ice

slice-java:
	@rm -rf java/DemoModule && $(ICE_HOME)/bin/slice2java --output-dir java Demo.ice

slice-java-compat:
	@rm -rf java-compat/DemoModule && $(ICE_HOME)/bin/slice2java --compat --output-dir java-compat Demo.ice

build-server: slice-cpp
	@cd cpp && $(CXX) $(CXXFLAGS) $(LDFLAGS) Demo.cpp DemoServiceI.cpp -shared -o libDemoService.so

build-client-cpp: slice-cpp
	@cd cpp && $(CXX) $(CXXFLAGS) $(LDFLAGS) DemoClientApp.cpp Demo.cpp -o DemoClientApp

build-client-csharp: slice-csharp
	@cd csharp/client && dotnet build

build-client-java: slice-java
	@rm -f .java-version \
		&& cd java \
		&& javac -cp $(JAVA_ICE_CLASSPATH) Client/*.java DemoModule/*.java \
		&& jar -cf App.jar Client/*.class DemoModule/*.class

build-client-java-compat: slice-java-compat
	@jenv local $(JENV_JAVA_VERSION_COMPAT) \
		&& cd java-compat \
		&& javac -cp $(JAVA_ICE_COMPAT_CLASSPATH) ClientCompat/*.java DemoModule/*.java \
		&& jar -cf AppCompat.jar ClientCompat/*.class DemoModule/*.class

client: build-client-cpp
	@echo "Starting client (WS)"
	@DYLD_PRINT_LIBRARIES=YES LD_LIBRARY_PATH=.:$(ICE_HOME)/lib cpp/DemoClientApp --Ice.Config=config.client

client-wss: build-client-cpp
	@echo "Starting client (WSS)"
	@DYLD_PRINT_LIBRARIES=YES LD_LIBRARY_PATH=.:$(ICE_HOME)/lib cpp/DemoClientApp --Ice.Config=config.client,config.client-wss

client-wss-csharp: build-client-csharp
	@echo "Starting client (WSS, C#)"
	@dotnet run --no-build --no-restore -p csharp/client -- --Ice.Config=config.client,config.client-wss,config.client-wss-csharp --Ice.Plugin.IceSSL=$(ICE_HOME)/../csharp/bin/netcoreapp2.1/IceSSL.dll:IceSSL.PluginFactory

client-wss-java: build-client-java
	@echo "Starting client (WSS, Java)"
	@DYLD_PRINT_LIBRARIES=YES java -cp java/App.jar:$(JAVA_ICE_CLASSPATH) Client.App -- --Ice.Config=config.client,config.client-wss,config.client-wss-java

client-wss-java-compat: build-client-java-compat
	@echo "Starting client (WSS, Java compat)"
	@echo "Using Java version:" \
		&& jenv which java \
		&& DYLD_PRINT_LIBRARIES=YES java -cp java-compat/AppCompat.jar:$(JAVA_ICE_COMPAT_CLASSPATH) ClientCompat.App -- --Ice.Config=config.client,config.client-wss,config.client-wss-java-compat

server: kill build-server
	@echo "Starting server (WS)"
	@DYLD_PRINT_LIBRARIES=YES LD_LIBRARY_PATH=cpp:$(ICE_HOME)/lib $(ICE_HOME)/bin/icebox --Ice.Config=config.icebox

server-wss: kill build-server
	@echo "Starting server (WSS)"
	@DYLD_PRINT_LIBRARIES=YES LD_LIBRARY_PATH=cpp:$(ICE_HOME)/lib $(ICE_HOME)/bin/icebox --Ice.Config=config.icebox,config.icebox-wss

hosts-entry:
	@grep -wq the-server /etc/hosts || printf "\n# From %s\n127.0.0.1 the-server\n" "$$(pwd)" | sudo tee -a /etc/hosts

kill:
	@echo "Kill all"
	@-killall icebox

clean:
	@echo "Remove all generated files"
	@cd cpp && rm -vf Demo.h Demo.cpp libDemoService.so DemoClientApp *~
	@cd csharp && rm -vrf Demo.cs client/bin client/obj
	@cd java && rm -vrf DemoModule && find . -name \*.class -exec rm -v {} \;
	@cd java-compat && rm -vrf DemoModule && find . -name \*.class -exec rm -v {} \;

.PHONY: build-client-cpp
.PHONY: build-client-csharp
.PHONY: build-client-java
.PHONY: build-client-java-compat
.PHONY: build-server
.PHONY: clean
.PHONY: client
.PHONY: client-wss
.PHONY: client-wss-csharp
.PHONY: client-wss-java
.PHONY: client-wss-java-compat
.PHONY: hosts-entry
.PHONY: kill
.PHONY: server
.PHONY: server-wss
.PHONY: slice-cpp
.PHONY: slice-csharp
.PHONY: slice-java
.PHONY: slice-java-compat
