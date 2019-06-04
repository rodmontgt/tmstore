package com.twist.tmstore.entities;

import com.utils.ListUtils;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 9/12/2017.
 */

public class PickupLocation {

    private String country;
    private String cost;
    private int id;
    private String note;
    private String company;
    private String address1;
    private String address2;
    private String city;
    private String state;
    private String postcode;
    private String phone;

    private static List<PickupLocation> pickupLocations;

    private PickupLocation() {
    }

    public static PickupLocation create() {
        if (pickupLocations == null) {
            pickupLocations = new ArrayList<>();
        }
        PickupLocation mPickupLocation = new PickupLocation();
        pickupLocations.add(mPickupLocation);
        return mPickupLocation;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public String getCost() {
        return cost;
    }

    public void setCost(String cost) {
        this.cost = cost;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public String getCompany() {
        return company;
    }

    public void setCompany(String company) {
        this.company = company;
    }

    public String getAddress1() {
        return address1;
    }

    public void setAddress1(String address1) {
        this.address1 = address1;
    }

    public String getAddress2() {
        return address2;
    }

    public void setAddress2(String address2) {
        this.address2 = address2;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public String getPostcode() {
        return postcode;
    }

    public void setPostcode(String postcode) {
        this.postcode = postcode;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public static List<PickupLocation> getAll() {
        return pickupLocations;
    }

    public static void clearAll() {
        if (pickupLocations != null) {
            pickupLocations.clear();
        }
    }

    public static String getFirstPickupLocation() {
        if (!ListUtils.isEmpty(pickupLocations)) {
            return pickupLocations.get(0).getPickupAddressString();
        }
        return "";
    }

    public String getPickupAddressString() {
        StringBuilder str = new StringBuilder();
        str.append(this.getAddress1()).append(", ")
                .append(this.getAddress2()).append(", ")
                .append(this.getCity()).append(", ")
                .append(this.getState()).append(", ")
                .append(this.getCountry()).append(", ")
                .append(this.getPostcode());
        return str.toString();
    }
}