package com.twist.tmstore.payments.web;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.JavascriptInterface;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.LinearLayout;

import com.twist.tmstore.BasePaymentActivity;
import com.twist.tmstore.L;

import java.util.HashMap;
import java.util.Map;

public class PayULatamActivity extends BasePaymentActivity {
    private WebView webView;
    private String apiKey;
    private String merchantId;
    private String accountId;
    private String description;
    private String amount;
    private String tax;
    private String taxReturnBase;
    private String currency;
    private String buyerEmail;
    private String test = "0";
    private String confirmationUrl = "";
    private String responseUrl = "";
    private String baseURL = "";

    @SuppressLint({"AddJavascriptInterface", "SetJavaScriptEnabled", "JavascriptInterface"})
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        webView = new WebView(this);
        webView.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        setContentView(webView);
        setupActionBarHomeAsUp("PayU Latam");

        Bundle bundle = getIntent().getExtras();
        if (bundle != null) {
            apiKey = bundle.getString("apikey");
            merchantId = bundle.getString("merchantid");
            accountId = bundle.getString("accountid");
            baseURL = bundle.getString("baseurl");
            description = bundle.getString("order_id");
            amount = bundle.getString("amount");
            tax = bundle.getString("tax");
            taxReturnBase = bundle.getString("taxreturnbase");
            currency = bundle.getString("currency");
            buyerEmail = bundle.getString("email");
            responseUrl = bundle.getString("responseurl");
            confirmationUrl = bundle.getString("confirmationurl");

            final ProgressDialog progressDialog = new ProgressDialog(this);
            progressDialog.setCanceledOnTouchOutside(false);
            progressDialog.setMessage(L.getString(L.string.please_wait));

            webView.setWebViewClient(new PaymentWebClient(baseURL, new PaymentWebResponseHandler() {
                @Override
                public void onFinished(WebView view, String url) {
                    if (url.startsWith(confirmationUrl)) {
                        onPaymentSuccess();
                    } else if (url.startsWith(responseUrl)) {
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
                            intent.putExtra("result", result);
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
                    runOnUiThread(() -> {
                        Intent intent = new Intent();
                        intent.putExtra("result", result);
                        setResult(RESULT_CANCELED, intent);
                        finish();
                    });
                }
            }, "PayU Latam");

            Map<String, String> mapParams = new HashMap<>();
            mapParams.put("apiKey", encrypt(apiKey));
            mapParams.put("merchantId", encrypt(merchantId));
            mapParams.put("accountId", encrypt(accountId));
            mapParams.put("description", encrypt(description));
            mapParams.put("test", encrypt(test));
            mapParams.put("amount", encrypt(amount));
            mapParams.put("tax", encrypt(tax));
            mapParams.put("taxReturnBase", encrypt(taxReturnBase));
            mapParams.put("currency", encrypt(currency));
            mapParams.put("buyerEmail", encrypt(buyerEmail));
            mapParams.put("responseUrl", encrypt(responseUrl));
            mapParams.put("confirmationUrl", encrypt(confirmationUrl));
            postWebRequest(webView, baseURL, mapParams.entrySet());
        }
    }

    @Override
    protected void onActionBarRestored() {
    }
}