package com.twist.tmstore.config;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.graphics.Point;
import android.support.v4.app.Fragment;
import android.support.v4.text.TextUtilsCompat;
import android.support.v4.view.ViewCompat;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.freshchat.consumer.sdk.Freshchat;
import com.freshchat.consumer.sdk.FreshchatCallbackStatus;
import com.freshchat.consumer.sdk.FreshchatConfig;
import com.freshchat.consumer.sdk.FreshchatUser;
import com.twist.tmstore.R;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.utils.Helper;
import com.utils.JsonHelper;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

/**
 * Created by Twist Mobile on 21-Jul-16.
 */

public class FreshChatConfig {

    private static final int POS_DRAWER = 0;
    private static final int POS_SCREEN = 1;

    public static final int PUSH_TYPE_FCM = 1;

    private static FreshChatConfig mFreshChatConfig;
    private static ImageButton openChatButton;
    private boolean isChatShowing = true;

    private String mAppId = "";

    private String mAppKey = "";

    private String mMenuTitle = "";

    private int mChatPos = 0;

    private boolean mEnabled = false;

    private FreshChatConfig() {
    }

    public static String getMenuTitle() {
        return (FreshChatConfig.isEnabled()) ? mFreshChatConfig.mMenuTitle : "";
    }

    public static boolean isEnabled() {
        return mFreshChatConfig != null && mFreshChatConfig.mEnabled;
    }

    public static boolean shouldShowInDrawer() {
        return FreshChatConfig.isEnabled() && mFreshChatConfig.mChatPos == FreshChatConfig.POS_DRAWER;
    }

    public static void createConfig(JSONObject jsonObject) {
        try {
            mFreshChatConfig = new FreshChatConfig();
            mFreshChatConfig.mAppId = JsonHelper.getString(jsonObject, "app_id");
            mFreshChatConfig.mAppKey = JsonHelper.getString(jsonObject, "app_key");
            mFreshChatConfig.mChatPos = JsonHelper.getInt(jsonObject, "pos", POS_DRAWER);
            mFreshChatConfig.mMenuTitle = JsonHelper.getString(jsonObject, "title");
            mFreshChatConfig.mEnabled = JsonHelper.getBool(jsonObject, "enabled", true);
        } catch (Exception e) {
            e.printStackTrace();
            mFreshChatConfig = null;
        }
    }

    public static void resetConfig() {
        mFreshChatConfig = null;
    }

    public static void initialize(final AppCompatActivity activity) {
        LinearLayout liveChatSection = activity.findViewById(R.id.live_chat_section);
        ImageButton buttonOpenChat = activity.findViewById(R.id.btn_live_chat);
        if (FreshChatConfig.isEnabled()) {
            // Change layouts here if you have updated in activity_main.xml
            // Floating Chat Button is placed above Bottom Navigation Bar, hence we need to update
            // its layout parameters when Bottom Navigation Bar is hidden.
            if (!AppInfo.SHOW_BOTTOM_NAV_MENU && mFreshChatConfig.mChatPos == FreshChatConfig.POS_SCREEN) {
                if (liveChatSection.getParent() instanceof RelativeLayout) {
                    RelativeLayout parentLayout = (RelativeLayout) liveChatSection.getParent();
                    RelativeLayout.LayoutParams layoutParams = (RelativeLayout.LayoutParams) liveChatSection.getLayoutParams();
                    layoutParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
                    parentLayout.updateViewLayout(liveChatSection, layoutParams);
                }
            }

            if (buttonOpenChat != null) {
                if (mFreshChatConfig.mChatPos == FreshChatConfig.POS_SCREEN) {
                    buttonOpenChat.setOnClickListener(v -> showConversations(activity));
                    buttonOpenChat.setBackground(Helper.getBtnOvalDrawable());
                    buttonOpenChat.setVisibility(View.VISIBLE);
                    liveChatSection.setVisibility(View.VISIBLE);
                } else {
                    liveChatSection.setVisibility(View.GONE);
                }
            }
            updateUnreadCount(activity, 0);
            FreshchatConfig freshchatConfig = new FreshchatConfig(mFreshChatConfig.mAppId, mFreshChatConfig.mAppKey);
            freshchatConfig.setCameraCaptureEnabled(true);
            freshchatConfig.setGallerySelectionEnabled(true);
            Freshchat.getInstance(activity.getApplicationContext()).init(freshchatConfig);
            if (AppUser.getInstance().user_type != AppUser.USER_TYPE.ANONYMOUS_USER) {
                FreshchatUser freshUser = Freshchat.getInstance(activity.getApplicationContext()).getUser();
                freshUser.setFirstName(AppUser.getInstance().first_name);
                freshUser.setLastName(AppUser.getInstance().last_name);
                freshUser.setEmail(AppUser.getEmail());
                if (AppUser.getInstance().billing_address != null) {
                    freshUser.setPhone(freshUser.getPhoneCountryCode(), AppUser.getInstance().billing_address.phone);
                }
                Freshchat.getInstance(activity.getApplicationContext()).setUser(freshUser);
            }
        } else {
            liveChatSection.setVisibility(View.GONE);
        }
    }

    public static void showConversations(AppCompatActivity activity) {
        if (FreshChatConfig.isEnabled()) {
            String screen = "Home";
            Fragment fragment = activity.getSupportFragmentManager().findFragmentById(R.id.content);
            if (fragment != null) {
                screen = fragment.getTag();
            }
            Map<String, String> userMeta = new HashMap<>();
            userMeta.put("Screen", screen != null ? screen : "Home");
            Freshchat.getInstance(activity.getApplicationContext()).setUserProperties(userMeta);
            Freshchat.showConversations(activity.getApplicationContext());
        }
    }


    public static void logout(Context context) {
        if (FreshChatConfig.isEnabled()) {
            Freshchat.resetUser(context.getApplicationContext());
        }
    }

    public static void onResume(final AppCompatActivity activity) {
        if (FreshChatConfig.isEnabled()) {
            Freshchat.getInstance(activity.getApplicationContext()).getUnreadCountAsync((freshchatCallbackStatus, unreadCount) -> updateUnreadCount(activity, unreadCount));
        }
    }

    private static void updateUnreadCount(AppCompatActivity activity, int unreadCount) {
        if (FreshChatConfig.isEnabled()) {
            if (mFreshChatConfig.mChatPos == FreshChatConfig.POS_SCREEN) {
                TextView textViewUnreadCount = activity.findViewById(R.id.text_live_chat_unread_count);
                if (textViewUnreadCount != null) {
                    if (unreadCount > 0) {
                        textViewUnreadCount.setText(String.valueOf(unreadCount));
                        textViewUnreadCount.setBackground(Helper.getBtnOvalDrawable2());
                        textViewUnreadCount.setTextColor(Color.parseColor(AppInfo.color_theme));
                        textViewUnreadCount.setVisibility(View.VISIBLE);
                    } else {
                        textViewUnreadCount.setVisibility(View.GONE);
                    }
                }
            }
        }
    }

    public static void incrementUnreadCount(AppCompatActivity activity, int unreadCount) {
        if (FreshChatConfig.isEnabled() && !activity.isFinishing()) {
            if (mFreshChatConfig.mChatPos == FreshChatConfig.POS_SCREEN) {
                TextView textViewUnreadCount = activity.findViewById(R.id.text_live_chat_unread_count);
                if (textViewUnreadCount != null) {
                    if (unreadCount > 0) {
                        try {
                            unreadCount += Integer.parseInt(textViewUnreadCount.getText().toString());
                        } catch (Exception e) {
                        }
                        textViewUnreadCount.setText(String.valueOf(unreadCount));
                        textViewUnreadCount.setBackground(Helper.getBtnOvalDrawable2());
                        textViewUnreadCount.setTextColor(Color.parseColor(AppInfo.color_theme));
                        textViewUnreadCount.setVisibility(View.VISIBLE);
                    } else {
                        textViewUnreadCount.setVisibility(View.GONE);
                    }
                }
            }
        }
    }


    public static void setChatButtonVisibility(Activity activity, int visibility) {
        if (FreshChatConfig.isEnabled() && mFreshChatConfig.mChatPos == FreshChatConfig.POS_SCREEN) {
            openChatButton = activity.findViewById(R.id.btn_live_chat);
            if (openChatButton != null) {
                openChatButton.setVisibility(visibility);
            }
        }
    }

    public static void showChatButton(Activity activity, boolean show) {
        if (FreshChatConfig.isEnabled() && mFreshChatConfig.mChatPos == FreshChatConfig.POS_SCREEN) {
            LinearLayout openChatButton = activity.findViewById(R.id.live_chat_section);
            if (openChatButton != null) {
                if (show) {
                    if (!mFreshChatConfig.isChatShowing) {
                        mFreshChatConfig.isChatShowing = true;
                        if (TextUtilsCompat.getLayoutDirectionFromLocale(Locale.getDefault()) == ViewCompat.LAYOUT_DIRECTION_LTR) {
                            openChatButton.animate().translationX(0).start();
                        } else {
                            openChatButton.animate().translationX(0).start();
                        }
                    }
                } else {
                    if (mFreshChatConfig.isChatShowing) {
                        mFreshChatConfig.isChatShowing = false;
                        final Point point = new Point();
                        activity.getWindow().getWindowManager().getDefaultDisplay().getSize(point);
                        final float translation = openChatButton.getX() - (point.x);
                        if (TextUtilsCompat.getLayoutDirectionFromLocale(Locale.getDefault()) == ViewCompat.LAYOUT_DIRECTION_LTR) {
                            openChatButton.animate().translationX(translation).start();
                        } else {
                            openChatButton.animate().translationXBy(-translation).start();
                        }
                    }
                }
            }
        }
    }
}
