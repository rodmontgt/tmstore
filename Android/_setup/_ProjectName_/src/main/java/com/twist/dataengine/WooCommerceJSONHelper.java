package com.twist.dataengine;

import com.google.gson.Gson;
import com.twist.dataengine.entities.AuctionInfo;
import com.twist.dataengine.entities.BlogItem;
import com.twist.dataengine.entities.BookingInfo;
import com.twist.dataengine.entities.CurrencyItem;
import com.twist.dataengine.entities.OrderBookingInfo;
import com.twist.dataengine.entities.PaymentDetail;
import com.twist.dataengine.entities.PincodeSetting;
import com.twist.dataengine.entities.ProductLocation;
import com.twist.dataengine.entities.QuantityRule;
import com.twist.dataengine.entities.RawCategory;
import com.twist.dataengine.entities.RawProductInfo;
import com.twist.dataengine.entities.RawShipping;
import com.twist.dataengine.entities.RewardPoint;
import com.twist.dataengine.entities.SellerInfo;
import com.twist.dataengine.entities.ShortAttribute;
import com.twist.dataengine.entities.TM_AccountDetail;
import com.twist.dataengine.entities.TM_Address;
import com.twist.dataengine.entities.TM_Attribute;
import com.twist.dataengine.entities.TM_Bundle;
import com.twist.dataengine.entities.TM_CategoryInfo;
import com.twist.dataengine.entities.TM_CommonInfo;
import com.twist.dataengine.entities.TM_ComparableFilter;
import com.twist.dataengine.entities.TM_Coupon;
import com.twist.dataengine.entities.TM_Dimension;
import com.twist.dataengine.entities.TM_FilterAttribute;
import com.twist.dataengine.entities.TM_FilterAttributeOption;
import com.twist.dataengine.entities.TM_LineItem;
import com.twist.dataengine.entities.TM_MixMatch;
import com.twist.dataengine.entities.TM_Order;
import com.twist.dataengine.entities.TM_PaymentGateway;
import com.twist.dataengine.entities.TM_ProductFilter;
import com.twist.dataengine.entities.TM_ProductImage;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.dataengine.entities.TM_ProductReview;
import com.twist.dataengine.entities.TM_SimpleCart;
import com.twist.dataengine.entities.TM_Tax;
import com.twist.dataengine.entities.TM_Variation;
import com.twist.dataengine.entities.TM_VariationAttribute;
import com.twist.dataengine.entities.TM_WaitList;
import com.twist.dataengine.entities.TM_WishList;
import com.twist.tmstore.entities.DepositInfo;
import com.twist.tmstore.entities.ProductAddons;
import com.twist.tmstore.entities.RolePrice;
import com.utils.CurrencyHelper;
import com.utils.DataHelper;
import com.utils.JsonHelper;
import com.utils.TaxHelper;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

public class WooCommerceJSONHelper {

    private static Comparator productAttributeComparator = new Comparator<TM_Attribute>() {
        @Override
        public int compare(TM_Attribute attribute1, TM_Attribute attribute2) {
            return (attribute1.position - attribute2.position);
        }
    };

    public static TM_Order parseOrder(String jsonStringContent) throws JSONException {
        DataHelper.log("-- parseOrder::jsonStringContent: [" + jsonStringContent + "] --");
        JSONObject jMainObject = DataHelper.safeJsonObject(jsonStringContent);
        JSONObject orderInfoJson = jMainObject.getJSONObject("order");
        return parseOrder(orderInfoJson);

    }

    public static TM_Order parseOrder(JSONObject orderInfoJson) throws JSONException {
        TM_Order order = new TM_Order();

        order.id = orderInfoJson.getInt("id");
        order.order_number = orderInfoJson.getString("order_number");
        order.created_at = orderInfoJson.getString("created_at");
        order.updated_at = orderInfoJson.getString("updated_at");
        order.completed_at = orderInfoJson.getString("completed_at");
        order.status = orderInfoJson.getString("status");
        order.currency = orderInfoJson.getString("currency");
        order.total = DataHelper.safeFloat(orderInfoJson.getString("total"));
        order.subtotal = orderInfoJson.getString("subtotal");
        order.total_line_items_quantity = orderInfoJson.getInt("total_line_items_quantity");
        order.total_tax = Float.parseFloat(orderInfoJson.getString("total_tax"));
        order.total_shipping = Float.parseFloat(orderInfoJson.getString("total_shipping"));
        order.cart_tax = Float.parseFloat(orderInfoJson.getString("cart_tax"));
        order.shipping_tax = Float.parseFloat(orderInfoJson.getString("shipping_tax"));
        order.total_discount = Float.parseFloat(orderInfoJson.getString("total_discount"));
        order.shipping_methods = orderInfoJson.getString("shipping_methods");
        JSONObject billing_address_json = orderInfoJson.getJSONObject("billing_address");
        order.billing_address = parseAddress(billing_address_json);

        JSONObject shipping_address_json = orderInfoJson.getJSONObject("shipping_address");
        order.shipping_address = parseAddress(shipping_address_json);


        JSONObject payment_details_json = orderInfoJson.getJSONObject("payment_details");
        {
            order.payment_details = parsePaymentDetail(payment_details_json);
        }

        //TM_Address billing_address;
        //TM_Address shipping_address;
        order.note = orderInfoJson.getString("note");
        order.customer_id = orderInfoJson.getInt("customer_id");
        order.view_order_url = orderInfoJson.getString("view_order_url");

        JSONArray line_items_json = orderInfoJson.getJSONArray("line_items");
        for (int j = 0; j < line_items_json.length(); j++) {
            try {
                JSONObject lineItemJson = line_items_json.getJSONObject(j);
                TM_LineItem lineItem = parseLineItem(lineItemJson);
                order.line_items.add(lineItem);
            } catch (JSONException ex) {
                ex.printStackTrace();
            }
        }
        return order;
    }

    public static TM_Coupon parseCoupon(JSONObject couponInfoJson) throws JSONException {
        TM_Coupon coupon = new TM_Coupon();

        coupon.id = couponInfoJson.getInt("id");
        coupon.code = couponInfoJson.getString("code");
        coupon.type = couponInfoJson.getString("type");
        coupon.amount = DataHelper.safeFloat(couponInfoJson.getString("amount"));
        coupon.individual_use = couponInfoJson.getBoolean("individual_use");

        JSONArray json_product_ids = couponInfoJson.getJSONArray("product_ids");
        for (int i = 0; i < json_product_ids.length(); i++) {
            coupon.product_ids.add(json_product_ids.getInt(i));
        }

        JSONArray json_exclude_product_ids = couponInfoJson.getJSONArray("exclude_product_ids");
        for (int i = 0; i < json_exclude_product_ids.length(); i++) {
            coupon.exclude_product_ids.add(json_exclude_product_ids.getInt(i));
        }

        coupon.usage_limit = DataHelper.safeInt(couponInfoJson, "usage_limit", 99999);
        coupon.usage_limit_per_user = DataHelper.safeInt(couponInfoJson, "usage_limit_per_user", 99999);

        coupon.limit_usage_to_x_items = couponInfoJson.getInt("limit_usage_to_x_items");
        coupon.usage_count = couponInfoJson.getInt("usage_count");
        try {
            DateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
            coupon.expiry_date = sdf.parse(couponInfoJson.getString("expiry_date"));
        } catch (ParseException e) {
            coupon.expiry_date = null;
            //e.printStackTrace();
        }

        coupon.enable_free_shipping = couponInfoJson.getBoolean("enable_free_shipping");
        JSONArray json_product_category_ids = couponInfoJson.getJSONArray("product_category_ids");
        for (int i = 0; i < json_product_category_ids.length(); i++) {
            coupon.product_category_ids.add(json_product_category_ids.getInt(i));
        }
        JSONArray json_exclude_product_category_ids = couponInfoJson.getJSONArray("exclude_product_category_ids");
        for (int i = 0; i < json_exclude_product_category_ids.length(); i++) {
            coupon.exclude_product_category_ids.add(json_exclude_product_category_ids.getInt(i));
        }
        coupon.exclude_sale_items = couponInfoJson.getBoolean("exclude_sale_items");
        coupon.minimum_amount = DataHelper.safeFloat(couponInfoJson.getString("minimum_amount"));
        coupon.maximum_amount = DataHelper.safeFloat(couponInfoJson.getString("maximum_amount"));
        JSONArray json_customer_emails = couponInfoJson.getJSONArray("customer_emails");
        for (int i = 0; i < json_customer_emails.length(); i++) {
            coupon.customer_emails.add(json_customer_emails.getString(i));
        }
        coupon.description = couponInfoJson.getString("description");

        return coupon;
    }

    public static TM_ProductFilter parseFilterPrices(JSONObject jsonObject) throws JSONException {
        int c_id = DataHelper.safeInt(jsonObject, "c_id", -1);
        TM_ProductFilter filter = TM_ProductFilter.getWithCategoryId(c_id);
        filter.maxPrice = DataHelper.safeFloatPrice(jsonObject.getString("max_limit"));
        filter.minPrice = DataHelper.safeFloatPrice(jsonObject.getString("min_limit"));
        return filter;
    }

    public static TM_ComparableFilter parseComparableFilterFromJson(String jsonStringContent) throws JSONException {
        jsonStringContent = DataHelper.safeJsonObject(jsonStringContent).toString();
        TM_ComparableFilter tm_comparableFilter = new Gson().fromJson(jsonStringContent, TM_ComparableFilter.class);
        return tm_comparableFilter;
    }

    public static TM_ProductFilter parseFilterAttributes(JSONObject jsonObject) throws JSONException {
        int c_id = DataHelper.safeInt(jsonObject, "c_id", -1);
        TM_ProductFilter filter = TM_ProductFilter.getWithCategoryId(c_id);
        JSONArray attribute = jsonObject.getJSONArray("attribute");
        for (int i = 0; i < attribute.length(); i++) {
            JSONObject attribute_data = attribute.getJSONObject(i).getJSONObject("attribute_data");
            JSONArray attribute_var_data = attribute.getJSONObject(i).getJSONArray("attribute_var_data");
            TM_FilterAttribute filterAttribute = new TM_FilterAttribute();
            filterAttribute.attribute = attribute_data.getString("attribute");
            filterAttribute.query_type = attribute_data.getString("query_type");
            for (int j = 0; j < attribute_var_data.length(); j++) {
                TM_FilterAttributeOption option = new TM_FilterAttributeOption();
                option.name = attribute_var_data.getJSONObject(j).getString("name");
                option.taxo = attribute_var_data.getJSONObject(j).getString("taxonomy");
                option.slug = attribute_var_data.getJSONObject(j).getString("slug");
                filterAttribute.options.add(option);
            }
            filter.addAttribute(filterAttribute);
        }
        return filter;
    }

    public static TM_PaymentGateway parseJsonAndCreateGateway(JSONObject gateway) throws JSONException {
        DataHelper.log("-- parseJsonAndCreateGateway:[" + gateway.toString() + "] --");
        TM_PaymentGateway paymentGateway = new TM_PaymentGateway();
        paymentGateway.id = gateway.getString("id");
        paymentGateway.title = gateway.getString("title");
        paymentGateway.description = DataHelper.safeString(gateway, "description");

        paymentGateway.icon = gateway.getString("icon");
        paymentGateway.order_button_text = gateway.getString("order_button_text");
        try {
            paymentGateway.enabled = gateway.getString("enabled").equalsIgnoreCase("yes");
        } catch (Exception e) {
            paymentGateway.enabled = false;
        }
        paymentGateway.instructions = DataHelper.safeString(gateway, "instructions");

        if (gateway.has("account_details")) {
            paymentGateway.account_details = parseJsonAndCreateAccountDetails(gateway.getJSONArray("account_details"));
        }

        if (gateway.has("settings")) {
            paymentGateway.settings = parseJsonAndCreateGatewaySettings(gateway);
        }
        return paymentGateway;
    }

    public static TM_SimpleCart parseJsonAndCreateSimpleCart(JSONObject gateway) throws JSONException {
        DataHelper.log("-- parseJsonAndCreateSimpleCart:[" + gateway.toString() + "] --");
        TM_SimpleCart simpleCart = new TM_SimpleCart();
        simpleCart.title = gateway.getString("title");

        simpleCart.pid = gateway.getInt("pid");
        simpleCart.vid = gateway.getInt("vid");

        //TODO check if taxable property available in gateway
        if (gateway.has("taxable")) {
            simpleCart.taxable = gateway.getBoolean("taxable");
        }

        if (gateway.has("index")) {
            simpleCart.index = gateway.getInt("index");
        } else {
            simpleCart.index = -2; // for backward compatibility
        }

        simpleCart.price = TM_CommonInfo.getPriceIncludingTax1((float) gateway.getDouble("price"), simpleCart.taxable);
        try {
            simpleCart.regular_price = TM_CommonInfo.getPriceIncludingTax1((float) gateway.getDouble("regular_price"), simpleCart.taxable);
        } catch (JSONException ignored) {
        }
        try {
            simpleCart.sale_price = TM_CommonInfo.getPriceIncludingTax1((float) gateway.getDouble("sale_price"), simpleCart.taxable);
        } catch (JSONException ignored) {
        }

        TaxHelper.setPriceFromTax(simpleCart);
        RolePrice.applyPrice(simpleCart);

        if (gateway.has("weight")) {
            simpleCart.weight = (double) DataHelper.safeFloat(gateway.getString("weight"));
        }

        simpleCart.img = gateway.getString("img");
        simpleCart.url = gateway.getString("url");
        simpleCart.type = gateway.getString("type");

        simpleCart.manage_stock = gateway.getString("manage_stock");
        simpleCart.stock_status = gateway.getString("stock_status");
        simpleCart.manage_stock = gateway.getString("manage_stock");
        simpleCart.backorders = gateway.getString("backorders");
        simpleCart.total_stock = DataHelper.safeIntOrString(gateway, "total_stock", 0);

        return simpleCart;
    }

    public static List<TM_Order> parseJsonAndCreateOrders(String jsonStringContent) {
        List<TM_Order> orders_list = new ArrayList<>();
        try {
            JSONObject jMainObject = DataHelper.safeJsonObject(jsonStringContent);
            JSONArray orders = jMainObject.getJSONArray("orders");
            for (int i = 0; i < orders.length(); i++) {
                JSONObject orderInfoJson = orders.getJSONObject(i);
                TM_Order order = WooCommerceJSONHelper.parseOrder(orderInfoJson);
                orders_list.add(order);
            }
        } catch (JSONException je) {
            je.printStackTrace();
        }
        return orders_list;
    }

    public static void parseOrderDeliverySlots(String jsonString, List<TM_Order> orders) throws JSONException {
        JSONObject jsonObject = DataHelper.safeJsonObject(jsonString);
        JSONArray orderJsonArray = jsonObject.getJSONArray("data");
        for (int i = 0; i < orderJsonArray.length(); i++) {
            JSONObject orderJson = orderJsonArray.getJSONObject(i);
            int orderID = orderJson.getInt("order_id");
            for (TM_Order tm_order : orders) {
                if (tm_order.id == orderID) {
                    tm_order.deliveryDate = orderJson.getString("date");
                    tm_order.deliveryTime = orderJson.getString("time");
                    break;
                }
            }
        }
    }

    public static void parseOrderMeta(String jsonString, List<TM_Order> orders) throws JSONException {
        JSONArray orderJsonArray = DataHelper.safeJsonArray(jsonString);
        for (int i = 0; i < orderJsonArray.length(); i++) {
            JSONObject orderJson = orderJsonArray.getJSONObject(i);
            int orderID = orderJson.getInt("order_id");
            for (TM_Order tm_order : orders) {
                if (tm_order.id == orderID) {
                    tm_order.billing_address.latitude = tm_order.shipping_address.latitude = orderJson.getString("latitude");
                    tm_order.billing_address.longitude = tm_order.shipping_address.longitude = orderJson.getString("longitude");
                    break;
                }
            }
        }
    }

    public static void parseOrderBookingSlots(String jsonString, List<TM_Order> orders) throws JSONException {
        JSONArray orderJsonArray = DataHelper.safeJsonArray(jsonString);
        for (int i = 0; i < orderJsonArray.length(); i++) {
            JSONObject orderJson = orderJsonArray.getJSONObject(i);
            OrderBookingInfo orderBookingInfo = new OrderBookingInfo();

            int orderID = orderJson.getInt("order_id");
            for (TM_Order tm_order : orders) {
                if (tm_order.id == orderID) {

                    orderBookingInfo.order_id = orderJson.getInt("order_id");
                    orderBookingInfo.enable_payment = orderJson.getBoolean("enable_payment");

                    if (!orderBookingInfo.bookingStatusList.isEmpty())
                        orderBookingInfo.bookingStatusList.clear();

                    JSONArray bookingStatusJsonArray = orderJson.getJSONArray("booking_status");
                    for (int k = 0; k < bookingStatusJsonArray.length(); k++) {

                        JSONObject bookingStatusJsonObject = bookingStatusJsonArray.getJSONObject(k);
                        OrderBookingInfo.BookingInfoStatus bookingInfoStatus = new OrderBookingInfo.BookingInfoStatus();

                        if (bookingStatusJsonObject.has("booking_id"))
                            bookingInfoStatus.booking_id = bookingStatusJsonObject.getInt("booking_id");

                        if (bookingStatusJsonObject.has("bid"))
                            bookingInfoStatus.booking_date = DataHelper.safeString(bookingStatusJsonObject, "booking_date");

                        if (bookingStatusJsonObject.has("booking_start"))
                            bookingInfoStatus.booking_start = DataHelper.safeString(bookingStatusJsonObject, "booking_start");

                        if (bookingStatusJsonObject.has("booking_end"))
                            bookingInfoStatus.booking_end = DataHelper.safeString(bookingStatusJsonObject, "booking_end");

                        if (bookingStatusJsonObject.has("status"))
                            bookingInfoStatus.status = DataHelper.safeString(bookingStatusJsonObject, "status");

                        orderBookingInfo.bookingStatusList.add(bookingInfoStatus);
                    }
                    tm_order.orderBookingInfo = orderBookingInfo;
                }
            }
        }
    }


    public static List<TM_Tax> parseTaxes(String jsonStringContent) throws JSONException {
        List<TM_Tax> taxList = new ArrayList<>();
        JSONObject jMainObject = DataHelper.safeJsonObject(jsonStringContent);
        JSONArray taxes = jMainObject.getJSONArray("taxes");
        for (int i = 0; i < taxes.length(); i++) {
            try {
                JSONObject orderInfoJson = taxes.getJSONObject(i);
                TM_Tax tax = WooCommerceJSONHelper.parseTax(orderInfoJson);
                taxList.add(tax);
            } catch (JSONException je) {
                je.printStackTrace();
            }
        }
        return taxList;
    }

    public static TM_Tax parseTax(JSONObject taxJson) throws JSONException {
        TM_Tax tax = new TM_Tax(taxJson.getInt("id"));
        tax.setCountry(taxJson.getString("country"));
        tax.setState(taxJson.getString("state"));
        tax.setPostcode(taxJson.getString("postcode"));
        tax.setCity(taxJson.getString("city"));
        tax.setRate(taxJson.getString("rate"));
        tax.setName(taxJson.getString("name"));
        tax.setPriority(taxJson.getInt("priority"));
        tax.setCompound(taxJson.getBoolean("compound"));
        tax.setShipping(taxJson.getBoolean("shipping"));
        tax.setOrder(taxJson.getInt("order"));
        tax.setTaxClass(taxJson.getString("class"));
        return tax;
    }

    public static TM_LineItem parseLineItem(JSONObject lineItemJson) throws JSONException {
        //DataHelper.log("------------------------------------------\n");
        //DataHelper.log(lineItemJson.toString());
        //DataHelper.log("------------------------------------------\n");

        TM_LineItem lineItem = new TM_LineItem();

        lineItem.id = lineItemJson.getInt("id");
        lineItem.subtotal = Float.parseFloat(lineItemJson.getString("subtotal"));
        lineItem.subtotal_tax = Float.parseFloat(lineItemJson.getString("subtotal_tax"));
        lineItem.total = Float.parseFloat(lineItemJson.getString("total"));
        lineItem.total_tax = Float.parseFloat(lineItemJson.getString("total_tax"));
        lineItem.price = Float.parseFloat(lineItemJson.getString("price"));
        lineItem.quantity = lineItemJson.getInt("quantity");
        lineItem.tax_class = lineItemJson.getString("tax_class");
        lineItem.name = lineItemJson.getString("name");
        lineItem.product_id = lineItemJson.getInt("product_id");
        lineItem.sku = lineItemJson.getString("sku");

        JSONArray meta = lineItemJson.getJSONArray("meta");
        String strMeta = "";
        for (int i = 0; i < meta.length(); i++) {
            JSONObject metaObject = meta.getJSONObject(i);
            strMeta += metaObject.getString("label") + ":" + metaObject.getString("value") + " | ";
        }
        if (strMeta.length() > 3) {
            strMeta = strMeta.substring(0, strMeta.length() - 3);
        }
        lineItem.meta = strMeta;
        return lineItem;
    }

    public static PaymentDetail parsePaymentDetail(JSONObject payment_details_json) throws JSONException {
        PaymentDetail paymentDetail = new PaymentDetail();

        paymentDetail.method_id = payment_details_json.getString("method_id");
        paymentDetail.method_title = payment_details_json.getString("method_title");
        paymentDetail.paid = payment_details_json.getBoolean("paid");

        return paymentDetail;
    }

    public static TM_Address parseAddress(JSONObject json_address) throws JSONException {
        TM_Address address = new TM_Address();
        address.first_name = DataHelper.safeString(json_address, "first_name");
        address.last_name = DataHelper.safeString(json_address, "last_name");
        address.company = DataHelper.safeString(json_address, "company");
        address.address_1 = DataHelper.safeString(json_address, "address_1");
        address.address_2 = DataHelper.safeString(json_address, "address_2");
        address.city = DataHelper.safeString(json_address, "city");
        address.state = DataHelper.safeString(json_address, "state");
        address.postcode = DataHelper.safeString(json_address, "postcode");
        address.country = DataHelper.safeString(json_address, "country");
        address.email = DataHelper.safeString(json_address, "email");
        address.phone = DataHelper.safeString(json_address, "phone");
        return address;
    }

    public static TM_CategoryInfo parseRawCategory(JSONObject categoryInfoJson) throws JSONException {
        TM_CategoryInfo category = TM_CategoryInfo.getWithId(categoryInfoJson.getInt("id"));
        category.setName(DataHelper.safeString(categoryInfoJson, "name"));
        category.slug = DataHelper.safeString(categoryInfoJson, "slug");
        try {
            String img_url = DataHelper.safeString(categoryInfoJson, "img_url");
            img_url = DataHelper.getResizedImageUrl(img_url);
            category.image = img_url;
        } catch (Exception e) {
            e.printStackTrace();
            category.image = "";
        }
        category.tempSlugDigit = categoryInfoJson.getInt("id");
        category.count = categoryInfoJson.getInt("count");
        category.setParent(TM_CategoryInfo.getWithId(categoryInfoJson.getInt("parent")));
        return category;
    }

    public static TM_CategoryInfo parseCategory(JSONObject categoryInfoJson) throws JSONException {
        TM_CategoryInfo category = TM_CategoryInfo.getWithId(categoryInfoJson.getInt("id"));
        category.setName(DataHelper.safeString(categoryInfoJson, "name"));
        category.slug = DataHelper.safeString(categoryInfoJson, "slug");
        category.description = DataHelper.safeString(categoryInfoJson, "description");
        category.display = DataHelper.safeString(categoryInfoJson, "display");
        category.image = DataHelper.safeString(categoryInfoJson, "image");
        category.count = DataHelper.safeInt(categoryInfoJson, "count", 0);
        category.tempSlugDigit = categoryInfoJson.getInt("id");
        /*
        try
    	{
    		category.tempSlugDigit = Integer.parseInt(category.slugs);
    	}
    	catch(Exception e)
    	{
    		category.tempSlugDigit = 999;
    		e.printStackTrace();
    	}
    	*/

        category.setParent(TM_CategoryInfo.getWithId(categoryInfoJson.getInt("parent")));

        return category;
    }

    public static TM_ProductInfo.TM_DeliveryInfo parseProductDeliveryInfo(String jsonStringContent, TM_ProductInfo product) throws JSONException {

        JSONObject deliveryInfo_JSON = DataHelper.safeJsonObject(jsonStringContent);

        TM_ProductInfo.TM_DeliveryInfo deliveryInfo = new TM_ProductInfo.TM_DeliveryInfo();

        deliveryInfo.prdd_enable_date = DataHelper.safeString(deliveryInfo_JSON, "prdd_enable_date");
        deliveryInfo.prdd_enable_time = DataHelper.safeString(deliveryInfo_JSON, "prdd_enable_time");
        deliveryInfo.prdd_recurring_chk = DataHelper.safeString(deliveryInfo_JSON, "prdd_recurring_chk");

        JSONObject delivery_recurringJson = deliveryInfo_JSON.getJSONObject("prdd_recurring");
        deliveryInfo.prdd_weekday_0 = DataHelper.safeString(delivery_recurringJson, "prdd_weekday_0");
        deliveryInfo.prdd_weekday_1 = DataHelper.safeString(delivery_recurringJson, "prdd_weekday_1");
        deliveryInfo.prdd_weekday_2 = DataHelper.safeString(delivery_recurringJson, "prdd_weekday_2");
        deliveryInfo.prdd_weekday_3 = DataHelper.safeString(delivery_recurringJson, "prdd_weekday_3");
        deliveryInfo.prdd_weekday_4 = DataHelper.safeString(delivery_recurringJson, "prdd_weekday_4");
        deliveryInfo.prdd_weekday_5 = DataHelper.safeString(delivery_recurringJson, "prdd_weekday_5");
        deliveryInfo.prdd_weekday_6 = DataHelper.safeString(delivery_recurringJson, "prdd_weekday_6");
        deliveryInfo.prdd_minimum_number_days = DataHelper.safeInt(deliveryInfo_JSON, "prdd_minimum_number_days", 0);
        deliveryInfo.prdd_maximum_number_days = DataHelper.safeInt(deliveryInfo_JSON, "prdd_maximum_number_days", 0);
        deliveryInfo.prdd_date_lockout = DataHelper.safeInt("prdd_date_lockout");
        deliveryInfo.prdd_date_range_type = DataHelper.safeString(deliveryInfo_JSON, "prdd_date_range_type");
        deliveryInfo.prdd_start_date_range = DataHelper.safeString(deliveryInfo_JSON, "prdd_start_date_range");
        deliveryInfo.prdd_end_date_range = DataHelper.safeString(deliveryInfo_JSON, "prdd_end_date_range");

        JSONObject prdd_time_settingsJsonObject = deliveryInfo_JSON.getJSONObject("prdd_time_settings");
        deliveryInfo.prdd_weekday_time_slot = new HashMap<>();
        Iterator<String> prdd_time_settings_slot_keys = prdd_time_settingsJsonObject.keys();
        while (prdd_time_settings_slot_keys.hasNext()) {
            String key = prdd_time_settings_slot_keys.next();
            JSONObject prdd_weekday_slotJsonObject = prdd_time_settingsJsonObject.getJSONObject(key);
            List<TM_ProductInfo.TM_DeliveryInfo.TimeSettings> timeSettingsList = new ArrayList<>();
            Iterator<String> prdd_weekday_slot_innerKeys = prdd_weekday_slotJsonObject.keys();
            while (prdd_weekday_slot_innerKeys.hasNext()) {
                String innerKkey = prdd_weekday_slot_innerKeys.next();
                JSONObject timeSettingsJsonObject = prdd_weekday_slotJsonObject.getJSONObject(innerKkey);
                TM_ProductInfo.TM_DeliveryInfo.TimeSettings timeSettings = new TM_ProductInfo.TM_DeliveryInfo.TimeSettings();
                timeSettings.slot_price = DataHelper.safeString(timeSettingsJsonObject, "slot_price");
                timeSettings.from_slot_hrs = DataHelper.safeString(timeSettingsJsonObject, "from_slot_hrs");
                timeSettings.from_slot_min = DataHelper.safeString(timeSettingsJsonObject, "from_slot_min");
                timeSettings.to_slot_hrs = DataHelper.safeString(timeSettingsJsonObject, "to_slot_hrs");
                timeSettings.to_slot_min = DataHelper.safeString(timeSettingsJsonObject, "to_slot_min");
                timeSettings.lockout_slot = DataHelper.safeString(timeSettingsJsonObject, "lockout_slot");
                timeSettingsList.add(timeSettings);
            }
            deliveryInfo.prdd_weekday_time_slot.put(key, timeSettingsList);
        }
        product.deliveryInfo = deliveryInfo;
        return deliveryInfo;
    }

    public static TM_ProductInfo parseFullProduct(JSONObject productInfoJson) throws JSONException {
        int id = productInfoJson.getInt("id");
        TM_ProductInfo product = TM_ProductInfo.getOrCreate(id);

        product.title = DataHelper.safeString(productInfoJson, "title");
        product.downloadable = productInfoJson.getBoolean("downloadable");
        product.virtual = productInfoJson.getBoolean("virtual");
        product.permalink = DataHelper.safeString(productInfoJson, "permalink");
        product.sku = DataHelper.safeString(productInfoJson, "sku");
        product.taxable = productInfoJson.getBoolean("taxable");
        product.price = TM_CommonInfo.getPriceIncludingTax1(DataHelper.safeFloatPrice(DataHelper.safeString(productInfoJson, "price")), product.taxable);
        product.regular_price = TM_CommonInfo.getPriceIncludingTax1(DataHelper.safeFloatPrice(DataHelper.safeString(productInfoJson, "regular_price")), product.taxable);
        product.sale_price = TM_CommonInfo.getPriceIncludingTax1(DataHelper.safeFloatPrice(DataHelper.safeString(productInfoJson, "sale_price")), product.taxable);
        product.clonePrice();

        TaxHelper.setPriceFromTax(product);
        CurrencyHelper.applyCurrencyRate(product);
        RolePrice.applyPrice(product);

        product.weight = DataHelper.safeFloat(DataHelper.safeString(productInfoJson, "weight"));

        //pricing
        float priceToUse = product.regular_price != 0 ? product.regular_price : product.price;
        float discountPrice = product.sale_price != 0 ? (priceToUse - product.sale_price) : 0;
        if (discountPrice > 0) {
            product.discount = discountPrice * 100.0f / priceToUse;
        } else {
            product.discount = 0;
        }
        product.price_html = DataHelper.safeString(productInfoJson, "price_html");

        product.managing_stock = DataHelper.safeBool(productInfoJson.getString("managing_stock"));

        product.in_stock = productInfoJson.getBoolean("in_stock");
        product.stockQty = product.in_stock ? (product.managing_stock ? DataHelper.safeInt(productInfoJson, "stock_quantity", 1) : 0) : 0;
        product.sold_individually = productInfoJson.getBoolean("sold_individually");
        product.purchaseable = productInfoJson.getBoolean("purchaseable");
        product.featured = productInfoJson.getBoolean("featured");
        product.visible = productInfoJson.getBoolean("visible");
        product.on_sale = productInfoJson.getBoolean("on_sale");
        product.product_url = DataHelper.safeString(productInfoJson, "product_url");
        product.shipping_required = productInfoJson.getBoolean("shipping_required");
        product.shipping_taxable = productInfoJson.getBoolean("shipping_taxable");
        product.shipping_class = DataHelper.safeString(productInfoJson, "shipping_class");
        product.setDescription(DataHelper.safeString(productInfoJson, "description"));
        product.setShortDescription(DataHelper.safeString(productInfoJson, "short_description"));
        product.reviews_allowed = productInfoJson.getBoolean("reviews_allowed");
        product.average_rating = DataHelper.safeFloat(DataHelper.safeString(productInfoJson, "average_rating"));
        product.rating_count = productInfoJson.getInt("rating_count");
        product.parent_id = DataHelper.safeInt(productInfoJson, "parent_id", -1);

        DataHelper.log("**** product.parent_id : [" + product.parent_id + "] ****");

        //Category stuff
        if (!DataEngine.getDataEngine().getVersionString().equalsIgnoreCase("v1")) {
            JSONArray categories = productInfoJson.getJSONArray("categories");
            DataHelper.log("**** parseFullProduct:categories : [" + categories.toString() + "] ****");
            List<String> keyWords = new ArrayList<>();
            for (int j = 0; j < categories.length(); j++) {
                keyWords.add(categories.getString(j));
            }
            List<TM_CategoryInfo> temp = TM_CategoryInfo.getAllWithKeyWords(keyWords);
            if (temp.size() > 1) {
                DataHelper.log("---## found (" + temp.size() + ") categories for product.. need to eliminate some of them ##---");
                temp = TM_CategoryInfo.eliminateParents(temp);
            } else if (temp.size() == 1) {
                DataHelper.log("---## found just one category :) [" + temp.get(0).id + "] ##---");
            } else {
                DataHelper.log("---## found no category for product: [" + product.id + "] ##---");
            }
            for (TM_CategoryInfo c : temp) {
                c.isProductRefreshed = true;
            }
            product.putInCategories(temp);
        }

        //tags
        JSONArray tags = productInfoJson.getJSONArray("tags");
        for (int j = 0; j < tags.length(); j++) {
            product.tags.add(tags.getString(j).toLowerCase());
        }

        //images
        product.removeAllImages();
        JSONArray images = productInfoJson.getJSONArray("images");
        for (int j = 0; j < images.length(); j++) {
            product.addImage(parseImage(images.getJSONObject(j)));
        }

        product.featured_src = DataHelper.safeString(productInfoJson, "featured_src");

        //attribs
        {
            if (!product.attributes.isEmpty())
                product.attributes.clear();
            product.extra_attribs_loaded = false;
            JSONArray attributes = productInfoJson.getJSONArray("attributes");
            for (int k = 0; k < attributes.length(); k++) {
                product.attributes.add(parseAttribute(attributes.getJSONObject(k)));
            }
        }
        //arrangeAttributes(product);

        product.menu_order = DataHelper.safeInt(productInfoJson, "menu_order", 0);
        product.download_limit = productInfoJson.getInt("download_limit");
        product.download_expiry = productInfoJson.getInt("download_expiry");
        product.download_type = DataHelper.safeString(productInfoJson, "download_type");
        product.purchase_note = DataHelper.safeString(productInfoJson, "purchase_note");
        product.total_sales = productInfoJson.getInt("total_sales");

        if (productInfoJson.has("type")) {
            product.type = TM_ProductInfo.ProductType.from(productInfoJson.getString("type"));
            //DataHelper.log("[ Product Type => " + product.type.toString() + " ] [ Product Name => " + product.title + " ]");
        }

        if (productInfoJson.has("status")) {
            product.setStatus(productInfoJson.getString("status"));
        }

        if (productInfoJson.has("upsell_ids")) {
            JSONArray upsell_ids = productInfoJson.getJSONArray("upsell_ids");
            if (upsell_ids.length() > 0) {
                product.upsell_ids = new ArrayList<>();
                for (int i = 0; i < upsell_ids.length(); i++) {
                    product.upsell_ids.add(upsell_ids.getInt(i));
                }
            }
        }

        if (productInfoJson.has("cross_sell_ids")) {
            JSONArray cross_sell_ids = productInfoJson.getJSONArray("cross_sell_ids");
            if (cross_sell_ids.length() > 0) {
                product.cross_sell_ids = new ArrayList<>();
                for (int i = 0; i < cross_sell_ids.length(); i++) {
                    product.cross_sell_ids.add(cross_sell_ids.getInt(i));
                }
            }
        }

        if (productInfoJson.has("related_ids")) {
            JSONArray related_ids = productInfoJson.getJSONArray("related_ids");
            if (related_ids.length() > 0) {
                product.related_ids = new ArrayList<>();
                for (int i = 0; i < related_ids.length(); i++) {
                    product.related_ids.add(related_ids.getInt(i));
                }
            }
        }

        //variations
        if (!product.variations.isEmpty())
            product.variations.clear();
        if (productInfoJson.has("variations")) {
            JSONArray variations_json = productInfoJson.getJSONArray("variations");
            for (int j = 0; j < variations_json.length(); j++) {
                product.variations.add(parseVariation(variations_json.getJSONObject(j)));
            }
        }


        String createdAt = DataHelper.safeString(productInfoJson, "created_at");
        String updatedAt = DataHelper.safeString(productInfoJson, "updated_at");
        try {
            DateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.getDefault());
            product.created_at = sdf.parse(createdAt);
            product.updated_at = sdf.parse(updatedAt);
        } catch (ParseException ignored) {
            try {
                DateFormat sdf = new SimpleDateFormat("yyyy-mm-dd hh:mm:ss", Locale.getDefault());
                product.created_at = sdf.parse(createdAt);
                product.updated_at = sdf.parse(updatedAt);
            } catch (ParseException e1) {
                e1.printStackTrace();
            }
        }

        product.adjustAttributes();
        if (DataEngine.auto_generate_variations) {
            product.adjustVariations();
        }
        product.reIndexVariations();

        if (DataEngine.append_variation_images) {
            for (TM_Variation variation : product.variations) {
                for (TM_ProductImage image : variation.images) {
                    product.addImage(image);
                }
            }
        }

        for (TM_Variation variation : product.variations) {
            if (product.price_max < variation.price) {
                product.price_max = variation.price;
            }
        }
        product.price_min = product.price_max;
        for (TM_Variation variation : product.variations) {
            if (product.price_min > variation.price) {
                product.price_min = variation.price;
            }
        }

        if (productInfoJson.has("backorders_allowed")) {
            product.backorders_allowed = productInfoJson.getBoolean("backorders_allowed");
        }

        if (productInfoJson.has("backordered")) {
            product.backordered = productInfoJson.getBoolean("backordered");
        }

        if (productInfoJson.has("price_labeller")) {
            parseAndSetPriceLabelData(product, productInfoJson);
        }

        if (productInfoJson.has("min_qty_rule")) {
            product.setQuantityRules(parseQuantityRulesData(productInfoJson.getJSONObject("min_qty_rule")));
        }

        if (productInfoJson.has("deposit_info")) {
            product.depositInfo = DepositInfo.create(productInfoJson);
        }

        if (productInfoJson.has("product_addons")) {
            product.productAddons = parseProductAddonsJson(productInfoJson);
        }

        if (productInfoJson.has("geo_location")) {
            product.productLocation = parseProductLocationJson(productInfoJson);
        }

        product.full_data_loaded = true;
        return product;
    }

    public static TM_ProductInfo parseFullProductWithNullCheck(JSONObject productInfoJson) throws JSONException {
        int id = productInfoJson.getInt("id");
        TM_ProductInfo product = TM_ProductInfo.getOrCreate(id);
        product.title = DataHelper.safeString(productInfoJson, "title");

        if (productInfoJson.has("downloadable"))
            product.downloadable = productInfoJson.getBoolean("downloadable");

        product.virtual = productInfoJson.getBoolean("virtual");
        product.permalink = DataHelper.safeString(productInfoJson, "permalink");
        product.sku = DataHelper.safeString(productInfoJson, "sku");
        product.price = DataHelper.safeFloatPrice(DataHelper.safeString(productInfoJson, "price"));
        product.regular_price = DataHelper.safeFloatPrice(DataHelper.safeString(productInfoJson, "regular_price"));
        product.sale_price = DataHelper.safeFloatPrice(DataHelper.safeString(productInfoJson, "sale_price"));
        product.weight = DataHelper.safeFloat(DataHelper.safeString(productInfoJson, "weight"));

        product.clonePrice();

        RolePrice.applyPrice(product);
        //pricing
        {
            float priceToUse = product.regular_price != 0 ? product.regular_price : product.price;
            float discountPrice = product.sale_price != 0 ? (priceToUse - product.sale_price) : 0;
            if (discountPrice > 0) {
                product.discount = discountPrice * 100.0f / priceToUse;
            } else {
                product.discount = 0;
            }
            product.price_html = DataHelper.safeString(productInfoJson, "price_html");
        }

        product.taxable = productInfoJson.getBoolean("taxable");

        product.managing_stock = DataHelper.safeBool(productInfoJson.getString("managing_stock"));

        product.in_stock = productInfoJson.getBoolean("in_stock");
        product.stockQty = product.in_stock ? (product.managing_stock ? DataHelper.safeInt(productInfoJson, "stock_quantity", 1) : 0) : 0;
        product.sold_individually = productInfoJson.getBoolean("sold_individually");
        product.purchaseable = productInfoJson.getBoolean("purchaseable");
        product.featured = productInfoJson.getBoolean("featured");
        product.visible = productInfoJson.getBoolean("visible");
        product.on_sale = productInfoJson.getBoolean("on_sale");
        product.product_url = DataHelper.safeString(productInfoJson, "product_url");
        product.shipping_required = productInfoJson.getBoolean("shipping_required");
        product.shipping_taxable = productInfoJson.getBoolean("shipping_taxable");
        product.shipping_class = DataHelper.safeString(productInfoJson, "shipping_class");
        product.setDescription(DataHelper.safeString(productInfoJson, "description"));

        product.setShortDescription(DataHelper.safeString(productInfoJson, "short_description"));
        product.reviews_allowed = productInfoJson.getBoolean("reviews_allowed");
        product.average_rating = DataHelper.safeFloat(DataHelper.safeString(productInfoJson, "average_rating"));
        product.rating_count = productInfoJson.getInt("rating_count");
        product.parent_id = DataHelper.safeInt(productInfoJson, "parent_id", -1);

        DataHelper.log("**** product.parent_id : [" + product.parent_id + "] ****");

        //Category stuff
        if (!DataEngine.getDataEngine().getVersionString().equalsIgnoreCase("v1")) {
            JSONArray categories = productInfoJson.getJSONArray("categories");
            DataHelper.log("**** parseFullProduct:categories : [" + categories.toString() + "] ****");
            List<String> keyWords = new ArrayList<>();
            for (int j = 0; j < categories.length(); j++) {
                keyWords.add(categories.getString(j));
            }
            List<TM_CategoryInfo> temp = TM_CategoryInfo.getAllWithKeyWords(keyWords);
            if (temp.size() > 1) {
                DataHelper.log("---## found (" + temp.size() + ") categories for product.. need to eliminate some of them ##---");
                temp = TM_CategoryInfo.eliminateParents(temp);
            } else if (temp.size() == 1) {
                DataHelper.log("---## found just one category :) [" + temp.get(0).id + "] ##---");
            } else {
                DataHelper.log("---## found nor category for product: [" + product.id + "] ##---");
            }
            for (TM_CategoryInfo c : temp) {
                c.isProductRefreshed = true;
            }
            product.putInCategories(temp);
        }

        //tags
        {
            JSONArray tags = productInfoJson.getJSONArray("tags");
            for (int j = 0; j < tags.length(); j++) {
                product.tags.add(tags.getString(j).toLowerCase());
            }
        }

        //images
        {
            product.removeAllImages();
            JSONArray images = productInfoJson.getJSONArray("images");
            for (int j = 0; j < images.length(); j++) {
                product.addImage(DataHelper.getScaledImageUrl(images.getString(j)));
            }
        }
        product.featured_src = DataHelper.safeString(productInfoJson, "featured_src");

        //attribs
        {
            if (!product.attributes.isEmpty())
                product.attributes.clear();

            product.extra_attribs_loaded = false;
            JSONArray attributes = productInfoJson.getJSONArray("attributes");

            for (int k = 0; k < attributes.length(); k++) {
                TM_Attribute attribute = new TM_Attribute(UUID.randomUUID().toString());
                JSONObject attributeJsonObj = attributes.getJSONObject(k);

                attribute.name = attributeJsonObj.getString("name");

                if (attributeJsonObj.has("id"))
                    attribute.slug = attributeJsonObj.getString("id");

                if (attributeJsonObj.has("position"))
                    attribute.position = attributeJsonObj.getInt("position");

                if (attributeJsonObj.has("visible"))
                    attribute.visible = attributeJsonObj.getBoolean("visible");

                if (attributeJsonObj.has("variation"))
                    attribute.variation = attributeJsonObj.getBoolean("variation");

                if (attributeJsonObj.has("options")) {
                    JSONArray options = attributeJsonObj.getJSONArray("options");
                    for (int l = 0; l < options.length(); l++) {
                        attribute.options.add(options.getString(l));
                    }
                }
                product.attributes.add(attribute);
            }
        }

        //String[] product.attributes;
        //String[] product.downloads;
        product.menu_order = DataHelper.safeInt(productInfoJson, "menu_order", 0);
        product.download_limit = productInfoJson.getInt("download_limit");
        product.download_expiry = productInfoJson.getInt("download_expiry");
        product.download_type = DataHelper.safeString(productInfoJson, "download_type");
        product.purchase_note = DataHelper.safeString(productInfoJson, "purchase_note");
        product.total_sales = productInfoJson.getInt("total_sales");
        //String []product.variations;

        if (productInfoJson.has("type")) {
            product.type = TM_ProductInfo.ProductType.from(productInfoJson.getString("type"));
            //DataHelper.log("[ Product Type => " + product.type.toString() + " ] [ Product Name => " + product.title + " ]");
        }

        if (productInfoJson.has("status")) {
            product.setStatus(productInfoJson.getString("status"));
        }

        if (productInfoJson.has("upsell_ids")) {
            JSONArray upsell_ids = productInfoJson.getJSONArray("upsell_ids");
            if (upsell_ids.length() > 0) {
                product.upsell_ids = new ArrayList<>();
                for (int i = 0; i < upsell_ids.length(); i++) {
                    product.upsell_ids.add(upsell_ids.getInt(i));
                }
            }
        }

        if (productInfoJson.has("cross_sell_ids")) {
            JSONArray cross_sell_ids = productInfoJson.getJSONArray("cross_sell_ids");
            if (cross_sell_ids.length() > 0) {
                product.cross_sell_ids = new ArrayList<>();
                for (int i = 0; i < cross_sell_ids.length(); i++) {
                    product.cross_sell_ids.add(cross_sell_ids.getInt(i));
                }
            }
        }

        if (productInfoJson.has("related_ids")) {
            JSONArray related_ids = productInfoJson.getJSONArray("related_ids");
            if (related_ids.length() > 0) {
                product.related_ids = new ArrayList<>();
                for (int i = 0; i < related_ids.length(); i++) {
                    product.related_ids.add(related_ids.getInt(i));
                }
            }
        }

        //variations
        {
            if (!product.variations.isEmpty())
                product.variations.clear();

            JSONArray variations_json = productInfoJson.getJSONArray("variations");
            for (int j = 0; j < variations_json.length(); j++) {
                product.variations.add(parseVariationForFullProduct(variations_json.getJSONObject(j)));
            }
        }

        {
            String createdAt = DataHelper.safeString(productInfoJson, "created_at");
            String updatedAt = DataHelper.safeString(productInfoJson, "updated_at");
            try {
                DateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.getDefault());
                product.created_at = sdf.parse(createdAt);
                product.updated_at = sdf.parse(updatedAt);
            } catch (ParseException ignored) {
                try {
                    DateFormat sdf = new SimpleDateFormat("yyyy-mm-dd hh:mm:ss", Locale.getDefault());
                    product.created_at = sdf.parse(createdAt);
                    product.updated_at = sdf.parse(updatedAt);
                } catch (ParseException e1) {
                    e1.printStackTrace();
                }
            }
        }

        //long t1 = System.currentTimeMillis();

        product.adjustAttributes();

        if (DataEngine.auto_generate_variations) {
            product.adjustVariations();
        }
        product.reIndexVariations();

        if (DataEngine.append_variation_images) {
            for (TM_Variation variation : product.variations) {
                for (TM_ProductImage image : variation.images) {
                    product.addImage(image);
                }
            }
        }

        if (productInfoJson.has("backorders_allowed")) {
            product.backorders_allowed = productInfoJson.getBoolean("backorders_allowed");
        }
        if (productInfoJson.has("backordered")) {
            product.backordered = productInfoJson.getBoolean("backordered");
        }

        if (productInfoJson.has("deposit_info")) {
            product.depositInfo = DepositInfo.create(productInfoJson);
        }

        if (productInfoJson.has("product_addons")) {
            product.productAddons = parseProductAddonsJson(productInfoJson);
        }

        product.full_data_loaded = true;

        return product;
    }

    public static TM_ProductInfo parseFullProductFast(String jsonString) throws JSONException {
        DataHelper.log("TM_ProductInfo::parseFullProductFast\n" + jsonString);
        JSONArray jsonArray = DataHelper.safeJsonArray(jsonString);
        JSONObject jsonObject = jsonArray.getJSONObject(0);
        JSONObject product_info = jsonObject.getJSONObject("product_info");
        TM_ProductInfo product = parseFullProduct(product_info);

        if (jsonObject.has("ext_data")) {
            if (product.type == TM_ProductInfo.ProductType.MIXNMATCH) {
                JSONObject ext_data = jsonObject.getJSONObject("ext_data");
                TM_MixMatch mixMatch = new TM_MixMatch();
                //mixMatch.addMatchingItems();
                mixMatch.setPerProductPricing(ext_data.getBoolean("per_product_pricing"));
                mixMatch.setPerProductShipping(ext_data.getBoolean("per_product_shipping"));
                mixMatch.setIsSynced(ext_data.getBoolean("is_synced"));
                mixMatch.setMinPrice(DataHelper.safeFloat(ext_data.getString("min_price")));
                mixMatch.setMaxPrice(DataHelper.safeFloat(ext_data.getString("max_price")));
                mixMatch.setBasePrice(DataHelper.safeFloat(ext_data.getString("base_price")));
                mixMatch.setBaseRegularPrice(DataHelper.safeFloat(ext_data.getString("base_regular_price")));
                mixMatch.setBaseSalePrice(DataHelper.safeFloat(ext_data.getString("base_sale_price")));
                mixMatch.setContainerSize(DataHelper.safeFloat(ext_data.getString("container_size")));

                JSONArray productsJsonArray = ext_data.getJSONArray("product_info");
                for (int i = 0; i < productsJsonArray.length(); i++) {
                    mixMatch.addMatchingItems(parseRawProduct(productsJsonArray.getJSONObject(i)));
                }
                product.mMixMatch = mixMatch;
            } else if (product.type == TM_ProductInfo.ProductType.BUNDLE || product.type == TM_ProductInfo.ProductType.BUNDLE_YITH) {
                JSONArray ext_data = jsonObject.getJSONArray("ext_data");
                product.mBundles = new ArrayList<>();
                for (int i = 0; i < ext_data.length(); i++) {
                    JSONObject bundleJson = ext_data.getJSONObject(i);
                    TM_Bundle bundle = new TM_Bundle();
                    bundle.setHideThumbnail(DataHelper.safeBool(DataHelper.safeString(bundleJson, "hide_thumbnail")));
                    bundle.setOverrideTitle(DataHelper.safeBool(DataHelper.safeString(bundleJson, "override_title")));
                    bundle.setOverrideDescription(DataHelper.safeBool(DataHelper.safeString(bundleJson, "override_description")));
                    bundle.setOptional(DataHelper.safeBool(DataHelper.safeString(bundleJson, "optional")));
                    bundle.setVisibility(DataHelper.safeBool(DataHelper.safeString(bundleJson, "visibility")));
                    bundle.setBundleQuantity(DataHelper.safeInt(bundleJson, "bundle_quantity", 1));
                    bundle.setBundleDiscount(DataHelper.safeFloat(DataHelper.safeString(bundleJson, "bundle_discount")));
                    bundle.setProduct(parseRawProduct(bundleJson.getJSONObject("product_info")));
                    product.mBundles.add(bundle);
                }
            }
        }
        return product;
    }

    public static TM_ProductInfo parseRawProduct(JSONObject productInfoJson) throws JSONException {
        int id = productInfoJson.getInt("id");
        TM_ProductInfo product = TM_ProductInfo.getOrCreate(id);

        product.title = DataHelper.safeString(productInfoJson, "title");

        if (!product.hasAnyImage()) {
            String img_url = DataHelper.safeString(productInfoJson, "img");
            img_url = DataHelper.getScaledImageUrl(img_url);
            product.addImage(img_url);
        }

        String img_url = DataHelper.safeString(productInfoJson, "img");
        product.thumb = DataHelper.getScaledThumbnailUrl(img_url);

        if (productInfoJson.has("taxable")) {
            product.taxable = productInfoJson.getBoolean("taxable");
        }

        product.price = TM_CommonInfo.getPriceIncludingTax1(DataHelper.safeFloatPrice(DataHelper.safeString(productInfoJson, "price")), product.taxable);

        if (productInfoJson.has("min_var_price")) {
            try {
                product.price_min = TM_CommonInfo.getPriceIncludingTax1((float) productInfoJson.getDouble("min_var_price"), product.taxable);
            } catch (Exception e) {
                product.price_min = product.price;
            }
            product.price_min = CurrencyHelper.applyRate(product.price_min);
        }

        if (productInfoJson.has("max_var_price")) {
            try {
                product.price_max = TM_CommonInfo.getPriceIncludingTax1((float) productInfoJson.getDouble("max_var_price"), product.taxable);
            } catch (Exception e) {
                product.price_max = product.price;
            }
            product.price_max = CurrencyHelper.applyRate(product.price_max);
        }

        if (productInfoJson.has("type")) {
            product.type = TM_ProductInfo.ProductType.from(productInfoJson.getString("type"));
            //DataHelper.log("[ Product Type => " + product.type.toString() + " ] [ Product Name => " + product.title + " ]");
        }

        //attribs
        {
            if (productInfoJson.has("attributes")) {
                if (!product.attributes.isEmpty())
                    product.attributes.clear();
                product.extra_attribs_loaded = false;
                JSONArray attributes = productInfoJson.getJSONArray("attributes");
                for (int k = 0; k < attributes.length(); k++) {
                    product.attributes.add(parseAttribute(attributes.getJSONObject(k)));
                }
            }
        }
        product.adjustAttributes();
        product.regular_price = TM_CommonInfo.getPriceIncludingTax1(DataHelper.safeFloatPrice(DataHelper.safeString(productInfoJson, "regular_price")), product.taxable);
        product.product_url = DataHelper.safeString(productInfoJson, "url");
        product.permalink = DataHelper.safeString(productInfoJson, "url");
        product.sale_price = TM_CommonInfo.getPriceIncludingTax1(DataHelper.safeFloatPrice(DataHelper.safeString(productInfoJson, "sale_price")), product.taxable);
        product.clonePrice();

        //product.in_stock = DataHelper.safeBool(productInfoJson.getString("stock"));
        TaxHelper.setPriceFromTax(product);
        CurrencyHelper.applyCurrencyRate(product);
        RolePrice.applyPrice(product);
        if (productInfoJson.has("stock")) {
            try {
                product.in_stock = productInfoJson.getBoolean("stock");
            } catch (Exception e) {
                product.in_stock = DataHelper.safeBool(productInfoJson.getString("stock"));
            }
        } else {
            product.in_stock = true;
        }

        //new fields
        if (productInfoJson.has("featured")) {
            product.featured = productInfoJson.getBoolean("featured");
        }

        if (productInfoJson.has("total_sales")) {
            product.total_sales = productInfoJson.getInt("total_sales");
        }

        if (productInfoJson.has("average_rating")) {
            product.average_rating = productInfoJson.getInt("average_rating");
        }

        if (productInfoJson.has("created_at")) {
            try {
                DateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                product.created_at = sdf.parse(DataHelper.safeString(productInfoJson, "created_at"));
            } catch (ParseException e) {
                e.printStackTrace();
            }
        }

        if (productInfoJson.has("seller_info")) {
            JSONObject jsonObject = productInfoJson.getJSONObject("seller_info");
            product.sellerInfo = parseAndCreateSellerInfo(jsonObject);
        }

        if (productInfoJson.has("stock_quantity")) {
            product.stockQty = productInfoJson.getInt("stock_quantity");
        }

        if (productInfoJson.has("managing_stock")) {
            product.managing_stock = productInfoJson.getBoolean("managing_stock");
        }

        if (productInfoJson.has("min_qty_rule")) {
            product.setQuantityRules(parseQuantityRulesData(productInfoJson.getJSONObject("min_qty_rule")));
        }

        if (productInfoJson.has("price_labeller")) {
            parseAndSetPriceLabelData(product, productInfoJson);
        }

        if (productInfoJson.has("deposit_info")) {
            product.depositInfo = DepositInfo.create(productInfoJson);
        }

        if (productInfoJson.has("product_addons")) {
            product.productAddons = parseProductAddonsJson(productInfoJson);
        }

        return product;
    }


    private static void arrangeAttributes(TM_ProductInfo product) {
        Collections.sort(product.attributes, productAttributeComparator);
    }

    public static TM_ProductInfo parseHomepageProduct(JSONObject productInfoJson) throws JSONException {
        TM_ProductInfo product = TM_ProductInfo.getOrCreate(productInfoJson.getInt("id"));
        product.title = DataHelper.safeString(productInfoJson, "title");
        product.setShortDescription(DataHelper.safeString(productInfoJson, "desc"));

        if (!product.hasAnyImage()) {
            String img_url = DataHelper.safeString(productInfoJson, "img");
            img_url = DataHelper.getScaledImageUrl(img_url);
            product.addImage(img_url);
        }

        String img_url = DataHelper.safeString(productInfoJson, "img");
        product.thumb = DataHelper.getScaledThumbnailUrl(img_url);

        if (productInfoJson.has("taxable")) {
            product.taxable = productInfoJson.getBoolean("taxable");
        }
        if (productInfoJson.has("tax_class")) {
            product.taxClass = productInfoJson.getString("tax_class");
        }

        product.price = TM_CommonInfo.getPriceIncludingTax1(DataHelper.safeFloatPrice(DataHelper.safeString(productInfoJson, "price")), product.taxable);
        product.regular_price = TM_CommonInfo.getPriceIncludingTax1(DataHelper.safeFloatPrice(DataHelper.safeString(productInfoJson, "regular_price")), product.taxable);
        product.sale_price = TM_CommonInfo.getPriceIncludingTax1(DataHelper.safeFloatPrice(DataHelper.safeString(productInfoJson, "sale_price")), product.taxable);
        product.clonePrice();

        TaxHelper.setPriceFromTax(product);
        CurrencyHelper.applyCurrencyRate(product);
        RolePrice.applyPrice(product);
        if (productInfoJson.has("min_var_price")) {
            try {
                product.price_min = TM_CommonInfo.getPriceIncludingTax1((float) productInfoJson.getDouble("min_var_price"), product.taxable);
                product.price_min = CurrencyHelper.applyRate(product.price_min);
            } catch (Exception e) {
                product.price_min = product.price;
            }
        }

        if (productInfoJson.has("max_var_price")) {
            try {
                product.price_max = TM_CommonInfo.getPriceIncludingTax1((float) productInfoJson.getDouble("max_var_price"), product.taxable);
                product.price_max = CurrencyHelper.applyRate(product.price_max);
            } catch (Exception e) {
                product.price_max = product.price;
            }
        }

        if (productInfoJson.has("type")) {
            product.type = TM_ProductInfo.ProductType.from(productInfoJson.getString("type"));
            //DataHelper.log("[ Product Type => " + product.type.toString() + " ] [ Product Name => " + product.title + " ]");
        }

        if (productInfoJson.has("stock")) {
            try {
                product.in_stock = productInfoJson.getBoolean("stock");
            } catch (Exception e) {
                product.in_stock = DataHelper.safeBool(productInfoJson.getString("stock"));
            }
        } else {
            product.in_stock = true;
        }
        product.product_url = DataHelper.safeString(productInfoJson, "url");
        product.permalink = DataHelper.safeString(productInfoJson, "url");

        // Attributes
        if (productInfoJson.has("attributes")) {
            if (!product.attributes.isEmpty())
                product.attributes.clear();
            product.extra_attribs_loaded = false;
            JSONArray attributes = productInfoJson.getJSONArray("attributes");
            for (int k = 0; k < attributes.length(); k++) {
                product.attributes.add(parseAttribute(attributes.getJSONObject(k)));
            }
        }
        product.adjustAttributes();

        JSONArray category_ids = productInfoJson.getJSONArray("category_ids");
        for (int i = 0; i < category_ids.length(); i++) {
            product.putInCategory(category_ids.getInt(i));
        }

        //new fields
        if (productInfoJson.has("featured")) {
            product.featured = productInfoJson.getBoolean("featured");
        }

        if (productInfoJson.has("total_sales")) {
            product.total_sales = productInfoJson.getInt("total_sales");
        }

        if (productInfoJson.has("average_rating")) {
            product.average_rating = (float) productInfoJson.getDouble("average_rating");
        }

        if (productInfoJson.has("created_at")) {
            try {
                DateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                product.created_at = sdf.parse(DataHelper.safeString(productInfoJson, "created_at"));
            } catch (ParseException e) {
                e.printStackTrace();
            }
        }

        if (productInfoJson.has("seller_info")) {
            JSONObject jsonObject = productInfoJson.getJSONObject("seller_info");
            product.sellerInfo = parseAndCreateSellerInfo(jsonObject);
        }

        if (productInfoJson.has("status")) {
            product.setStatus(productInfoJson.getString("status"));
        }

        if (productInfoJson.has("min_qty_rule")) {
            product.setQuantityRules(parseQuantityRulesData(productInfoJson.getJSONObject("min_qty_rule")));
        }

        if (productInfoJson.has("price_labeller")) {
            parseAndSetPriceLabelData(product, productInfoJson);
        }

        if (productInfoJson.has("deposit_info")) {
            product.depositInfo = DepositInfo.create(productInfoJson);
        }

        if (productInfoJson.has("product_addons")) {
            product.productAddons = parseProductAddonsJson(productInfoJson);
        }
        return product;
    }

    public static SellerInfo parseAndCreateSellerInfo(JSONObject jsonObject) {
        String id = "";
        String last_name = "";
        String first_name = "";
        String[] location = null;
        String profile_url = "";
        boolean verified = false;
        String phone = "";
        String info = "";
        String name = "";
        String shop_url = "";
        String icon_url = "";
        String avatar_url = "";
        String banner_url = "";
        String address = "";
        String description = "";
        double latitude = 0;
        double longitude = 0;

        try {
            if (jsonObject.has("seller")) {
                JSONObject sellerObject = jsonObject.getJSONObject("seller");
                id = JsonHelper.getString(sellerObject, "id", "");
                first_name = JsonHelper.getString(sellerObject, "first_name", "");
                last_name = JsonHelper.getString(sellerObject, "last_name", "");
                avatar_url = JsonHelper.getString(sellerObject, "avatar", "");
                location = JsonHelper.getStringArray(sellerObject, "location");
                profile_url = JsonHelper.getString(sellerObject, "profile_url", "");
                verified = JsonHelper.getBool(sellerObject, "verified", true);
                phone = JsonHelper.getString(sellerObject, "phone", "");
                info = JsonHelper.getString(sellerObject, "info", "");
            }
            if (jsonObject.has("shop")) {
                JSONObject shopObject = jsonObject.getJSONObject("shop");
                name = JsonHelper.getString(shopObject, "name", "");
                shop_url = JsonHelper.getString(shopObject, "shop_url", "");
                icon_url = JsonHelper.getString(shopObject, "icon_url", "");
                banner_url = JsonHelper.getString(shopObject, "banner_url", "");
                address = JsonHelper.getString(shopObject, "address", "");
                description = JsonHelper.getString(shopObject, "description", "");
            }

            if (jsonObject.has("geo_location")) {
                JSONObject geoLocation = jsonObject.getJSONObject("geo_location");
                latitude = JsonHelper.getSafeDouble(geoLocation, "latitude", 0.0);
                longitude = JsonHelper.getSafeDouble(geoLocation, "longitude", 0.0);
            }

            SellerInfo sellerInfo = new SellerInfo();
            sellerInfo.setId(id);
            sellerInfo.setShopUrl(shop_url);
            sellerInfo.setPhoneNumber(phone);
            sellerInfo.setTitle(first_name);
            sellerInfo.setShopAddress(address);
            sellerInfo.setShopName(name);
            sellerInfo.setVendorLastName(last_name);
            sellerInfo.setIconUrl(trimSellerUrls(icon_url));
            sellerInfo.setAvatarUrl(trimSellerUrls(avatar_url));
            sellerInfo.setLatitude(latitude);
            sellerInfo.setLongitude(longitude);
            return sellerInfo;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static ProductAddons parseProductAddonsJson(JSONObject jsonObject) {
        try {
            Object object = jsonObject.get("product_addons");
            if (object instanceof JSONArray) {
                JSONArray product_addons = (JSONArray) object;
                if (product_addons.length() > 0) {
                    return new Gson().fromJson(product_addons.getJSONObject(0).toString(), ProductAddons.class);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static ProductLocation parseProductLocationJson(JSONObject jsonObject) {
        try {
            String geo_location = jsonObject.get("geo_location").toString();
            return new Gson().fromJson(geo_location, ProductLocation.class);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static String trimSellerUrls(String str) {
        if (str.startsWith("//")) {
            return str.replaceFirst("//", "https://");
        }
        return str;
    }

    public static TM_ProductImage parseImage(JSONObject imgJsonObj) throws JSONException {
        TM_ProductImage img = new TM_ProductImage();
        img.id = imgJsonObj.getInt("id");
        img.position = imgJsonObj.getInt("position");
        img.src = imgJsonObj.getString("src");
        //DataHelper.log("ImageUrl => " + img.src);
        img.title = imgJsonObj.getString("title");
        img.alt = imgJsonObj.getString("alt");
        return img;
    }

    public static TM_Attribute parseAttribute(JSONObject attributeJsonObj) throws JSONException {
        TM_Attribute attribute = new TM_Attribute(UUID.randomUUID().toString());
        attribute.name = attributeJsonObj.getString("name");
        if (attributeJsonObj.has("slug")) {
            attribute.slug = attributeJsonObj.getString("slug");
        } else {
            attribute.slug = attributeJsonObj.getString("id");
        }

        if (attributeJsonObj.has("position"))
            attribute.position = attributeJsonObj.getInt("position");

        if (attributeJsonObj.has("visible"))
            attribute.visible = attributeJsonObj.getBoolean("visible");

        if (attributeJsonObj.has("variation"))
            attribute.variation = attributeJsonObj.getBoolean("variation");

        if (attributeJsonObj.has("options")) {
            JSONArray options = attributeJsonObj.getJSONArray("options");
            for (int l = 0; l < options.length(); l++) {
                attribute.options.add(options.getString(l));
            }
        }
        return attribute;
    }

    public static void parseExtraAttributesForProduct(TM_ProductInfo product, String jsonString) throws JSONException {
        DataHelper.log("-- parseExtraAttributesForProduct --");
        JSONObject jsonObject = DataHelper.safeJsonObject(jsonString);
        JSONArray variation_simple_fields = jsonObject.getJSONArray("variation_simple_fields");
        for (int i = 0; i < variation_simple_fields.length(); i++) {
            JSONObject attributeObject = variation_simple_fields.getJSONObject(i);
            JSONObject saved_attribute = attributeObject.getJSONObject("saved_attribute");
            Iterator keysToCopyIterator = saved_attribute.keys();
            String key = (String) keysToCopyIterator.next();
            String value = saved_attribute.getString(key);

            float extraPrice = DataHelper.safeFloat(DataHelper.safeString(saved_attribute, "Additional Price", "0")); //Plugin walo ke paap. Yaha float = "null" bhi aa shkta hai

            for (TM_Attribute attribute : product.attributes) {
                for (int j = 0; j < attribute.options.size(); j++) {
                    String option = attribute.options.get(j);
                    if (option.equals(value)) {
                        attribute.addAdditionalPrice(option, extraPrice);
                        break; //just internal loop
                        //attribute.options.set(j, value + " [+ " + DataHelper.appendCurrency(extraPrice) + "]");
                    }
                }
            }
        }
        product.extra_attribs_loaded = true;
    }

    public static TM_VariationAttribute parseVariationAttribute(JSONObject attributeJsonObj) throws JSONException {
        TM_VariationAttribute attribute = new TM_VariationAttribute(UUID.randomUUID().toString());
        attribute.name = attributeJsonObj.getString("name");
        attribute.slug = attributeJsonObj.getString("slug");
        attribute.value = attributeJsonObj.getString("option");
        return attribute;
    }

    public static TM_Variation parseVariation(JSONObject variation_json) throws JSONException {
        TM_Variation variation = new TM_Variation();
        variation.id = variation_json.getInt("id");
        //variation.stock_quantity 	= safeInt(variation_json.getString("stock_quantity"));
        variation.download_limit = variation_json.getInt("download_limit");
        variation.download_expiry = variation_json.getInt("download_expiry");

        variation.created_at = variation_json.getString("created_at");
        variation.updated_at = variation_json.getString("updated_at");
        variation.permalink = variation_json.getString("permalink");
        variation.sku = variation_json.getString("sku");
        variation.tax_status = variation_json.getString("tax_status");
        variation.tax_class = variation_json.getString("tax_class");
        variation.weight = DataHelper.safeFloat(variation_json.getString("weight"));
        variation.shipping_class = variation_json.getString("shipping_class");
        variation.shipping_class_id = variation_json.getString("shipping_class_id");

        variation.downloadable = variation_json.getBoolean("downloadable");
        variation.virtual = variation_json.getBoolean("virtual");
        variation.taxable = variation_json.getBoolean("taxable");
        variation.managing_stock = DataHelper.safeBool(variation_json.getString("managing_stock"));
        variation.in_stock = variation_json.getBoolean("in_stock");
        variation.stock_quantity = variation.in_stock ? 1 : 0;

        if (variation_json.has("backorders_allowed")) {
            variation.backorders_allowed = variation_json.getBoolean("backorders_allowed");
        }
        if (variation_json.has("backordered")) {
            variation.backordered = variation_json.getBoolean("backordered");
        }
        variation.purchaseable = variation_json.getBoolean("purchaseable");
        variation.visible = variation_json.getBoolean("visible");
        variation.on_sale = variation_json.getBoolean("on_sale");

        variation.price = DataHelper.safeFloatPrice(variation_json.getString("price"));
        variation.regular_price = DataHelper.safeFloatPrice(variation_json.getString("regular_price"));
        variation.sale_price = DataHelper.safeFloatPrice(variation_json.getString("sale_price"));

        variation.clonePrice();

        CurrencyHelper.applyCurrencyRate(variation);

        RolePrice.applyPrice(variation);

        variation.dimensions = parseDimension(variation_json.getJSONObject("dimensions"));

        variation.images.clear();
        JSONArray images_variation = variation_json.getJSONArray("image");
        variation.images.addAll(parseJSONAndCreateImages(images_variation));

        JSONArray attributes = variation_json.getJSONArray("attributes");
        for (int k = 0; k < attributes.length(); k++) {
            variation.attributes.add(parseVariationAttribute(attributes.getJSONObject(k)));
        }
        return variation;
    }

    public static TM_Variation parseVariationForFullProduct(JSONObject variation_json) throws JSONException {
        TM_Variation variation = new TM_Variation();
        variation.id = variation_json.getInt("id");
        //variation.stock_quantity 	= safeInt(variation_json.getString("stock_quantity"));
        variation.download_limit = variation_json.getInt("download_limit");
        variation.download_expiry = variation_json.getInt("download_expiry");

        variation.created_at = variation_json.getString("created_at");
        variation.updated_at = variation_json.getString("updated_at");
        variation.permalink = variation_json.getString("permalink");
        variation.sku = variation_json.getString("sku");
        variation.tax_status = variation_json.getString("tax_status");
        variation.tax_class = variation_json.getString("tax_class");
        variation.weight = DataHelper.safeFloat(variation_json.getString("weight"));
        variation.shipping_class = variation_json.getString("shipping_class");
        variation.shipping_class_id = variation_json.getString("shipping_class_id");

        variation.downloadable = variation_json.getBoolean("downloadable");
        variation.virtual = variation_json.getBoolean("virtual");
        variation.taxable = variation_json.getBoolean("taxable");

        if (variation_json.has("managing_stock"))
            variation.managing_stock = DataHelper.safeBool(variation_json.getString("managing_stock"));

        variation.in_stock = variation_json.getBoolean("in_stock");
        variation.stock_quantity = variation.in_stock ? 1 : 0;

        if (variation_json.has("backorders_allowed")) {
            variation.backorders_allowed = variation_json.getBoolean("backorders_allowed");
        }
        if (variation_json.has("backordered")) {
            variation.backordered = variation_json.getBoolean("backordered");
        }
        variation.purchaseable = variation_json.getBoolean("purchaseable");
        variation.visible = variation_json.getBoolean("visible");
        variation.on_sale = variation_json.getBoolean("on_sale");

        variation.price = DataHelper.safeFloatPrice(variation_json.getString("price"));
        variation.regular_price = DataHelper.safeFloatPrice(variation_json.getString("regular_price"));
        variation.sale_price = DataHelper.safeFloatPrice(variation_json.getString("sale_price"));
        variation.clonePrice();

        CurrencyHelper.applyCurrencyRate(variation);
        RolePrice.applyPrice(variation);

        variation.dimensions = parseDimension(variation_json.getJSONObject("dimensions"));

        variation.images.clear();
        JSONArray images_variation = variation_json.getJSONArray("image");
        List<TM_ProductImage> images = new ArrayList<>();
        for (int k = 0; k < images_variation.length(); k++) {
            TM_ProductImage tm_productImage = new TM_ProductImage();
            tm_productImage.src = images_variation.get(k).toString();
            images.add(tm_productImage);
        }
        variation.images.addAll(images);


        JSONArray attributes = variation_json.getJSONArray("attributes");
        for (int k = 0; k < attributes.length(); k++) {
            TM_VariationAttribute attribute = new TM_VariationAttribute(UUID.randomUUID().toString());
            attribute.name = attributes.getJSONObject(k).getString("name");
            attribute.slug = attributes.getJSONObject(k).getString("id");
            attribute.value = attributes.getJSONObject(k).getString("option");
            variation.attributes.add(attribute);
        }
        return variation;
    }

    public static List<TM_ProductImage> parseJSONAndCreateImages(JSONArray images_variation) throws JSONException {
        List<TM_ProductImage> images = new ArrayList<>();
        for (int k = 0; k < images_variation.length(); k++) {
            images.add(parseImage(images_variation.getJSONObject(k)));
        }
        return images;
    }

    public static TM_Dimension parseDimension(JSONObject dimensions_json) throws JSONException {
        TM_Dimension dimension = new TM_Dimension();
        dimension.length = DataHelper.safeFloat(dimensions_json.getString("length"));
        dimension.width = DataHelper.safeFloat(dimensions_json.getString("width"));
        dimension.height = DataHelper.safeFloat(dimensions_json.getString("height"));
        dimension.unit = dimensions_json.getString("unit");
        return dimension;
    }

    public static TM_ProductReview parseProductReview(JSONObject productReviewJson) throws JSONException {
        TM_ProductReview productReview = new TM_ProductReview();

        productReview.id = productReviewJson.getInt("id");
        //productReview.created_at 	 = productReviewJson.getString("created_at");
        try {
            DateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
            productReview.created_at = sdf.parse(DataHelper.safeString(productReviewJson, "created_at"));
        } catch (ParseException e) {
            e.printStackTrace();
        }
        productReview.review = productReviewJson.getString("review");
        productReview.rating = DataHelper.safeFloat(productReviewJson.getString("rating"));
        productReview.reviewer_name = productReviewJson.getString("reviewer_name");
        productReview.reviewer_email = productReviewJson.getString("reviewer_email");
        productReview.verified = productReviewJson.getBoolean("verified");

        return productReview;
    }

    public static void parseCommonInfoFromJsonString(JSONObject meta) throws JSONException {
        TM_CommonInfo.timezone = meta.getString("tz");//"Asia\/Kolkata",
        TM_CommonInfo.currency = meta.getString("c");//"INR"
        TM_CommonInfo.currency_format = meta.getString("c_f");//"Rs."
        TM_CommonInfo.currency_position = DataHelper.safeString(meta, "c_p", "left"); //"left"
        //TM_CommonInfo.thousand_separator = DataHelper.safeString(meta,"t_s",","); //"."
        TM_CommonInfo.decimal_separator = DataHelper.safeString(meta, "d_s", "."); //","
        TM_CommonInfo.price_num_decimals = DataHelper.safeInt(meta, "p_d", 2); //2
        TM_CommonInfo.tax_included = meta.getBoolean("t_i"); //false
        TM_CommonInfo.weight_unit = DataHelper.safeString(meta, "w_u", "kg");//"kg"
        TM_CommonInfo.dimension_unit = DataHelper.safeString(meta, "d_u", "cm");

        if (meta.has("hide_out_of_stock")) {
            try {
                TM_CommonInfo.hide_out_of_stock = meta.getString("hide_out_of_stock").equalsIgnoreCase("yes");
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        if (meta.has("add_price_to_product")) {
            TM_CommonInfo.addTaxToProductPrice = meta.getBoolean("add_price_to_product");
        }

        if (meta.has("tax_settings")) {
            JSONObject inner = meta.getJSONObject("tax_settings");
            TM_CommonInfo.shipping_tax_class = inner.getString("shipping_tax_class");
            TM_CommonInfo.tax_based_on = inner.getString("tax_based_on");

            TM_CommonInfo.woocommerce_prices_include_tax = JsonHelper.getString(inner, "woocommerce_prices_include_tax");
            TM_CommonInfo.woocommerce_tax_display_shop = JsonHelper.getString(inner, "woocommerce_tax_display_shop");
            TM_CommonInfo.woocommerce_prices_include_cart = JsonHelper.getString(inner, "woocommerce_prices_include_cart");
            TM_CommonInfo.addTaxToProductPrice = JsonHelper.getBool(inner, "add_price_to_product");

            if (TM_CommonInfo.tax_based_on.compareTo("base") != 0) {
                TM_CommonInfo.addTaxToProductPrice = false;
            }

            if (inner.has("store_base_location")) {
                TM_CommonInfo.store_base_location.country = inner.getJSONObject("store_base_location").getString("country");
                TM_CommonInfo.store_base_location.state = inner.getJSONObject("store_base_location").getString("state");
            }

            if (TM_CommonInfo.addTaxToProductPrice) {
                if (inner.has("taxes")) {
                    TM_Tax.all_Tax.clear();
                    JSONArray taxes = inner.getJSONArray("taxes");
                    for (int i = 0; i < taxes.length(); i++) {
                        TM_Tax.all_Tax.add(parseTax(taxes.getJSONObject(i)));
                    }
                }
            }
        }

        if (meta.has("cart_url")) {
            DataEngine.getDataEngine().url_checkout = meta.getString("cart_url") + "?device_type=android";
        } else {
            DataHelper.log("== cart_url not found ==");
        }

        if (meta.has("home_notification_label")) {
            try {
                TM_CommonInfo.home_notification_label = meta.getString("home_notification_label");
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        if (meta.has("currency_meta")) {
            JSONObject jsonObject = meta.getJSONObject("currency_meta");
            Iterator<String> iterator = jsonObject.keys();
            CurrencyHelper.clearAllCurrency();
            while (iterator.hasNext()) {
                JSONObject innerJsonObject = jsonObject.getJSONObject(iterator.next());
                CurrencyItem currencyItem = new CurrencyItem();
                currencyItem.setName(innerJsonObject.getString("name"));
                currencyItem.setRate(DataHelper.safeFloatPrice(DataHelper.safeString(innerJsonObject, "rate")));
                currencyItem.setSymbol(innerJsonObject.getString("symbol"));
                currencyItem.setPosition(innerJsonObject.getString("position"));
                currencyItem.setIs_etalon(innerJsonObject.getInt("is_etalon"));
                currencyItem.setHide_cents(innerJsonObject.getInt("hide_cents"));
                currencyItem.setDecimals(innerJsonObject.getInt("decimals"));
                currencyItem.setDescription(innerJsonObject.getString("description"));
                currencyItem.setFlag(innerJsonObject.getString("flag"));
                CurrencyHelper.addNewCurrency(currencyItem);
            }
            CurrencyHelper.loadSavedCurrency();
        }
    }

    public static <T> boolean hasResponseError(String response, T handler) {
        try {
            String message = null;
            if (response.contains("errors")) {
                DataHelper.log("== hasResponseError1: [" + response + "] ==");
                List<WooComRestError> errors = parseJsonAndCreateWooComRestErrors(response);
                if (errors.size() > 0) {
                    message = errors.get(0).message;
                }
            } else if (response.contains("error")) {
                DataHelper.log("== hasResponseError2: [" + response + "] ==");
                JSONObject jsonObject = DataHelper.safeJsonObject(response);
                String status = jsonObject.getString("status");
                if (status.equalsIgnoreCase("failed") || status.equalsIgnoreCase("error")) {
                    message = jsonObject.getString("message");
                }
            }
            if (message != null) {
                if (handler != null) {
                    if (handler instanceof TM_LoginListener) {
                        ((TM_LoginListener) handler).onLoginFailed(message);
                    } else if (handler instanceof DataQueryHandler) {
                        ((DataQueryHandler) handler).onFailure(new Exception(message));
                    }
                }
                return true;
            }
        } catch (JSONException ex) {
            ex.printStackTrace();
        }
        return false;
    }

    public static List<WooComRestError> parseJsonAndCreateWooComRestErrors(String jsonStringContent) throws JSONException {
        List<WooComRestError> wooComRestErrors = new ArrayList<>();
        JSONObject jMainObject = DataHelper.safeJsonObject(jsonStringContent);
        if (jMainObject.has("errors")) {
            JSONArray errors = jMainObject.getJSONArray("errors");
            for (int i = 0; i < errors.length(); i++) {
                wooComRestErrors.add(parseJsonAndCreateWooComRestError(errors.getJSONObject(0)));
            }
        }
        return wooComRestErrors;
    }

    public static WooComRestError parseJsonAndCreateWooComRestError(JSONObject jsonObject) throws JSONException {
        WooComRestError wooComRestError = new WooComRestError();
        wooComRestError.code = jsonObject.getString("code");
        wooComRestError.message = jsonObject.getString("message");
        return wooComRestError;
    }

    public static void parseCommonInfoFromJsonString(String jsonStringContent) throws JSONException {
        JSONObject jMainObject = DataHelper.safeJsonObject(jsonStringContent);
        JSONObject store = jMainObject.getJSONObject("store");
        JSONObject meta = store.getJSONObject("meta");
        //JSONObject meta  = new JSONObject(jsonStringContent);
        TM_CommonInfo.timezone = meta.getString("timezone");//"Asia\/Kolkata",
        TM_CommonInfo.currency = meta.getString("currency");//"INR"
        TM_CommonInfo.currency_format = meta.getString("currency_format");//"Rs."
        TM_CommonInfo.currency_position = DataHelper.safeString(meta, "currency_position", "left"); //"left"
        //TM_CommonInfo.thousand_separator = DataHelper.safeString(meta,"thousand_separator",","); //"."
        TM_CommonInfo.decimal_separator = DataHelper.safeString(meta, "decimal_separator", "."); //","
        TM_CommonInfo.price_num_decimals = DataHelper.safeInt(meta, "price_num_decimals", 2); //2
        TM_CommonInfo.tax_included = meta.getBoolean("tax_included"); //false
        TM_CommonInfo.weight_unit = DataHelper.safeString(meta, "weight_unit", "kg");//"kg"
        TM_CommonInfo.dimension_unit = DataHelper.safeString(meta, "dimension_unit", "cm");
    }

    public static List<TM_AccountDetail> parseJsonAndCreateAccountDetails(JSONArray jsonArray) throws JSONException {
        List<TM_AccountDetail> accountDetails = new ArrayList<>();
        for (int i = 0; i < jsonArray.length(); i++) {
            accountDetails.add(parseJsonAndCreateAccountDetail(jsonArray.getJSONObject(i)));
        }
        return accountDetails;
    }

    public static TM_PaymentGateway.GatewaySettings parseJsonAndCreateGatewaySettings(JSONObject jsonObject) throws JSONException {
        if (jsonObject.get("settings") instanceof JSONObject) {
            JSONObject settingsObject = jsonObject.getJSONObject("settings");
            TM_PaymentGateway.GatewaySettings gatewaySettings = new TM_PaymentGateway.GatewaySettings();
            gatewaySettings.extra_charges = settingsObject.getString("extra_charges");
            gatewaySettings.extra_charges_msg = settingsObject.getString("extra_charges_msg");
            gatewaySettings.extra_charges_type = settingsObject.getString("extra_charges_type");
            gatewaySettings.cod_pincodes = settingsObject.getString("cod_pincodes");
            gatewaySettings.in_ex_pincode = settingsObject.getString("in_ex_pincode");
            if (settingsObject.has("min_amount"))
                gatewaySettings.min_amount = settingsObject.getString("min_amount");
            if (settingsObject.has("max_amount"))
                gatewaySettings.max_amount = settingsObject.getString("max_amount");
            return gatewaySettings;
        }
        return null;
    }

    public static TM_AccountDetail parseJsonAndCreateAccountDetail(JSONObject jsonObject) throws JSONException {
        TM_AccountDetail accountDetail = new TM_AccountDetail();
        if (jsonObject.has("account_name")) {
            accountDetail.account_name = jsonObject.getString("account_name");
        }
        if (jsonObject.has("account_number")) {
            accountDetail.account_number = jsonObject.getString("account_number");
        }
        if (jsonObject.has("bank_name")) {
            accountDetail.bank_name = jsonObject.getString("bank_name");
        }
        if (jsonObject.has("sort_code")) {
            accountDetail.sort_code = jsonObject.getString("sort_code");
        }
        if (jsonObject.has("iban")) {
            accountDetail.iban = jsonObject.getString("iban");
        }
        if (jsonObject.has("bic")) {
            accountDetail.bic = jsonObject.getString("bic");
        }
        return accountDetail;
    }

    public static void createWishListFromJson(String jsonString) throws JSONException {
        JSONObject jsonObject = new JSONObject(jsonString);
        JSONArray jsonArray = jsonObject.getJSONArray("products");
        TM_WishList.clearAll();
        for (int i = 0; i < jsonArray.length(); i++) {
            JSONObject object = jsonArray.getJSONObject(i);
            int productId = Integer.parseInt(object.getString("pid"));
            int quantity = Integer.parseInt(object.getString("qty"));
            TM_WishList wishList = TM_WishList.create(productId);
            wishList.setQuantity(quantity);
        }
        TM_WishList.setId(jsonObject.getString("wishlist_id"));
    }

    public static void createWaitListFromJson(String jsonString) throws JSONException {
        JSONObject jsonObject = new JSONObject(jsonString);
        JSONArray jsonArray = jsonObject.getJSONArray("pids");
        TM_WaitList.clearAllProductIds();
        for (int i = 0; i < jsonArray.length(); i++) {
            TM_WaitList.addProductId(jsonArray.getInt(i));
        }
    }

    public static void parseRewardPointsSettingFromJson(String jsonString) throws JSONException {
        JSONObject jsonObject = new JSONObject(jsonString);
        JSONObject earn_conversion = jsonObject.getJSONObject("earn_conversion");
        JSONObject redeem_conversion = jsonObject.getJSONObject("redeem_conversion");
        RewardPoint.getInstance().conversionUnitVal = earn_conversion.getDouble("value");
        RewardPoint.getInstance().redeemUnitVal = redeem_conversion.getDouble("value");
    }

    public static void parseProductRewardPointsFromJson(String jsonString) throws JSONException {
        JSONObject jsonObject = new JSONObject(jsonString);
        JSONObject productObj = jsonObject.getJSONObject("prod_data");
        int productId = Integer.parseInt(productObj.getString("prod_id"));
        TM_ProductInfo productInfo = TM_ProductInfo.findProductById(productId);
        if (productInfo != null) {
            if (!productInfo.hasVariations()) {
                productInfo.setRewardPoints(Integer.parseInt(productObj.getString("prod_points")));
                return;
            }
            if (jsonObject.has("var_data")) {
                JSONArray jsonArray = jsonObject.getJSONArray("var_data");
                for (int i = 0; i < jsonArray.length(); i++) {
                    JSONObject variationObj = jsonArray.getJSONObject(i);
                    int variationId = Integer.parseInt(variationObj.getString("var_id"));
                    TM_Variation variation = productInfo.variations.getVariation(variationId);
                    variation.setRewardPoints(DataHelper.safeInt(variationObj, "var_points", 0));
                }
            }
        }
    }

    public static void parseProductsRewardPointsFromJson(String jsonString) throws JSONException {
        JSONObject jsonObject = new JSONObject(jsonString);
        JSONArray jsonArray = jsonObject.getJSONArray("product_data");
        for (int i = 0; i < jsonArray.length(); i++) {
            JSONObject productObj = jsonArray.getJSONObject(i).getJSONObject("prod_data");
            TM_ProductInfo product = TM_ProductInfo.findProductById(productObj.getInt("prod_id"));
            if (!product.hasVariations()) {
                product.setRewardPoints(productObj.getInt("prod_points"));
            } else {
                JSONArray variationArray = jsonArray.getJSONObject(i).getJSONArray("var_data");
                if (variationArray.length() != 0) {
                    JSONObject variationObj = variationArray.getJSONObject(0);
                    int variationId = variationObj.getInt("var_id");
                    //product.getVariation(variationId).setRewardPoints(Integer.parseInt(variationObj.getString("var_points")));
                    product.getVariation(variationId).setRewardPoints(DataHelper.safeInt(variationObj, "var_points", 0));
                }
            }
        }
    }

    public static void parseProductsBrandNamesJson(String jsonString) throws JSONException {
        JSONObject jsonObject = new JSONObject(jsonString);
        JSONArray jsonArray = jsonObject.getJSONArray("woo_brand");
        for (int i = 0; i < jsonArray.length(); i++) {
            JSONObject obj = jsonArray.getJSONObject(i);
            Object data = obj.get("data");
            if (data instanceof String) {
                int productId = obj.getInt("pid");
                TM_ProductInfo product = TM_ProductInfo.findProductById(productId);
                if (product != null) {
                    product.setBrandName(data.toString());
                }
            }
        }
    }

    public static void parseProductsPriceLabelsJson(String jsonString) throws JSONException {
        JSONObject jsonObject = new JSONObject(jsonString);
        JSONArray jsonArray = jsonObject.getJSONArray("woocommerce_price_labeller");
        for (int i = 0; i < jsonArray.length(); i++) {
            JSONObject object = jsonArray.getJSONObject(i);
            TM_ProductInfo product = TM_ProductInfo.findProductById(object.getInt("pid"));
            if (product != null) {
                JSONObject dataObject = object.getJSONObject("data");
                product.setPriceLabel(dataObject.getString("price_label"));
                product.setPriceLabelPosition(dataObject.getString("label_position"));
            }
        }
    }

    public static String getJsonFromProduct(RawProductInfo product) throws JSONException {
        JSONObject jsonObject = new JSONObject();
        JSONObject jsonProduct = new JSONObject();
        {
            jsonProduct.put("title", product.title);
            jsonProduct.put("regular_price", product.regular_price);
            if (product.sale_price > 0 && product.sale_price < product.regular_price) {
                jsonProduct.put("sale_price", product.sale_price);
            }
            jsonProduct.put("description", product.description);
            jsonProduct.put("short_description", product.short_description);
            JSONArray categories = new JSONArray();

            for (RawCategory category : product.categories) {
                categories.put(category.getId());
            }

            jsonProduct.put("categories", categories);
            JSONArray images = new JSONArray();
            {
                int i = 0;
                for (String imageUrl : product.getImages()) {
                    JSONObject imageJson = new JSONObject();
                    {
                        imageJson.put("src", imageUrl);
                        imageJson.put("position", i++);
                    }
                    images.put(imageJson);
                }
            }
            jsonProduct.put("images", images);
            jsonProduct.put("type", product.type.toString());

            if (!product.attributes.isEmpty()) {
                JSONArray jsonAttributes = new JSONArray();
                {
                    int i = 0;
                    for (TM_Attribute attribute : product.attributes) {
                        JSONObject attributeJson = new JSONObject();
                        {
                            attributeJson.put("name", attribute.name);
                            attributeJson.put("slug", attribute.slug);
                            //attributeJson.put("position", attribute.position);
                            attributeJson.put("position", i++);
                            attributeJson.put("visible", attribute.visible);
                            attributeJson.put("variation", attribute.variation);
                            JSONArray attributeOptions = new JSONArray();
                            {
                                for (String option : attribute.options) {
                                    attributeOptions.put(option);
                                }
                            }
                            attributeJson.put("options", attributeOptions);
                        }
                        jsonAttributes.put(attributeJson);
                    }
                }
                jsonProduct.put("attributes", jsonAttributes);


                for (TM_Attribute attribute : product.attributes) {
                    if (!attribute.options.isEmpty()) {
                        JSONArray default_attributes = new JSONArray();
                        {
                            JSONObject defaultAttributeJson = new JSONObject();
                            {
                                defaultAttributeJson.put("name", attribute.name);
                                defaultAttributeJson.put("slug", attribute.slug);
                                defaultAttributeJson.put("option", attribute.options.get(0));
                            }
                            default_attributes.put(defaultAttributeJson);
                        }
                        jsonProduct.put("default_attributes", default_attributes);
                        break;
                    }
                }
            }

            if (!product.variations.isEmpty()) {
                JSONArray variationsJson = new JSONArray();
                {
                    for (TM_Variation variation : product.variations) {
                        JSONObject variationJson = new JSONObject();
                        variationJson.put("regular_price", variation.regular_price);
                        JSONArray variationImagesJson = new JSONArray();
                        {
                            for (TM_ProductImage image : variation.images) {
                                JSONObject imageJsonObject = new JSONObject();
                                {
                                    imageJsonObject.put("src", image.src);
                                    imageJsonObject.put("position", image.position);
                                }
                                variationImagesJson.put(imageJsonObject);
                            }
                        }
                        variationJson.put("regular_price", variationImagesJson);
                    }
                }
                jsonProduct.put("image", variationsJson);
            }

            jsonProduct.put("in_stock", product.in_stock);
            if (product.managing_stock) {
                jsonProduct.put("managing_stock", true);
                jsonProduct.put("stock_quantity", product.stock_quantity);
            }

            if (product.status != null) {
                jsonProduct.put("status", product.status.value());
            }
        }
        jsonObject.put("product", jsonProduct);
        return jsonObject.toString();
    }

    public static void parseProductsQuantityRulesJson(String jsonString) throws JSONException {
        JSONObject jsonObject = new JSONObject(jsonString);
        JSONArray jsonArray = jsonObject.getJSONArray("woocommerce_incremental_product_quantities");
        for (int i = 0; i < jsonArray.length(); i++) {
            JSONObject object = jsonArray.getJSONObject(i);
            TM_ProductInfo product = TM_ProductInfo.findProductById(object.getInt("pid"));
            if (product != null) {
                product.setQuantityRules(parseQuantityRulesData(object.getJSONObject("data")));
            }
        }
    }

    private static QuantityRule parseQuantityRulesData(JSONObject dataObject) throws JSONException {
        QuantityRule quantityRule = new QuantityRule();
        quantityRule.setOverrideRule(dataObject.getString("override_rule").equalsIgnoreCase("on"));
        quantityRule.setMinQuantity(DataHelper.safeInt(dataObject, "min_value", 0));
        quantityRule.setMaxQuantity(DataHelper.safeInt(dataObject, "max_value", 0));
        quantityRule.setMinOutOfStock(DataHelper.safeIntWithCeil(dataObject, "min_oos", 0));
        quantityRule.setMaxOutOfStock(DataHelper.safeIntWithCeil(dataObject, "max_oos", 0));
        quantityRule.setStepValue(DataHelper.safeIntWithCeil(dataObject, "step", 1));
        return quantityRule;
    }

    private static void parseAndSetPriceLabelData(TM_ProductInfo product, JSONObject jsonObject) {
        try {
            Object object = jsonObject.get("price_labeller");
            if (object instanceof JSONObject) {
                JSONObject jsonObj = (JSONObject) object;
                if (jsonObj.has("price_label"))
                    product.setPriceLabel(jsonObj.getString("price_label"));
                if (jsonObj.has("label_position"))
                    product.setPriceLabelPosition(jsonObj.getString("label_position"));
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public static void parseProductsPincodeSettings(String jsonString) throws JSONException {
        JSONObject pinCodeSettingJson = new JSONObject(jsonString).getJSONObject("pincode_settings");
        PincodeSetting pincodeSetting = PincodeSetting.getInstance();
        pincodeSetting.setEnableOnProductPage(pinCodeSettingJson.getBoolean("enable_on_productpage"));
        pincodeSetting.setZipTitle(pinCodeSettingJson.getString("zip_title"));
        pincodeSetting.setZipButtonText(pinCodeSettingJson.getString("zip_buttontext"));
        pincodeSetting.setZipNotFoundMessage(pinCodeSettingJson.getString("zip_notfound_msg"));
        pincodeSetting.clearZipSettings();
        JSONArray zipSettingsJsonArray = pinCodeSettingJson.getJSONArray("zip_settings");
        for (int i = 0; i < zipSettingsJsonArray.length(); i++) {
            JSONObject zipSettingJson = zipSettingsJsonArray.getJSONObject(i);
            PincodeSetting.ZipSetting zipSetting = new PincodeSetting.ZipSetting();
            zipSetting.setPincode(zipSettingJson.getString("pincode"));
            zipSetting.setMessage(zipSettingJson.getString("available_msg"));
            pincodeSetting.addZipSetting(zipSetting);
        }
        pincodeSetting.setFetched(true);
    }

    public static void parseJsonAndCreateShippingType(String jsonStringContent) throws JSONException {
        JSONArray jsonArrayShippingType = new JSONArray(jsonStringContent);

        for (int i = 0; i < jsonArrayShippingType.length(); i++) {
            JSONObject jsonObjectShippingType = jsonArrayShippingType.getJSONObject(i);
            parseShippingType(jsonObjectShippingType);
        }
    }

    private static void parseShippingType(JSONObject jsonObjectShippingType) {
        RawShipping tm_shippingType = new RawShipping();
        try {
            tm_shippingType.setId(JsonHelper.getString(jsonObjectShippingType, "id", ""));
            tm_shippingType.setLabel(JsonHelper.getString(jsonObjectShippingType, "label", ""));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }


    public static List<SellerInfo> parseJsonAndCreateVendors(String jsonString) {
        List<SellerInfo> sellers = new ArrayList<>();
        try {
            JSONArray jsonArray = DataHelper.safeJsonArray(jsonString);
            for (int i = 0; i < jsonArray.length(); i++) {
                SellerInfo seller = parseJsonAndCreateVendor(jsonArray.getJSONObject(i));
                sellers.add(seller);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return sellers;
    }

    public static SellerInfo parseJsonAndCreateVendor(String jsonString) {
        SellerInfo seller = null;
        try {
            seller = parseJsonAndCreateVendor(new JSONObject(jsonString));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return seller;
    }

    public static SellerInfo parseJsonAndCreateVendor(JSONObject jsonObject) throws JSONException {
        SellerInfo sellerInfo = new SellerInfo();
        sellerInfo.setId(JsonHelper.getString(jsonObject, "seller_id"));
        sellerInfo.setTitle(JsonHelper.getString(jsonObject, "seller_name"));
        sellerInfo.setEmail(JsonHelper.getString(jsonObject, "seller_email", ""));
        sellerInfo.setLocations(JsonHelper.getStringArray(jsonObject, "seller_location"));
        sellerInfo.setPhoneNumber(JsonHelper.getString(jsonObject, "seller_phone"));
        sellerInfo.setShopAddress(JsonHelper.getString(jsonObject, "shop_address"));
        sellerInfo.setImageUrl(JsonHelper.getString(jsonObject, "seller_image_url"));
        sellerInfo.setShopImageUrl(JsonHelper.getString(jsonObject, "shop_image_url"));
        sellerInfo.setShopUrl(JsonHelper.getString(jsonObject, "shop_url"));
        sellerInfo.setShopName(JsonHelper.getString(jsonObject, "shop_name"));
        return sellerInfo;
    }

    public static void parseAndCreateShortAttribute(String jsonString) throws JSONException {
        JSONArray jsonArrayShortAttribute = new JSONArray(jsonString);
        for (int i = 0; i < jsonArrayShortAttribute.length(); i++) {
            ShortAttribute shortAttribute = new ShortAttribute();
            JSONObject jsonObjectShippingType = jsonArrayShortAttribute.getJSONObject(i);

            String attribute_slug = jsonObjectShippingType.getString("attribute_slug");
            attribute_slug = attribute_slug.toLowerCase();
            if (attribute_slug.startsWith("pa_")) {
                attribute_slug = attribute_slug.substring(3, attribute_slug.length());
            }
            shortAttribute.setSlug(attribute_slug);

            shortAttribute.setName(jsonObjectShippingType.getString("attribute_name"));
            JSONObject jsonObjectTerms = jsonObjectShippingType.getJSONObject("attribute_terms");

            List<ShortAttribute.Term> termArrayList = new ArrayList<>();
            Iterator<String> termKeys = jsonObjectTerms.keys();
            while (termKeys.hasNext()) {
                ShortAttribute.Term term = new ShortAttribute.Term();
                term.key = termKeys.next();
                term.value = jsonObjectTerms.getString(term.key);
                termArrayList.add(term);
                shortAttribute.setTerms(termArrayList);
            }
        }
    }

    public static void parseBlogsResponse(String msg) throws JSONException {
        JSONArray jsonArrays = new JSONArray(msg);
        BlogItem.getAll().clear();
        for (int i = 0; i < jsonArrays.length(); i++) {
            JSONObject jsonObject = jsonArrays.getJSONObject(i);
            parseBlogResponse(jsonObject.toString());
        }
    }

    public static BlogItem parseBlogResponse(String msg) throws JSONException {
        JSONObject jsonObject = new JSONObject(msg);
        int id = jsonObject.getInt("ID");
        BlogItem blogItem = BlogItem.createBlog(id);
        blogItem.setId(id);
        String post_date = jsonObject.getString("post_date");
        blogItem.setPostDate(post_date);
        String post_content = jsonObject.getString("post_content");
        blogItem.setPostContent(post_content);
        String guid = jsonObject.getString("guid");
        blogItem.setGuid(guid);
        blogItem.setPostTitle(jsonObject.getString("post_title"));
        blogItem.setFeaturedImage(jsonObject.getString("featured_img"));
        blogItem.setPostAuthor(jsonObject.getString("post_author"));
        return blogItem;
    }

    public static AuctionInfo parseProductAuctionInfo(String jsonStringContent, TM_ProductInfo product) throws JSONException {
        JSONArray auctionJSONArray = DataHelper.safeJsonArray(jsonStringContent);

        JSONObject auctionJSON = auctionJSONArray.getJSONObject(0);
        JSONObject auctionInfo_JSON = auctionJSON.getJSONObject("auction_info");
        AuctionInfo auctionInfo = new AuctionInfo();

        auctionInfo.auction_bid_count = DataHelper.safeString(auctionInfo_JSON, "_auction_bid_count");
        auctionInfo.auction_regular_price = DataHelper.safeString(auctionInfo_JSON, "_regular_price");
        auctionInfo.auction_sale_price = DataHelper.safeString(auctionInfo_JSON, "_sale_price");
        auctionInfo.auction_price = DataHelper.safeString(auctionInfo_JSON, "_price");

        auctionInfo.auction_start_price = DataHelper.safeString(auctionInfo_JSON, "_auction_start_price");
        auctionInfo.auction_bid_increment = DataHelper.safeString(auctionInfo_JSON, "_auction_bid_increment");

        auctionInfo.auction_manage_stock = DataHelper.safeString(auctionInfo_JSON, "_manage_stock");
        auctionInfo.auction_stock = DataHelper.safeString(auctionInfo_JSON, "_stock");
        auctionInfo.auction_stock_status = DataHelper.safeString(auctionInfo_JSON, "_stock_status");

        auctionInfo.auction_dates_from = DataHelper.safeString(auctionInfo_JSON, "_auction_dates_from");
        auctionInfo.auction_dates_to = DataHelper.safeString(auctionInfo_JSON, "_auction_dates_to");

        auctionInfo.auction_item_condition = DataHelper.safeString(auctionInfo_JSON, "_auction_item_condition");
        auctionInfo.auction_type = DataHelper.safeString(auctionInfo_JSON, "_auction_type");

        auctionInfo.auction_current_bid = DataHelper.safeString(auctionInfo_JSON, "_auction_current_bider");
        auctionInfo.auction_start = DataHelper.safeString(auctionInfo_JSON, "auction_start");
        auctionInfo.timezone = DataHelper.safeString(auctionInfo_JSON, "timezone");

        if (!auctionInfo.auctionHistoryList.isEmpty())
            auctionInfo.auctionHistoryList.clear();

        JSONArray auctionHistoryJsonArray = auctionJSON.getJSONArray("auction_history");
        for (int k = 0; k < auctionHistoryJsonArray.length(); k++) {

            JSONObject auctionHistoryJsonObject = auctionHistoryJsonArray.getJSONObject(k);
            AuctionInfo.AuctionHistory auctionHistory = new AuctionInfo.AuctionHistory();

            if (auctionHistoryJsonObject.has("id"))
                auctionHistory.id = DataHelper.safeString(auctionHistoryJsonObject, "id");

            if (auctionHistoryJsonObject.has("userid"))
                auctionHistory.userid = DataHelper.safeString(auctionHistoryJsonObject, "userid");

            if (auctionHistoryJsonObject.has("userid"))
                auctionHistory.username = DataHelper.safeString(auctionHistoryJsonObject, "username");

            if (auctionHistoryJsonObject.has("auction_id"))
                auctionHistory.auction_id = DataHelper.safeString(auctionHistoryJsonObject, "auction_id");

            if (auctionHistoryJsonObject.has("bid"))
                auctionHistory.bid = DataHelper.safeString(auctionHistoryJsonObject, "bid");

            if (auctionHistoryJsonObject.has("date"))
                auctionHistory.date = DataHelper.safeString(auctionHistoryJsonObject, "date");

            if (auctionHistoryJsonObject.has("proxy"))
                auctionHistory.proxy = DataHelper.safeString(auctionHistoryJsonObject, "proxy");

            auctionInfo.auctionHistoryList.add(auctionHistory);
        }
        product.auctionInfo = auctionInfo;
        return auctionInfo;
    }


    public static BookingInfo parseProductBookingInfo(String jsonStringContent, TM_ProductInfo product) throws Exception {
        JSONObject bookingInfo_JSON = DataHelper.safeJsonObject(jsonStringContent);

        BookingInfo bookingInfo = new BookingInfo();
        DateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

        bookingInfo.product = DataHelper.safeString(bookingInfo_JSON, "product");

        JSONObject bookingsDate_JSON = bookingInfo_JSON.getJSONObject("bookings_date");

        bookingInfo.enable_addtocart = bookingsDate_JSON.getBoolean("addtocart");

        bookingInfo.start_date = sdf.parse(DataHelper.safeString(bookingsDate_JSON, "start_date"));

        bookingInfo.end_date = sdf.parse(DataHelper.safeString(bookingsDate_JSON, "end_date"));

        JSONArray partiallyBookedDaysJsonArray = bookingsDate_JSON.getJSONArray("partially_booked_days");
        if (partiallyBookedDaysJsonArray.length() > 0) {
            List<Date> partiallyBookedDaysList = new ArrayList<>();
            for (int i = 0; i < partiallyBookedDaysJsonArray.length(); i++) {
                partiallyBookedDaysList.add(sdf.parse(partiallyBookedDaysJsonArray.getString(i)));
            }
            if (partiallyBookedDaysList.size() > 0) {
                bookingInfo.partially_booked_days = new Calendar[partiallyBookedDaysList.size()];
                for (int i = 0; i < partiallyBookedDaysList.size(); i++) {
                    Calendar calendar = Calendar.getInstance();
                    calendar.setTime(partiallyBookedDaysList.get(i));
                    bookingInfo.partially_booked_days[i] = calendar;
                }
            }
        }

        JSONArray fullyBookedDaysJsonArray = bookingsDate_JSON.getJSONArray("fully_booked_days");
        if (fullyBookedDaysJsonArray.length() > 0) {
            List<Date> fullyBookedDaysList = new ArrayList<>();
            for (int i = 0; i < fullyBookedDaysJsonArray.length(); i++) {
                fullyBookedDaysList.add(sdf.parse(fullyBookedDaysJsonArray.getString(i)));
            }
            if (fullyBookedDaysList.size() > 0) {
                bookingInfo.fully_booked_days = new Calendar[fullyBookedDaysList.size()];
                for (int i = 0; i < fullyBookedDaysList.size(); i++) {
                    Calendar calendar = Calendar.getInstance();
                    calendar.setTime(fullyBookedDaysList.get(i));
                    bookingInfo.fully_booked_days[i] = calendar;
                }
            }
        }

        JSONArray bufferDaysJsonArray = bookingsDate_JSON.getJSONArray("buffer_days");
        if (bufferDaysJsonArray.length() > 0) {
            List<Date> bufferDaysList = new ArrayList<>();
            for (int i = 0; i < bufferDaysJsonArray.length(); i++) {
                bufferDaysList.add(sdf.parse(bufferDaysJsonArray.getString(i)));
            }
            if (bufferDaysList.size() > 0) {
                bookingInfo.buffer_days = new Calendar[bufferDaysList.size()];
                for (int i = 0; i < bufferDaysList.size(); i++) {
                    Calendar calendar = Calendar.getInstance();
                    calendar.setTime(bufferDaysList.get(i));
                    bookingInfo.buffer_days[i] = calendar;
                }
            }
        }

        product.bookingInfo = bookingInfo;
        return bookingInfo;
    }

    public static BookingInfo parseProductBookingCostInfo(String jsonStringContent, TM_ProductInfo product) throws Exception {
        if (product.bookingInfo == null) {
            return null;
        }
        JSONObject bookingCostInfo_JSON = DataHelper.safeJsonObject(jsonStringContent);

        BookingInfo bookingInfo = product.bookingInfo;

        bookingInfo.result = DataHelper.safeString(bookingCostInfo_JSON, "result");
        bookingInfo.error = DataHelper.safeString(bookingCostInfo_JSON, "error");

        bookingInfo.booking_price = TM_CommonInfo.getPriceIncludingTax1(DataHelper.safeFloatPrice(DataHelper.safeString(bookingCostInfo_JSON, "price")), product.taxable);

        bookingInfo.price_suffix = DataHelper.safeString(bookingCostInfo_JSON, "price_suffix");
        product.bookingInfo.product_id_booking = bookingCostInfo_JSON.getInt("pid");

        product.bookingInfo = bookingInfo;
        return bookingInfo;
    }

}

