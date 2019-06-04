package com.twist.tmstore.notifications

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.preference.PreferenceManager
import android.support.v4.app.NotificationCompat
import com.parse.ParseObject
import com.parse.ParsePushBroadcastReceiver
import com.parse.ParseQuery
import com.twist.tmstore.Extras
import com.twist.tmstore.LauncherActivity
import com.twist.tmstore.entities.AppInfo
import com.twist.tmstore.entities.Notification

/* JSON example for demo */
/*
      // for only category
      {
          "alert": "Check out this Category",
          "badge": "Increment",
          "title": "Category",
          "data_array": {
            "content": ""
            "id": 12,
            "type": 1
          }
      }

      // for only product
      {
          "alert": "Check out this Product",
          "badge": "Increment",
          "title": "Product",
          "data_array": {
            "content": ""
            "id": 201,
            "type": 2
          }
      }

      // for only shop cart
      {
          "alert": "Check out what's in your Cart",
          "badge": "Increment",
          "title": "Cart",
          "data_array": {
            "content": ""
            "id": -1,
            "type": 3
          }
      }

      // for only wishlist
      {
        "alert": "Check out what's in your WishList",
        "badge": "Increment",
        "title": "WishList",
        "data_array": {
            "content": "",
            "id": -1,
            "type": 4
        }
    }
      {
        "alert": "यह एक परीक्षण अधिसूचना है!",
        "badge": "Increment",
        "title": "परीक्षण",
        "data_array": {
            "content": "",
            "id": -1,
            "type": 4
        }
    }
*/

class ParseNotificationReceiver : ParsePushBroadcastReceiver() {

    public override fun onPushReceive(context: Context, intent: Intent) {
        super.onPushReceive(context, intent)
        intent.extras?.let { bundle ->
            val json = bundle.getString("com.parse.Data")
            Notification.save(json)
            if (json.isNullOrBlank()) {
                AppInfo.PENDING_NOTIFICATIONS++
            }
        }
    }

    public override fun onPushOpen(context: Context, intent: Intent) {
        super.onPushOpen(context, intent)
        intent.extras?.let { bundle ->
            val data = bundle.getString("com.parse.Data")
            if (!data.isNullOrBlank()) {
                AppInfo.PENDING_NOTIFICATIONS--
                val notification = Notification.create(data)
                context.startActivity(Intent(context, LauncherActivity::class.java).apply {
                    putExtra(Extras.NOTIFICATION, notification)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                })
                updateNotificationsCount(notification)
            }
        }
    }

    public override fun onPushDismiss(context: Context?, intent: Intent?) {
        super.onPushDismiss(context, intent)
        intent?.extras?.let { bundle ->
            val json = bundle.getString("com.parse.Data")
            if (!json.isNullOrBlank())
                AppInfo.PENDING_NOTIFICATIONS++
        }
    }

    override fun getNotification(context: Context, intent: Intent): NotificationCompat.Builder? {
        val sp = PreferenceManager.getDefaultSharedPreferences(context)
        var bgColor = Color.parseColor("#ff00aff0")
        try {
            bgColor = Color.parseColor(sp.getString("color_theme", "#ff00aff0"))
        } catch (e: Exception) {
        }
        val notificationBuilder = super.getNotification(context, intent)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            notificationBuilder?.color = bgColor
        }
        return notificationBuilder
    }

    private fun updateNotificationsCount(notification: Notification) {
        if (!notification.getNotifyId().isNullOrEmpty()) {
            val query = ParseQuery.getQuery<ParseObject>("Push_Notify")
            query.getInBackground(notification.getNotifyId()) { obj, e ->
                if (e == null) {
                    obj.increment("push_open")
                    obj.saveInBackground { e1 ->
                        e1?.printStackTrace()
                    }
                }
            }
        }
    }
}
