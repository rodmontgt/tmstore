/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package oauthtester;

import java.awt.Desktop;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;

/**
 *
 * @author Ankur
 */
public class ProjectSetupWizard {

    Charset charset = StandardCharsets.UTF_8;
    private String project_root_directroy = "";
    private String setup_directory = "";
    private String current_directory = "";

    String project_directroy = "";
    String iml_file_path = "";

    boolean mPrintConfigOnly = false;

    public ProjectSetupWizard(String[] args) {
        this.setup_directory = args[0];
        this.current_directory = args[1];
        if (args.length == 3) {
            String command = args[2];
            if (command.equals("config")) {
                mPrintConfigOnly = true;
                System.out.println("Command for configuration only : " + command);
            }
        }
        this.project_root_directroy = this.current_directory + "/dump";
    }

    void start() {
        if (!findAndReadJson()) {
            return;
        }

        if (!validateJsonData()) {
            return;
        }

        if (mPrintConfigOnly) {
            // We don't need to copy or build.
            return;
        }

        if (copyProject()) {
            if (renameProject()) {
                if (editProjectFiles()) {
                    if (copyResources()) {
//                                if(setSelectedColors()) {
                        if (generatePropertyFile()) {
//                                        if(compileProject()) {
//                                            if(openAPKFolder()) {
//                                                System.out.println("-- DONE --");
//                                                return;
//                                            }
//                                        } else {
//                                            if(openBuildFolder()) {
//                                                System.out.println("-- DONE --");
//                                                return;
//                                            }
//                                        }
                            //compileProjectRelease();
                            System.out.println("-- PROJECT SETUP DONE --");
                        }
//                                }
                    }
                }
            }
        }
    }

    boolean findAndReadJson() {
        try {
            JSONParser parser = new JSONParser();
            Object obj = parser.parse(new FileReader(current_directory + "/androidapp.json"));
            JSONObject jSONObject = (JSONObject) obj;
            return readJsonData(jSONObject);
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("== error finding json file ==");
            return false;
        }
    }

    String parse_server;
    String parse_app_id;
    String parse_client_key;
    String txt_project_name;
    String txt_display_name;
    String txt_base_url;
    String txt_package_name;
    String build_flavour;

    /*
    String txt_color_1;
    String txt_color_2;
    String txt_color_3;
    String txt_color_4;
    String txt_color_5;
    String txt_color_6;
    String txt_color_7;
     */
    String keyStoreName;
    String keyStorePath;
    String keyStorePassword;
    String aliasName;
    String aliasPassword;
    File keyStore;
    File googleServicesJson;

    File app_icon;
    File app_notification_icon;
    File app_splash;

    File placeholder_banner = null;
    File placeholder_category = null;
    File placeholder_product = null;

    File[] appBanners;

    String mAppSHA1;
    String mAppKeyhash;

    String mGCMSenderId;

    String google_android_geo_api_key;
    String google_admob_app_id;
    String google_admob_interstitial_ad_unit;
    String razorpay_api_key;
    
    boolean is_multi_store = false;
    boolean is_multi_merchant = false;    
    boolean is_intro_splash = false;
    boolean is_intro_anim = false;
    boolean is_search_nearby = false;
    boolean checkReleaseBuilds = true;
    boolean abortOnError = true;
    
    String versionName = "";
    String versionCode = "";

    private boolean openAPKFolder() {
        System.out.println("-- openAPKFolder --");
        try {
            Desktop.getDesktop().open(new File(project_directroy + "/build/outputs/apk"));
            return true;
        } catch (IOException ex) {
            Logger.getLogger(OAuthTesterView.class.getName()).log(Level.SEVERE, null, ex);
            return false;
        }
    }

    private boolean openBuildFolder() {
        System.out.println("-- openBuildFolder --");
        try {
            //Desktop.getDesktop().open(new File(project_directroy + "/build/outputs/apk"));
            Desktop.getDesktop().open(new File(project_root_directroy));
            return true;
        } catch (IOException ex) {
            Logger.getLogger(OAuthTesterView.class.getName()).log(Level.SEVERE, null, ex);
            return false;
        }
    }

    private void compileProjectRelease() {
        try {
            String[] commands = {"cd", this.project_root_directroy};
            String output = Utils.executeCommand(commands);
            System.out.println("== output1: [" + output + "] ==");
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            System.setProperty("user.dir", this.project_root_directroy);
            //String command = this.project_root_directroy+"/gradlew.bat assembleRelease";            
            String[] commands = {this.project_root_directroy + "/gradlew.bat", "assembleRelease"};
            String output = Utils.executeCommand(commands);
            System.out.println("== output2: [" + output + "] ==");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private boolean compileProject() {
        System.out.println("-- compileProject --");
        try {
            String command = project_root_directroy + "\\dump\\compile_release.bat";
            System.out.println("-- command: [" + command + "] --");
            //Process pr = Runtime.getRuntime().exec(command);
            //Runtime.getRuntime().exec(new String[] { "cmd.exe", "/c", command });            
            //Runtime.getRuntime().exec( command );            
            //String result = executeCommand(new String[] { "cmd.exe", "/c", command });
            //String result = executeCommand(command);
            //System.out.println("-- result: ["+result+"] --");

            Desktop.getDesktop().open(new File(command));
            return true;

        } catch (Exception ex) {
            Logger.getLogger(OAuthTesterView.class.getName()).log(Level.SEVERE, null, ex);
            ex.printStackTrace();
            return false;
        }
    }

    private boolean generatePropertyFile() {
        System.out.println("-- generatePropertyFile --");
        try {
            JSONObject jsonText = new JSONObject();
            String testString3 = Utils.encrypt(parse_app_id, "tmsTore123");
            String testString4 = Utils.encrypt(parse_client_key, "tmsTore123");
            String testString5 = testString3.substring(0, testString3.length() - 2);
            String testString6 = testString4.substring(0, testString4.length() - 2);
            jsonText.put("dimension", testString5);
            jsonText.put("dpi", testString6);
            jsonText.put("imagedata", "l9098wqbp9hljas90d7yhsd78hkl0980ihjsd0-9090hhd09908e9298yjhhsd09709712dksd89y0192okjls09d890891kjjks8d0990shkjhsd0870ohas089d\n"
                    + "asd99009sdoihoi09983held89s98893jkj0978784lkksd90734gjhdfljlsd8328jkod90lkd747hgsd;ldf89r7643.khj88skhdf873gwkcnbc,jkod90lkd747hgsd;ldf89r7643.khj88skhdf873gwkcnbc,xc-we7yejdo0d77hsp;jks\n"
                    + "kjbaskhdoi88ehskjdf787ejskodo94977clw;dp9088979s4hvjhvf,hjocu7['pr9puoh;fuy934r8-pdiuf;sofjjsdf974oslhgs7748yhhsiskjdfhf94hdfkksdb3hdy74k\n"
                    + "jkasdilf e8973 foi789wfjhsfssd884ydhjksdd[j9[d}i8djj3b3irf09ewhjnlbkjcio32ihosdfo88sdlksvhjasklasioe3jksklasi3kasdnasdlk3jk3j3i3ios990101");
            System.out.println("== dimension: [" + testString5 + "] ==");
            System.out.println("== dpi: [" + testString6 + "] ==");

            boolean result = TextToGraphics.printDataToFile(jsonText.toString(), ",", project_directroy + "/src/main/assets/" + "data.png");

            /*
            File file = new File(project_directroy+"/src/main/assets/"+"data.png");
            FileOutputStream fileOut = new FileOutputStream(file);
            properties.store(fileOut, "");
            fileOut.close();
            System.out.println("-- Property file created succesfully --");
             */
            //System.exit(0);
            return result;
        } /*catch (FileNotFoundException e) {
            e.printStackTrace();
            System.out.println("-- Property file creation failed 1--");
            return false;
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("-- Property file creation failed 2--");
            return false;
        } */ catch (Exception e) {
            e.printStackTrace();
            System.out.println("-- Property file creation failed 2--");
            return false;
        }
    }

    /*
    private boolean setSelectedColors() {
        try {
            Charset charset = StandardCharsets.UTF_8;

            Path path = Paths.get(project_directroy+"/src/main/res/values/app_colors.xml");

            String search1 = "_txt_color_1_";
            String replacement1 = "#"+txt_color_1;

            String search2 = "_txt_color_2_";
            String replacement2 = "#"+txt_color_2;

            String search3 = "_txt_color_3_";
            String replacement3 = "#"+txt_color_3;

            String search4 = "_txt_color_4_";
            String replacement4 = "#"+txt_color_4;

            String search5 = "_txt_color_5_";
            String replacement5 = "#"+txt_color_5;

            String search6 = "_txt_color_6_";
            String replacement6 = "#"+txt_color_6;

            String search7 = "_txt_color_7_";
            String replacement7 = "#"+txt_color_7;

            String content = new String(Files.readAllBytes(path), charset);
            
            content = content.replaceAll(search1,replacement1);
            content = content.replaceAll(search2,replacement2);
            content = content.replaceAll(search3,replacement3);
            content = content.replaceAll(search4,replacement4);
            content = content.replaceAll(search5,replacement5);
            content = content.replaceAll(search6,replacement6);
            content = content.replaceAll(search7,replacement7);

            Files.write(path, content.getBytes(charset));
            
            System.out.println("-- editing color done.. --");
        }
        catch(Exception e) {
            e.printStackTrace();
            return false;
        }
        return true;
    }
     */
    private boolean copyResources() {
        if (app_icon != null) {
            try {
                Path from = app_icon.toPath(); //convert from File to Path
                Path to = Paths.get(project_directroy + "/src/main/res/drawable/" + app_icon.getName()); //convert from String to Path
                Files.copy(from, to, StandardCopyOption.REPLACE_EXISTING);
            } catch (Exception e) {
                System.out.println("-- copy app icon image failed --");
                e.printStackTrace();
                return false;
            }
        }

        if (app_notification_icon != null) {
            try {
                Path from = app_notification_icon.toPath(); //convert from File to Path
                Path to = Paths.get(project_directroy + "/src/main/res/drawable/ic_stat.png"); //convert from String to Path
                Files.copy(from, to, StandardCopyOption.REPLACE_EXISTING);
            } catch (Exception e) {
                System.out.println("-- copy app notification icon image failed --");
                e.printStackTrace();
                return false;
            }
        }

        if (app_splash != null) {
            try {
                Path from = app_splash.toPath(); //convert from File to Path
                Path to = Paths.get(project_directroy + "/src/main/res/drawable-hdpi/" + app_splash.getName()); //convert from String to Path
                Files.copy(from, to, StandardCopyOption.REPLACE_EXISTING);
            } catch (Exception e) {
                System.out.println("-- copy app splash image failed --");
                e.printStackTrace();
                return false;
            }
        }

        if (appBanners != null && appBanners.length > 0) {
            try {
                for (int i = 0; i < appBanners.length; i++) {
                    Path from = appBanners[i].toPath();
                    Path to = Paths.get(project_directroy + "/src/main/res/drawable/" + appBanners[i].getName()); //convert from String to Path
                    Files.copy(from, to, StandardCopyOption.REPLACE_EXISTING);
                }
            } catch (Exception e) {
                System.out.println("-- copy app icon image failed --");
                e.printStackTrace();
                return false;
            }
        }

        if (keyStore != null) {
            try {
                Path from = keyStore.toPath(); //convert from File to Path
                Path to = Paths.get(project_directroy + "/" + keyStore.getName()); //convert from String to Path
                Files.copy(from, to, StandardCopyOption.REPLACE_EXISTING);
            } catch (Exception e) {
                System.out.println("-- copy app Signing Key failed --");
                e.printStackTrace();
                return false;
            }
        }

        if (googleServicesJson != null) {
            System.out.println("-- googleServicesJson != null --");
            try {
                Path from = googleServicesJson.toPath(); //convert from File to Path
                //String googleJsonWritePath = project_directroy+"/src/main/assets/"+googleServicesJson.getName();
                String googleJsonWritePath = project_directroy + "/" + googleServicesJson.getName();
                //Path to = Paths.get(googleJsonWritePath); //convert from String to Path               
                //System.out.println("-- copying google json from 1: ["+from.toString()+"] to ["+to.toString()+"] --");
                //Files.copy(from, to, StandardCopyOption.REPLACE_EXISTING);

                Path to2 = Paths.get(googleJsonWritePath); //convert from String to Path
                System.out.println("-- copying google json from 2: [" + from.toString() + "] to [" + to2.toString() + "] --");
                Files.copy(from, to2, StandardCopyOption.REPLACE_EXISTING);
            } catch (Exception e) {
                System.out.println("-- copy googleServicesJson failed --");
                e.printStackTrace();
                return false;
            }
        } else {
            System.out.println("-- googleServicesJson == null --");
        }

        {
            System.out.println("-- COPYING REQUESTED RES --");
            File srcFolder = new File(current_directory + "/res");
            File destFolder = new File(project_directroy + "/src/main/res");
            //make sure source exists
            if (srcFolder.exists()) {
                try {
                    copyFolder(srcFolder, destFolder);
                    System.out.println("*** copy requested res :: succeed ***");
                } catch (IOException e) {
                    System.out.println("*** copy requested res :: failed ***");
                    e.printStackTrace();
                    return false;
                }
            }
        }

        {
            System.out.println("-- COPYING REQUESTED ASSETS --");
            File srcFolder = new File(current_directory + "/assets");
            if (srcFolder.exists()) {
                try {
                    File destFolder = new File(project_directroy + "/src/main/assets");
                    copyFolder(srcFolder, destFolder);
                    System.out.println("*** copy requested assets :: succeed ***");
                } catch (IOException e) {
                    System.out.println("*** copy requested assets :: failed ***");
                    e.printStackTrace();
                    return false;
                }
            }
        }

        return true;
    }

    private boolean editProjectFiles() {
        System.out.println("-- editProjectFiles --");
        //String projectName = txt_project_name.getText().trim().replaceAll("\\s","");
        try {
            Charset charset = StandardCharsets.UTF_8;
            {
                Path path1 = Paths.get(iml_file_path);
                String search1 = "_ProjectName_";  // <- changed to work with String.replaceAll()
                String replacement1 = txt_project_name;

                String content1 = new String(Files.readAllBytes(path1), charset);
                content1 = content1.replaceAll(search1, replacement1);
                Files.write(path1, content1.getBytes(charset));
                System.out.println("-- editing 1 done.. --");
            }

            {
                Path path2 = Paths.get(project_directroy + "/build.gradle");

                String search1 = "com.tmstore";  // <- changed to work with String.replaceAll()
                String replacement1 = txt_package_name;

                String search2 = "_storeFile_";  // <- changed to work with String.replaceAll()
                String replacement2 = keyStoreName;

//                if(appSigningKey != null) {
//                    replacement2 = appSigningKey.getName();
//                }
                String search3 = "_storePassword_";  // <- changed to work with String.replaceAll()
                //String replacement3 = txt_store_password.getText().trim();
                String replacement3 = keyStorePassword;

                String search4 = "_keyAlias_";  // <- changed to work with String.replaceAll()
                //String replacement4 = txt_key_alias.getText().trim();
                String replacement4 = aliasName;

                String search5 = "_keyPassword_";  // <- changed to work with String.replaceAll()
                //String replacement5 = txt_key_password.getText().trim();
                String replacement5 = aliasPassword;

                // Patch for TMStoreDemo app package name override issue
                String search6 = "com.tmstore.tmstoredemo";
                String replacement6 = "com.tmstore";

                String content = new String(Files.readAllBytes(path2), charset);
                content = content.replaceAll(search1, replacement1);
                content = content.replaceAll(search2, replacement2);
                content = content.replaceAll(search3, replacement3);
                content = content.replaceAll(search4, replacement4);
                content = content.replaceAll(search5, replacement5);
                content = content.replaceAll(search6, replacement6);
                Files.write(path2, content.getBytes(charset));
                System.out.println("-- editing 2 done.. --");
            }
                // Increament Version Code and Version Name
            if (!Utils.isEmptyString(versionCode) && Utils.isEmptyString(versionName)){
                Path filePath = Paths.get(project_directroy + "/src/main/AndroidManifest.xml");
                String search = "android:versionName=";
                String replacement = "android:versionName=\"" + versionName + "\"";
                String content = new String(Files.readAllBytes(filePath), charset);
                int start, end;
                
                start = content.indexOf(search);
                end = -1;
                if (start != -1) {
                    end = content.indexOf('"', start);
                    end = content.indexOf('"', end + 1);
                    search = content.substring(start, end);
                    content = content.replaceAll(search, replacement);
                }
                
                search = "android:versionCode=";
                replacement = "android:versionCode=\"" + versionCode + "\"";
                start = content.indexOf(search);
                end = -1;
                if (start != -1) {
                    end = content.indexOf('"', start);
                    end = content.indexOf('"', end + 1);
                    search = content.substring(start, end);
                    content = content.replaceAll(search, replacement);
                }           
                
                Files.write(filePath, content.getBytes(charset));
                System.out.println("-- editing versionName and versionCode done.. --");
            } else {
                Path filePath = Paths.get(project_directroy + "/src/main/AndroidManifest.xml");
                String content = new String(Files.readAllBytes(filePath), charset);

                String search;
                int start;

                // Increment Version Name
                search = "android:versionName=";
                start = content.indexOf(search);
                if (start != -1) {
                    int s = content.indexOf('"', start) + 1;
                    int e = content.indexOf('"', s);
                    try {
                        String nameString = content.substring(s, e);
                        search += "\"";
                        search += nameString;
                        search += "\"";
                        nameString = nameString.replace(".", "");
                        nameString = Integer.toString(Integer.parseInt(nameString) + 1);
                        StringBuilder str = new StringBuilder();
                        for (int i = 0; i < nameString.length(); i++) {
                            str.append(nameString.charAt(i));
                            if (i < nameString.length() - 1) {
                                str.append(".");
                            }
                        }
                        String replacement = "android:versionName=\"" + str + "\"";
                        content = content.replace(search, replacement);
                        System.out.println(content);
                    } catch (NumberFormatException error) {
                        error.printStackTrace();
                    }
                }

                // Increment Version Code
                search = "android:versionCode=";
                start = content.indexOf(search);
                if (start != -1) {
                    int s = content.indexOf('"', start) + 1;
                    int e = content.indexOf('"', s);
                    try {
                        String codeString = content.substring(s, e);
                        search += "\"";
                        search += codeString;
                        search += "\"";
                        codeString = Integer.toString(Integer.parseInt(codeString) + 1);
                        String replacement = "android:versionCode=\"" + codeString + "\"";
                        content = content.replace(search, replacement);
                        System.out.println(content);
                    } catch (NumberFormatException error) {
                        error.printStackTrace();
                    }
                }
                Files.write(filePath, content.getBytes(charset));
                System.out.println("-- editing versionName and versionCode done.. --");
            }
           
            {
                try {
                    String search3 = "_ProjectName_";  // <- changed to work with String.replaceAll()
                    String replacement3 = txt_display_name;
                    String fileName = project_directroy + "/src/main/res/values/app_strings.xml";
                    //Utils.replaceInFile(fileName, search3, replacement3);

                    System.out.println("== txt_display_name: [ " + replacement3 + " ] ==");

                    Path path3 = Paths.get(fileName);
                    String content2 = new String(Files.readAllBytes(path3), charset);
                    content2 = content2.replaceAll(search3, replacement3);
                    
                    // Replace host_url => __host_url__
                    content2 = content2.replaceAll("__host_url__", txt_base_url);

                    // Replace parse_server
                    content2 = content2.replaceAll("__parse_server__", parse_server);

                    // Replace GCMSenderId
                    String defaultGCMSenderId = "id:xxxxxxxxxxxx";
                    if (content2.contains(defaultGCMSenderId)) {
                        if (mGCMSenderId == null || mGCMSenderId.length() == 0 || mGCMSenderId.equals("null")) {
                            mGCMSenderId = defaultGCMSenderId;
                        } else {
                            // Prefix 'id:' for back4app meta tag 'gcm_sender_id' in 'AndroidManifest.xml'
                            mGCMSenderId = "id:" + mGCMSenderId;
                        }
                        content2 = content2.replaceAll(defaultGCMSenderId, mGCMSenderId);
                    } else {
                        System.out.println("-- 'gcm_sender_id' is not defined in app_strings.xml --");
                    }
                    
                    // Replace google_android_geo_api_key in app_strings.xml              
                    if (content2.contains("__google_android_geo_api_key__")) {
                        if (Utils.isEmptyString(google_android_geo_api_key)) {
                            google_android_geo_api_key = "";
                        }
                        content2 = content2.replaceAll("__google_android_geo_api_key__", google_android_geo_api_key);
                    } else {
                        System.out.println("-- 'google_android_geo_api_key' is not defined in app_strings.xml --");
                    }
                    
                    // Replace google_admob_app_id in app_strings.xml    
                    if (content2.contains("__google_admob_app_id__")) {
                        if (Utils.isEmptyString(google_admob_app_id)) {
                            google_admob_app_id = "";
                        }
                        content2 = content2.replaceAll("__google_admob_app_id__", google_admob_app_id);
                    } else {
                        System.out.println("-- 'google_admob_app_id' is not defined in app_strings.xml --");
                    }
                    
                    // Replace google_admob_app_id in app_strings.xml    
                    if (content2.contains("__google_admob_interstitial_ad_unit__")) {
                        if (Utils.isEmptyString(google_admob_interstitial_ad_unit)) {
                            google_admob_interstitial_ad_unit = "";
                        }
                        content2 = content2.replaceAll("__google_admob_interstitial_ad_unit__", google_admob_interstitial_ad_unit);
                    } else {
                        System.out.println("-- 'google_admob_interstitial_ad_unit' is not defined in app_strings.xml --");
                    }
                    
                    // Replace razorpay_api_key in app_strings.xml              
                    if (content2.contains("__razorpay_api_key__")) {
                        if (Utils.isEmptyString(razorpay_api_key)) {
                            razorpay_api_key = "";
                        }
                        content2 = content2.replaceAll("__razorpay_api_key__", razorpay_api_key);
                    } else {
                        System.out.println("-- 'razorpay_api_key' is not defined in app_strings.xml --");
                    }                  
                    
                    Files.write(path3, content2.getBytes(charset));                  
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }

            {
                Path path2 = Paths.get(project_directroy + "/google-services.json");
                String search1 = "com.tmstore";  // <- changed to work with String.replaceAll()
                String replacement1 = txt_package_name;

                String content = new String(Files.readAllBytes(path2), charset);
                content = content.replaceAll(search1, replacement1);
                Files.write(path2, content.getBytes(charset));
            }
            {
                Path path = Paths.get(project_directroy + "/build.gradle");
                String content = new String(Files.readAllBytes(path), charset);
                
                if (is_search_nearby) {
                    String search = "IS_SEARCH_NEARBY = \"false\"";
                    String replace = "IS_SEARCH_NEARBY = \"true\"";
                    content = content.replaceAll(search, replace);
                }
                
                if (is_multi_store) {
                    String search = "IS_MULTI_STORE = \"false\"";
                    String replace = "IS_MULTI_STORE = \"true\"";
                    content = content.replaceAll(search, replace);
                }

                if (is_multi_merchant) {
                    String search = "IS_MULTI_MERCHANT = \"false\"";
                    String replace = "IS_MULTI_MERCHANT = \"true\"";
                    content = content.replaceAll(search, replace);                    
                }
                
                if (is_intro_splash) {
                    String search = "IS_INTRO_SPLASH = \"false\"";
                    String replace = "IS_INTRO_SPLASH = \"true\"";
                    content = content.replaceAll(search, replace);                    
                }
                
                if (is_intro_anim) {
                    String search = "IS_INTRO_ANIM = \"false\"";
                    String replace = "IS_INTRO_ANIM = \"true\"";
                    content = content.replaceAll(search, replace);
                }

                if(!checkReleaseBuilds) {
                    String search = "checkReleaseBuilds true";
                    String replace = "checkReleaseBuilds false";
                    content = content.replaceAll(search, replace);
                }

                if(!abortOnError) {                    
                    String search = "abortOnError true";
                    String replace = "abortOnError false";
                    content = content.replaceAll(search, replace);
                }
                Files.write(path, content.getBytes(charset));
            }

            // out of date
            /*
            if(appBanners!=null && appBanners.length>0) {
                Path path3 = Paths.get(project_directroy+"/src/main/res/values/app_strings.xml");
                String search3 = "<!--_banners_-->";  // <- changed to work with String.replaceAll()
                String replacement3 = "";
                for(int i=0; i<appBanners.length; i++) {
                    replacement3 += "<item>@drawable/app_banner"+i+"</item>\n";
                }
                String content3 = new String(Files.readAllBytes(path3), charset);
                content3 = content3.replaceAll(search3,replacement3);
                Files.write(path3, content3.getBytes(charset));
                System.out.println("-- editing 3 done.. --");
            }
             */
            {
                Path path4 = Paths.get(project_root_directroy + "/settings.gradle");
                String search4 = "_ProjectName_";  // <- changed to work with String.replaceAll()
                String replacement4 = txt_project_name;

                String content4 = new String(Files.readAllBytes(path4), charset);
                content4 = content4.replaceAll(search4, replacement4);
                Files.write(path4, content4.getBytes(charset));
                System.out.println("-- editing 4 done.. --");
            }

            {
                Path path4 = Paths.get(project_root_directroy + "/compile_debug.bat");
                String search4 = "_ProjectName_";  // <- changed to work with String.replaceAll()
                String replacement4 = project_root_directroy.replace("\\", "/");

                String content4 = new String(Files.readAllBytes(path4), charset);
                content4 = content4.replaceAll(search4, replacement4);
                Files.write(path4, content4.getBytes(charset));
                System.out.println("-- editing 5 done.. --");
            }

            {
                Path path4 = Paths.get(project_root_directroy + "/compile_release.bat");
                String search4 = "_ProjectName_";  // <- changed to work with String.replaceAll()
                String replacement4 = project_root_directroy.replace("\\", "/");

                String content4 = new String(Files.readAllBytes(path4), charset);
                content4 = content4.replaceAll(search4, replacement4);
                Files.write(path4, content4.getBytes(charset));
                System.out.println("-- editing 6 done.. --");
            }

            {
                Path path4 = Paths.get(project_root_directroy + "/compile_release.bat");
                String search4 = "_FLAVOUR_";  // <- changed to work with String.replaceAll()
                String replacement4 = build_flavour;

                String content4 = new String(Files.readAllBytes(path4), charset);
                content4 = content4.replaceAll(search4, replacement4);
                Files.write(path4, content4.getBytes(charset));
                System.out.println("-- editing 7 done.. --");
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private boolean renameProject() {
        System.out.println("-- renameProject --");

        File imlDirOld = new File(project_root_directroy + "/_ProjectName_");
        File imlDirNew = new File(project_root_directroy + "/" + txt_project_name);

        System.out.println("-- [" + imlDirOld.getPath() + "] --> [" + imlDirNew.getPath() + "] --");

        if (imlDirOld.renameTo(imlDirNew)) {
            System.out.println("renamed");
            project_directroy = imlDirNew.getPath();
            System.out.println("--# project_directroy: [" + project_directroy + "] #--");

            File imlFileOld = new File(project_directroy + "/_ProjectName_.iml");
            File imlFileNew = new File(project_directroy + "/" + txt_project_name + ".iml");

            System.out.println("-- [" + imlFileOld.getPath() + "] --> [" + imlFileNew.getPath() + "] --");

            if (imlFileOld.renameTo(imlFileNew)) {
                System.out.println("renamed");
                iml_file_path = imlFileNew.getPath();
                System.out.println("*** iml_file_path: [" + iml_file_path + "] ***");
                return true;
            } else {
                System.out.println("Error");
                return false;
            }
        } else {
            System.out.println("Error");
            return false;
        }
    }

    private boolean copyProject() {
        File srcFolder = new File(setup_directory);
        File destFolder = new File(project_root_directroy);

        //make sure source exists
        if (!srcFolder.exists()) {
            System.out.println("== refrence Directory does not exist. ==");
            return false;
        } else {
            try {
                copyFolder(srcFolder, destFolder);
                System.out.println("*** copyProject :: succeed ***");
                return true;
            } catch (IOException e) {
                System.out.println("*** copyProject :: failed ***");
                e.printStackTrace();
                return false;
            }
        }
    }

    boolean validateJsonData() {

        if (app_icon == null) {
            System.out.println("== app_icon is null ==");
            return false;
        }

        if (app_splash == null) {
            System.out.println("== app_splash is null ==");
            return false;
        }

        if (appBanners == null) {
            System.out.println("== appBanners is null, but its Ok :) ==");
        } else {
            for (int i = 0; i < appBanners.length; i++) {
                if (appBanners[i] == null) {
                    System.out.println("== appBanner[" + i + "] is null ==");
                    return false;
                }
            }
        }

        if (keyStore == null) {
            System.out.println("== keyStore is null ==");
            return false;
        }

        return true;
    }

    boolean readJsonData(JSONObject jSONObject) {
        try {
            if(jSONObject.containsKey("parse_server")) {
                parse_server = jSONObject.get("parse_server").toString();
            } else {
                parse_server = "https://parseapi.back4app.com/";
            }
            parse_app_id = jSONObject.get("parse_app_id").toString();
            parse_client_key = jSONObject.get("parse_client_key").toString();
            txt_project_name = jSONObject.get("txt_project_name").toString();

            //ICU
            {
                txt_project_name = txt_project_name.trim();
                txt_project_name = txt_project_name.replaceAll("[^\\w\\s-]", "");
            }

            if (jSONObject.containsKey("txt_display_name")) {
                txt_display_name = jSONObject.get("txt_display_name").toString();
                if (txt_display_name == null || txt_display_name.length() == 0) {
                    txt_display_name = txt_project_name;
                }
            } else {
                txt_display_name = txt_project_name;
            }

            //System.out.println("=###= txt_display_name : [ "+txt_display_name+" ] ###==");
            //System.out.println("=###= default name 1 : [ "+"Мапуз"+" ] ###==");
            //System.out.println("=###= default name 2 : [ "+"تعطي يونيكود رقما فريدا لكل حرف"+" ] ###==");
            //System.exit(0);
            if (jSONObject.containsKey("txt_base_url")) {
                txt_base_url = jSONObject.get("txt_base_url").toString();
                if (txt_base_url == null || txt_base_url.length() == 0) {
                    txt_base_url = txt_project_name;
                }
                txt_base_url = txt_base_url.replace("\\", "/");
                if (txt_base_url.contains("://")) {
                    txt_base_url = txt_base_url.split("://")[1];
                }
            } else {
                txt_base_url = txt_project_name;
            }

            if (jSONObject.containsKey("build_flavour")) {
                build_flavour = jSONObject.get("build_flavour").toString();
            } else {
                build_flavour = "Common";
            }

            txt_package_name = jSONObject.get("txt_package_name").toString();

            /*
            JSONObject app_colors = (JSONObject) jSONObject.get("app_colors");
            {
                txt_color_1 = app_colors.get("txt_color_1").toString();
                txt_color_2 = app_colors.get("txt_color_2").toString();
                txt_color_3 = app_colors.get("txt_color_3").toString();
                txt_color_4 = app_colors.get("txt_color_4").toString();
                txt_color_5 = app_colors.get("txt_color_5").toString();
                txt_color_6 = app_colors.get("txt_color_6").toString();
                txt_color_7 = app_colors.get("txt_color_7").toString();
            }
             */
            JSONObject app_files = (JSONObject) jSONObject.get("app_files");
            {

                String path_app_icon = app_files.get("app_icon").toString();
                if (path_app_icon != null) {
                    app_icon = new File(current_directory + "/" + path_app_icon);
                }

                String path_appNotificationIcon = "";
                if (app_files.containsKey("app_notification_icon")) {
                    path_appNotificationIcon = app_files.get("app_notification_icon").toString();
                } else {
                    path_appNotificationIcon = app_files.get("app_icon").toString();
                }
                if (path_appNotificationIcon != null) {
                    app_notification_icon = new File(current_directory + "/" + path_appNotificationIcon);
                }

                String path_app_splash = app_files.get("app_splash").toString();
                if (path_app_splash != null) {
                    app_splash = new File(current_directory + "/" + path_app_splash);
                }

                JSONArray appBannersJson = (JSONArray) app_files.get("app_banners");

                if (appBannersJson != null && appBannersJson.size() > 0) {
                    appBanners = new File[appBannersJson.size()];
                    for (int i = 0; i < appBannersJson.size(); i++) {
                        appBanners[i] = new File(current_directory + "/" + appBannersJson.get(i).toString());
                    }
                }
            }

            // GCMSenderId for notifications from cloud server.
            if (jSONObject.containsKey("gcm_sender_id")) {
                mGCMSenderId = jSONObject.get("gcm_sender_id").toString();
            }

            // Google Android Geo-Location Api Key for Maps.
            if (jSONObject.containsKey("google_android_geo_api_key")) {
                google_android_geo_api_key = jSONObject.get("google_android_geo_api_key").toString().trim();
            }
            
            // Google AdMob App ID.
            if (jSONObject.containsKey("google_admob_app_id")) {
                google_admob_app_id = jSONObject.get("google_admob_app_id").toString().trim();
            }
            
            // Google AdMob Interstitial Ad Unit.
            if (jSONObject.containsKey("google_admob_interstitial_ad_unit")) {
                google_admob_interstitial_ad_unit = jSONObject.get("google_admob_interstitial_ad_unit").toString().trim();
            }
            
            // RazorPay API Key.
            if (jSONObject.containsKey("razorpay_api_key")) {
                razorpay_api_key = jSONObject.get("razorpay_api_key").toString().trim();
            }
            
            // Read MultiStore configuration..
            if (jSONObject.containsKey("is_multi_store")) {
                is_multi_store = (Boolean) jSONObject.get("is_multi_store");
            }
            
            // Read MultiStore search nearby configuration..
            if (jSONObject.containsKey("is_search_nearby")) {
                is_search_nearby = (Boolean) jSONObject.get("is_search_nearby");
            }
            
            // Read MultiMerchant configuration..
            if (jSONObject.containsKey("is_multi_merchant")) {
                is_multi_merchant = (Boolean) jSONObject.get("is_multi_merchant");
            }
            
            // Read intro splash configuration
            if (jSONObject.containsKey("is_intro_splash")) {
                is_intro_splash = (Boolean) jSONObject.get("is_intro_splash");
            }
            
            // Read intro animation configuration..
            if (jSONObject.containsKey("is_intro_anim")) {
                is_intro_anim = (Boolean) jSONObject.get("is_intro_anim");
            }
            
            // lint check for release build 
            if (jSONObject.containsKey("checkReleaseBuilds")) {
                checkReleaseBuilds = (Boolean) jSONObject.get("checkReleaseBuilds");
            }
            
             // abort on lint error 
            if (jSONObject.containsKey("abortOnError")) {
                abortOnError = (Boolean) jSONObject.get("abortOnError");
            }
            
            // Version Name
            if(jSONObject.containsKey("versionName")) {
                versionName = (String)jSONObject.get("versionName");
            }
            
            // Version Code
            if(jSONObject.containsKey("versionCode")) {
                versionCode = (String)jSONObject.get("versionCode");
            }

            {
                try {
                    String googleJsonReadPath = current_directory + "/" + "google-services.json";
                    System.out.println("-- googleJsonReadPath:[" + googleJsonReadPath + "]--");
                    googleServicesJson = new File(googleJsonReadPath);
                    if (!googleServicesJson.exists()) {
                        System.out.println(" - googleServicesJson is not created yet, so clearing it --");
                        googleServicesJson = null;
                    }
                    System.out.println(" - googleServicesJson found for project --");
                } catch (Exception e) {
                    System.out.println(" - googleServicesJson not found for this project --");
                    googleServicesJson = null;
                    e.printStackTrace();
                }
            }

            JSONObject certificateDetails = (JSONObject) jSONObject.get("certificateDetails");
            {
                keyStoreName = certificateDetails.get("keyStoreName").toString().trim();
                //keyStorePath = certificateDetails.get("keyStorePath").toString();
                keyStorePath = current_directory;
                keyStorePassword = certificateDetails.get("keyStorePassword").toString();
                aliasName = certificateDetails.get("aliasName").toString();
                aliasPassword = certificateDetails.get("aliasPassword").toString();

                keyStore = new File(current_directory + "/" + keyStoreName);
                System.out.println(" - keystore path to chk [" + keyStore.getPath() + "] --");

                if (keyStore.exists()) {
                    System.out.println(" == Key store exists, so continue with build ==");
                    return printCertificateSignatures();
                } else {
                    JSONObject contact_details = (JSONObject) certificateDetails.get("contact_details");
                    String companyDetailString = generateCompnayDetailString(contact_details);
                    System.out.println(" == keystore does not exist for [" + txt_project_name + "] hence creating a new one == ");
                    return generateKeyStore(companyDetailString);
                }
            }
        } catch (Exception e) {
            System.out.println("== error reading json data ==");
            e.printStackTrace();
            return false;
        }
    }

    private boolean printCertificateSignatures() {
        if (!isKeyHashPrinted()) {
            printKeyHashInFile();
        }

        if (!isSha1Printed()) {
            printSHAInFile();
        }

        if (!isConfigPrinted()) {
            generateKeyHash();
            generateSHA1();
            printConfigInFile();
        }
        return true;
    }

    private boolean isSha1Printed() {
        String outputPath = current_directory + "/keySHA_" + txt_project_name + ".txt";
        File outputFile = new File(outputPath);
        return outputFile.exists();
    }

    private boolean isKeyHashPrinted() {
        String outputPath = current_directory + "/keyhash_" + txt_project_name + ".txt";
        File outputFile = new File(outputPath);
        return outputFile.exists();
    }

    private boolean isConfigPrinted() {
        String outputPath = current_directory + "/configuration.json";
        File outputFile = new File(outputPath);
        return outputFile.exists();
    }

//    private boolean generateKeyStore(String companyDetailString) {
//        System.out.println("-- generateKeyStore --");
//        try {            
//            String command = "echo lalalalalaa>hahahaha.txt";
//            System.out.println("-- command: ["+command+"] --");
//            //String result = Utils.executeCommand(command);
//            {
//                ProcessBuilder pb = new ProcessBuilder(command);
//                pb.redirectOutput(Redirect.INHERIT);
//                pb.redirectError(Redirect.INHERIT);
//                Process p = pb.start();
//            }
//            //System.out.println("-- result: ["+result+"] --");
//            return false;
//        } catch (Exception ex) {
//            Logger.getLogger(OAuthTesterView.class.getName()).log(Level.SEVERE, null, ex);
//            ex.printStackTrace();
//            return false;
//        }
//    }
    private boolean generateKeyStore(String companyDetailString) {
        System.out.println("-- generateKeyStore --");
        try {
            String command = "keytool -genkeypair -dname \"" + companyDetailString + "\" -alias " + aliasName + " -keypass " + aliasPassword + " -keystore \"" + keyStorePath + "/" + keyStoreName + "\" -storepass " + keyStorePassword + " -validity 9999";
            System.out.println("-- command: [" + command + "] --");
            String result = Utils.executeCommand(command);
            System.out.println("-- result: [" + result + "] --");
            if (result.equals("")) {
                return printCertificateSignatures();
            } else {
                return false;
            }
        } catch (Exception ex) {
            Logger.getLogger(OAuthTesterView.class.getName()).log(Level.SEVERE, null, ex);
            ex.printStackTrace();
            return false;
        }
    }

    private boolean printKeyHashInFile() {
        System.out.println("-- printKeyHashInFile --");
        try {
            String keyStoreFullPath = keyStorePath + "/" + keyStoreName;
            //keyStoreFullPath = keyStoreFullPath.replace("\\","/");

            System.out.println("== keyStoreFullPath: [" + keyStoreFullPath + "] ==");
            String[] commands = {
                "cmd", "/C",
                "keytool -exportcert -alias " + aliasName + " -keystore \"" + keyStoreFullPath + "\" -storepass " + keyStorePassword + " | openssl sha1 -binary | openssl base64"
            };
            System.out.println("--   command2: [" + commands[2] + "] --");
            String outputPath = current_directory + "/keyhash_" + txt_project_name + ".txt";
            outputPath = outputPath.replace("\\", "\\\\");
            File outputFile = new File(outputPath);
            boolean b1 = Utils.executeCommandInFile(commands, outputFile);
            System.out.println("-- b1: [" + b1 + "] --");
            return (b1 && printSHAInFile());
        } catch (Exception ex) {
            Logger.getLogger(OAuthTesterView.class.getName()).log(Level.SEVERE, null, ex);
            ex.printStackTrace();
            return false;
        }
    }

    private void generateKeyHash() {
        System.out.println("-- generateKeyHash --");
        try {
            String keyStoreFullPath = keyStorePath + "/" + keyStoreName;
            //keyStoreFullPath = keyStoreFullPath.replace("\\","/");          
            System.out.println("== keyStoreFullPath: [" + keyStoreFullPath + "] ==");
            String[] commands = {
                "cmd", "/C",
                "keytool -exportcert -alias " + aliasName + " -keystore \"" + keyStoreFullPath + "\" -storepass " + keyStorePassword + " | openssl sha1 -binary | openssl base64"
            };
            System.out.println("--   command2: [" + commands[2] + "] --");
            mAppKeyhash = Utils.executeCommand(commands);
            System.out.println("-- keyhash : [" + mAppKeyhash + "] --");
        } catch (Exception ex) {
            Logger.getLogger(OAuthTesterView.class.getName()).log(Level.SEVERE, null, ex);
            ex.printStackTrace();
        }
    }

    private boolean printSHAInFile() {
        System.out.println("-- printSHAInFile --");
        System.out.println("== keyStorePath: [" + keyStorePath + "] ==");
        System.out.println("== keyStoreName: [" + keyStoreName + "] ==");
        System.out.println("== aliasName: [" + aliasName + "] ==");
        System.out.println("== aliasPassword: [" + aliasPassword + "] ==");
        System.out.println("== keypass: [" + aliasPassword + "] ==");

        try {
            String keyStoreFullPath = keyStorePath + "/" + keyStoreName;
            keyStoreFullPath = keyStoreFullPath.replace("\\", "/");
            System.out.println("== keyStoreFullPath: [" + keyStoreFullPath + "] ==");

            String[] command3 = {
                //"sh", "-c", // for linus and mac
                "cmd", "/C", // for windows only
                //"keytool -exportcert -alias " + aliasName + " -keystore \""+ keyStorePath +"/"+ keyStoreName + "\" -storepass " + aliasPassword + " | openssl sha1 -binary | openssl base64"
                "keytool -list -v -keystore \"" + keyStoreFullPath + "\" -alias " + aliasName + " -storepass " + aliasPassword + " -keypass " + aliasPassword + ""
            };
            System.out.println("--   command3: [" + command3[2] + "] --");
            String outputPath = current_directory + "/keySHA_" + txt_project_name + ".txt";
            outputPath = outputPath.replace("\\", "\\\\");
            System.out.println("== outputPath : [" + outputPath + "] ==");
            File outputFile = new File(outputPath);
            boolean b2 = Utils.executeCommandInFile(command3, outputFile);
            System.out.println("-- b2: [" + b2 + "] --");
            return b2;
        } catch (Exception ex) {
            Logger.getLogger(OAuthTesterView.class.getName()).log(Level.SEVERE, null, ex);
            ex.printStackTrace();
            return false;
        }
    }

    private void generateSHA1() {
        System.out.println("-- generateSHA1 --");
        System.out.println("== keyStorePath: [" + keyStorePath + "] ==");
        System.out.println("== keyStoreName: [" + keyStoreName + "] ==");
        System.out.println("== aliasName: [" + aliasName + "] ==");
        System.out.println("== aliasPassword: [" + aliasPassword + "] ==");
        System.out.println("== keypass: [" + aliasPassword + "] ==");

        try {
            String keyStoreFullPath = keyStorePath + "/" + keyStoreName;
            keyStoreFullPath = keyStoreFullPath.replace("\\", "/");
            System.out.println("== keyStoreFullPath: [" + keyStoreFullPath + "] ==");
            String[] commands = {
                //"sh", "-c", // for linux and mac
                "cmd", "/C", // for windows only
                //"keytool -exportcert -alias " + aliasName + " -keystore \""+ keyStorePath +"/"+ keyStoreName + "\" -storepass " + aliasPassword + " | openssl sha1 -binary | openssl base64"
                "keytool -list -v -keystore \"" + keyStoreFullPath + "\" -alias " + aliasName + " -storepass " + aliasPassword + " -keypass " + aliasPassword + ""
            };
            System.out.println("--   command3: [" + commands[2] + "] --");
            String result = Utils.executeCommand(commands);
            String str = "SHA1: ";
            int startIndex = result.indexOf(str);
            if (startIndex != -1) {
                int endIndex = result.indexOf("\n", startIndex);
                mAppSHA1 = result.substring(startIndex + str.length(), endIndex);
            }
            System.out.println("-- SHA1 : [" + mAppSHA1 + "] --");
        } catch (Exception ex) {
            Logger.getLogger(OAuthTesterView.class.getName()).log(Level.SEVERE, null, ex);
            ex.printStackTrace();
        }
    }

    private void printConfigInFile() {
        String outputPath = current_directory + "/configuration.json";
        outputPath = outputPath.replace("\\", "\\\\");
        System.out.println("== outputPath : [" + outputPath + "] ==");
        String outputContent = "{"
                + "\n\t\"keyhash\" : " + "\"" + mAppKeyhash.trim() + "\","
                + "\n\t\"sha1\" : " + "\"" + mAppSHA1.trim() + "\","
                + "\n\t\"parse_serrver\" : " + "\"" + parse_server.trim() + "\","
                + "\n\t\"parse_app_id\" : " + "\"" + parse_app_id.trim() + "\","
                + "\n\t\"package_name\" : " + "\"" + txt_package_name.trim() + "\""
                + "\n}";
        File outputFile = new File(outputPath);
        try {
            Utils.writeInFile(outputFile, outputContent);
        } catch (IOException ex) {
            Logger.getLogger(ProjectSetupWizard.class.getName()).log(Level.SEVERE, null, ex);
            ex.printStackTrace();
        }
    }

    private String generateCompnayDetailString(JSONObject contact_details) {

        String common_name = contact_details.get("common_name").toString();
        String organization_unit = contact_details.get("organization_unit").toString();
        String organization_name = contact_details.get("organization_name").toString();
        String city = contact_details.get("city").toString();
        String state = contact_details.get("state").toString();
        String country = contact_details.get("country").toString();

        String companyDetailString = "";// = "cn=Mark Jones, ou=JavaSoft, o=Sun, c=US";
        companyDetailString += "CN=" + common_name;
        companyDetailString += ", OU=" + organization_unit;
        companyDetailString += ", O=" + organization_name;
        companyDetailString += ", L=" + city;
        companyDetailString += ", S=" + state;
        companyDetailString += ", C=" + country;

        return companyDetailString;
    }

    public static void copyFolder(File src, File dest) throws IOException {
        if (src.isDirectory()) {
            //if directory not exists, create it
            if (!dest.exists()) {
                dest.mkdir();
                System.out.println("Directory copied from "
                        + src + "  to " + dest);
            }

            //list all the directory contents
            String files[] = src.list();

            for (String file : files) {
                //construct the src and dest file structure
                File srcFile = new File(src, file);
                File destFile = new File(dest, file);
                //recursive copy
                copyFolder(srcFile, destFile);
            }
        } else {
            //if file, then copy it
            //Use bytes stream to support all file types
            InputStream in = new FileInputStream(src);
            OutputStream out = new FileOutputStream(dest);

            byte[] buffer = new byte[1024];

            int length;
            //copy the file content in bytes
            while ((length = in.read(buffer)) > 0) {
                out.write(buffer, 0, length);
            }

            in.close();
            out.close();
            System.out.println("File copied from " + src + " to " + dest);
        }
    }
}
