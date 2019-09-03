package ClientCompat;

public class App {
    public static void main(String[] args) {
        System.out.println("Client starting");

        try {
            Ice.Communicator communicator = Ice.Util.initialize(args);
            Ice.ObjectPrx base = communicator.propertyToProxy("DemoInterface.Proxy");
            DemoModule.DemoInterfacePrx demo = DemoModule.DemoInterfacePrxHelper.checkedCast(base);
            if (demo == null) {
                throw new Error("Invalid proxy");
            }
            demo.method();
        } catch (Exception e) {
            System.out.println("ERROR: " + e.toString());
            System.exit(1);
        }
        System.exit(0);
    }
}
