package com.twist.tmstore.dialogs;

import android.app.Activity;
import android.app.Dialog;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.TextView;

import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.utils.Helper;

import static com.twist.tmstore.L.getString;

/**
 * Created by Twist Mobile on 3/6/2016.
 */
public class UpdateAppDialog {
    public void showDialog(Activity activity, final boolean isForceUpdate, final View.OnClickListener listenerAction, final View.OnClickListener listenerCancel){
        final Dialog dialog = new Dialog(activity);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setCancelable(false);
        dialog.setContentView(R.layout.dialog_update_app);

        Helper.stylizeView(dialog.findViewById(R.id.header_box));

        TextView titleView = (TextView) dialog.findViewById(R.id.text_title);
        titleView.setText(getString(L.string.title_dialog_update));

        TextView txt_msg = (TextView) dialog.findViewById(R.id.txt_msg);

        if(isForceUpdate){
            txt_msg.setText(getString(L.string.update_message_forcefully));
        } else {
            txt_msg.setText(getString(L.string.update_message_ask));
        }

        Button btnUpdate = (Button) dialog.findViewById(R.id.btn_update_now);
        btnUpdate.setText(getString(L.string.update_now));
        Helper.stylize(btnUpdate);
        btnUpdate.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View v) {
                if(listenerAction != null){
                    listenerAction.onClick(v);
                }
            }
        });

        Button btnLater = (Button) dialog.findViewById(R.id.btn_later);
        btnLater.setText(getString(L.string.later));
        Helper.stylize(btnLater);
        if(isForceUpdate){
            btnLater.setVisibility(View.GONE);
        } else {
            btnLater.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(final View v) {
                    dialog.dismiss();
                    if(listenerCancel != null){
                        listenerCancel.onClick(v);
                    }
                }
            });
        }
        dialog.show();
    }
}
