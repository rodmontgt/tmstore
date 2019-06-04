package com.twist.tmstore.dialogs;

import android.app.ProgressDialog;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.content.ContextCompat;
import android.text.InputFilter;
import android.text.InputType;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.BaseDialogFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.twist.tmstore.config.ContactForm7Config;
import com.utils.Base64Utils;
import com.utils.Helper;
import com.utils.JsonHelper;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import com.twist.oauth.NetworkRequest;
import com.twist.oauth.NetworkResponse;

/**
 * Created by Twist Mobile on 23-12-2016.
 */

public class ContactFormDialog extends BaseDialogFragment {
    private static boolean formDataLoaded = false;
    Button btn_ok;
    TextView tv_title;
    List<View> validationList = new ArrayList<>();
    List<EditText> editTextList = new ArrayList<>();
    TM_ProductInfo product;
    private LinearLayout layout_dynamic;
    private ProgressDialog progressDialog;

    public void setProduct(TM_ProductInfo product) {
        this.product = product;
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.custom_dialog, container, false);
        btn_ok = (Button) view.findViewById(R.id.btn_ok);
        tv_title = (TextView) view.findViewById(R.id.tv_title);
        tv_title.setText(ContactForm7Config.getTitle());
        progressDialog = new ProgressDialog(getActivity());
        layout_dynamic = (LinearLayout) view.findViewById(R.id.layout_dynamic);
        tv_title = (TextView) view.findViewById(R.id.tv_title);
        btn_ok.setText(getString(L.string.ok));
        Helper.stylize(btn_ok);
        btn_ok.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (isValid()) {
                    submitData();
                }
            }
        });
        String bgUrl = ContactForm7Config.getBgUrl();
        ImageView iv_form7_bg = (ImageView) view.findViewById(R.id.iv_form7_bg);
        if (Helper.isValidString(bgUrl)) {
            iv_form7_bg.setVisibility(View.VISIBLE);
            Glide.with(getActivity())
                    .load(bgUrl).placeholder(R.drawable.placeholder_banner)
                    .into(iv_form7_bg);
        } else {
            iv_form7_bg.setVisibility(View.GONE);
        }
        return view;
    }

    @Override
    public void onResume() {
        super.onResume();
        if (formDataLoaded) {
            initTextFields();
        } else {
            loadFormData();
        }
    }

    private void loadFormData() {
        showProgress(getString(L.string.loading), false);
        HashMap<String, String> params = new HashMap<>();
        params.put("type", Base64Utils.encode("contact_form"));
        NetworkResponse.ResponseListener responseListener = new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse postResponse) {
                progressDialog.dismiss();
                if (postResponse.succeed) {
                    try {
                        JSONObject jsonObject = new JSONObject(postResponse.msg);
                        JSONArray textFieldsArray = jsonObject.getJSONArray("text_fields");
                        for (int i = 0; i < textFieldsArray.length(); i++) {
                            JSONObject textFiledObject = textFieldsArray.getJSONObject(i);
                            String char_type = JsonHelper.getString(textFiledObject, "char_type", "alphanumeric");
                            int line_count = JsonHelper.getInt(textFiledObject, "line_count", 1);
                            boolean enabled = JsonHelper.getBool(textFiledObject, "enabled", true);
                            boolean single_line = JsonHelper.getBool(textFiledObject, "single_line", true);
                            String hint_text = JsonHelper.getString(textFiledObject, "hint_text", "");
                            boolean compulsory = JsonHelper.getBool(textFiledObject, "compulsory", false);
                            int char_limit = JsonHelper.getInt(textFiledObject, "char_limit", -1);
                            ContactForm7Config.TextField textField = new ContactForm7Config.TextField();
                            textField.setCharType(char_type);
                            textField.setLineCount(line_count);
                            textField.setEnabled(enabled);
                            textField.setSingleLine(single_line);
                            textField.setHintText(hint_text);
                            textField.setCompulsory(compulsory);
                            textField.setCharLimit(char_limit);
                            if (textFiledObject.has("param_name")) {
                                String param_name = JsonHelper.getString(textFiledObject, "param_name", "");
                                textField.setParamName(param_name);
                            }
                            ContactForm7Config.addTextField(textField);
                        }
                        initTextFields();
                        formDataLoaded = true;
                    } catch (Exception e) {
                        e.printStackTrace();
                        Helper.toast(getString(L.string.please_try_again));
                    }
                } else {
                    postResponse.error.printStackTrace();
                    Helper.toast(getString(L.string.please_try_again));
                }
                progressDialog.dismiss();
            }
        };
        NetworkRequest.makeCommonPostRequest(ContactForm7Config.getSubmitUrl(), params, null, responseListener);
    }

    private void initTextFields() {
        layout_dynamic.removeAllViewsInLayout();
        for (ContactForm7Config.TextField textField : ContactForm7Config.getTextFields()) {
            createView(textField);
        }
    }

    public void showProgress(final String msg, final boolean isCancellable) {
        progressDialog.setMessage(msg);
        progressDialog.show();
        progressDialog.setCancelable(isCancellable);
    }

    private void submitData() {
        showProgress(getString(L.string.submiting_request), false);
        HashMap<String, String> params = new HashMap<>();
        params.put("type", Base64Utils.encode("send_email"));
        params.put("recipient", Base64Utils.encode(product.id));
        params.put("subject", Base64Utils.encode(product.title));
        for (EditText editText : editTextList) {
            if (!TextUtils.isEmpty(editText.getText()) && editText.getTag() != null) {
                params.put(editText.getTag().toString(), Base64Utils.encode(editText.getText().toString()));
            }
        }
        NetworkResponse.ResponseListener responseListener = new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse postResponse) {
                progressDialog.dismiss();
                if (postResponse.succeed) {
                    Helper.toast(getString(L.string.quote_submitted));
                    dismiss();
                } else {
                    postResponse.error.printStackTrace();
                    Helper.toast(getString(L.string.please_try_again));
                }
            }
        };
        NetworkRequest.makeCommonPostRequest(ContactForm7Config.getSubmitUrl(), params, null, responseListener);
    }

    public boolean isValid() {
        for (View view : validationList) {
            if (view instanceof EditText) {
                EditText editText = (EditText) view;
                if (TextUtils.isEmpty(editText.getText())) {
                    showEditTextError(editText);
                    return false;
                }
                switch (editText.getInputType()) {
                    case InputType.TYPE_CLASS_NUMBER: {
                        if (!Helper.isValidPhoneNumber(editText.getText().toString())) {
                            editText.setError(getString(L.string.invalid_contact_number));
                            editText.requestFocus();
                            return false;
                        }
                        break;
                    }
                    case InputType.TYPE_NUMBER_FLAG_DECIMAL: {
                        break;
                    }
                    case InputType.TYPE_TEXT_VARIATION_PERSON_NAME: {
                        break;
                    }
                    case InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS: {
                        if (!Helper.isValidEmail(editText.getText().toString())) {
                            editText.setError(getString(L.string.invalid_email));
                            editText.requestFocus();
                            return false;
                        }
                        break;
                    }
                }
            }
        }

        return true;
    }

    private void showEditTextError(EditText editText) {
        if (editText.getHint() != null) {
            editText.setError(getString(L.string.invalid) + ":" + editText.getHint());
        } else {
            editText.setError(getString(L.string.invalid));
        }
    }

    @Override
    public void onStart() {
        super.onStart();
        if (getDialog() != null && getDialog().getWindow() != null) {
            int width = ViewGroup.LayoutParams.MATCH_PARENT;
            int height = ViewGroup.LayoutParams.WRAP_CONTENT;
            getDialog().getWindow().setLayout(width, height);
        }
    }

    private void createView(ContactForm7Config.TextField textField) {
        EditText editText = new EditText(getContext());
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        editText.setEnabled(textField.getEnabled());
        editText.setMaxLines(textField.getLineCount());
        switch (textField.getCharType()) {
            case "numeric":
                editText.setInputType(InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_FLAG_DECIMAL);
                break;
            case "alphanumeric":
                editText.setInputType(InputType.TYPE_TEXT_VARIATION_PERSON_NAME);
                break;
            case "email":
                editText.setInputType(InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS);
                break;
            default:
                editText.setInputType(InputType.TYPE_NULL);
                break;
        }
        editText.setHint(textField.getHintText());
        editText.setSingleLine(textField.getSingleLine());
        editText.setLines(textField.getLineCount());
        editText.setGravity(Gravity.LEFT | Gravity.TOP);
        editText.setTag(textField.getParamName());

        if (textField.getCharLimit() > 0) {
            InputFilter[] FilterArray = new InputFilter[1];
            FilterArray[0] = new InputFilter.LengthFilter(textField.getCharLimit());
            editText.setFilters(FilterArray);
        }

        editText.setImeOptions(EditorInfo.IME_FLAG_NO_EXTRACT_UI);
        editText.setTextColor(ContextCompat.getColor(getContext(), R.color.normal_text_color));
        if (textField.getCompulsory()) {
            validationList.add(editText);
        }
        layout_dynamic.addView(editText);
        editTextList.add(editText);
    }
}
