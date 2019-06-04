package com.twist.tmstore.payments.web;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.content.ContextCompat;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.parse.ParseObject;
import com.twist.tmstore.BasePaymentActivity;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.Log;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicHeader;
import org.apache.http.util.EntityUtils;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Locale;

/**
 * Created by Twist Mobile on 18-07-2017.
 */

public class SatispayActivity extends BasePaymentActivity {

    private static class Logger {
        static StringBuilder logStr = new StringBuilder();

        public static void d(String str) {
            logStr.append("\n\n\n").append(str);
            Log.d(str);
        }

        private static void clearLog() {
            logStr.setLength(0);
        }

        public static void sendLog(String userId) {
            if (enableDebugging && userId.equals(debugUserId)) {
                ParseObject parseObject = ParseObject.create("SatispayDebug");
                parseObject.put("user_id", userId);
                parseObject.put("log", logStr.toString());
                parseObject.saveInBackground();
            }
        }
    }

    private final String URL_AUTHENTICATED = "https://authservices.satispay.com/wally-services/protocol/authenticated";
    private final String URL_CREATE_USER = "https://authservices.satispay.com/online/v1/users";
    private final String URL_CREATE_CHARGE = "https://authservices.satispay.com/online/v1/charges";

    private float amount = 0;
    private String currency = "";
    private String phoneNumber = "";
    private String description = "";
    private String redirectUrl = "";
    private String chargeId = "";
    private String appId;
    private String securityBearer = "";
    private EditText mEditMobileNumber;

    //private boolean IS_TEST = false;

    private static boolean enableDebugging = false;
    private static String debugUserId = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_satispay);
        setupActionBarHomeAsUp("Satispay");

        Bundle extras = getIntent().getExtras();
        if (extras != null) {
            amount = extras.getFloat("amount");
            currency = extras.getString("currency");
            phoneNumber = extras.getString("phone_number");
            description = extras.getString("description");
            appId = extras.getString("app_id");
            securityBearer = extras.getString("security_bearer");
            redirectUrl = extras.getString("redirect_url");
            SatispayActivity.enableDebugging = extras.getBoolean("enable_debugging");
            SatispayActivity.debugUserId = extras.getString("debug_user_id");
            try {
                // check if redirect url not ends with / (back slash)
                if (redirectUrl != null && redirectUrl.charAt(redirectUrl.length() - 1) != '/') {
                    Logger.d("SatispayActivity:: redirect_url must end with / ( back slash).");
                }
            } catch (Exception e) {
                e.printStackTrace();
                if (redirectUrl != null && redirectUrl.charAt(redirectUrl.length() - 1) != '/') {
                    Logger.d("SatispayActivity:: Please check redirect_url in configuration.");
                }
            }
        }

        TextView totalAmountLabel = (TextView) findViewById(R.id.title_total_amount);
        totalAmountLabel.setText(getString(L.string.title_total_amount));

        TextView totalAmountText = (TextView) findViewById(R.id.text_total_amount);
        totalAmountText.setText(HtmlCompat.fromHtml(Helper.appendCurrency(amount)));

        //TODO strictly used only for test purpose.
//        if (IS_TEST || BuildConfig.DEBUG) {
//            phoneNumber = "+393488978530";
//            amount = 1;
//            currency = "EUR";
//            description = "TMStore Test Payment";
//            redirectUrl = "https://www.sexappealstore.it/";
//            //TODO CHARGE ID FOR TEST PURPOSE ONLY.
//            chargeId = "a67a19a4-2baa-4e55-af2e-e65ad2b172ea";
//
//            TM_CommonInfo.currency = "EUR";
//            TM_CommonInfo.currency_format = "€";
//            totalAmountText.setText(HtmlCompat.fromHtml(Helper.appendCurrency(amount / 100.0f)));
//        }

        mEditMobileNumber = (EditText) findViewById(R.id.edit_mobile_number);
        mEditMobileNumber.setText(phoneNumber);
        mEditMobileNumber.setHint(getString(L.string.hint_mobile_number));

        Drawable drawable = ContextCompat.getDrawable(this, R.drawable.ic_vc_mobile);
        Helper.stylize(drawable);
        mEditMobileNumber.setCompoundDrawablesWithIntrinsicBounds(drawable, null, null, null);
        Helper.stylize(mEditMobileNumber, false);

        Button buttonPay = (Button) findViewById(R.id.button_pay);
        buttonPay.setText(getString(L.string.title_pay));
        Helper.stylize(buttonPay);
        buttonPay.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (isValid()) {
                    Logger.clearLog();
                    GetUserTask task = new GetUserTask();
                    task.execute(phoneNumber);
                }
            }
        });
    }

    @Override
    protected void onActionBarRestored() {
    }

    private boolean isValid() {
        phoneNumber = mEditMobileNumber.getText().toString().trim();
        if (!Helper.isValidString(phoneNumber)) {
            mEditMobileNumber.setError(getString(L.string.error_invalid_mobile_number));
            return false;
        }

        if (!phoneNumber.startsWith("+")) {
            mEditMobileNumber.setError(getString(L.string.error_country_code_required));
            return false;
        }
        return true;
    }

    private String postRequestResponse(String requestUrl, String requestBody) throws Exception {
        HttpClient httpClient = new DefaultHttpClient();
        StringEntity stringEntity = new StringEntity(requestBody, "utf-8");
        HttpPost httpPost = new HttpPost(requestUrl);
        httpPost.addHeader(new BasicHeader("Authorization", "Bearer " + securityBearer));
        httpPost.addHeader(new BasicHeader("Content-Type", "application/json"));
        //httpPost.addHeader(new BasicHeader("x-satispay-skip-push", "false"));
        httpPost.setEntity(stringEntity);
        HttpResponse httpResponse = httpClient.execute(httpPost);
        return EntityUtils.toString(httpResponse.getEntity());
    }

    private String getRequestResponse(String requestUrl) throws Exception {
        HttpClient httpClient = new DefaultHttpClient();
        HttpGet httpGet = new HttpGet(requestUrl);
        httpGet.addHeader(new BasicHeader("Authorization", "Bearer " + securityBearer));
        httpGet.addHeader(new BasicHeader("Content-Type", "application/json"));
        //httpGet.addHeader(new BasicHeader("x-satispay-skip-push", "false"));
        HttpResponse httpResponse = httpClient.execute(httpGet);
        return EntityUtils.toString(httpResponse.getEntity());
    }

    private class GetUserTask extends AsyncTask<String, Void, String> {
        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            showProgress(getString(L.string.satispay_checking_user), false);
        }

        @Override
        protected String doInBackground(String... params) {
            try {
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("phone_number", params[0]);
                return postRequestResponse(URL_CREATE_USER, jsonObject.toString());
            } catch (Exception e) {
                e.printStackTrace();
            }
            return null;
        }

        @Override
        protected void onPostExecute(String result) {
            super.onPostExecute(result);
            Logger.d("Satispay::GetUserTask Response =>" + result);
            hideProgress();
            try {
                JSONObject jsonObject = new JSONObject(result);
                if (jsonObject.has("id") && jsonObject.has("uuid")) {
                    String id = jsonObject.getString("id");
                    String uuid = jsonObject.getString("uuid");
                    CreateChargeTask task = new CreateChargeTask();
                    task.execute(id, uuid);
                } else if (jsonObject.has("code") && jsonObject.has("message")) {
                    //TODO use code when need to use localized message.
                    //int code = jsonObject.getInt("code");
                    String message = jsonObject.getString("message");
                    Helper.showErrorToast(message);
                    Logger.d("GetUserTask::onPostExecute" + message);
                }
            } catch (JSONException e) {
                e.printStackTrace();
                Helper.showErrorToast(getString(L.string.satispay_error_checking_user));
                Logger.d("GetUserTask::onPostExecute json parsing failed.");
            }
        }
    }

    private class CreateChargeTask extends AsyncTask<String, Void, String> {
        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            showProgress(getString(L.string.satispay_creating_charge), false);
        }

        @Override
        protected String doInBackground(String... params) {
            try {
                // Satispay only supports EUR and amount is smallest unit of EUR hence multiply it with 100
                // Reference link : https://s3-eu-west-1.amazonaws.com/docs.online.satispay.com/index.html#create-a-charge
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("description", description);
                jsonObject.put("currency", currency);
                jsonObject.put("amount", amount * 100);
                jsonObject.put("user_id", params[0]);
                //TODO metadata is not required for now
                //jsonObject.put("metadata", "{}");
                jsonObject.put("required_success_email", true);
                jsonObject.put("expire_in", 60 * 2); // in seconds
                jsonObject.put("callback_url", redirectUrl + params[1]);

                return postRequestResponse(URL_CREATE_CHARGE, jsonObject.toString());
            } catch (Exception e) {
                e.printStackTrace();
            }
            return null;
        }

        @Override
        protected void onPostExecute(String result) {
            super.onPostExecute(result);
            hideProgress();
            Logger.d("Satispay::CreateChargeTask Response =>" + result);
            try {
                JSONObject jsonObject = new JSONObject(result);
                if (jsonObject.has("status") && jsonObject.has("paid")) {
                    String status = jsonObject.getString("status");
                    boolean paid = jsonObject.getBoolean("paid");
                    if (status.equals("REQUIRED") && !paid) {
                        chargeId = jsonObject.getString("uuid");
                        Logger.d("Received Charge Id for Satispay :: " + chargeId);
                        payUsingChargeId();
                    }
                }
            } catch (JSONException e) {
                e.printStackTrace();
                Helper.showErrorToast(getString(L.string.satispay_error_creating_charge));
                Logger.d("CreateChargeTask::onPostExecute json parsing failed. " + e.getMessage());
            }
        }
    }

    private class VerifyChargeTask extends AsyncTask<Void, Void, String> {
        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            showProgress(getString(L.string.satispay_verifying_charge), false);
        }

        @Override
        protected String doInBackground(Void... params) {
            try {
                return getRequestResponse(URL_CREATE_CHARGE + "/" + chargeId);
            } catch (Exception e) {
                e.printStackTrace();
            }
            return null;
        }

        @Override
        protected void onPostExecute(String result) {
            super.onPostExecute(result);
            hideProgress();
            Logger.d("Satispay::VerifyChargeTask =>" + result);
            boolean success = false;
            try {
                JSONObject jsonObject = new JSONObject(result);
                if (jsonObject.has("status") && jsonObject.has("paid")) {
                    String status = jsonObject.getString("status");
                    boolean paid = jsonObject.getBoolean("paid");
                    success = status.equals("SUCCESS") && paid;
                }
            } catch (JSONException e) {
                e.printStackTrace();
                Logger.d(e.getMessage());
            }
            handleResult(success);
        }
    }

    private static final int REQUEST_PAY_CHARGE_ID = 5471;

    private int mRetryCount = 0;

    private void payUsingChargeId() {
        if (isSatispayAvailable()) {
            Uri uriToCheck = SatispayIntent.uriForOpenApp(SatispayIntent.PRODUCTION_SCHEME);
            try {
                SatispayIntent.ApiStatus apiStatus = SatispayIntent.getApiStatus(this, SatispayIntent.PRODUCTION_APP_PACKAGE, uriToCheck);
                if (apiStatus.isValidRequest()) {
                    uriToCheck = SatispayIntent.uriForPayChargeId(SatispayIntent.PRODUCTION_SCHEME, appId, chargeId);
                    apiStatus = SatispayIntent.getApiStatus(this, SatispayIntent.PRODUCTION_APP_PACKAGE, uriToCheck);
                    if (apiStatus.isValidRequest()) {
                        Intent intent = SatispayIntent.payChargeId(SatispayIntent.PRODUCTION_SCHEME, appId, chargeId);
                        if (SatispayIntent.isIntentSafe(this, intent)) {
                            startActivityForResult(intent, REQUEST_PAY_CHARGE_ID);
                        } else {
                            Logger.d("Unable to open Satisapay");
                            handleResult(false);
                        }
                    } else {
                        String message = getErrorHint(apiStatus.getCode());
                        Helper.showErrorToast(message);
                        Logger.d(message);
                    }
                } else {
                    String message = getErrorHint(apiStatus.getCode());
                    Helper.showErrorToast(message);
                    Logger.d(message);
                }
            } catch (Exception e) {
                e.printStackTrace();
                if (mRetryCount <= 2) {
                    mRetryCount++;
                    payUsingChargeId();
                } else {
                    Helper.showErrorToast(getString(L.string.generic_error));
                    handleResult(false);
                }
            }
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_PAY_CHARGE_ID) {
            SatispayIntent.ApiStatus apiStatus = SatispayIntent.ApiStatus.from(resultCode, data);
            if (apiStatus.isValidRequest()) {
                VerifyChargeTask task = new VerifyChargeTask();
                task.execute();
            } else {
                String message = getErrorHint(apiStatus.getCode());
                Helper.showErrorToast(message);
                Logger.d(message);
                handleResult(false);
            }
        }
    }

    protected void handleResult(boolean success) {
        Logger.sendLog(phoneNumber);
        if (success)
            onPaymentSuccess();
        else
            onPaymentError();
    }

    private boolean isSatispayAvailable() {
        boolean available = SatispayIntent.isSatispayAvailable(this, SatispayIntent.PRODUCTION_SCHEME);
        if (!available) {
            Intent openPlayStoreIntent = SatispayIntent.openPlayStore(this, SatispayIntent.PRODUCTION_APP_PACKAGE);
            startActivity(openPlayStoreIntent);
        }
        return available;
    }

    private String getErrorHint(int errorCode) {
        String hint;
        switch (errorCode) {
            case SatispayIntent.RESULT_CANCEL_BAD_REQUEST:
                hint = "BAD REQUEST";
                break;
            case SatispayIntent.RESULT_CANCEL_FORBIDDEN:
                hint = "FORBIDDEN: User cannot proceed (User is logged?)";
                break;
            case SatispayIntent.RESULT_CANCEL_NOT_FOUND:
                hint = "NOT FOUND: Wrong URI or Satispay app cannot handle this URI yet";
                break;
            case SatispayIntent.RESULT_CANCEL_GONE:
                hint = "GONE: Indicates that the resource requested is no longer available and will not be available again";
                break;
            case SatispayIntent.RESULT_CANCEL_UPGRADE_REQUIRED:
                hint = "UPGRADE REQUIRED: Upgrade SatispayIntent SDK is REQUIRED!";
                break;
            case SatispayIntent.RESULT_CANCEL_TOO_MANY_REQUESTS:
                hint = "TOO MANY REQUESTS: Try again later";
                break;
            case SatispayIntent.RESULT_ERROR_UNKNOWN:
                hint = "UNKNOWN: Old Satispay app? Wrong appPackage? Other reason?";
                break;
            case SatispayIntent.RESULT_ERROR_SCHEME_NOT_FOUND:
                hint = "SCHEME NOT FOUND: Wrong scheme? Is Satispay installed? Restricted access?";
                break;
            default:
                hint = "NEW ERROR CODE: Try to update SatispayIntent SDK!";
                break;
        }
        return hint;
    }

    private static class SatispayIntent {
        public static final String PRODUCTION_APP_PACKAGE = "com.satispay.customer";
        public static final String PRODUCTION_SCHEME = "satispay";

        public static final String HOST = "external";

        public static final int RESULT_ERROR_SCHEME_NOT_FOUND = -1;
        public static final int RESULT_ERROR_UNKNOWN = 0;
        public static final int RESULT_OK_VALID_REQUEST = 200;
        public static final int RESULT_CANCEL_BAD_REQUEST = 400;
        public static final int RESULT_CANCEL_FORBIDDEN = 403;     // User cannot proceed
        public static final int RESULT_CANCEL_NOT_FOUND = 404;
        public static final int RESULT_CANCEL_GONE = 410;   // After @deprecated: Indicates that the resource requested is no longer available and will not be available again.
        public static final int RESULT_CANCEL_UPGRADE_REQUIRED = 426;
        public static final int RESULT_CANCEL_TOO_MANY_REQUESTS = 429;

        // Intent utils
        public static boolean isSatispayAvailable(@NonNull Context context, @NonNull String scheme) {
            return isIntentSafe(context, intentFromUri(uriForOpenApp(scheme)));
        }

        public static boolean isIntentSafe(@NonNull Context context, @NonNull Intent intent) {
            return context.getPackageManager().queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY).size() > 0;
        }

        @NonNull
        public static Intent intentFromUri(@NonNull Uri uri) {
            return new Intent(Intent.ACTION_VIEW).setData(uri);
        }


        // Satispay scheme generators
        @NonNull
        public static Uri uriForApiProvider(@NonNull String appPackage, @NonNull String path) {
            return Uri.parse(String.format("content://%s.apiprovider/%s", appPackage, path));
        }

        @NonNull
        public static Uri uriForOpenApp(@NonNull String scheme) {
            if (TextUtils.isEmpty(scheme)) throw new IllegalArgumentException("Required: scheme");
            return Uri.parse(String.format("%s:", scheme));
        }

        @NonNull
        public static Uri uriForOpenPlayStoreWithMarket(@NonNull String appPackage) {
            if (TextUtils.isEmpty(appPackage))
                throw new IllegalArgumentException("Required: appPackage");
            return Uri.parse(String.format("market://details?id=%s", appPackage));
        }

        @NonNull
        public static Uri uriForOpenPlayStoreWithHttps(@NonNull String appPackage) {
            if (TextUtils.isEmpty(appPackage))
                throw new IllegalArgumentException("Required: appPackage");
            return Uri.parse(String.format("https://play.google.com/store/apps/details?id=%s", appPackage));
        }

        @Deprecated
        @NonNull
        public static Uri uriForPayToken(@NonNull String scheme, @NonNull String appId, @NonNull String token) {
            return uriForPayChargeId(scheme, appId, token);
        }

        @NonNull
        public static Uri uriForPayChargeId(@NonNull String scheme, @NonNull String appId, @NonNull String token) {
            if (TextUtils.isEmpty(scheme)) throw new IllegalArgumentException("Required: scheme");
            if (TextUtils.isEmpty(appId)) throw new IllegalArgumentException("Required: appId");
            if (TextUtils.isEmpty(token)) throw new IllegalArgumentException("Required: token");
            Uri.Builder builder = Uri.parse(String.format("%s://%s/%s/charge", scheme, HOST, appId)).buildUpon();
            builder.appendQueryParameter("token", token);
            return builder.build();
        }

        @NonNull
        public static Uri uriForPayPhoneAmount(@NonNull String scheme, @NonNull String phoneNumber, @Nullable String amount) {
            if (TextUtils.isEmpty(scheme)) throw new IllegalArgumentException("Required: scheme");
            if (TextUtils.isEmpty(phoneNumber))
                throw new IllegalArgumentException("Required: phoneNumber");
            Uri.Builder builder = Uri.parse(String.format("%s://%s/generic/sendmoney", scheme, HOST)).buildUpon();
            builder.appendQueryParameter("to", phoneNumber);
            if (!TextUtils.isEmpty(amount)) builder.appendQueryParameter("amount", amount);
            return builder.build();
        }

        @NonNull
        public static Uri uriForDeveloperPlayground(@NonNull String scheme, @NonNull String version) {
            if (TextUtils.isEmpty(scheme)) throw new IllegalArgumentException("Required: scheme");
            if (TextUtils.isEmpty(version)) throw new IllegalArgumentException("Required: version");
            return Uri.parse(String.format("%s://%s/generic/playground/v%s", scheme, HOST, version));
        }


        // Check API availability

        @NonNull
        public static SatispayIntent.ApiStatus getApiStatus(@NonNull Context context, @NonNull String appPackage, @NonNull Uri uriToCheck) throws Exception {
            if (TextUtils.isEmpty(appPackage))
                throw new IllegalArgumentException("Required: appPackage");
            if (uriToCheck == null) throw new IllegalArgumentException("Required: uri");
            Uri uri = SatispayIntent.uriForApiProvider(appPackage, "status").buildUpon().appendQueryParameter("q", uriToCheck.toString()).build();
            Cursor cursor = context.getContentResolver().query(uri, null, null, null, null);
            SatispayIntent.ApiStatus apiStatus;
            if (cursor != null && cursor.moveToFirst()) {
                apiStatus = SatispayIntent.ApiStatus.from(cursor);
                cursor.close();
            } else {
                apiStatus = new SatispayIntent.ApiStatus();
                apiStatus.message = "Cannot check API Availability: Please check appPackage. Maybe old Satispay app?";
            }
            return apiStatus;
        }


        // Satispay intent generators

        @NonNull
        public static Intent openApp(@NonNull String scheme) {
            return intentFromUri(uriForOpenApp(scheme));
        }

        @NonNull
        public static Intent openPlayStore(@NonNull Context context, @NonNull String appPackage) {
            Intent intent = intentFromUri(uriForOpenPlayStoreWithMarket(appPackage));
            if (!isIntentSafe(context, intent))
                intent = intentFromUri(uriForOpenPlayStoreWithHttps(appPackage));
            return intent;
        }

        @Deprecated
        @NonNull
        public static Intent payToken(@NonNull String scheme, @NonNull String appId, @NonNull String token) {
            return payChargeId(scheme, appId, token);
        }

        @NonNull
        public static Intent payChargeId(@NonNull String scheme, @NonNull String appId, @NonNull String token) {
            return intentFromUri(uriForPayToken(scheme, appId, token));
        }

        @NonNull
        public static Intent payPhoneAmount(@NonNull String scheme, @NonNull String phoneNumber, @Nullable Long amount) {
            return intentFromUri(uriForPayPhoneAmount(scheme, phoneNumber, amount == null ? null : amount.toString()));
        }


        // Support classes

        public static class ApiStatus {
            private boolean validRequest;
            private int version;
            private int code;
            private String message;
            private boolean deprecated;
            private int maxVersion;

            private ApiStatus() {
            }

            private SatispayIntent.ApiStatus initCompleted() {
                if (!validRequest && message == null) {
                    message = "Request not valid!";
                }
                return this;
            }

            private static int getColumnInt(Cursor cursor, String columnName, int defaultValue) {
                int colId = cursor.getColumnIndex(columnName);
                return colId != -1 ? cursor.getInt(colId) : defaultValue;
            }

            private static String getColumnString(Cursor cursor, String columnName, String defaultValue) {
                int colId = cursor.getColumnIndex(columnName);
                return colId != -1 ? cursor.getString(colId) : defaultValue;
            }

            public static SatispayIntent.ApiStatus from(int resultCode, @Nullable Intent data) {
                SatispayIntent.ApiStatus apiStatus = new SatispayIntent.ApiStatus();
                apiStatus.validRequest = resultCode == Activity.RESULT_OK;
                if (data != null) {
                    apiStatus.code = data.getIntExtra("code", apiStatus.code);
                    apiStatus.version = data.getIntExtra("version", apiStatus.version);
                    apiStatus.message = data.getStringExtra("message");
                    apiStatus.deprecated = data.getBooleanExtra("deprecated", apiStatus.deprecated);
                    apiStatus.maxVersion = data.getIntExtra("maxVersion", apiStatus.maxVersion);
                }
                return apiStatus.initCompleted();
            }

            public static SatispayIntent.ApiStatus from(@NonNull Cursor cursor) {
                SatispayIntent.ApiStatus apiStatus = new SatispayIntent.ApiStatus();
                apiStatus.validRequest = getColumnInt(cursor, "validRequest", 0) != 0;
                apiStatus.version = getColumnInt(cursor, "version", 0);
                apiStatus.code = getColumnInt(cursor, "code", 0);
                apiStatus.message = getColumnString(cursor, "message", null);
                apiStatus.deprecated = getColumnInt(cursor, "deprecated", 0) != 0;
                apiStatus.maxVersion = getColumnInt(cursor, "maxVersion", 0);
                return apiStatus.initCompleted();
            }

            public boolean isValidRequest() {
                return validRequest;
            }

            public int getVersion() {
                return version;
            }

            public int getCode() {
                return code;
            }

            @Nullable
            public String getMessage() {
                return message;
            }

            public boolean isDeprecated() {
                return deprecated;
            }

            public int getMaxVersion() {
                return maxVersion;
            }

            @Override
            public String toString() {
                return String.format(Locale.ENGLISH, "[%s/%d] v%d [max:v%d] %s%s", validRequest ? "OK" : "KO", code, version, maxVersion, deprecated ? "DEPRECATED! " : "", message);
            }
        }
    }
}

