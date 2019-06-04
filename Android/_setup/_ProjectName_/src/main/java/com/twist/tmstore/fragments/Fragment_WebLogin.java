package com.twist.tmstore.fragments;

import android.app.Dialog;
import android.graphics.Point;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.ProgressBar;

import com.twist.dataengine.DataEngine;
import com.twist.tmstore.BaseDialogFragment;
import com.twist.tmstore.R;
import com.twist.tmstore.WebLoginInterface;
import com.twist.tmstore.listeners.LoginListener;
import com.utils.Helper;
import com.utils.Log;

import java.io.File;
import java.util.Objects;


public class Fragment_WebLogin extends BaseDialogFragment {

    public void setLoginListener(LoginListener handler) {
        this.loginDialogHandler = handler;
    }

    private LoginListener loginDialogHandler = null;

    public Fragment_WebLogin() {
    }

    int loadCounter = 0;
    WebView webView;
    ProgressBar progress;

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        if (getDialog() != null) {
            Objects.requireNonNull(getDialog().getWindow()).requestFeature(Window.FEATURE_NO_TITLE);
        }

        View rootView = inflater.inflate(R.layout.fragment_about, container, false);

        progress = rootView.findViewById(R.id.progress);
        Helper.stylize(progress);
        progress.setVisibility(View.GONE);

        webView = rootView.findViewById(R.id.webView);
        initWebView();
        File dir = getActivity().getCacheDir();
        if (!dir.exists()) {
            dir.mkdirs();
        }

        progress.setVisibility(View.VISIBLE);
        loadCounter = 1;
        webView.loadUrl(DataEngine.baseURL + "/wp-login.php?user_platform=Android");

        return rootView;
    }


    private class AppWebViewClient extends WebViewClient {
        @Override
        public boolean shouldOverrideUrlLoading(WebView webView, String url) {
            webView.loadUrl(url);
            return true;
        }

        @Override
        public void onPageFinished(WebView view, String url) {
            super.onPageFinished(view, url);
            loginToWebSite(url);
        }
    }

    public void loginToWebSite(String url) {
        switch (loadCounter) {
            case 0:
                webView.loadUrl(DataEngine.baseURL + "/wp-login.php?user_platform=Android");
                loadCounter = 1;
                break;
            case 1:
                webView.setVisibility(View.VISIBLE);
                progress.setVisibility(View.GONE);
                /*
                String formFillJavaScript = "javascript:document.getElementById('user_login').value = '"
					+ AppUser.getInstance().username
					+ "';"
					+ "javascript:document.getElementById('user_pass').value = '"
					+ AppUser.getInstance().password
					+ "';";
				System.out.println("*** formFillJavaScript: ["+formFillJavaScript+"] ***");
				webView.loadUrl(formFillJavaScript);
				loadCounter = 2;
				*/
                break;
        }
    }

    private void initWebView() {
        WebSettings settings = webView.getSettings();
        settings.setDefaultTextEncodingName("utf-8");
        settings.setLayoutAlgorithm(WebSettings.LayoutAlgorithm.SINGLE_COLUMN);
        WebLoginInterface webInterface = new WebLoginInterface();
        webInterface.setWebResponseListener((resultCode, response) -> {
            Log.d("== MainActivity::onResponseReceived [" + resultCode + "][" + response + "] ==");
            if (response.contains("Login Successful")) {
                Log.d("-- MainActivity|signInWebUsing|setWebResponseListener::onResponseReceived [Login Successful] --");
                if (loginDialogHandler != null) {
                    loginDialogHandler.onLoginSuccess(response);
                    dismiss();
                }
            } else {
                Log.d("-- MainActivity|signInWebUsing|setWebResponseListener::onResponseReceived [Login Failed] --");
                if (loginDialogHandler != null) {
                    loginDialogHandler.onLoginFailed("Web SignIn Failed!");
                    dismiss();
                }
            }
        });
        webView.addJavascriptInterface(webInterface, "Android");
        settings.setJavaScriptEnabled(true);
        settings.setSaveFormData(true);
        settings.setDatabaseEnabled(true);
        settings.setDomStorageEnabled(true);
        settings.setAllowFileAccess(true);
        settings.setSupportMultipleWindows(true);
        webView.setVisibility(View.INVISIBLE);
        webView.setWebViewClient(new AppWebViewClient());
    }

    @Override
    public void onStart() {
        Helper.gc();
        super.onStart();
        Dialog dialog = this.getDialog();
        if (dialog != null) {
            Window window = dialog.getWindow();
            if (window != null) {
                Display display = getActivity().getWindowManager().getDefaultDisplay();
                Point size = new Point();
                display.getSize(size);
                int width = size.x;
                int height = window.getAttributes().height;
                window.setLayout(width, height);
            }

            if (dialog.getActionBar() != null) {
                dialog.getActionBar().setBackgroundDrawable(new ColorDrawable(getResources().getColor(R.color.color_theme)));
            }
        }
    }
}
