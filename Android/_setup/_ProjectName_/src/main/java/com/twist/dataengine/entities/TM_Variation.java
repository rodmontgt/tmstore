package com.twist.dataengine.entities;

import com.twist.dataengine.DataEngine;
import com.utils.DataHelper;
import com.utils.StringUtils;

import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;

public class TM_Variation {

    public int index;

    public int id;
    public int stock_quantity;
    public int download_limit;
    public int download_expiry;

    public String created_at;
    public String updated_at;
    public String permalink;
    public String sku;
    public String tax_status;
    public String tax_class;
    public float weight;
    public String shipping_class;
    public String shipping_class_id;

    public float price;
    public float price_clone;
    public float regular_price;
    public float regular_price_clone;
    public float sale_price;
    public float sale_price_clone;

    public boolean downloadable;
    public boolean virtual;
    public boolean taxable;
    public boolean managing_stock;
    public boolean in_stock;

    public boolean backorders_allowed;
    public boolean backordered;
    public boolean purchaseable;
    public boolean visible;
    public boolean on_sale;

    public TM_Dimension dimensions;
    public List<TM_ProductImage> images = new ArrayList<>();
    public List<TM_VariationAttribute> attributes = new ArrayList<>();
    public String[] downloads;
    private int rewardPoints = -1;


    public TM_Variation() {

    }

    public TM_Variation(TM_Variation other) {
        this.id = other.id;
        this.stock_quantity = other.stock_quantity;
        this.download_limit = other.download_limit;
        this.download_expiry = other.download_expiry;

        this.created_at = other.created_at;
        this.updated_at = other.updated_at;
        this.permalink = other.permalink;
        this.sku = other.sku;
        this.tax_status = other.tax_status;
        this.tax_class = other.tax_class;
        this.weight = other.weight;
        this.shipping_class = other.shipping_class;
        this.shipping_class_id = other.shipping_class_id;

        this.price = other.price;
        this.regular_price = other.regular_price;
        this.sale_price = other.sale_price;

        this.downloadable = other.downloadable;
        this.virtual = other.virtual;
        this.taxable = other.taxable;
        this.managing_stock = other.managing_stock;
        this.in_stock = other.in_stock;
        this.backorders_allowed = other.backorders_allowed;
        this.backordered = other.backordered;
        this.purchaseable = other.purchaseable;
        this.visible = other.visible;
        this.on_sale = other.on_sale;

        this.dimensions = other.dimensions;
        this.images = (ArrayList) ((ArrayList) other.images).clone();

        for (TM_VariationAttribute attribute : other.attributes) {
            this.attributes.add(attribute.clone());
        }

        if (other.downloads != null) {
            this.downloads = other.downloads.clone();
        }
        this.rewardPoints = other.rewardPoints;
    }

    public String[] getImageUrls() {
        String[] array = new String[images.size()];
        for (int i = 0; i < images.size(); i++) {
            array[i] = images.get(i).src;
        }
        return array;
    }

    public TM_VariationAttribute getWithName(String name) {
        for (TM_VariationAttribute attribute : this.attributes) {
            if (DataHelper.compareAttributeStrings(attribute.name, name)) {
                return attribute;
            }
        }
        return null;
    }

    public TM_VariationAttribute getWithName(List<TM_VariationAttribute> listAttributes, String name) {
        for (TM_VariationAttribute attribute : listAttributes) {
            String attributeSlug = DataHelper.toSlug(attribute.name);
            if (DataHelper.compareAttributeStrings(attributeSlug, name)) {
                return attribute;
            }
        }
        return null;
    }

    public boolean equals(TM_Variation other) {
        if (this.attributes == null && other.attributes == null) return true;
        if (this.attributes != null && other.attributes != null) {
            if (this.attributes.size() == other.attributes.size()) {
                for (TM_VariationAttribute li1Long : this.attributes) {
                    boolean isEqual = false;
                    for (TM_VariationAttribute li2Long : other.attributes) {
                        if (li1Long.equals(li2Long)) {
                            isEqual = true;
                            break;
                        }
                    }
                    if (!isEqual) return false;
                }
            } else {
                return false;
            }
        } else {
            return false;
        }
        return true;
    }

    public boolean compareAttributes(List<TM_VariationAttribute> other_attributes) {
        if (this.attributes == null && other_attributes == null)
            return true;

        if (this.attributes != null && other_attributes != null) {
            boolean allAttributeMatches = true;
            for (TM_VariationAttribute availableVariationAttribute : this.attributes) {
                TM_VariationAttribute expectedVariationAttribute = getWithName(other_attributes, availableVariationAttribute.name);
                if (expectedVariationAttribute == null) {
                    continue;
                }

                if (!DataHelper.compareAttributeStrings(expectedVariationAttribute.value, availableVariationAttribute.value)) {
                    if (DataEngine.auto_generate_variations || !StringUtils.isNull(availableVariationAttribute.value)) {
                        allAttributeMatches = false;
                        break;
                    }
                }
            }
            return allAttributeMatches;
        } else {
            return false;
        }
    }

    public float getActualPrice() {
        return (sale_price > 0) ? sale_price : price;
    }

    public void setActualPrice(float newPrice) {
        if (sale_price > 0)
            sale_price = newPrice;
        else
            price = newPrice;
    }

    public String getAttributeString() {
        String str = "";
        for (TM_VariationAttribute attribute : this.attributes) {
            String attribName = attribute.name;
            String attribValue = attribute.value;
            if (DataHelper.normalizationRequired(attribName)) {
                attribName = DataHelper.normalizePercentages(attribName);
            }
            if (DataHelper.normalizationRequired(attribValue)) {
                attribValue = DataHelper.normalizePercentages(attribValue);
            }
            str += attribName + " : <strong>" + attribValue + "</strong> | ";
        }
        if (str.length() > 3) {
            str = str.substring(0, str.length() - 3);
        }
        return str;
    }

    public List<String> getAttributeStringList() {
        List<String> selected_attributes_array = new ArrayList<>();
        for (TM_VariationAttribute attribute : this.attributes) {
            String attribName = attribute.name;
            String attribValue = attribute.value;
            if (attribName.split("%").length > 3) {
                try {
                    attribName = java.net.URLDecoder.decode(attribName, "UTF-8");
                } catch (UnsupportedEncodingException e) {
                    e.printStackTrace();
                }
            }
            if (attribValue.split("%").length > 3) {
                try {
                    attribValue = java.net.URLDecoder.decode(attribValue, "UTF-8");
                } catch (UnsupportedEncodingException e) {
                    e.printStackTrace();
                }
            }
            selected_attributes_array.add(attribName + " : <strong>" + attribValue + "</strong>");
        }
        return selected_attributes_array;
    }

    public float getWeight() {
        return this.weight;
    }

    public boolean hasOptionForAttribute(String attribName, String option) {
        TM_VariationAttribute attribute = getWithName(attribName);
        if (attribute != null) {
            if (attribute.value == null || attribute.value.trim().equals("") || DataHelper.compareAttributeStrings(attribute.value, option)) {
                return true;
            }
        }
        return false;
    }

    public int getRewardPoints() {
        return rewardPoints;
    }

    public void setRewardPoints(int rewardPoints) {
        this.rewardPoints = rewardPoints;
    }

    public void clonePrice() {
        this.price_clone = this.price;
        this.regular_price_clone = this.regular_price;
        this.sale_price_clone = this.sale_price;
    }
}
