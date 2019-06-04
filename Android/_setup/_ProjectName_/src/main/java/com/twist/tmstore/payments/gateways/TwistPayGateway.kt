package com.twist.tmstore.payments.gateways

import android.app.Activity
import android.content.Intent
import android.os.Build
import android.os.Bundle
import com.twist.dataengine.entities.TM_CommonInfo
import com.twist.tmstore.BasePaymentActivity
import com.twist.tmstore.entities.AppInfo
import com.twist.tmstore.entities.AppUser
import com.twist.tmstore.payments.PaymentGateway
import com.twist.tmstore.payments.web.TwistPayActivity
import com.utils.JsonHelper
import com.utils.forEach
import org.json.JSONObject
import java.util.*

/**
 * Created by Twist Mobile on 12/28/2018.
 */

class TwistPayGateway() : PaymentGateway() {

    override fun open(orderId: Int, amount: Float): Boolean {
        intent.putExtra(TwistPayActivity.EXTRA_ORDER_ID, BasePaymentActivity.encrypt(orderId.toString()))
        intent.putExtra(TwistPayActivity.EXTRA_AMOUNT, BasePaymentActivity.encrypt(amount.toString()))
        this.launchIntent()
        return true
    }

    override fun isPrepaid(): Boolean {
        return true
    }

    fun create(activity: Activity, jsonObject: JSONObject): TwistPayGateway {
        try {
            val configBundle = Bundle().apply {
                val keysIterator = jsonObject.keys()
                while (keysIterator.hasNext()) {
                    val key = keysIterator.next()
                    this.putString(key, BasePaymentActivity.encrypt(jsonObject.getString(key)))
                }
            }

            val userBundle = Bundle().apply {

                val address = if (AppUser.hasSignedIn())
                    AppUser.getInstance().billing_address
                else
                    AppInfo.dummyUser.billing_address
                address?.let {
                    jsonObject.optJSONArray("user_data")?.forEach<String> { key ->
                        when (key) {
                            "first_name" -> {
                                this.putString(key, BasePaymentActivity.encrypt(it.first_name))
                            }
                            "last_name" -> {
                                this.putString(key, BasePaymentActivity.encrypt(it.last_name))
                            }
                            "email" -> {
                                this.putString(key, BasePaymentActivity.encrypt(it.email))
                            }
                            "phone" -> {
                                this.putString(key, BasePaymentActivity.encrypt(it.phone))
                            }
                            "address" -> {
                                this.putString(key, BasePaymentActivity.encrypt("${it.address_1} ${it.address_2}"))
                            }
                            "country" -> {
                                this.putString(key, BasePaymentActivity.encrypt(it.countryCode))
                            }
                            "state" -> {
                                this.putString(key, BasePaymentActivity.encrypt(it.stateCode))
                            }
                            "city" -> {
                                this.putString(key, BasePaymentActivity.encrypt(it.city))
                            }
                            "pincode" -> {
                                this.putString(key, BasePaymentActivity.encrypt(it.postcode))
                            }
                            "currency" -> {
                                this.putString(key, BasePaymentActivity.encrypt(TM_CommonInfo.currency))
                            }
                            "language" -> {

                                val configuration = activity.resources.configuration
                                val locale: Locale = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                    configuration.locales.get(0)
                                } else {
                                    configuration.locale
                                }
                                val language = locale.language
                                this.putString(key, BasePaymentActivity.encrypt(language))
                            }
                        }
                    }
                }
            }

            val intent = Intent(activity, TwistPayActivity::class.java).apply {
                putExtra(TwistPayActivity.EXTRA_BASE_URL, JsonHelper.getString(jsonObject, "base_url"))
                putExtra(TwistPayActivity.EXTRA_SUCCESS_URL, JsonHelper.getString(jsonObject, "success_url"))
                putExtra(TwistPayActivity.EXTRA_FAILURE_URL, JsonHelper.getString(jsonObject, "failure_url"))
                putExtra(TwistPayActivity.EXTRA_CONFIG_DATA, configBundle)
                putExtra(TwistPayActivity.EXTRA_USER_DATA, userBundle)
            }
            this.id = jsonObject.optString("gateway_id")
            this.isEnabled = JsonHelper.getBool(jsonObject, "enabled")
            this.initialize(activity, intent)
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return this
    }
}