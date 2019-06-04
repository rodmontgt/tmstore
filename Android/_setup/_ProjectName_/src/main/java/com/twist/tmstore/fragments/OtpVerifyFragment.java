package com.twist.tmstore.fragments;

import android.Manifest;
import android.app.Dialog;
import android.content.DialogInterface;
import android.content.pm.PackageManager;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Typeface;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.design.widget.TextInputLayout;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.DialogFragment;
import android.support.v4.content.ContextCompat;
import android.text.Spannable;
import android.text.SpannableStringBuilder;
import android.text.TextUtils;
import android.text.style.StyleSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.utils.DataHelper;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.entities.AppInfo;
import com.utils.Helper;
import com.utils.Log;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.concurrent.TimeUnit;

/**
 * Created by Twist Mobile on 12-06-2017.
 */

public class OtpVerifyFragment extends DialogFragment {

    interface OtpVerifyListener {
        void onVerified();
    }

    private final String OTP_TYPE_VERIFY = "verify";
    private final String OTP_TYPE_SEND = "send";
    private final String OTP_TYPE_RESEND = "resend";

    private EditText edit_enter_otp;
    private TextInputLayout label_enter_otp;
    private TextView txt_resend_timer;
    private OtpVerifyListener otpVerifyListener;
    private MainActivity mMainActivity;
    private String mPhoneNumber;
    private String mRequestId;
    private boolean isCanceled;
    private boolean otp_type;
    private long startTime;

    public static OtpVerifyFragment newInstance(OtpVerifyListener otpVerifyListener, MainActivity mainActivity, String phoneNumber, boolean otp_type) {
        OtpVerifyFragment otpVerifyFragment = new OtpVerifyFragment();
        otpVerifyFragment.otpVerifyListener = otpVerifyListener;
        otpVerifyFragment.mMainActivity = mainActivity;
        otpVerifyFragment.mPhoneNumber = phoneNumber;
        otpVerifyFragment.otp_type = otp_type;
        return otpVerifyFragment;
    }
    
    public static OtpVerifyFragment newInstance(OtpVerifyListener otpVerifyListener, MainActivity mainActivity, String phoneNumber, String requestId) {
        OtpVerifyFragment otpVerifyFragment = new OtpVerifyFragment();
        otpVerifyFragment.otpVerifyListener = otpVerifyListener;
        otpVerifyFragment.mMainActivity = mainActivity;
        otpVerifyFragment.mPhoneNumber = phoneNumber;
        otpVerifyFragment.mRequestId = requestId;
        return otpVerifyFragment;
    }

    public static OtpVerifyFragment newInstance(OtpVerifyListener otpVerifyListener, MainActivity mainActivity, String phoneNumber) {
        OtpVerifyFragment otpVerifyFragment = new OtpVerifyFragment();
        otpVerifyFragment.otpVerifyListener = otpVerifyListener;
        otpVerifyFragment.mMainActivity = mainActivity;
        otpVerifyFragment.mPhoneNumber = phoneNumber;
        return otpVerifyFragment;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setStyle(DialogFragment.STYLE_NORMAL, R.style.Theme_AppCompat_Light_Dialog_Alert);
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_otp_verify, container, false);
    }

    @NonNull
    @Override
    public Dialog onCreateDialog(@NonNull Bundle savedInstanceState) {
        Dialog dialog = super.onCreateDialog(savedInstanceState);
        Window window = dialog.getWindow();
        if (window != null) {
            window.requestFeature(Window.FEATURE_NO_TITLE);
        }
        return dialog;
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        startTime = System.currentTimeMillis();
        Log.d("_*_*_*_startTime_*_*_---> " + startTime);

        TextView text_dialog = (TextView) view.findViewById(R.id.text_dialog_title);
        text_dialog.setText(L.getString(L.string.otp_verification));
        Helper.stylizeActionText(text_dialog);

        label_enter_otp = (TextInputLayout) view.findViewById(R.id.label_enter_otp);
        label_enter_otp.setHint(L.getString(L.string.enter_otp));
        Helper.stylize(label_enter_otp);

        edit_enter_otp = (EditText) view.findViewById(R.id.edit_enter_otp);
        txt_resend_timer = (TextView) view.findViewById(R.id.txt_resend_timer);

        TextView label_phone_number = (TextView) view.findViewById(R.id.label_phone_number);
        String country_code = "+";
        SpannableStringBuilder spannable = new SpannableStringBuilder(country_code + " " + mPhoneNumber);
        spannable.setSpan(new StyleSpan(Typeface.BOLD), country_code.length() + 1, country_code.length() + mPhoneNumber.length() + 1, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        label_phone_number.setText(spannable);

        txt_resend_timer.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                long estimatedTime = System.currentTimeMillis() - startTime;
                Log.d("_*_*_*_estimatedTime_*_*_---> " + estimatedTime);

                if (estimatedTime >= 300000) {
                    startTime = System.currentTimeMillis();
                    sendOrResendCode(OTP_TYPE_SEND);
                } else {
                    sendOrResendCode(otp_type ? OTP_TYPE_SEND : OTP_TYPE_RESEND);
                }

            }
        });
        enableInputField(true);
        startTimer();

        Button btn_confirm = (Button) view.findViewById(R.id.btn_confirm);
        btn_confirm.setText(L.getString(L.string.verify));
        Helper.stylize(btn_confirm);

        btn_confirm.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String _otp = edit_enter_otp.getText().toString().trim();
                if (!TextUtils.isEmpty(_otp)) {
                    initiate(OTP_TYPE_VERIFY, mPhoneNumber, _otp, mRequestId);
                } else {
                    Helper.toast(L.getString(L.string.please_enter_otp));
                }
            }
        });

        ImageView iv_edit_phone_number = (ImageView) view.findViewById(R.id.iv_edit_phone_number);
        iv_edit_phone_number.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                isCanceled = true;
                dismiss();
            }
        });
    }

    private void enableInputField(boolean enable) {
        if (enable) {
            label_enter_otp.setVisibility(View.VISIBLE);
            txt_resend_timer.setVisibility(View.VISIBLE);
            edit_enter_otp.requestFocus();
        } else {
            label_enter_otp.setVisibility(View.GONE);
            txt_resend_timer.setVisibility(View.GONE);
        }
    }
    
    public void sendOrResendCode(String type) {
        startTimer();
        createVerification(mPhoneNumber, true, "+91", type);
    }
    
    void createVerification(String phoneNumber, boolean skipPermissionCheck, String countryCode, String type) {
        if (!skipPermissionCheck && ContextCompat.checkSelfPermission(mMainActivity, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_DENIED) {
            ActivityCompat.requestPermissions(mMainActivity, new String[]{Manifest.permission.READ_SMS}, 0);
            mMainActivity.hideProgress();
        } else {
            initiate(type, phoneNumber, "", "");
        }
    }
    
    private void initiate(final String type, String phoneNumber, String otpCode, String request_id) {
        MainActivity.mActivity.hideKeyBoard();
        mMainActivity.showProgress(getString(R.string.please_wait), false);
        DataEngine.getDataEngine().requestOtpVerifyInBackground(type, phoneNumber, otpCode, request_id, new DataQueryHandler<String>() {
            @Override
            public void onSuccess(String data) {
                mMainActivity.hideProgress();
                JSONObject jsonObject;
                try {
                    jsonObject = DataHelper.safeJsonObject(data);
                    String status = jsonObject.getString("status");
                    if (!status.equalsIgnoreCase("error")) {
                        if (type.equalsIgnoreCase(OTP_TYPE_VERIFY)) {
                            mMainActivity.hideProgress();
                            otpVerifyListener.onVerified();
                            isCanceled = true;
                            dismiss();
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onFailure(Exception error) {
                mMainActivity.hideProgress();
                Helper.toast(error.getMessage());
            }
        });
    }

    private void startTimer() {
        txt_resend_timer.setClickable(false);
        txt_resend_timer.setTextColor(ContextCompat.getColor(mMainActivity, R.color.color_icon_overlay));
        new CountDownTimer(5*60000, 1000) {
            public void onTick(long millis) {
                if (isCanceled) {
                    cancel();
                } else {
                    String hms = String.format("%02d:%02d:%02d",
                            TimeUnit.MILLISECONDS.toHours(millis),
                            TimeUnit.MILLISECONDS.toMinutes(millis) - TimeUnit.HOURS.toMinutes(TimeUnit.MILLISECONDS.toHours(millis)),
                            TimeUnit.MILLISECONDS.toSeconds(millis) - TimeUnit.MINUTES.toSeconds(TimeUnit.MILLISECONDS.toMinutes(millis)));
                    txt_resend_timer.setText(L.getString(L.string.resend_otp) + " " + hms);
                    txt_resend_timer.setPaintFlags(txt_resend_timer.getPaintFlags());
                }
            }

            public void onFinish() {
                long estimatedTime = System.currentTimeMillis() - startTime;
                Log.d("_*_*_*_estimatedTime_*_*_---> " + estimatedTime);
                if (estimatedTime >= 300000) {
                    txt_resend_timer.setText(L.getString(L.string.regenerate_otp));
                } else {
                    txt_resend_timer.setText(L.getString(L.string.resend_otp));
                }
                txt_resend_timer.setClickable(true);
                txt_resend_timer.setPaintFlags(txt_resend_timer.getPaintFlags() | Paint.UNDERLINE_TEXT_FLAG);
                txt_resend_timer.setTextColor(ColorStateList.valueOf(Color.parseColor(AppInfo.normal_button_color)));
            }
        }.start();
    }

    @Override
    public void onDismiss(DialogInterface dialog) {
        super.onDismiss(dialog);
        isCanceled = true;
    }
}
