package com.twist.tmstore.fragments;

import android.app.Dialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;

import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.BaseDialogFragment;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.listeners.FragmentRefreshListener;
import com.twist.tmstore.listeners.OnFragmentPopListener;
import com.utils.Helper;

public class ProductDetailDialogFragment extends BaseDialogFragment {
    private Fragment_ProductDetail fragment;

    public static ProductDetailDialogFragment create(TM_ProductInfo product, int selected_variation_id, int selected_variation_index, boolean can_buy) {
        ProductDetailDialogFragment dialog = new ProductDetailDialogFragment();
        if (selected_variation_id != -1) {
            dialog.fragment = new Fragment_ProductDetail(product, selected_variation_id, selected_variation_index, can_buy);
        } else {
            dialog.fragment = new Fragment_ProductDetail(product);
            dialog.fragment.mCanBuy = true;
        }
        return dialog;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        Dialog dialog = this.getDialog();
        if (dialog != null) {
            Window window = dialog.getWindow();
            if (window != null) {
                window.requestFeature(Window.FEATURE_NO_TITLE);
            }
        }
        fragment.setOnFragmentPopListener(new OnFragmentPopListener() {
            @Override
            public void onFragmentPoped(int code) {
                if (code == OnFragmentPopListener.CODE_BUY || code == OnFragmentPopListener.CODE_SHOW) {
                    getDialog().dismiss();
                    MainActivity.mActivity.openCartFragment();
                }
            }
        });
        fragment.setFragmentRefreshListener(new FragmentRefreshListener() {
            @Override
            public void onFragmentRefreshed() {
                // refresh action bar items when items added into cart or wishlist
                MainActivity.mActivity.restoreActionBar();
            }
        });
        View rootView = inflater.inflate(R.layout.fragment_product_info_page, container, false);
        return fragment.onCreateView(rootView, getActivity(), true);
    }

    @SuppressWarnings("deprecation")
    @Override
    public void onStart() {
        Helper.gc();
        super.onStart();
    }

    @Override
    public void onStop() {
        Helper.gc();
        super.onStop();
    }

    @Override
    public void onDismiss(DialogInterface dialog) {
        super.onDismiss(dialog);
        // Refresh all adapters to reflect changes made in cart in dialog
        FragmentManager fm = getActivity().getSupportFragmentManager();
        Fragment fragment = fm.findFragmentById(R.id.content);
        if (fragment != null) {
            if (fragment instanceof Fragment_Home) {
                ((Fragment_Home) fragment).refreshAllAdapters();
            } else if (fragment instanceof CategoryFragment) {
                ((CategoryFragment) fragment).updateCartBadgeCount();
            }
        }
    }
}
