package com.twist.tmstore.payments.gateways

import android.app.Activity
import android.content.Intent
import com.twist.tmstore.entities.AppUser
import com.twist.tmstore.payments.PaymentGateway
import com.twist.tmstore.payments.web.AuthorizeNetActivity
import com.utils.JsonHelper
import org.json.JSONObject

/**
 * Created by Twist Mobile on 24-02-2017.
 */

class AuthorizeNetGateway private constructor() : PaymentGateway() {

    override fun isPrepaid(): Boolean {
        return true
    }

    override fun open(orderId: Int, amount: Float): Boolean {
        intent.putExtra("amount", amount.toString())
        intent.putExtra("orderid", orderId.toString())
        this.launchIntent()
        return true
    }

    companion object {

        private var mGateway: AuthorizeNetGateway? = null

        val instance: AuthorizeNetGateway
            get() {
                if (mGateway == null) {
                    mGateway = AuthorizeNetGateway()
                }
                return mGateway!!
            }

        fun createGateway(activity: Activity, jsonObject: JSONObject) {
            try {
                mGateway = AuthorizeNetGateway.instance
                val address = AppUser.getInstance().billing_address
                val intent = Intent(activity, AuthorizeNetActivity::class.java)
                intent.putExtra("baseurl", JsonHelper.getString(jsonObject, "baseurl"))
                intent.putExtra("furl", JsonHelper.getString(jsonObject, "furl"))
                intent.putExtra("surl", JsonHelper.getString(jsonObject, "surl"))
                intent.putExtra("fname", address.first_name)
                intent.putExtra("lname", address.last_name)
                intent.putExtra("address", address.address_1 + " " + address.address_2)
                intent.putExtra("country", address.countryCode)
                intent.putExtra("state", address.stateCode)
                intent.putExtra("city", address.city)
                intent.putExtra("zipcode", address.postcode)
                intent.putExtra("phone", address.phone)
                intent.putExtra("email", address.email)
                intent.putExtra("description", "")
                mGateway!!.isEnabled = JsonHelper.getBool(jsonObject, "enabled")
                mGateway!!.initialize(activity, intent)
            } catch (e: Exception) {
                e.printStackTrace()
            }

        }
    }
}