/*
 * OAuthTesterApp.java
 */
package oauthtester;

import org.jdesktop.application.Application;
import org.jdesktop.application.SingleFrameApplication;

/**
 * The main class of the application.
 */
public class OAuthTesterApp extends SingleFrameApplication {

    /**
     * At startup create and show the main frame of the application.
     */
    @Override
    protected void startup() {
        show(new OAuthTesterView(this));
    }

    /**
     * This method is to initialize the specified window by injecting resources.
     * Windows shown in our application come fully initialized from the GUI
     * builder, so this additional configuration is not needed.
     */
    @Override
    protected void configureWindow(java.awt.Window root) {
    }

    /**
     * A convenient static getter for the application instance.
     *
     * @return the instance of OAuthTesterApp
     */
    public static OAuthTesterApp getApplication() {
        return Application.getInstance(OAuthTesterApp.class);
    }

    /**
     * Main method launching the application.
     *
     * @param args
     */
    private static boolean DEBUG_MODE = false;

    public static void main(String[] args) {
        if (DEBUG_MODE) {
            args = new String[2];
            args[0] = "D:\\Android\\AppBuilder\\_setup";
            args[1] = "D:\\Netbeans\\APKBiilder3\\test\\QUETENIS.COM";
        }

        if (args == null || args.length == 0) {
            launch(OAuthTesterApp.class, args);
        } else if (args.length > 1) {
            ProjectSetupWizard projectSetupWizard = new ProjectSetupWizard(args);
            projectSetupWizard.start();
        } else {
            System.out.println("Please check if you have provided correct command arguments.");
        }

        /*
        String testString1 = "CHlBeu59GqGvYYloGyXQuNKhCO81z67S0PwVCn1p";
        String testString2 = "IHGs3XVSUFQ14P7nx4TFe9rvYlWMGqlr9uGB45fs";
        
        String testString3 = Utils.encrypt(testString1, "tmsTore123");
        String testString4 = Utils.encrypt(testString2, "tmsTore123");
        
        String testString5 = testString3.substring(0, testString3.length()-2);
        String testString6 = testString4.substring(0, testString4.length()-2);
        
        System.out.println("------------------------");
        System.out.println(testString5);
        System.out.println(testString6);
        System.out.println("------------------------");
         */
    }
}
