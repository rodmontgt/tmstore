package com.twist.tmstore.entities;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by Twist Mobile on 01/03/2018.
 */

public class DepositInfo {

    public String deposit_amount;
    public String deposit_type;
    public float full_price;
    public float deposit_price;

    public String checkCartDepositType;
    public float cartDepositAmount;

    public static final String PAY_FULL_DEPOSIT = "pay_full_deposit";
    public static final String PAY_DEPOSIT = "pay_deposit";

    public static DepositInfo create(JSONObject jsonObject) {
        DepositInfo depositInfo = null;
        try {
            Object object = jsonObject.get("deposit_info");
            if (object instanceof JSONObject) {
                JSONObject depositInfoJsonObj = (JSONObject) object;
                depositInfo = new DepositInfo();
                depositInfo.deposit_amount = depositInfoJsonObj.getString("deposit_amount");
                depositInfo.deposit_type = depositInfoJsonObj.getString("deposit_type");
                depositInfo.full_price = depositInfoJsonObj.getInt("full_price");
                depositInfo.deposit_price = depositInfoJsonObj.getInt("deposit_price");
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return depositInfo;
    }
}