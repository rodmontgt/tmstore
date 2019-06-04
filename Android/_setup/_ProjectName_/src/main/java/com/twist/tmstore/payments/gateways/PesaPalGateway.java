package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;
import android.text.TextUtils;

import com.twist.tmstore.entities.Address;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.web.PesaPalActivity;
import com.utils.JsonHelper;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by Twist Mobile on 2/27/2017.
 */

public class PesaPalGateway extends PaymentGateway {

    static PesaPalGateway mPesaPalGateway;

    public static PesaPalGateway getInstance() {
        if (mPesaPalGateway == null)
            mPesaPalGateway = new PesaPalGateway();
        return mPesaPalGateway;
    }

    private PesaPalGateway() {
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

        // Check for required fields for payment gateway.
        Address billingAddress = AppUser.getBillingAddress();
        if (billingAddress == null
                || TextUtils.isEmpty(billingAddress.first_name)
                || TextUtils.isEmpty(billingAddress.last_name)
                || TextUtils.isEmpty(billingAddress.phone)
                || TextUtils.isEmpty(billingAddress.email)) {
            return false;
        }

        getIntent().putExtra("first_name", billingAddress.first_name);
        getIntent().putExtra("last_name", billingAddress.last_name);
        getIntent().putExtra("email", billingAddress.email);
        getIntent().putExtra("phonenumber", billingAddress.phone);
        getIntent().putExtra("description", "");

        this.launchIntent();
        return true;
    }

    public static void createGateway(Activity activity, JSONObject jsonObject) {
        try {
            mPesaPalGateway = PesaPalGateway.getInstance();
            Intent intent = new Intent(activity, PesaPalActivity.class);
            intent.putExtra("baseurl", JsonHelper.getString(jsonObject, "baseurl"));
            intent.putExtra("surl", JsonHelper.getString(jsonObject, "surl"));
            intent.putExtra("furl", JsonHelper.getString(jsonObject, "furl"));
            mPesaPalGateway.setEnabled(JsonHelper.getBool(jsonObject, "enabled"));
            mPesaPalGateway.initialize(activity, intent);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }
}
