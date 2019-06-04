package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;

import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.web.SenangPayActivity;
import com.utils.JsonHelper;

import org.json.JSONObject;

public class SenangPayGateway extends PaymentGateway {

    private static SenangPayGateway mGateway;

    @Override
    public boolean open(int orderId, float amount) {
        getIntent().putExtra("amount", "" + amount);
        getIntent().putExtra("orderid", "" + orderId);
        getIntent().putExtra("name", "");
        getIntent().putExtra("email", "");
        getIntent().putExtra("phonenumber", "");
        getIntent().putExtra("description", "");
        this.launchIntent();
        return true;
    }

    public static SenangPayGateway getInstance() {
        if (mGateway == null) {
            mGateway = new SenangPayGateway();
        }
        return mGateway;
    }

    private SenangPayGateway() {
        super();
    }

    public static void createGateway(Activity activity, JSONObject jsonObject) {
        try {
            mGateway = SenangPayGateway.getInstance();
            Intent intent = new Intent(activity, SenangPayActivity.class);
            intent.putExtra("baseurl", JsonHelper.getString(jsonObject, "baseurl"));
            intent.putExtra("surl", JsonHelper.getString(jsonObject, "surl"));
            intent.putExtra("furl", JsonHelper.getString(jsonObject, "furl"));
            mGateway.setEnabled(JsonHelper.getBool(jsonObject, "enabled"));
            mGateway.initialize(activity, intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public boolean isPrepaid() {
        return true;
    }
}
