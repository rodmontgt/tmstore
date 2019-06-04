package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;

import com.twist.tmstore.entities.Address;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.web.InstaMojoActivity;
import com.utils.JsonHelper;

import org.json.JSONObject;


public class InstaMojoGateway extends PaymentGateway {

    private static InstaMojoGateway mGateway;

    @Override
    public boolean open(int orderId, float amount) {
        getIntent().putExtra("amount", "" + amount);
        getIntent().putExtra("orderid", "" + orderId);
        this.launchIntent();
        return true;
    }

    public static InstaMojoGateway getInstance() {
        if (mGateway == null) {
            mGateway = new InstaMojoGateway();
        }
        return mGateway;
    }

    private InstaMojoGateway() {
        super();
    }

    public static void createGateway(Activity activity, JSONObject jsonObject) {
        try {
            mGateway = InstaMojoGateway.getInstance();
            Intent intent = new Intent(activity, InstaMojoActivity.class);
            intent.putExtra("baseurl", JsonHelper.getString(jsonObject, "baseurl"));
            intent.putExtra("surl", JsonHelper.getString(jsonObject, "surl"));
            intent.putExtra("furl", JsonHelper.getString(jsonObject, "furl"));

            Address billingAddress = AppUser.hasSignedIn()
                    ? AppUser.getInstance().billing_address
                    : AppInfo.dummyUser.billing_address;
            
            intent.putExtra("name", billingAddress.first_name);
            intent.putExtra("email", billingAddress.email);
            intent.putExtra("phone", billingAddress.phone);
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
