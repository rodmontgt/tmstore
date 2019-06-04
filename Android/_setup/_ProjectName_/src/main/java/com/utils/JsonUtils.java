package com.utils;

import android.content.Context;
import android.text.TextUtils;
import com.google.gson.Gson;
import com.twist.dataengine.WooCommerceJSONHelper;
import com.twist.dataengine.entities.*;
import com.twist.tmstore.L;
import com.twist.tmstore.config.GuestUserConfig;
import com.twist.tmstore.entities.*;
import com.twist.tmstore.payments.PaymentGateway;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.*;

import static com.twist.tmstore.L.getString;

/**
 * Created by Twist Mobile on 01-Dec-16.
 */

public class JsonUtils {
    public static void parseJsonAndCreateAppUser(String jsonStringContent) {
        Log.d("- parseJsonAndCreateAppUser: [" + jsonStringContent + "] --");
        JSONObject jMainObject = null;
        try {
            jMainObject = safeJSONObject(jsonStringContent);
            JSONObject jsonObject = jMainObject.getJSONObject("customer");

            AppUser.getInstance().user_type = AppUser.USER_TYPE.WORDPRESS_USER;
            AppUser.setUserId(jsonObject.getInt("id"));
            AppUser.getInstance().created_at = jsonObject.getString("created_at");
            AppUser.getInstance().email = jsonObject.getString("email");

            String first_name = jsonObject.getString("first_name");
            if (!first_name.equals("")) {
                AppUser.getInstance().first_name = first_name;
            }
            String last_name = jsonObject.getString("last_name");
            if (!last_name.equals("")) {
                AppUser.getInstance().last_name = last_name;
            }
            AppUser.getInstance().username = jsonObject.getString("username");
            AppUser.getInstance().orders_count = jsonObject.getInt("orders_count");
            AppUser.getInstance().total_spent = Double.parseDouble(jsonObject.getString("total_spent"));
            AppUser.getInstance().avatar_url = jsonObject.getString("avatar_url");

            if (jsonObject.has("role")) {
                AppUser.getInstance().setRole(jsonObject.getString("role"));
            }

            JSONObject json_billing_address = jsonObject.getJSONObject("billing_address");
            Address billing_address = parseAddress(json_billing_address);
            billing_address.title = getString(L.string.billing_address);


            JSONObject json_shipping_address = jsonObject.getJSONObject("shipping_address");
            Address shipping_address = parseAddress(json_shipping_address);
            shipping_address.title = getString(L.string.shipping_address);

            if (AppUser.getInstance().billing_address == null || !AppUser.getInstance().billing_address.hasData()) {
                Log.d("-- found billing data : [" + billing_address.getAddressLine() + "]--");
                AppUser.getInstance().billing_address = billing_address;
                AppUser.getInstance().billing_address.save();
            }

            if (AppUser.getInstance().shipping_address == null || !AppUser.getInstance().shipping_address.hasData()) {
                Log.d("-- found shipping data : [" + shipping_address.getAddressLine() + "]--");
                AppUser.getInstance().shipping_address = shipping_address;
                AppUser.getInstance().shipping_address.save();
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            Log.d("-- Saving with customer id: [" + AppUser.getUserId() + "] --");
            AppUser.getInstance().saveAll();
        }
    }

    public static String getShippingString(Address address) throws JSONException {
        AppUser appUser = AppUser.getInstance();
        JSONArray jsonArray;
        if (appUser.getAddressJson() != null && !appUser.getAddressJson().isEmpty()) {
            jsonArray = new JSONArray(appUser.getAddressJson());
        } else {
            jsonArray = new JSONArray();
        }

        JSONObject jsonObjectAddress = getShippingJSON(address);
        jsonArray.put(jsonArray.length(), jsonObjectAddress);
        return jsonArray.toString();
    }

    public static JSONObject getShippingJSON(Address address) throws JSONException {
        JSONObject data = new JSONObject();
        data.put("shipping_first_name", address.first_name);
        data.put("shipping_last_name", address.last_name);
        data.put("shipping_company", address.company);
        data.put("shipping_address_1", address.address_1);
        data.put("shipping_address_2", address.address_2);
        data.put("shipping_city", address.city);
        data.put("shipping_state", address.state);
        data.put("shipping_postcode", address.postcode);
        data.put("label", address.first_name);
        return data;
    }

    public static String getLocalShippingString() throws JSONException {
        AppUser appUser = AppUser.getInstance();
        List<Address> addressList = appUser.addressList;
        JSONArray jsonArray = new JSONArray();
        for (Address address1 : addressList) {
            JSONObject jsonObjectAddress = getLocalShippingJSON(address1);
            jsonArray.put(jsonObjectAddress);
        }
        return jsonArray.toString();
    }

    public static JSONObject getLocalShippingJSON(Address address) throws JSONException {
        JSONObject data = new JSONObject();
        data.put("shipping_first_name", address.first_name);
        data.put("shipping_last_name", address.last_name);
        data.put("shipping_company", address.company);
        data.put("shipping_address_1", address.address_1);
        data.put("shipping_city", address.city);
        data.put("shipping_state", address.state);
        data.put("shipping_postcode", address.postcode);
        data.put("shipping_latitude", address.latitude);
        data.put("shipping_longitude", address.longitude);
        data.put("label", address.first_name);
        return data;
    }

    public static MyProfileItem parseMyProfileObject(JSONObject jsonDrawerItem, Context context) throws JSONException {
        int id = jsonDrawerItem.getInt("id");
        MyProfileItem myProfileItem;
        if (jsonDrawerItem.has("name")) {
            String name = jsonDrawerItem.getString("name");
            myProfileItem = new MyProfileItem(id, name);
        } else {
            myProfileItem = new MyProfileItem(id);
        }
        return myProfileItem;
    }

    public static NavDrawItem createNavDrawItem(JSONObject drawerItemJSON, Context context) throws JSONException {
        int id = drawerItemJSON.getInt("id");
        NavDrawItem drawerItem;
        if (drawerItemJSON.has("name")) {
            String name = drawerItemJSON.getString("name");
            drawerItem = new NavDrawItem(id, name);
        } else {
            drawerItem = new NavDrawItem(id);
        }

        if (drawerItemJSON.has("icon_url")) {
            Object object = drawerItemJSON.get("icon_url");
            drawerItem.setIconUrl(object.toString());
        }

        if (drawerItemJSON.has("sort_order")) {
            drawerItem.setSortOrder(JsonHelper.getIntArray(drawerItemJSON, "sort_order"));
        }

        if (drawerItemJSON.has("data")) {
            String data = drawerItemJSON.getString("data");
            drawerItem.setData(data);
        }

        if (drawerItemJSON.has("role")) {
            String data = drawerItemJSON.getString("role");
            drawerItem.setRole(data);
        }

        if (drawerItemJSON.has("children")) {
            JSONArray children = drawerItemJSON.getJSONArray("children");
            for (int j = 0; j < children.length(); j++) {
                drawerItem.addChild(createNavDrawItem(children.getJSONObject(j), context));
            }
        }
        drawerItem.setShowIcon(JsonHelper.getBool(drawerItemJSON, "show_icon", true));
        return drawerItem;
    }

    public static void parseJsonAndCreateAppColors(String jsonString) throws JSONException {
        JSONObject jsonObject = new JSONObject(jsonString);
        /* Color value can't be empty for application hence set default value if there is empty value came from cloud. */
        AppInfo.color_theme = JsonHelper.getHexColorString(jsonObject, "color_theme", AppInfo.color_theme);
        AppInfo.color_theme_statusbar = JsonHelper.getHexColorString(jsonObject, "color_theme_statusbar", AppInfo.color_theme_statusbar);
        AppInfo.normal_button_color = JsonHelper.getHexColorString(jsonObject, "normal_button_color", AppInfo.normal_button_color);
        AppInfo.normal_button_text_color = JsonHelper.getHexColorString(jsonObject, "normal_button_text_color", AppInfo.normal_button_text_color);
        AppInfo.selected_button_color = JsonHelper.getHexColorString(jsonObject, "selected_button_color", AppInfo.selected_button_color);
        AppInfo.selected_button_text_color = JsonHelper.getHexColorString(jsonObject, "selected_button_text_color", AppInfo.selected_button_text_color);
        AppInfo.disable_button_color = JsonHelper.getHexColorString(jsonObject, "desable_button_color", AppInfo.disable_button_color);
        AppInfo.color_pager_title_strip = JsonHelper.getHexColorString(jsonObject, "color_pager_title_strip", AppInfo.color_pager_title_strip);
        AppInfo.color_actionbar_text = JsonHelper.getHexColorString(jsonObject, "color_actionbar_text", AppInfo.color_actionbar_text);
        AppInfo.color_theme_dark = JsonHelper.getHexColorString(jsonObject, "color_theme_dark", AppInfo.color_theme_dark);
        AppInfo.color_regular_price = JsonHelper.getHexColorString(jsonObject, "color_regular_price", AppInfo.color_regular_price);
        AppInfo.color_sale_price = JsonHelper.getHexColorString(jsonObject, "color_sale_price", AppInfo.color_sale_price);
        AppInfo.color_splash_text = JsonHelper.getHexColorString(jsonObject, "color_splash_text", AppInfo.color_splash_text);
        AppInfo.color_splash_bg = JsonHelper.getHexColorString(jsonObject, "color_splash_bg", AppInfo.color_splash_bg);
        AppInfo.color_home_section_header_bg = JsonHelper.getHexColorString(jsonObject, "color_home_section_header_bg", AppInfo.color_home_section_header_bg);
        AppInfo.color_home_section_header_text = JsonHelper.getHexColorString(jsonObject, "color_home_section_header_text", AppInfo.color_home_section_header_text);

        if (jsonObject.has("color_bottom_nav_normal")) {
            AppInfo.color_bottom_nav_normal = JsonHelper.getHexColorString(jsonObject, "color_bottom_nav_normal", AppInfo.color_bottom_nav_normal);
        } else {
            AppInfo.color_bottom_nav_normal = AppInfo.color_theme;
        }

        if (jsonObject.has("color_bottom_nav_selected")) {
            AppInfo.color_bottom_nav_selected = JsonHelper.getHexColorString(jsonObject, "color_bottom_nav_selected", AppInfo.color_bottom_nav_selected);
        } else {
            AppInfo.color_bottom_nav_selected = AppInfo.color_theme;
        }

        if (jsonObject.has("color_bottom_nav_bg")) {
            AppInfo.color_bottom_nav_bg = JsonHelper.getHexColorString(jsonObject, "color_bottom_nav_bg", AppInfo.color_bottom_nav_bg);
        } else {
            AppInfo.color_bottom_nav_bg = AppInfo.color_actionbar_text;
        }
    }

    public static CartMeta parseJsonAndCreateCartMeta(String jsonString) {
        CartMeta cartMeta = new CartMeta();
        try {
            JSONObject jsonObject = DataHelper.safeJsonObject(jsonString);
            if (jsonObject.has("cart_meta")) {
                JSONObject cart_meta = jsonObject.getJSONObject("cart_meta");
                JSONArray coupon_discounted = cart_meta.getJSONArray("coupon_discounted");
                cartMeta.applied_coupons = new AppliedCoupon[coupon_discounted.length()];
                for (int i = 0; i < coupon_discounted.length(); i++) {
                    JSONObject jsonObjectCoupon = coupon_discounted.getJSONObject(i);
                    cartMeta.applied_coupons[i] = new AppliedCoupon(jsonObjectCoupon.getString("coupon"));
                    cartMeta.applied_coupons[i].discount_amount = (float) jsonObjectCoupon.getDouble("discount");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return cartMeta;
    }

    public static MinOrderData parseJsonAndCreateMinOrderData(String jsonString) {
        try {
            JSONObject jsonObject = DataHelper.safeJsonObject(jsonString);
            if (jsonObject.has("min_order_data")) {
                MinOrderData minOrder = new MinOrderData();
                JSONObject min_order_data = jsonObject.getJSONObject("min_order_data");
                minOrder.minOrderAmount = (float) min_order_data.getDouble("wcj_order_minimum_amount");
                minOrder.minOrderMessage = min_order_data.getString("wcj_order_minimum_amount_error_message");
                return minOrder;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public static List<TimeSlot> parseJsonAndCreateTimeSlots(String jsonString) throws JSONException {
        List<TimeSlot> timeSlots = new ArrayList<>();
        JSONObject jsonObject = DataHelper.safeJsonObject(jsonString);
        Iterator<String> keys = jsonObject.keys();
        while (keys.hasNext()) {
            TimeSlot timeSlot = new TimeSlot(keys.next());
            String value = jsonObject.getString(timeSlot.getId());
            timeSlot.setTitle(value);
            //timeSlot.cost = (float) jsonObject.getDouble("cost");
            timeSlots.add(timeSlot);
        }
        return timeSlots;
    }

    public static List<DateTimeSlot> createDateTimeSlots(String jsonString) throws JSONException {
        ArrayList<DateTimeSlot> dateTimeSlots = new ArrayList<>();
        JSONArray jsonArray = DataHelper.safeJsonArray(jsonString);
        for (int i = 0; i < jsonArray.length(); i++) {
            ArrayList<TimeSlot> timeSlots = new ArrayList<>();
            JSONObject jsonObject = jsonArray.getJSONObject(i);
            String dateSlot = jsonObject.getString("dateSlot");
            DateTimeSlot dateTimeSlot = new DateTimeSlot(dateSlot);
            JSONArray timeJsonArray = jsonObject.getJSONArray("timeSlot");
            for (int j = 0; j < timeJsonArray.length(); j++) {
                JSONObject jsonTimeObject = timeJsonArray.getJSONObject(j);
                int id = jsonTimeObject.getInt("id");
                String title = jsonTimeObject.getString("title");
                String cost = jsonTimeObject.getString("cost");
                TimeSlot timeSlot = new TimeSlot(id);
                timeSlot.setCost(cost);
                timeSlot.setTitle(title);
                timeSlot.setParent(dateTimeSlot);
                timeSlots.add(timeSlot);
            }
            dateTimeSlot.setTimeSlots(timeSlots);
            dateTimeSlots.add(dateTimeSlot);
        }
        return dateTimeSlots;
    }

    public static Map<String, List<DateTimeSlot>> createShippingDateTimeSlotsMap(List<TM_Shipping> shippingList, String jsonString) throws JSONException {
        /*
        * Sample Json for Parsing
        * {
              "flat_rate": {
                "07/08/2017": [
                  {
                    "title": "07:30 PM - 08:30 PM",
                    "id": 0,
                    "cost": "0"
                  },
                  {
                    "title": "07:30 PM - 11:00 PM",
                    "id": 2,
                    "cost": "7"
                  }
                ],
                "08/08/2017": [
                  {
                    "title": "07:30 PM - 08:30 PM",
                    "id": 0,
                    "cost": "0"
                  },
                  {
                    "title": "07:30 PM - 11:00 PM",
                    "id": 2,
                    "cost": "7"
                  }
                ]
              }
            }
        * */

        Map<String, List<DateTimeSlot>> shippingDateTimeSlotsMap = new HashMap<>(shippingList.size());
        JSONObject jsonObject = new JSONObject(jsonString);
        for (TM_Shipping shipping : shippingList) {
            ArrayList<DateTimeSlot> dateTimeSlots = new ArrayList<>();
            JSONObject shippingJsonObject = jsonObject.getJSONObject(shipping.method_id);
            Iterator<String> dateKeys = shippingJsonObject.keys();
            while (dateKeys.hasNext()) {
                String dateKey = dateKeys.next();
                DateTimeSlot dateTimeSlot = new DateTimeSlot(dateKey);
                ArrayList<TimeSlot> timeSlots = new ArrayList<>();
                JSONArray dateSlotJsonArray = shippingJsonObject.getJSONArray(dateKey);
                for (int i = 0; i < dateSlotJsonArray.length(); i++) {
                    JSONObject timeSlotJsonObject = dateSlotJsonArray.getJSONObject(i);
                    int id = timeSlotJsonObject.getInt("id");
                    String title = timeSlotJsonObject.getString("title");
                    String cost = timeSlotJsonObject.getString("cost");
                    TimeSlot timeSlot = new TimeSlot(id);
                    timeSlot.setTitle(title);
                    timeSlot.setCost(cost);
                    timeSlot.setParent(dateTimeSlot);
                    timeSlots.add(timeSlot);
                }
                dateTimeSlot.setTimeSlots(timeSlots);
                dateTimeSlots.add(dateTimeSlot);
            }
            shippingDateTimeSlotsMap.put(shipping.method_id, dateTimeSlots);
        }
        return shippingDateTimeSlotsMap;
    }

    public static List<FeeData> parseJsonAndCreateFees(String jsonString) {
        List<FeeData> feeData = new ArrayList<>();
        try {
            JSONObject jsonObject = DataHelper.safeJsonObject(jsonString);
            JSONArray fee_data = jsonObject.getJSONArray("fee_data");
            for (int i = 0; i < fee_data.length(); i++) {
                FeeData fee = parseJsonAndCreateFee(fee_data.getJSONObject(i));
                feeData.add(fee);
            }
        } catch (Exception e) {
            Log.e("fee_data in not available");
        }
        return feeData;
    }

    public static SellerInfo parseJsonAndCreateSellerInfo(String jsonString) throws JSONException {
        JSONObject jsonObject = null;
        String id = "";
        String last_name = "";
        String first_name = "";
        String[] location = null;
        String profile_url = "";
        boolean verified = false;
        String phone = "";
        String info = "";
        String avatar = "";
        String name = "";
        String shop_url = "";
        String icon_url = "";
        String banner_url = "";
        String address = "";
        String description = "";
        Double latitude = 0.0;
        Double longitude = 0.0;
        jsonObject = new JSONObject(jsonString);
        if (jsonObject.has("seller")) {
            JSONObject sellerObject = jsonObject.getJSONObject("seller");
            id = JsonHelper.getString(sellerObject, "id", "");
            first_name = JsonHelper.getString(sellerObject, "first_name", "");
            last_name = JsonHelper.getString(sellerObject, "last_name", "");
            avatar = JsonHelper.getString(sellerObject, "avatar", "");
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
            try {
                JSONObject geoLocation = jsonObject.getJSONObject("geo_location");
                latitude = JsonHelper.getDouble(geoLocation, "latitude", 0.0);
                longitude = JsonHelper.getDouble(geoLocation, "longitude", 0.0);
            } catch (Exception e) {
                Log.e("latitude  or longitude not available");
            }
        }

        SellerInfo sellerInfo = new SellerInfo();
        sellerInfo.setId(id);
        sellerInfo.setPhoneNumber(phone);
        sellerInfo.setTitle(first_name);
        sellerInfo.setShopAddress(address);
        sellerInfo.setShopName(name);
        sellerInfo.setVerified(verified);
        sellerInfo.setVendorLastName(last_name);
        sellerInfo.setIconUrl(icon_url);
        sellerInfo.setAvatarUrl(avatar);
        sellerInfo.setLatitude(latitude);
        sellerInfo.setLongitude(longitude);

        if (jsonObject.has("membership_level")) {
            try {
                JSONObject membership_level = jsonObject.getJSONObject("membership_level");
                sellerInfo.subscription_id = JsonHelper.getString(membership_level, "subscription_id", "");
                sellerInfo.level_id = JsonHelper.getString(membership_level, "level_id", "");
                sellerInfo.subscription_name = JsonHelper.getString(membership_level, "subscription_name", "");
                sellerInfo.subscription_url = JsonHelper.getString(membership_level, "subscription_url", "");
                sellerInfo.expiration_number = JsonHelper.getString(membership_level, "expiration_number", "");
                sellerInfo.expiration_period = JsonHelper.getString(membership_level, "expiration_period", "");
                sellerInfo.allow_signups = JsonHelper.getString(membership_level, "allow_signups", "");
                sellerInfo.initial_payment = JsonHelper.getString(membership_level, "initial_payment", "");
                sellerInfo.billing_amount = JsonHelper.getString(membership_level, "billing_amount", "");
                sellerInfo.trial_amount = JsonHelper.getString(membership_level, "trial_amount", "");
                sellerInfo.trial_limit = JsonHelper.getString(membership_level, "trial_limit", "");
                sellerInfo.startdate = JsonHelper.getString(membership_level, "startdate", "");
                sellerInfo.enddate = JsonHelper.getString(membership_level, "enddate", "");
                sellerInfo.membership_status = JsonHelper.getString(membership_level, "membership_status", "");
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return sellerInfo;
    }

    public static FeeData parseJsonAndCreateFee(JSONObject jsonObject) throws JSONException {
        FeeData fee = new FeeData();
        fee.plugin_title = jsonObject.getString("plugin_title");
        fee.label = jsonObject.getString("label");
        fee.taxable = jsonObject.getBoolean("taxable");
        fee.minorder = safeFloat(jsonObject.getString("minorder"));
        fee.cost = safeFloat(jsonObject.getString("cost"));
        fee.type = FeeData.Type.from(JsonHelper.getString(jsonObject, "type"));
        return fee;
    }

    public static List<TM_Shipping> parseJsonAndCreateOrderData(String jsonString) throws JSONException {
        List<TM_Shipping> shippingMethods = new ArrayList<>();
        JSONObject jsonObject = DataHelper.safeJsonObject(jsonString);
        if (jsonObject.has("shipping_data")) {
            JSONObject shipping_data = jsonObject.getJSONObject("shipping_data");
            parseShippingMethods(shippingMethods, shipping_data);
            TM_PaymentGateway.clear();
            try {
                JSONObject payment = jsonObject.getJSONObject("payment");
                if (payment.has("gateways")) {
                    JSONArray gatewaysArray = payment.getJSONArray("gateways");
                    for (int i = 0; i < gatewaysArray.length(); i++) {
                        JSONObject gatewayJsonObject = gatewaysArray.getJSONObject(i);
                        TM_PaymentGateway paymentGateway = WooCommerceJSONHelper.parseJsonAndCreateGateway(gatewayJsonObject);
                        paymentGateway.commit();
                    }
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        } else {
            parseShippingMethods(shippingMethods, jsonObject);
        }
        return shippingMethods;
    }

    public static void parseShippingMethods(List<TM_Shipping> shippingMethods, JSONObject jsonObject) throws JSONException {
        if (jsonObject.has("show_shipping") && jsonObject.getInt("show_shipping") == 0) {
            TM_Shipping.SHIPPING_REQUIRED = false;
            return;
        }

        JSONArray shipping = jsonObject.getJSONArray("shipping");
        JSONObject firstBlock = shipping.getJSONObject(0);
        JSONArray methods = firstBlock.getJSONArray("methods");
        for (int i = 0; i < methods.length(); i++) {
            JSONObject methodJson = methods.getJSONObject(i);
            TM_Shipping shippingMethod = new TM_Shipping();
            shippingMethod.id = methodJson.getString("id");
            shippingMethod.label = methodJson.getString("label");
            shippingMethod.cost = Double.parseDouble(methodJson.getString("cost"));
            if (methodJson.has("taxes")) {
                try {
                    if (methodJson.get("taxes") instanceof JSONArray) {
                        JSONArray taxesJson = methodJson.getJSONArray("taxes");
                        for (int j = 0; j < taxesJson.length(); j++) {
                            shippingMethod.taxes.add(taxesJson.getString(j));
                        }
                    } else if (methodJson.get("taxes") instanceof JSONObject) {
                        JSONObject taxesJson = methodJson.getJSONObject("taxes");
                        Iterator<String> iterator = taxesJson.keys();
                        while (iterator.hasNext()) {
                            shippingMethod.taxes.add(taxesJson.get(iterator.next()).toString());
                        }
                    }
                } catch (JSONException e) {
                    Log.d("Error while parsing shipping tax data in JSON");
                    e.printStackTrace();
                }
            }
            if (methodJson.has("locations")) {
                try {
                    JSONArray locations = methodJson.getJSONArray("locations");
                    for (int k = 0; k < locations.length(); k++) {
                        shippingMethod.locations.add(parsePickupLocation(locations.getJSONObject(k)));

                    }
                } catch (JSONException e) {
                    Log.d("Error while parsing shipping Pickup Location data in JSON");
                    e.printStackTrace();
                }
            }
            shippingMethod.method_id = methodJson.getString("method_id");
            shippingMethods.add(shippingMethod);
        }
    }

    private static TM_Shipping_Pickup_Location parsePickupLocation(JSONObject jsonObject) throws JSONException {
        Log.D("-- parsePickupLocation:[" + jsonObject.toString() + "] --");
        TM_Shipping_Pickup_Location tm_shipping_pickup_location = new TM_Shipping_Pickup_Location();
        tm_shipping_pickup_location.id = jsonObject.getString("id");
        tm_shipping_pickup_location.country = jsonObject.getString("country");
        tm_shipping_pickup_location.cost = jsonObject.getString("cost");
        tm_shipping_pickup_location.note = jsonObject.getString("note");
        tm_shipping_pickup_location.company = jsonObject.getString("company");
        tm_shipping_pickup_location.address_1 = jsonObject.getString("address_1");
        tm_shipping_pickup_location.address_2 = jsonObject.getString("address_2");
        tm_shipping_pickup_location.city = jsonObject.getString("city");
        tm_shipping_pickup_location.state = jsonObject.getString("state");
        tm_shipping_pickup_location.postcode = jsonObject.getString("postcode");
        tm_shipping_pickup_location.phone = jsonObject.getString("phone");
        return tm_shipping_pickup_location;
    }

    public static Address parseAddress(JSONObject json_address) throws JSONException {
        Address address = new Address();
        address.first_name = safeString(json_address, "first_name");
        address.last_name = safeString(json_address, "last_name");
        address.company = safeString(json_address, "company");
        address.address_1 = safeString(json_address, "address_1");
        address.address_2 = safeString(json_address, "address_2");
        address.city = safeString(json_address, "city");
        address.stateCode = safeString(json_address, "state");
        address.postcode = safeString(json_address, "postcode");
        address.countryCode = safeString(json_address, "country");
        address.email = safeString(json_address, "email");
        address.phone = safeString(json_address, "phone");
        address.region = "";
        return address;
    }

    public static int getProductIdFromNotificationJson(String jsonString) {
        try {
            JSONObject jsonObject = DataHelper.safeJsonObject(jsonString);
            return jsonObject.getInt("product_id");
        } catch (Exception ex) {
            return -1;
        }
    }

    public static String safeString(JSONObject obj, String key) throws JSONException {
        if (obj == null) {
            return "";
        }

        if (obj.has(key)) {
            return obj.getString(key);
        }
        return "";
    }

    public static float safeFloat(String input) {
        float output = 0.0f;

        if (input == null)
            return output;

        if (input.equals(""))
            return output;

        if (input.equals("null"))
            return output;

        try {
            output = Float.parseFloat(input);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return output;
    }

    public static String prepareBookingJson() {
        String bookingId = "";
        JSONObject data = new JSONObject();
        JSONArray booking_data = new JSONArray();
        for (Cart cart : Cart.getAll()) {
            if (TextUtils.isEmpty(cart.product.orderAgainBookingId)) {
                break;
            }
            try {
                JSONObject booking_item = new JSONObject();
                booking_item.put("booking_id", cart.product.orderAgainBookingId);
                booking_item.put("booking_date", cart.product.orderAgainBookingDate);
                bookingId = cart.product.orderAgainBookingId;
                booking_data.put(booking_item);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        try {
            data.put("data", booking_data);
        } catch (JSONException je) {
            je.printStackTrace();
        }
        Log.d("------------ sending booking data -----------");
        Log.d(data.toString());
        Log.d("------------------------------------------");
        return booking_data.length() != 0 ? bookingId : null;
    }

    public static String prepareCartJson() {
        JSONObject data = new JSONObject();
        JSONArray cart_data = new JSONArray();
        for (Cart cart : Cart.getAll()) {
            try {
                JSONObject cart_item = new JSONObject();
                cart_item.put("pid", cart.product_id);
                cart_item.put("variation_id", cart.selected_variation_id);
                if (AppInfo.SHOW_PRODUCTS_BOOKING_INFO) {
                    cart_item.put("booking_date", cart.booking_date);
                }
                cart_item.put("quantity", cart.count);
                if (cart.attributes != null) {
                    JSONArray jsonAttributes = new JSONArray();
                    for (TM_VariationAttribute attribute : cart.attributes) {
                        JSONObject jAttribute = new JSONObject();
                        String attributeName = attribute.name;
                        String attributeValue = attribute.value;
                        //super special case
                        if (attributeValue == null || attributeValue.equals("")) {
                            List<TM_Attribute> tm_attributes = cart.product.attributes;
                            for (TM_Attribute attribute1 : tm_attributes) {
                                if (attribute1.slug.equals(attribute.slug)) {
                                    attributeValue = attribute1.options.get(0);
                                }
                            }
                        }

                        if (!AppInfo.SKIP_MANUAL_ENCODING) {
                            try {
                                attributeName = URLEncoder.encode(attributeName, "UTF-8");
                                attributeValue = URLEncoder.encode(attributeValue, "UTF-8");
                            } catch (UnsupportedEncodingException ignored) {
                            }
                        }
                        jAttribute.put("name", attributeName);
                        jAttribute.put("value", attributeValue);
                        jsonAttributes.put(jAttribute);
                    }
                    cart_item.put("attributes", jsonAttributes);
                } else {
                    cart_item.put("attributes", null);
                }

                if (!TextUtils.isEmpty(cart.cart_meta_json)) {
                    cart_item.put("cart_meta", new JSONObject(cart.cart_meta_json));
                }
                cart_data.put(cart_item);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        try {
            data.put("data", cart_data);
        } catch (JSONException je) {
            je.printStackTrace();
        }
        Log.d("------------ sending cart data -----------");
        Log.d(data.toString());
        Log.d("------------------------------------------");
        return cart_data.toString();
    }

    public static String prepareShippingJson() {
        JSONObject data = new JSONObject();
        try {
            if (AppInfo.mGuestUserConfig == null || !GuestUserConfig.isGuestCheckout() || AppUser.hasSignedIn()) {
                String cal_shipping_country = AppUser.getInstance().shipping_address.countryCode;
                String cal_shipping_state = AppUser.getInstance().shipping_address.stateCode;
                String cal_shipping_postcode = AppUser.getInstance().shipping_address.postcode;
                String cal_shipping_city = AppUser.getInstance().shipping_address.city;

                data.put("cal_shipping_country", cal_shipping_country);
                data.put("cal_shipping_state", cal_shipping_state);
                data.put("cal_shipping_postcode", cal_shipping_postcode);
                data.put("cal_shipping_city", cal_shipping_city);
            } else {
                DummyUser user = AppInfo.dummyUser;
                String cal_shipping_country = user.shipping_address.countryCode;
                String cal_shipping_state = user.shipping_address.stateCode;
                String cal_shipping_postcode = user.shipping_address.postcode;
                String cal_shipping_city = user.shipping_address.city;

                data.put("cal_shipping_country", cal_shipping_country);
                data.put("cal_shipping_state", cal_shipping_state);
                data.put("cal_shipping_postcode", cal_shipping_postcode);
                data.put("cal_shipping_city", cal_shipping_city);
            }
        } catch (JSONException je) {
            je.printStackTrace();
        }
        Log.d("------------ sending shipping data -----------");
        Log.d(data.toString());
        Log.d("------------------------------------------");
        return data.toString();
    }

    public static String prepareBillingJson() {
        JSONObject data = new JSONObject();
        try {
            if (AppInfo.mGuestUserConfig == null || !GuestUserConfig.isGuestCheckout() || AppUser.hasSignedIn()) {

                String cal_billing_country = AppUser.getInstance().billing_address.countryCode;
                String cal_billing_state = AppUser.getInstance().billing_address.stateCode;
                String cal_billing_postcode = AppUser.getInstance().billing_address.postcode;
                String cal_billing_city = AppUser.getInstance().billing_address.city;

                data.put("cal_billing_country", cal_billing_country);
                data.put("cal_billing_state", cal_billing_state);
                data.put("cal_billing_postcode", cal_billing_postcode);
                data.put("cal_billing_city", cal_billing_city);

            } else {
                DummyUser user = AppInfo.dummyUser;
                String cal_billing_country = user.billing_address.countryCode;
                String cal_billing_state = user.billing_address.stateCode;
                String cal_billing_postcode = user.billing_address.postcode;
                String cal_billing_city = user.billing_address.city;

                data.put("cal_billing_country", cal_billing_country);
                data.put("cal_billing_state", cal_billing_state);
                data.put("cal_billing_postcode", cal_billing_postcode);
                data.put("cal_billing_city", cal_billing_city);
            }
        } catch (JSONException je) {
            je.printStackTrace();
        }
        Log.d("------------ sending billing data -----------");
        Log.d(data.toString());
        Log.d("------------------------------------------");
        return data.toString();
    }

    public static String prepareCouponJson() {
        JSONObject data = new JSONObject();
        JSONArray coupon_data = new JSONArray();
        if (Cart.isAnyCouponApplied()) {
            for (TM_Coupon coupon : Cart.applied_coupons) {
                try {
                    JSONObject coupon_item = new JSONObject();
                    coupon_item.put("id", coupon.id);
                    coupon_item.put("code", coupon.code);
                    coupon_data.put(coupon_item);
                } catch (Exception je) {
                    je.printStackTrace();
                }
            }
        }
        Log.d("------------ sending coupon data -----------");
        Log.d(coupon_data.toString());
        Log.d("------------------------------------------");
        return coupon_data.toString();
    }

    public static String prepareCartSynqCouponJson() {
        JSONArray coupon_data = new JSONArray();
        if (Cart.isAnyCouponApplied()) {
            for (TM_Coupon coupon : Cart.applied_coupons) {
                if (!coupon.enable_free_shipping)
                    continue;
                try {
                    JSONObject coupon_item = new JSONObject();
                    coupon_item.put("id", coupon.id);
                    coupon_item.put("code", coupon.code);
                    coupon_data.put(coupon_item);
                } catch (Exception je) {
                    je.printStackTrace();
                }
            }
        }

        Log.d("------------ sending coupon data -----------");
        Log.d(coupon_data.toString());
        Log.d("------------------------------------------");
        return coupon_data.toString();
    }

    public static String getCartItemsJSONString(List<TM_Shipping> shippingMethods, PaymentGateway paymentGateway, List<FeeData> feeDataList, String note) throws JSONException {
        JSONObject data = new JSONObject();
        JSONObject order = new JSONObject();
        {
            if (!AppUser.isAnonymous()) {
                order.put("customer_id", AppUser.getUserId());
            }
            AppUser appUser;
            if (AppInfo.mGuestUserConfig == null || !GuestUserConfig.isGuestCheckout() || AppUser.hasSignedIn()) {
                appUser = AppUser.getInstance();
            } else {
                appUser = new AppUser();
                appUser.billing_address = AppInfo.dummyUser.billing_address;
                appUser.shipping_address = AppInfo.dummyUser.shipping_address;
            }

            JSONObject billing_address = new JSONObject();
            String first_name = appUser.billing_address.first_name;
            String last_name = appUser.billing_address.last_name;
            String address_1 = appUser.billing_address.address_1;
            String address_2 = appUser.billing_address.address_2;
            String city = appUser.billing_address.city;
            String stateCode = appUser.billing_address.stateCode;
            String postcode = appUser.billing_address.postcode;
            String countryCode = appUser.billing_address.countryCode;
            String email = appUser.billing_address.email;
            String phone = appUser.billing_address.phone;

            if (!AppInfo.SKIP_MANUAL_ENCODING) {
                try {
                    // URLEncoder.encode is required for some special char like:
                    // first_name= "Ånkota";. Other wise post data will not be detected.
                    first_name = URLEncoder.encode(first_name, "UTF-8");
                    last_name = URLEncoder.encode(last_name, "UTF-8");
                    address_1 = URLEncoder.encode(address_1, "UTF-8");
                    address_2 = URLEncoder.encode(address_2, "UTF-8");
                    city = URLEncoder.encode(city, "UTF-8");
                    postcode = URLEncoder.encode(postcode, "UTF-8");
                    email = URLEncoder.encode(email, "UTF-8");
                } catch (UnsupportedEncodingException ignored) {
                }
            }

            billing_address.put("first_name", first_name);
            billing_address.put("last_name", last_name);
            billing_address.put("address_1", address_1);
            billing_address.put("address_2", address_2);
            billing_address.put("city", city);
            billing_address.put("state", stateCode);
            billing_address.put("postcode", postcode);
            billing_address.put("country", countryCode);
            billing_address.put("email", email);
            billing_address.put("phone", phone);

            order.put("billing_address", billing_address);

            JSONObject shipping_address;
            shipping_address = new JSONObject();
            shipping_address.put("first_name", appUser.shipping_address.first_name);
            shipping_address.put("last_name", appUser.shipping_address.last_name);
            shipping_address.put("address_1", appUser.shipping_address.address_1);
            shipping_address.put("address_2", appUser.shipping_address.address_2);
            shipping_address.put("city", appUser.shipping_address.city);
            shipping_address.put("state", appUser.shipping_address.stateCode);
            shipping_address.put("postcode", appUser.shipping_address.postcode);
            shipping_address.put("country", appUser.shipping_address.countryCode);

            first_name = appUser.shipping_address.first_name;
            last_name = appUser.shipping_address.last_name;
            address_1 = appUser.shipping_address.address_1;
            address_2 = appUser.shipping_address.address_2;
            city = appUser.shipping_address.city;
            stateCode = appUser.shipping_address.stateCode;
            postcode = appUser.shipping_address.postcode;
            countryCode = appUser.shipping_address.countryCode;

            if (!AppInfo.SKIP_MANUAL_ENCODING) {
                try {
                    final String enc = "UTF-8";
                    first_name = URLEncoder.encode(first_name, enc);
                    last_name = URLEncoder.encode(last_name, enc);
                    address_1 = URLEncoder.encode(address_1, enc);
                    address_2 = URLEncoder.encode(address_2, enc);
                    city = URLEncoder.encode(city, enc);
                    postcode = URLEncoder.encode(postcode, enc);
                } catch (UnsupportedEncodingException ignored) {
                }
            }

            shipping_address.put("first_name", first_name);
            shipping_address.put("last_name", last_name);
            shipping_address.put("address_1", address_1);
            shipping_address.put("address_2", address_2);
            shipping_address.put("city", city);
            shipping_address.put("state", stateCode);
            shipping_address.put("postcode", postcode);
            shipping_address.put("country", countryCode);
            order.put("shipping_address", shipping_address);

            double totalShippingCost = 0.0f;
            if (shippingMethods != null && shippingMethods.get(0) != null) {
                totalShippingCost = shippingMethods.get(0).cost;
            }
            float cartNewTotal = 0.0f;
            JSONArray line_items = new JSONArray();
            for (Cart c : Cart.getAll()) {
                JSONObject line_item = new JSONObject();
                if (c.selected_variation_id != -1)
                    line_item.put("product_id", c.selected_variation_id);
                else line_item.put("product_id", c.product_id);

                line_item.put("quantity", c.count);

                float totPrice = c.getItemTotalPrice();
                float totDiscount = c.getTotalDiscount();
                float newTotal = c.getItemTotalPrice() - c.getTotalDiscount();

                if (newTotal < 0) {
                    newTotal = 0.0f;
                }

                if (AppInfo.ALLOW_NEGATIVE_SHIPPING_HACK) {
                    if (totalShippingCost < 0) {
                        if (newTotal >= (totalShippingCost * -1)) {
                            newTotal += totalShippingCost;
                            totalShippingCost = 0;
                        } else {
                            totalShippingCost += newTotal;
                            newTotal = 0;
                        }
                    }
                }

                totPrice = c.getItemTotalPrice();
                totDiscount = c.getTotalPaymentExcludingTax(c);

                float taxIncludedInProductPrice = c.getItemTotalPrice() - c.getTotalPaymentExcludingTax(c);
                float priceToReduce = 0.0f;
                if (taxIncludedInProductPrice != 0.0f && c.originalTotal != 0.0f) {
                    float discountPercent = c.discountTotal / c.originalTotal * 100.0f;
                    if (discountPercent > 0.0f) {
                        float taxAfterDiscountInProductPrice = taxIncludedInProductPrice * discountPercent / 100.0f;
                        priceToReduce = taxAfterDiscountInProductPrice;
                    } else {
                        priceToReduce = taxIncludedInProductPrice;
                    }
                }

                float substractPrice = (c.discountTotal - priceToReduce);
                if (substractPrice < 0) {
                    substractPrice *= -1;
                }

                if (c.discountTotal == 0) {
                    newTotal = c.originalTotal - substractPrice;
                } else {
                    newTotal = c.getTotalPaymentExcludingTax(c) - substractPrice;
                }

                //float newTotal = cInfo.originalTotal - cInfo.discountTotal - priceToReduce;
                if (newTotal < 0) {
                    newTotal = 0.0f;
                }
                cartNewTotal += newTotal;
                line_item.put("subtotal", c.originalTotal - taxIncludedInProductPrice);
                line_item.put("total", newTotal);

                if (c.attributes != null && !c.attributes.isEmpty()) {
                    JSONObject variations = new JSONObject();
                    for (TM_VariationAttribute attribute : c.attributes) {
                        String attributeName = attribute.name;
                        String attributeValue = attribute.value;
                        String attributeSlug = attribute.slug;

                        //Log.d("== TM_VariationAttribute:attributeName 1["+attributeName+"] ==");
                        //Log.d("== TM_VariationAttribute:attributeValue 1["+attributeValue+"] ==");
                        //Log.d("== TM_VariationAttribute:attributeSlug 1["+attributeSlug+"] ==");

                        //super special case
                        if (attributeValue == null || attributeValue.equals("")) {
                            List<TM_Attribute> tm_attributes = c.product.attributes;
                            for (TM_Attribute attribute1 : tm_attributes) {
                                Log.d("== comparing attribute: [" + attribute1.slug + "]:[" + attribute1.options.get(0) + "] ==");
                                if (attribute1.slug.equals(attribute.slug) || attribute1.name.equalsIgnoreCase(attributeName)) {
                                    attributeValue = attribute1.options.get(0);
                                    break;
                                }
                            }
                        }

                        //Log.d("== TM_VariationAttribute:attributeName 2["+attributeName+"] ==");
                        //Log.d("== TM_VariationAttribute:attributeValue 2["+attributeValue+"] ==");
                        //Log.d("== TM_VariationAttribute:attributeSlug 2["+attributeSlug+"] ==");

                        if (!AppInfo.SKIP_MANUAL_ENCODING) {
                            try {
                                attributeName = URLEncoder.encode(attributeName, "UTF-8");
                                attributeValue = URLEncoder.encode(attributeValue, "UTF-8");
                            } catch (UnsupportedEncodingException ignored) {
                            }
                        }

                        variations.put(attributeName, attributeValue);
                    }
                    line_item.put("variations", variations);
                }

                if (!TextUtils.isEmpty(c.cart_meta_json)) {
                    JSONObject jsonObject = new JSONObject(c.cart_meta_json);
                    line_item.put("meta", jsonObject.getJSONArray("meta"));
                }

                line_items.put(line_item);

                if (c.bundledItems != null) {
                    for (CartBundleItem cartBundleItem : c.bundledItems) {
                        JSONObject bundleItemJson = new JSONObject();
                        bundleItemJson.put("product_id", cartBundleItem.getProductId());
                        bundleItemJson.put("quantity", cartBundleItem.getQuantity() * c.count);
                        bundleItemJson.put("subtotal", 0);
                        bundleItemJson.put("total", 0);
                        line_items.put(bundleItemJson);
                    }
                }
            }
            order.put("line_items", line_items);
            if (Cart.applied_coupons != null) {
                float total_discount = 0.0f;
                JSONArray coupon_lines = new JSONArray();
                for (TM_Coupon coupon : Cart.applied_coupons) {
                    JSONObject jsonCoupon = new JSONObject();
                    jsonCoupon.put("id", coupon.id);
                    jsonCoupon.put("code", coupon.code);
                    jsonCoupon.put("amount", coupon.couponDiscountOnApply);
                    coupon_lines.put(jsonCoupon);
                    total_discount += coupon.couponDiscountOnApply;
                }
                order.put("coupon_lines", coupon_lines);
                order.put("total_discount", total_discount);
            }

            if (feeDataList != null && !feeDataList.isEmpty()) {
                JSONArray fee_lines = new JSONArray();
                for (FeeData feeData : feeDataList) {
                    JSONObject fee_line = new JSONObject();
                    fee_line.put("title", feeData.label);

                    if (feeData.type == FeeData.Type.PERCENT) {
                        feeData.cost = (cartNewTotal) * feeData.cost / 100.0f;
                    }
                    fee_line.put("total", feeData.cost);
                    fee_lines.put(fee_line);
                }

                if (paymentGateway.getGatewaySettings() != null) {
                    JSONObject fee_line_for_payment_method = new JSONObject();
                    fee_line_for_payment_method.put("id", paymentGateway.getGatewaySettings().extra_charges_msg);
                    fee_line_for_payment_method.put("title", paymentGateway.getGatewaySettings().extra_charges_msg);
                    fee_line_for_payment_method.put("total", paymentGateway.getGatewaySettings().extra_charges);
                    fee_lines.put(fee_line_for_payment_method);
                }
                order.put("fee_lines", fee_lines);
            } else if (paymentGateway.getId().equalsIgnoreCase("cod") && paymentGateway.getGatewaySettings() != null) {
                JSONArray fee_lines = new JSONArray();
                JSONObject fee_line_for_payment_method = new JSONObject();
                fee_line_for_payment_method.put("id", paymentGateway.getGatewaySettings().extra_charges_msg);
                fee_line_for_payment_method.put("title", paymentGateway.getGatewaySettings().extra_charges_msg);
                fee_line_for_payment_method.put("total", paymentGateway.getGatewaySettings().extra_charges);
                fee_lines.put(fee_line_for_payment_method);
                order.put("fee_lines", fee_lines);
            }

            if (shippingMethods != null) {
                JSONArray shipping_lines = new JSONArray();
                for (TM_Shipping shippingMethod : shippingMethods) {
                    if (shippingMethod != null) {
                        JSONObject shipping_line = new JSONObject();
                        shipping_line.put("method_id", shippingMethod.method_id);
                        if (!AppInfo.SKIP_MANUAL_ENCODING) {
                            try {
                                shipping_line.put("method_title", URLEncoder.encode(shippingMethod.label, "UTF-8"));
                            } catch (UnsupportedEncodingException e) {
                                shipping_line.put("method_title", shippingMethod.label);
                                e.printStackTrace();
                            }
                        } else {
                            shipping_line.put("method_title", shippingMethod.label);
                        }

                        //shipping_line.put("total",Cart.getTotalPayment());
                        if (shippingMethod.cost < 0 && AppInfo.ALLOW_NEGATIVE_SHIPPING_HACK) {
                            shipping_line.put("total", 0);
                        } else {
                            double shippingTotal = shippingMethod.cost;
                            for (String tax : shippingMethod.taxes) {
                                try {
                                    shippingTotal += Double.parseDouble(tax);
                                } catch (NumberFormatException e) {
                                    e.printStackTrace();
                                }
                            }
                            shipping_line.put("total", shippingTotal);
                        }
                        shipping_lines.put(shipping_line);
                    }
                }
                order.put("shipping_lines", shipping_lines);
            }

            if (Helper.isValidString(note))
                order.put("note", note);

            if (TM_CommonInfo.woocommerce_prices_include_tax.equals("yes") || TM_CommonInfo.woocommerce_prices_include_tax.equals("true")) {
                order.put("is_vat_exempt", true);
            } else {
                order.put("is_vat_exempt", false);
            }

            // uncomment if stock quantity is not decreasing
            /*if (paymentGateway != null) {
                JSONObject payment_details = new JSONObject();
                payment_details.put("method_id", paymentGateway.getId());
                if (Helper.isValidString(paymentGateway.getTitle())) {
                    payment_details.put("method_title", paymentGateway.getTitle());
                }
                payment_details.put("paid", paymentGateway.isPrepaid());
                order.put("set_paid", paymentGateway.isPrepaid());
                order.put("payment_details", payment_details);
            }*/
            data.put("order", order);
        }
        return data.toString();
    }

    public static String createOrderStatusJsonString(String status, String id, String title, boolean paid) throws JSONException {
        JSONObject order = new JSONObject();
        order.put("status", status);
        JSONObject payment_details = new JSONObject();
        payment_details.put("method_id", id);
        if (Helper.isValidString(title)) {
            payment_details.put("method_title", title);
        }
        payment_details.put("paid", paid);
        order.put("payment_details", payment_details);
        order.put("set_paid", paid);

        JSONObject data = new JSONObject();
        data.put("order", order);
        return data.toString();
    }

    public static String createOrderStatusJsonString(String status) throws JSONException {
        JSONObject data = new JSONObject();
        JSONObject order = new JSONObject();
        order.put("status", status);
        data.put("order", order);
        return data.toString();
    }

    public static String getLatestCustomerJSON() throws JSONException {
        JSONObject data = new JSONObject();
        JSONObject customer = new JSONObject();
        customer.put("first_name", AppUser.getInstance().first_name);
        customer.put("last_name", AppUser.getInstance().last_name);

        {
            JSONObject billing_address = new JSONObject();
            billing_address.put("first_name", AppUser.getInstance().billing_address.first_name);
            billing_address.put("last_name", AppUser.getInstance().billing_address.last_name);
            billing_address.put("company", AppUser.getInstance().billing_address.company);
            billing_address.put("address_1", AppUser.getInstance().billing_address.address_1);
            billing_address.put("address_2", AppUser.getInstance().billing_address.address_2);
            billing_address.put("city", AppUser.getInstance().billing_address.city);
            billing_address.put("state", AppUser.getInstance().billing_address.stateCode);
            billing_address.put("postcode", AppUser.getInstance().billing_address.postcode);
            billing_address.put("country", AppUser.getInstance().billing_address.countryCode);
            billing_address.put("email", AppUser.getInstance().billing_address.email);
            billing_address.put("phone", AppUser.getInstance().billing_address.phone);
            customer.put("billing_address", billing_address);
        }

        {
            JSONObject shipping_address = new JSONObject();
            shipping_address.put("first_name", AppUser.getInstance().shipping_address.first_name);
            shipping_address.put("last_name", AppUser.getInstance().shipping_address.last_name);
            shipping_address.put("company", AppUser.getInstance().shipping_address.company);
            shipping_address.put("address_1", AppUser.getInstance().shipping_address.address_1);
            shipping_address.put("address_2", AppUser.getInstance().shipping_address.address_2);
            shipping_address.put("city", AppUser.getInstance().shipping_address.city);
            shipping_address.put("state", AppUser.getInstance().shipping_address.stateCode);
            shipping_address.put("postcode", AppUser.getInstance().shipping_address.postcode);
            shipping_address.put("country", AppUser.getInstance().shipping_address.countryCode);
            shipping_address.put("email", AppUser.getInstance().shipping_address.email);
            shipping_address.put("phone", AppUser.getInstance().shipping_address.phone);
            customer.put("shipping_address", shipping_address);
        }

        data.put("customer", customer);
        return data.toString();
    }

    public static String getCustomerJSON(DummyUser dummyUser) throws JSONException {
        JSONObject data = new JSONObject();
        JSONObject customer = new JSONObject();

        String first_name = dummyUser.first_name;
        String last_name = dummyUser.last_name;
        if (!AppInfo.SKIP_MANUAL_ENCODING) {
            // URLEncoder.encode is required for some special char like: first_name= "Ånkota";. Other wise post data will not be detected.
            try {
                first_name = URLEncoder.encode(first_name, "UTF-8");
                last_name = URLEncoder.encode(last_name, "UTF-8");
            } catch (UnsupportedEncodingException whoCares) {
            }
        }
        customer.put("first_name", first_name);
        customer.put("last_name", last_name);
        {

            String billing_first_name = dummyUser.billing_address.first_name;
            String billing_last_name = dummyUser.billing_address.last_name;
            String billing_company = dummyUser.billing_address.company;
            String billing_address_1 = dummyUser.billing_address.address_1;
            String billing_address_2 = dummyUser.billing_address.address_2;
            String billing_city = dummyUser.billing_address.city;
            String billing_stateCode = dummyUser.billing_address.stateCode;
            String billing_postcode = dummyUser.billing_address.postcode;
            String billing_countryCode = dummyUser.billing_address.countryCode;
            String billing_email = dummyUser.billing_address.email;
            String billing_phone = dummyUser.billing_address.phone;

            if (!AppInfo.SKIP_MANUAL_ENCODING) {
                // URLEncoder.encode is required for some special char like: first_name= "Ånkota";. Other wise post data will not be detected.
                try {
                    billing_first_name = URLEncoder.encode(billing_first_name, "UTF-8");
                    billing_last_name = URLEncoder.encode(billing_last_name, "UTF-8");
                    billing_company = URLEncoder.encode(billing_company, "UTF-8");
                    billing_address_1 = URLEncoder.encode(billing_address_1, "UTF-8");
                    billing_address_2 = URLEncoder.encode(billing_address_2, "UTF-8");
                    billing_city = URLEncoder.encode(billing_city, "UTF-8");
                    billing_stateCode = URLEncoder.encode(billing_stateCode, "UTF-8");
                    billing_postcode = URLEncoder.encode(billing_postcode, "UTF-8");
                    billing_countryCode = URLEncoder.encode(billing_countryCode, "UTF-8");
                    billing_email = URLEncoder.encode(billing_email, "UTF-8");
                    billing_phone = URLEncoder.encode(billing_phone, "UTF-8");
                } catch (UnsupportedEncodingException whoCares) {
                }
            }

            JSONObject billing_address = new JSONObject();
            billing_address.put("first_name", billing_first_name);
            billing_address.put("last_name", billing_last_name);
            billing_address.put("company", billing_company);
            billing_address.put("address_1", billing_address_1);
            billing_address.put("address_2", billing_address_2);
            billing_address.put("city", billing_city);
            billing_address.put("state", billing_stateCode);
            billing_address.put("postcode", billing_postcode);
            billing_address.put("country", billing_countryCode);
            billing_address.put("email", billing_email);
            billing_address.put("phone", billing_phone);

            customer.put("billing_address", billing_address);
        }

        {
            String shipping_first_name = dummyUser.shipping_address.first_name;
            String shipping_last_name = dummyUser.shipping_address.last_name;
            String shipping_company = dummyUser.shipping_address.company;
            String shipping_address_1 = dummyUser.shipping_address.address_1;
            String shipping_address_2 = dummyUser.shipping_address.address_2;
            String shipping_city = dummyUser.shipping_address.city;
            String shipping_stateCode = dummyUser.shipping_address.stateCode;
            String shipping_postcode = dummyUser.shipping_address.postcode;
            String shipping_countryCode = dummyUser.shipping_address.countryCode;

            if (!AppInfo.SKIP_MANUAL_ENCODING) {
                // URLEncoder.encode is required for some special char like: first_name= "Ånkota";. Other wise post data will not be detected.
                try {
                    shipping_first_name = URLEncoder.encode(shipping_first_name, "UTF-8");
                    shipping_last_name = URLEncoder.encode(shipping_last_name, "UTF-8");
                    shipping_company = URLEncoder.encode(shipping_company, "UTF-8");
                    shipping_address_1 = URLEncoder.encode(shipping_address_1, "UTF-8");
                    shipping_address_2 = URLEncoder.encode(shipping_address_2, "UTF-8");
                    shipping_city = URLEncoder.encode(shipping_city, "UTF-8");
                    shipping_stateCode = URLEncoder.encode(shipping_stateCode, "UTF-8");
                    shipping_postcode = URLEncoder.encode(shipping_postcode, "UTF-8");
                    shipping_countryCode = URLEncoder.encode(shipping_countryCode, "UTF-8");
                } catch (UnsupportedEncodingException whoCares) {
                }
            }

            JSONObject shipping_address = new JSONObject();
            shipping_address.put("first_name", shipping_first_name);
            shipping_address.put("last_name", shipping_last_name);
            shipping_address.put("company", shipping_company);
            shipping_address.put("address_1", shipping_address_1);
            shipping_address.put("address_2", shipping_address_2);
            shipping_address.put("city", shipping_city);
            shipping_address.put("state", shipping_stateCode);
            shipping_address.put("postcode", shipping_postcode);
            shipping_address.put("country", shipping_countryCode);
            customer.put("shipping_address", shipping_address);
        }
        data.put("customer", customer);
        return data.toString();
    }

    public static List<List<String>> getCartStringForParse() throws Exception {
        List<List<String>> jsonArray = new ArrayList<>();
        for (Cart cart : Cart.getAll()) {
            List<String> cartObject = new ArrayList<>();
            cartObject.add(cart.product_id + "");
            cartObject.add(cart.title);
            cartObject.add(cart.count + "");
            cartObject.add(cart.selected_variation_id + "");
            cartObject.add(cart.getItemPrice() + "");
            jsonArray.add(cartObject);
        }
        return jsonArray;
    }


    public static List<List<String>> getPreviousCartStringForParse() throws Exception {
        List<List<String>> jsonArray = new ArrayList<>();
        for (Cart cart : Cart.getAllPrevious()) {
            List<String> cartObject = new ArrayList<>();
            cartObject.add(cart.product_id + "");
            cartObject.add(cart.title);
            cartObject.add(cart.count + "");
            cartObject.add(cart.selected_variation_id + "");
            jsonArray.add(cartObject);
        }
        return jsonArray;
    }

    public static List<String> getCategoryStringForParse(TM_CategoryInfo category) {
        List<String> orderItem = new ArrayList<>();
        orderItem.add(category.id + "");
        orderItem.add(category.getName());
        orderItem.add("1");
        return orderItem;
    }

    public static List<String> getProductStringForParse(TM_ProductInfo product) {
        List<String> orderItem = new ArrayList<>();
        orderItem.add(product.id + "");
        orderItem.add(product.title);
        orderItem.add("1");
        return orderItem;
    }

    public static TM_ProductInfo parseRawProduct(JSONObject productInfoJson) throws JSONException {
        int id = productInfoJson.getInt("id");
        TM_ProductInfo product = TM_ProductInfo.getOrCreate(id);

        product.title = JsonHelper.getString(productInfoJson, "title");

        if (!product.hasAnyImage()) {
            String img_url = JsonHelper.getString(productInfoJson, "img");
            product.addImage(img_url);
        }

        String img_url = JsonHelper.getString(productInfoJson, "img");
        product.thumb = DataHelper.getScaledThumbnailUrl(img_url);

        product.price = safeFloat(JsonHelper.getString(productInfoJson, "price"));
        product.regular_price = safeFloat(JsonHelper.getString(productInfoJson, "regular_price"));
        product.product_url = JsonHelper.getString(productInfoJson, "url");
        product.sale_price = safeFloat(JsonHelper.getString(productInfoJson, "sale_price"));
        product.in_stock = DataHelper.safeBool(productInfoJson.getString("stock"));

        if (productInfoJson.has("taxable")) {
            product.taxable = productInfoJson.getBoolean("taxable");
        }

        try {
            product.featured = productInfoJson.getBoolean("featured");
            product.total_sales = productInfoJson.getInt("total_sales");
            product.average_rating = (float) productInfoJson.getDouble("average_rating");
            try {
                DateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.ENGLISH);
                product.created_at = sdf.parse(JsonHelper.getString(productInfoJson, "created_at"));
            } catch (Exception e) {
                e.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return product;
    }

    public static void parseJsonAndCretePromo(String jsonString) throws Exception {
        JSONObject jsonObject = new JSONObject(jsonString);
        AppInfo.PROMO_TITLE = jsonObject.getString("title");
        AppInfo.PROMO_DESC = jsonObject.getString("desc");
        AppInfo.PROMO_URL = jsonObject.getString("url");
        AppInfo.PROMO_IMG_URL = jsonObject.getString("img");
    }

    public static List<List<String>> getWishlistStringForParse() throws Exception {
        List<List<String>> jsonArray = new ArrayList<>();
        for (Wishlist wish : Wishlist.getAll()) {
            List<String> wishObject = new ArrayList<>();
            wishObject.add(wish.product_id + "");
            if (wish.product != null) {
                wishObject.add(wish.product.title);
                wishObject.add(wish.product.price + "");
            }
            wishObject.add(1 + "");
            jsonArray.add(wishObject);
        }
        return jsonArray;
    }

    public static List<List<String>> getPurchasedItemsStringForParse(TM_Order order) throws Exception {
        List<List<String>> jsonArray = new ArrayList<>();
        for (TM_LineItem lineItem : order.line_items) {
            List<String> orderItem = new ArrayList<>();
            orderItem.add(lineItem.product_id + "");
            orderItem.add(lineItem.name);
            orderItem.add(lineItem.quantity + "");
            jsonArray.add(orderItem);
        }
        return jsonArray;
    }

    public static String getCartStringForVerification() throws JSONException {
        JSONArray jsonArray = new JSONArray();
        for (Cart cart : Cart.getAll()) {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("pid", cart.product_id);
            jsonObject.put("vid", cart.selected_variation_id);
            jsonObject.put("index", cart.selected_variation_index);
            jsonArray.put(jsonObject);

            if (cart.bundledItems != null) {
                for (CartBundleItem bundleItem : cart.bundledItems) {
                    JSONObject cartItemJsonObject = new JSONObject();
                    cartItemJsonObject.put("pid", bundleItem.getProductId());
                    cartItemJsonObject.put("vid", -1);
                    cartItemJsonObject.put("index", -1);
                    jsonArray.put(cartItemJsonObject);
                }
            }
        }
        return jsonArray.toString();
    }

    public static List<Banner> getBannersFromJson(String jsonString) throws Exception {
        List<Banner> banners = new ArrayList<>();
        JSONArray jsonArray = new JSONArray(jsonString);
        for (int i = 0; i < jsonArray.length(); i++) {
            banners.add(parseJsonAndGetBanner(jsonArray.getJSONObject(i).toString()));
        }
        return banners;
    }

    public static List<TM_ProductInfo> getProductsFromJson(String jsonString) throws Exception {
        List<TM_ProductInfo> products = new ArrayList<>();
        JSONArray jsonArray = new JSONArray(jsonString);
        for (int i = 0; i < jsonArray.length(); i++) {
            products.add(parseRawProduct(jsonArray.getJSONObject(i)));
        }
        return products;
    }

    public static List<Tile> getTilesFromJson(String jsonString) throws Exception {
        List<Tile> tiles = new ArrayList<>();
        JSONArray jsonArray = new JSONArray(jsonString);
        for (int i = 0; i < jsonArray.length(); i++) {
            tiles.add(parseJsonAndGetTile(jsonArray.getJSONObject(i).toString()));
        }
        return tiles;
    }

    public static Banner parseJsonAndGetBanner(String jsonString) {
        Gson gson = new Gson();
        return gson.fromJson(jsonString, Banner.class);
    }

    public static Tile parseJsonAndGetTile(String jsonString) {
        Gson gson = new Gson();
        return gson.fromJson(jsonString, Tile.class);
    }

    public static String getCustomerDataStringForParse() throws JSONException {
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("user_id", AppUser.getUserId());
        jsonObject.put("first_name", AppUser.getInstance().first_name);
        jsonObject.put("last_name", AppUser.getInstance().last_name);
        jsonObject.put("email", AppUser.getEmail());
        jsonObject.put("model", android.os.Build.MODEL);
        jsonObject.put("platform", "Android");
        jsonObject.put("gender", AppUser.getInstance().gender);

        JSONObject billing_address = new JSONObject();
        if (AppUser.getInstance().billing_address != null) {
            billing_address.put("first_name", AppUser.getInstance().billing_address.first_name);
            billing_address.put("last_name", AppUser.getInstance().billing_address.last_name);
            billing_address.put("company", AppUser.getInstance().billing_address.company);
            billing_address.put("address_1", AppUser.getInstance().billing_address.address_1);
            billing_address.put("address_2", AppUser.getInstance().billing_address.address_2);
            billing_address.put("postcode", AppUser.getInstance().billing_address.postcode);
            billing_address.put("city", AppUser.getInstance().billing_address.city);
            billing_address.put("state", AppUser.getInstance().billing_address.state);
            billing_address.put("stateCode", AppUser.getInstance().billing_address.stateCode);
            billing_address.put("country", AppUser.getInstance().billing_address.country);
            billing_address.put("countryCode", AppUser.getInstance().billing_address.countryCode);
            billing_address.put("email", AppUser.getInstance().billing_address.email);
            billing_address.put("phone", AppUser.getInstance().billing_address.phone);
        }
        jsonObject.put("billing_address", billing_address);
        return jsonObject.toString();
    }

    public static JSONObject safeJSONObject(String json) throws JSONException {
        return new JSONObject(json.substring(json.indexOf("{"), json.lastIndexOf("}") + 1));
    }

    public static List<ContactDetail> generateContactDetails(String content) throws JSONException {
        JSONObject jsonObject = new JSONObject(content);
        if (jsonObject.has("contactDetails")) {
            List<ContactDetail> contactDetails = new ArrayList<>();
            JSONArray contactDetailsJson = jsonObject.getJSONArray("contactDetails");
            for (int i = 0; i < contactDetailsJson.length(); i++) {
                contactDetails.add(new Gson().fromJson(contactDetailsJson.getJSONObject(i).toString(), ContactDetail.class));
            }
            return contactDetails;
        }
        return null;
    }

    public static void parseAndCreatePickupLocations(String jsonString) throws JSONException {
        JSONObject jsonObject = DataHelper.safeJsonObject(jsonString);
        if (jsonObject.has("pickup_locations")) {
            JSONArray pickupJsonArray = jsonObject.getJSONArray("pickup_locations");
            PickupLocation.clearAll();
            for (int i = 0; i < pickupJsonArray.length(); i++) {
                JSONObject pickupJson = pickupJsonArray.getJSONObject(i);
                PickupLocation pickupLocation = PickupLocation.create();
                pickupLocation.setId(pickupJson.getInt("id"));
                pickupLocation.setCountry(pickupJson.getString("country"));
                pickupLocation.setCost(pickupJson.getString("cost"));
                pickupLocation.setNote(pickupJson.getString("note"));
                pickupLocation.setCompany(pickupJson.getString("company"));
                pickupLocation.setAddress1(pickupJson.getString("address_1"));
                pickupLocation.setAddress2(pickupJson.getString("address_2"));
                pickupLocation.setCity(pickupJson.getString("city"));
                pickupLocation.setState(pickupJson.getString("state"));
                pickupLocation.setPostcode(pickupJson.getString("postcode"));
                pickupLocation.setPhone(pickupJson.getString("phone"));
            }
        }
    }
}
