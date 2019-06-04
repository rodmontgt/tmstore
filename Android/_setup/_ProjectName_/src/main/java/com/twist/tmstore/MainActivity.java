package com.twist.tmstore;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Parcelable;
import android.preference.PreferenceManager;
import android.support.annotation.NonNull;
import android.support.design.internal.BottomNavigationItemView;
import android.support.design.internal.BottomNavigationMenuView;
import android.support.design.widget.BottomNavigationView;
import android.support.design.widget.FloatingActionButton;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.content.LocalBroadcastManager;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AlertDialog;
import android.support.v7.widget.CardView;
import android.support.v7.widget.Toolbar;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.webkit.CookieManager;
import android.webkit.ValueCallback;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.bumptech.glide.GlideBuilder;
import com.bumptech.glide.load.engine.cache.InternalCacheDiskCacheFactory;
import com.google.android.gms.common.api.CommonStatusCodes;
import com.parse.DeleteCallback;
import com.parse.GetCallback;
import com.parse.LogOutCallback;
import com.parse.ParseException;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.SaveCallback;
import com.twist.dataengine.DataEngine;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.TM_LoginListener;
import com.twist.dataengine.entities.BlogItem;
import com.twist.dataengine.entities.MenuInfo;
import com.twist.dataengine.entities.PincodeSetting;
import com.twist.dataengine.entities.SellerInfo;
import com.twist.dataengine.entities.ShortAttribute;
import com.twist.dataengine.entities.TM_CategoryInfo;
import com.twist.dataengine.entities.TM_Coupon;
import com.twist.dataengine.entities.TM_Order;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.oauth.NetworkRequest;
import com.twist.oauth.OAuthUtils;
import com.twist.tmstore.adapters.PhoneNumberAdapter;
import com.twist.tmstore.config.FreshChatConfig;
import com.twist.tmstore.config.GuestUserConfig;
import com.twist.tmstore.config.ImageDownloaderConfig;
import com.twist.tmstore.config.MultiStoreConfig;
import com.twist.tmstore.config.MultiVendorConfig;
import com.twist.tmstore.config.NotificationConfig;
import com.twist.tmstore.config.PinCodeSettingsConfig;
import com.twist.tmstore.config.WordPressMenuConfig;
import com.twist.tmstore.dialogs.PendingUserDialog;
import com.twist.tmstore.entities.Address;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.entities.Cart;
import com.twist.tmstore.entities.CategoryItem;
import com.twist.tmstore.entities.CustomerData;
import com.twist.tmstore.entities.NavDrawItem;
import com.twist.tmstore.entities.Notification;
import com.twist.tmstore.entities.RecentlyViewedItem;
import com.twist.tmstore.entities.RolePrice;
import com.twist.tmstore.entities.RoleType;
import com.twist.tmstore.entities.TimeSlot;
import com.twist.tmstore.entities.WishListGroup;
import com.twist.tmstore.entities.Wishlist;
import com.twist.tmstore.fragments.BlogDetailFragment;
import com.twist.tmstore.fragments.BlogsFragment;
import com.twist.tmstore.fragments.CategoryChildFragment;
import com.twist.tmstore.fragments.CategoryFragment;
import com.twist.tmstore.fragments.Fragment_About;
import com.twist.tmstore.fragments.Fragment_AboutCool;
import com.twist.tmstore.fragments.Fragment_Cart;
import com.twist.tmstore.fragments.Fragment_ConfirmOrder;
import com.twist.tmstore.fragments.Fragment_ContactForm3;
import com.twist.tmstore.fragments.Fragment_Coupons;
import com.twist.tmstore.fragments.Fragment_FixedProduct;
import com.twist.tmstore.fragments.Fragment_Home;
import com.twist.tmstore.fragments.Fragment_HomeUltimate;
import com.twist.tmstore.fragments.Fragment_ItemList;
import com.twist.tmstore.fragments.Fragment_Login_Dialog;
import com.twist.tmstore.fragments.Fragment_NavigationDrawer;
import com.twist.tmstore.fragments.Fragment_NavigationDrawerExtra;
import com.twist.tmstore.fragments.Fragment_Notification;
import com.twist.tmstore.fragments.Fragment_Opinions;
import com.twist.tmstore.fragments.Fragment_OrderFail;
import com.twist.tmstore.fragments.Fragment_OrderReceipt;
import com.twist.tmstore.fragments.Fragment_Orders;
import com.twist.tmstore.fragments.Fragment_Placeholder;
import com.twist.tmstore.fragments.Fragment_Profile;
import com.twist.tmstore.fragments.Fragment_ReservationForm;
import com.twist.tmstore.fragments.Fragment_SellerOrders;
import com.twist.tmstore.fragments.Fragment_SellerProducts;
import com.twist.tmstore.fragments.Fragment_SellerProfile;
import com.twist.tmstore.fragments.Fragment_SellerStoreSettings;
import com.twist.tmstore.fragments.Fragment_SellerZone;
import com.twist.tmstore.fragments.Fragment_Wish;
import com.twist.tmstore.fragments.Fragment_Wishlist_Dialog;
import com.twist.tmstore.fragments.PaymentFragment;
import com.twist.tmstore.fragments.ProductDetailDialogFragment;
import com.twist.tmstore.fragments.SearchFragment;
import com.twist.tmstore.fragments.SellerHomeFragment;
import com.twist.tmstore.fragments.SellerLoginFragment;
import com.twist.tmstore.fragments.ShipmentStatusFragment;
import com.twist.tmstore.fragments.SponsorFriendFragment;
import com.twist.tmstore.fragments.WebViewFragment;
import com.twist.tmstore.listeners.ActivityResultHandler;
import com.twist.tmstore.listeners.LoginDialogListener;
import com.twist.tmstore.listeners.LoginListener;
import com.twist.tmstore.listeners.NavigationDrawerCallbacks;
import com.twist.tmstore.listeners.OnFragmentPopListener;
import com.twist.tmstore.listeners.OnProfileEditListener;
import com.twist.tmstore.listeners.TaskListener;
import com.twist.tmstore.listeners.WishListDialogHandler;
import com.twist.tmstore.multistore.BarcodeReaderActivity;
import com.twist.tmstore.multistore.MultiStoreListActivity;
import com.twist.tmstore.multistore.MultiStoreMapActivity;
import com.twist.tmstore.notifications.MyFcmRegistrationService;
import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.PaymentManager;
import com.utils.AnalyticsHelper;
import com.utils.ArrayUtils;
import com.utils.CContext;
import com.utils.GoogleApiHelper;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.ImageUpload;
import com.utils.JsonHelper;
import com.utils.JsonUtils;
import com.utils.Log;
import com.utils.Preferences;

import org.apache.http.util.EncodingUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.util.List;
import java.util.Objects;

import static com.twist.tmstore.L.getString;

public class MainActivity extends BaseActivity implements NavigationDrawerCallbacks {

    public static MainActivity mActivity;
    private ActionBar actionBar;
    private OnProfileEditListener mOnProfileEditListener;
    private Fragment_NavigationDrawer mNavigationDrawerFragment;
    private TextView txt_badgecount_cart = null;
    private RelativeLayout layoutCartBadgeSection = null;
    private TextView txt_badgecount_wishlist = null;
    private TextView txt_badgecount_opinion = null;
    private ImageView icon_badge_cart = null;
    private ImageView icon_badge_wishlist = null;
    private ImageView icon_badge_opinion = null;
    private WebView mWebView;
    private WebLoginInterface webLoginInterface;
    private View coordinatorLayout;
    private ProgressDialog progressDialog;

    private BroadcastReceiver mFreshChatPushReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            FreshChatConfig.incrementUnreadCount(MainActivity.this, 1);
        }
    };

    private ActivityResultHandler activityResultHandler = null;
    private GoogleApiHelper mGoogleApiHelper;
    private BottomNavigationView bottom_navigation;
    private CardView cardView;
    private TextView cart_badge_txt;
    private TextView wishlist_badge_txt;
    private TextView opinion_badge_txt;
    private View opinion_badge_section;
    private View wishlist_badge_section;
    private View cart_badge_section;

    private void clearSessionData() {
        CookieManager cookieManager = CookieManager.getInstance();
        cookieManager.setAcceptCookie(true);
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                ValueCallback<Boolean> callback = new ValueCallback<Boolean>() {
                    @Override
                    public void onReceiveValue(Boolean value) {
                    }
                };
                cookieManager.removeSessionCookies(callback);
                cookieManager.removeAllCookies(callback);
            } else {
                cookieManager.removeSessionCookie();
                cookieManager.removeAllCookie();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void clearWebData() {
        if (mWebView != null) {
            try {
                mWebView.clearFormData();
                mWebView.clearHistory();
                mWebView.clearCache(true);
                mWebView.clearMatches();
                mWebView.clearSslPreferences();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    public GoogleApiHelper getGoogleApiHelper() {
        return mGoogleApiHelper;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mActivity = this;
        OAuthUtils.init(this);

        GlideBuilder builder = new GlideBuilder(this);
        builder.setDiskCache(new InternalCacheDiskCacheFactory(this, 1024));

        progressDialog = new ProgressDialog(this);

        AppUser.getInstance();

        setContentView(R.layout.activity_main);

        setShowActionBarSearch(AppInfo.SHOW_BOTTOM_NAV_MENU);

        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        Helper.stylizeOverflowIcon(toolbar);

        coordinatorLayout = findViewById(R.id.coordinatorLayout);
        cardView = findViewById(R.id.card_view);
        bottom_navigation = findViewById(R.id.bottom_navigation);

        showBottomNavMenu();

        initWebView();

        DrawerLayout drawerLayout = findViewById(R.id.drawer_layout);
        mNavigationDrawerFragment = (Fragment_NavigationDrawer) getFM().findFragmentById(R.id.navigation_drawer);
        mNavigationDrawerFragment.setUp(R.id.navigation_drawer, drawerLayout, toolbar);
        FloatingActionButton btn_extra_menu = findViewById(R.id.btn_extra_menu);
        if ((MultiVendorConfig.isEnabled() && MultiVendorConfig.getScreenType() == MultiVendorConfig.ScreenType.VENDORS)) {
            final Fragment_NavigationDrawerExtra navigationDrawerFragmentExtra = (Fragment_NavigationDrawerExtra) getFM().findFragmentById(R.id.navigation_drawer_extra);
            navigationDrawerFragmentExtra.setUp(R.id.navigation_drawer_extra, drawerLayout);
            Helper.stylize(btn_extra_menu);
            btn_extra_menu.setVisibility(View.VISIBLE);
            btn_extra_menu.setOnClickListener(v -> navigationDrawerFragmentExtra.openDrawer());
        } else {
            drawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, GravityCompat.END);
            btn_extra_menu.setVisibility(View.GONE);
        }

        if (MultiVendorConfig.shouldShowLocation())
            mGoogleApiHelper = new GoogleApiHelper(this);

        btn_extra_menu.setVisibility(View.GONE);

        DataEngine.getDataEngine().setContext(this);

        actionBar = getSupportActionBar();
        updateUserInfoInBackground();

        showHomeFragment(true);

        if (AppInfo.SHOW_LOGIN_AT_START && !AppUser.hasSignedIn()) {
            onLoginClick(false);
        }

        handleExtras(null);

        handleData(getIntent().getData());

        if ((AppInfo.drawerItems == null || AppInfo.drawerItems.isEmpty()) && !TM_CategoryInfo.isAllEmpty()) {
            mNavigationDrawerFragment.addCategories(AppInfo.DRAWER_INDEX_CATEGORY);
        }
        supportInvalidateOptionsMenu();
        unlockDrawer();

        if (WordPressMenuConfig.getInstance().isEnabled()) {
            if (MenuInfo.getAll().size() == 0) {
                DataEngine.getDataEngine().getWordPressMenuItemsAsync(new DataQueryHandler() {
                    @Override
                    public void onSuccess(Object data) {
                        mNavigationDrawerFragment.addMenuItems();
                    }

                    @Override
                    public void onFailure(Exception e) {
                        Log.d(e.getMessage());
                    }
                });
            }
        }

        if (AppInfo.ENABLE_CUSTOM_POINTS) {
            DataEngine.getDataEngine().getRewardPointsSettingsAsync(new DataQueryHandler() {
                @Override
                public void onSuccess(Object data) {
                }

                @Override
                public void onFailure(Exception e) {
                    Log.d(e.getMessage());
                }
            });
        }

        FreshChatConfig.initialize(this);

        if (AppInfo.ENABLE_CUSTOM_WAITLIST) {
            DataEngine.getDataEngine().getWaitListProductIdsAsync(
                    AppUser.getUserId(),
                    AppUser.getEmail(),
                    new DataQueryHandler<String>() {
                        @Override
                        public void onSuccess(String data) {
                        }

                        @Override
                        public void onFailure(Exception reason) {
                        }
                    });
        }

        PinCodeSettingsConfig pinCodeSettingsConfig = PinCodeSettingsConfig.getInstance();
        if (pinCodeSettingsConfig.isEnabled() && pinCodeSettingsConfig.getCheckType() == PinCodeSettingsConfig.CheckType.CHECK_ALL_PRODUCT) {
            if (!PincodeSetting.getInstance().isFetched()) {
                DataEngine.getDataEngine().getProductsPincodeSettings(new DataQueryHandler() {
                    @Override
                    public void onSuccess(Object data) {
                        PincodeSetting.getInstance().setFetched(true);
                    }

                    @Override
                    public void onFailure(Exception error) {
                        PincodeSetting.getInstance().setFetched(false);
                    }
                });
            }
        }

        if (AppInfo.mProductDetailsConfig.show_awesome_attribute_options) {
            if (!ShortAttribute.getAll().isEmpty()) {
                return;
            }

            DataEngine.getDataEngine().getProductShortAttributes(new DataQueryHandler<Objects>() {
                @Override
                public void onSuccess(Objects objects) {
                }

                @Override
                public void onFailure(Exception exception) {
                    exception.printStackTrace();
                }
            });
        }
        toggleNotificationChannelsSubscription();
        autoSubscribeNotificationChannels();
        addFragmentBackStackListener();

        if (AppInfo.SHOW_BOTTOM_NAV_MENU) {
            mNavigationDrawerFragment.hideDrawer();
        }
    }

    @Override
    protected void onStart() {
        super.onStart();
        if (FreshChatConfig.isEnabled()) {
            LocalBroadcastManager.getInstance(this)
                    .registerReceiver(mFreshChatPushReceiver, new IntentFilter(Constants.ACTION_BROADCAST_NOTIFICATION));
        }
    }

    @Override
    protected void onStop() {
        super.onStop();
        if (FreshChatConfig.isEnabled()) {
            LocalBroadcastManager.getInstance(this)
                    .unregisterReceiver(mFreshChatPushReceiver);
        }
    }

    public void setOnProfileEditListener(OnProfileEditListener listener) {
        this.mOnProfileEditListener = listener;
    }

    private void handleExtras(Bundle extras) {
        if (extras == null) {
            extras = getIntent().getExtras();
        }
        if (extras != null) {
            String data = "";
            if (getIntent().getData() != null) {
                data = getIntent().getData().getSchemeSpecificPart();
            }

            if (data.contains("pid=")) {
                try {
                    String productIdStr = data.split("pid=")[1];
                    if (productIdStr.contains("&")) {
                        productIdStr = productIdStr.split("&")[0];
                    }
                    int productId = Integer.parseInt(productIdStr);
                    this.openOrLoadProductInfo(productId);
                } catch (Exception ignore) {
                }
            } else if (extras.containsKey(Extras.REFERRER)) {
                int productId = extras.getInt(Extras.PRODUCT_ID);
                this.openOrLoadProductInfo(productId);
                try {
                    String referrer = extras.getString(Extras.REFERRER);
                    if (!TextUtils.isEmpty(referrer)) {
                        AnalyticsHelper.registerReferrerReceivedEvent(referrer);
                        CustomerData customerData = CustomerData.getInstance();
                        String referrerType = extras.getString(Extras.REFERRER_TYPE);
                        if (!TextUtils.isEmpty(referrerType)) {
                            if (referrerType.equals(Constants.Key.REFERRER_INSTALL)) {
                                customerData.addReferrer("android[" + referrer + "]");
                            }
                        }
                        customerData.saveInBackground();
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            } else if (extras.containsKey(Extras.NOTIFICATION)) {
                handleNotification(extras.getParcelable(Extras.NOTIFICATION));
            }
        }
    }

    private void handleData(Uri data) {
        if (data != null) {
            String output = getIntent().getData().toString();
            if (output != null && output.contains("wlid=")) {
                String recipeId = output.substring(output.lastIndexOf("?") + 1);
                recipeId = recipeId.split("wlid=")[1];
                if (recipeId.contains("&")) {
                    recipeId = recipeId.split("&")[0];
                }
                int wishId = Integer.parseInt(recipeId);
                createAndOpenSharedWishlist(wishId);
            }
        }
    }

    private void handleNotification(Parcelable parcelable) {
        try {
            handleNotification((Notification) parcelable);
        } catch (ClassCastException e) {
            e.printStackTrace();
        }
    }

    public void handleNotification(Notification notification) {
        Log.d("Notification: " + notification.toString());
        switch (notification.getType()) {
            case CATEGORY:
                showCategoryInfo(notification.getNotificationId());
                break;
            case PRODUCT:
                openOrLoadProductInfo(notification.getNotificationId());
                break;
            case CART:
                openCartFragment(notification.getContent());
                break;
            case WISHLIST:
                openWishlistFragment(false);
                break;
            case ORDER:
                showOrdersFragment();
                break;
            case SELLER_ORDER:
                showSellerOrdersFragment(notification.getContent());
                break;
            case FIXED_PRODUCT:
                try {
                    JSONObject jsonObject = new JSONObject(notification.getContent());
                    String title = JsonHelper.getString(jsonObject, "title", "");
                    String[] product_ids = JsonHelper.getStringArray(jsonObject, "product_ids");
                    if (product_ids != null && product_ids.length > 0) {
                        int[] ids = new int[product_ids.length];
                        for (int i = 0; i < product_ids.length; i++) {
                            ids[i] = Integer.parseInt(product_ids[i]);
                        }
                        openFixedProductFragment(title, ids);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                break;
        }
        notification.setRead();
        AnalyticsHelper.registerNotificationOpenEvent(notification.getType().getValue());
    }

    public void openOrLoadProductInfo(final int productId) {
        if (productId > 0) {
            TM_ProductInfo product = TM_ProductInfo.findProductById(productId);
            if (product != null) {
                openProductInfo(product);
            } else {
                loadProductInfo(productId);
            }
        }
    }

    public void openOrLoadProductInfo(final String sku) {
        if (!TextUtils.isEmpty(sku)) {
            TM_ProductInfo product = TM_ProductInfo.getProductWithSku(sku);
            if (product != null) {
                openProductInfo(product);
            } else {
                loadProductInfoSku(sku);
            }
        }
    }

    private void loadProductInfoSku(String sku) {
        showProgress(getString(L.string.fetching_product_info));
        DataEngine.getDataEngine().getProductWithSkuInBackground(sku, new DataQueryHandler<TM_ProductInfo>() {
            public void onSuccess(TM_ProductInfo data) {
                Log.d(data.toString());
                hideProgress();
                openProductInfo(data);
            }

            @Override
            public void onFailure(Exception error) {
                hideProgress();
                Helper.toast(getString(L.string.error_retrieving_product));
                error.printStackTrace();
            }
        });
    }

    private void loadProductInfo(final int productId) {
        showProgress(getString(L.string.fetching_product_info));
        DataEngine.getDataEngine().getProductInfoInBackground(productId, new DataQueryHandler<TM_ProductInfo>() {
                    @Override
                    public void onSuccess(TM_ProductInfo data) {
                        hideProgress();
                        openProductInfo(data);
                    }

                    @Override
                    public void onFailure(Exception reason) {
                        hideProgress();
                        Log.d("-- loadProductInformation:onFailure:[" + reason.getMessage() + "] --");
                        reason.printStackTrace();
                    }
                }
        );
    }

    public void loadProductInfo(final int productId, final DataQueryHandler dataQueryHandler) {
        showProgress(getString(L.string.fetching_product_info));
        DataEngine.getDataEngine().getProductInfoInBackground(productId, new DataQueryHandler<TM_ProductInfo>() {
                    @Override
                    public void onSuccess(TM_ProductInfo data) {
                        hideProgress();
                        if (dataQueryHandler != null)
                            dataQueryHandler.onSuccess(data);
                    }

                    @Override
                    public void onFailure(Exception reason) {
                        hideProgress();
                        Log.d("-- loadProductInformation:onFailure:[" + reason.getMessage() + "] --");
                        reason.printStackTrace();
                        if (dataQueryHandler != null)
                            dataQueryHandler.onFailure(reason);
                    }
                }
        );
    }

    @SuppressLint({"AddJavascriptInterface", "SetJavaScriptEnabled"})
    private void initWebView() {
        webLoginInterface = new WebLoginInterface();
        mWebView = findViewById(R.id.web_view);
        mWebView.setVisibility(View.INVISIBLE);
        mWebView.getSettings().setSaveFormData(true);
        mWebView.getSettings().setJavaScriptEnabled(true);
        mWebView.getSettings().setDatabaseEnabled(true);
        mWebView.getSettings().setDomStorageEnabled(true);
        mWebView.getSettings().setAllowFileAccess(true);
        mWebView.getSettings().setSupportMultipleWindows(true);
        mWebView.addJavascriptInterface(webLoginInterface, "Android");
        mWebView.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView webView, String url) {
                webView.loadUrl(url);
                return true;
            }
        });
        String userAgentString = mWebView.getSettings().getUserAgentString();
        Log.d("== userAgentString : [" + userAgentString + "] ==");
        NetworkRequest.setUserAgentStr(userAgentString);
    }

    public void loadInitialProducts() {
        if (AppInfo.basic_content_loading || AppInfo.basic_content_loaded)
            return;

        AppInfo.basic_content_loading = true;
        DataQueryHandler dataQueryHandler = new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {
                AppInfo.basic_content_loaded = true;
                AppInfo.basic_content_loading = false;
                refreshActiveViewPager();
            }

            @Override
            public void onFailure(Exception exception) {
                AppInfo.basic_content_loading = false;
                Log.d("-- Some error while loading Home Page Products from server..");
            }
        };

        if (MultiVendorConfig.isEnabled() && MultiVendorConfig.getScreenType() == MultiVendorConfig.ScreenType.VENDORS) {
            DataEngine.getDataEngine().getInitialProductsInBackground(SellerInfo.getSelectedSeller().getId(), dataQueryHandler);
        } else {
            DataEngine.getDataEngine().getInitialProductsInBackground(dataQueryHandler);
        }
    }

    public void updateUserInfoInBackground() {
        if (AppUser.getInstance().isWordPressUser()) {
            if (MultiVendorConfig.isSellerApp() && actionBar != null) {
                actionBar.hide();
            }
            LoginManager.fetchCustomerData(AppUser.getEmail(), new LoginListener() {
                @Override
                public void onLoginSuccess(String message) {
                    LoginManager.signInWeb(
                            AppUser.getInstance().email,
                            AppUser.getInstance().password,
                            new LoginListener() {
                                @Override
                                public void onLoginSuccess(String message) {
                                    createAppUser(true);
                                    // handle if response is from user approval plugin
                                    if (!TextUtils.isEmpty(message)) {
                                        try {
                                            JSONObject jsonObject = new JSONObject(message);
                                            String msg = jsonObject.getString("msg");
                                            String status = jsonObject.getString("status");
                                            if (!TextUtils.isEmpty(status) && (status.equals("denied") || status.equals("pending"))) {
                                                PendingUserDialog pendingUserDialog = new PendingUserDialog();
                                                pendingUserDialog.showDialog(MainActivity.this, msg);
                                            }
                                        } catch (Exception e) {
                                            Log.w(e.getMessage());
                                        }
                                        if (AppInfo.ENABLE_ROLE_PRICE) {
                                            try {
                                                JSONObject jsonObject = new JSONObject(message);
                                                RolePrice rolePrice = RolePrice.create(jsonObject);
                                                AppUser.getInstance().setRolePrice(rolePrice);
                                            } catch (Exception e) {
                                                e.printStackTrace();
                                            }
                                        }
                                    }
                                }

                                @Override
                                public void onLoginFailed(String cause) {
                                    Helper.showToast(coordinatorLayout, cause);
                                }
                            });
                }

                @Override
                public void onLoginFailed(String cause) {
                    Log.d("-- [signInAPIUsing] FAILED--");
                    Helper.showToast(coordinatorLayout, cause);
                }
            });
        } else if (AppUser.isAnonymous()) {
            Log.d("UpdateUserInfoInBackground" + AppUser.isAnonymous());
        }
    }

    private void signUpInBackground(final String email) {
        DataEngine.getDataEngine().signInSocialUsing(email, new TM_LoginListener() {
            @Override
            public void onLoginSuccess(String data) {
                LoginManager.fetchCustomerData(
                        email,
                        new LoginListener() {
                            @Override
                            public void onLoginSuccess(String message) {
                                createAppUser(true);
                                signInParse(email, new LoginListener() {
                                    @Override
                                    public void onLoginSuccess(String message) {
                                        resetDrawer();
                                    }

                                    @Override
                                    public void onLoginFailed(String cause) {
                                        Helper.showToast(coordinatorLayout, cause);
                                    }
                                });
                            }

                            @Override
                            public void onLoginFailed(String cause) {
                                Helper.showToast(coordinatorLayout, cause);
                            }
                        }
                );
                AnalyticsHelper.registerSignInEvent("Social SignIn");
            }

            @Override
            public void onLoginFailed(String cause) {
                Helper.showToast(coordinatorLayout, cause);
            }
        });
    }

    public void signInParse(final String emailId, final LoginListener loginListener) {
        ParseQuery<CustomerData> query = ParseQuery.getQuery(CustomerData.class);
        query.whereEqualTo("EmailID", emailId);
        query.getFirstInBackground(new GetCallback<CustomerData>() {
            @Override
            public void done(CustomerData object, ParseException exception) {
                if (exception == null || exception.getCode() == ParseException.OBJECT_NOT_FOUND) {
                    if (object == null) {
                        Log.d(" -- This email id is not yet used --");
                        AppUser.getInstance().sync();  //PS. 1. Don't change order of the below lines
                        CustomerData.getInstance().setEmailID(emailId);
                        AppUser.getInstance().saveAll();
                    } else {
                        Log.d(" -- This email id has been already used.. --");
                        Log.d(" -- device model : [" + object.getDeviceModel() + "] --");
                        final CustomerData currentAnonymousDeviceCustomer = CustomerData.getInstance();
                        CustomerData.setInstance(object);   //PS. 1. Don't change order of the below lines
                        final CustomerData newSignedInCustomer = CustomerData.getInstance();
                        Log.d(" -- obj id 4 : [" + CustomerData.getInstance().getObjectId() + "] --");
                        AppUser.getInstance().sync();   //PS. 1. Don't change order of the below lines
                        CustomerData.getInstance().setParseUser(ParseUser.getCurrentUser());
                        AppUser.getInstance().saveAll();
                        currentAnonymousDeviceCustomer.fetchIfNeededInBackground(new GetCallback<CustomerData>() {
                            @Override
                            public void done(CustomerData object, ParseException e) {
                                CustomerData.appendData(object, newSignedInCustomer);
                                currentAnonymousDeviceCustomer.deleteInBackground();
                                newSignedInCustomer.saveInBackground();
                            }
                        });
                    }

                    if (loginListener != null)
                        loginListener.onLoginSuccess("");

                    toggleNotificationChannelsSubscription();
                } else {
                    Log.d("-- Retrieved the existing [CustomerData] object. --");
                    exception.printStackTrace();
                    if (loginListener != null)
                        loginListener.onLoginFailed(getString(L.string.signin_failed));
                }
            }
        });
    }

    public void signInWebInBackground(final LoginListener loginListener) {
        webLoginInterface.setWebResponseListener((resultCode, response) -> {
            if (response.contains("Login Successful")) {
                if (loginListener != null) {
                    loginListener.onLoginSuccess(response);
                }
            } else {
                hideProgress();
                if (loginListener != null) {
                    loginListener.onLoginFailed("Web SignIn Failed!");
                }
            }
        });

        File dir = getCacheDir();
        if (!dir.exists()) {
            dir.mkdirs();
        }

        showProgress(getString(L.string.please_wait));
        String url = DataEngine.getDataEngine().url_login_website;
        String postData = "user_platform=Android&user_emailID=" + AppUser.getEmail();
        Log.d("-- postData: [" + url + "?" + postData + "] --");
        mWebView.postUrl(url, EncodingUtils.getBytes(postData, "BASE64"));
    }

    @Override
    public void showProgress(final String msg) {
        showProgress(msg, true);
    }

    public void showProgress(final String msg, final boolean isCancellable) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                progressDialog.setMessage(msg);
                progressDialog.setCancelable(isCancellable);
                progressDialog.setOnShowListener(new DialogInterface.OnShowListener() {
                    @Override
                    public void onShow(DialogInterface dialog) {
                        Helper.stylize(progressDialog);
                    }
                });
                progressDialog.show();
            }
        });
    }

    @Override
    public void hideProgress() {
        progressDialog.dismiss();
    }

    public void resetTitleBar() {
        if (BuildConfig.MULTI_STORE) {
            MultiStoreConfig multiStoreConfig = MultiStoreConfig.findByPlatform(Preferences.getString(Constants.Key.MULTI_STORE_PLATFORM, ""));
            if (multiStoreConfig != null && !TextUtils.isEmpty(multiStoreConfig.getTitle())) {
                this.setTitleText(multiStoreConfig.getTitle());
                return;
            }
        }
        this.setTitleText(AppInfo.SHOW_ACTIONBAR_ICON ? null : (!AppInfo.ACTION_BAR_HOME_TITLE.isEmpty() ? AppInfo.ACTION_BAR_HOME_TITLE : getString(R.string.app_name)));
    }

    public void resetDrawer() {
        if (mNavigationDrawerFragment != null) {
            mNavigationDrawerFragment.resetDrawer();
        }
    }

    public void closeDrawer() {
        if (mNavigationDrawerFragment != null) {
            mNavigationDrawerFragment.closeDrawer();
        }
    }

    public void unlockDrawer() {
        if (mNavigationDrawerFragment != null) {
            mNavigationDrawerFragment.unlockDrawer();
        }
    }

    public void lockDrawer() {
        if (mNavigationDrawerFragment != null) {
            mNavigationDrawerFragment.lockDrawer();
        }
    }

    public void refreshActiveViewPager() {
        try {
            Fragment f = getFM().findFragmentById(R.id.content);
            if (f instanceof CategoryChildFragment) {
                ((CategoryChildFragment) f).loadAvailableProductsInAdapter();
            } else if (f instanceof CategoryFragment) {
                ((CategoryFragment) f).loadProductsInAdapter();
            } else if (f instanceof Fragment_Home) {
                ((Fragment_Home) f).updateAdapter();
                ((Fragment_Home) f).updateBarcodeSections();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void getProductsOfCategory(final TM_CategoryInfo category, final TaskListener taskListener) {
        final DataQueryHandler dataQueryHandler = new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {
                taskListener.onTaskDone();
            }

            @Override
            public void onFailure(Exception reason) {
                taskListener.onTaskFailed(getString(L.string.generic_error));
            }
        };

        if (MultiVendorConfig.isEnabled() && MultiVendorConfig.getScreenType() == MultiVendorConfig.ScreenType.VENDORS) {
            DataEngine.getDataEngine().getProductsOfCategory(category.id, SellerInfo.getSelectedSeller().getId(), 0, 0, dataQueryHandler);
        } else {
            DataEngine.getDataEngine().getProductsOfCategory(category.id, dataQueryHandler);
        }
    }

    @Override
    public void onNavigationDrawerItemSelected(int itemId, int position) {
        Helper.hideKeyboard(getCurrentFocus());
        switch (itemId) {
            case Constants.MENU_ID_PROFILE:
                showProfileFragment();
                break;
            case Constants.MENU_ID_HOME:
                showHomeFragment(true);
                break;
            case Constants.MENU_ID_WISH:
                openWishlistFragment(true);
                break;
            case Constants.MENU_ID_MY_COUPONS:
                openCouponList();
                break;
            case Constants.MENU_ID_NOTIFICATIONS:
                openNotificationList();
                break;
            case Constants.MENU_ID_CART:
                openCartFragment();
                break;
            case Constants.MENU_ID_ORDERS:
                showOrdersFragment(true);
                break;
            case Constants.MENU_ID_SELLER_HOME:
                showVendorSection();
                break;
            case Constants.MENU_ID_MY_ADDRESS:
                showEditProfile(false);
                break;
            case Constants.MENU_ID_SETTINGS:
                startActivity(new Intent(this, SettingsActivity.class));
                break;
            case Constants.MENU_ID_ABOUT:
                openAboutFragment();
                break;
            case Constants.MENU_ID_CHANGE_SELLER:
                changeVendor(position);
                break;
            case Constants.MENU_ID_SIGN_OUT:
                showHomeFragment(true);
                proceedSignOut();
                break;
            case Constants.MENU_ID_SIGN_IN:
                onLoginClick(true);
                break;
            case Constants.MENU_ID_SEARCH:
                openSearchFragment();
                break;
            case Constants.MENU_ID_OPINION:
                openOpinionFragment();
                break;
            case Constants.MENU_ID_FRESH_CHAT:
                FreshChatConfig.showConversations(this);
                break;
            case Constants.MENU_ID_REFER_FRIEND:
                openSponsorFriendFragment();
                break;
            case Constants.MENU_ID_RATE_APP:
                Helper.rateMyApp();
                break;
            case Constants.MENU_ID_CHANGE_PLATFORM:
                changePlatform();
                break;
            case Constants.MENU_ID_SCAN_PRODUCT:
                openBarCodeReader();
                break;
            case Constants.MENU_ID_CHANGE_STORE:
                changeMultiStore();
                break;
            case Constants.MENU_ID_LOCATE_STORE:
                locateMultiStore();
                break;
            case Constants.MENU_ID_RESERVATION_FORM:
                openReservationFormFragment();
                break;
            case Constants.MENU_ID_CONTACT_FORM3:
                openContactForm3Fragment();
                break;
            case Constants.MENU_ID_SHARE_APP:
                Helper.shareApp(this);
                break;
            case Constants.MENU_ID_NEWS_FEED:
                openNewsFeed();
                break;
            case Constants.MENU_ID_LIVE_CHAT:
                LiveChatHandler.startChatScreen(this);
                break;
            default:
                getFM().beginTransaction()
                        .replace(R.id.content, Fragment_Placeholder.newInstance(getString(L.string.no_data)))
                        .addToBackStack(Fragment_Placeholder.class.getSimpleName())
                        .commit();
                break;
        }
    }

    private void openNewsFeed() {
        BlogsFragment blogsFragment = BlogsFragment.newInstance();
        getFM().beginTransaction()
                .replace(R.id.content, blogsFragment)
                .addToBackStack(BlogsFragment.class.getSimpleName())
                .commit();
    }

    public void openBlogDetail(BlogItem blogItem) {
        BlogDetailFragment blogDetailFragment = BlogDetailFragment.newInstance(blogItem);
        getFM().beginTransaction()
                .replace(R.id.content, blogDetailFragment)
                .addToBackStack(BlogDetailFragment.class.getSimpleName())
                .commit();
    }

    public void openCartFragment() {
        openCartFragment("");
    }

    public void openCartFragment(String couponCode) {
        fragmentPopBackStack();
        if (AppInfo.mGuestUserConfig == null || !AppInfo.mGuestUserConfig.isEnabled() || !AppInfo.mGuestUserConfig.isPreventCart() || AppUser.hasSignedIn()) {
            Fragment fragment = findFragmentById(R.id.content);
            if (fragment instanceof Fragment_Cart) {
                FragmentTransaction trans = getFM().beginTransaction();
                trans.remove(fragment);
                trans.commit();
                getFM().popBackStack();
            }
            getFM().beginTransaction()
                    .replace(R.id.content, Fragment_Cart.newInstance(couponCode))
                    .addToBackStack(Fragment_Cart.class.getSimpleName())
                    .commit();
            AnalyticsHelper.registerVisitScreenEvent(Constants.CART);
        } else {
            Helper.toast(getString(L.string.you_need_to_login_first));
        }
    }

    public void openFixedProductFragment(String title, int[] productId) {
        String tag = Fragment_FixedProduct.class.getSimpleName();
        getFM().beginTransaction()
                .replace(R.id.content, Fragment_FixedProduct.newInstance(title, productId), tag)
                .addToBackStack(tag)
                .commit();
    }

    public void showProfileFragment() {
        AnalyticsHelper.registerVisitScreenEvent(Constants.PROFILE);
        getFM().beginTransaction()
                .replace(R.id.content, Fragment_Profile.newInstance(this))
                .addToBackStack(Fragment_Profile.class.getSimpleName())
                .commit();
    }

    public void createAndOpenSharedWishlist(int wishlistId) {
        showProgress(getString(L.string.please_wait));
        WishListGroup.getWishListInfo(wishlistId, new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {
                try {
                    JSONObject jsonObject = new JSONObject(data.toString());
                    int id = jsonObject.getInt("id");
                    String title = jsonObject.getString("title");
                    WishListGroup group = WishListGroup.createGroup(title, id);
                    group.url = jsonObject.getString("url");
                    WishListGroup.allwishListGroup.add(group);

                    JSONArray array = jsonObject.getJSONArray("items");
                    for (int i = 0; i < array.length(); i++) {
                        JSONObject item = array.getJSONObject(i);
                        int pid = item.getInt("id");

                        TM_ProductInfo product = TM_ProductInfo.getProductWithId(pid);
                        if (product != null && !Wishlist.hasItem(product)) {
                            Wishlist.addProduct(product, group);
                        }

                    }
                    hideProgress();

                    Helper.toast(getString(L.string.item_added_to_wishlist) + ": " + group.title);
                    Fragment_Wish wishlist = Fragment_Wish.newInstance();
                    Bundle bundle = new Bundle();
                    bundle.putBoolean(Constants.ARG_WISHLIST_DEEPLINK, true);
                    wishlist.setArguments(bundle);
                    wishlist.setWishGroup(group);
                    getFM().beginTransaction()
                            .replace(R.id.content, wishlist)
                            .addToBackStack(Fragment_Wish.class.getSimpleName())
                            .commit();
                    AnalyticsHelper.registerVisitScreenEvent(Constants.WISHLIST);

                } catch (JSONException e) {
                    e.printStackTrace();
                    Helper.showAlertDialog(getString(L.string.error_wishlist_share), getString(L.string.wish_list_deleted_error), getString(L.string.ok), true, new View.OnLongClickListener() {
                        @Override
                        public boolean onLongClick(View view) {
                            return false;
                        }
                    });
                }
            }

            @Override
            public void onFailure(Exception error) {
            }
        });
    }

    public void popBackWishFragment() {
        List<Fragment> allFragments = getSupportFragmentManager().getFragments();
        for (Fragment fragment : allFragments) {
            if (fragment instanceof Fragment_Wishlist_Dialog) {
                FragmentTransaction trans = getFM().beginTransaction();
                trans.remove(fragment);
                trans.commit();
                getFM().popBackStack();
            }
        }

    }

    public void openWishlistFragment(boolean sync) {
        fragmentPopBackStack();
        if (AppInfo.mGuestUserConfig != null && AppInfo.mGuestUserConfig.isEnabled() && AppInfo.mGuestUserConfig.isPreventWishlist() && AppUser.isAnonymous()) {
            Helper.toast(L.string.you_need_to_login_first);
            return;
        }

        if (!AppInfo.ENABLE_MULTIPLE_WISHLIST) {

            Fragment_Wish wishlist = Fragment_Wish.newInstance();
            wishlist.setWishGroup(null);
            getFM().beginTransaction()
                    .replace(R.id.content, wishlist)
                    .addToBackStack(Fragment_Wish.class.getSimpleName())
                    .commit();
            AnalyticsHelper.registerVisitScreenEvent(Constants.WISHLIST);
            return;
        }

        showWishListDialog(sync, null, new WishListDialogHandler() {
            @Override
            public void onSelectGroupSuccess(TM_ProductInfo product, WishListGroup obj) {

                Fragment_Wish wishlist = Fragment_Wish.newInstance();
                wishlist.setWishGroup(obj);
                getFM().beginTransaction()
                        .replace(R.id.content, wishlist)
                        .addToBackStack(Fragment_Wish.class.getSimpleName())
                        .commit();
                AnalyticsHelper.registerVisitScreenEvent(Constants.WISHLIST);
            }

            @Override
            public void onSelectGroupFailed(String cause) {
            }

            @Override
            public void onSkipDialog(TM_ProductInfo product, WishListGroup obj) {
                Fragment_Wish wishlist = Fragment_Wish.newInstance();
                wishlist.setWishGroup(obj);
                getFM().beginTransaction()
                        .replace(R.id.content, wishlist)
                        .addToBackStack(Fragment_Wish.class.getSimpleName())
                        .commit();
                AnalyticsHelper.registerVisitScreenEvent(Constants.WISHLIST);
            }
        });
    }

    public void fragmentPopBackStack() {
        List<Fragment> allFragments = getFM().getFragments();
        if (allFragments != null) {
            for (int i = allFragments.size() - 1; i >= 0; i--) {
                Fragment fragment = allFragments.get(i);
                if (fragment instanceof PaymentFragment || fragment instanceof Fragment_ConfirmOrder) {
                    getFM().popBackStackImmediate();
                }
            }
        }
    }

    public void openOpinionFragment() {
        fragmentPopBackStack();
        getFM().beginTransaction()
                .replace(R.id.content, Fragment_Opinions.newInstance())
                .addToBackStack(Fragment_Opinions.class.getSimpleName())
                .commit();
        AnalyticsHelper.registerVisitScreenEvent(Constants.OPINION);
    }

    public void openConfirmOrderFragment() {
        getFM().beginTransaction()
                .replace(R.id.content, Fragment_ConfirmOrder.newInstance())
                .commit();
        AnalyticsHelper.registerVisitScreenEvent(Constants.CONFIRM_ORDER);
    }

    public void openWebFragment(String title, String url) {
        // hide navigation drawer before opening fragment
        if (mNavigationDrawerFragment != null) {
            mNavigationDrawerFragment.closeDrawer();
        }

        Fragment fragment = findFragmentById(R.id.content);
        if (fragment instanceof WebViewFragment) {
            FragmentTransaction trans = getFM().beginTransaction();
            trans.remove(fragment);
            trans.commit();
            getFM().popBackStack();
        }

        if (AppUser.hasSignedIn() && AppUser.getRoleType() == RoleType.MANDOOB) {
            url = url + "/?id=" + AppUser.getInstance().getId();
        }

        getFM().beginTransaction()
                .replace(R.id.content, WebViewFragment.create(title, url))
                .addToBackStack(WebViewFragment.class.getSimpleName())
                .commit();
        AnalyticsHelper.registerVisitWebPageEvent(title);
    }

    public void openSponsorFriendFragment() {
        getFM().beginTransaction()
                .replace(R.id.content, SponsorFriendFragment.newInstance())
                .addToBackStack(SponsorFriendFragment.class.getSimpleName())
                .commit();
        AnalyticsHelper.registerVisitScreenEvent(Constants.SPONSER_FRIEND);
    }

    @Override
    public void onResume() {
        super.onResume();
        reloadMenu();
        FreshChatConfig.onResume(this);
    }

    public void onLoginClick(final boolean showProfile) {
        Fragment_Login_Dialog fragment = new Fragment_Login_Dialog();
        fragment.setLoginDialogHandler(new LoginDialogListener() {
            @Override
            public void onLoginSuccess() {
                if (AppInfo.ENABLE_ROLE_PRICE && AppUser.getInstance().getRolePrice() != null) {
                    Intent intent = new Intent(MainActivity.this, LauncherActivity.class);
                    intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    startActivity(intent);
                    finish();
                } else {
                    if (showProfile || AppInfo.EDIT_PROFILE_ON_LOGIN) {
                        showEditProfile(false);
                    }
                    toggleNotificationChannelsSubscription();
                }
            }

            @Override
            public void onLoginFailed(String cause) {
                Log.d(cause);
            }
        });
        fragment.show(getFM(), Fragment_Login_Dialog.class.getSimpleName());
    }

    public void showSellerLoginFragment() {
        getFM().beginTransaction()
                .replace(R.id.content, SellerLoginFragment.newInstance())
                .addToBackStack(SellerLoginFragment.class.getSimpleName())
                .commit();
    }

    public void showWishListDialog(final boolean sync, final TM_ProductInfo product, final WishListDialogHandler loginDialogHandler) {
        if (AppUser.hasSignedIn()) {
            MainActivity.mActivity.showProgress(getString(L.string.syncing_wishlist), false);
            WishListGroup.syncGuestWishListToServer(sync, new DataQueryHandler() {
                @Override
                public void onSuccess(Object data) {
                    WishListGroup.syncAndRefreshWishListToServer(sync, new DataQueryHandler() {
                        @Override
                        public void onSuccess(Object data) {
                            openWishDialogFragment(product, loginDialogHandler);
                            hideProgress();
                        }

                        @Override
                        public void onFailure(Exception error) {
                            openWishDialogFragment(product, loginDialogHandler);
                            hideProgress();
                        }
                    });
                }

                @Override
                public void onFailure(Exception error) {
                    hideProgress();
                }
            });
        } else {
            if (AppInfo.mGuestUserConfig != null && AppInfo.mGuestUserConfig.isEnabled() && AppInfo.mGuestUserConfig.isPreventWishlist() && AppUser.isAnonymous()) {
                Helper.toast(L.string.you_need_to_login_first);
            } else
                openWishDialogFragment(product, loginDialogHandler);
        }
    }

    public void openWishDialogFragment(final TM_ProductInfo product, final WishListDialogHandler loginDialogHandler) {
        Fragment f = findFragmentById(R.id.content);
        if (f instanceof Fragment_Wishlist_Dialog) {
            Fragment_Wishlist_Dialog fragment = (Fragment_Wishlist_Dialog) f;
            fragment.refresh(loginDialogHandler);
            return;
        }

        Fragment_Wishlist_Dialog wishlist_dialog = new Fragment_Wishlist_Dialog();
        wishlist_dialog.setProduct(product);
        wishlist_dialog.setWishListDialogHandler(loginDialogHandler);
        getFM().beginTransaction()
                .replace(R.id.content, wishlist_dialog)
                .addToBackStack(Fragment_Wishlist_Dialog.class.getSimpleName())
                .commit();
    }

    public void openSearchFragment() {
        try {
            getFM().beginTransaction()
                    .replace(R.id.content, SearchFragment.newInstance())
                    .addToBackStack(SearchFragment.class.getSimpleName())
                    .commit();
            AnalyticsHelper.registerVisitScreenEvent(Constants.SEARCH);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void proceedSignOut() {
        AnalyticsHelper.registerLogoutEvent();
        AppUser.deleteInstance();
        SellerInfo.setCurrentSeller(null);
        ParseUser.logOutInBackground(new LogOutCallback() {
            @Override
            public void done(ParseException e) {
                ParseUser.getCurrentUser().deleteInBackground(new DeleteCallback() {
                    @Override
                    public void done(ParseException e) {
                        if (e == null) {
                            Log.d("--previous parse user deleted successfully --");
                            ParseUser.getCurrentUser().saveInBackground(new SaveCallback() {
                                @Override
                                public void done(ParseException e) {
                                    if (e == null) {
                                        Log.d("-- new anonymous use created successfully --");
                                        CustomerData c = new CustomerData();
                                        CustomerData.setInstance(c);
                                        CustomerData.getInstance().setApp_Name(getApplicationContext().getPackageName());
                                        CustomerData.getInstance().setDeviceModel(android.os.Build.MODEL);
                                        CustomerData.getInstance().setParseUser(ParseUser.getCurrentUser());
                                        CustomerData.getInstance().setCurrent_Day_App_Visit(1);
                                        CustomerData.getInstance().setCurrent_Day_Purchased_Amount(0);
                                        CustomerData.getInstance().saveInBackground();
                                        toggleNotificationChannelsSubscription();
                                        clearSessionData();
                                        Cart.clearCoupons();
                                        WishListGroup.clearAll();
                                    } else {
                                        Log.d("-- new anonymous user creation failed --");
                                        e.printStackTrace();
                                    }
                                }
                            });
                        } else {
                            Log.d("--previous parse user deletion failed --");
                            e.printStackTrace();
                        }
                    }
                });
            }
        });
        resetDrawer();
        onLoginClick(true);
    }

    public void openAboutFragment() {
        if (AppInfo.contactDetails != null && !AppInfo.contactDetails.isEmpty()) {
            getFM().beginTransaction()
                    .replace(R.id.content, Fragment_AboutCool.newInstance())
                    .addToBackStack(Fragment_AboutCool.class.getSimpleName())
                    .commit();
        } else {
            getFM().beginTransaction()
                    .replace(R.id.content, Fragment_About.newInstance())
                    .addToBackStack(Fragment_About.class.getSimpleName())
                    .commit();
        }
        AnalyticsHelper.registerVisitScreenEvent(Constants.CONTACT_US);
    }

    public void openFixedProductFragment(NavDrawItem navDrawItem) {
        closeDrawer();
        try {
            JSONObject jsonObject = new JSONObject(navDrawItem.getData());
            if (jsonObject.has("category")) {
                int id = jsonObject.getInt("category");
                openFixedProductFragment(navDrawItem.getName(), id);
            } else if (jsonObject.has("products")) {
                JSONArray jsonArray = jsonObject.getJSONArray("products");
                int[] ids = new int[jsonArray.length()];
                for (int i = 0; i < jsonArray.length(); i++) {
                    ids[i] = jsonArray.getInt(i);
                }
                openFixedProductFragment(navDrawItem.getName(), ids);
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public void openFixedProductFragment(String title, int categoryId) {
        switch (categoryId) {
            case CategoryItem.ID_TRENDING_ITEMS: {
                openFixedProductFragment(title, TM_ProductInfo.getTrending(AppInfo.MAX_ITEMS_COUNT_HOME));
                break;
            }
            case CategoryItem.ID_BEST_DEALS: {
                openFixedProductFragment(title, TM_ProductInfo.getBestDeals(AppInfo.MAX_ITEMS_COUNT_HOME));
                break;
            }
            case CategoryItem.ID_FRESH_ARRIVALS: {
                openFixedProductFragment(title, TM_ProductInfo.getFreshArrivals(AppInfo.MAX_ITEMS_COUNT_HOME));
                break;
            }
            case CategoryItem.ID_RECENTLY_VIEWED: {
                openFixedProductFragment(title, RecentlyViewedItem.getAllProducts());
                break;
            }
            default: {
                openFixedProductFragment(title, TM_CategoryInfo.getWithId(categoryId));
            }
        }
    }

    public void openFixedProductFragment(String title, TM_CategoryInfo categoryInfo) {
        String tag = CategoryChildFragment.class.getSimpleName();
        getFM().beginTransaction()
                .replace(R.id.content, CategoryChildFragment.newInstance(title, categoryInfo, true), tag)
                .addToBackStack(tag)
                .commit();
    }

    public void openFixedProductFragment(String title, List<TM_ProductInfo> products) {
        String tag = Fragment_FixedProduct.class.getSimpleName();
        getFM().beginTransaction()
                .replace(R.id.content, Fragment_FixedProduct.newInstance(title, products), tag)
                .addToBackStack(tag)
                .commit();
    }

    public void showOrdersFragment() {
        showOrdersFragment(false);
    }

    public void showOrdersFragment(boolean addToBackStack) {
        if (AppUser.hasSignedIn() || GuestUserConfig.isGuestCheckout()) {
            getFM().beginTransaction()
                    .replace(R.id.content, Fragment_Orders.newInstance())
                    .addToBackStack(Fragment_Orders.class.getSimpleName())
                    .commit();
            AnalyticsHelper.registerVisitScreenEvent(Constants.ORDERS);
        }
    }

    public void showSellerOrdersFragment(String content) {
        if (AppUser.hasSignedIn() || GuestUserConfig.isGuestCheckout()) {

            getFM().beginTransaction()
                    .replace(R.id.content, Fragment_SellerOrders.newInstance(content, true))
                    .commit();
            AnalyticsHelper.registerVisitScreenEvent(Constants.ORDERS);
        }
    }

    public void openReservationFormFragment() {
        getFM().beginTransaction()
                .replace(R.id.content, Fragment_ReservationForm.newInstance())
                .addToBackStack(Fragment_ReservationForm.class.getSimpleName())
                .commit();
    }

    public void openContactForm3Fragment() {
        getFM().beginTransaction()
                .replace(R.id.content, Fragment_ContactForm3.newInstance())
                .addToBackStack(Fragment_ContactForm3.class.getSimpleName())
                .commit();
    }

    private void changeVendor(final int index) {
        if (Cart.getItemCount() + Wishlist.getItemCount() > 0) {
            Helper.getConfirmation(this, getString(L.string.vendor_change_confirmation), new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    confirmChangeVendor(index);
                }
            });
        } else {
            confirmChangeVendor(index);
        }
    }

    private void confirmChangeVendor(int index) {
        Cart.clearCart();
        Wishlist.clearItems();
        RecentlyViewedItem.clearItems();
        TM_Coupon.clearAll();

        Preferences.putString("vendor", "");
        final Intent intent = new Intent(this, VendorsActivity.class);
        if (index > 0) {
            SellerInfo vendor = SellerInfo.getAllSellers().get(index);
            intent.putExtra("requestedVendorId", vendor.getId());
        }
        startActivity(intent);
        finish();
    }

    public void showHomeFragment(final boolean clearStack) {
        FragmentManager fragmentManager = getSupportFragmentManager();
        if (clearStack) {
            clearFragmentStack(fragmentManager);
        }
        if (MultiVendorConfig.isSellerApp()) {
            if (MultiVendorConfig.isEnabled() && AppUser.isVendor()) {
                SellerInfo sellerInfo = SellerInfo.getCurrentSeller();
                if (sellerInfo != null && sellerInfo.isVerified()) {
                    showVendorSection(true);
                } else if (sellerInfo != null && !sellerInfo.isVerified()) {
                    Helper.toast(getString(L.string.dialog_msg_not_verified_seller));
                    showVendorSection(true);
                } else {
                    //TODO please test this condition in release build.
                    //Helper.toast("User not Registered as Vendor");
                    //updateUserInfoInBackground();
                }
            } else {
                showSellerHomeFragment(clearStack);
            }
        } else {
            if (AppInfo.homeConfigUltimate != null && AppInfo.homeConfigUltimate.homeElements != null) {
                fragmentManager.beginTransaction()
                        .replace(R.id.content, Fragment_HomeUltimate.newInstance())
                        .commit();
            } else {
                fragmentManager.beginTransaction()
                        .replace(R.id.content, Fragment_Home.newInstance())
                        .commit();
            }
            AnalyticsHelper.registerVisitScreenEvent(Constants.HOME);
        }
    }

    public void showShipmentStatusFragment(final boolean clearStack, String waybillNumber) {
        FragmentManager fm = getSupportFragmentManager();
        if (clearStack) {
            clearFragmentStack(fm);
        }

        ShipmentStatusFragment fragment = ShipmentStatusFragment.newInstance();
        Bundle bundle = new Bundle();
        bundle.putString(Constants.ARG_WAYBILL_NUMBER, waybillNumber);
        fragment.setArguments(bundle);
        fm.beginTransaction()
                .replace(R.id.content, fragment)
                .addToBackStack(ShipmentStatusFragment.class.getSimpleName())
                .commit();
    }

    public void showSellerHomeFragment(boolean clearStack) {
        FragmentManager fragmentManager = getSupportFragmentManager();
        if (clearStack) {
            clearFragmentStack(fragmentManager);
        }
        fragmentManager.beginTransaction()
                .replace(R.id.content, SellerHomeFragment.newInstance())
                .commit();
        AnalyticsHelper.registerVisitScreenEvent(Constants.HOME);
    }

    public void showVendorSection() {
        showVendorSection(false);
    }

    public void showVendorSection(final boolean openAsHome) {
        SellerInfo sellerInfo = SellerInfo.getCurrentSeller();
        if (sellerInfo != null) {
            showSellerFragment(openAsHome);
        } else {
            showProgress(getString(L.string.loading_seller_info));
            fetchVendor(new TaskListener() {
                @Override
                public void onTaskDone() {
                    hideProgress();
                    showSellerFragment(openAsHome);
                }

                @Override
                public void onTaskFailed(String msg) {
                    Log.d("-- fetchVendor::onTaskFailed: [" + msg + "] --");
                    hideProgress();
                }
            });
        }
    }

    private void showSellerFragment(boolean openAsHome) {
        SellerInfo sellerInfo = SellerInfo.getCurrentSeller();
        if (sellerInfo == null) {
            Helper.toast(L.string.please_try_again);
            return;
        }

        if (!sellerInfo.isVerified()) {
            if (MultiVendorConfig.isSubscriptionEnabled() && sellerInfo.membership_status != null && !sellerInfo.membership_status.equalsIgnoreCase("active")) {
                showSellerSubscriptionDialog(sellerInfo.subscription_url);
                // Reset seller info to force load updated seller info
                SellerInfo.setCurrentSeller(null);
                return;
            }

            Helper.toast(L.string.seller_verification_is_pending);
            return;
        }

        try {
            getFM().beginTransaction()
                    .replace(R.id.content, Fragment_SellerZone.newInstance(), Fragment_SellerZone.class.getSimpleName())
                    .commit();
            AnalyticsHelper.registerVisitScreenEvent(openAsHome ? Constants.HOME : Constants.VENDOR_SECTION);
        } catch (Exception ignored) {
        }
    }

    public void fetchVendor(final TaskListener taskListener) {
        DataEngine.getDataEngine().fetchSellerInBackground(AppUser.getUserId(), new DataQueryHandler<String>() {
            @Override
            public void onSuccess(String data) {
                try {
                    SellerInfo.setCurrentSeller(JsonUtils.parseJsonAndCreateSellerInfo(data));
                    if (taskListener != null) {
                        taskListener.onTaskDone();
                    }
                } catch (JSONException je) {
                    je.printStackTrace();
                    if (taskListener != null) {
                        taskListener.onTaskFailed(getString(L.string.generic_error));
                    }
                }
            }

            @Override
            public void onFailure(Exception exception) {
                if (taskListener != null) {
                    taskListener.onTaskFailed(getString(L.string.generic_error));
                }
            }
        });
    }

    private void printFragmentStats(String action) {
        Log.d("FragmentManager", "====================== start ======================");
        Log.d("FragmentManager", "==>" + action);
        int count = getSupportFragmentManager().getBackStackEntryCount();
        Log.d("FragmentManager", "==> " + count);
        Log.d("FragmentManager", "======================= end ========================");
    }

    private void clearFragmentStack(FragmentManager fragmentManager) {
        //FragmentManager.enableDebugLogging(true);
        if (fragmentManager != null) {
            for (int i = fragmentManager.getBackStackEntryCount() - 1; i >= 0; i--) {
                String name = fragmentManager.getBackStackEntryAt(i).getName();
                Log.d("Fragment Manager Name", name);
                fragmentManager.popBackStack(name, FragmentManager.POP_BACK_STACK_INCLUSIVE);
            }
        }
    }

    //Call when you'r 100% sure about product availability
    public void openProductInfo(int productId) {
        openProductInfo(TM_ProductInfo.findProductById(productId));
    }

    //Call when you'r 100% sure about product availability
    public void openProductInfo(TM_ProductInfo product) {
        if (product != null) {
            Intent intent = new Intent(this, ProductDetailActivity.class);
            intent.putExtra(Extras.PRODUCT_ID, product.id);
            startActivityForResult(intent, Constants.REQUEST_SHOW_PRODUCT);
        } else {
            Helper.toast(coordinatorLayout, L.string.product_not_available);
        }
    }

    public void showProductInfoDialog(int productId) {
        TM_ProductInfo product = TM_ProductInfo.getProductWithId(productId);
        if (product != null) {
            if (AppInfo.SHOW_CART_WITH_PRODUCT && product.hasAttributes()) {
                ProductDetailDialogFragment dialog = ProductDetailDialogFragment.create(product, -1, -1, true);
                dialog.setRetainInstance(true);
                dialog.show(getSupportFragmentManager(), ProductDetailDialogFragment.class.getSimpleName());
            } else {
                Intent intent = new Intent(this, ProductDetailActivity.class);
                intent.putExtra(Extras.PRODUCT_ID, productId);
                startActivityForResult(intent, Constants.REQUEST_SHOW_PRODUCT);
            }
        } else {
            Helper.toast(coordinatorLayout, L.string.product_not_available);
        }
    }

    public void showEditProduct(final int productId) {
        TM_ProductInfo product = TM_ProductInfo.findProductById(productId);
        if (product != null) {
            showProgress(getString(L.string.fetching_product_info));
            DataEngine.getDataEngine().getProductInfoInBackground(productId, new DataQueryHandler() {
                @Override
                public void onSuccess(Object data) {
                    hideProgress();
                    Intent intent = new Intent(MainActivity.this, ProductUploadActivity.class);
                    intent.putExtra(Extras.PRODUCT_ID, productId);
                    startActivityForResult(intent, Constants.REQUEST_UPLOAD_PRODUCT);
                }

                @Override
                public void onFailure(Exception error) {
                    hideProgress();
                    error.printStackTrace();
                }
            });
        }
    }

    public void showCategoryInfo(int categoryId) {
        if (!TM_CategoryInfo.hasCategory(categoryId)) {
            Helper.toast(coordinatorLayout, L.string.category_not_available);
        } else {
            expandCategory(categoryId);
        }
    }

    public void showProductInfoQuick(int productId, int selected_variation_id, int selected_variation_index, boolean can_buy) {
        if (!TM_ProductInfo.isAvailable(productId)) {
            Helper.toast(coordinatorLayout, L.string.product_not_available);
            return;
        }

        Intent intent = new Intent(this, ProductDetailActivity.class);
        intent.putExtra(Extras.PRODUCT_ID, productId);
        intent.putExtra("selected_variation_id", selected_variation_id);
        intent.putExtra("selected_variation_index", selected_variation_index);
        intent.putExtra("can_buy", can_buy);
        startActivityForResult(intent, Constants.REQUEST_SHOW_PRODUCT);
    }

    public void showEditProfile(boolean showFullProfile) {
        Intent intent = new Intent(this, ProfileActivity.class);
        intent.putExtra(Extras.SHOW_FULL_PROFILE, showFullProfile);
        startActivityForResult(intent, Constants.REQUEST_EDIT_PROFILE);
    }

    public void showEditProfile(boolean showFullProfile, Address address) {
        Intent intent = new Intent(this, ProfileActivity.class);
        intent.putExtra(Extras.SHOW_FULL_PROFILE, showFullProfile);
        intent.putExtra(Extras.LOCATION_DATA_EXTRA, address);
        startActivityForResult(intent, Constants.REQUEST_EDIT_PROFILE);
    }

    public void showUpdateProduct(int productId) {
        Intent intent = new Intent(this, ProductUploadActivity.class);
        intent.putExtra(Extras.PRODUCT_ID, productId);
        startActivityForResult(intent, Constants.REQUEST_UPLOAD_PRODUCT);
    }

    public void setActivityResultHandler(ActivityResultHandler activityResultHandler) {
        this.activityResultHandler = activityResultHandler;
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (activityResultHandler != null) {
            activityResultHandler.onActivityResult(requestCode, resultCode, data);
            activityResultHandler = null;
        }

        if (PaymentManager.INSTANCE.handleResult(requestCode, resultCode, data)) {
            return;
        }

        switch (requestCode) {
            case Constants.REQUEST_SHOW_PRODUCT: {
                handleShowProductRequestResult(resultCode);
            }
            break;

            case Constants.REQUEST_EDIT_PROFILE: {
                handleEditProfileRequestResult(resultCode);
            }
            break;

            case Constants.REQUEST_UPLOAD_PRODUCT: {
                Fragment fragment = findFragment(Fragment_SellerZone.class);
                if (fragment instanceof Fragment_SellerZone) {
                    ((Fragment_SellerZone) fragment).handleActivityResult(requestCode, resultCode, data);
                }
            }
            break;

            case Constants.REQUEST_CHANGE_STORE: {
                if (resultCode == RESULT_OK) {
                    changeStore(data.getStringExtra(Extras.MULTI_STORE_PLATFORM));
                }
            }
            break;

            case Constants.REQUEST_BARCODE_CAPTURE: {
                if (resultCode == CommonStatusCodes.SUCCESS) {
                    if (data != null) {
                        String sku = data.getStringExtra(BarcodeReaderActivity.BarcodeObject);
                        openOrLoadProductInfo(sku);
                    }
                } else {
                    Helper.toast(String.format(getString(R.string.barcode_error),
                            CommonStatusCodes.getStatusCodeString(resultCode)));
                }
            }
            break;

            case ImageUpload.REQUEST_IMAGE_CAPTURE:
            case ImageUpload.PICK_PHOTO_CODE: {
                Fragment fragment = findFragmentById(R.id.content);
                if (fragment instanceof Fragment_Orders) {
                    ((Fragment_Orders) fragment).handleActivityResult(requestCode, resultCode, data);
                } else if (fragment instanceof Fragment_SellerStoreSettings) {
                    ((Fragment_SellerStoreSettings) fragment).handleActivityResult(requestCode, resultCode, data);
                }
            }
            break;

            default: {
                Fragment fragment = findFragment(Fragment_Login_Dialog.class);
                if (fragment instanceof Fragment_Login_Dialog) {
                    ((Fragment_Login_Dialog) fragment).handleActivityResult(requestCode, resultCode, data);
                } else if (fragment instanceof SellerLoginFragment) {
                    ((SellerLoginFragment) fragment).handleActivityResult(requestCode, resultCode, data);
                }
            }
        }
    }

    private void handleShowProductRequestResult(int resultCode) {
        switch (resultCode) {
            case OnFragmentPopListener.CODE_BUY:
            case OnFragmentPopListener.CODE_SHOW:
                openCartFragment();
                break;
            case OnFragmentPopListener.CODE_HOME:
                showHomeFragment(true);
                break;
            case OnFragmentPopListener.CODE_CART:
                openCartFragment();
                break;
            case OnFragmentPopListener.CODE_WISHLIST:
                openWishlistFragment(false);
                break;
            case OnFragmentPopListener.CODE_SEARCH:
                openSearchFragment();
                break;
            case OnFragmentPopListener.CODE_OPINIONS:
                openOpinionFragment();
                break;
        }
    }

    private void handleEditProfileRequestResult(int resultCode) {
        switch (resultCode) {
            case RESULT_OK:
                if (mOnProfileEditListener != null) {
                    mOnProfileEditListener.done();
                    mOnProfileEditListener = null;
                } else {
                    try {
                        Fragment f = getFM().findFragmentById(R.id.content);
                        if (f instanceof Fragment_ConfirmOrder) {
                            ((Fragment_ConfirmOrder) f).refresh();
                        }
                    } catch (Exception ignored) {
                    }
                }
                break;
            case Constants.RESULT_EDIT_PROFILE_SKIP_LOGIN:
                openSelectPaymentPage(null);
                break;
            default:
                if (mOnProfileEditListener != null) {
                    mOnProfileEditListener.canceled();
                    mOnProfileEditListener = null;
                }
                break;
        }
    }

    @Override
    protected void onActionBarRestored() {
        updateBadgeCounts();
        updateActionBarView();
    }

    public void updateBadgeCounts() {
        if (AppInfo.ENABLE_CART && txt_badgecount_cart != null && layoutCartBadgeSection != null) {
            if (Cart.getItemCount() > 0) {
                /* try {
                    int oldValue = Integer.parseInt(txt_badgecount_cart.getText().toString());
                    int newValue = Cart.getItemCount();
                    if (oldValue != newValue) {
                        new FadeInAnimation(layoutCartBadgeSection).setDuration(200).animate();
                        new ScaleInOutHeartBeatAnimation(layoutCartBadgeSection).setDuration(200).animate();
                    }
                } catch (Exception ignored) {
                } */
                txt_badgecount_cart.setText(String.valueOf(Cart.getItemCount()));
                icon_badge_cart.setVisibility(View.VISIBLE);
            } else {
                txt_badgecount_cart.setText("");
                icon_badge_cart.setVisibility(View.GONE);
            }

        }
        if (AppInfo.SHOW_BOTTOM_NAV_MENU && AppInfo.ENABLE_CART) {
            if (Cart.getItemCount() > 0) {
                cart_badge_txt.setText(String.valueOf(Cart.getItemCount()));
                cart_badge_txt.setVisibility(View.VISIBLE);
                cart_badge_section.setVisibility(View.VISIBLE);
            } else {
                cart_badge_txt.setVisibility(View.GONE);
                cart_badge_section.setVisibility(View.GONE);
            }
        }

        if (txt_badgecount_wishlist != null) {
            if (Wishlist.getItemCount() > 0) {
                /*
                try {
                    int oldValue = Integer.parseInt(txt_badgecount_wishlist.getText().toString());
                    int newValue = Wishlist.getItemCount();
                    if (oldValue != newValue) {
                        new ScaleInOutHeartBeatAnimation(icon_badge_wishlist).setDuration(200).animate();
                    }
                } catch (Exception ignored) {
                }
				*/

                txt_badgecount_wishlist.setText(String.valueOf(Wishlist.getItemCount()));
                icon_badge_wishlist.setVisibility(View.VISIBLE);
            } else {
                txt_badgecount_wishlist.setText("");
                icon_badge_wishlist.setVisibility(View.GONE);
            }
        }
        if (AppInfo.SHOW_BOTTOM_NAV_MENU && AppInfo.ENABLE_WISHLIST && wishlist_badge_txt != null) {
            if (Wishlist.getItemCount() > 0) {
                wishlist_badge_txt.setText(String.valueOf(Wishlist.getItemCount()));
                wishlist_badge_txt.setVisibility(View.VISIBLE);
                wishlist_badge_section.setVisibility(View.VISIBLE);
            } else {
                wishlist_badge_txt.setVisibility(View.GONE);
                wishlist_badge_section.setVisibility(View.GONE);
            }
        }

        if (txt_badgecount_opinion != null) {
            if (AppInfo.PENDING_NOTIFICATIONS > 0) {
                txt_badgecount_opinion.setText(String.valueOf(AppInfo.PENDING_NOTIFICATIONS));
                icon_badge_opinion.setVisibility(View.VISIBLE);
            } else {
                txt_badgecount_opinion.setText("");
                icon_badge_opinion.setVisibility(View.GONE);
            }
        }

        if (AppInfo.SHOW_BOTTOM_NAV_MENU && opinion_badge_txt != null) {
            if (AppInfo.PENDING_NOTIFICATIONS > 0) {
                opinion_badge_txt.setText(String.valueOf(AppInfo.PENDING_NOTIFICATIONS));
                opinion_badge_txt.setVisibility(View.VISIBLE);
                opinion_badge_section.setVisibility(View.VISIBLE);
            } else {
                opinion_badge_txt.setVisibility(View.GONE);
                opinion_badge_section.setVisibility(View.GONE);
            }
        }

    }

    public void reloadMenu() {
        supportInvalidateOptionsMenu();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        this.setOptionsMenu(menu);
        FreshChatConfig.onResume(this);
        if (!mNavigationDrawerFragment.isDrawerOpen()) {
            getMenuInflater().inflate(R.menu.menu_empty, menu);

            final Fragment fragment = findFragmentById(R.id.content);

            boolean showHome = true;
            boolean showCart = true;
            boolean showWishList = true;
            boolean showSearch = true;
            boolean showOpinions = true;
            boolean showActionBarImage = false;
            boolean showCurrencySwitch = false;
            boolean showCall = false;

            if (fragment instanceof Fragment_Cart) {
                showCart = false;
            } else if (fragment instanceof Fragment_Wish) {
                showWishList = false;
            } else if (fragment instanceof SearchFragment) {
                showSearch = false;
            } else if (fragment instanceof Fragment_Opinions) {
                showOpinions = false;
            } else if (fragment instanceof Fragment_Orders
                    || fragment instanceof Fragment_Profile
                    || fragment instanceof Fragment_About
                    || fragment instanceof Fragment_OrderFail
                    || fragment instanceof Fragment_OrderReceipt
                    || fragment instanceof Fragment_SellerZone) {
                showOpinions = false;
                showSearch = false;
                showWishList = false;
                showCart = false;
            } else if (fragment instanceof Fragment_Home || fragment instanceof Fragment_HomeUltimate) {
                showHome = false;
                showActionBarImage = true;
                showCurrencySwitch = true;
                showCall = true;
            }

            for (int i = 0; i < AppInfo.HOME_MENU_ITEMS.length; i++) {
                switch (AppInfo.HOME_MENU_ITEMS[i] + Constants.ID_ACTION_MENU_HOME) {
                    case Constants.ID_ACTION_MENU_HOME: {
                        MenuItem item = menu.findItem(Constants.ID_ACTION_MENU_HOME);
                        if (item == null) {
                            item = menu.add(0, Constants.ID_ACTION_MENU_HOME, 0, getString(L.string.menu_title_home)).setIcon(R.drawable.ic_vc_home);
                            item.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM);
                            item.getIcon().setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_IN);
                        }
                        item.setVisible(showHome);
                        break;
                    }
                    case Constants.ID_ACTION_MENU_CART: {
                        MenuItem item = menu.findItem(Constants.ID_ACTION_MENU_CART);
                        if (item == null) {
                            item = menu.add(0, Constants.ID_ACTION_MENU_CART, 0, getString(L.string.menu_title_cart))
                                    .setIcon(R.drawable.ic_vc_cart);
                            item.setActionView(R.layout.icon_badge_cart);
                            item.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM);
                        }
                        if (showCart && AppInfo.ENABLE_CART && GuestUserConfig.isEnableCart()) {
                            item.setVisible(true);
                            RelativeLayout actionView = (RelativeLayout) item.getActionView();
                            layoutCartBadgeSection = (RelativeLayout) actionView.findViewById(R.id.badge_section);
                            txt_badgecount_cart = (TextView) actionView.findViewById(R.id.text_badge_count);
                            icon_badge_cart = (ImageView) actionView.findViewById(R.id.icon_badge);
                            Helper.stylizeBadgeView(icon_badge_cart, txt_badgecount_cart);
                            actionView.findViewById(R.id.main_icon).setOnClickListener(new View.OnClickListener() {
                                @Override
                                public void onClick(View v) {
                                    openCartFragment();
                                }
                            });

                            ImageView main_icon = (ImageView) actionView.findViewById(R.id.main_icon);
                            Helper.stylizeActionBar(main_icon);
                        } else {
                            item.setVisible(false);
                        }
                        break;
                    }
                    case Constants.ID_ACTION_MENU_WISH: {
                        if (!AppInfo.ENABLE_WISHLIST) {
                            break;
                        }
                        MenuItem item = menu.findItem(Constants.ID_ACTION_MENU_WISH);
                        if (item == null) {
                            item = menu.add(0, Constants.ID_ACTION_MENU_WISH, 0,
                                    Helper.getTotalWishListCount())
                                    .setIcon(R.drawable.ic_vc_wish_flat);
                            item.setActionView(R.layout.icon_badge_wishlist);
                            item.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM);
                        }
                        if (showWishList) {
                            item.setVisible(true);
                            RelativeLayout actionView = (RelativeLayout) item.getActionView();
                            txt_badgecount_wishlist = (TextView) actionView.findViewById(R.id.text_badge_count);
                            icon_badge_wishlist = (ImageView) actionView.findViewById(R.id.icon_badge);
                            Helper.stylizeBadgeView(icon_badge_wishlist, txt_badgecount_wishlist);
                            actionView.findViewById(R.id.main_icon).setOnClickListener(new View.OnClickListener() {
                                @Override
                                public void onClick(View v) {
                                    openWishlistFragment(true);
                                }
                            });
                            ImageView main_icon = (ImageView) actionView.findViewById(R.id.main_icon);
                            Helper.stylizeActionBar(main_icon);
                        } else {
                            item.setVisible(false);
                        }
                        break;
                    }

                    case Constants.ID_ACTION_MENU_SEARCH: {
                        if (AppInfo.SHOW_BOTTOM_NAV_MENU) {
                            // don't show search icon when using bottom navigation
                            break;
                        }

                        MenuItem item = menu.findItem(Constants.ID_ACTION_MENU_SEARCH);
                        if (item == null) {
                            item = menu.add(0, Constants.ID_ACTION_MENU_SEARCH, 0, getString(L.string.menu_title_search));
                            item.setIcon(R.drawable.ic_vc_search);
                            item.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM);
                        }
                        item.getIcon().setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_IN);
                        item.setVisible(showSearch);
                        break;
                    }

                    case Constants.ID_ACTION_MENU_OPINION: {
                        if (AppInfo.ENABLE_OPINIONS) {
                            MenuItem item = menu.findItem(Constants.ID_ACTION_MENU_OPINION);
                            if (item == null) {
                                item = menu.add(0, Constants.ID_ACTION_MENU_OPINION, 0,
                                        getString(L.string.menu_title_opinion))
                                        .setIcon(R.drawable.ic_vc_opinion);
                                item.setActionView(R.layout.icon_badge_opinions);
                                item.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM);
                            }
                            if (showOpinions) {
                                item.setVisible(true);
                                RelativeLayout opinionLayout = (RelativeLayout) item.getActionView();
                                txt_badgecount_opinion = (TextView) opinionLayout.findViewById(R.id.text_badge_count);
                                icon_badge_opinion = (ImageView) opinionLayout.findViewById(R.id.icon_badge);
                                Helper.stylizeBadgeView(icon_badge_opinion, txt_badgecount_opinion);
                                opinionLayout.findViewById(R.id.main_icon).setOnClickListener(new View.OnClickListener() {
                                    @Override
                                    public void onClick(View v) {
                                        openOpinionFragment();
                                    }
                                });
                                ImageView main_icon = (ImageView) opinionLayout.findViewById(R.id.main_icon);
                                Helper.stylizeActionBar(main_icon);
                            } else {
                                item.setVisible(false);
                            }
                        }
                        break;
                    }
                    case Constants.ID_ACTION_MENU_DOWNLOADS: {
                        MenuItem item = menu.findItem(Constants.ID_ACTION_MENU_DOWNLOADS);
                        if (item == null) {
                            item = menu.add(0, Constants.ID_ACTION_MENU_DOWNLOADS, 0,
                                    getString(L.string.downloads))
                                    .setIcon(R.drawable.ic_vc_folder_open);
                            item.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM);
                            item.getIcon().setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_IN);
                            item.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
                                @Override
                                public boolean onMenuItemClick(MenuItem menuItem) {
                                    Helper.openDownloadsFolder(MainActivity.this);
                                    return false;
                                }
                            });
                        }

                        if (ImageDownloaderConfig.isEnabled()) {
                            item.setVisible(true);
                        }
                        break;
                    }
                    case Constants.ID_ACTION_MENU_CURRENCY: {
                        if (AppInfo.ENABLE_CURRENCY_SWITCHER) {
                            MenuItem item = menu.findItem(Constants.ID_ACTION_MENU_CURRENCY);
                            if (item == null) {
                                item = menu.add(0, Constants.ID_ACTION_MENU_CURRENCY, 0, getString(L.string.change_currency));
                                item.setIcon(R.drawable.ic_vc_currency);
                                item.setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS);
                                item.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
                                    @Override
                                    public boolean onMenuItemClick(MenuItem menuItem) {
                                        //CurrencySwitcherDialogFragment fragment = new CurrencySwitcherDialogFragment();
                                        //fragment.show(getSupportFragmentManager(), CurrencySwitcherDialogFragment.class.getSimpleName());
                                        startActivity(new Intent(MainActivity.this, ChangeCurrencyActivity.class));
                                        return true;
                                    }
                                });
                            }
                            item.getIcon().setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_IN);
                            item.setVisible(showCurrencySwitch);
                        }
                        break;
                    }
                    case Constants.ID_ACTION_MENU_CALL: {
                        MenuItem item = menu.findItem(Constants.ID_ACTION_MENU_CALL);
                        if (item == null && !AppInfo.homeMenuContactNumbers.isEmpty() && AppInfo.homeMenuContactNumbers.size() > 1) {
                            item = menu.add(0, Constants.ID_ACTION_MENU_CALL, 0, getString(L.string.menu_title_call));
                            item.setIcon(R.drawable.ic_vc_call);
                            item.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM);
                            item.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
                                @Override
                                public boolean onMenuItemClick(MenuItem menuItem) {
                                    if (AppInfo.homeMenuContactNumbers.size() > 1) {
                                        Helper.openCallDialog(MainActivity.this, AppInfo.homeMenuContactNumbers);
                                    } else {
                                        String phoneNumber = AppInfo.homeMenuContactNumbers.get(0);
                                        if (!phoneNumber.isEmpty()){
                                            Helper.callTo(MainActivity.this, phoneNumber);
                                        }
                                    }
                                    return false;
                                }
                            });
                        }
                        item.getIcon().setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_IN);
//                        item.setVisible(showCall);
                        break;
                    }
                }
            }
            setShowActionBarImage(showActionBarImage);
            restoreActionBar();
            return true;
        }
        return super.onCreateOptionsMenu(menu);
    }

    public void setupWishGroupMenu(Menu menu) {
        menu.add(0, Constants.ID_WISH_MENU_RENAME, 0, getString(L.string.rename));
        menu.add(0, Constants.ID_WISH_MENU_DELETE, 0, getString(L.string.delete));
        menu.add(0, Constants.ID_WISH_MENU_DOWNLOAD_LIST, 0, getString(L.string.download));

        if (AppUser.hasSignedIn())
            menu.add(0, Constants.ID_WISH_MENU_SHARE, 0, getString(L.string.share));
    }

    public void createAppUser(boolean fetchSellerInfo) {
        String jsonData = AppUser.getInstance().getJsonData();
        if (!TextUtils.isEmpty(jsonData)) {
            JsonUtils.parseJsonAndCreateAppUser(jsonData);
            AppUser.getInstance().setJsonData("");
        }
        if (fetchSellerInfo) {
            fetchVendorInfo();
        }
    }

    private void fetchVendorInfo() {
        if (MultiVendorConfig.isEnabled() && AppUser.isVendor()) {
            fetchVendor(new TaskListener() {
                @Override
                public void onTaskDone() {
                    if (MultiVendorConfig.isSellerApp()) {
                        showHomeFragment(true);
                    } else {
                        Fragment fragment = getFM().findFragmentById(R.id.content);
                        if (fragment != null && fragment instanceof Fragment_SellerZone) {
                            Fragment_SellerZone fragmentSellerZone = (Fragment_SellerZone) fragment;
                            fragmentSellerZone.updateSellerInfo();
                            Fragment page = fragmentSellerZone.getChildFragmentManager().findFragmentByTag("android:switcher:" + R.id.seller_view_pager + ":" + 0);
                            if (page != null && page instanceof Fragment_SellerProfile) {
                                Fragment_SellerProfile sellerProfile = (Fragment_SellerProfile) page;
                                sellerProfile.refreshSellerInfo(SellerInfo.getCurrentSeller());
                            }
                        }
                    }
                }

                @Override
                public void onTaskFailed(String msg) {
                    if (MultiVendorConfig.isSellerApp()) {
                        showSellerHomeFragment(true);
                    }
                }
            });
        }
    }

    public void generateOrderReceipt(TM_Order order, PaymentGateway gateway, TimeSlot timeSlot) {
        fragmentPopBackStack();
        getFM().beginTransaction()
                .replace(R.id.content, Fragment_OrderReceipt.newInstance(order, gateway, timeSlot))
                .addToBackStack(Fragment_OrderReceipt.class.getSimpleName())
                .commitAllowingStateLoss();
    }

    public void generateOrderReceipt(int orderId, PaymentGateway gateway, TimeSlot timeSlot) {
        fragmentPopBackStack();
        getFM().beginTransaction()
                .replace(R.id.content, Fragment_OrderReceipt.newInstance(orderId, gateway, timeSlot))
                .addToBackStack(Fragment_OrderReceipt.class.getSimpleName())
                .commitAllowingStateLoss();
    }

    public void generateOrderFailure(String reason) {
        fragmentPopBackStack();
        getFM().beginTransaction()
                .replace(R.id.content, Fragment_OrderFail.newInstance(reason))
                .addToBackStack(Fragment_OrderFail.class.getSimpleName())
                .commitAllowingStateLoss();
    }

    public void openSelectPaymentPage(String[] args) {
        getFM().beginTransaction()
                .replace(R.id.content, PaymentFragment.newInstance(args))
                .addToBackStack(PaymentFragment.class.getSimpleName())
                .commit();
        AnalyticsHelper.registerVisitScreenEvent(Constants.SELECT_PAYMENT);
    }

    public void expandCategory(int categoryId) {
        if (TM_CategoryInfo.hasCategory(categoryId)) {
            expandCategory(TM_CategoryInfo.getWithId(categoryId));
        } else {
            Helper.toast(coordinatorLayout, L.string.category_not_available);
        }
    }

    public void showAllCategoryList() {
        String tag = Fragment_ItemList.class.getSimpleName();
        getFM().beginTransaction()
                .replace(R.id.content, Fragment_ItemList.newInstance(TM_CategoryInfo.getAll(), "category", getString(L.string.category)), tag)
                .addToBackStack(tag)
                .commit();
    }

    public void showAllSellerList() {
        List<SellerInfo> allSellers = SellerInfo.getAllSellers();
        if (!allSellers.isEmpty()) {
            showAllSellerList(allSellers);
        } else {
            DataEngine.getDataEngine().fetchSellersInBackground(new DataQueryHandler<List<SellerInfo>>() {
                @Override
                public void onSuccess(List<SellerInfo> vendors) {
                    for (SellerInfo vendor : vendors) {
                        vendor.commit();
                    }
                    showAllSellerList(vendors);
                }

                @Override
                public void onFailure(Exception exception) {
                    exception.printStackTrace();
                }
            });
        }
    }

    public void showAllSellerList(List<SellerInfo> allSellers) {
        String tag = Fragment_ItemList.class.getSimpleName();
        getFM().beginTransaction()
                .replace(R.id.content, Fragment_ItemList.newInstance(allSellers, "seller", getString(L.string.title_seller_zone)), tag)
                .addToBackStack(tag)
                .commit();
    }

    public void expandCategory(TM_CategoryInfo category) {
        String tag = CategoryFragment.class.getSimpleName();
        getFM().beginTransaction()
                .replace(R.id.content, CategoryFragment.newInstance(category), tag)
                .addToBackStack(tag)
                .commit();
        AnalyticsHelper.registerVisitCategoryEvent(category);
    }

    public void showSellerInfo(SellerInfo sellerInfo) {
        if (sellerInfo != null) {
            getFM().beginTransaction()
                    .replace(R.id.content, Fragment_SellerProducts.newInstance(sellerInfo, true, false))
                    .addToBackStack(Fragment_SellerProducts.class.getSimpleName())
                    .commit();
        }
    }

    public void openCouponList() {
        getFM().beginTransaction()
                .replace(R.id.content, Fragment_Coupons.newInstance())
                .addToBackStack(Fragment_Coupons.class.getSimpleName())
                .commit();
    }

    public void openNotificationList() {
        getFM().beginTransaction()
                .replace(R.id.content, Fragment_Notification.newInstance())
                .addToBackStack(Fragment_Notification.class.getSimpleName())
                .commit();
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        outState.putString("WORKAROUND_FOR_BUG_19917_KEY", "WORKAROUND_FOR_BUG_19917_VALUE");
        super.onSaveInstanceState(outState);
    }

    @Override
    public void onBackPressed() {
        if (mNavigationDrawerFragment.isDrawerOpen()) {
            mNavigationDrawerFragment.closeDrawer();
            return;
        }

        Fragment fragment = findFragmentById(R.id.content);
        if (!MultiVendorConfig.isSellerApp() && fragment instanceof Fragment_SellerZone) {
            showHomeFragment(true);
        } else {
            super.onBackPressed();
        }
    }

    private boolean isHomeFragment(Fragment fragment) {
        return fragment instanceof Fragment_Home || fragment instanceof Fragment_HomeUltimate;
    }

    private void toggleNotificationChannelsSubscription() {
        if (NotificationConfig.isEnabled() && NotificationConfig.getType() == NotificationConfig.Type.FCM) {
            if (NotificationConfig.containsChannels(new String[]{Constants.CHANNEL_GUEST, Constants.CHANNEL_LOGIN})) {
                Intent intent = new Intent(this, MyFcmRegistrationService.class);
                intent.setAction(Constants.ACTION_MANAGE_CHANNEL_SUBSCRIPTION);
                if (AppUser.hasSignedIn()) {
                    intent.putExtra(Extras.SUBSCRIBE_CHANNEL, Constants.CHANNEL_LOGIN);
                    intent.putExtra(Extras.UNSUBSCRIBE_CHANNEL, Constants.CHANNEL_GUEST);
                } else {
                    intent.putExtra(Extras.SUBSCRIBE_CHANNEL, Constants.CHANNEL_GUEST);
                    intent.putExtra(Extras.UNSUBSCRIBE_CHANNEL, Constants.CHANNEL_LOGIN);
                }
                this.startService(intent);
            }
        }
    }

    private void autoSubscribeNotificationChannels() {
        if (NotificationConfig.isEnabled()) {
            List<NotificationConfig.Channel> channels = NotificationConfig.getChannels();
            if (channels != null) {
                for (NotificationConfig.Channel channel : channels) {
                    if (channel.subscribe) {
                        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(this);
                        boolean enabled = sharedPreferences.getBoolean(channel.id, true);
                        if (enabled) {
                            Intent intent = new Intent(this, MyFcmRegistrationService.class);
                            intent.setAction(Constants.ACTION_MANAGE_CHANNEL_SUBSCRIPTION);
                            intent.putExtra(Extras.SUBSCRIBE_CHANNEL, channel.id);
                            this.startService(intent);
                        }
                    }
                }
            }
        }
    }

    private void addFragmentBackStackListener() {
        final FragmentManager fragmentManager = this.getSupportFragmentManager();
        fragmentManager.addOnBackStackChangedListener(() -> {
            int stackCount = fragmentManager.getBackStackEntryCount();
            if (stackCount > 0) {
                FragmentManager.BackStackEntry backStackEntry = fragmentManager.getBackStackEntryAt(stackCount - 1);
                String name = backStackEntry.getName();
                if (name.equals(Fragment_Cart.class.getSimpleName())
                        || name.equals(Fragment_ConfirmOrder.class.getSimpleName())
                        || name.equals(Fragment_OrderReceipt.class.getSimpleName())
                        || name.equals(Fragment_OrderFail.class.getSimpleName())
                        || name.equals(PaymentFragment.class.getSimpleName())) {
                    FreshChatConfig.setChatButtonVisibility(MainActivity.this, View.GONE);
                    if (AppInfo.SHOW_BOTTOM_NAV_MENU) {
                        Menu menu = bottom_navigation.getMenu();
                        MenuItem cartMenu = menu.findItem(Constants.ID_ACTION_MENU_CART);
                        if (cartMenu != null) {
                            cartMenu.setChecked(true);
                        }
                    }
                    return;
                }
            }
            setBottomNavMenuItemChecked();
            FreshChatConfig.setChatButtonVisibility(MainActivity.this, View.VISIBLE);
        });
    }

    private void changeMultiStore() {
        if (BuildConfig.MULTI_STORE) {
            Intent intent = new Intent(this, MultiStoreListActivity.class);
            startActivityForResult(intent, Constants.REQUEST_CHANGE_STORE);
        }
    }

    public void locateMultiStore() {
        if (BuildConfig.MULTI_STORE) {
            Intent intent = new Intent(this, MultiStoreMapActivity.class);
            intent.setAction(Constants.ACTION_MULTI_STORE_LOCATE_ALL);
            startActivity(intent);
        }
    }

    public void changePlatform() {
        clearData();
        startActivity(new Intent(this, LauncherActivity.class));
        finish();
    }

    public void changeStore(String platform) {
        if (BuildConfig.MULTI_STORE && !platform.equals("")) {
            clearData();
            Intent intent = new Intent(this, LauncherActivity.class);
            intent.putExtra(Extras.MULTI_STORE_PLATFORM, platform);
            startActivity(intent);
            finish();
        }
    }

    private void openBarCodeReader() {
        if (BuildConfig.MULTI_STORE) {
            Intent intent = new Intent(this, BarcodeReaderActivity.class);
            intent.putExtra(BarcodeReaderActivity.AutoFocus, true);
            intent.putExtra(BarcodeReaderActivity.UseFlash, false);
            startActivityForResult(intent, Constants.REQUEST_BARCODE_CAPTURE);
        }
    }

    private void clearData() {
        try {
            Cart.clearCart();
            Wishlist.clearItems();
            RecentlyViewedItem.clearItems();
            TM_Coupon.clearAll();
            proceedSignOut();
        } catch (Exception e) {
            e.printStackTrace();
        }
        Preferences.putString("debug_platform", "");
    }

    private void showBottomNavMenu() {
        if (AppInfo.SHOW_BOTTOM_NAV_MENU) {
            bottom_navigation.setVisibility(View.VISIBLE);
            Helper.stylize(bottom_navigation);
            inflateBottomNavMenu();
            try {
                inflateIconBadges();
            } catch (Exception e) {
                e.printStackTrace();
            }
            bottom_navigation.setOnNavigationItemSelectedListener(new BottomNavigationView.OnNavigationItemSelectedListener() {
                @Override
                public boolean onNavigationItemSelected(@NonNull MenuItem item) {
                    handleBottomNavigationItemSelected(item);
                    return true;
                }
            });
        } else {
            bottom_navigation.setVisibility(View.GONE);
        }
    }

    private void inflateBottomNavMenu() {
        Menu menu = bottom_navigation.getMenu();
        menu.clear();
        MenuItem homeItem = menu.findItem(Constants.ID_ACTION_MENU_HOME);
        if (homeItem == null) {
            homeItem = menu.add(0, Constants.ID_ACTION_MENU_HOME, 0, getString(L.string.menu_title_home)).setIcon(R.drawable.ic_vc_home);
            homeItem.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM);
            homeItem.getIcon().setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_IN);
        }

        for (int i = 0; i < AppInfo.HOME_NAV_MENU_ITEMS.length; i++) {
            switch (AppInfo.HOME_NAV_MENU_ITEMS[i] + Constants.ID_ACTION_MENU_HOME) {
                case Constants.ID_ACTION_MENU_CART: {
                    if (AppInfo.ENABLE_CART && GuestUserConfig.isEnableCart()) {
                        MenuItem item = menu.findItem(Constants.ID_ACTION_MENU_CART);
                        if (item == null) {
                            item = menu.add(0, Constants.ID_ACTION_MENU_CART, 0,
                                    getString(L.string.menu_title_cart))
                                    .setIcon(R.drawable.ic_vc_cart);
                            item.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM);
                        }
                        item.setVisible(true);
                    }
                    break;
                }
                case Constants.ID_ACTION_MENU_WISH: {
                    if (!AppInfo.ENABLE_WISHLIST) {
                        break;
                    }
                    MenuItem item = menu.findItem(Constants.ID_ACTION_MENU_WISH);
                    if (item == null) {
                        item = menu.add(0, Constants.ID_ACTION_MENU_WISH, 0,
                                getString(L.string.menu_title_wishlist))
                                .setIcon(R.drawable.ic_vc_wish_flat);
                        item.setActionView(R.layout.icon_badge_wishlist);
                        item.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM);
                    }
                    item.setVisible(true);
                    break;
                }
                case Constants.ID_ACTION_MENU_SEARCH: {
                    MenuItem item = menu.findItem(Constants.ID_ACTION_MENU_SEARCH);
                    if (item == null) {
                        item = menu.add(0, Constants.ID_ACTION_MENU_SEARCH, 0, getString(L.string.menu_title_search));
                        item.setIcon(R.drawable.ic_vc_search);
                        item.setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS);
                    }
                    item.setVisible(true);
                    break;
                }

                case Constants.ID_ACTION_MENU_CURRENCY: {
                    if (AppInfo.ENABLE_CURRENCY_SWITCHER) {
                        MenuItem item = menu.findItem(Constants.ID_ACTION_MENU_CURRENCY);
                        if (item == null) {
                            item = menu.add(0, Constants.ID_ACTION_MENU_CURRENCY, 0, getString(L.string.change_currency));
                            item.setIcon(R.drawable.ic_vc_currency);
                            item.setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS);
                        }
                        item.setVisible(true);
                    }
                    break;
                }

                case Constants.ID_ACTION_MENU_OPINION: {
                    if (AppInfo.ENABLE_OPINIONS) {
                        MenuItem item = menu.findItem(Constants.ID_ACTION_MENU_OPINION);
                        if (item == null) {
                            item = menu.add(0, Constants.ID_ACTION_MENU_OPINION, 0,
                                    getString(L.string.menu_title_opinion))
                                    .setIcon(R.drawable.ic_vc_opinion);
                            item.setActionView(R.layout.icon_badge_opinions);
                            item.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM);
                        }
                        item.setVisible(true);
                    }
                    break;
                }
                case Constants.ID_ACTION_MENU_DOWNLOADS: {
                    if (!ImageDownloaderConfig.isEnabled()) {
                        break;
                    }
                    MenuItem item = menu.findItem(Constants.ID_ACTION_MENU_DOWNLOADS);
                    if (item == null) {
                        item = menu.add(0, Constants.ID_ACTION_MENU_DOWNLOADS, 0,
                                getString(L.string.downloads))
                                .setIcon(R.drawable.ic_vc_folder_open);
                        item.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM);
                    }
                    item.setVisible(true);
                    break;
                }

            }
        }
    }

    private void handleBottomNavigationItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case Constants.ID_ACTION_MENU_CART:
                openCartFragment();
                break;
            case Constants.ID_ACTION_MENU_WISH:
                openWishlistFragment(true);
                break;
            case Constants.ID_ACTION_MENU_HOME:
                showHomeFragment(true);
                break;
            case Constants.ID_ACTION_MENU_CURRENCY:
                startActivity(new Intent(MainActivity.this, ChangeCurrencyActivity.class));
                break;
            case Constants.ID_ACTION_MENU_OPINION:
                openOpinionFragment();
                break;
            case Constants.ID_ACTION_MENU_DOWNLOADS:
                Helper.openDownloadsFolder(MainActivity.this);
                break;
            case Constants.ID_ACTION_MENU_SEARCH:
                openSearchFragment();
                break;
        }
    }

    public void setBottomNavMenuItemChecked() {
        if (AppInfo.SHOW_BOTTOM_NAV_MENU) {
            Fragment fragment = getFM().findFragmentById(R.id.content);
            Menu menu = bottom_navigation.getMenu();
            MenuItem selectedMenuItem = null;
            if (fragment instanceof Fragment_Home || fragment instanceof Fragment_HomeUltimate || fragment instanceof CategoryChildFragment || fragment instanceof CategoryFragment) {
                selectedMenuItem = menu.findItem(Constants.ID_ACTION_MENU_HOME);
            } else if (fragment instanceof Fragment_Cart) {
                selectedMenuItem = menu.findItem(Constants.ID_ACTION_MENU_CART);
            } else if (fragment instanceof Fragment_Wish) {
                selectedMenuItem = menu.findItem(Constants.ID_ACTION_MENU_WISH);
            } else if (fragment instanceof Fragment_Opinions) {
                selectedMenuItem = menu.findItem(Constants.ID_ACTION_MENU_OPINION);
            } else if (fragment instanceof SearchFragment) {
                selectedMenuItem = menu.findItem(Constants.ID_ACTION_MENU_SEARCH);
            }
            if (selectedMenuItem != null) {
                selectedMenuItem.setChecked(true);
            }
        }
    }

    private void updateActionBarView() {
        if (AppInfo.SHOW_BOTTOM_NAV_MENU) {
            final Fragment fragment = findFragmentById(R.id.content);
            if (fragment instanceof Fragment_Home || fragment instanceof Fragment_HomeUltimate) {
                cardView.setRadius(Helper.DP(4));
                cardView.setCardElevation(Helper.DP(4));
                cardView.setPreventCornerOverlap(true);
                cardView.setUseCompatPadding(false);
                RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
                int margin = Helper.DP(8);
                layoutParams.setMargins(margin, margin, margin, margin);
                cardView.setLayoutParams(layoutParams);
                coordinatorLayout.setBackgroundColor(Color.parseColor(AppInfo.color_theme_statusbar));
                actionBar.setDisplayHomeAsUpEnabled(false);
                actionBar.setDisplayShowHomeEnabled(false);
                actionBar.setHomeAsUpIndicator(null);
                actionBar.setHomeButtonEnabled(false);
                return;
            }
        }
        //TODO use only when you don't need search view as card view
        cardView.setRadius(0);
        cardView.setCardElevation(0);
        cardView.setPreventCornerOverlap(true);
        cardView.setUseCompatPadding(false);
        RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.WRAP_CONTENT);
        layoutParams.setMargins(0, 0, 0, 0);
        cardView.setLayoutParams(layoutParams);
        coordinatorLayout.setBackgroundColor(CContext.getColor(this, R.color.color_bg_theme));
    }

    private void inflateIconBadges() throws Exception {
        Menu menu = bottom_navigation.getMenu();
        for (int i = 0; i < menu.size(); i++) {
            MenuItem menuItem = menu.getItem(i);
            int id = menuItem.getItemId();
            BottomNavigationMenuView menuView = (BottomNavigationMenuView) bottom_navigation.getChildAt(0);
            BottomNavigationItemView itemView = (BottomNavigationItemView) menuView.getChildAt(i);
            if (id == Constants.ID_ACTION_MENU_WISH) {
                View badge = LayoutInflater.from(this)
                        .inflate(R.layout.wishlist_badge, menuView, false);
                wishlist_badge_txt = (TextView) badge.findViewById(R.id.wishlist_badge_tv);
                wishlist_badge_section = badge.findViewById(R.id.wishlist_badge_section);
                ImageView icon_badge = (ImageView) badge.findViewById(R.id.icon_badge);
                if (itemView != null) {
                    itemView.addView(badge);
                }
                Helper.stylizeBadgeView(icon_badge, wishlist_badge_txt);
            } else if (id == Constants.ID_ACTION_MENU_CART) {
                View badge = LayoutInflater.from(this)
                        .inflate(R.layout.cart_badge, menuView, false);
                cart_badge_txt = (TextView) badge.findViewById(R.id.cart_badge_tv);
                cart_badge_section = badge.findViewById(R.id.cart_badge_section);
                ImageView icon_badge = (ImageView) badge.findViewById(R.id.icon_badge);
                if (itemView != null) {
                    itemView.addView(badge);
                }
                Helper.stylizeBadgeView(icon_badge, cart_badge_txt);
            } else if (id == Constants.ID_ACTION_MENU_OPINION) {
                View badge = LayoutInflater.from(this)
                        .inflate(R.layout.opinion_badge, menuView, false);
                opinion_badge_section = badge.findViewById(R.id.opinion_badge_section);
                opinion_badge_txt = (TextView) badge.findViewById(R.id.opinion_badge_tv);
                ImageView icon_badge = (ImageView) badge.findViewById(R.id.icon_badge);
                if (itemView != null) {
                    itemView.addView(badge);
                }
                Helper.stylizeBadgeView(icon_badge, opinion_badge_txt);
            }
        }
    }


    private void showSellerSubscriptionDialog(final String subscriptionUrl) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        View view = LayoutInflater.from(this).inflate(R.layout.dialog_seller_subscription, null);
        LinearLayout header_box = view.findViewById(R.id.header_box);
        header_box.setBackgroundColor(Color.parseColor(AppInfo.color_theme));
        TextView header_msg = view.findViewById(R.id.header_msg);
        Helper.stylizeActionBar(header_msg);
        ImageView iv_close = view.findViewById(R.id.iv_close);
        Helper.stylizeActionBar(iv_close);

        header_msg.setText(getString(L.string.seller_subscription_dialog_title));
        TextView txt_msg = view.findViewById(R.id.txt_msg);
        String message = getString(L.string.seller_subscription_dialog_msg);
        txt_msg.setText(HtmlCompat.fromHtml(message));
        Button btn_ok = view.findViewById(R.id.btn_ok);
        btn_ok.setText(getString(L.string.visit));
        Helper.stylize(btn_ok);

        builder.setView(view).setCancelable(false);
        final AlertDialog alertDialog = builder.create();

        btn_ok.setOnClickListener(view1 -> {
            Helper.hideKeyboard(view1);
            signInWebInBackground(new LoginListener() {
                @Override
                public void onLoginSuccess(String data) {
                    hideProgress();
                    openWebFragment("", subscriptionUrl);
                }

                @Override
                public void onLoginFailed(String cause) {
                    hideProgress();
                    Helper.visitSite(MainActivity.this, subscriptionUrl);
                }
            });
            alertDialog.dismiss();
        });

        iv_close.setOnClickListener(v -> {
            Helper.hideKeyboard(v);
            alertDialog.cancel();
        });
        alertDialog.show();
    }
}
