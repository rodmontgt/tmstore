package com.twist.tmstore.payments.web;

import android.content.Context;
import android.graphics.Typeface;
import android.os.AsyncTask;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;

import com.stripe.android.Stripe;
import com.stripe.android.TokenCallback;
import com.stripe.android.model.Card;
import com.stripe.android.model.Token;
import com.twist.tmstore.BasePaymentActivity;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.utils.Base64Utils;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.Log;
import com.utils.Preferences;

import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class StripeActivity extends BasePaymentActivity {

    private static final String TAG = StripeActivity.class.getSimpleName();
    // Stripe accepts only integer payments and payment must be >= 50 cents

    private static final String KEY_CUSTOMER_DATA = "customer_data";

    Context mContext;
    private float amount = 0;
    private String currency = "";
    private String publishableKey = "";
    private String secretKey = "";
    private String chargeUrl = "";

    private LinearLayout new_card_layout;
    private EditText mEditCardNum;
    private EditText mEditCVV;
    private EditText mEditExpiryMonth;
    private EditText mEditExpiryYear;
    private View layout_saved_cards;
    private RadioGroup radio_group_saved_cards;
    private CheckBox chkSaveCardDetails;
    private boolean saveCardDetails = false;

    private Card mCard;
    private String cardNum;
    private String cvv;
    private int expiryMonth;
    private int expiryYear;

    private JSONArray customerJsonData = new JSONArray();
    private List<StripeCustomer> stripeCustomers = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_stripe);
        setupActionBarHomeAsUp("Stripe");
        mContext = this;
        Bundle extras = getIntent().getExtras();
        if (extras != null) {
            amount = extras.getFloat("amount");
            currency = extras.getString("currency");
            publishableKey = extras.getString("publishable_key");
            secretKey = extras.getString("secret_key");
            chargeUrl = extras.getString("save_card_url");
        }

        TextView mTotalAmountLabel = (TextView) findViewById(R.id.title_total_amount);
        mTotalAmountLabel.setText(getString(L.string.title_total_amount));

        TextView mTotalAmountText = (TextView) findViewById(R.id.text_total_amount);
        mTotalAmountText.setText(HtmlCompat.fromHtml(Helper.appendCurrency(amount)));

        TextView title_saved_cards = (TextView) findViewById(R.id.title_saved_cards);
        title_saved_cards.setText(getString(L.string.saved_cards));

        new_card_layout = (LinearLayout) findViewById(R.id.new_card_layout);
        new_card_layout.setVisibility(View.VISIBLE);

        mEditCardNum = (EditText) findViewById(R.id.edit_card_number);
        mEditCardNum.setHint(getString(L.string.hint_card_number));
        mEditCardNum.setOnTouchListener(onTouchListener);
        ((TextView) findViewById(R.id.title_card_number)).setText(getString(L.string.title_card_number));

        mEditCVV = (EditText) findViewById(R.id.edit_card_cvv);
        mEditCVV.setHint(getString(L.string.hint_card_cvv));
        mEditCVV.setOnTouchListener(onTouchListener);
        ((TextView) findViewById(R.id.title_card_cvv)).setText(getString(L.string.title_card_cvv));

        mEditExpiryMonth = (EditText) findViewById(R.id.edit_card_expiry_month);
        mEditExpiryMonth.setHint(getString(L.string.hint_card_expiry_month));
        mEditExpiryMonth.setOnTouchListener(onTouchListener);
        ((TextView) findViewById(R.id.title_card_expiry_month)).setText(getString(L.string.title_card_expiry_month));

        mEditExpiryYear = (EditText) findViewById(R.id.edit_card_expiry_year);
        mEditExpiryYear.setHint(getString(L.string.hint_card_expiry_year));
        mEditExpiryYear.setOnTouchListener(onTouchListener);
        ((TextView) findViewById(R.id.title_card_expiry_year)).setText(getString(L.string.title_card_expiry_year));

        chkSaveCardDetails = (CheckBox) findViewById(R.id.chk_save_card_details);
        chkSaveCardDetails.setText(L.getString(L.string.save_card_details));
        Helper.stylize(chkSaveCardDetails);
        chkSaveCardDetails.setChecked(false);
        chkSaveCardDetails.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                saveCardDetails = isChecked;
            }
        });

        Button buttonPay = (Button) findViewById(R.id.button_pay);
        buttonPay.setText(getString(L.string.title_pay));
        Helper.stylize(buttonPay);
        buttonPay.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                int id = radio_group_saved_cards.getCheckedRadioButtonId();
                if (id != -1) {
                    int index = findViewById(id).getId();
                    new StripeActivity.StripePayTask("", stripeCustomers.get(index).customer_id).execute();
                } else if (isValid()) {
                    mCard = new Card(cardNum, expiryMonth, expiryYear, cvv);
                    if (mCard.validateCard()) {
                        startPayment();
                    } else {
                        Helper.showErrorToast(getString(L.string.error_check_card_details), true);
                    }
                }
            }
        });

        layout_saved_cards = findViewById(R.id.layout_saved_cards);
        layout_saved_cards.setVisibility(View.GONE);
        radio_group_saved_cards = (RadioGroup) findViewById(R.id.radio_group_saved_cards);
        loadCustomerData();
    }

    public View.OnTouchListener onTouchListener = new View.OnTouchListener() {
        @Override
        public boolean onTouch(View v, MotionEvent event) {
            radio_group_saved_cards.clearCheck();
            return false;
        }
    };

    public void loadCustomerData() {
        stripeCustomers.clear();
        String customerData = Preferences.getString(Base64Utils.encode(KEY_CUSTOMER_DATA));
        if (!TextUtils.isEmpty(customerData)) {
            try {
                JSONArray arrayCd = new JSONArray(Base64Utils.decode(customerData));
                for (int i = 0; i < arrayCd.length(); i++) {
                    String customer_id = ((JSONObject) arrayCd.get(i)).getString("customer_id");
                    String last4 = ((JSONObject) arrayCd.get(i)).getString("last4");
                    if (!hasCustomer(last4)) {
                        stripeCustomers.add(new StripeCustomer(customer_id, last4));
                        customerJsonData.put(arrayCd.get(i));
                    }
                }
            } catch (JSONException e) {
                e.printStackTrace();
            }

            int index = 0;
            for (StripeCustomer customer : stripeCustomers) {
                if (customer.last4Digit.compareTo("") == 0) {
                    continue;
                }
                RadioButton radioButton = new RadioButton(this);
                Helper.setTextAppearance(this, radioButton, android.R.style.TextAppearance_Small);
                radioButton.setId(index);
                radioButton.setText("**** **** **** " + customer.last4Digit);
                radioButton.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
                radioButton.setPadding(Helper.DP(12), Helper.DP(12), Helper.DP(6), Helper.DP(6));
                Helper.stylize(radioButton);
                radioButton.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                    @Override
                    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                        buttonView.setTypeface(null, Typeface.NORMAL);
                        if (isChecked) {
                            buttonView.setTypeface(null, Typeface.BOLD);
                        }
                    }
                });

                radio_group_saved_cards.addView(radioButton);
                layout_saved_cards.setVisibility(View.VISIBLE);
                index++;
            }
        }
    }

    @Override
    protected void onActionBarRestored() {
    }

    private void startPayment() {
        try {
            showProgress(L.getString(L.string.please_wait), false);
            Stripe stripe = new Stripe(this, publishableKey);
            stripe.createToken(
                    mCard,
                    new TokenCallback() {
                        public void onSuccess(Token token) {
                            Log.d(TAG, token.toString());
                            new StripeActivity.StripePayTask(token.getId(), "").execute();
                        }

                        public void onError(Exception error) {
                            error.printStackTrace();
                            hideProgress();
                            onPaymentError();
                        }
                    }
            );
        } catch (Exception e) {
            e.printStackTrace();
            hideProgress();
            onPaymentError();
        }
    }

    private boolean isValid() {
        cardNum = mEditCardNum.getText().toString().trim();
        if (!Helper.isValidString(cardNum) || cardNum.length() < 10) {
            mEditCardNum.setError(getString(L.string.error_invalid_card_number));
            return false;
        }

        cvv = mEditCVV.getText().toString().trim();
        if (!Helper.isValidString(cvv)) {
            mEditCVV.setError(getString(L.string.error_invalid_cvv));
            return false;
        }

        String sMonth = mEditExpiryMonth.getText().toString().trim();
        try {
            expiryMonth = Integer.parseInt(sMonth);
        } catch (Exception ignored) {
            mEditExpiryMonth.setError(getString(L.string.error_invalid_month));
            return false;
        }

        String sYear = mEditExpiryYear.getText().toString().trim();
        try {
            expiryYear = Integer.parseInt(sYear);
            expiryYear += 2000;
        } catch (Exception ignored) {
            mEditExpiryYear.setError(getString(L.string.error_invalid_year));
            return false;
        }
        return true;
    }

    private class StripePayTask extends AsyncTask<Void, Void, String> {
        private final String token;
        private final String customerId;

        StripePayTask(String token, String customerId) {
            this.token = token;
            this.customerId = customerId;
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            showProgress(L.getString(L.string.please_wait), false);
        }

        @Override
        protected String doInBackground(Void... voids) {
            try {
                HttpClient httpClient = new DefaultHttpClient();
                HttpPost httpPost = new HttpPost(chargeUrl);
                List<NameValuePair> nameValuePair = new ArrayList<>();
                nameValuePair.add(new BasicNameValuePair("stripeToken", token));
                nameValuePair.add(new BasicNameValuePair("amount", String.valueOf(amount)));
                nameValuePair.add(new BasicNameValuePair("apikey", secretKey));
                nameValuePair.add(new BasicNameValuePair("currency", currency));
                nameValuePair.add(new BasicNameValuePair("description", ""));
                if (saveCardDetails && !TextUtils.isEmpty(customerId)) {
                    nameValuePair.add(new BasicNameValuePair("customer_id", customerId));
                }
                httpPost.setEntity(new UrlEncodedFormEntity(nameValuePair));
                HttpResponse httpResponse = httpClient.execute(httpPost);
                return EntityUtils.toString(httpResponse.getEntity());
            } catch (Exception e) {
                e.printStackTrace();
            }
            return null;
        }

        @Override
        protected void onPostExecute(String result) {
            super.onPostExecute(result);
            hideProgress();
            if (result != null && result.length() > 0) {
                if (result.contains("SUCCESS")) {
                    try {
                        JSONObject response = new JSONObject(result);
                        if (response.has("status") && response.getString("status").compareTo("SUCCESS") == 0) {
                            JSONArray customerDataJsonArray = response.getJSONArray("customer_data");
                            for (int i = 0; i < customerDataJsonArray.length(); i++) {

                                JSONObject customerDataJSONObject = customerDataJsonArray.getJSONObject(i);
                                String last4 = customerDataJSONObject.getString("last4");
                                if (!hasCustomer(last4)) {
                                    customerJsonData.put(customerDataJSONObject);
                                }
                            }
                            if (chkSaveCardDetails.isChecked() && saveCardDetails) {
                                String key = Base64Utils.encode(KEY_CUSTOMER_DATA);
                                String value = Base64Utils.encode(customerJsonData.toString());
                                Preferences.putString(key, value);
                            }
                            onPaymentSuccess();
                        } else {
                            Helper.showErrorToast(result);
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                        Helper.showErrorToast(result);
                    }
                } else {
                    Helper.showErrorToast(result);
                }
            } else {
                onPaymentError();
            }
        }
    }

    private boolean hasCustomer(String last4Digit) {
        for (StripeCustomer stripeCustomer : stripeCustomers) {
            if (stripeCustomer.last4Digit.compareTo(last4Digit) == 0)
                return true;
        }
        return false;
    }

    private class StripeCustomer {
        private String customer_id = "";
        private String last4Digit = "";

        StripeCustomer(String customer_id, String last4) {
            this.customer_id = customer_id;
            this.last4Digit = last4;
        }
    }
}