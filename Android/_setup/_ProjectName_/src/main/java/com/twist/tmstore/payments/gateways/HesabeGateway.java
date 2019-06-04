package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;

import com.twist.tmstore.entities.Address;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.web.HesabeActivity;
import com.utils.JsonHelper;

import org.json.JSONObject;

/**
 * Created by Twist Mobile on 11/21/2017.
 */

public class HesabeGateway extends PaymentGateway {

    static HesabeGateway mGateway;

    public static HesabeGateway getInstance() {
        return mGateway == null ? (mGateway = new HesabeGateway()) : mGateway;
    }

    private HesabeGateway() {
        super();
    }

    @Override
    public boolean isPrepaid() {
        return true;
    }

    @Override
    public boolean open(int orderId, float amount) {
        getIntent().putExtra("order_id", String.valueOf(orderId));
        getIntent().putExtra("amount", String.valueOf(amount));
        this.launchIntent();
        return true;
    }

    public static void createGateway(Activity activity, JSONObject jsonObject) {
        try {
            mGateway = HesabeGateway.getInstance();
            Intent intent = new Intent(activity, HesabeActivity.class);
            intent.putExtra("baseurl", JsonHelper.getString(jsonObject, "baseurl"));
            intent.putExtra("surl", JsonHelper.getString(jsonObject, "surl"));
            intent.putExtra("furl", JsonHelper.getString(jsonObject, "furl"));

            AppUser appUser = AppUser.getInstance();
            intent.putExtra("first_name", appUser.first_name);
            intent.putExtra("last_name", appUser.last_name);
            intent.putExtra("email", appUser.email);

            Address billingAddress = AppUser.getBillingAddress();
            intent.putExtra("phonenumber", billingAddress.phone);

            mGateway.setEnabled(JsonHelper.getBool(jsonObject, "enabled"));
            mGateway.initialize(activity, intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}