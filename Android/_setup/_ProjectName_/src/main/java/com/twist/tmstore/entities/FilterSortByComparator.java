package com.twist.tmstore.entities;

import com.twist.dataengine.entities.TM_ProductInfo;

import java.util.Comparator;

/**
 * Created by Twist Mobile on 03-11-2017.
 */

public class FilterSortByComparator implements Comparator {

    private FilterSortType key;

    public FilterSortByComparator(FilterSortType key) {
        this.key = key;
    }

    @Override
    public int compare(Object o1, Object o2) {
        if (o1 != null && o2 != null) {
            try {
                TM_ProductInfo p1 = (TM_ProductInfo) o1;
                TM_ProductInfo p2 = (TM_ProductInfo) o2;
                switch (this.key) {
                    case PRICE_HIGH_TO_LOW:
                        return (int) (p2.getActualPrice() - p1.getActualPrice());
                    case PRICE_LOW_TO_HIGH:
                        return (int) (p1.getActualPrice() - p2.getActualPrice());
                    case POPULARITY:
                        return p2.total_sales - p1.total_sales;
                    case USER_RATING:
                        return (int) (p2.average_rating - p1.average_rating);
//                case DISCOUNT:
//                    return (int) (p2.discount - p1.discount);
                    case FRESH_ARRIVALS:
                        return p2.created_at.compareTo(p1.created_at);
                    default:
                        return p2.created_at.compareTo(p1.created_at);
                }
            } catch (Exception ignored) {
            }
        }
        return 0;
    }
}
