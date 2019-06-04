package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;

import com.twist.dataengine.entities.TM_CommonInfo;
import com.twist.tmstore.R;
import com.twist.tmstore.entities.Address;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.web.SatispayActivity;
import com.utils.JsonHelper;

import org.json.JSONObject;

/**
 * Created by Twist Mobile on 21-Jul-17.
 */

public class SatispayGateway extends PaymentGateway {

    static SatispayGateway mGateway;

    public static SatispayGateway getInstance() {
        return mGateway == null
                ? (mGateway = new SatispayGateway()) : mGateway;
    }

    private SatispayGateway() {
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
            mGateway = SatispayGateway.getInstance();
            Intent intent = new Intent(activity, SatispayActivity.class);

            Address address = AppUser.getBillingAddress();
            intent.putExtra("phone_number", address.phone);
            intent.putExtra("currency", TM_CommonInfo.currency);
            intent.putExtra("description", activity.getString(R.string.app_name));
            intent.putExtra("app_id", JsonHelper.getString(jsonObject, "app_id"));
            intent.putExtra("security_bearer", JsonHelper.getString(jsonObject, "security_bearer"));
            intent.putExtra("redirect_url", JsonHelper.getString(jsonObject, "redirect_url"));
            intent.putExtra("enable_debugging", JsonHelper.getBool(jsonObject, "enable_debugging"));
            intent.putExtra("debug_user_id", JsonHelper.getString(jsonObject, "debug_user_id"));

            mGateway.setEnabled(JsonHelper.getBool(jsonObject, "enabled"));
            mGateway.initialize(activity, intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}