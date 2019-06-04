package com.twist.tmstore.payments.web;

import android.app.ProgressDialog;
import android.content.Intent;
import android.net.http.SslError;
import android.os.Bundle;
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
import com.twist.tmstore.L;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

public class DusuPayActivity extends BasePaymentActivity {

    private ProgressDialog progressDialog;
    private WebView webView;

    String baseURL = "http://sandbox.dusupay.com/dusu_payments/dusupay";
    String dusupay_environment = "sandbox";
    String dusupay_hash = "";
    String dusupay_itemId = "Item";
    String dusupay_itemName = "MyItem";
    String dusupay_transactionReference = "";
    String dusupay_amount = "";
    String dusupay_currency = "UGX";
    String dusupay_merchantId = "";
    String dusupay_redirectURL = "";
    String dusupay_successURL = "";

    boolean isSandboxMode = true;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setupActionBarHomeAsUp("DusuPay");

        webView = new WebView(this);
        webView.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        setContentView(webView);

        if (getIntent().getExtras() != null) {
            Bundle bundle = getIntent().getExtras().getBundle("data");
            if (bundle != null) {
                dusupay_merchantId = bundle.getString("merchant_id");
                isSandboxMode = bundle.getBoolean("isSandbox");
                dusupay_redirectURL = bundle.getString("redirect_url");
                dusupay_successURL = bundle.getString("surl");
                dusupay_itemId = String.valueOf(bundle.getInt("order_id"));
                dusupay_itemName = dusupay_itemId;
                dusupay_amount = String.valueOf(bundle.getFloat("amount"));
                if (!isSandboxMode) {
                    baseURL = "https://dusupay.com/dusu_payments/dusupay";
                    dusupay_environment = "";
                }
                dusupay_transactionReference = "";
                dusupay_hash = "";

                Random rand = new Random();
                int i = rand.nextInt() % 999999999;
                String strHash = null;
                try {
                    strHash = createSHA1(new Date().toString());
                } catch (NoSuchAlgorithmException e) {
                    e.printStackTrace();
                } catch (UnsupportedEncodingException e) {
                    e.printStackTrace();
                }

                dusupay_transactionReference = strHash;

                Map<String, String> params = new HashMap<>();
                params.put("dusupay_merchantId", encrypt(dusupay_merchantId));
                params.put("dusupay_amount", encrypt(dusupay_amount));
                params.put("dusupay_currency", encrypt(dusupay_currency));
                params.put("dusupay_itemId", encrypt(dusupay_itemId));
                params.put("dusupay_itemName", encrypt(dusupay_itemName));
                params.put("dusupay_transactionReference", encrypt(dusupay_transactionReference));
                params.put("dusupay_redirectURL", encrypt(dusupay_redirectURL));
                params.put("dusupay_successURL", encrypt(dusupay_successURL));
                params.put("dusupay_environment", encrypt(isSandboxMode ? dusupay_environment : ""));

                String post = "";
                for (Map.Entry<String, String> param : params.entrySet()) {
                    post += "&" + param.getKey() + "=" + param.getValue();
                }

                webView.setWebViewClient(new WebViewClient());
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
                    }

                    @JavascriptInterface
                    public void onFailure() {
                        onFailure("");
                    }

                    @JavascriptInterface
                    public void onFailure(final String result) {
                    }
                }, "DusuPay");

                progressDialog = new ProgressDialog(this);
                progressDialog.setCanceledOnTouchOutside(false);
                progressDialog.setMessage(getString(L.string.loading));
                progressDialog.show();

                webView.setWebViewClient(new WebViewClient() {
                    @Override
                    public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
                        super.onReceivedError(view, request, error);
                        progressDialog.dismiss();
                        onPaymentError();
                    }

                    @Override
                    public void onReceivedSslError(final WebView view, final SslErrorHandler handler, SslError error) {
                        handleSslError(handler, baseURL, progressDialog);
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
                        progressDialog.dismiss();
                        if (url.startsWith(dusupay_redirectURL)) {
                            Intent intent = new Intent();
                            setResult(RESULT_OK, intent);
                            finish();
                        }
                        super.onPageFinished(view, url);
                    }
                });
                postWebRequest(webView, baseURL, params.entrySet());
            }
        }
    }

    @Override
    protected void onActionBarRestored() {
    }

    public static String createSHA1(String text) throws NoSuchAlgorithmException, UnsupportedEncodingException {
        MessageDigest md = MessageDigest.getInstance("SHA-1");
        byte[] textBytes = text.getBytes("iso-8859-1");
        md.update(textBytes, 0, textBytes.length);
        byte[] sha1hash = md.digest();
        return convertToHex(sha1hash);
    }

    private static String convertToHex(byte[] data) {
        StringBuilder buf = new StringBuilder();
        for (byte b : data) {
            int halfbyte = (b >>> 4) & 0x0F;
            int two_halfs = 0;
            do {
                buf.append((0 <= halfbyte) && (halfbyte <= 9) ? (char) ('0' + halfbyte) : (char) ('a' + (halfbyte - 10)));
                halfbyte = b & 0x0F;
            } while (two_halfs++ < 1);
        }
        return buf.toString();
    }
}