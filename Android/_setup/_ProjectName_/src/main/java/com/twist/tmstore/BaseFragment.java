package com.twist.tmstore;

import android.app.Activity;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.support.annotation.IdRes;
import android.support.design.widget.TextInputLayout;
import android.support.v4.app.FragmentManager;
import android.support.v4.view.ViewPager;
import android.support.v7.app.ActionBar;
import android.view.KeyEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.listeners.BackKeyListener;
import com.twist.tmstore.listeners.ViewPagerKeyListener;
import com.utils.CContext;
import com.utils.HtmlCompat;
import com.utils.Log;

/**
 * Created by Twist Mobile on 04-Jul-16.
 */

public abstract class BaseFragment extends android.support.v4.app.Fragment {

    private View mRootView;

    private ViewPagerKeyListener viewPagerKeyListener;

    public void setRootView(View rootView) {
        this.mRootView = rootView;
    }

    public void setTitle(String key) {
        Activity activity = this.getActivity();
        if (activity instanceof BaseActivity) {
            ((BaseActivity) activity).setTitleText(getString(key));
        } else {
            activity.setTitle(HtmlCompat.fromHtml(getString(key)));
        }
    }

    public String getString(String key) {
        return L.getString(key);
    }

    public String getString(String key, boolean ignoreFormat) {
        return L.getString(key, ignoreFormat);
    }

    protected void setTextOnView(View parent, int resourceId, String textKey) {
        View view = parent.findViewById(resourceId);
        if (view instanceof EditText) {
            ((EditText) view).setHint(getString(textKey));
        } else if (view instanceof TextView) {
            ((TextView) view).setText(getString(textKey));
        }
    }

    protected void setTextOnView(int resourceId, String textKey) {
        View view = mRootView.findViewById(resourceId);
        if (view instanceof TextView) {
            ((TextView) view).setText(getString(textKey));
        }
    }

    protected void setHintOnTextInput(int resourceId, String textKey) {
        if (mRootView == null) {
            Log.e("You must set root viewPager first.");
            return;
        }

        View view = mRootView.findViewById(resourceId);
        if (view instanceof TextInputLayout) {
            ((TextInputLayout) view).setHint(getString(textKey));
        }
    }

    protected EditText findEditText(@IdRes int resourceId) {
        return (EditText) mRootView.findViewById(resourceId);
    }

    protected TextInputLayout findTextInputLayout(@IdRes int resourceId) {
        return (TextInputLayout) mRootView.findViewById(resourceId);
    }

    protected TextView findTextView(@IdRes int resourceId) {
        return (TextView) mRootView.findViewById(resourceId);
    }

    protected Button findButton(@IdRes int resourceId) {
        return (Button) mRootView.findViewById(resourceId);
    }

    protected ImageView findImageView(@IdRes int resourceId) {
        return (ImageView) mRootView.findViewById(resourceId);
    }

    protected View findView(@IdRes int resourceId) {
        return mRootView.findViewById(resourceId);
    }

    protected void requestFocus(View view) {
        if (view != null && view.requestFocus()) {
            getActivity().getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_VISIBLE);
        }
    }

    protected String getViewPagerTag(ViewPager viewPager) {
        return "android:switcher:" + viewPager.getId() + ":" + viewPager.getCurrentItem();
    }

    protected BaseActivity getBaseActivity() {
        return (BaseActivity) getActivity();
    }

    public android.support.v4.app.Fragment findChildFragment(String tag) throws Exception {
        return getActivity().getSupportFragmentManager().findFragmentByTag(this.getClass().getSimpleName()).getChildFragmentManager().findFragmentByTag(tag);
    }

    //protected abstract void handleActivityResult(int requestCode, int resultCode, Intent data);

    public void setViewPagerKeyListener(final ViewPagerKeyListener viewPagerKeyListener) {
        this.viewPagerKeyListener = viewPagerKeyListener;
    }

    public void registerViewPagerKeyListenerOnView(View rootView) {
        if (rootView != null) {
            rootView.setFocusableInTouchMode(true);
            rootView.requestFocus();
            rootView.setOnKeyListener(new View.OnKeyListener() {
                @Override
                public boolean onKey(View v, int keyCode, KeyEvent event) {
                    return viewPagerKeyListener != null && viewPagerKeyListener.onKey(v, keyCode, event);
                }
            });
        }
    }

    public void addBackKeyListenerOnView(final View rootView, final BackKeyListener backKeyListener) {
        if (rootView == null) {
            throw new RuntimeException("rootView can not be null.");
        }

        if (backKeyListener == null) {
            throw new RuntimeException("backKeyListener can not be null.");
        }

        rootView.setFocusableInTouchMode(true);
        rootView.requestFocus();
        rootView.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                if (event.getAction() == KeyEvent.ACTION_DOWN) {
                    if (keyCode == KeyEvent.KEYCODE_BACK) {
                        backKeyListener.onBackPressed();
                        return true;
                    }
                }
                return false;
            }
        });
    }


    private int mProgressCount = 0;

    protected void showProgress(String msg, boolean cancellable) {
        BaseActivity activity = getBaseActivity();
        if (activity != null && !activity.isFinishing()) {
            mProgressCount++;
            activity.showProgress(msg, cancellable);
        }
    }

    protected void showProgress(int msgResId, boolean cancellable) {
        showProgress(getString(msgResId), cancellable);
    }

    protected void showProgress(int msgResId) {
        showProgress(getString(msgResId), true);
    }

    protected void showProgress(String message) {
        showProgress(message, true);
    }

    protected void hideProgress() {
        BaseActivity activity = getBaseActivity();
        if (activity != null && !activity.isFinishing()) {
            if (mProgressCount == 1) {
                activity.hideProgress();
            }
            if (mProgressCount > 0) {
                mProgressCount--;
            }
        }
    }

    protected void showToast(String message) {
        getBaseActivity().showToast(message);
    }

    protected ActionBar getSupportActionBar() {
        return getBaseActivity().getSupportActionBar();
    }

    protected FragmentManager getSupportFM() {
        return getActivity().getSupportFragmentManager();
    }

    protected void setActionBarHomeAsUpIndicator() {
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setHomeButtonEnabled(true);
            actionBar.setDisplayHomeAsUpEnabled(true);
            Drawable upArrow = CContext.getDrawable(getActivity(), R.drawable.abc_ic_ab_back_material);
            upArrow.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_ATOP);
            actionBar.setHomeAsUpIndicator(upArrow);
        }
    }
}
