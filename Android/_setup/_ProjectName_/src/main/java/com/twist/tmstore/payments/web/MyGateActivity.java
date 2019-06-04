package com.twist.tmstore.payments.web;

import android.annotation.SuppressLint;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.net.http.SslError;
import android.os.Bundle;
import android.support.v7.app.AlertDialog;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.JavascriptInterface;
import android.webkit.SslErrorHandler;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.LinearLayout;

import com.twist.tmstore.BasePaymentActivity;
import com.twist.tmstore.BuildConfig;
import com.twist.tmstore.L;
import com.utils.HtmlCompat;

import java.util.HashMap;
import java.util.Map;

import static com.utils.DataHelper.encrypt;

public class MyGateActivity extends BasePaymentActivity {

    @SuppressLint({"AddJavascriptInterface", "SetJavaScriptEnabled", "JavascriptInterface"})
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Bundle bundle = getIntent().getExtras();
        if (bundle == null) {
            return;
        }

        WebView webView = new WebView(this);
        webView.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        setContentView(webView);

        setupActionBarHomeAsUp("MyGate");

        // Minimum amount value is 9 .
        String amount = bundle.getString("amount");
        if (BuildConfig.DEBUG) {
            amount = "9";
        }

        final String baseURL = bundle.getString("baseurl");
        final String sURL = bundle.getString("surl");
        final String fURL = bundle.getString("furl");

        final ProgressDialog progressDialog = new ProgressDialog(this);
        progressDialog.setCanceledOnTouchOutside(false);
        progressDialog.setMessage(L.getString(L.string.please_wait));
        webView.setWebViewClient(new WebViewClient() {
            @Override
            public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
                super.onReceivedError(view, request, error);
                progressDialog.dismiss();
                onPaymentError();
            }

            @Override
            public void onReceivedSslError(final WebView view, final SslErrorHandler handler, SslError error) {
                // Handle SSL Certificate error with Ok & Cancel dialog to comply with Play Store Security Policy
                if (progressDialog.isShowing()) {
                    progressDialog.dismiss();
                }
                String msgString = getString(L.string.security_cert_dialog_msg);
                msgString += " <b>" + baseURL + "</b>";
                AlertDialog.Builder alertDialog = new AlertDialog.Builder(MyGateActivity.this);
                alertDialog.setTitle(getString(L.string.security_cert_dialog_title));
                alertDialog.setMessage(HtmlCompat.fromHtml(msgString));
                alertDialog.setPositiveButton(getString(L.string.proceed), new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        handler.proceed();
                        progressDialog.show();
                    }
                });
                alertDialog.setNegativeButton(getString(L.string.cancel), new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        handler.cancel();
                        onPaymentError();
                    }
                });
                alertDialog.show();
            }

            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                if (!progressDialog.isShowing()) {
                    progressDialog.show();
                }
                return super.shouldOverrideUrlLoading(view, url);
            }

            @Override
            public void onPageFinished(WebView view, String url) {
                if (progressDialog.isShowing()) {
                    progressDialog.dismiss();
                }
                if (url.startsWith(sURL)) {
                    onPaymentSuccess();
                } else if (url.startsWith(fURL)) {
                    onPaymentError();
                }
                super.onPageFinished(view, url);
            }
        });

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
                        onPaymentSuccess();
                    }
                });
            }

            @JavascriptInterface
            public void onFailure() {
                onFailure("");
            }

            @JavascriptInterface
            public void onFailure(final String result) {
                runOnUiThread(() -> onPaymentError());
            }
        }, "MyGate");

        Map<String, String> mapParams = new HashMap<>();
        mapParams.put("amount", encrypt(amount));
        postWebRequest(webView, baseURL, mapParams.entrySet());
    }

    @Override
    protected void onActionBarRestored() {
    }
}