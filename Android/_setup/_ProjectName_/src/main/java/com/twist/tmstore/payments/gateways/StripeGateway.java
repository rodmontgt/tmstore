package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;

import com.twist.dataengine.entities.TM_CommonInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.web.StripeActivity;
import com.utils.JsonHelper;

import org.json.JSONObject;

/**
 * Created by Twist Mobile on 02-Dec-16.
 */

public class StripeGateway extends PaymentGateway {

    static StripeGateway mStripeGateway;

    public static StripeGateway getInstance() {
        if (mStripeGateway == null) {
            mStripeGateway = new StripeGateway();
        }
        return mStripeGateway;
    }

    private StripeGateway() {
        super();
    }

    @Override
    public boolean isPrepaid() {
        return true;
    }

    @Override
    public boolean open(int orderId, float amount) {
        getIntent().putExtra("order_id", String.valueOf(orderId));
        getIntent().putExtra("amount", amount);
        this.launchIntent();
        return true;
    }

    public static void createGateway(Activity activity, JSONObject jsonObject) {
        try {
            mStripeGateway = StripeGateway.getInstance();
            Intent intent = new Intent(activity, StripeActivity.class);
            intent.putExtra("email", AppUser.getEmail());
            intent.putExtra("currency", TM_CommonInfo.currency);
            intent.putExtra("publishable_key", JsonHelper.getString(jsonObject, "publishable_key"));
            intent.putExtra("secret_key", JsonHelper.getString(jsonObject, "secret_key"));
            intent.putExtra("save_card_url", JsonHelper.getString(jsonObject, "backend_save_card_url"));
            mStripeGateway.setEnabled(JsonHelper.getBool(jsonObject, "enabled"));
            mStripeGateway.initialize(activity, intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}