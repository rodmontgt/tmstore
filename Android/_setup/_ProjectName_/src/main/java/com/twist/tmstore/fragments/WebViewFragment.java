package com.twist.tmstore.fragments;

import android.graphics.Bitmap;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.TextView;

import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.Extras;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.utils.Helper;
import com.utils.customviews.progressbar.CircleProgressBar;

/**
 * Created by Twist Mobile on 10-Jun-16.
 */
public class WebViewFragment extends BaseFragment {

    private WebView mWebView;

    private View mEmptyView;

    private CircleProgressBar mProgressBar;

    public WebViewFragment() {
    }

    public static WebViewFragment create(String title, String url) {
        WebViewFragment fragment = new WebViewFragment();
        Bundle args = new Bundle();
        args.putString(Extras.ARG_TITLE, title);
        args.putString(Extras.ARG_URL, url);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_webview, container, false);
        rootView.setFocusableInTouchMode(true);
        rootView.requestFocus();
        rootView.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                if (event.getAction() == KeyEvent.ACTION_DOWN) {
                    if (keyCode == KeyEvent.KEYCODE_BACK) {
                        if (getActivity().getSupportFragmentManager().getBackStackEntryCount() > 0) {
                            getActivity().getSupportFragmentManager().popBackStack();
                            return true;
                        }
                    }
                }
                return false;
            }
        });

        mEmptyView = rootView.findViewById(R.id.empty_view);
        mProgressBar = (CircleProgressBar) rootView.findViewById(R.id.progress_bar);
        Helper.stylize(mProgressBar);

        TextView text_empty = (TextView) rootView.findViewById(R.id.text_empty);
        text_empty.setText(getString(L.string.nothing_to_display));

        mWebView = (WebView) rootView.findViewById(R.id.web_view);
        mWebView.getSettings().setCacheMode(WebSettings.LOAD_DEFAULT);
        mWebView.getSettings().setJavaScriptEnabled(true);
        mWebView.setWebViewClient(new MyWebClient());
        mWebView.loadUrl(getArguments().getString(Extras.ARG_URL));
        setTitle(getArguments().getString(Extras.ARG_TITLE));
        setActionBarHomeAsUpIndicator();
        return rootView;
    }

    public class MyWebClient extends WebViewClient {
        @Override
        public void onPageStarted(WebView view, String url, Bitmap favicon) {
            super.onPageStarted(view, url, favicon);
            mEmptyView.setVisibility(View.GONE);
            mProgressBar.setVisibility(View.VISIBLE);
            mWebView.setVisibility(View.GONE);
        }

        @Override
        public boolean shouldOverrideUrlLoading(WebView view, String url) {
            view.loadUrl(url);
            return true;
        }

        @Override
        public void onPageFinished(WebView view, String url) {
            super.onPageFinished(view, url);
            mEmptyView.setVisibility(View.GONE);
            mProgressBar.setVisibility(View.GONE);
            mWebView.setVisibility(View.VISIBLE);
        }

        @Override
        public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
            super.onReceivedError(view, request, error);
            mEmptyView.setVisibility(View.VISIBLE);
            mProgressBar.setVisibility(View.GONE);
            mWebView.setVisibility(View.GONE);
        }
    }
}
