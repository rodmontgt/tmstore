package com.twist.tmstore.payments.paystack;

import android.app.ProgressDialog;
import android.os.Bundle;
import android.support.design.widget.TextInputLayout;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;
import com.twist.tmstore.BasePaymentActivity;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.utils.Helper;
import com.utils.Log;

import java.io.IOException;

import co.paystack.android.Paystack;
import co.paystack.android.PaystackSdk;
import co.paystack.android.model.Card;
import co.paystack.android.model.Token;
import okhttp3.Interceptor;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;
import retrofit2.http.Body;
import retrofit2.http.POST;

public class PayStackActivity extends BasePaymentActivity {

    private class PaymentRequest {
        @SerializedName("token")
        @Expose
        public String token;
        @SerializedName("email")
        @Expose
        public String email;
        @SerializedName("amount")
        @Expose
        public Double amount;
        @SerializedName("reference")
        @Expose
        public String reference;
    }

    private String email = "";
    private float amount = 0;

    private EditText mEditCardNum;
    private EditText mEditCVV;
    private EditText mEditExpiryMonth;
    private EditText mEditExpiryYear;
    private ProgressDialog mProgressDialog;

    private Card card;
    private Retrofit retrofit;

    interface MyApiEndpointInterface {
        @POST("transaction/charge_token")
        Call<PaymentResponse> chargeUserInBackground(@Body PaymentRequest request);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_paystack);
        setupActionBarHomeAsUp("PayStack");

        Bundle extras = getIntent().getExtras();
        if (extras == null) {
            onPaymentError();
            return;
        }

        email = extras.getString("email");
        amount = extras.getFloat("amount");
        String currency = extras.getString("currency");
        if (currency != null && currency.equalsIgnoreCase("NGN")) {
            amount = amount * 100;
        }

        final String publicKey = extras.getString("publicKey");
        final String secretKey = extras.getString("secretKey");

        PaystackSdk.initialize(getApplicationContext());
        PaystackSdk.setPublishableKey(publicKey);

        mProgressDialog = new ProgressDialog(this);

        mEditCardNum = (EditText) findViewById(R.id.edit_card_number);
        ((TextInputLayout) findViewById(R.id.label_card_number)).setHint(getString(L.string.hint_card_number));

        mEditCVV = (EditText) findViewById(R.id.edit_card_cvv);
        ((TextInputLayout) findViewById(R.id.label_card_cvv)).setHint(getString(L.string.hint_card_cvv));

        mEditExpiryMonth = (EditText) findViewById(R.id.edit_card_expiry_month);
        ((TextInputLayout) findViewById(R.id.label_card_expiry_month)).setHint(getString(L.string.hint_card_expiry_month));

        mEditExpiryYear = (EditText) findViewById(R.id.edit_card_expiry_year);
        ((TextInputLayout) findViewById(R.id.label_card_expiry_year)).setHint(getString(L.string.hint_card_expiry_year));

        Button buttonPay = (Button) findViewById(R.id.button_pay);
        buttonPay.setText(getString(L.string.title_pay));
        Helper.stylize(buttonPay);
        buttonPay.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (isValid()) {
                    mProgressDialog.setMessage(getString(L.string.please_wait));
                    mProgressDialog.setCancelable(true);
                    mProgressDialog.setCanceledOnTouchOutside(true);
                    mProgressDialog.show();
                    createToken(card);
                }
            }
        });

        OkHttpClient.Builder builder = new OkHttpClient.Builder();
        builder.interceptors().add(new Interceptor() {
            @Override
            public okhttp3.Response intercept(Chain chain) throws IOException {
                Request newRequest = chain.request().newBuilder()
                        .addHeader("Authorization", "Bearer " + secretKey)
                        .addHeader("Content-Type", "application/json")
                        .build();
                return chain.proceed(newRequest);
            }
        });
        retrofit = new Retrofit.Builder()
                .baseUrl("https://api.paystack.co")
                .addConverterFactory(GsonConverterFactory.create())
                .client(builder.build())
                .build();
    }

    @Override
    protected void onActionBarRestored() {
    }

    private boolean isValid() {
        //validate fields
        String cardNum = mEditCardNum.getText().toString().trim();

        if (!Helper.isValidString(cardNum)) {
            mEditCardNum.setError(getString(L.string.error_empty_card_number));
            return false;
        }

        //build card object with ONLY the number, update the other fields later
        card = new Card.Builder(cardNum, 0, 0, "").build();

        if (!card.validNumber()) {
            mEditCardNum.setError(getString(L.string.error_invalid_card_number));
            return false;
        }

        //validate cvc
        String cvc = mEditCVV.getText().toString().trim();
        if (!Helper.isValidString(cvc)) {
            mEditCVV.setError(getString(L.string.error_empty_cvv));
            return false;
        }
        //update the cvc field of the card
        card.setCvc(cvc);

        //check that it's valid
        if (!card.validCVC()) {
            mEditCVV.setError(getString(L.string.error_invalid_cvv));
            return false;
        }

        //validate expiry month;
        String sMonth = mEditExpiryMonth.getText().toString().trim();
        int month = -1;
        try {
            month = Integer.parseInt(sMonth);
        } catch (Exception ignored) {
        }

        if (month < 1) {
            mEditExpiryMonth.setError(getString(L.string.error_invalid_month));
            return false;
        }

        card.setExpiryMonth(month);

        String sYear = mEditExpiryYear.getText().toString().trim();
        int year = -1;
        try {
            year = Integer.parseInt(sYear);
        } catch (Exception ignored) {
        }

        if (year < 1) {
            mEditExpiryYear.setError(getString(L.string.error_invalid_year));
            return false;
        }

        card.setExpiryYear(year);

        //validate expiry
        if (!card.validExpiryDate()) {
            String invalidExpiry = getString(L.string.error_invalid_expiry);
            mEditExpiryMonth.setError(invalidExpiry);
            mEditExpiryYear.setError(invalidExpiry);
            return false;
        }
        return card.isValid();
    }

    private void createToken(Card card) {
        PaystackSdk.createToken(card, new Paystack.TokenCallback() {
            @Override
            public void onCreate(Token token) {
                chargeUser(token);
            }

            @Override
            public void onError(Exception error) {
                if (mProgressDialog.isShowing()) {
                    mProgressDialog.dismiss();
                }
                onPaymentError();
            }
        });
    }

    private void chargeUser(Token token) {
        MyApiEndpointInterface apiService = retrofit.create(MyApiEndpointInterface.class);
        PaymentRequest request = new PaymentRequest();
        request.reference = String.valueOf(System.currentTimeMillis());
        request.token = token.token;
        request.email = email;
        request.amount = (double) amount;

        Call<PaymentResponse> call = apiService.chargeUserInBackground(request);
        call.enqueue(new Callback<PaymentResponse>() {
            @Override
            public void onResponse(Call<PaymentResponse> call, Response<PaymentResponse> response) {
                int statusCode = response.code();
                if (mProgressDialog.isShowing()) {
                    mProgressDialog.dismiss();
                }

                if (statusCode == 200) {
                    PaymentResponse paymentResponse = response.body();
                    Log.d("=== [" + paymentResponse.message + "] ===");
                    if (response.isSuccessful()) {
                        onPaymentSuccess();
                    } else {
                        onPaymentError();
                    }
                } else {
                    if (response.errorBody() != null) {
                        try {
                            Log.d(response.errorBody().string());
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    }
                    onPaymentError();
                }
            }

            @Override
            public void onFailure(Call<PaymentResponse> call, Throwable t) {
                Log.d("=== [" + "failed" + "] ===");
                onPaymentError();
            }
        });
    }
}
