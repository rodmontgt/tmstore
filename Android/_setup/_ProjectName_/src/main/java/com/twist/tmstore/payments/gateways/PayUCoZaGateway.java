package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;

import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.payucoza.PayUCoZaActivity;
import com.utils.JsonHelper;

import org.json.JSONObject;


public class PayUCoZaGateway extends PaymentGateway {

    static PayUCoZaGateway mPayUCoZaGateway;

    public static PayUCoZaGateway getInstance() {
        if (mPayUCoZaGateway == null) {
            mPayUCoZaGateway = new PayUCoZaGateway();
        }
        return mPayUCoZaGateway;
    }

    private PayUCoZaGateway() {
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
        getIntent().putExtra("email", "" + AppUser.getEmail());
        this.launchIntent();
        return true;
    }

    public static void createGateway(Activity activity, JSONObject jsonObject) {
        try {
            mPayUCoZaGateway = PayUCoZaGateway.getInstance();
            Intent intent = new Intent(activity, PayUCoZaActivity.class);
            intent.putExtra("username", JsonHelper.getString(jsonObject, "UserName"));
            intent.putExtra("password", JsonHelper.getString(jsonObject, "Password"));
            intent.putExtra("sandbox_mode", JsonHelper.getString(jsonObject, "sandbox_mode"));
            intent.putExtra("safekey", JsonHelper.getString(jsonObject, "SafeKey"));
            intent.putExtra("surl", JsonHelper.getString(jsonObject, "surl"));
            intent.putExtra("furl", JsonHelper.getString(jsonObject, "furl"));
            mPayUCoZaGateway.setEnabled(JsonHelper.getBool(jsonObject, "enabled"));
            mPayUCoZaGateway.initialize(activity, intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
