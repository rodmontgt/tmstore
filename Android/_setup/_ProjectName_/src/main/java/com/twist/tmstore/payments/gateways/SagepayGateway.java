package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;

import com.twist.tmstore.entities.Address;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.web.SagepayActivity;
import com.utils.JsonHelper;

import org.json.JSONObject;

/**
 * Created by Twist Mobile on 10/25/2017.
 */

public class SagepayGateway extends PaymentGateway {

    static SagepayGateway mGateway;

    public static SagepayGateway getInstance() {
        return mGateway == null
                ? (mGateway = new SagepayGateway()) : mGateway;
    }

    private SagepayGateway() {
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
        this.launchIntent();
        return true;
    }

    public static void createGateway(Activity activity, JSONObject jsonObject) {
        try {
            mGateway = SagepayGateway.getInstance();
            Intent intent = new Intent(activity, SagepayActivity.class);

            intent.putExtra("baseurl", JsonHelper.getString(jsonObject, "baseurl"));
            intent.putExtra("surl", JsonHelper.getString(jsonObject, "surl"));
            intent.putExtra("furl", JsonHelper.getString(jsonObject, "furl"));
            intent.putExtra("title", JsonHelper.getString(jsonObject, "title"));

            AppUser appUser = AppUser.getInstance();
            intent.putExtra("first_name", appUser.first_name);
            intent.putExtra("last_name", appUser.last_name);
            intent.putExtra("email", appUser.email);
            intent.putExtra("user_id", String.valueOf(AppUser.getUserId()));

            Address billingAddress = AppUser.getBillingAddress();
            intent.putExtra("phone", billingAddress.phone);
            intent.putExtra("billingAddress1", billingAddress.address_1);
            intent.putExtra("billingAddress2", billingAddress.address_2);
            intent.putExtra("billingCity", billingAddress.city);
            intent.putExtra("billingState", billingAddress.state);
            intent.putExtra("billingZip", billingAddress.postcode);
            intent.putExtra("billingCountry", billingAddress.country);

            mGateway.setEnabled(JsonHelper.getBool(jsonObject, "enabled"));
            mGateway.initialize(activity, intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}