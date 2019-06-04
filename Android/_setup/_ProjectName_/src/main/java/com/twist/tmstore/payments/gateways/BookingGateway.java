package com.twist.tmstore.payments.gateways;

import android.os.Handler;

import com.twist.tmstore.payments.PaymentGateway;


public class BookingGateway extends PaymentGateway {

    private BookingGateway(PaymentListener paymentListener) {
        super(paymentListener);
    }

    public boolean isPrepaid() {
        return true;
    }

    public static BookingGateway create(PaymentListener paymentListener) {
        BookingGateway gateway = new BookingGateway(paymentListener);
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
        }, 100);
        return true;
    }
}
