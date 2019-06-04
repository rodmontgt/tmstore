package com.twist.tmstore.dialogs;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.DialogInterface;
import android.graphics.Typeface;
import android.support.v4.app.Fragment;
import android.text.TextUtils;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.twist.tmstore.TMStoreApp;
import com.twist.tmstore.config.ConsentDialogConfig;
import com.twist.tmstore.entities.AppInfo;
import com.utils.Base64Utils;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.Preferences;

import org.json.JSONArray;
import org.json.JSONObject;

public class ConsentDialog {
    public static void show(final Fragment fragment) {
        if (ConsentDialogConfig.mConsentDialogConfig == null || !ConsentDialogConfig.mConsentDialogConfig.isEnabled()) {
            return;
        }

        if (!ConsentDialogConfig.mConsentDialogConfig.isShowAlways()) {
            if (!Preferences.getBool(R.string.key_consent_dialog_enabled, true)) {
                return;
            }
        }

        if (TextUtils.isEmpty(ConsentDialogConfig.mConsentDialogConfig.getLayout())) {
            return;
        }

        AlertDialog.Builder builder = new AlertDialog.Builder(fragment.getActivity());
        View view = LayoutInflater.from(fragment.getActivity()).inflate(R.layout.dialog_consent, null);
        LinearLayout parent = view.findViewById(R.id.main_content);
        boolean titleEnabled = false;
        try {
            JSONArray jsonArray = new JSONArray(ConsentDialogConfig.mConsentDialogConfig.getLayout());
            for (int i = 0; i < jsonArray.length(); i++) {
                JSONObject jsonObject = jsonArray.getJSONObject(i);
                String viewType = jsonObject.getString("view");
                if (viewType.equalsIgnoreCase("text")) {
                    String type = jsonObject.getString("type");
                    String content = jsonObject.getString("content");
                    if (!TextUtils.isEmpty(type)) {
                        if (type.equalsIgnoreCase("header")) {
                            if (i == 0) {
                                TextView text_title = (TextView) view.findViewById(R.id.text_title);
                                text_title.setVisibility(View.VISIBLE);
                                text_title.setText(HtmlCompat.fromHtml(content));
                                titleEnabled = true;
                                continue;
                            }

                            TextView header_msg = addNewTextView(fragment.getActivity(), parent, content);
                            TypedValue tv = new TypedValue();
                            if (fragment.getActivity().getTheme().resolveAttribute(android.R.attr.actionBarSize, tv, true)) {
                                header_msg.setMinHeight(TypedValue.complexToDimensionPixelSize(tv.data, fragment.getActivity().getResources().getDisplayMetrics()));
                            }

                            header_msg.setGravity(Gravity.CENTER | Gravity.CENTER_HORIZONTAL);
                            Helper.setTextAppearance(fragment.getActivity(), header_msg, android.R.style.TextAppearance_Large);
                            header_msg.setTypeface(Typeface.DEFAULT_BOLD);
                        } else {
                            TextView txt_msg = addNewTextView(fragment.getActivity(), parent, content);
                            txt_msg.setGravity(Gravity.CENTER | Gravity.CENTER_HORIZONTAL);
                            Helper.setTextAppearance(fragment.getActivity(), txt_msg, android.R.style.TextAppearance_Small);
                        }
                    }
                } else if (viewType.equalsIgnoreCase("image")) {
                    String image_url = jsonObject.getString("content");
                    if (!TextUtils.isEmpty(image_url)) {
                        ImageView img = addNewImageView(fragment.getActivity(), parent);
                        img.setScaleType(ImageView.ScaleType.CENTER_CROP);
                        Glide.with(fragment.getActivity())
                                .load(image_url)
                                .placeholder(AppInfo.ID_PLACEHOLDER_PRODUCT)
                                .error(R.drawable.error_product)
                                .into(img);
                    }
                } else if (viewType.equalsIgnoreCase("html")) {
                    String content = jsonObject.getString("content");
                    WebView webView = addNewWebView(fragment.getActivity(), parent);
                    webView.setWebViewClient(new WebViewClient() {
                        public boolean shouldOverrideUrlLoading(WebView view, String url){
                            view.loadUrl(url);
                            return true;
                        }

                        @Override
                        public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                            view.loadUrl(request.getUrl().toString());
                            return true;
                        }
                    });
                    if (content.startsWith("http://") || content.startsWith("https://")) {
                        webView.getSettings().setCacheMode(WebSettings.LOAD_DEFAULT);
                        webView.getSettings().setJavaScriptEnabled(true);
                        webView.loadUrl(content);
                    } else {
                        webView.loadData(Base64Utils.decode(content), "text/html; charset=utf-8", "UTF-8");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (!titleEnabled) {
            TextView text_title = (TextView) view.findViewById(R.id.text_title);
            text_title.setVisibility(View.GONE);
        }

        Button btn_ok = view.findViewById(R.id.btn_ok);
        Helper.stylizeRoundButton(btn_ok, AppInfo.normal_button_color, AppInfo.disable_button_color);
        btn_ok.setText(L.getString(L.string.button_accept));

        Button btn_cancel = view.findViewById(R.id.btn_cancel);
        Helper.stylizeRoundButton(btn_cancel, AppInfo.normal_button_color, AppInfo.disable_button_color);
        btn_cancel.setText(L.getString(L.string.button_cancel));

        builder.setView(view).setCancelable(false);
        final AlertDialog alertDialog = builder.create();
        btn_ok.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Helper.hideKeyboard(view);
                Preferences.putBool(R.string.key_consent_dialog_enabled, false);
                alertDialog.dismiss();
            }
        });
        btn_cancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Helper.hideKeyboard(view);
                alertDialog.dismiss();
                TMStoreApp.exit(fragment.getActivity());
            }
        });
        alertDialog.show();
        alertDialog.setOnKeyListener(new Dialog.OnKeyListener() {
            @Override
            public boolean onKey(DialogInterface dialogInterface, int keyCode, KeyEvent event) {
                if (keyCode == KeyEvent.KEYCODE_BACK) {
                    TMStoreApp.exit(fragment.getActivity());
                }
                return true;
            }
        });
    }

    private static TextView addNewTextView(Activity activity, LinearLayout layout, String label) {
        TextView labelText = new TextView(activity);
        labelText.setText(HtmlCompat.fromHtml(label));
        labelText.setPadding(Helper.DP(12), Helper.DP(6), Helper.DP(12), Helper.DP(6));
        layout.addView(labelText, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        return labelText;
    }

    private static ImageView addNewImageView(Activity activity, LinearLayout layout) {
        ImageView img = new ImageView(activity);
        img.setPadding(Helper.DP(12), Helper.DP(6), Helper.DP(12), Helper.DP(6));
        LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 720/*, 240*//*ViewGroup.LayoutParams.MATCH_PARENT,ViewGroup.LayoutParams.WRAP_CONTENT*/);
        layoutParams.gravity = Gravity.CENTER;
        layout.addView(img, layoutParams);
        return img;
    }

    private static WebView addNewWebView(Activity activity, LinearLayout layout) {
        WebView webView = new WebView(activity);
        LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT);
        layout.addView(webView, layoutParams);
        return webView;
    }
}
