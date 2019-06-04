package com.twist.tmstore.entities;

import com.activeandroid.Model;
import com.activeandroid.annotation.Column;
import com.activeandroid.annotation.Table;
import com.activeandroid.query.Select;
import com.utils.Log;

import java.util.ArrayList;
import java.util.List;

@Table(name = "RecentSearchItem")
public class RecentSearchItem extends Model {
    @Column(name = "text")
    public String text = "";

    private static final int MAX_RECENT_SEARCH_ITEM_COUNT = 5; //10;
    private static List<RecentSearchItem> mRecentSearchItems = null;
    private static boolean init = false;

    public RecentSearchItem() {
        super();
    }

    public static void create(String text) {
        if (!init) init();
        while (mRecentSearchItems.size() >= MAX_RECENT_SEARCH_ITEM_COUNT) {
            safelyRemove(0);
        }
        safelyRemove(text);

        RecentSearchItem recentSearchItem = new RecentSearchItem();
        recentSearchItem.text = text;
        recentSearchItem.save();
        mRecentSearchItems.add(recentSearchItem);
    }

    public RecentSearchItem(String str) {
        if (!init) init();

        while (mRecentSearchItems.size() >= MAX_RECENT_SEARCH_ITEM_COUNT) {
            safelyRemove(0);
        }

        safelyRemove(str);

        this.text = str;
        this.save();
        mRecentSearchItems.add(this);
    }

    private static void safelyRemove(int index) {
        if (index >= 0 && index < mRecentSearchItems.size()) {
            mRecentSearchItems.get(index).delete();
            mRecentSearchItems.remove(index);
        }
    }

    private static void safelyRemove(String str) {
        for (int i = 0; i < mRecentSearchItems.size(); i++) {
            if (mRecentSearchItems.get(i).text.equals(str)) {
                safelyRemove(i);
                break;
            }
        }
    }

    public static void safelyRemove(RecentSearchItem searchItem) {
        safelyRemove(mRecentSearchItems.indexOf(searchItem));
    }

    public static List<RecentSearchItem> getAll() {
        if (!init) init();
        return mRecentSearchItems;
    }

    public static List<String> getAllString() {
        if (!init) init();
        List<String> str_recenteSearchItems = new ArrayList<>();
        for (RecentSearchItem r : mRecentSearchItems) {
            str_recenteSearchItems.add(r.text);
        }
        java.util.Collections.reverse(str_recenteSearchItems);
        return str_recenteSearchItems;
    }

    public static void printAll() {
        if (!init) init();
        for (RecentSearchItem r : mRecentSearchItems) {
            Log.d("------- :[" + r.text + "] --------");
        }
    }

    public static void saveAll() {
        if (!init) init();
        for (RecentSearchItem r : mRecentSearchItems) {
            r.save();
        }
    }

    public static void init() {
        mRecentSearchItems = new Select().from(RecentSearchItem.class).execute();
        if (mRecentSearchItems == null)
            mRecentSearchItems = new ArrayList<>();
        init = true;
    }
}
