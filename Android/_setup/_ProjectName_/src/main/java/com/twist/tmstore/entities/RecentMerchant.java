package com.twist.tmstore.entities;

import com.activeandroid.Model;
import com.activeandroid.annotation.Column;
import com.activeandroid.annotation.Table;
import com.activeandroid.query.Select;
import com.utils.Log;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Table(name = "RecentMerchant")
public class RecentMerchant extends Model {

    @Column(name = "_id")
    public String id = "";

    @Column(name = "title")
    public String title = "";

    @Column(name = "description")
    public String description = "";

    @Column(name = "image_url")
    public String imageUrl = "";

    @Column(name = "is_referred")
    public boolean isReferred = false;

    private static final int MAX_RECENT_MERCHANTS = 20;

    private static List<RecentMerchant> mRecentMerchants = null;

    private static boolean initialized = false;

    public RecentMerchant() {
        super();
    }

    public static boolean initialize() {
        if (!initialized) {
            mRecentMerchants = new Select().from(RecentMerchant.class).execute();
            if (mRecentMerchants == null)
                mRecentMerchants = new ArrayList<>();
            initialized = true;
        }
        return true;
    }

    public RecentMerchant(String id) {
        if (initialize()) {
            while (mRecentMerchants.size() >= MAX_RECENT_MERCHANTS) {
                safelyRemove(0);
            }
            safelyRemove(id);
            this.id = id;
            mRecentMerchants.add(this);
        }
    }

    private static void safelyRemove(int index) {
        if (index >= 0 && index < mRecentMerchants.size()) {
            mRecentMerchants.get(index).delete();
            mRecentMerchants.remove(index);
        }
    }

    private static void safelyRemove(String str) {
        for (int i = 0; i < mRecentMerchants.size(); i++) {
            if (mRecentMerchants.get(i).id.equals(str)) {
                safelyRemove(i);
                break;
            }
        }
    }

    public static void safelyRemove(RecentMerchant searchItem) {
        safelyRemove(mRecentMerchants.indexOf(searchItem));
    }

    public static List<RecentMerchant> getAll() {
        RecentMerchant.initialize();
        return mRecentMerchants;
    }

    public static List<String> getAllString() {
        List<String> list = null;
        if (initialize()) {
            list = new ArrayList<>();
            for (RecentMerchant recentMerchant : mRecentMerchants) {
                list.add(recentMerchant.id);
            }
            Collections.reverse(list);
        }
        return list;
    }

    public static void saveAll() {
        if (initialize()) {
            for (RecentMerchant recentMerchant : mRecentMerchants) {
                recentMerchant.save();
            }
        }
    }

    public static void printAll() {
        if (initialize()) {
            for (RecentMerchant r : mRecentMerchants) {
                Log.d("------- :[" + r.id + "] --------");
            }
        }
    }
}
