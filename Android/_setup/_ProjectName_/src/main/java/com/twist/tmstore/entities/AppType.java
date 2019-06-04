package com.twist.tmstore.entities;

/**
 * Created by Twist Mobile on 11/27/2017.
 */

public class AppType {
    private String mTitle;
    private int mIconId;
    private String mType;

    private String mDescription;

    public AppType(String title, int iconId, String type, String description) {
        this.mTitle = title;
        this.mIconId = iconId;
        this.mType = type;
        this.mDescription = description;

    }

    public String getDescription() {
        return mDescription;
    }

    public void setDescription(String mDescription) {
        this.mDescription = mDescription;
    }

    public String getTitle() {
        return mTitle;
    }

    public void setTitle(String title) {
        this.mTitle = title;
    }

    public int getIconId() {
        return mIconId;
    }

    public void setIconId(int iconId) {
        this.mIconId = iconId;
    }

    public String getType() {
        return mType;
    }

    public void setType(String type) {
        this.mType = type;
    }

}
