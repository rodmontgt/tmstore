package com.twist.tmstore.fragments;

import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Patterns;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;

import com.bumptech.glide.Glide;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.config.SponsorFriendConfig;
import com.twist.tmstore.entities.AppUser;
import com.utils.Helper;

import java.util.HashMap;

public class SponsorFriendFragment extends BaseFragment implements View.OnClickListener {

    private EditText mInputFriendFirstName;
    private EditText mInputFriendLastName;
    private EditText mInputFriendEmail;
    private EditText mInputOptionalMessage;

    public SponsorFriendFragment() {
        // Required empty public constructor
    }

    public static SponsorFriendFragment newInstance() {
        SponsorFriendFragment fragment = new SponsorFriendFragment();
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_sponsor_friend, container, false);
        setRootView(rootView);
        setTitle(L.string.sponsor_a_friend);

        setHintOnTextInput(R.id.label_friend_first_name, L.string.your_friend_first_name);
        setHintOnTextInput(R.id.label_friend_last_name, L.string.your_friend_last_name);
        setHintOnTextInput(R.id.label_friend_email, L.string.your_friend_email);
        setHintOnTextInput(R.id.label_optional_message, L.string.optional_message);

        Button btnSponsorFriend = findButton(R.id.btn_sponsor_friend);
        Helper.stylize(btnSponsorFriend);
        btnSponsorFriend.setOnClickListener(this);

        mInputFriendFirstName = findEditText(R.id.text_friend_first_name);
        mInputFriendFirstName.addTextChangedListener(new MyTextWatcher(mInputFriendFirstName));

        mInputFriendLastName = findEditText(R.id.text_friend_last_name);
        mInputFriendLastName.addTextChangedListener(new MyTextWatcher(mInputFriendLastName));

        mInputFriendEmail = findEditText(R.id.text_friend_email);
        mInputFriendEmail.addTextChangedListener(new MyTextWatcher(mInputFriendEmail));

        mInputOptionalMessage = findEditText(R.id.text_optional_message);
        mInputOptionalMessage.addTextChangedListener(new MyTextWatcher(mInputOptionalMessage));

        this.stylizeAll();

        String headerImageUrl = SponsorFriendConfig.getInstance().getSponsorImageUrl();
        if (!TextUtils.isEmpty(headerImageUrl)) {
            ImageView sponsorImageView = findImageView(R.id.image_view_sponsor);
            Glide.with(getActivity())
                    .load(headerImageUrl)
                    .placeholder(R.drawable.placeholder_banner)
                    .error(R.drawable.placeholder_banner)
                    .fitCenter()
                    .into(sponsorImageView);
        }
        return rootView;
    }

    private void stylizeAll() {
        Helper.stylize(findTextInputLayout(R.id.label_friend_first_name));
        Helper.stylize(findTextInputLayout(R.id.label_friend_last_name));
        Helper.stylize(findTextInputLayout(R.id.label_friend_email));
        Helper.stylize(findTextInputLayout(R.id.label_optional_message));
    }

    @Override
    public void onClick(View view) {
        if (view.getId() == R.id.btn_sponsor_friend) {
            this.onSponsorFriendClick();
        }
    }

    private void onSponsorFriendClick() {
        if (!validateFirstName()) {
            return;
        }

        if (!validateLastName()) {
            return;
        }

        if (!validateEmail()) {
            return;
        }

        if (!validateMessage()) {
            return;
        }

        if (AppUser.getInstance().user_type == AppUser.USER_TYPE.ANONYMOUS_USER) {
            Helper.toast(L.string.not_signed_in);
            return;
        }

        String friendFirstName = mInputFriendFirstName.getText().toString().trim();
        String friendLastName = mInputFriendLastName.getText().toString().trim();
        String friendEmail = mInputFriendEmail.getText().toString().trim();
        String message = mInputOptionalMessage.getText().toString().trim();

        final HashMap<String, String> parameters = new HashMap<>();
        parameters.put("to_firstname", friendFirstName);
        parameters.put("to_lastname", friendLastName);
        parameters.put("to_message", message);
        parameters.put("to_email", friendEmail);
        parameters.put("from_email", AppUser.getEmail());
        parameters.put("user_id", String.valueOf(AppUser.getUserId()));

        MainActivity.mActivity.showProgress(getString(L.string.please_wait), false);
        DataEngine.getDataEngine().sponsorFriendAsync(parameters, new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {
                MainActivity.mActivity.hideProgress();
                Helper.toast(L.string.sponsor_friend_message_sent);
                //SponsorFriendFragment.this.resetAllInputTexts();
            }

            @Override
            public void onFailure(Exception reason) {
                MainActivity.mActivity.hideProgress();
                Helper.showToast(reason.getMessage());
                reason.printStackTrace();
            }
        });
    }

    private void setErrorText(EditText editText, String error) {
        editText.setError(error);
        this.requestFocus(editText);
    }

    private boolean validateFirstName() {
        String friendFirstName = mInputFriendFirstName.getText().toString().trim();
        if (friendFirstName.isEmpty() || friendFirstName.length() < 2 || friendFirstName.length() > 16) {
            this.setErrorText(mInputFriendFirstName, getString(L.string.your_friend_first_name_invalid));
            return false;
        } else {
            findTextInputLayout(R.id.label_friend_first_name).setErrorEnabled(false);
        }
        return true;
    }

    private boolean validateLastName() {
        String friendLastName = mInputFriendLastName.getText().toString().trim();
        if (friendLastName.isEmpty() || friendLastName.length() < 2 || friendLastName.length() > 16) {
            this.setErrorText(mInputFriendLastName, getString(L.string.your_friend_last_name_invalid));
            return false;
        } else {
            findTextInputLayout(R.id.label_friend_last_name).setErrorEnabled(false);
        }
        return true;
    }

    private boolean validateEmail() {
        String friendEmail = mInputFriendEmail.getText().toString().trim();
        if (friendEmail.isEmpty() || !Patterns.EMAIL_ADDRESS.matcher(friendEmail).matches()) {
            this.setErrorText(mInputFriendEmail, getString(L.string.your_friend_email_invalid));
            return false;
        } else {
            findTextInputLayout(R.id.label_friend_email).setErrorEnabled(false);
        }
        return true;
    }

    private void resetAllInputTexts() {
        mInputFriendFirstName.setText("");
        mInputFriendLastName.setText("");
        mInputFriendEmail.setText("");
        mInputOptionalMessage.setText("");
    }

    private boolean validateMessage() {
        String message = mInputOptionalMessage.getText().toString().trim();
        if (message.length() > 1024) {
            this.setErrorText(mInputOptionalMessage, getString(L.string.optional_message_too_large));
            return false;
        } else {
            findTextInputLayout(R.id.label_optional_message).setErrorEnabled(false);
        }
        return true;
    }

    private class MyTextWatcher implements TextWatcher {

        private View view;

        private MyTextWatcher(View view) {
            this.view = view;
        }

        public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {
        }

        public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
        }

        public void afterTextChanged(Editable editable) {
            switch (view.getId()) {
                case R.id.text_friend_first_name:
                    validateFirstName();
                    //Helper.stylize(findTextInputLayout(R.id.label_friend_first_name));
                    break;

                case R.id.text_friend_last_name:
                    validateLastName();
                    //Helper.stylize(findTextInputLayout(R.id.label_friend_last_name));
                    break;

                case R.id.text_friend_email:
                    validateEmail();
                    //Helper.stylize(findTextInputLayout(R.id.label_friend_email));
                    break;

                case R.id.text_optional_message:
                    validateMessage();
                    //Helper.stylize(findTextInputLayout(R.id.label_optional_message));
                    break;
            }
        }
    }
}
