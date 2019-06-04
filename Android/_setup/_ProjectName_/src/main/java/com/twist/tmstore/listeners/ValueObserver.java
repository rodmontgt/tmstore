package com.twist.tmstore.listeners;

import android.view.View;
import android.widget.EditText;

import com.twist.dataengine.entities.QuantityRule;

/**
 * Created by Twist Mobile on 03-Jun-16.
 */
public class ValueObserver implements View.OnClickListener {

    public interface OnChangeCallback {
        void onChange(int value);
    }

    public enum Type {
        INCREASE,
        DECREASE,
    }

    private final EditText editText;

    private final Type type;

    private final OnChangeCallback callback;

    private int maximum = 999999999;

    private int minimum = 1;

    private int step = 1;

    public ValueObserver(EditText editText, Type type, OnChangeCallback callback) {
        super();
        this.editText = editText;
        this.type = type;
        this.callback = callback;
    }

    public ValueObserver(EditText editText, Type type, OnChangeCallback callback, QuantityRule quantityRule) {
        super();
        this.editText = editText;
        this.type = type;
        this.callback = callback;

        if (quantityRule != null && quantityRule.isOverrideRule()) {
            if (quantityRule.getStepValue() > 0) {
                this.step = quantityRule.getStepValue();
            }
            this.minimum = quantityRule.getMinQuantity();

            if (quantityRule.getMaxQuantity() > 0) {
                this.maximum = quantityRule.getMaxQuantity();
            }
        }
    }

    public ValueObserver(EditText editText, Type type, OnChangeCallback callback, int minimum, int maximum) {
        super();
        this.editText = editText;
        this.type = type;
        this.callback = callback;
        this.minimum = minimum;
        this.maximum = maximum;
    }

    @Override
    public void onClick(View view) {
        if (editText == null) {
            return;
        }

        int value = 1;
        try {
            value = Integer.parseInt(editText.getText().toString());
            if (type.equals(Type.INCREASE)) {
                value = value + step;
            } else {
                value = value - step;
            }

            if (value < minimum) {
                value = minimum;
            } else if (value > maximum) {
                value = maximum;
            }
        } catch (NumberFormatException ignored) {
        }
        editText.setText(String.valueOf(value));
        if (callback != null) {
            callback.onChange(value);
        }
    }
}
