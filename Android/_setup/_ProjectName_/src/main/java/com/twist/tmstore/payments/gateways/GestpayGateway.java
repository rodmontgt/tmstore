package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;

import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.web.GestpayActivity;
import com.utils.JsonHelper;

import org.json.JSONObject;

/**
 * Created by Twist Mobile on 21-Mar-17.
 */
public class GestpayGateway extends PaymentGateway {

    private static GestpayGateway mGateway;

    public static GestpayGateway getInstance() {
        if (mGateway == null) {
            mGateway = new GestpayGateway();
        }
        return mGateway;
    }

    private GestpayGateway() {
        super();
    }

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
            mGateway = GestpayGateway.getInstance();
            Intent intent = new Intent(activity, GestpayActivity.class);
            intent.putExtra("payment_url", JsonHelper.getString(jsonObject, "payment_url"));
            intent.putExtra("shop_login", JsonHelper.getString(jsonObject, "shop_login"));
            intent.putExtra("shop_transaction_id", JsonHelper.getString(jsonObject, "shop_transaction_id"));
            mGateway.setEnabled(JsonHelper.getBool(jsonObject, "enabled"));
            mGateway.initialize(activity, intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}