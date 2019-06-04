package com.twist.tmstore;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Build;
import android.os.Bundle;
import android.support.multidex.MultiDex;
import android.support.v7.app.AppCompatDelegate;
import android.text.TextUtils;

import com.activeandroid.ActiveAndroid;
import com.crashlytics.android.Crashlytics;
import com.crashlytics.android.core.CrashlyticsCore;
import com.facebook.FacebookSdk;
import com.facebook.appevents.AppEventsLogger;
import com.parse.Parse;
import com.parse.ParseInstallation;
import com.parse.ParseObject;
import com.parse.ParsePush;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.CustomerData;
import com.utils.Base64Utils;
import com.utils.GraphicsToText;
import com.utils.LocaleUtils;
import com.utils.Log;
import com.utils.Preferences;
import com.utils.customviews.TypefaceUtil;

import org.json.JSONObject;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import io.fabric.sdk.android.Fabric;

/**
 * Created by Twist Mobile on 12/10/2015.
 */
public class TMStoreApp extends Application {

    static {
        AppCompatDelegate.setCompatVectorFromResourcesEnabled(true);
    }

    private String mLocale;
    private List<Activity> activities = new ArrayList<>();

    public static void exit(Activity currentActivity) {
        try {
            Application application = currentActivity.getApplication();
            TMStoreApp app = (TMStoreApp) application;
            for (Activity activity : app.getActivityList()) {
                activity.finish();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onCreate() {
        super.onCreate();
//        //TODO TESTING INSTALL_REFERRER
//        Intent intent = new Intent(this, InstallReceiver.class);
//        intent.setAction("com.android.vending.INSTALL_REFERRER");
//        intent.putExtra("referrer", "pid%3Dcom.twist.tmstore8");
//        sendBroadcast(intent);
		//this.verifyAppConfigKeys();  // no need in apkbuilder
        if (AppInfo.ENABLE_CRASHLYTICS) {
            Crashlytics crashlytics;
            if (BuildConfig.DEBUG) {
                crashlytics = new Crashlytics.Builder().core(new CrashlyticsCore.Builder().disabled(true).build()).build();
            } else {
                crashlytics = new Crashlytics();
            }
            Fabric.with(this, crashlytics);
        }

        if (AppInfo.ENABLE_FACEBOOK_SDK) {
            FacebookSdk.sdkInitialize(getApplicationContext());
            AppEventsLogger.activateApp(this, "");
        }

        this.initializeDatabase();

        this.initializeParse();

        L.getInstance().init(this);

        this.registerActivityLifecycleCallbacks(new ActivityLifecycleCallbacks() {
            @Override
            public void onActivityCreated(Activity activity, Bundle bundle) {
                activities.add(activity);
                Log.d("Activity is created : " + activity.getClass().getSimpleName());
            }

            @Override
            public void onActivityStarted(Activity activity) {
            }

            @Override
            public void onActivityResumed(Activity activity) {
            }

            @Override
            public void onActivityPaused(Activity activity) {
            }

            @Override
            public void onActivityStopped(Activity activity) {
            }

            @Override
            public void onActivitySaveInstanceState(Activity activity, Bundle bundle) {
            }

            @Override
            public void onActivityDestroyed(Activity activity) {
                activities.remove(activity);
                Log.d("Activity is destroyed : " + activity.getClass().getSimpleName());
            }
        });
    }

    @Override
    protected void attachBaseContext(Context context) {
        super.attachBaseContext(context);
        MultiDex.install(this);
    }

    private void overrideFonts(Context context) {
        TypefaceUtil.overrideFonts(context);
    }

    protected void initializeDatabase() {
        ActiveAndroid.initialize(
                new com.activeandroid.Configuration.Builder(this)
                        .create());
    }

    private void initializeParse() {
        ParseObject.registerSubclass(CustomerData.class);
        String appId = "";
        String clientKey = "";

        try {
            InputStream is = this.getAssets().open("data.png");
            Bitmap bitmap = BitmapFactory.decodeStream(is);
            String string = GraphicsToText.getString(bitmap, ",");
            JSONObject jsonObject = new JSONObject(string);
            String dimension = jsonObject.getString("dimension");
            String dpi = jsonObject.getString("dpi");
            appId = Base64Utils.decode(dimension + "==", "tmsTore123");
            clientKey = Base64Utils.decode(dpi + "==", "tmsTore123");
        } catch (Exception ignored) {
            appId = getString(R.string.parse_app_id);
            clientKey = getString(R.string.parse_client_key);
            if (TextUtils.isEmpty(appId) || appId.contains("parse_app_id")) {
                throw new RuntimeException("Error: Invalid Parse App ID, please check for parse_app_id in app_strings.xml");
            }

            if (TextUtils.isEmpty(clientKey) || clientKey.contains("parse_client_key")) {
                throw new RuntimeException("Error: Invalid Parse Client Key, please check for parse_client_key in app_strings.xml");
            }
        }

        final String server = getString(R.string.parse_server);
        if (!TextUtils.isEmpty(appId) && !TextUtils.isEmpty(clientKey) && !TextUtils.isEmpty(server)) {
            Parse.Configuration.Builder pcb = new Parse.Configuration.Builder(this);
            pcb.applicationId(appId)
                    .clientKey(clientKey)
                    .server(server);
            Parse.initialize(pcb.build());
        }
        if (BuildConfig.DEBUG) {
            Parse.setLogLevel(Parse.LOG_LEVEL_DEBUG);
        }
        ParseUser.enableAutomaticUser();
        ParseInstallation installation = ParseInstallation.getCurrentInstallation();
        String gcm_sender_id = "";
        try {
            // Default GCMSenderId format in strings.xml is {id:xxxxxxxxxxxx}
            //TODO don't change GCM format if you want to receive push via back4app/parse
            gcm_sender_id = getString(R.string.gcm_sender_id).split(":")[1];
        } catch (Exception e) {
            e.printStackTrace();
        }
        installation.put("GCMSenderId", gcm_sender_id);
        installation.saveInBackground(e -> {
            if (e == null) {
                ParseUser parseUser = ParseUser.getCurrentUser();
                if (parseUser != null) {
                    parseUser.put("installation_id", ParseInstallation.getCurrentInstallation());
                    parseUser.saveInBackground(e1 -> {
                        if (e1 != null) {
                            Log.d("-- TMStoreApp::parseUser::saveInBackground::failed --");
                            e1.printStackTrace();
                        }
                    });
                    // for configuration changes in back4app notifications
                    ParsePush.subscribeInBackground("android");
                }

                ParseQuery<CustomerData> query = ParseQuery.getQuery(CustomerData.class);
                query.whereEqualTo("ParseUser", parseUser);
                query.getFirstInBackground((object, exception) -> {
                    if (exception != null || object == null) {
                        Log.d(" -- Creating new [CustomerData] Object --");
                        createFreshUser();
                    } else {
                        CustomerData.setInstance(object);
                        object.incrementCurrent_Day_App_Visit();
                        CustomerData.getInstance().saveInBackground();
                        Log.d("-- Retrieved the existing [CustomerData] object. --");
                    }
                });
            }
        });
    }

    public void createFreshUser() {
        CustomerData.setInstance(new CustomerData());
        CustomerData.getInstance().setApp_Name(getApplicationContext().getPackageName());
        CustomerData.getInstance().setDeviceModel(Build.MODEL);
        CustomerData.getInstance().setParseUser(ParseUser.getCurrentUser());
        CustomerData.getInstance().setCurrent_Day_App_Visit(1);
        CustomerData.getInstance().setCurrent_Day_Purchased_Amount(0);
        CustomerData.getInstance().saveInBackground();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        if (mLocale != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                if (LocaleUtils.getLocale(newConfig) != null) {
                    Locale locale = LocaleUtils.create(mLocale);
                    Locale.setDefault(locale);
                    Configuration config = new Configuration();
                    config.setLocale(locale);
                    createConfigurationContext(config);
                }
            } else if (newConfig.locale != null) {
                Locale locale = LocaleUtils.create(mLocale);
                Locale.setDefault(locale);
                Configuration config = new Configuration();
                config.locale = locale;
                getResources().updateConfiguration(config, getResources().getDisplayMetrics());
            }
        }
    }

    public boolean setLocale(String locale, boolean updated) {
        if (mLocale == null || !locale.equalsIgnoreCase(mLocale)) {
            mLocale = locale;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                Configuration config = new Configuration();
                config.setLocale(LocaleUtils.create(mLocale));
                createConfigurationContext(config);
            } else {
                Configuration config = new Configuration();
                config.locale = LocaleUtils.create(mLocale);
                Resources resources = getBaseContext().getResources();
                resources.updateConfiguration(config, resources.getDisplayMetrics());
            }
            L.getInstance().loadLocale(mLocale);
            return true;
        }

        if (updated) {
            L.getInstance().loadLocale(mLocale);
            return true;
        }
        return false;
    }

    public void loadSavedLocale() {
        String locale = Preferences.getString(R.string.key_app_lang, null);
        if (locale != null) {
            this.setLocale(locale, true);
        }
    }

    public boolean setLocale(String locale) {
        return setLocale(locale, false);
    }

    public List<Activity> getActivityList() {
        return activities;
    }

    private void verifyAppConfigKeys() {
        // Verify GCM Sender ID
        String gcm_sender_id = getString(R.string.gcm_sender_id);
        if (!TextUtils.isEmpty(gcm_sender_id) && !gcm_sender_id.equals("id:xxxxxxxxxxxx")) {
            try {
                // Your 12 digits GCM Sender ID must be followed by "id:"
                gcm_sender_id = gcm_sender_id.split(":")[1];
                Log.d("GCMSenderID : " + gcm_sender_id);
            } catch (Exception e) {
                throw new RuntimeException(
                        "Error:" + e.getMessage() + "\n"
                                + "Reason: invalid GCM Sender ID, gcm_sender_id must be , your GCM Sender ID must be like id:xxxxxxxxxxxx\n"
                                + "Please check for gcm_sender_id in app_strings.xml or strings.xml");
            }
        } else {
            String message = "\n\n======================== TMStore Configuration Warning ========================\n\n";
            message += "GCM Sender ID is missing, If you are using Push notification via GCM or Panel then please check for gcm_sender_id in app_strings.xml";
            message += "\n\n===============================================================================\n\n";
            Log.e(message);
        }

        // Verify host url for deep linking
        String host_url = getString(R.string.host_url);
        if (TextUtils.isEmpty(host_url) || host_url.contains("host_url") || !host_url.startsWith("http")) {
            String message = "\n\n======================== TMStore Configuration Warning ========================\n\n";
            message += "Host url for deep linking is missing,  Please check for host_url in app_strings.xml";
            message += "\n\n===============================================================================\n\n";
            Log.e(message);
        }

        // Verify Google Geo Location API Key
        String google_android_geo_api_key = getString(R.string.google_android_geo_api_key);
        if (TextUtils.isEmpty(google_android_geo_api_key) || google_android_geo_api_key.contains("google_android_geo_api_key")) {
            String message = "\n\n======================== TMStore Configuration Warning ========================\n\n";
            message += "Google Geo Location API Key is missing, If you are using Google Map, Places or Distance API features in your app then please check for google_android_geo_api_key in app_strings.xml";
            message += "\n\n===============================================================================\n\n";
            Log.e(message);
        }

        // Verify Razorpay API Key
        if (BuildConfig.FLAVOR.equals("razorpay")) {
            String razorpay_api_key = getString(R.string.razorpay_api_key);
            if (TextUtils.isEmpty(razorpay_api_key) || razorpay_api_key.contains("razorpay_api_key")) {
                throw new RuntimeException("Error: Invalid API key for Razorpay, please check for razorpay_api_key in app_strings.xml");
            }
        }
    }
}
