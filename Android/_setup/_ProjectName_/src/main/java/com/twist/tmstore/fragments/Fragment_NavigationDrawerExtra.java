package com.twist.tmstore.fragments;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;

import com.twist.dataengine.entities.SellerInfo;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.Constants;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.Adapter_NavigationDrawer;
import com.twist.tmstore.config.MultiVendorConfig;
import com.twist.tmstore.entities.NavDrawItem;
import com.twist.tmstore.listeners.NavigationDrawerCallbacks;
import com.utils.Helper;

import java.util.ArrayList;
import java.util.List;

public class Fragment_NavigationDrawerExtra extends BaseFragment {

    private NavigationDrawerCallbacks mCallbacks;

    private DrawerLayout mDrawerLayout;
    private RecyclerView mDrawerListView;
    View mDrawerView;
    private View mFragmentContainerView;

    List<NavDrawItem> drawerItems = new ArrayList<>();
    Adapter_NavigationDrawer mDrawerListAdapter;
    View userProfile;

    public Fragment_NavigationDrawerExtra() {
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        setHasOptionsMenu(true);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        mDrawerView = inflater.inflate(R.layout.fragment_navdrawer_extra, container, false);
        userProfile = mDrawerView.findViewById(R.id.user_profile);
        Helper.stylizeDynamically(userProfile);
        mDrawerListView = (RecyclerView) mDrawerView.findViewById(R.id.drawerListView);
        return mDrawerView;
    }

    private void setupDrawerComponents() {
        setTextOnView(mDrawerView, R.id.change_vendor, L.string.title_change_vendor);
        if (MultiVendorConfig.isEnabled()) {
            for (SellerInfo vendor : SellerInfo.getAllSellers()) {
                drawerItems.add(new NavDrawItem(Constants.MENU_ID_CHANGE_SELLER, vendor.getTitle()));
            }
        }
        mDrawerListAdapter = new Adapter_NavigationDrawer(getActivity(), drawerItems, new NavigationDrawerCallbacks() {
            @Override
            public void onNavigationDrawerItemSelected(int itemId, int position) {
                selectItem(itemId, position);
            }
        });
        mDrawerListView.setAdapter(mDrawerListAdapter);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
    }

    public void setUp(int fragmentId, DrawerLayout drawerLayout) {
        mFragmentContainerView = getActivity().findViewById(fragmentId);
        mDrawerLayout = drawerLayout;
        setupDrawerComponents();
    }

    private void selectItem(int id) {
        selectItem(id, -1);
    }

    private void selectItem(int id, int position) {
        if (mCallbacks != null) {
            mCallbacks.onNavigationDrawerItemSelected(id, position);
        }
        closeDrawer();
    }

    public void openDrawer() {
        if (mDrawerLayout != null) {
            getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    mDrawerLayout.openDrawer(mFragmentContainerView);
                }
            });
        }
    }

    public void closeDrawer() {
        if (mDrawerLayout != null) {
            getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    mDrawerLayout.closeDrawer(mFragmentContainerView);
                }
            });
        }
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        try {
            mCallbacks = (NavigationDrawerCallbacks) context;
        } catch (ClassCastException e) {
            throw new ClassCastException("Activity must implement NavigationDrawerCallbacks.");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mCallbacks = null;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case Constants.ID_ACTION_MENU_HOME:
                selectItem(Constants.MENU_ID_HOME);
                return true;
            case Constants.ID_ACTION_MENU_CART:
                selectItem(Constants.MENU_ID_CART);
                return true;
            case Constants.ID_ACTION_MENU_WISH:
                selectItem(Constants.MENU_ID_WISH);
                return true;
            case Constants.ID_ACTION_MENU_OPINION:
                selectItem(Constants.MENU_ID_OPINION);
                return true;
            case Constants.ID_ACTION_MENU_SEARCH:
                selectItem(Constants.MENU_ID_SEARCH);
                return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
