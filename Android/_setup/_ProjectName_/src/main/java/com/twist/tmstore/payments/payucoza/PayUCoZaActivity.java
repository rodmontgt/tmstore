package com.twist.tmstore.payments.payucoza;

/**
 * Created by Twist Mobile on 23-06-2017.
 */

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.twist.tmstore.BaseActivity;
import com.utils.Log;

public class PayUCoZaActivity extends BaseActivity implements IWsdl2CodeEvents {

    private static final String STAGING_API_URL = "https://staging.payu.co.za/service/PayUAPI";
    private static final String LIVE_API_URL = "https://secure.payu.co.za/service/PayUAPI";
    private String CANCEL_URL = "https://secure.payu.co.za/cancelRedirect.do";

    private String SUCCESS_URL = "http://www.google.com", FAIL_URL = "http://www.twitter.com/";


    private String USERNAME = "Staging Integration Store 3", PASSWORD = "WSAUFbw6";
    private String SAFEKEY = "{07F70723-1B96-4B97-B891-7BF708594EEA}";

    private String AMOUNT = "1000", DESCRIPTION = "Test Product", CURRENCY = "ZAR";
    private String EMAIL = "";
    private Activity activity;

    private Bundle bundle = null;

    private ProgressDialog progressDialog;

    private static SetTransactionResponseMessage setTransactionResponseMessage;
    //views
    WebView webview;
    GetTransactionResponseMessage getTransactionResponseMessage;
    private boolean isStaging = false;

    public SetTransaction buildSetTransaction() {
        SetTransaction setTransaction = new SetTransaction();
        setTransaction.set_Api("ONE_ZERO");
        if (bundle != null) {
            isStaging = Boolean.parseBoolean(bundle.getString("sandbox_mode"));
            if (!isStaging) {
                USERNAME = bundle.getString("username");
                PASSWORD = bundle.getString("password");
                SAFEKEY = bundle.getString("safekey");

                SUCCESS_URL = bundle.getString("surl");
                FAIL_URL = bundle.getString("furl");
            }
            EMAIL = bundle.getString("email");
            AMOUNT = bundle.getString("amount");
            DESCRIPTION = bundle.getString("order_id");
        }

        Log.d("PayUSA: isStaging=" + isStaging);
        Log.d("PayUSA: SUCCESS_URL=" + SUCCESS_URL);
        Log.d("PayUSA: FAIL_URL=" + FAIL_URL);
        Log.d("PayUSA: AMOUNT=" + AMOUNT);

        // AdditionalInfo
        additionalInfo addInfo = new additionalInfo();
        addInfo.merchantReference = "TwistMobile";
        addInfo.demoMode = "false";
        addInfo.cancelUrl = FAIL_URL;
        addInfo.returnUrlField = SUCCESS_URL;
        addInfo.notificationUrl = FAIL_URL;
        addInfo.supportedPaymentMethods = "CREDITCARD";
        addInfo.redirectChannel = "mobi";

        setTransaction.set_AdditionalInformation(addInfo);

        basket basket = new basket();
        Integer amount = Integer.parseInt(AMOUNT.substring(0, AMOUNT.indexOf('.')));
        basket.amountInCents = String.valueOf(amount * 100);
        basket.currencyCode = CURRENCY;
        basket.description = "OrderId : " + DESCRIPTION;


        setTransaction.set_Basket(basket);

        customer customer = new customer();
        //customer.firstName = FNAME;
        //customer.lastName = LNAME;
        customer.email = EMAIL;
        //customer.mobile = NUMBER;

        setTransaction.set_Customer(customer);


        setTransaction.set_Safekey(SAFEKEY);
        setTransaction.set_TransactionType(WS_Enums.transactionType.PAYMENT);

        return setTransaction;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        webview = new WebView(this);
        webview.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        setContentView(webview);
        activity = this;

        setupActionBarHomeAsUp("PayU");

        bundle = getIntent().getExtras();

        progressDialog = new ProgressDialog(this);
        progressDialog.setCanceledOnTouchOutside(false);
        progressDialog.setMessage("Loading...");
        progressDialog.show();

        new AsyncTask<Void, Void, Void>() {
            @Override
            protected Void doInBackground(Void... params) {
                callWebService();
                return null;
            }
        }.execute();


        webview.getSettings().setJavaScriptEnabled(true);
        webview.setWebViewClient(new WebViewClient() {
            public void onPageFinished(WebView view, String url) {
                progressDialog.dismiss();
            }

            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                if (url.startsWith(SUCCESS_URL)) {
                    //look for success/failure URL
                    EnterpriseAPISoapService srv1 = new EnterpriseAPISoapService((IWsdl2CodeEvents) activity);
                    srv1.setUrl(isStaging ? STAGING_API_URL : LIVE_API_URL);
                    additionalInfo additionalInfo = new additionalInfo();
                    additionalInfo.payUReference = setTransactionResponseMessage.payUReference;
                    additionalInfo.merchantReference = setTransactionResponseMessage.merchantReference;
                    try {
                        srv1.getTransactionAsync("ONE_ZERO", SAFEKEY, additionalInfo, USERNAME, PASSWORD);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    return true;
                }
                if (url.startsWith(FAIL_URL)) {
                    Intent intent = new Intent();
                    setResult(RESULT_CANCELED, intent);
                    finish();
                    return true;
                }

                if (url.startsWith(CANCEL_URL)) {
                    Intent intent = new Intent();
                    setResult(RESULT_CANCELED, intent);
                    finish();
                    return true;
                }
                return true;
            }
        });
    }

    @Override
    protected void onActionBarRestored() {
    }

    public void callWebService() {
        try {
            SetTransaction setTran = buildSetTransaction();
            EnterpriseAPISoapService srv1 = new EnterpriseAPISoapService(this);
            srv1.setUrl(isStaging ? STAGING_API_URL : LIVE_API_URL);
            setTransactionResponseMessage = srv1.setTransaction(setTran.get_Api(), setTran.get_SafeKey(), setTran.get_TransactionType(), true, false, false,
                    setTran.get_AdditionalInfo(), setTran.get_Customer(), setTran.get_baBasket(), null, null, null, null, null, null, null, null, null, null, null, null, USERNAME, PASSWORD);

            webview.post(new Runnable() {
                @Override
                public void run() {
                    if (setTransactionResponseMessage != null) {
                        if (isStaging)
                            webview.loadUrl("https://staging.payu.co.za/rpp.do?PayUReference=" + setTransactionResponseMessage.payUReference);
                        else
                            webview.loadUrl("https://secure.payu.co.za/rpp.do?PayUReference=" + setTransactionResponseMessage.payUReference);
                    }
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void Wsdl2CodeStartedRequest() {
        Log.e("Wsdl2Code", "Wsdl2CodeStartedRequest");
    }

    @Override
    public void Wsdl2CodeFinished(String methodName, Object Data) {
        Log.e("Wsdl2Code", "Wsdl2CodeFinished");
        Log.e("Wsdl2Code", methodName);

        Log.d("PayUSA: Wsdl2CodeFinished=" + methodName);
        if (methodName.equals("getTransaction")) {
            getTransactionResponseMessage = ((GetTransactionResponseMessage) Data);

            if (getTransactionResponseMessage != null && getTransactionResponseMessage.successful) {
                Log.d("PayUSA: getTransactionResponseMessage=" + getTransactionResponseMessage.toString());
                Intent intent = new Intent();
                intent.putExtra("result", getTransactionResponseMessage.toString());
                setResult(RESULT_OK, intent);
                finish();
            } else {
                Log.d("PayUSA: getTransactionResponseMessage= is null or not successfull!");
                Toast.makeText(activity, "Aah, payment failed!", Toast.LENGTH_SHORT).show();
                Intent intent = new Intent();
                intent.putExtra("result", getTransactionResponseMessage.toString());
                setResult(RESULT_CANCELED, intent);
                finish();
            }
        }
    }

    @Override
    public void Wsdl2CodeFinishedWithException(Exception ex) {
        Log.e("Wsdl2Code", "Wsdl2CodeFinishedWithException");
        Log.d("PayUSA: Wsdl2CodeFinishedWithException=");
    }

    @Override
    public void Wsdl2CodeEndedRequest() {
        Log.e("Wsdl2Code", "Wsdl2CodeEndedRequest");
    }
}

