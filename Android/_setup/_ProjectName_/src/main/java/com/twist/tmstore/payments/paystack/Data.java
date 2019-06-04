
package com.twist.tmstore.payments.paystack;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;

public class Data {

    @SerializedName("amount")
    @Expose
    public Integer amount;
    @SerializedName("transaction_date")
    @Expose
    public String transactionDate;
    @SerializedName("status")
    @Expose
    public String status;
    @SerializedName("reference")
    @Expose
    public String reference;
    @SerializedName("domain")
    @Expose
    public String domain;
    @SerializedName("authorization")
    @Expose
    public Authorization authorization;
    @SerializedName("customer")
    @Expose
    public Customer customer;
    @SerializedName("plan")
    @Expose
    public Integer plan;

}
