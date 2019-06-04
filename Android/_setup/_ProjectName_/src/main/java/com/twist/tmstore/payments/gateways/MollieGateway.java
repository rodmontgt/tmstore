package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;

import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.web.MollieActivity;
import com.utils.JsonHelper;

import org.json.JSONObject;

/**
 * Created by Twist Mobile on 21-04-2017.
 */

public class MollieGateway extends PaymentGateway {

    static MollieGateway mGateway;

    public static MollieGateway getInstance() {
        if (mGateway == null) {
            mGateway = new MollieGateway();
        }
        return mGateway;
    }

    private MollieGateway() {
        super();
    }

    @Override
    public boolean open(int orderId, float amount) {
        getIntent().putExtra("orderid", String.valueOf(orderId));
        getIntent().putExtra("amount", String.valueOf(amount));
        this.launchIntent();
        return true;
    }

    public static void createGateway(Activity activity, JSONObject jsonObject) {
        try {
            mGateway = MollieGateway.getInstance();
            Intent intent = new Intent(activity, MollieActivity.class);
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
