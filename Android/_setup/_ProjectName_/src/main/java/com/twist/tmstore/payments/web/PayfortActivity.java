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

import java.util.HashMap;
import java.util.Map;

/**
 * Created by Twist Mobile on 10/25/2017.
 */

public class PayfortActivity extends BasePaymentActivity {

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
            setupActionBarHomeAsUp(TextUtils.isEmpty(title) ? "Payfort" : title);

            baseUrl = bundle.getString("baseurl");
            successUrl = bundle.getString("surl");
            failureUrl = bundle.getString("furl");

            String orderid = bundle.getString("order_id");
            String amount = bundle.getString("amount");

            String name = bundle.getString("first_name") + " " + bundle.getString("last_name");
            String email = bundle.getString("email");

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
            params.put("amount", encrypt(amount));
            params.put("orderid", encrypt(orderid));
            params.put("name", encrypt(name));
            params.put("email", encrypt(email));
            params.put("description", encrypt(orderid));
            postWebRequest(webView, baseUrl, params.entrySet());
        }
    }

    @Override
    protected void onActionBarRestored() {
    }
}
