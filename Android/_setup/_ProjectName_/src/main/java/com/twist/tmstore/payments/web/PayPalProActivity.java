package com.twist.tmstore.payments.web;

import android.app.ProgressDialog;
import android.os.Build;
import android.os.Bundle;
import android.view.ViewGroup;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.LinearLayout;

import com.twist.tmstore.BasePaymentActivity;

import java.util.HashMap;
import java.util.Map;

public class PayPalProActivity extends BasePaymentActivity {

    private ProgressDialog progressDialog;
    private WebView mWebView;

    String baseURL = "";
    String amount = "";
    String orderid = "";

    private Bundle bundle = null;

    String first_name = "";
    String last_name = "";
    String email = "";

    String billingAddress1 = "";
    String billingAddress2 = "";
    String billingCity = "";
    String billingState = "";
    String billingZip = "";
    String billingCountry = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setupActionBarHomeAsUp("Paypal Pro");

        mWebView = new WebView(this);
        mWebView.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        setContentView(mWebView);

        bundle = getIntent().getExtras();
        if (bundle != null) {
            baseURL = bundle.getString("backendurl");
            amount = String.valueOf(bundle.getFloat("amount"));
            orderid = bundle.getString("order_id");
            first_name = bundle.getString("first_name");
            last_name = bundle.getString("last_name");
            email = bundle.getString("email");
            billingAddress1 = bundle.getString("billingAddress1");
            billingAddress2 = bundle.getString("billingAddress2");
            billingCity = bundle.getString("billingCity");
            billingState = bundle.getString("billingState");
            billingZip = bundle.getString("billingZip");
            billingCountry = bundle.getString("billingCountry");
        }

        MyWebInterface webInterface = new MyWebInterface(new WebResponseListener() {
            @Override
            public void onResponseReceived(String response) {
                if (response.contains("success")) {
                    onPaymentSuccess();
                } else {
                    onPaymentError();
                }
            }
        });
        mWebView.addJavascriptInterface(webInterface, "Android");
        mWebView.getSettings().setSaveFormData(true);
        mWebView.getSettings().setJavaScriptEnabled(true);
        mWebView.getSettings().setDatabaseEnabled(true);
        mWebView.getSettings().setDomStorageEnabled(true);
        mWebView.getSettings().setAllowFileAccess(true);
        mWebView.getSettings().setSupportMultipleWindows(true);


        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            WebView.setWebContentsDebuggingEnabled(true);
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            mWebView.getSettings().setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);
        }
        mWebView.setWebViewClient(new PaymentWebClient(baseURL, new PaymentWebResponseHandler() {
            @Override
            public void onFinished(WebView view, String url) {
            }
        }));
        mWebView.getSettings().setLoadWithOverviewMode(true);
        mWebView.getSettings().setPluginState(WebSettings.PluginState.ON);

        Map<String, String> params = new HashMap<>();
        params.put("amount", encrypt(amount));
        params.put("order_id", encrypt(orderid));
        params.put("first_name", encrypt(first_name));
        params.put("last_name", encrypt(last_name));
        params.put("email", encrypt(email));
        params.put("phone", encrypt("122"));
        params.put("billingAddress1", encrypt(billingAddress1));
        params.put("billingAddress2", encrypt(billingAddress2));
        params.put("billingCity", encrypt(billingCity));
        params.put("billingState", encrypt(billingState));
        params.put("billingZip", encrypt(billingZip));
        params.put("billingCountry", encrypt(billingCountry));

        postWebRequest(mWebView, baseURL, params.entrySet());
    }

    @Override
    protected void onActionBarRestored() {
    }
}
