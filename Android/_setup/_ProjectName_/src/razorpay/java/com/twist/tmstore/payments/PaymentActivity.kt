package com.twist.tmstore.payments

import android.os.Bundle
import com.razorpay.Checkout
import com.razorpay.PaymentResultListener
import com.twist.tmstore.BasePaymentActivity
import com.twist.tmstore.R
import com.utils.Log
import org.json.JSONObject


class PaymentActivity : BasePaymentActivity(), PaymentResultListener {

    private var email: String? = ""
    private var amount = 0
    private var orderId = 0
    private var contact: String? = ""
    private var name: String? = ""
    private var merchant: String? = ""
    private var color: String? = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        intent.extras?.let { bundle ->
            val title = bundle.getString("title")
            setupActionBarHomeAsUp(if (title.isEmpty()) "Razorpay" else title)
            email = bundle.getString("email")
            amount = bundle.getInt("amount")
            name = bundle.getString("name")
            orderId = bundle.getInt("order_id")
            contact = bundle.getString("contact")
            merchant = bundle.getString("merchant")
            color = bundle.getString("color")
            initREST()
        }
    }

    override fun onActionBarRestored() {}

    private fun initREST() {
        Checkout.preload(applicationContext)
        val checkout = Checkout()
        checkout.setImage(R.drawable.app_icon)
        checkout.setFullScreenDisable(true)
        try {
            val options = JSONObject()
            options.put("name", merchant)
            options.put("description", "Order #$orderId")
            options.put("currency", "INR")
            options.put("amount", amount)
            options.put("prefill", JSONObject("{email: '$email', contact: '$contact', name: '$name'}"))
            options.put("theme", JSONObject("{color: '$color'}"))
            checkout.open(this, options)
        } catch (e: Exception) {
            e.printStackTrace()
            onPaymentError()
        }
    }

    override fun onPaymentSuccess(razorpayPaymentID: String) {
        Log.d("Payment Successful: $razorpayPaymentID")
        onPaymentSuccess()
    }

    override fun onPaymentError(code: Int, response: String) {
        Log.d("Payment failed: error code $code $response")
        onPaymentError()
    }
}
