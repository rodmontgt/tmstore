package com.twist.tmstore.entities;

/**
 * Created by Twist Mobile on 8/3/2016.
 */

public class AppliedCoupon {
    public float discount_amount;
    public float tax_amounts;
    public String title;

    public AppliedCoupon(String title) {
        this.title = title;
    }
}
