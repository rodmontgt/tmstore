package com.twist.tmstore.payments.web;

import android.app.ProgressDialog;
import android.os.Bundle;
import android.support.design.widget.Snackbar;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.twist.tmstore.BasePaymentActivity;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.utils.Helper;

import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserFactory;

import java.io.StringReader;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import com.twist.oauth.NetworkRequest;
import com.twist.oauth.NetworkResponse;

/**
 * Created by Twist Mobile on 10-03-2017.
 */

public class VcsCoZaActivity extends BasePaymentActivity {

    private static final String SERVER_URL = "https://www.vcs.co.za/vvonline/ccxmlauth.asp";
    private static final String TAG = VcsCoZaActivity.class.getSimpleName();

    private TextView amountTextView;
    private EditText cardHolderEditText;
    private EditText cardNumberEditText;
    private EditText cardCvcEditText;
    private EditText cardExpMonthEditText;
    private EditText cardExpYearEditText;
    private ProgressDialog progressDialog;

    private String mAmount;
    private String mCardHolder;
    private String mCardNumber;
    private String mCardCVC;
    private String mExpiryMonth;
    private String mExpiryYear;
    private String mMerchantId;
    private String mCurrency;
    private String mReference;
    private String mDescription;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_vcscoza);
        setupActionBarHomeAsUp("Virtual Card Services");

        Bundle bundle = getIntent().getExtras();
        if (bundle != null) {
            mMerchantId = getIntent().getStringExtra("merchant_id");
            mAmount = getIntent().getStringExtra("amount");
            mCurrency = getIntent().getStringExtra("currency").toLowerCase();
            mDescription = getIntent().getStringExtra("description");
        }

        amountTextView = (TextView) findViewById(R.id.text_amount);
        cardHolderEditText = (EditText) findViewById(R.id.edit_card_holder);
        cardNumberEditText = (EditText) findViewById(R.id.edit_card_number);
        cardCvcEditText = (EditText) findViewById(R.id.edit_cvc);
        cardExpMonthEditText = (EditText) findViewById(R.id.edit_expiry_month);
        cardExpYearEditText = (EditText) findViewById(R.id.edit_expiry_year);

//        if (BuildConfig.DEBUG) {
//            mMerchantId = "3958";
//            mDescription = "Goods";
//            mAmount = "10.0";
//            mCurrency = "bwp";
//            cardHolderEditText.setText("TMStore");
//            cardNumberEditText.setText("4242424242424242");
//            cardCvcEditText.setText("123");
//            cardExpMonthEditText.setText("01");
//            cardExpYearEditText.setText("18");
//            amountTextView.setText(mAmount);
//        }
        amountTextView.setText("Amount: " + mAmount + " " + mCurrency.toUpperCase());

        progressDialog = new ProgressDialog(this);
        progressDialog.setMessage(getString(L.string.please_wait));
        progressDialog.setCancelable(false);

        Button payButton = (Button) findViewById(R.id.button_pay);
        payButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onPayClick(v);
            }
        });
    }

    @Override
    protected void onActionBarRestored() {
    }

    private boolean isDataVerified(View view) {
        Helper.hideKeyboard(view);

        mCardHolder = cardHolderEditText.getText().toString();
        mCardNumber = cardNumberEditText.getText().toString();
        mCardCVC = cardCvcEditText.getText().toString();
        mExpiryMonth = cardExpMonthEditText.getText().toString();
        mExpiryYear = cardExpYearEditText.getText().toString();
        mReference = this.getUniqueReferenceID();

        if (TextUtils.isEmpty(mMerchantId)) {
            Snackbar.make(view, "Merchant ID is not valid", Snackbar.LENGTH_LONG).show();
            return false;
        }

        if (TextUtils.isEmpty(mCurrency)) {
            Snackbar.make(view, "Invalid currency", Snackbar.LENGTH_LONG).show();
            return false;
        }

        if (TextUtils.isEmpty(mAmount)) {
            Snackbar.make(view, "Invalid amount", Snackbar.LENGTH_LONG).show();
            return false;
        }

        if (TextUtils.isEmpty(mCardNumber) || mCardNumber.length() != 16) {
            Snackbar.make(view, "Card number must be 16 digit long", Snackbar.LENGTH_LONG).show();
            return false;
        }

        if (TextUtils.isEmpty(mCardHolder)) {
            Snackbar.make(view, "Name on Card can't be empty", Snackbar.LENGTH_LONG).show();
            return false;
        }

        if (mCardHolder.length() > 30) {
            Snackbar.make(view, "Name on Card can't be more than 30 characters", Snackbar.LENGTH_LONG).show();
            return false;
        }

        if (TextUtils.isEmpty(mCardCVC) || mCardCVC.length() != 3) {
            Snackbar.make(view, "CVC or CVV must be of 3 digit", Snackbar.LENGTH_LONG).show();
            return false;
        }

        if (TextUtils.isEmpty(mExpiryMonth) || mExpiryMonth.length() != 2) {
            Snackbar.make(view, "Card expiry month must be of 2 digit", Snackbar.LENGTH_LONG).show();
            return false;
        }

        if (TextUtils.isEmpty(mExpiryYear) || mExpiryYear.length() != 2) {
            Snackbar.make(view, "Card expiry year must be of 2 digit", Snackbar.LENGTH_LONG).show();
            return false;
        }
        return true;
    }

    private String getRequestData() {
        return "<?xml version=\"1.0\" ?>" +
                "<AuthorisationRequest>" +
                "<UserId>" + mMerchantId + "</UserId>" +
                "<Reference>" + mReference + "</Reference>" +
                "<Description>" + mDescription + "</Description>" +
                "<Amount>" + mAmount + "</Amount>" +
                "<Currency>" + mCurrency + "</Currency>" +
                "<CardholderName>" + mCardHolder + "</CardholderName>" +
                "<CardNumber>" + mCardNumber + "</CardNumber>" +
                "<ExpiryMonth>" + mExpiryMonth + "</ExpiryMonth>" +
                "<ExpiryYear>" + mExpiryYear + "</ExpiryYear>" +
                "<CardValidationCode>" + mCardCVC + "</CardValidationCode>" +
                "</AuthorisationRequest>";
    }

    private String getUniqueReferenceID() {
        // Returns 36 characters long unique string.
        String uuid = UUID.randomUUID().toString();
        StringBuilder sb = new StringBuilder(uuid);
        uuid = sb.reverse().toString().replaceAll("-", "");
        return uuid.substring(0, 25);
    }

    private String getResponseTag(String src) {
        try {
            XmlPullParserFactory factory = XmlPullParserFactory.newInstance();
            factory.setNamespaceAware(true);
            XmlPullParser parser = factory.newPullParser();
            parser.setInput(new StringReader(src));
            int eventType = parser.getEventType();
            String tag = "";
            while (eventType != XmlPullParser.END_DOCUMENT) {
                switch (eventType) {
                    case XmlPullParser.START_TAG: {
                        tag = parser.getName();
                        break;
                    }

                    case XmlPullParser.TEXT: {
                        if (tag.equals("Response")) {
                            return parser.getText().trim();
                        }
                        break;
                    }
                }
                eventType = parser.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }

    private void onPayClick(View view) {
        if (!isDataVerified(view)) {
            return;
        }

        progressDialog.show();
        Map<String, String> params = new HashMap<>();
        params.put("xmlMessage", getRequestData());
        NetworkRequest.makeCommonPostRequest(SERVER_URL, params, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse postResponse) {
                if (postResponse.succeed) {
                    if (!isFinishing()) {
                        progressDialog.dismiss();
                    }
                    String response = postResponse.msg;
                    Log.d(TAG, response);
                    String str = getResponseTag(response);
                    if (!TextUtils.isEmpty(str)) {
                        if (str.contains("APPROVED") && str.length() == 14) {
                            //Toast.makeText(VcsCoZaActivity.this, "Payment successful.", Toast.LENGTH_LONG).show();
                            onPaymentSuccess();
                        } else {
                            Toast.makeText(VcsCoZaActivity.this, str.substring(1), Toast.LENGTH_LONG).show();
                            onPaymentError();
                        }
                    } else {
                        //Toast.makeText(VcsCoZaActivity.this, "Payment failed.", Toast.LENGTH_LONG).show();
                        onPaymentError();
                    }
                } else {
                    Log.d(TAG, "Payment failed.");
                    if (!isFinishing()) {
                        progressDialog.dismiss();
                    }
                    onPaymentError();
                }
            }
        });
    }
}