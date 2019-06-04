package com.twist.tmstore.payments.web;

import android.os.Bundle;
import android.view.View;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.LinearLayout;

import com.twist.tmstore.BasePaymentActivity;

import java.util.HashMap;
import java.util.Map;

import static android.view.ViewGroup.LayoutParams;

public class AuthorizeNetActivity extends BasePaymentActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setupActionBarHomeAsUp("Authorize.Net");

        final WebView webView = new WebView(this);
        webView.setLayoutParams(new LinearLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
        setContentView(webView);

        Bundle bundle = getIntent().getExtras();
        if (bundle != null) {
            String fname = bundle.getString("fname");
            String lname = bundle.getString("lname");
            String address = bundle.getString("address");
            String countryCode = bundle.getString("country");
            String stateCode = bundle.getString("state");
            String city = bundle.getString("city");
            String zipcode = bundle.getString("zipcode");
            String phone = bundle.getString("phone");
            String amount = bundle.getString("amount");
            String email = bundle.getString("email");
            String description = bundle.getString("description");
            String orderid = bundle.getString("orderid");
            
            String baseUrl = bundle.getString("baseurl");
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
            params.put("fname", encrypt(fname));
            params.put("lname", encrypt(lname));
            params.put("address", encrypt(address));
            params.put("country", encrypt(countryCode));
            params.put("state", encrypt(stateCode));
            params.put("city", encrypt(city));
            params.put("zipcode", encrypt(zipcode));
            params.put("phone", encrypt(phone));
            params.put("amount", encrypt(amount));
            params.put("email", encrypt(email));
            params.put("orderid", encrypt(orderid));
            params.put("description", encrypt(description));
            postWebRequest(webView, baseUrl, params.entrySet());
        }
    }

    @Override
    protected void onActionBarRestored() {
    }
}