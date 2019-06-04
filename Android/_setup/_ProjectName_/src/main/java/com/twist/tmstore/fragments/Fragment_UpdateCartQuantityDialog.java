package com.twist.tmstore.fragments;

import android.app.Dialog;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.widget.SearchView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.TextView;

import com.twist.tmstore.BaseDialogFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.twist.tmstore.entities.Cart;
import com.twist.tmstore.listeners.QuantityListener;
import com.utils.Helper;
import com.utils.HtmlCompat;

/**
 * Created by Twist Mobile on 13-12-2016.
 */

public class Fragment_UpdateCartQuantityDialog extends BaseDialogFragment implements SearchView.OnCloseListener {

    public static final String TAG = Fragment_UpdateCartQuantityDialog.class.getSimpleName();
    private Cart cart;
    private int originalsQty = 1;
    private OnCompleteListener mOnCompleteListener;
    EditText quantity;


    public static Fragment_UpdateCartQuantityDialog getInstance(Cart cart, OnCompleteListener onCompleteListener) {
        Fragment_UpdateCartQuantityDialog df = new Fragment_UpdateCartQuantityDialog();
        df.cart = cart;
        df.originalsQty = cart.count;
        df.mOnCompleteListener = onCompleteListener;
        return df;
    }

    @Override
    public void onStart() {
        super.onStart();
        Dialog dialog = getDialog();
        if (dialog != null) {
            dialog.getWindow().setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            dialog.getWindow().setBackgroundDrawable(new ColorDrawable(Color.WHITE));
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        Dialog dialog = this.getDialog();
        if (dialog != null) {
            Window window = dialog.getWindow();
            if (window != null) {
                window.requestFeature(Window.FEATURE_NO_TITLE);
            }
        }

        View rootView = inflater.inflate(R.layout.layout_update_cart_quantity, container, false);

        final TextView name = (TextView) rootView.findViewById(R.id.name);
        final TextView txt_qty = (TextView) rootView.findViewById(R.id.txt_qty);
        quantity = (EditText) rootView.findViewById(R.id.quantity);
        final TextView total = (TextView) rootView.findViewById(R.id.total);
        final ImageButton btn_cancel = (ImageButton) rootView.findViewById(R.id.btn_cancel);
        final ImageButton btn_done = (ImageButton) rootView.findViewById(R.id.btn_done);

        name.setText(HtmlCompat.fromHtml(this.cart.title));
        txt_qty.setText(getString(L.string.qty));
        quantity.setText(String.valueOf(this.cart.count));
        total.setText(HtmlCompat.fromHtml(Helper.appendCurrency(this.cart.getItemTotalPrice())));

        Helper.stylizeActionBar(btn_done);
        Helper.stylizeActionBar(btn_cancel);

        quantity.addTextChangedListener(new QuantityListener(quantity, new QuantityListener.OnChangeCallback() {
            @Override
            public void onChange(final int value) {
//                quantity.setOnEditorActionListener(new TextView.OnEditorActionListener() {
//                    @Override
//                    public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
//                        if (actionId == EditorInfo.IME_ACTION_DONE) {
//                            cart.setCount(value);
//                            total.setText(HtmlCompat.fromHtml(Helper.appendCurrency(cart.getItemTotalPrice())));
//                        }
//                        return false;
//                    }
//                });
                if (value > 0) {
                    cart.setCount(value);
                    total.setText(HtmlCompat.fromHtml(Helper.appendCurrency(cart.getItemTotalPrice())));
                }
                quantity.requestFocus();
                quantity.requestFocusFromTouch();
            }
        }));

        btn_done.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (mOnCompleteListener != null) {
                    mOnCompleteListener.onCompletion();
                }
                Fragment_UpdateCartQuantityDialog.this.dismiss();
            }
        });

        btn_cancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                cart.setCount(originalsQty);
                Fragment_UpdateCartQuantityDialog.this.dismiss();
            }
        });

        return rootView;
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle bundle) {
        super.onViewCreated(view, bundle);
        quantity.requestFocus();
    }

    public interface OnCompleteListener {
        void onCompletion();
    }

    @Override
    public boolean onClose() {
        return false;
    }
}