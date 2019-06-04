package com.twist.dataengine.entities;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 12/12/2016.
 */

public class RawCategory {

    private int id;
    private int parent_id = -1;
    private String name;
    private String thumb;

    private List<RawCategory> children = new ArrayList<>();

    private RawCategory(int id) {
        this.id = id;
        allCategories.add(this);
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getThumb() {
        return thumb;
    }

    public void setThumb(String thumb) {
        this.thumb = thumb;
    }

    public List<RawCategory> getChildren() {
        return children;
    }

    public  int getParentId() {
        return parent_id;
    }

    public void addChild(RawCategory category) {
        category.parent_id = this.id;
        this.children.add(category);
    }

    @Override
    public String toString() {
        //return getNestedName();
        return this.name;
    }

    public String getNestedName() {
        if (this.parent_id == -1) {
            return this.name;
        } else {
            return getWithId(this.parent_id).getNestedName() + " » " + this.name;
        }
    }

    //// STATICs ////

    private static boolean _tempCategoriesLoaded = false;

    public static void setCategoriesLoaded() {
        _tempCategoriesLoaded = true;
    }

    public static boolean loadingCompleted() {
        return _tempCategoriesLoaded;
    }

    public static List<RawCategory> getRoots() {
        List<RawCategory> roots = new ArrayList<>();
        for (RawCategory category : allCategories) {
            if (category.parent_id == -1) {
                roots.add(category);
            }
        }
        return roots;
    }

    public static RawCategory getWithId(int id) {
        for (RawCategory category : allCategories) {
            if (category.id == id) {
                return category;
            }
        }
        return new RawCategory(id);
    }

    public static List<RawCategory> getAll() {
        return new ArrayList<>(allCategories);
    }

    private static List<RawCategory> allCategories = new ArrayList<>();

}
