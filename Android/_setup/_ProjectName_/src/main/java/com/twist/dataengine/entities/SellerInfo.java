package com.twist.dataengine.entities;

import com.bignerdranch.expandablerecyclerview.Model.ParentListItem;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 8/5/2016.
 */

public class SellerInfo {
    public static List<String> allSellerLocations = new ArrayList<>();
    private static SellerInfo selectedSeller = null;
    private static SellerInfo currentSeller = null;
    private static List<SellerInfo> allSellers = new ArrayList<>();

    private String id;
    private String title;
    private String email;
    private String[] locations;
    private String imageUrl;
    private String shopName;
    private String shopUrl;
    private String shopImageUrl;
    private String phoneNumber;
    private String vendorLastName;
    private boolean isVerified;
    private String bannerUrl;
    private String iconUrl;
    private String avatarUrl;
    private double latitude;
    private double longitude;
    private String shopAddress;
    public String subscription_id;
    public String level_id;
    public String subscription_name;
    public String subscription_url;
    public String expiration_number;
    public String expiration_period;
    public String allow_signups;
    public String initial_payment;
    public String billing_amount;
    public String trial_amount;
    public String trial_limit;
    public String startdate;
    public String enddate;
    public String membership_status;

    public SellerInfo() {
    }

    public static SellerInfo getCurrentSeller() {
        return currentSeller;
    }

    public static void setCurrentSeller(SellerInfo currentSeller) {
        SellerInfo.currentSeller = currentSeller;
    }

    public static SellerInfo getSellerInfo(String sellerId) {
        for (SellerInfo seller : allSellers) {
            if (seller.id.equals(sellerId))
                return seller;
        }
        return null;
    }

    public static List<SellerInfo> getAllSellers() {
        return new ArrayList<>(allSellers);
    }

    public static SellerInfo getSelectedSeller() {
        return selectedSeller;
    }

    public static void setSelectedSeller(SellerInfo selectedSeller) {
        SellerInfo.selectedSeller = selectedSeller;
    }

    private static void updateLocations(String[] newLocations) {
        if (newLocations != null) {
            for (String newLocation : newLocations) {
                if (!allSellerLocations.contains(newLocation)) {
                    allSellerLocations.add(newLocation);
                }
            }
        }
    }

    public static List<ExpandableSeller> getAllExpandableSellers() {
        List<ExpandableSeller> expandableSellers = new ArrayList<>();
        for (String location : allSellerLocations) {
            List<SellerInfo> sellersWithConstrain = getAllSellersWithLocation(location);
            if (!sellersWithConstrain.isEmpty()) {
                ExpandableSeller expandableSeller = new ExpandableSeller(location);
                expandableSeller.addSellers(sellersWithConstrain);
                expandableSellers.add(expandableSeller);
            }
        }
        return expandableSellers;
    }

    public static List<ExpandableSeller> getAllExpandableSellers(String[] keyWords) {
        List<ExpandableSeller> expandableSellers = new ArrayList<>();
        for (String location : allSellerLocations) {
            if (hasAnyKeyWord(location, keyWords)) {
                List<SellerInfo> sellersWithConstrain = getAllSellersWithLocation(location);
                if (!sellersWithConstrain.isEmpty()) {
                    ExpandableSeller expandableSeller = new ExpandableSeller(location);
                    expandableSeller.addSellers(sellersWithConstrain);
                    expandableSellers.add(expandableSeller);
                }
            } else {
                List<SellerInfo> sellersWithConstrain = getAllSellersWithLocationAndKeyWords(location, keyWords);
                if (!sellersWithConstrain.isEmpty()) {
                    ExpandableSeller expandableSeller = new ExpandableSeller(location);
                    expandableSeller.addSellers(sellersWithConstrain);
                    expandableSellers.add(expandableSeller);
                }
            }
        }
        return expandableSellers;
    }

    public static boolean hasAnyKeyWord(String src, String[] tags) {
        for (String tag : tags) {
            if (src.toLowerCase().contains(tag.toLowerCase()))
                return true;
        }
        return false;
    }

    public static List<SellerInfo> getAllSellersWithLocation(String location1) {
        List<SellerInfo> sellersWithLocation = new ArrayList<>();
        for (SellerInfo seller : allSellers) {
            if (seller.locations != null) {
                for (String location2 : seller.locations) {
                    if (location2.equals(location1)) {
                        sellersWithLocation.add(seller);
                        break;
                    }
                }
            }
        }
        return sellersWithLocation;
    }

    public static SellerInfo findSellerById(int sellerId) {
        return SellerInfo.findSellerById(String.valueOf(sellerId));
    }

    public static SellerInfo findSellerById(String sellerId) {
        if (allSellers != null) {
            for (SellerInfo seller : allSellers) {
                if (seller.id.equals(sellerId)) {
                    return seller;
                }
            }
        }
        return null;
    }

    public static List<SellerInfo> getAllSellersWithLocationAndKeyWords(String location1, String[] keyWords) {
        List<SellerInfo> sellersWithLocation = new ArrayList<>();
        for (SellerInfo seller : allSellers) {
            if (seller.locations != null) {
                for (String location2 : seller.locations) {
                    if (location2.equals(location1) && seller.hasAnyKeyWord(keyWords)) {
                        sellersWithLocation.add(seller);
                        break;
                    }
                }
            }
        }
        return sellersWithLocation;
    }

    public String getBannerUrl() {
        return bannerUrl;
    }

    public void setBannerUrl(String bannerUrl) {
        this.bannerUrl = bannerUrl;
    }

    public String getIconUrl() {
        return iconUrl;
    }

    public void setIconUrl(String iconUrl) {
        this.iconUrl = iconUrl;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    public boolean isVerified() {
        return isVerified;
    }

    public void setVerified(boolean verified) {
        isVerified = verified;
    }

    public String getVendorLastName() {
        return vendorLastName;
    }

    public void setVendorLastName(String vendorLastName) {
        this.vendorLastName = vendorLastName;
    }

    public String getShopAddress() {
        return shopAddress;
    }

    public void setShopAddress(String shopAddress) {
        this.shopAddress = shopAddress;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getSellerFirstLocation() {
        if (locations != null && locations.length > 0)
            return locations[0];
        return "";
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getShopName() {
        return shopName;
    }

    public void setShopName(String shopName) {
        this.shopName = shopName;
    }

    public String getShopUrl() {
        return shopUrl;
    }

    public void setShopUrl(String shopUrl) {
        this.shopUrl = shopUrl;
    }

    public String getShopImageUrl() {
        return shopImageUrl;
    }

    public void setShopImageUrl(String shopImageUrl) {
        this.shopImageUrl = shopImageUrl;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String[] getLocations() {
        return locations;
    }

    public void setLocations(String[] locations) {
        this.locations = locations;
    }

    public boolean hasAnyKeyWord(String[] keywords) {
        for (String keyword : keywords) {
            if (hasKeyWord(keyword)) {
                return true;
            }
        }
        return false;
    }

    @Override
    public String toString() {
        return this.getTitle();
    }

    public boolean hasKeyWord(String tag) {
        return this.title.toLowerCase().contains(tag.toLowerCase());
    }

    public void commit() {
        if (!hasSeller(this)) {
            allSellers.add(this);
            updateLocations(this.locations);
        }
    }

    public boolean hasSeller(SellerInfo seller2) {
        for (SellerInfo seller1 : allSellers) {
            if (seller1.id.equals(seller2.id))
                return true;
        }
        return false;
    }

    public boolean equals(SellerInfo another) {
        return this.id.equals(another.id);
    }

    public static class ExpandableSeller implements ParentListItem {
        String title;
        List<SellerInfo> sellers;

        public ExpandableSeller(String string) {
            title = string;
            sellers = new ArrayList<>();
        }

        public String getTitle() {
            return title;
        }

        public void addSeller(SellerInfo seller) {
            sellers.add(seller);
        }

        public void addSellers(List<SellerInfo> newSellers) {
            sellers.addAll(newSellers);
        }

        @Override
        public List<?> getChildItemList() {
            return sellers;
        }

        @Override
        public boolean isInitiallyExpanded() {
            return false;
        }

        @Override
        public String toString() {
            return title;
        }

        public boolean hasAnyKeyWord(String[] keywords) {
            for (String keyword : keywords) {
                if (title.toLowerCase().contains(keyword.toLowerCase())) {
                    return true;
                }
            }
            return false;
        }

        public boolean hasKeyWord(String tag) {
            return this.title.toLowerCase().contains(tag.toLowerCase());
        }
    }
}
