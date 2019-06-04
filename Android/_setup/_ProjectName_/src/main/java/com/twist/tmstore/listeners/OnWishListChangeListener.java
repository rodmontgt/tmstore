package com.twist.tmstore.listeners;

import android.view.View;
import android.widget.CompoundButton;

import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.entities.WishListGroup;
import com.twist.tmstore.entities.Wishlist;
import com.twist.tmstore.fragments.Fragment_Wishlist_Dialog;
import com.utils.Helper;

/**
 * Created by Twist Mobile on 24-Jun-16.
 */

public class OnWishListChangeListener implements CompoundButton.OnCheckedChangeListener {
    private TM_ProductInfo mProductInfo;

    private View mRootView;

    public OnWishListChangeListener(TM_ProductInfo productInfo, View rootView) {
        mProductInfo = productInfo;
        mRootView = rootView;
    }

    @Override
    public void onCheckedChanged(final CompoundButton buttonView, boolean isChecked) {
        try {
            if (isChecked) {
                Fragment_Wishlist_Dialog.OpenWishGroupDialog(mProductInfo, new WishListDialogHandler() {
                    @Override
                    public void onSelectGroupSuccess(TM_ProductInfo product, final WishListGroup obj) {
                        MainActivity.mActivity.showProgress(MainActivity.mActivity.getString(L.string.please_wait), false);
                        WishListGroup.addProductToWishList(obj.id, product.id, new DataQueryHandler() {
                            @Override
                            public void onSuccess(Object data) {
                                MainActivity.mActivity.hideProgress();
                                if (Wishlist.addProduct(mProductInfo, obj)) {
                                    if (mRootView != null) {
                                        Helper.toast(mRootView, Helper.showItemAddedToWishListToast(obj));
                                    } else {
                                        Helper.toast(Helper.showItemAddedToWishListToast(obj));
                                    }
                                } else {
                                    buttonView.setOnCheckedChangeListener(null);
                                    buttonView.setChecked(false);
                                    buttonView.setOnCheckedChangeListener(OnWishListChangeListener.this);
                                }
                            }

                            @Override
                            public void onFailure(Exception error) {
                            }
                        });
                    }

                    @Override
                    public void onSelectGroupFailed(String cause) {
                        buttonView.setOnCheckedChangeListener(null);
                        buttonView.setChecked(false);
                        buttonView.setOnCheckedChangeListener(OnWishListChangeListener.this);
                    }

                    @Override
                    public void onSkipDialog(TM_ProductInfo product, final WishListGroup obj) {
                        if (Wishlist.addProduct(mProductInfo, obj)) {
                            if (mRootView != null) {
                                Helper.toast(mRootView, Helper.showItemAddedToWishListToast(obj));
                            } else {
                                Helper.toast(Helper.showItemAddedToWishListToast(obj));
                            }
                        } else {
                            buttonView.setOnCheckedChangeListener(null);
                            buttonView.setChecked(false);
                            buttonView.setOnCheckedChangeListener(OnWishListChangeListener.this);
                        }
                    }
                });
            } else {
                Wishlist.removeProduct(mProductInfo);
//                if (mRootView != null) {
//                    Helper.toast(mRootView, L.string.item_removed_from_wishlist);
//                } else {
//                    Helper.toast(L.string.item_removed_from_wishlist);
//                }
            }

            if (MainActivity.mActivity != null) {
                MainActivity.mActivity.reloadMenu();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
