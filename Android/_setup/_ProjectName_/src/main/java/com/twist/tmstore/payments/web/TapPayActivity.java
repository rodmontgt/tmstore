package com.twist.tmstore.payments.web;

import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.ViewGroup;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.LinearLayout;

import com.twist.tmstore.BasePaymentActivity;

import java.util.HashMap;
import java.util.Map;

public class TapPayActivity extends BasePaymentActivity {
    private WebView mWebView;
    private Bundle bundle;

    String baseURL = "";
    String amount = "";
    String first_name = "";
    String email = "";
    String phone_number = "";
    String order_id = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mWebView = new WebView(this);
        mWebView.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        setContentView(mWebView);
        bundle = getIntent().getExtras();
        if (bundle != null) {
            String title = bundle.getString("title");
            setupActionBarHomeAsUp(TextUtils.isEmpty(title) ? "TapPay" : title);
            baseURL = bundle.getString("backendurl");
            amount = String.valueOf(bundle.getFloat("amount"));
            order_id = String.valueOf(bundle.getFloat("order_id"));
            first_name = bundle.getString("first_name");
            email = bundle.getString("email");
            phone_number = bundle.getString("phone_number");
            mWebView.addJavascriptInterface(new MyWebInterface(new WebResponseListener() {
                @Override
                public void onResponseReceived(String response) {
                    if (response.contains("success")) {
                        onPaymentSuccess();
                    } else {
                        onPaymentError();
                    }
                }
            }), "Android");
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

            mWebView.getSettings().setAllowUniversalAccessFromFileURLs(true);
            mWebView.setWebViewClient(new PaymentWebClient(baseURL, new PaymentWebResponseHandler() {
                @Override
                public void onFinished(WebView view, String url) {
                }
            }));
            mWebView.getSettings().setLoadWithOverviewMode(true);
            mWebView.getSettings().setPluginState(WebSettings.PluginState.ON);

            Map<String, String> params = new HashMap<>();
            //params.put("amount", encrypt(amount));
            //params.put("ItemName", encrypt("Total"));
            //params.put("ItemQty", encrypt("1"));
            params.put("ItemPrice", encrypt(amount));
            params.put("OrdID", encrypt(order_id));
            params.put("CstFName", encrypt(first_name));
            params.put("CstEmail", encrypt(email));
            params.put("CstMobile", encrypt(phone_number));
            postWebRequest(mWebView, baseURL, params.entrySet());
        }
    }

    @Override
    protected void onActionBarRestored() {
    }
}
