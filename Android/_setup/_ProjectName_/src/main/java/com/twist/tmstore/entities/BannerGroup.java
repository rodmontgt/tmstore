package com.twist.tmstore.entities;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 6/21/2016.
 */

public class BannerGroup extends HomeElement {
    public List<Banner> banners = new ArrayList<>();
    public BannerGroup() {
        type = 0;
    }
}
