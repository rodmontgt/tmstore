package com.twist.dataengine.entities;

public class TM_CommonInfo {
    public static String timezone = "Asia/Kolkata";
    public static String currency = "INR";
    public static String currency_format = "Rs.";
    public static String currency_position = "left";
    public static String thousand_separator = ".";
    public static String decimal_separator = ",";
    public static int price_num_decimals = 2;
    public static boolean tax_included = false;
    public static String weight_unit = "kg";
    public static String dimension_unit = "cm";
    public static boolean hide_out_of_stock = false;
    public static String home_notification_label;

    public static class store_base_location {
        public static String country = "";
        public static String state = "";
    }

    //For Tax Calculation based on Locality.

    public static class LocalityInfo {
        public String countryCode = "";
        public String stateCode = "";
        public String city = "";
        public String pinCode = "";
    }

    public static String shipping_tax_class = "";
    public static String tax_based_on = "";
    public static String woocommerce_prices_include_tax = "";
    public static String woocommerce_tax_display_shop = "";
    public static String woocommerce_prices_include_cart = "";
    public static boolean addTaxToProductPrice = false;

    public static LocalityInfo billingLocalityInfo = new LocalityInfo();
    public static LocalityInfo shippingLocalityInfo = new LocalityInfo();

    public static float getPriceIncludingTax1(float originalPrice, boolean taxable) {
        //Let it Go as it is as of now
        return originalPrice;
    }
}






