package com.twist.dataengine.entities;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 12/15/2016.
 */

public class RawAttribute {

    private static List<RawAttribute> allRawAttributes = new ArrayList<>();
    private int id;
    private String name;
    private String slug;
    private String type;
    private String order_by;
    private boolean has_archives;
    private List<RawAttributeTerm> attribute_terms = new ArrayList<>();

    private RawAttribute(int id) {
        this.id = id;
        allRawAttributes.add(this);
    }

    public static List<RawAttribute> getAll() {
        return new ArrayList<>(allRawAttributes);
    }

    public static void clearAll() {
        allRawAttributes.clear();
    }

    public static RawAttribute getWithId(int id) {
        for (RawAttribute attribute : allRawAttributes) {
            if (attribute.id == id)
                return attribute;
        }
        return new RawAttribute(id);
    }

    public static RawAttribute getWithSlug(String slug) {
        for (RawAttribute attribute : allRawAttributes) {
            if (attribute.slug.equals(slug))
                return attribute;
        }
        return null;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
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

    public void setType(String type) {
        this.type = type;
    }

    public void addAttributeTerm(RawAttributeTerm term) {
        this.attribute_terms.add(term);
    }

    public List<RawAttributeTerm> getAttributeTerms() {
        return this.attribute_terms;
    }

    @Override
    public String toString() {
        return this.name;
    }
}
