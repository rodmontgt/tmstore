package com.twist.tmstore.payments.gateways;

import android.os.Handler;

import com.twist.tmstore.payments.PaymentGateway;


public class DirectBankGateway extends PaymentGateway {

    private DirectBankGateway(PaymentListener paymentListener) {
        super(paymentListener);
    }

    public boolean isPrepaid() {
        return true;
    }

    public static DirectBankGateway create(PaymentListener paymentListener) {
        DirectBankGateway gateway = new DirectBankGateway(paymentListener);
        gateway.setEnabled(true);
        return gateway;
    }

    @Override
    public boolean open(int orderId, float amount) {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                getPaymentListener().onPaymentSucceed(0);
            }
        }, 500);
        return true;
    }
}
