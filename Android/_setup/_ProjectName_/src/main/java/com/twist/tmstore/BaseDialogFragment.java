package com.twist.tmstore;

import android.view.View;
import android.widget.TextView;

/**
 * Created by Twist Mobile on 04-Jul-16.
 */

public abstract class BaseDialogFragment extends android.support.v4.app.DialogFragment {
    public String getString(String key) {
        return L.getString(key);
    }

    public void setTextOnView(View parent, int textViewResId, String textKey) {
        View view = parent.findViewById(textViewResId);
        if (view instanceof TextView) {
            ((TextView) view).setText(getString(textKey));
        }
    }
}
