package com.twist.tmstore.views;

import android.content.Context;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.support.annotation.Nullable;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.SearchView;
import android.text.Spannable;
import android.text.SpannableStringBuilder;
import android.text.style.ImageSpan;
import android.util.AttributeSet;
import android.view.View;
import android.widget.ImageView;

import com.twist.tmstore.R;

/**
 * Created by Twist Mobile on 02-Sep-16.
 */

public class MySearchView extends SearchView {
    private int mThemeColor = Color.WHITE;

    private SearchView.SearchAutoComplete mQueryTextView;

    public MySearchView(Context context) {
        super(context);
        this.setIconifiedByDefault(true);
    }

    public MySearchView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public MySearchView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public void setThemeColor(int color) {
        this.mThemeColor = color;
        try {
            mQueryTextView = (SearchView.SearchAutoComplete) findViewById(android.support.v7.appcompat.R.id.search_src_text);
            if (mQueryTextView != null) {
                mQueryTextView.setTextColor(mThemeColor);
                mQueryTextView.setHintTextColor(mThemeColor);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            ImageView searchCloseBtn = (ImageView) findViewById(android.support.v7.appcompat.R.id.search_close_btn);
            if (searchCloseBtn != null) {
                searchCloseBtn.setColorFilter(mThemeColor, PorterDuff.Mode.SRC_IN);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            ImageView searchMagIcon = (ImageView) findViewById(android.support.v7.appcompat.R.id.search_mag_icon);
            if (searchMagIcon != null) {
                searchMagIcon.setColorFilter(mThemeColor, PorterDuff.Mode.SRC_IN);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            ImageView searchButton = (ImageView) findViewById(android.support.v7.appcompat.R.id.search_button);
            if (searchButton != null) {
                searchButton.setColorFilter(mThemeColor, PorterDuff.Mode.SRC_IN);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            View mSearchPlate = findViewById(android.support.v7.appcompat.R.id.search_plate);
            if (mSearchPlate != null) {
                Drawable background = mSearchPlate.getBackground();
                if (background != null) {
                    background.setColorFilter(mThemeColor, PorterDuff.Mode.SRC_IN);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void setQueryHint(@Nullable CharSequence hint) {
        try {
            if (mQueryTextView != null) {
                SpannableStringBuilder ssb = new SpannableStringBuilder("   "); // for the icon
                ssb.append(hint);
                Drawable searchIcon = ContextCompat.getDrawable(getContext(), R.drawable.ic_vc_search);
                searchIcon.setColorFilter(mThemeColor, PorterDuff.Mode.SRC_IN);
                int textSize = (int) (mQueryTextView.getTextSize() * 1.25);
                searchIcon.setBounds(0, 0, textSize, textSize);
                ssb.setSpan(new ImageSpan(searchIcon), 1, 2, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
                mQueryTextView.setHint(ssb);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
