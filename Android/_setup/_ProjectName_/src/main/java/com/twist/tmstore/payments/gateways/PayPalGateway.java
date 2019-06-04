package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;

import com.twist.dataengine.entities.TM_CommonInfo;
import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.paypal.PayPalActivity;
import com.utils.JsonHelper;

import org.json.JSONObject;


public class PayPalGateway extends PaymentGateway {

    static PayPalGateway mPayPalGateway;

    public static PayPalGateway getInstance() {
        if (mPayPalGateway == null) {
            mPayPalGateway = new PayPalGateway();
        }
        return mPayPalGateway;
    }

    private PayPalGateway() {
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
            mPayPalGateway = PayPalGateway.getInstance();
            Intent intent = new Intent(activity, PayPalActivity.class);
            intent.putExtra("currency", TM_CommonInfo.currency);
            intent.putExtra("merchant_id", JsonHelper.getString(jsonObject, "merchant_id"));
            intent.putExtra("enableCreditCard", JsonHelper.getBool(jsonObject, "enableCreditCard"));
            mPayPalGateway.setEnabled(JsonHelper.getBool(jsonObject, "enabled"));
            mPayPalGateway.initialize(activity, intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
