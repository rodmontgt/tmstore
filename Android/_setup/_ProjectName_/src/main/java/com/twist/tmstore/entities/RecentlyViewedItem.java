package com.twist.tmstore.entities;

import com.activeandroid.ActiveAndroid;
import com.activeandroid.Model;
import com.activeandroid.annotation.Column;
import com.activeandroid.annotation.Table;
import com.activeandroid.query.Delete;
import com.activeandroid.query.Select;
import com.twist.dataengine.entities.TM_CommonInfo;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.dataengine.entities.TM_Variation;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 1/5/2017.
 */

@Table(name = "RecentlyViewedItem")
public class RecentlyViewedItem extends Model {

    public RecentlyViewedItem() {
        super();
    }

    @Column(name = "type")
    int type;

    @Column(name = "item_id")
    int item_id;

    @Column(name = "title")
    String title;

    @Column(name = "thumb")
    String thumb;

    @Column(name = "short_description")
    String short_description;

    @Column(name = "sku")
    String sku;

    @Column(name = "price")
    float price;

    @Column(name = "price_min")
    float price_min;

    @Column(name = "price_max")
    float price_max;

    public String getSku() {
        return sku;
    }

    public String getShortDescription() {
        return short_description;
    }

    public String getThumb() {
        return thumb;
    }

    public String getTitle() {
        return title;
    }


    public int getItemId() {
        return item_id;
    }

    public int getType() {
        return type;
    }

    public float getPrice() {
        return price;
    }

    public float getPrice_min() {
        return price_min;
    }

    public float getPrice_max() {
        return price_max;
    }

    public static final int ITEM_TYPE_CATEGORY = 0;
    public static final int ITEM_TYPE_PRODUCT = 1;

    public static RecentlyViewedItem create(TM_ProductInfo product) {
        if (product == null)
            return null;

        safelyRemove(ITEM_TYPE_PRODUCT, product.id);

        RecentlyViewedItem recentItem = new RecentlyViewedItem();
        recentItem.type = ITEM_TYPE_PRODUCT;
        recentItem.item_id = product.id;
        recentItem.title = product.title;
        recentItem.thumb = product.thumb;
        recentItem.short_description = product.getShortDescription();
        recentItem.sku = product.sku;

        recentItem.price = product.price;
        recentItem.price_max = product.price;
        recentItem.price_min = product.price;

        for (TM_Variation variation : product.variations) {
            if (recentItem.price_max < variation.price) {
                recentItem.price_max = variation.price;
            }
            if (recentItem.price_max > variation.price) {
                recentItem.price_min = variation.price;
            }
        }
        recentItem.save();
        return recentItem;
    }

    public static List<RecentlyViewedItem> create(List<TM_ProductInfo> products) {
        if (products == null)
            return null;
        List<RecentlyViewedItem> recentItems = new ArrayList<>();
        try {
            for (TM_ProductInfo product : products) {
                safelyRemove(ITEM_TYPE_PRODUCT, product.id);
                RecentlyViewedItem recentItem = new RecentlyViewedItem();
                recentItem.type = ITEM_TYPE_PRODUCT;
                recentItem.item_id = product.id;
                recentItem.title = product.title;
                recentItem.thumb = product.thumb;
                recentItem.short_description = product.getShortDescription();
                recentItem.sku = product.sku;

                recentItem.price = product.price;
                recentItem.price_max = product.price;
                recentItem.price_min = product.price;

                for (TM_Variation variation : product.variations) {
                    if (product.price_max < variation.price) {
                        recentItem.price_max = variation.price;
                    }
                    if (product.price_max > variation.price) {
                        recentItem.price_min = variation.price;
                    }
                }
                recentItem.save();
                recentItems.add(recentItem);
            }
            ActiveAndroid.setTransactionSuccessful();
        } finally {
            ActiveAndroid.endTransaction();
        }
        return recentItems;
    }

    public static List<RecentlyViewedItem> getAll() {
        try {
            return new Select().from(RecentlyViewedItem.class).execute();
        } catch (Exception e) {
            return new ArrayList<>();
        }
    }

    public static List<TM_ProductInfo> getAllProducts() {
        try {
            List<RecentlyViewedItem> recentlyViewedItems = getAll();
            List<TM_ProductInfo> products = new ArrayList<>();
            for (RecentlyViewedItem recentlyViewedItem : recentlyViewedItems) {
                if (recentlyViewedItem.type == ITEM_TYPE_PRODUCT) {
                    TM_ProductInfo product = TM_ProductInfo.getOrCreate(recentlyViewedItem.item_id);
                    if (product.title == null || "".equals(product.title)) {
                        product.title = recentlyViewedItem.title;
                        product.thumb = recentlyViewedItem.thumb;
                        product.setShortDescription(recentlyViewedItem.short_description);
                        product.sku = recentlyViewedItem.sku;
                        product.price = recentlyViewedItem.price;
                        product.price_max = recentlyViewedItem.price_max;
                        product.price_min = recentlyViewedItem.price_min;
                    }
                    if (TM_CommonInfo.hide_out_of_stock) {
                        if (product.in_stock)
                            products.add(product);
                    } else {
                        products.add(product);
                    }
                }
            }
            return products;
        } catch (Exception e) {
            return new ArrayList<>();
        }
    }

    private static void safelyRemove(int type, int item_id) {
        try {
            new Delete()
                    .from(RecentlyViewedItem.class)
                    .where("type = ?", type)
                    .where("item_id = ?", item_id)
                    .execute();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void clearItems() {
        try {
            new Delete().from(RecentlyViewedItem.class).execute();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
