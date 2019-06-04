package com.twist.tmstore.fragments;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.ProgressBar;

import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.entities.AppInfo;
import com.utils.Helper;
import com.utils.Log;

public class Fragment_About extends BaseFragment {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
    }

    public static Fragment_About newInstance() {
        return new Fragment_About();
    }

    public Fragment_About() {
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_about, container, false);

        setActionBarHomeAsUpIndicator();
        getBaseActivity().restoreActionBar();

        ProgressBar progress = (ProgressBar) rootView.findViewById(R.id.progress);
        Helper.stylize(progress);
        progress.setVisibility(View.GONE);

        WebView webView = (WebView) rootView.findViewById(R.id.webView);
        WebSettings settings = webView.getSettings();
        settings.setDefaultTextEncodingName("utf-8");
        settings.setJavaScriptEnabled(true);
        settings.setLayoutAlgorithm(WebSettings.LayoutAlgorithm.SINGLE_COLUMN);
        webView.setWebViewClient(new WebViewClient() {
            public void onPageFinished(WebView view, String url) {
                MainActivity.mActivity.hideProgress();
            }

            public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
                MainActivity.mActivity.hideProgress();
            }
        });
        MainActivity.mActivity.showProgress(getString(L.string.loading));
        webView.loadUrl(AppInfo.ABOUT_URL);
        setTitle(getString(L.string.title_about));
        Log.commitBuffer();

        return rootView;
    }
}