package com.twist.tmstore;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.support.annotation.NonNull;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.AppCompatImageView;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.SearchView;
import android.text.InputType;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.animation.GlideAnimation;
import com.bumptech.glide.request.target.SimpleTarget;
import com.twist.dataengine.entities.CurrencyItem;
import com.twist.dataengine.entities.SellerInfo;
import com.twist.dataengine.entities.TM_CommonInfo;
import com.twist.oauth.NetworkUtils;
import com.twist.tmstore.adapters.CurrencyItemsAdapter;
import com.twist.tmstore.config.MultiVendorConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.Cart;
import com.twist.tmstore.views.DividerItemDecorationView;
import com.utils.CContext;
import com.utils.CurrencyHelper;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.LocaleUtils;
import com.utils.Log;
import com.utils.Preferences;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.Locale;

import pl.tajchert.nammu.Nammu;

public abstract class BaseActivity extends AppCompatActivity {

    private String mTitle;

    private boolean showActionBarImage = false;

    private boolean showActionBarSearch = false;

    private View mActionView;

    private Menu mOptionsMenu;

    private ProgressDialog mProgressDialog;

    private boolean actionBarStyleable = true;
    private CurrencyItem mSelectedCurrencyItem = null;

    public void setActionBarStyleable(boolean actionBarStyleable) {
        this.actionBarStyleable = actionBarStyleable;
    }

    @Override
    protected void onResume() {
        super.onResume();
        Helper.init(this);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && actionBarStyleable) {
            Window window = getWindow();
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            int statusBarColor = Color.parseColor(AppInfo.color_theme_statusbar);
            window.setStatusBarColor(statusBarColor);
            if (Helper.isLightColor(statusBarColor)) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
                }
            }
        }

        Nammu.init(getApplicationContext());
        Helper.initContext(this);
        Helper.init(this);
        Preferences.init(this);
        mActionView = LayoutInflater.from(this).inflate(R.layout.layout_actionbar, null);
        mProgressDialog = new ProgressDialog(this);
    }

    protected abstract void onActionBarRestored();

    protected void setupActionBarHomeAsUp(String title) {
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setDisplayHomeAsUpEnabled(true);
            actionBar.setHomeButtonEnabled(true);
            Drawable upArrow = CContext.getDrawable(this, R.drawable.abc_ic_ab_back_material);
            upArrow.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_ATOP);
            actionBar.setHomeAsUpIndicator(upArrow);
            setTitleText(title);
            restoreActionBar();
        }
    }

    public void restoreActionBar() {
        ActionBar mActionBar = getSupportActionBar();
        if (mActionBar != null) {
            mActionBar.setDisplayShowCustomEnabled(true);
            mActionBar.setTitle("");

            final ImageView imageView = (ImageView) mActionView.findViewById(R.id.actionImageView);
            final TextView textView = (TextView) mActionView.findViewById(R.id.actionTextView);
            final SearchView searchView = (SearchView) mActionView.findViewById(R.id.ab_search_view);
            if (!showActionBarSearch) {
                searchView.setVisibility(View.GONE);
                if (AppInfo.SHOW_HOME_TITLE_TEXT && !TextUtils.isEmpty(mTitle)) {
                    textView.setVisibility(View.VISIBLE);
                    if (actionBarStyleable) {
                        textView.setTextColor(Color.parseColor(AppInfo.color_actionbar_text));
                    }
                    textView.setText(HtmlCompat.fromHtml(mTitle));
                } else {
                    textView.setVisibility(View.GONE);
                }

                if (AppInfo.SHOW_ACTIONBAR_ICON && showActionBarImage) {
                    imageView.setVisibility(View.VISIBLE);
                    if (!TextUtils.isEmpty(AppInfo.ACTIONBAR_ICON_URL)) {
                        Glide.with(this)
                                .load(AppInfo.ACTIONBAR_ICON_URL)
                                .asBitmap()
                                .error(R.drawable.actionbar_icon)
                                .into(new SimpleTarget<Bitmap>() {
                                    @Override
                                    public void onResourceReady(Bitmap bitmap, GlideAnimation<? super Bitmap> glideAnimation) {
                                        imageView.setImageBitmap(bitmap);
                                    }

                                    @Override
                                    public void onLoadFailed(Exception e, Drawable errorDrawable) {
                                        imageView.setImageDrawable(errorDrawable);
                                    }
                                });
                    }
                } else {
                    imageView.setVisibility(View.GONE);
                }
            } else {
                textView.setVisibility(View.GONE);
                imageView.setVisibility(View.GONE);
                searchView.setVisibility(View.VISIBLE);
                setUpSearch(searchView);
            }
            mActionBar.setCustomView(mActionView);
            if (actionBarStyleable) {
                mActionBar.setBackgroundDrawable(new ColorDrawable(Color.parseColor(AppInfo.color_theme)));
            }
            setOverflowIconColor(Color.parseColor(AppInfo.color_actionbar_text));
        }
        onActionBarRestored();
    }

    public void hideKeyBoard() {
        View view = this.getCurrentFocus();
        if (view != null) {
            InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
            imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
        }
    }

    public android.support.v4.app.FragmentManager getFM() {
        return this.getSupportFragmentManager();
    }

    public android.support.v4.app.Fragment findFragmentById(final int id) {
        return this.getFM().findFragmentById(id);
    }

    public android.support.v4.app.Fragment findFragmentByClass(Class clz) {
        return getFM().findFragmentByTag(clz.getSimpleName());
    }

    public android.support.v4.app.Fragment findChildFragmentByTag(Class clz, String childTag) throws Exception {
        return getSupportFragmentManager().findFragmentByTag(clz.getSimpleName()).getChildFragmentManager().findFragmentByTag(childTag);
    }

    public android.support.v4.app.Fragment findFragmentByTag(String tag) {
        return getSupportFragmentManager().findFragmentByTag(tag);
    }

    public android.support.v4.app.Fragment findFragment(Class cls) {
        return getSupportFragmentManager().findFragmentByTag(cls.getSimpleName());
    }

    public void setTitleText(String title) {
        mTitle = title;
        if ((MultiVendorConfig.isEnabled()) && SellerInfo.getSelectedSeller() != null) {
            mTitle = SellerInfo.getSelectedSeller().getTitle();
        }
        restoreActionBar();
    }

    public void setTitleText(int textResId) {
        this.setTitleText(getString(textResId));
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        Nammu.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    public String getString(String key) {
        return L.getString(key);
    }

    public void setTextOnView(int textViewResId, String textKey) {
        View view = findViewById(textViewResId);
        if (view instanceof TextView) {
            ((TextView) view).setText(getString(textKey));
        }
    }

    public void setTextOnView(View rootView, int textViewResId, String textKey) {
        View view = rootView.findViewById(textViewResId);
        if (view instanceof TextView) {
            ((TextView) view).setText(getString(textKey));
        }
    }

    public void setShowActionBarImage(boolean show) {
        showActionBarImage = show;
    }

    public void setShowActionBarSearch(boolean show) {
        showActionBarSearch = show;
    }

    public Menu getOptionsMenu() {
        return mOptionsMenu;
    }

    public void setOptionsMenu(Menu optionsMenu) {
        this.mOptionsMenu = optionsMenu;
    }

    @Override
    protected void attachBaseContext(Context newBase) {
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(newBase);
        String locale = preferences.getString(newBase.getString(R.string.key_app_lang), L.getInstance().getLanguage().defaultLocale);
        String language = LocaleUtils.getLanguage(locale);
        String country = LocaleUtils.getCountry(locale);
        super.attachBaseContext(LocaleUtils.getLocalizedContext(newBase, new Locale(language, country)));
    }

    public void showProgress(final String msg, final boolean cancellable) {
        if (!this.isFinishing() && mProgressDialog != null) {
            mProgressDialog.setOnShowListener(new DialogInterface.OnShowListener() {
                @Override
                public void onShow(DialogInterface dialog) {
                    Helper.stylize(mProgressDialog);
                }
            });
            mProgressDialog.setMessage(msg);
            mProgressDialog.setCancelable(cancellable);
            mProgressDialog.show();
        }
    }

    public void showProgress(int msgResId, boolean isCancellable) {
        showProgress(getString(msgResId), isCancellable);
    }

    public void showProgress(int msgResId) {
        showProgress(getString(msgResId), true);
    }

    public void showProgress(String message) {
        showProgress(message, true);
    }

    public void hideProgress() {
        if (!this.isFinishing()) {
            if (mProgressDialog != null && mProgressDialog.isShowing()) {
                mProgressDialog.dismiss();
            }
        }
    }

    public void showToast(String message) {
        Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
    }

    public void setOverflowIconColor(final int color) {
        final String overflowDescription = getString(R.string.abc_action_menu_overflow_description);
        final ViewGroup decorView = (ViewGroup) getWindow().getDecorView();
        decorView.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                final ArrayList<View> outViews = new ArrayList<>();
                try {
                    decorView.findViewsWithText(outViews, overflowDescription, View.FIND_VIEWS_WITH_CONTENT_DESCRIPTION);
                    if (!outViews.isEmpty()) {
                        AppCompatImageView overflow = (AppCompatImageView) outViews.get(0);
                        overflow.setColorFilter(color);
                    }
                    decorView.getViewTreeObserver().removeOnGlobalLayoutListener(this);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if ((keyCode == KeyEvent.KEYCODE_VOLUME_DOWN)) {
            if (NetworkUtils.UPLOAD_LOG) {
                Log.commitBuffer();
                Helper.toast("Log uploaded!");
            }
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }

    protected View inflateCurrencySwitchLayout(Activity activity, LayoutInflater inflater, ViewGroup container) {
        return inflateCurrencySwitchLayout(activity, inflater, container, false, null);
    }

    protected View inflateCurrencySwitchLayout(final Activity activity, LayoutInflater inflater, ViewGroup container, boolean isDialog, final View.OnClickListener closeListener) {
        View rootView = inflater.inflate(R.layout.fragment_change_currency, container, false);
        rootView.setFocusableInTouchMode(true);
        rootView.requestFocus();

        View actionBarView = rootView.findViewById(R.id.layout_action_bar);
        if (actionBarView != null) {
            if (isDialog) {
                actionBarView.setVisibility(View.VISIBLE);
                Helper.stylize(actionBarView);

                TextView titleTextView = (TextView) rootView.findViewById(R.id.title_change_currency);
                titleTextView.setText(getString(L.string.change_currency));
                Helper.stylizeActionBar(titleTextView);

                ImageView btn_close = (ImageView) rootView.findViewById(R.id.btn_close);
                Helper.stylizeActionBar(btn_close);
                btn_close.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(final View view) {
                        if (closeListener != null) {
                            closeListener.onClick(view);
                        }
                    }
                });
            } else {
                actionBarView.setVisibility(View.GONE);
            }
        }

        mSelectedCurrencyItem = null;

        RecyclerView recyclerView = (RecyclerView) rootView.findViewById(R.id.rv_currency_list);
        Button btn_apply_currency = (Button) rootView.findViewById(R.id.btn_apply_currency);
        btn_apply_currency.setText(getString(L.string.change_currency));
        Helper.stylize(btn_apply_currency);
        Drawable dividerDrawable = CContext.getDrawable(this, R.drawable.item_recyclerview_decorator);
        recyclerView.addItemDecoration(new DividerItemDecorationView(dividerDrawable));
        final CurrencyItemsAdapter mAdapter = new CurrencyItemsAdapter(CurrencyHelper.getAllCurrency());
        recyclerView.setAdapter(mAdapter);
        mAdapter.setCurrencySelectionListener(new CurrencyItemsAdapter.OnCurrencySelectionListener() {
            @Override
            public void onSelectCurrency(CurrencyItem currencyItem) {
                mSelectedCurrencyItem = currencyItem;
            }
        });

        String currencyName = Preferences.getString(getString(R.string.key_app_currency), TM_CommonInfo.currency);
        int index = 0;
        for (CurrencyItem currencyItem : CurrencyHelper.getAllCurrency()) {
            if (currencyItem.getName().equalsIgnoreCase(currencyName)) {
                mSelectedCurrencyItem = currencyItem;
                mAdapter.setSelectedItemIndex(index);
                break;
            }
            index++;
        }

        btn_apply_currency.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String currencyName = Preferences.getString(getString(R.string.key_app_currency), TM_CommonInfo.currency);
                if (mAdapter.getItemCount() > 0 && mSelectedCurrencyItem != null) {
                    if (!mSelectedCurrencyItem.getName().equals(currencyName)) {
                        CurrencyHelper.setSelectedCurrencyItem(mSelectedCurrencyItem);
                        Preferences.putString(getString(R.string.key_app_currency), mSelectedCurrencyItem.getName());
                        // update currency of saved cart items.
                        try {
                            CurrencyItem prevCurrencyItem = CurrencyHelper.getCurrencyItemWithName(currencyName);
                            if (prevCurrencyItem != null) {
                                if (Cart.getAll() != null && Cart.getAll().size() > 0) {
                                    for (Cart cart : Cart.getAll()) {
                                        float price = (cart.getPrice() / prevCurrencyItem.getRate()) * mSelectedCurrencyItem.getRate();
                                        cart.setPrice(price);
                                        cart.save();
                                    }
                                }
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }

                        Intent i = new Intent(activity, LauncherActivity.class);
                        i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                        startActivity(i);
                        finish();
                    } else {
                        Helper.showToast(getString(L.string.already_selected_currency));
                    }
                } else {
                    Helper.showToast(getString(L.string.please_select_currency));
                }
            }
        });
        if (mAdapter.getItemCount() > 0) {
            btn_apply_currency.setVisibility(View.VISIBLE);
        } else {
            btn_apply_currency.setVisibility(View.GONE);
        }
        return rootView;
    }

    private void setUpSearch(final SearchView searchView) {
        searchView.setIconifiedByDefault(false);
        searchView.setIconified(true);
        searchView.setInputType(InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS);
        searchView.setOnQueryTextFocusChangeListener(null);
        searchView.setQueryHint(getString(L.string.txt_search_hint));
        searchView.clearFocus();
        searchView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                ((MainActivity) (view.getContext())).openSearchFragment();
            }
        });
        searchView.setOnQueryTextFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View view, boolean hasFocus) {
                if (hasFocus) {
                    ((MainActivity) (view.getContext())).openSearchFragment();
                }
            }
        });

        Helper.stylize(searchView);
        try {
            SearchView.SearchAutoComplete search_src_text = (SearchView.SearchAutoComplete) searchView.findViewById(android.support.v7.appcompat.R.id.search_src_text);
            search_src_text.setHintTextColor(Color.parseColor(AppInfo.color_actionbar_text));
            search_src_text.setBackgroundColor(Color.parseColor(AppInfo.color_theme));

            Field mCursorDrawableRes = TextView.class.getDeclaredField("mCursorDrawableRes");
            mCursorDrawableRes.setAccessible(true);
            mCursorDrawableRes.set(search_src_text, R.drawable.search_view_cursor);
        } catch (Exception e) {
        }

        try {
            ImageView search_close_btn = (ImageView) searchView.findViewById(android.support.v7.appcompat.R.id.search_close_btn);
            search_close_btn.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_IN);
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            View search_plate = searchView.findViewById(android.support.v7.appcompat.R.id.search_plate);
            search_plate.setBackgroundColor(Color.parseColor(AppInfo.color_theme));
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            LinearLayout search_bar = (LinearLayout) searchView.findViewById(android.support.v7.appcompat.R.id.search_bar);
            LinearLayout search_edit_frame = (LinearLayout) searchView.findViewById(android.support.v7.appcompat.R.id.search_edit_frame);
            LinearLayout.LayoutParams layoutParams = (LinearLayout.LayoutParams) search_edit_frame.getLayoutParams();
            layoutParams.setMargins(0, 0, 0, 0);
            search_bar.updateViewLayout(search_edit_frame, layoutParams);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
