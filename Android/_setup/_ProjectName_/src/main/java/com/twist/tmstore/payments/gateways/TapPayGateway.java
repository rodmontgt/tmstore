package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;
import android.text.TextUtils;

import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.web.TapPayActivity;
import com.utils.JsonHelper;

import org.json.JSONObject;

public class TapPayGateway extends PaymentGateway {

    private static TapPayGateway mTapPayGateway;

    public static TapPayGateway getInstance() {
        if (mTapPayGateway == null) {
            mTapPayGateway = new TapPayGateway();
        }
        return mTapPayGateway;
    }

    private TapPayGateway() {
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

        // Check for required fields for payment gateway.
        if(AppUser.getBillingAddress() == null || TextUtils.isEmpty(AppUser.getBillingAddress().phone)) {
            return false;
        }

        if(TextUtils.isEmpty(AppUser.getInstance().first_name)) {
            return false;
        }

        if(TextUtils.isEmpty(AppUser.getInstance().email)) {
            return false;
        }

        getIntent().putExtra("first_name", AppUser.getInstance().first_name);
        getIntent().putExtra("email", AppUser.getInstance().email);
        getIntent().putExtra("phone_number", AppUser.getBillingAddress().phone);
        this.launchIntent();
        return true;
    }

    public static void createGateway(Activity activity, JSONObject jsonObject) {
        try {
            mTapPayGateway = TapPayGateway.getInstance();
            Intent intent = new Intent(activity, TapPayActivity.class);
            intent.putExtra("backendurl", JsonHelper.getString(jsonObject, "backendurl"));
            mTapPayGateway.setEnabled(JsonHelper.getBool(jsonObject, "enabled"));
            mTapPayGateway.initialize(activity, intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}