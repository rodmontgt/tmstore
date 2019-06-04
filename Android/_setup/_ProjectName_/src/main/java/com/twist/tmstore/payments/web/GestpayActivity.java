package com.twist.tmstore.payments.web;

/**
 * Created by Twist Mobile on 20-06-2017.
 */

import android.os.Build;
import android.os.Bundle;
import android.view.ViewGroup;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.LinearLayout;

import com.twist.tmstore.BasePaymentActivity;

import org.apache.http.util.EncodingUtils;

public class GestpayActivity extends BasePaymentActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        WebView webView = new WebView(this);
        webView.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        setContentView(webView);
        setupActionBarHomeAsUp("Gestpay Checkout");
        Bundle extras = getIntent().getExtras();
        if (extras != null) {
            webView.getSettings().setSaveFormData(true);
            webView.getSettings().setJavaScriptEnabled(true);
            webView.getSettings().setDatabaseEnabled(true);
            webView.getSettings().setDomStorageEnabled(true);
            webView.getSettings().setAllowFileAccess(true);
            webView.getSettings().setSupportMultipleWindows(true);
            webView.getSettings().setAllowUniversalAccessFromFileURLs(true);
            webView.setWebChromeClient(new WebChromeClient());
            webView.getSettings().setLoadWithOverviewMode(true);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                webView.getSettings().setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);
            }

            String amount = extras.getString("amount");
            String payment_url = extras.getString("payment_url");
            String shop_login = extras.getString("shop_login");
            String shop_transaction_id = extras.getString("shop_transaction_id");

            webView.setWebViewClient(new PaymentWebClient(payment_url, new PaymentWebResponseHandler()));
            webView.addJavascriptInterface((new MyWebInterface(new WebResponseListener() {
                @Override
                public void onResponseReceived(String response) {
                    if (response.contains("success")) {
                        onPaymentSuccess();
                    } else {
                        onPaymentError();
                    }
                }
            })), "Android");
            StringBuilder params = new StringBuilder();
            params.append(addToPostParams("shoptransactionid", shop_transaction_id));
            params.append(addToPostParams("totalamount", amount));
            params.append(addToPostParams("shoplogin", shop_login));
            webView.postUrl(payment_url, EncodingUtils.getBytes(params.substring(0, params.length() - 1), "UTF-8"));
        } else {
            onPaymentError();
        }
    }

    @Override
    protected void onActionBarRestored() {
    }
}