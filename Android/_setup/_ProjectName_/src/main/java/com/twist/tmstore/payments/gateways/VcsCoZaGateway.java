package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;

import com.twist.dataengine.entities.TM_CommonInfo;
import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.web.VcsCoZaActivity;
import com.utils.JsonHelper;

import org.json.JSONObject;

/**
 * Created by Twist Mobile on 10-03-2017.
 */

public class VcsCoZaGateway extends PaymentGateway {

    private static VcsCoZaGateway mGateway;

    public static VcsCoZaGateway getInstance() {
        if (mGateway == null) {
            mGateway = new VcsCoZaGateway();
        }
        return mGateway;
    }

    private VcsCoZaGateway() {
        super();
    }

    public boolean isPrepaid() {
        return true;
    }

    @Override
    public boolean open(int orderId, float amount) {
        getIntent().putExtra("amount", String.valueOf(amount));
        getIntent().putExtra("currency", TM_CommonInfo.currency);
        this.launchIntent();
        return true;
    }

    public static void createGateway(Activity activity, JSONObject jsonObject) {
        try {
            mGateway = VcsCoZaGateway.getInstance();
            Intent intent = new Intent(activity, VcsCoZaActivity.class);
            intent.putExtra("description", JsonHelper.getString(jsonObject, "gateway"));
            intent.putExtra("merchant_id", JsonHelper.getString(jsonObject, "merchant_id"));
            mGateway.setEnabled(JsonHelper.getBool(jsonObject, "enabled"));
            mGateway.initialize(activity, intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
