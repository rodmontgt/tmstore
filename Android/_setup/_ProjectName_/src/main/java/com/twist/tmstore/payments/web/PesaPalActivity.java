package com.twist.tmstore.payments.web;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.twist.tmstore.BasePaymentActivity;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by Twist Mobile on 2/27/2017.
 */

public class PesaPalActivity extends BasePaymentActivity {

    private WebView webView;
    private Context activity;

    private String baseUrl = "";
    private String successUrl = "";
    private String failureUrl = "";

    private String first_name;
    private String last_name;
    private String email;
    private String phone_number;
    private String description;

    private String amount;
    private String orderid_reference;

    @SuppressLint({"AddJavascriptInterface", "SetJavaScriptEnabled", "JavascriptInterface"})
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        activity = this;
        setupActionBarHomeAsUp("PesaPal.com");

        webView = new WebView(this);
        webView.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        setContentView(webView);

        Bundle bundle = getIntent().getExtras();
        if (bundle != null) {
            String title = bundle.getString("title");
            setupActionBarHomeAsUp(!TextUtils.isEmpty(title) ? title : "PesaPal.com");
            orderid_reference = bundle.getString("orderid");
            baseUrl = bundle.getString("baseurl");
            successUrl = bundle.getString("surl");
            failureUrl = bundle.getString("furl");

            first_name = bundle.getString("first_name");
            last_name = bundle.getString("last_name");
            email = bundle.getString("email");
            phone_number = bundle.getString("phonenumber");
            description = bundle.getString("description");
            amount = bundle.getString("amount");

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
            params.put("first_name", encrypt(first_name));
            params.put("last_name", encrypt(last_name));
            params.put("phone_number", encrypt(phone_number));
            params.put("amount", encrypt(amount));
            params.put("email", encrypt(email));
            params.put("orderid", encrypt(orderid_reference));
            params.put("description", encrypt(description));
            postWebRequest(webView, baseUrl, params.entrySet());
        } else {
            Toast.makeText(activity, "Something went wrong, Try again.", Toast.LENGTH_LONG).show();
        }
    }

    @Override
    protected void onActionBarRestored() {

    }
}
