package com.twist.dataengine.entities;

import com.utils.DataHelper;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class TM_FilterAttribute {

    public String attribute;
    public String query_type;
    //public String slugs;
    //public String taxo;
    //public int position;
    //public boolean visible;
    //public boolean variation;

    public List<TM_FilterAttributeOption> options = new ArrayList<>();

    public TM_FilterAttributeOption getWithSlug(String slug) {
        for (TM_FilterAttributeOption option : options) {
            if (option.slug.equalsIgnoreCase(slug))
                return option;
        }
        return null;
    }

    public TM_FilterAttributeOption getWithName(String name) {
        for (TM_FilterAttributeOption option : options) {
            if (DataHelper.compareAttributeStrings(option.name, name))
                return option;
        }
        return null;
    }

    public TM_FilterAttributeOption getWithName(String name, boolean slugify) {
        for (TM_FilterAttributeOption option : options) {
            if (slugify) {
                if (DataHelper.compareAttributeStrings(option.name, name))
                    return option;
            } else if (option.name.equals(name)) {
                return option;
            }
        }
        return null;
    }

    public boolean isSubsetOf(TM_FilterAttribute other) {
        if (other == null)
            return false;

        if (!this.attribute.equalsIgnoreCase(other.attribute))
            return false;

        if (this.options.size() > other.options.size())
            return false;

        for (TM_FilterAttributeOption option : this.options) {
            if (!other.hasOption(option)) {
                return false;
            }
        }
        return true;
    }


    public boolean isSubsetOf(TM_Attribute other) {
        if (other == null)
            return false;

        if (!this.attribute.equalsIgnoreCase(other.name))
            return false;

        if (this.options.size() > other.options.size())
            return false;

        for (TM_FilterAttributeOption option : this.options) {
            if (!other.hasOptionFilterAttribute(option)) {
                return false;
            }
        }
        return true;
    }

    public boolean hasOption(TM_FilterAttributeOption otherOption) {
        for (TM_FilterAttributeOption option : this.options) {
            if (option.slug.equals(otherOption.slug)) {
                return true;
            }
        }
        return false;
    }


    public boolean removeOption(TM_FilterAttributeOption optionToRemove) {
        for (TM_FilterAttributeOption option : this.options) {
            if (option.slug.equals(optionToRemove.slug)) {
                this.options.remove(option);
                return true;
            }
        }
        return false;
    }

    public boolean hasOptionStr(String optionValue) {
        for (TM_FilterAttributeOption option : this.options) {
            if (option.name.equalsIgnoreCase(optionValue)) {
                return true;
            }
        }
        return false;
    }

    public TM_Attribute getProductAttribute() {
        TM_Attribute attribute = new TM_Attribute(UUID.randomUUID().toString());
        attribute.name = this.attribute;
        if (!this.options.isEmpty()) {
            attribute.slug = this.options.get(0).slug;
            attribute.taxo = this.options.get(0).taxo;
        } else {
            attribute.slug = this.attribute;
            attribute.taxo = "";
        }
        for (TM_FilterAttributeOption option : this.options) {
            attribute.options.add(option.name);
        }
        return attribute;
    }
}
