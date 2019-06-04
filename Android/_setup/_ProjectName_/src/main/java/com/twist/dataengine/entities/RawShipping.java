package com.twist.dataengine.entities;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 09-02-2017.
 */

public class RawShipping {

    public String id;
    public String label;
    public boolean visible = true;
    public boolean variation = false;
    public float cost = 0;
    private static List<RawShipping> allShippingTypes = new ArrayList<>();

    @Override
    public String toString() {
        return label;
    }


    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public String getId() {

        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public RawShipping() {
        allShippingTypes.add(this);
    }

    public static List<RawShipping> getAll() {
        return allShippingTypes;
    }
    private static boolean _tempShippingLoaded = false;

    public static void setShippingLoaded() {
        _tempShippingLoaded = true;
    }

    public static boolean loadingCompleted() {
        return _tempShippingLoaded;
    }
}
