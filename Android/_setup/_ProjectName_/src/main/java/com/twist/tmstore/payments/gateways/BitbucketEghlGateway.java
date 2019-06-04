package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;
import com.twist.dataengine.entities.TM_CommonInfo;
import com.twist.tmstore.entities.Address;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.payments.PaymentActivity;
import com.twist.tmstore.payments.PaymentGateway;
import com.utils.JsonHelper;
import org.json.JSONObject;

/**
 * Created by Twist Mobile on 11/07/2017.
 */

public class BitbucketEghlGateway extends PaymentGateway {
    
    static BitbucketEghlGateway mGateway;
    
    public static BitbucketEghlGateway getInstance() {
        return mGateway == null
            ? (mGateway = new BitbucketEghlGateway())
            : mGateway;
    }
    
    private BitbucketEghlGateway() {
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
            mGateway = BitbucketEghlGateway.getInstance();
            Intent intent = new Intent(activity, PaymentActivity.class);
            intent.putExtra("baseurl", JsonHelper.getString(jsonObject, "baseurl"));
            intent.putExtra("merchant_name", JsonHelper.getString(jsonObject, "merchant_name"));
            intent.putExtra("password", JsonHelper.getString(jsonObject, "password"));
            intent.putExtra("service_id", JsonHelper.getString(jsonObject, "service_id"));
            intent.putExtra("transaction_type", JsonHelper.getString(jsonObject, "transaction_type"));
            intent.putExtra("payment_method", JsonHelper.getString(jsonObject, "payment_method"));
            
            AppUser appUser = AppUser.getInstance();
            Address billingAddress = AppUser.getBillingAddress();
            
            intent.putExtra("currency_code", TM_CommonInfo.currency);
            intent.putExtra("first_name", appUser.first_name);
            intent.putExtra("last_name", appUser.last_name);
            intent.putExtra("email", appUser.email);
            intent.putExtra("phone", billingAddress.phone);
            
            mGateway.setEnabled(JsonHelper.getBool(jsonObject, "enabled"));
            mGateway.initialize(activity, intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}