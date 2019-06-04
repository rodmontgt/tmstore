package com.twist.dataengine.entities;

public class TM_VariationAttribute {

    public TM_VariationAttribute(String id, String name, String slug, String value, float extraPrice) {
        this.id = id;
        this.name = name;
        this.slug = slug;
        this.value = value;
        this.extraPrice = extraPrice;
    }

    public String id;
    public String name;
    public String slug;
    public String value;
    public float extraPrice;

    public TM_VariationAttribute(String id) {
        this.id = id;
    }

    public TM_VariationAttribute(TM_VariationAttribute other) {
        this.id = other.id;
        this.name = other.name;
        this.slug = other.slug;
        this.value = other.value;
        this.extraPrice = other.extraPrice;
    }

    public TM_VariationAttribute clone() {
        return new TM_VariationAttribute(this);
    }

    @Override
    public boolean equals(Object object) {
        if (object instanceof TM_VariationAttribute) {
            TM_VariationAttribute other = (TM_VariationAttribute) object;
            //return this.name.equalsIgnoreCase(other.name) && this.value.equalsIgnoreCase(other.value);
            return this.id.equals(other.id);
        }
        return super.equals(object);
    }
}
