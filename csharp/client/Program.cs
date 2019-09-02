using System;

namespace client
{
    class Program
    {
        static void Main(string[] args)
        {
            int status = 0;
            Ice.Communicator ic = null;
            try
            {
                ic = Ice.Util.initialize(ref args);
                Ice.ObjectPrx b = ic.propertyToProxy("DemoInterface.Proxy");
                DemoModule.DemoInterfacePrx demo = DemoModule.DemoInterfacePrxHelper.checkedCast(b);
                if (demo == null)
                {
                    throw new Exception("Invalid proxy");
                }
                demo.method();
            }
            catch (Exception e)
            {
                Console.Error.WriteLine(e);
                status = 1;
            }
            if (ic != null)
            {
                try
                {
                    ic.destroy();
                }
                catch (Exception e)
                {
                    Console.Error.WriteLine(e);
                    status = 1;
                }
            }
            Environment.Exit(status);
        }
    }
}
