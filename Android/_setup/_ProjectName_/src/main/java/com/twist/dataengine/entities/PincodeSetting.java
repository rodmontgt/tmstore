package com.twist.dataengine.entities;

import java.util.ArrayList;

/**
 * Created by admin on 08/11/16.
 */

public class PincodeSetting {

    public static class ZipSetting {
        private String pincode;
        private String message;

        public String getPincode() {
            return pincode;
        }

        public void setPincode(String pinCode) {
            this.pincode = pinCode;
        }

        public String getMessage() {
            return message;
        }

        public void setMessage(String message) {
            this.message = message;
        }
    }

    private boolean enableOnProductPage;

    private String zipTitle;

    private String zipButtonText;

    private String zipNotFoundMessage;

    private ArrayList<ZipSetting> zipSettings;

    private boolean fetched = false;

    private static PincodeSetting mPincodeSetting;

    private PincodeSetting() {
    }

    public static PincodeSetting getInstance() {
        if (mPincodeSetting == null) {
            mPincodeSetting = new PincodeSetting();
        }
        return mPincodeSetting;
    }

    public static void destroyInstance() {
        if (mPincodeSetting != null) {
            mPincodeSetting = null;
        }
    }

    public boolean isEnableOnProductPage() {
        return enableOnProductPage;
    }

    public void setEnableOnProductPage(boolean enableOnProductPage) {
        this.enableOnProductPage = enableOnProductPage;
    }

    public String getZipTitle() {
        return zipTitle;
    }

    public void setZipTitle(String zipTitle) {
        this.zipTitle = zipTitle;
    }

    public String getZipButtonText() {
        return zipButtonText;
    }

    public void setZipButtonText(String zipButtonText) {
        this.zipButtonText = zipButtonText;
    }

    public String getZipNotFoundMessage() {
        return zipNotFoundMessage;
    }

    public void setZipNotFoundMessage(String zipNotFoundMessage) {
        this.zipNotFoundMessage = zipNotFoundMessage;
    }

    public void clearZipSettings() {
        if (zipSettings != null) {
            zipSettings.clear();
            zipSettings = null;
        }
    }

    public void addZipSetting(ZipSetting zipSetting) {
        if (zipSettings == null) {
            zipSettings = new ArrayList<>();
        }
        zipSettings.add(zipSetting);
    }

    public ZipSetting getZipSetting(String pincode) {
        if (zipSettings != null && pincode != null && pincode.length() > 0) {
            for (ZipSetting zipSetting : zipSettings) {
                if (zipSetting.getPincode() != null && zipSetting.getPincode().equalsIgnoreCase(pincode)) {
                    return zipSetting;
                }
            }
        }
        return null;
    }

    public boolean isFetched() {
        return fetched;
    }

    public void setFetched(boolean fetched) {
        this.fetched = fetched;
    }
}
