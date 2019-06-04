package com.twist.tmstore.fragments;

import android.app.Activity;
import android.graphics.Color;
import android.graphics.Point;
import android.graphics.Typeface;
import android.os.Bundle;
import android.support.design.widget.TextInputLayout;
import android.support.v7.app.AlertDialog;
import android.support.v7.widget.CardView;
import android.support.v7.widget.RecyclerView;
import android.text.Spannable;
import android.text.SpannableStringBuilder;
import android.text.style.StyleSpan;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.twist.dataengine.entities.RewardPoint;
import com.twist.dataengine.TM_LoginListener;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.Adapter_MyProfile;
import com.twist.tmstore.config.MultiVendorConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.entities.RoleType;
import com.twist.tmstore.listeners.MyProfileItemClickListener;
import com.twist.tmstore.listeners.NavigationDrawerCallbacks;
import com.utils.CContext;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.customviews.RoundedImageView;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by Twist Mobile on 05-12-2016.
 */

public class Fragment_Profile extends BaseFragment {

    private TextView tv_user_name;
    private TextView tv_user_email;
    private RoundedImageView iv_user_profile;
    private RecyclerView rv_my_profile;
    private Adapter_MyProfile adapter_myProfile;
    private NavigationDrawerCallbacks mCallbacks;
    private CardView card_view;

    private TextView mPointsView;
    private TextView mVendorStatusView;

    public static Fragment_Profile newInstance(NavigationDrawerCallbacks mCallback) {
        Fragment_Profile fragment = new Fragment_Profile();
        fragment.mCallbacks = mCallback;
        return fragment;
    }

    public Fragment_Profile() {
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.my_profile, container, false);

        setActionBarHomeAsUpIndicator();
        getBaseActivity().restoreActionBar();
        setTitle(getString(L.string.app_name));

        rv_my_profile = (RecyclerView) view.findViewById(R.id.rv_my_profile);

        View list_header = View.inflate(getActivity(), R.layout.fragment_profile_header, null);
        card_view = (CardView) list_header.findViewById(R.id.card_view);

        {
            Display display = getActivity().getWindowManager().getDefaultDisplay();
            Point size = new Point();
            display.getSize(size);

            int windowHeight = (int) (AppInfo.HOME_SLIDER_STANDARD_HEIGHT * size.x * 1.0f / AppInfo.HOME_SLIDER_STANDARD_WIDTH);
            LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, windowHeight);
            card_view.setLayoutParams(params);
        }

        ImageView profile_bg = (ImageView) list_header.findViewById(R.id.profile_bg);
        if (Helper.isValidString(AppInfo.profile_header_bg)) {
            profile_bg.setVisibility(View.VISIBLE);
            Glide.with(getActivity()).load(AppInfo.profile_header_bg)
                    .into(profile_bg);
        } else {
            profile_bg.setVisibility(View.GONE);
        }

        tv_user_name = (TextView) list_header.findViewById(R.id.tv_user_name);
        tv_user_email = (TextView) list_header.findViewById(R.id.tv_user_email);
        iv_user_profile = (RoundedImageView) list_header.findViewById(R.id.iv_user_profile);
        mPointsView = (TextView) list_header.findViewById(R.id.your_points);
        mPointsView.setVisibility(View.GONE);

        adapter_myProfile = new Adapter_MyProfile(AppInfo.profileItems);
        adapter_myProfile.addHeader(list_header);

        rv_my_profile.setAdapter(adapter_myProfile);

        mVendorStatusView = (TextView) list_header.findViewById(R.id.text_vendor_status);

        this.showMyRewardPoints();

        this.showVendorStatus();

        TextView txt_reset_password = (TextView) view.findViewById(R.id.txt_reset_password);
        if (AppInfo.SHOW_RESET_PASSWORD) {
            txt_reset_password.setVisibility(View.VISIBLE);
            String str_reset_pass = "<u>" + getString(L.string.title_reset_password) + "</u>";
            txt_reset_password.setText(HtmlCompat.fromHtml(str_reset_pass));
            txt_reset_password.setTextColor(Color.parseColor(AppInfo.normal_button_color));
            txt_reset_password.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    showResetPasswordDialog(getActivity());
                }
            });
        } else {
            txt_reset_password.setVisibility(View.GONE);
        }

        return view;
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
    }


    private void selectItem(int id, int position) {
        if (mCallbacks != null) {
            mCallbacks.onNavigationDrawerItemSelected(id, position);
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        tv_user_name.setText(AppUser.getInstance().getDisplayName());
        tv_user_email.setText(AppUser.getEmail());
        if (AppUser.getInstance().avatar_url != null && !AppUser.getInstance().avatar_url.equals("")) {
            Glide.with(getActivity())
                    .load(AppUser.getInstance().avatar_url)
                    .asBitmap()
                    .into(iv_user_profile);
        } else {
            iv_user_profile.setImageDrawable(CContext.getDrawable(getContext(), R.drawable.user_img));
        }

        adapter_myProfile.setMyProfileItemClickListener(new MyProfileItemClickListener() {
            @Override
            public void onMyProfileItemClick(int id, int position) {
                selectItem(id, position);
            }
        });
        card_view.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                ((MainActivity) getActivity()).showEditProfile(true);
            }
        });
    }

    private void showMyRewardPoints() {
        if (!AppInfo.ENABLE_CUSTOM_POINTS) {
            return;
        }

        if (!AppUser.hasSignedIn()) {
            return;
        }

        mPointsView.setVisibility(View.INVISIBLE);
        Map<String, String> params = new HashMap<>();
        params.put("user_id", "" + AppUser.getUserId());
        params.put("email_id", AppUser.getEmail());
        DataEngine.getDataEngine().getUserRewardPointsAsync(params, new DataQueryHandler<String>() {
            @Override
            public void onSuccess(String data) {
                try {
                    JSONObject jsonObject = new JSONObject(data);
                    RewardPoint.getInstance().setRewardsPoints(jsonObject.getInt("total_reward_points"));
                    mPointsView.setVisibility(View.VISIBLE);
                    mPointsView.setText(HtmlCompat.fromHtml(String.format(getString(L.string.your_points), RewardPoint.getInstance().getRewardPoints())));
                    Animation fadeInAnimation = AnimationUtils.loadAnimation(getActivity(), R.anim.fade_in);
                    mPointsView.startAnimation(fadeInAnimation);
                } catch (JSONException e) {
                    mPointsView.setVisibility(View.GONE);
                }
            }

            @Override
            public void onFailure(Exception reason) {
                mPointsView.setVisibility(View.GONE);
            }
        });
    }

    private void showVendorStatus() {
        if (AppUser.hasSignedIn() && MultiVendorConfig.isEnabled()) {
            String label = getString(L.string.vendor_status_label);
            String status = "";
            RoleType roleType = AppUser.getRoleType();
            if (roleType == RoleType.VENDOR || roleType == RoleType.VENDOR_YITH || roleType == RoleType.VENDOR_DC) {
                status = getString(L.string.vendor_status_verified);
            } else if (roleType == RoleType.PENDING_VENDOR || roleType == RoleType.PENDING_VENDOR_DC) {
                status = getString(L.string.vendor_status_pending);
            }
            if (!status.equals("")) {
                SpannableStringBuilder spannable = new SpannableStringBuilder(label + " " + status);
                spannable.setSpan(new StyleSpan(Typeface.BOLD), label.length() + 1, label.length() + status.length() + 1, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
                mVendorStatusView.setText(spannable);
                mVendorStatusView.setVisibility(View.VISIBLE);
                return;
            }
        }
        mVendorStatusView.setVisibility(View.GONE);
    }


    public void showResetPasswordDialog(final Activity activity) {

        AlertDialog.Builder builder = new AlertDialog.Builder(activity);
        View view = LayoutInflater.from(activity).inflate(R.layout.dialog_reset_password, null);

        LinearLayout header = (LinearLayout) view.findViewById(R.id.header_box);
        header.setBackgroundColor(Color.parseColor(AppInfo.color_theme));
        TextView header_msg = (TextView) view.findViewById(R.id.header_msg);
        header_msg.setText(L.getString(L.string.action_reset_password));

        TextInputLayout label_password = ((TextInputLayout) view.findViewById(R.id.label_user_password));
        label_password.setHint(L.getString(L.string.prompt_current_password));
        TextInputLayout label_new_password = ((TextInputLayout) view.findViewById(R.id.label_user_new_password));
        label_new_password.setHint(L.getString(L.string.prompt_new_password));
        TextInputLayout label_password_confirm = ((TextInputLayout) view.findViewById(R.id.label_password_confirm));
        label_password_confirm.setHint(L.getString(L.string.prompt_password_confirm));

        final EditText password = (EditText) view.findViewById(R.id.password);
        final EditText password_new = (EditText) view.findViewById(R.id.password_new);
        final EditText password_confirm = (EditText) view.findViewById(R.id.password_confirm);

        final Button email_reset_button = (Button) view.findViewById(R.id.password_reset_btn);
        email_reset_button.setText(L.getString(L.string.action_reset_password));
        Helper.stylize(email_reset_button);

        ImageView iv_close = (ImageView) view.findViewById(R.id.iv_close);
        Helper.stylizeActionBar(iv_close);

        builder.setView(view).setCancelable(true);
        final AlertDialog alertDialog = builder.create();

        email_reset_button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Helper.hideKeyboard(v);
                final String _email = AppUser.getEmail();
                final String _user_pass = password.getText().toString();
                final String _user_pass_new = password_new.getText().toString();
                final String _confirmPassword = password_confirm.getText().toString();

                if (checkCredentialsResetPass(_email, _user_pass, _user_pass_new, _confirmPassword)) {
                    handleForgetPassword(_email, _user_pass, _user_pass_new, alertDialog);
                }
            }
        });
        iv_close.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                alertDialog.dismiss();
            }
        });

        alertDialog.show();
    }

    private boolean checkCredentialsResetPass(String email, String password, String newPassword, String confirmPassword) {
        if (!android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
            Helper.toast(L.string.invalid_email);
            return false;
        }
        if (!Helper.isValidString(password)) {
            Helper.toast(L.string.password_required);
            return false;
        }
        boolean result;
        switch (AppInfo.REQUIRED_PASSWORD_STRENGTH) {
            case 1:
                result = verifyAveragePassword(newPassword);
                break;
            case 2:
                result = verifyStrongPassword(newPassword);
                break;
            default:
                result = verifyWeakPassword(newPassword);
                break;
        }

        if (!result)
            return false;


        if (!confirmPassword.equals(newPassword)) {
            Helper.toast(L.string.passwords_mismatch);
            return false;
        }
        return true;
    }

    private boolean verifyWeakPassword(String password) {
        if (password.length() == 0) {
            Helper.POPUP(getActivity(), L.getString(L.string.prompt_password), L.getString(L.string.password_specification_weak), true, null);
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
            Helper.POPUP(getActivity(), L.getString(L.string.prompt_password), L.getString(L.string.password_specification_average), true, null);
            return false;
        }

        boolean hasUppercase = !password.equals(password.toLowerCase());
        if (!hasUppercase) {
            Helper.POPUP(getActivity(), L.getString(L.string.prompt_password), L.getString(L.string.password_specification_average), true, null);
            return false;
        }

        boolean hasLowercase = !password.equals(password.toUpperCase());
        if (!hasLowercase) {
            Helper.POPUP(getActivity(), L.getString(L.string.prompt_password), L.getString(L.string.password_specification_average), true, null);
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
            Helper.POPUP(getActivity(), L.getString(L.string.prompt_password), L.getString(L.string.password_specification_strong), true, null);
            return false;
        }
        boolean hasSpecial = !password.matches("[A-Za-z0-9 ]*");//Checks at least one char is not alpha numeric
        if (!hasSpecial) {
            Helper.POPUP(getActivity(), L.getString(L.string.prompt_password), L.getString(L.string.password_specification_strong), true, null);
            return false;
        }
        return true;
    }

    private void handleForgetPassword(String _email, String _user_pass, String _user_pass_new, final AlertDialog alertDialog) {
        showProgress(L.getString(L.string.updating), false);

        DataEngine.getDataEngine().resetPassword(_email, _user_pass, _user_pass_new, new TM_LoginListener() {
            @Override
            public void onLoginSuccess(String response) {
                alertDialog.dismiss();
                hideProgress();
                Helper.POPUP(getActivity(), L.getString(L.string.action_reset_password), response, true, null);
            }

            @Override
            public void onLoginFailed(String msg) {
                alertDialog.dismiss();
                hideProgress();
                Helper.POPUP(getActivity(), L.getString(L.string.action_reset_password), msg, true, null);
            }
        });
    }
}