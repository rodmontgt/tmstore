package com.utils;

import android.Manifest;
import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.ActivityNotFoundException;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.ContentValues;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.res.ColorStateList;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.Point;
import android.graphics.PorterDuff;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.InsetDrawable;
import android.graphics.drawable.LayerDrawable;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.StateListDrawable;
import android.graphics.drawable.shapes.OvalShape;
import android.location.Criteria;
import android.location.LocationManager;
import android.media.ExifInterface;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.preference.PreferenceManager;
import android.provider.MediaStore;
import android.support.annotation.DrawableRes;
import android.support.annotation.StyleRes;
import android.support.design.widget.BottomNavigationView;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.design.widget.TextInputLayout;
import android.support.v4.content.ContextCompat;
import android.support.v4.content.FileProvider;
import android.support.v4.content.res.ResourcesCompat;
import android.support.v4.graphics.drawable.DrawableCompat;
import android.support.v7.app.AlertDialog;
import android.support.v7.widget.PopupMenu;
import android.support.v7.widget.SearchView;
import android.support.v7.widget.SwitchCompat;
import android.support.v7.widget.Toolbar;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextUtils;
import android.text.style.ForegroundColorSpan;
import android.util.Base64;
import android.util.DisplayMetrics;
import android.util.Patterns;
import android.util.TypedValue;
import android.view.Display;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.View.MeasureSpec;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.view.Window;
import android.view.WindowManager;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.AlphaAnimation;
import android.view.animation.DecelerateInterpolator;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.GridView;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.RadioButton;
import android.widget.RatingBar;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ToggleButton;

import com.daimajia.slider.library.SliderLayout;
import com.easyandroidanimations.library.Animation;
import com.easyandroidanimations.library.SlideInAnimation;
import com.shopgun.android.materialcolorcreator.MaterialColor;
import com.shopgun.android.materialcolorcreator.MaterialColorImpl;
import com.shopgun.android.materialcolorcreator.Shade;
import com.twist.dataengine.DataEngine;
import com.twist.dataengine.entities.TM_CategoryInfo;
import com.twist.dataengine.entities.TM_CommonInfo;
import com.twist.dataengine.entities.TM_PaymentGateway;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.BuildConfig;
import com.twist.tmstore.Constants;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.PhoneNumberAdapter;
import com.twist.tmstore.config.GuestUserConfig;
import com.twist.tmstore.config.ImageDownloaderConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.CustomerData;
import com.twist.tmstore.entities.WishListGroup;
import com.twist.tmstore.entities.Wishlist;
import com.utils.customviews.progressbar.CircleProgressBar;
import com.utils.customviews.rangeseekbar.RangeSeekBar;
import com.utils.customviews.staggeredgridviews.StaggeredGridView;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.reflect.Field;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.DateFormat;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Random;
import java.util.regex.Pattern;

import eu.fiskur.chipcloud.ChipCloud;
import pl.tajchert.nammu.Nammu;
import pl.tajchert.nammu.PermissionCallback;

import static com.twist.tmstore.L.getString;

@SuppressWarnings("deprecation")
public class Helper {
    public static Context context = null;
    public static boolean isFTBMenuOpen = false;

    public static void shareImageWithText(Bitmap bitmap, String text) {
        try {
            Intent intent = new Intent(Intent.ACTION_SEND);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.putExtra(Intent.EXTRA_TEXT, text);
            intent.setType("text/plain");
            Uri uri = Helper.getBitmapUri(context, bitmap);
            if (uri != null) {
                intent.putExtra(Intent.EXTRA_STREAM, uri);
                intent.setType("image/*");
            }
            context.startActivity(intent);
        } catch (Exception e) {
            e.printStackTrace();
            Helper.toast(L.string.whatsapp_install_error);
        }
    }

    public static void shareOnWhatsApp(String extraText, ArrayList<Uri> bitmap) {
        try {
            Intent intent = new Intent(android.content.Intent.ACTION_SEND_MULTIPLE);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.setType("text/plain");
            if (bitmap != null) {
                intent.putExtra(Intent.EXTRA_STREAM, bitmap);
                intent.setType("image/*");
            }
            //intent.setPackage("com.whatsapp");
            MainActivity.mActivity.startActivityForResult(intent, 11);
        } catch (Exception e) {
            e.printStackTrace();
            toast(L.string.whatsapp_install_error);
        }

    }

    public static void shareApp(Activity activity) {
        try {
            Intent sharingIntent = new Intent(android.content.Intent.ACTION_SEND);
            sharingIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            sharingIntent.setType("text/plain");

            String extraText = String.format(getString(L.string.share_app_title), getApplicationName(), Uri.parse(getPlayStoreUrl()));
            sharingIntent.putExtra(android.content.Intent.EXTRA_TEXT, extraText);

            activity.startActivity(Intent.createChooser(sharingIntent, getString(L.string.share_via)));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static Bitmap getBitmapFromURL(String src) {
        try {
            URL url = new URL(src);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setDoInput(true);
            connection.connect();
            InputStream input = connection.getInputStream();
            return BitmapFactory.decodeStream(input);
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }

    public static void shareOnWhatsApp(String extraText, Bitmap bitmap) {
        try {
            Intent intent = new Intent(Intent.ACTION_SEND);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.putExtra(Intent.EXTRA_TEXT, extraText);
            Uri uri = Helper.getBitmapUri(context, bitmap);
            if (uri != null) {
                intent.putExtra(Intent.EXTRA_STREAM, uri);
                intent.setType("image/*");
            } else {
                intent.setType("text/plain");
            }
            intent.setPackage("com.whatsapp");
            context.startActivity(intent);
        } catch (Exception e) {
            e.printStackTrace();
            toast(L.string.whatsapp_install_error);
        }
    }

    public static BitmapDrawable getColoredBitmapDrawable(int resId, String color) {
        BitmapDrawable bitmapDrawable = new BitmapDrawable(BitmapFactory.decodeResource(context.getResources(), resId));
        bitmapDrawable.setColorFilter(Color.parseColor(color), android.graphics.PorterDuff.Mode.MULTIPLY);
        return bitmapDrawable;
    }

    public static GradientDrawable getShapeRect1(int color, int strokeColor) {
        GradientDrawable shape_rect_1 = new GradientDrawable();
        shape_rect_1.setShape(GradientDrawable.RECTANGLE);
        shape_rect_1.setColor(color);
        shape_rect_1.setStroke(DP(1), strokeColor);
        return shape_rect_1;
    }

    public static GradientDrawable getShapeRect1() {
        int color = Color.parseColor(AppInfo.normal_button_color);
        // both colors are same here
        return getShapeRect1(color, color);
    }

    public static GradientDrawable getShapeRect2(int color, int strokeColor) {
        GradientDrawable drawable = new GradientDrawable();
        drawable.setShape(GradientDrawable.RECTANGLE);
        drawable.setColor(color);
        drawable.setStroke(DP(1), strokeColor);
        return drawable;
    }

    public static GradientDrawable getShapeRect2() {
        int color = getColorShade(AppInfo.normal_button_color, Shade.Shade300);
        int strokeColor = Color.parseColor(AppInfo.normal_button_color);
        return getShapeRect2(color, strokeColor);
    }

    public static GradientDrawable getShapeRect3() {
        GradientDrawable shape_rect_3 = new GradientDrawable();
        shape_rect_3.setShape(GradientDrawable.RECTANGLE);
        shape_rect_3.setColor(Color.parseColor(AppInfo.disable_button_color));
        shape_rect_3.setStroke(DP(1), Color.parseColor(AppInfo.disable_button_color));
        return shape_rect_3;
    }

    public static GradientDrawable getButtonSectionBorder() {
        GradientDrawable gd = new GradientDrawable();
        gd.setShape(GradientDrawable.RECTANGLE);
        gd.setStroke(Helper.DP(1), Color.parseColor(AppInfo.normal_button_color));
        return gd;
    }

    public static StateListDrawable getBtnOvalDrawable() {
        StateListDrawable drawables = new StateListDrawable();
        drawables.addState(new int[]{-android.R.attr.state_enabled}, getShapeOval1());
        drawables.addState(new int[]{android.R.attr.state_pressed}, getShapeOval1());
        drawables.addState(new int[]{android.R.attr.state_enabled}, getShapeOval1());
        drawables.addState(new int[]{android.R.attr.state_first}, getShapeOval1());
        return drawables;
    }

    public static StateListDrawable getBtnOvalDrawable2() {
        StateListDrawable drawables = new StateListDrawable();
        drawables.addState(new int[]{-android.R.attr.state_enabled}, getShapeOval2());
        drawables.addState(new int[]{android.R.attr.state_pressed}, getShapeOval2());
        drawables.addState(new int[]{android.R.attr.state_enabled}, getShapeOval2());
        drawables.addState(new int[]{android.R.attr.state_first}, getShapeOval2());
        return drawables;
    }

    public static GradientDrawable getShapeOval1() {
        GradientDrawable shape = new GradientDrawable();
        shape.setShape(GradientDrawable.OVAL);
        shape.setColor(Color.parseColor(AppInfo.normal_button_color));
        return shape;
    }

    public static GradientDrawable getShapeOval2() {
        GradientDrawable shape = new GradientDrawable();
        shape.setShape(GradientDrawable.OVAL);
        shape.setColor(Color.parseColor("#F0F0F0"));
        return shape;
    }

    public static GradientDrawable getShapeRectForEditText() {
        GradientDrawable shape = new GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM, new int[]{Color.parseColor("#FFFFFF"), Color.parseColor("#FFFFFF")});
        shape.setShape(GradientDrawable.RECTANGLE);
        shape.setCornerRadii(getCornerRadiiDP(1));
        shape.setStroke(Helper.DP(1), Color.parseColor(AppInfo.normal_button_color));
        shape.setGradientType(GradientDrawable.LINEAR_GRADIENT);
        return shape;
    }

    public static GradientDrawable getFlatRectShapeForEditText() {
        GradientDrawable shape = new GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM, new int[]{Color.WHITE, Color.WHITE});
        shape.setShape(GradientDrawable.RECTANGLE);
        shape.setCornerRadii(getCornerRadiiDP(4));
        shape.setStroke(Helper.DP(3), Color.parseColor(AppInfo.normal_button_color));
        shape.setGradientType(GradientDrawable.LINEAR_GRADIENT);
        return shape;
    }

    public static float[] getCornerRadiiDP(int r) {
        float cr = DP(r);
        return new float[]{cr, cr, cr, cr, cr, cr, cr, cr};
    }

    public static GradientDrawable getTextViewDashedBorder() {
        GradientDrawable shape = new GradientDrawable();
        shape.setShape(GradientDrawable.RECTANGLE);
        shape.setCornerRadii(getCornerRadiiDP(4));
        shape.setStroke(DP(2), Color.parseColor(AppInfo.normal_button_color), DP(10), DP(5));
        shape.setGradientType(GradientDrawable.LINEAR_GRADIENT);
        return shape;
    }

    public static LayerDrawable getInsetBackground(int bgColor, int strokeColor, int s, int g) {
        s = Helper.DP(s);
        g = Helper.DP(g);

        GradientDrawable border1 = new GradientDrawable();
        border1.setColor(strokeColor);

        GradientDrawable border2 = new GradientDrawable();
        if (isLightColor(bgColor)) {
            //border2.setColor(new MaterialColorImpl(bgColor).getColor(Shade.Shade600).getValue());
            border2.setColor(Color.parseColor("#f9f9f9"));
        } else {
            //border2.setColor(new MaterialColorImpl(bgColor).getColor(Shade.Shade300).getValue());
            border2.setColor(Color.WHITE);
        }

        GradientDrawable border3 = new GradientDrawable();
        border3.setColor(bgColor);

        GradientDrawable[] layers = {border1, border2, border3};
        LayerDrawable layerDrawable = new LayerDrawable(layers);

        layerDrawable.setLayerInset(0, 0, 0, 0, 0);
        layerDrawable.setLayerInset(1, s, s, s, s);
        layerDrawable.setLayerInset(2, s + g, s + g, s + g, s + g);

        return layerDrawable;
    }

    public static GradientDrawable getSelectedListItemBorder(int color, int stroke, int cornerRadii) {
        GradientDrawable shape = new GradientDrawable();
        shape.setShape(GradientDrawable.RECTANGLE);
        shape.setCornerRadii(getCornerRadiiDP(cornerRadii));
        shape.setStroke(Helper.DP(stroke), color);
        shape.setGradientType(GradientDrawable.LINEAR_GRADIENT);
        return shape;
    }

    public static GradientDrawable getSelectedListItemBorder(int color) {
        return getSelectedListItemBorder(color, 1, 2);
    }

    public static void stylizeSwitchCompact(SwitchCompat button) {
        ColorStateList buttonStates = new ColorStateList(
                new int[][]{
                        new int[]{android.R.attr.state_checked},
                        new int[]{android.R.attr.state_pressed},
                        new int[]{-android.R.attr.state_checked}
                },
                new int[]{
                        Color.parseColor(AppInfo.normal_button_color),
                        Color.parseColor(AppInfo.selected_button_color),
                        Color.parseColor(AppInfo.disable_button_color)
                }
        );
        button.setThumbTintList(buttonStates);
        button.setTrackTintList(buttonStates);
    }

    public static GradientDrawable getShapeRoundBG_Green() {
        GradientDrawable shape = new GradientDrawable();
        shape.setShape(GradientDrawable.OVAL);
        shape.setColor(Color.parseColor("#ff66bb6a"));
        shape.setStroke(DP(2), Color.parseColor("#9966bb6a"));
        return shape;
    }

    public static GradientDrawable getShapeRoundBG_Gray() {
        GradientDrawable shape = new GradientDrawable();
        shape.setShape(GradientDrawable.OVAL);
        shape.setColor(Color.parseColor("#ffffff"));
        shape.setStroke(DP(2), Color.parseColor("#c2c2c2"));
        return shape;
    }

    public static ColorStateList getTxtCommon1(int colorNormal, int colorSelected) {
        int[][] states = new int[][]{
                new int[]{-android.R.attr.state_enabled},
                new int[]{android.R.attr.state_pressed},
                new int[]{android.R.attr.state_enabled},
                new int[]{android.R.attr.state_first}
        };
        int[] colors = new int[]{
                colorNormal,
                colorSelected,
                colorNormal,
                colorNormal
        };
        return new ColorStateList(states, colors);
    }

    public static ColorStateList getTxtCommon1() {
        int colorNormal = Color.parseColor(AppInfo.normal_button_text_color);
        int colorSelected = new MaterialColorImpl(colorNormal).getColor(Shade.Shade200).getValue();
        return getTxtCommon1(colorNormal, colorSelected);
    }

    public static ColorStateList getToggleTxtCommon1() {
        int[][] states = new int[][]{
                new int[]{android.R.attr.state_pressed}, // while user holds his/her finger on button temp
                new int[]{android.R.attr.state_checked}, // when button is checked
                new int[]{-android.R.attr.state_checked}, //when button is not checked
                new int[]{android.R.attr.state_first} //default
        };
        int[] colors = new int[]{
                Color.parseColor(AppInfo.normal_button_text_color), //red //perfect
                Color.parseColor(AppInfo.selected_button_text_color), //blue //awesome
                Color.parseColor(AppInfo.normal_button_text_color), // purple
                Color.parseColor(AppInfo.normal_button_text_color) //yellow
        };
        return new ColorStateList(states, colors);
    }

    public static void init(Context c) {
        context = c;
    }

    public static void stylize(ProgressBar progressBar) {
        if (progressBar == null) return;
        int color = Color.parseColor(AppInfo.color_theme);
        if (Helper.isLightColor(color)) {
            color = Color.parseColor(AppInfo.color_actionbar_text);
        }
        progressBar.getIndeterminateDrawable().setColorFilter(color, android.graphics.PorterDuff.Mode.SRC_IN);
    }

    public static void stylizeActionMenuItem(MenuItem item_delete) {
        item_delete.getIcon().setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_IN);
    }

    public static void stylize(CircleProgressBar progressBar) {
        stylize(progressBar, false);
    }

    public static void stylize(CircleProgressBar progressBar, boolean applyDefaults) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            if (applyDefaults) {
                progressBar.setBackGroundColor(CContext.getColor(context, android.R.color.white));
                progressBar.setColorFilter(CContext.getColor(context, R.color.colorPrimary), PorterDuff.Mode.SRC_IN);
            } else {
                progressBar.setBackGroundColor(Color.parseColor(AppInfo.color_actionbar_text));
                progressBar.setColorFilter(Color.parseColor(AppInfo.color_theme), PorterDuff.Mode.SRC_IN);
            }
        } else {
            progressBar.setColorSchemeResources(R.color.colorPrimary);
        }
    }

    public static void stylize(ProgressDialog progressDialog) {
        try {
            ProgressBar progressBar = (ProgressBar) progressDialog.findViewById(android.R.id.progress);
            int color = Color.parseColor(AppInfo.color_theme);
            if (Helper.isLightColor(color)) {
                // use actionbar text color, it should not be white.
                color = Color.parseColor(AppInfo.color_actionbar_text);
            }
            progressBar.getIndeterminateDrawable().setColorFilter(color, PorterDuff.Mode.MULTIPLY);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void stylize(RatingBar progressBar) {
        int color = Color.parseColor(AppInfo.color_theme);
        if (Helper.isLightColor(color)) {
            color = Color.parseColor(AppInfo.color_actionbar_text);
        }
        progressBar.getIndeterminateDrawable().setColorFilter(color, android.graphics.PorterDuff.Mode.SRC_IN);
    }

    public static void stylize(SearchView view) {
        view.setBackgroundColor(Color.parseColor(AppInfo.color_theme));
        ImageView img = (ImageView) view.findViewById(android.support.v7.appcompat.R.id.search_mag_icon);
        img.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_IN);
        EditText searchEditText = (EditText) view.findViewById(android.support.v7.appcompat.R.id.search_src_text);
        searchEditText.setTextColor(Color.parseColor(AppInfo.color_actionbar_text));
        searchEditText.setHintTextColor(Color.parseColor(AppInfo.color_actionbar_text));
        //LinearLayout searchPlate = (LinearLayout) view.findViewById(android.support.v7.appcompat.R.id.search_plate);
    }

    public static void stylize(SliderLayout sliderLayout) {
        int selectedColor = Color.parseColor(AppInfo.color_theme);
        if (isLightColor(selectedColor)) {
            selectedColor = Color.parseColor(AppInfo.color_actionbar_text);
        }

        int unselectedColor = new MaterialColorImpl(selectedColor).getColor(Shade.Shade100).getValue();

        ShapeDrawable selected = new ShapeDrawable(new OvalShape());
        selected.setIntrinsicHeight(Helper.DP(6));
        selected.setIntrinsicWidth(Helper.DP(6));
        selected.getPaint().setColor(selectedColor);

        ShapeDrawable unselected = new ShapeDrawable(new OvalShape());
        unselected.setIntrinsicHeight(Helper.DP(6));
        unselected.setIntrinsicWidth(Helper.DP(6));
        unselected.getPaint().setColor(unselectedColor);
        sliderLayout.setIndicatorStyleResource(selected, unselected);
    }

    public static void stylize(ChipCloud chipCloud) {
        chipCloud.setSelectedColor(Color.parseColor(AppInfo.color_theme));
        chipCloud.setUnselectedColor(Color.parseColor(AppInfo.color_theme));
        chipCloud.setSelectedFontColor(Color.parseColor(AppInfo.color_actionbar_text));
        if (AppInfo.color_actionbar_text.equalsIgnoreCase("#ffffff") | AppInfo.color_actionbar_text.equalsIgnoreCase("#fff")) {
            chipCloud.setUnselectedFontColor(Color.parseColor("#eeffffff"));
        } else {
            chipCloud.setUnselectedFontColor(Color.parseColor(AppInfo.color_actionbar_text));
        }
        chipCloud.setMode(ChipCloud.Mode.MULTI);
    }

    public static void stylize(View view) {
        view.setBackgroundColor(Color.parseColor(AppInfo.color_theme));
    }

    public static void stylizeView(View view) {
        view.setBackgroundColor(Color.parseColor(AppInfo.color_theme));
    }

    public static void stylize(BottomNavigationView button) {
        int colorBackground = Color.parseColor(AppInfo.color_bottom_nav_bg);
        int colorSelected = Color.parseColor(AppInfo.color_bottom_nav_selected);
        if (AppInfo.color_bottom_nav_selected.equals(AppInfo.color_bottom_nav_normal)) {
            if (isLightColor(AppInfo.color_bottom_nav_selected)) {
                colorSelected = colorBackground;
            }
            colorSelected = new MaterialColorImpl(colorSelected).getColor(Shade.Shade200).getValue();
        }

        ColorStateList buttonStates = new ColorStateList(
                new int[][]{
                        new int[]{android.R.attr.state_checked},
                        new int[]{android.R.attr.state_pressed},
                        new int[]{-android.R.attr.state_checked},
                },
                new int[]{
                        Color.parseColor(AppInfo.color_bottom_nav_selected),
                        Color.parseColor(AppInfo.color_bottom_nav_normal),
                        colorSelected,
                }
        );
        button.setBackgroundColor(colorBackground);
        button.setItemIconTintList(buttonStates);
        button.setItemTextColor(buttonStates);
    }

    public static void stylize(View view, boolean outline) {
        if (outline) {
            GradientDrawable shape = new GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM, new int[]{Color.WHITE, Color.WHITE});
            shape.setShape(GradientDrawable.RECTANGLE);
            shape.setCornerRadii(new float[]{4, 4, 4, 4, 4, 4, 4, 4});
            shape.setStroke(3, Color.parseColor("#9F9F9F"));
            shape.setGradientType(GradientDrawable.LINEAR_GRADIENT);
            view.setBackground(shape);
        } else {
            stylize(view);
        }
    }

    public static void stylize(ImageView view) {
        if (view != null) {
            view.setColorFilter(Color.parseColor(AppInfo.color_theme), PorterDuff.Mode.SRC_IN);
        }
    }

    public static void stylize(ImageView view, boolean useButtonColor) {
        if (useButtonColor) {
            if (view != null) {
                view.setColorFilter(Color.parseColor(AppInfo.normal_button_color), PorterDuff.Mode.SRC_IN);
            }
        } else {
            stylize(view);
        }
    }

    public static void stylize(FloatingActionButton mFab) {
        mFab.setBackgroundTintList(ColorStateList.valueOf(Color.parseColor(AppInfo.normal_button_color)));
        mFab.setRippleColor(Color.parseColor(AppInfo.normal_button_color));
    }

    public static void stylizeBGIndicator(Drawable drawable) {
        drawable.setColorFilter(Color.parseColor(AppInfo.color_theme_dark), PorterDuff.Mode.SRC_IN);
    }

    public static void stylizeActionBar(ImageView view) {
        view.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_IN);
    }

    public static void stylizeActionBar(TextView textView) {
        textView.setTextColor(Color.parseColor(AppInfo.color_actionbar_text));
    }

    public static void stylizeActionBar(Button button) {
        button.setBackgroundColor(Color.parseColor(AppInfo.color_actionbar_text));
        button.setTextColor(Color.parseColor(AppInfo.color_theme));
    }

    public static void stylizeActionBar(ImageButton button) {
        button.setBackgroundColor(Color.parseColor(AppInfo.color_theme));
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            //vectorButton.setDrawBackgroundTintList(ColorStateList.valueOf(Color.parseColor(AppInfo.normal_button_color)));
            button.setImageTintList(ColorStateList.valueOf(Color.parseColor(AppInfo.color_actionbar_text)));
        } else {
            final Drawable originalDrawable = button.getDrawable();
            final Drawable wrappedDrawable = DrawableCompat.wrap(originalDrawable);
            DrawableCompat.setTint(wrappedDrawable, Color.parseColor(AppInfo.color_actionbar_text));
        }
    }

    public static void stylizeActionText(TextView textView) {
        textView.setBackgroundColor(Color.parseColor(AppInfo.color_theme));
        textView.setTextColor(Color.parseColor(AppInfo.color_actionbar_text));
    }

    public static void stylizeSplashText(TextView textView) {
        textView.setTextColor(Color.parseColor(AppInfo.color_splash_text));
    }

    public static void stylizeRegularPriceText(TextView textView) {
        textView.setTextColor(Color.parseColor(AppInfo.color_regular_price));
    }

    public static void stylizeSalePriceText(TextView textView) {
        textView.setTextColor(Color.parseColor(AppInfo.color_sale_price));
    }

    public static void styleFlat(TextView textView) {
        StateListDrawable stateListDrawable = new StateListDrawable();
        stateListDrawable.addState(new int[]{-android.R.attr.state_enabled}, getShapeRect1());
        stateListDrawable.addState(new int[]{android.R.attr.state_pressed}, getShapeRect2());
        stateListDrawable.addState(new int[]{android.R.attr.state_enabled}, getShapeRect1());
        stateListDrawable.addState(new int[]{android.R.attr.state_first}, getShapeRect1());
        textView.setBackgroundDrawable(stateListDrawable);
        textView.setTextColor(getTxtCommon1());
    }

    public static void stylizeBtnSeparator(View view) {
        view.setBackgroundColor(Color.parseColor(AppInfo.normal_button_color));
    }

    public static void stylize(Button button) {
        float cr = Helper.DP(2);
        GradientDrawable drawableNormal3 = new GradientDrawable();
        drawableNormal3.setShape(GradientDrawable.RECTANGLE);
        drawableNormal3.setCornerRadii(new float[]{cr, cr, cr, cr, cr, cr, cr, cr});
        drawableNormal3.setColor(Color.parseColor(AppInfo.disable_button_color));
        drawableNormal3.setStroke(DP(1), Color.parseColor(AppInfo.disable_button_color));
        InsetDrawable insetDrawableNormal3 = new InsetDrawable(drawableNormal3, DP(6));

        GradientDrawable drawableNormal2 = new GradientDrawable();
        drawableNormal2.setShape(GradientDrawable.RECTANGLE);
        drawableNormal2.setCornerRadii(new float[]{cr, cr, cr, cr, cr, cr, cr, cr});
        drawableNormal2.setColor(getColorShade(AppInfo.normal_button_color, Shade.Shade400));
        drawableNormal2.setStroke(DP(1), Color.parseColor(AppInfo.normal_button_color));
        InsetDrawable insetDrawableNormal2 = new InsetDrawable(drawableNormal2, DP(6));

        GradientDrawable drawableNormal1 = new GradientDrawable();
        drawableNormal1.setShape(GradientDrawable.RECTANGLE);
        drawableNormal1.setCornerRadii(new float[]{cr, cr, cr, cr, cr, cr, cr, cr});
        drawableNormal1.setColor(Color.parseColor(AppInfo.normal_button_color));
        drawableNormal1.setStroke(DP(1), Color.parseColor(AppInfo.normal_button_color));
        InsetDrawable insetDrawableNormal1 = new InsetDrawable(drawableNormal1, DP(6));

        StateListDrawable drawable = new StateListDrawable();
        drawable.addState(new int[]{-android.R.attr.state_enabled}, insetDrawableNormal3);
        drawable.addState(new int[]{android.R.attr.state_pressed}, insetDrawableNormal2);
        drawable.addState(new int[]{android.R.attr.state_enabled}, insetDrawableNormal1);
        drawable.addState(new int[]{android.R.attr.state_first}, insetDrawableNormal1);

        button.setBackgroundDrawable(drawable);
        button.setPaddingRelative(20, 20, 20, 20);
        button.setPadding(20, 20, 20, 20);
        button.setTextColor(getTxtCommon1());
    }

    public static void stylize(Button button, int normalColor, int unPressedColor, int buttonTextColor) {
        float cr = Helper.DP(2);
        GradientDrawable drawableNormal3 = new GradientDrawable();
        drawableNormal3.setShape(GradientDrawable.RECTANGLE);
        drawableNormal3.setCornerRadii(new float[]{cr, cr, cr, cr, cr, cr, cr, cr});
        drawableNormal3.setColor(unPressedColor);
        drawableNormal3.setStroke(DP(1), unPressedColor);
        InsetDrawable insetDrawableNormal3 = new InsetDrawable(drawableNormal3, DP(6));

        GradientDrawable drawableNormal2 = new GradientDrawable();
        drawableNormal2.setShape(GradientDrawable.RECTANGLE);
        drawableNormal2.setCornerRadii(new float[]{cr, cr, cr, cr, cr, cr, cr, cr});
        drawableNormal2.setColor(getPressedColor(normalColor));
        drawableNormal2.setStroke(DP(1), normalColor);
        InsetDrawable insetDrawableNormal2 = new InsetDrawable(drawableNormal2, DP(6));

        GradientDrawable drawableNormal1 = new GradientDrawable();
        drawableNormal1.setShape(GradientDrawable.RECTANGLE);
        drawableNormal1.setCornerRadii(new float[]{cr, cr, cr, cr, cr, cr, cr, cr});
        drawableNormal1.setColor(normalColor);
        drawableNormal1.setStroke(DP(1), normalColor);
        InsetDrawable insetDrawableNormal1 = new InsetDrawable(drawableNormal1, DP(6));

        StateListDrawable drawable = new StateListDrawable();
        drawable.addState(new int[]{-android.R.attr.state_enabled}, insetDrawableNormal3);
        drawable.addState(new int[]{android.R.attr.state_pressed}, insetDrawableNormal2);
        drawable.addState(new int[]{android.R.attr.state_enabled}, insetDrawableNormal1);
        drawable.addState(new int[]{android.R.attr.state_first}, insetDrawableNormal1);

        button.setBackgroundDrawable(drawable);
        button.setPaddingRelative(20, 20, 20, 20);
        button.setPadding(20, 20, 20, 20);
        button.setTextColor(buttonTextColor);
    }

    public static void styleFlat(Button button) {
        StateListDrawable stateListDrawable = new StateListDrawable();
        stateListDrawable.addState(new int[]{-android.R.attr.state_enabled}, getShapeRect1());
        stateListDrawable.addState(new int[]{android.R.attr.state_pressed}, getShapeRect2());
        stateListDrawable.addState(new int[]{android.R.attr.state_enabled}, getShapeRect1());
        stateListDrawable.addState(new int[]{android.R.attr.state_first}, getShapeRect1());
        button.setBackgroundDrawable(stateListDrawable);
        button.setTextColor(getTxtCommon1());
    }

    public static void styleFlatSelected(Button button) {
        int colorNormal = getColorShade(AppInfo.normal_button_color, Shade.Shade300);
        int colorNormalStroke = Color.parseColor(AppInfo.normal_button_color);

        int colorSelected = Color.parseColor(AppInfo.normal_button_color);
        int colorSelectedStroke = Color.parseColor(AppInfo.normal_button_color);

        StateListDrawable stateListDrawable = new StateListDrawable();
        stateListDrawable.addState(new int[]{-android.R.attr.state_enabled}, getShapeRect1(colorNormal, colorNormalStroke));
        stateListDrawable.addState(new int[]{android.R.attr.state_pressed}, getShapeRect2(colorSelected, colorSelectedStroke));
        stateListDrawable.addState(new int[]{android.R.attr.state_enabled}, getShapeRect1(colorNormal, colorNormalStroke));
        stateListDrawable.addState(new int[]{android.R.attr.state_first}, getShapeRect1(colorNormal, colorNormalStroke));
        button.setBackgroundDrawable(stateListDrawable);
        button.setTextColor(getTxtCommon1());
    }

    public static void styleRoundFlat(Button button) {
        StateListDrawable stateListDrawable = new StateListDrawable();
        GradientDrawable drawable3 = new GradientDrawable();
        drawable3.setShape(GradientDrawable.RECTANGLE);
        drawable3.setCornerRadii(new float[]{3, 3, 3, 3, 3, 3, 3, 3});
        drawable3.setColor(Color.parseColor(AppInfo.disable_button_color));
        drawable3.setStroke(DP(1), Color.parseColor(AppInfo.disable_button_color));

        GradientDrawable drawable2 = new GradientDrawable();
        drawable2.setShape(GradientDrawable.RECTANGLE);
        drawable2.setCornerRadii(new float[]{3, 3, 3, 3, 3, 3, 3, 3});
        drawable2.setColor(getColorShade(AppInfo.normal_button_color, Shade.Shade400));
        drawable2.setStroke(DP(1), Color.parseColor(AppInfo.normal_button_color));

        GradientDrawable drawable1 = new GradientDrawable();
        drawable1.setShape(GradientDrawable.RECTANGLE);
        drawable1.setCornerRadii(new float[]{3, 3, 3, 3, 3, 3, 3, 3});
        drawable1.setColor(Color.parseColor(AppInfo.normal_button_color));
        drawable1.setStroke(DP(1), Color.parseColor(AppInfo.normal_button_color));

        InsetDrawable insetDrawable3 = new InsetDrawable(drawable3, DP(1));
        InsetDrawable insetDrawable2 = new InsetDrawable(drawable2, DP(1));
        InsetDrawable insetDrawable1 = new InsetDrawable(drawable1, DP(1));

        stateListDrawable.addState(new int[]{-android.R.attr.state_enabled}, insetDrawable3);
        stateListDrawable.addState(new int[]{android.R.attr.state_pressed}, insetDrawable2);
        stateListDrawable.addState(new int[]{android.R.attr.state_enabled}, insetDrawable1);
        stateListDrawable.addState(new int[]{android.R.attr.state_first}, insetDrawable1);

        button.setBackgroundDrawable(stateListDrawable);
        button.setTextColor(getTxtCommon1());
    }

    public static void styleFlatImageButton(ImageButton button) {
        StateListDrawable stateListDrawable = new StateListDrawable();
        GradientDrawable drawable3 = new GradientDrawable();
        drawable3.setShape(GradientDrawable.RECTANGLE);
        drawable3.setStroke(DP(1), getPressedColor(Color.parseColor(AppInfo.normal_button_color)));
        drawable3.setColor(Color.parseColor(AppInfo.disable_button_color));

        GradientDrawable drawable2 = new GradientDrawable();
        drawable2.setShape(GradientDrawable.RECTANGLE);
        drawable2.setStroke(DP(1), getPressedColor(Color.parseColor(AppInfo.normal_button_color)));
        drawable2.setColor(getPressedColor(Color.parseColor(AppInfo.normal_button_color)));

        GradientDrawable drawable1 = new GradientDrawable();
        drawable1.setShape(GradientDrawable.RECTANGLE);
        drawable1.setStroke(DP(1), getPressedColor(Color.parseColor(AppInfo.normal_button_color)));
        drawable1.setColor(Color.parseColor(AppInfo.normal_button_color));

        stateListDrawable.addState(new int[]{-android.R.attr.state_enabled}, drawable3);
        stateListDrawable.addState(new int[]{android.R.attr.state_pressed}, drawable2);
        stateListDrawable.addState(new int[]{android.R.attr.state_enabled}, drawable1);
        stateListDrawable.addState(new int[]{android.R.attr.state_first}, drawable1);

        button.setBackgroundDrawable(stateListDrawable);
    }

    public static void stylizeFlatEditText(EditText editText) {
        GradientDrawable drawable1 = new GradientDrawable();
        drawable1.setShape(GradientDrawable.RECTANGLE);
        drawable1.setStroke(DP(1), getPressedColor(Color.parseColor(AppInfo.normal_button_color)));
        editText.setBackground(drawable1);
    }

    public static void stylizeRoundButton(Button button, String normalColor, String unPressedColor) {
        GradientDrawable drawableNormal3 = new GradientDrawable();
        drawableNormal3.setCornerRadius(DP(36));
        drawableNormal3.setShape(GradientDrawable.RECTANGLE);
//        drawableNormal3.setCornerRadii(new float[]{20, 20, 20, 20, 20, 20, 20, 20});
        drawableNormal3.setColor(Color.parseColor(unPressedColor));
        drawableNormal3.setStroke(DP(1), Color.parseColor(unPressedColor));
        InsetDrawable insetDrawableNormal3 = new InsetDrawable(drawableNormal3, DP(6));

        GradientDrawable drawableNormal2 = new GradientDrawable();
        drawableNormal2.setCornerRadius(DP(36));
        drawableNormal2.setShape(GradientDrawable.RECTANGLE);
//        drawableNormal2.setCornerRadii(new float[]{20, 20, 20, 20, 20, 20, 20, 20});
        //drawableNormal2.setColor(Color.parseColor(AppInfo.selected_button_color));
        drawableNormal2.setColor(getPressedColor(Color.parseColor(normalColor)));
        drawableNormal2.setStroke(DP(1), Color.parseColor(normalColor));
        InsetDrawable insetDrawableNormal2 = new InsetDrawable(drawableNormal2, DP(6));

        GradientDrawable drawableNormal1 = new GradientDrawable();
        drawableNormal1.setCornerRadius(DP(36));
        drawableNormal1.setShape(GradientDrawable.RECTANGLE);
//        drawableNormal1.setCornerRadii(new float[]{20, 20, 20, 20, 20, 20, 20, 20});
        drawableNormal1.setColor(Color.parseColor(normalColor));
        drawableNormal1.setStroke(DP(1), Color.parseColor(normalColor));
        InsetDrawable insetDrawableNormal1 = new InsetDrawable(drawableNormal1, DP(6));

        StateListDrawable drawable = new StateListDrawable();
        drawable.addState(new int[]{-android.R.attr.state_enabled}, insetDrawableNormal3);
        drawable.addState(new int[]{android.R.attr.state_pressed}, insetDrawableNormal2);
        drawable.addState(new int[]{android.R.attr.state_enabled}, insetDrawableNormal1);
        drawable.addState(new int[]{android.R.attr.state_first}, insetDrawableNormal1);

        button.setBackgroundDrawable(drawable);
        button.setPaddingRelative(48, 24, 48, 24);
        button.setPadding(48, 24, 48, 24);
        button.setTextColor(getTxtCommon1());
    }

    public static void styleRemove(Button button) {
        GradientDrawable drawableNormal = new GradientDrawable();
        drawableNormal.setShape(GradientDrawable.RECTANGLE);
        drawableNormal.setCornerRadii(new float[]{4, 4, 4, 4, 4, 4, 4, 4});
        drawableNormal.setColor(Color.parseColor("#F24F51"));
        drawableNormal.setStroke(3, Color.parseColor("#E46567"));
        InsetDrawable insetDrawableNormal = new InsetDrawable(drawableNormal, 12);

        GradientDrawable drawablePressed = new GradientDrawable();
        drawablePressed.setShape(GradientDrawable.RECTANGLE);
        drawablePressed.setCornerRadii(new float[]{4, 4, 4, 4, 4, 4, 4, 4});
        drawablePressed.setColor(Color.parseColor("#F4676A"));
        drawablePressed.setStroke(3, Color.parseColor("#E46567"));
        InsetDrawable insetDrawablePressed = new InsetDrawable(drawablePressed, 12);

        StateListDrawable drawable = new StateListDrawable();
        drawable.addState(new int[]{-android.R.attr.state_enabled}, insetDrawableNormal);
        drawable.addState(new int[]{android.R.attr.state_pressed}, insetDrawablePressed);
        drawable.addState(new int[]{android.R.attr.state_enabled}, insetDrawableNormal);
        drawable.addState(new int[]{android.R.attr.state_first}, insetDrawableNormal);
        button.setBackgroundDrawable(drawable);
        button.setTextColor(getTxtCommon1());
    }

    public static void styleCancel(Button button) {
        GradientDrawable drawableNormal = new GradientDrawable();
        drawableNormal.setShape(GradientDrawable.RECTANGLE);
        drawableNormal.setCornerRadii(new float[]{4, 4, 4, 4, 4, 4, 4, 4});
        drawableNormal.setColor(Color.parseColor("#C1C2C2"));
        drawableNormal.setStroke(3, Color.parseColor("#D6D7D7"));
        InsetDrawable insetDrawableNormal = new InsetDrawable(drawableNormal, 12);

        GradientDrawable drawablePressed = new GradientDrawable();
        drawablePressed.setShape(GradientDrawable.RECTANGLE);
        drawablePressed.setCornerRadii(new float[]{4, 4, 4, 4, 4, 4, 4, 4});
        drawablePressed.setColor(Color.parseColor("#B7B8B8"));
        drawablePressed.setStroke(3, Color.parseColor("#D6D7D7"));
        InsetDrawable insetDrawablePressed = new InsetDrawable(drawablePressed, 12);

        StateListDrawable drawable = new StateListDrawable();
        drawable.addState(new int[]{-android.R.attr.state_enabled}, insetDrawableNormal);
        drawable.addState(new int[]{android.R.attr.state_pressed}, insetDrawablePressed);
        drawable.addState(new int[]{android.R.attr.state_enabled}, insetDrawableNormal);
        drawable.addState(new int[]{android.R.attr.state_first}, insetDrawableNormal);
        button.setBackgroundDrawable(drawable);

        int[][] states = new int[][]{
                new int[]{-android.R.attr.state_enabled}, // enabled
                new int[]{android.R.attr.state_pressed},  // pressed
                new int[]{android.R.attr.state_enabled},
                new int[]{android.R.attr.state_first}
        };
        int[] colors = new int[]{
                Color.parseColor("#3D3E3E"),
                Color.parseColor("#3D3E3E"),
                Color.parseColor("#3D3E3E"),
                Color.parseColor("#3D3E3E")
        };
        button.setTextColor(new ColorStateList(states, colors));
    }

    public static void stylize(EditText editText) {
        editText.setBackground(getShapeRectForEditText());
    }

    public static void openExternalLink(Context context, String url) {
        try {
            Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
            context.startActivity(intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void stylize(TextInputLayout textInputLayout) {
        try {
            EditText editText = textInputLayout.getEditText();
            int color = Color.parseColor(AppInfo.color_theme);
            if (Helper.isLightColor(color)) {
                // use actionbar text color, it should not be white.
                color = Color.parseColor(AppInfo.color_actionbar_text);
            }
            // Changes color of the bottom line of EditText
            if (editText != null) {
                Field fCursorDrawableRes = TextView.class.getDeclaredField("mCursorDrawableRes");
                fCursorDrawableRes.setAccessible(true);
                int mCursorDrawableRes = fCursorDrawableRes.getInt(editText);
                Field fEditor = TextView.class.getDeclaredField("mEditor");
                fEditor.setAccessible(true);
                Object editor = fEditor.get(editText);
                Class<?> clazz = editor.getClass();
                Field fCursorDrawable = clazz.getDeclaredField("mCursorDrawable");
                fCursorDrawable.setAccessible(true);
                Drawable[] drawables = new Drawable[2];
                drawables[0] = ContextCompat.getDrawable(editText.getContext(), mCursorDrawableRes);
                drawables[1] = ContextCompat.getDrawable(editText.getContext(), mCursorDrawableRes);
                drawables[0].setColorFilter(color, PorterDuff.Mode.SRC_IN);
                drawables[1].setColorFilter(color, PorterDuff.Mode.SRC_IN);
                fCursorDrawable.set(editor, drawables);
                editText.getBackground().mutate().setColorFilter(color, PorterDuff.Mode.SRC_ATOP);
                editText.setHighlightColor(color);
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    editText.getBackground().mutate().setTintList(new ColorStateList(
                            new int[][]{{0, 0, 0, 0}},
                            new int[]{color, color, color, color}));
                }
            }
            Field fFocusedTextColor = TextInputLayout.class.getDeclaredField("mFocusedTextColor");
            fFocusedTextColor.setAccessible(true);
            fFocusedTextColor.set(textInputLayout, new ColorStateList(new int[][]{{0}}, new int[]{color}));
        } catch (Exception ignored) {
        }
    }

    public static void stylize(EditText editText, boolean hasBorder) {
        if (hasBorder) {
            Helper.stylize(editText);
            return;
        }
        try {
            int color = Color.parseColor(AppInfo.color_theme);
            if (Helper.isLightColor(color)) {
                // use actionbar text color, it should not be white.
                color = Color.parseColor(AppInfo.color_actionbar_text);
            }
            // Changes color of the bottom line of EditText
            Field fCursorDrawableRes = TextView.class.getDeclaredField("mCursorDrawableRes");
            fCursorDrawableRes.setAccessible(true);
            int mCursorDrawableRes = fCursorDrawableRes.getInt(editText);
            Field fEditor = TextView.class.getDeclaredField("mEditor");
            fEditor.setAccessible(true);
            Object editor = fEditor.get(editText);
            Class<?> clazz = editor.getClass();
            Field fCursorDrawable = clazz.getDeclaredField("mCursorDrawable");
            fCursorDrawable.setAccessible(true);
            Drawable[] drawables = new Drawable[2];
            drawables[0] = ContextCompat.getDrawable(editText.getContext(), mCursorDrawableRes);
            drawables[1] = ContextCompat.getDrawable(editText.getContext(), mCursorDrawableRes);
            drawables[0].setColorFilter(color, PorterDuff.Mode.SRC_IN);
            drawables[1].setColorFilter(color, PorterDuff.Mode.SRC_IN);
            fCursorDrawable.set(editor, drawables);
            editText.getBackground().mutate().setColorFilter(color, PorterDuff.Mode.SRC_ATOP);
            editText.setHighlightColor(color);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                editText.getBackground().mutate().setTintList(new ColorStateList(
                        new int[][]{{0, 0, 0, 0}},
                        new int[]{color, color, color, color}));
            }
        } catch (Exception ignored) {
        }
    }

    public static void stylize(ToggleButton button) {
        GradientDrawable drawable1 = new GradientDrawable();
        drawable1.setShape(GradientDrawable.RECTANGLE);
        drawable1.setCornerRadii(new float[]{3, 3, 3, 3, 3, 3, 3, 3});
        drawable1.setColor(Color.parseColor(AppInfo.normal_button_color));
        drawable1.setStroke(DP(1), Color.parseColor(AppInfo.normal_button_color));
        InsetDrawable insetDrawable1 = new InsetDrawable(drawable1, DP(1));

        GradientDrawable drawable2 = new GradientDrawable();
        drawable2.setShape(GradientDrawable.RECTANGLE);
        drawable2.setCornerRadii(new float[]{3, 3, 3, 3, 3, 3, 3, 3});
        drawable2.setColor(getPressedColor(Color.parseColor(AppInfo.normal_button_color)));
        drawable2.setStroke(DP(1), getPressedColor(Color.parseColor(AppInfo.normal_button_color)));
        InsetDrawable insetDrawable2 = new InsetDrawable(drawable2, DP(1));

        StateListDrawable stateListDrawable = new StateListDrawable();
        stateListDrawable.addState(new int[]{-android.R.attr.state_checked}, insetDrawable1);
        stateListDrawable.addState(new int[]{android.R.attr.state_checked}, insetDrawable2);

        button.setBackgroundDrawable(stateListDrawable);
        button.setTextColor(getToggleTxtCommon1());
    }

    public static void stylizeThemedText(TextView textView) {
        int color = Color.parseColor(AppInfo.color_theme);
        if (Helper.isLightColor(color)) {
            color = Color.parseColor(AppInfo.color_actionbar_text);
        }
        textView.setTextColor(color);
    }

    public static void stylizeBadgeView(ImageView imageView, TextView textView) {
        int bgColor;
        int strokeColor;
        if (isLightColor(AppInfo.color_theme)) {
            bgColor = Helper.getColorShade(AppInfo.color_theme, Shade.Shade300);
            strokeColor = Color.parseColor(AppInfo.color_actionbar_text);
            textView.setTextColor(Color.parseColor(AppInfo.color_actionbar_text));
        } else {
            //bgColor = Helper.getColorShade(AppInfo.color_actionbar_text, Shade.Shade300);
            bgColor = Color.parseColor(AppInfo.color_actionbar_text);
            strokeColor = Helper.getColorShade(AppInfo.color_theme, Shade.Shade600);
            textView.setTextColor(Color.parseColor(AppInfo.color_theme));
        }

        GradientDrawable drawableNotificationBg = new GradientDrawable();
        drawableNotificationBg.setSize(Helper.DP(18), Helper.DP(18));
        drawableNotificationBg.setShape(GradientDrawable.OVAL);
        drawableNotificationBg.setStroke(Helper.DP(1), strokeColor);
        drawableNotificationBg.setColor(bgColor);
        imageView.setImageDrawable(drawableNotificationBg);
    }

    public static void stylize(CheckBox checkBox) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            checkBox.setButtonTintList(ColorStateList.valueOf(Color.parseColor(AppInfo.normal_button_color)));
        } else {
            //final Drawable originalDrawable = checkBox.getBackground();
            //final Drawable wrappedDrawable = DrawableCompat.wrap(originalDrawable);
            //DrawableCompat.setTint(wrappedDrawable, Color.parseColor(AppInfo.normal_button_color));
        }
    }

    public static void stylize(RadioButton radioButton) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            radioButton.setButtonTintList(ColorStateList.valueOf(Color.parseColor(AppInfo.normal_button_color)));
        } else {
            //aaaaa
            //final Drawable originalDrawable = radioButton.getBackground();
            //final Drawable wrappedDrawable = DrawableCompat.wrap(originalDrawable);
            //DrawableCompat.setTint(wrappedDrawable, Color.parseColor(AppInfo.normal_button_color));
        }
    }

    public static void stylizeDrawble(Drawable drawable) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            drawable.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_ATOP);
        } else {
            //final Drawable wrappedDrawable = DrawableCompat.wrap(drawable);
            //DrawableCompat.setTint(wrappedDrawable, Color.parseColor(AppInfo.normal_button_color));
        }
    }

    public static void stylizeVector(ToggleButton toggleButton) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            toggleButton.setButtonTintList(ColorStateList.valueOf(Color.parseColor(AppInfo.normal_button_color)));
        } else {
            final Drawable originalDrawable = toggleButton.getBackground();
            final Drawable wrappedDrawable = DrawableCompat.wrap(originalDrawable);
            DrawableCompat.setTint(wrappedDrawable, Color.parseColor(AppInfo.normal_button_color));
        }
    }

    public static void stylizeVector(Button vectorButton) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            vectorButton.setBackgroundTintList(ColorStateList.valueOf(Color.parseColor(AppInfo.normal_button_color)));
        } else {
            final Drawable originalDrawable = vectorButton.getBackground();
            final Drawable wrappedDrawable = DrawableCompat.wrap(originalDrawable);
            DrawableCompat.setTint(wrappedDrawable, Color.parseColor(AppInfo.normal_button_color));
        }
    }

    public static void stylizeVector(ImageButton vectorButton) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            vectorButton.setImageTintList(ColorStateList.valueOf(Color.parseColor(AppInfo.normal_button_color)));
        } else {
            final Drawable originalDrawable = vectorButton.getDrawable();
            final Drawable wrappedDrawable = DrawableCompat.wrap(originalDrawable);
            DrawableCompat.setTint(wrappedDrawable, Color.parseColor(AppInfo.normal_button_color));
        }
    }

    public static void stylizeVector(ImageView imageView) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            imageView.setImageTintList(ColorStateList.valueOf(Color.parseColor(AppInfo.normal_button_color)));
        } else {
            final Drawable originalDrawable = imageView.getDrawable();
            final Drawable wrappedDrawable = DrawableCompat.wrap(originalDrawable);
            DrawableCompat.setTint(wrappedDrawable, Color.parseColor(AppInfo.normal_button_color));
        }
    }

    public static void stylize(Drawable drawableCompat) {
        DrawableCompat.setTint(drawableCompat, Color.parseColor(AppInfo.normal_button_color));
    }

    public static void setColorSpan(TextView textView, String text, String subText, int color) {
        textView.setText(text, TextView.BufferType.SPANNABLE);
        Spannable str = (Spannable) textView.getText();
        int start = text.indexOf(subText);
        str.setSpan(new ForegroundColorSpan(color), start, start + subText.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
    }

    public static void initContext(Context c) {
        context = c;
        AnalyticsHelper.initContext(context);
    }

    public static int versionStrToInt(String versionStr) {
        versionStr = versionStr.replaceAll(Pattern.quote("."), "");
        return Integer.parseInt(versionStr);
    }

    public static void setListViewHeightBasedOnChildren(ListView listView) {
        ListAdapter listAdapter = listView.getAdapter();
        if (listAdapter == null)
            return;

        int desiredWidth = MeasureSpec.makeMeasureSpec(listView.getWidth(), MeasureSpec.UNSPECIFIED);
        int totalHeight = 0;
        View view = null;
        for (int i = 0; i < listAdapter.getCount(); i++) {
            view = listAdapter.getView(i, view, listView);
            if (i == 0)
                view.setLayoutParams(new ViewGroup.LayoutParams(desiredWidth, LayoutParams.WRAP_CONTENT));

            view.measure(desiredWidth, MeasureSpec.UNSPECIFIED);
            totalHeight += view.getMeasuredHeight();
            //totalHeight += view.getPaddingTop();
            //totalHeight += view.getPaddingBottom();
        }
        ViewGroup.LayoutParams params = listView.getLayoutParams();
        params.height = totalHeight +
                (listView.getDividerHeight() * (listAdapter.getCount() - 1)) +
                listView.getPaddingTop() +
                listView.getPaddingBottom();
        listView.setLayoutParams(params);
        listView.requestLayout();
    }

    public static void setGridViewHeightBasedOnChildren(GridView gridView, int numColumns) {

        ListAdapter listAdapter = gridView.getAdapter();
        if (listAdapter == null)
            return;
        int desiredWidth = MeasureSpec.makeMeasureSpec(gridView.getWidth(), MeasureSpec.UNSPECIFIED);
        int totalHeight = 0;

        int girdViewVerticalSpacing = 0;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.JELLY_BEAN) {
            girdViewVerticalSpacing = gridView.getVerticalSpacing();
        }

        View view = null;

        //int numColumns = gridView.getNumColumns();
        //int numColumns = getNumColumns(gridView);
        int i = 0;
        while (i < listAdapter.getCount()) {
            int temp_increment = 0;
            view = listAdapter.getView(i, view, gridView);
            view.measure(desiredWidth, MeasureSpec.UNSPECIFIED);
            temp_increment += view.getMeasuredHeight();
            int paddingBottom = view.getPaddingBottom();
            temp_increment += paddingBottom;
            temp_increment += girdViewVerticalSpacing;
            totalHeight += temp_increment;
            i += numColumns;
        }

        ViewGroup.LayoutParams params = gridView.getLayoutParams();
        params.height = totalHeight + gridView.getPaddingTop() + gridView.getPaddingBottom();

        gridView.setLayoutParams(params);
        gridView.requestLayout();
    }

    public static int getNumColumns(GridView gridView) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.HONEYCOMB) {
            return gridView.getNumColumns();
        } else {
            try {
                Field numColumns = gridView.getClass().getSuperclass().getDeclaredField("mNumColumns");
                numColumns.setAccessible(true);
                return numColumns.getInt(gridView);
            } catch (Exception e) {
                return 1;
            }
        }
    }

    public static void setGridViewHeightBasedOnChildren2(GridView gridView, int numColum) {
        ListAdapter listAdapter = gridView.getAdapter();
        if (listAdapter == null)
            return;

        //int desiredWidth = MeasureSpec.makeMeasureSpec(gridView.getWidth(), MeasureSpec.AT_MOST);
        int desiredWidth = MeasureSpec.makeMeasureSpec(gridView.getWidth(), MeasureSpec.UNSPECIFIED);
        int totalHeight = 0;

        //int girdViewHorizontalSpacing = gridView.getHorizontalSpacing();
        int girdViewVerticalSpacing = 0;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.JELLY_BEAN) {
            girdViewVerticalSpacing = gridView.getVerticalSpacing();
        }

        //log("-- item spacing ["+girdViewHorizontalSpacing+","+girdViewVerticalSpacing+"] --");

        View view = null;
        /*
         for (int i = 0; i < listAdapter.getCount(); i+=numColum)
 	    {
 	        view = listAdapter.getView(i, view, gridView);
 	        if (i == 0)
 	            view.setLayoutParams(new ViewGroup.LayoutParams(desiredWidth, LayoutParams.WRAP_CONTENT));

 	        view.measure(desiredWidth, MeasureSpec.UNSPECIFIED);
 	        totalHeight += view.getMeasuredHeight();

	 	    int paddingBottom = view.getPaddingBottom();
	 	    int paddingTop = view.getPaddingTop();
	 	    totalHeight += paddingBottom;
	 	    //totalHeight += paddingTop;
	 	    totalHeight += girdViewVerticalSpacing;

 	        //log("-- item padding [x,x,"+paddingTop+","+paddingBottom+"] --");
 	      // totalHeight += 100;

 	        //ViewGroup.MarginLayoutParams lp = (ViewGroup.MarginLayoutParams) view.getLayoutParams();
 	       	//totalHeight += lp.topMargin;
 	       	//totalHeight += lp.bottomMargin;
 	    }
 	    */

        for (int i = 0; i < listAdapter.getCount(); i += numColum) {
            int increment = 0;
            for (int j = 0; j < numColum; j++) {
                int temp_increment = 0;
                int cellId = i + j;
                if (cellId >= listAdapter.getCount()) {
                    break;
                }

                view = listAdapter.getView(i, view, gridView);
                if (i == 0)
                    view.setLayoutParams(new ViewGroup.LayoutParams(desiredWidth, LayoutParams.WRAP_CONTENT));

                view.measure(desiredWidth, MeasureSpec.UNSPECIFIED);
                temp_increment += view.getMeasuredHeight();

                int paddingBottom = view.getPaddingBottom();
                int paddingTop = view.getPaddingTop();
                temp_increment += paddingBottom;
                //totalHeight += paddingTop;
                temp_increment += girdViewVerticalSpacing;

                //log("-- item padding [x,x,"+paddingTop+","+paddingBottom+"] --");
                // temp_increment += 100;

                //ViewGroup.MarginLayoutParams lp = (ViewGroup.MarginLayoutParams) view.getLayoutParams();
                //temp_increment += lp.topMargin;
                //temp_increment += lp.bottomMargin;

                increment = Math.max(increment, temp_increment);
            }
            totalHeight += increment;
        }

        ViewGroup.LayoutParams params = gridView.getLayoutParams();
        params.height = totalHeight +
                gridView.getPaddingTop() +
                gridView.getPaddingBottom();

        gridView.setLayoutParams(params);
        gridView.requestLayout();
    }

    public static void setGridViewHeightBasedOnChildren(StaggeredGridView gridView, int numColum) {
        ListAdapter listAdapter = gridView.getAdapter();
        if (listAdapter == null)
            return;

        //int desiredWidth = MeasureSpec.makeMeasureSpec(gridView.getWidth(), MeasureSpec.AT_MOST);
        int desiredWidth = MeasureSpec.makeMeasureSpec(gridView.getWidth(), MeasureSpec.UNSPECIFIED);
        int totalHeight = 0;

        //int girdViewHorizontalSpacing = gridView.getHorizontalSpacing();
        int girdViewVerticalSpacing = gridView.getPaddingTop(); //VerticalSpacing();

        //log("-- item spacing ["+girdViewHorizontalSpacing+","+girdViewVerticalSpacing+"] --");

        View view = null;
        for (int i = 0; i < listAdapter.getCount(); i += numColum) {
            view = listAdapter.getView(i, view, gridView);
            if (i == 0)
                view.setLayoutParams(new ViewGroup.LayoutParams(desiredWidth, LayoutParams.WRAP_CONTENT));

            view.measure(desiredWidth, MeasureSpec.UNSPECIFIED);
            totalHeight += view.getMeasuredHeight();

            int paddingBottom = view.getPaddingBottom();
            int paddingTop = view.getPaddingTop();
            totalHeight += paddingBottom;
            //totalHeight += paddingTop;
            totalHeight += girdViewVerticalSpacing;

            //log("-- item padding [x,x,"+paddingTop+","+paddingBottom+"] --");
            // totalHeight += 100;

            //ViewGroup.MarginLayoutParams lp = (ViewGroup.MarginLayoutParams) view.getLayoutParams();
            //totalHeight += lp.topMargin;
            //totalHeight += lp.bottomMargin;
        }
        ViewGroup.LayoutParams params = gridView.getLayoutParams();
        params.height = totalHeight +
                gridView.getPaddingTop() +
                gridView.getPaddingBottom();

        gridView.setLayoutParams(params);
        gridView.requestLayout();
    }

    public static String updateHtmlCurrency(String currecyString) {
        currecyString = currecyString.replace("del", "strike");
        currecyString = currecyString.replace("<ins>", "\n");
        return currecyString;
    }

    public static String appendDiv(String text, int bgColor, int textColor) {
        String bgColorHexStr = String.format("#%06X", (0xFFFFFF & bgColor));
        String textColorHexStr = String.format("#%06X", (0xFFFFFF & textColor));
        //String colorHexStr = "#" + Integer.toHexString(color); //this is also a good idea
        return "<body bgcolor=" + bgColorHexStr + "  text=" + textColorHexStr + " style=\"margin:0;padding:0\">" + text + "</body>";
    }

    public static String appendCurrency(float amount, TM_ProductInfo product) {
        String finalCurrency = appendCurrency(formatCurrency(amount));
        if (product != null) {
            if (AppInfo.SHOW_PRICE_LABELS) {
                if (!TextUtils.isEmpty(product.getPriceLabel())) {
                    finalCurrency = finalCurrency + product.getPriceLabel();
                }
            }
        }
        return finalCurrency;
    }

    public static String appendCurrency(float amount) {
        return appendCurrency(formatCurrency(amount));
    }

    public static String formatCurrency(float amount) {
        StringBuilder precisions = new StringBuilder(amount < 1 ? "0." : ".");
        for (int i = 0; i < TM_CommonInfo.price_num_decimals; i++) {
            precisions.append("0");
        }

        if (precisions.length() == 1) {
            precisions = new StringBuilder("");
        }

        DecimalFormatSymbols dfs = DecimalFormatSymbols.getInstance();
        dfs.setDecimalSeparator(TM_CommonInfo.decimal_separator.trim().charAt(0));
        dfs.setGroupingSeparator(TM_CommonInfo.thousand_separator.trim().charAt(0));
        DecimalFormat df = new DecimalFormat("###,###" + precisions.toString(), dfs);
        return df.format(amount);
    }

    public static String getPlainText(String mHtmlString) {
        return HtmlCompat.fromHtml(mHtmlString).toString();
    }

    public static String appendCurrency(String amount) {
        if (TM_CommonInfo.currency_position.equalsIgnoreCase("left")) {
            return TM_CommonInfo.currency_format + amount;
        } else if (TM_CommonInfo.currency_position.equalsIgnoreCase("left_space")) {
            return TM_CommonInfo.currency_format + " " + amount;
        } else if (TM_CommonInfo.currency_position.equalsIgnoreCase("right")) {
            return amount + TM_CommonInfo.currency_format;
        } else if (TM_CommonInfo.currency_position.equalsIgnoreCase("right_space")) {
            return amount + " " + TM_CommonInfo.currency_format;
        } else {
            return amount + TM_CommonInfo.currency_format;
        }
    }

    public static boolean isNetworkAvailable(Context context) {
        ConnectivityManager connectivityManager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo activeNetworkInfo = connectivityManager.getActiveNetworkInfo();
        return activeNetworkInfo != null && activeNetworkInfo.isConnected();
    }

    // A method to find height of the status bar
    public static int getStatusBarHeight(Context c) {
        int result = 0;
        int resourceId = c.getResources().getIdentifier("status_bar_height", "dimen", "android");
        if (resourceId > 0) {
            result = c.getResources().getDimensionPixelSize(resourceId);
        }
        return result;
    }

    public static boolean isValidString(String text) {
        return (text != null && text.length() > 0);
    }

    public static boolean isValidString(CharSequence text) {
        return (text != null && text.length() > 0);
    }

    public static boolean isValidEmail(String text) {
        return Patterns.EMAIL_ADDRESS.matcher(text).matches();
    }

    public static boolean isValidPhoneNumber(String text) {
        return Patterns.PHONE.matcher(text).matches();
    }

    public static boolean isValidNumber(String text) {
        try {
            Double.parseDouble(text);
        } catch (NumberFormatException ignored) {
            return false;
        }
        return true;
    }

    public static int DP(int measure, Resources res) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, measure, res.getDisplayMetrics());
    }

    public static int DP(int measure) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, measure, context.getResources().getDisplayMetrics());
    }

    public static int PX(int measure, Resources res) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_PX, measure, res.getDisplayMetrics());
    }

    public static int PX(int measure) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_PX, measure, context.getResources().getDisplayMetrics());
    }

    public static int SP(int measure, Resources res) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, measure, res.getDisplayMetrics());
    }

    public static void setTextAppearance(Context context, TextView textView, @StyleRes int resId) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            textView.setTextAppearance(resId);
        } else {
            textView.setTextAppearance(context, resId);
        }
    }

    public static void setTextAppearance(Context context, RadioButton radioButton, @StyleRes int resId) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            radioButton.setTextAppearance(resId);
        } else {
            radioButton.setTextAppearance(context, resId);
        }
    }

    public static void emailTo(final Activity activity, final String address) {
        getConfirmation(
                activity,
                String.format(getString(L.string.write_to_email), address),
                false,
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        email(activity, address);
                    }
                },
                null
        );
    }

    public static void openLocation(Activity activity, float latitude, float longitude) {
        String uri = String.format(Locale.ENGLISH, "geo:%f,%f", latitude, longitude);
        Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(uri));
        activity.startActivity(intent);
    }

    public static void email(Activity activity, String address) {
        try {
            Intent emailIntent = new Intent(Intent.ACTION_SENDTO, Uri.fromParts("mailto", address, null));
            //emailIntent.putExtra(Intent.EXTRA_SUBJECT, "Subject");
            //emailIntent.putExtra(Intent.EXTRA_TEXT, "Body");
            //activity.startActivity(Intent.createChooser(emailIntent, activity.getString(L.string.send_email)));
            activity.startActivity(Intent.createChooser(emailIntent, getString(L.string.send_email)));
        } catch (Exception e) {
            Helper.toast(L.string.some_problem_occurred);
            e.printStackTrace();
        }
    }

    public static void callTo(final Activity activity, final String number) {
        getConfirmation(
                activity,
                String.format(getString(L.string.call_to_number), number),
                false,
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        chkPermissionAndCall(activity, number);
                    }
                },
                null
        );
    }

    public static void getConfirmation(final Activity activity, String message, DialogInterface.OnClickListener onYes) {
        getConfirmation(activity, message, getString(L.string.btn_yes), getString(L.string.btn_no), true, onYes, null);
    }

    public static void getConfirmation(final Activity activity, String message, boolean isCancelable, DialogInterface.OnClickListener onYes, DialogInterface.OnClickListener onNo) {
        getConfirmation(activity, message, getString(L.string.btn_yes), getString(L.string.btn_no), isCancelable, onYes, onNo);
    }

    public static void getConfirmation(final Activity activity, int messageResId, boolean isCancelable, DialogInterface.OnClickListener onYes, DialogInterface.OnClickListener onNo) {
        getConfirmation(activity, activity.getResources().getString(messageResId), getString(L.string.btn_yes), getString(L.string.btn_no), isCancelable, onYes, onNo);
    }

    public static void getConfirmation(final Activity activity, String message, String actionYes, String actionNo, boolean isCancelable, DialogInterface.OnClickListener onYes, DialogInterface.OnClickListener onNo) {
        new AlertDialog.Builder(activity)
                .setMessage(HtmlCompat.fromHtml(message))
                .setCancelable(isCancelable)
                .setPositiveButton(actionYes, onYes)
                .setNegativeButton(actionNo, onNo)
                .show();
    }

    @SuppressWarnings("MissingPermission")
    private static void makeCall(Activity activity, String number) {
        try {
            Intent callIntent = new Intent(Intent.ACTION_CALL);
            callIntent.setData(Uri.parse("tel:" + number));
            activity.startActivity(callIntent);
        } catch (Exception e) {
            Helper.toast(L.string.some_problem_occurred);
            e.printStackTrace();
        }
    }

    private static void chkPermissionAndCall(final Activity activity, final String number) {
        if (!Nammu.checkPermission(Manifest.permission.CALL_PHONE)) {
            Nammu.askForPermission(activity, Manifest.permission.CALL_PHONE, new PermissionCallback() {
                @Override
                public void permissionGranted() {
                    makeCall(activity, number);
                }

                @Override
                public void permissionRefused() {
                }
            });
        } else {
            makeCall(activity, number);
        }
    }

    public static void confirmAndVisitSite(final Activity activity, final String address) {
        getConfirmation(
                activity,
                String.format(getString(L.string.visit_site), address),
                false,
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        visitSite(activity, address);
                    }
                },
                null
        );
    }

    public static void visitSite(Activity activity, String address) {
        try {
            String url = "" + address;
            if (!url.startsWith("http://") && !url.startsWith("https://"))
                url = "http://" + url;
            Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
            activity.startActivity(browserIntent);
        } catch (Exception e) {
            Helper.toast(L.string.some_problem_occurred);
            e.printStackTrace();
        }
    }

    private static void showSnackBar(View view, String str) {
        if (TextUtils.isEmpty(str)) {
            return;
        }

        if (view != null) {
            try {
                Snackbar.make(view, HtmlCompat.fromHtml(str), Snackbar.LENGTH_LONG)
                        .show();
            } catch (Exception e) {
                e.printStackTrace();
                toast(str);
            }
        } else {
            toast(str);
        }
    }

    public static void showErrorToast(String errorText, boolean shortDuration) {
        View view = LayoutInflater.from(context).inflate(R.layout.toast_error_layout, null);
        Toast toast = new Toast(context);
        toast.setDuration(shortDuration ? Toast.LENGTH_SHORT : Toast.LENGTH_LONG);
        toast.setGravity(Gravity.CENTER_VERTICAL, 0, 0);
        toast.setView(view);
        TextView errorTextView = (TextView) view.findViewById(R.id.text_error);
        errorTextView.setText(errorText);
        toast.show();
    }

    public static void showErrorToast(String errorText) {
        showErrorToast(errorText, false);
    }

    public static void showToast(String text) {
        Toast.makeText(context, text, Toast.LENGTH_SHORT).show();
    }

    public static void showToastLong(String text) {
        Toast.makeText(context, text, Toast.LENGTH_LONG).show();
    }

    public static void toast(String key) {
        Toast.makeText(context, getString(key), Toast.LENGTH_SHORT).show();
    }

    public static void showToast(View view, String text) {
        Helper.showSnackBar(view, text);
    }

    public static void toast(View view, String key) {
        Helper.showToast(view, getString(key));
    }

    public static String getAppLink(Context context) {
        final String appPackageName = context.getPackageName(); // getPackageName() from Context or Activity object
        try {
            String EmailID = CustomerData.getInstance().getString("EmailID");
            final String referrer = (EmailID != null && EmailID.length() > 0) ? EmailID : CustomerData.getInstance().getObjectId();
            return "http://play.google.com/store/apps/details?id=" + appPackageName + "&referrer=" + referrer;
        } catch (Exception e) {
            return "http://play.google.com/store/apps/details?id=" + appPackageName;
        }
    }

    public static void gc() {
        new Thread(new Runnable() {
            @Override
            public void run() {
                System.gc();
            }
        }).start();
    }

    public static boolean copyToClipboard(Context context, String text) {
        return Helper.copyToClipboard(context, text, "");
    }

    public static boolean copyToClipboard(Context context, String text, String label) {
        try {
            ClipboardManager clipboard = (ClipboardManager) context.getSystemService(Context.CLIPBOARD_SERVICE);
            clipboard.setPrimaryClip(ClipData.newPlainText(label, text));
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public static void hideKeyboard(View view) {
        if (view != null) {
            InputMethodManager inputMethodManager = (InputMethodManager) view.getContext().getSystemService(Activity.INPUT_METHOD_SERVICE);
            inputMethodManager.hideSoftInputFromWindow(view.getWindowToken(), InputMethodManager.RESULT_UNCHANGED_SHOWN);
        }
    }

    public static Uri getBitmapUri(Context context, Bitmap bitmap) {
        Uri uri = null;
        if (bitmap != null) {
            try {
                ContentValues values = new ContentValues();
                values.put(MediaStore.Images.Media.TITLE, "product_" + System.currentTimeMillis());
                values.put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg");
                uri = context.getContentResolver().insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values);
                if (uri != null) {
                    OutputStream os = context.getContentResolver().openOutputStream(uri);
                    bitmap.compress(Bitmap.CompressFormat.JPEG, 100, os);
                    if (os != null) {
                        os.close();
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return uri;
    }

    public static Uri getBitmapURI(Context context, Bitmap bitmap) {
        Uri uri = null;
        try {
            File file = new File(context.getExternalCacheDir(), System.currentTimeMillis() + ".jpeg");
            FileOutputStream fos = new FileOutputStream(file);
            bitmap.compress(Bitmap.CompressFormat.JPEG, 100, fos);
            fos.flush();
            fos.close();
            uri = FileProvider.getUriForFile(context, context.getString(R.string.file_provider_authority), file);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return uri;
    }

    public static boolean hasWhatsApp(Context context) {
        try {
            context.getPackageManager().getApplicationInfo("com.whatsapp", 0);
            return true;
        } catch (PackageManager.NameNotFoundException e) {
            return false;
        }
    }

    public static void POPUP(Context context, String title, String msg, final boolean dismissAction, final View.OnClickListener listener) {
        final Dialog dialog = new Dialog(context);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setCancelable(false);
        dialog.setContentView(R.layout.dialog_common);

        final View coordinatorLayout = dialog.findViewById(R.id.coordinatorLayout);

        Helper.stylizeView(dialog.findViewById(R.id.header_box));

        TextView header_msg = (TextView) dialog.findViewById(R.id.header_msg);
        header_msg.setText(HtmlCompat.fromHtml(title));
        Helper.stylizeActionBar(header_msg);

        TextView text = (TextView) dialog.findViewById(R.id.txt_msg);
        text.setText(HtmlCompat.fromHtml(msg));

        Button btn_action = (Button) dialog.findViewById(R.id.btn_action);
        Helper.stylize(btn_action);

        btn_action.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(final View v) {
                if (dismissAction)
                    dialog.dismiss();
                if (listener != null) {
                    listener.onClick(v);
                }
            }
        });

        dialog.show();
        dialog.setOnShowListener(new DialogInterface.OnShowListener() {
            @Override
            public void onShow(DialogInterface dialog) {
                new SlideInAnimation(coordinatorLayout).setDirection(Animation.DIRECTION_DOWN).animate();
            }
        });
    }

    public static void shareWithFriends(String s) {
        Intent intent = new Intent();
        intent.setAction(Intent.ACTION_SEND);
        intent.setType("text/plain");
        intent.putExtra(Intent.EXTRA_TEXT, s);
        context.startActivity(Intent.createChooser(intent, getString(L.string.share_via)));
    }

    public static boolean listCompare(List list1, List list2) {
        if (list1 == null || list2 == null) {
            return (list2 == list1);
        }
        if (list1.size() != list2.size()) {
            return false;
        }
        for (Object o1 : list1) {
            if (list2.indexOf(o1) < 0)
                return false;
        }
        return true;
    }

    public static void cleanPreLoadedProducts() {
        TM_CategoryInfo.init();
        TM_ProductInfo.removeAll();
        TM_PaymentGateway.clearAll();
        AppInfo.basic_content_loading = false;
        AppInfo.basic_content_loaded = false;
    }

    public static void rateMyApp() {
        try {
            context.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(getPlayStoreUri())));
        } catch (ActivityNotFoundException e) {
            context.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(getPlayStoreUrl())));
        }
    }

    public static String getApplicationName() {
        int stringId = context.getApplicationInfo().labelRes;
        return context.getString(stringId);
    }

    public static String getWishListNote() {
        String data = "";
        int index = 1;
        for (Wishlist w : Wishlist.getAll()) {
            data += "[" + index++ + "] id:[" + w.product_id + "] note:[" + w.note + "]\n";
        }
        return data;
    }

    public static View getDownloadPanel(ViewGroup parent, final View.OnClickListener selectClickListener, final View.OnClickListener selectchoiceClickListener) {
        LinearLayout downloadPanel = (LinearLayout) View.inflate(context, R.layout.layout_download_panel, null);
        downloadPanel.setBackground(context.getResources().getDrawable(R.drawable.bottom_border_layout_white));
        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.addRule(RelativeLayout.ALIGN_PARENT_TOP);
        parent.addView(downloadPanel, params);

        TextView textSelect = (TextView) downloadPanel.findViewById(R.id.textselect);
        textSelect.setTextColor(Color.parseColor(AppInfo.color_theme));
        textSelect.setText(getString(L.string.actions));
        textSelect.setVisibility(View.GONE);
        textSelect.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                selectClickListener.onClick(view);
            }
        });

        Button btnSelect = (Button) downloadPanel.findViewById(R.id.button_select);
        Helper.stylize(btnSelect);
        btnSelect.setText(getString(L.string.select_multiple));
        btnSelect.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                selectClickListener.onClick(view);
            }
        });

        Button textSelectChoice = (Button) downloadPanel.findViewById(R.id.buttonSelectChoice);
        Helper.stylize(textSelectChoice);
        textSelectChoice.setText(getString(L.string.select_choice));
        textSelectChoice.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                selectchoiceClickListener.onClick(view);
            }
        });

        if (AppInfo.ENABLE_SINGLE_CHECK_WISHLIST) {
            btnSelect.setVisibility(View.GONE);
            textSelect.setVisibility(View.VISIBLE);
        }
        return downloadPanel;
    }

    public static void openDownloadsFolder(Context activity) {
        String appName = Helper.getApplicationName();
        String path = Environment.getExternalStorageDirectory().getPath() + "/" + appName;
        Uri selectedUri = Uri.parse(path);
        Intent intent = new Intent(Intent.ACTION_GET_CONTENT);
        intent.setDataAndType(selectedUri, "resource/folder");

        if (intent.resolveActivity(activity.getPackageManager()) != null) {
            activity.startActivity(intent);
        } else {

            intent.setType("file/*");
            if (intent.resolveActivity(activity.getPackageManager()) != null) {
                activity.startActivity(intent);
            } else {
                showToast(getString(L.string.error_no_app_to_open_folder));
            }
        }
    }

    public static void openCallDialog(Activity activity, List<String> listContactNo){

        AlertDialog.Builder builder = new AlertDialog.Builder(activity);
        final PhoneNumberAdapter adapter = new PhoneNumberAdapter(listContactNo);
        builder.setTitle(getString(L.string.pick_number)).setAdapter(adapter, (dialogInterface, i) -> {
            String phoneNumber = (String) adapter.getItem(i);
            Helper.callTo(activity, phoneNumber);
            dialogInterface.dismiss();
        });
        builder.create().show();
    }

    public static void showSelectMultipleMenu(View parent, boolean showDelete,
                                              final View.OnClickListener downloadClickListener,
                                              final View.OnClickListener addToListClickListener,
                                              final View.OnClickListener addToCartClickListener,
                                              final View.OnClickListener addToSingleWishListClickListener,
                                              final View.OnClickListener deleteClickListener,
                                              final View.OnClickListener shareClickListener) {
        final int ID_MENU_DOWNLOAD = 101;
        final int ID_MENU_ADD_TO_LIST = 102;
        final int ID_MENU_ADD_TO_CART = 103;
        final int ID_MENU_ADD_TO_SINGLE_LIST = 104;
        final int ID_MENU_MULTI_DELETE = 105;
        final int ID_MENU_SHARE = 106;

        PopupMenu popup = new PopupMenu(parent.getContext(), parent);
        if (ImageDownloaderConfig.isEnabled())
            popup.getMenu().add(0, ID_MENU_DOWNLOAD, 0, getString(L.string.download));

        if (AppInfo.ENABLE_MULTIPLE_WISHLIST)
            popup.getMenu().add(0, ID_MENU_ADD_TO_LIST, 0, getString(L.string.add_to_mlultiple_wishlist));

        if (AppInfo.ENABLE_SINGLE_CHECK_WISHLIST)
            popup.getMenu().add(0, ID_MENU_ADD_TO_SINGLE_LIST, 0, getString(L.string.add_to_wishlist));

        if (AppInfo.ENABLE_CART && AppInfo.mGuestUserConfig != null && GuestUserConfig.isEnableCart())
            popup.getMenu().add(0, ID_MENU_ADD_TO_CART, 0, getString(L.string.add_to_cart));

        if (AppInfo.ENABLE_MULTIPLE_WISHLIST && AppInfo.mImageDownloaderConfig != null && AppInfo.mImageDownloaderConfig.isShare())
            popup.getMenu().add(0, ID_MENU_SHARE, 0, getString(L.string.share));

        if (showDelete && AppInfo.ENABLE_MULTIPLE_DELETE)
            popup.getMenu().add(0, ID_MENU_MULTI_DELETE, 0, getString(L.string.delete));

        popup.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
            @Override
            public boolean onMenuItemClick(MenuItem item) {
                int id = item.getItemId();
                if (id == ID_MENU_DOWNLOAD) {
                    downloadClickListener.onClick(null);
                } else if (id == ID_MENU_ADD_TO_LIST) {
                    addToListClickListener.onClick(null);
                } else if (id == ID_MENU_ADD_TO_CART) {
                    addToCartClickListener.onClick(null);
                } else if (id == ID_MENU_ADD_TO_SINGLE_LIST) {
                    addToSingleWishListClickListener.onClick(null);
                } else if (id == ID_MENU_MULTI_DELETE) {
                    deleteClickListener.onClick(null);
                } else if (id == ID_MENU_SHARE) {
                    shareClickListener.onClick(null);
                }
                return false;
            }
        });
        popup.getMenuInflater().inflate(R.menu.menu_empty, popup.getMenu());
        popup.show();
    }

    public static void hideSelectMultipleActionButtons(ViewGroup parent) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Helper.isFTBMenuOpen = false;

            parent.findViewById(R.id.item_img_download).setVisibility(View.GONE);
            FloatingActionButton btn_download = ((FloatingActionButton) parent.findViewById(R.id.btn_img_download));
            btn_download.setVisibility(View.GONE);

            parent.findViewById(R.id.item_add_multiple_list).setVisibility(View.GONE);
            FloatingActionButton btn_add_multiple_list = ((FloatingActionButton) parent.findViewById(R.id.btn_add_multiple_list));
            btn_add_multiple_list.setVisibility(View.GONE);


            parent.findViewById(R.id.item_img_add_single_list).setVisibility(View.GONE);
            FloatingActionButton btn_add_single_list = ((FloatingActionButton) parent.findViewById(R.id.btn_add_single_list));
            btn_add_single_list.setVisibility(View.GONE);

            parent.findViewById(R.id.item_add_to_cart).setVisibility(View.GONE);
            FloatingActionButton btn_add_to_cart = ((FloatingActionButton) parent.findViewById(R.id.btn_add_to_cart));
            btn_add_to_cart.setVisibility(View.GONE);


            parent.findViewById(R.id.item_share).setVisibility(View.GONE);
            FloatingActionButton btn_share = ((FloatingActionButton) parent.findViewById(R.id.btn_share));
            btn_share.setVisibility(View.GONE);


            parent.findViewById(R.id.item_delete).setVisibility(View.GONE);
            FloatingActionButton btn_delete = ((FloatingActionButton) parent.findViewById(R.id.btn_delete));
            btn_delete.setVisibility(View.GONE);
        }
    }

    public static void showSelectMultipleActionButtons(ViewGroup parent, boolean bshowDelete, final View.OnClickListener downloadClickListener, final View.OnClickListener addtolistClickListener, final View.OnClickListener addtocartClickListener, final View.OnClickListener addtoSingleWishListClickListener, final View.OnClickListener deleteClickListener, final View.OnClickListener shareClickListener) {
        android.view.animation.Animation fab_open = new AlphaAnimation(0, 1);
        fab_open.setInterpolator(new DecelerateInterpolator()); //add this
        fab_open.setDuration(300);

        android.view.animation.Animation fab_close = new AlphaAnimation(1, 0);
        fab_close.setInterpolator(new AccelerateInterpolator()); //and this
        fab_close.setDuration(300);

        parent.findViewById(R.id.item_img_download).setVisibility(View.GONE);
        FloatingActionButton btn_download = ((FloatingActionButton) parent.findViewById(R.id.btn_img_download));
        btn_download.setVisibility(View.GONE);
        Helper.stylize(btn_download);
        btn_download.setAnimation(fab_close);
        btn_download.setClickable(false);
        btn_download.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_IN);
        btn_download.setOnClickListener(downloadClickListener);
        parent.findViewById(R.id.ftb_text_download).setOnClickListener(downloadClickListener);
        ((TextView) parent.findViewById(R.id.ftb_text_download)).setText(L.getString(L.string.download_selected));

        parent.findViewById(R.id.item_add_multiple_list).setVisibility(View.GONE);
        FloatingActionButton btn_add_multiple_list = ((FloatingActionButton) parent.findViewById(R.id.btn_add_multiple_list));
        btn_add_multiple_list.setVisibility(View.GONE);
        Helper.stylize(btn_add_multiple_list);
        btn_add_multiple_list.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_IN);
        btn_add_multiple_list.setAnimation(fab_close);
        btn_add_multiple_list.setClickable(false);
        btn_add_multiple_list.setOnClickListener(addtolistClickListener);
        parent.findViewById(R.id.ftb_text_add_multiple_list).setOnClickListener(addtolistClickListener);
        ((TextView) parent.findViewById(R.id.ftb_text_add_multiple_list)).setText(L.getString(L.string.add_to_mlultiple_wishlist));

        parent.findViewById(R.id.item_img_add_single_list).setVisibility(View.GONE);
        FloatingActionButton btn_add_single_list = ((FloatingActionButton) parent.findViewById(R.id.btn_add_single_list));
        Helper.stylize(btn_add_single_list);
        btn_add_single_list.setVisibility(View.GONE);
        btn_add_single_list.setAnimation(fab_close);
        btn_add_single_list.setClickable(false);
        btn_add_single_list.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_IN);
        btn_add_single_list.setOnClickListener(addtoSingleWishListClickListener);
        parent.findViewById(R.id.ftb_text_add_single_list).setOnClickListener(addtoSingleWishListClickListener);
        ((TextView) parent.findViewById(R.id.ftb_text_add_single_list)).setText(L.getString(L.string.add_to_wishlist));

        parent.findViewById(R.id.item_add_to_cart).setVisibility(View.GONE);
        FloatingActionButton btn_add_to_cart = ((FloatingActionButton) parent.findViewById(R.id.btn_add_to_cart));
        Helper.stylize(btn_add_to_cart);
        btn_add_to_cart.setVisibility(View.GONE);
        btn_add_to_cart.setAnimation(fab_close);
        btn_add_to_cart.setClickable(false);
        btn_add_to_cart.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_IN);
        btn_add_to_cart.setOnClickListener(addtocartClickListener);
        parent.findViewById(R.id.ftb_text_add_to_cart).setOnClickListener(addtocartClickListener);
        ((TextView) parent.findViewById(R.id.ftb_text_add_to_cart)).setText(L.getString(L.string.add_to_cart));

        parent.findViewById(R.id.item_share).setVisibility(View.GONE);
        FloatingActionButton btn_share = ((FloatingActionButton) parent.findViewById(R.id.btn_share));
        Helper.stylize(btn_share);
        btn_share.setVisibility(View.GONE);
        btn_share.setAnimation(fab_close);
        btn_share.setClickable(false);
        btn_share.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_IN);
        btn_share.setOnClickListener(shareClickListener);
        parent.findViewById(R.id.ftb_text_share).setOnClickListener(shareClickListener);
        ((TextView) parent.findViewById(R.id.ftb_text_share)).setText(L.getString(L.string.share));

        parent.findViewById(R.id.item_delete).setVisibility(View.GONE);
        FloatingActionButton btn_delete = ((FloatingActionButton) parent.findViewById(R.id.btn_delete));
        Helper.stylize(btn_delete);
        btn_delete.setVisibility(View.GONE);
        btn_delete.setAnimation(fab_close);
        btn_delete.setClickable(false);
        btn_delete.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_IN);
        btn_delete.setOnClickListener(deleteClickListener);
        parent.findViewById(R.id.ftb_text_delete).setOnClickListener(deleteClickListener);
        ((TextView) parent.findViewById(R.id.ftb_text_delete)).setText(L.getString(L.string.delete));

        if (isFTBMenuOpen) {
            isFTBMenuOpen = false;
            return;
        }

        if (ImageDownloaderConfig.isEnabled()) {
            btn_download.setVisibility(View.VISIBLE);
            Helper.stylize(btn_download);
            btn_download.setClickable(true);
            btn_download.setAnimation(fab_open);
            (parent.findViewById(R.id.item_img_download)).setVisibility(View.VISIBLE);
        }

        if (AppInfo.ENABLE_MULTIPLE_WISHLIST) {
            btn_add_multiple_list.setVisibility(View.VISIBLE);
            Helper.stylize(btn_add_multiple_list);
            btn_add_multiple_list.setClickable(true);
            btn_add_multiple_list.setAnimation(fab_open);
            (parent.findViewById(R.id.item_add_multiple_list)).setVisibility(View.VISIBLE);
        }

        if (AppInfo.ENABLE_SINGLE_CHECK_WISHLIST) {
            btn_add_single_list.setVisibility(View.VISIBLE);
            Helper.stylize(btn_add_single_list);
            btn_add_single_list.setClickable(true);
            btn_add_single_list.setAnimation(fab_open);
            (parent.findViewById(R.id.item_img_add_single_list)).setVisibility(View.VISIBLE);
        }

        if (AppInfo.ENABLE_CART && AppInfo.mGuestUserConfig != null && GuestUserConfig.isEnableCart()) {
            btn_add_to_cart.setVisibility(View.VISIBLE);
            Helper.stylize(btn_add_to_cart);
            btn_add_to_cart.setClickable(true);
            btn_add_to_cart.setAnimation(fab_open);
            (parent.findViewById(R.id.item_add_to_cart)).setVisibility(View.VISIBLE);
        }

        if (AppInfo.ENABLE_MULTIPLE_WISHLIST && AppInfo.mImageDownloaderConfig != null && AppInfo.mImageDownloaderConfig.isShare()) {
            btn_share.setVisibility(View.VISIBLE);
            Helper.stylize(btn_share);
            btn_share.setClickable(true);
            btn_share.setAnimation(fab_open);
            (parent.findViewById(R.id.item_share)).setVisibility(View.VISIBLE);
        }

        if (bshowDelete && AppInfo.ENABLE_MULTIPLE_DELETE) {
            btn_delete.setVisibility(View.VISIBLE);
            Helper.stylize(btn_delete);
            btn_delete.setClickable(true);
            btn_delete.setAnimation(fab_open);
            (parent.findViewById(R.id.item_delete)).setVisibility(View.VISIBLE);
        }
        isFTBMenuOpen = true;
    }

    public static String changeLine(String msg) {
        return msg.compareTo("") == 0 ? "" : msg + "\n\n";
    }

    public static void showAlertDialog(String title, String message, String buttontext, boolean issCancelable, final View.OnLongClickListener listner) {
        if (!((Activity) context).isFinishing()) {
            android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(context);
            builder.setTitle(title);
            builder.setMessage(message);
            builder.setCancelable(issCancelable);
            builder.setPositiveButton(buttontext, new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int id) {
                    listner.onLongClick(null);
                }
            });
            builder.create().show();
        }
    }

    public static int randInt(int min, int max) {
        Random rand = new Random();
        return rand.nextInt((max - min) + 1) + min;
    }

    public static String getTotalWishListCount() {
        if (Wishlist.allWishlistItems.size() > 0)
            return getString(L.string.menu_title_wishlist) + " " + "(" + Wishlist.allWishlistItems.size() + ")";
        return getString(L.string.menu_title_wishlist);
    }

    public static void saveGuestOrder(Context context, int orderId) {
        SharedPreferences sp = PreferenceManager.getDefaultSharedPreferences(context);
        String str = sp.getString(Constants.GUEST_ORDER_ID, "");
        if (str.equals("")) {
            str = "[" + orderId + "]";
        } else {
            str = str.split(Pattern.quote("]"))[0];
            str = str + "," + orderId + "]";
        }
        sp.edit().putString(Constants.GUEST_ORDER_ID, str).apply();
    }

    public static String showItemAddedToWishListToast(WishListGroup obj) {

        String str = getString(L.string.item_added_to_wishlist);
        if (obj != null)
            str += ": " + obj.title;

        return str;
    }

    public static String getProductPermalink(TM_ProductInfo product) {
        StringBuilder link = new StringBuilder();

        if (Helper.isValidString(AppInfo.PRODUCT_DEEPLINK_URL)) {
            link.append(AppInfo.PRODUCT_DEEPLINK_URL);
        } else if (Helper.isValidString(product.permalink)) {
            link.append(product.permalink);
        } else {
            link.append(DataEngine.getDataEngine().getBaseURL());
        }

        char lastChar = link.charAt(link.length() - 1);
        link.append(lastChar != '?' ? "?pid=" : "&pid=");
        link.append(product.id);

        return link.toString();
    }

    public static String showItemRemovedToWishListToast(String title) {
        String str = getString(L.string.item_removed_from_wishlist);
        if (isValidString(title))
            str += ": " + title;

        return str;
    }

    public static Spannable getThemedString(String str, String color) {
        Spannable spannable = new SpannableString(str);
        ForegroundColorSpan colorSpan = new ForegroundColorSpan(Color.parseColor(color));
        spannable.setSpan(colorSpan, 0, str.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        return spannable;
    }

    public static void openPlayStorePage(Context context) {
        try {
            context.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(getPlayStoreUri())));
        } catch (Exception e) {
            context.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(getPlayStoreUrl())));
        }
    }

    public static boolean hasLocationAccess(Context context) {
        LocationManager locationManager = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
        Criteria criteria = new Criteria();
        criteria.setPowerRequirement(Criteria.POWER_LOW);
        String bestProvider = locationManager.getBestProvider(criteria, false);
        return bestProvider != null;
    }

    public static String stringFromList(final List<String> strings) {
        String output = "";
        for (String string : strings) {
            output += string + ", ";
        }
        if (output.length() > 2) {
            output = output.substring(0, output.length() - 2);
        }
        return output;
    }

    public static Bitmap base64ToBitmap(String base64) {
        byte[] bytes = Base64.decode(base64, Base64.DEFAULT);
        return BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
    }

    public static String bitmapToBase64(Bitmap bitmap) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, baos);
        return Base64.encodeToString(baos.toByteArray(), Base64.DEFAULT);
    }

    public static ArrayList<Uri> getImageUriList(Context context, HashMap<Integer, Boolean> mCheckedItem) {
        final ArrayList<Uri> uriList = new ArrayList<>();
        for (Map.Entry<Integer, Boolean> entry : mCheckedItem.entrySet()) {
            TM_ProductInfo product = TM_ProductInfo.getProductWithId(entry.getKey());
            if (product != null && entry.getValue()) {
                for (String imgUrl : product.getImageUrls()) {
                    try {
                        URL url = new URL(imgUrl);
                        uriList.add(Helper.getBitmapURI(context, BitmapFactory.decodeStream(url.openConnection().getInputStream())));
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        }
        return uriList;
    }

    public static DisplayMetrics getDisplayMetrics(Activity activity) {
        WindowManager windowManager = (WindowManager) activity.getSystemService(Context.WINDOW_SERVICE);
        Display display = windowManager.getDefaultDisplay();
        DisplayMetrics displayMetrics = new DisplayMetrics();
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN_MR1) {
            display.getMetrics(displayMetrics);
        } else {
            display.getRealMetrics(displayMetrics);
        }
        return displayMetrics;
    }

    public static Point getDisplaySize(Activity activity) {
        Display display = activity.getWindowManager().getDefaultDisplay();
        Point size = new Point();
        display.getSize(size);
        return size;
    }

    public static int getPressedColor(int color) {
        float[] hsv = new float[3];
        Color.colorToHSV(color, hsv);
        hsv[2] *= 0.90f;
        return Color.HSVToColor(hsv);
    }

    public static int getColorShade(String hexColor, Shade shade) {
        return getColorShade(Color.parseColor(hexColor), shade);
    }

    public static int getColorShade(int color, Shade shade) {
        MaterialColor mainColor = new MaterialColorImpl(color);
        return mainColor.getColor(shade).getValue();
    }

    public static void setStyleWithDrawables(CompoundButton button, int resourceNormal, int resourceSelected) {
        Drawable drawable1, drawable2;
        try {
            drawable1 = CContext.getVectorDrawable(button.getContext(), resourceNormal).mutate();
        } catch (Exception ignored) {
            drawable1 = CContext.getDrawable(button.getContext(), resourceNormal).mutate();
        }

        try {
            drawable2 = CContext.getVectorDrawable(button.getContext(), resourceSelected).mutate();
        } catch (Exception ignored) {
            drawable2 = CContext.getDrawable(button.getContext(), resourceSelected).mutate();
        }

        StateListDrawable stateList = new StateListDrawable();
        stateList.addState(new int[]{-android.R.attr.state_checked}, drawable1);
        stateList.addState(new int[]{android.R.attr.state_checked}, drawable2);
        stateList.addState(new int[]{-android.R.attr.state_pressed}, drawable2);
        button.setButtonDrawable(stateList);
    }

    public static void setStyleWithDrawables(CompoundButton button, int resourceNormal, int resourceSelected, int resColorNormal) {
        setStyleWithDrawables(button, resourceNormal, resourceSelected, resColorNormal, resColorNormal);
    }

    public static void setStyleWithDrawables(CompoundButton button, int resourceNormal, int resourceSelected, int resColorNormal, int resColorSelected) {
        int colorNormal = CContext.getColor(context, resColorNormal);
        int colorSelected = CContext.getColor(context, resColorSelected);

        Drawable drawable1, drawable2;
        try {
            drawable1 = CContext.getVectorDrawable(button.getContext(), resourceNormal).mutate();
        } catch (Exception ignored) {
            drawable1 = CContext.getDrawable(button.getContext(), resourceNormal).mutate();
        }
        drawable1.setColorFilter(colorNormal, PorterDuff.Mode.SRC_ATOP);

        try {
            drawable2 = CContext.getVectorDrawable(button.getContext(), resourceSelected).mutate();
        } catch (Exception ignored) {
            drawable2 = CContext.getDrawable(button.getContext(), resourceSelected);
        }
        drawable2.setColorFilter(colorSelected, PorterDuff.Mode.SRC_ATOP);

        InsetDrawable insetDrawable1 = new InsetDrawable(drawable1, DP(3));
        InsetDrawable insetDrawable2 = new InsetDrawable(drawable2, DP(3));

        StateListDrawable stateList = new StateListDrawable();
        stateList.addState(new int[]{-android.R.attr.state_checked}, insetDrawable1);
        stateList.addState(new int[]{android.R.attr.state_checked}, insetDrawable2);

        button.setButtonDrawable(stateList);
    }

    /* Stylize Options Menu Overflow Icon in Toolbar */
    public static void stylizeOverflowIcon(Toolbar toolbar) {
        Drawable drawable = toolbar.getOverflowIcon();
        if (drawable != null) {
            int tint = Color.parseColor(AppInfo.color_actionbar_text);
            drawable = DrawableCompat.wrap(drawable);
            DrawableCompat.setTint(drawable.mutate(), tint);
            toolbar.setOverflowIcon(drawable);
        }
    }

    public static void stylizeEdit(EditText editText) {
    }

    public static boolean isTabletUI(Context context) {
        int screenLayoutSize = context.getResources().getConfiguration().screenLayout & Configuration.SCREENLAYOUT_SIZE_MASK;
        return (screenLayoutSize == Configuration.SCREENLAYOUT_SIZE_LARGE || screenLayoutSize == Configuration.SCREENLAYOUT_SIZE_XLARGE);
    }

    public static int getCategoryLayoutColumns() {
        switch (AppInfo.ID_LAYOUT_CATEGORIES) {
            case 0:
                return 2;
            default:
                return 1;
        }
    }

    public static long getDaysDifference(Date date) {
        long difference = new Date().getTime() - date.getTime();
        return difference / 86400000;
    }

    public static long getDaysDifference(Date startDate, Date endDate) {
        long difference = endDate.getTime() - startDate.getTime();
        return difference / 86400000;
    }

    public static String getPlayStoreUri() {
        String packageName = BuildConfig.DEBUG ? "com.tmstore.tmstoredemo" : context.getPackageName();
        return "market://details?id=" + packageName;
    }

    public static String getPlayStoreUrl() {
        String packageName = BuildConfig.DEBUG ? "com.tmstore.tmstoredemo" : context.getPackageName();
        return "http://play.google.com/store/apps/details?id=" + packageName;
    }

    public static void openPromotionUrl(Context context) {
        String url = AppInfo.PROMO_URL;
        if (!url.startsWith("http://") && !url.startsWith("https://")) {
            url = "http://" + url;
        }
        try {
            context.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse(url)));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static String convertMeterToMiles(long value) {
        return String.valueOf((int) (value / 1609.344)); // **1609.344 is meter in one mile
    }

    public static String convertMeterToKms(long value) {
        return String.valueOf((int) (value / 1000)); // **1000 is meter in one Km
    }

    public static Drawable getTransparentRoundBackground(String strokeColor) {
        GradientDrawable drawable = new GradientDrawable();
        drawable.setShape(GradientDrawable.OVAL);
        drawable.setColor(Color.parseColor("#00ffffff"));
        strokeColor = Helper.isLightColor(strokeColor)
                ? AppInfo.color_actionbar_text
                : AppInfo.color_theme;
        drawable.setStroke(Helper.DP(2), Color.parseColor(strokeColor));
        return drawable;
    }

    public static boolean isLightColor(String color) {
        return isLightColor(Color.parseColor(color));
    }

    public static boolean isLightColor(int color) {
        int k = 200;
        return (Color.red(color) >= k && Color.green(color) >= k && Color.blue(color) >= k);
    }

    public static boolean isDarkColor(String color) {
        return isDarkColor(Color.parseColor(color));
    }

    public static boolean isDarkColor(int color) {
        int k = 50;
        return (Color.red(color) <= k && Color.green(color) <= k && Color.blue(color) <= k);
    }

    public static void stylizeDynamically(View view) {
        int color = Color.parseColor(AppInfo.color_theme);
        if (Helper.isLightColor(color)) {
            // use actionbar text color, it should not be white.
            color = Color.parseColor(AppInfo.color_actionbar_text);
        }
        view.setBackgroundColor(color);
    }

    public static void stylizeDynamically(ImageView view) {
        if (view != null) {
            int color = Color.parseColor(AppInfo.color_theme);
            if (Helper.isLightColor(color)) {
                // use actionbar text color, it should not be white.
                color = Color.parseColor(AppInfo.color_actionbar_text);
            }
            view.setColorFilter(color, PorterDuff.Mode.SRC_IN);
        }
    }

    public static String getDateByPattern(Date date) {

        if (date != null && !date.toString().isEmpty()) {
            try {
                SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
                String strDate = simpleDateFormat.format(date);
                return getDateByPattern(strDate);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return "";
    }

    public static String getDateByPattern(String strDate) {
        if (!TextUtils.isEmpty(strDate)) {
            try {
                DateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
                Date formattedDate = sdf.parse(strDate);
                Calendar calendar = Calendar.getInstance();
                calendar.setTime(formattedDate);
                calendar.add(Calendar.MONTH, 1);
                String calendarFinal = "" + calendar.get(Calendar.DAY_OF_MONTH) + "-" + calendar.get(Calendar.MONTH) + "-" + calendar.get(Calendar.YEAR);
                if (!TextUtils.isEmpty(AppInfo.DATE_FORMAT_PATTERN)) {
                    calendar.add(Calendar.MONTH, -1);
                    Date date1 = calendar.getTime();
                    SimpleDateFormat simpleDateFormat = new SimpleDateFormat(AppInfo.DATE_FORMAT_PATTERN);
                    calendarFinal = simpleDateFormat.format(date1);
                }
                return calendarFinal;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return "";
    }

    public static void setDrawableLeft(TextView textView, int drawableResId) {
        setDrawableLeft(textView, drawableResId, false);
    }

    public static void setDrawableLeft(TextView textView, int drawableResId, boolean setPadding) {
        int tintColor = Color.parseColor(AppInfo.color_theme);
        if (Helper.isLightColor(tintColor)) {
            tintColor = Color.parseColor(AppInfo.color_actionbar_text);
        }
        setDrawableLeft(textView, drawableResId, tintColor);

        if (setPadding) {
            textView.setCompoundDrawablePadding(Helper.DP(20));
            textView.setPaddingRelative(Helper.DP(14), Helper.DP(12), Helper.DP(12), Helper.DP(12));
            textView.setPadding(Helper.DP(14), Helper.DP(12), Helper.DP(12), Helper.DP(12));
        }
    }

    public static void setDrawableLeft(TextView textView, int drawableResId, int tintColor) {
        try {
            Drawable drawable = ContextCompat.getDrawable(context, drawableResId);
            DrawableCompat.setTint(drawable, tintColor);
            textView.setCompoundDrawablesWithIntrinsicBounds(drawable, null, null, null);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void setDrawableRight(TextView textView, int drawableResId) {
        int tintColor = Color.parseColor(AppInfo.color_theme);
        if (Helper.isLightColor(tintColor)) {
            tintColor = Color.parseColor(AppInfo.color_actionbar_text);
        }
        setDrawableRight(textView, drawableResId, tintColor);
    }

    public static void setDrawableRight(TextView textView, int drawableResId, int tintColor) {
        try {
            Drawable drawable = ContextCompat.getDrawable(context, drawableResId);
            DrawableCompat.setTint(drawable, tintColor);
            textView.setCompoundDrawablesWithIntrinsicBounds(null, null, drawable, null);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void setDrawableLeftOnButton(Activity activity, Button button, int drawableResId) {
        setDrawableLeftOnButton(activity, button, drawableResId, false);
    }

    public static void setDrawableLeftOnButton(Activity activity, Button button, int drawableResId, boolean setPadding) {
        try {
            Drawable drawable = CContext.getVectorDrawable(activity, drawableResId).mutate();
            DrawableCompat.setTint(drawable, Color.parseColor(AppInfo.normal_button_text_color));
            button.setCompoundDrawablesWithIntrinsicBounds(drawable, null, null, null);
            if (setPadding) {
                button.setCompoundDrawablePadding(Helper.DP(20));
                button.setPaddingRelative(Helper.DP(16), Helper.DP(12), Helper.DP(16), Helper.DP(12));
                button.setPadding(Helper.DP(16), Helper.DP(12), Helper.DP(16), Helper.DP(12));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void setDrawableRightOnButton(Activity activity, Button button, int drawableResId) {
        setDrawableRightOnButton(activity, button, drawableResId, false);
    }

    public static void setDrawableRightOnButton(Activity activity, Button button, int drawableResId, boolean setPadding) {
        try {
            Drawable drawable = CContext.getVectorDrawable(activity, drawableResId).mutate();
            DrawableCompat.setTint(drawable, Color.parseColor(AppInfo.normal_button_text_color));
            button.setCompoundDrawablesWithIntrinsicBounds(null, null, drawable, null);
            if (setPadding) {
                button.setCompoundDrawablePadding(Helper.DP(20));
                button.setPaddingRelative(Helper.DP(16), Helper.DP(12), Helper.DP(16), Helper.DP(12));
                button.setPadding(Helper.DP(16), Helper.DP(12), Helper.DP(16), Helper.DP(12));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void stylize(RangeSeekBar rangeSeekBar) {
        int activeColor = Color.parseColor(AppInfo.color_theme);
        if (Helper.isLightColor(activeColor)) {
            activeColor = Color.parseColor(AppInfo.color_actionbar_text);
        }
        rangeSeekBar.setActiveColor(activeColor);

        int textAboveThumbsColor = Color.parseColor(AppInfo.color_actionbar_text);
        if (Helper.isLightColor(textAboveThumbsColor)) {
            textAboveThumbsColor = Color.parseColor(AppInfo.color_theme);
        }
        rangeSeekBar.setTextAboveThumbsColor(textAboveThumbsColor);
    }

    public static void setTextOnView(View rootView, int textViewResId, String textKey) {
        View view = rootView.findViewById(textViewResId);
        if (view instanceof TextView) {
            ((TextView) view).setText(getString(textKey));
        }
        if (view instanceof EditText) {
            ((EditText) view).setText(getString(textKey));
        }
    }

    public static boolean isGoogleMapsInstalled(Activity activity) {
        try {
            ApplicationInfo info = activity.getPackageManager().getApplicationInfo("com.google.android.apps.maps", 0);
            return true;
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static void openNavigationLocation(Activity activity, String latitude, String longitude, String address_2) {
        String uriFormat = "google.navigation:q=" + latitude + "," + longitude + " (" + address_2 + ")";  // for start navigation using lat+lng+address
//        String uriFormat = "google.navigation:q=" + "Belkund, Maharashtra 413520"   /*address_2 + "" + city*/;
//        String uriFormat = "http://maps.google.co.in/maps?q=" + "Belkund, Maharashtra 413520";  // Locate address Point by address
//        String uriFormat = "http://maps.google.com/maps?"/*saddr=" + address.latitude */ + "&daddr=" + latitude + "," + longitude + " (" + address_2 + ")"; // Locate address Point by latlng uri -- /*"http://maps.google.com/maps?saddr=20.344,34.34&daddr=20.5666,45.345"*/

        try {
            Intent intent = new Intent(android.content.Intent.ACTION_VIEW, Uri.parse(uriFormat));
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            activity.startActivity(intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void openPlayStoreURI(Activity activity, String packageName) {
        String uriFormat = "market://details?id=" + packageName;
        try {
            Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(uriFormat));
            activity.startActivity(intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void stylizeStroke(View view) {
        GradientDrawable drawable = (GradientDrawable) view.getBackground();
        drawable.setStroke(1, Color.parseColor(AppInfo.color_theme));
    }

    public static void openGPSSetting(Activity activity) {
        try {
            Intent callGPSSettingIntent = new Intent(android.provider.Settings.ACTION_LOCATION_SOURCE_SETTINGS);
            activity.startActivity(callGPSSettingIntent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public String readFromClipboard(Context context) {
        ClipboardManager clipboard = (ClipboardManager) context.getSystemService(Context.CLIPBOARD_SERVICE);
        ClipData clip = clipboard.getPrimaryClip();
        if (clip != null) {
            ClipData.Item item = clip.getItemAt(0);
            return item.getText().toString();
        }
        return "";
    }

    private static Random mColorRandom = new Random(System.currentTimeMillis());

    private static int material_light_colors[] = new int[]{
            R.color.material_light_color_1,
            R.color.material_light_color_2,
            R.color.material_light_color_3,
            R.color.material_light_color_4,
            R.color.material_light_color_5,
            R.color.material_light_color_6,
            R.color.material_light_color_7,
            R.color.material_light_color_8,
            R.color.material_light_color_9,
            R.color.material_light_color_10,
            R.color.material_light_color_11,
            R.color.material_light_color_12,
            R.color.material_light_color_13,
            R.color.material_light_color_14,
            R.color.material_light_color_15,
            R.color.material_light_color_16,
            R.color.material_light_color_17
    };

    public static int getPlaceholderColor() {
        final int length = material_light_colors.length;
        return material_light_colors[mColorRandom.nextInt(length)];
    }

    public static int getThemeColor() {
        int color = Color.parseColor(AppInfo.color_theme);
        if (Helper.isLightColor(color)) {
            color = Color.parseColor(AppInfo.color_actionbar_text);
        }
        return color;
    }

    public static Bitmap vectorToBitmap(@DrawableRes int resId, int tint) {
        Drawable vectorDrawable = ResourcesCompat.getDrawable(context.getResources(), resId, null);
        Bitmap bitmap = Bitmap.createBitmap(vectorDrawable.getIntrinsicWidth(), vectorDrawable.getIntrinsicHeight(), Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);
        vectorDrawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
        DrawableCompat.setTint(vectorDrawable, tint);
        vectorDrawable.draw(canvas);
        return bitmap;
    }

    public static Bitmap fixImageOrientation(String filePath) {
        try {
            BitmapFactory.Options bounds = new BitmapFactory.Options();
            bounds.inJustDecodeBounds = false;
            bounds.inPreferredConfig = Bitmap.Config.RGB_565;
            bounds.inDither = true;
            BitmapFactory.decodeFile(filePath, bounds);

            BitmapFactory.Options opts = new BitmapFactory.Options();
            opts.inJustDecodeBounds = false;
            opts.inPreferredConfig = Bitmap.Config.RGB_565;
            opts.inDither = true;
            Bitmap bm = BitmapFactory.decodeFile(filePath, opts);

            ExifInterface exif = new ExifInterface(filePath);
            String orientString = exif.getAttribute(ExifInterface.TAG_ORIENTATION);
            int orientation = orientString != null ? Integer.parseInt(orientString) : ExifInterface.ORIENTATION_NORMAL;

            int rotationAngle = 0;
            if (orientation == ExifInterface.ORIENTATION_ROTATE_90) rotationAngle = 90;
            if (orientation == ExifInterface.ORIENTATION_ROTATE_180) rotationAngle = 180;
            if (orientation == ExifInterface.ORIENTATION_ROTATE_270) rotationAngle = 270;

            Matrix matrix = new Matrix();
            matrix.setRotate(rotationAngle, (float) bm.getWidth() / 2, (float) bm.getHeight() / 2);
            return Bitmap.createBitmap(bm, 0, 0, bounds.outWidth, bounds.outHeight, matrix, true);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return BitmapFactory.decodeFile(filePath);
    }

    public static boolean accessLocation(Context context) {
        LocationManager locationManager = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
        Criteria criteria = new Criteria();
        criteria.setPowerRequirement(Criteria.POWER_LOW);
        String bestProvider = locationManager.getBestProvider(criteria, false);
        return (bestProvider != null);
    }
}
