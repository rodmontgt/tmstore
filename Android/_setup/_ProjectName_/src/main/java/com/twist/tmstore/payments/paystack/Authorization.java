
package com.twist.tmstore.payments.paystack;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class Authorization {

    @SerializedName("authorization_code")
    @Expose
    public String authorizationCode;
    @SerializedName("card_type")
    @Expose
    public String cardType;
    @SerializedName("last4")
    @Expose
    public String last4;
    @SerializedName("bank")
    @Expose
    public Object bank;

}
