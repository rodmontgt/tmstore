package com.twist.tmstore.entities;

import com.activeandroid.Model;
import com.activeandroid.annotation.Column;
import com.activeandroid.annotation.Table;
import com.activeandroid.query.Select;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.dataengine.entities.TM_Variation;
import com.twist.dataengine.entities.TM_WishList;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.utils.AnalyticsHelper;
import com.utils.Helper;
import com.utils.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Table(name = "Wishlist")
public class Wishlist extends Model {
    @Column(name = "wishlist_product_id")
    public int product_id;

    @Column(name = "price")
    public float price = 0;

    @Column(name = "parent_title")
    public String parent_title = "";

    @Column(name = "parent_id")
    public Integer parent_id = 0;

    @Column(name = "title")
    public String title;

    @Column(name = "img_url")
    public String img_url;

    @Column(name = "short_description")
    public String short_description;

    @Column(name = "note")
    public String note;

    @Column(name = "price_min")
    public float price_min;

    @Column(name = "price_max")
    public float price_max;

    public boolean isChecked = false;

    public TM_ProductInfo product;

    public static List<Wishlist> allWishlistItems = null;

    public Wishlist() {
        super();
    }

    public Wishlist(int product_id, TM_ProductInfo product) {
        this.product_id = product_id;
        this.product = product;
        allWishlistItems.add(this);
    }

    public static boolean allItemAvailable() {
        for (Wishlist wishlist : allWishlistItems) {
            if (wishlist.product == null)
                return false;
        }
        return true;
    }

    public static String getUnavailableProductIds() {
        String ids = "";
        for (Wishlist wishlist : allWishlistItems) {
            if (wishlist.product == null)
                ids += wishlist.product_id + ";";
        }
        return ids;
    }

    public static void init() {
        allWishlistItems = new Select().from(Wishlist.class).execute();
        if (allWishlistItems == null) {
            allWishlistItems = new ArrayList<>();
        }

        for (Wishlist w : allWishlistItems) {
            w.product = TM_ProductInfo.getProductWithId(w.product_id);
        }
    }

    public float getItemPrice() {
        return product.getActualPrice();
    }

    public static int getItemCount() {
        return allWishlistItems.size();
    }

    public static void refresh() {
        if (allWishlistItems != null) {
            for (Wishlist w : allWishlistItems) {
                w.product = TM_ProductInfo.getProductWithId(w.product_id);
                if (w.product != null) {
                    w.title = w.product.title;
                    w.price = w.product.getActualPrice();
                    w.img_url = w.product.thumb;
                    w.short_description = w.product.getShortDescription();

                    w.price_max = w.product.price_max;
                    w.price_min = w.product.price_min;

//                  TODO Updating Price According to Variations
                    for (TM_Variation variation : w.product.variations) {
                        if (w.price_max < variation.price) {
                            w.price_max = variation.price;
                        }
                        if (w.price_max > variation.price) {
                            w.price_min = variation.price;
                        }
                    }
                }
            }
        }
    }

    public static List<Wishlist> getAll() {
        return allWishlistItems;
    }

    public static boolean addProduct(TM_ProductInfo product, WishListGroup wishgroup) {
        return Wishlist.addProduct(product, wishgroup, false);
    }

    public static boolean addProduct(final TM_ProductInfo product, final WishListGroup wishgroup, final boolean fromServer) {
        if (AppInfo.mGuestUserConfig != null && AppInfo.mGuestUserConfig.isEnabled() && AppInfo.mGuestUserConfig.isPreventWishlist() && AppUser.isAnonymous()) {
            Helper.toast(L.string.you_need_to_login_first);
            return false;
        }

        if (!AppInfo.ENABLE_MULTIPLE_WISHLIST) {
            if (hasItem(product)) {
                Log.d("-- requested product is already in wishlist --");
                return true;
            }
        }

        Wishlist w = new Wishlist(product.id, product);
        w.title = product.title;
        w.img_url = product.thumb;
        w.price = product.getActualPrice();
        w.short_description = product.getShortDescription();

        if (wishgroup != null) {
            w.parent_id = wishgroup.id;
            w.parent_title = wishgroup.title;
        }

//        TODO Updating Price According to Variations
        w.price_max = product.price_max;
        w.price_min = product.price_min;

        for (TM_Variation variation : product.variations) {
            if (w.price_max < variation.price) {
                w.price_max = variation.price;
            }
            if (w.price_max > variation.price) {
                w.price_min = variation.price;
            }
        }

        if (!AppInfo.ENABLE_MULTIPLE_WISHLIST || !AppUser.hasSignedIn())
            w.save();

        AnalyticsHelper.registerAddToWishListEvent(w);

        if (AppInfo.ENABLE_CUSTOM_WISHLIST && !fromServer) {
            Map<String, String> params = new HashMap<>();
            params.put("type", "add");
            params.put("user_id", "" + AppUser.getUserId());
            params.put("email_id", AppUser.getEmail());
            params.put("prod_id", "" + product.id);
            params.put("quantity", "1");
            params.put("wishlist_id", TM_WishList.getId());
            DataEngine.getDataEngine().addOrRemoveWishListProductAsync(params, new DataQueryHandler<String>() {
                @Override
                public void onSuccess(String data) {
                    Log.d(data);
                }

                @Override
                public void onFailure(Exception reason) {
                    Log.d(reason.getMessage());
                }
            });
        }
        return true;
    }

    public static void removeProduct(final TM_ProductInfo product) {
        for (Wishlist w : allWishlistItems) {
            if (w.product_id == product.id) {
                removeSafely(w);
                return;
            }
        }
        Log.d("-- can't remove, requested product not found in wishlist --");
    }

    public static boolean hasItem(TM_ProductInfo product) {
        for (Wishlist w : allWishlistItems) {
            if (w.product_id == product.id) {
                return true;
            }
        }
        return false;
    }

    public static Wishlist findCart(int product_id) {
        for (Wishlist w : allWishlistItems) {
            if (w.product_id == product_id) {
                return w;
            }
        }
        return null;
    }

    public static void removeChecked(final Wishlist wish) {
        try {
            wish.parent_id = 0;
            wish.delete();
            allWishlistItems.remove(wish);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void removeSafely(final Wishlist wish) {
        int wishProductId = -1;
        int productId = wish.product_id;
        if (AppInfo.USE_PARSE_ANALYTICS) {
            try {
                wishProductId = wish.product_id;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        if (AppInfo.ENABLE_MULTIPLE_WISHLIST) {
            if (AppUser.hasSignedIn()) {
                final int finalWishProductId = wishProductId;
                MainActivity.mActivity.showProgress(MainActivity.mActivity.getString(L.string.please_wait), false);
                WishListGroup.removeProductFromWishList(wish.product.wishlist_key, WishListGroup.getWishListIdFromProductKey(wish.product.wishlist_key), new DataQueryHandler() {
                    @Override
                    public void onSuccess(Object data) {
                        try {
                            wish.parent_id = 0;
                            allWishlistItems.remove(wish);
                            if (finalWishProductId != 1) {
                                AnalyticsHelper.registerRemoveWishListProductEvent(wish);
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                        MainActivity.mActivity.hideProgress();
                    }

                    @Override
                    public void onFailure(Exception error) {
                        MainActivity.mActivity.hideProgress();
                    }
                });
            } else {
                try {
                    wish.parent_id = 0;
                    wish.delete();
                    allWishlistItems.remove(wish);
                    if (wishProductId != 1) {
                        AnalyticsHelper.registerRemoveWishListProductEvent(wish);
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        } else {
            try {
                wish.parent_id = 0;
                wish.delete();
                allWishlistItems.remove(wish);
                if (wishProductId != 1) {
                    AnalyticsHelper.registerRemoveWishListProductEvent(wish);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        if (AppInfo.ENABLE_CUSTOM_WISHLIST) {
            Map<String, String> params = new HashMap<>();
            params.put("type", "delete");
            params.put("user_id", "" + AppUser.getUserId());
            params.put("email_id", AppUser.getEmail());
            params.put("prod_id", "" + productId);
            params.put("wishlist_id", TM_WishList.getId());
            DataEngine.getDataEngine().addOrRemoveWishListProductAsync(params, new DataQueryHandler<String>() {
                @Override
                public void onSuccess(String data) {
                    Log.d(data);
                }

                @Override
                public void onFailure(Exception reason) {
                    Log.d(reason.getMessage());
                }
            });
        }
    }

    public int getWishlistItemCategory() {
        if (product != null) {
            return product.getFirstCategoryId();
        } else {
            return -1;
        }
    }

    public static void removeAllOfflineSafely(final List<Wishlist> wishlist) {
        for (Wishlist wish : wishlist) {
            int wishProductId = -1;
            if (AppInfo.USE_PARSE_ANALYTICS) {
                try {
                    wishProductId = wish.product_id;
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            try {
                wish.parent_id = 0;
                wish.delete();
                allWishlistItems.remove(wish);
                if (wishProductId != 1) {
                    AnalyticsHelper.registerRemoveWishListProductEvent(wish);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    public static void clearItems() {
        if (allWishlistItems == null || allWishlistItems.size() <= 0)
            return;
        for (Wishlist wish : allWishlistItems) {
            wish.delete();
        }
        allWishlistItems.clear();
    }

    public static void printAll() {
        for (Wishlist w : allWishlistItems) {
            Log.d("------- Wishlist:[" + w.product_id + "] --------");
        }
    }

    public boolean hasPriceRange() {
        return price_min != price_max;
    }
}
