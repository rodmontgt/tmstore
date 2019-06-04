package com.twist.tmstore.dialogs;

import android.graphics.Color;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.twist.tmstore.BaseDialogFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.twist.tmstore.entities.AppInfo;
import com.utils.Helper;

/**
 * Created by Twist Mobile on 11/29/2017.
 */

public class SimpleMessageDialog extends BaseDialogFragment {

    private String title;
    private String message;
    private String buttonText;

    private View.OnClickListener onOkBtnClickListener;

    public SimpleMessageDialog() {
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public void setButtonText(String buttonText) {
        this.buttonText = buttonText;
    }

    public void setBtnOkClickListener(View.OnClickListener onOkBtnClickListener) {
        this.onOkBtnClickListener = onOkBtnClickListener;
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.dialog_simple_message, container, false);

        LinearLayout header_box = (LinearLayout) view.findViewById(R.id.header_box);
        header_box.setBackgroundColor(Color.parseColor(AppInfo.color_theme));

        TextView header_msg = (TextView) view.findViewById(R.id.header_msg);
        Helper.stylizeActionBar(header_msg);
        TextView txt_msg = (TextView) view.findViewById(R.id.txt_msg);

        Button btn_ok = (Button) view.findViewById(R.id.btn_ok);
        Helper.stylize(btn_ok);

        if (!TextUtils.isEmpty(title)) {
            header_msg.setText(title);
        } else {
            header_box.setVisibility(View.GONE);
        }

        if (!TextUtils.isEmpty(message)) {
            txt_msg.setText(message);
        } else {
            txt_msg.setVisibility(View.GONE);
        }

        if (!TextUtils.isEmpty(buttonText)) {
            btn_ok.setText(buttonText);
        } else {
            btn_ok.setText(getString(L.string.ok));
        }

        btn_ok.setOnClickListener(onOkBtnClickListener);

        return view;
    }
}
