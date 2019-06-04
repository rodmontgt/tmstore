package com.twist.tmstore.fragments;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.IdRes;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.design.widget.TextInputLayout;
import android.support.v7.app.ActionBar;
import android.text.TextUtils;
import android.text.method.PasswordTransformationMethod;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.GraphRequest;
import com.facebook.GraphResponse;
import com.facebook.login.LoginResult;
import com.google.android.gms.auth.api.Auth;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.auth.api.signin.GoogleSignInResult;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.twist.dataengine.entities.SellerInfo;
import com.twist.dataengine.TM_LoginListener;
import com.twist.tmstore.BaseActivity;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.Extras;
import com.twist.tmstore.L;
import com.twist.tmstore.LoginManager;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.config.MultiVendorConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.entities.DummyUser;
import com.twist.tmstore.listeners.LoginListener;
import com.twist.tmstore.listeners.TaskListener;
import com.utils.AnalyticsHelper;
import com.utils.CContext;
import com.utils.Helper;
import com.utils.Log;
import com.utils.customviews.IconButton;

import org.json.JSONObject;

import java.util.Arrays;

public class SellerLoginFragment extends BaseFragment implements View.OnClickListener {

    private static final int GOOGLE_SIGN_IN_REQUEST = 100;
    private View rootView;
    private Context context;
    private BaseActivity mActivity;
    private TextInputLayout labelMobileNumber;
    private EditText editMobileNumber;
    private TextView mTitleView;
    private EditText email;
    private EditText password;
    private EditText password1;
    private EditText password_confirm;
    private EditText email1;
    private EditText email_2;
    private EditText first_name;
    private EditText last_name;
    private EditText shop_name;
    private EditText contact;
    private Button email_sign_in_button;
    private Button email_sign_up_button;
    private Button email_forget_button;
    private Button next_button;
    private IconButton btnFacebook;
    private IconButton btnGoogle;
    private IconButton btnTwitter;
    private View mSignUpForm, mSignInForm, mForgotForm;
    private CallbackManager mCallbackManager;
    private GoogleApiClient mGoogleApiClient;
    private boolean _signingUpAsSeller = false;
    private RadioGroup check_vendor;
    private LinearLayout guest_continue_section;
    private TextView label_guest_continue;

    public SellerLoginFragment() {
    }

    public static SellerLoginFragment newInstance() {
        SellerLoginFragment fragment = new SellerLoginFragment();

        return fragment;
    }


    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setHomeButtonEnabled(true);
            actionBar.setDisplayHomeAsUpEnabled(true);
            Drawable upArrow = CContext.getDrawable(getActivity(), R.drawable.abc_ic_ab_back_material);
            upArrow.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_ATOP);
            actionBar.setHomeAsUpIndicator(upArrow);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
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
                    if (MultiVendorConfig.isSellerApp()) {
                        check_vendor.setVisibility(View.GONE);
                    } else {
                        check_vendor.setVisibility(View.VISIBLE);
                    }
                    break;
                case REQUIRED:
                    check_vendor.setVisibility(View.GONE);
                    break;
            }
        }
    }

    public View onCreateView(Activity activity, LayoutInflater inflater, ViewGroup container) {

        mActivity = (BaseActivity) activity;
        context = inflater.getContext();

        rootView = inflater.inflate(R.layout.seller_login_fragment, container, false);
        rootView.setFocusableInTouchMode(true);
        rootView.requestFocus();

        if (rootView != null && rootView.requestFocus()) {
            getActivity().getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
        }

        ImageView login_bg = (ImageView) rootView.findViewById(R.id.login_bg);
        if (Helper.isValidString(AppInfo.login_bg)) {
            login_bg.setVisibility(View.VISIBLE);
            Glide.with(context)
                    .load(AppInfo.login_bg)
                    .into(login_bg);
        } else {
            login_bg.setVisibility(View.GONE);
        }

        initComponent();

        TextView textViewSignIn = (TextView) rootView.findViewById(R.id.txt_signin);
        textViewSignIn.setText(L.getString(L.string.sign_in_here));
        textViewSignIn.setOnClickListener(this);

        TextView textViewSignUp = (TextView) rootView.findViewById(R.id.txt_signup);
        textViewSignUp.setText(L.getString(L.string.sign_up_here));
        textViewSignUp.setOnClickListener(this);

        TextView txt_forget = (TextView) rootView.findViewById(R.id.txt_forget);
        txt_forget.setText(L.getString(L.string.txt_forget));
        txt_forget.setOnClickListener(this);

        TextView txt_go_back = (TextView) rootView.findViewById(R.id.txt_go_back);
        txt_go_back.setText(L.getString(L.string.txt_go_back));
        txt_go_back.setOnClickListener(this);

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


        if (!AppInfo.SHOW_SIGNUP_UI) {
            showSignIn();
            rootView.findViewById(R.id.social_section).setVisibility(View.GONE);
            rootView.findViewById(R.id.dont_have_account).setVisibility(View.GONE);
            textViewSignUp.setVisibility(View.GONE);
        } else {
            showSignUp();
        }

        password.setTypeface(email.getTypeface());
        password.setTransformationMethod(new PasswordTransformationMethod());

        password1.setTypeface(email1.getTypeface());
        password_confirm.setTypeface(email.getTypeface());
        password1.setTransformationMethod(new PasswordTransformationMethod());
        password_confirm.setTransformationMethod(new PasswordTransformationMethod());

        password.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_DONE) {
                    email_sign_in_button.callOnClick();
                }
                return false;
            }
        });
        return rootView;
    }

    private void initComponent() {

        LinearLayout loginActionBar = (LinearLayout) rootView.findViewById(R.id.login_action_bar);
        loginActionBar.setBackgroundColor(Color.parseColor(AppInfo.color_theme));

        mTitleView = (TextView) rootView.findViewById(R.id.txt_login_title);
        mTitleView.setTextColor(Color.parseColor(AppInfo.color_actionbar_text));

        ImageView iv_close = (ImageView) rootView.findViewById(R.id.iv_close);
        iv_close.setVisibility(AppInfo.CANCELLABLE_LOGIN ? View.VISIBLE : View.GONE);
        Drawable drawableClose = CContext.getDrawable(context, R.drawable.ic_vc_close);
        drawableClose.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_ATOP);
        iv_close.setImageDrawable(drawableClose);
        iv_close.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                MainActivity.mActivity.getFM().popBackStack();
            }
        });


        mSignUpForm = rootView.findViewById(R.id.email_signup_form);
        mSignInForm = rootView.findViewById(R.id.email_login_form);
        mForgotForm = rootView.findViewById(R.id.email_forgot_form);

        TextInputLayout label_email = setTextInputLayout(R.id.label_email, L.string.prompt_email);
        TextInputLayout label_email1 = setTextInputLayout(R.id.label_email1, L.string.prompt_email);
        TextInputLayout label_password = setTextInputLayout(R.id.label_password, L.string.prompt_password);
        TextInputLayout label_password1 = setTextInputLayout(R.id.label_password1, L.string.prompt_password);
        TextInputLayout label_password_confirm = setTextInputLayout(R.id.label_password_confirm, L.string.prompt_password_confirm);
        TextInputLayout label_shop_name = setTextInputLayout(R.id.label_shop_name, L.string.prompt_shop_name);
        TextInputLayout label_first_name = setTextInputLayout(R.id.label_first_name, L.string.first_name);
        TextInputLayout label_last_name = setTextInputLayout(R.id.label_last_name, L.string.last_name);
        TextInputLayout label_contact_number = setTextInputLayout(R.id.label_contact, L.string.contact_number);

        labelMobileNumber = setTextInputLayout(R.id.label_mobile_number, L.string.mobile_number);
        labelMobileNumber.setVisibility(View.GONE);
        editMobileNumber = setEditText(R.id.edit_mobile_number, R.drawable.ic_vc_contact_phone);
        if (AppInfo.SHOW_MOBILE_NUMBER_IN_SIGNUP) {
            labelMobileNumber.setVisibility(View.VISIBLE);
            editMobileNumber.setVisibility(View.VISIBLE);
        }

        setTextOnView(rootView, R.id.dont_have_account, L.string.dont_have_account);
        setTextOnView(rootView, R.id.already_have_account, L.string.already_have_account);
        setTextOnView(rootView, R.id.sign_in_1_click, L.string.sign_in_1_click);
        setTextOnView(rootView, R.id.txt_or, L.string.or);
        setTextOnView(rootView, R.id.txt_forget, L.string.txt_forget);

        email = setEditText(R.id.email, R.drawable.ic_vc_email);
        password = setEditText(R.id.password, R.drawable.ic_vc_password_vpn_key);
        password1 = setEditText(R.id.password1, R.drawable.ic_vc_password_vpn_key);
        password_confirm = setEditText(R.id.password_confirm, R.drawable.ic_vc_verified_user);

        email1 = setEditText(R.id.email1, R.drawable.ic_vc_email);
        email_2 = setEditText(R.id.email_2, R.drawable.ic_vc_email);

        first_name = setEditText(R.id.first_name, R.drawable.ic_vc_person);
        last_name = setEditText(R.id.last_name, R.drawable.ic_vc_person);
        shop_name = setEditText(R.id.shop_name, R.drawable.ic_vc_store);
        contact = setEditText(R.id.contact, R.drawable.ic_vc_contact_phone);


        email_sign_in_button = setButtonLayout(R.id.email_sign_in_button, L.string.action_sign_in_short);
        email_sign_up_button = setButtonLayout(R.id.email_sign_up_button, L.string.action_sign_up_short);
        email_forget_button = setButtonLayout(R.id.email_forget_button, L.string.action_reset_password);

        next_button = setButtonLayout(R.id.next_button, L.string.action_sign_up_short);
        Helper.setDrawableRightOnButton(getActivity(), next_button, R.drawable.ic_vc_navigate);
        next_button.setVisibility(View.GONE);

        setAllSocialLoginButton();

        allButtonClick();

        if (MultiVendorConfig.isEnabled()) {
            rootView.findViewById(R.id.vendor_section).setVisibility(View.VISIBLE);

            final View vendor_options = rootView.findViewById(R.id.vendor_options);
            vendor_options.setVisibility(View.GONE);

            check_vendor = (RadioGroup) rootView.findViewById(R.id.check_vendor);
            final RadioButton seller = (RadioButton) rootView.findViewById(R.id.seller);
            final RadioButton buyer = (RadioButton) rootView.findViewById(R.id.buyer);
            buyer.setChecked(true);
            _signingUpAsSeller = false;
            labelMobileNumber.setVisibility(View.VISIBLE);
            if (MultiVendorConfig.isSellerApp()) {
                vendor_options.setVisibility(View.VISIBLE);
                check_vendor.setVisibility(View.GONE);
                labelMobileNumber.setVisibility(View.GONE);
                rootView.findViewById(R.id.social_section).setVisibility(View.GONE);
                _signingUpAsSeller = true;
            }
            check_vendor.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(RadioGroup group, @IdRes int checkedId) {
                    // find which radio button is selected
                    if (checkedId == R.id.seller) {
                        Helper.toast("choice: Seller");
                        _signingUpAsSeller = true;
                    } else if (checkedId == R.id.buyer) {
                        Helper.toast("choice: buyer");
                        _signingUpAsSeller = false;
                    }
                    vendor_options.setVisibility(_signingUpAsSeller ? View.VISIBLE : View.GONE);
//                    next_button.setVisibility(_signingUpAsSeller ? View.VISIBLE : View.GONE);
//                    email_sign_up_button.setVisibility(_signingUpAsSeller ? View.GONE : View.VISIBLE);

                    labelMobileNumber.setVisibility(_signingUpAsSeller ? View.GONE : View.VISIBLE);
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
    }

    private void setAllSocialLoginButton() {
        btnFacebook = (IconButton) rootView.findViewById(R.id.btn_fb_signin);
        btnGoogle = (IconButton) rootView.findViewById(R.id.btn_google_signin);
        btnTwitter = (IconButton) rootView.findViewById(R.id.btn_twitter);

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

        if (btnFacebook.getVisibility() == View.GONE
                && btnTwitter.getVisibility() == View.GONE
                && btnGoogle.getVisibility() == View.GONE) {
            rootView.findViewById(R.id.social_section).setVisibility(View.GONE);
        }
    }

    private void allButtonClick() {

        email_sign_in_button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Helper.hideKeyboard(v);
                final String _email = email.getText().toString();
                final String _password = password.getText().toString();
                if (checkCredentials(_email, _password)) {
                    signInAPI(_email, _password);
                }
            }
        });

        next_button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

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
                if (_signingUpAsSeller) {
                    final String _first_name = first_name.getText().toString();
                    final String _last_name = last_name.getText().toString();
                    final String _shop_name = shop_name.getText().toString();
                    final String _phone = contact.getText().toString();
                    if (checkSellerCredentials(_email, _password, _password_confirm, _first_name, _last_name, _shop_name, _phone)) {
                        mActivity.showProgress(L.getString(L.string.signing_up), false);
                        signUpPluginForSeller(_email, _password, _first_name, _last_name, _shop_name, _phone, "seller");
                    }
                } else if (AppInfo.SHOW_MOBILE_NUMBER_IN_SIGNUP) {
                    if (AppInfo.REQUIRE_MOBILE_NUMBER_IN_SIGNUP) {
                        _username = editMobileNumber.getText().toString();
                        if (checkMobileCredentials(_email, _password, _password_confirm, _username)) {
                            mActivity.showProgress(L.getString(L.string.please_wait), false);
                            DataEngine.getDataEngine().requestLoginOtpInBackground(editMobileNumber.getText().toString(), new DataQueryHandler<String>() {
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
                                                        signUpWebUsing(_email, editMobileNumber.getText().toString(), _password);
                                                    }
                                                }, MainActivity.mActivity, editMobileNumber.getText().toString());
                                                otpVerifyFragment.show(getActivity().getSupportFragmentManager(), SellerLoginFragment.class.getSimpleName());
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
                    } else if (checkCredentials(_email, _password, _password_confirm)) {
                        _username = _email;
                        MainActivity.mActivity.showProgress(L.getString(L.string.signing_up), false);
                        signUpWebUsing(_email, _username, _password);
                    }

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
                if (checkCredentials(_email)) {
                    handleForgetPassword(_email);
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
                                        MainActivity.mActivity.createAppUser(false);
                                        signInParse(_email, _password);
                                    }

                                    @Override
                                    public void onLoginFailed(String error) {
                                        Log.d("-- signInWeb::onLoginFailed --");
                                        mActivity.hideProgress();
                                        Helper.showErrorToast(error);
                                    }
                                }
                        );
                    }

                    @Override
                    public void onLoginFailed(String cause) {
                        mActivity.hideProgress();
                        Helper.showToast(cause);
                    }
                }
        );
    }

    private void signInParse(final String _email, final String _password) {
        ((MainActivity) getActivity()).signInParse(_email, new LoginListener() {
            @Override
            public void onLoginSuccess(String message) {
                Log.d("-- signInParse::onLoginSuccess --");
                AppUser.getInstance().password = _password;
                AppUser.getInstance().save();
                if (MultiVendorConfig.isEnabled()) {
                    if (AppUser.isPendingVendor()) {
                        onUserLoginFailed(getString(L.string.seller_verification_is_pending));
                    } else if (AppUser.isVendor()) {
                        ((MainActivity) getActivity()).resetDrawer();
                        ((MainActivity) getActivity()).fetchVendor(new TaskListener() {
                            @Override
                            public void onTaskDone() {
                                if (MultiVendorConfig.isSellerApp()) {
                                    ((MainActivity) getActivity()).showHomeFragment(true);
                                } else {
                                    loginSuccess();
                                }
                                mActivity.hideProgress();
                            }

                            @Override
                            public void onTaskFailed(String msg) {
                                onUserLoginFailed(msg);
                            }
                        });
                    } else {
                        onUserLoginFailed(getString(L.string.not_registered_as_vendor));
                    }
                } else {
                    onUserLoginFailed(getString(L.string.not_registered_as_vendor));
                }
            }

            @Override
            public void onLoginFailed(String cause) {
                Log.d("-- signInParse::onLoginFailed --");
                mActivity.hideProgress();
                Helper.showToast(cause);
            }
        });
    }

    private void loginSuccess() {
        if (MultiVendorConfig.isSellerApp()) {
            if (MultiVendorConfig.isEnabled() && AppUser.isVendor()) {
                SellerInfo sellerInfo = SellerInfo.getCurrentSeller();
                if (sellerInfo != null && sellerInfo.isVerified()) {
                    ((MainActivity) getActivity()).showVendorSection(true);
                } else if (sellerInfo != null && !sellerInfo.isVerified()) {
                    Helper.POPUP(getActivity(), getString(L.string.dialog_title_thankyou), getString(L.string.dialog_msg_not_verified_seller), false, new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            ((MainActivity) getActivity()).showVendorSection(true);
                        }
                    });
                } else {
                    Helper.toast(getString(L.string.not_registered_as_vendor));
                    ((MainActivity) getActivity()).updateUserInfoInBackground();
                }
            } else {
                Helper.POPUP(getActivity(), getString(L.string.dialog_title_alert), getString(L.string.dialog_msg_not_seller), true, null);
            }
        }
    }

    private void signUpWebUsing(final String _email, final String _username, final String _password) {
        DataEngine.getDataEngine().signUpWebUsing(_email, _username, _password, new TM_LoginListener() {
            @Override
            public void onLoginSuccess(String data) {
                Log.d("-- signUpWebUsing::onLoginSuccess --");
                signUpAPI(_email, _password);
                AnalyticsHelper.registerSignInEvent("Web SignUp");
            }

            @Override
            public void onLoginFailed(String msg) {
                mActivity.hideProgress();
                Helper.showToast(msg);
            }
        });
    }

    private void signUpPluginForSeller(final String _email, final String _password, String _first_name, String _last_name, String _shop_name, String _phone, String _role) {
        // Here email and user id are same;
        DataEngine.getDataEngine().signUpWebUsing(_email, _email, _password, _first_name, _last_name, _shop_name, _phone, _role, new TM_LoginListener() {
            @Override
            public void onLoginSuccess(String data) {
                Log.d("-- signUpPluginForSeller::signUpWebUsing::onLoginSuccess --");
                signUpAPI(_email, _password);
                AnalyticsHelper.registerSignInEvent("Web SignUp");
            }

            @Override
            public void onLoginFailed(String msg) {
                mActivity.hideProgress();
                Helper.showToast(msg);
            }
        });
    }

    private void signUpAPI(final String _email, final String _password) {
        LoginManager.fetchCustomerData(
                _email,
                new LoginListener() {
                    @Override
                    public void onLoginSuccess(String message) {
                        Log.d("-- signInAPIUsing::onLoginSuccess --");
                        AnalyticsHelper.registerSignUpEvent("API Signup");
                        MainActivity.mActivity.createAppUser(false);
                        signUpParse(_email, _password);
                    }

                    @Override
                    public void onLoginFailed(String cause) {
                        mActivity.hideProgress();
                        Helper.showToast(cause);
                    }
                }
        );
    }

    private void signUpParse(final String _email, final String _password) {
        MainActivity.mActivity.signInParse(_email, new LoginListener() {
            @Override
            public void onLoginSuccess(String message) {
                AppUser.getInstance().password = _password;
                AppUser.getInstance().save();
                Log.d("-- signInParse::onLoginSuccess --");
                MainActivity.mActivity.resetDrawer();
                if (MultiVendorConfig.isEnabled()) {
                    if (AppUser.isPendingVendor()) {
                        mActivity.hideProgress();
                        Helper.showToast(getString(L.string.dialog_msg_not_verified_seller));
                        getSupportFM().popBackStack();
                    } else if (AppUser.isVendor()) {
                        MainActivity.mActivity.fetchVendor(new TaskListener() {
                            @Override
                            public void onTaskDone() {
                                if (MultiVendorConfig.isSellerApp()) {
                                    MainActivity.mActivity.showHomeFragment(true);
                                } else {
                                    loginSuccess();
                                }
                                mActivity.hideProgress();
                            }

                            @Override
                            public void onTaskFailed(String msg) {
                                onUserLoginFailed(msg);
                            }
                        });
                    }
                }
            }

            @Override
            public void onLoginFailed(String cause) {
                mActivity.hideProgress();
                Helper.showToast(cause);
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
                        }
                    }
                });
                request.setParameters(parameters);
                request.executeAsync();
            }

            @Override
            public void onCancel() {
                mActivity.hideProgress();
                Helper.showToast(L.getString(L.string.facebook_access_canceled));
            }

            @Override
            public void onError(FacebookException exception) {
                mActivity.hideProgress();
                Helper.showToast(exception.toString());

            }
        });
        mActivity.showProgress(L.getString(L.string.signing_in), false);
        com.facebook.login.LoginManager.getInstance().logInWithReadPermissions(mActivity, Arrays.asList("public_profile", "email"));
    }

    private void onGoogleLoginClick() {
        GoogleSignInOptions gso = new GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                .requestEmail()
                .requestProfile()
                .requestIdToken(AppInfo.GOOGLE_APP_KEY)
                .build();

        GoogleApiClient.OnConnectionFailedListener listener = new GoogleApiClient.OnConnectionFailedListener() {
            @Override
            public void onConnectionFailed(@NonNull ConnectionResult connectionResult) {
                mActivity.hideProgress();
                Helper.showErrorToast(getString(L.string.google_signin_failed));
            }
        };

        if (mGoogleApiClient == null) {
            mGoogleApiClient = new GoogleApiClient.Builder(mActivity).enableAutoManage(mActivity, listener).addApi(Auth.GOOGLE_SIGN_IN_API, gso).build();
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
        mTitleView.setText(L.getString(L.string.action_sign_up_title));
        setTitle(L.getString(L.string.action_sign_up_title));
    }

    private void showSignIn() {
        mSignUpForm.setVisibility(View.GONE);
        mSignInForm.setVisibility(View.VISIBLE);
        mForgotForm.setVisibility(View.GONE);
        mTitleView.setText(L.getString(L.string.action_sign_in_short));
        setTitle(L.getString(L.string.action_sign_in_short));
    }

    private void showForgotForm() {
        mSignUpForm.setVisibility(View.GONE);
        mSignInForm.setVisibility(View.GONE);
        mForgotForm.setVisibility(View.VISIBLE);
        mTitleView.setText(L.getString(L.string.action_reset_password));
        setTitle(L.getString(L.string.action_reset_password));
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
        if (!android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
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
        if (!android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
            Helper.toast(L.string.invalid_email);
            return false;
        }

        boolean result;
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

    private boolean checkSellerCredentials(String email, String password, String confirmPassword, String first_name, String last_name, String shop_name, String phone) {
        if (!checkCredentials(email, password, confirmPassword)) {
            return false;
        }
        if (!Helper.isValidString(first_name)) {
            Helper.toast(L.string.invalid_first_name);
            return false;
        }
        if (!Helper.isValidString(last_name)) {
            Helper.toast(L.string.invalid_last_name);
            return false;
        }
        if (!Helper.isValidString(shop_name)) {
            Helper.toast(L.string.invalid_shop_name);
            return false;
        }
        if (!Helper.isValidPhoneNumber(phone)) {
            Helper.toast(L.string.invalid_contact_number);
            return false;
        }
        return true;
    }

    private boolean checkMobileCredentials(String email, String password, String confirmPassword, String phone) {
        if (!checkCredentials(email, password, confirmPassword)) {
            return false;
        }
        if (!Helper.isValidPhoneNumber(phone)) {
            Helper.toast(L.string.invalid_contact_number);
            return false;
        }
        return true;
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
                        MainActivity.mActivity.createAppUser(false);
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
                                if (MultiVendorConfig.isEnabled() && AppUser.isVendor()) {
                                    MainActivity.mActivity.fetchVendor(new TaskListener() {
                                        @Override
                                        public void onTaskDone() {
                                            if (MultiVendorConfig.isSellerApp()) {
                                                MainActivity.mActivity.showHomeFragment(true);
                                            } else {
                                                loginSuccess();
                                            }
                                            mActivity.hideProgress();
                                        }

                                        @Override
                                        public void onTaskFailed(String msg) {
                                            onUserLoginFailed(msg);
                                        }
                                    });
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
        Helper.showToastLong(cause);
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
        menu.clear();
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

    public EditText setEditText(int id, int drawableResId) {
        if (rootView == null) {
            return null;
        }
        EditText edittext = (EditText) rootView.findViewById(id);
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
}