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

public class SagepayActivity extends BasePaymentActivity {

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
            setupActionBarHomeAsUp(TextUtils.isEmpty(title) ? "SagePay" : title);

            baseUrl = bundle.getString("baseurl");
            successUrl = bundle.getString("surl");
            failureUrl = bundle.getString("furl");

            String orderid = bundle.getString("order_id");
            String amount = bundle.getString("amount");

            String first_name = bundle.getString("first_name");
            String last_name = bundle.getString("last_name");
            String email = bundle.getString("email");
            String user_id = bundle.getString("user_id");

            String billingAddress1 = bundle.getString("billingAddress1");
            String billingAddress2 = bundle.getString("billingAddress2");
            String billingCity = bundle.getString("billingCity");
            String billingState = bundle.getString("billingState");
            String billingZip = bundle.getString("billingZip");
            String billingCountry = bundle.getString("billingCountry");

            String phone_number = bundle.getString("phone");

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
            params.put("order_id", encrypt(orderid));
            params.put("first_name", encrypt(first_name));
            params.put("last_name", encrypt(last_name));
            params.put("email", encrypt(email));
            params.put("user_id", encrypt(user_id));
            params.put("billingAddress1", encrypt(billingAddress1));
            params.put("billingAddress2", encrypt(billingAddress2));
            params.put("billingCity", encrypt(billingCity));
            params.put("billingState", encrypt(billingState));
            params.put("billingZip", encrypt(billingZip));
            params.put("billingCountry", encrypt(billingCountry));
            params.put("phone", encrypt(phone_number));
            postWebRequest(webView, baseUrl, params.entrySet());
        }
    }

    @Override
    protected void onActionBarRestored() {
    }
}
