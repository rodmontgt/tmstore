package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;

import com.twist.tmstore.entities.Address;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.web.PlugnPayActivity;
import com.utils.JsonHelper;

import org.json.JSONObject;

/**
 * Created by Twist Mobile on 5/26/2017.
 */

public class PlugnPayGateway extends PaymentGateway {

    static PlugnPayGateway mPlugnPayGateway;

    public static PlugnPayGateway getInstance() {
        if (mPlugnPayGateway == null) {
            mPlugnPayGateway = new PlugnPayGateway();
        }
        return mPlugnPayGateway;
    }

    private PlugnPayGateway() {
        super();
    }

    @Override
    public boolean isPrepaid() {
        return true;
    }

    @Override
    public boolean open(int orderId, float amount) {
        getIntent().putExtra("amount", String.valueOf(amount));
        getIntent().putExtra("orderid", String.valueOf(orderId));
        this.launchIntent();
        return true;
    }

    public static void createGateway(Activity activity, JSONObject jsonObject) {
        try {
            mPlugnPayGateway = PlugnPayGateway.getInstance();
            Intent intent = new Intent(activity, PlugnPayActivity.class);
            Address address =  AppUser.getBillingAddress();
            intent.putExtra("baseurl", JsonHelper.getString(jsonObject, "baseurl"));
            intent.putExtra("surl", JsonHelper.getString(jsonObject, "surl"));
            intent.putExtra("furl", JsonHelper.getString(jsonObject, "furl"));
            intent.putExtra("name", address.first_name + " " + address.last_name);
            intent.putExtra("email", address.email);
            intent.putExtra("phone", address.phone);
            intent.putExtra("description", "");
            mPlugnPayGateway.setEnabled(JsonHelper.getBool(jsonObject, "enabled"));
            mPlugnPayGateway.initialize(activity, intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
