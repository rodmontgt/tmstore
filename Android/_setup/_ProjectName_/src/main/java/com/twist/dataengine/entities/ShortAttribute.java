package com.twist.dataengine.entities;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 22-08-2017.
 */

public class ShortAttribute {
    private String name;
    private String slug;
    private List<Term> terms;

    private static List<ShortAttribute> shortAttributes = new ArrayList<>();

    public static class Term {
        public String key;
        public String value;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getSlug() {
        return slug;
    }

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public List<Term> getTerms() {
        return terms;
    }

    public void setTerms(List<Term> terms) {
        this.terms = terms;
    }

    public ShortAttribute() {
        shortAttributes.add(this);
    }

    public static List<ShortAttribute> getAll() {
        return shortAttributes;
    }

    public static ShortAttribute getShortAttributeWithSlug(String slug) {
        for (ShortAttribute shortAttribute : shortAttributes) {
            if (shortAttribute.slug.equalsIgnoreCase(slug)) {
                return shortAttribute;
            }
        }
        return null;
    }
}
