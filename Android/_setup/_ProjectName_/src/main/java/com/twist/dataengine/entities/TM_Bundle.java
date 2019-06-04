package com.twist.dataengine.entities;

public class TM_Bundle {

    public TM_ProductInfo getProduct() {
        return product;
    }

    public void setProduct(TM_ProductInfo product) {
        this.product = product;
    }

    public int getBundleQuantity() {
        return bundle_quantity;
    }

    public void setBundleQuantity(int bundle_quantity) {
        this.bundle_quantity = bundle_quantity;
    }

    public void setHideThumbnail(boolean hide_thumbnail) {
        this.hide_thumbnail = hide_thumbnail;
    }

    public void setOverrideTitle(boolean override_title) {
        this.override_title = override_title;
    }

    public void setOverrideDescription(boolean override_description) {
        this.override_description = override_description;
    }

    public void setOptional(boolean optional) {
        this.optional = optional;
    }

    public void setBundleDiscount(float bundle_discount) {
        this.bundle_discount = bundle_discount;
    }

    public void setVisibility(boolean visibility) {
        this.visibility = visibility;
    }

    private TM_ProductInfo product;
    private int bundle_quantity = 1;
    private float bundle_discount = 1;
    private boolean visibility = true;
    private boolean hide_thumbnail = false;
    private boolean override_title = false;
    private boolean override_description = false;
    private boolean optional = false;
}
