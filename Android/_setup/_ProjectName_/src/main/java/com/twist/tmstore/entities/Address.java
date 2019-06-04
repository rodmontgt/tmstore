package com.twist.tmstore.entities;

import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;

import com.activeandroid.ActiveAndroid;
import com.activeandroid.Model;
import com.activeandroid.annotation.Column;
import com.activeandroid.annotation.Table;
import com.activeandroid.query.Select;
import com.utils.Helper;
import com.utils.Log;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

@Table(name = "Address")
public class Address extends Model implements Serializable {
    @Column(name = "first_name")
    public String first_name = "";    // "John",

    @Column(name = "last_name")
    public String last_name = "";    // Doe",

    @Column(name = "company")
    public String company = "";    // "",

    @Column(name = "address_1")
    public String address_1 = "";    // : "969 Market",

    @Column(name = "address_2")
    public String address_2 = "";    // : "",

    @Column(name = "city")
    public String city = "";    // ": "San Francisco",

    @Column(name = "state")
    public String state = "";    // ": "CA",

    @Column(name = "stateCode")
    public String stateCode = "";    // ": "CA",

    @Column(name = "postcode")
    public String postcode = "";    // ": "94103",

    @Column(name = "country")
    public String country = "";    // ": "US",

    @Column(name = "countryCode")
    public String countryCode = "";    // ": "US",

    @Column(name = "email")
    public String email = "";    // ": "john.doe@example.com",

    @Column(name = "phone")
    public String phone = "";    // ": "(555) 555-5555"

    @Column(name = "title")
    public String title = "";    // ": "Billing Address"

    @Column(name = "region")
    public String region = ""; //destination address

    @Column(name = "latitude")
    public String latitude = "";

    @Column(name = "longitude")
    public String longitude = "";

    @Column(name = "last_modified_timestamp")
    public String lastModifiedTimeStamp = "";


    public Address() {
        super();
        if (!Helper.isValidEmail(this.region)) {
            if (Helper.isValidString(stateCode)) {

            } else if (Helper.isValidString(countryCode)) {

            }
        }
    }

    public Address(String title) {
        super();
        this.title = title;
    }

    public static Address getLastModifiedAddress() {
        List<Address> addressList = new Select().all().from(Address.class)
                .orderBy("last_modified_timestamp DESC").execute();
        if (addressList != null && !addressList.isEmpty()) {
            return addressList.get(0);
        }
        return null;
    }

    public static List<Address> getAddress1ByAddress2FromDB(String address_2, String postcode) {
        List<Address> addressList = new ArrayList<>();
        // Select All Query
        String selectQuery = "SELECT address_1 FROM Address WHERE  address_2 = '" + address_2 + "' and postcode = '" + postcode + "'";

        SQLiteDatabase db = ActiveAndroid.getDatabase();
        Cursor cursor = db.rawQuery(selectQuery, null);
        // looping through all rows and adding to list
        if (cursor.moveToFirst()) {
            do {
                Address address = new Address();
                address.address_1 = cursor.getString(0);
                // Adding contact to list
                addressList.add(address);
            } while (cursor.moveToNext());
        }
        return addressList;
    }


    public String getAddressLine() {
        return getAddressLine("\n");
    }

    public String getAddressLine(String saperator) {
        String str_address = "";
        if (!company.equals(""))
            str_address += company + saperator;
        if (!address_1.equals(""))
            str_address += address_1 + saperator;
        if (!address_2.equals(""))
            str_address += address_2 + saperator;
        if (!city.equals(""))
            str_address += city + " - ";
        if (!state.equals(""))
            str_address += state + saperator;
        if (!postcode.equals(""))
            str_address += postcode + " - ";
        if (!country.equals(""))
            str_address += country + saperator;
        if (!email.equals(""))
            str_address += email + saperator;
        if (!phone.equals(""))
            str_address += phone;
        return str_address;
    }

    public void copyFrom(Address other) {
        this.title = other.title;
        this.first_name = other.first_name;
        this.last_name = other.last_name;
        this.company = other.company;
        this.address_1 = other.address_1;
        this.address_2 = other.address_2;
        this.city = other.city;
        this.state = other.state;
        this.stateCode = other.stateCode;
        this.postcode = other.postcode;
        this.country = other.country;
        this.countryCode = other.countryCode;
        this.email = other.email;
        this.phone = other.phone;
        this.region = other.region;
    }

    public boolean hasData() {
        return Helper.isValidString(this.first_name) &&
                Helper.isValidString(this.last_name) &&
                Helper.isValidString(this.address_1) &&
                Helper.isValidString(this.region) &&
                Helper.isValidString(this.city);
    }

    public boolean hasBillingData() {
        if (!isExcluded("billing_first_name") && !isOptional("billing_first_name") && !Helper.isValidString(this.first_name)) {
            Log.d("billing_first_name is missing");
            return false;
        }

        if (!isExcluded("billing_address_1") && !isOptional("billing_address_1") && !Helper.isValidString(this.address_1)) {
            Log.d("billing_address_1 is missing");
            return false;
        }
        if (!isExcluded("billing_address_2") && !isOptional("billing_address_2") && !Helper.isValidString(this.address_2)) {
            Log.d("billing_address_2 is missing");
            return false;
        }
        if (!isExcluded("billing_city") && !isOptional("billing_city") && !Helper.isValidString(this.city)) {
            Log.d("billing_city is missing");
            return false;
        }
        //if ( !isExcluded("billing_state") && !isOptional("billing_first_name") && !Helper.isValidString(this.state)) {
        //    return false;
        //}
        if (!isExcluded("billing_postcode") && !isOptional("billing_postcode") && !Helper.isValidString(this.postcode)) {
            Log.d("billing_postcode is missing");
            return false;
        }
        if (!isExcluded("billing_country") && !isOptional("billing_country") && !Helper.isValidString(this.country)) {
            Log.d("billing_country is missing");
            return false;
        }
        if (!isExcluded("billing_email") && !isOptional("billing_email") && !Helper.isValidString(this.email)) {
            Log.d("billing_country is missing");
            return false;
        }
        if (!isExcluded("billing_phone") && !isOptional("billing_phone") && !Helper.isValidString(this.phone)) {
            Log.d("billing_postcode is missing");
            return false;
        }
        return true;
    }

    public boolean hasShippingData() {
        if (!isExcluded("shipping_first_name") && !isOptional("shipping_first_name") && !Helper.isValidString(this.first_name)) {
            return false;
        }
        if (!isExcluded("shipping_address_1") && !isOptional("shipping_address_1") && !Helper.isValidString(this.address_1)) {
            return false;
        }
        if (!isExcluded("shipping_address_2") && !isOptional("shipping_address_2") && !Helper.isValidString(this.address_2)) {
            return false;
        }
        if (!isExcluded("shipping_city") && !isOptional("shipping_city") && !Helper.isValidString(this.city)) {
            return false;
        }
        //if ( !isExcluded("shipping_state") && !isOptional("billing_first_name") && !Helper.isValidString(this.state)) {
        //    return false;
        //}
        if (!isExcluded("shipping_postcode") && !isOptional("shipping_postcode") && !Helper.isValidString(this.postcode)) {
            return false;
        }
        if (!isExcluded("shipping_country") && !isOptional("shipping_country") && !Helper.isValidString(this.country)) {
            return false;
        }
        return true;
    }

    public boolean isExcluded(String key) {
        if (AppInfo.EXCLUDED_ADDRESSES == null)
            return false;
        for (String excludedKey : AppInfo.EXCLUDED_ADDRESSES) {
            if (excludedKey.equalsIgnoreCase(key))
                return true;
        }
        return false;
    }

    public boolean isOptional(String key) {
        if (AppInfo.OPTIONAL_ADDRESSES == null)
            return false;
        for (String compulsoryKey : AppInfo.OPTIONAL_ADDRESSES) {
            if (compulsoryKey.equalsIgnoreCase(key))
                return true;
        }
        return false;
    }

    @Override
    public String toString() {
        return "Address{" +
                "first_name='" + first_name + '\'' +
                ", last_name='" + last_name + '\'' +
                ", company='" + company + '\'' +
                ", address_1='" + address_1 + '\'' +
                ", address_2='" + address_2 + '\'' +
                ", city='" + city + '\'' +
                ", state='" + state + '\'' +
                ", stateCode='" + stateCode + '\'' +
                ", postcode='" + postcode + '\'' +
                ", country='" + country + '\'' +
                ", countryCode='" + countryCode + '\'' +
                ", email='" + email + '\'' +
                ", phone='" + phone + '\'' +
                ", title='" + title + '\'' +
                ", region='" + region + '\'' +
                ", latitude='" + latitude + '\'' +
                ", longitude='" + longitude + '\'' +
                '}';
    }
}
