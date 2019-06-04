package com.twist.dataengine.entities;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 4/8/2016.
 */
public class TM_ProductFilter {

    public static List<TM_ProductFilter> getAll() {
        return allProductFilters;
    }

    public static void clearAll() {
        allProductFilters.clear();
    }

    private static List<TM_ProductFilter> allProductFilters = new ArrayList<>();

    private TM_ProductFilter() {
        register();
    }

    public static TM_ProductFilter getForCategory(int categoryId) {
        for (TM_ProductFilter filter : allProductFilters) {
            if (filter.categoryId == categoryId)
                return filter;
        }

        TM_ProductFilter productFilter = TM_ProductFilter.getWithCategoryId(categoryId);
        productFilter.maxPrice = Integer.MAX_VALUE;
        productFilter.minPrice = -1;
        productFilter.maxDiscount = Integer.MAX_VALUE;
        productFilter.minDiscount = -1;
        productFilter.register();
        return productFilter;
    }

    public static TM_ProductFilter getWithCategoryId(int categoryId) {
        if (categoryId != -1) {
            for (TM_ProductFilter filter : allProductFilters) {
                if (filter.categoryId == categoryId)
                    return filter;
            }
        }
        TM_ProductFilter filter = new TM_ProductFilter();
        filter.categoryId = categoryId;
        return filter;
    }

    private void register() {
        allProductFilters.add(this);
    }

    public int categoryId = -1;
    public float minPrice;
    public float maxPrice;

    public float minDiscount;
    public float maxDiscount;

    private List<TM_FilterAttribute> attributes = new ArrayList<>();

    public List<TM_FilterAttribute> getAttributes() {
        return attributes;
    }

    public void addAttribute(TM_FilterAttribute attribute) {
        attributes.add(attribute);
    }

    public void clearAttribute() {
        attributes.clear();
    }

    public static boolean attribsLoaded = false;

}
