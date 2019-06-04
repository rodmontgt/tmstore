package com.twist.tmstore.payments.web;

import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.LinearLayout;

import com.twist.tmstore.BasePaymentActivity;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by Twist Mobile on 21-04-2017.
 */

public class MollieActivity extends BasePaymentActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setupActionBarHomeAsUp("Mollie");

        WebView webView = new WebView(this);
        webView.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        setContentView(webView);

        Bundle bundle = getIntent().getExtras();
        if (bundle != null) {
            final String description = "My Order";
            final String amount = bundle.getString("amount");
            final String orderid = bundle.getString("orderid");
            final String baseUrl = bundle.getString("baseurl");
            final String successUrl = bundle.getString("surl");
            final String failureUrl = bundle.getString("furl");

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
            params.put("description", encrypt(description));
            postWebRequest(webView, baseUrl, params.entrySet());
        }
    }

    @Override
    protected void onActionBarRestored() {
    }
}