package com.twist.tmstore.payments.web;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.LinearLayout;

import com.twist.tmstore.BasePaymentActivity;
import com.utils.Base64Utils;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by Twist Mobile on 11/21/2017.
 */

public class HesabeActivity extends BasePaymentActivity {

    private WebView webView;
    private String baseUrl = "";
    private String successUrl = "";
    private String failureUrl = "";

    @SuppressLint({"AddJavascriptInterface", "SetJavaScriptEnabled", "JavascriptInterface"})
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        webView = new WebView(this);
        webView.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        setContentView(webView);

        Bundle bundle = getIntent().getExtras();
        if (bundle != null) {
            String title = bundle.getString("title");
            setupActionBarHomeAsUp(TextUtils.isEmpty(title) ? "Hesabe" : title);

            baseUrl = bundle.getString("baseurl");
            successUrl = bundle.getString("surl");
            failureUrl = bundle.getString("furl");

            String orderid = bundle.getString("order_id");
            String amount = bundle.getString("amount");

            String name = bundle.getString("first_name") + " " + bundle.getString("last_name");
            String email = bundle.getString("email");

            String phone_number = bundle.getString("phonenumber");

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
            params.put("amount", Base64Utils.encode(amount));
            params.put("orderid", Base64Utils.encode(orderid));
            params.put("name", Base64Utils.encode(name));
            params.put("email", Base64Utils.encode(email));
            params.put("phonenumber", Base64Utils.encode(phone_number));
            params.put("description", Base64Utils.encode(name));
            postWebRequest(webView, baseUrl, params.entrySet());
        }
    }

    @Override
    protected void onActionBarRestored() {
    }
}