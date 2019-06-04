package com.twist.tmstore.listeners;

import android.text.Editable;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import com.twist.dataengine.entities.QuantityRule;
import com.utils.Helper;

/**
 * Created by Twist Mobile on 03-Jun-16.
 */
public class QuantityListener implements TextWatcher {
    public interface OnChangeCallback {
        void onChange(int value);
    }

    private EditText mEditText;

    private final OnChangeCallback mOnChangeCallback;

    private QuantityRule mQuantityRule;

    private int mDefaultValue = 1;

    public QuantityListener(EditText editText, OnChangeCallback onChangeCallback, QuantityRule quantityRule, int defaultValue) {
        this.mEditText = editText;
        this.mOnChangeCallback = onChangeCallback;
        this.mQuantityRule = quantityRule;
        this.mDefaultValue = defaultValue;

        mEditText = editText;
        // check text and dismiss keyboard on enter action.
        mEditText.setOnEditorActionListener(new EditText.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView view, int actionId, KeyEvent event) {
                String value = view.getText().toString();
                if (value.length() == 0) {
                    value = String.valueOf(mDefaultValue);
                }
                setQuantity(value);
                Helper.hideKeyboard(mEditText);
                return true;
            }
        });

        // dismiss keyboard on focus change.
        mEditText.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                if (!hasFocus) {
                    Helper.hideKeyboard(v);
                }
            }
        });
    }

    public QuantityListener(EditText editText, OnChangeCallback onChangeCallback, QuantityRule quantityRule) {
        this(editText, onChangeCallback, quantityRule, 1);
    }

    public QuantityListener(EditText editText, OnChangeCallback callback) {
        this(editText, callback, null);
    }

    public QuantityListener(EditText editText) {
        this(editText, null);
    }

    public QuantityListener(EditText editText, int defaultValue) {
        this(editText, null, null, defaultValue);
    }

    @Override
    public void beforeTextChanged(CharSequence s, int start, int count, int after) {
    }

    @Override
    public void onTextChanged(CharSequence s, int start, int before, int count) {
    }

    @Override
    public void afterTextChanged(Editable s) {
        this.setQuantity(s.toString());
    }

    private void setQuantity(String str) {
        try {
            int quantity = Integer.parseInt(str);
			if(quantity < mDefaultValue) {
                quantity = mDefaultValue;
            }
            if(mQuantityRule != null && mQuantityRule.isOverrideRule() && mQuantityRule.getMinQuantity() > quantity) {
                quantity = mQuantityRule.getMinQuantity();
            }
            if (mOnChangeCallback != null) {
                mOnChangeCallback.onChange(quantity);
            }
        } catch (Exception ignored) {
        }
    }
}