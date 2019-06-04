package com.twist.dataengine.entities;

/**
 * Created by Twist Mobile on 4/16/2016.
 */
public class TM_FilterAttributeOption {
    public String name;
    public String taxo;
    public String slug;

    public TM_FilterAttributeOption() {

    }

    public TM_FilterAttributeOption(TM_FilterAttributeOption other) {
        this.name = other.name;
        this.slug = other.slug;
        this.taxo = other.taxo;
    }
}
