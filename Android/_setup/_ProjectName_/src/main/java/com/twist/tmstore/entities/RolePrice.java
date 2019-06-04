package com.twist.tmstore.entities;

import android.text.TextUtils;

import com.twist.dataengine.entities.TM_CommonInfo;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.dataengine.entities.TM_SimpleCart;
import com.twist.dataengine.entities.TM_Variation;
import com.utils.Log;

import org.json.JSONException;
import org.json.JSONObject;

import java.math.RoundingMode;
import java.text.NumberFormat;
import java.util.Locale;

/**
 * Created by Twist Mobile on 12/26/2017.
 */

public class RolePrice {
    public String role;
    public String type;
    public String value;
    public String option_type;
    public String price_type;

    public static RolePrice create(JSONObject jsonObject) {
        RolePrice rolePrice = null;
        try {
            rolePrice = new RolePrice();
            rolePrice.role = jsonObject.getString("role");
            JSONObject rolePriceJsonObject = jsonObject.getJSONObject("role_price");
            rolePrice.type = rolePriceJsonObject.getString("type");
            rolePrice.value = rolePriceJsonObject.getString("value");
            rolePrice.option_type = rolePriceJsonObject.getString("option_type");
            rolePrice.price_type = rolePriceJsonObject.getString("price_type");
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return rolePrice;
    }

    public static void applyPrice(TM_ProductInfo productInfo) {
        RolePrice rolePrice = AppUser.getInstance().getRolePrice();
        if (AppInfo.ENABLE_ROLE_PRICE && rolePrice != null) {
            if (!TextUtils.isEmpty(rolePrice.type) && !TextUtils.isEmpty(rolePrice.value) && !TextUtils.isEmpty(rolePrice.option_type)) {
                float rolePriceValue = Float.parseFloat(rolePrice.value);
                if (rolePriceValue <= 0) {
                    return;
                }
                productInfo.price = getNewPrice(rolePrice, rolePriceValue, productInfo.price_clone);
                productInfo.regular_price = getNewPrice(rolePrice, rolePriceValue, productInfo.regular_price_clone);
                productInfo.sale_price = getNewPrice(rolePrice, rolePriceValue, productInfo.sale_price_clone);
                productInfo.price_min = getNewPrice(rolePrice, rolePriceValue, productInfo.price_min_clone);
                productInfo.price_max = getNewPrice(rolePrice, rolePriceValue, productInfo.price_max_clone);
            } else {
                Log.d("no role price data found");
            }
        }
    }

    public static void applyPrice(TM_Variation variation) {
        RolePrice rolePrice = AppUser.getInstance().getRolePrice();
        if (AppInfo.ENABLE_ROLE_PRICE && rolePrice != null) {
            if (!TextUtils.isEmpty(rolePrice.type) && !TextUtils.isEmpty(rolePrice.value) && !TextUtils.isEmpty(rolePrice.option_type)) {
                float rolePriceValue = Float.parseFloat(rolePrice.value);
                if (rolePriceValue <= 0) {
                    return;
                }
                variation.price = getNewPrice(rolePrice, rolePriceValue, variation.price_clone);
                variation.regular_price = getNewPrice(rolePrice, rolePriceValue, variation.regular_price_clone);
                variation.sale_price = getNewPrice(rolePrice, rolePriceValue, variation.sale_price_clone);
            } else {
                Log.d("no role price data found");
            }
        }
    }

    public static void applyPrice(TM_SimpleCart simpleCart) {
        RolePrice rolePrice = AppUser.getInstance().getRolePrice();
        if (AppInfo.ENABLE_ROLE_PRICE && rolePrice != null) {
            if (!TextUtils.isEmpty(rolePrice.type) && !TextUtils.isEmpty(rolePrice.value) && !TextUtils.isEmpty(rolePrice.option_type)) {
                float rolePriceValue = Float.parseFloat(rolePrice.value);
                if (rolePriceValue <= 0) {
                    return;
                }

                simpleCart.price = getNewPrice(rolePrice, rolePriceValue, (float) simpleCart.price_clone);
                simpleCart.regular_price = getNewPrice(rolePrice, rolePriceValue, (float) simpleCart.regular_price_clone);
                simpleCart.sale_price = getNewPrice(rolePrice, rolePriceValue, (float) simpleCart.sale_price_clone);
            } else {
                Log.d("no role price data found");
            }
        }
    }


    private static float getNewPrice(RolePrice rolePrice, float rolePriceValue, float productPrice) {
        float newPrice = productPrice;
        if (rolePrice.type.equalsIgnoreCase("discount")) {
            if (rolePrice.option_type.equalsIgnoreCase("percent")) {
                newPrice = applyDecimalPrecision(productPrice - (productPrice * rolePriceValue / 100.0f));
            } else if (rolePrice.option_type.equalsIgnoreCase("fixed")) {
                newPrice = productPrice - rolePriceValue;
            }
        } else if (rolePrice.type.equalsIgnoreCase("markup")) {
            if (rolePrice.option_type.equalsIgnoreCase("percent")) {
                newPrice = applyDecimalPrecision(productPrice + (productPrice * rolePriceValue / 100.0f));
            } else if (rolePrice.option_type.equalsIgnoreCase("fixed")) {
                newPrice = productPrice + rolePriceValue;
            }
        }
        return newPrice;
    }

    private static float applyDecimalPrecision(float value) {
        try {
            NumberFormat formatter = NumberFormat.getInstance(Locale.US);
            formatter.setMaximumFractionDigits(TM_CommonInfo.price_num_decimals);
            formatter.setMinimumFractionDigits(TM_CommonInfo.price_num_decimals);
            formatter.setRoundingMode(RoundingMode.HALF_UP);
            value = Float.valueOf(formatter.format(value).replaceAll(",", ""));
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }
        return value;
    }
}
