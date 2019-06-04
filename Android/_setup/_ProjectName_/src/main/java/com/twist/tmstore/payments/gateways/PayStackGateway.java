package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;

import com.twist.dataengine.entities.TM_CommonInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.paystack.PayStackActivity;
import com.utils.JsonHelper;

import org.json.JSONObject;


public class PayStackGateway extends PaymentGateway {

    static PayStackGateway mGateway;

    public static PayStackGateway getInstance() {
        if (mGateway == null) {
            mGateway = new PayStackGateway();
        }
        return mGateway;
    }

    private PayStackGateway() {
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
            mGateway = PayStackGateway.getInstance();
            Intent intent = new Intent(activity, PayStackActivity.class);
            intent.putExtra("publicKey", jsonObject.getString("publicKey"));
            intent.putExtra("secretKey", jsonObject.getString("secretKey"));
            intent.putExtra("email", AppUser.getEmail());
            intent.putExtra("currency", TM_CommonInfo.currency);
            mGateway.setEnabled(JsonHelper.getBool(jsonObject, "enabled", true));
            mGateway.initialize(activity, intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
