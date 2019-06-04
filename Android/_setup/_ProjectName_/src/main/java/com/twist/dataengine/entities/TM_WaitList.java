package com.twist.dataengine.entities;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 26-Jul-16.
 */

public class TM_WaitList {

    private static List<Integer> productIds;

    public static void addProductId(Integer id) {
        if (productIds == null) {
            productIds = new ArrayList<>();
        }

        if (!productIds.contains(id)) {
            productIds.add(id);
        }
    }

    public static void removeProductId(Integer id) {
        if (productIds != null && productIds.contains(id)) {
            productIds.remove(id);
        }
    }

    public static boolean hasProductId(int id) {
        return productIds != null && productIds.contains(id);
    }

    public static void clearAllProductIds() {
        if (productIds != null) {
            productIds.clear();
        }
    }
}
