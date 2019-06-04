package com.utils;


import com.twist.dataengine.entities.CurrencyItem;
import com.twist.dataengine.entities.TM_CommonInfo;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.dataengine.entities.TM_Variation;
import com.twist.tmstore.entities.AppInfo;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 8/28/2017.
 */

public class CurrencyHelper {

    private static final String TAG = CurrencyHelper.class.getSimpleName();

    private static List<CurrencyItem> mCurrencyItems = new ArrayList<>();

    public static void clearAllCurrency() {
        if (mCurrencyItems != null) {
            mCurrencyItems.clear();
        }
    }

    public static void addNewCurrency(CurrencyItem currencyItem) {
        mCurrencyItems.add(currencyItem);
    }

    public static List<CurrencyItem> getAllCurrency() {
        return mCurrencyItems;
    }

    private static CurrencyItem currencyItem;
    private static String currencyName = "";

    public static void setSelectedCurrencyItem(CurrencyItem currencyItem) {
        CurrencyHelper.currencyItem = currencyItem;
        CurrencyHelper.currencyName = currencyItem.getName();
        TM_CommonInfo.currency_format = currencyItem.getSymbol();
        TM_CommonInfo.currency = currencyItem.getName();
    }

    public static void loadSavedCurrency() {
        if (!AppInfo.ENABLE_CURRENCY_SWITCHER)
            return;

        CurrencyHelper.currencyName = Preferences.getString(com.twist.tmstore.R.string.key_app_currency, TM_CommonInfo.currency);
        for (CurrencyItem currencyItem : getAllCurrency()) {
            if (currencyItem.getName().equalsIgnoreCase(CurrencyHelper.currencyName)) {
                CurrencyHelper.currencyItem = currencyItem;
                break;
            }
        }
    }

    public static CurrencyItem getCurrencyItemWithName(String currencyName) {
        for (CurrencyItem currencyItem : getAllCurrency()) {
            if (currencyItem.getName().equalsIgnoreCase(currencyName)) {
                return currencyItem;
            }
        }
        return null;
    }

    public static void applyCurrencyRate(TM_ProductInfo product) {
        if (currencyItem == null)
            return;

        TM_CommonInfo.currency_format = currencyItem.getSymbol();
        TM_CommonInfo.currency = currencyItem.getName();
        DataHelper.log(TAG + " Product Price before currency change => " + product.price);
        product.price = CurrencyHelper.applyRate(product.price);
        product.regular_price = CurrencyHelper.applyRate(product.regular_price);
        product.sale_price = CurrencyHelper.applyRate(product.sale_price);
        DataHelper.log(TAG + " Product Price after currency change => " + product.price);
    }

    public static void applyCurrencyRate(TM_Variation variation) {
        if (currencyItem == null)
            return;

        TM_CommonInfo.currency_format = currencyItem.getSymbol();
        TM_CommonInfo.currency = currencyItem.getName();
        DataHelper.log(TAG + " Variation Price before currency change => " + variation.price);
        variation.price = CurrencyHelper.applyRate(variation.price);
        variation.regular_price = CurrencyHelper.applyRate(variation.regular_price);
        variation.sale_price = CurrencyHelper.applyRate(variation.sale_price);
        DataHelper.log(TAG + " Variation Price after currency change => " + variation.price);
    }

    public static float applyRate(float price) {
        return currencyItem == null ? price : price * currencyItem.getRate();
    }
}
