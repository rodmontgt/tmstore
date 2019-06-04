package com.twist.tmstore.listeners;

import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.entities.WishListGroup;

public interface WishListDialogHandler {

    void onSelectGroupSuccess(TM_ProductInfo product, WishListGroup obj);
    void onSelectGroupFailed(String cause);
    void onSkipDialog(TM_ProductInfo product, WishListGroup obj);
}