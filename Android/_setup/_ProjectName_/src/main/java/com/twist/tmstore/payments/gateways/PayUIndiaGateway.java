package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;

import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.payments.PaymentGateway;
import com.utils.JsonHelper;

import org.json.JSONObject;

public class PayUIndiaGateway extends PaymentGateway {

    private static PayUIndiaGateway mGateway;

    public static PayUIndiaGateway getInstance() {
        if (mGateway == null)
            mGateway = new PayUIndiaGateway();
        return mGateway;
    }

    private PayUIndiaGateway() {
        super();
    }

    @Override
    public boolean isPrepaid() {
        return true;
    }

    @Override
    public boolean open(int orderId, float amount) {
        getIntent().putExtra("order_id", orderId);
        getIntent().putExtra("amount", amount);
        this.launchIntent();
        return true;
    }

    public static void createGateway(Activity activity, JSONObject jsonObject) {
        try {
            mGateway = PayUIndiaGateway.getInstance();
            String gateway = jsonObject.getString("gateway").toLowerCase();
            String className = "";
            if (gateway.equals("payumoney")) {
                className = "com.twist.tmstore.payments.web.PayUMoneyActivity";
            } else if (gateway.equals("payubiz")) {
                className = "com.twist.tmstore.payments.web.PayUbizActivity";
            }
            Intent intent = new Intent(activity, Class.forName(className));
            intent.putExtra("gateway", gateway);
            intent.putExtra("name", AppUser.getInstance().getDisplayName());
            intent.putExtra("email", AppUser.getEmail());
            intent.putExtra("phone", AppUser.getInstance().billing_address.phone);
            intent.putExtra("merchant_id", JsonHelper.getString(jsonObject, "merchant_id"));
            intent.putExtra("merchant_key", JsonHelper.getString(jsonObject, "merchant_key"));
            intent.putExtra("salt", JsonHelper.getString(jsonObject, "salt"));
            intent.putExtra("surl", JsonHelper.getString(jsonObject, "surl"));
            intent.putExtra("furl", JsonHelper.getString(jsonObject, "furl"));
            intent.putExtra("hurl", JsonHelper.getString(jsonObject, "hurl"));
            mGateway.setEnabled(JsonHelper.getBool(jsonObject, "enabled", true));
            mGateway.initialize(activity, intent);
        } catch (Exception e) {
            mGateway.setEnabled(false);
            e.printStackTrace();
        }
    }
}
