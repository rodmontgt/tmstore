package com.twist.tmstore.entities;

import com.activeandroid.Model;
import com.activeandroid.annotation.Column;
import com.activeandroid.annotation.Table;
import com.activeandroid.query.Delete;
import com.activeandroid.query.Select;
import com.utils.AnalyticsHelper;
import com.utils.Helper;
import com.utils.Log;

import org.json.JSONException;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

@Table(name = "AppUser")
public class AppUser extends Model implements Serializable {

    public enum USER_TYPE {
        ANONYMOUS_USER,
        WORDPRESS_USER,
        FACEBOOK_USER,
        GOOGLE_USER,
        TWITTER_USER
    }

    @Column(name = "user_id")
    private int user_id = -1;

    @Column(name = "email")
    public String email = "";

    @Column(name = "username")
    public String username = "";

    @Column(name = "password")
    public String password = "";

    public String created_at = ""; //": "2015-01-05T18:34:19Z",

    @Column(name = "first_name")
    public String first_name = "";

    @Column(name = "last_name")
    public String last_name = "";

    @Column(name = "gender")
    public String gender = "";

    @Column(name = "role")
    private String role = "";

    public int orders_count;

    public double total_spent;

    @Column(name = "avatar_url")
    public String avatar_url = "";

    @Column(name = "user_type")
    public USER_TYPE user_type = USER_TYPE.ANONYMOUS_USER;

    @Column(name = "billing_address")
    public Address billing_address;

    @Column(name = "shipping_address")
    public Address shipping_address;

    @Column(name = "address_json")
    private String address_json = "";

    public List<Address> addressList = new ArrayList<>();

    private String jsonData;

    public String mylocation = "";

    private RolePrice mRolePrice;


    private static AppUser mAppUser = null;

    public static AppUser getInstance() {
        if (mAppUser == null) {
            mAppUser = new Select().from(AppUser.class).executeSingle();
            if (mAppUser == null) {
                mAppUser = new AppUser();
            }
        }
        return mAppUser;
    }

    public void addAddress(Address address) throws JSONException {
        if (addressList == null) {
            addressList = new ArrayList<>();
        }
        addressList.add(address);
        this.save();
    }

    public static int getUserId() {
        return AppUser.getInstance().user_id;
    }

    public static void setUserId(int userId) {
        AppUser.getInstance().user_id = userId;
    }

    public static boolean hasSignedIn() {
        return AppUser.getUserId() != -1 && !AppUser.getEmail().equals("");
    }

    public static boolean isVendor() {
        RoleType roleType = AppUser.getRoleType();
        return AppUser.hasSignedIn()
                && (roleType == RoleType.VENDOR
                || roleType == RoleType.VENDOR_YITH
                || roleType == RoleType.VENDOR_DC
                || roleType == RoleType.SELLER
                || roleType == RoleType.ADMINISTRATOR);
    }

    public static boolean isPendingVendor() {
        return AppUser.hasSignedIn() && (AppUser.getRoleType() == RoleType.PENDING_VENDOR || AppUser.getRoleType() == RoleType.PENDING_VENDOR_DC);
    }

    public static RoleType getRoleType() {
        return RoleType.from(AppUser.getInstance().role);
    }

    public static String getEmail() {
        return AppUser.getInstance().email;
    }

    public static void reload() {
        AppUser temp = new Select().from(AppUser.class).executeSingle();
        if (temp != null) {
            mAppUser.user_id = temp.user_id;
            mAppUser.email = temp.email;
            mAppUser.username = temp.username;
            mAppUser.password = temp.password;
        } else {
            mAppUser.user_id = -1;
            mAppUser.email = "";
            mAppUser.username = "";
            mAppUser.password = "";
        }
    }

    public String getDisplayName() {
        String displayName = "";
        if (!first_name.equals("")) {
            displayName += first_name;
            if (!last_name.equals("")) {
                displayName += " " + last_name;
            }
        } else {
            displayName = username;
        }
        return displayName;
    }

    public boolean isProfileComplete() {
        return Helper.isValidString(email) &&
                Helper.isValidString(first_name) &&
                billing_address != null &&
                billing_address.hasBillingData();
    }

    public boolean hasBasicDetails() {
        return !(first_name.equals("") && last_name.equals(""));
    }

    public void sync() {
        if (CustomerData.getInstance() != null) {
            CustomerData.getInstance().setFirstName(first_name);
            CustomerData.getInstance().setLastName(last_name);
            CustomerData.getInstance().setUsername(username);
            CustomerData.getInstance().setEmailID(email);
            CustomerData.getInstance().setPassword(password);
        }
    }

    public void saveAll() {
        try {
            if (this.billing_address != null) {
                this.billing_address.save();
            }
            if (this.shipping_address != null) {
                this.shipping_address.save();
            }
            this.save();
            CustomerData.getInstance().saveInBackground();
            AnalyticsHelper.registerCustomerUpdateEvent();
            Log.d("AppUser", this.toString());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void deleteInstance() {
        if (mAppUser != null) {
            mAppUser.delete();
            new Delete().from(AppUser.class).execute();
            mAppUser = null;
            Helper.gc();
        }
    }

    public static boolean isAnonymous() {
        return getInstance().user_type == USER_TYPE.ANONYMOUS_USER;
    }

    public USER_TYPE getUserType() {
        return user_type;
    }

    public boolean isWordPressUser() {
        return AppUser.getInstance().getUserType() == AppUser.USER_TYPE.WORDPRESS_USER;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getAddressJson() {
        return address_json;
    }

    public void setAddressJson(String address_json) {
        this.address_json = address_json;
    }

    public String getJsonData() {
        return jsonData;
    }

    public void setJsonData(String jsonData) {
        this.jsonData = jsonData;
    }

    public static Address getBillingAddress() {
        return AppUser.hasSignedIn() ? AppUser.getInstance().billing_address : AppInfo.dummyUser.billing_address;
    }

    public static Address getShippingAddress() {
        return AppUser.hasSignedIn() ? AppUser.getInstance().shipping_address : AppInfo.dummyUser.shipping_address;
    }

    public RolePrice getRolePrice() {
        return mRolePrice;
    }

    public void setRolePrice(RolePrice rolePrice) {
        this.mRolePrice = rolePrice;
    }

    public static DummyUser createDummyUser(String mobileNumber) {
        DummyUser dummyUser = null;
        AppUser appUser = AppUser.getInstance();
        if (appUser != null) {
            dummyUser = new DummyUser();
            dummyUser.first_name = appUser.first_name;
            dummyUser.last_name = appUser.last_name;
            dummyUser.email = appUser.email;
            dummyUser.password = appUser.password;
            dummyUser.username = appUser.first_name + " " + appUser.last_name;
            dummyUser.avatar_url = appUser.avatar_url;
            dummyUser.billing_address = appUser.billing_address;
            dummyUser.billing_address.phone = mobileNumber;
            dummyUser.shipping_address = appUser.shipping_address;
            dummyUser.shipping_address.phone = mobileNumber;
        }
        return dummyUser;
    }
}
