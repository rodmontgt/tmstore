package com.twist.tmstore.entities;

/**
 * Created by Twist Mobile on 03-11-2017.
 */

public enum FilterSortType {
    FRESH_ARRIVALS,
    FEATURED,
    DISCOUNT,
    USER_RATING,
    PRICE_HIGH_TO_LOW,
    PRICE_LOW_TO_HIGH,
    POPULARITY;

    @Override
    public String toString() {
        switch (ordinal()) {
            case 0:
            default:
                return "sort_fresh_arrival";
            case 1:
                return "sort_featured";
            case 2:
                return "sort_discount";
            case 3:
                return "sort_user_rating";
            case 4:
                return "sort_price_high_to_low";
            case 5:
                return "sort_price_low_to_high";
            case 6:
                return "sort_popularity";
        }
    }
}
