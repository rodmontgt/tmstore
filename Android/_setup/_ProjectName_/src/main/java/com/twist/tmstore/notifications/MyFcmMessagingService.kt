package com.twist.tmstore.notifications

/**
 * Created by Twist Mobile on 16-03-2017.
 */

import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.RingtoneManager
import android.support.v4.app.NotificationCompat
import com.freshchat.consumer.sdk.Freshchat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import com.twist.tmstore.Extras
import com.twist.tmstore.LauncherActivity
import com.twist.tmstore.R
import com.twist.tmstore.config.FreshChatConfig
import com.twist.tmstore.config.NotificationConfig
import com.twist.tmstore.entities.Notification
import com.utils.HtmlCompat
import com.utils.Log
import org.json.JSONObject
import java.util.*

class MyFcmMessagingService : FirebaseMessagingService() {

    //  Command for force token refresh, make sure all service receivers are defined with { android:exported="true" } attribute
    //  adb shell am startservice -a com.google.android.gms.iid.InstanceID --es "CMD" "RST" -n com.twist.tmstore/com.twist.tmstore.notifications.MyFcmIIDListenerService
    override fun onNewToken(s: String?) {
        super.onNewToken(s)
        if (FreshChatConfig.isEnabled() || NotificationConfig.isEnabled() && NotificationConfig.getType() == NotificationConfig.Type.FCM) {
            this.startService(Intent(this, MyFcmRegistrationService::class.java))
        }
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage?) {
        // Do not change order of below code block
        if (FreshChatConfig.isEnabled()) {
            if (Freshchat.isFreshchatNotification(remoteMessage!!)) {
                Freshchat.getInstance(this).handleFcmMessage(remoteMessage)
                return
            }
        }

        if (NotificationConfig.isEnabled() && NotificationConfig.getType() == NotificationConfig.Type.FCM) {
            var message: String? = ""
            try {
                if (remoteMessage?.notification != null) {
                    message = remoteMessage.notification?.body
                } else if (remoteMessage?.data != null) {
                    message = JSONObject(remoteMessage.data).toString()
                }
                Log.d("-- onMessageReceived::message [$message] --")
            } catch (e: Exception) {
                Log.d("-- onMessageReceived::message [" + e.message + "] --")
            }

            if (!message.isNullOrBlank()) {
                val notification = Notification.create(message)
                val intent = Intent(this, LauncherActivity::class.java).apply {
                    putExtra(Extras.NOTIFICATION, notification)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    action = "notification"
                }
                val requestCode = Random().nextInt()
                val pendingIntent = PendingIntent.getActivity(this, requestCode, intent, PendingIntent.FLAG_UPDATE_CURRENT)
                val notificationBuilder = NotificationCompat.Builder(this)
                        .setSmallIcon(R.drawable.app_icon)
                        .setContentTitle(HtmlCompat.fromHtml(notification!!.getTitle()))
                        .setContentText(HtmlCompat.fromHtml(notification.getAlert()))
                        .setAutoCancel(true)
                        .setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION))
                        .setContentIntent(pendingIntent)
                val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                notificationManager.notify(0, notificationBuilder.build())
            }
        }
    }
}
