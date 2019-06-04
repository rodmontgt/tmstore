package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;

import com.twist.dataengine.entities.TM_CommonInfo;
import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.web.CCAvenueActivity;
import com.utils.JsonHelper;

import org.json.JSONObject;

public class CCAvenueGateway extends PaymentGateway {

    static CCAvenueGateway mGateway;

    public static CCAvenueGateway getInstance() {
        if (mGateway == null) {
            mGateway = new CCAvenueGateway();
        }
        return mGateway;
    }

    private CCAvenueGateway() {
        super();
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
            mGateway = CCAvenueGateway.getInstance();
            Intent intent = new Intent(activity, CCAvenueActivity.class);
            intent.putExtra("merchant_id", JsonHelper.getString(jsonObject, "merchant_id"));
            intent.putExtra("access_code", JsonHelper.getString(jsonObject, "access_code"));
            intent.putExtra("redirect_url", JsonHelper.getString(jsonObject, "redirect_url"));
            intent.putExtra("cancel_url", JsonHelper.getString(jsonObject, "cancel_url"));
            intent.putExtra("rsa_key_url", JsonHelper.getString(jsonObject, "rsa_key_url"));
            intent.putExtra("currency", TM_CommonInfo.currency);
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
