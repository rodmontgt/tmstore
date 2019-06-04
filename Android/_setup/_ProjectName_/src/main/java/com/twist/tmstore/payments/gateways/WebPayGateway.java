package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;

import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.web.WebPayActivity;


public class WebPayGateway extends PaymentGateway {

    private static WebPayGateway mWebPayGateway;

    public static WebPayGateway getInstance() {
        if (mWebPayGateway == null) {
            mWebPayGateway = new WebPayGateway();
        }
        return mWebPayGateway;
    }

    private WebPayGateway() {
        super();
    }

    @Override
    public boolean isPrepaid() {
        return true;
    }

    @Override
    public boolean open(int orderId, float amount) {
        this.launchIntent();
        return true;
    }

    public void launch() {
        this.launchIntent();
    }

    public static WebPayGateway createGateway(Activity activity) {
        mWebPayGateway = WebPayGateway.getInstance();
        Intent intent = new Intent(activity, WebPayActivity.class);
        mWebPayGateway.setEnabled(true);
        mWebPayGateway.initialize(activity, intent);
        return mWebPayGateway;
    }
}