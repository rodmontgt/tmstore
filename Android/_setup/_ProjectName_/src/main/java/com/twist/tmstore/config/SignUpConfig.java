package com.twist.tmstore.config;

import com.utils.JsonHelper;

import org.json.JSONObject;

/**
 * Created by Twist Mobile on 12/4/2017.
 */

public class SignUpConfig {

    public static final String SIGNUP_LAYOUT_EMAIL = "email";
    public static final String SIGNUP_LAYOUT_PASSWORD = "password";
    public static final String SIGNUP_LAYOUT_CONFIRM_PASSWORD = "confirm_password";

    public static final String SIGNUP_LAYOUT_FIRST_NAME = "first_name";
    public static final String SIGNUP_LAYOUT_LAST_NAME = "last_name";
    public static final String SIGNUP_LAYOUT_SHOP_NAME = "shop_name";
    public static final String SIGNUP_LAYOUT_CONTACT_NUMBER = "contact_number";

    public static final String SIGNUP_LAYOUT_MOBILE_NUMBER = "mobile_number";

    public static final String SIGNUP_LAYOUT_MCI_REGISTRATION_NUMBER = "mci_registration_number";
    public static final String SIGNUP_LAYOUT_MCI_YEAR_REGISTRATION = "mci_year_registration";
    public static final String SIGNUP_LAYOUT_QUALIFICATION = "qualification";

    private static SignUpConfig mSignUpConfig;
    private boolean enabled = true;

    private String[] layout_fields = new String[]{SIGNUP_LAYOUT_EMAIL, SIGNUP_LAYOUT_PASSWORD, SIGNUP_LAYOUT_CONFIRM_PASSWORD, SIGNUP_LAYOUT_FIRST_NAME, SIGNUP_LAYOUT_LAST_NAME, SIGNUP_LAYOUT_SHOP_NAME, SIGNUP_LAYOUT_CONTACT_NUMBER};

    public static boolean isEnabled() {
        return mSignUpConfig != null && mSignUpConfig.enabled;
    }

    public static String[] getLayoutFields() {
        if (mSignUpConfig == null) {
			// MultiVendorConfig must be  parsed befor SignUp Config
            if(MultiVendorConfig.isEnabled()) {
                return new String[]{SIGNUP_LAYOUT_EMAIL, SIGNUP_LAYOUT_PASSWORD, SIGNUP_LAYOUT_CONFIRM_PASSWORD, SIGNUP_LAYOUT_FIRST_NAME, SIGNUP_LAYOUT_LAST_NAME, SIGNUP_LAYOUT_SHOP_NAME, SIGNUP_LAYOUT_CONTACT_NUMBER};
            }
            return new String[]{ SIGNUP_LAYOUT_EMAIL, SIGNUP_LAYOUT_PASSWORD, SIGNUP_LAYOUT_CONFIRM_PASSWORD};
        }
        return mSignUpConfig.layout_fields;
    }

    private SignUpConfig() {
    }

    public static void createConfig(JSONObject mainJsonObject) {
        if (mainJsonObject.has("sign_up_config")) {
            try {
                JSONObject jsonObject = mainJsonObject.getJSONObject("sign_up_config");
                SignUpConfig signUpConfig = new SignUpConfig();
                signUpConfig.enabled = JsonHelper.getBool(jsonObject, "enabled", signUpConfig.enabled);
                if (jsonObject.has("layout_fields")) {
                    signUpConfig.layout_fields = JsonHelper.getStringArray(jsonObject, "layout_fields");
                }
                mSignUpConfig = signUpConfig;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
