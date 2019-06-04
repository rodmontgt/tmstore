package com.twist.dataengine.entities;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Created by Twist Mobile on 3/16/2016.
 */
public class TM_Coupon {
    private static List<TM_Coupon> allCoupons = new ArrayList<>();

    public static List<TM_Coupon> getAll() {
        return allCoupons;
    }

    public static void clearAll() {
        allCoupons.clear();
        allCouponsLoaded = false;
    }

    public TM_Coupon() {
        product_ids = new ArrayList<>();
        exclude_product_ids = new ArrayList<>();
        product_category_ids = new ArrayList<>();
        exclude_product_category_ids = new ArrayList<>();
        customer_emails = new ArrayList<>();
        couponDiscountOnApply = 0;
    }

    public boolean applicableForId(int productId, boolean isProductOnSale) {
        if (this.exclude_sale_items && isProductOnSale) {
            return false;
        }

        if (!product_ids.isEmpty()) {
            return this.product_ids.contains(productId);
        } else if (!exclude_product_ids.isEmpty()) {
            return !this.exclude_product_ids.contains(productId);
        }
        return true;
    }

    public static TM_Coupon getWithCode(String couponCode) {
        for (TM_Coupon coupon : allCoupons) {
            if (coupon.code.equals(couponCode)) {
                return coupon;
            }
        }
        return null;
    }

//    public String verify(List<Integer> selectedProductIds, List<Integer> selectedCategoryIds, String userEmail, float total_amount) {
//        if (!this.product_ids.isEmpty()) {
//            if (this.type.equals("fixed_product") || this.type.equals("percent_product")) {
//                boolean applicableProductFound = false;
//                for (int id : selectedProductIds) {
//                    if (this.product_ids.contains(id)) {
//                        applicableProductFound = true;
//                        break;
//                    }
//                }
//                if (!applicableProductFound) {
//                    DataHelper.log("== product [" + id + "] does not belongs to coupon's product_ids ==");
//                    return "This coupon can not be applied on any of your selected Product.";
//                }
//            }
//        }
//
//        if (!this.exclude_product_ids.isEmpty()) {
//            if (this.type.equals("fixed_product") || this.type.equals("percent_product")) {
//                boolean applicableProductFound = false;
//                for (int id : selectedProductIds) {
//                    if (!this.exclude_product_ids.contains(id)) {
//                        applicableProductFound = true;
//                        break;
//                    }
//                }
//                if (!applicableProductFound) {
//                    DataHelper.log("== product [" + id + "] does not belongs to coupon's exclude_product_ids ==");
//                    return "This coupon is not valid for any of your selected Products.";
//                }
//            } else {
//                for (int id : selectedProductIds) {
//                    if (this.exclude_product_ids.contains(id)) {
//                        DataHelper.log("== product [" + id + "] belongs to coupon's exclude_product_ids ==");
//                        return "This coupon is not valid for \"" + TM_ProductInfo.getProductWithId(id).title + "\"";
//                    }
//                }
//            }
//        }
//
//        if (this.usage_limit <= 0 || this.usage_count > this.usage_limit) {
//            return "This coupon surpasses total usage limit.";
//        }
//
//        if (this.usage_limit_per_user <= 0) {
//            return "This coupon exceeds usage limit.";
//        }
//
//        if (this.limit_usage_to_x_items > 0 && selectedProductIds.size() > this.limit_usage_to_x_items) {
//            return "This coupon can not be applied on more than " + this.limit_usage_to_x_items + " items.";
//        }
//
//        if (expiry_date != null && this.expiry_date.before(today())) {
//            return "This coupon is expired.";
//        }
//
//        if (!this.product_category_ids.isEmpty()) {
//            for (int id : selectedCategoryIds) {
//                if (!this.product_category_ids.contains(id)) {
//                    DataHelper.log("== product [" + id + "] does not belongs to coupon's product_category_ids ==");
//                    return "This coupon is not valid for one or more selected Category.";
//                }
//            }
//        }
//
//        if (!this.exclude_product_category_ids.isEmpty()) {
//            for (int id : selectedCategoryIds) {
//                if (this.exclude_product_category_ids.contains(id)) {
//                    DataHelper.log("== product [" + id + "] belongs to coupon's exclude_product_category_ids ==");
//                    return "This coupon is not valid for one or more selected Category.";
//                }
//            }
//        }
//
//        if (this.exclude_sale_items) {
//            for (int id : selectedProductIds) {
//                TM_ProductInfo productInfo = TM_ProductInfo.getProductWithId(id);
//                if (productInfo.on_sale) {
//                    return "This coupon is not valid for those items which are already on sale.";
//                }
//            }
//        }
//
//        if (this.minimum_amount > 0 && total_amount < this.minimum_amount) {
//            return "This coupon is only valid for minimum purchase of " + DataHelper.appendCurrency(this.minimum_amount) + " amount.";
//        }
//
//        if (this.maximum_amount > 0 && total_amount > this.maximum_amount) {
//            return "This coupon is not valid for purchase of more than " + DataHelper.appendCurrency(this.maximum_amount) + " amount.";
//        }
//
//        if (!this.customer_emails.isEmpty()) {
//            if (!this.customer_emails.contains(userEmail)) {
//                return "This coupon is not applicable for your Email.";
//            }
//        }
//        return "success";
//    }

    private Date today() {
        return new Date();
    }

    public void register() {
        allCoupons.add(this);
    }

    public int id;
    public String code;
    public String type;
    public float amount;
    public boolean individual_use;
    public List<Integer> product_ids;
    public List<Integer> exclude_product_ids;
    public int usage_limit;
    public int usage_limit_per_user;
    public int limit_usage_to_x_items;
    public int usage_count;
    public Date expiry_date;
    public boolean enable_free_shipping;
    public List<Integer> product_category_ids;
    public List<Integer> exclude_product_category_ids;
    public boolean exclude_sale_items;
    public float minimum_amount;
    public float maximum_amount;
    public List<String> customer_emails;
    public String description;
    public float couponDiscountOnApply;

    public static boolean allCouponsLoaded = false;
}
