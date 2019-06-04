package com.twist.dataengine.entities;

import java.util.ArrayList;
import java.util.List;

public class TM_Order {
    public int id; //":73,
    public String order_number; //":"73",
    public String created_at; //":"2015-09-15T17:05:07Z",
    public String updated_at; //":"2015-09-15T17:05:08Z",
    public String completed_at; //":"2015-09-15T17:05:08Z",
    public String status;//":"processing",
    public String currency; //":"INR",
    public float total; //":"299.00",
    public String subtotal;//":"299.00",
    public int total_line_items_quantity;//":2,
    public float total_tax; //":"0.00",
    public float total_shipping; //":"0.00",
    public float cart_tax; //":"0.00",
    public float shipping_tax; //":"0.00",
    public float total_discount; //":"0.00",
    public String shipping_methods; //":"",
    public PaymentDetail payment_details;
    public TM_Address billing_address;
    public TM_Address shipping_address;
    public String note;
    public int customer_id; //":2,
    public String view_order_url;
    public List<TM_LineItem> line_items = new ArrayList<>();
    public List<String> shipping_lines;
    public List<String> tax_lines;
    public List<String> fee_lines;
    public List<String> coupon_lines;
    public List<String> trackingIds = new ArrayList<>();

    public String trackingId;
    public String provider;
    public String trackingURL = "";
    public int pointsEarned;
    public int pointsRedeemed;
    public String deliveryDate = "";
    public String deliveryTime = "";
    public String metaData = "";
    public String imgUploadUrl = "";

    public OrderBookingInfo orderBookingInfo;

    public void update(TM_Order other) {
        this.order_number = other.order_number;
        this.created_at = other.created_at; //":"2015-09-15T17:05:07Z",
        this.updated_at = other.updated_at; //":"2015-09-15T17:05:08Z",
        this.completed_at = other.completed_at; //":"2015-09-15T17:05:08Z",
        this.status = other.status;//":"processing",
        this.currency = other.currency; //":"INR",
        this.total = other.total; //":"299.00",
        this.subtotal = other.subtotal;//":"299.00",
        this.total_line_items_quantity = other.total_line_items_quantity;//":2,
        this.total_tax = other.total_tax; //":"0.00",
        this.total_shipping = other.total_shipping; //":"0.00",
        this.cart_tax = other.cart_tax; //":"0.00",
        this.shipping_tax = other.shipping_tax; //":"0.00",
        this.total_discount = other.total_discount; //":"0.00",
        this.shipping_methods = other.shipping_methods; //":"",
        this.payment_details = other.payment_details;
        this.billing_address = other.billing_address;
        this.shipping_address = other.shipping_address;
        this.note = other.note;
        this.customer_id = other.customer_id; //":2,
        this.view_order_url = other.view_order_url;
        this.line_items = other.line_items;
        this.shipping_lines = other.shipping_lines;
        this.tax_lines = other.tax_lines;
        this.fee_lines = other.fee_lines;
        this.coupon_lines = other.coupon_lines;
        this.orderBookingInfo = other.orderBookingInfo;
    }

    public int getPointsEarned() {
        return pointsEarned;
    }

    public void setPointsEarned(int pointsEarned) {
        this.pointsEarned = pointsEarned;
    }

    public int getPointsRedeemed() {
        return pointsRedeemed;
    }

    public void setPointsRedeemed(int pointsRedeemed) {
        this.pointsRedeemed = pointsRedeemed;
    }

}
