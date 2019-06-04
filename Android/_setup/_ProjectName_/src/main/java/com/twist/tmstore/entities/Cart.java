package com.twist.tmstore.entities;

import com.activeandroid.Model;
import com.activeandroid.annotation.Column;
import com.activeandroid.annotation.Table;
import com.activeandroid.query.Select;
import com.twist.dataengine.entities.RewardPoint;
import com.twist.dataengine.entities.TM_Bundle;
import com.twist.dataengine.entities.TM_CategoryInfo;
import com.twist.dataengine.entities.TM_CommonInfo;
import com.twist.dataengine.entities.TM_Coupon;
import com.twist.dataengine.entities.TM_Order;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.dataengine.entities.TM_Variation;
import com.twist.dataengine.entities.TM_VariationAttribute;
import com.twist.tmstore.L;
import com.twist.tmstore.listeners.CartEventListener;
import com.utils.AnalyticsHelper;
import com.utils.ArrayUtils;
import com.utils.DataHelper;
import com.utils.Helper;
import com.utils.Log;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Table(name = "Cart")
public class Cart extends Model {

    @Column(name = "cart_product_id")
    public int product_id;

    @Column(name = "count")
    public int count = 0;

    @Column(name = "selected_variation_id")
    public int selected_variation_id = -1;

    @Column(name = "selected_variation_index")
    public int selected_variation_index = -1;

    @Column(name = "price")
    private float price = 0;

    @Column(name = "title")
    public String title;

    @Column(name = "variation_json")
    public String variation_json;

    @Column(name = "img_url")
    public String img_url;

    @Column(name = "is_alive")
    public int is_alive = 0;

    @Column(name = "taxable")
    public int taxable = 0;

    @Column(name = "pastSessionToken")
    private long pastSessionToken = -1;

    @Column(name = "note")
    public String note = "";

    @Column(name = "bundled_items_json_2")
    private String bundled_items_json = "";

    @Column(name = "matched_items_json_2")
    private String matched_items_json = "";

    @Column(name = "delivery_info_json")
    private String delivery_info_json = "";

    @Column(name = "booking_date")
    public String booking_date;

    @Column(name = "order_id")
    public int order_id;

    @Column(name = "deposit_price")
    private float deposit_price = 0;

    @Column(name = "cart_meta_json")
    public String cart_meta_json = "";

    public String selectedDeliveryDate = "";

    public String selectedDeliveryTime = "";

    public String selectedDeliverySlotPrice = "0";

    public float weight = 0;

    public float taxOnProduct = 0;

    public List<TM_VariationAttribute> attributes = null;

    public List<CartBundleItem> bundledItems = null;

    public List<CartMatchedItem> matchedItems = null;

    public TM_ProductInfo product;

    private static List<Cart> allCartItems = null;

    private static List<Cart> previousCartItems = null;

    private static long currentSessionToken = 0;

    private static float mPointsPriceDiscount = 0.0f;

    private static int mPointsUsed = 0;

    public static void generateSession() {
        currentSessionToken = System.currentTimeMillis();
    }

    private static CartEventListener mCartEventListener;

    public float getExtraPrice() {
        float extra = 0.0f;
        for (TM_VariationAttribute attribute : attributes) {
            extra += attribute.extraPrice;
        }
        return extra;
    }

    public static void moveCartToBin(Cart cart) {
        if (previousCartItems == null) {
            previousCartItems = new ArrayList<>();
        }

        List<Cart> cartsToDelete = new ArrayList<>();
        for (Cart c : previousCartItems) {
            if (c.pastSessionToken != currentSessionToken) {
                cartsToDelete.add(c);
            }
        }
        previousCartItems.removeAll(cartsToDelete);
        for (Cart c : cartsToDelete) {
            c.delete();
        }
        cartsToDelete.clear();
        Helper.gc();

        allCartItems.remove(cart);
        cart.is_alive = -1;
        cart.pastSessionToken = currentSessionToken;
        previousCartItems.add(cart);
        try {
            cart.save();
        } catch (Exception e) {
            e.printStackTrace();
        }

        AnalyticsHelper.registerAddToCartEvent(cart, -1 * cart.count);

        clearCoupons();
    }


    public static List<TM_Coupon> applied_coupons = null;

    public static String addCoupon(TM_Coupon coupon) {

        if (coupon == null) {
            return "Can not add null Coupon.";
        }

        if (applied_coupons == null) {
            applied_coupons = new ArrayList<>();
        }

        for (TM_Coupon c : applied_coupons) {
            if (c.id == coupon.id) {
                return "This coupon is already applied.";
            } else if (c.individual_use) {
                return "This Coupon can not be combined with previous coupons.";
            }
        }

        if (coupon.individual_use && !applied_coupons.isEmpty()) {
            applied_coupons.clear();
        }

        applied_coupons.add(coupon);
        return "success";
    }

    public static void removeCoupon(int couponId) {
        for (TM_Coupon coupon : applied_coupons) {
            if (coupon.id == couponId) {
                applied_coupons.remove(coupon);
                break;
            }
        }
    }

    public static boolean isAnyCouponApplied() {
        return !(applied_coupons == null || applied_coupons.isEmpty());
    }

    public float discountTotal = 0; //for quicker access
    public float originalTotal = 0; //for quicker access

    public float getTotalDiscount() {
        return discountTotal;
    }

    public static float getTotalWeight() {
        float totalWeight = 0.0f;
        for (Cart cart : allCartItems) {
            float weight = cart.weight;
            totalWeight += weight;
        }
        return totalWeight > AppInfo.SHIPPING_DEFAULT_WEIGHT ? totalWeight : AppInfo.SHIPPING_DEFAULT_WEIGHT;
    }

    public static float getTotalCouponBenefits(final float totalCartPayment) {
        for (Cart cart : allCartItems) {
            cart.discountTotal = 0.0f;
        }

        float totalCardDiscount = 0;
        try {
            if (applied_coupons != null) {
                for (TM_Coupon coupon : applied_coupons) {
                    float thisCouponDiscount = 0;
                    switch (coupon.type) {
                        case "percent": {
                            for (Cart cart : allCartItems) {
                                cart.discountTotal = cart.originalTotal * coupon.amount * 1.0f / 100.0f;
                            }
                            float discoutAmount = totalCartPayment * coupon.amount * 1.0f / 100.0f;
                            totalCardDiscount += discoutAmount;
                            thisCouponDiscount += discoutAmount;
                        }
                        break;
                        case "fixed_product": {
                            //total -= coupon.amount;
                            for (Cart cart : allCartItems) {
                                if (coupon.applicableForId(cart.product_id, cart.product.on_sale)) {
                                    totalCardDiscount += (coupon.amount * cart.count);
                                    thisCouponDiscount += (coupon.amount * cart.count);
                                    cart.discountTotal += (coupon.amount * cart.count);
                                }
                            }
                        }
                        break;
                        case "percent_product": {
                            //float discoutAmount = total * coupon.amount * 1.0f / 100.0f;
                            //total -= discoutAmount;
                            for (Cart cart : allCartItems) {
                                if (coupon.applicableForId(cart.product_id, cart.product.on_sale)) {
                                    float productPrice = TM_ProductInfo.getProductWithId(cart.product_id).getActualPrice() * cart.count;
                                    float discoutAmount = productPrice * coupon.amount * 1.0f / 100.0f;
                                    totalCardDiscount += discoutAmount;
                                    thisCouponDiscount += discoutAmount;
                                    cart.discountTotal += discoutAmount;
                                }
                            }
                        }
                        break;
                        default: {
                            totalCardDiscount += coupon.amount;
                            thisCouponDiscount += coupon.amount;
                            if (totalCartPayment != 0) {
                                for (Cart cart : allCartItems) {
                                    cart.discountTotal += (coupon.amount * (cart.originalTotal / totalCartPayment));
                                }
                            } else {
                                for (Cart cart : allCartItems) {
                                    cart.discountTotal += 0.0f;
                                }
                            }
                        }
                        break;
                    }
                    coupon.couponDiscountOnApply = thisCouponDiscount;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (AppInfo.ENABLE_CUSTOM_POINTS) {
            float totalPointsDiscountPrice = getPointsPriceDiscount();
            totalCardDiscount += totalPointsDiscountPrice;
            for (Cart cart : allCartItems) {
                float actualProductPrice = cart.getDiscountedPrice();
                float discountForProduct = actualProductPrice < totalPointsDiscountPrice ? actualProductPrice : totalPointsDiscountPrice;
                cart.discountTotal += discountForProduct;
                totalPointsDiscountPrice -= discountForProduct;
                if (totalPointsDiscountPrice <= 0)
                    break;
            }
        }
        return totalCardDiscount;
    }

    public float getDiscountedPrice() {
        return this.getItemTotalPrice() - this.getTotalDiscount();
    }

    public static void clearCoupons() {
        if (applied_coupons != null) {
            applied_coupons.clear();
            applied_coupons = null;
        }
    }

    public static Cart findCart(TM_ProductInfo product, int variation_id, int variation_index) {
        return product == null ? null : findCart(product.id, variation_id, variation_index);
    }

    public static Cart findCart(int product_id, int variation_id, int variation_index) {
        for (Cart c : allCartItems) {
            // mix n match product has no variations.
            if (c.matchedItems != null) {
                for (CartMatchedItem item : c.matchedItems) {
                    if (c.product_id == item.getProductId()) {
                        return c;
                    }
                }
            }

            if (variation_index == -2) { //for backward compatibility
                if (c.product_id == product_id && c.selected_variation_id == variation_id) {
                    return c;
                }
            } else {
                if (c.product_id == product_id && c.selected_variation_id == variation_id && c.selected_variation_index == variation_index) {
                    return c;
                }
            }
        }
        return null;
    }

    public static Cart findCart(int product_id) {
        for (Cart c : allCartItems) {
            if (c.product_id == product_id) {
                return c;
            }
        }
        return null;
    }

    public Cart() {
        super();
    }

    public Cart(int product_id, String title, float price, int selected_variation_id, int selected_variation_index, TM_ProductInfo product, List<TM_VariationAttribute> attributes, Map<TM_ProductInfo, Integer> matchedItems, TM_Order order) {
        this.product_id = product_id;
        this.product = product;
        this.title = title;
        this.count = 1;
        this.selected_variation_index = selected_variation_index;
        this.selected_variation_id = selected_variation_id;
        this.attributes = attributes;
        if (this.attributes == null) {
            this.attributes = new ArrayList<>();
        }
        if (selected_variation_id != -1) {
            try {
                TM_Variation variation;
                if (selected_variation_index < product.variations.size()) {
                    variation = product.variations.get(selected_variation_index);
                } else {
                    variation = product.variations.getVariation(selected_variation_id);
                }
                if (variation != null) {
                    if (!variation.images.isEmpty()) {
                        this.img_url = variation.images.get(0).src;
                    } else {
                        this.img_url = product.thumb;
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else {
            this.img_url = product.thumb;
        }
        this.variation_json = CartVariation.encodeToString(this.attributes);

        if (product.type == TM_ProductInfo.ProductType.BUNDLE || product.type == TM_ProductInfo.ProductType.BUNDLE_YITH) {
            this.bundled_items_json = CartBundleItem.encodeToString(this.product.mBundles);
        } else {
            this.bundled_items_json = "";
        }

        if (product.type == TM_ProductInfo.ProductType.MIXNMATCH) {
            this.matched_items_json = CartMatchedItem.encodeToString(matchedItems);
        } else {
            this.matched_items_json = "";
        }

        this.price = price;
        this.is_alive = 0;

        if (AppInfo.ENABLE_PRODUCT_DELIVERY_DATE && product.deliveryInfo != null) {
            selectedDeliveryDate = product.selectedDeliveryDate;
            selectedDeliveryTime = product.selectedDeliveryTime;
            selectedDeliverySlotPrice = product.selectedDeliverySlotPrice;
            try {
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("date", selectedDeliveryDate);
                jsonObject.put("time", selectedDeliveryTime);
                jsonObject.put("slot_price", selectedDeliverySlotPrice);
                delivery_info_json = jsonObject.toString();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        if (AppInfo.SHOW_PRODUCTS_BOOKING_INFO) {
            if (product.bookingInfo != null && product.type == TM_ProductInfo.ProductType.BOOKING) {
                this.booking_date = product.selectedBookingDate;
            }
            this.order_id = order != null ? order.id : 0;
        }

        if (AppInfo.ENABLE_DEPOSIT_ADDONS && product.depositInfo != null) {
            deposit_price = product.depositInfo.cartDepositAmount;
        }

        allCartItems.add(this);
    }

    public static void init() {
        List<Cart> savedCarts = new Select().from(Cart.class).execute();
        if (allCartItems == null) {
            allCartItems = new ArrayList<>();
        }
        allCartItems.clear();
        if (previousCartItems == null) {
            previousCartItems = new ArrayList<>();
        }
        previousCartItems.clear();
        if (savedCarts != null) {
            for (Cart cart : savedCarts) {
                if (cart.is_alive == -1) {
                    previousCartItems.add(cart);
                } else {
                    allCartItems.add(cart);
                }
            }
        }
        refresh();
    }

    public static void refresh() {
        prepareCart();
    }

    public static float getTotalPayment(boolean includeDeposit) {
        float totalCartPayment = getTotalPaymentExcludingCoupons(includeDeposit);
        float totalCouponBenefits = getTotalCouponBenefits(totalCartPayment);
        return (totalCartPayment - totalCouponBenefits);
    }

    public static float getTotalPayment() {
        float totalCartPayment = getTotalPaymentExcludingCoupons();
        float totalCouponBenefits = getTotalCouponBenefits(totalCartPayment);
        return (totalCartPayment - totalCouponBenefits);
    }

    public static float getTotalBasicPaymentPrice() {
        float total = 0.0f;
        for (Cart c : allCartItems) {
            try {
                total += c.product.priceOriginal * c.count;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return total;
    }

    public static float getTotalPaymentExcludingCoupons() {
        return getTotalPaymentExcludingCoupons(false);
    }

    public static float getTotalPaymentExcludingCoupons(boolean includeDeposit) {
        float total = 0.0f;
        for (Cart c : allCartItems) {
            try {
                float price = c.getItemTotalPrice(includeDeposit);
                total += price;
                c.originalTotal = price;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return total;
    }

    public float getTotalPaymentExcludingTax(Cart c) {
        if (TM_CommonInfo.addTaxToProductPrice) {
            return c.product.priceOriginal * count;
        } else {
            float price = c.getItemTotalPrice();
            c.originalTotal = price;
            return price;
        }
    }

    public float getItemPrice() {
        return getItemPrice(false);
    }

    public float getItemPrice(boolean includeDeposit) {
        return getActualPrice(includeDeposit) + getExtraPrice();
    }

    public float getActualPrice() {
        return getActualPrice(false);
    }

    public float getActualPrice(boolean includeDeposit) {
        if (this.matchedItems != null && this.matchedItems.size() != 0) {
            float subTotalPrice = 0;
            for (CartMatchedItem matchedItem : matchedItems) {
                subTotalPrice += matchedItem.getBasePrice() * matchedItem.getQuantity();
            }
            return subTotalPrice;
        }

        if (product != null && product.full_data_loaded) {
            if (includeDeposit && product.depositInfo != null) {
                //TODO must check this
                return deposit_price;
            }
            return product.getActualPrice(this.selected_variation_id);
        } else {
            return price;
        }
    }

    public void updatePrice(float newPrice) {
        if (product != null && product.full_data_loaded) {
            this.product.setActualPrice(this.selected_variation_id, newPrice);
        } else {
            this.price = newPrice;
        }
    }

    public float getPrice() {
        return price;
    }

    public float setPrice(float price) {
        return this.price = price;
    }

    public static List<Integer> getAllProductIds() {
        List<Integer> productIds = new ArrayList<>();
        for (Cart cart : allCartItems) {
            productIds.add(cart.product_id);
        }
        return productIds;
    }

    public static List<Integer> getAllVariationIds() {
        List<Integer> variationIds = new ArrayList<>();
        for (Cart cart : allCartItems) {
            if (cart.selected_variation_id != -1) {
                variationIds.add(cart.selected_variation_id);
            }
        }
        return variationIds;
    }

    public static List<Integer> getAllCategoryIds() {
        List<Integer> categoryIds = new ArrayList<>();
        for (Cart cart : allCartItems) {
            for (TM_CategoryInfo category : cart.product.categories) {
                if (!categoryIds.contains(category.id)) {
                    categoryIds.add(category.id);
                }
            }
        }
        return categoryIds;
    }

    public float getItemTotalPrice(boolean includeDeposit) {
        return getItemPrice(includeDeposit) * count;
    }

    public float getItemTotalPrice() {
        return getItemTotalPrice(false);
    }

    public static String getUnavailableProductIds() {
        String ids = "";
        for (Cart c : allCartItems) {
            if (c.product == null) {
                Log.d("-- found null product: [" + c.product_id + "] --");
                ids += c.product_id + ";";
            } else {
                Log.d("-- found not null product: [" + c.product.id + "] --");
            }
        }
        return ids;
    }

    public boolean setCount(int newCount) {
        int oldCount = this.count;
        if (AppInfo.ENABLE_BUNDLED_PRODUCTS) {
            if (product != null && (product.type == TM_ProductInfo.ProductType.BUNDLE || product.type == TM_ProductInfo.ProductType.BUNDLE_YITH)) {
                if (product.mBundles != null) {
                    for (TM_Bundle tm_bundle : product.mBundles) {
                        TM_ProductInfo product = tm_bundle.getProduct();
                        if (product != null) {
                            if (product.managing_stock) {
                                if (!product.in_stock && product.stockQty < newCount) {
                                    saveCart();
                                    return false;
                                }
                            } else if (!product.in_stock) {
                                saveCart();
                                return false;
                            } else if (product.stockQty < newCount) {
                                saveCart();
                                return false;
                            }
                        }
                    }
                }
            }
        }

        if (AppInfo.ENABLE_PRODUCT_ADDONS && product != null && product.productAddons != null) {
            ProductAddons.GroupAddon[] groupAddons = product.productAddons.group_addon;
            if (!ArrayUtils.isEmpty(groupAddons) && groupAddons[0] != null) {
                if (!ArrayUtils.isEmpty(groupAddons[0].options)) {
                    /*
                    {
                      "cart_meta": {
                        "ywapo_text_1": [
                          12,
                          12,
                          12,
                          12,
                          12
                        ],
                        "yith_wapo_is_single": 1,
                        "458-deposit-radio": "full",
                        "quantity": 1,
                        "add-to-cart": 458,
                        "0-deposit-radio": "full"
                      }
                    }
                    */
                    try {
                        JSONArray jsonArray = new JSONArray();
                        JSONArray metaJsonArray = new JSONArray();
                        String text_field = "";
                        for (ProductAddons.GroupAddon.Option option : groupAddons[0].options) {
                            jsonArray.put(option.value);
                            text_field = option.field_name;
                            JSONObject jsonObject = new JSONObject();
                            jsonObject.put("key", option.label);
                            jsonObject.put("value", option.value);
                            jsonObject.put("label", option.label);
                            metaJsonArray.put(jsonObject);
                        }

                        int s = text_field.indexOf("[");
                        int e = text_field.indexOf("]");
                        if (s > 0 && e > 0) {
                            text_field = text_field.substring(0, s);
                        }

                        JSONObject jsonObject = new JSONObject();
                        jsonObject.put(text_field, jsonArray);
                        jsonObject.put(product.id + "-deposit-radio", "full");
                        jsonObject.put("quantity", count);
                        jsonObject.put("yith_wapo_is_single", 1);
                        jsonObject.put("add-to-cart", product.id);
                        jsonObject.put("0-deposit-radio", "full");
                        jsonObject.put("meta", metaJsonArray);
                        this.cart_meta_json = jsonObject.toString();
                    } catch (JSONException e) {
                        e.printStackTrace();
                        return false;
                    }
                }
            }
        }

        this.count = newCount;
        saveCart();
        AnalyticsHelper.registerAddToCartEvent(this, newCount - oldCount);
        return true;
    }

    private void saveCart() {
        if (bundledItems != null) {
            JSONArray jsonArray = new JSONArray();
            for (CartBundleItem cartBundleItem : bundledItems) {
                try {
                    jsonArray.put(cartBundleItem.toJSONObject());
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            bundled_items_json = jsonArray.toString();
        }
        try {
            this.save();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public String getAttributeString() {
        String str = "";
        for (TM_VariationAttribute attribute : this.attributes) {
            String attributeName = attribute.name;
            String attributeValue = attribute.value;
            if (DataHelper.normalizationRequired(attributeName))
                attributeName = DataHelper.normalizePercentages(attributeName);
            if (DataHelper.normalizationRequired(attributeValue))
                attributeValue = DataHelper.normalizePercentages(attributeValue);
            str += attributeName + " : <strong>" + attributeValue + "</strong> | ";
        }
        if (str.length() > 3) {
            str = str.substring(0, str.length() - 3);
        }
        return str;
    }

    public int getCartItemCategory() {
        if (product != null) {
            return product.getFirstCategoryId();
        } else {
            return -1;
        }
    }

    public static float getTotalSavings() {
        float total = 0.0f;
        for (Cart c : allCartItems) {
            try {
                TM_ProductInfo p = c.product;
                float realSellingPrice = p.getActualPrice();
                if (p.regular_price > 0 && p.regular_price > realSellingPrice) {
                    total += (p.regular_price - realSellingPrice) * c.count;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        float totalCartPayment = getTotalPaymentExcludingCoupons();
        float totalCouponBenefits = getTotalCouponBenefits(totalCartPayment);
        return (total + totalCouponBenefits);
    }

    public static int getTotalRewardPoints() {
        int totalPoints = 0;
        for (Cart cart : Cart.getAll()) {
            if (cart.product != null) {
                int rewardPoints = cart.product.getRewardPoints(cart.selected_variation_id);
                if (rewardPoints > 0.0f) {
                    totalPoints += rewardPoints * cart.count;
                }
            }
        }
        return totalPoints;
    }

    public static List<Cart> getAllPrevious() {
        return previousCartItems;
    }

    public static List<Cart> getAll() {
        return allCartItems;
    }

    public static int getItemCount() {
        if (allCartItems == null) {
            return -1;
        }
        return allCartItems.size();
    }

    public static void prepareCart() {
        if (allCartItems != null)
            for (Cart c : allCartItems) {
                c.product = TM_ProductInfo.getProductWithId(c.product_id);
                if (c.product != null && c.product.full_data_loaded) {
                    c.title = c.product.title;
                    c.price = c.product.getActualPrice(c.selected_variation_id); //update and overwrite latest price of cart items
                }
//            if(c.variation_json != null && c.variation_json.length() > 0) {
//                c.attributes = CartVariation.decodeString(c.variation_json);
//            }
                c.attributes = CartVariation.decodeString(c.variation_json);
                if (c.attributes == null) {
                    c.attributes = new ArrayList<>();
                }

                if (c.bundled_items_json == null) {
                    c.bundled_items_json = "";
                }
                if (c.matched_items_json == null) {
                    c.matched_items_json = "";
                }

                //c.selected_variationAttributes = CartVariation.decodeString(c.attribute_json);

                c.bundledItems = CartBundleItem.decodeString(c.bundled_items_json);
                c.matchedItems = CartMatchedItem.decodeString(c.matched_items_json);

                if (AppInfo.ENABLE_PRODUCT_DELIVERY_DATE) {
                    try {
                        JSONObject jsonObject = new JSONObject(c.delivery_info_json);
                        c.selectedDeliveryDate = jsonObject.getString("date");
                        c.selectedDeliveryTime = jsonObject.getString("time");
                        c.selectedDeliverySlotPrice = jsonObject.getString("slot_price");
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                Log.d("== found saved cart item [" + c.product_id + "] [" + c.count + "] [" + c.price + "] ==");
            }
    }

    public static boolean addProduct(TM_ProductInfo product) {
        return Cart.addProduct(product, 1);
    }

    public static boolean addProduct(TM_ProductInfo product, int count) {
        if (product.managing_stock) {
            if (!product.backorders_allowed && !product.in_stock) {
                Log.d("Product out of stock.");
                return false;
            }
        } else if (!product.in_stock) {
            Log.d("Product out of stock.");
            return false;
        }

        if (!AppInfo.ENABLE_ZERO_PRICE_ORDER) {
            if (product.getActualPrice() <= 0) {
                Log.d("Product is not for sale.");
                return false;
            }
        }
        return addProduct(product, -1, -1, count, new ArrayList<TM_VariationAttribute>());
    }

    public static boolean addProduct(TM_ProductInfo product, int variation_id, int variation_index, int count, List<TM_VariationAttribute> attributes) {
        return Cart.addProduct(product, variation_id, variation_index, count, attributes, null, null);
    }

    public static boolean addProduct(TM_ProductInfo product, int variation_id, int variation_index, int count, List<TM_VariationAttribute> attributes, Map<TM_ProductInfo, Integer> matchedItems) {
        return Cart.addProduct(product, variation_id, variation_index, count, attributes, matchedItems, null);
    }

    public static boolean addProduct(TM_ProductInfo product, int variation_id, int variation_index, int count, List<TM_VariationAttribute> attributes, TM_Order order) {
        return Cart.addProduct(product, variation_id, variation_index, count, attributes, null, order);
    }

    /* Returns true if product added first time otherwise false */
    public static boolean addProduct(TM_ProductInfo product, int variation_id, int variation_index, int count, List<TM_VariationAttribute> attributes, Map<TM_ProductInfo, Integer> matchedItems, TM_Order order) {
        if (AppInfo.mGuestUserConfig != null && AppInfo.mGuestUserConfig.isEnabled() && AppInfo.mGuestUserConfig.isPreventCart() && AppUser.isAnonymous()) {
            Helper.toast(L.string.you_need_to_login_first);
            return false;
        }

        if (AppInfo.SHOW_PRODUCTS_BOOKING_INFO) {
            for (Cart cart : allCartItems) {
                TM_ProductInfo productInfo = TM_ProductInfo.findProductById(cart.product_id);
                if (productInfo != null && productInfo.type != product.type) {
                    Cart.clearCart();
                    break;
                }
            }
        }

        if (count <= 0) {
            count = 1;
        }

        for (Cart cart : allCartItems) {
            if (cart.product_id == product.id && cart.selected_variation_id == variation_id && cart.selected_variation_index == variation_index && Helper.listCompare(cart.attributes, attributes)) {
                cart.setCount(count);
                cart.weight = product.weight;
                clearCoupons();
                if (mCartEventListener != null) {
                    mCartEventListener.onItemUpdated(cart);
                }
                return true;
            }
        }

        Cart cart = new Cart(product.id, product.title, product.getActualPrice(variation_id), variation_id, variation_index, product, attributes, matchedItems, order);
        cart.setCount(count);
        cart.weight = product.weight;
        clearCoupons();

        AnalyticsHelper.registerAddToCartEvent(cart, 1);
        if (mCartEventListener != null) {
            mCartEventListener.onItemAdded(cart);
        }
        return true;
    }

    public static void removeProduct(TM_ProductInfo product) {
        Cart.removeProduct(product, -1, -1);
    }

    public static void removeProduct(TM_ProductInfo product, int variation_id, int variation_index) {
        Cart c = findCart(product, variation_id, variation_index);
        if (c != null) {
            removeSafely(c);
            if (mCartEventListener != null) {
                mCartEventListener.onItemRemoved();
            }
            return;
        }
        Log.d("-- Can't remove, requested product not found in Cart --");
    }


    public static void clearCart() {
        mPointsPriceDiscount = 0.0f;
        if (allCartItems == null)
            return;

        if (allCartItems.size() <= 0)
            return;

        clearCoupons();

        GhostCart.clearCart();

        for (Cart c : allCartItems) {
            c.delete();
        }
        allCartItems.clear();

        AnalyticsHelper.registerCartModificationEvent();
    }

    public static boolean hasItem(TM_ProductInfo product, int variation_id, int variation_index) {
        for (Cart c : allCartItems) {
            if (c.product_id == product.id && c.selected_variation_id == variation_id && c.selected_variation_index == variation_index) {
                return true;
            }
        }
        return false;
    }

    public static boolean hasItem(int id) {
        for (Cart c : allCartItems) {
            if (c.product_id == id) {
                return true;
            }
        }
        return false;
    }

    public static boolean hasItem(TM_ProductInfo product) {
        return hasItem(product.id);
    }

    public static void removeSafely(Cart cart) {
        int cartProductId = -1;
        int cartCategoryId = -1;
        int cartCount = 1;
        if (AppInfo.USE_PARSE_ANALYTICS) {
            try {
                cartProductId = cart.product_id;
                cartCount = cart.count;
                cartCategoryId = cart.getCartItemCategory();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        try {
            cart.delete();
            allCartItems.remove(cart);
            if (cartProductId != -1) {
                AnalyticsHelper.registerAddToCartEvent(cart, -1 * cartCount);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        clearCoupons();
    }

    public static void setPointsPriceDiscount(float pointsPriceDiscount) {
        if (AppInfo.ENABLE_CUSTOM_POINTS) {
            mPointsPriceDiscount = Cart.getTotalPayment() > pointsPriceDiscount
                    ? pointsPriceDiscount
                    : Cart.getTotalPayment();
        }
    }


    public static void removePointsPriceDiscount() {
        mPointsPriceDiscount = 0.0f;
    }

    public static int calculatePointsUsed(float totalPoints) {
        float totalPayment = Cart.getTotalPaymentExcludingCoupons();
        float perPointVal = (float) RewardPoint.getInstance().redeemUnitVal;
        float pointsVal = totalPoints * perPointVal;
        int remainingPoints = (int) ((totalPayment - pointsVal) / perPointVal);
        remainingPoints = remainingPoints > 0 ? remainingPoints : remainingPoints * -1;
        mPointsUsed = (int) totalPayment >= pointsVal ? (int) totalPoints : (int) totalPoints - remainingPoints;
        return mPointsUsed;
    }

    public static float getPointsPriceDiscount() {
        return mPointsPriceDiscount;
    }

    public static float getPointsUsed() {
        return mPointsUsed;
    }

    public void updateMatchedItems(String json) {
        this.matched_items_json = json;
    }

    public static void setCartEventListener(CartEventListener cartEventListener) {
        Cart.mCartEventListener = cartEventListener;
    }

    public static boolean containsBookingProduct() {
        for (Cart cart : allCartItems) {
            TM_ProductInfo productInfo = TM_ProductInfo.findProductById(cart.product_id);
            if (productInfo != null && productInfo.type == TM_ProductInfo.ProductType.BOOKING) {
                return true;
            }
        }
        return false;
    }

    public static int getDepositAmount() {
        int deposit_price = 0;
        for (Cart cart : Cart.getAll()) {
            deposit_price += cart.deposit_price;
        }
        return deposit_price;
    }
}
