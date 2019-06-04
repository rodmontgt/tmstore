package com.twist.tmstore.notifications;

import android.app.IntentService;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.text.TextUtils;

import com.freshchat.consumer.sdk.Freshchat;
import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.messaging.FirebaseMessaging;
import com.twist.tmstore.Constants;
import com.twist.tmstore.Extras;
import com.twist.tmstore.R;
import com.twist.tmstore.config.FreshChatConfig;
import com.twist.tmstore.config.NotificationConfig;
import com.twist.tmstore.entities.CustomerData;
import com.utils.Log;

import java.io.IOException;

public class MyFcmRegistrationService extends IntentService {

    private static final String TAG = "MyFcmRegistrationService";

    private final String TOPICS[] = {"android", "both"};

    public MyFcmRegistrationService() {
        super(TAG);
    }

    @Override
    protected void onHandleIntent(Intent intent) {

        String action = intent.getAction();
        if (action == null)
            action = "";

        switch (action) {
            case Constants.ACTION_UNREGISTER_NOTIFICATION:
                deleteToken();
                break;
            case Constants.ACTION_REGISTER_NOTIFICATION:
                registerFCM();
                break;
            case Constants.ACTION_MANAGE_CHANNEL_SUBSCRIPTION:
                manageChannelSubscription(intent.getExtras());
                break;
            default:
                registerFCM();
                break;
        }
    }

    private void manageChannelSubscription(Bundle bundle) {
        if (bundle != null) {
            subscribeChannel(bundle.getString(Extras.SUBSCRIBE_CHANNEL));
            unsubscribeChannel(bundle.getString(Extras.UNSUBSCRIBE_CHANNEL));
        }
    }

    private void subscribeChannel(String channel) {
        if (TextUtils.isEmpty(channel)) {
            Log.d("subscribeChannel :: Channel name is empty");
            return;
        }

        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);
        if (preferences.getBoolean(getString(R.string.key_app_notification), true)) {
            if (NotificationConfig.getType() == NotificationConfig.Type.FCM) {
                String topic = "android_" + channel;
                FirebaseMessaging.getInstance().subscribeToTopic(topic);
                Log.d("Subscribed to topic : " + topic);
            }
        }
    }

    private void unsubscribeChannel(String channel) {
        if (TextUtils.isEmpty(channel)) {
            Log.d("unsubscribeChannel :: Channel name is empty");
            return;
        }

        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);
        if (preferences.getBoolean(getString(R.string.key_app_notification), true)) {
            if (NotificationConfig.getType() == NotificationConfig.Type.FCM) {
                String topic = "android_" + channel;
                FirebaseMessaging.getInstance().unsubscribeFromTopic(topic);
                Log.d("FCM::Unsubscribed from topic : " + topic);
            }
        }
    }

    private void registerFCM() {
        final String token = this.getToken();
        try {
            Log.d("Token : " + token);
            if (FreshChatConfig.isEnabled() && !TextUtils.isEmpty(token)) {
                Freshchat.getInstance(this).setPushRegistrationToken(token);
            }

            SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);
            if (preferences.getBoolean(getString(R.string.key_app_notification), true)) {
                if (NotificationConfig.getType() == NotificationConfig.Type.FCM) {
                    String lastToken = preferences.getString(Constants.Key.DEVICE_TOKEN, "");
                    if (!lastToken.equals(token)) {
                        CustomerData customerData = CustomerData.getInstance();
                        if (customerData != null) {
                            customerData.addDeviceToken(token);
                            customerData.saveEventually();
                        }

                        for (String topic : TOPICS) {
                            FirebaseMessaging.getInstance().subscribeToTopic(topic);
                        }
                    }
                    preferences.edit().putString(Constants.Key.DEVICE_TOKEN, token).apply();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            Log.d("Failed to complete firebase token refresh");
        }

    }

    private void deleteToken() {
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(this);
        if (!preferences.getBoolean(getString(R.string.key_app_notification), true)) {
            try {
                FirebaseInstanceId.getInstance().deleteInstanceId();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    private String getToken() {
        String token = FirebaseInstanceId.getInstance().getToken();
        Log.d("FCM::deviceToken", token);
        return token;
    }
}