package com.twist.dataengine.entities;

import java.util.Calendar;
import java.util.Date;

/**
 * Created by Twist Mobile on 11/24/2017.
 */

public class BookingInfo {

    public Date start_date;
    public Date end_date;

    public String product;
    public boolean enable_addtocart = false;

    public Calendar[] fully_booked_days;
    public Calendar[] partially_booked_days;
    public Calendar[] buffer_days;

    public String result;
    public String error;
    public float booking_price;
    public String price_suffix;
    public int product_id_booking;
}