package com.twist.tmstore.entities;

/**
 * Created by Twist Mobile on 6/21/2016.
 */

public abstract class HomeElement {
    public int getType() {
        return type;
    }
    int type;
    public int margin_l;
    public int margin_t;
    public int margin_r;
    public int margin_b;
    public int padding_l;
    public int padding_t;
    public int padding_r;
    public int padding_b;
}
