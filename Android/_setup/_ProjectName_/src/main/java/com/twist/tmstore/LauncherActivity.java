package com.twist.tmstore;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.res.AssetFileDescriptor;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AlertDialog;
import android.text.TextUtils;
import android.text.util.Linkify;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.widget.*;
import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.drawable.GlideDrawable;
import com.bumptech.glide.load.resource.gif.GifDrawable;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.animation.GlideAnimation;
import com.bumptech.glide.request.target.GlideDrawableImageViewTarget;
import com.bumptech.glide.request.target.Target;
import com.easyandroidanimations.library.Animation;
import com.easyandroidanimations.library.AnimationListener;
import com.easyandroidanimations.library.FadeInAnimation;
import com.easyandroidanimations.library.ScaleOutAnimation;
import com.facebook.FacebookSdk;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.common.api.CommonStatusCodes;
import com.google.gson.Gson;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.twist.dataengine.DataEngine;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.entities.SellerInfo;
import com.twist.dataengine.entities.TM_CategoryInfo;
import com.twist.dataengine.entities.TM_CommonInfo;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.oauth.NetworkRequest;
import com.twist.oauth.NetworkUtils;
import com.twist.oauth.OAuthUtils;
import com.twist.tmstore.L.Language;
import com.twist.tmstore.config.*;
import com.twist.tmstore.dialogs.DemoAppTypesDialog;
import com.twist.tmstore.dialogs.GetCodeDialog;
import com.twist.tmstore.dialogs.PendingUserDialog;
import com.twist.tmstore.dialogs.UpdateAppDialog;
import com.twist.tmstore.entities.*;
import com.twist.tmstore.listeners.LoginListener;
import com.twist.tmstore.multistore.BarcodeReaderActivity;
import com.twist.tmstore.multistore.MultiStoreListActivity;
import com.twist.tmstore.multistore.MultiStoreMapActivity;
import com.twist.tmstore.notifications.MyFcmRegistrationService;
import com.twist.tmstore.payments.PaymentManager;
import com.utils.*;
import com.utils.customviews.TextureVideoView;
import com.utils.customviews.progressbar.CircleProgressBar;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;

import static android.view.WindowManager.LayoutParams;

public class LauncherActivity extends BaseActivity {
    private View error_page;
    private CircleProgressBar progressBar;
    private LinearLayout sampleAppLayout;
    private RelativeLayout splashLayout;
    private EditText editText;
    private Button btn_launch_sample;
    private TextView txt_tmstore;
    private TextView txt_loading;
    private TextView text_merchant_desc;
    private ImageView img_splash_full;
    private ImageView image_app_splash;

    private String debugCode = "";
    private String welcomeString;

    private boolean parseDataLoaded = false;
    private boolean contentLoaded = false;
    private boolean languagesLoaded = false;
    private boolean errorWhileLoading = false;

    private String multiStorePlatform;
    private String merchantId;
    private String referredMerchant = "";
    private String recentMerchantId = "";
    private Intent fromIntent = null;
    private boolean mIsStoreDeepLink = false;
    private String mDeepLinkStoreName = "";
    private String mConfig;
    private Button btn_enter;
    private TextureVideoView intro_video_view;
    private ImageView intro_anim_view;
    private RelativeLayout main_section;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        System.out.println("************LauncherActivity onCreate ******* isTaskRooted= " + isTaskRoot() +
                " CategoryLauncher= " + getIntent().hasCategory(Intent.CATEGORY_LAUNCHER) +
                " (getAction != null) = " + (getIntent().getAction() != null));
		
		if (!isTaskRoot()
                && getIntent().hasCategory(Intent.CATEGORY_LAUNCHER)
                && getIntent().getAction() != null
                && getIntent().getAction().equals(Intent.ACTION_MAIN)) {
            finish();
            return;
        }

        getWindow().setFlags(LayoutParams.FLAG_FULLSCREEN, LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_splash);
        initAppColors();
        initMainUI();
        initDemoUI();
        loadIntroVideo();
        AnalyticsHelper.registerVisitScreenEvent(Constants.SPLASH);
    }

    private void initMainUI() {
        splashLayout = findViewById(R.id.splash_layout);
        main_section = findViewById(R.id.main_section);
        image_app_splash = findViewById(R.id.image_app_splash);
        img_splash_full = findViewById(R.id.image_splash_full);

        txt_tmstore = findViewById(R.id.txt_tmstore);
        txt_tmstore.setText(getString(L.string.powered_by_tm_store));
        txt_tmstore.setVisibility(View.INVISIBLE);
        Helper.stylizeSplashText(txt_tmstore);

        txt_loading = findViewById(R.id.txt_loading);
        Helper.stylizeSplashText(txt_loading);

        text_merchant_desc = findViewById(R.id.text_merchant_desc);
        Helper.stylizeSplashText(text_merchant_desc);
        text_merchant_desc.setVisibility(View.GONE);

        progressBar = (CircleProgressBar) findViewById(R.id.progress);
        Helper.stylize(progressBar);
        progressBar.setVisibility(View.GONE);

        error_page = findViewById(R.id.error_page);
        error_page.setVisibility(View.GONE);
    }

    private void initDemoUI() {
        sampleAppLayout = (LinearLayout) findViewById(R.id.layout_sample_app);
        editText = (EditText) findViewById(R.id.editText);
        editText.setHint(HtmlCompat.fromHtml(getString(L.string.prompt_demo_code)));
        Drawable drawable = ContextCompat.getDrawable(this, R.drawable.ic_vc_scan);
        Helper.stylize(drawable);
        editText.setCompoundDrawablesWithIntrinsicBounds(null, null, drawable, null);
        Helper.stylize(editText, false);
        editText.setOnTouchListener(new View.OnTouchListener() {
            @SuppressLint("ClickableViewAccessibility")
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                final int DRAWABLE_RIGHT = 2;
                if (event.getAction() == MotionEvent.ACTION_UP) {
                    if (event.getRawX() >= (editText.getRight() - editText.getCompoundDrawables()[DRAWABLE_RIGHT].getBounds().width())) {
                        Intent intent = new Intent(LauncherActivity.this, BarcodeReaderActivity.class);
                        intent.putExtra(BarcodeReaderActivity.AutoFocus, true);
                        intent.putExtra(BarcodeReaderActivity.UseFlash, false);
                        startActivityForResult(intent, Constants.REQUEST_BARCODE_CAPTURE);
                        return true;
                    }
                }
                return false;
            }
        });
        btn_launch_sample = (Button) findViewById(R.id.btn_launch_sample);
        btn_launch_sample.setText(getString(L.string.launch_sample_app));
        Helper.stylize(btn_launch_sample);
        btn_enter = (Button) findViewById(R.id.btn_enter);
        btn_enter.setText(getString(L.string.enter));
        btn_enter.setOnClickListener(v -> loadRequiredContent());
        Helper.stylize(btn_enter);
        btn_launch_sample.setOnClickListener(v -> {
            if (BuildConfig.DEMO_VERSION) {
                DemoAppTypesDialog demoAppTypesDialog = DemoAppTypesDialog.newInstance();
                demoAppTypesDialog.setAppTypeDialogListener(config -> {
                    mConfig = config;
                    loadRequiredContent();
                });
                demoAppTypesDialog.show(getSupportFragmentManager(), DemoAppTypesDialog.class.getSimpleName());
            } else {
                loadRequiredContent();
            }
        });

        TextView txt_help1 = findViewById(R.id.txt_help_1);
        txt_help1.setText(getString(L.string.demo_code_help_1));
        txt_help1.setPaintFlags(txt_help1.getPaintFlags() | Paint.UNDERLINE_TEXT_FLAG);
        txt_help1.setOnClickListener(v -> GetCodeDialog.show(LauncherActivity.this, true, null));
        TextView txt_help2 = findViewById(R.id.txt_help_2);
        txt_help2.setText(getString(L.string.demo_code_help_2));
    }

    private void loadIntroVideo() {
        intro_video_view = findViewById(R.id.intro_video_view);
        if (BuildConfig.INTRO_VIDEO) {
            try {
                main_section.setVisibility(View.GONE);
                intro_video_view.setVisibility(View.VISIBLE);
                intro_video_view.setListener(new TextureVideoView.MediaPlayerListener() {
                    @Override
                    public void onVideoPrepared() {
                    }

                    @Override
                    public void onVideoEnd() {
                        proceedLoading();
                    }

                    @Override
                    public void onVideoError(String msg) {
                        proceedLoading();
                    }
                });
                int videoResourceId = getResources().getIdentifier("intro_video", "raw", getPackageName());
                AssetFileDescriptor afd = getResources().openRawResourceFd(videoResourceId);
                intro_video_view.setDataSource(afd);
                intro_video_view.play();
            } catch (Exception e) {
                proceedLoading();
            }
        } else {
            proceedLoading();
        }
    }

    private void proceedLoading() {
        intro_video_view.setVisibility(View.GONE);
        main_section.setVisibility(View.VISIBLE);
        loadEverything(getIntent());
    }

    private void loadEverything(Intent intent) {

        System.out.println("**** call loadEverything ****");
        loadAppSplash();
        handleIntentExtras(intent);
        initDefaults();
        clearDummyContent();
        setDebugView();
        hideLoading();

        if (!BuildConfig.DEMO_VERSION) {
            hideErrorPage();
            findViewById(R.id.btn_retry).setOnClickListener(v -> retryLastQuery());
            hideSampleAppLayout();

            loadRequiredContent();
        } else {
            String appId = Preferences.getString("demoAppId", "");
            if (!TextUtils.isEmpty(appId)) {
                editText.setText(appId);
                loadRequiredContent();
            } else {
                appId = Preferences.getString("autoFillDemoCode", null);
                if (!TextUtils.isEmpty(appId)) {
                    editText.setText(appId);
                }
                showSampleAppLayout();
            }
        }
        Helper.stylize(progressBar);
    }

    private void loadAppSplash() {
        String splashUrl = Preferences.getString("splash_url");
        if (TextUtils.isEmpty(splashUrl)) {
            if (BuildConfig.INTRO_SPLASH) {
                image_app_splash.setVisibility(View.VISIBLE);
                image_app_splash.setImageResource(R.drawable.app_splash);
                image_app_splash.setScaleType(ImageView.ScaleType.FIT_XY);
                image_app_splash.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.MATCH_PARENT));
            } else {
                image_app_splash.setVisibility(View.VISIBLE);
            }
        } else {
            img_splash_full.setScaleType(ImageView.ScaleType.CENTER_CROP);
            img_splash_full.setLayoutParams(new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.MATCH_PARENT));
            splashLayout.setBackgroundColor(Color.parseColor(AppInfo.color_splash_bg));
            Glide.with(this)
                    .load(splashUrl)
                    .listener(new RequestListener<String, GlideDrawable>() {
                        @Override
                        public boolean onException(Exception e, String model, Target<GlideDrawable> target, boolean isFirstResource) {
                            return false;
                        }

                        @Override
                        public boolean onResourceReady(GlideDrawable resource, String model, Target<GlideDrawable> target, boolean isFromMemoryCache, boolean isFirstResource) {
                            image_app_splash.setVisibility(View.INVISIBLE);
                            return false;
                        }
                    }).into(img_splash_full);
        }
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        handleIntentExtras(intent);
    }

    private void handleIntentExtras(Intent intent) {
        //TODO test install referrers
        //getIntent().putExtra(Extras.REFERRER, "pid=3a60f9358f9856973f7cf0d58437db69");
        //getIntent().putExtra(Extras.REFERRER_TYPE, Constants.Key.REFERRER_INSTALL);
        fromIntent = intent;

        Bundle extras = intent.getExtras();
        if (extras != null) {
            if (extras.containsKey(Extras.MULTI_STORE_PLATFORM)) {
                multiStorePlatform = extras.getString(Extras.MULTI_STORE_PLATFORM);
            }
        }
    }

    private void initDefaults() {
        AppInfo.resetAll();
        DataEngine.setLogEnabled(Log.DEBUG);
        NetworkRequest.setLogEnabled(Log.DEBUG);
        OAuthUtils.init(this);
        Cart.generateSession();
        ((TMStoreApp) getApplication()).loadSavedLocale();

        String _locale = Preferences.getString(R.string.key_app_lang, null);
        if (_locale != null) {
            ((TMStoreApp) getApplication()).setLocale(_locale);
        }
        welcomeString = Preferences.getString(R.string.welcome_string, R.string.checking_app_data);
    }

    private void clearDummyContent() {
        if (AppInfo.drawerItems == null) {
            AppInfo.drawerItems = new ArrayList<>();
        } else {
            AppInfo.drawerItems.clear();
        }

        if (AppInfo.front_page_categories == null) {
            AppInfo.front_page_categories = new ArrayList<>();
        } else {
            AppInfo.front_page_categories.clear();
        }

        if (AppInfo.profileItems == null) {
            AppInfo.profileItems = new ArrayList<>();
        } else {
            AppInfo.profileItems.clear();
        }
    }

    private void setDebugView() {
        View.OnClickListener clickListener = new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                switch (v.getId()) {
                    case R.id.btn_debug1:
                        debugCode += "1";
                        break;
                    case R.id.btn_debug2:
                        debugCode += "2";
                        break;
                    case R.id.btn_debug3:
                        debugCode += "3";
                        break;
                    case R.id.btn_debug4:
                        debugCode += "4";
                        break;
                }
                // verify debug code on debug buttons click
                if (debugCode.equals(AppInfo.DEBUG_CODE)) {
                    Log.DEBUG = true;
                    DataEngine.setLogEnabled(Log.DEBUG);
                    NetworkRequest.setLogEnabled(true);
                    Helper.showErrorToast("Powered by TMStore");
                    debugCode = "";
                }
            }
        };
        findViewById(R.id.btn_debug1).setOnClickListener(clickListener);
        findViewById(R.id.btn_debug2).setOnClickListener(clickListener);
        findViewById(R.id.btn_debug3).setOnClickListener(clickListener);
        findViewById(R.id.btn_debug4).setOnClickListener(clickListener);
    }

    private void loadRequiredContent() {

        System.out.println("**** call loadRequiredContent ****");
        errorWhileLoading = false;
        if (!Helper.isNetworkAvailable(this)) {
            handleFetchingError(L.string.no_internet_connection);
            return;
        }

        if (!parseDataLoaded) {
            loadParseData();
        } else if (!languagesLoaded && AppInfo.ENABLE_LOCALIZATION) {
            loadLanguages();
        } else if (!contentLoaded) {
            if (MultiVendorConfig.isEnabled() && MultiVendorConfig.getScreenType() == MultiVendorConfig.ScreenType.VENDORS) {
                loadVendorsInBackground();
            } else {
                loadSplashProducts();
            }
        } else {
            if (MultiVendorConfig.isEnabled() && (MultiVendorConfig.getScreenType() == MultiVendorConfig.ScreenType.VENDORS)) {
                launchVendorsActivity();
            } else {
                launchMainActivity();
            }
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        switch (requestCode) {
            case Constants.REQUEST_BARCODE_CAPTURE: {
                if (resultCode == CommonStatusCodes.SUCCESS) {
                    if (data != null) {
                        String barCodeResult = data.getStringExtra(BarcodeReaderActivity.BarcodeObject);
                        if (barCodeResult.contains("demo_app_id")) {
                            try {
                                String[] params = barCodeResult.split("=");
                                if (params.length >= 2) {
                                    String demoAppId = params[1];
                                    editText.setText(demoAppId);
                                    btn_enter.performClick();
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    }
                }
            }
            break;
        }
    }

    @Override
    protected void onActionBarRestored() {
    }

    @Override
    public void onBackPressed() {
        // block back key here
        if (errorWhileLoading) {
            super.onBackPressed();
        }
    }

    private void retryLastQuery() {
        errorWhileLoading = false;
        Log.commitBuffer();
        hideErrorPage();
        showLoading();
        loadRequiredContent();
    }

    private void hideErrorPage() {
        if (!BuildConfig.DEMO_VERSION) {
            error_page.setVisibility(View.GONE);
        }
    }

    private void hideSampleAppLayout() {
        sampleAppLayout.setVisibility(View.GONE);
        btn_launch_sample.setVisibility(View.GONE);
    }

    private void showSampleAppLayout() {
        sampleAppLayout.setVisibility(View.VISIBLE);
        btn_launch_sample.setVisibility(View.VISIBLE);
    }

    private void loadParseData() {
        showLoading();
        if (BuildConfig.DEMO_VERSION) {
            Helper.hideKeyboard(getCurrentFocus());
            String demoCode = editText.getText().toString().trim();
            if (!TextUtils.isEmpty(demoCode)) {
                loadParseDataDemo(demoCode);
            } else {
                if (!TextUtils.isEmpty(mConfig)) {
                    loadParseDataDemo(AppInfo.SAMPLE_APP_ID);
                } else {
                    handleFetchingError(L.string.invalid_demo_code);
                }
            }
        } else {
            txt_loading.setText(welcomeString);
            if (BuildConfig.MULTI_STORE) {
                loadMultiStoreData();
            } else {
                if (BuildConfig.DEBUG) {
                    loadDebugPlatformParseData();
                } else {
                    loadPlatformData("android");
                }
            }
        }
    }

    private void loadDebugPlatformParseData() {
        if (!BuildConfig.DEBUG) {
            return;
        }

        String debug_platform = Preferences.getString("debug_platform", "");
        if (debug_platform.equals("")) {
            ParseQuery<ParseObject> query = ParseQuery.getQuery("AppData");
            query.whereContains("platform", "android");
            query.findInBackground((objects, e) -> {
                if (e == null) {
                    final CharSequence[] platforms = new CharSequence[objects.size()];
                    for (int i = 0; i < objects.size(); i++) {
                        String p = objects.get(i).getString("platform");
                        if (p.contains("_")) {
                            int index = p.indexOf("_");
                            platforms[i] = p.substring(index + 1, p.length());
                        } else {
                            platforms[i] = p;
                        }
                    }

                    if (platforms.length > 1) {
                        AlertDialog.Builder builder = new AlertDialog.Builder(LauncherActivity.this);
                        builder.setTitle("Select Store")
                                .setItems(platforms, (dialog, which) -> {
                                    String p = platforms[which].toString();
                                    p = !p.equals("android") ? "android_" + p : p;
                                    loadPlatformData(p);
                                    Log.d("Platform { " + p + " } is selected.");
                                });
                        builder.setCancelable(false);
                        builder.create().show();
                    } else {
                        String p = platforms[0].toString();
                        p = !p.equals("android") ? "android_" + p : p;
                        loadPlatformData(p);
                        Log.d("Platform { " + p + " } is selected.");
                    }
                } else {
                    Preferences.putString("debug_platform", ""); //clearing default platform if saved
                    e.printStackTrace();
                    if (e.getCode() == -1) {
                        handleFetchingError(getString(L.string.generic_error));
                    } else {
                        handleFetchingError(e.getMessage());
                    }
                }
            });
        } else {
            loadPlatformData(debug_platform);
            Log.d("Platform { " + debug_platform + " } is selected.");
        }
    }

    private void loadMultiStoreData() {
        if (!BuildConfig.MULTI_STORE) {
            Helper.showErrorToast("MultiStore is not supported.");
            return;
        }

        if (!TextUtils.isEmpty(multiStorePlatform)) {
            loadMultiStorePlatformData(multiStorePlatform);
            return;
        }

        // Multi Store product deep linking
        if (getIntent().getData() != null) {
            String url = getIntent().getData().getSchemeSpecificPart();
            if (!TextUtils.isEmpty(url) && url.contains("pid") && url.contains("store")) {
                try {
                    String str = url.split("&")[1];
                    mDeepLinkStoreName = str.split("=")[1];
                    mIsStoreDeepLink = true;
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }

        String platform = Preferences.getString(Constants.Key.MULTI_STORE_PLATFORM, "");
        if (TextUtils.isEmpty(platform) || MultiStoreConfig.isEmpty() || mIsStoreDeepLink) {
            ParseQuery<ParseObject> query = ParseQuery.getQuery("AppData");
            query.whereContains("multi_store_platform", "android");
            query.whereExists("multi_store_config");
            query.findInBackground((objects, e) -> {
                if (e == null && objects.size() > 0) {
                    List<MultiStoreConfig> multiStoreConfigs = MultiStoreConfig.createConfigs(objects, false);

                    for (int j = 0; j < multiStoreConfigs.size(); j++) {
                        MultiStoreConfig multiStoreConfig = multiStoreConfigs.get(j);
//                        if (j == 1) {
//                            multiStoreConfig.setDefaultStore(true);
//                        }
                        Log.D("Multistore " + multiStoreConfig.toString());
                    }

                    List<MultiStoreConfig> defaultMultiStoreConfigs = MultiStoreConfig.getdefaultMultiStoreConfigList(true);
                    if (!defaultMultiStoreConfigs.isEmpty()) {
                        launchMultiStore(defaultMultiStoreConfigs, objects);
                    } else {
                        launchMultiStore(multiStoreConfigs, objects);
                    }
                } else {
                    Preferences.putString(Constants.Key.MULTI_STORE_PLATFORM, "");
                    if (e != null) {
                        e.printStackTrace();
                        handleFetchingError(e.getCode() == -1 ? getString(L.string.generic_error) : e.getMessage());
                    } else {
                        if (BuildConfig.DEBUG) {
                            Helper.showErrorToast("No platform available for MultiStore.");
                        }
                        handleFetchingError(getString(L.string.generic_error));
                    }
                }
            });
        } else if (!MultiStoreConfig.isEmpty()) {
            if (mIsStoreDeepLink && !TextUtils.isEmpty(mDeepLinkStoreName)) {
                platform = mDeepLinkStoreName;
            }
            loadMultiStorePlatformData(platform);
        }
    }

    private void launchMultiStore(List<MultiStoreConfig> multiStoreConfigs, List<ParseObject> objects) {
        if (multiStoreConfigs.size() > 1) {
            if (!mIsStoreDeepLink && TextUtils.isEmpty(mDeepLinkStoreName)) {
                // forcefully load theme colors.
                loadThemeColors(objects.get(0));
                Intent intent;
                if (BuildConfig.SEARCH_NEARBY) {
                    intent = new Intent(LauncherActivity.this, MultiStoreMapActivity.class);
                } else {
                    intent = new Intent(LauncherActivity.this, MultiStoreListActivity.class);
                    intent.putExtra(Extras.SHOW_ALL_PLATFORMS, true);
                }
                startActivity(intent);
                finish();
            } else {
                MultiStoreConfig multiStoreConfig = MultiStoreConfig.findByPlatform(mDeepLinkStoreName);
                if (multiStoreConfig != null) {
                    loadMultiStorePlatformData(mDeepLinkStoreName);
                } else {
                    handleFetchingError(getString(L.string.generic_error));
                }
            }
        } else {
            if (multiStoreConfigs.size() > 0) {
                MultiStoreConfig multiStoreConfig = multiStoreConfigs.get(0);
                if (!TextUtils.isEmpty(multiStoreConfig.getPlatform())) {
                    loadMultiStorePlatformData(multiStoreConfig.getPlatform());
                    return;
                }
            }
            handleFetchingError(getString(L.string.generic_error));
        }
    }


    private void loadMultiStorePlatformData(final String platform) {
        if (BuildConfig.MULTI_STORE) {
            ParseQuery<ParseObject> query = ParseQuery.getQuery("AppData");
            query.whereEqualTo("multi_store_platform", platform);
            query.getFirstInBackground((object, e) -> {
                hideLoading();
                if (e == null) {
                    if (!TextUtils.isEmpty(platform)) {
                        Preferences.putString(Constants.Key.MULTI_STORE_PLATFORM, platform);
                    }
                    handleParseResponse(object);
                } else {
                    e.printStackTrace();
                    handleFetchingError(e.getCode() == -1 ? getString(L.string.generic_error) : e.getMessage());
                }
            });
        }
    }

    private void loadPlatformData(final String platform) {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("AppData");
        query.whereEqualTo("platform", platform);
        query.getFirstInBackground((object, e) -> {
            if (e == null) {
                Preferences.putString("debug_platform", platform);
                hideLoading();
                handleParseResponse(object);
            } else {
                Preferences.putString("debug_platform", "");
                e.printStackTrace();
                handleFetchingError(e.getCode() == -1 ? getString(L.string.generic_error) : e.getMessage());
            }
        });
    }

    private void loadParseDataDemo(final String objectId) {
        txt_loading.setText(getString(L.string.loading_checking_app_id));
        hideSampleAppLayout();
        final ParseQuery<ParseObject> query = ParseQuery.getQuery("AppData");
        query.whereEqualTo("merchant_obj", ParseObject.createWithoutData("Merchant_Plugin_Data", objectId));
        query.whereEqualTo("platform", "android");
        query.countInBackground((count, e) -> {
            if (e != null) {
                e.printStackTrace();
                handleFetchingError(e.getMessage());
                showSampleAppLayout();
            } else {
                if (count > 0) {
                    query.getFirstInBackground((object, e1) -> {
                        if (e1 == null) {
                            hideLoading();
                            handleParseResponse(object);
                        } else {
                            e1.printStackTrace();
                            handleFetchingError(e1.getMessage());
                            showSampleAppLayout();
                        }
                    });
                } else {
                    ParseQuery.getQuery("Merchant_Plugin_Data")
                            .include("app_data_id")
                            .whereEqualTo("objectId", objectId)
                            .getFirstInBackground((object, e12) -> {
                                if (e12 == null) {
                                    hideLoading();
                                    if (object != null) {
                                        ParseObject parseObject = object.getParseObject("app_data_id");
                                        if (parseObject != null) {
                                            handleParseResponse(parseObject);
                                            return;
                                        }
                                    }
                                    handleParseResponseDemo(object);
                                } else {
                                    e12.printStackTrace();
                                    if (e12.getCode() == ParseException.OBJECT_NOT_FOUND) {
                                        handleFetchingError(L.string.invalid_demo_code);
                                    } else {
                                        handleFetchingError(e12.getMessage());
                                    }
                                    showSampleAppLayout();
                                }
                            });
                }
            }
        });
    }

    private void initAppComponents() {
        if (!TextUtils.isEmpty(AppInfo.FACEBOOK_APP_ID)) {
            FacebookSdk.setApplicationId(AppInfo.FACEBOOK_APP_ID);
        }
        Helper.cleanPreLoadedProducts();
        PaymentManager.INSTANCE.reset();
        GhostCart.init();
        Cart.init();
        Wishlist.init();
        WishListGroup.init(true, null);
    }

    private void handleParseResponseDemo(ParseObject appData) {
        if (appData == null) {
            handleFetchingError(L.string.demo_code_not_found);
            showSampleAppLayout();
            return;
        }

        try {
            txt_tmstore.setVisibility(View.VISIBLE);
            new FadeInAnimation(txt_tmstore).animate();

            AppInfo.DEMO_APP = true;
            AppInfo.ID_PLACEHOLDER_BANNER = R.drawable.placeholder_banner_demo;
            AppInfo.ID_PLACEHOLDER_PRODUCT = R.drawable.placeholder_product_demo;
            AppInfo.ID_PLACEHOLDER_CATEGORY = R.drawable.placeholder_category_demo;

            AppInfo.ABOUT_URL = appData.getString("site_url");
            AppInfo.PROMO_URL = "";
            AppInfo.PROMO_IMG_URL = "";
            AppInfo.FACEBOOK_APP_ID = appData.getString("fb_appid");
            AppInfo.TWITTER_APP_KEY = appData.getString("twitter_key");
            AppInfo.GOOGLE_APP_KEY = appData.getString("google_key");
            AppInfo.ID_LAYOUT_PRODUCTS = appData.getInt("id_layout_products");
            AppInfo.ID_LAYOUT_CATEGORIES = appData.getInt("id_layout_categories");
            AppInfo.ID_LAYOUT_CART = ParseHelper.getInt(appData, "id_layout_cart", AppInfo.ID_LAYOUT_CART);
            AppInfo.MERCHANT_ID = appData.getObjectId();
            AppInfo.ENABLE_COUPONS = ParseHelper.getBool(appData, "enableCoupons", AppInfo.ENABLE_COUPONS);

            DataEngine.stepup_single_child_categories = false;
            DataEngine.max_categories_query_count_limit = 25;
            DataEngine.max_products_query_count_limit = 25;
            DataEngine.refine_categories = appData.getBoolean("refine_categories");

            loadThemeColors(appData);

            loadBannerImage(appData);

            String baseUrl = getBaseUrl(appData);

            String api_version = ParseHelper.getString(appData, "api_version", "v3");
            String api_key = appData.getString("wc_api_key");
            String api_secret = appData.getString("wc_api_secret");

            DataEngine.getDataEngine().initWithArgs(this, baseUrl, api_key, api_secret, api_version, "tm", "", AppInfo.SHIPPING_PROVIDER, AppInfo.SHIPPING_KEY);

            System.out.println("**** call initAppComponent __handleParseResponse ***");
            initAppComponents();

            loadNewSplash(appData);
        } catch (Exception e) {
            e.printStackTrace();
            handleFetchingError(L.string.error_loading_data);
            showSampleAppLayout();
        }
    }

    private void handleParseResponse(ParseObject appData) {
        if (appData == null) {
            handleFetchingError(L.string.error_loading_data);
            return;
        }

        try {
            int service_active = appData.getInt("service_active");
            if (BuildConfig.DEMO_VERSION) {
                service_active = 1;
            }

            if (service_active == 0) {
                handleFetchingError(L.string.service_not_active);
                return;
            }

            if (BuildConfig.DEBUG) {
                ParseHelper.printClass(appData);
            }

            AppInfo.ID_PLACEHOLDER_BANNER = AppInfo.DEMO_APP ? R.drawable.placeholder_banner_demo : R.drawable.placeholder_banner;
            AppInfo.ID_PLACEHOLDER_PRODUCT = AppInfo.DEMO_APP ? R.drawable.placeholder_product_demo : R.drawable.placeholder_product;
            AppInfo.ID_PLACEHOLDER_CATEGORY = AppInfo.DEMO_APP ? R.drawable.placeholder_category_demo : R.drawable.placeholder_category;

            try {
                String json = "";
                if (AppInfo.ENABLE_LOCAL_CONFIG || BuildConfig.DEMO_VERSION) {
                    if (TextUtils.isEmpty(mConfig)) {
                        json = AssetHelper.loadFileContent(this, "config.json");
                    } else {
                        json = AssetHelper.loadFileContent(this, mConfig + ".json");
                    }
                } else {
                    json = appData.getString("addons");
                }

                JSONObject object = new JSONObject(json);
                if (object.has("config")) {
                    JSONObject config = object.getJSONObject("config");
                    AppInfo.drawer_header_bg = JsonHelper.getString(config, "drawer_header_bg");
                    AppInfo.profile_header_bg = JsonHelper.getString(config, "profile_header_bg");
                    AppInfo.login_bg = JsonHelper.getString(config, "login_bg");
                    AppInfo.SHOW_CART_WITH_PRODUCT = JsonHelper.getBool(config, "show_cart_with_product", AppInfo.SHOW_CART_WITH_PRODUCT);
                    AppInfo.HIDE_PRODUCT_PRICE_TAG = JsonHelper.getBool(config, "hide_product_price_tag", AppInfo.HIDE_PRODUCT_PRICE_TAG);
                    AppInfo.ENABLE_ZERO_PRICE_ORDER = JsonHelper.getBool(config, "enable_zero_price_order", AppInfo.ENABLE_ZERO_PRICE_ORDER);
                    AppInfo.ENABLE_OPINIONS = JsonHelper.getBool(config, "enable_opinions", AppInfo.ENABLE_OPINIONS);
                    AppInfo.ENABLE_WISHLIST = JsonHelper.getBool(config, "enable_wishlist", AppInfo.ENABLE_WISHLIST);
                    AppInfo.ENABLE_SINGLE_CHECK_WISHLIST = JsonHelper.getBool(config, "enable_single_wishlist", AppInfo.ENABLE_SINGLE_CHECK_WISHLIST);
                    AppInfo.ENABLE_MULTIPLE_DELETE = JsonHelper.getBool(config, "enable_multiple_delete", AppInfo.ENABLE_MULTIPLE_DELETE);
                    AppInfo.ENABLE_AUTOMATIC_BANNERS = JsonHelper.getBool(config, "enable_automatic_banners", AppInfo.ENABLE_AUTOMATIC_BANNERS);
                    AppInfo.HOME_SLIDER_STANDARD_WIDTH = JsonHelper.getInt(config, "home_slider_standard_width", AppInfo.HOME_SLIDER_STANDARD_WIDTH);
                    AppInfo.HOME_SLIDER_STANDARD_HEIGHT = JsonHelper.getInt(config, "home_slider_standard_height", AppInfo.HOME_SLIDER_STANDARD_HEIGHT);
                    AppInfo.PRODUCT_SLIDER_STANDARD_WIDTH = JsonHelper.getInt(config, "product_slider_standard_width", AppInfo.PRODUCT_SLIDER_STANDARD_WIDTH);
                    AppInfo.PRODUCT_SLIDER_STANDARD_HEIGHT = JsonHelper.getInt(config, "product_slider_standard_height", AppInfo.PRODUCT_SLIDER_STANDARD_HEIGHT);
                    AppInfo.SHOW_IOS_STYLE_SUB_CATEGORIES = JsonHelper.getBool(config, "show_ios_style_sub_categories", AppInfo.SHOW_IOS_STYLE_SUB_CATEGORIES);
                    AppInfo.SKIP_MANUAL_ENCODING = JsonHelper.getBool(config, "skip_manual_encoding", AppInfo.SKIP_MANUAL_ENCODING);
                    AppInfo.AUTO_LOAD_MORE_ITEMS = JsonHelper.getBool(config, "auto_load_more_items", AppInfo.AUTO_LOAD_MORE_ITEMS);
                    AppInfo.ADD_SEARCH_IN_HOME = JsonHelper.getBool(config, "add_search_in_home", AppInfo.ADD_SEARCH_IN_HOME);
                    AppInfo.GEO_LOC_SEARCH_IN_HOME = JsonHelper.getBool(config, "geo_loc_search_in_home", AppInfo.GEO_LOC_SEARCH_IN_HOME);
                    AppInfo.USE_HTTPTASK_WITH_COOKIES = JsonHelper.getBool(config, "use_httptask_with_cookies", AppInfo.USE_HTTPTASK_WITH_COOKIES);
                    AppInfo.PRODUCT_ACTIVITY_ANIMATION = JsonHelper.getInt(config, "product_activity_animation", AppInfo.PRODUCT_ACTIVITY_ANIMATION);
                    AppInfo.SHOW_MIN_MAX_PRICE = JsonHelper.getBool(config, "show_min_max_price", AppInfo.SHOW_MIN_MAX_PRICE);
                    AppInfo.AUTO_SELECT_VARIATION = JsonHelper.getBool(config, "auto_select_variation", AppInfo.AUTO_SELECT_VARIATION);
                    AppInfo.AUTO_DETECT_ADDRESS = JsonHelper.getBool(config, "auto_detect_address", AppInfo.AUTO_DETECT_ADDRESS);
                    AppInfo.SHOW_SORTING_IF_FILTER_UNAVAILABLE = JsonHelper.getBool(config, "show_sorting_if_filter_unavailable", AppInfo.SHOW_SORTING_IF_FILTER_UNAVAILABLE);
                    AppInfo.PRODUCT_DEEPLINK = JsonHelper.getString(config, "product_deeplink", AppInfo.PRODUCT_DEEPLINK);
                    AppInfo.SHOW_ACTIONBAR_ICON = JsonHelper.getBool(config, "show_actionbar_icon", AppInfo.SHOW_ACTIONBAR_ICON);
                    AppInfo.ACTIONBAR_ICON_URL = JsonHelper.getString(config, "actionbar_icon_url", AppInfo.ACTIONBAR_ICON_URL);
                    AppInfo.ACTION_BAR_HOME_TITLE = JsonHelper.getString(config, "action_bar_home_title", AppInfo.ACTION_BAR_HOME_TITLE);
                    AppInfo.SHOW_HOME_TITLE_TEXT = JsonHelper.getBool(config, "show_home_title_text", AppInfo.SHOW_HOME_TITLE_TEXT);
                    AppInfo.ALLOW_NEGATIVE_SHIPPING_HACK = JsonHelper.getBool(config, "allow_negative_shipping_hack", AppInfo.ALLOW_NEGATIVE_SHIPPING_HACK);
                    AppInfo.REQUIRED_PASSWORD_STRENGTH = JsonHelper.getInt(config, "required_password_strength", AppInfo.REQUIRED_PASSWORD_STRENGTH);
                    AppInfo.SHOW_SIGNUP_UI = JsonHelper.getBool(config, "show_signup_ui", AppInfo.SHOW_SIGNUP_UI);
                    AppInfo.SHOW_SECTION_BEST_DEALS = JsonHelper.getBool(config, "show_section_best_deals", AppInfo.SHOW_SECTION_BEST_DEALS);
                    AppInfo.SHOW_SECTION_FRESH_ARRIVALS = JsonHelper.getBool(config, "show_section_fresh_arrivals", AppInfo.SHOW_SECTION_FRESH_ARRIVALS);
                    AppInfo.SHOW_SECTION_TRENDING = JsonHelper.getBool(config, "show_section_trending", AppInfo.SHOW_SECTION_TRENDING);
                    AppInfo.SHOW_UPSELL_PRODUCTS = JsonHelper.getBool(config, "show_upsell_products", AppInfo.SHOW_UPSELL_PRODUCTS);
                    AppInfo.SHOW_CROSSSEL_PRODUCTS = JsonHelper.getBool(config, "show_crosssell_products", AppInfo.SHOW_CROSSSEL_PRODUCTS);
                    AppInfo.SHOW_DISCOUNT_PERCENTAGE_ON_PRODUCTS = JsonHelper.getBool(config, "show_discount_percentage_on_products", AppInfo.SHOW_DISCOUNT_PERCENTAGE_ON_PRODUCTS);
                    AppInfo.ENABLE_CUSTOM_WISHLIST = JsonHelper.getBool(config, "enable_custom_wishlist", AppInfo.ENABLE_CUSTOM_WISHLIST);
                    AppInfo.ENABLE_MULTIPLE_WISHLIST = JsonHelper.getBool(config, "enable_multiple_wishlist", AppInfo.ENABLE_MULTIPLE_WISHLIST);
                    AppInfo.ENABLE_CART = JsonHelper.getBool(config, "enable_cart", AppInfo.ENABLE_CART);
                    AppInfo.HIDE_NOTIFICATIONS_LIST = JsonHelper.getBool(config, "hide_notifications_list", AppInfo.HIDE_NOTIFICATIONS_LIST);
                    AppInfo.ENABLE_CUSTOM_WAITLIST = JsonHelper.getBool(config, "enable_custom_waitlist", AppInfo.ENABLE_CUSTOM_WAITLIST);
                    AppInfo.ENABLE_CUSTOM_POINTS = JsonHelper.getBool(config, "enable_custom_points", AppInfo.ENABLE_CUSTOM_POINTS);
                    AppInfo.ENABLE_AUTO_COUPONS = JsonHelper.getBool(config, "enable_auto_coupons", AppInfo.ENABLE_AUTO_COUPONS);
                    AppInfo.ENABLE_WEBVIEW_PAYMENT = JsonHelper.getBool(config, "enable_webview_payment", AppInfo.ENABLE_WEBVIEW_PAYMENT);
                    AppInfo.EDIT_PROFILE_ON_LOGIN = JsonHelper.getBool(config, "edit_profile_on_login", AppInfo.EDIT_PROFILE_ON_LOGIN);
                    AppInfo.HIDE_COUPON_LIST = JsonHelper.getBool(config, "hide_coupon_list", AppInfo.HIDE_COUPON_LIST);
                    AppInfo.FULL_SCREEN_LOGIN = JsonHelper.getBool(config, "full_screen_login", AppInfo.FULL_SCREEN_LOGIN);
                    AppInfo.CANCELLABLE_LOGIN = JsonHelper.getBool(config, "cancellable_login", AppInfo.CANCELLABLE_LOGIN);
                    AppInfo.SHOW_LOGIN_AT_START = JsonHelper.getBool(config, "show_login_at_start", AppInfo.SHOW_LOGIN_AT_START);
                    AppInfo.CHECK_MIN_ORDER_DATA = JsonHelper.getBool(config, "check_min_order_data", AppInfo.CHECK_MIN_ORDER_DATA);
                    AppInfo.ENABLE_APP_RATING = JsonHelper.getBool(config, "enable_app_rating", AppInfo.ENABLE_APP_RATING);
                    AppInfo.ENABLE_WISHLIST_NOTE = JsonHelper.getBool(config, "enable_note_wishlist", AppInfo.ENABLE_WISHLIST_NOTE);
                    AppInfo.SHOW_KEEP_SHOPPING_IN_CART = JsonHelper.getBool(config, "show_keep_shopping_in_cart", AppInfo.SHOW_KEEP_SHOPPING_IN_CART);
                    AppInfo.SHOW_ORDER_AGAIN = JsonHelper.getBool(config, "show_order_again", AppInfo.SHOW_ORDER_AGAIN);
                    AppInfo.SHOW_NON_VARIATION_ATTRIBUTE = JsonHelper.getBool(config, "show_non_variation_attribute", AppInfo.SHOW_NON_VARIATION_ATTRIBUTE);
                    AppInfo.IS_VAT_EXEMPT = JsonHelper.getBool(config, "is_vat_exempt", AppInfo.IS_VAT_EXEMPT);
                    AppInfo.SHOW_TOTAL_SAVINGS = JsonHelper.getBool(config, "show_total_savings", AppInfo.SHOW_TOTAL_SAVINGS);
                    AppInfo.SHOW_OUTOFSTOCK_PRODUCT_TAG = JsonHelper.getBool(config, "show_outofstock_product_tag", AppInfo.SHOW_OUTOFSTOCK_PRODUCT_TAG);
                    AppInfo.SHOW_SALE_PRODUCT_TAG = JsonHelper.getBool(config, "show_sale_product_tag", AppInfo.SHOW_SALE_PRODUCT_TAG);

                    AppInfo.SHOW_NEW_PRODUCT_TAG = JsonHelper.getBool(config, "show_new_product_tag", AppInfo.SHOW_NEW_PRODUCT_TAG);
                    if (AppInfo.SHOW_NEW_PRODUCT_TAG) {
                        AppInfo.NEW_PRODUCT_DAYS_LIMIT = JsonHelper.getInt(config, "new_product_days_limit", AppInfo.NEW_PRODUCT_DAYS_LIMIT);
                    }

                    AppInfo.SHOW_CATEGORY_BANNER = JsonHelper.getBool(config, "show_category_banner", AppInfo.SHOW_CATEGORY_BANNER);
                    if (AppInfo.SHOW_CATEGORY_BANNER) {
                        AppInfo.SHOW_CATEGORY_BANNER_FULL = JsonHelper.getBool(config, "show_category_banner_full", AppInfo.SHOW_CATEGORY_BANNER_FULL);
                    }
                    AppInfo.SHOW_HOME_PAGE_BANNER = JsonHelper.getBool(config, "show_home_page_banner", AppInfo.SHOW_HOME_PAGE_BANNER);
                    AppInfo.ENABLE_SPECIAL_ORDER_NOTE = JsonHelper.getBool(config, "enable_special_order_note", AppInfo.ENABLE_SPECIAL_ORDER_NOTE);
                    AppInfo.SHOW_NESTED_CATEGORY_MENU = JsonHelper.getBool(config, "show_nested_category_menu", AppInfo.SHOW_NESTED_CATEGORY_MENU);
                    AppInfo.SHOW_CART_FOOTER_OVERLAY = JsonHelper.getBool(config, "show_cart_footer_overlay", AppInfo.SHOW_CART_FOOTER_OVERLAY);
                    AppInfo.USE_MULTIPLE_SHIPPING_ADDRESSES = JsonHelper.getBool(config, "use_multiple_shipping_addresses", AppInfo.USE_MULTIPLE_SHIPPING_ADDRESSES);
                    AppInfo.SHOW_APP_URL_IN_SHARE_TEXT = JsonHelper.getBool(config, "show_app_url_in_share_text", AppInfo.SHOW_APP_URL_IN_SHARE_TEXT);
                    AppInfo.SHOW_PRICE_IN_SHARE_TEXT = JsonHelper.getBool(config, "show_price_in_share_text", AppInfo.SHOW_PRICE_IN_SHARE_TEXT);
                    AppInfo.ENABLE_MULTI_STORE_CHECKOUT = JsonHelper.getBool(config, "enable_multi_store_checkout", AppInfo.ENABLE_MULTI_STORE_CHECKOUT);
                    AppInfo.SHOW_MOBILE_NUMBER_IN_SIGNUP = JsonHelper.getBool(config, "show_mobile_number_in_signup", AppInfo.SHOW_MOBILE_NUMBER_IN_SIGNUP);
                    AppInfo.REQUIRE_MOBILE_NUMBER_IN_SIGNUP = JsonHelper.getBool(config, "require_mobile_number_in_signup", AppInfo.REQUIRE_MOBILE_NUMBER_IN_SIGNUP);
                    AppInfo.SHOW_ONLY_MOBILE_NUMBER_IN_SIGNUP = JsonHelper.getBool(config, "show_only_mobile_number_in_signup", AppInfo.SHOW_ONLY_MOBILE_NUMBER_IN_SIGNUP);
                    AppInfo.EMAIL_DOMAIN = JsonHelper.getString(config, "email_domain", AppInfo.EMAIL_DOMAIN);
                    AppInfo.SHOW_PAYMENT_GATEWAY_DESCRIPTION = JsonHelper.getBool(config, "show_payment_gateway_description", AppInfo.SHOW_PAYMENT_GATEWAY_DESCRIPTION);
                    AppInfo.SHOW_PAYMENT_GATEWAY_INSTRUCTIONS = JsonHelper.getBool(config, "show_payment_gateway_instructions", AppInfo.SHOW_PAYMENT_GATEWAY_INSTRUCTIONS);
                    AppInfo.SHOW_RESET_PASSWORD = JsonHelper.getBool(config, "show_reset_password", AppInfo.SHOW_RESET_PASSWORD);
                    AppInfo.DATE_FORMAT_PATTERN = JsonHelper.getString(config, "date_format_pattern", AppInfo.DATE_FORMAT_PATTERN);
                    AppInfo.REMOVE_CART_OR_WISH_ITEMS = JsonHelper.getBool(config, "remove_cart_or_wish_items", AppInfo.REMOVE_CART_OR_WISH_ITEMS);
                    AppInfo.ENABLE_OTP_IN_COD_PAYMENT = JsonHelper.getBool(config, "enable_otp_in_cod_payment", AppInfo.ENABLE_OTP_IN_COD_PAYMENT);
                    AppInfo.SHOW_CATEGORY_PRODUCTS_COUNT = JsonHelper.getBool(config, "show_category_products_count", AppInfo.SHOW_CATEGORY_PRODUCTS_COUNT);
                    AppInfo.CATEGORY_TITLE_ALL_CAPS = JsonHelper.getBool(config, "category_title_all_caps", AppInfo.CATEGORY_TITLE_ALL_CAPS);
                    AppInfo.USE_LAT_LONG_IN_ORDER = JsonHelper.getBool(config, "use_lat_long_in_order", AppInfo.USE_LAT_LONG_IN_ORDER);
                    AppInfo.ENABLE_CURRENCY_SWITCHER = JsonHelper.getBool(config, "enable_currency_switcher", AppInfo.ENABLE_CURRENCY_SWITCHER);
                    AppInfo.SHOW_PICKUP_LOCATION = JsonHelper.getBool(config, "show_pickup_location", AppInfo.SHOW_PICKUP_LOCATION);
                    AppInfo.ENABLE_LOCATION_IN_FILTERS = JsonHelper.getBool(config, "enable_location_in_filters", AppInfo.ENABLE_LOCATION_IN_FILTERS);
                    AppInfo.ENABLE_FILTERS_PER_CATEGORY = JsonHelper.getBool(config, "enable_filters_per_category", AppInfo.ENABLE_FILTERS_PER_CATEGORY);
                    AppInfo.REQUIRE_ORDER_PAYMENT_PROOF = JsonHelper.getBool(config, "require_order_payment_proof", AppInfo.REQUIRE_ORDER_PAYMENT_PROOF);
                    AppInfo.SHOW_PRICE_LABELS = JsonHelper.getBool(config, "show_price_labels", AppInfo.SHOW_PRICE_LABELS);
                    AppInfo.SHOW_PRODUCTS_BOOKING_INFO = JsonHelper.getBool(config, "show_products_booking_info", AppInfo.SHOW_PRODUCTS_BOOKING_INFO);
                    AppInfo.SHOW_ORDER_PLACED_DIALOG = JsonHelper.getBool(config, "show_order_placed_dialog", AppInfo.SHOW_ORDER_PLACED_DIALOG);

                    AppInfo.ENABLE_MIXMATCH_PRODUCTS = JsonHelper.getBool(config, "enable_mixmatch_products", AppInfo.ENABLE_MIXMATCH_PRODUCTS);
                    AppInfo.ENABLE_BUNDLED_PRODUCTS = JsonHelper.getBool(config, "enable_bundled_products", AppInfo.ENABLE_BUNDLED_PRODUCTS);
                    AppInfo.SHOW_BOTTOM_NAV_MENU = JsonHelper.getBool(config, "show_bottom_nav_menu", AppInfo.SHOW_BOTTOM_NAV_MENU);
                    AppInfo.ENABLE_ROLE_PRICE = JsonHelper.getBool(config, "enable_role_price", AppInfo.ENABLE_ROLE_PRICE);
                    AppInfo.ENABLE_PRODUCT_ADDONS = JsonHelper.getBool(config, "enable_product_addons", AppInfo.ENABLE_PRODUCT_ADDONS);
                    AppInfo.ENABLE_DEPOSIT_ADDONS = JsonHelper.getBool(config, "enable_deposit_addons", AppInfo.ENABLE_DEPOSIT_ADDONS);
                    AppInfo.ENABLE_AUTO_SLIDE_BANNER = JsonHelper.getBool(config, "enable_auto_slide_banner", AppInfo.ENABLE_AUTO_SLIDE_BANNER);

                    // Configurations related to Data Engine
                    DataEngine.enable_mix_n_match = AppInfo.ENABLE_MIXMATCH_PRODUCTS || AppInfo.ENABLE_BUNDLED_PRODUCTS;
                    DataEngine.use_plugin_for_full_data = JsonHelper.getBool(config, "use_plugin_for_full_data", DataEngine.use_plugin_for_full_data);
                    DataEngine.hide_blocked_items = JsonHelper.getBool(config, "hide_blocked_items", DataEngine.hide_blocked_items);
                    DataEngine.show_child_cat_products_in_parent_cat = JsonHelper.getBool(config, "show_child_cat_products_in_parent_cat", DataEngine.show_child_cat_products_in_parent_cat);
                    DataEngine.load_extra_attrib_data = JsonHelper.getBool(config, "load_extra_attrib_data", DataEngine.load_extra_attrib_data);
                    DataEngine.append_variation_images = JsonHelper.getBool(config, "append_variation_images", DataEngine.append_variation_images);
                    DataEngine.use_plugin_for_pagging = JsonHelper.getBool(config, "use_plugin_for_pagging", DataEngine.use_plugin_for_pagging);
                    DataEngine.auto_generate_variations = JsonHelper.getBool(config, "auto_generate_variations", DataEngine.auto_generate_variations);
                    DataEngine.show_non_variation_attribute = JsonHelper.getBool(config, "show_non_variation_attribute", DataEngine.show_non_variation_attribute);
                    DataEngine.resize_product_thumbs = JsonHelper.getBool(config, "resize_product_thumbs", DataEngine.resize_product_thumbs);
                    DataEngine.resize_product_images = JsonHelper.getBool(config, "resize_product_images", DataEngine.resize_product_images);

                    // Configurations related to Network Utils
                    NetworkUtils.UPLOAD_LOG = JsonHelper.getBool(config, "upload_log", NetworkUtils.UPLOAD_LOG);
                    NetworkUtils.USE_NETWORK_COOKIES = JsonHelper.getBool(config, "enableCookieManagementHttpURLConnection", NetworkUtils.USE_NETWORK_COOKIES);
                    NetworkUtils.NETWORK_LIBRARY_TYPE = JsonHelper.getInt(config, "network_library_type", NetworkUtils.NETWORK_LIBRARY_TYPE);
                    NetworkUtils.REQUEST_USER_AGENT = JsonHelper.getString(config, "request_user_agent", NetworkUtils.REQUEST_USER_AGENT);
                    NetworkUtils.SSL_CONTEXT_PROTOCOL = JsonHelper.getString(config, "ssl_context_protocol", NetworkUtils.SSL_CONTEXT_PROTOCOL);

                    if (config.has("excluded_addresses")) {
                        try {
                            AppInfo.EXCLUDED_ADDRESSES.clear();
                            AppInfo.EXCLUDED_ADDRESSES.addAll(JsonHelper.getStringList(config, "excluded_addresses"));
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    } else {
                        // don't move this from here
                        AppInfo.EXCLUDED_ADDRESSES.clear();
                        AppInfo.EXCLUDED_ADDRESSES.add("billing_address_2");
                        AppInfo.EXCLUDED_ADDRESSES.add("shipping_address_2");
                    }

                    if (config.has("optional_addresses")) {
                        try {
                            AppInfo.OPTIONAL_ADDRESSES.clear();
                            AppInfo.OPTIONAL_ADDRESSES.addAll(JsonHelper.getStringList(config, "optional_addresses"));
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    } else {
                        // don't move this from here
                        AppInfo.OPTIONAL_ADDRESSES.clear();
                        AppInfo.OPTIONAL_ADDRESSES.add("billing_address_2");
                        AppInfo.OPTIONAL_ADDRESSES.add("shipping_address_2");
                        AppInfo.OPTIONAL_ADDRESSES.add("billing_postcode");
                        AppInfo.OPTIONAL_ADDRESSES.add("shipping_postcode");
                    }

                    if (config.has("restricted_categories")) {
                        try {
                            AppInfo.restrictedCategories = JsonHelper.getIntegerList(config, "restricted_categories");
                        } catch (Exception e) {
                            e.printStackTrace();
                            AppInfo.restrictedCategories = null;
                        }
                    } else {
                        AppInfo.restrictedCategories = null;
                    }

                    if (config.has("front_page_categories")) {
                        // if front page categories are there then
                        // remove default categories from front page
                        if (AppInfo.front_page_categories != null) {
                            AppInfo.front_page_categories.clear();
                        }
                        try {
                            JSONArray categories = config.getJSONArray("front_page_categories");
                            if (categories.length() == 0) {
                                AppInfo.front_page_categories = null;
                            } else {
                                for (int i = 0; i < categories.length(); i++) {
                                    JSONObject jsonObject = categories.getJSONObject(i);
                                    CategoryItem categoryItem = new CategoryItem();
                                    categoryItem.title = JsonHelper.getString(jsonObject, "title");
                                    categoryItem.id = JsonHelper.getInt(jsonObject, "id");
                                    AppInfo.front_page_categories.add(categoryItem);
                                }
                            }
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }

                    AppInfo.ENABLE_PRODUCT_DELIVERY_DATE = false;
                    FreshChatConfig.resetConfig();
                    MultiVendorConfig.resetConfig();
                    TimeSlotConfig.resetConfig();
                    ContactForm7Config.resetConfig();
                    ContactForm3Config.resetConfig();
                    ReservationFormConfig.resetConfig();
                    FirebaseAnalyticsConfig.resetConfig();
                    PinCodeSettingsConfig.resetConfig();
                    SponsorFriendConfig.resetConfig();
                    ProductDetailsConfig.createConfig(config);
                    ImageDownloaderConfig.createConfig(config);
                    CategoryLayoutsConfig.createConfig(config);
                    PinCodeSettingsConfig.createConfigOld(config);
                    WordPressMenuConfig.createConfig(config);
                    OrderNoteConfig.createConfig(config);
                    CartNoteConfig.createConfig(config);
                    GuestUserConfig.createConfig(config);
                    ConsentDialogConfig.createConfig(config);

                    if (config.has("home_menu_items")) {
                        AppInfo.HOME_MENU_ITEMS = JsonHelper.getIntArray(config, "home_menu_items");
                    } else {
                        AppInfo.HOME_MENU_ITEMS = new int[]{0, 1, 2, 3};
                    }

                    if (config.has("home_nav_menu_items")) {
                        AppInfo.HOME_NAV_MENU_ITEMS = JsonHelper.getIntArray(config, "home_nav_menu_items");
                    } else {
                        AppInfo.HOME_NAV_MENU_ITEMS = new int[]{0, 1, 2, 3};
                    }

                    if (config.has("product_menu_items")) {
                        AppInfo.PRODUCT_MENU_ITEMS = JsonHelper.getIntArray(config, "product_menu_items");
                    } else {
                        AppInfo.PRODUCT_MENU_ITEMS = new int[]{0, 1, 4};
                    }

                    AppInfo.drawerItems = null;
                    if (config.has("drawer_items")) {
                        try {
                            JSONArray array = config.getJSONArray("drawer_items");
                            AppInfo.drawerItems = new ArrayList<>();
                            for (int i = 0; i < array.length(); i++) {
                                NavDrawItem item = JsonUtils.createNavDrawItem(array.getJSONObject(i), this);
                                if (item != null) {
                                    AppInfo.drawerItems.add(item);
                                }
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }

                    AppInfo.profileItems = null;
                    if (config.has("profile_items")) {
                        try {
                            JSONArray jsonProfileItems = config.getJSONArray("profile_items");
                            AppInfo.profileItems = new ArrayList<>();
                            for (int i = 0; i < jsonProfileItems.length(); i++) {
                                JSONObject jsonProfileItem = jsonProfileItems.getJSONObject(i);
                                MyProfileItem drawerItem = JsonUtils.parseMyProfileObject(jsonProfileItem, this);
                                AppInfo.profileItems.add(drawerItem);
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }

                    AppInfo.homeMenuContactNumbers = null;
                    if (config.has("home_contact_numbers")) {
                        try {
                            AppInfo.homeMenuContactNumbers = JsonHelper.getStringList(config, "home_contact_numbers");
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }

                    AppInfo.ENABLE_LOCALIZATION = false;
                    if (config.has("language")) {
                        try {
                            String language = config.getJSONObject("language").toString();
                            L.getInstance().setLanguage(Language.parse(language));
                            ((TMStoreApp) getApplication()).loadSavedLocale();
                            //for backward compatibility
                            AppInfo.ENABLE_LOCALIZATION = true;
                        } catch (Exception e) {
                            e.printStackTrace();
                            L.getInstance();
                            AppInfo.ENABLE_LOCALIZATION = false;
                        }
                    }
                }

                if (object.has("apps")) {
                    JSONArray appsJsonArray = object.getJSONArray("apps");
                    for (int i = 0; i < appsJsonArray.length(); i++) {
                        JSONObject jsonObject = appsJsonArray.getJSONObject(i);
                        final String name = jsonObject.getString("app_name");
                        if (name.equalsIgnoreCase("FRESHCHAT")) {
                            FreshChatConfig.createConfig(jsonObject);
                        } else if (name.equalsIgnoreCase("MULTIVENDOR")) {
                            MultiVendorConfig.createConfig(jsonObject);
                        } else if (name.equalsIgnoreCase("TIMESLOT")) {
                            TimeSlotConfig.createConfiguration(jsonObject);
                        } else if (name.equalsIgnoreCase("CONTACTFORM7")) {
                            ContactForm7Config.createConfig(jsonObject);
                        } else if (name.equalsIgnoreCase("CONTACTFORM3")) {
                            ContactForm3Config.createConfig(jsonObject);
                        } else if (name.equalsIgnoreCase("RESERVATIONFORM")) {
                            ReservationFormConfig.createConfig(jsonObject);
                        } else if (name.equalsIgnoreCase("FIREBASEANALYTICS")) {
                            FirebaseAnalyticsConfig.createConfiguration(jsonObject);
                        } else if (name.equalsIgnoreCase("PINCODE_SETTINGS")) {
                            PinCodeSettingsConfig.createConfig(jsonObject);
                        } else if (name.equalsIgnoreCase("SPONSOR_FRIEND")) {
                            SponsorFriendConfig.createConfig(jsonObject);
                        } else if (name.equalsIgnoreCase("PRODUCT_DELIVERY_DATE")) {
                            AppInfo.ENABLE_PRODUCT_DELIVERY_DATE = JsonHelper.getBool(jsonObject, "enabled", AppInfo.ENABLE_PRODUCT_DELIVERY_DATE);
                        }
                    }
                }

                // SHIPPING
                {
                    // Reset shipping variables
                    AppInfo.SHIPPING_PROVIDER = "";
                    AppInfo.SHIPPING_KEY = "";
                    AppInfo.SHIPPING_MINIMUM_WEIGHT = 0;
                    AppInfo.SHIPPING_DEFAULT_WEIGHT = 0;
                    AppInfo.SHIPPING_TRACK_URL = "";
                    AppInfo.ENABLE_SHIPMENT_TRACKING = false;

                    if (object.has("shipping")) {
                        try {
                            JSONArray jsonArray = object.getJSONArray("shipping");
                            if (jsonArray.length() > 0) {
                                JSONObject jsonObject = jsonArray.getJSONObject(0);
                                String provider = jsonObject.getString("provider");
                                switch (provider) {
                                    case Constants.Key.SHIPPING_RAJAONGKIR:
                                        AppInfo.SHIPPING_PROVIDER = Constants.Key.SHIPPING_RAJAONGKIR;
                                        AppInfo.SHIPPING_KEY = jsonObject.getString("key");
                                        AppInfo.SHIPPING_MINIMUM_WEIGHT = jsonObject.getInt("minimum_weight");
                                        AppInfo.SHIPPING_DEFAULT_WEIGHT = jsonObject.getInt("default_weight");
                                        AppInfo.SHIPPING_TRACK_URL = JsonHelper.getString(jsonObject, "tracking_url");
                                        AppInfo.ENABLE_SHIPMENT_TRACKING = !TextUtils.isEmpty(AppInfo.SHIPPING_TRACK_URL);
                                        break;
                                    case Constants.Key.SHIPPING_EPEKEN_JNE:
                                        AppInfo.SHIPPING_PROVIDER = Constants.Key.SHIPPING_EPEKEN_JNE;
                                        AppInfo.SHIPPING_KEY = "";
                                        break;
                                    case Constants.Key.SHIPPING_JNE_ALL_COURIER:
                                        AppInfo.SHIPPING_PROVIDER = Constants.Key.SHIPPING_JNE_ALL_COURIER;
                                        AppInfo.SHIPPING_KEY = "";
                                        break;
                                    case Constants.Key.SHIPPING_AFTERSHIP:
                                        AppInfo.SHIPPING_PROVIDER = Constants.Key.SHIPPING_AFTERSHIP;
                                        AppInfo.SHIPPING_TRACK_URL = jsonObject.getString("tracking_url");
                                        AppInfo.ENABLE_SHIPMENT_TRACKING = true;
                                        break;
                                }
                            }
                        } catch (Exception e) {
                            Log.e("Error while parsing shipping data");
                            e.printStackTrace();
                        }
                    }
                }

                PaymentManager.INSTANCE.setPaymentJson(object);
                NotificationConfig.createConfig(object);
                NavDrawerConfig.createConfig(object);
                SignUpConfig.createConfig(object);
            } catch (Exception e) {
                e.printStackTrace();
                Log.e("Error while parsing addons data");
            }

            PackageInfo packageInfo = getPackageManager().getPackageInfo(getPackageName(), 0);

            AppInfo.homeConfigUltimate = null;
            if (appData.has("homeConfigUltimate")) {
                try {
                    int versionName = Helper.versionStrToInt(packageInfo.versionName);
                    String jsonString = appData.getString("homeConfigUltimate");
                    if (!TextUtils.isEmpty(jsonString)) {
                        JSONObject jsonObject = new JSONObject(jsonString);
                        int min_app_version = Helper.versionStrToInt(jsonObject.getString("min_app_version"));
                        if (versionName >= min_app_version) {
                            AppInfo.homeConfigUltimate = new Gson().fromJson(jsonString, HomeConfigUltimate.class);
                            AppInfo.homeConfigUltimate.calculateDimensions();
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    Log.e("Error while parsing homeConfigUltimate data");
                    AppInfo.homeConfigUltimate = null;
                }
            }

            try {
                if (appData.has("homeConfigUltimateLand")) {
                    String jsonString = "{\"homeElements\":" + appData.getString("homeConfigUltimateLand") + "}";
                    AppInfo.homeConfigUltimateLand = new Gson().fromJson(jsonString, HomeConfigUltimate.class);
                    AppInfo.homeConfigUltimateLand.calculateDimensions();
                }
            } catch (Exception e) {
                e.printStackTrace();
                Log.e("Error while parsing homeConfigUltimateLand data");
                AppInfo.homeConfigUltimateLand = null;
            }

            boolean isEmpty = true;
            try {
                String json = appData.getString("promo_json");
                if (json != null) {
                    JsonUtils.parseJsonAndCretePromo(json);
                    isEmpty = false;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            if (isEmpty) {
                AppInfo.PROMO_TITLE = "";
                AppInfo.PROMO_DESC = "";
                AppInfo.PROMO_URL = "";
                AppInfo.PROMO_IMG_URL = "";
            }

            if (AppInfo.contactDetails != null) {
                AppInfo.contactDetails.clear();
                AppInfo.contactDetails = null;
            }
            String contactDetail = appData.getString("contactDetail");
            if (!TextUtils.isEmpty(contactDetail)) {
                try {
                    AppInfo.contactDetails = JsonUtils.generateContactDetails(contactDetail);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            AppInfo.sort_config = appData.getString("sort_config");
            AppInfo.ABOUT_URL = appData.getString("about_url");
            AppInfo.MERCHANT_ID = appData.getString("merchant_id");
            AppInfo.FACEBOOK_APP_ID = appData.getString("fb_appid");
            AppInfo.TWITTER_APP_KEY = appData.getString("twitter_key");
            AppInfo.GOOGLE_APP_KEY = appData.getString("google_key");

            AppInfo.ENABLE_COUPONS = ParseHelper.getBool(appData, "enableCoupons", AppInfo.ENABLE_COUPONS);
            AppInfo.SHOW_SEASONAL_GREETINGS = appData.getBoolean("showSeasonalGreetings");
            AppInfo.ENABLE_PROMO_BUTTON = appData.getBoolean("enable_promo_button");
            AppInfo.AUTO_SIGNIN_IN_HIDDEN_WEBVIEW = appData.getBoolean("auto_signin_in_hidden_webview");
            AppInfo.ENABLE_FILTERS = appData.getBoolean("enable_filters");
            AppInfo.ID_LAYOUT_PRODUCTS = appData.getInt("id_layout_products");
            AppInfo.ID_LAYOUT_CATEGORIES = appData.getInt("id_layout_categories");
            AppInfo.ID_LAYOUT_CART = ParseHelper.getInt(appData, "id_layout_cart", AppInfo.ID_LAYOUT_CART);
            AppInfo.DEEP_LINK_URL = ParseHelper.getString(appData, "deep_link_url", AppInfo.DEEP_LINK_URL);

            DataEngine.refine_categories = appData.getBoolean("refine_categories");
            DataEngine.stepup_single_child_categories = appData.getBoolean("stepup_single_child_categories");
            DataEngine.max_categories_query_count_limit = ParseHelper.getInt(appData, "max_categories_query_count_limit", DataEngine.max_categories_query_count_limit);
            DataEngine.max_products_query_count_limit = ParseHelper.getInt(appData, "max_products_query_count_limit", DataEngine.max_products_query_count_limit);
            DataEngine.max_initial_products_query_limit = ParseHelper.getInt(appData, "max_initial_products_query_limit", DataEngine.max_initial_products_query_limit);

            String wc_api_key = appData.getString(BuildConfig.DEMO_VERSION ? "wc_api_key" : "oauth_consumer_key");
            String wc_api_secret = appData.getString(BuildConfig.DEMO_VERSION ? "wc_api_secret" : "oauth_consumer_secret");
            String api_version = ParseHelper.getString(appData, BuildConfig.DEMO_VERSION ? "api_version" : "api_version_string", "v3");
            String mvp = MultiVendorConfig.getPluginType().getValue();
            String endpoint = ParseHelper.getString(appData, "endpoint", "tm");

            loadThemeColors(appData);
            loadBannerImage(appData);
            String baseUrl = getBaseUrl(appData);

            DataEngine.getDataEngine().initWithArgs(this, baseUrl, wc_api_key, wc_api_secret, api_version, endpoint, mvp, AppInfo.SHIPPING_PROVIDER, AppInfo.SHIPPING_KEY);

            if (appData.getBoolean("show_tmstore_text")) {
                txt_tmstore.setVisibility(View.VISIBLE);
                new FadeInAnimation(txt_tmstore).animate();
            }

            TM_CommonInfo.thousand_separator = appData.getString("thousand_separator");
            if (TextUtils.isEmpty(TM_CommonInfo.thousand_separator)) {
                TM_CommonInfo.thousand_separator = ",";
            }

            initAppComponents();

            int versionName = Helper.versionStrToInt(packageInfo.versionName);
            int versionCode = packageInfo.versionCode;
            Log.d("-- versionName: [" + versionName + "] & versionCode: [" + versionCode + "] --");
            int min_app_version = Helper.versionStrToInt(ParseHelper.getString(appData, "min_app_version", "1.0.0"));
            int current_app_version = Helper.versionStrToInt(ParseHelper.getString(appData, "current_app_version", "1.0.0"));
            if (versionName < min_app_version) {
                View.OnClickListener updateListener = new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Helper.openPlayStorePage(LauncherActivity.this);
                    }
                };
                new UpdateAppDialog().showDialog(this, true, updateListener, null);
                handleFetchingError(L.string.outdated_version);
                return;
            } else if (versionName < current_app_version) {
                Log.d("Update available");
                View.OnClickListener updateListener = new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Helper.openPlayStorePage(LauncherActivity.this);
                    }
                };
                View.OnClickListener cancelListener = new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        parseDataLoaded = true;
                        loadRequiredContent();
                    }
                };
                new UpdateAppDialog().showDialog(this, false, updateListener, cancelListener);
                return;
            }

            // For LiveChat and FCM
            if (FreshChatConfig.isEnabled() || NotificationConfig.isEnabled()) {
                if (checkPlayServices(this)) {
                    startService(new Intent(this, MyFcmRegistrationService.class));
                }
            }
            loadNewSplash(appData);
        } catch (Exception e) {
            e.printStackTrace();
            handleFetchingError(L.string.parse_object_error);
        }
    }

    private void loadThemeColors(ParseObject appData) {
        if (appData.has("app_color") && AppInfo.ENABLE_THEME_COLORS) {
            String jsonColors = appData.getString("app_color");
            if (!TextUtils.isEmpty(jsonColors)) {
                try {
                    JsonUtils.parseJsonAndCreateAppColors(jsonColors);
                } catch (Exception e) {
                    Log.d("Error while parsing app colors.");
                    e.printStackTrace();
                    initAppColors();
                }
            } else {
                initAppColors();
            }
            // Style loading text and bar according to theme color.
            Helper.stylizeSplashText(txt_loading);
            Helper.stylize(progressBar);
        }
    }

    private void loadBannerImage(ParseObject appData) {
        if (appData.has("image_data")) {
            try {
                String bannerString = appData.getString("image_data");
                AppInfo.banners = JsonUtils.getBannersFromJson(bannerString);
            } catch (Exception e) {
                e.printStackTrace();
                AppInfo.banners = null;
            }
        }
    }

    private String getBaseUrl(ParseObject appData) {
        String url = appData.getString(BuildConfig.DEMO_VERSION ? "site_url" : "baseurl");
        if (!TextUtils.isEmpty(url)) {
            url = url.trim();
            if (url.charAt(url.length() - 1) == '/') {
                Log.e("Base URL contains trailing backward slash character { / }");
            }
        }
        if (!TextUtils.isEmpty(AppInfo.PRODUCT_DEEPLINK)) {
            AppInfo.PRODUCT_DEEPLINK_URL = url + "/" + AppInfo.PRODUCT_DEEPLINK;
        }
        return url;
    }

    private void loadNewSplash(ParseObject appData) throws Exception {
        img_splash_full.setScaleType(ImageView.ScaleType.CENTER_CROP);
        img_splash_full.setLayoutParams(new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.MATCH_PARENT));
        splashLayout.setBackgroundColor(Color.parseColor(AppInfo.color_splash_bg));

        String newSplashUrl = appData.getString("splash_url");
        Preferences.putString("splash_url", newSplashUrl);
        showLoading();
        if (AppInfo.DEMO_APP)
            image_app_splash.setVisibility(View.VISIBLE);
        Glide.with(this)
                .load(newSplashUrl)
                .listener(new RequestListener<String, GlideDrawable>() {
                    @Override
                    public boolean onException(Exception e, String model, Target<GlideDrawable> target, boolean isFirstResource) {
                        parseDataLoaded = true;
                        hideLoading();
                        loadDummyContent();
                        loadRequiredContent();
                        return false;
                    }

                    @Override
                    public boolean onResourceReady(GlideDrawable resource, String model, Target<GlideDrawable> target, boolean isFromMemoryCache, boolean isFirstResource) {
                        image_app_splash.setVisibility(View.INVISIBLE);
                        parseDataLoaded = true;
                        hideLoading();
                        loadDummyContent();
                        loadRequiredContent();
                        return false;
                    }
                }).into(img_splash_full);
    }

    private void loadDummyContent() {
        if (AppInfo.drawerItems == null)
            AppInfo.drawerItems = new ArrayList<>();

        if (AppInfo.drawerItems.isEmpty()) {
            AppInfo.drawerItems.add(new NavDrawItem(Constants.MENU_ID_HOME));
            AppInfo.drawerItems.add(new NavDrawItem(Constants.MENU_ID_CATEGORIES));
            AppInfo.drawerItems.add(new NavDrawItem(Constants.MENU_ID_WISH));
            AppInfo.drawerItems.add(new NavDrawItem(Constants.MENU_ID_CART));
            AppInfo.drawerItems.add(new NavDrawItem(Constants.MENU_ID_MY_COUPONS));
            AppInfo.drawerItems.add(new NavDrawItem(Constants.MENU_ID_NOTIFICATIONS));
            AppInfo.drawerItems.add(new NavDrawItem(Constants.MENU_ID_ORDERS));
            AppInfo.drawerItems.add(new NavDrawItem(Constants.MENU_ID_SEARCH));
            AppInfo.drawerItems.add(new NavDrawItem(Constants.MENU_ID_ABOUT));
            AppInfo.drawerItems.add(new NavDrawItem(Constants.MENU_ID_FRESH_CHAT));
            AppInfo.drawerItems.add(new NavDrawItem(Constants.MENU_ID_SETTINGS));
            AppInfo.drawerItems.add(new NavDrawItem(Constants.MENU_ID_SELLER_HOME));
            AppInfo.drawerItems.add(new NavDrawItem(Constants.MENU_ID_CHANGE_SELLER));
            AppInfo.drawerItems.add(new NavDrawItem(Constants.MENU_ID_SIGN_OUT));
            AppInfo.drawerItems.add(new NavDrawItem(Constants.MENU_ID_SIGN_IN));
            AppInfo.drawerItems.add(new NavDrawItem(Constants.MENU_ID_REFER_FRIEND));
            AppInfo.drawerItems.add(new NavDrawItem(Constants.MENU_ID_RATE_APP));
            AppInfo.drawerItems.add(new NavDrawItem(Constants.MENU_ID_WP_MENU));
            AppInfo.drawerItems.add(new NavDrawItem(Constants.MENU_ID_RESERVATION_FORM));
            AppInfo.drawerItems.add(new NavDrawItem(Constants.MENU_ID_CONTACT_FORM3));
            if (BuildConfig.DEMO_VERSION) {
                AppInfo.drawerItems.add(new NavDrawItem(Constants.MENU_ID_LIVE_CHAT));
            }
            if (BuildConfig.MULTI_STORE) {
                AppInfo.drawerItems.add(new NavDrawItem(Constants.MENU_ID_SCAN_PRODUCT));
                AppInfo.drawerItems.add(new NavDrawItem(Constants.MENU_ID_CHANGE_STORE));
                AppInfo.drawerItems.add(new NavDrawItem(Constants.MENU_ID_LOCATE_STORE));
            }
        }

        if (AppInfo.front_page_categories != null && AppInfo.front_page_categories.isEmpty()) {
            AppInfo.front_page_categories.add(new CategoryItem(CategoryItem.ID_TRENDING_ITEMS, null));
            AppInfo.front_page_categories.add(new CategoryItem(CategoryItem.ID_BEST_DEALS, null));
            AppInfo.front_page_categories.add(new CategoryItem(CategoryItem.ID_FRESH_ARRIVALS, null));
            AppInfo.front_page_categories.add(new CategoryItem(CategoryItem.ID_RECENTLY_VIEWED, null));
        }

        if (AppInfo.profileItems == null) {
            AppInfo.profileItems = new ArrayList<>();
        }

        if (AppInfo.profileItems.isEmpty()) {
            AppInfo.profileItems.add(new MyProfileItem(Constants.MENU_ID_MY_ADDRESS));
            AppInfo.profileItems.add(new MyProfileItem(Constants.MENU_ID_ORDERS));
            AppInfo.profileItems.add(new MyProfileItem(Constants.MENU_ID_RATE_APP));
            AppInfo.profileItems.add(new MyProfileItem(Constants.MENU_ID_ABOUT));
            AppInfo.profileItems.add(new MyProfileItem(Constants.MENU_ID_SIGN_OUT));
        }
    }

    private void loadLanguages() {
        showLoading();
        L.loadLanguagesAsync(new L.LoadCallback() {
            @Override
            public void onSuccess(final boolean updated) {
                languagesLoaded = true;
                Locale locale = getResources().getConfiguration().locale;
                final Language language = L.getInstance().getLanguage();
                if (locale.toString().equals(language.defaultLocale)) {
                    L.getInstance().loadDefault();
                    loadRequiredContent();
                } else {
                    String lastSelectedLanguage = Preferences.getString(R.string.key_current_lang, "");
                    L.LocaleConfig[] localeConfigs = L.getInstance().getLanguage().localeConfigs;
                    if (TextUtils.isEmpty(lastSelectedLanguage) && localeConfigs.length > 1) {
                        AlertDialog.Builder builder = new AlertDialog.Builder(LauncherActivity.this);
                        builder.setCancelable(false);
                        builder.setTitle(getString(L.string.select_language));
                        builder.setSingleChoiceItems(language.getTitles(), 0, null);
                        builder.setPositiveButton(android.R.string.ok, (dialog, whichButton) -> {
                            int position = ((AlertDialog) dialog).getListView().getCheckedItemPosition();
                            if (position >= 0) {
                                String locale1 = language.getLocales()[position];
                                Preferences.putString(R.string.key_current_lang, locale1);
                                Preferences.putString(R.string.key_app_lang, locale1);
                                TMStoreApp application = (TMStoreApp) getApplication();
                                application.setLocale(locale1, updated);
                                loadRequiredContent();
                                updateTextViews();
                            }
                            dialog.dismiss();
                        });
                        builder.show();
                    } else {
                        String _locale = Preferences.getString(R.string.key_app_lang, language.defaultLocale);
                        TMStoreApp application = (TMStoreApp) getApplication();
                        application.setLocale(_locale, updated);
                        loadRequiredContent();
                        updateTextViews();
                    }
                }
            }

            @Override
            public void onError() {
                AppInfo.ENABLE_LOCALIZATION = false;
                languagesLoaded = true;
                loadRequiredContent();
            }
        });
    }

    private void loadSplashProducts() {
        txt_loading.setText(getString(L.string.loading_products));
        showLoading();
        DataEngine.getDataEngine().getFrontPageContentInBackground(new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {
                Cart.refresh();
                Wishlist.refresh();
                refreshSortOrder();
                refreshCategories();
                contentLoaded = true;
                loadCustomerData();
            }

            @Override
            public void onFailure(Exception exception) {
                hideLoading(true);
                final String errorMessage = exception.getMessage();
                if (TextUtils.isEmpty(errorMessage)) {
                    handleFetchingError(getString(L.string.generic_error));
                } else {
                    Log.d("-- msg: [" + errorMessage + "] --");
                    handleFetchingError(errorMessage);
                }
            }
        });
    }

    private void refreshCategories() {
        // Remove Categories
        if (!AppUser.hasSignedIn() && AppInfo.mGuestUserConfig != null) {
            List<Integer> restrictedCategoryIds = AppInfo.mGuestUserConfig.getRestrictedCategoryIds();
            if (restrictedCategoryIds.size() > 0) {
                List<TM_CategoryInfo> allCategories = TM_CategoryInfo.getAll();
                if (allCategories != null) {
                    for (TM_CategoryInfo category : allCategories) {
                        if (restrictedCategoryIds.contains(category.id)) {
                            category.isBlocked = true;
                        }
                    }
                }
            }
        }

        // Remove Categories
        if (AppInfo.restrictedCategories != null && !AppInfo.restrictedCategories.isEmpty()) {
            List<TM_CategoryInfo> allCategories = TM_CategoryInfo.getAll();
            if (allCategories != null) {
                for (TM_CategoryInfo category : allCategories) {
                    if (AppInfo.restrictedCategories.contains(category.id)) {
                        category.isBlocked = true;
                    }
                }
            }
        }
    }

    private void loadCustomerData() {
        if (AppInfo.ENABLE_ROLE_PRICE || MultiVendorConfig.isSellerApp() && AppUser.getInstance().isWordPressUser()) {
            LoginManager.fetchCustomerData(AppUser.getEmail(), new LoginListener() {
                @Override
                public void onLoginSuccess(String message) {
                    LoginManager.signInWeb(
                            AppUser.getInstance().email,
                            AppUser.getInstance().password,
                            new LoginListener() {
                                @Override
                                public void onLoginSuccess(String message) {
                                    String jsonData = AppUser.getInstance().getJsonData();
                                    if (!TextUtils.isEmpty(jsonData)) {
                                        JsonUtils.parseJsonAndCreateAppUser(jsonData);
                                        AppUser.getInstance().setJsonData("");
                                    }

                                    // handle if response is from user approval plugin
                                    if (!TextUtils.isEmpty(message)) {
                                        try {
                                            JSONObject jsonObject = new JSONObject(message);
                                            String msg = jsonObject.getString("msg");
                                            String status = jsonObject.getString("status");
                                            if (!TextUtils.isEmpty(status) && (status.equals("denied") || status.equals("pending"))) {
                                                PendingUserDialog pendingUserDialog = new PendingUserDialog();
                                                pendingUserDialog.showDialog(LauncherActivity.this, msg);
                                                hideLoading(true);
                                                return;
                                            }
                                        } catch (Exception e) {
                                            Log.w(e.getMessage());
                                        }
                                        if (AppInfo.ENABLE_ROLE_PRICE) {
                                            try {
                                                JSONObject jsonObject = new JSONObject(message);
                                                RolePrice rolePrice = RolePrice.create(jsonObject);
                                                AppUser.getInstance().setRolePrice(rolePrice);
                                                for (TM_ProductInfo productInfo : TM_ProductInfo.getAll()) {
                                                    RolePrice.applyPrice(productInfo);
                                                }
                                                hideLoading(true);
                                                loadRequiredContent();
                                            } catch (Exception e) {
                                                e.printStackTrace();
                                            }
                                        }
                                    }

                                    if (MultiVendorConfig.isSellerApp() && AppUser.getInstance().isWordPressUser()) {
                                        DataEngine.getDataEngine().fetchSellerInBackground(AppUser.getUserId(), new DataQueryHandler<String>() {
                                            @Override
                                            public void onSuccess(String data) {
                                                hideLoading();
                                                try {
                                                    SellerInfo.setCurrentSeller(JsonUtils.parseJsonAndCreateSellerInfo(data));
                                                    loadRequiredContent();
                                                } catch (JSONException e) {
                                                    e.printStackTrace();
                                                }
                                            }

                                            @Override
                                            public void onFailure(Exception exception) {
                                                hideLoading(true);
                                            }
                                        });
                                    }
                                }

                                @Override
                                public void onLoginFailed(String cause) {
                                    hideLoading(true);
                                    if (AppInfo.ENABLE_ROLE_PRICE) {
                                        loadRequiredContent();
                                    }
                                }
                            });
                }

                @Override
                public void onLoginFailed(String cause) {
                    hideLoading(true);
                    if (AppInfo.ENABLE_ROLE_PRICE) {
                        loadRequiredContent();
                    }
                }
            });
        } else {
            hideLoading(true);
            loadRequiredContent();
        }
    }

    private void refreshSortOrder() {
        if (AppInfo.sort_config != null && AppInfo.sort_config.length() > 0) {
            try {
                JSONObject jsonSortConfig = new JSONObject(AppInfo.sort_config);
                JSONArray categories = jsonSortConfig.getJSONArray("categories");
                for (int index = 0; index < categories.length(); index++) {
                    int id = categories.getInt(index);
                    if (TM_CategoryInfo.hasCategory(id)) {
                        TM_CategoryInfo.reorderCategoryIndex(id, index);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    private void launchVendorsActivity() {
        final Intent intent = new Intent(this, VendorsActivity.class);
        intent.putExtras(intent);
        startActivity(intent);
        this.finish();
    }

    private void launchMainActivity() {
        System.out.println("**** LauncherActivity **** Launch MainActivity ****");
        savePreferenceValues();
        final Intent intent = new Intent(this, MainActivity.class);
        final Bundle extras = fromIntent.getExtras();
        if (extras != null) {
            if (extras.containsKey("from") && extras.containsKey("message")) {
                String message = extras.getString("message");
                Notification notification = Notification.create(message);
                extras.putParcelable(Extras.NOTIFICATION, notification);
            } else if (extras.containsKey(Extras.REFERRER)) {
                // Ignore editor warning here. it is not unused actually, it is used only with demo build variant.
                String referrer = extras.getString(Extras.REFERRER);
                if (BuildConfig.DEMO_VERSION && StringUtils.startsWith(referrer, "appcode_")) {
                    try {
                        String demoCode = referrer.split("appcode_")[1];
                        if (!demoCode.equals(AppInfo.SAMPLE_APP_ID)) {
                            Preferences.putString("autoFillDemoCode", demoCode);
                        }
                    } catch (Exception ignored) {
                    }
                }

                int productId = -1;
                try {
                    String data = getIntent().getData().getSchemeSpecificPart();
                    if (data != null) {
                        productId = Integer.parseInt(data.split("pid=")[1]);
                        extras.putInt(Extras.PRODUCT_ID, productId);
                        extras.putString(Extras.REFERRER_TYPE, Constants.Key.REFERRER_PRODUCT);
                    }
                } catch (Exception ignored) {
                }

                if (productId < 0) {
                    try {
                        String jsonData = extras.getString("com.parse.Data");
                        if (!TextUtils.isEmpty(jsonData)) {
                            productId = JsonUtils.getProductIdFromNotificationJson(jsonData);
                            extras.putInt(Extras.PRODUCT_ID, productId);
                            extras.putString(Extras.REFERRER_TYPE, Constants.Key.REFERRER_PRODUCT);
                        }
                    } catch (Exception ignored) {
                    }
                }
            }
            intent.putExtras(extras);
            intent.setAction("notification");
        }

        if (getIntent().getData() != null) {
            intent.setData(getIntent().getData());
        }

        txt_loading.setVisibility(View.GONE);
        text_merchant_desc.setVisibility(View.GONE);

        ScaleOutAnimation scaleOutAnimation = new ScaleOutAnimation(progressBar);
        scaleOutAnimation.setListener(new AnimationListener() {
            @Override
            public void onAnimationEnd(Animation animation) {

                System.out.println("**** LauncherActivity startActivity(MainActivity) ****  finish" );
                LauncherActivity.this.startActivity(intent);
                LauncherActivity.this.finish();
            }
        });
        scaleOutAnimation.animate();
    }

    private void handleFetchingError(final String key) {
        errorWhileLoading = true;
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                hideLoading();
                String msg = getString(key);
                if (BuildConfig.DEMO_VERSION) {
                    showErrorDialog();
                } else {
                    error_page.setVisibility(View.VISIBLE);
                    TextView txt_error_msg = findViewById(R.id.txt_error_msg);
                    txt_error_msg.setText(msg);
                }
            }
        });
    }

    private void showErrorDialog() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        View view = LayoutInflater.from(this).inflate(R.layout.custom_error_dialog, null);
        TextView txt_msg = view.findViewById(R.id.txt_msg);
        TextView tv_chat = view.findViewById(R.id.tv_chat);
        TextView tv_email = view.findViewById(R.id.tv_email);
        TextView txt_visit = view.findViewById(R.id.txt_visit);
        Helper.stylizeView(view.findViewById(R.id.header_box));
        TextView header_msg = view.findViewById(R.id.header_msg);
        View chat_layout = view.findViewById(R.id.chat_layout);
        View email_layout = view.findViewById(R.id.email_layout);
        View image_flag_bg = view.findViewById(R.id.image_flag_bg);
        View image_flag_bg1 = view.findViewById(R.id.image_flag_bg1);
        header_msg.setText(getString(L.string.error));
        Helper.stylizeStroke(image_flag_bg);
        Helper.stylizeStroke(image_flag_bg1);
        Helper.stylizeActionBar(header_msg);
        final TextView tv_link = view.findViewById(R.id.tv_link);
        tv_email.setText(getString(L.string.email));
        tv_chat.setText(getString(L.string.title_live_chat));
        txt_visit.setText(getString(L.string.visit));
        txt_msg.setText(getString(L.string.contact_support_team));
        tv_link.setText(getString(R.string.site_url));
        Linkify.addLinks(tv_link, Linkify.WEB_URLS);
        ImageView img_email = view.findViewById(R.id.img_email);
        ImageView img_chat = view.findViewById(R.id.img_chat);
        ImageButton btn_close = view.findViewById(R.id.btn_close);
        Helper.stylize(img_email);
        Helper.stylize(img_chat);
        builder.setView(view).setCancelable(true);
        final AlertDialog alertDialog = builder.create();
        btn_close.setOnClickListener(v -> alertDialog.dismiss());
        chat_layout.setOnClickListener(v -> {
            alertDialog.dismiss();
            LiveChatHandler.startChatScreen(LauncherActivity.this);
        });
        email_layout.setOnClickListener(v -> {
            alertDialog.dismiss();
            Helper.email(LauncherActivity.this, getString(R.string.mail_address));
        });
        tv_link.setOnClickListener(v -> {
            alertDialog.dismiss();
            Helper.visitSite(LauncherActivity.this, getString(R.string.site_url));
        });
        alertDialog.show();
    }

    private void showLoading() {
        if (txt_loading.getVisibility() == View.GONE)
            txt_loading.setVisibility(View.VISIBLE);
        if (progressBar.getVisibility() == View.GONE)
            progressBar.setVisibility(View.VISIBLE);
        hideErrorPage();
    }

    private void hideLoading() {
        hideLoading(false);
    }

    private void hideLoading(boolean textOnly) {
        if (txt_loading.getVisibility() == View.VISIBLE)
            txt_loading.setVisibility(View.GONE);

        if (!textOnly && progressBar.getVisibility() == View.VISIBLE)
            progressBar.setVisibility(View.GONE);
    }

    private void initAppColors() {
        AppInfo.color_theme = Preferences.getColorString("color_theme", R.color.color_theme);
        AppInfo.color_theme_dark = Preferences.getColorString("color_theme_dark", R.color.color_theme_statusbar);
        AppInfo.color_theme_statusbar = Preferences.getColorString("color_theme_statusbar", R.color.color_theme_statusbar);
        AppInfo.normal_button_color = Preferences.getColorString("normal_button_color", R.color.normal_button_color);
        AppInfo.normal_button_text_color = Preferences.getColorString("normal_button_text_color", R.color.selected_button_color);
        AppInfo.selected_button_color = Preferences.getColorString("selected_button_color", R.color.selected_button_color);
        AppInfo.selected_button_text_color = Preferences.getColorString("selected_button_text_color", R.color.normal_button_color);
        AppInfo.disable_button_color = Preferences.getColorString("disable_button_color", R.color.disable_button_color);
        AppInfo.color_pager_title_strip = Preferences.getColorString("color_pager_title_strip", R.color.color_pager_title_strip);
        AppInfo.color_actionbar_text = Preferences.getColorString("color_actionbar_text", R.color.color_actionbar_text);
        AppInfo.color_splash_text = Preferences.getColorString("color_splash_text", R.color.color_splash_text);
        AppInfo.color_regular_price = Preferences.getColorString("color_regular_price", R.color.color_regular_price);
        AppInfo.color_sale_price = Preferences.getColorString("color_sale_price", R.color.color_sale_price);
        AppInfo.color_splash_bg = Preferences.getColorString("color_splash_bg", R.color.color_splash_bg);
        AppInfo.color_home_section_header_bg = Preferences.getColorString("color_home_section_header_bg", R.color.color_home_section_header_bg);
        AppInfo.color_home_section_header_text = Preferences.getColorString("color_home_section_header_text", R.color.color_home_section_header_text);
        AppInfo.color_bottom_nav_selected = Preferences.getColorString("color_bottom_nav_selected", R.color.color_bottom_nav_selected);
        AppInfo.color_bottom_nav_normal = Preferences.getColorString("color_bottom_nav_normal", R.color.color_bottom_nav_normal);
        AppInfo.color_bottom_nav_bg = Preferences.getColorString("color_bottom_nav_bg", R.color.color_bottom_nav_bg);

        if (Log.DEBUG) {
            Log.d("color_theme: " + AppInfo.color_theme);
            Log.d("color_theme_dark: " + AppInfo.color_theme_dark);
            Log.d("color_theme_statusbar: " + AppInfo.color_theme_statusbar);
            Log.d("normal_button_color: " + AppInfo.normal_button_color);
            Log.d("normal_button_text_color: " + AppInfo.normal_button_text_color);
            Log.d("selected_button_color: " + AppInfo.selected_button_color);
            Log.d("selected_button_text_color: " + AppInfo.selected_button_text_color);
            Log.d("disable_button_color: " + AppInfo.disable_button_color);
            Log.d("color_pager_title_strip: " + AppInfo.color_pager_title_strip);
            Log.d("color_actionbar_text: " + AppInfo.color_actionbar_text);
            Log.d("color_splash_bg: " + AppInfo.color_splash_bg);
            Log.d("color_home_section_header_bg: " + AppInfo.color_home_section_header_bg);
            Log.d("color_home_section_header_text: " + AppInfo.color_home_section_header_text);
            Log.d("color_bottom_nav_selected: " + AppInfo.color_bottom_nav_selected);
            Log.d("color_bottom_nav_normal: " + AppInfo.color_bottom_nav_normal);
            Log.d("color_bottom_nav_bg: " + AppInfo.color_bottom_nav_bg);
        }
    }

    public void savePreferenceValues() {
        String appId = editText.getText().toString().trim();
        if (!appId.equals(AppInfo.SAMPLE_APP_ID))
            Preferences.putString("demoAppId", appId);

        Preferences.putString("welcome_string", getString(L.string.checking_app_data));

        HashMap<String, String> colorMap = new HashMap<>();
        colorMap.put("color_theme", AppInfo.color_theme);
        colorMap.put("color_theme_dark", AppInfo.color_theme_dark);
        colorMap.put("color_theme_statusbar", AppInfo.color_theme_statusbar);
        colorMap.put("normal_button_color", AppInfo.normal_button_color);
        colorMap.put("normal_button_text_color", AppInfo.normal_button_text_color);
        colorMap.put("selected_button_color", AppInfo.selected_button_color);
        colorMap.put("selected_button_text_color", AppInfo.selected_button_text_color);
        colorMap.put("disable_button_color", AppInfo.disable_button_color);
        colorMap.put("color_pager_title_strip", AppInfo.color_pager_title_strip);
        colorMap.put("color_actionbar_text", AppInfo.color_actionbar_text);
        colorMap.put("color_splash_text", AppInfo.color_splash_text);
        colorMap.put("color_sale_price", AppInfo.color_sale_price);
        colorMap.put("color_regular_price", AppInfo.color_regular_price);
        colorMap.put("color_splash_bg", AppInfo.color_splash_bg);
        colorMap.put("color_home_section_header_bg", AppInfo.color_home_section_header_bg);
        colorMap.put("color_home_section_header_text", AppInfo.color_home_section_header_text);
        colorMap.put("color_bottom_nav_selected", AppInfo.color_bottom_nav_selected);
        colorMap.put("color_bottom_nav_normal", AppInfo.color_bottom_nav_normal);
        colorMap.put("color_bottom_nav_bg", AppInfo.color_bottom_nav_bg);
        Preferences.putHashMap(colorMap);
    }

    private void loadVendorsInBackground() {
        txt_loading.setText(getString(L.string.loading_vendors));
        DataEngine.getDataEngine().fetchSellersInBackground(new DataQueryHandler<List<SellerInfo>>() {
            @Override
            public void onSuccess(List<SellerInfo> vendors) {
                for (SellerInfo vendor : vendors) {
                    vendor.commit();
                }
                contentLoaded = true;
                loadRequiredContent();
            }

            @Override
            public void onFailure(Exception exception) {
                handleFetchingError(getString(L.string.generic_error));
            }
        });
    }

    private void updateTextViews() {
        txt_tmstore.setText(getString(L.string.powered_by_tm_store));
    }

    private static final int PLAY_SERVICES_RESOLUTION_REQUEST = 1001;

    private boolean checkPlayServices(Activity activityContext) {
        GoogleApiAvailability apiAvailability = GoogleApiAvailability.getInstance();
        int resultCode = apiAvailability.isGooglePlayServicesAvailable(activityContext);
        if (resultCode != ConnectionResult.SUCCESS) {
            if (apiAvailability.isUserResolvableError(resultCode)) {
                apiAvailability.getErrorDialog(activityContext, resultCode, PLAY_SERVICES_RESOLUTION_REQUEST).show();
            } else {
                Helper.showErrorToast("This device is not supported.");
            }
            return false;
        }
        return true;
    }
}