#include <iostream>

#include <Ice/Ice.h>
#include <IceBox/IceBox.h>

#include "Demo.h"

class DemoInterfaceI : public DemoModule::DemoInterface
{
public:
	void method(const Ice::Current&)
	{
		std::cout << "Ice service method called" << std::endl;
	}
};

class DemoServiceI : public IceBox::Service
{
	Ice::ObjectAdapterPtr _adapter;

public:
	void start(const std::string& name, const Ice::CommunicatorPtr& communicator, const Ice::StringSeq&)
	{
		_adapter = communicator->createObjectAdapter(name);
		_adapter->add(new DemoInterfaceI(), communicator->stringToIdentity("DemoObject"));
		_adapter->activate();
	}

	virtual void stop()
	{
		_adapter->destroy();
	}
};

extern "C"
{
	ICE_DECLSPEC_EXPORT
	IceBox::Service* create(Ice::CommunicatorPtr communicator)
	{
		return new DemoServiceI;
	}
}
