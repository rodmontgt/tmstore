package com.twist.tmstore.dialogs;

import android.app.Activity;
import android.app.Dialog;
import android.os.Build;
import android.view.View;
import android.view.Window;
import android.widget.ImageButton;
import android.widget.TextView;

import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.utils.Helper;

import static com.twist.tmstore.L.getString;

/**
 * Created by Twist Mobile on 3/6/2016.
 */
public class GetCodeDialog {

    public static void show(Activity activity, final boolean dismissAction, final View.OnClickListener listener) {
        //  final Dialog dialog = new Dialog(activity, android.R.style.Theme_Light_NoTitleBar_Fullscreen);
        final Dialog dialog = new Dialog(activity);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH) {
            dialog.requestWindowFeature(Window.FEATURE_SWIPE_TO_DISMISS);
        }
        dialog.setCancelable(true);
        dialog.setContentView(R.layout.dialog_get_code);

       /* dialog.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        dialog.getWindow().setLayout(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.MATCH_PARENT);*/

        Helper.stylizeView(dialog.findViewById(R.id.header_box));

        TextView header_msg = (TextView) dialog.findViewById(R.id.header_msg);
        header_msg.setText(getString(L.string.title_dialog_get_code));
        Helper.stylizeActionBar(header_msg);

        ImageButton btn_close = (ImageButton) dialog.findViewById(R.id.btn_close);


        btn_close.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View v) {
                if (dismissAction)
                    dialog.dismiss();

            }
        });

        ((TextView) dialog.findViewById(R.id.get_code_step_1)).setText(getString(L.string.get_code_step_1));
        StringBuffer stringBuffer = new StringBuffer();
        stringBuffer.append(getString(L.string.get_code_step_2));
        stringBuffer.append("\n\n");
        stringBuffer.append(getString(L.string.get_code_step_3));
        stringBuffer.append("\n\n");
        stringBuffer.append(getString(L.string.get_code_step_4));
        stringBuffer.append("\n\n");
        stringBuffer.append(getString(L.string.get_code_step_5));
        stringBuffer.append("\n\n");
        stringBuffer.append(getString(L.string.get_code_step_6));
        stringBuffer.append("\n\n");
        stringBuffer.append(getString(L.string.get_code_step_7));
        stringBuffer.append("\n\n");
        stringBuffer.append(getString(L.string.get_code_step_8));
        stringBuffer.append("\n\n");
        stringBuffer.append(getString(L.string.get_code_step_9));
        stringBuffer.append("\n\n");
        stringBuffer.append(getString(L.string.get_code_step_10));

        ((TextView) dialog.findViewById(R.id.get_code_step_2)).setText(stringBuffer);
        dialog.show();
    }
}
