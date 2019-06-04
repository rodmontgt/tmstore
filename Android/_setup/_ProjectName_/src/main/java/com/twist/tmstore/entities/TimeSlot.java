package com.twist.tmstore.entities;

import com.utils.Helper;

/**
 * Created by Twist Mobile on 12-12-2016.
 */

public class TimeSlot {
    private String  id;

    private String title;

    private String cost;

    private DateTimeSlot parent = null;

    public TimeSlot(String id) {
        this.id = id;
    }

    public TimeSlot(int id) {
        this.id = String.valueOf(id);
    }

    public String getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }


    public float getCost() {
        try {
            return Float.parseFloat(cost);
        } catch (Exception e) {
            return 0.0f;
        }
    }

    public void setCost(String cost) {
        this.cost = cost;
    }

    public DateTimeSlot getParent() {
        return parent;
    }

    public void setParent(DateTimeSlot parent) {
        this.parent = parent;
    }

    @Override
    public String toString() {
        if (getCost() > 0) {
            return title + " <b>(+" + Helper.appendCurrency(cost) + ")</b>";
        }
        return title;
    }
}
