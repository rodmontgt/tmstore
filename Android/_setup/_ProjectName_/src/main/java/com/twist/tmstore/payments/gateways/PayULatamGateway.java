package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;

import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.web.PayULatamActivity;
import com.utils.JsonHelper;

import org.json.JSONObject;


public class PayULatamGateway extends PaymentGateway {

    static PayULatamGateway mPayULatamGateway;

    public static PayULatamGateway getInstance() {
        if (mPayULatamGateway == null) {
            mPayULatamGateway = new PayULatamGateway();
        }
        return mPayULatamGateway;
    }

    private PayULatamGateway() {
        super();
    }

    @Override
    public boolean isPrepaid() {
        return true;
    }

    @Override
    public boolean open(int orderId, float amount) {
        getIntent().putExtra("orderid", String.valueOf(orderId));
        getIntent().putExtra("amount", String.valueOf(amount));
        getIntent().putExtra("email", AppUser.getEmail());
        this.launchIntent();
        return true;
    }

    public static void createGateway(Activity activity, JSONObject jsonObject) {
        try {
            mPayULatamGateway = PayULatamGateway.getInstance();
            Intent intent = new Intent(activity, PayULatamActivity.class);
            intent.putExtra("apikey", JsonHelper.getString(jsonObject, "apikey"));
            intent.putExtra("merchantid", JsonHelper.getString(jsonObject, "merchantid"));
            intent.putExtra("accountid", JsonHelper.getString(jsonObject, "accountid"));
            intent.putExtra("baseurl", JsonHelper.getString(jsonObject, "baseurl"));
            intent.putExtra("tax", JsonHelper.getString(jsonObject, "tax"));
            intent.putExtra("taxreturnbase", JsonHelper.getString(jsonObject, "taxreturnbase"));
            intent.putExtra("currency", JsonHelper.getString(jsonObject, "currency"));
            intent.putExtra("responseurl", JsonHelper.getString(jsonObject, "responseurl"));
            intent.putExtra("confirmationurl", JsonHelper.getString(jsonObject, "confirmationurl"));
            mPayULatamGateway.setEnabled(true);
            mPayULatamGateway.initialize(activity, intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}