package com.twist.tmstore;

import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.SearchView;
import android.view.Menu;
import android.view.View;

import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.twist.dataengine.entities.SellerInfo;
import com.twist.tmstore.adapters.Adapter_ExpandableVendors;
import com.twist.tmstore.entities.Cart;
import com.twist.tmstore.entities.Wishlist;
import com.twist.tmstore.listeners.VendorClickHandler;
import com.utils.Helper;
import com.utils.Log;

import java.util.ArrayList;

public class VendorsActivity extends BaseActivity implements VendorClickHandler, SearchView.OnQueryTextListener {
    private View coordView;
    ProgressDialog progressDialog;
    SharedPreferences preferences;
    Adapter_ExpandableVendors adapter;
    RecyclerView list_vendors;
    String previousVendor;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        preferences = PreferenceManager.getDefaultSharedPreferences(VendorsActivity.this);

        try {
            previousVendor = preferences.getString("vendor", "");
        } catch (Exception e) {
            e.printStackTrace();
            previousVendor = null;
        }

        progressDialog = new ProgressDialog(this);

        setContentView(R.layout.activity_vendors);

        coordView = findViewById(R.id.activity_vendors);

        list_vendors = (RecyclerView) findViewById(R.id.list_vendors);
        adapter = new Adapter_ExpandableVendors(this, new ArrayList<>(SellerInfo.getAllExpandableSellers()), this);
        list_vendors.setAdapter(adapter);

        if (getIntent().getExtras() != null) {
            String requestedVendorId = getIntent().getExtras().getString("requestedVendorId", null);
            if (requestedVendorId != null) {
                list_vendors.setVisibility(View.GONE);
                onVendorSelected(SellerInfo.getSellerInfo(requestedVendorId));
            } else if (previousVendor != null) {
                list_vendors.setVisibility(View.GONE);
                onVendorSelected(SellerInfo.getSellerInfo(previousVendor));
            }
        } else {
            if (previousVendor != null) {
                list_vendors.setVisibility(View.GONE);
                onVendorSelected(SellerInfo.getSellerInfo(previousVendor));
            }
        }

        setTitleText(R.string.app_name);
        restoreActionBar();
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    @Override
    protected void onActionBarRestored() {
    }

    @Override
    public void onVendorSelected(SellerInfo vendor) {
        if (vendor == null) {
            list_vendors.setVisibility(View.VISIBLE);
            return;
        }

        if (SellerInfo.getSelectedSeller() != null && SellerInfo.getSelectedSeller().equals(vendor)) {
            startMainActivity();
        } else {
            Helper.cleanPreLoadedProducts();
            loadVendorsFrontPageContent(vendor);
            preferences.edit().putString("vendor", vendor.getId()).apply();
        }
    }

    void loadVendorsFrontPageContent(final SellerInfo vendor) {
        Log.d("-- loadVendorsFrontpageContent [" + vendor.getTitle() + "] --");
        showProgress(getString(L.string.loading_products), false);
        new Thread(new Runnable() {
            @Override
            public void run() {
                DataEngine.getDataEngine().getFrontPageContentInBackground(vendor.getId(), new DataQueryHandler() {
                    @Override
                    public void onSuccess(Object data) {
                        SellerInfo.setSelectedSeller(vendor);
                        hideProgress();
                        Cart.refresh();
                        Wishlist.refresh();
                        startMainActivity();
                    }

                    @Override
                    public void onFailure(Exception exception) {
                        hideProgress();
                        list_vendors.setVisibility(View.VISIBLE);
                        Helper.toast(coordView, getString(L.string.generic_error));
                    }
                });
            }
        }).start();
    }

    void startMainActivity() {
        final Intent intent = new Intent(this, MainActivity.class);
        final Bundle extras = getIntent().getExtras();
        if (extras != null) {
            intent.putExtras(extras);
        }
        startActivity(intent);
        finish();
    }

    public void showProgress(final String msg, final boolean isCancellable) {
        progressDialog.setMessage(msg);
        progressDialog.show();
        progressDialog.setCancelable(isCancellable);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_search, menu);
        {
            SearchView search = (SearchView) menu.findItem(R.id.menu_search).getActionView();
            search.setOnQueryTextListener(VendorsActivity.this);
        }
        return true;
    }

    @Override
    public void hideProgress() {
        progressDialog.dismiss();
    }

    @Override
    public boolean onQueryTextSubmit(String query) {
        return false;
    }

    @Override
    public boolean onQueryTextChange(String constraint) {
        final String[] keyWords = constraint.split(" ");
        adapter = new Adapter_ExpandableVendors(this, new ArrayList<>(SellerInfo.getAllExpandableSellers(keyWords)), this);
        list_vendors.setAdapter(adapter);
        return true;
    }
}
