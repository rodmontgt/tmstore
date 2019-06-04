package com.twist.tmstore.entities;

import com.twist.dataengine.entities.TM_ProductInfo;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 6/21/2016.
 */

public class TileGroupVertical extends HomeElement {
    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    String title;
    public List<TM_ProductInfo> products = new ArrayList<>();
    public TileGroupVertical() {
        type = 2;
    }
}
