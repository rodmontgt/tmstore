package com.twist.tmstore.config;

import com.twist.tmstore.entities.AppInfo;
import com.utils.JsonHelper;
import com.utils.Log;

import org.json.JSONObject;

/**
 * Created by Twist Mobile on 21-Jul-16.
 */

public class ImageDownloaderConfig {

    private boolean showInCategory = false;
    private boolean showInWishList = false;
    private boolean showInCart = false;
    private boolean showInProdDetail = false;

    public boolean isShare() {
        return isShare;
    }

    public void setShare(boolean share) {
        isShare = share;
    }

    private boolean isShare = true;
    private boolean showInHome = false;


    public static boolean isEnabled() {
        return AppInfo.mImageDownloaderConfig != null;
    }

    public boolean isShowInProdDetail() {
        return showInProdDetail;
    }

    public boolean isShowInCart() {
        return showInCart;
    }

    public boolean isShowInCategory() {
        return showInCategory;
    }

    public boolean isShowInHome() {
        return showInHome;
    }

    public boolean isShowInWishList() {
        return showInWishList;
    }

    public static void createConfig(JSONObject jsonObject) {
        resetConfig();
        String key = "img_downloader_config";
        if (jsonObject == null || !jsonObject.has(key)) {
            Log.e("No configuration for " + ImageDownloaderConfig.class.getSimpleName() + " in JSON");
            return;
        }

        try {
            JSONObject configJsonObject = jsonObject.getJSONObject(key);
            ImageDownloaderConfig config = new ImageDownloaderConfig();
            config.showInCategory = JsonHelper.getBool(configJsonObject, "show_in_category", config.showInCategory);
            config.showInWishList = JsonHelper.getBool(configJsonObject, "show_in_wishlist", config.showInWishList);
            config.showInCart = JsonHelper.getBool(configJsonObject, "show_in_cart", config.showInCart);
            config.showInProdDetail = JsonHelper.getBool(configJsonObject, "show_in_prod_detail", config.showInProdDetail);
            config.showInHome = JsonHelper.getBool(configJsonObject, "show_in_home", config.showInHome);
            config.isShare = JsonHelper.getBool(configJsonObject, "share", config.isShare);
            AppInfo.mImageDownloaderConfig = config;
        } catch (Exception e) {
            Log.e("Error while parsing " + ImageDownloaderConfig.class.getSimpleName() + " JSON");
            e.printStackTrace();
        }
    }

    public static void resetConfig() {
        AppInfo.mImageDownloaderConfig = null;
    }
}
