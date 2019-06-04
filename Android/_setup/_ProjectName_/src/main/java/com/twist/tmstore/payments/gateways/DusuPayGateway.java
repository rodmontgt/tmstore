package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;

import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.web.DusuPayActivity;
import com.utils.JsonHelper;

import org.json.JSONObject;

public class DusuPayGateway extends PaymentGateway {

    private static DusuPayGateway mGateway;

    @Override
    public boolean open(int orderId, float amount) {
        getIntent().putExtra("amount", amount);
        getIntent().putExtra("order_id", orderId);
        getIntent().putExtra("name", AppUser.getInstance().getDisplayName());
        this.launchIntent();
        return true;
    }

    public static DusuPayGateway getInstance() {
        if (mGateway == null) {
            mGateway = new DusuPayGateway();
        }
        return mGateway;
    }

    private DusuPayGateway() {
        super();
    }

    public static void createGateway(Activity activity, JSONObject jsonObject) {
        try {
            mGateway = DusuPayGateway.getInstance();
            Intent intent = new Intent(activity, DusuPayActivity.class);
            intent.putExtra("merchant_id", JsonHelper.getString(jsonObject, "merchant_id"));
            intent.putExtra("surl", JsonHelper.getString(jsonObject, "success_url"));
            intent.putExtra("redirect_url", JsonHelper.getString(jsonObject, "redirect_url"));
            intent.putExtra("isDefault", JsonHelper.getBool(jsonObject, "default_gateway"));
            intent.putExtra("isSandbox", JsonHelper.getBool(jsonObject, "sandbox_mode"));
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
