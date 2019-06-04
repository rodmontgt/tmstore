package com.twist.tmstore.payments.web;

import android.os.Bundle;
import android.view.View;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.twist.dataengine.DataEngine;;
import com.twist.tmstore.BasePaymentActivity;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.twist.tmstore.WebLoginInterface;
import com.twist.tmstore.entities.AppUser;
import com.utils.JsonUtils;
import com.utils.Log;

import org.apache.http.util.EncodingUtils;

public class WebPayActivity extends BasePaymentActivity {

    private WebView mWebView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_web_pay);
        setupActionBarHomeAsUp(getString(L.string.proceed));
        mWebView = findViewById(R.id.web_view);
        initWebPayView();
        syncCartItems();
    }

    @Override
    protected void onActionBarRestored() {
    }

    private void initWebPayView() {
        mWebView.addJavascriptInterface(new WebLoginInterface(), "Android");
        mWebView.getSettings().setSaveFormData(true);
        mWebView.getSettings().setJavaScriptEnabled(true);
        mWebView.getSettings().setDatabaseEnabled(true);
        mWebView.getSettings().setDomStorageEnabled(true);
        mWebView.getSettings().setAllowFileAccess(true);
        mWebView.getSettings().setSupportMultipleWindows(true);
        mWebView.setVisibility(View.INVISIBLE);
        mWebView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                super.onPageFinished(view, url);
                hideProgress();
                if (url.contains(DataEngine.getDataEngine().url_cart_items)) {
                    Log.d("Cart synchronized.");
                    proceedCheckout();
                }
            }
        });
    }

    private void syncCartItems() {
        showProgress(getString(L.string.syncing_cart), false);
        String data = "cart_data=" + JsonUtils.prepareCartJson() + "&ship_data=" + JsonUtils.prepareShippingJson();
        mWebView.postUrl(DataEngine.getDataEngine().url_cart_items, EncodingUtils.getBytes(data, "BASE64"));
    }

    private void proceedCheckout() {
        mWebView.getSettings().setSaveFormData(true);
        mWebView.getSettings().setJavaScriptEnabled(true);
        mWebView.getSettings().setDatabaseEnabled(true);
        mWebView.getSettings().setDomStorageEnabled(true);
        mWebView.getSettings().setAllowFileAccess(true);
        mWebView.getSettings().setSupportMultipleWindows(true);
        mWebView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                Log.d("-- onPageFinished[" + url + "] -- ");
                super.onPageFinished(view, url);
                if (url.contains("/checkout")) {
                    /*
                    int currentCountryIndex = 0;
					int currentStateIndex = 0;
					TM_Country currentCountry = TM_Country.getByName(AppUser.getInstance().billing_address.country);
					if(currentCountry != null) {
						currentCountryIndex = TM_Country.getIndexOf(AppUser.getInstance().billing_address.country);
						currentStateIndex = currentCountry.getIndexOfState(AppUser.getInstance().billing_address.state);
						Log.d("-- currentCountryIndex:["+currentCountryIndex+"] --");
						Log.d("-- currentStateIndex:["+currentStateIndex+"] --");
						Log.d("-- currentCountry:["+currentCountry.name+"] --");
						Log.d("-- currentState:["+currentCountry.states.get(currentStateIndex)+"] --");
					}*/

                    if (AppUser.getInstance().billing_address != null) {
                        String autoFillUrl = "javascript:document.getElementById('billing_first_name').value = '" + AppUser.getInstance().billing_address.first_name + "';" +
                                "javascript:document.getElementById('billing_last_name').value = '" + AppUser.getInstance().billing_address.last_name + "';" +
                                "javascript:document.getElementById('billing_company').value = '" + AppUser.getInstance().billing_address.company + "';" +
                                "javascript:document.getElementById('billing_email').value = '" + AppUser.getInstance().billing_address.email + "';" +
                                "javascript:document.getElementById('billing_phone').value = '" + AppUser.getInstance().billing_address.phone + "';" +
                                //"javascript:document.getElementById('billing_country').selectedIndex = '"+currentCountryIndex+"';" +
                                //"javascript:document.getElementsByName('billing_country')[0].value = 'BR';" +
                                "javascript:document.getElementById('billing_address_1').value = '" + AppUser.getInstance().billing_address.address_1 + "';" +
                                "javascript:document.getElementById('billing_address_2').value = '" + AppUser.getInstance().billing_address.address_2 + "';" +
                                "javascript:document.getElementById('billing_city').value = '" + AppUser.getInstance().billing_address.city + "';" +
                                //"javascript:document.getElementById('billing_state').options["+currentStateIndex+"].selected=true;" +
                                //"javascript:document.getElementById('billing_state').value = '"+"AM"+"';" +
                                "javascript:document.getElementById('billing_postcode').value = '" + AppUser.getInstance().billing_address.postcode + "';" +
                                "javascript:document.getElementsByName('save_address')[0].click();";
                        Log.d("-- autoFillUrl: [" + autoFillUrl + "] --");
                        mWebView.loadUrl(autoFillUrl);
                    }
                } else {
                    mWebView.setVisibility(View.VISIBLE);
                }
                hideProgress();
            }
        });
        mWebView.addJavascriptInterface(new MyWebInterface(response -> {
            try {
                int orderId = Integer.parseInt(response.substring(response.indexOf("[") + 1, response.indexOf("]")));
                onPaymentSuccess(orderId);
            } catch (Exception e) {
                e.printStackTrace();
                onPaymentError();
            }
        }), "Android");
        showProgress(getString(L.string.please_wait));
        mWebView.loadUrl(DataEngine.getDataEngine().url_checkout);
    }

    @Override
    public void onBackPressed() {
        if (mWebView.canGoBack()) {
            mWebView.goBack();
        } else {
            super.onBackPressed();
        }
    }
}
