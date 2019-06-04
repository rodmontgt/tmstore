package com.twist.dataengine.entities;

import com.google.gson.Gson;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 8/25/2016.
 */

public class TM_Region {

    public boolean regionsLoaded = false;

    //public boolean isNode = false;
    public String type;
    //public String parentId;
    public String id;
    public String title;
    public String parentId; //new headache
    private List<TM_Region> children = new ArrayList<>();

    private TM_Region(String type, String id, String title, TM_Region parentRegion) {
        this.type = type;
        //this.parentId = parentId;
        this.id = id;
        this.title = title;
        if (parentRegion != null) {
            this.parentId = parentRegion.id;
            //this.isNode = false;
            parentRegion.children.add(this);
        } else {
            //this.isNode = true;
            this.parentId = "";
        }
        regionList.add(this);
    }

    private static List<TM_Region> regionList = new ArrayList<>();

    public static TM_Region getRegion(String type, String id, String title, TM_Region parent) {
        for (TM_Region region : regionList) {
            if (region.type.equals(type) && region.id.equals(id) && (region.parentId == null || parent == null || region.parentId.equals(parent.id))) { // new headache
                return region;
            }
        }
        return new TM_Region(type, id, title, parent);
    }

    public static TM_Region getRegionFromAll(String type, String title) {
        for (TM_Region region : regionList) {
            if (region.type.equals(type) && region.title.equals(title)) {
                return region;
            }
        }
        return new TM_Region(type, title, title, null);
    }

    public static List<TM_Region> getRegions(TM_Region parent) {
        if (parent != null) {
            return parent.children;
        } else {
            List<TM_Region> regions = new ArrayList<>();
            for (TM_Region region : regionList) {
                if (region.parentId == null || region.parentId.length() == 0) {
                    regions.add(region);
                }
            }
            return regions;
        }
    }

    @Override
    public String toString() {
        return this.title;
    }

    @Override
    public boolean equals(Object object) {
        if (object instanceof TM_Region) {
            TM_Region other = (TM_Region) object;
            return (this.type.equals(other.type) && this.id.equals(other.id));
        }
        return super.equals(object);
    }

    public String toJson() {
        return new Gson().toJson(this);
    }

    public static TM_Region fromJson(String jsonString) {
        return new Gson().fromJson(jsonString, TM_Region.class);
    }
}
