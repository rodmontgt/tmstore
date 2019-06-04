package com.utils;

import android.content.Context;
import android.os.Bundle;

import com.facebook.appevents.AppEventsConstants;
import com.facebook.appevents.AppEventsLogger;
import com.google.firebase.analytics.FirebaseAnalytics;
import com.parse.FunctionCallback;
import com.parse.ParseCloud;
import com.parse.ParseException;
import com.twist.dataengine.entities.TM_CategoryInfo;
import com.twist.dataengine.entities.TM_CommonInfo;
import com.twist.dataengine.entities.TM_LineItem;
import com.twist.dataengine.entities.TM_Order;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.BuildConfig;
import com.twist.tmstore.Extras;
import com.twist.tmstore.config.FirebaseAnalyticsConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.entities.Cart;
import com.twist.tmstore.entities.CustomerData;
import com.twist.tmstore.entities.Wishlist;
import com.twist.tmstore.payments.PaymentGateway;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * Created by Twist Mobile on 11/9/2016.
 */

public class AnalyticsHelper {

    private static FirebaseAnalytics mFirebaseAnalytics;
    private static AppEventsLogger mFBAppEventsLogger;

    public static void initContext(Context context) {
        if (FirebaseAnalyticsConfig.isEnabled()) {
            mFirebaseAnalytics = FirebaseAnalytics.getInstance(context);
        }
        if (AppInfo.ENABLE_FACEBOOK_SDK) {
            mFBAppEventsLogger = AppEventsLogger.newLogger(context);
        }
    }

    public static void registerShareProductEvent(TM_ProductInfo product) {
        if (FirebaseAnalyticsConfig.isEnabled()) {
            Bundle bundle = new Bundle();
            bundle.putString(FirebaseAnalytics.Param.ITEM_ID, product.id + "");
            bundle.putString(FirebaseAnalytics.Param.ITEM_NAME, product.title);
            bundle.putString(FirebaseAnalytics.Param.CONTENT_TYPE, "product");
            mFirebaseAnalytics.logEvent("share_product", bundle);
        }
    }

    public static void registerLogoutEvent() {
        if (FirebaseAnalyticsConfig.isEnabled()) {
            Bundle bundle = new Bundle();
            bundle.putString("logout", "logout");
            mFirebaseAnalytics.logEvent("logout", bundle);
        }
    }

    public static void registerVisitScreenEvent(String screenName) {
        if (FirebaseAnalyticsConfig.isEnabled()) {
            Bundle bundle = new Bundle();
            bundle.putString(FirebaseAnalytics.Param.CONTENT_TYPE, screenName);
            mFirebaseAnalytics.logEvent("visit_screen", bundle);
        }
    }

    public static void registerVisitWebPageEvent(String title) {
        if (FirebaseAnalyticsConfig.isEnabled()) {
            Bundle bundle = new Bundle();
            bundle.putString(FirebaseAnalytics.Param.CONTENT_TYPE, "webpage");
            bundle.putString("title", title);
            mFirebaseAnalytics.logEvent("visit_screen", bundle);
        }
    }

    public static void registerOrderEvent(TM_Order order, boolean succeeded) {
        if (FirebaseAnalyticsConfig.isEnabled()) {
            Bundle bundle = new Bundle();
            bundle.putString(FirebaseAnalytics.Param.ITEM_ID, order.id + "");
            bundle.putString(FirebaseAnalytics.Param.TRANSACTION_ID, order.order_number);
            bundle.putString(FirebaseAnalytics.Param.CURRENCY, TM_CommonInfo.currency);
            bundle.putString(FirebaseAnalytics.Param.PRICE, order.subtotal + "");
            bundle.putString(FirebaseAnalytics.Param.VALUE, order.total + "");
            bundle.putString(FirebaseAnalytics.Param.CONTENT_TYPE, "order");
            bundle.putString("payment_method_id", order.payment_details.method_id);
            bundle.putString("payment_method_title", order.payment_details.method_title);

            ArrayList<Bundle> lineItemBundle = new ArrayList<>();
            for (TM_LineItem line_item : order.line_items) {
                Bundle innerBundle = new Bundle();
                innerBundle.putString(FirebaseAnalytics.Param.ITEM_ID, line_item.id + "");
                innerBundle.putString(FirebaseAnalytics.Param.ITEM_NAME, line_item.name);
                innerBundle.putString(FirebaseAnalytics.Param.CONTENT_TYPE, "product");
                lineItemBundle.add(innerBundle);
            }
            bundle.putParcelableArrayList("line_items", lineItemBundle);
            mFirebaseAnalytics.logEvent(FirebaseAnalytics.Event.ECOMMERCE_PURCHASE, bundle);
        }
        if (AppInfo.ENABLE_FACEBOOK_SDK) {
            Bundle parameters = new Bundle();
            parameters.putString(AppEventsConstants.EVENT_PARAM_NUM_ITEMS, Cart.getItemCount() + "");
            parameters.putString(AppEventsConstants.EVENT_PARAM_CONTENT_TYPE, "Order");
            parameters.putString(AppEventsConstants.EVENT_PARAM_CONTENT_ID, order.id + "");
            parameters.putString(AppEventsConstants.EVENT_PARAM_CURRENCY, TM_CommonInfo.currency);
            float purchasePrice = Cart.getTotalPayment();
            mFBAppEventsLogger.logEvent(AppEventsConstants.EVENT_NAME_PURCHASED, purchasePrice, parameters);
        }

        if (AppInfo.USE_PARSE_ANALYTICS) {
            Log.d("-- registerParseOrder[" + order.id + "] --");
            try {
                HashMap<String, Object> params = new HashMap<>();
                params.put("catalog_class_name", "Order_Data");
                params.put("catalog_name", "Order_Id");
                params.put("catalog_value", order.id + "");
                //params.put("customer_data", CustomerData.getInstance()); // pointer for customer
                HashMap<String, Object> catalogObj = new HashMap<>();
                catalogObj.put("Amount", order.total);
                catalogObj.put("Status", order.status);
                catalogObj.put("Email_Id", AppUser.getEmail());
                catalogObj.put("User_Id", order.customer_id + "");
                catalogObj.put("User_Name", AppUser.getInstance().getDisplayName());
                params.put("catalog_Obj", catalogObj);
                registerParseAnalytics(params);
            } catch (Exception e) {
                e.printStackTrace();
            }

            for (TM_LineItem lineItem : order.line_items) {
                registerParsePurchaseProduct(lineItem.product_id, lineItem.quantity, lineItem.total);
            }

            Log.d("-- registerParseCustomerPurchase[" + order.id + "] --");
            try {
                HashMap<String, Object> params = new HashMap<>();
                params.put("catalog_class_name", "CustomerData");
                params.put("catalog_name", "objectId");
                params.put("catalog_value", CustomerData.getInstance().getObjectId());
                HashMap<String, Object> catalogObj = new HashMap<>();
                catalogObj.put("*Current_Day_Purchased_Items", JsonUtils.getPurchasedItemsStringForParse(order));
                params.put("catalog_Obj", catalogObj);
                registerParseAnalytics(params);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    private static void registerParsePurchaseProduct(int productId, int increment, float total) {
        if (AppInfo.USE_PARSE_ANALYTICS) {
            Log.d("-- registerParsePurchaseProduct[" + productId + "] --");
            //for products
            {
                try {
                    HashMap<String, Object> params = new HashMap<>();
                    params.put("catalog_class_name", "Product_Data");
                    params.put("catalog_name", "Product_Id");
                    params.put("catalog_value", productId + "");

                    TM_ProductInfo product = TM_ProductInfo.getProductWithId(productId);
                    String productName = "";
                    String productParentName = "";
                    String productParentId = "";
                    if (product != null) {
                        productName = product.title;
                        if (!product.categories.isEmpty()) {
                            productParentName = product.getFirstCategory().getName();
                            productParentId = product.getFirstCategory().id + "";
                        }
                    }
                    HashMap<String, Object> catalogObj = new HashMap<>();
                    catalogObj.put("Product_Name", productName);
                    catalogObj.put("Category_Name", productParentName);
                    catalogObj.put("Category_Id", productParentId);
                    catalogObj.put("#Current_Day_Sales", increment);
                    catalogObj.put("#Current_Day_Revenue", total);
                    catalogObj.put("#Current_Day_Revenue", total);
                    params.put("catalog_Obj", catalogObj);
                    registerParseAnalytics(params);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            //for categories
            int categoryId = TM_ProductInfo.findProductById(productId).getFirstCategoryId();
            if (categoryId != -1) {
                try {
                    HashMap<String, Object> params = new HashMap<>();
                    params.put("catalog_class_name", "Category_Data");
                    params.put("catalog_name", "Category_Id");
                    params.put("catalog_value", categoryId + "");
                    TM_CategoryInfo category = TM_CategoryInfo.getWithId(categoryId);
                    String categoryParentName = "";
                    String categoryParentId = "";
                    String categoryName = "";
                    if (category != null) {
                        categoryName = category.getName();
                        if (category.parent != null) {
                            categoryParentName = category.parent.getName();
                            categoryParentId = category.parent.id + "";
                        }
                    }

                    HashMap<String, Object> catalogObj = new HashMap<>();
                    catalogObj.put("Category_Name", categoryName);
                    catalogObj.put("Category_Parent_Name", categoryParentName);
                    catalogObj.put("Category_Parent_Id", categoryParentId);
                    catalogObj.put("#Current_Day_Sales", increment);
                    params.put("catalog_Obj", catalogObj);
                    registerParseAnalytics(params);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }


    public static void registerAddToCartEvent(Cart cart, int count) { //no 'cart.count' here as size may vary
        //Remove from cart firebase event
        if (FirebaseAnalyticsConfig.isEnabled()) {
            Bundle bundle = new Bundle();
            bundle.putString(FirebaseAnalytics.Param.ITEM_ID, cart.product_id + "");
            bundle.putString(FirebaseAnalytics.Param.ITEM_NAME, cart.title);
            bundle.putString(FirebaseAnalytics.Param.ITEM_CATEGORY, cart.getCartItemCategory() + "");
            bundle.putString(FirebaseAnalytics.Param.CURRENCY, TM_CommonInfo.currency);
            bundle.putString(FirebaseAnalytics.Param.CONTENT_TYPE, "product");
            bundle.putFloat(FirebaseAnalytics.Param.PRICE, cart.getItemPrice());
            if (count > 0) {
                bundle.putInt(FirebaseAnalytics.Param.QUANTITY, count);
                mFirebaseAnalytics.logEvent(FirebaseAnalytics.Event.ADD_TO_CART, bundle);
            } else {
                bundle.putInt(FirebaseAnalytics.Param.QUANTITY, -1 * count);
                mFirebaseAnalytics.logEvent("remove_from_cart", bundle);
            }
        }

        if (AppInfo.ENABLE_FACEBOOK_SDK) {
            Bundle parameters = new Bundle();
            parameters.putString(AppEventsConstants.EVENT_PARAM_CURRENCY, TM_CommonInfo.currency);
            parameters.putString(AppEventsConstants.EVENT_PARAM_CONTENT_TYPE, "product");
            parameters.putString(AppEventsConstants.EVENT_PARAM_NUM_ITEMS, count + "");
            parameters.putString(AppEventsConstants.EVENT_PARAM_CONTENT_ID, cart.product_id + "");
            mFBAppEventsLogger.logEvent(AppEventsConstants.EVENT_NAME_ADDED_TO_CART, cart.getItemPrice(), parameters);
        }

        //PARSE
        if (AppInfo.USE_PARSE_ANALYTICS) {
            //for product
            {
                try {
                    HashMap<String, Object> params = new HashMap<>();
                    params.put("catalog_class_name", "Product_Data");
                    params.put("catalog_name", "Product_Id");
                    params.put("catalog_value", cart.product_id + "");
                    String productName = cart.product.title;
                    String productParentName = "";
                    String productParentId = "";
                    if (!cart.product.categories.isEmpty()) {
                        productParentName = cart.product.getFirstCategory().getName();
                        productParentId = cart.product.getFirstCategory().id + "";
                    }
                    HashMap<String, Object> catalogObj = new HashMap<>();
                    catalogObj.put("Product_Name", productName);
                    catalogObj.put("Category_Name", productParentName);
                    catalogObj.put("Category_Id", productParentId);
                    catalogObj.put("#Current_day_cart_added", count);
                    params.put("catalog_Obj", catalogObj);
                    registerParseAnalytics(params);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            // fix for a crash when app server config changes and we try to delete an old
            // product from the cart, this bug should never ever produce in release build.
            if (cart.product == null) {
                return;
            }

            //for categories
            if (cart.product.getFirstCategoryId() != -1) {
                int categoryId = cart.product.getFirstCategoryId();
                try {
                    HashMap<String, Object> params = new HashMap<>();
                    params.put("catalog_class_name", "Category_Data");
                    params.put("catalog_name", "Category_Id");
                    params.put("catalog_value", categoryId + "");

                    TM_CategoryInfo category = TM_CategoryInfo.getWithId(categoryId);

                    String categoryParentName = "";
                    String categoryParentId = "";
                    String categoryName = "";

                    if (category != null) {
                        categoryName = category.getName();
                        if (category.parent != null) {
                            categoryParentName = category.parent.getName();
                            categoryParentId = category.parent.id + "";
                        }
                    }

                    HashMap<String, Object> catalogObj = new HashMap<>();
                    catalogObj.put("Category_Name", categoryName);
                    catalogObj.put("Category_Parent_Name", categoryParentName);
                    catalogObj.put("Category_Parent_Id", categoryParentId);
                    catalogObj.put("#Current_day_cart_added", count);
                    params.put("catalog_Obj", catalogObj);
                    registerParseAnalytics(params);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            //for customer
            {
                Log.d("-- registerParseCustomerCart --");
                try {
                    HashMap<String, Object> params = new HashMap<>();
                    params.put("catalog_class_name", "CustomerData");
                    params.put("catalog_name", "objectId");
                    params.put("catalog_value", CustomerData.getInstance().getObjectId());
                    HashMap<String, Object> catalogObj = new HashMap<>();
                    catalogObj.put("Current_Day_Cart_Items", JsonUtils.getCartStringForParse());
                    params.put("catalog_Obj", catalogObj);
                    registerParseAnalytics(params);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public static void registerCartModificationEvent() {
        //only for Parse
        if (AppInfo.USE_PARSE_ANALYTICS) {
            Log.d("-- registerParseCustomerPreviousCart --");
            try {
                HashMap<String, Object> params = new HashMap<>();
                params.put("catalog_class_name", "CustomerData");
                params.put("catalog_name", "objectId");
                params.put("catalog_value", CustomerData.getInstance().getObjectId());
                HashMap<String, Object> catalogObj = new HashMap<>();
                catalogObj.put("stats_recent_cart_items", JsonUtils.getPreviousCartStringForParse());
                params.put("catalog_Obj", catalogObj);
                registerParseAnalytics(params);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    public static void registerReferrerReceivedEvent(String referrerCode) {
        //only for Parse
        if (AppInfo.USE_PARSE_ANALYTICS) {
            try {
                HashMap<String, Object> params = new HashMap<>();
                params.put("catalog_class_name", "CustomerData");
                params.put("catalog_name", "objectId");
                params.put("catalog_value", CustomerData.getInstance().getObjectId());
                HashMap<String, Object> catalogObj = new HashMap<>();
                catalogObj.put("*referrers", referrerCode);
                params.put("catalog_Obj", catalogObj);
                registerParseAnalytics(params);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    public static void registerNotificationOpenEvent(int notificationId) {
        //only for Parse
        if (AppInfo.USE_PARSE_ANALYTICS) {
            try {
                HashMap<String, Object> params = new HashMap<>();
                params.put("catalog_class_name", "CustomerData");

                params.put("catalog_name", "objectId");
                params.put("catalog_value", CustomerData.getInstance().getObjectId());

                HashMap<String, Object> catalogObj = new HashMap<>();
                catalogObj.put("@stats_notification", notificationId);
                //Todo : stats_notification // change this name after you receive from Parse support;
                params.put("catalog_Obj", catalogObj);
                registerParseAnalytics(params);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    public static void registerAddToWishListEvent(Wishlist wishlist) {
        if (FirebaseAnalyticsConfig.isEnabled()) {
            Bundle bundle = new Bundle();
            bundle.putString(FirebaseAnalytics.Param.ITEM_ID, wishlist.product_id + "");
            bundle.putString(FirebaseAnalytics.Param.CURRENCY, TM_CommonInfo.currency);
            bundle.putString(FirebaseAnalytics.Param.ITEM_NAME, wishlist.title);
            bundle.putString(FirebaseAnalytics.Param.CONTENT_TYPE, "product");
            bundle.putInt(FirebaseAnalytics.Param.QUANTITY, 1);
            bundle.putString(FirebaseAnalytics.Param.ITEM_CATEGORY, wishlist.getWishlistItemCategory() + "");
            bundle.putFloat(FirebaseAnalytics.Param.PRICE, wishlist.getItemPrice());
            mFirebaseAnalytics.logEvent(FirebaseAnalytics.Event.ADD_TO_WISHLIST, bundle);
        }

        if (AppInfo.ENABLE_FACEBOOK_SDK) {
            Bundle parameters = new Bundle();
            parameters.putString(AppEventsConstants.EVENT_PARAM_CURRENCY, TM_CommonInfo.currency);
            parameters.putString(AppEventsConstants.EVENT_PARAM_CONTENT_TYPE, "product");
            parameters.putString(AppEventsConstants.EVENT_PARAM_CONTENT_ID, wishlist.product_id + "");
            mFBAppEventsLogger.logEvent(AppEventsConstants.EVENT_NAME_ADDED_TO_WISHLIST, wishlist.getItemPrice(), parameters);
        }

        //PARSE
        if (AppInfo.USE_PARSE_ANALYTICS) {
            //for products
            {
                try {
                    HashMap<String, Object> params = new HashMap<>();
                    params.put("catalog_class_name", "Product_Data");
                    params.put("catalog_name", "Product_Id");
                    params.put("catalog_value", wishlist.product_id + "");
                    HashMap<String, Object> catalogObj = new HashMap<>();
                    String productName = wishlist.product.title;
                    String productParentName = "";
                    String productParentId = "";
                    if (!wishlist.product.categories.isEmpty()) {
                        productParentName = wishlist.product.getFirstCategory().getName();
                        productParentId = wishlist.product.getFirstCategory().id + "";
                    }
                    catalogObj.put("Product_Name", productName);
                    catalogObj.put("Category_Name", productParentName);
                    catalogObj.put("Category_Id", productParentId);
                    catalogObj.put("#Current_day_wish_added", 1);
                    params.put("catalog_Obj", catalogObj);
                    registerParseAnalytics(params);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            //for categories
            if (wishlist.product != null && wishlist.product.getFirstCategoryId() != -1) {
                int categoryId = wishlist.product.getFirstCategoryId();
                try {
                    HashMap<String, Object> params = new HashMap<>();
                    params.put("catalog_class_name", "Category_Data");
                    params.put("catalog_name", "Category_Id");
                    params.put("catalog_value", categoryId + "");

                    HashMap<String, Object> catalogObj = new HashMap<>();
                    TM_CategoryInfo category = TM_CategoryInfo.getWithId(categoryId);
                    String categoryParentName = "";
                    String categoryParentId = "";
                    String categoryName = "";
                    if (category != null) {
                        categoryName = category.getName();
                        if (category.parent != null) {
                            categoryParentName = category.parent.getName();
                            categoryParentId = category.parent.id + "";
                        }
                    }
                    catalogObj.put("Category_Name", categoryName);
                    catalogObj.put("Category_Parent_Name", categoryParentName);
                    catalogObj.put("Category_Parent_Id", categoryParentId);
                    catalogObj.put("#Current_day_wish_added", 1);
                    params.put("catalog_Obj", catalogObj);
                    registerParseAnalytics(params);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            //customers
            {
                try {
                    HashMap<String, Object> params = new HashMap<>();
                    params.put("catalog_class_name", "CustomerData");
                    params.put("catalog_name", "objectId");
                    params.put("catalog_value", CustomerData.getInstance().getObjectId());
                    HashMap<String, Object> catalogObj = new HashMap<>();
                    catalogObj.put("Current_Day_Whishlist_Items", JsonUtils.getWishlistStringForParse());
                    params.put("catalog_Obj", catalogObj);
                    registerParseAnalytics(params);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public static void registerRemoveWishListProductEvent(Wishlist wishlist) {
        if (FirebaseAnalyticsConfig.isEnabled()) {
            Bundle bundle = new Bundle();
            bundle.putString(FirebaseAnalytics.Param.ITEM_ID, wishlist.product_id + "");
            bundle.putString(FirebaseAnalytics.Param.CURRENCY, TM_CommonInfo.currency);
            bundle.putString(FirebaseAnalytics.Param.ITEM_NAME, wishlist.title);
            bundle.putString(FirebaseAnalytics.Param.CONTENT_TYPE, "product");
            bundle.putInt(FirebaseAnalytics.Param.QUANTITY, 1);
            bundle.putString(FirebaseAnalytics.Param.ITEM_CATEGORY, wishlist.getWishlistItemCategory() + "");
            bundle.putFloat(FirebaseAnalytics.Param.PRICE, wishlist.getItemPrice());
            mFirebaseAnalytics.logEvent("remove_from_wishlist", bundle);
        }
    }

    public static void registerVisitProductEvent(TM_ProductInfo product) {
        if (FirebaseAnalyticsConfig.isEnabled()) {
            Bundle bundle = new Bundle();
            bundle.putString(FirebaseAnalytics.Param.ITEM_ID, product.id + "");
            bundle.putString(FirebaseAnalytics.Param.ITEM_NAME, product.title);
            bundle.putString(FirebaseAnalytics.Param.ITEM_CATEGORY, product.getCategoryName());
            bundle.putString(FirebaseAnalytics.Param.CONTENT_TYPE, "product");
            mFirebaseAnalytics.logEvent(FirebaseAnalytics.Event.VIEW_ITEM, bundle);
        }

        if (AppInfo.ENABLE_FACEBOOK_SDK) {
            Bundle parameters = new Bundle();
            parameters.putString(AppEventsConstants.EVENT_PARAM_CURRENCY, TM_CommonInfo.currency);
            parameters.putString(AppEventsConstants.EVENT_PARAM_CONTENT_TYPE, "product");
            parameters.putString(AppEventsConstants.EVENT_PARAM_CONTENT_ID, product.id + "");
            mFBAppEventsLogger.logEvent(AppEventsConstants.EVENT_NAME_VIEWED_CONTENT, product.getActualPrice(), parameters);
        }

        if (AppInfo.USE_PARSE_ANALYTICS) {
            //for products
            {
                try {
                    HashMap<String, Object> params = new HashMap<>();
                    params.put("catalog_class_name", "Product_Data");
                    params.put("catalog_name", "Product_Id");
                    params.put("catalog_value", product.id + "");
                    HashMap<String, Object> catalogObj = new HashMap<>();
                    String productName = product.title;
                    String productParentName = "";
                    String productParentId = "";
                    if (!product.categories.isEmpty()) {
                        productParentName = product.getFirstCategory().getName();
                        productParentId = product.getFirstCategory().id + "";
                    }
                    catalogObj.put("Product_Name", productName);
                    catalogObj.put("Category_Name", productParentName);
                    catalogObj.put("Category_Id", productParentId);
                    catalogObj.put("#Current_day_Product_Visited", 1);
                    params.put("catalog_Obj", catalogObj);
                    registerParseAnalytics(params);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            //for customers
            {
                Log.d("-- registerParseCustomerVisitProduct --");
                try {
                    HashMap<String, Object> params = new HashMap<>();
                    params.put("catalog_class_name", "CustomerData");
                    params.put("catalog_name", "objectId");
                    params.put("catalog_value", CustomerData.getInstance().getObjectId());
                    HashMap<String, Object> catalogObj = new HashMap<>();
                    catalogObj.put("@stats_product_visit", JsonUtils.getProductStringForParse(product));
                    params.put("catalog_Obj", catalogObj);
                    registerParseAnalytics(params);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            //for categories
            int categoryId = product.getFirstCategoryId();
            if (categoryId != -1) {
                try {
                    HashMap<String, Object> params = new HashMap<>();
                    params.put("catalog_class_name", "Category_Data");
                    params.put("catalog_name", "Category_Id");
                    params.put("catalog_value", categoryId + "");
                    HashMap<String, Object> catalogObj = new HashMap<>();
                    TM_CategoryInfo category = TM_CategoryInfo.getWithId(categoryId);
                    String categoryParentName = "";
                    String categoryParentId = "";
                    String categoryName = "";
                    if (category != null) {
                        categoryName = category.getName();
                        if (category.parent != null) {
                            categoryParentName = category.parent.getName();
                            categoryParentId = category.parent.id + "";
                        }
                    }
                    catalogObj.put("Category_Name", categoryName);
                    catalogObj.put("Category_Parent_Name", categoryParentName);
                    catalogObj.put("Category_Parent_Id", categoryParentId);
                    catalogObj.put("#Current_day_Product_Visited", 1);
                    params.put("catalog_Obj", catalogObj);
                    registerParseAnalytics(params);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        } //that was too much, i know. can't deal with that.
    }

    public static void registerVisitCategoryEvent(TM_CategoryInfo category) {
        if (FirebaseAnalyticsConfig.isEnabled()) {
            Bundle bundle = new Bundle();
            bundle.putString(FirebaseAnalytics.Param.ITEM_ID, category.id + "");
            bundle.putString(FirebaseAnalytics.Param.ITEM_NAME, category.getName());
            bundle.putString(FirebaseAnalytics.Param.CONTENT_TYPE, "category");
            mFirebaseAnalytics.logEvent(FirebaseAnalytics.Event.VIEW_ITEM_LIST, bundle);


            Bundle bundle2 = new Bundle();
            bundle2.putString("category_id", category.id + "");
            bundle2.putString("category_name", category.getName());
            bundle2.putString(FirebaseAnalytics.Param.CONTENT_TYPE, "category");
            mFirebaseAnalytics.logEvent("view_category", bundle2);
        }

        if (AppInfo.ENABLE_FACEBOOK_SDK) {
            Bundle parameters = new Bundle();
            parameters.putString(AppEventsConstants.EVENT_PARAM_CURRENCY, TM_CommonInfo.currency);
            parameters.putString(AppEventsConstants.EVENT_PARAM_CONTENT_TYPE, "category");
            parameters.putString(AppEventsConstants.EVENT_PARAM_CONTENT_ID, category.id + "");
            mFBAppEventsLogger.logEvent(AppEventsConstants.EVENT_NAME_VIEWED_CONTENT, parameters);
        }

        if (AppInfo.USE_PARSE_ANALYTICS) {
            Log.d("-- registerParseVisitCategory[" + category.id + "] --");
            if (category.id != -1) {
                //for category
                {
                    try {
                        HashMap<String, Object> params = new HashMap<>();
                        params.put("catalog_class_name", "Category_Data");
                        params.put("catalog_name", "Category_Id");
                        params.put("catalog_value", category.id + "");
                        String categoryParentName = "";
                        String categoryParentId = "";
                        if (category.parent != null) {
                            categoryParentName = category.parent.getName();
                            categoryParentId = category.parent.id + "";
                        }
                        HashMap<String, Object> catalogObj = new HashMap<>();
                        catalogObj.put("Category_Name", category.getName());
                        catalogObj.put("Category_Parent_Name", categoryParentName);
                        catalogObj.put("Category_Parent_Id", categoryParentId);
                        catalogObj.put("#Current_Day_Category_Visit", 1);
                        params.put("catalog_Obj", catalogObj);
                        registerParseAnalytics(params);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }

                //for customer
                {
                    try {
                        HashMap<String, Object> params = new HashMap<>();
                        params.put("catalog_class_name", "CustomerData");
                        params.put("catalog_name", "objectId");
                        params.put("catalog_value", CustomerData.getInstance().getObjectId());
                        HashMap<String, Object> catalogObj = new HashMap<>();
                        catalogObj.put("@stats_category_visit", JsonUtils.getCategoryStringForParse(category));
                        params.put("catalog_Obj", catalogObj);
                        registerParseAnalytics(params);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }

    public static void registerPaymentEvent(PaymentGateway paymentGateway) {
        if (FirebaseAnalyticsConfig.isEnabled()) {
            Bundle bundle = new Bundle();
            bundle.putString("payment_method_id", paymentGateway.getId());
            bundle.putString("payment_method_title", paymentGateway.getTitle());
            mFirebaseAnalytics.logEvent(FirebaseAnalytics.Event.ADD_PAYMENT_INFO, bundle);
        }
    }

    public static void registerClickBannerEvent(String type, int id) {
        if (FirebaseAnalyticsConfig.isEnabled()) {
            Bundle bundle = new Bundle();
            bundle.putString(FirebaseAnalytics.Param.ITEM_ID, id + "");
            bundle.putString("banner_type", type);
            mFirebaseAnalytics.logEvent("visit_banner", bundle);
        }
    }

    public static void registerClickApplyCouponEvent(String couponCode) {
        if (FirebaseAnalyticsConfig.isEnabled()) {
            Bundle bundle = new Bundle();
            bundle.putString(FirebaseAnalytics.Param.COUPON, couponCode);
            mFirebaseAnalytics.logEvent("used_coupon", bundle);
        }
    }

    public static void registerSearchEvent(String text, boolean found) {
        if (FirebaseAnalyticsConfig.isEnabled()) {
            Bundle bundle = new Bundle();
            bundle.putString(FirebaseAnalytics.Param.SEARCH_TERM, text);
            bundle.putString(FirebaseAnalytics.Param.VALUE, found + "");
            mFirebaseAnalytics.logEvent(FirebaseAnalytics.Event.SEARCH, bundle);
        }

        if (AppInfo.ENABLE_FACEBOOK_SDK) {
            Bundle parameters = new Bundle();
            parameters.putString(AppEventsConstants.EVENT_PARAM_CONTENT_TYPE, "Search");
            parameters.putString(AppEventsConstants.EVENT_PARAM_SEARCH_STRING, text);
            parameters.putString(AppEventsConstants.EVENT_PARAM_SUCCESS, found + "");
            mFBAppEventsLogger.logEvent(AppEventsConstants.EVENT_NAME_SEARCHED, parameters);
        }
    }

    public static void registerPaymentEvent(TM_Order order, PaymentGateway paymentGateway) {
        if (FirebaseAnalyticsConfig.isEnabled()) {
            Bundle bundle = new Bundle();
            bundle.putString(FirebaseAnalytics.Param.ITEM_ID, order.id + "");
            bundle.putString(FirebaseAnalytics.Param.TRANSACTION_ID, order.order_number);
            bundle.putString(FirebaseAnalytics.Param.CURRENCY, TM_CommonInfo.currency);
            bundle.putString(FirebaseAnalytics.Param.PRICE, order.subtotal + "");
            bundle.putString(FirebaseAnalytics.Param.VALUE, order.total + "");
            bundle.putString(FirebaseAnalytics.Param.QUANTITY, order.line_items.size() + "");
            bundle.putString("payment_method_id", paymentGateway.getId());
            bundle.putString("payment_method_title", paymentGateway.getTitle());
            mFirebaseAnalytics.logEvent(FirebaseAnalytics.Event.BEGIN_CHECKOUT, bundle);
            Bundle bundle2 = new Bundle();
            bundle2.putString(FirebaseAnalytics.Param.QUANTITY, order.line_items.size() + "");
            bundle2.putString(FirebaseAnalytics.Param.CONTENT_TYPE, "product");
            mFirebaseAnalytics.logEvent("no_of_orders", bundle2);
        }
        if (AppInfo.ENABLE_FACEBOOK_SDK) {
            Bundle parameters = new Bundle();
            parameters.putString(AppEventsConstants.EVENT_PARAM_CONTENT_TYPE, "Checkout");
            parameters.putString(AppEventsConstants.EVENT_PARAM_CONTENT_ID, "0");
            parameters.putString(AppEventsConstants.EVENT_PARAM_NUM_ITEMS, order.line_items.size() + "");
            parameters.putString(AppEventsConstants.EVENT_PARAM_PAYMENT_INFO_AVAILABLE, true + "");
            parameters.putString(AppEventsConstants.EVENT_PARAM_CURRENCY, TM_CommonInfo.currency);
            mFBAppEventsLogger.logEvent(AppEventsConstants.EVENT_NAME_INITIATED_CHECKOUT, order.line_items.size(), parameters);
        }

        //no such event for parse
    }


    public static void registerSignUpEvent(String method) {
        if (FirebaseAnalyticsConfig.isEnabled()) {
            Bundle bundle = new Bundle();
            bundle.putString(FirebaseAnalytics.Param.SIGN_UP_METHOD, method);
            mFirebaseAnalytics.logEvent(FirebaseAnalytics.Event.SIGN_UP, bundle);
        }
        if (AppInfo.ENABLE_FACEBOOK_SDK) {
            Bundle parameters = new Bundle();
            parameters.putString(AppEventsConstants.EVENT_PARAM_REGISTRATION_METHOD, method);
            mFBAppEventsLogger.logEvent(AppEventsConstants.EVENT_NAME_COMPLETED_REGISTRATION, parameters);
        }
        //no such event for parse
    }

    public static void registerCustomerUpdateEvent() {
        //only parse here
        if (AppInfo.USE_PARSE_ANALYTICS) {
            Log.d("-- registerParseCustomerUpdate --");
            try {
                HashMap<String, Object> params = new HashMap<>();
                params.put("catalog_class_name", "CustomerData");
                params.put("catalog_name", "objectId");
                params.put("catalog_value", CustomerData.getInstance().getObjectId());
                HashMap<String, Object> catalogObj = new HashMap<>();
                catalogObj.put("Customer_Data", JsonUtils.getCustomerDataStringForParse());
                params.put("catalog_Obj", catalogObj);
                registerParseAnalytics(params);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    public static void registerSignInEvent(String method) {
        if (FirebaseAnalyticsConfig.isEnabled()) {
            Bundle bundle = new Bundle();
            bundle.putString(FirebaseAnalytics.Param.SIGN_UP_METHOD, method);
            mFirebaseAnalytics.logEvent(FirebaseAnalytics.Event.LOGIN, bundle);
        }

        if (AppInfo.ENABLE_FACEBOOK_SDK) {
            Bundle parameters = new Bundle();
            parameters.putString(AppEventsConstants.EVENT_PARAM_REGISTRATION_METHOD, method);
            mFBAppEventsLogger.logEvent(AppEventsConstants.EVENT_NAME_COMPLETED_REGISTRATION, parameters);
        }
        //no such event for parse
    }

    private static void registerParseAnalytics(final HashMap<String, Object> params) {
        if (BuildConfig.DEMO_VERSION)
            return;
        ParseCloud.callFunctionInBackground("update_catalog_data", params, new FunctionCallback<Object>() {
            @Override
            public void done(Object object, ParseException e) {
                if (e != null) {
                    e.printStackTrace();
                }
            }
        });
    }
}
