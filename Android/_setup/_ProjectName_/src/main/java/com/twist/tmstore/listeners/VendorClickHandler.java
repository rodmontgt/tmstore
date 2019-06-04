package com.twist.tmstore.listeners;


import com.twist.dataengine.entities.SellerInfo;

public interface VendorClickHandler {
    void onVendorSelected(SellerInfo seller);
}