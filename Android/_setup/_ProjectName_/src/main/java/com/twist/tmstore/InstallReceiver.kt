package com.twist.tmstore

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import com.parse.ParseInstallation
import java.net.URLDecoder

/**
 * Created by Twist Mobile on 23-Mar-16.
 * Command :
 * adb shell
 * am broadcast -a com.android.vending.INSTALL_REFERRER -n com.twist.tmstore/com.twist.tmstore.InstallReceiver --es referrer "http://www.twistmobile.in/demo/wordpress/p/142/referrer=r0001"
 */
class InstallReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context?, intent: Intent?) {
        when {
            intent?.hasExtra(Extras.REFERRER) == true -> try {
                val referrer = URLDecoder.decode(intent.getStringExtra(Extras.REFERRER), "UTF-8")
                context?.startActivity(Intent(context, LauncherActivity::class.java).apply {
                    putExtra(Extras.REFERRER, referrer)
                    putExtra(Extras.REFERRER_TYPE, Constants.Key.REFERRER_INSTALL)
                    data = Uri.parse(referrer)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                })
                println("**** InstallReceiver REFERRER onReceive ****")
                registerReferrer(referrer)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        Log.d(TAG, intent?.extras?.toString())
    }

    private fun registerReferrer(referrer: String) {
        when {
            referrer.isNotBlank() -> {
                Log.d(TAG, referrer)
                val parseInstallation = ParseInstallation.getCurrentInstallation()
                parseInstallation.put(Extras.REFERRER, referrer)
                parseInstallation.saveInBackground { e ->
                    when (e) {
                        null -> Log.e(TAG, "Referrer request is sent.")
                        else -> Log.e(TAG, "Referrer request is not sent.")
                    }
                }
            }
            else -> Log.e(TAG, "Referrer not found.")
        }
    }

    companion object {
        private const val TAG = "InstallReceiver"
    }
}