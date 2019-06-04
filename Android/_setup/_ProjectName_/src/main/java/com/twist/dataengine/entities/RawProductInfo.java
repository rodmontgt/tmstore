package com.twist.dataengine.entities;

import com.utils.DataHelper;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class RawProductInfo {

    public String wishlist_key = "";
    public String title;
    public int id = -1;
    public boolean downloadable;
    public boolean virtual;
    public String permalink;
    public String sku;
    public float price;
    public float price_min;
    public float price_max;
    public float regular_price;
    public float msrp_price;
    public float cost_of_good;
    public float discount;
    public float sale_price;
    public String price_html;
    public boolean taxable;
    public boolean in_stock;
    public boolean sold_individually;
    public boolean purchaseable;
    public boolean featured;
    public boolean visible;
    public boolean on_sale;
    public float weight;
    public String product_url;
    public boolean shipping_required;
    public boolean shipping_taxable;
    public String shipping_class;
    public String description = "N/A";
    public String short_description = "N/A";
    public boolean reviews_allowed;
    public float average_rating;
    public int rating_count;
    public List<Integer> related_ids = null;
    public List<Integer> upsell_ids = null;
    public List<Integer> cross_sell_ids = null;
    public int parent_id;
    public List<RawCategory> categories = new ArrayList<>();

    public List<String> tags = new ArrayList<>();

    public String thumb = "";
    private List<String> images = new ArrayList<>();
    public String featured_src;
    public List<TM_Attribute> attributes = new ArrayList<>();
    public String[] downloads;
    public int download_limit;
    public int download_expiry;
    public String download_type;
    public String purchase_note;
    public int total_sales;
    public TM_Variation_Set variations = new TM_Variation_Set();

    public Date created_at = new Date();
    public Date updated_at = new Date();

    public TM_ProductInfo.ProductType type = TM_ProductInfo.ProductType.SIMPLE;

    public int menu_order = 0;

    public boolean full_data_loaded = false;

    private int rewardPoints = -1;

    private String brandName = null;

    private String priceLabel = null;

    private QuantityRule quantityRules = null;

    public boolean isChecked = false;

    public boolean managing_stock = false;

    public int stock_quantity = 0;

    public enum Status {
        PENDING("pending"),
        DRAFT("draft"),
        PUBLISH("publish");

        public String value() {
            return name().toLowerCase();
        }

        private final String value;

        Status(String value) {
            this.value = value;
        }

        public String getValue() {
            return this.value;
        }

        public static Status from(String name) {
            if (name != null && !name.equals("")) {
                for (Status type : values()) {
                    if (type.getValue().toLowerCase().equalsIgnoreCase(name)) {
                        return type;
                    }
                }
            }
            return PENDING;
        }
    }

    public Status status = Status.PENDING;

    public TM_Attribute getAttributeWithName(String name) {
        for (TM_Attribute attribute : attributes) {
            String attributeSlug = DataHelper.toSlug(attribute.name);
            if (DataHelper.compareAttributeStrings(attributeSlug, name)) {
                return attribute;
            }
        }
        return null;
    }

    public void addAttribute(TM_Attribute attribute) {
        TM_Attribute attribute1 = this.getAttributeWithName(attribute.name);
        if (attribute1 == null) {
            attributes.add(attribute);
        } else {
            for (String option : attribute.options) {
                if (!attribute1.options.contains(option)) {
                    attribute1.options.add(option);
                }
            }
        }
    }

    public float getWeight(int variationId) {
        if (variationId < 0) {
            return getWeight();
        } else {
            TM_Variation variation = variations.getVariation(variationId);
            try {
                return variation.getWeight();
            } catch (Exception e) {
                e.printStackTrace();
                return 0;
            }
        }
    }

    public float getWeight() {
        return this.weight;
    }

    public float getActualPrice(int variationId) {
        if (variationId < 0) {
            return getActualPrice();
        } else {
            TM_Variation variation = variations.getVariation(variationId);
            try {
                float actual_price = variation.getActualPrice();
//                for(TM_VariationAttribute variationAttribute : variation.attributes) {
//                    TM_Attribute productAttribute = getAttributeWithName(variationAttribute.name);
//                    if(productAttribute != null) {
//                        float extra_price = productAttribute.getAdditionalPrice(variationAttribute.value);
//                        actual_price += extra_price;
//                    }
//                }
                return actual_price;
            } catch (Exception e) {
                e.printStackTrace();
                return 0;
            }
        }
    }

    public void setActualPrice(int variationId, float newPrice) {
        if (variationId < 0) {
            setActualPrice(newPrice);
        } else {
            TM_Variation variation = variations.getVariation(variationId);
            try {
                variation.setActualPrice(newPrice);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    public float getActualPrice() {
        return (sale_price > 0) ? sale_price : price;
    }

    public boolean hasPriceRange() {
        return price_min != price_max;
    }

    public void setActualPrice(float newPrice) {
        if (sale_price > 0)
            sale_price = newPrice;
        else
            price = newPrice;
    }


    public boolean containsTag(String tag) {
        if (this.title.toLowerCase().contains(tag))
            return true;
        if (this.sku.toLowerCase().contains(tag))
            return true;
        if (this.short_description.toLowerCase().contains(tag))
            return true;
        return false;
    }

    public boolean hasKeyWord(String tag) {
        if (this.title != null && this.title.toLowerCase().contains(tag))
            return true;
        if (this.sku != null && this.sku.toLowerCase().contains(tag))
            return true;
        if (this.short_description != null && this.short_description.toLowerCase().contains(tag))
            return true;
        //if (this.tags != null && this.tags.contains(tag))
        if (this.tags.contains(tag.toLowerCase()))
            return true;

        if (this.description != null && this.description.toLowerCase().contains(tag)) //this will kill the search.. seriously
            return true;

        return false;
    }

    public boolean hasKeyWords(String[] keywords) {
        for (String keyword : keywords) {
            if (!hasKeyWord(keyword)) {
                return false;
            }
        }
        return true;
    }

    public String getCategoryName() {
        return getCategoryName(0);
    }

    public String getCategoryName(int id) {
        String name = "";
        if (id < categories.size()) {
            String str = categories.get(id).getName();
            if (str != null) {
                name = str;
            }
        }
        return name;
    }

    public int getFirstCategoryId() {
        if (!categories.isEmpty())
            return categories.get(0).getId();
        return -1;
    }

    public RawCategory getFirstCategory() {
        if (!categories.isEmpty())
            return categories.get(0);
        return null;
    }

    public void putInCategories(List<RawCategory> categoriesToAssign) {
        for (RawCategory category : categoriesToAssign) {
            if (!isInCategory(category)) {
                this.categories.add(category);
            }
        }
    }

    public void putInCategory(int categoryId) {
        putInCategory(RawCategory.getWithId(categoryId));
    }

    public void putInCategory(RawCategory category) {
        if (!isInCategory(category)) {
            categories.add(category);
        }
    }

    public boolean isInCategory(RawCategory category) {
        for (RawCategory c : categories) {
            if (c.getId() == category.getId())
                return true;
        }
        return false;
    }

    public String getFirstValueOfAttrib(String key) {
        for (TM_Attribute attrib : attributes) {
            if (attrib.name.equalsIgnoreCase("key")) {
                return attrib.options.get(0);
            }
        }
        return "";
    }

    public String getFirstImageUrl() {
        if (hasAnyImage()) {
            return images.get(0);
        }
        return "";
    }

    private boolean hasImage(String img_url) {
        for (String image : images) {
            if (image.equalsIgnoreCase(img_url))
                return true;
        }
        return false;
    }

    public void addImages(List<String> urls) {
        images.addAll(urls);
    }

    public void addImages(String urls[]) {
        for (String url : urls)
            addImage(url);
    }

    public void addImage(String url) {
        images.add(url);
    }

    public void addImage(int index, String url) {
        images.add(index, url);
    }

//    private void addImage(TM_ProductImage image) {
//        if (!this.hasImage(image.src)) {
//            images.add(image);
//            generateThumb();
//        }
//    }

//    private void addImage(int index, TM_ProductImage image) {
//        if (!this.hasImage(image.src)) {
//            images.add(index, image);
//            generateThumb();
//        }
//    }

    public List<String> getImages() {
        return images;
    }

    public boolean hasThumb() {
        return !thumb.equals("");
    }

    public boolean hasAnyImage() {
        return !images.isEmpty();
    }

    public void removeAllImages() {
        images.clear();
    }

    public boolean hasAttributes() {
        return (attributes != null && !attributes.isEmpty());
    }

    public boolean hasVariations() {
        return (variations != null && !variations.isEmpty());
    }

    public int getVariationId(int index) {
        if (hasVariations() && index < variations.size()) {
            return variations.get(index).id;
        }
        return -1;
    }

    /*
    * Returns comma separated string of Variation ID's
    * */

    public String getVariationsIds() {
        String ids = "";
        if (hasVariations()) {
            int size = variations.size();
            for (int i = 0; i < size; i++) {
                ids += variations.get(i).id;
                ids += (i < size - 1) ? "," : "";
            }
        }
        return ids;
    }


    public void adjustVariations() {
        if (this.variations.isEmpty())
            return;
        List<TM_Variation> newVariationsToAdd = new ArrayList<>();
        List<TM_Variation> variationsToDelete = new ArrayList<>();

        for (TM_Variation variation : this.variations) {
            for (int attributeIndex = 0; attributeIndex < variation.attributes.size(); attributeIndex++) {
                TM_VariationAttribute attribute = variation.attributes.get(attributeIndex);
                if (attribute.value == null || attribute.value.length() == 0 || attribute.value.trim().equals("")) {
                    TM_Attribute productAttribute = this.getAttributeWithName(attribute.name);
                    if (productAttribute != null) {
                        //TODO - some magic here
                        for (String option : productAttribute.options) {
                            TM_Variation newVariation = new TM_Variation(variation);
                            newVariation.attributes.get(attributeIndex).value = option;
                            newVariationsToAdd.add(newVariation);
                        }
                        if (!variationsToDelete.contains(variation)) {
                            variationsToDelete.add(variation);
                        }
                    }
                }
            }
        }

        this.variations.addAll(newVariationsToAdd);
        this.variations.removeAll(variationsToDelete);

        if (!variationsToDelete.isEmpty()) {
            adjustVariations();
        }
    }

    public void reIndexVariations() {
        for (int index = 0; index < variations.size(); index++) {
            variations.get(index).index = index;
        }
    }


    public void adjustAttributes() {
        List<TM_Attribute> extraAttributes = new ArrayList<>();

        for (TM_Attribute attribute : this.attributes) {
            if (attribute.variation) { //if this attribute is used for variation or not
                List<String> extraOptions = new ArrayList<>();
                for (String option : attribute.options) {
                    boolean isAttributeUsedEver = false;
                    for (TM_Variation variation : this.variations) {
                        if (variation.hasOptionForAttribute(attribute.name, option)) {
                            isAttributeUsedEver = true;
                            break;
                        }
                    }
                    if (!isAttributeUsedEver) {
                        extraOptions.add(option);
                    }
                }
                attribute.options.removeAll(extraOptions);
            }
            //New Logic
            if (attribute.options.isEmpty()) {
                extraAttributes.add(attribute);
            }
        }

        this.attributes.removeAll(extraAttributes);
    }

    public int getRewardPoints(int variationId) {
        if (variationId < 0) {
            return rewardPoints;
        }

        TM_Variation variation = getVariation(variationId);
        if (variation != null) {
            return variation.getRewardPoints();
        }
        return 0;
    }

    public void setRewardPoints(int rewardPoints) {
        this.rewardPoints = rewardPoints;
    }

    public TM_Variation getVariation(int variationId) {
        return variations.getVariation(variationId);
    }

    public String getBrandName() {
        return brandName;
    }

    public void setBrandName(String brandName) {
        this.brandName = " " + brandName;
    }

    public String getPriceLabel() {
        return priceLabel;
    }

    public void setPriceLabel(String priceLabel) {
        this.priceLabel = " " + priceLabel;
    }

    public QuantityRule getQuantityRules() {
        return quantityRules;
    }

    public void setQuantityRules(QuantityRule quantityRules) {
        this.quantityRules = quantityRules;
    }
}
