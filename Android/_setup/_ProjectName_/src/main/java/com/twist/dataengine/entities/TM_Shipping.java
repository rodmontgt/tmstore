package com.twist.dataengine.entities;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 8/20/2016.
 */

public class TM_Shipping {
    public String id = ""; //"free_shipping",
    public String label; //":"Free Shipping",
    public double cost; //":"0.00",
    public List<String> taxes = new ArrayList<>(); //":[],
    public List<TM_Shipping_Pickup_Location> locations = new ArrayList<>(); //":[],
    public String method_id; //":"free_shipping"
    public String description = "";
    public String etd = "";

    public static boolean SHIPPING_REQUIRED = true;

    public boolean isFree() {
        return method_id.equalsIgnoreCase("free_shipping");
    }

    @Override
    public String toString() {
        return this.label;
    }
}
