package com.twist.tmstore;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.content.LocalBroadcastManager;
import android.support.v7.app.ActionBar;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.dataengine.entities.TM_ProductReview;
import com.twist.tmstore.config.FreshChatConfig;
import com.twist.tmstore.config.GuestUserConfig;
import com.twist.tmstore.config.MultiVendorConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.Cart;
import com.twist.tmstore.entities.Wishlist;
import com.twist.tmstore.fragments.Fragment_ProductDetail;
import com.twist.tmstore.fragments.ReviewRatingListFragment;
import com.twist.tmstore.listeners.FragmentRefreshListener;
import com.twist.tmstore.listeners.OnFragmentPopListener;
import com.utils.CContext;
import com.utils.GoogleApiHelper;
import com.utils.Helper;

import java.util.ArrayList;
import java.util.List;

public class ProductDetailActivity extends BaseActivity {

    private ProductDetailPageFragment fragment;

    TextView txt_badgecount_cart = null;
    TextView txt_badgecount_wishlist = null;
    TextView txt_badgecount_opinion = null;
    ImageView icon_badge_cart = null;
    ImageView icon_badge_wishlist = null;
    ImageView icon_badge_opinion = null;

    OnFragmentPopListener onFragmentPopListener;

    private GoogleApiHelper mGoogleApiHelper;
    private static ProductDetailActivity mActivity;

    public static GoogleApiHelper getGoogleApiHelperInstance() {
        return mActivity.mGoogleApiHelper;
    }

    private BroadcastReceiver mFreshChatPushReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            FreshChatConfig.incrementUnreadCount(ProductDetailActivity.this, 1);
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
//        if (!isTaskRoot()
//                && getIntent().hasCategory(Intent.CATEGORY_LAUNCHER)
//                && getIntent().getAction() != null
//                && getIntent().getAction().equals(Intent.ACTION_MAIN)) {
//            finish();
//            return;
//        }
        mActivity = this;
        setContentView(R.layout.activity_product);
        FreshChatConfig.initialize(this);
        FreshChatConfig.setChatButtonVisibility(this, View.VISIBLE);
        Bundle bundle = getIntent().getExtras();
        int productId = bundle.getInt(Extras.PRODUCT_ID);

        TM_ProductInfo product = TM_ProductInfo.getProductWithId(productId);

        int selected_variation_id = bundle.getInt("selected_variation_id", -1);
        int selected_variation_index = bundle.getInt("selected_variation_index", -1);
        boolean can_buy = bundle.getBoolean("can_buy", true);

        setTitleText(product != null ? product.title : "");

        fragment = ProductDetailPageFragment.newInstance(product, selected_variation_id, selected_variation_index, can_buy);

        onFragmentPopListener = new OnFragmentPopListener() {
            @Override
            public void onFragmentPoped(int code) {
                setResult(code);
                closeActivity();
            }
        };

        fragment.setOnFragmentPopListener(onFragmentPopListener);
        getSupportFragmentManager().beginTransaction()
                .replace(R.id.content, fragment)
                .addToBackStack(fragment.getClass().getSimpleName())
                .commit();

        fragment.setFragmentRefreshListener(new FragmentRefreshListener() {
            @Override
            public void onFragmentRefreshed() {
                restoreActionBar();
            }
        });

        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setHomeButtonEnabled(true);
            actionBar.setDisplayHomeAsUpEnabled(true);
            Drawable upArrow = CContext.getDrawable(this, R.drawable.abc_ic_ab_back_material);
            upArrow.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_ATOP);
            actionBar.setHomeAsUpIndicator(upArrow);
        }
        restoreActionBar();

        if (AppInfo.PRODUCT_ACTIVITY_ANIMATION > 0) {
            overridePendingTransition(R.anim.slide_in, R.anim.slide_out);
        }

        if (MultiVendorConfig.shouldShowLocation() || AppInfo.SHOW_PRODUCTS_BOOKING_INFO)
            mGoogleApiHelper = new GoogleApiHelper(this);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_empty, menu);
        for (int i = 0; i < AppInfo.PRODUCT_MENU_ITEMS.length; i++) {
            switch (AppInfo.PRODUCT_MENU_ITEMS[i] + Constants.ID_ACTION_MENU_HOME) {
                case Constants.ID_ACTION_MENU_HOME: {
                    MenuItem item = menu.findItem(Constants.ID_ACTION_MENU_HOME);
                    if (item == null) {
                        item = menu.add(0, Constants.ID_ACTION_MENU_HOME, 0,
                                getString(L.string.menu_title_home))
                                .setIcon(R.drawable.ic_vc_home);
                        item.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM);
                        Drawable menuIcon = item.getIcon();
                        menuIcon.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_IN);
                    }
                    break;
                }
                case Constants.ID_ACTION_MENU_CART: {
                    if (AppInfo.ENABLE_CART && GuestUserConfig.isEnableCart()) {
                        MenuItem item = menu.findItem(Constants.ID_ACTION_MENU_CART);
                        if (item == null) {
                            item = menu.add(0, Constants.ID_ACTION_MENU_CART, 0, getString(L.string.menu_title_cart));
                            item.setIcon(R.drawable.ic_vc_cart);
                            item.setActionView(R.layout.icon_badge_cart);
                            item.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM);
                        }
                        RelativeLayout actionView = (RelativeLayout) item.getActionView();
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
                    }
                    break;
                }
                case Constants.ID_ACTION_MENU_WISH: {
                    MenuItem item = menu.findItem(Constants.ID_ACTION_MENU_WISH);
                    if (item == null) {
                        item = menu.add(0, Constants.ID_ACTION_MENU_WISH, 0, getString(L.string.menu_title_wishlist));
                        item.setIcon(R.drawable.ic_vc_wish_flat);
                        item.setActionView(R.layout.icon_badge_wishlist);
                        item.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM);
                    }
                    RelativeLayout wishlistLayout = (RelativeLayout) item.getActionView();
                    txt_badgecount_wishlist = (TextView) wishlistLayout.findViewById(R.id.text_badge_count);
                    icon_badge_wishlist = (ImageView) wishlistLayout.findViewById(R.id.icon_badge);
                    Helper.stylizeBadgeView(icon_badge_wishlist, txt_badgecount_wishlist);
                    wishlistLayout.findViewById(R.id.main_icon).setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            openWishListFragment();
                        }
                    });
                    ImageView main_icon = (ImageView) wishlistLayout.findViewById(R.id.main_icon);
                    Helper.stylizeActionBar(main_icon);
                    break;
                }
                case Constants.ID_ACTION_MENU_SEARCH: {
                    MenuItem item = menu.findItem(Constants.ID_ACTION_MENU_SEARCH);
                    if (item == null) {
                        item = menu.add(0, Constants.ID_ACTION_MENU_SEARCH, 0, getString(L.string.menu_title_search));
                        item.setIcon(R.drawable.ic_vc_search);
                        item.setShowAsAction(MenuItem.SHOW_AS_ACTION_ALWAYS);
                    }
                    item.getIcon().setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_IN);
                    break;
                }
                case Constants.ID_ACTION_MENU_OPINION: {
                    if (AppInfo.ENABLE_OPINIONS) {
                        MenuItem item = menu.findItem(Constants.ID_ACTION_MENU_OPINION);
                        if (item == null) {
                            item = menu.add(0, Constants.ID_ACTION_MENU_OPINION, 0, getString(L.string.menu_title_opinion)).setIcon(R.drawable.ic_vc_opinion);
                            item.setActionView(R.layout.icon_badge_opinions);
                            item.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM);
                        }
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
                    }
                    break;
                }
                case Constants.ID_ACTION_MENU_CALL: {
                    MenuItem item = menu.findItem(Constants.ID_ACTION_MENU_CALL);

                    List<String> listContactNo = new ArrayList<>();
                    if (!AppInfo.homeMenuContactNumbers.isEmpty() && AppInfo.homeMenuContactNumbers.size() > 1) {
                        listContactNo = AppInfo.homeMenuContactNumbers;
//                    } else if (!AppInfo.mProductDetailsConfig.contact_numbers.isEmpty() && AppInfo.mProductDetailsConfig.contact_numbers.size() > 1){
//                        listContactNo = AppInfo.mProductDetailsConfig.contact_numbers;
                    }

                    if (item == null && !listContactNo.isEmpty()) {
                        item = menu.add(0, Constants.ID_ACTION_MENU_CALL, 0, getString(L.string.menu_title_call));
                        item.setIcon(R.drawable.ic_vc_call);
                        item.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM);
                        item.setOnMenuItemClickListener(new MenuItem.OnMenuItemClickListener() {
                            @Override
                            public boolean onMenuItemClick(MenuItem menuItem) {
                                List<String> listContactNo = new ArrayList<>();

                                if (!AppInfo.homeMenuContactNumbers.isEmpty() && AppInfo.homeMenuContactNumbers.size() > 1) {
                                    listContactNo = AppInfo.homeMenuContactNumbers;
//                                } else if (!AppInfo.mProductDetailsConfig.contact_numbers.isEmpty() && AppInfo.mProductDetailsConfig.contact_numbers.size() > 1){
//                                    listContactNo = AppInfo.mProductDetailsConfig.contact_numbers;
                                }
                                if (listContactNo.size() > 1) {
                                    Helper.openCallDialog(ProductDetailActivity.this, listContactNo);
                                } else {
                                    String phoneNumber = listContactNo.get(0);
                                    if (!phoneNumber.isEmpty()) {
                                        Helper.callTo(ProductDetailActivity.this, phoneNumber);
                                    }
                                }
                                return false;
                            }
                        });
                    }
                    item.getIcon().setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_IN);
                    break;
                }
            }
        }
        restoreActionBar();
        return true;
    }

    void openOpinionFragment() {
        if (onFragmentPopListener != null) {
            onFragmentPopListener.onFragmentPoped(OnFragmentPopListener.CODE_OPINIONS);
        }
    }

    void openWishListFragment() {
        if (onFragmentPopListener != null) {
            onFragmentPopListener.onFragmentPoped(OnFragmentPopListener.CODE_WISHLIST);
        }
    }

    void openSearchFragment() {
        if (onFragmentPopListener != null) {
            onFragmentPopListener.onFragmentPoped(OnFragmentPopListener.CODE_SEARCH);
        }
    }

    void openCartFragment() {
        if (onFragmentPopListener != null) {
            onFragmentPopListener.onFragmentPoped(OnFragmentPopListener.CODE_CART);
        }
    }

    void openHomeFragment() {
        if (onFragmentPopListener != null) {
            onFragmentPopListener.onFragmentPoped(OnFragmentPopListener.CODE_HOME);
        }
    }

    public void openReviewRatingList(TM_ProductInfo product, List<TM_ProductReview> productReviews) {
        getFM().beginTransaction()
                .replace(R.id.content, ReviewRatingListFragment.newInstance(product, productReviews))
                .addToBackStack(ReviewRatingListFragment.class.getSimpleName())
                .commit();
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                Fragment fragment = getSupportFragmentManager().findFragmentById(R.id.content);
                if (fragment instanceof ProductDetailPageFragment) {
                    closeActivity();
                } else {
                    getSupportFragmentManager().popBackStack();
                }
                return true;
            case Constants.ID_ACTION_MENU_HOME:
                openHomeFragment();
                return true;
            case Constants.ID_ACTION_MENU_CART:
                openCartFragment();
                return true;
            case Constants.ID_ACTION_MENU_WISH:
                openWishListFragment();
                return true;
            case Constants.ID_ACTION_MENU_OPINION:
                openOpinionFragment();
                return true;
            case Constants.ID_ACTION_MENU_SEARCH:
                openSearchFragment();
                return true;
            case Constants.ID_ACTION_MENU_DOWNLOADS:
                Helper.openDownloadsFolder(this);
                return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onBackPressed() {
        closeActivity();
    }

    private void closeActivity() {
        TMStoreApp app = (TMStoreApp) getApplication();
        for (Activity activity : app.getActivityList()) {
            if (activity instanceof ProductDetailActivity) {
                activity.finish();
            }
        }

        if (AppInfo.PRODUCT_ACTIVITY_ANIMATION > 0) {
            overridePendingTransition(R.anim.slide_out_reverse, R.anim.slide_in_reverse);
        }
    }

    @Override
    protected void onActionBarRestored() {
        updateBadgeCounts();
    }

    public void updateBadgeCounts() {
        if (AppInfo.ENABLE_CART && txt_badgecount_cart != null) {
            if (Cart.getItemCount() > 0) {
                txt_badgecount_cart.setText(String.valueOf(Cart.getItemCount()));
                icon_badge_cart.setVisibility(View.VISIBLE);
            } else {
                txt_badgecount_cart.setText("");
                icon_badge_cart.setVisibility(View.GONE);
            }
        }

        if (txt_badgecount_wishlist != null) {
            if (Wishlist.getItemCount() > 0) {
                txt_badgecount_wishlist.setText(String.valueOf(Wishlist.getItemCount()));
                icon_badge_wishlist.setVisibility(View.VISIBLE);
            } else {
                txt_badgecount_wishlist.setText("");
                icon_badge_wishlist.setVisibility(View.GONE);
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
    }

    @Override
    protected void onResume() {
        super.onResume();
        FreshChatConfig.onResume(this);
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

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String permissions[], @NonNull int[] grantResults) {
        if (grantResults.length > 0 && grantResults[0] == 0) {
            switch (requestCode) {
                case 0: {
                    fragment.getProductDetail().createOrFetchPoll();
                    break;
                }
                case 1: {
                    fragment.getProductDetail().shareProductWithFriends();
                    break;
                }
                case 2: {
                    fragment.getProductDetail().shareProductOnWhatsApp();
                    break;
                }
            }
        }
    }

    public static class ProductDetailPageFragment extends BaseFragment {

        private Fragment_ProductDetail fragment;

        public ProductDetailPageFragment() {
        }

        public static ProductDetailPageFragment newInstance(TM_ProductInfo product, int selected_variation_id, int selected_variation_index, boolean can_buy) {
            ProductDetailPageFragment fragment = new ProductDetailPageFragment();
            fragment.fragment = new Fragment_ProductDetail(product, selected_variation_id, selected_variation_index, can_buy);
            return fragment;
        }

        @Nullable
        @Override
        public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
            Helper.gc();
            View rootView = inflater.inflate(R.layout.fragment_product_info_page, container, false);
            return fragment.onCreateView(rootView, getActivity(), false);
        }

        @Override
        public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
            fragment.onViewCreated(view, savedInstanceState);
            super.onViewCreated(view, savedInstanceState);
        }

        @Override
        public void onStop() {
            Helper.gc();
            super.onStop();
        }

        public Fragment_ProductDetail getProductDetail() {
            return fragment;
        }

        public void setOnFragmentPopListener(OnFragmentPopListener onPopListener) {
            fragment.setOnFragmentPopListener(onPopListener);
        }

        public void setFragmentRefreshListener(FragmentRefreshListener fragmentRefreshListener) {
            fragment.setFragmentRefreshListener(fragmentRefreshListener);
        }

        @Override
        public void onDestroy() {
            super.onDestroy();
            if (AppInfo.SHOW_CART_FOOTER_OVERLAY) {
                Cart.setCartEventListener(null);
            }
        }
    }
}
