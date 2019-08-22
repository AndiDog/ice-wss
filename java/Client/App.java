package Client;

public class App {
    public static void main(String[] args) {
        System.out.println("Client starting");

        try (com.zeroc.Ice.Communicator communicator = com.zeroc.Ice.Util.initialize(args)) {
            com.zeroc.Ice.ObjectPrx base = communicator.propertyToProxy("DemoInterface.Proxy");
            DemoModule.DemoInterfacePrx demo = DemoModule.DemoInterfacePrx.checkedCast(base);
            if (demo == null) {
                throw new Error("Invalid proxy");
            }
            demo.method();
        }
    }
}
