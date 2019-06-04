package com.twist.tmstore.payments.web;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.JavascriptInterface;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.twist.tmstore.BasePaymentActivity;
import com.twist.tmstore.BuildConfig;

import java.util.HashMap;
import java.util.Map;

public class BrainTreeActivity extends BasePaymentActivity {

    private WebView webView;

    private String amount;

    String baseURL = "";
    String sURL = "";
    String fURL = "";

    @SuppressLint({"AddJavascriptInterface", "SetJavaScriptEnabled", "JavascriptInterface"})
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setupActionBarHomeAsUp("BrainTree");

        webView = new WebView(this);
        webView.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        setContentView(webView);

        Bundle bundle = getIntent().getExtras();
        if (bundle != null) {
            amount = bundle.getString("amount");
            if (BuildConfig.DEBUG)
                amount = ".01";

            baseURL = bundle.getString("baseurl");
            sURL = bundle.getString("surl");
            fURL = bundle.getString("furl");

            webView.setWebViewClient(new PaymentWebClient(baseURL, new PaymentWebResponseHandler() {
                @Override
                public void onFinished(WebView view, String url) {
                    if (url.startsWith(sURL)) {
                        onPaymentSuccess();
                    } else if (url.startsWith(fURL)) {
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
            webView.addJavascriptInterface(new Object() {
                @JavascriptInterface
                public void onSuccess() {
                    onSuccess("");
                }

                @JavascriptInterface
                public void onSuccess(final String result) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Intent intent = new Intent();
                            setResult(RESULT_OK, intent);
                            finish();
                        }
                    });
                }

                @JavascriptInterface
                public void onFailure() {
                    onFailure("");
                }

                @JavascriptInterface
                public void onFailure(final String result) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Intent intent = new Intent();
                            setResult(RESULT_CANCELED, intent);
                            finish();
                        }
                    });
                }
            }, "BrainTree");

            Map<String, String> mapParams = new HashMap<>();
            mapParams.put("amount", encrypt(amount));
            postWebRequest(webView, baseURL, mapParams.entrySet());
        } else {
            Toast.makeText(this, "Something went wrong, Try again.", Toast.LENGTH_LONG).show();
        }
    }

    @Override
    protected void onActionBarRestored() {
    }
}