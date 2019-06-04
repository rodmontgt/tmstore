package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;

import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.web.MyGateActivity;
import com.utils.JsonHelper;

import org.json.JSONException;
import org.json.JSONObject;

public class MyGateGateway extends PaymentGateway {

    static MyGateGateway mMyGateGateway;

    public static MyGateGateway getInstance() {
        if (mMyGateGateway == null) {
            mMyGateGateway = new MyGateGateway();
        }
        return mMyGateGateway;
    }

    private MyGateGateway() {
        super();
    }

    @Override
    public boolean isPrepaid() {
        return true;
    }

    @Override
    public boolean open(int orderId, float amount) {
        getIntent().putExtra("amount", String.valueOf(amount));
        this.launchIntent();
        return true;
    }

    public static void createGateway(Activity activity, JSONObject jsonObject) {
        try {
            mMyGateGateway = MyGateGateway.getInstance();
            Intent intent = new Intent(activity, MyGateActivity.class);
            intent.putExtra("baseurl", JsonHelper.getString(jsonObject, "baseurl"));
            intent.putExtra("surl", JsonHelper.getString(jsonObject, "surl"));
            intent.putExtra("furl", JsonHelper.getString(jsonObject, "furl"));
            mMyGateGateway.setEnabled(true);
            mMyGateGateway.initialize(activity, intent);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
}