package com.utils;

import android.os.Build;
import android.text.Html;
import android.text.Spanned;

/**
 * Created by Twist Mobile on 30/08/16.
 * <p>
 * Compatibility class for deprecated members in Html
 */

public class HtmlCompat {
    public static Spanned fromHtml(StringBuilder source) {
        return HtmlCompat.fromHtml(source.toString());
    }

    public static Spanned fromHtml(String source) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            return Html.fromHtml(source, Html.FROM_HTML_MODE_LEGACY);
        }
        return Html.fromHtml(source);
    }
}
