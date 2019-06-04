package com.utils;

import com.parse.ParseException;
import com.parse.ParseFile;
import com.parse.ParseObject;
import com.parse.SaveCallback;
import com.twist.tmstore.BuildConfig;
import com.twist.tmstore.entities.AppUser;

import com.twist.oauth.NetworkUtils;

/**
 * Created by Twist Mobile on 11-Jan-16.
 */
public class Log {

    private static String TAG = "TMStore";
    public static boolean DEBUG = BuildConfig.DEBUG;

    public static void setTag(String tag) {
        Log.TAG = tag;
    }

    public static void d(String message) {
        if (DEBUG) {
            android.util.Log.d(TAG, message == null ? "" : message);
        }
        NetworkUtils.appendBuffer(message);
    }

    public static void D(String message) {
        if (DEBUG) {
            android.util.Log.d(TAG, message == null ? "" : message);
        }
        NetworkUtils.appendBuffer(message);
    }

    public static void d(long value) {
        if (DEBUG) {
            android.util.Log.d(TAG, String.valueOf(value));
        }
        NetworkUtils.appendBuffer(value);
    }

    public static void d(String tag, String message) {
        if (DEBUG) {
            android.util.Log.d(tag, message == null ? "" : message);
        }
        NetworkUtils.appendBuffer(message);
    }

    public static void e(String message) {
        if (DEBUG) {
            android.util.Log.e(TAG, message == null ? "" : message);
        }
        NetworkUtils.appendBuffer(message);
    }

    public static void e(long value) {
        if (DEBUG) {
            android.util.Log.e(TAG, String.valueOf(value));
        }
        NetworkUtils.appendBuffer(value);
    }

    public static void e(String tag, String message) {
        if (DEBUG) {
            android.util.Log.e(tag, message == null ? "" : message);
        }
        NetworkUtils.appendBuffer(message);
    }

    public static void w(String message) {
        if (DEBUG) {
            android.util.Log.w(TAG, message == null ? "" : message);
        }
        NetworkUtils.appendBuffer(message);
    }

    public static void W(String message) {
        Log.w(message);
    }

    public static void commitBuffer() {
        if (!NetworkUtils.UPLOAD_LOG)
            return;
        try {
            final ParseFile logFile = new ParseFile(System.currentTimeMillis() + ".txt", String.valueOf(NetworkUtils.logBuffer).getBytes());
            logFile.saveInBackground(new SaveCallback() {
                @Override
                public void done(ParseException e) {
                    if (e == null) {
                        ParseObject parseObject = ParseObject.create("Log_Data");
                        parseObject.put("logFile", logFile);
                        if (!AppUser.isAnonymous()) {
                            parseObject.put("user", AppUser.getEmail());
                        }
                        parseObject.saveEventually();
                    }
                }
            });
            //if(OAuthUtils.UPLOAD_LOG) OAuthUtils.logBuffer.setLength(0);
        } catch (Exception e) {
            e.printStackTrace();
            //if(OAuthUtils.UPLOAD_LOG) OAuthUtils.logBuffer.setLength(0);
        }
    }
}
