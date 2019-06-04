package com.twist.tmstore.config;

import com.twist.tmstore.entities.AppInfo;
import com.utils.JsonHelper;
import com.utils.Log;

import org.json.JSONObject;

import java.util.List;

public class ProductDetailsConfig {

    public static final String EXTRA_ATTRIBUTE_LAYOUT_HZ = "horizontal";
    public static final String EXTRA_ATTRIBUTE_LAYOUT_VT = "vertical";

    public int product_short_desc_max_line = 2;
    public double img_slider_height_ratio = 1.0f;

    public boolean show_top_section = true;
    public boolean show_image_slider = true;
    public boolean show_share_button = true;
    public boolean show_zoom_button = true;
    public boolean show_combo_section = true;
    public boolean show_product_title = true;
    public boolean show_short_desc = true;
    public boolean show_price = true;
    public boolean show_reward_points = true;
    public boolean show_variation_section = true;
    public boolean show_opinion_section = false;
    public boolean show_full_share_section = true;
    public boolean show_waitlist_section = true;
    public boolean show_details_section = true;
    public boolean show_full_description = true;
    public boolean show_show_more = true;
    public boolean show_ratings_section = true;
    public boolean show_reviews_section = true;
    public boolean show_upsell_section = false;
    public boolean show_related_section = false;
    public boolean show_best_deals_section = false;
    public boolean show_fresh_arrivals_section = false;
    public boolean show_trending_section = false;
    public boolean show_brand_names = false;
    public boolean show_price_labels = false;
    public boolean show_quantity_rules = false;
    public List<String> contact_numbers = null;
    public boolean show_awesome_attribute_options = false;
    public boolean show_full_description_collapsed = false;
    public boolean show_ratings_section_collapsed = false;
    public boolean show_reviews_section_collapsed = false;
    public QuickCartSectionConfig configQuickCart = null;
    public BuyButtonSectionConfig configBuyButton = new BuyButtonSectionConfig();
    public boolean show_buy_button_description = false;
    public String extra_attributes_layout_type = EXTRA_ATTRIBUTE_LAYOUT_HZ;
    public boolean show_auction_section = false;
    public boolean show_image_loading_bar = false;
    public boolean show_additional_info = true;

    public static void createConfig(JSONObject jsonObject) {
        if (jsonObject == null || !jsonObject.has("product_details_config")) {
            AppInfo.mProductDetailsConfig.resetConfig();
            Log.e("No configuration for " + ProductDetailsConfig.class.getSimpleName() + " in JSON");
            return;
        }

        try {
            ProductDetailsConfig config = AppInfo.mProductDetailsConfig;
            JSONObject configJsonObject = jsonObject.getJSONObject("product_details_config");
            config.show_top_section = JsonHelper.getBool(configJsonObject, "show_top_section", config.show_top_section);
            config.show_image_slider = JsonHelper.getBool(configJsonObject, "show_image_slider", config.show_image_slider);
            config.show_share_button = JsonHelper.getBool(configJsonObject, "show_share_button", config.show_share_button);
            config.show_zoom_button = JsonHelper.getBool(configJsonObject, "show_zoom_button", config.show_zoom_button);
            config.show_combo_section = JsonHelper.getBool(configJsonObject, "show_combo_section", config.show_combo_section);
            config.show_product_title = JsonHelper.getBool(configJsonObject, "show_product_title", config.show_product_title);
            config.show_short_desc = JsonHelper.getBool(configJsonObject, "show_short_desc", config.show_short_desc);
            config.show_price = JsonHelper.getBool(configJsonObject, "show_price", config.show_price);
            config.show_reward_points = JsonHelper.getBool(configJsonObject, "show_reward_points", config.show_reward_points);
            config.show_variation_section = JsonHelper.getBool(configJsonObject, "show_variation_section", config.show_variation_section);
            config.show_opinion_section = JsonHelper.getBool(configJsonObject, "show_opinion_section", config.show_opinion_section);
            config.show_full_share_section = JsonHelper.getBool(configJsonObject, "show_full_share_section", config.show_full_share_section);
            config.show_waitlist_section = JsonHelper.getBool(configJsonObject, "show_waitlist_section", config.show_waitlist_section);
            config.show_details_section = JsonHelper.getBool(configJsonObject, "show_details_section", config.show_details_section);
            config.show_full_description = JsonHelper.getBool(configJsonObject, "show_full_description", config.show_full_description);
            config.show_show_more = JsonHelper.getBool(configJsonObject, "show_show_more", config.show_show_more);
            config.show_ratings_section = JsonHelper.getBool(configJsonObject, "show_ratings_section", config.show_ratings_section);
            config.show_reviews_section = JsonHelper.getBool(configJsonObject, "show_reviews_section", config.show_reviews_section);
            config.show_upsell_section = JsonHelper.getBool(configJsonObject, "show_upsell_section", config.show_upsell_section);
            config.show_related_section = JsonHelper.getBool(configJsonObject, "show_related_section", config.show_related_section);
            config.show_best_deals_section = JsonHelper.getBool(configJsonObject, "show_best_deals_section", config.show_best_deals_section);
            config.show_fresh_arrivals_section = JsonHelper.getBool(configJsonObject, "show_fresh_arrivals_section", config.show_fresh_arrivals_section);
            config.show_trending_section = JsonHelper.getBool(configJsonObject, "show_trending_section", config.show_trending_section);
            config.show_brand_names = JsonHelper.getBool(configJsonObject, "show_brand_names", config.show_brand_names);
            config.show_price_labels = JsonHelper.getBool(configJsonObject, "show_price_labels", config.show_price_labels);
            config.show_quantity_rules = JsonHelper.getBool(configJsonObject, "show_quantity_rules", config.show_quantity_rules);
            config.contact_numbers = JsonHelper.getStringList(configJsonObject, "contact_numbers");
            config.show_awesome_attribute_options = JsonHelper.getBool(configJsonObject, "show_awesome_attribute_options", config.show_awesome_attribute_options);
            config.show_full_description_collapsed = JsonHelper.getBool(configJsonObject, "show_full_description_collapsed", config.show_full_description_collapsed);
            config.show_ratings_section_collapsed = JsonHelper.getBool(configJsonObject, "show_ratings_section_collapsed", config.show_ratings_section_collapsed);
            config.show_reviews_section_collapsed = JsonHelper.getBool(configJsonObject, "show_reviews_section_collapsed", config.show_reviews_section_collapsed);
            config.show_buy_button_description = JsonHelper.getBool(configJsonObject, "show_buy_button_description", config.show_buy_button_description);
            config.product_short_desc_max_line = JsonHelper.getInt(configJsonObject, "product_short_desc_max_line", config.product_short_desc_max_line);
            config.img_slider_height_ratio = JsonHelper.getDouble(configJsonObject, "img_slider_height_ratio", config.img_slider_height_ratio);

            /*  Quick Cart Section */
            if (configJsonObject.has("show_quick_cart_section")) {
                config.configQuickCart = new QuickCartSectionConfig();
                config.configQuickCart.enabled = JsonHelper.getBool(configJsonObject, "show_quick_cart_section");
                config.configQuickCart.layoutPosition = ProductDetailsConfig.LayoutPosition.DEFAULT;
            } else if (jsonObject.has("show_cart_with_product")) {
                config.configQuickCart = new QuickCartSectionConfig();
                config.configQuickCart.enabled = JsonHelper.getBool(jsonObject, "show_cart_with_product");
                config.configQuickCart.layoutPosition = ProductDetailsConfig.LayoutPosition.DEFAULT;
            }

            if (configJsonObject.has("quick_cart_section_config")) {
                config.configQuickCart = new QuickCartSectionConfig();
                JSONObject configJsonObjectCart = configJsonObject.getJSONObject("quick_cart_section_config");
                config.configQuickCart.enabled = JsonHelper.getBool(configJsonObjectCart, "enabled", config.configQuickCart.enabled);
                config.configQuickCart.layoutPosition = LayoutPosition.from(JsonHelper.getString(configJsonObjectCart, "layout_position"));
            } else {
                Log.e("Error while parsing " + QuickCartSectionConfig.class.getSimpleName() + " JSON");
            }

            /*  Buy Button Section  */
            config.configBuyButton = new BuyButtonSectionConfig();
            config.configBuyButton.layoutPosition = ProductDetailsConfig.LayoutPosition.DEFAULT;
            config.configBuyButton.enabled = JsonHelper.getBool(configJsonObject, "show_button_section", config.configBuyButton.enabled);

            if (configJsonObject.has("buy_button_section_config")) {
                JSONObject configJsonObjectBuyButton = configJsonObject.getJSONObject("buy_button_section_config");
                config.configBuyButton.enabled = JsonHelper.getBool(configJsonObjectBuyButton, "enabled", config.configBuyButton.enabled);
                config.configBuyButton.layoutPosition = LayoutPosition.from(JsonHelper.getString(configJsonObjectBuyButton, "layout_position"));
            } else {
                Log.e("Error while parsing " + BuyButtonSectionConfig.class.getSimpleName() + " JSON");
            }
            config.extra_attributes_layout_type = JsonHelper.getString(configJsonObject, "extra_attributes_layout_type", config.extra_attributes_layout_type);
            config.show_auction_section = JsonHelper.getBool(configJsonObject, "show_auction_section", config.show_auction_section);
            config.show_image_loading_bar = JsonHelper.getBool(configJsonObject, "show_image_loading_bar", config.show_image_loading_bar);
            config.show_additional_info = JsonHelper.getBool(configJsonObject, "show_additional_info", config.show_additional_info);
        } catch (Exception e) {
            Log.e("Error while parsing " + ProductDetailsConfig.class.getSimpleName() + " JSON");
            AppInfo.mProductDetailsConfig.resetConfig();
            e.printStackTrace();
        }
    }

    public static boolean isEnabled() {
        return AppInfo.mProductDetailsConfig != null;
    }

    private void resetConfig() {
        show_top_section = true;
        show_image_slider = true;
        show_share_button = true;
        show_zoom_button = true;
        show_combo_section = true;
        show_product_title = true;
        show_short_desc = true;
        show_price = true;
        show_reward_points = true;
        show_variation_section = true;
        show_opinion_section = false;
        show_full_share_section = true;
        show_waitlist_section = true;
        show_details_section = true;
        show_full_description = true;
        show_show_more = true;
        show_ratings_section = true;
        show_reviews_section = true;
        show_upsell_section = false;
        show_related_section = false;
        show_best_deals_section = false;
        show_fresh_arrivals_section = false;
        show_trending_section = false;
        show_brand_names = false;
        show_price_labels = false;
        show_quantity_rules = false;
        contact_numbers = null;
        configQuickCart = null;
        configBuyButton = new BuyButtonSectionConfig();
        show_buy_button_description = false;
        extra_attributes_layout_type = EXTRA_ATTRIBUTE_LAYOUT_HZ;
        show_auction_section = false;
    }

    public enum LayoutPosition {
        DEFAULT("default"),
        BOTTOM("bottom");

        private final String value;

        LayoutPosition(String value) {
            this.value = value;
        }

        public static LayoutPosition from(String name) {
            if (name != null && !name.equals("")) {
                for (LayoutPosition type : values()) {
                    if (type.value.equalsIgnoreCase(name)) {
                        return type;
                    }
                }
            }
            return DEFAULT;
        }

        public String getValue() {
            return this.value;
        }
    }

    public static class QuickCartSectionConfig {
        public boolean enabled = false;
        public LayoutPosition layoutPosition = LayoutPosition.DEFAULT;
    }

    public static class BuyButtonSectionConfig {
        public boolean enabled = true;
        public LayoutPosition layoutPosition = LayoutPosition.DEFAULT;
    }
}