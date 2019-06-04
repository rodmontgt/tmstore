package com.twist.tmstore;

import android.annotation.TargetApi;
import android.app.ProgressDialog;
import android.content.ComponentName;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.http.SslError;
import android.os.Build;
import android.os.Bundle;
import android.support.v7.app.AlertDialog;
import android.util.Base64;
import android.view.MenuItem;
import android.webkit.JavascriptInterface;
import android.webkit.SslErrorHandler;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.Log;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.utils.URLEncodedUtils;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.HttpProtocolParams;
import org.apache.http.util.EntityUtils;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.security.KeyFactory;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.PublicKey;
import java.security.spec.X509EncodedKeySpec;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Random;

import javax.crypto.Cipher;

/**
 * Created by Twist Mobile on 02-03-2017.
 */

public abstract class BasePaymentActivity extends BaseActivity {

    private AlertDialog mPaymentCancelDialog;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    protected void onPaymentSuccess() {
        ComponentName component = getCallingActivity();
        if (component != null) {
            Intent intent = new Intent(this, component.getClass());
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            setResult(RESULT_OK, intent);
        }
        finish();
    }

    protected void onPaymentSuccess(int orderId) {
        ComponentName component = getCallingActivity();
        if (component != null) {
            Intent intent = new Intent(this, component.getClass());
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            intent.putExtra(Extras.ORDER_ID, orderId);
            setResult(RESULT_OK, intent);
        }
        finish();
    }

    protected void onPaymentError() {
        ComponentName componentName = getCallingActivity();
        if (componentName != null) {
            Intent intent = new Intent(this, componentName.getClass());
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            setResult(RESULT_CANCELED, intent);
        }
        finish();
    }

    protected void postWebRequest(WebView webView, String url, Collection<Map.Entry<String, String>> postData) {
        StringBuilder sb = new StringBuilder();
        sb.append("<html><head></head>");
        sb.append("<body onload='form1.submit()'>");
        sb.append(String.format("<form id='form1' action='%s' method='%s'>", url, "post"));
        for (Map.Entry<String, String> item : postData) {
            sb.append(String.format("<input name='%s' type='hidden' value='%s' />", item.getKey(), item.getValue()));
        }
        sb.append("</form></body></html>");
        webView.loadData(sb.toString(), "text/html", "utf-8");
    }

    public static String encrypt(final String data) {
        return Base64.encodeToString(data.getBytes(), Base64.NO_WRAP);
    }

    protected String hashCal(String type, String str) {
        byte[] hashSequence = str.getBytes();
        StringBuilder hexString = new StringBuilder();
        try {
            MessageDigest algorithm = MessageDigest.getInstance(type);
            algorithm.reset();
            algorithm.update(hashSequence);
            byte messageDigest[] = algorithm.digest();
            for (int i = 0; i < messageDigest.length; i++) {
                String hex = Integer.toHexString(0xFF & messageDigest[i]);
                if (hex.length() == 1)
                    hexString.append("0");
                hexString.append(hex);
            }
        } catch (NoSuchAlgorithmException ignored) {
        }
        return hexString.toString();
    }

    protected String rsaEncrypt(String plainText, String key) {
        try {
            PublicKey publicKey = KeyFactory.getInstance("RSA").generatePublic(new X509EncodedKeySpec(Base64.decode(key, Base64.DEFAULT)));
            Cipher cipher = Cipher.getInstance("RSA/ECB/PKCS1Padding");
            cipher.init(Cipher.ENCRYPT_MODE, publicKey);
            return Base64.encodeToString(cipher.doFinal(plainText.getBytes("UTF-8")), Base64.DEFAULT);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    protected String addToPostParams(String paramKey, String paramValue) {
        if (paramValue != null)
            return paramKey.concat("=").concat(paramValue).concat("&");
        return "";
    }

    public static int randInt(int min, int max) {
        // Usually this should be a field rather than a method variable so
        // that it is not re-seeded every call.
        Random rand = new Random();
        // nextInt is normally exclusive of the top value,
        // so add 1 to make it inclusive
        int randomNum = rand.nextInt((max - min) + 1) + min;
        return randomNum;
    }

    protected void handleSslError(final SslErrorHandler sslErrorHandler, String baseURL, final ProgressDialog progressDialog) {
        if (mPaymentCancelDialog != null && mPaymentCancelDialog.isShowing()) {
            mPaymentCancelDialog.dismiss();
        }

        // Handle SSL Certificate error with Ok & Cancel dialog to comply with Play Store Security Policy
        if (progressDialog.isShowing()) {
            progressDialog.dismiss();
        }

        String message = getString(L.string.security_cert_dialog_msg) + "\n<b>" + baseURL + "</b>";
        AlertDialog.Builder alertDialog = new AlertDialog.Builder(this);
        alertDialog.setTitle(getString(L.string.security_cert_dialog_title));
        alertDialog.setMessage(HtmlCompat.fromHtml(message));
        alertDialog.setPositiveButton(getString(L.string.proceed), new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                if (!isFinishing()) {
                    sslErrorHandler.proceed();
                    progressDialog.show();
                }
            }
        });
        alertDialog.setNegativeButton(getString(L.string.cancel), new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                sslErrorHandler.cancel();
                onPaymentError();
            }
        });
        if (!isFinishing()) {
            alertDialog.show();
        }
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            onBackPressed();
        }
        return super.onOptionsItemSelected(item);
    }


    @Override
    public void onBackPressed() {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle(L.getString(L.string.warning));
        builder.setMessage(L.getString(L.string.question_cancel_transaction));
        builder.setPositiveButton(L.getString(L.string.btn_yes), new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                finish();
            }
        });
        builder.setNegativeButton(L.getString(L.string.btn_no), new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
            }
        });
        mPaymentCancelDialog = builder.create();
        mPaymentCancelDialog.show();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mPaymentCancelDialog != null && mPaymentCancelDialog.isShowing()) {
            mPaymentCancelDialog.dismiss();
        }
    }

    public class PaymentWebResponseHandler {
        public void onStarted(WebView view, String url) {
            //TODO implement in child if needed
        }

        public void onRedirected(WebView view, String url) {
            //TODO implement in child if needed
        }

        public void onFinished(WebView view, String url) {
            //TODO implement in child if needed
        }
    }

    public class PaymentWebClient extends WebViewClient {
        private String baseURL;
        private PaymentWebResponseHandler responseHandler;
        private ProgressDialog progressDialog;

        public PaymentWebClient(String baseURL, PaymentWebResponseHandler paymentWebResponseHandler) {
            this.baseURL = baseURL;
            this.responseHandler = paymentWebResponseHandler;
            progressDialog = new ProgressDialog(BasePaymentActivity.this);
            progressDialog.setCanceledOnTouchOutside(false);
            progressDialog.setCancelable(true);
            progressDialog.setMessage(L.getString(L.string.please_wait));
            progressDialog.setOnShowListener(dialog -> Helper.stylize(progressDialog));
        }

        @Override
        public void onPageStarted(WebView view, String url, Bitmap favicon) {
            super.onPageStarted(view, url, favicon);
            Log.d("PaymentWebClient::onPageStarted => " + url);
            showProgress();
            if (responseHandler != null) {
                responseHandler.onStarted(view, url);
            }
        }

        @SuppressWarnings("deprecation")
        @Override
        public boolean shouldOverrideUrlLoading(WebView view, String url) {
            Log.d("PaymentWebClient::shouldOverrideUrlLoading => " + url);
            showProgress();
            if (responseHandler != null) {
                responseHandler.onRedirected(view, url);
            }
            return super.shouldOverrideUrlLoading(view, url);
        }

        @TargetApi(Build.VERSION_CODES.N)
        @Override
        public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
            Log.d("PaymentWebClient::shouldOverrideUrlLoading => " + request.getUrl().toString());
            showProgress();
            if (responseHandler != null) {
                responseHandler.onRedirected(view, request.getUrl().toString());
            }
            return super.shouldOverrideUrlLoading(view, request);
        }

        @SuppressWarnings("deprecation")
        @Override
        public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
            super.onReceivedError(view, errorCode, description, failingUrl);
            Log.d("PaymentWebClient::onReceivedError => " + failingUrl + " [Error Description => " + description + ", Error Code =>" + errorCode + "]");
            hideProgress();
            BasePaymentActivity.this.onPaymentError();
        }

        @TargetApi(Build.VERSION_CODES.N)
        @Override
        public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
            super.onReceivedError(view, request, error);
            Log.d("PaymentWebClient::onReceivedError => " + request.getUrl().toString() + " [Error Description => " + error.getDescription() + ", Error Code =>" + error.getErrorCode() + "]");
            hideProgress();

            //TODO patch to ignore temporary resource loading issue in PayUmoney Payment Gateway
            if (request.getUrl().toString().equals("https://media.dev.payumoney.com/media/css/payment/payment.css")) {
                return;
            }
			
            if (request.getUrl().toString().equals("https://auth/op/file/download?path=logo/2017/06/30/prod/81e38d51-5642-4ac5-bf4a-2169b98e7b40_logo.png&isLogo=1&fileType=jpg")) {
                return;
            }
            BasePaymentActivity.this.onPaymentError();
        }

        @Override
        public void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error) {
            super.onReceivedSslError(view, handler, error);
            Log.d("PaymentWebClient::onReceivedSslError => " + error.getUrl() + " [SSL Error => " + error.toString() + "]");
            handleSslError(handler, baseURL, progressDialog);
        }

        @Override
        public void onPageFinished(WebView view, String url) {
            super.onPageFinished(view, url);
            Log.d("PaymentWebClient::onPageFinished => " + url);
            hideProgress();
            if (responseHandler != null) {
                responseHandler.onFinished(view, url);
            }
        }

        private void showProgress() {
            if (!isFinishing()) {
                if (progressDialog != null && !progressDialog.isShowing()) {
                    progressDialog.show();
                }
            }
        }

        private void hideProgress() {
            if (!isFinishing()) {
                if (progressDialog != null && progressDialog.isShowing()) {
                    progressDialog.dismiss();
                }
            }
        }
    }

    public interface WebResponseListener {
        void onResponseReceived(String response);
    }

    public class MyWebInterface {
        WebResponseListener listener;

        public MyWebInterface(WebResponseListener listener) {
            this.listener = listener;
        }

        @JavascriptInterface
        public void showToast(String message) {
            if (listener != null) {
                listener.onResponseReceived(message);
            }
        }
    }

    public static class ServiceHandler {
        static String response = null;
        public final static int GET = 1;
        public final static int POST = 2;

        public String makeServiceCall(String url, int method, List<NameValuePair> params) {
            try {
                DefaultHttpClient httpClient = new DefaultHttpClient();
                HttpEntity httpEntity = null;
                HttpResponse httpResponse = null;
                httpClient.getParams().setParameter(
                        HttpProtocolParams.USER_AGENT,
                        "Mozilla/5.0 (Linux; U; Android-4.0.3; en-us; Galaxy Nexus Build/IML74K) AppleWebKit/535.7 (KHTML, like Gecko) CrMo/16.0.912.75 Mobile Safari/535.7"
                );

                // Checking http request method type
                if (method == POST) {
                    HttpPost httpPost = new HttpPost(url);
                    // adding post params
                    if (params != null) {
                        httpPost.setEntity(new UrlEncodedFormEntity(params));
                    }
                    httpResponse = httpClient.execute(httpPost);
                } else if (method == GET) {
                    // appending params to url
                    if (params != null) {
                        String paramString = URLEncodedUtils.format(params, "utf-8");
                        url += "?" + paramString;
                    }
                    HttpGet httpGet = new HttpGet(url);
                    httpResponse = httpClient.execute(httpGet);
                }
                httpEntity = httpResponse.getEntity();
                response = EntityUtils.toString(httpEntity);
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            } catch (ClientProtocolException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            }
            return response;
        }
    }
}