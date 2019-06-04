package com.twist.tmstore.payments;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;

import com.eghl.sdk.EGHL;
import com.eghl.sdk.ELogger;
import com.eghl.sdk.params.PaymentParams;
import com.twist.tmstore.BasePaymentActivity;
import com.twist.tmstore.BuildConfig;
import com.twist.tmstore.R;
import com.utils.Log;

import java.text.DecimalFormat;

/**
 * Created by Twist Mobile on 11/07/2017.
 */

public class PaymentActivity extends BasePaymentActivity {
    private EGHL eghl;
    private String baseUrl = "";
    private String merchant_name;
    private String password;
    private String service_id;
    private String transaction_type;
    private String payment_method;
    private String orderid;
    private String amount;
    private String name;
    private String email;
    private String phone_number;
    private String currency_code;

    @SuppressLint({"AddJavascriptInterface", "SetJavaScriptEnabled", "JavascriptInterface"})
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        eghl = EGHL.getInstance();
        ELogger.setLoggable(BuildConfig.DEBUG);

        Bundle bundle = getIntent().getExtras();
        try {
            if (bundle != null) {
                String title = bundle.getString("title");
                setupActionBarHomeAsUp(TextUtils.isEmpty(title) ? "Bitbucket EGHL" : title);
                baseUrl = bundle.getString("baseurl");
                merchant_name = bundle.getString("merchant_name");
                password = bundle.getString("password");
                service_id = bundle.getString("service_id");
                transaction_type = bundle.getString("transaction_type");
                payment_method = bundle.getString("payment_method");
                orderid = bundle.getString("order_id");
                name = bundle.getString("first_name") + " " + bundle.getString("last_name");
                email = bundle.getString("email");
                phone_number = bundle.getString("phone");
                currency_code = bundle.getString("currency_code");
                amount = new DecimalFormat(".00").format(bundle.getFloat("amount"));
                openExecutePaymentGateway();
            }
        } catch (Exception e) {
            e.printStackTrace();
            onPaymentError();
        }
    }

    @Override
    protected void onActionBarRestored() {
    }

    private void openExecutePaymentGateway() {
        PaymentParams.Builder params = new PaymentParams.Builder()
                .setPaymentGateway(baseUrl)
                .setPaymentMethod(payment_method)    //ANY // DD // CC
                .setPaymentId(orderid)
                .setMerchantName(merchant_name) // GHL ePayment
                .setPassword(password)      //sit12345
                .setToken("")
                .setTokenType("")
                .setMerchantReturnUrl("SDK")//
                .setServiceId(service_id)   // SIT // OM2
                .setPageTimeout("500")      //500
                .setPaymentDesc(getString(R.string.app_name))
                .setTransactionType(transaction_type) //SALE  // AUTH
                .setOrderNumber(orderid)    //cnasit
                .setAmount(amount)
                .setLanguageCode("EN")
                .setCurrencyCode(currency_code)
                .setCustName(name)
                .setCustEmail(email)
                .setCustPhone(phone_number)
                .setTriggerReturnURL(true);
        Bundle paymentParams = params.build();
        eghl.executePayment(paymentParams, PaymentActivity.this);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        Log.d("Bitbucket => request code " + requestCode + " resultcode " + resultCode);
        if (requestCode == EGHL.REQUEST_PAYMENT && data != null) {
            Log.d("Bitbucket =>  TxnStatus = " + data.getIntExtra(EGHL.TXN_STATUS, EGHL.TRANSACTION_NO_STATUS) + "\n" + "TxnMessage = " + data.getStringExtra(EGHL.TXN_MESSAGE) + "\nRaw Response:\n" + data.getStringExtra(EGHL.RAW_RESPONSE));
            switch (resultCode) {
                case EGHL.TRANSACTION_SUCCESS:
                    Log.d("Bitbucket =>  Transaction payment successful" + data.toString());
                    onPaymentSuccess();
                    break;
                case EGHL.TRANSACTION_AUTHORIZED:
                    Log.d("Bitbucket =>  Transaction Payment Authorized => " + data.toString());
                    break;
                case EGHL.TRANSACTION_FAILED:
                case EGHL.TRANSACTION_CANCELLED:
                default:
                    Log.e("Bitbucket =>  Transaction payment failed => " + data.toString());
                    onPaymentError();
                    break;
            }
        } else if (resultCode == EGHL.TRANSACTION_CANCELLED) {
            onPaymentError();
        } else {
            onBackPressed();
        }
    }
}
