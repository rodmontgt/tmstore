package com.twist.tmstore.payments.gateways;

import android.app.Activity;
import android.content.Intent;

import com.twist.dataengine.entities.TM_LineItem;
import com.twist.dataengine.entities.TM_Order;
import com.twist.tmstore.entities.Address;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.web.ConektaActivity;
import com.utils.JsonHelper;

import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Created by Twist Mobile on 7/10/2017.
 */

public class ConektaGateway extends PaymentGateway {

    private static ConektaGateway mGateway;

    public static ConektaGateway getInstance() {
        if (mGateway == null) {
            mGateway = new ConektaGateway();
        }
        return mGateway;
    }

    private ConektaGateway() {
        super();
    }

    public boolean isPrepaid() {
        return true;
    }

    @Override
    public boolean open(int orderId, float amount) {
        getIntent().putExtra("amount", String.valueOf(amount));
        getIntent().putExtra("orderid", String.valueOf(orderId));
        getIntent().putExtra("order_items", getOrderItemString(this.order));
        this.launchIntent();
        return true;
    }

    public static void createGateway(Activity activity, JSONObject jsonObject) {
        try {
            mGateway = ConektaGateway.getInstance();
            AppUser appUser = AppUser.getInstance();

            Address billing_address = appUser.billing_address;
            JSONArray billing_addressJson = new JSONArray();
            JSONObject billing_addressObject = new JSONObject();
            billing_addressObject.put("company_name", billing_address.company);
            billing_addressObject.put("street1", billing_address.address_1);
            billing_addressObject.put("street2", billing_address.address_2);
            billing_addressObject.put("zip", billing_address.postcode);
            billing_addressObject.put("city", billing_address.city);
            billing_addressObject.put("phone", billing_address.phone);
            billing_addressObject.put("email", billing_address.email);
            billing_addressObject.put("country", billing_address.country);
            billing_addressObject.put("state", billing_address.state);
            billing_addressJson.put(billing_addressObject);

            Address shipping_address = appUser.shipping_address;
            JSONArray shipping_addressJson = new JSONArray();
            JSONObject shipping_addressObject = new JSONObject();
            shipping_addressObject.put("street1", shipping_address.address_1);
            shipping_addressObject.put("street2", shipping_address.address_2);
            shipping_addressObject.put("zip", shipping_address.postcode);
            shipping_addressObject.put("city", shipping_address.city);
            shipping_addressObject.put("phone", shipping_address.phone);
            shipping_addressObject.put("country", shipping_address.country);
            shipping_addressObject.put("state", shipping_address.state);
            shipping_addressJson.put(shipping_addressObject);

            JSONArray shipmentJson = new JSONArray();
            JSONObject shipmentObject = new JSONObject();
            shipmentObject.put("carrier", "default");
            shipmentObject.put("service", "default");
            shipmentObject.put("price", 0);
            shipmentJson.put(shipmentObject);

            Intent intent = new Intent(activity, ConektaActivity.class);
            intent.putExtra("baseurl", JsonHelper.getString(jsonObject, "baseurl"));
            intent.putExtra("furl", JsonHelper.getString(jsonObject, "furl"));
            intent.putExtra("surl", JsonHelper.getString(jsonObject, "surl"));

            intent.putExtra("name", AppUser.getInstance().getDisplayName());
            intent.putExtra("email", AppUser.getEmail());
            intent.putExtra("phonenumber", AppUser.getInstance().billing_address.phone);

            intent.putExtra("billing_address", billing_addressJson.toString());
            intent.putExtra("shipping_address", shipping_addressJson.toString());
            intent.putExtra("shipment", shipmentJson.toString());
            intent.putExtra("description", AppUser.getInstance().getDisplayName());

            intent.putExtra("baseurl", JsonHelper.getString(jsonObject, "baseurl"));
            intent.putExtra("surl", JsonHelper.getString(jsonObject, "surl"));
            intent.putExtra("furl", JsonHelper.getString(jsonObject, "furl"));
            mGateway.setEnabled(JsonHelper.getBool(jsonObject, "enabled"));
            mGateway.initialize(activity, intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private String getOrderItemString(TM_Order order) {
        JSONArray orderJsonArray = new JSONArray();
        try {
            for (TM_LineItem lineItem : order.line_items) {
                JSONObject orderJsonObject = new JSONObject();
                orderJsonObject.put("name", lineItem.name);
                orderJsonObject.put("unit_price", lineItem.price);
                orderJsonObject.put("description", lineItem.name);
                orderJsonObject.put("quantity", lineItem.quantity);
                orderJsonObject.put("sku", lineItem.sku);
                orderJsonObject.put("type", "");
                orderJsonArray.put(orderJsonObject);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return orderJsonArray.toString();
    }
}
