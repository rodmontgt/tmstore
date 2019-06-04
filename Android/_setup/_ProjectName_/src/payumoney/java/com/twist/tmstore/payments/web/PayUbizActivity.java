package com.twist.tmstore.payments.web;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.text.TextUtils;

import com.payu.india.Interfaces.OneClickPaymentListener;
import com.payu.india.Model.PaymentParams;
import com.payu.india.Model.PayuConfig;
import com.payu.india.Model.PayuHashes;
import com.payu.india.Payu.Payu;
import com.payu.india.Payu.PayuConstants;
import com.payu.payuui.Activity.PayUBaseActivity;
import com.twist.tmstore.BasePaymentActivity;
import com.twist.tmstore.R;
import com.utils.Log;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.ProtocolException;
import java.net.URL;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Random;

public class PayUbizActivity extends BasePaymentActivity implements OneClickPaymentListener {

    private final String TAG = PayUbizActivity.class.getSimpleName();
    private PaymentParams mPaymentParams;
    private PayuConfig payuConfig;

    private String mMerchantKey;
    private String mSuccessUrl = "";
    private String mFailedUrl = "";
    private String mHashUrl = "";
    private String mTitle = "";
    private String mProductInfo = "My Product";
    private String mTxnId;
    private String mFirstName;
    private String mEmailId;
    private String mUserCredentials;
    private int mEnvironment = PayuConstants.PRODUCTION_ENV;
    private double mAmount;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        //TODO Must write below code in your activity to set up initial context for PayU
        Payu.setInstance(this);

        Bundle bundle = getIntent().getExtras();

        mTitle = bundle.getString("title");

        setupActionBarHomeAsUp(TextUtils.isEmpty(mTitle) ? "PayUbiz" : mTitle);

        mMerchantKey = bundle.getString("merchant_key");
        mFirstName = bundle.getString("name");
        mEmailId = bundle.getString("email");
        mAmount = bundle.getFloat("amount");
        mSuccessUrl = bundle.getString("surl");
        mFailedUrl = bundle.getString("furl");
        mHashUrl = bundle.getString("hurl");
        mAmount = new BigDecimal(mAmount).setScale(0, RoundingMode.UP).intValue();

        launchPayUBizFlow();
    }

    @Override
    protected void onActionBarRestored() {
    }

    private void launchPayUBizFlow() {

        mUserCredentials = mMerchantKey + ":" + mEmailId;

        long id = new Random().nextInt() + System.currentTimeMillis() / 1000L;
        mTxnId = hashCal("SHA-256", String.valueOf(id)).substring(0, 20);

        //TODO Below are mandatory params for hash generation
        mPaymentParams = new PaymentParams();
        mPaymentParams.setKey(mMerchantKey);
        mPaymentParams.setAmount(String.valueOf(mAmount));
        mPaymentParams.setProductInfo(mProductInfo);
        mPaymentParams.setFirstName(mFirstName);
        mPaymentParams.setEmail(mEmailId);
        mPaymentParams.setTxnId(mTxnId);
        mPaymentParams.setSurl(mSuccessUrl);
        mPaymentParams.setFurl(mFailedUrl);
        mPaymentParams.setUdf1("udf1");
        mPaymentParams.setUdf2("udf2");
        mPaymentParams.setUdf3("udf3");
        mPaymentParams.setUdf4("udf4");
        mPaymentParams.setUdf5("udf5");
        mPaymentParams.setUserCredentials(mUserCredentials);

        payuConfig = new PayuConfig();
        payuConfig.setEnvironment(mEnvironment);

        generateHashFromServer(mPaymentParams);
    }

    public void generateHashFromServer(PaymentParams paymentParam) {
        StringBuilder postParamsBuffer = new StringBuilder();
        postParamsBuffer.append(concatParams(PayuConstants.KEY, paymentParam.getKey()));
        postParamsBuffer.append(concatParams(PayuConstants.AMOUNT, paymentParam.getAmount()));
        postParamsBuffer.append(concatParams(PayuConstants.TXNID, paymentParam.getTxnId()));
        postParamsBuffer.append(concatParams(PayuConstants.EMAIL, null == paymentParam.getEmail() ? "" : paymentParam.getEmail()));
        postParamsBuffer.append(concatParams(PayuConstants.PRODUCT_INFO, paymentParam.getProductInfo()));
        postParamsBuffer.append(concatParams(PayuConstants.FIRST_NAME, null == paymentParam.getFirstName() ? "" : paymentParam.getFirstName()));
        postParamsBuffer.append(concatParams(PayuConstants.UDF1, paymentParam.getUdf1() == null ? "" : paymentParam.getUdf1()));
        postParamsBuffer.append(concatParams(PayuConstants.UDF2, paymentParam.getUdf2() == null ? "" : paymentParam.getUdf2()));
        postParamsBuffer.append(concatParams(PayuConstants.UDF3, paymentParam.getUdf3() == null ? "" : paymentParam.getUdf3()));
        postParamsBuffer.append(concatParams(PayuConstants.UDF4, paymentParam.getUdf4() == null ? "" : paymentParam.getUdf4()));
        postParamsBuffer.append(concatParams(PayuConstants.UDF5, paymentParam.getUdf5() == null ? "" : paymentParam.getUdf5()));
        postParamsBuffer.append(concatParams(PayuConstants.USER_CREDENTIALS, paymentParam.getUserCredentials() == null ? PayuConstants.DEFAULT : paymentParam.getUserCredentials()));

        // for offer_key
        if (null != paymentParam.getOfferKey())
            postParamsBuffer.append(concatParams(PayuConstants.OFFER_KEY, paymentParam.getOfferKey()));

        String postParams = postParamsBuffer.charAt(postParamsBuffer.length() - 1) == '&' ? postParamsBuffer.substring(0, postParamsBuffer.length() - 1) : postParamsBuffer.toString();

        // lets make an api call
        GetHashesFromServerTask getHashesFromServerTask = new GetHashesFromServerTask();
        getHashesFromServerTask.execute(postParams);
    }

    private class GetHashesFromServerTask extends AsyncTask<String, String, PayuHashes> {
        private ProgressDialog progressDialog;

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            progressDialog = new ProgressDialog(PayUbizActivity.this);
            progressDialog.setMessage("Please wait...");
            progressDialog.show();
        }

        @Override
        protected PayuHashes doInBackground(String... postParams) {
            PayuHashes payuHashes = new PayuHashes();
            try {
                URL url = new URL(mHashUrl);
                String postParam = postParams[0];

                byte[] postParamsByte = postParam.getBytes("UTF-8");

                HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("POST");
                conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
                conn.setRequestProperty("Content-Length", String.valueOf(postParamsByte.length));
                conn.setDoOutput(true);
                conn.getOutputStream().write(postParamsByte);

                InputStream responseInputStream = conn.getInputStream();
                StringBuilder responseStringBuffer = new StringBuilder();
                byte[] byteContainer = new byte[1024];
                for (int i; (i = responseInputStream.read(byteContainer)) != -1; ) {
                    responseStringBuffer.append(new String(byteContainer, 0, i));
                }

                JSONObject response = new JSONObject(responseStringBuffer.toString());
                Iterator<String> payuHashIterator = response.keys();
                while (payuHashIterator.hasNext()) {
                    String key = payuHashIterator.next();
                    switch (key) {
                        case "payment_hash":
                            payuHashes.setPaymentHash(response.getString(key));
                            break;
                        case "vas_for_mobile_sdk_hash":
                            payuHashes.setVasForMobileSdkHash(response.getString(key));
                            break;
                        case "payment_related_details_for_mobile_sdk_hash":
                            payuHashes.setPaymentRelatedDetailsForMobileSdkHash(response.getString(key));
                            break;
                        case "delete_user_card_hash":
                            payuHashes.setDeleteCardHash(response.getString(key));
                            break;
                        case "get_user_cards_hash":
                            payuHashes.setStoredCardsHash(response.getString(key));
                            break;
                        case "edit_user_card_hash":
                            payuHashes.setEditCardHash(response.getString(key));
                            break;
                        case "save_user_card_hash":
                            payuHashes.setSaveCardHash(response.getString(key));
                            break;
                        case "check_offer_status_hash":
                            payuHashes.setCheckOfferStatusHash(response.getString(key));
                            break;
                        default:
                            break;
                    }
                }
            } catch (MalformedURLException e) {
                e.printStackTrace();
            } catch (ProtocolException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            } catch (JSONException e) {
                e.printStackTrace();
            }
            return payuHashes;
        }

        @Override
        protected void onPostExecute(PayuHashes payuHashes) {
            super.onPostExecute(payuHashes);
            progressDialog.dismiss();
            launchSdkUI(payuHashes);
        }
    }

    public void launchSdkUI(PayuHashes payuHashes) {
        Intent intent = new Intent(this, PayUBaseActivity.class);
        intent.putExtra(PayuConstants.PAYU_CONFIG, payuConfig);
        intent.putExtra(PayuConstants.PAYMENT_PARAMS, mPaymentParams);
        intent.putExtra(PayuConstants.PAYU_HASHES, payuHashes);
        intent.putExtra(PayUBaseActivity.PAYU_THEME_ID, R.style.PayUbizTheme);
        startActivityForResult(intent, PayuConstants.PAYU_REQUEST_CODE);
        //Lets fetch all the one click card tokens first
        //fetchMerchantHashes(intent);
    }

    //TODO This method is used only if integrating One Tap Payments

    /**
     * This method fetches merchantHash and cardToken already stored on merchant server.
     */
    private void fetchMerchantHashes(final Intent intent) {
        final String postParams = "merchant_key=" + mMerchantKey + "&user_credentials=" + mUserCredentials;
        new AsyncTask<Void, Void, HashMap<String, String>>() {

            @Override
            protected HashMap<String, String> doInBackground(Void... params) {
                try {
                    //TODO Replace below url with your server side file url.
                    URL url = new URL("https://payu.herokuapp.com/get_merchant_hashes");

                    byte[] postParamsByte = postParams.getBytes("UTF-8");

                    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                    conn.setRequestMethod("GET");
                    conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
                    conn.setRequestProperty("Content-Length", String.valueOf(postParamsByte.length));
                    conn.setDoOutput(true);
                    conn.getOutputStream().write(postParamsByte);

                    InputStream responseInputStream = conn.getInputStream();
                    StringBuffer responseStringBuffer = new StringBuffer();
                    byte[] byteContainer = new byte[1024];
                    for (int i; (i = responseInputStream.read(byteContainer)) != -1; ) {
                        responseStringBuffer.append(new String(byteContainer, 0, i));
                    }
                    JSONObject response = new JSONObject(responseStringBuffer.toString());
                    HashMap<String, String> cardTokens = new HashMap<>();
                    JSONArray oneClickCardsArray = response.getJSONArray("data");
                    int arrayLength;
                    if ((arrayLength = oneClickCardsArray.length()) >= 1) {
                        for (int i = 0; i < arrayLength; i++) {
                            cardTokens.put(oneClickCardsArray.getJSONArray(i).getString(0), oneClickCardsArray.getJSONArray(i).getString(1));
                        }
                        return cardTokens;
                    }
                    // pass these to next activity
                } catch (JSONException e) {
                    e.printStackTrace();
                } catch (MalformedURLException e) {
                    e.printStackTrace();
                } catch (ProtocolException e) {
                    e.printStackTrace();
                } catch (UnsupportedEncodingException e) {
                    e.printStackTrace();
                } catch (IOException e) {
                    e.printStackTrace();
                }
                return null;
            }

            @Override
            protected void onPostExecute(HashMap<String, String> oneClickTokens) {
                super.onPostExecute(oneClickTokens);
                intent.putExtra(PayuConstants.ONE_CLICK_CARD_TOKENS, oneClickTokens);
                startActivityForResult(intent, PayuConstants.PAYU_REQUEST_CODE);
            }
        }.execute();
    }


    protected String concatParams(String key, String value) {
        return key + "=" + value + "&";
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == PayuConstants.PAYU_REQUEST_CODE) {
            if (resultCode == RESULT_OK && data != null) {
                if (!TextUtils.isEmpty(data.getStringExtra("payu_response"))) {
                    String payu_response = data.getStringExtra("payu_response");
                    try {
                        String status = new JSONObject(payu_response).getString("status");
                        if (status.equals("success")) {
                            onPaymentSuccess();
                        } else {
                            onPaymentError();
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                        onPaymentError();
                    }
                } else {
                    onPaymentError();
                }
            } else {
                Log.d(TAG, "PayUbiz =>  Transaction cancelled, no data returned.");
                onPaymentError();
            }
        } else {
            Log.d(TAG, "PayUbiz =>  Transaction cancelled, back key pressed.");
            onBackPressed();
        }
    }

    @Override
    public HashMap<String, String> getAllOneClickHash(String userCredentials) {
        return null;
    }

    @Override
    public void getOneClickHash(String cardToken, String merchantKey, String userCredentials) {
    }

    @Override
    public void saveOneClickHash(String cardToken, String oneClickHash) {
    }

    @Override
    public void deleteOneClickHash(String cardToken, String userCredentials) {
    }
}