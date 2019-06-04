package com.twist.tmstore.entities;

import android.text.TextUtils;

import com.parse.ParseObject;
import com.utils.ArrayUtils;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;

/**
 * Created by Twist Mobile on 8/5/2016.
 */

public class Merchant {

    private String id;
    private String title = "";
    private String description = "";
    private String baseUrl;
    private String imageUrl;
    private String tags[];
    private String categories[];
    private String shipping[];
    private boolean approved;
    private StoreLocation store_location;

    private static ArrayList<Merchant> merchantList = new ArrayList<>();

    public static ArrayList<Merchant> getMerchantList() {
        return merchantList;
    }

    public static void clearAll() {
        merchantList.clear();
    }

    public static boolean addMerchant(Merchant merchant) {
        for (Merchant anotherMerchant : merchantList) {
            if (merchant.id.equals(anotherMerchant.id)) {
                return false;
            }
        }
        merchantList.add(merchant);
        return true;
    }

    public static Merchant findMerchant(String merchantId) {
        for (Merchant merchant : merchantList)
            if (merchant.getId().equals(merchantId))
                return merchant;
        return null;
    }

    public final static class StoreLocation {
        public String getCountry() {
            return country;
        }

        public void setCountry(String country) {
            this.country = country;
        }

        public String getCountryCode() {
            return country_code;
        }

        public void setCountryCode(String county_code) {
            this.country_code = county_code;
        }

        public String getState() {
            return state;
        }

        public void setState(String state) {
            this.state = state;
        }

        public String getCity() {
            return city;
        }

        public void setCity(String city) {
            this.city = city;
        }

        public String getDistrict() {
            return district;
        }

        public void setDistrict(String district) {
            this.district = district;
        }

        String country;
        String country_code;
        String state;
        String city;
        String district;

        @Override
        public String toString() {
            return "StoreLocation{" +
                    "country='" + country + '\'' +
                    ", country_code='" + country_code + '\'' +
                    ", state='" + state + '\'' +
                    ", city='" + city + '\'' +
                    ", district='" + district + '\'' +
                    '}';
        }
    }

    public Merchant() {
    }

    public static Merchant create(ParseObject parseObject) {
        Merchant merchant = new Merchant();
        merchant.id = parseObject.getObjectId();
        merchant.baseUrl = parseObject.getString("baseurl");
        merchant.description = parseObject.getString("desc");
        merchant.imageUrl = parseObject.getString("splash_url");
        merchant.title = parseObject.getString("app_name");
        merchant.approved = parseObject.getBoolean("is_approved");

        final String searchables = parseObject.getString("searchables");
        if (!TextUtils.isEmpty(searchables)) {
            try {
                JSONObject jsonSearchables = new JSONObject(searchables);
                if (jsonSearchables.has("categories")) {
                    JSONArray jsonArray = jsonSearchables.getJSONArray("categories");
                    String[] categories = new String[jsonArray.length()];
                    for (int i = 0; i < jsonArray.length(); i++) {
                        categories[i] = jsonArray.getString(i);
                    }
                    merchant.setCategories(categories);
                }
                if (jsonSearchables.has("shipping")) {
                    JSONArray jsonArray = jsonSearchables.getJSONArray("shipping");
                    String[] shipping = new String[jsonArray.length()];
                    for (int i = 0; i < jsonArray.length(); i++) {
                        shipping[i] = jsonArray.getString(i);
                    }
                    merchant.setShipping(shipping);
                }
                if (jsonSearchables.has("tags")) {
                    JSONArray jsonArray = jsonSearchables.getJSONArray("tags");
                    String[] tags = new String[jsonArray.length()];
                    for (int i = 0; i < jsonArray.length(); i++) {
                        tags[i] = jsonArray.getString(i);
                    }
                    merchant.setTags(tags);
                }
                if (jsonSearchables.has("store_location")) {
                    JSONObject json_store_location = jsonSearchables.getJSONObject("store_location");
                    Merchant.StoreLocation store_location = new Merchant.StoreLocation();
                    if (json_store_location.has("country"))
                        store_location.setCountry(json_store_location.getString("country"));
                    if (json_store_location.has("country_code"))
                        store_location.setCountryCode(json_store_location.getString("country_code"));
                    if (json_store_location.has("state"))
                        store_location.setState(json_store_location.getString("state"));
                    if (json_store_location.has("city"))
                        store_location.setCity(json_store_location.getString("city"));
                    if (json_store_location.has("district"))
                        store_location.setDistrict(json_store_location.getString("district"));
                    merchant.setStoreLocation(store_location);
                }
            } catch (Exception je) {
                je.printStackTrace();
            }
        }
        return merchant;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getBaseUrl() {
        return baseUrl;
    }

    public void setBaseUrl(String baseUrl) {
        this.baseUrl = baseUrl;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String[] getTags() {
        return tags;
    }

    public void setTags(String[] tags) {
        this.tags = tags;
    }

    public String[] getCategories() {
        return categories;
    }

    public String getCategoryString() {
        String categoryString = "";
        if (!ArrayUtils.isEmpty(categories)) {
            for (String category : categories) {
                categoryString += category + ", ";
            }
            if (categoryString.length() > 2) {
                categoryString = categoryString.substring(0, categoryString.length() - 2);
            }
        }
        return categoryString;
    }

    public String getFirstCategory() {
        if (!ArrayUtils.isEmpty(categories)) {
            return categories[1];
        }
        return "";
    }

    public void setCategories(String[] categories) {
        this.categories = categories;
    }

    public String[] getShipping() {
        return shipping;
    }

    public void setShipping(String[] shipping) {
        this.shipping = shipping;
    }

    public boolean isApproved() {
        return approved;
    }

    public void setApproved(boolean approved) {
        this.approved = approved;
    }

    public StoreLocation getStoreLocation() {
        return store_location;
    }

    public void setStoreLocation(StoreLocation store_location) {
        this.store_location = store_location;
    }

    public boolean hasKeyword(String keyWord) {
        if (keyWord == null)
            return false;

        if (keyWord.length() == 0)
            return true;

        keyWord = keyWord.toLowerCase();

        if (this.title != null && this.title.toLowerCase().contains(keyWord))
            return true;

        if (this.description != null && this.description.toLowerCase().contains(keyWord))
            return true;

        if (this.baseUrl != null && this.baseUrl.toLowerCase().contains(keyWord))
            return true;

        if (this.categories != null) {
            for (String category : this.categories) {
                if (category.toLowerCase().contains(keyWord))
                    return true;
            }
        }

        if (this.tags != null) {
            for (String tag : this.tags) {
                if (tag.toLowerCase().contains(keyWord))
                    return true;
            }
        }

        if (this.shipping != null) {
            for (String location : this.shipping) {
                if (location.toLowerCase().contains(keyWord))
                    return true;
            }
        }

        return false;
    }

    public boolean hasAllKeywords(String[] keywords) {
        for (String keyword : keywords) {
            if (!hasKeyword(keyword))
                return false;
        }
        return true;
    }

    public boolean hasAnyKeyword(String[] keywords) {
        for (String keyword : keywords) {
            if (hasKeyword(keyword))
                return true;
        }
        return false;
    }

    public boolean isValid() {
        return approved
                && title != null
                && baseUrl != null
                && imageUrl != null
                && description != null;
    }
}