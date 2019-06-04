package com.twist.tmstore.fragments;

import android.os.Bundle;
import android.support.design.widget.TextInputLayout;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;

import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.config.ContactForm3Config;
import com.utils.DataHelper;
import com.utils.Helper;
import com.utils.HtmlCompat;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by Twist Mobile on 4/17/2017.
 */

public class Fragment_ContactForm3 extends BaseFragment {

    String nameShortCode;
    String emailShortCode;
    String messageShortCode;
    private View rootView;
    private TextInputLayout label_name;
    private TextInputLayout label_email;
    private TextInputLayout label_optional_message;
    private EditText text_name;
    private EditText text_email;
    private EditText text_optional_message;
    private Button btnSendMessage;

    public Fragment_ContactForm3() {
    }

    public static Fragment_ContactForm3 newInstance() {
        return new Fragment_ContactForm3();
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        rootView = inflater.inflate(R.layout.fragment_contact_form3, container, false);
        getContactUsData();
        return rootView;
    }

    private void getContactUsData() {
        if (ContactForm3Config.mContactForm3Config != null && ContactForm3Config.mContactForm3Config.enabled) {
            if (ContactForm3Config.mContactForm3Config.contactForm3Map.size() != 0) {
                initComponents(rootView);
            } else {
                MainActivity.mActivity.showProgress(getString(L.string.please_wait));
                DataEngine.getDataEngine().getContactForm3InBackground(new DataQueryHandler<String>() {
                    @Override
                    public void onSuccess(String data) {
                        try {
                            parseJsonAndCreateContactUs(data);
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                        MainActivity.mActivity.hideProgress();
                    }

                    @Override
                    public void onFailure(Exception reason) {
                        Helper.showToast(rootView, reason.getMessage());
                        MainActivity.mActivity.hideProgress();
                    }
                });
            }
        }
    }

    public void parseJsonAndCreateContactUs(String jsonStringContent) throws Exception {
        JSONObject jMainObject = DataHelper.safeJsonObject(jsonStringContent);
        JSONArray contactusArray = jMainObject.getJSONArray("input");
        for (int i = 0; i < contactusArray.length(); i++) {
            ContactForm3Config.ContactForm3 formData = new ContactForm3Config.ContactForm3();
            JSONObject contactusInfoJson = contactusArray.getJSONObject(i);
            formData.shortcode = contactusInfoJson.getString("shortcode");
            formData.label = contactusInfoJson.getString("label");
            formData.submit_mess = jMainObject.getString("submit_mess");
            ContactForm3Config.mContactForm3Config.contactForm3Map.put(formData.shortcode, formData);
        }
        initComponents(rootView);
    }

    private void initComponents(final View rootView) {

        label_name = ((TextInputLayout) rootView.findViewById(R.id.label_name_contactus));
        Helper.stylize(label_name);

        label_email = ((TextInputLayout) rootView.findViewById(R.id.label_email));
        Helper.stylize(label_email);

        label_optional_message = ((TextInputLayout) rootView.findViewById(R.id.label_optional_message));
        Helper.stylize(label_optional_message);

        text_name = (EditText) rootView.findViewById(R.id.text_name_contactus);
        text_email = (EditText) rootView.findViewById(R.id.text_email);
        text_optional_message = (EditText) rootView.findViewById(R.id.text_optional_message);

        btnSendMessage = (Button) rootView.findViewById(R.id.btn_send_message);
        btnSendMessage.setText(L.getString(L.string.btn_send_message_contactus));
        Helper.stylize(btnSendMessage);
        btnSendMessage.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                final String name = text_name.getText().toString().trim();
                final String email = text_email.getText().toString().trim();
                final String message = text_optional_message.getText().toString().trim();

                if (!Helper.isValidString(name)) {
                    setErrorText(text_name, getString(L.string.invalid_name));
                    return;
                }
                if (!android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
                    setErrorText(text_email, getString(L.string.invalid_email));
                    return;
                }

                if (!Helper.isValidString(message)) {
                    setErrorText(text_optional_message, getString(L.string.invalid_message));
                    return;
                }
                if (message.length() > 2048) {
                    setErrorText(text_optional_message, getString(L.string.optional_message_too_large));
                    return;
                }

                Map<String, String> params = new HashMap<>();
                params.put("type", "submit_contact_form");
                params.put("form_id", "0");
                params.put(nameShortCode, name);
                params.put(emailShortCode, email);
                params.put(messageShortCode, message);

                MainActivity.mActivity.showProgress(getString(L.string.please_wait));
                DataEngine.getDataEngine().postContactForm3InBackground(params, new DataQueryHandler<String>() {
                    @Override
                    public void onSuccess(String data) {
                        text_name.setText("");
                        text_name.requestFocus();
                        text_email.setText("");
                        text_optional_message.setText("");
                        Helper.showToast(rootView, data);
                        MainActivity.mActivity.hideProgress();
                    }

                    @Override
                    public void onFailure(Exception error) {
                        text_name.setText(name);
                        text_name.requestFocus();
                        text_email.setText(email);
                        text_optional_message.setText(message);
                        MainActivity.mActivity.hideProgress();
                    }
                });
            }
        });


        for (Map.Entry<String, ContactForm3Config.ContactForm3> entry : ContactForm3Config.mContactForm3Config.contactForm3Map.entrySet()) {
            ContactForm3Config.ContactForm3 value = entry.getValue();
            String key = entry.getKey();
            if (key.equals("nometprenom")) {
                label_name.setHint(value.label);
                nameShortCode = value.shortcode;
            } else if (key.equals("adresseemail")) {
                label_email.setHint(value.label);
                emailShortCode = value.shortcode;
            } else if (key.equals("message")) {
                label_optional_message.setHint(HtmlCompat.fromHtml(value.label));
                messageShortCode = value.shortcode;
            } else {
                label_name.setHint((L.getString(L.string.label_last_and_first_name)));
                label_email.setHint(L.getString(L.string.email_address));
                label_optional_message.setHint(L.getString(L.string.label_message_reservation));
            }
            btnSendMessage.setText(value.submit_mess);
        }
    }

    private void setErrorText(EditText editText, String error) {
        editText.setError(error);
        this.requestFocus(editText);
    }
}
