package com.twist.dataengine.entities;

import com.utils.DataHelper;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

public class TM_CategoryInfo {
    private static List<TM_CategoryInfo> allCategories = null;
    private static List<TM_CategoryInfo> rootCategories = null;
    public int id;
    public String slug;
    public int loadedPageCount = 0;
    public int officiallyLoadedProductsCount = 0;
    public TM_CategoryInfo parent = null;
    public String description;
    public String display;
    public String image;
    public int count;
    public int tempSlugDigit = 9999;
    public boolean isProductRefreshed = true;
    public boolean isBlocked = false;
    public List<TM_CategoryInfo> childrens = new ArrayList<>();
    private String name = "Other";
    private String banner = null;
    private int strict_count = -1;

    public static void init() {
        if (allCategories == null) {
            allCategories = new ArrayList<>();
        }

        if (allCategories.size() > 0) {
            allCategories.clear();
        }

        if (rootCategories != null) {
            rootCategories.clear();
        }
    }

    public static void remove(TM_CategoryInfo category) {
        try {
            if (category.hasParent()) {
                category.parent.childrens.remove(category);
            }
        } catch (Exception ignored) {
        }
        allCategories.remove(category);
    }

    public static void reorderCategoryIndex(int id, int index) {
        TM_CategoryInfo category = TM_CategoryInfo.getWithId(id);
        reorderCategoryIndex(category, index);
    }

    public static void reorderCategoryIndex(TM_CategoryInfo category, int index) {
        allCategories.remove(category);
        allCategories.add(index, category);
    }

    public static void clearRoots() {
        if (rootCategories != null) {
            rootCategories.clear();
            rootCategories = null;
        }
    }

    public static TM_CategoryInfo getWithSlug(String slug) {
        for (TM_CategoryInfo c : allCategories) {
            if (c.slug.equalsIgnoreCase(slug)) {
                return c;
            }
        }

        TM_CategoryInfo cate = new TM_CategoryInfo();
        cate.slug = slug;
        allCategories.add(cate);
        return cate;
    }

    public static TM_CategoryInfo getWithName(String name) {
        for (TM_CategoryInfo c : allCategories) {
            if (c.name.equalsIgnoreCase(name)) {
                return c;
            }
        }

        TM_CategoryInfo cate = new TM_CategoryInfo();
        cate.name = name;
        allCategories.add(cate);
        return cate;
    }

    public static TM_CategoryInfo getWithId(int id) {
        if (id <= 0)
            return null;

        for (TM_CategoryInfo c : allCategories) {
            if (c.id == id) {
                return c;
            }
        }

        TM_CategoryInfo cate = new TM_CategoryInfo();
        cate.id = id;
        allCategories.add(cate);
        return cate;
    }

    public static int indexOfCategory(int id) {
        if (id <= 0)
            return -1;

        for (int i = 0; i < allCategories.size(); i++) {
            if (allCategories.get(i).id == id) {
                return i;
            }
        }
        return -1;
    }

    public static boolean hasCategory(int id) {
        if (id > 0 && allCategories != null) {
            for (TM_CategoryInfo c : allCategories) {
                if (c.id == id) {
                    return true;
                }
            }
        }
        return false;
    }

    public static List<TM_CategoryInfo> getAllWithKeyWords(List<String> keyWords) {
        DataHelper.log("### cateogryinfo:getAllWithKeyWords:[" + keyWords.size() + "] ###");
        List<TM_CategoryInfo> categoriesWithKeywords = new ArrayList<>();
        TM_CategoryInfo temp = getWithKeyWords(keyWords);
        if (temp != null) {
            categoriesWithKeywords.add(temp);
            return categoriesWithKeywords;
        }

        if (keyWords.size() == 0)
            return categoriesWithKeywords;

        for (TM_CategoryInfo c : allCategories) {
            if (c.hasAnyOfThisKeyWord(keyWords)) {
                if (!categoriesWithKeywords.contains(c)) {
                    categoriesWithKeywords.add(c);
                }
            }
        }
        return categoriesWithKeywords;
    }

    public static List<TM_CategoryInfo> eliminateParents(List<TM_CategoryInfo> givenList) {
        DataHelper.log("### cateogryinfo:eliminateParents:[" + givenList.size() + "] ###");
        List<TM_CategoryInfo> returnList = new ArrayList<>();
        if (givenList.size() == 0)
            return returnList;

        for (TM_CategoryInfo c : givenList) {
            if (!c.hasAnyOfThisChild(givenList)) {
                returnList.add(c);
            }
        }
        return returnList;
    }

    public static TM_CategoryInfo getWithKeyWords(List<String> keyWords) {
        DataHelper.log("### cateogryinfo:getWithKeyWords:[" + keyWords.size() + "] ###");
        if (keyWords.size() == 0)
            return null;

        for (TM_CategoryInfo c : allCategories) {
            if (c.hasKeyWords(keyWords)) {
                return c;
            }
        }
        return null;
    }

    public static List<TM_CategoryInfo> getAll() {
        return allCategories;
    }

    public static boolean isAllEmpty() {
        return (allCategories == null || allCategories.isEmpty());
    }

    public static void flushAll() {
        for (int i = allCategories.size() - 1; i >= 0; i--) {
            allCategories.remove(i);
        }
        clearRoots();
    }

    public static List<TM_CategoryInfo> getRootCategoriesExcludingEmptyOrOrphan() {
        if (allCategories == null) {
            DataHelper.log("-- Categories are not initialized --");
            return null;
        }

        if (rootCategories == null) {
            rootCategories = new ArrayList<>();
        }

        rootCategories.clear();

        for (TM_CategoryInfo c : allCategories) {
            if (c.parent == null && c.name != null && !c.isBlocked) {
                if (c.name.equalsIgnoreCase("other")) {
                    continue;
                }
                rootCategories.add(c);
            }
        }
        return rootCategories;
    }

    public static List<TM_CategoryInfo> getAllRootCategories() {
        if (allCategories == null) {
            DataHelper.log("-- Categories are not initialized --");
            return null;
        }

        if (rootCategories == null) {
            rootCategories = new ArrayList<>();
        }

        rootCategories.clear();

        for (TM_CategoryInfo c : allCategories) {
            if (c.parent == null && c.name != null && !c.isBlocked) {
                rootCategories.add(c);
            }
        }
        return rootCategories;
    }

    public static List<String> getAllRootCategoryNames() {
        if (allCategories == null) {
            DataHelper.log("-- Categories are not initialized --");
            return null;
        }

        if (rootCategories == null) {
            getAllRootCategories();
        }

        List<String> names = new ArrayList<>();
        for (TM_CategoryInfo c : allCategories) {
            names.add(c.name);
        }
        return names;
    }

    public static void printAll() {
        for (TM_CategoryInfo c : allCategories) {
            //DataHelper.log("------- Category:[" + c.id + "] --------");
            DataHelper.log("-- name: " + c.name);
            //DataHelper.log("-- slug: " + c.slug);
            //DataHelper.log("-- parent: " + (c.parent == null ? "null" : c.parent.id));
            //DataHelper.log("-- description: " + c.description);
            //DataHelper.log("-- display: " + c.display);
            //DataHelper.log("-- count: " + c.count);
            //DataHelper.log("-------------------------------------------------------");
        }
    }

    public static void sortCategory() {
        Collections.sort(allCategories, new Comparator<TM_CategoryInfo>() {
            @Override
            public int compare(TM_CategoryInfo tm_categoryInfo, TM_CategoryInfo t1) {
                return tm_categoryInfo.name.compareToIgnoreCase(t1.name);
            }
        });
    }

    public static TM_CategoryInfo findCategoryByName(String name) {
        for (TM_CategoryInfo c : allCategories) {
            if (c.name.equalsIgnoreCase(name)) {
                return c;
            }
        }
        return null;
    }

    public boolean belongsToCategory(TM_CategoryInfo category) {
        if (this.equals(category))
            return true;

        for (TM_CategoryInfo c : category.childrens) {
            if (c.belongsToCategory(this)) {
                return true;
            }
        }
        return false;
    }

    public int getTotalProductCount() {
        return count;
    }

    public int getCompleteProductCountIncludingSubCategories() {
        int total = 0;
        for (TM_CategoryInfo category : childrens) {
            total += category.getCompleteProductCountIncludingSubCategories();
        }
        return total + count;
    }

    public int getStrictProductCount() {
//        if (strict_count < 0) {
//            int tempCount = this.count;
//            for (TM_CategoryInfo category : childrens) {
//                tempCount -= category.getStrictProductCount();
//            }
//            strict_count = tempCount;
//        }
//        return strict_count;
        return this.count;
    }

    public boolean hasKeyWord(String key) {
        return this.name.equalsIgnoreCase(key) || this.hasParent() && this.parent.hasKeyWord(key);
    }

    public boolean hasAnyOfThisKeyWord(List<String> keys) {
        if (keys.isEmpty()) {
            return false;
        }

        for (String key : keys) {
            if (this.name.equalsIgnoreCase(key))
                return true;
        }
        return false;
    }

    public boolean hasKeyWordForSearch(String key) {
        return this.name.toLowerCase().contains(key) || this.hasParent() && this.parent.hasKeyWordForSearch(key);
    }

    public boolean containsTag(String tag) {
        return this.name.toLowerCase().contains(tag);
    }

    public boolean hasParent() {
        return parent != null;
    }

    public void addChild(TM_CategoryInfo child) {
        childrens.add(child);
    }

    public void setParent(TM_CategoryInfo parent) {
        if (parent != null) {
            parent.addChild(this);
        }
        this.parent = parent;
    }

    public boolean hasAnyOfThisChild(List<TM_CategoryInfo> childrens) {
        for (TM_CategoryInfo child : childrens) {
            if (this.childrens.contains(child)) {
                return true;
            }
        }
        return false;
    }

    public boolean hasKeyWords(List<String> keyWords) {
        for (String keyWord : keyWords) {
            if (!this.hasKeyWord(keyWord))
                return false;
        }
        return true;
    }

    public List<TM_CategoryInfo> getSubCategories() {
        List<TM_CategoryInfo> list = new ArrayList<>();
        for (TM_CategoryInfo c : allCategories) {
            if (c.parent == this && !c.isBlocked) {
                list.add(c);
            }
        }
        return list;
    }

    public boolean equals(TM_CategoryInfo another) {
        return (this.id == another.id);
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getBanner() {
        return banner;
    }

    public void setBanner(String banner) {
        this.banner = banner;
    }

    public boolean hasBanner() {
        return (this.banner != null && this.banner.length() > 0);
    }

    @Override
    public String toString() {
        String text = this.name;
        if (this.parent != null) {
            text += " (" + parent.name + ")";
        }
        return text;
    }
}
