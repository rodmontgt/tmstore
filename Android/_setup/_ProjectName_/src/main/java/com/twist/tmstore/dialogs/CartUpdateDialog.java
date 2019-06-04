package com.twist.tmstore.dialogs;

import android.app.Activity;
import android.app.Dialog;
import android.view.View;
import android.view.Window;
import android.widget.ImageView;
import android.widget.TextView;

import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.utils.Helper;

import static com.twist.tmstore.L.getString;

/**
 * Created by Twist Mobile on 3/6/2016.
 */
public class CartUpdateDialog {
    public void showDialog(Activity activity, String msg, final boolean dismissAction, final View.OnClickListener listener) {
        final Dialog dialog = new Dialog(activity);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setCancelable(false);
        dialog.setContentView(R.layout.dialog_cart_changed);

        Helper.stylizeView(dialog.findViewById(R.id.header_box));

        TextView header_msg = (TextView) dialog.findViewById(R.id.text_dialog_cart_update);
        header_msg.setText(getString(L.string.title_dialog_cart_update));
        Helper.stylizeActionBar(header_msg);

        TextView text = (TextView) dialog.findViewById(R.id.txt_msg);
        text.setText(msg);

        ImageView btn_close = (ImageView) dialog.findViewById(R.id.btn_close);
        Helper.stylizeActionBar(btn_close);
        btn_close.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View v) {
                if (dismissAction)
                    dialog.dismiss();
                if (listener != null) {
                    listener.onClick(v);
                }
            }
        });
        dialog.show();
    }
}
