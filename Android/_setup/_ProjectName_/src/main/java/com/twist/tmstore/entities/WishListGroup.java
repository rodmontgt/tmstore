package com.twist.tmstore.entities;

import android.app.Activity;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

import com.activeandroid.Model;
import com.activeandroid.annotation.Column;
import com.activeandroid.annotation.Table;
import com.activeandroid.query.Select;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.twist.dataengine.WooCommerceJSONHelper;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.utils.DataHelper;
import com.utils.Helper;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by Twist Mobile on 10/18/2016.
 */
@Table(name = "WishGroup")
public class WishListGroup extends Model {

    public static List<WishListGroup> allwishListGroup = null;

    public static List<TM_ProductInfo> selectedProductToAddInWishList = null;

    @Column(name = "title")
    public String title = "";

    @Column(name = "group_id")
    public int id = 0;

    @Column(name = "is_default")
    public boolean is_default = false;

    public String url = "";
    public String description = "";
    public String items = "";
    public boolean isChecked = false;


    public WishListGroup() {

    }

    public WishListGroup(String title, int id) {

        this.title = title;
        this.id = id;
    }

    public static WishListGroup createGroup(String title, int id) {

        WishListGroup wishGroup = new WishListGroup(title, id);

        if (!AppUser.hasSignedIn())
            wishGroup.save();

        return wishGroup;
    }

    public static WishListGroup getWishListGroupById(int id) {

        if (allwishListGroup != null && allwishListGroup.size() > 0) {
            for (WishListGroup wishlistgroup : allwishListGroup) {
                if (wishlistgroup.id == id)
                    return wishlistgroup;
            }
        }
        return null;
    }

    public static void init(boolean sync, final DataQueryHandler handler) {
        if (selectedProductToAddInWishList == null)
            selectedProductToAddInWishList = new ArrayList<>();

        if (!AppInfo.ENABLE_MULTIPLE_WISHLIST) {
            allwishListGroup = new Select().from(WishListGroup.class).execute();
            if (allwishListGroup == null) {
                allwishListGroup = new ArrayList<>();
            }
            return;
        }

        if (!AppUser.hasSignedIn()) {
            allwishListGroup = new Select().from(WishListGroup.class).execute();
        } else {
            if (allwishListGroup == null) {
                allwishListGroup = new ArrayList<>();
            }
            if (!sync) {
                if (handler != null)
                    handler.onSuccess(null);
                return;
            }
            syncAndRefreshWishListToServer(sync, handler);
        }
    }

    public static void addWishlist(final String title, final DataQueryHandler dataQueryHandler) {
        Map<String, String> params = new HashMap<>();
        params.put("type", "create-list");
        params.put("emailid", AppUser.getEmail());
        params.put("user_id", String.valueOf(AppUser.getUserId()));

        try {
            params.put("wish_info", ((new JSONObject().put("wishlist_title", title)).toString()));
        } catch (JSONException e) {
            e.printStackTrace();
        }

        DataEngine.getDataEngine().addOrRemoveMultipleWishListProductAsync(params, new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {
                MainActivity.mActivity.hideProgress();
                try {
                    JSONObject jsonobj = DataHelper.safeJsonObject(data.toString());
                    WishListGroup wg = createAndAddNewGroupOffline(title, jsonobj.getInt("wishlist_id"));
                    dataQueryHandler.onSuccess(wg);
                } catch (JSONException e) {
                    e.printStackTrace();
                    dataQueryHandler.onFailure(e);
                }
            }

            @Override
            public void onFailure(Exception error) {
                dataQueryHandler.onFailure(error);
            }
        });
    }

    public static void updateWishList(final int wid, final String title, final DataQueryHandler dataQueryHandler) {
        Map<String, String> params = new HashMap<>();
        params.put("type", "update-list");
        params.put("emailid", AppUser.getEmail());
        params.put("user_id", String.valueOf(AppUser.getUserId()));
        params.put("wid", String.valueOf(wid));
        params.put("user_id", String.valueOf(AppUser.getUserId()));


        try {
            params.put("wish_info", ((new JSONObject().put("wishlist_title", title)).toString()));
        } catch (JSONException e) {
            e.printStackTrace();
        }

        DataEngine.getDataEngine().addOrRemoveMultipleWishListProductAsync(params, new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {
                MainActivity.mActivity.hideProgress();
                try {
                    JSONObject jsonobj = DataHelper.safeJsonObject(data.toString());
                    if (jsonobj.getString("status").compareTo("success") == 0)
                        dataQueryHandler.onSuccess(data);
                    else
                        dataQueryHandler.onFailure(new Exception("Failed"));
                } catch (JSONException e) {
                    e.printStackTrace();
                    dataQueryHandler.onFailure(e);
                }
            }

            @Override
            public void onFailure(Exception error) {
                dataQueryHandler.onFailure(error);
            }
        });
    }

    public static void deleteWishList(final int wid, final DataQueryHandler dataQueryHandler) {
        Map<String, String> params = new HashMap<>();
        params.put("type", "delete-list");
        params.put("emailid", AppUser.getEmail());
        params.put("user_id", String.valueOf(AppUser.getUserId()));
        params.put("wid", String.valueOf(wid));

        DataEngine.getDataEngine().addOrRemoveMultipleWishListProductAsync(params, new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {
                MainActivity.mActivity.hideProgress();
                try {
                    JSONObject jsonobj = DataHelper.safeJsonObject(data.toString());
                    int id = jsonobj.getInt("wishlist_id");
                    if (id == wid)
                        dataQueryHandler.onSuccess(data);
                    else
                        dataQueryHandler.onFailure(new Exception("Failed"));
                } catch (JSONException e) {
                    e.printStackTrace();
                    dataQueryHandler.onFailure(e);
                }
            }

            @Override
            public void onFailure(Exception error) {
                dataQueryHandler.onFailure(error);
            }
        });
    }

    public static WishListGroup createAndAddNewGroupOffline(String title, int id) {
        if (allwishListGroup != null) {
            WishListGroup wg = WishListGroup.createGroup(title, id);
            allwishListGroup.add(wg);
            return wg;
        }
        return null;
    }

    public static void addProductToWishList(final int wid, final int pid, final DataQueryHandler dataQueryHandler) {
        Map<String, String> params = new HashMap<>();
        params.put("type", "add-item");
        params.put("emailid", AppUser.getEmail());
        params.put("user_id", String.valueOf(AppUser.getUserId()));
        params.put("wid", String.valueOf(wid));
        params.put("pid", String.valueOf(pid));

        DataEngine.getDataEngine().addOrRemoveMultipleWishListProductAsync(params, new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {

                try {
                    JSONObject jsonobj = DataHelper.safeJsonObject(data.toString());
                    if (jsonobj.getString("status").compareTo("success") == 0)
                        dataQueryHandler.onSuccess(data);
                    else
                        dataQueryHandler.onFailure(new Exception("Failed"));

                } catch (JSONException e) {
                    e.printStackTrace();
                    dataQueryHandler.onFailure(e);
                }
            }

            @Override
            public void onFailure(Exception error) {
                dataQueryHandler.onFailure(error);
            }
        });
    }

    public static void addProductsToMultipleWishList(final String str, final DataQueryHandler dataQueryHandler) {
        Map<String, String> params = new HashMap<>();
        params.put("type", "multiple-wishlists-items");
        params.put("wish_data_items", str);
        params.put("emailid", AppUser.getEmail());
        params.put("user_id", String.valueOf(AppUser.getUserId()));

        DataEngine.getDataEngine().addOrRemoveMultipleWishListProductAsync(params, new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {
                try {
                    JSONObject jsonobj = DataHelper.safeJsonObject(data.toString());
                    if (jsonobj.getString("status").compareTo("success") == 0)
                        dataQueryHandler.onSuccess(data);
                    else
                        dataQueryHandler.onFailure(new Exception("Failed"));

                } catch (JSONException e) {
                    e.printStackTrace();
                    dataQueryHandler.onFailure(e);
                }
            }

            @Override
            public void onFailure(Exception error) {
                dataQueryHandler.onFailure(error);
            }
        });
    }

    public static void deleteMultipleProductFromWishlist(final int wid, final String str, final DataQueryHandler dataQueryHandler) {

        Map<String, String> params = new HashMap<>();
        params.put("type", "delete-item-list");
        params.put("wish_data_items", str);
        params.put("emailid", AppUser.getEmail());
        params.put("user_id", String.valueOf(AppUser.getUserId()));

        DataEngine.getDataEngine().addOrRemoveMultipleWishListProductAsync(params, new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {

                try {
                    JSONObject jsonobj = DataHelper.safeJsonObject(data.toString());
                    if (jsonobj.getString("status").compareTo("success") == 0)
                        dataQueryHandler.onSuccess(data);
                    else
                        dataQueryHandler.onFailure(new Exception("Failed"));

                } catch (JSONException e) {
                    e.printStackTrace();
                    dataQueryHandler.onFailure(e);
                }
            }

            @Override
            public void onFailure(Exception error) {
                dataQueryHandler.onFailure(error);
            }
        });
    }

    public static void removeProductFromWishList(final String key, int wid, final DataQueryHandler dataQueryHandler) {
        Map<String, String> params = new HashMap<>();
        params.put("type", "delete-item");
        params.put("emailid", AppUser.getEmail());
        params.put("user_id", String.valueOf(AppUser.getUserId()));
        params.put("wid", String.valueOf(wid));
        params.put("wish_item_key", key);

        DataEngine.getDataEngine().addOrRemoveMultipleWishListProductAsync(params, new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {
                try {
                    JSONObject jsonobj = DataHelper.safeJsonObject(data.toString());
                    if (jsonobj.getString("status").compareTo("success") == 0)
                        dataQueryHandler.onSuccess(data);
                    else
                        dataQueryHandler.onFailure(new Exception("Failed"));

                } catch (JSONException e) {
                    e.printStackTrace();
                    dataQueryHandler.onFailure(e);
                }
            }

            @Override
            public void onFailure(Exception error) {
                dataQueryHandler.onFailure(error);
            }
        });
    }

    public static void getUserWishList(int wid, final DataQueryHandler dataQueryHandler) {
        Map<String, String> params = new HashMap<>();
        params.put("type", "user-wishlist-info");
        params.put("wid", String.valueOf(wid));
        params.put("emailid", AppUser.getEmail());
        params.put("user_id", String.valueOf(AppUser.getUserId()));

        DataEngine.getDataEngine().addOrRemoveMultipleWishListProductAsync(params, new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {
                MainActivity.mActivity.hideProgress();
                try {
                    JSONObject jsonobj = DataHelper.safeJsonObject(data.toString());
                    dataQueryHandler.onSuccess(jsonobj.toString());
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onFailure(Exception error) {
                dataQueryHandler.onFailure(error);
            }
        });
    }

    public static void getWishListInfo(int wid, final DataQueryHandler dataQueryHandler) {
        Map<String, String> params = new HashMap<>();
        params.put("type", "wishlist-info");
        params.put("wid", String.valueOf(wid));
        params.put("emailid", AppUser.getEmail());
        params.put("user_id", String.valueOf(AppUser.getUserId()));

        DataEngine.getDataEngine().addOrRemoveMultipleWishListProductAsync(params, new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {
                MainActivity.mActivity.hideProgress();
                try {
                    JSONObject jsonobj = DataHelper.safeJsonObject(data.toString());
                    dataQueryHandler.onSuccess(jsonobj.toString());

                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onFailure(Exception error) {
                dataQueryHandler.onFailure(error);
            }
        });
    }

    public static void syncAndRefreshWishListToServer(boolean sync, final DataQueryHandler handler) {
        if (!sync) {
            if (handler != null)
                handler.onSuccess(null);
            return;
        }

        allwishListGroup.clear();
        Wishlist.allWishlistItems.clear();

        Map<String, String> params = new HashMap<>();
        params.put("type", "user-wishlist-info");
        params.put("emailid", AppUser.getEmail());
        params.put("user_id", String.valueOf(AppUser.getUserId()));

        DataEngine.getDataEngine().addOrRemoveMultipleWishListProductAsync(params, new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {
                try {
                    JSONArray jsonArray = DataHelper.safeJsonArray(data.toString());
                    for (int i = 0; i < jsonArray.length(); i++) {
                        JSONObject jsonObject;
                        try {
                            jsonObject = jsonArray.getJSONObject(i);
                            int id = jsonObject.getInt("id");
                            String title = jsonObject.getString("title");
                            String url = jsonObject.getString("url");
                            final WishListGroup group = new WishListGroup(title, id);
                            group.url = url;
                            WishListGroup.allwishListGroup.add(group);
                            final JSONArray array = jsonObject.getJSONArray("items");
                            String jsonString = array.toString();
                            try {
                                List<TM_ProductInfo> list = parseJsonAndGetInitialProducts(jsonString);
                                for (TM_ProductInfo product : list) {
                                    if (product != null) {
                                        Wishlist.addProduct(product, group);
                                    }
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            }

                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                    }

                } catch (JSONException e) {
                    e.printStackTrace();
                }

                if (handler != null)
                    handler.onSuccess(null);
            }

            @Override
            public void onFailure(Exception error) {
                if (handler != null)
                    handler.onFailure(null);
            }
        });
    }

    public static void syncGuestWishListToServer(boolean sync, final DataQueryHandler dataQueryHandler) {
        List<WishListGroup> list = new Select().from(WishListGroup.class).execute();
        if (list == null || list.size() == 0 || !sync) {
            dataQueryHandler.onSuccess(null);
            return;
        }

        int wishGroupId;
        String title;
        JSONArray array = new JSONArray();
        for (final WishListGroup wishListGroup : list) {
            JSONObject object = new JSONObject();
            JSONObject innerobj = new JSONObject();
            wishGroupId = wishListGroup.id;
            title = wishListGroup.title;
            try {
                innerobj.put("wishlist_title", title);
                object.put("wish_info", innerobj);

                object.put("pids", getAllProductFromWishGroup(wishGroupId));

            } catch (JSONException e) {
                e.printStackTrace();
            }
            array.put(object);
        }

        Map<String, String> params = new HashMap<>();
        params.put("type", "create-list-add-items");
        params.put("wish_data", array.toString());
        params.put("emailid", AppUser.getEmail());
        params.put("user_id", String.valueOf(AppUser.getUserId()));

        DataEngine.getDataEngine().addOrRemoveMultipleWishListProductAsync(params, new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {
                MainActivity.mActivity.hideProgress();
                JSONArray jsonArray;
                try {
                    jsonArray = DataHelper.safeJsonArray(data.toString());
                    if (jsonArray.length() != 0) {
                        clearAllfromDB();
                        dataQueryHandler.onSuccess("");
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                    dataQueryHandler.onSuccess("");
                }
            }

            @Override
            public void onFailure(Exception error) {
                dataQueryHandler.onFailure(error);
            }
        });
    }

    public static String getPidsArrayString(List<WishListGroup> allwishListGroup, List<TM_ProductInfo> allProdList) {
        JSONArray wishlist = new JSONArray();
        for (WishListGroup wishGroup : allwishListGroup) {
            try {
                if (wishGroup.isChecked) {

                    JSONObject innerobj = new JSONObject();
                    JSONArray jsonpids = new JSONArray();
                    innerobj.put("wid", wishGroup.id);
                    for (TM_ProductInfo product : allProdList) {
                        if (!WishListGroup.hasChild(wishGroup.id, product)) {
                            jsonpids.put(product.id);
                        }
                    }
                    wishGroup.isChecked = false;
                    innerobj.put("pids", jsonpids);
                    wishlist.put(innerobj);
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        return wishlist.toString();
    }

    public static String getProductWishKeyArrayString(List<WishListGroup> allwishListGroup, List<TM_ProductInfo> allProdList) {
        JSONArray wishlist = new JSONArray();
        for (WishListGroup wishGroup : allwishListGroup) {
            try {
                if (wishGroup.isChecked) {
                    JSONObject innerobj = new JSONObject();
                    JSONArray jsonpids = new JSONArray();
                    innerobj.put("wid", wishGroup.id);
                    for (TM_ProductInfo product : allProdList) {
                        if (WishListGroup.hasChild(wishGroup.id, product)) {
                            jsonpids.put(product.wishlist_key);
                        }
                    }
                    wishGroup.isChecked = false;
                    innerobj.put("wkeys", jsonpids);
                    wishlist.put(innerobj);
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        return wishlist.toString();
    }

    private static JSONArray getAllProductFromWishGroup(int id) {
        JSONArray jsonpids = new JSONArray();
        for (Wishlist wishlist : Wishlist.getAll()) {

            if (wishlist.parent_id == id) {
                jsonpids.put(wishlist.product.id);
            }
        }
        return jsonpids;
    }

    public static int getWishListIdFromProductKey(String key) {
        for (Wishlist wishlist : Wishlist.getAll()) {

            if (wishlist.product.wishlist_key.compareTo(key) == 0) {
                return wishlist.parent_id;
            }
        }
        return -1;
    }

    private static void clearAllfromDB() {
        List<WishListGroup> allwish = new Select().from(WishListGroup.class).execute();
        for (WishListGroup wishListGroup : allwish) {
            wishListGroup.delete();
        }
    }

    public static void removeAllChildFromGroup(WishListGroup obj) {
        List<Wishlist> removeList = new ArrayList<>();
        for (Wishlist wishObj : Wishlist.allWishlistItems) {
            if (wishObj.parent_id == obj.id) {
                removeList.add(wishObj);
            }
        }
        Wishlist.removeAllOfflineSafely(removeList);
    }

    public static void remove(final Activity activity, final WishListGroup wishObj) {
        try {
            if (wishObj != null) {
                removeAllChildFromGroup(wishObj);
                allwishListGroup.remove(wishObj);
                wishObj.delete();
            }
        } catch (Exception e) {
            Helper.toast((L.string.generic_error));
        }
    }

    public static WishListGroup getDefaultItem() {
        WishListGroup obj = null;
        for (WishListGroup groupobj : allwishListGroup) {
            if (groupobj.id == getdefaultWishGroupID()) {
                obj = groupobj;
            }
        }
        if (obj == null && allwishListGroup.size() > 0)
            obj = allwishListGroup.get(0);

        return obj;
    }

    public static boolean isExists(int id) {
        for (WishListGroup obj : allwishListGroup) {
            if (obj.id == id) {
                return true;
            }
        }
        return false;
    }

    public static boolean hasChild(int parentid, TM_ProductInfo product) {
        for (Wishlist wishlist : Wishlist.allWishlistItems) {
            if (wishlist.parent_id == parentid && wishlist.product != null && wishlist.product.id == product.id) {
                return true;
            }
        }
        return false;
    }

    public static void setdefaultWishGroupID(int wid) {
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(MainActivity.mActivity);
        sp.edit().putInt("defaultWishGroupID", wid).apply();
    }

    public static int getdefaultWishGroupID() {
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(MainActivity.mActivity);
        return sp.getInt("defaultWishGroupID", -1);
    }

    public static int getdefaultWishGroupID(List<WishListGroup> data) {
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(MainActivity.mActivity);
        int mdefaultWishGroupID = sp.getInt("defaultWishGroupID", -1);
        if (!WishListGroup.isExists(mdefaultWishGroupID) && data != null && data.size() > 0) {
            mdefaultWishGroupID = data.get(0).id;
        }
        return mdefaultWishGroupID;
    }

    public static void clearAll() {
        if (WishListGroup.allwishListGroup != null && Wishlist.allWishlistItems != null) {
            WishListGroup.allwishListGroup.clear();
            Wishlist.allWishlistItems.clear();
        }
    }

    public static List<TM_ProductInfo> parseJsonAndGetInitialProducts(String jsonStringContent) throws Exception {
        List<TM_ProductInfo> list = new ArrayList<>();
        JSONArray jMainObject = DataHelper.safeJsonArray(jsonStringContent);
        for (int j = 0; j < jMainObject.length(); j++) {
            TM_ProductInfo productInfo = WooCommerceJSONHelper.parseHomepageProduct(jMainObject.getJSONObject(j));
            String wish_item_key = jMainObject.getJSONObject(j).getString("wish_item_key");
            if (wish_item_key != null && wish_item_key.compareTo("") != 0)
                productInfo.wishlist_key = wish_item_key;
            list.add(productInfo);
        }
        return list;
    }
}
