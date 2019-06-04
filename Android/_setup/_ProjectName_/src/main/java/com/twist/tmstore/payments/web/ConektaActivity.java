package com.twist.tmstore.payments.web;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.LinearLayout;

import com.twist.tmstore.BasePaymentActivity;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by Twist Mobile on 7/10/2017.
 */

public class ConektaActivity extends BasePaymentActivity {

    private WebView webView;
    private String baseUrl = "";
    private String successUrl = "";
    private String failureUrl = "";
    private String name;
    private String phone;
    private String amount;
    private String email;
    private String description;
    private String orderid;
    private String order_items;
    private String billing_address;
    private String shipping_address;
    private String shipment;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        webView = new WebView(this);
        webView.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        setContentView(webView);

        Bundle bundle = getIntent().getExtras();
        if (bundle != null) {
            String title = bundle.getString("title");
            setupActionBarHomeAsUp(TextUtils.isEmpty(title) ? "ConektaCard" : title);
            name = bundle.getString("name");
            email = bundle.getString("email");
            phone = bundle.getString("phonenumber");
            description = bundle.getString("description");

            order_items = bundle.getString("order_items");
            billing_address = bundle.getString("billing_address");
            shipping_address = bundle.getString("shipping_address");
            shipment = bundle.getString("shipment");

            amount = bundle.getString("amount");
            orderid = bundle.getString("orderid");
            baseUrl = bundle.getString("baseurl");
            successUrl = bundle.getString("surl");
            failureUrl = bundle.getString("furl");

            webView.setWebViewClient(new PaymentWebClient(baseUrl, new PaymentWebResponseHandler() {
                @Override
                public void onFinished(WebView view, String url) {
                    if (url.startsWith(successUrl)) {
                        onPaymentSuccess();
                    } else if (url.startsWith(failureUrl)) {
                        onPaymentError();
                    }
                }
            }));

            webView.setVisibility(View.VISIBLE);
            webView.getSettings().setBuiltInZoomControls(true);
            webView.getSettings().setCacheMode(WebSettings.LOAD_NO_CACHE);
            webView.getSettings().setDomStorageEnabled(true);
            webView.clearHistory();
            webView.clearCache(true);
            webView.getSettings().setJavaScriptEnabled(true);
            webView.getSettings().setSupportZoom(true);
            webView.getSettings().setUseWideViewPort(false);
            webView.getSettings().setLoadWithOverviewMode(false);

            Map<String, String> params = new HashMap<>();
            params.put("name", encrypt(name));
            params.put("email", encrypt(email));
            params.put("phonenumber", encrypt(phone));
            params.put("description", encrypt(description));
            params.put("order_items", encrypt(order_items));
            params.put("billing_address", encrypt(billing_address));
            params.put("shipping_address", encrypt(shipping_address));
            params.put("shipment", encrypt(shipment));
            params.put("amount", encrypt(amount));
            params.put("orderid", encrypt(orderid));

            postWebRequest(webView, baseUrl, params.entrySet());
        }
    }

    @Override
    protected void onActionBarRestored() {
    }
}