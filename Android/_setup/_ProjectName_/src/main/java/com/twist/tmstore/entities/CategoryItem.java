package com.twist.tmstore.entities;

/**
 * Created by Twist Mobile on 22-12-2016.
 */

public class CategoryItem {

    public static final int ID_TRENDING_ITEMS = -1;
    public static final int ID_BEST_DEALS = -2;
    public static final int ID_FRESH_ARRIVALS = -3;
    public static final int ID_RECENTLY_VIEWED = -4;

    public CategoryItem(int id, String title) {
        this.id = id;
        this.title = title;
    }

    public CategoryItem() {
    }

    public int id;
    public String title;
}
