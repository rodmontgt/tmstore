package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;

import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.web.BrainTreeActivity;
import com.utils.JsonHelper;

import org.json.JSONObject;


public class BrainTreeGateway extends PaymentGateway {

    static BrainTreeGateway mBrainTreeGateway;

    public static BrainTreeGateway getInstance() {
        if (mBrainTreeGateway == null) {
            mBrainTreeGateway = new BrainTreeGateway();
        }
        return mBrainTreeGateway;
    }

    private BrainTreeGateway() {
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
            mBrainTreeGateway = BrainTreeGateway.getInstance();
            Intent intent = new Intent(activity, BrainTreeActivity.class);
            intent.putExtra("baseurl", JsonHelper.getString(jsonObject, "baseurl"));
            intent.putExtra("surl", JsonHelper.getString(jsonObject, "surl"));
            intent.putExtra("furl", JsonHelper.getString(jsonObject, "furl"));
            mBrainTreeGateway.setEnabled(true);
            mBrainTreeGateway.initialize(activity, intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}