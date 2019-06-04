package com.twist.dataengine.entities;

import android.os.Build;
import android.text.Html;

import com.twist.dataengine.DataEngine;
import com.utils.DataHelper;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class TM_Attribute {
    public String id;
    public String name;
    public String slug;
    public String taxo;
    public int position;
    public boolean visible = true;
    public boolean variation = false;
    public List<String> options = new ArrayList<>();
    public double additional_price = 0;
    public HashMap<String, Float> additional_values;

    public TM_Attribute(String id) {
        this.id = id;
    }

    @Override
    public String toString() {
        return name + " (" + options.size() + ")";
    }

    public TM_VariationAttribute getVariationAttribute(int optionIndex) {
        TM_VariationAttribute tm_variationAttribute = new TM_VariationAttribute(this.id);
        tm_variationAttribute.name = this.name;
        tm_variationAttribute.slug = this.slug;
        tm_variationAttribute.value = this.options.get(optionIndex);
        return tm_variationAttribute;
    }

    public boolean isSubsetOf(TM_Attribute other) {
        if (other == null)
            return false;

        if (!this.name.equalsIgnoreCase(other.name))
            return false;

        if (this.options.size() > other.options.size())
            return false;

        for (String option : this.options) {
            if (!other.options.contains(option))
                return false;
        }
        return true;
    }


    public boolean hasOptionFilterAttribute(TM_FilterAttributeOption optionValue) {
        for (String option : this.options) {
            if (option.equalsIgnoreCase(optionValue.name)) {
                return true;
            }
        }
        return false;
    }

//    public void updateValue(String oldValue, String newValue) {
//        for (int i = 0; i < options.size(); i++) {
//            if (options.get(i).equals(oldValue)) {
//                options.set(i, newValue);
//                return;
//            }
//        }
//    }

    public void addAdditionalPrice(String option, float value) {
        option = DataHelper.toSlug(option);
        if (additional_values == null) {
            additional_values = new HashMap<>();
        }
        additional_values.put(option, value);
    }

    public float getAdditionalPrice(String option) {
        option = DataHelper.toSlug(option);
        if (additional_values != null && additional_values.containsKey(option))
            return additional_values.get(option);
        return 0;
    }

    public List<String> getOptions() {
        if (DataEngine.load_extra_attrib_data) {
            List<String> returnValues = new ArrayList<>();
            for (String option : options) {
                String returnString = option;
                float additionalPrice = getAdditionalPrice(option);
                if (additionalPrice > 0) {
                    returnString += " [+ " + DataHelper.appendCurrency(additionalPrice) + "]";
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    returnValues.add(Html.fromHtml(returnString, Html.FROM_HTML_MODE_LEGACY).toString());
                } else {
                    returnValues.add(Html.fromHtml(returnString).toString());
                }
            }
            return returnValues;
        } else {
            return options;
        }
    }
}
