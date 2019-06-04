package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;

import com.twist.dataengine.DataEngine;
import com.twist.tmstore.entities.Address;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.payments.PaymentActivity;
import com.twist.tmstore.payments.PaymentGateway;
import com.utils.JsonHelper;

import org.json.JSONObject;

public class RazorpayGateway extends PaymentGateway {

    private static RazorpayGateway mGateway;

    public static RazorpayGateway getInstance() {
        if (mGateway == null) {
            mGateway = new RazorpayGateway();
        }
        return mGateway;
    }

    private RazorpayGateway() {
        super();
    }

    @Override
    public boolean isPrepaid() {
        return true;
    }

    @Override
    public boolean open(int orderId, float amount) {
        getIntent().putExtra("order_id", orderId);
        getIntent().putExtra("amount", (int) (amount * 100));
        this.launchIntent();
        return true;
    }

    public static void createGateway(Activity activity, JSONObject jsonObject) {
        try {
            mGateway = RazorpayGateway.getInstance();
            Address address = AppUser.getBillingAddress();
            Intent intent = new Intent(activity, PaymentActivity.class);
            intent.putExtra("name", AppUser.getInstance().getDisplayName());
            intent.putExtra("email", AppUser.getEmail());
            intent.putExtra("contact", address.phone);
            intent.putExtra("merchant", DataEngine.baseURL);
            intent.putExtra("color", AppInfo.color_theme);
            mGateway.setEnabled(JsonHelper.getBool(jsonObject, "enabled", true));
            mGateway.initialize(activity, intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
