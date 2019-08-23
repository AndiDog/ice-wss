#include <iostream>

#include <Ice/Ice.h>

#include "Demo.h"

class Client : public Ice::Application
{
	auto run(int argc, char** argv) -> int override
	{
		const auto ic = communicator();
		const auto logger = ic->getLogger();
		try
		{
			const auto demo = DemoModule::DemoInterfacePrx::checkedCast(ic->propertyToProxy("DemoInterface.Proxy"));
			demo->method();
		}
		catch (const std::exception& e)
		{
			logger->error(std::string("Caught Exception: ") + e.what());
			return 1;
		}
		catch (...)
		{
			logger->error("Caught unknown exception");
			return 1;
		}
		return 0;
	}
};

int main(int argc, char** argv)
{
	return Client().main(argc, argv);
}
