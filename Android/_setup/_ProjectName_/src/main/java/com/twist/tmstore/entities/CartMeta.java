package com.twist.tmstore.entities;

/**
 * Created by Twist Mobile on 8/3/2016.
 */

public class CartMeta {

    public AppliedCoupon[] applied_coupons;

    public AppliedCoupon getAppliedCouponWithTitle(String title) {
        for (AppliedCoupon coupon : applied_coupons) {
            if (coupon.title.equals(title))
                return coupon;
        }
        return null;
    }

}
