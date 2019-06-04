package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;

import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.web.PayfortActivity;
import com.utils.JsonHelper;

import org.json.JSONObject;

/**
 * Created by Twist Mobile on 10/25/2017.
 */

public class PayfortGateway extends PaymentGateway {

    static PayfortGateway mGateway;

    public static PayfortGateway getInstance() {
        return mGateway == null ? (mGateway = new PayfortGateway()) : mGateway;
    }

    private PayfortGateway() {
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
            mGateway = PayfortGateway.getInstance();
            Intent intent = new Intent(activity, PayfortActivity.class);
            intent.putExtra("baseurl", JsonHelper.getString(jsonObject, "baseurl"));
            intent.putExtra("surl", JsonHelper.getString(jsonObject, "surl"));
            intent.putExtra("furl", JsonHelper.getString(jsonObject, "furl"));

            AppUser appUser = AppUser.getInstance();
            intent.putExtra("first_name", appUser.first_name);
            intent.putExtra("last_name", appUser.last_name);
            intent.putExtra("email", appUser.email);

            mGateway.setEnabled(JsonHelper.getBool(jsonObject, "enabled"));
            mGateway.initialize(activity, intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}