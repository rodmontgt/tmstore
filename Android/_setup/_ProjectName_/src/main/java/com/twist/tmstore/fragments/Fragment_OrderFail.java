package com.twist.tmstore.fragments;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.utils.Helper;
import com.utils.HtmlCompat;

public class Fragment_OrderFail extends BaseFragment {
    String reason;
    LinearLayout reason_section;
    Button btn_retry;
    TextView textViewPaymentFail;
    TextView textViewContactUs1;
    TextView textViewContactUs2;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
    }

    public static Fragment_OrderFail newInstance(String reason) {
        Fragment_OrderFail fragment = new Fragment_OrderFail();
        fragment.reason = reason;
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_order_failed, container, false);

        reason_section = (LinearLayout) rootView.findViewById(R.id.reason_section);

        btn_retry = (Button) rootView.findViewById(R.id.btn_retry);
        btn_retry.setText(getString(L.string.retry_payment));

        textViewPaymentFail = (TextView) rootView.findViewById(R.id.payment_fail);
        textViewPaymentFail.setText(getString(L.string.order_payment_failed));

        textViewContactUs1 = (TextView) rootView.findViewById(R.id.contact_us_1);
        textViewContactUs1.setText(getString(L.string.contact_on_payment_deduct));

        textViewContactUs2 = (TextView) rootView.findViewById(R.id.contact_us_2);
        textViewContactUs2.setText(getString(L.string.contact_or_retry_payment));

        TextView textViewReason = (TextView) rootView.findViewById(R.id.text_reason);

        if (TextUtils.isEmpty(this.reason)) {
            reason_section.setVisibility(View.GONE);
            textViewReason.setText(getString(L.string.failure_reason));
        } else {
            reason_section.setVisibility(View.VISIBLE);
            textViewReason.setText(HtmlCompat.fromHtml(Helper.isValidString(this.reason) ? this.reason : ""));
        }

        btn_retry.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                ((MainActivity) getActivity()).openConfirmOrderFragment();
            }
        });
        Helper.stylize(btn_retry);

        rootView.setFocusableInTouchMode(true);
        rootView.requestFocus();
        rootView.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                if (event.getAction() == KeyEvent.ACTION_DOWN) {
                    if (keyCode == KeyEvent.KEYCODE_BACK) {
                        return true;
                    }
                }
                return false;
            }
        });
        return rootView;
    }
}