package com.twist.tmstore;

import android.app.Dialog;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v7.app.ActionBar;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;

import com.twist.tmstore.entities.AppInfo;
import com.utils.CContext;

/**
 * Created by Twist Mobile on 8/28/2017.
 */

public class ChangeCurrencyActivity extends BaseActivity {

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setHomeButtonEnabled(true);
            actionBar.setDisplayHomeAsUpEnabled(true);
            Drawable upArrow = CContext.getDrawable(this, R.drawable.abc_ic_ab_back_material);
            upArrow.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_ATOP);
            actionBar.setHomeAsUpIndicator(upArrow);
            this.setTitleText(getString(L.string.title_currency));
            this.restoreActionBar();
        }
        setContentView(R.layout.activity_change_currency);
        CurrencySwitcherFragment fragment = new CurrencySwitcherFragment();
        getSupportFragmentManager().beginTransaction()
                .replace(R.id.content, fragment)
                .commit();
    }

    @Override
    protected void onActionBarRestored() {
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            this.onBackPressed();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    public static class CurrencySwitcherDialogFragment extends BaseDialogFragment {
        public CurrencySwitcherDialogFragment() {
        }

        @Override
        public void dismiss() {
            getDialog().dismiss();
        }

        @NonNull
        @Override
        public Dialog onCreateDialog(@NonNull Bundle savedInstanceState) {
            Dialog dialog = super.onCreateDialog(savedInstanceState);
            if (dialog.getWindow() != null) {
                dialog.getWindow().requestFeature(Window.FEATURE_NO_TITLE);
            }
            return dialog;
        }

        @Override
        public void onStart() {
            super.onStart();
            if (getDialog() != null) {
                Dialog dialog = getDialog();
                if (dialog != null) {
                    int width = ViewGroup.LayoutParams.WRAP_CONTENT;
                    int height = ViewGroup.LayoutParams.WRAP_CONTENT;
                    if (dialog.getWindow() != null) {
                        dialog.getWindow().setLayout(width, height);
                    }
                }
            }
        }

        @Nullable
        @Override
        public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
            if (getDialog() != null && getDialog().getWindow() != null) {
                getDialog().getWindow().requestFeature(Window.FEATURE_NO_TITLE);
            }
            return ((BaseActivity) getActivity()).inflateCurrencySwitchLayout(getActivity(), inflater, container, true, new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    CurrencySwitcherDialogFragment.this.dismiss();
                }
            });
        }
    }

    public static class CurrencySwitcherFragment extends BaseFragment {
        public CurrencySwitcherFragment() {
        }

        @Nullable
        @Override
        public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
            return ((BaseActivity) getActivity()).inflateCurrencySwitchLayout(getActivity(), inflater, container);
        }
    }
}
