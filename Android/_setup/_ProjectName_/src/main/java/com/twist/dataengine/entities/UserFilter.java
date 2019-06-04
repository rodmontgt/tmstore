package com.twist.dataengine.entities;

import java.util.ArrayList;
import java.util.List;

public class UserFilter {

    public UserFilter(String cat_slug, float minPrice, float maxPrice, List<TM_FilterAttribute> attributes, boolean chkStock) {
        this.cat_slug = cat_slug;
        this.minPrice = minPrice;
        this.maxPrice = maxPrice;
        this.chkStock = chkStock;
        this.attributes = attributes;
    }

    private float minPrice;
    private float maxPrice;
    public float taxApplied = 0.0f;
    public boolean chkStock = false;
    private List<TM_FilterAttribute> attributes;
    private String cat_slug;
    private int sort_type;
    private boolean filterModified = false;
    private boolean on_sale = false;
    private GeoLocation geoLocation;
    private int limit = 30;
    private int offset = 0;

    public int getLimit() {
        return limit;
    }

    public void setLimit(int limit) {
        this.limit = limit;
    }

    public int getOffset() {
        return offset;
    }

    public void setOffset(int offset) {
        this.offset = offset;
    }

    public boolean isFilterModified() {
        return filterModified;
    }

    public void setCheckSale(boolean on_sale) {
        this.on_sale = on_sale;
    }

    public void setMinPrice(float price) {
        this.minPrice = price;
    }

    public void setMaxPrice(float price) {
        this.maxPrice = price;
    }

    public void setSortOrder(int sort_type) {
        this.sort_type = sort_type;
    }

    public void addAttribute(TM_FilterAttribute attribute) {
        attributes.add(attribute);
    }

    public void addAttributeOption(TM_FilterAttribute attribute, TM_FilterAttributeOption option) {
        if (!attribute.hasOption(option)) {
            attribute.options.add(option);
        }
        this.filterModified = true;
    }

    public void removeAttributeOption(TM_FilterAttribute attribute, TM_FilterAttributeOption option) {
        attribute.removeOption(option);
        this.filterModified = true;
    }

    public void removeAttributes(List<TM_FilterAttribute> attributesToRemove) {
        attributes.removeAll(attributesToRemove);
    }

    public List<TM_FilterAttribute> getAttributes() {
        return attributes;
    }

    public float getMaxPrice() {
        return maxPrice;
    }

    public float getMinPrice() {
        return minPrice;
    }

    public boolean isChkStock() {
        return chkStock;
    }

    public boolean shouldCheckOnSale() {
        return on_sale;
    }

    public String getCatSlug() {
        return cat_slug;
    }

    public int getSortOrder() {
        return sort_type;
    }

    public TM_FilterAttribute getOrAddAttributeByNameOf(TM_FilterAttribute other) {
        if (attributes == null) {
            attributes = new ArrayList<>();
        }

        for (TM_FilterAttribute attribute : attributes) {
            if (attribute.attribute.equalsIgnoreCase(other.attribute))
                return attribute;
        }

        TM_FilterAttribute attribute = new TM_FilterAttribute();
        attribute.attribute = other.attribute;
        attribute.query_type = other.query_type;
        attributes.add(attribute);

        return attribute;
    }

    public TM_FilterAttribute getAttributeWithName(String name) {
        for (TM_FilterAttribute attribute : attributes) {
            if (attribute.attribute.equalsIgnoreCase(name))
                return attribute;
        }
        return null;
    }

    public String getFilterString() {
        String filterString = "";
        for (TM_FilterAttribute attribute : attributes) {
            for (TM_FilterAttributeOption option : attribute.options) {
                filterString += option.name + " | ";
            }
        }

        if (filterString.length() > 3) {
            filterString = filterString.substring(0, filterString.length() - 3);
        }

        return filterString;
    }

    public GeoLocation getGeoLocation() {
        return this.geoLocation;
    }

    public static class GeoLocation {
        public String unit = "";
        public String latitude = "";
        public String longitude = "";
        public String radius = "";
    }

    public GeoLocation createGeoLocation() {
        if (this.geoLocation == null) {
            this.geoLocation = new GeoLocation();
        }
        return this.geoLocation;
    }
}
