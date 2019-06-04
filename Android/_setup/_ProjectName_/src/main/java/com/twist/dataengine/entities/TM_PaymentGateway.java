package com.twist.dataengine.entities;

import java.util.ArrayList;
import java.util.List;

public class TM_PaymentGateway {

    public static class GatewaySettings {
        public String extra_charges;
        public String extra_charges_msg;
        public String extra_charges_type;
        public String cod_pincodes;
        public String in_ex_pincode;
        public String min_amount;
        public String max_amount;
    }

    public String id = "";
    public String title = "";
    public String description = "";
    public String icon = "";
    public String order_button_text = "";
    public String instructions = "";
    public boolean enabled = true;
    public List<TM_AccountDetail> account_details = null;
    public GatewaySettings settings = null;

    public static List<TM_PaymentGateway> allPaymentGateways = new ArrayList<>();

    public static void clear() {
        allPaymentGateways.clear();
    }

    public TM_PaymentGateway() {
    }

    public void commit() {
        allPaymentGateways.add(this);
    }

    public static void clearAll() {
        allPaymentGateways.clear();
    }
}