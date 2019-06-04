package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;

import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.web.PayTMActivity;
import com.utils.JsonHelper;

import org.json.JSONObject;

/**
 * Created by Twist Mobile on 21-04-2017.
 */

public class PayTMGateway extends PaymentGateway {

    static PayTMGateway mGateway;

    public static PayTMGateway getInstance() {
        if (mGateway == null) {
            mGateway = new PayTMGateway();
        }
        return mGateway;
    }

    private PayTMGateway() {
        super();
    }

    @Override
    public boolean open(int orderId, float amount) {
        String customer_id = AppUser.hasSignedIn() ? AppUser.getEmail() : AppInfo.dummyUser.email;
        getIntent().putExtra("orderid", String.valueOf(orderId));
        getIntent().putExtra("amount", String.valueOf(amount));
        getIntent().putExtra("customer_id", String.valueOf(customer_id));
        this.launchIntent();
        return true;
    }

    public static void createGateway(Activity activity, JSONObject jsonObject) {
        try {
            mGateway = PayTMGateway.getInstance();
            Intent intent = new Intent(activity, PayTMActivity.class);
            intent.putExtra("baseurl", JsonHelper.getString(jsonObject, "baseurl"));
            intent.putExtra("surl", JsonHelper.getString(jsonObject, "surl"));
            intent.putExtra("furl", JsonHelper.getString(jsonObject, "furl"));
            intent.putExtra("callback_url", JsonHelper.getString(jsonObject, "callback_url"));
            intent.putExtra("mid", JsonHelper.getString(jsonObject, "mid"));
            intent.putExtra("industry_type_id", JsonHelper.getString(jsonObject, "industry_type_id"));
            intent.putExtra("channel_id", JsonHelper.getString(jsonObject, "channel_id"));
            intent.putExtra("website_id", JsonHelper.getString(jsonObject, "website_id"));
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
