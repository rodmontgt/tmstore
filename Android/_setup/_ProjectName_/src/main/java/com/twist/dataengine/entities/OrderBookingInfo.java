package com.twist.dataengine.entities;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 12/4/2017.
 */

public class OrderBookingInfo {

    public int order_id;
    public boolean enable_payment;

    public List<BookingInfoStatus> bookingStatusList = new ArrayList<>();

    public BookingInfoStatus getBookingInfoStatus(int id) {
        for (BookingInfoStatus bookingInfoStatus : bookingStatusList) {
            if (bookingInfoStatus.booking_id == id) {
                return bookingInfoStatus;
            }
        }
        return null;
    }

    public static class BookingInfoStatus {
        public int booking_id;
        public String booking_date;
        public String booking_start;
        public String booking_end;
        public String status;
    }
}
