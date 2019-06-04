package com.twist.tmstore.payments.web;

import android.app.Activity;
import android.app.ProgressDialog;
import android.os.AsyncTask;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.ViewGroup;
import android.webkit.JavascriptInterface;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.twist.tmstore.BasePaymentActivity;
import com.twist.tmstore.L;
import com.utils.Log;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EncodingUtils;

import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;

public class CCAvenueActivity extends BasePaymentActivity {

    public static final String ACCESS_CODE = "access_code";
    public static final String MERCHANT_ID = "merchant_id";
    public static final String ORDER_ID = "order_id";
    public static final String AMOUNT = "amount";
    public static final String CURRENCY = "currency";
    public static final String ENC_VAL = "enc_val";
    public static final String REDIRECT_URL = "redirect_url";
    public static final String CANCEL_URL = "cancel_url";
    public static final String RSA_KEY_URL = "rsa_key_url";

    private ProgressDialog dialog;
    private String encVal;
    private WebView mWebView;
    private Activity mActivity;

    private final String TRANS_URL = "https://secure.ccavenue.com/transaction/initTrans";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mActivity = this;
        mWebView = new WebView(this);
        mWebView.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        setContentView(mWebView);
        setupActionBarHomeAsUp("CCAvenue");

        new RenderView().execute();
    }

    @Override
    protected void onActionBarRestored() {
    }

    private class RenderView extends AsyncTask<Void, Void, String> {
        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            dialog = new ProgressDialog(mActivity);
            dialog.setMessage(getString(L.string.please_wait));
            dialog.setCancelable(false);
            dialog.show();
        }

        @Override
        protected String doInBackground(Void... arg0) {
            // Creating service handler class instance
            ServiceHandler sh = new ServiceHandler();
            // Making a request to url and getting response
            List<NameValuePair> params = new ArrayList<>();
            params.add(new BasicNameValuePair(ACCESS_CODE, getIntent().getStringExtra(ACCESS_CODE)));
            params.add(new BasicNameValuePair(ORDER_ID, String.valueOf(getIntent().getIntExtra(ORDER_ID, 0))));

            String vResponse = sh.makeServiceCall(getIntent().getStringExtra(RSA_KEY_URL), ServiceHandler.POST, params);

            String error = "";
            if (!TextUtils.isEmpty(vResponse) && !vResponse.contains("ERROR")) {
                Log.e("CCAvenue: ", vResponse);
                StringBuilder vEncVal = new StringBuilder("");
                vEncVal.append(addToPostParams(AMOUNT, String.valueOf(getIntent().getFloatExtra(AMOUNT, 0.0f))));
                vEncVal.append(addToPostParams(CURRENCY, getIntent().getStringExtra(CURRENCY)));
                encVal = rsaEncrypt(vEncVal.substring(0, vEncVal.length() - 1), vResponse);
            } else {
                Log.e("CCAvenue: ", vResponse);
                error = vResponse;
            }
            return error;
        }

        @Override
        protected void onPostExecute(String result) {
            super.onPostExecute(result);
            // Dismiss the progress dialog
            if (dialog.isShowing())
                dialog.dismiss();

            if (!TextUtils.isEmpty(result)) {
                Toast.makeText(mActivity, result.replace("!ERROR!", ""), Toast.LENGTH_LONG).show();
            }

            @SuppressWarnings("unused")
            class MyJavaScriptInterface {
                @JavascriptInterface
                public void processHTML(String html) {
                    // process the html as needed by the app
                    boolean status = false;
                    if (html.contains("Failure")) {
                        Log.d("Transaction Declined!");
                    } else if (html.contains("Success")) {
                        status = true;
                        Log.d("Transaction Successful!");
                    } else if (html.contains("Aborted")) {
                        Log.d("Transaction Cancelled!");
                    } else {
                        Log.d("Status Not Known!");
                    }

                    if (status) {
                        onPaymentSuccess();
                    } else {
                        onPaymentError();
                    }
                }
            }
            mWebView.getSettings().setJavaScriptEnabled(true);
            mWebView.addJavascriptInterface(new MyJavaScriptInterface(), "HTMLOUT");
            mWebView.setWebViewClient(new WebViewClient() {
                @Override
                public void onPageFinished(WebView view, String url) {
                    super.onPageFinished(mWebView, url);
                    //TODO replace it with server configuration in future
                    if (url.contains("/ccavResponseHandler.php")) {
                        mWebView.loadUrl("javascript:window.HTMLOUT.processHTML('<head>'+document.getElementsByTagName('html')[0].innerHTML+'</head>');");
                    }
                }

                @Override
                public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
                    Log.e("errorCode: " + errorCode + ", " + description);
                    onPaymentError();
                }
            });

            try {
                /* An instance of this class will be registered as a JavaScript interface */
                StringBuilder params = new StringBuilder();
                params.append(addToPostParams(ACCESS_CODE, getIntent().getStringExtra(ACCESS_CODE)));
                params.append(addToPostParams(MERCHANT_ID, getIntent().getStringExtra(MERCHANT_ID)));
                params.append(addToPostParams(ORDER_ID, getIntent().getStringExtra(ORDER_ID)));
                //params.append(addToPostParams(ORDER_ID, String.valueOf(randInt(0, 9999999))));
                params.append(addToPostParams(REDIRECT_URL, getIntent().getStringExtra(REDIRECT_URL)));
                params.append(addToPostParams(CANCEL_URL, getIntent().getStringExtra(CANCEL_URL)));
                params.append(addToPostParams(ENC_VAL, URLEncoder.encode(encVal)));

                String vPostParams = params.substring(0, params.length() - 1);
                mWebView.postUrl(TRANS_URL, EncodingUtils.getBytes(vPostParams, "UTF-8"));
            } catch (Exception e) {
                Log.e(e.getMessage());
                onPaymentError();
            }
        }
    }
}