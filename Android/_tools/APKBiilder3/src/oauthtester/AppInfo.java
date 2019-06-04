package oauthtester;

public class AppInfo {
    public String txt_project_name = "";
    public String txt_package_name = "";
    public String txt_api_secret = "";
    public String txt_api_key = "";
    public boolean is_demo = false;
    public String version_code = "";
    public String version_number = "";
    public App_files app_files = new App_files();
    public App_colors app_colors = new App_colors();
    public CertificateDetails certificateDetails = new CertificateDetails();
}

class CertificateDetails {
    public String keyStoreName = "";
    public String keyStorePath = "";
    public String keyStorePassword = "";
    public String aliasName = "";
    public String aliasPassword = "";
}

class App_files {
    public String app_icon = "app_icon.png";
    public String app_splash = "app_splash.png";
}

class App_colors {
    public String txt_color_1 = "#000000";
    public String txt_color_2 = "#000000";
    public String txt_color_3 = "#000000";
    public String txt_color_4 = "#000000";
    public String txt_color_5 = "#000000";
    public String txt_color_6 = "#000000";
    public String txt_color_7 = "#000000";
}