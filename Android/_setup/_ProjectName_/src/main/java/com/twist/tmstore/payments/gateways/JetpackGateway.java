package com.twist.tmstore.payments.gateways;

import android.os.Handler;

import com.twist.tmstore.payments.PaymentGateway;


public class JetpackGateway extends PaymentGateway {

    private String instructions;

    public boolean isPrepaid() {
        return true;
    }

    private JetpackGateway(PaymentListener paymentListener) {
        super(paymentListener);
    }

    public static JetpackGateway create(PaymentListener paymentListener) {
        return new JetpackGateway(paymentListener);
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

    public String getInstructions() {
        return instructions;
    }

    public void setInstructions(String instructions) {
        this.instructions = instructions;
    }
}
