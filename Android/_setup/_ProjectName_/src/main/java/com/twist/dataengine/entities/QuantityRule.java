package com.twist.dataengine.entities;

/**
 * Created by Twist Mobile on 06-Sep-16.
 */

public class QuantityRule {

    private boolean overrideRule = false;
    private int stepValue = 1;
    private int maxQuantity = 0;
    private int minQuantity = 0;
    private int minOutOfStock = 0;
    private int maxOutOfStock = 0;

    public int getStepValue() {
        return stepValue;
    }

    public void setStepValue(int stepValue) {
        this.stepValue = stepValue;
    }

    public int getMaxQuantity() {
        return maxQuantity;
    }

    public void setMaxQuantity(int maxQuantity) {
        this.maxQuantity = maxQuantity;
    }

    public int getMinQuantity() {
        return minQuantity;
    }

    public void setMinQuantity(int minQuantity) {
        this.minQuantity = minQuantity;
    }

    public int getMinOutOfStock() {
        return minOutOfStock;
    }

    public void setMinOutOfStock(int minOutOfStock) {
        this.minOutOfStock = minOutOfStock;
    }

    public int getMaxOutOfStock() {
        return maxOutOfStock;
    }

    public void setMaxOutOfStock(int maxOutOfStock) {
        this.maxOutOfStock = maxOutOfStock;
    }

    public boolean isOverrideRule() {
        return overrideRule;
    }

    public void setOverrideRule(boolean overrideRule) {
        this.overrideRule = overrideRule;
    }
}
