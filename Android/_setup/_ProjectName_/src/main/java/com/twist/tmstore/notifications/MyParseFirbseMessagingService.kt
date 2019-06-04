package com.twist.tmstore.notifications

import android.content.Intent
import android.support.v4.content.LocalBroadcastManager
import android.text.TextUtils
import com.freshchat.consumer.sdk.Freshchat
import com.google.firebase.messaging.RemoteMessage
import com.parse.fcm.ParseFCM
import com.parse.fcm.ParseFirebaseMessagingService
import com.twist.tmstore.Constants
import com.twist.tmstore.MainActivity
import com.twist.tmstore.config.FreshChatConfig

class MyParseFirbseMessagingService : ParseFirebaseMessagingService() {
    override fun onNewToken(token: String?) {
        super.onNewToken(token)
        if (FreshChatConfig.isEnabled() && !TextUtils.isEmpty(token)) {
            Freshchat.getInstance(this).setPushRegistrationToken(token!!)
        }
        ParseFCM.register(applicationContext);
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage?) {
        if (FreshChatConfig.isEnabled() && Freshchat.isFreshchatNotification(remoteMessage!!)) {
            Freshchat.getInstance(this).handleFcmMessage(remoteMessage)
            LocalBroadcastManager.getInstance(this).sendBroadcast(Intent(applicationContext, MainActivity::class.java).apply {
                action = Constants.ACTION_BROADCAST_NOTIFICATION
            })
            return
        } else
            super.onMessageReceived(remoteMessage)
    }
}