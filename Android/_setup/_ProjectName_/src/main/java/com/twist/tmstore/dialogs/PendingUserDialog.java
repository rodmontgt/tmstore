package com.twist.tmstore.dialogs;

import android.app.Activity;
import android.app.Dialog;
import android.view.Window;
import android.widget.TextView;

import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.utils.Helper;

import static com.twist.tmstore.L.getString;

/**
 * Created by Twist Mobile on 3/11/2017.
 */
public class PendingUserDialog {
    public void showDialog(Activity activity, String msg) {
        final Dialog dialog = new Dialog(activity);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setCancelable(false);
        dialog.setContentView(R.layout.dialog_pending_user);

        Helper.stylizeView(dialog.findViewById(R.id.header_box));

        TextView header_msg = (TextView) dialog.findViewById(R.id.text_welcome);
        header_msg.setText(getString(L.string.title_welcome));
        Helper.stylizeActionBar(header_msg);

        TextView text = (TextView) dialog.findViewById(R.id.txt_msg);
        text.setText(msg);
        dialog.show();
    }
}
