package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;

import com.twist.tmstore.entities.Address;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.web.PayPalProActivity;
import com.utils.JsonHelper;

import org.json.JSONObject;


public class PayPalProGateway extends PaymentGateway {

    static PayPalProGateway mPayPalProGateway;

    public static PayPalProGateway getInstance() {
        if (mPayPalProGateway == null) {
            mPayPalProGateway = new PayPalProGateway();
        }
        return mPayPalProGateway;
    }

    private PayPalProGateway() {
        super();
    }

    @Override
    public boolean isPrepaid() {
        return true;
    }

    @Override
    public boolean open(int orderId, float amount) {
        getIntent().putExtra("amount", amount);
        getIntent().putExtra("order_id", String.valueOf(orderId));
        this.launchIntent();
        return true;
    }

    public static void createGateway(Activity activity, JSONObject jsonObject) {
        try {
            mPayPalProGateway = PayPalProGateway.getInstance();
            Intent intent = new Intent(activity, PayPalProActivity.class);

            AppUser appUser = AppUser.getInstance();
            Address address = appUser.billing_address;
            intent.putExtra("first_name", appUser.first_name);
            intent.putExtra("last_name", appUser.last_name);
            intent.putExtra("email", AppUser.getEmail());
            intent.putExtra("billingAddress1", address.address_1);
            intent.putExtra("billingAddress2", address.address_2);
            intent.putExtra("billingCity", address.city);
            intent.putExtra("billingState", address.state);
            intent.putExtra("billingZip", address.postcode);
            intent.putExtra("billingCountry", address.country);
            intent.putExtra("backendurl", JsonHelper.getString(jsonObject, "backendurl"));
            intent.putExtra("title", JsonHelper.getString(jsonObject, "title"));
            mPayPalProGateway.setEnabled(JsonHelper.getBool(jsonObject, "enabled"));
            mPayPalProGateway.initialize(activity, intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
