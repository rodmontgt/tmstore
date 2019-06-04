package com.utils;


import android.text.TextUtils;

import com.twist.dataengine.entities.TM_CommonInfo;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.dataengine.entities.TM_SimpleCart;
import com.twist.dataengine.entities.TM_Tax;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import static com.twist.dataengine.entities.TM_Tax.all_Tax;
import static com.twist.dataengine.entities.TM_Tax.all_TaxesApplied;

/**
 * Created by Twist Mobile on 6/7/2017.
 */

public class TaxHelper {

    public static boolean isTaxApplicable(TM_Tax tax) {
        if (TM_CommonInfo.tax_based_on.equals(""))
            return false;

        TM_CommonInfo.LocalityInfo localityInfo = new TM_CommonInfo.LocalityInfo();
        if (TM_CommonInfo.tax_based_on.equals("shipping")) {
            //tax is applied on customer shipping address
            localityInfo = TM_CommonInfo.shippingLocalityInfo;
        } else if (TM_CommonInfo.tax_based_on.equals("billing")) {
            //tax is applied on customer billing address
            localityInfo = TM_CommonInfo.billingLocalityInfo;
        } else if (TM_CommonInfo.tax_based_on.equals("base")) {
//            //tax is applied on merchant shop base address
//            /*userCountryCode = commonInfo -> _shopBaseAddressCountryId ?[[NSString stringWithFormat:@
//            "%@", commonInfo -> _shopBaseAddressCountryId]uppercaseString]:@ "";
//            userStateCode = commonInfo -> _shopBaseAddressStateId ?[[NSString stringWithFormat:@
//            "%@", commonInfo -> _shopBaseAddressStateId]uppercaseString]:@ "";*/
        }

        if (tax.getCountry().compareTo("") != 0 && !tax.getCountry().equals(localityInfo.countryCode)) {
            return false;
        }

        if (tax.getState().compareTo("") != 0 && !tax.getState().equals(localityInfo.stateCode)) {
            return false;
        }

        if (tax.getCity().compareTo("") != 0 && !tax.getCity().equals(localityInfo.city)) {
            return false;
        }

        if (tax.getPostcode().compareTo("") != 0 && !tax.getPostcode().equals(localityInfo.pinCode)) {
            return false;
        }
        return true;
    }

    public static double calculateTaxProduct(double price, String taxClass, boolean isProductTaxable, boolean isShippingNecessary) {
        double productPriceWithoutTax = price;
        double productPriceWithTax = price;
        double taxOnProduct = 0.0f;

        if (price == 0.0f) {
            return taxOnProduct;
        }

        if (isProductTaxable) {
            if (taxClass == null || taxClass.compareTo("") == 0) {
                taxClass = "standard";
            }

            List<TM_Tax> taxesForThisProd = new ArrayList<>();
            Collections.sort(all_Tax, new Comparator<TM_Tax>() {
                @Override
                public int compare(TM_Tax o1, TM_Tax o2) {
                    return o1.getPriority() - o2.getPriority();
                }
            });
            all_TaxesApplied.clear();
            for (TM_Tax obj : all_Tax) {
                if (obj.taxClass.compareTo(taxClass) == 0) {
                    taxesForThisProd.add(TM_Tax.copy(obj));
                    all_TaxesApplied.add(obj);
                    DataHelper.log("TaxHelper " + obj.getName());
                }
            }

            double productPrice = price;
            if (productPrice < 0) {
                productPrice = 0.0f;
            }
            productPriceWithTax = productPrice;
            productPriceWithoutTax = productPrice;

            DataHelper.log("TaxHelper 000: " + taxesForThisProd.size());

            for (TM_Tax taxObj : taxesForThisProd) {
                if (isTaxApplicable(taxObj) && !taxObj.compound) {
                    if (!isShippingNecessary || taxObj.shipping) {
                        double taxOnThisProduct = productPrice * taxObj.rate / 100.0f;
                        productPriceWithTax += taxOnThisProduct;
                        DataHelper.log("TaxHelper taxOnThisProduct: " + taxOnThisProduct);
                        DataHelper.log("TaxHelper netTax: " + taxObj.netTax);
                        DataHelper.log("TaxHelper productPriceWithTax: " + productPriceWithTax);
                    }
                }
            }

            double productPriceWithTaxForCompound = productPriceWithTax;
            for (TM_Tax taxObj : taxesForThisProd) {
                if (isTaxApplicable(taxObj) && taxObj.compound) {
                    if (!isShippingNecessary || taxObj.shipping) {
                        double taxOnThisProduct = productPriceWithTaxForCompound * taxObj.rate / 100.0f;
                        productPriceWithTax += taxOnThisProduct;
                    }
                }
            }

        }
        taxOnProduct = productPriceWithTax - productPriceWithoutTax;
        DataHelper.log("TaxHelper taxOnProduct: " + taxOnProduct);
        DataHelper.log("TaxHelper productPriceWithTax: " + productPriceWithTax);
        DataHelper.log("TaxHelper productPriceWithoutTax: " + productPriceWithoutTax);
        return taxOnProduct;
    }

    public static float calculateTax(float cost, String productTaxClass, boolean isProductTaxable, boolean isShippingNecessary) {
        if (!isShippingNecessary && TM_CommonInfo.woocommerce_prices_include_tax.equals("true")) {
            return 0.0f;
        }

        if (!isShippingNecessary && TM_CommonInfo.addTaxToProductPrice) {
            return 0.0f;
        }

        float productPriceWithoutTax = cost;
        float productPriceWithTax = cost;
        float taxOnProduct = 0.0f;

        if (cost == 0.0f) {
            return taxOnProduct;
        }
        if (isProductTaxable) {
            if (TextUtils.isEmpty(productTaxClass)) {
                productTaxClass = "standard";
            }

            List<TM_Tax> taxesForThisProd = new ArrayList<>();
            Collections.sort(all_Tax, new Comparator<TM_Tax>() {
                @Override
                public int compare(TM_Tax o1, TM_Tax o2) {
                    return o1.getPriority() - o2.getPriority();
                }
            });

            all_TaxesApplied.clear();
            for (TM_Tax obj : all_Tax) {
                if (obj.taxClass.compareTo(productTaxClass) == 0) {
                    taxesForThisProd.add(TM_Tax.copy(obj));
                    all_TaxesApplied.add(obj);
                    DataHelper.log("TaxHelper " + obj.getName());
                }
            }

            float productPrice = cost;
            if (productPrice < 0) {
                productPrice = 0.0f;
            }

            productPriceWithTax = productPrice;
            productPriceWithoutTax = productPrice;
            for (TM_Tax taxObj : taxesForThisProd) {
                if (isTaxApplicable(taxObj) && !taxObj.compound) {
                    if (!isShippingNecessary || taxObj.shipping) {
                        double taxOnThisProduct = productPrice * taxObj.rate / 100.0f;
                        taxObj.netTax += taxOnThisProduct;
                        productPriceWithTax += taxOnThisProduct;
                    }
                }
            }
            float productPriceWithTaxForCompound = productPriceWithTax;
            for (TM_Tax taxObj : taxesForThisProd) {
                if ((isTaxApplicable(taxObj) && taxObj.compound)) {
                    if (!isShippingNecessary || taxObj.shipping) {
                        double taxOnThisProduct = productPriceWithTaxForCompound * taxObj.rate / 100.0f;
                        taxObj.netTax += taxOnThisProduct;
                        productPriceWithTax += taxOnThisProduct;
                    }
                }
            }
        }

        taxOnProduct = productPriceWithTax - productPriceWithoutTax;
        return taxOnProduct;
    }

    public static void setPriceFromTax(TM_ProductInfo pInfo) {
        pInfo.priceOriginal = pInfo.price;
        pInfo.regular_priceOriginal = pInfo.regular_price;
        pInfo.sale_priceOriginal = pInfo.sale_price;

        if (!TM_CommonInfo.addTaxToProductPrice) {
            return;
        }

        if (pInfo.taxable) {
            DataHelper.log("TaxHelper Price: " + pInfo.price);
            pInfo.price += calculateTaxProduct(pInfo.price, pInfo.taxClass, pInfo.taxable, false);
            DataHelper.log("TaxHelper newPrice: " + pInfo.price);
            pInfo.regular_price += calculateTaxProduct(pInfo.regular_price, pInfo.taxClass, pInfo.taxable, false);
            pInfo.sale_price += calculateTaxProduct(pInfo.sale_price, pInfo.taxClass, pInfo.taxable, false);
        }
    }

    public static void setPriceFromTax(TM_SimpleCart pInfo) {
        if (!TM_CommonInfo.addTaxToProductPrice) {
            return;
        }

        if (pInfo != null && pInfo.taxable) {
            pInfo.price += calculateTaxProduct(pInfo.price, "", true, false);
            pInfo.regular_price += calculateTaxProduct(pInfo.regular_price, "", pInfo.taxable, false);
            pInfo.sale_price += calculateTaxProduct(pInfo.sale_price, "", pInfo.taxable, false);
        }
    }

    public static float calculateTotalTax(float shippingCost) {
        calculateTax(shippingCost, TM_CommonInfo.shipping_tax_class, true, true);
        float totalTax = 0.0f;
        for (TM_Tax taxObj : all_TaxesApplied) {
            if (taxObj.netTax > 0) {
                totalTax += taxObj.netTax;
            }
        }
        return totalTax;
    }

    public static float applyTaxOnPrice(float priceActual) {
        if (!TM_CommonInfo.addTaxToProductPrice)
            return 0.0f;
        return (float) calculateTaxProduct(priceActual, TM_CommonInfo.shipping_tax_class, true, false);
    }
}
