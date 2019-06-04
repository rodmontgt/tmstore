package com.twist.dataengine.entities;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 10/4/2016.
 */

public class TM_MixMatch {
    public List<TM_ProductInfo> getMatchingItems() {
        return new ArrayList<>(matchingItems);
    }

    public void addMatchingItems(TM_ProductInfo product) {
        this.matchingItems.add(product);
    }

    public int getMixMatchingItemPurchaseCount() {
        return mixMatchingItemPurchaseCount;
    }

    public void setMixMatchingItemPurchaseCount(int mixMatchingItemPurchaseCount) {
        this.mixMatchingItemPurchaseCount = mixMatchingItemPurchaseCount;
    }

    public int getMaxMatchingItemPurchaseCount() {
        return maxMatchingItemPurchaseCount;
    }

    public void setMaxMatchingItemPurchaseCount(int maxMatchingItemPurchaseCount) {
        this.maxMatchingItemPurchaseCount = maxMatchingItemPurchaseCount;
    }

    public boolean isPerProductPricing() {
        return per_product_pricing;
    }

    public void setPerProductPricing(boolean per_product_pricing) {
        this.per_product_pricing = per_product_pricing;
    }

    public boolean isPerProductShipping() {
        return per_product_shipping;
    }

    public void setPerProductShipping(boolean per_product_shipping) {
        this.per_product_shipping = per_product_shipping;
    }

    public boolean isSynced() {
        return is_synced;
    }

    public void setIsSynced(boolean is_synced) {
        this.is_synced = is_synced;
    }

    public float getMinPrice() {
        return min_price;
    }

    public void setMinPrice(float min_price) {
        this.min_price = min_price;
    }

    public float getMaxPrice() {
        return max_price;
    }

    public void setMaxPrice(float max_price) {
        this.max_price = max_price;
    }

    public float getBasePrice() {
        return base_price;
    }

    public void setBasePrice(float base_price) {
        this.base_price = base_price;
    }

    public float getBaseRegularPrice() {
        return base_regular_price;
    }

    public void setBaseRegularPrice(float base_regular_price) {
        this.base_regular_price = base_regular_price;
    }

    public float getBaseSalePrice() {
        return base_sale_price;
    }

    public void setBaseSalePrice(float base_sale_price) {
        this.base_sale_price = base_sale_price;
    }

    public float getContainerSize() {
        return container_size;
    }

    public void setContainerSize(float container_size) {
        this.container_size = container_size;
    }

    private List<TM_ProductInfo> matchingItems = new ArrayList<>();
    private int mixMatchingItemPurchaseCount;
    private int maxMatchingItemPurchaseCount;
    private boolean per_product_pricing = false;
    private boolean per_product_shipping = false;
    private boolean is_synced = false;
    private float min_price = 0;
    private float max_price = 0;
    private float base_price = 0;
    private float base_regular_price = 0;
    private float base_sale_price = 0;
    private float container_size = 0;
}
