package com.twist.dataengine.entities;

import android.text.TextUtils;

import com.twist.dataengine.DataEngine;
import com.twist.tmstore.entities.DepositInfo;
import com.twist.tmstore.entities.ProductAddons;
import com.utils.DataHelper;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

public class TM_ProductInfo {
    public static final int ID_PROMO_BUTTON = 9999999;
    public static List<TM_ProductInfo> bestDealProductsIds = new ArrayList<>();
    public static List<TM_ProductInfo> freshArrivalProductsIds = new ArrayList<>();
    public static List<TM_ProductInfo> trendingProductsIds = new ArrayList<>();
    public static int totalProductsOnServerCount = -1;
    static TM_ProductInfo productInfo;// = new TM_ProductInfo();
    private static List<TM_ProductInfo> allProducts = new ArrayList<>();
    public String wishlist_key = "";
    public String title;
    public int id;
    public boolean downloadable;
    public boolean virtual;
    public String permalink;
    public String sku;
    public float price;
    public float price_clone;
    public float regular_price;
    public float regular_price_clone;
    public float sale_price;
    public float sale_price_clone;
    public float price_min;
    public float price_min_clone;
    public float price_max;
    public float price_max_clone;
    public String price_html;
    public float discount;
    public boolean taxable = false;
    public String taxClass = "";
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
    public boolean reviews_allowed;
    public float average_rating;
    public int rating_count;
    public List<Integer> related_ids = null;
    public List<Integer> upsell_ids = null;
    public List<Integer> cross_sell_ids = null;
    public int parent_id;

    public boolean managing_stock;
    public boolean backorders_allowed;
    public boolean backordered;

    public float priceOriginal;
    public float regular_priceOriginal;
    public float sale_priceOriginal;

    // public TM_CategoryInfo[] categories;
    public List<TM_CategoryInfo> categories = new ArrayList<>();

    //public int[] tags;
    public List<String> tags = new ArrayList<>();

    public String thumb = "";
    public String featured_src;
    public List<TM_Attribute> attributes = new ArrayList<>();
    public List<TM_Attribute> extraAttributes = new ArrayList<>();
    public int download_limit;
    public int download_expiry;
    public String download_type;
    public String purchase_note;
    public int total_sales;
    public TM_Variation_Set variations = new TM_Variation_Set();
    public Date created_at = new Date();
    public Date updated_at = new Date();
    public ProductType type = ProductType.SIMPLE;
    public int stockQty = 0;
    public int menu_order = 0;
    public int likes = 0;
    public int unlikes = 0;
    public String poll_id = "";
    public boolean has_poll = false;
    public boolean full_data_loaded = false;
    public boolean extra_attribs_loaded = false;
    public boolean isChecked = false;
    public TM_MixMatch mMixMatch = null;
    public List<TM_Bundle> mBundles = null;
    public TM_DeliveryInfo deliveryInfo;
    public AuctionInfo auctionInfo;
    public BookingInfo bookingInfo;
    public DepositInfo depositInfo;
    public ProductAddons productAddons;
    public ProductLocation productLocation;
    public String selectedDeliveryDate = "";
    public String selectedDeliveryTime = "";
    public String selectedDeliverySlotPrice = "";
    public SellerInfo sellerInfo;
    public String selectedBookingDate = "";
    public String orderAgainBookingDate = "";
    public String orderAgainBookingId = "";
    public float selectedBookingCost;
    public String distance;
    private String description; //"N/A";
    private String short_description; //"N/A";
    private List<TM_ProductImage> images = new ArrayList<>();
    private int rewardPoints = -1;
    private String brandName = null;
    private String priceLabel = null;
    private String priceLabelPosition = "right";
    private QuantityRule quantityRules = null;
    private String status = null;

    public TM_ProductInfo() {
        allProducts.add(this);
    }

    public static List<TM_ProductInfo> getAll() {
        if (DataEngine.hide_blocked_items) {
            List<TM_ProductInfo> productsToShow = new ArrayList<>();
            for (TM_ProductInfo product : allProducts) {
                if (!product.isBlocked()) {
                    productsToShow.add(product);
                }
            }
            return productsToShow;
        }
        return allProducts;
    }

    public static void clearAll() {
        if (allProducts != null)
            allProducts.clear();
    }

    public static void removeAll() {
        if (allProducts != null) {
            allProducts.clear();
        }

        if (bestDealProductsIds != null) {
            bestDealProductsIds.clear();
        }

        if (freshArrivalProductsIds != null) {
            freshArrivalProductsIds.clear();
        }

        if (trendingProductsIds != null) {
            trendingProductsIds.clear();
        }
    }

    public static TM_ProductInfo getProductWithId(int id) {
        for (TM_ProductInfo p : allProducts) {
            if (p.id == id) {
                return p;
            }
        }
        return null;
    }

    public static TM_ProductInfo findProductById(int id) {
        return TM_ProductInfo.getProductWithId(id);
    }

    public static TM_ProductInfo getOrCreate(int id) {
        for (TM_ProductInfo p : allProducts) {
            if (p.id == id) {
                return p;
            }
        }
        TM_ProductInfo productInfo = new TM_ProductInfo();
        productInfo.id = id;
        return productInfo;
    }

    public static TM_ProductInfo getProductWithSku(String sku) {
        for (TM_ProductInfo p : allProducts) {
            if (p != null && p.sku != null) {
                if (p.sku.equals(sku)) {
                    return p;
                }
            }
        }
        return null;
    }

    public static List<TM_ProductInfo> getAllProductWithPoll() {
        List<TM_ProductInfo> list = new ArrayList<>();
        for (TM_ProductInfo p : allProducts) {
            if (p.has_poll) {
                list.add(p);
            }
        }
        return list;
    }

    public static boolean isAvailable(int id) {
        for (TM_ProductInfo p : allProducts) {
            if (p.id == id) {
                return true;
            }
        }
        return false;
    }

    public static List<TM_ProductInfo> getOnlyForCategory(TM_CategoryInfo category) {
        List<TM_ProductInfo> productsWithinCategory = new ArrayList<>();
        for (TM_ProductInfo p : allProducts) {
            //DataHelper.log("---- checkin product: [" + p.title + "] with categories [" + p.categories.size() + "] ----");
            for (TM_CategoryInfo c : p.categories) {
                //DataHelper.log("- checkin category: [" + c.name + "] -");
                if (c.equals(category)) {
                    productsWithinCategory.add(p);
                    break;
                }
            }
        }
        return productsWithinCategory;
    }

    public static List<TM_ProductInfo> getBestDeals(int count) {
        List<TM_ProductInfo> bestDealProducts = new ArrayList<>();
        int i = 0;
        for (TM_ProductInfo product : bestDealProductsIds) {
            if (!product.isBlocked()) {
                // = TM_ProductInfo.getProductWithId(id);
                if (TM_CommonInfo.hide_out_of_stock) {
                    if (product.in_stock)
                        bestDealProducts.add(product);
                } else {
                    bestDealProducts.add(product);
                }
            }
            if (i++ > count) break;
        }
        return bestDealProducts;
    }

    public static List<TM_ProductInfo> getFreshArrivals(int count) {
        List<TM_ProductInfo> freshArrivalProducts = new ArrayList<>();
        int i = 0;
        for (TM_ProductInfo product : freshArrivalProductsIds) {
            if (!product.isBlocked()) {
                //TM_ProductInfo product = TM_ProductInfo.getProductWithId(id);
                if (TM_CommonInfo.hide_out_of_stock) {
                    if (product.in_stock)
                        freshArrivalProducts.add(product);
                } else {
                    freshArrivalProducts.add(product);
                }
            }
            if (i++ > count) break;
        }
        return freshArrivalProducts;
    }

    public static List<TM_ProductInfo> getTrending(int count) {
        //DataHelper.log("-- getTrending --");
        List<TM_ProductInfo> trendingProductIds = new ArrayList<>();
        //bestDealProducts.addAll(getAll());

        int i = 0;
        for (TM_ProductInfo product : trendingProductsIds) {
            if (!product.isBlocked()) {
                //TM_ProductInfo product = TM_ProductInfo.getProductWithId(id);
                if (TM_CommonInfo.hide_out_of_stock) {
                    if (product.in_stock)
                        trendingProductIds.add(product);
                } else {
                    trendingProductIds.add(product);
                }
            }
            if (i++ > count) break;
        }
        return trendingProductIds;
    }

    public static List<TM_ProductInfo> getAllForCategory(TM_CategoryInfo category) {
        List<TM_ProductInfo> productsWithinCategory = new ArrayList<>();
        // adding products directly belongs to the given category
        for (TM_ProductInfo p : allProducts) {
            for (TM_CategoryInfo c : p.categories) {
                if (c.equals(category)) {
                    productsWithinCategory.add(p);
                    break;
                }
            }
        }
        // adding products belongs to the childern categories of given category
        for (TM_CategoryInfo c : category.childrens) {
            productsWithinCategory.addAll(getAllForCategory(c));
        }
        return productsWithinCategory;
    }

    public static List<TM_ProductInfo> get10ForCategory(TM_CategoryInfo category) {
        List<TM_ProductInfo> productsWithinCategory = new ArrayList<>();
        // adding products directly belongs to the given category
        int productCount = 0;
        for (TM_ProductInfo p : allProducts) {
            for (TM_CategoryInfo c : p.categories) {
                if (c.equals(category)) {
                    productCount++;
                    productsWithinCategory.add(p);
                    break;
                }
            }
            if (productCount > 10)
                break;
        }
        return productsWithinCategory;
    }

    public static void printAll() {
        for (TM_ProductInfo p : allProducts) {
            DataHelper.log("------- ProductId:[" + p.id + "] --------");
            DataHelper.log("-- name: " + p.title);
            DataHelper.log("-- short_description: " + p.short_description);
            DataHelper.log("-- description: " + p.description);
            DataHelper.log("-- price: " + p.price);
            DataHelper.log("-- sale_price: " + p.sale_price);
            DataHelper.log("-------------------------------------------------------");
        }
    }

    public static String getThumbOfProduct(int productId) {
        for (TM_ProductInfo p : allProducts) {
            if (p.id == productId) {
                if (p.images.size() > 0) {
                    return p.images.get(0).src;
                } else {
                    return "";
                }
            }
        }
        return "";
    }

    public static TM_ProductInfo getPromoProduct() {
        if (productInfo == null) {
            productInfo = new TM_ProductInfo();
            productInfo.id = ID_PROMO_BUTTON;
            productInfo.title = "Get More";
            productInfo.short_description = "Awesome Products";
            productInfo.price = 0;
            TM_ProductImage img = new TM_ProductImage();
            productInfo.images.add(img);
        }
        return productInfo;
    }

    public static void removeProductById(Integer productId) {
        if (allProducts != null && allProducts.size() > 0) {
            for (TM_ProductInfo productInfo : allProducts) {
                if (productInfo.id == productId) {
                    allProducts.remove(productInfo);
                    break;
                }
            }
        }
    }

    public boolean isBlocked() {
        for (TM_CategoryInfo category : this.categories) {
            if (category.isBlocked)
                return true;
        }
        return false;
    }

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

    public String getDescription() {
        if (this.description != null) {
            return "<html><head><style>iframe {max-width: 100%; width:auto; height: auto;}</style></head><body>" + this.description + "</body></html>";
        }
        return "";
    }

    public void setDescription(String string) {
        description = string;
        description = description.replace("\"//", "\"http://");
        description = DataHelper.replaceNewLines(description);
    }

    public boolean hasDescription() {
        return this.description != null && this.description.length() > 0;
    }

    public String getShortDescription() {
        if (this.short_description != null) {
            return this.short_description.trim();
        }
        return ""; //"N/A";
    }

    public void setShortDescription(String string) {
        this.short_description = DataHelper.replaceNewLines(string);
    }

    public boolean hasShortDescription() {
        return this.short_description != null && this.short_description.length() > 0;
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

    public void setActualPrice(float newPrice) {
        if (sale_price > 0)
            sale_price = newPrice;
        else
            price = newPrice;
    }

    public void clonePrice() {
        this.price_clone = this.price;
        this.regular_price_clone = this.regular_price;
        this.sale_price_clone = this.sale_price;
        this.price_min_clone = this.price_min;
        this.price_max_clone = this.price_max;
    }

    public int getDiscountPercentage() {
        return (int) Math.floor(100.0f - (100.0f * getActualPrice() / regular_price));
    }

    public boolean hasPriceRange() {
        return price_min >= 0 && price_max > 0 && price_min != price_max;
    }

    public boolean hasPriceRangeEqual() {
        return price_min == price_max;
    }

    public boolean belongsToCategory(TM_CategoryInfo category) {
        for (TM_CategoryInfo c_parent : this.categories) {
            // chking if product belong to this category directly or not
            if (c_parent.equals(category))
                return true;
            // chking if product belong to any children categories of this
            // category or not
            for (TM_CategoryInfo c_child : category.childrens) {
                if (c_child.belongsToCategory(c_parent)) {
                    return true;
                }
            }
        }
        return false;
    }

    public boolean containsTag(String tag) {
        if (this.title.toLowerCase().contains(tag))
            return true;
        if (this.sku.toLowerCase().contains(tag))
            return true;
        if (this.short_description.toLowerCase().contains(tag))
            return true;
        for (TM_CategoryInfo c : this.categories) {
            if (c.containsTag(tag))
                return true;
        }
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

        for (TM_CategoryInfo c : this.categories) {
            if (c.hasKeyWordForSearch(tag))
                return true;
        }

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
            return categories.get(0).id;
        return -1;
    }

    public TM_CategoryInfo getFirstCategory() {
        if (!categories.isEmpty())
            return categories.get(0);
        return null;
    }

    public void putInCategories(List<TM_CategoryInfo> categoriesToAssign) {
        for (TM_CategoryInfo category : categoriesToAssign) {
            if (!isInCategory(category)) {
                this.categories.add(category);
            }
        }
    }

    public void putInCategory(int categoryId) {
        putInCategory(TM_CategoryInfo.getWithId(categoryId));
    }

    public void putInCategory(TM_CategoryInfo category) {
        if (!isInCategory(category)) {
            categories.add(category);
        }
    }

    public boolean isInCategory(TM_CategoryInfo category) {
        for (TM_CategoryInfo c : categories) {
            if (c.id == category.id)
                return true;
        }
        return false;
    }

    public boolean containedInCategories(List<Integer> categoryIds) {
        for (TM_CategoryInfo category : categories) {
            if (categoryIds.contains(category.id)) {
                return true;
            }
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

    public String[] getImageUrls() {
        String[] array = new String[images.size()];
        for (int i = 0; i < images.size(); i++) {
            array[i] = images.get(i).src;
        }
        return array;
    }

    public String getFirstImageUrl() {
        if (hasAnyImage()) {
            return images.get(0).src;
        }
        return "";
    }

    private boolean hasImage(String img_url) {
        for (TM_ProductImage image : images) {
            if (image.src.equalsIgnoreCase(img_url))
                return true;
        }
        return false;
    }

    public void addImage(String url) {
        TM_ProductImage image = new TM_ProductImage();
        image.src = url;
        addImage(image);
    }

    public void addImage(TM_ProductImage image) {
        if (!this.hasImage(image.src)) {
            images.add(image);
            generateThumb();
        }
    }

    public void addImage(int index, TM_ProductImage image) {
        if (!this.hasImage(image.src)) {
            images.add(index, image);
            generateThumb();
        }
    }

    private void generateThumb() {
        if (hasAnyImage() && !hasThumb()) {
            String img_url = images.get(0).src;
            this.thumb = DataHelper.getScaledThumbnailUrl(img_url);
        }
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

    public List<TM_ProductInfo> getRelatedProducts() {
        if (related_ids == null || related_ids.isEmpty())
            return null;
        List<TM_ProductInfo> relatedProducts = new ArrayList<>();
        for (int id : related_ids) {
            TM_ProductInfo relatedProduct = TM_ProductInfo.getProductWithId(id);
            if (relatedProduct != null) {
                if (!TM_CommonInfo.hide_out_of_stock || relatedProduct.in_stock) {
                    relatedProducts.add(relatedProduct);
                }
            }
        }
        return relatedProducts;
    }

    public List<TM_ProductInfo> getUpSellProducts() {
        if (upsell_ids == null || upsell_ids.isEmpty())
            return null;
        List<TM_ProductInfo> upSellProducts = new ArrayList<>();
        for (int id : upsell_ids) {
            TM_ProductInfo upSellProduct = TM_ProductInfo.getProductWithId(id);
            if (upSellProduct != null) {
                if (!TM_CommonInfo.hide_out_of_stock || upSellProduct.in_stock) {
                    upSellProducts.add(upSellProduct);
                }
            }
        }
        return upSellProducts;
    }

    public List<TM_ProductInfo> getCrossSellProducts() {
        if (cross_sell_ids == null || cross_sell_ids.isEmpty())
            return null;
        List<TM_ProductInfo> crossLessProducts = new ArrayList<>();
        for (int id : cross_sell_ids) {
            TM_ProductInfo crossLessProduct = TM_ProductInfo.getProductWithId(id);
            if (crossLessProduct != null) {
                if (!TM_CommonInfo.hide_out_of_stock || crossLessProduct.in_stock) {
                    crossLessProducts.add(crossLessProduct);
                }
            }
        }
        return crossLessProducts;
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
                    // excludes attributes having visibility and no variations
                    if (!attribute.visible && !isAttributeUsedEver) {
                        extraOptions.add(option);
                    }
                }
                attribute.options.removeAll(extraOptions);
            }

            if (attribute.options.isEmpty() || (TextUtils.isEmpty(attribute.name) && TextUtils.isEmpty(attribute.slug))) {
                extraAttributes.add(attribute);
            } else if (!DataEngine.show_non_variation_attribute && !attribute.variation) {
                extraAttributes.add(attribute);
            } else if ((!attribute.visible && !attribute.variation) || !attribute.variation) {
                extraAttributes.add(attribute);
            }
        }
        // Add extra attribute for additional information
        this.extraAttributes.clear();
        this.extraAttributes.addAll(extraAttributes);
        // Remove extra attribute for normal attribute selection
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


    public String getPriceLabelPosition() {
        return priceLabelPosition;
    }

    public void setPriceLabelPosition(String priceLabelPosition) {
        this.priceLabelPosition = priceLabelPosition;
    }

    public QuantityRule getQuantityRules() {
        return quantityRules;
    }

    public void setQuantityRules(QuantityRule quantityRules) {
        this.quantityRules = quantityRules;
    }

    public RawProductInfo getReferenceProduct() {
        RawProductInfo rawProduct = new RawProductInfo();
        rawProduct.title = this.title;
        rawProduct.short_description = this.short_description;
        rawProduct.description = this.description;
        for (TM_CategoryInfo category : this.categories) {
            rawProduct.categories.add(RawCategory.getWithId(category.id));
        }
        rawProduct.price = this.price;
        rawProduct.price_html = this.price_html;
        rawProduct.regular_price = this.regular_price;
        rawProduct.sale_price = this.sale_price;
        rawProduct.in_stock = this.in_stock;
        rawProduct.taxable = this.taxable;
        rawProduct.stock_quantity = this.stockQty;
        rawProduct.type = this.type;
        rawProduct.downloadable = this.downloadable;
        rawProduct.id = this.id;
        rawProduct.weight = this.weight;
        rawProduct.visible = this.visible;
        rawProduct.addImages(this.getImageUrls());
        rawProduct.attributes.addAll(this.attributes);
        if (extraAttributes.size() > 0) {
            rawProduct.attributes.addAll(this.extraAttributes);
        }
        return rawProduct;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public enum ProductType {
        SIMPLE("simple"),
        GROUPED("grouped"),
        CONFIGURABLE("configurable"),
        VIRTUAL("virtual"),
        BUNDLE("bundle"),
        BUNDLE_YITH("yith_bundle"),
        DOWNLOADABLE("downloadable"),
        MIXNMATCH("mix-and-match"),
        VARIABLE("variable"),
        EXTERNAL("external"),
        BOOKING("booking"),
        AUCTION("auction");

        private final String value;

        ProductType(String value) {
            this.value = value;
        }

        public static ProductType from(String name) {
            if (name != null && !name.equals("")) {
                for (ProductType type : values()) {
                    if (type.toString().equalsIgnoreCase(name)) {
                        return type;
                    }
                }
            }
            return SIMPLE;
        }

        @Override
        public String toString() {
            return this.value;
        }
    }

    public static class TM_DeliveryInfo {
        public String prdd_enable_date;
        public String prdd_enable_time;
        public String prdd_recurring_chk;
        public String prdd_weekday_0;
        public String prdd_weekday_1;
        public String prdd_weekday_2;
        public String prdd_weekday_3;
        public String prdd_weekday_4;
        public String prdd_weekday_5;
        public String prdd_weekday_6;
        public int prdd_minimum_number_days;
        public int prdd_maximum_number_days;
        public int prdd_date_lockout;
        public String prdd_product_holiday;
        public String prdd_date_range_type;
        public String prdd_start_date_range;
        public String prdd_end_date_range;

        public Map<String, List<TimeSettings>> prdd_weekday_time_slot;

        public List<String> getWeekDayTimeSlots(String weekday) {
            List<TimeSettings> timeSettingsList = prdd_weekday_time_slot.get(weekday);
            List<String> list = new ArrayList<>();
            for (TimeSettings timeSettings : timeSettingsList) {
                list.add(timeSettings.getSlotString());
            }
            return list;
        }

        public static class TimeSettings {
            public String slot_price;
            public String from_slot_hrs;
            public String from_slot_min;
            public String to_slot_hrs;
            public String to_slot_min;
            public String lockout_slot;

            public String getSlotString() {
                return from_slot_hrs + ":" + from_slot_min + "-" + to_slot_hrs + ":" + to_slot_min;
            }
        }
    }
}
