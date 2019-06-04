package com.twist.tmstore.dialogs;

import android.app.Activity;
import android.app.Dialog;
import android.content.DialogInterface;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.TextView;

import com.easyandroidanimations.library.Animation;
import com.easyandroidanimations.library.SlideInAnimation;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.utils.Helper;

import static com.twist.tmstore.L.getString;

/**
 * Created by Twist Mobile on 3/6/2016.
 */
public class WhatsappDialog {
    public void showDialog(Activity activity, String msg, final boolean dismissAction, final View.OnClickListener listener){
        final Dialog dialog = new Dialog(activity);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setCancelable(false);
        dialog.setContentView(R.layout.dialog_whatsapp);

        final View coordinatorLayout = dialog.findViewById(R.id.coordinatorLayout);

        Helper.stylizeView(dialog.findViewById(R.id.header_box));

        TextView header_msg = (TextView) dialog.findViewById(R.id.header_msg);
        header_msg.setText(getString(L.string.title_poll));
        Helper.stylizeActionBar(header_msg);

        TextView text = (TextView) dialog.findViewById(R.id.txt_msg);
        text.setText(msg);

        Button btn_action = (Button) dialog.findViewById(R.id.btn_action);
        Helper.stylize(btn_action);

        //btn_action.setOnClickListener(listener);
        btn_action.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View v) {
                if(dismissAction)
                    dialog.dismiss();
                if(listener != null){
                    listener.onClick(v);
                }
            }
        });

        dialog.show();

        dialog.setOnShowListener(new DialogInterface.OnShowListener() {
            @Override
            public void onShow(DialogInterface dialog) {
                new SlideInAnimation(coordinatorLayout).setDirection(Animation.DIRECTION_DOWN).animate();
            }
        });
    }
}
