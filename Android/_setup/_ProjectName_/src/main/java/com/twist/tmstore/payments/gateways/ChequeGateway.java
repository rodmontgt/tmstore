package com.twist.tmstore.payments.gateways;

import android.os.Handler;

import com.twist.tmstore.payments.PaymentGateway;


public class ChequeGateway extends PaymentGateway {

    private ChequeGateway(PaymentListener paymentListener) {
        super(paymentListener);
    }

    public boolean isPrepaid() {
        return true;
    }

    public static ChequeGateway create(PaymentListener paymentListener) {
        ChequeGateway gateway = new ChequeGateway(paymentListener);
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
