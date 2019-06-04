package com.twist.tmstore.fragments;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Point;
import android.graphics.PorterDuff;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.TextInputLayout;
import android.support.v4.app.FragmentActivity;
import android.support.v4.content.res.ResourcesCompat;
import android.text.InputType;
import android.text.TextUtils;
import android.text.method.PasswordTransformationMethod;
import android.view.*;
import android.view.inputmethod.EditorInfo;
import android.widget.*;
import com.bumptech.glide.Glide;
import com.facebook.*;
import com.facebook.login.LoginResult;
import com.google.android.gms.auth.api.Auth;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.auth.api.signin.GoogleSignInResult;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.twist.dataengine.DataEngine;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.TM_LoginListener;
import com.twist.tmstore.*;
import com.twist.tmstore.R;
import com.twist.tmstore.config.MultiVendorConfig;
import com.twist.tmstore.config.SignUpConfig;
import com.twist.tmstore.dialogs.PendingUserDialog;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.entities.DummyUser;
import com.twist.tmstore.entities.RolePrice;
import com.twist.tmstore.listeners.LoginDialogListener;
import com.twist.tmstore.listeners.LoginListener;
import com.twist.tmstore.views.Country;
import com.twist.tmstore.views.CountrySpinner;
import com.utils.AnalyticsHelper;
import com.utils.CContext;
import com.utils.Helper;
import com.utils.Log;
import com.utils.customviews.IconButton;
import org.jetbrains.annotations.NotNull;
import org.json.JSONObject;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

public class Fragment_Login_Dialog extends BaseDialogFragment implements View.OnClickListener {
    
    private static final int GOOGLE_SIGN_IN_REQUEST = 100;
    private View rootView;
    private Context context;
    private BaseActivity mActivity;
    private LinearLayout mMobileSection;
    private TextInputLayout labelMobileNumber;
    private EditText editMobileNumber;
    private LoginDialogListener mLoginDialogListener;
    private TextView mTitleView;
    private View mSignUpForm, mSignInForm, mForgotForm, mResetPasswordForm;
    private CallbackManager mCallbackManager;
    private GoogleApiClient mGoogleApiClient;
    private boolean _signingUpAsSeller = false;
    private CheckBox check_vendor;
    private LinearLayout guest_continue_section;
    private TextView label_guest_continue;
    private View vendor_options;
    private TextView textViewSignIn;
    private TextView textViewSignUp;
    private TextView txt_forget;
    private TextView txt_go_back;
    private TextView txt_go_back1;
    
    private EditText email;
    private EditText password;
    private TextInputLayout label_email1;
    private EditText email1;
    private TextInputLayout label_password1;
    private EditText password1;
    private TextInputLayout label_password_confirm;
    private EditText password_confirm;
    private TextInputLayout label_shop_name;
    private EditText shop_name;
    private TextInputLayout label_first_name;
    private EditText first_name;
    private TextInputLayout label_last_name;
    private EditText last_name;
    private TextInputLayout label_contact_number;
    private EditText contact;
    
    private EditText email_2;
    
    private TextInputLayout label_new_password;
    private EditText edit_password_new;
    private TextInputLayout label_user_new_password_confirm;
    private EditText edit_new_password_confirm;
    
    private TextInputLayout label_mci_registration_number;
    private EditText edit_mci_registration_number;
    private TextInputLayout label_mci_year_registration;
    private EditText edit_mci_year_registration;
    private TextInputLayout label_qualification;
    private EditText edit_qualification;
    private Button password_reset_button;
    
    private CountrySpinner spinner_country_signup;
    private CountrySpinner spinner_country1_mobileEmail;
    private CountrySpinner spinner_country_signin;
    private CountrySpinner spinner_country_forgot;
    
    private String selectedCountryCodeSignup = "";
    private String selectedCountryCodeMobileEmail = "";
    private String selectedCountryCodeSignin = "";
    private String selectedCountryCodeForgot = "";
    
    public Fragment_Login_Dialog() {
    }
    
    public void setLoginDialogHandler(LoginDialogListener handler) {
        this.mLoginDialogListener = handler;
    }
    
    @Override
    public void dismiss() {
        getDialog().dismiss();
    }
    
    @NonNull
    @Override
    public Dialog onCreateDialog(@NonNull Bundle savedInstanceState) {
        Dialog dialog = super.onCreateDialog(savedInstanceState);
        if (dialog.getWindow() != null) {
            dialog.getWindow().requestFeature(Window.FEATURE_NO_TITLE);
        }
        return dialog;
    }
    
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        if (getDialog() != null && getDialog().getWindow() != null) {
            getDialog().getWindow().requestFeature(Window.FEATURE_NO_TITLE);
        }
        return onCreateView(getActivity(), inflater, container);
    }
    
    @Override
    public void onStop() {
        super.onStop();
        if (mGoogleApiClient != null) {
            mGoogleApiClient.stopAutoManage(mActivity);
            mGoogleApiClient.disconnect();
        }
    }
    
    @SuppressWarnings("deprecation")
    @Override
    public void onStart() {
        super.onStart();
        if (getDialog() != null) {
            Dialog dialog = getDialog();
            dialog.setCancelable(AppInfo.CANCELLABLE_LOGIN);
            if (AppInfo.FULL_SCREEN_LOGIN) {
                int width = ViewGroup.LayoutParams.MATCH_PARENT;
                int height = ViewGroup.LayoutParams.MATCH_PARENT;
                if (dialog.getWindow() != null) {
                    dialog.getWindow().setLayout(width, height);
                    dialog.getWindow().setBackgroundDrawable(new ColorDrawable(ResourcesCompat.getColor(getResources(), R.color.card_header_bg, null)));
                }
            } else if (!Helper.isTabletUI(getContext()) && dialog.getWindow() != null) {
                int height = dialog.getWindow().getAttributes().height;
                Display display = getActivity().getWindowManager().getDefaultDisplay();
                Point size = new Point();
                display.getSize(size);
                dialog.getWindow().setLayout(size.x, height);
            }
        }
    }
    
    public void handleActivityResult(int requestCode, int resultCode, Intent data) {
        if (mCallbackManager != null) {
            mCallbackManager.onActivityResult(requestCode, resultCode, data);
        } else if (requestCode == GOOGLE_SIGN_IN_REQUEST) {
            GoogleSignInResult result = Auth.GoogleSignInApi.getSignInResultFromIntent(data);
            if (result.isSuccess()) {
                mActivity.showProgress(L.getString(L.string.signing_in), false);
                GoogleSignInAccount account = result.getSignInAccount();
                if (account != null) {
                    final DummyUser userData = new DummyUser();
                    userData.email = account.getEmail();
                    userData.validated_id = account.getIdToken();
                    userData.first_name = account.getGivenName();
                    userData.last_name = account.getFamilyName();
                    Uri photoUrl = account.getPhotoUrl();
                    if (photoUrl != null) {
                        userData.avatar_url = photoUrl.toString();
                    }
                    userData.user_type = AppUser.USER_TYPE.GOOGLE_USER;
                    userData.username = userData.email.split("@")[0];
                    checkSignInSocial(userData);
                } else {
                    mActivity.hideProgress();
                    Helper.showErrorToast(getString(L.string.google_signin_failed));
                }
            } else {
                mActivity.hideProgress();
                Helper.showErrorToast(getString(L.string.google_signin_failed));
            }
        }
    }
    
    @Override
    public void onResume() {
        super.onResume();
        if (MultiVendorConfig.isEnabled()) {
            switch (MultiVendorConfig.getDefaultRole()) {
                case "VENDOR":
                case "SELLER":
                case "PENDING_VENDOR":
                case "PENDING_SELLER":
                    check_vendor.setChecked(true);
                    check_vendor.setVisibility(View.GONE);
                    break;
            }
        }
        
        if (MultiVendorConfig.isEnabled()) {
            switch (MultiVendorConfig.getSignupType()) {
                case LEGACY:
                    check_vendor.setVisibility(View.GONE);
                    break;
                case OPTIONAL:
                    check_vendor.setChecked(false);
                    check_vendor.setVisibility(View.VISIBLE);
                    break;
                case REQUIRED:
                    check_vendor.setChecked(true);
                    check_vendor.setVisibility(View.GONE);
                    break;
            }
        }
    }
    
    public View onCreateView(Activity activity, LayoutInflater inflater, ViewGroup container) {
        mActivity = (BaseActivity) activity;
        context = inflater.getContext();
        
        rootView = inflater.inflate(R.layout.activity_login_dialog, container, false);
        rootView.setFocusableInTouchMode(true);
        rootView.requestFocus();
        
        if (rootView != null && rootView.requestFocus()) {
            getActivity().getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
        }
        
        mTitleView = (TextView) rootView.findViewById(R.id.txt_login_title);
        mTitleView.setTextColor(Color.parseColor(AppInfo.color_actionbar_text));
        
        guest_continue_section = (LinearLayout) rootView.findViewById(R.id.guest_continue_section);
        if (getArguments() != null && getArguments().getBoolean(Extras.GUEST_CONTINUE)) {
            label_guest_continue = (TextView) rootView.findViewById(R.id.txt_continue);
            label_guest_continue.setPaintFlags(label_guest_continue.getPaintFlags() | Paint.UNDERLINE_TEXT_FLAG);
            label_guest_continue.setText(getString(L.string.continue_as_guest));
            guest_continue_section.setOnClickListener(this);
            guest_continue_section.setVisibility(View.VISIBLE);
        } else {
            guest_continue_section.setVisibility(View.GONE);
        }
        
        initComponent(rootView);
        
        final Button email_sign_in_button = setButtonLayout(R.id.email_sign_in_button, L.string.action_sign_in_short);
        final Button email_sign_up_button = setButtonLayout(R.id.email_sign_up_button, L.string.action_sign_up_short);
        final Button email_forget_button = setButtonLayout(R.id.email_forget_button, L.string.action_reset_password);
        password_reset_button = setButtonLayout(R.id.password_reset_button, L.string.action_reset_password);
        
        final IconButton btnFacebook = (IconButton) rootView.findViewById(R.id.btn_fb_signin);
        final IconButton btnGoogle = (IconButton) rootView.findViewById(R.id.btn_google_signin);
        final IconButton btnTwitter = (IconButton) rootView.findViewById(R.id.btn_twitter);
        
        if (AppInfo.SHOW_MOBILE_NUMBER_IN_SIGNUP && !AppInfo.SHOW_ONLY_MOBILE_NUMBER_IN_SIGNUP) {
            mMobileSection.setVisibility(View.VISIBLE);
            spinner_country_signup.setVisibility(View.VISIBLE);
        }
        
        if (MultiVendorConfig.isEnabled()) {
            rootView.findViewById(R.id.vendor_section).setVisibility(View.VISIBLE);
            check_vendor.setVisibility(View.VISIBLE);
            _signingUpAsSeller = false;
            check_vendor.setText(L.getString(L.string.register_as_vendor));
            check_vendor.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(CompoundButton compoundButton, boolean isChecked) {
                    _signingUpAsSeller = isChecked;
                    vendor_options.setVisibility(isChecked ? View.VISIBLE : View.GONE);
                    mMobileSection.setVisibility(isChecked ? View.GONE : View.VISIBLE);
                    spinner_country_signup.setVisibility(isChecked ? View.GONE : View.VISIBLE);
                    if (_signingUpAsSeller) {
                        rootView.findViewById(R.id.social_section).setVisibility(View.GONE);
                    } else {
                        if (btnFacebook.getVisibility() == View.GONE && btnTwitter.getVisibility() == View.GONE && btnGoogle.getVisibility() == View.GONE) {
                            rootView.findViewById(R.id.social_section).setVisibility(View.GONE);
                        } else {
                            rootView.findViewById(R.id.social_section).setVisibility(View.VISIBLE);
                        }
                    }
                }
            });
        } else {
            rootView.findViewById(R.id.vendor_section).setVisibility(View.GONE);
        }
        
        if (!AppInfo.SHOW_SIGNUP_UI) {
            showSignIn();
            rootView.findViewById(R.id.social_section).setVisibility(View.GONE);
            rootView.findViewById(R.id.dont_have_account).setVisibility(View.GONE);
            textViewSignUp.setVisibility(View.GONE);
        } else {
            showSignUp();
        }
        
        password.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_DONE) {
                    email_sign_in_button.callOnClick();
                }
                return false;
            }
        });
        
        email_sign_in_button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Helper.hideKeyboard(v);
                final String _email = email.getText().toString();
                final String _password = password.getText().toString();
                
                if (AppInfo.SHOW_MOBILE_NUMBER_IN_SIGNUP && AppInfo.REQUIRE_MOBILE_NUMBER_IN_SIGNUP && AppInfo.SHOW_ONLY_MOBILE_NUMBER_IN_SIGNUP) {
                    
                    final String mobileNo = selectedCountryCodeMobileEmail + _email;
                    final String mobileEmail = selectedCountryCodeSignin + _email + AppInfo.EMAIL_DOMAIN;
//					if (checkMobileEmailCredentials(_email) && checkCountryCodeCredentials(selectedCountryCodeSignin) && checkCredentials(mobileEmail, _password)) {
                    if (checkMobileEmailCredentials(mobileNo, selectedCountryCodeSignin, AppInfo.EMAIL_DOMAIN, _password, true)) {
                        
                        signInAPI(mobileEmail, _password);
                    }
                } else {
                    if (checkCredentials(_email, _password)) {
                        signInAPI(_email, _password);
                    }
                }
            }
        });
        
        email_sign_up_button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Helper.hideKeyboard(v);
                final String _email = email1.getText().toString();
                final String _password = password1.getText().toString();
                final String _password_confirm = password_confirm.getText().toString();
                String _username = "";
                if (_signingUpAsSeller && vendor_options.getVisibility() == View.VISIBLE && check_vendor.getVisibility() == View.VISIBLE) {
                    final String _first_name = first_name.getText().toString();
                    final String _last_name = last_name.getText().toString();
                    final String _shop_name = shop_name.getText().toString();
                    final String _phone = contact.getText().toString();
                    if (checkSellerCredentials(_email, _password, _password_confirm, _first_name, _last_name, _shop_name, _phone)) {
                        mActivity.showProgress(L.getString(L.string.signing_up), false);
                        signUpPluginForSeller(_email, _password, _first_name, _last_name, _shop_name, _phone, "seller");
                    }
                } else if (AppInfo.SHOW_MOBILE_NUMBER_IN_SIGNUP && (editMobileNumber.getVisibility() == View.VISIBLE || AppInfo.SHOW_ONLY_MOBILE_NUMBER_IN_SIGNUP)) {
                    if (AppInfo.REQUIRE_MOBILE_NUMBER_IN_SIGNUP) {
                        
                        if (AppInfo.SHOW_ONLY_MOBILE_NUMBER_IN_SIGNUP) {
                            
                            final String mobileNo = selectedCountryCodeMobileEmail + _email;
                            final String email = mobileNo + AppInfo.EMAIL_DOMAIN;
                            final String username = mobileNo;
                            if (checkMobileEmailCredentials(mobileNo, selectedCountryCodeMobileEmail, AppInfo.EMAIL_DOMAIN, _password, true) && checkCredentials(email, _password, _password_confirm)) {
                                mActivity.showProgress(L.getString(L.string.please_wait), false);
                                DataEngine.getDataEngine().verifyUserEmailInBackground(email, new TM_LoginListener() {
                                    @Override
                                    public void onLoginSuccess(String response) {
                                        mActivity.hideProgress();
                                        Helper.toast(response);
                                    }
    
                                    @Override
                                    public void onLoginFailed(String msg) {
                                        mActivity.hideProgress();
                                        signUpWithOTPVerify(getActivity(), mobileNo, email, username, _password);
                                    }
                                });
                            }
                        } else {
                            final String mobileNo = selectedCountryCodeSignup + editMobileNumber.getText().toString();
                            final String username = mobileNo;
                            if (checkMobileCredentials(_email, _password, _password_confirm, mobileNo, selectedCountryCodeSignup)) {
                                mActivity.showProgress(L.getString(L.string.please_wait), false);
                                signUpWithOTPVerify(getActivity(), mobileNo, _email, username, _password);
                            }
                        }
                    } else if (checkCredentials(_email, _password, _password_confirm)) {
                        _username = _email;
                        MainActivity.mActivity.showProgress(L.getString(L.string.signing_up), false);
                        signUpWebUsing(_email, _username, _password);
                    }
                } else if (SignUpConfig.isEnabled() && edit_mci_registration_number.getVisibility() == View.VISIBLE && edit_mci_year_registration.getVisibility() == View.VISIBLE) {
                    signUpWebUsing();
                } else if (checkCredentials(_email, _password, _password_confirm)) {
                    mActivity.showProgress(L.getString(L.string.signing_up), false);
                    _username = _email;
                    signUpWebUsing(_email, _username, _password);
                }
            }
        });
        
        email_forget_button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Helper.hideKeyboard(v);
                final String _email = email_2.getText().toString();
                if (AppInfo.SHOW_MOBILE_NUMBER_IN_SIGNUP && AppInfo.REQUIRE_MOBILE_NUMBER_IN_SIGNUP && AppInfo.SHOW_ONLY_MOBILE_NUMBER_IN_SIGNUP) {
                    final String mobileNo = selectedCountryCodeForgot + _email;
                    final String mobileEmail = mobileNo + AppInfo.EMAIL_DOMAIN;
                    if (checkMobileEmailCredentials(mobileNo, selectedCountryCodeForgot, AppInfo.EMAIL_DOMAIN, "", false) && checkCredentials(mobileEmail)) {
                        // Forget Password with Email Verification, then Mobile OTP
                        handleForgetPassword(getActivity(), mobileNo, mobileEmail);
                    }
                } else {
                    if (checkCredentials(_email)) {
                        handleForgetPassword(_email);
                    }
                }
            }
        });
        
        if (TextUtils.isEmpty(AppInfo.FACEBOOK_APP_ID)) {
            btnFacebook.setVisibility(View.GONE);
        } else {
            btnFacebook.setText(L.getString(L.string.login_facebook));
            btnFacebook.setVisibility(View.VISIBLE);
            btnFacebook.setOnClickListener(this);
        }
        
        if (TextUtils.isEmpty(AppInfo.GOOGLE_APP_KEY)) {
            btnGoogle.setVisibility(View.GONE);
        } else {
            btnGoogle.setText(L.getString(L.string.login_google));
            btnGoogle.setVisibility(View.VISIBLE);
            btnGoogle.setOnClickListener(this);
        }
        
        if (TextUtils.isEmpty(AppInfo.TWITTER_APP_KEY)) {
            btnTwitter.setVisibility(View.GONE);
        } else {
            btnTwitter.setText(L.getString(L.string.login_twitter));
            btnTwitter.setVisibility(View.VISIBLE);
            btnTwitter.setOnClickListener(this);
        }
        
        if (btnFacebook.getVisibility() == View.GONE && btnTwitter.getVisibility() == View.GONE && btnGoogle.getVisibility() == View.GONE) {
            rootView.findViewById(R.id.social_section).setVisibility(View.GONE);
        }
        setLayoutFieldsVisibility();
        
        if (label_first_name.getVisibility() == View.VISIBLE) {
            rootView.findViewById(R.id.vendor_section).setVisibility(View.VISIBLE);
            vendor_options = rootView.findViewById(R.id.vendor_options);
            vendor_options.setVisibility(View.VISIBLE);
        }
        return rootView;
    }
    
    private void initComponent(View rootView) {
        
        ImageView login_bg = (ImageView) rootView.findViewById(R.id.login_bg);
        if (Helper.isValidString(AppInfo.login_bg)) {
            login_bg.setVisibility(View.VISIBLE);
            Glide.with(context)
                .load(AppInfo.login_bg)
                .into(login_bg);
        } else {
            login_bg.setVisibility(View.GONE);
        }
        
        LinearLayout loginActionBar = (LinearLayout) rootView.findViewById(R.id.login_action_bar);
        loginActionBar.setBackgroundColor(Color.parseColor(AppInfo.color_theme));
        
        ImageView iv_close = (ImageView) rootView.findViewById(R.id.iv_close);
        iv_close.setVisibility(AppInfo.CANCELLABLE_LOGIN ? View.VISIBLE : View.GONE);
        Drawable drawableClose = CContext.getDrawable(context, R.drawable.ic_vc_close);
        drawableClose.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_ATOP);
        iv_close.setImageDrawable(drawableClose);
        iv_close.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                dismiss();
            }
        });
        
        mSignUpForm = rootView.findViewById(R.id.email_signup_form);
        mSignInForm = rootView.findViewById(R.id.email_login_form);
        mForgotForm = rootView.findViewById(R.id.email_forgot_form);
        mResetPasswordForm = rootView.findViewById(R.id.reset_password_form);
        
        textViewSignIn = (TextView) rootView.findViewById(R.id.txt_signin);
        textViewSignIn.setText(L.getString(L.string.sign_in_here));
        textViewSignIn.findViewById(R.id.txt_signin).setOnClickListener(this);
        
        textViewSignUp = (TextView) rootView.findViewById(R.id.txt_signup);
        textViewSignUp.setText(L.getString(L.string.sign_up_here));
        textViewSignUp.setOnClickListener(this);
        
        txt_forget = (TextView) rootView.findViewById(R.id.txt_forget);
        txt_forget.setText(L.getString(L.string.txt_forget));
        txt_forget.setOnClickListener(this);
        
        txt_go_back = (TextView) rootView.findViewById(R.id.txt_go_back);
        txt_go_back.setText(L.getString(L.string.txt_go_back));
        txt_go_back.setOnClickListener(this);
        
        txt_go_back1 = (TextView) rootView.findViewById(R.id.txt_go_back1);
        txt_go_back1.setText(L.getString(L.string.txt_go_back));
        txt_go_back1.setOnClickListener(this);
        
        setTextOnView(rootView, R.id.dont_have_account, L.string.dont_have_account);
        setTextOnView(rootView, R.id.already_have_account, L.string.already_have_account);
        setTextOnView(rootView, R.id.sign_in_1_click, L.string.sign_in_1_click);
        setTextOnView(rootView, R.id.txt_or, L.string.or);
        setTextOnView(rootView, R.id.txt_forget, L.string.txt_forget);
        setTextInputLayout(R.id.label_email, L.string.prompt_email);
        setTextInputLayout(R.id.label_password, L.string.prompt_password);
        
        label_email1 = setTextInputLayout(R.id.label_email1, L.string.prompt_email);
        label_email1.setVisibility(View.GONE);
        email1 = setEditText(R.id.email1, false);
        email1.setVisibility(View.GONE);
        
        label_password1 = setTextInputLayout(R.id.label_password1, L.string.prompt_password);
        label_password1.setVisibility(View.GONE);
        password1 = setEditText(R.id.password1, false);
        password1.setVisibility(View.GONE);
        
        label_password_confirm = setTextInputLayout(R.id.label_password_confirm, L.string.prompt_password_confirm);
        label_password_confirm.setVisibility(View.GONE);
        password_confirm = setEditText(R.id.password_confirm, false);
        password_confirm.setVisibility(View.GONE);
        
        label_shop_name = setTextInputLayout(R.id.label_shop_name, L.string.prompt_shop_name);
        label_shop_name.setVisibility(View.GONE);
        shop_name = setEditText(R.id.shop_name, false);
        shop_name.setVisibility(View.GONE);
        
        label_first_name = setTextInputLayout(R.id.label_first_name, L.string.first_name);
        label_first_name.setVisibility(View.GONE);
        first_name = setEditText(R.id.first_name, false);
        first_name.setVisibility(View.GONE);
        
        label_last_name = setTextInputLayout(R.id.label_last_name, L.string.last_name);
        label_last_name.setVisibility(View.GONE);
        last_name = setEditText(R.id.last_name, false);
        last_name.setVisibility(View.GONE);
        
        label_contact_number = setTextInputLayout(R.id.label_contact, L.string.contact_number);
        label_contact_number.setVisibility(View.GONE);
        contact = setEditText(R.id.contact, false);
        contact.setVisibility(View.GONE);
        
        mMobileSection = rootView.findViewById(R.id.mobile_section);
        mMobileSection.setVisibility(View.GONE);
        labelMobileNumber = setTextInputLayout(R.id.label_mobile_number, L.getString(L.string.mobile_number));
        editMobileNumber = setEditText(R.id.edit_mobile_number, false);
        
        label_mci_registration_number = setTextInputLayout(R.id.label_mci_registration_number, L.string.hint_mci_registration_number);
        label_mci_registration_number.setVisibility(View.GONE);
        edit_mci_registration_number = setEditText(R.id.edit_mci_registration_number, false);
        edit_mci_registration_number.setVisibility(View.GONE);
        
        label_mci_year_registration = setTextInputLayout(R.id.label_mci_year_registration, L.string.hint_mci_year_registration);
        label_mci_year_registration.setVisibility(View.GONE);
        edit_mci_year_registration = setEditText(R.id.edit_mci_year_registration, false);
        edit_mci_year_registration.setVisibility(View.GONE);
        
        label_qualification = setTextInputLayout(R.id.label_qualification, L.string.hint_qualification);
        label_qualification.setVisibility(View.GONE);
        edit_qualification = setEditText(R.id.edit_qualification, false);
        edit_qualification.setVisibility(View.GONE);
        
        email = (EditText) rootView.findViewById(R.id.email);
        password = (EditText) rootView.findViewById(R.id.password);
        
        email_2 = (EditText) rootView.findViewById(R.id.email_2);
        
        password.setTypeface(email.getTypeface());
        password.setTransformationMethod(new PasswordTransformationMethod());
        password1.setTypeface(email1.getTypeface());
        password1.setTransformationMethod(new PasswordTransformationMethod());
        password_confirm.setTypeface(email.getTypeface());
        password_confirm.setTransformationMethod(new PasswordTransformationMethod());
        
        vendor_options = rootView.findViewById(R.id.vendor_options);
        vendor_options.setVisibility(View.GONE);
        check_vendor = (CheckBox) rootView.findViewById(R.id.check_vendor);
        check_vendor.setVisibility(View.GONE);
        check_vendor.setChecked(false);
        Helper.stylize(check_vendor);
        
        label_new_password = setTextInputLayout(R.id.label_user_new_password, L.string.prompt_new_password);
        edit_password_new = setEditText(R.id.password_new, false);
        label_user_new_password_confirm = setTextInputLayout(R.id.label_user_new_password_confirm, L.string.prompt_password_confirm);
        edit_new_password_confirm = setEditText(R.id.new_password_confirm, false);
        
        spinner_country_signup = setCountrySpinner(R.id.spinner_country_signup);
        spinner_country_signup.setVisibility(View.GONE);
        spinner_country_signup.onCountrySelectedListener = new CountrySpinner.OnCountrySelectedListener() {
            
            @Override
            public void onCountrySelected(@NotNull Country country) {
                int countryPhonCode = country.phoneCode;
                Log.d("Selected Country Code : " + String.valueOf(countryPhonCode));
                selectedCountryCodeSignup = String.valueOf(countryPhonCode);
            }
        };
        
        spinner_country1_mobileEmail = setCountrySpinner(R.id.spinner_country_mobile_email);
        spinner_country1_mobileEmail.setVisibility(View.GONE);
        spinner_country1_mobileEmail.onCountrySelectedListener = country -> {
            int countryPhonCode = country.phoneCode;
            Log.d("Selected Country Code : " + String.valueOf(countryPhonCode));
            selectedCountryCodeMobileEmail = String.valueOf(countryPhonCode);
        };
        
        spinner_country_signin = setCountrySpinner(R.id.spinner_country_signin);
        spinner_country_signin.setVisibility(View.GONE);
        spinner_country_signin.onCountrySelectedListener = country -> {
            int countryPhonCode = country.phoneCode;
            Log.d("Selected Country Code : " + String.valueOf(countryPhonCode));
            selectedCountryCodeSignin = String.valueOf(countryPhonCode);
        };
        
        spinner_country_forgot = setCountrySpinner(R.id.spinner_country_forgot);
        spinner_country_forgot.setVisibility(View.GONE);
        spinner_country_forgot.onCountrySelectedListener = country -> {
            int countryPhonCode = country.phoneCode;
            Log.d("Selected Country Code Forgot : " + String.valueOf(countryPhonCode));
            selectedCountryCodeForgot = String.valueOf(countryPhonCode);
        };
        
        if (AppInfo.SHOW_ONLY_MOBILE_NUMBER_IN_SIGNUP) {
            label_email1 = setTextInputLayout(R.id.label_email1, L.string.mobile_number);
            setTextInputLayout(R.id.label_email, L.string.mobile_number);
            setTextInputLayout(R.id.label_email2, L.string.mobile_number);
            email1.setInputType(InputType.TYPE_CLASS_PHONE);
            email.setInputType(InputType.TYPE_CLASS_PHONE);
            email_2.setInputType(InputType.TYPE_CLASS_PHONE);
            
            spinner_country1_mobileEmail.setVisibility(View.VISIBLE);
            spinner_country_signin.setVisibility(View.VISIBLE);
            spinner_country_forgot.setVisibility(View.VISIBLE);
        }
    }
    
    private void setLayoutFieldsVisibility() {
        if (!SignUpConfig.isEnabled() && SignUpConfig.getLayoutFields() == null) {
            return;
        }
        
        for (String str : SignUpConfig.getLayoutFields()) {
            switch (str) {
                case SignUpConfig.SIGNUP_LAYOUT_EMAIL:
                    label_email1.setVisibility(View.VISIBLE);
                    email1.setVisibility(View.VISIBLE);
                    break;
                case SignUpConfig.SIGNUP_LAYOUT_PASSWORD:
                    label_password1.setVisibility(View.VISIBLE);
                    password1.setVisibility(View.VISIBLE);
                    break;
                case SignUpConfig.SIGNUP_LAYOUT_CONFIRM_PASSWORD:
                    label_password_confirm.setVisibility(View.VISIBLE);
                    password_confirm.setVisibility(View.VISIBLE);
                    break;
                case SignUpConfig.SIGNUP_LAYOUT_FIRST_NAME:
                    label_first_name.setVisibility(View.VISIBLE);
                    first_name.setVisibility(View.VISIBLE);
                    break;
                case SignUpConfig.SIGNUP_LAYOUT_LAST_NAME:
                    label_last_name.setVisibility(View.VISIBLE);
                    last_name.setVisibility(View.VISIBLE);
                    break;
                case SignUpConfig.SIGNUP_LAYOUT_CONTACT_NUMBER:
                    label_contact_number.setVisibility(View.VISIBLE);
                    contact.setVisibility(View.VISIBLE);
                    break;
                case SignUpConfig.SIGNUP_LAYOUT_MOBILE_NUMBER:
                    mMobileSection.setVisibility(View.VISIBLE);
                    spinner_country_signup.setVisibility(View.VISIBLE);
                    break;
                case SignUpConfig.SIGNUP_LAYOUT_SHOP_NAME:
                    label_shop_name.setVisibility(View.VISIBLE);
                    shop_name.setVisibility(View.VISIBLE);
                    break;
                case SignUpConfig.SIGNUP_LAYOUT_MCI_REGISTRATION_NUMBER:
                    label_mci_registration_number.setVisibility(View.VISIBLE);
                    edit_mci_registration_number.setVisibility(View.VISIBLE);
                    break;
                case SignUpConfig.SIGNUP_LAYOUT_MCI_YEAR_REGISTRATION:
                    label_mci_year_registration.setVisibility(View.VISIBLE);
                    edit_mci_year_registration.setVisibility(View.VISIBLE);
                    break;
                case SignUpConfig.SIGNUP_LAYOUT_QUALIFICATION:
                    label_qualification.setVisibility(View.VISIBLE);
                    edit_qualification.setVisibility(View.VISIBLE);
                    break;
            }
        }
    }
    
    private void signUpWithOTPVerify(FragmentActivity activity, String mobileNo, String email, String username, String _password) {
        DataEngine.getDataEngine().requestLoginOtpInBackground(mobileNo, new DataQueryHandler<String>() {
            @Override
            public void onSuccess(String data) {
                mActivity.hideProgress();
                try {
                    JSONObject jsonObject = new JSONObject(data);
                    if (jsonObject.has("message")) {
                        Object object = jsonObject.get("message");
                        String requestID = "";
                        String msg = "";
                        if (object instanceof JSONObject) {
                            JSONObject requestIdObj = (JSONObject) object;
                            msg = requestIdObj.getString("msg");
                            requestID = requestIdObj.getString("request_id");
                        }
                        if (!jsonObject.getString("message").equalsIgnoreCase((L.string.user_already_registered)) || (!msg.isEmpty() && !msg.equalsIgnoreCase((L.string.user_already_registered)))) {
                            OtpVerifyFragment otpVerifyFragment = OtpVerifyFragment.newInstance(
                                () -> {
                                    mActivity.showProgress(L.getString(L.string.signing_up), false);
                                    signUpWebUsing(email, username, _password);
                                },
                                MainActivity.mActivity,
                                mobileNo,
                                requestID);
                            otpVerifyFragment.show(activity.getSupportFragmentManager(), Fragment_Login_Dialog.class.getSimpleName());
                        } else {
                            Helper.toast(jsonObject.getString("message"));
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    Helper.toast(e.getMessage());
                }
            }
            
            @Override
            public void onFailure(Exception error) {
                mActivity.hideProgress();
                Helper.toast(error.getMessage());
            }
        });
    }
    
    private void signUpWebUsing() {
        final String _email = email1.getText().toString();
        final String _password = password1.getText().toString();
        final String _password_confirm = password_confirm.getText().toString();
        final String _username = _email;
        final String _first_name = first_name.getText().toString();
        final String _last_name = last_name.getText().toString();
        final String _mobile_no = editMobileNumber.getText().toString();
        
        final String _mci_registration_number = edit_mci_registration_number.getText().toString();
        final String _mci_year_registration = edit_mci_year_registration.getText().toString();
        final String _qualification = edit_qualification.getText().toString();
        
        if (!checkMCIRegistrationCredentials(_email, _password, _password_confirm, _first_name, _last_name, _mobile_no, _mci_registration_number, _mci_year_registration, _qualification)) {
            return;
        }
        
        if (checkMobileCredentials(_email, _password, _password_confirm, _mobile_no, selectedCountryCodeSignup)) {
            mActivity.showProgress(L.getString(L.string.please_wait), false);
            DataEngine.getDataEngine().requestLoginOtpInBackground(_mobile_no, new DataQueryHandler<String>() {
                @Override
                public void onSuccess(String data) {
                    mActivity.hideProgress();
                    try {
                        JSONObject jsonObject = new JSONObject(data);
                        if (jsonObject.has("message")) {
                            if (!jsonObject.getString("message").equalsIgnoreCase((L.string.user_already_registered))) {
                                OtpVerifyFragment otpVerifyFragment = OtpVerifyFragment.newInstance(new OtpVerifyFragment.OtpVerifyListener() {
                                    @Override
                                    public void onVerified() {
                                        mActivity.showProgress(L.getString(L.string.signing_up), false);
                                        Map<String, String> params = new HashMap<>();
                                        params.put("user_emailID", _email);
                                        params.put("user_pass", _password);
                                        params.put("user_name", _username);
                                        params.put("f_name", _first_name);
                                        params.put("l_name", _last_name);
                                        params.put("mobile", _mobile_no);
                                        params.put("reg_num", _mci_registration_number);
                                        params.put("year_of_reg", _mci_year_registration);
                                        params.put("qualification", _qualification);
                                        params.put("user_platform", "Android");
                                        
                                        signUpWebUsing(_email, _password, params);
                                    }
                                }, MainActivity.mActivity, _mobile_no, true);
                                otpVerifyFragment.show(getActivity().getSupportFragmentManager(), Fragment_Login_Dialog.class.getSimpleName());
                            } else {
                                Helper.toast(jsonObject.getString("message"));
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                        Helper.toast(e.getMessage());
                    }
                }
                
                @Override
                public void onFailure(Exception error) {
                    mActivity.hideProgress();
                    Helper.toast(error.getMessage());
                }
            });
        }
    }
    
    private void signUpWebUsing(final String _email, final String _password, Map<String, String> params) {
        
        mActivity.showProgress(L.getString(L.string.signing_up), false);
        DataEngine.getDataEngine().signUpWebUsing(params, new TM_LoginListener() {
            @Override
            public void onLoginSuccess(String data) {
                Log.d("-- signUpWebUsing::onLoginSuccess --");
                signUpAPI(_email, _password, data);
                AnalyticsHelper.registerSignInEvent("Web SignUp");
            }
            
            @Override
            public void onLoginFailed(String msg) {
                mActivity.hideProgress();
                Helper.showToast(msg);
                if (mLoginDialogListener != null) {
                    mLoginDialogListener.onLoginFailed(msg);
                }
            }
        });
    }
    
    private void signInAPI(final String _email, final String _password) {
        mActivity.showProgress(L.getString(L.string.signing_in), false);
        LoginManager.fetchCustomerData(
            _email,
            new LoginListener() {
                @Override
                public void onLoginSuccess(String message) {
                    Log.d("-- fetchCustomerData::onLoginSuccess --");
                    LoginManager.signInWeb(
                        _email,
                        _password,
                        new LoginListener() {
                            @Override
                            public void onLoginSuccess(String message) {
                                Log.d("-- signInWeb::onLoginSuccess --");
                                MainActivity.mActivity.createAppUser(true);
                                signInParse(_email, _password, message);
                            }
                            
                            @Override
                            public void onLoginFailed(String error) {
                                Log.d("-- signInWeb::onLoginFailed --");
                                mActivity.hideProgress();
                                Helper.showErrorToast(error);
                                if (mLoginDialogListener != null) {
                                    mLoginDialogListener.onLoginFailed(error);
                                }
                            }
                        }
                    );
                }
                
                @Override
                public void onLoginFailed(String cause) {
                    mActivity.hideProgress();
                    Helper.showToast(cause);
                    if (mLoginDialogListener != null) {
                        mLoginDialogListener.onLoginFailed(cause);
                    }
                }
            }
        );
    }
    
    private void signInParse(final String _email, final String _password, final String response) {
        MainActivity.mActivity.signInParse(_email, new LoginListener() {
            @Override
            public void onLoginSuccess(String message) {
                Log.d("-- signInParse::onLoginSuccess --");
                AppUser.getInstance().password = _password;
                AppUser.getInstance().save();
                MainActivity.mActivity.resetDrawer();
                mActivity.hideProgress();
                dismiss();
                // handle if response is from user approval plugin
                if (!TextUtils.isEmpty(response)) {
                    try {
                        JSONObject jsonObject = new JSONObject(response);
                        String msg = jsonObject.getString("msg");
                        String status = jsonObject.getString("status");
                        if (!TextUtils.isEmpty(status) && (status.equals("denied") || status.equals("pending"))) {
                            PendingUserDialog pendingUserDialog = new PendingUserDialog();
                            pendingUserDialog.showDialog(getActivity(), msg);
                            return;
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    
                    if (AppInfo.ENABLE_ROLE_PRICE) {
                        try {
                            JSONObject jsonObject = new JSONObject(response);
                            RolePrice rolePrice = RolePrice.create(jsonObject);
                            AppUser.getInstance().setRolePrice(rolePrice);
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }
                
                if (mLoginDialogListener != null) {
                    mLoginDialogListener.onLoginSuccess();
                }
            }
            
            @Override
            public void onLoginFailed(String cause) {
                Log.d("-- signInParse::onLoginFailed --");
                mActivity.hideProgress();
                Helper.showToast(cause);
                if (mLoginDialogListener != null) {
                    mLoginDialogListener.onLoginFailed(cause);
                }
            }
        });
    }
    
    private void signUpWebUsing(final String _email, final String _username, final String _password) {
        DataEngine.getDataEngine().signUpWebUsing(_email, _username, _password, new TM_LoginListener() {
            @Override
            public void onLoginSuccess(String data) {
                Log.d("-- signUpWebUsing::onLoginSuccess --");
                signUpAPI(_email, _password, data);
                AnalyticsHelper.registerSignInEvent("Web SignUp");
            }
            
            @Override
            public void onLoginFailed(String msg) {
                mActivity.hideProgress();
                Helper.showToast(msg);
                if (mLoginDialogListener != null) {
                    mLoginDialogListener.onLoginFailed(msg);
                }
            }
        });
    }
    
    private void signUpPluginForSeller(final String _email, final String _password, String _first_name, String _last_name, String _shop_name, String _phone, String _role) {
        // Here email and user id are same;
        DataEngine.getDataEngine().signUpWebUsing(_email, _email, _password, _first_name, _last_name, _shop_name, _phone, _role, new TM_LoginListener() {
            @Override
            public void onLoginSuccess(String data) {
                Log.d("-- signUpPluginForSeller::signUpWebUsing::onLoginSuccess --");
                signUpAPI(_email, _password, null);
                AnalyticsHelper.registerSignInEvent("Web SignUp");
            }
            
            @Override
            public void onLoginFailed(String msg) {
                mActivity.hideProgress();
                Helper.showToast(msg);
                if (mLoginDialogListener != null) {
                    mLoginDialogListener.onLoginFailed(msg);
                }
            }
        });
    }
    
    private void signUpAPI(final String _email, final String _password, final String response) {
        LoginManager.fetchCustomerData(
            _email,
            new LoginListener() {
                @Override
                public void onLoginSuccess(String message) {
                    Log.d("-- signInAPIUsing::onLoginSuccess --");
                    AnalyticsHelper.registerSignUpEvent("API Signup");
                    MainActivity.mActivity.createAppUser(true);
                    signUpParse(_email, _password, response);
                }
                
                @Override
                public void onLoginFailed(String cause) {
                    mActivity.hideProgress();
                    Helper.showToast(cause);
                    if (mLoginDialogListener != null) {
                        mLoginDialogListener.onLoginFailed(cause);
                    }
                }
            }
        );
    }
    
    private void signUpParse(final String _email, final String _password, final String response) {
        MainActivity.mActivity.signInParse(_email, new LoginListener() {
            @Override
            public void onLoginSuccess(String message) {
                AppUser.getInstance().password = _password;
                AppUser.getInstance().save();
                mActivity.hideProgress();
                Log.d("-- signInParse::onLoginSuccess --");
                MainActivity.mActivity.resetDrawer();
                dismiss();
                
                // handle if response is from user approval plugin
                if (!TextUtils.isEmpty(response)) {
                    try {
                        JSONObject jsonObject = new JSONObject(response);
                        String msg = jsonObject.getString("msg");
                        String status = jsonObject.getString("status");
                        if (!TextUtils.isEmpty(status) && (status.equals("denied") || status.equals("pending"))) {
                            PendingUserDialog pendingUserDialog = new PendingUserDialog();
                            pendingUserDialog.showDialog(getActivity(), msg);
                            return;
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    
                    if (AppInfo.ENABLE_ROLE_PRICE) {
                        try {
                            JSONObject jsonObject = new JSONObject(response);
                            RolePrice rolePrice = RolePrice.create(jsonObject);
                            AppUser.getInstance().setRolePrice(rolePrice);
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }
                if (mLoginDialogListener != null) {
                    mLoginDialogListener.onLoginSuccess();
                }
            }
            
            @Override
            public void onLoginFailed(String cause) {
                mActivity.hideProgress();
                Helper.showToast(cause);
                if (mLoginDialogListener != null) {
                    mLoginDialogListener.onLoginFailed(cause);
                }
            }
        });
    }
    
    @Override
    public void onClick(View view) {
        switch (view.getId()) {
            case R.id.txt_signin:
            case R.id.txt_go_back:
                this.showSignIn();
                break;
            
            case R.id.txt_go_back1:
                this.showSignIn();
                break;
            
            case R.id.txt_signup:
                this.showSignUp();
                break;
            
            case R.id.txt_forget:
                this.showForgotForm();
                break;
            
            case R.id.btn_fb_signin:
                this.onFacebookLoginClick();
                break;
            
            case R.id.btn_google_signin:
                this.onGoogleLoginClick();
                break;
            
            case R.id.btn_twitter:
                this.onTwitterClick();
                break;
            
            case R.id.guest_continue_section:
                dismiss();
                MainActivity.mActivity.showEditProfile(false);
                break;
        }
    }
    
    private void onFacebookLoginClick() {
        mCallbackManager = CallbackManager.Factory.create();
        com.facebook.login.LoginManager.getInstance().registerCallback(mCallbackManager, new FacebookCallback<LoginResult>() {
            @Override
            public void onSuccess(final LoginResult loginResult) {
                Bundle parameters = new Bundle();
                parameters.putString("fields", "id, name, email");
                GraphRequest request = GraphRequest.newMeRequest(loginResult.getAccessToken(), new GraphRequest.GraphJSONObjectCallback() {
                    @Override
                    public void onCompleted(JSONObject object, GraphResponse response) {
                        try {
                            DummyUser userData = new DummyUser();
                            userData.user_type = AppUser.USER_TYPE.FACEBOOK_USER;
                            userData.validated_id = object.getString("id");
                            userData.avatar_url = "http://graph.facebook.com/" + userData.validated_id + "/picture?type=large";
                            userData.first_name = object.getString("name");
                            userData.last_name = "";
                            userData.email = object.getString("email");
                            userData.username = userData.email;
                            userData.password = loginResult.getAccessToken().getToken();
                            signInSocialUsing(userData);
                        } catch (Exception e) {
                            e.printStackTrace();
                            mActivity.hideProgress();
                            Helper.showErrorToast(e.toString());
                            if (mLoginDialogListener != null) {
                                mLoginDialogListener.onLoginFailed(e.toString());
                            }
                        }
                    }
                });
                request.setParameters(parameters);
                request.executeAsync();
            }
            
            @Override
            public void onCancel() {
                mActivity.hideProgress();
                if (mLoginDialogListener != null) {
                    mLoginDialogListener.onLoginFailed(L.getString(L.string.facebook_access_canceled));
                }
            }
            
            @Override
            public void onError(FacebookException exception) {
                mActivity.hideProgress();
                Helper.showToast(exception.toString());
                if (mLoginDialogListener != null) {
                    mLoginDialogListener.onLoginFailed(exception.toString());
                }
            }
        });
        mActivity.showProgress(L.getString(L.string.signing_in), false);
        com.facebook.login.LoginManager.getInstance().logInWithReadPermissions(mActivity, Arrays.asList("public_profile", "email"));
    }
    
    private void onGoogleLoginClick() {
        if (mGoogleApiClient == null) {
            mGoogleApiClient = new GoogleApiClient.Builder(mActivity).enableAutoManage(mActivity,
                new GoogleApiClient.OnConnectionFailedListener() {
                    @Override
                    public void onConnectionFailed(@NonNull ConnectionResult connectionResult) {
                        mActivity.hideProgress();
                        Helper.showErrorToast(getString(L.string.google_signin_failed));
                    }
                })
                .addApi(Auth.GOOGLE_SIGN_IN_API, new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                    .requestEmail()
                    .requestProfile()
                    .requestIdToken(AppInfo.GOOGLE_APP_KEY)
                    .build())
                .build();
        }
        mActivity.startActivityForResult(Auth.GoogleSignInApi.getSignInIntent(mGoogleApiClient), GOOGLE_SIGN_IN_REQUEST);
    }
    
    private void onTwitterClick() {
//                      userData.user_type = AppUser.USER_TYPE.TWITTER_USER;
//                    userData.email = userData.email;
//                    //TODO Note: Twitter does'nt allow access to email directly.
//                    /*  note: twitter doesn't provide user's email address directly // [https://twittercommunity.com/t/how-to-get-email-from-twitter-user-using-oauthtokens/558/2]
//                        to retrieve user's email address you need to request twitter in a separate form: [http://stackoverflow.com/questions/22627083/can-we-get-email-id-from-twitter-oauth-api]
//                    */
//                    if (TextUtils.isEmpty(userData.email)) {
//                        userData.email = profile.getValidatedId() + "@twitter.com";
//                        userData.username = profile.getValidatedId();
//                    } else {
//                        userData.username = profile.getEmail().split("@")[0];
//                    }
//                    userData.first_name = profile.getDisplayName();
//                  checkSignInSocial(userData);
    }
    
    private void showSignUp() {
        mSignUpForm.setVisibility(View.VISIBLE);
        mSignInForm.setVisibility(View.GONE);
        mForgotForm.setVisibility(View.GONE);
        mResetPasswordForm.setVisibility(View.GONE);
        mTitleView.setText(L.getString(L.string.action_sign_up_title));
    }
    
    private void showSignIn() {
        mSignUpForm.setVisibility(View.GONE);
        mSignInForm.setVisibility(View.VISIBLE);
        mForgotForm.setVisibility(View.GONE);
        mResetPasswordForm.setVisibility(View.GONE);
        mTitleView.setText(L.getString(L.string.action_sign_in_short));
    }
    
    private void showForgotForm() {
        mSignUpForm.setVisibility(View.GONE);
        mSignInForm.setVisibility(View.GONE);
        mForgotForm.setVisibility(View.VISIBLE);
        mResetPasswordForm.setVisibility(View.GONE);
        mTitleView.setText(L.getString(L.string.action_reset_password));
    }
    
    private void showResetForm() {
        mSignUpForm.setVisibility(View.GONE);
        mSignInForm.setVisibility(View.GONE);
        mForgotForm.setVisibility(View.GONE);
        mResetPasswordForm.setVisibility(View.VISIBLE);
        mTitleView.setText(L.getString(L.string.title_reset_password));
    }
    
    private void handleForgetPassword(String _email) {
        mActivity.showProgress(L.getString(L.string.updating), false);
        DataEngine.getDataEngine().recoverPassword(_email, new TM_LoginListener() {
            @Override
            public void onLoginSuccess(String response) {
                showSignIn();
                mActivity.hideProgress();
                Helper.POPUP(mActivity, L.getString(L.string.action_reset_password), response, true, null);
            }
            
            @Override
            public void onLoginFailed(String msg) {
                mActivity.hideProgress();
                Helper.POPUP(mActivity, L.getString(L.string.action_reset_password), msg, true, null);
            }
        });
    }
    
    private void handleForgetPassword(FragmentActivity activity, String mobileNo, String mobileEmail) {
        
        mActivity.showProgress(L.getString(L.string.verify), false);
        DataEngine.getDataEngine().verifyUserEmailInBackground(mobileEmail, new TM_LoginListener() {
            @Override
            public void onLoginSuccess(String response) {
                mActivity.hideProgress();
                
                mActivity.showProgress(L.getString(L.string.please_wait), false);
                DataEngine.getDataEngine().requestLoginOtpInBackground(mobileNo, new DataQueryHandler<String>() {
                    @Override
                    public void onSuccess(String data) {
                        mActivity.hideProgress();
                        try {
                            JSONObject jsonObject = new JSONObject(data);
                            if (jsonObject.has("message")) {
                                Object object = jsonObject.get("message");
                                String requestID = "";
                                String msg = "";
                                if (object instanceof JSONObject) {
                                    JSONObject requestIdObj = (JSONObject) object;
                                    msg = requestIdObj.getString("msg");
                                    requestID = requestIdObj.getString("request_id");
                                }
                                if (!jsonObject.getString("message").equalsIgnoreCase((L.string.user_already_registered)) || (!msg.isEmpty() && !msg.equalsIgnoreCase((L.string.user_already_registered)))) {
                                    OtpVerifyFragment otpVerifyFragment = OtpVerifyFragment.newInstance(
                                        () -> {
                                            showResetForm();
                                            
                                            password_reset_button.setOnClickListener(new View.OnClickListener() {
                                                @Override
                                                public void onClick(View v) {
                                                    Helper.hideKeyboard(v);
                                                    
                                                    final String _password = edit_password_new.getText().toString();
                                                    final String _password_confirm = edit_new_password_confirm.getText().toString();
                                                    
                                                    if (checkCredentials(mobileEmail, _password, _password_confirm)) {
                                                        
                                                        mActivity.showProgress(L.getString(L.string.updating), false);
                                                        DataEngine.getDataEngine().resetPasswordAfterOtp(mobileEmail, _password, new TM_LoginListener() {
                                                            @Override
                                                            public void onLoginSuccess(String response) {
                                                                showSignIn();
                                                                mActivity.hideProgress();
                                                                Helper.POPUP(mActivity, L.getString(L.string.action_reset_password), response, true, null);
                                                            }
                                                            
                                                            @Override
                                                            public void onLoginFailed(String msg) {
                                                                mActivity.hideProgress();
                                                                Helper.POPUP(mActivity, L.getString(L.string.action_reset_password), msg, true, null);
                                                            }
                                                        });
                                                    }
                                                }
                                            });
                                        },
                                        MainActivity.mActivity,
                                        mobileNo,
                                        requestID);
                                    otpVerifyFragment.show(activity.getSupportFragmentManager(), Fragment_Login_Dialog.class.getSimpleName());
                                } else {
                                    Helper.toast(jsonObject.getString("message"));
                                }
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                            Helper.toast(e.getMessage());
                        }
                    }
                    
                    @Override
                    public void onFailure(Exception error) {
                        mActivity.hideProgress();
                        Helper.toast(error.getMessage());
                    }
                });
                
            }
            
            @Override
            public void onLoginFailed(String msg) {
                mActivity.hideProgress();
                Helper.toast(msg);
            }
        });
    }
    
    private boolean verifyWeakPassword(String password) {
        if (password.length() == 0) {
            Helper.POPUP(mActivity, L.getString(L.string.prompt_password), L.getString(L.string.password_specification_weak), true, null);
            return false;
        }
        return true;
    }
    
    private boolean verifyAveragePassword(String password) {
        if (!verifyWeakPassword(password)) {
            return false;
        }
        
        boolean isAtLeast8 = password.length() >= 8;//Checks for at least 8 characters
        if (!isAtLeast8) {
            Helper.POPUP(mActivity, L.getString(L.string.prompt_password), L.getString(L.string.password_specification_average), true, null);
            return false;
        }
        
        boolean hasUppercase = !password.equals(password.toLowerCase());
        if (!hasUppercase) {
            Helper.POPUP(mActivity, L.getString(L.string.prompt_password), L.getString(L.string.password_specification_average), true, null);
            return false;
        }
        
        boolean hasLowercase = !password.equals(password.toUpperCase());
        if (!hasLowercase) {
            Helper.POPUP(mActivity, L.getString(L.string.prompt_password), L.getString(L.string.password_specification_average), true, null);
            return false;
        }
        return true;
    }
    
    private boolean verifyStrongPassword(String password) {
        if (!verifyAveragePassword(password)) {
            return false;
        }
        boolean hasNumber = password.matches(".*\\d.*");
        if (!hasNumber) {
            Helper.POPUP(mActivity, L.getString(L.string.prompt_password), L.getString(L.string.password_specification_strong), true, null);
            return false;
        }
        boolean hasSpecial = !password.matches("[A-Za-z0-9 ]*");//Checks at least one char is not alpha numeric
        if (!hasSpecial) {
            Helper.POPUP(mActivity, L.getString(L.string.prompt_password), L.getString(L.string.password_specification_strong), true, null);
            return false;
        }
        return true;
    }
    
    private boolean checkCredentials(String email) {
        if (isVisible(email_2) && !android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
            Helper.toast(L.string.invalid_email);
            return false;
        }
        return true;
    }
    
    private boolean checkCredentials(String email, String password) {
        if (!android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
            Helper.toast(L.string.invalid_email);
            return false;
        }
        return verifyWeakPassword(password);
    }
    
    private boolean checkCredentials(String email, String password, String confirmPassword) {
        if (isVisible(email1) && !android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
            Helper.toast(L.string.invalid_email);
            return false;
        }
        
        boolean result;
        if (!isVisible(password1) && !isVisible(password_confirm)) {
            return false;
        }
        
        switch (AppInfo.REQUIRED_PASSWORD_STRENGTH) {
            case 1:
                result = verifyAveragePassword(password);
                break;
            case 2:
                result = verifyStrongPassword(password);
                break;
            default:
                result = verifyWeakPassword(password);
                break;
        }
        
        if (!result)
            return false;
        
        if (!confirmPassword.equals(password)) {
            Helper.toast(L.string.passwords_mismatch);
            return false;
        }
        return true;
    }
    
    private boolean checkSellerCredentials(String email, String password, String confirmPassword, String str_first_name, String str_last_name, String str_shop_name, String phone) {
        if (!checkCredentials(email, password, confirmPassword)) {
            return false;
        }
        
        if (isVisible(first_name) && !Helper.isValidString(str_first_name)) {
            Helper.toast(L.string.invalid_first_name);
            return false;
        }
        if (isVisible(last_name) && !Helper.isValidString(str_last_name)) {
            Helper.toast(L.string.invalid_last_name);
            return false;
        }
        if (isVisible(shop_name) && !Helper.isValidString(str_shop_name)) {
            Helper.toast(L.string.invalid_shop_name);
            return false;
        }
        if (isVisible(contact) && !Helper.isValidPhoneNumber(phone)) {
            Helper.toast(L.string.invalid_contact_number);
            return false;
        }
        return true;
    }
    
    private boolean checkMCIRegistrationCredentials(String email, String password, String confirmPassword, String str_first_name
        , String str_last_name, String mobile_no, String mci_registration_number, String mci_year_registration, String qualification) {
        if (!checkMobileCredentials(email, password, confirmPassword, mobile_no, selectedCountryCodeSignup)) {
            return false;
        }
        if (isVisible(edit_mci_registration_number) && !Helper.isValidString(mci_registration_number)) {
            Helper.toast(L.string.invalid_mci_registration_number);
            return false;
        }
        if (isVisible(edit_mci_year_registration) && !Helper.isValidString(mci_year_registration)) {
            Helper.toast(L.string.invalid_mci_year_registration);
            return false;
        }
//TODO Umcomment if use year check from 1970-2029
//        final String PATTERN_YEAR = "^(197\\d{1}|198\\d{1}|199\\d{1}|200\\d{1}|201\\d{1}|202\\d{1})"; // ^(19|20)\d{2}$
//        Pattern pattern = Pattern.compile(PATTERN_YEAR);
//        Matcher matcher = pattern.matcher(mci_year_registration);
//        if (!matcher.matches()) {
//            Helper.toast(L.string.invalid_mci_year_registration);
//            return false;
//        }
        
        if (isVisible(edit_qualification) && !Helper.isValidString(qualification)) {
            Helper.toast(L.string.invalid_qualification);
            return false;
        }
        
        if (isVisible(first_name) && !Helper.isValidString(str_first_name)) {
            Helper.toast(L.string.invalid_first_name);
            return false;
        }
        if (isVisible(last_name) && !Helper.isValidString(str_last_name)) {
            Helper.toast(L.string.invalid_last_name);
            return false;
        }
        return true;
    }
    
    private boolean isVisible(EditText view) {
        return view.getVisibility() == View.VISIBLE;
    }
    
    private boolean checkMobileCredentials(String email, String password, String confirmPassword, String phone, String countryCode) {
        if (!checkCredentials(email, password, confirmPassword)) {
            return false;
        }
        if (isVisible(editMobileNumber) && !Helper.isValidPhoneNumber(phone)) {
            Helper.toast(L.string.invalid_contact_number);
            return false;
        }
        if (!Helper.isValidString(countryCode)) {
            Helper.toast(L.string.invalid_select_country_code);
            return false;
        }
        return true;
    }
    
    private boolean checkMobileEmailCredentials(String mobileNo, String countryCode, String emailDomain, String password, boolean checkPass) {
        if (!Helper.isValidString(mobileNo) && !Helper.isValidPhoneNumber(mobileNo)) {
            Helper.toast(L.string.invalid_contact_number);
            return false;
        }
        
        if (!Helper.isValidString(countryCode)) {
            Helper.toast(L.string.invalid_select_country_code);
            return false;
        }
        
        if (!Helper.isValidString(emailDomain)) {
            Helper.toast(L.string.invalid_email_domain);
            return false;
        }
        if (checkPass) {
            return verifyWeakPassword(password);
        } else {
            return true;
        }
    }
    
    private void checkSignInSocial(final DummyUser userData) {
        try {
            if (userData.first_name == null && userData.username != null) {
                if (userData.username.contains(" ")) {
                    userData.first_name = userData.username.substring(0, userData.username.lastIndexOf(" "));
                    userData.last_name = userData.username.substring(userData.username.lastIndexOf(" "), userData.username.length());
                } else {
                    userData.first_name = userData.username;
                }
            }
            
            if (userData.last_name == null) {
                userData.last_name = "";
            }
            if (userData.password == null) {
                userData.password = "";
            }
            if (userData.avatar_url == null) {
                userData.avatar_url = "";
            }
            
            if (Log.DEBUG) {
                Log.d("Validate ID = " + userData.validated_id);
                Log.d("First Name  = " + userData.first_name);
                Log.d("Last Name = " + userData.last_name);
                Log.d("Username = " + userData.username);
                Log.d("Email = " + userData.email);
                Log.d("Password = " + userData.password);
                Log.d("Profile Image URL = " + userData.avatar_url);
            }
            signInSocialUsing(userData);
        } catch (Exception e) {
            Helper.toast(L.string.login_failed);
            mActivity.hideProgress();
            e.printStackTrace();
        }
    }
    
    private void signInSocialUsing(final DummyUser userData) {
        DataEngine.getDataEngine().signInSocialUsing(userData.email, new TM_LoginListener() {
            @Override
            public void onLoginSuccess(String data) {
                signInWeb(userData);
                AnalyticsHelper.registerSignInEvent("Social Signin");
            }
            
            @Override
            public void onLoginFailed(String msg) {
                onUserLoginFailed(msg);
            }
        });
    }
    
    private void signInWeb(final DummyUser userData) {
        LoginManager.fetchCustomerData(
            userData.email,
            new LoginListener() {
                @Override
                public void onLoginSuccess(String message) {
                    MainActivity.mActivity.createAppUser(true);
                    MainActivity.mActivity.signInParse(userData.email, new LoginListener() {
                        @Override
                        public void onLoginSuccess(String message) {
                            AppUser.getInstance().user_type = userData.user_type;
                            AppUser.getInstance().email = userData.email;
                            AppUser.getInstance().username = userData.username;
                            AppUser.getInstance().password = userData.password;
                            AppUser.getInstance().first_name = userData.first_name;
                            AppUser.getInstance().last_name = userData.last_name;
                            AppUser.getInstance().avatar_url = userData.avatar_url;
                            AppUser.getInstance().sync();
                            AppUser.getInstance().saveAll();
                            MainActivity.mActivity.resetDrawer();
                            mActivity.hideProgress();
                            dismiss();
                            if (mLoginDialogListener != null) {
                                mLoginDialogListener.onLoginSuccess();
                            }
                        }
                        
                        @Override
                        public void onLoginFailed(String cause) {
                            onUserLoginFailed(cause);
                        }
                    });
                }
                
                @Override
                public void onLoginFailed(String cause) {
                    onUserLoginFailed(cause);
                }
            }
        );
    }
    
    private void onUserLoginFailed(String cause) {
        mActivity.hideProgress();
        Helper.toast(cause);
        if (mLoginDialogListener != null) {
            mLoginDialogListener.onLoginFailed(cause);
        }
    }
    
    public TextInputLayout setTextInputLayout(int id, String stringHint) {
        if (rootView == null) {
            return null;
        }
        TextInputLayout textInputLayout = (TextInputLayout) rootView.findViewById(id);
        textInputLayout.setHint(L.getString(stringHint));
        Helper.stylize(textInputLayout);
        return textInputLayout;
    }
    
    public EditText setEditText(int id, boolean hasBorder) {
        if (rootView == null) {
            return null;
        }
        EditText edittext = (EditText) rootView.findViewById(id);
        Helper.stylize(edittext, hasBorder);
        return edittext;
    }
    
    public Button setButtonLayout(int id, String stringHint) {
        if (rootView == null) {
            return null;
        }
        Button button = (Button) rootView.findViewById(id);
        button.setText(L.getString(stringHint));
        Helper.stylize(button);
        return button;
    }
    
    private CountrySpinner setCountrySpinner(int id) {
        CountrySpinner spinner_country = rootView.findViewById(id);
        spinner_country.setPrompt(L.getString(L.string.dialog_title_select_country_code));
        String myCountry = spinner_country.getDefaultCountryName();
        spinner_country.setCountries(myCountry);
        return spinner_country;
    }
    
}
