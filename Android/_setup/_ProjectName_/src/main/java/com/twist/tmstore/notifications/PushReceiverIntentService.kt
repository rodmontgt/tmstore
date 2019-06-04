package com.twist.tmstore.notifications

import android.app.IntentService
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.media.RingtoneManager
import android.os.Bundle
import android.support.v4.app.NotificationCompat
import com.twist.tmstore.Extras
import com.twist.tmstore.R
import com.twist.tmstore.entities.Notification
import com.utils.HtmlCompat
import java.util.*

/**
 * Created by Twist Mobile on 29/08/16.
 */

class PushReceiverIntentService : IntentService(TAG) {

    override fun onHandleIntent(intent: Intent?) {
        intent?.extras?.let { bundle ->
            val notification = bundle.getParcelable<Notification>(Extras.NOTIFICATION)
            when (notification) {
                null -> {
                    sendNotification(Notification.save(bundle.getString("message")), bundle)
                }
                else -> sendNotification(notification, Bundle())
            }
        }
    }

    private fun sendNotification(notification: Notification, extras: Bundle) {
        val intent = Intent().apply {
            putExtra(Extras.NOTIFICATION, notification)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            action = "notification"
        }
        val random = Random()
        val requestCode = random.nextInt()
        val pendingIntent = PendingIntent.getActivity(this, requestCode, intent, PendingIntent.FLAG_UPDATE_CURRENT)
        val notificationBuilder = NotificationCompat.Builder(this)
                .setSmallIcon(R.drawable.ic_stat)
                .setLargeIcon(BitmapFactory.decodeResource(resources, R.drawable.ic_stat))
                .setContentTitle(HtmlCompat.fromHtml(notification.getTitle()))
                .setContentText(HtmlCompat.fromHtml(notification.getAlert()))
                .setAutoCancel(true)
                .setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION))
                .setContentIntent(pendingIntent)
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(0, notificationBuilder.build().apply {
            contentView.setImageViewResource(android.R.id.icon, R.drawable.ic_stat)
        })
    }

    companion object {
        private const val TAG = "PushReceiverIntentService"
    }
}