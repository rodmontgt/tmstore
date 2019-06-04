package com.twist.tmstore.fragments;

import android.app.Activity;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.os.Bundle;
import android.support.design.widget.TabLayout;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v7.app.ActionBar;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.View;
import android.view.ViewGroup;

import com.shopgun.android.materialcolorcreator.Shade;
import com.twist.dataengine.entities.SellerInfo;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.BuildConfig;
import com.twist.tmstore.Constants;
import com.twist.tmstore.Extras;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.TMStoreApp;
import com.twist.tmstore.config.MultiVendorConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.listeners.BackKeyListener;
import com.twist.tmstore.listeners.MyProfileItemClickListener;
import com.twist.tmstore.listeners.ViewPagerKeyListener;
import com.utils.Helper;

public class Fragment_SellerZone extends BaseFragment implements BackKeyListener {

    private static final int ITEM_SELLER_PROFILE = 0;
    private static final int ITEM_SELLER_PRODUCTS = 1;
    private static final int ITEM_SELLER_ORDERS = 2;
    private static final int ITEM_SELLER_SETTINGS = 3;
    private ViewPager mViewPager;
    private SellerInfo currentSeller;
    private SellerZonePagerAdapter mAdapter;
    private ViewPagerKeyListener mViewPagerKeyListener = new ViewPagerKeyListener() {
        @Override
        public boolean onKey(View v, int keyCode, KeyEvent event) {
            if (event.getAction() == KeyEvent.ACTION_DOWN && keyCode == KeyEvent.KEYCODE_BACK) {
                if (mViewPager.getCurrentItem() != 0) {
                    mViewPager.setCurrentItem(0);
                    return true;
                }
            }
            return false;
        }
    };

    public static Fragment_SellerZone newInstance() {
        Fragment_SellerZone fragment = new Fragment_SellerZone();
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (MultiVendorConfig.isSellerApp()) {
            setHasOptionsMenu(true);
            setActionBarHomeAsUpIndicator();
            getBaseActivity().restoreActionBar();
        }
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
        menu.clear();
        setActionBar();
    }

    public void setActionBar() {
        MainActivity.mActivity.resetDrawer();
        MainActivity.mActivity.closeDrawer();
        MainActivity.mActivity.lockDrawer();

        ActionBar actionBar = getSupportActionBar();
        actionBar.show();
        actionBar.setHomeButtonEnabled(false); // disable the button
        actionBar.setDisplayShowHomeEnabled(false); // remove the icon
        actionBar.setHomeAsUpIndicator(null); // remove the icon
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_vendor_screen, container, false);
        rootView.setFocusableInTouchMode(true);
        if (MultiVendorConfig.isSellerApp()) {
            addBackKeyListenerOnView(rootView, this);
        }

        currentSeller = SellerInfo.getSellerInfo(String.valueOf(AppUser.getUserId()));

        updateSellerInfo();

        int[] tabItems = MultiVendorConfig.getTabItems();
        String[] titles = new String[tabItems.length];
        for (int i = 0; i < tabItems.length; i++) {
            switch (tabItems[i]) {
                case MultiVendorConfig.TAB_PROFILE:
                    titles[i] = getString(L.string.title_seller_profile);
                    break;
                case MultiVendorConfig.TAB_PRODUCTS:
                    titles[i] = getString(L.string.title_seller_products);
                    break;
                case MultiVendorConfig.TAB_ORDERS:
                    titles[i] = getString(L.string.title_seller_orders);
                    break;
            }
        }

        mViewPager = (ViewPager) rootView.findViewById(R.id.seller_view_pager);
        mAdapter = new SellerZonePagerAdapter(getChildFragmentManager(), titles);
        mViewPager.setAdapter(mAdapter);

        TabLayout tabLayout = (TabLayout) rootView.findViewById(R.id.seller_tabs);
        tabLayout.setupWithViewPager(mViewPager);

        if (Helper.isLightColor(AppInfo.color_theme)) {
            tabLayout.setBackgroundColor(Color.parseColor(AppInfo.color_actionbar_text));
            tabLayout.setTabTextColors(ColorStateList.valueOf(Color.parseColor(AppInfo.color_theme)));
            tabLayout.setSelectedTabIndicatorColor(Helper.getColorShade(AppInfo.color_actionbar_text, Shade.Shade300));
        } else {
            tabLayout.setBackgroundColor(Color.parseColor(AppInfo.color_actionbar_text));
            tabLayout.setTabTextColors(ColorStateList.valueOf(Color.parseColor(AppInfo.color_theme)));
            tabLayout.setSelectedTabIndicatorColor(Color.parseColor(AppInfo.color_theme));
        }
        setTitle(getString(L.string.app_name));
        return rootView;
    }

    public void updateSellerInfo() {
        if (currentSeller == null) {
            currentSeller = SellerInfo.getCurrentSeller();
        } else {
            currentSeller = SellerInfo.getCurrentSeller();
        }
    }

    public void showStoreSettings() {
    }

    public void handleActivityResult(int requestCode, int resultCode, Intent data) {
        if (resultCode == Activity.RESULT_OK) {
            try {
                String childTag = getViewPagerTag(mViewPager);
                if (data != null && requestCode == Constants.REQUEST_UPLOAD_PRODUCT) {
                    Fragment fragment = findChildFragment(childTag);
                    if (fragment instanceof Fragment_SellerProducts) {
                        switch (data.getAction()) {
                            case Constants.ACTION_PRODUCT_DELETED: {
                                int productId = data.getIntExtra(Extras.PRODUCT_ID, -1);
                                ((Fragment_SellerProducts) fragment).removeProduct(productId);
                            }
                            break;

                            case Constants.ACTION_PRODUCT_UPDATED: {
                                int productId = data.getIntExtra(Extras.PRODUCT_ID, -1);
                                ((Fragment_SellerProducts) fragment).updateProduct(productId);
                            }
                            break;

                            case Constants.ACTION_PRODUCT_UPLOADED: {
                                ((Fragment_SellerProducts) fragment).loadProducts(true);
                            }
                            break;
                        }
                    } else if (fragment instanceof Fragment_SellerProfile) {
                        mViewPager.setCurrentItem(1, true);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    public void onBackPressed() {
        if (MultiVendorConfig.isSellerApp()) {
            Helper.getConfirmation(
                    getActivity(),
                    getString(L.string.exit_message),
                    false,
                    new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int id) {
                            TMStoreApp.exit(getActivity());
                        }
                    },
                    null);
        }
    }

    public class SellerZonePagerAdapter extends FragmentPagerAdapter {
        String[] titles;

        SellerZonePagerAdapter(android.support.v4.app.FragmentManager fm, String[] titles) {
            super(fm);
            this.titles = titles;
        }

        @Override
        public CharSequence getPageTitle(int position) {
            return titles[position];
        }

        @Override
        public int getCount() {
            return titles.length;
        }

        @Override
        public Fragment getItem(int position) {
            switch (position) {
                case ITEM_SELLER_PROFILE:
                    return Fragment_SellerProfile.newInstance(currentSeller, new SellerProfileItemClickListener());
                case ITEM_SELLER_PRODUCTS: {
                    Fragment_SellerProducts fragment = Fragment_SellerProducts.newInstance(currentSeller, false, true);
                    fragment.setViewPagerKeyListener(mViewPagerKeyListener);
                    return fragment;
                }
                case ITEM_SELLER_ORDERS: {
                    Fragment_SellerOrders fragment = Fragment_SellerOrders.newInstance(currentSeller);
                    fragment.setViewPagerKeyListener(mViewPagerKeyListener);
                    return fragment;
                }
            }
            return null;
        }
    }

    private class SellerProfileItemClickListener implements MyProfileItemClickListener {
        @Override
        public void onMyProfileItemClick(int itemId, int position) {
            switch (itemId) {
                case Constants.MENU_ID_SELLER_PRODUCTS:
                    mViewPager.setCurrentItem(ITEM_SELLER_PRODUCTS);
                    break;
                case Constants.MENU_ID_SELLER_ORDERS:
                    mViewPager.setCurrentItem(ITEM_SELLER_ORDERS);
                    break;
                case Constants.MENU_ID_SELLER_UPLOAD_PRODUCT:
                    ((MainActivity) getActivity()).showUpdateProduct(-1);
                    break;
                case Constants.MENU_ID_SELLER_STORE_SETTINGS:
                    showStoreSettings();
                    String tag = Fragment_SellerStoreSettings.class.getSimpleName();
                    getActivity().getSupportFragmentManager().beginTransaction()
                            .replace(R.id.content, Fragment_SellerStoreSettings.newInstance(currentSeller, true), tag)
                            .addToBackStack(tag)
                            .commit();
                    break;
                case Constants.MENU_ID_SIGN_OUT:
                    ((MainActivity) getActivity()).showSellerHomeFragment(true);
                    ((MainActivity) getActivity()).proceedSignOut();
                    break;
            }
        }
    }
}