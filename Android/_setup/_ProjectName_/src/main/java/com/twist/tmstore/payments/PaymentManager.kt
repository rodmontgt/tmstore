package com.twist.tmstore.payments

import android.app.Activity
import android.content.Intent
import android.text.TextUtils
import com.twist.dataengine.entities.TM_PaymentGateway
import com.twist.tmstore.Extras
import com.twist.tmstore.L
import com.twist.tmstore.L.getString
import com.twist.tmstore.R
import com.twist.tmstore.entities.AppInfo
import com.twist.tmstore.payments.gateways.*
import com.utils.Log
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.util.*

object PaymentManager {

    private var jsonArrayPayment: JSONArray? = null

    private val paymentGateways = ArrayList<PaymentGateway>()

    private val twistPayGateways = ArrayList<PaymentGateway>()

    private var mSkipped = false

    var selectedGateway: PaymentGateway? = null

    val allPaymentGateway: List<PaymentGateway>
        get() = paymentGateways

    fun setPaymentJson(jsonObject: JSONObject) {
        try {
            jsonArrayPayment = null
            if (jsonObject.has("payments")) {
                jsonArrayPayment = jsonObject.getJSONArray("payments")
            }
        } catch (e: JSONException) {
            e.printStackTrace()
        }
    }

    fun reset() {
        paymentGateways.clear()
        twistPayGateways.clear()
        selectedGateway = null
    }

    fun initialize(listener: PaymentGateway.PaymentListener, activity: Activity) {
        if (jsonArrayPayment != null) {
            parsePaymentGateways(activity)
        }

        if (paymentGateways.isNotEmpty()) {
            for (paymentGateway in paymentGateways) {
                paymentGateway.paymentListener = listener
            }
            return
        }

//        if (twistPayGateways.isNotEmpty()) {
//            for (twistPayGateway in twistPayGateways) {
//                twistPayGateway.paymentListener = listener
//            }
//            return
//        }

        mSkipped = false
        for (paymentGateway in TM_PaymentGateway.allPaymentGateways) {
            val id = paymentGateway.id
            val title = paymentGateway.title
            Log.d("Payment Gateway : [" + paymentGateway.id + "][" + title + "]")
            if (!paymentGateway.enabled) {
                mSkipped = true
                Log.d("Payment Gateway [$title] is disabled.")
                continue
            }
            // Don't use case sensitive strings here in switch case
            var gateway: PaymentGateway? = null
            when (id.toLowerCase()) {
                "cod" -> {
                    gateway = CashOnDeliveryGateway.create(listener)
                    if (paymentGateway.settings != null) {
                        gateway!!.gatewaySettings = paymentGateway.settings
                    }
                }
                "cop" -> {
                    gateway = CashOnPickupGateway.create(listener)
                    if (paymentGateway.settings != null) {
                        gateway!!.gatewaySettings = paymentGateway.settings
                    }
                }
                "cheque" -> {
                    gateway = ChequeGateway.create(listener)
                    gateway!!.setAccountDetails(paymentGateway.account_details)
                }
                "bacs" -> {
                    gateway = DirectBankGateway.create(listener)
                    gateway!!.setAccountDetails(paymentGateway.account_details)
                }
                "wc-booking-gateway" -> {
                    gateway = BookingGateway.create(listener)
                }
                "jetpack_custom_gateway", "jetpack_custom_gateway_2", "jetpack_custom_gateway_3" -> {
                    gateway = JetpackGateway.create(listener)
                    gateway!!.setAccountDetails(paymentGateway.account_details)
                    gateway.isEnabled = true
                }

                "razorpay" -> {
                    gateway = RazorpayGateway.getInstance()
                }
                "paystack" -> {
                    gateway = PayStackGateway.getInstance()
                }
                "paypal" -> {
                    gateway = PayPalGateway.getInstance()
                }
                "paypal_pro" -> {
                    gateway = PayPalProGateway.getInstance()
                }
                "tap", "tappay" -> {
                    gateway = TapPayGateway.getInstance()
                }
                "wc_gateway_gestpay_pro" -> {
                    gateway = GestpayGateway.getInstance()
                }
                "payu_in", "payuindia" -> {
                    gateway = PayUIndiaGateway.getInstance()
                }
                "ccavenue" -> {
                    gateway = CCAvenueGateway.getInstance()
                }
                "payu" -> {
                    gateway = PayUCoZaGateway.getInstance()
                }
                "dusupay" -> {
                    gateway = DusuPayGateway.getInstance()
                }
                "stripe" -> {
                    gateway = StripeGateway.getInstance()
                }
                "payulatam" -> {
                    gateway = PayULatamGateway.getInstance()
                }
                "braintree" -> {
                    gateway = BrainTreeGateway.getInstance()
                }
                "instamojo" -> {
                    gateway = InstaMojoGateway.getInstance()
                }
                "mygate" -> {
                    gateway = MyGateGateway.getInstance()
                }
                "authorizenet" -> {
                    gateway = AuthorizeNetGateway.instance
                }
                "pesapal" -> {
                    gateway = PesaPalGateway.getInstance()
                }
                "vcs" -> {
                    gateway = VcsCoZaGateway.getInstance()
                }
                "senangpay" -> {
                    gateway = SenangPayGateway.getInstance()
                }
                "mollie_wc_gateway_creditcard" -> {
                    gateway = MollieGateway.getInstance()
                }
                "paytm" -> {
                    gateway = PayTMGateway.getInstance()
                }
                "plugnpaydirect" -> {
                    gateway = PlugnPayGateway.getInstance()
                }
                "conektacard" -> {
                    gateway = ConektaGateway.getInstance()
                }
                "satispay" -> {
                    gateway = SatispayGateway.getInstance()
                }
                "paynow" -> {
                    gateway = SagepayGateway.getInstance() // Only paynow for SagePay is used for now.
                }
                "hesabe" -> {
                    gateway = HesabeGateway.getInstance()
                }
                "payfort" -> {
                    gateway = PayfortGateway.getInstance()
                }
                "eghl" -> {
                    gateway = BitbucketEghlGateway.getInstance() // Only EGHL for BitBucket is used for now.
                }
                else -> {
                    gateway = twistPayGateways.find { it.id == paymentGateway.id }
                    if (gateway == null) {
                        Log.d("[$title] is not available in TMStore")
                        mSkipped = true
                    }
                }
            }

            if (gateway != null) {
                addToPaymentGateway(activity, listener, paymentGateway, gateway)
            }
        }

        if (mSkipped && AppInfo.ENABLE_WEBVIEW_PAYMENT) {
            val title = String.format(getString(L.string.select_payment_from), activity.getString(R.string.app_name))
            val webPayGateway = WebPayGateway.createGateway(activity)
            webPayGateway.prepare(activity, listener, null)
            webPayGateway.title = title
            paymentGateways.add(webPayGateway)
        }
    }

    private fun addToPaymentGateway(activity: Activity, listener: PaymentGateway.PaymentListener, tm_paymentGateway: TM_PaymentGateway, paymentGateway: PaymentGateway) {
        // Check if gateway is enabled in our server configuration.
        if (paymentGateway.isEnabled) {
            paymentGateways.add(paymentGateway.prepare(activity, listener, tm_paymentGateway))
        } else {
            // Check if gateway is not in free gateways then show TMStore gateway.
            if (!mSkipped) {
                mSkipped = !TextUtils.isEmpty(tm_paymentGateway.id) && (tm_paymentGateway.id != "cod"
                        || tm_paymentGateway.id != "cop"
                        || tm_paymentGateway.id != "cheque"
                        || tm_paymentGateway.id != "bacs")
            }
        }
    }

    fun getPaymentGateway(id: Int): PaymentGateway? {
        return if (id < 0 || id >= paymentGateways.size) null else paymentGateways[id]
    }

    fun getPaymentGateway(id: String?): PaymentGateway? {
        if (id != null) {
            for (paymentGateway in paymentGateways) {
                if (paymentGateway.id.equals(id)) {
                    return paymentGateway;
                }
            }
        }
        return null;
    }

    fun removePaymentGateway(paymentGateway: PaymentGateway) {
        paymentGateways.remove(paymentGateway);
    }

    fun handleResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != PaymentGateway.REQUEST_PAYMENT) {
            return false
        }
        selectedGateway?.paymentListener?.let { listener ->
            if (resultCode == Activity.RESULT_OK && data != null) {
                listener.onPaymentSucceed(data.getIntExtra(Extras.ORDER_ID, 0))
            } else {
                listener.onPaymentFailed()
            }
        }
        return true
    }

    private fun parsePaymentGateways(activity: Activity) {
        // clear all twist pay gateways, since new gateways will override from json config
        twistPayGateways.clear()
        for (i in 0 until jsonArrayPayment!!.length()) {
            try {
                val jsonObject = jsonArrayPayment!!.getJSONObject(i)
                val gateway = jsonObject.getString("gateway")
                //TODO don't use case sensitive strings here in switch case
                when (gateway.toLowerCase()) {
                    "ccavenue" -> CCAvenueGateway.createGateway(activity, jsonObject)
                    "payumoney", "payubiz" -> PayUIndiaGateway.createGateway(activity, jsonObject)
                    "paypal" -> PayPalGateway.createGateway(activity, jsonObject)
                    "paypal payflow" -> PayPalProGateway.createGateway(activity, jsonObject)
                    "gestpay" -> GestpayGateway.createGateway(activity, jsonObject)
                    "paystack" -> PayStackGateway.createGateway(activity, jsonObject)
                    "payusa" -> PayUCoZaGateway.createGateway(activity, jsonObject)
                    "stripe" -> StripeGateway.createGateway(activity, jsonObject)
                    "payulatam" -> PayULatamGateway.createGateway(activity, jsonObject)
                    "braintree" -> BrainTreeGateway.createGateway(activity, jsonObject)
                    "mygate" -> MyGateGateway.createGateway(activity, jsonObject)
                    "instamojo" -> InstaMojoGateway.createGateway(activity, jsonObject)
                    "authorizenet" -> AuthorizeNetGateway.createGateway(activity, jsonObject)
                    "pesapal" -> PesaPalGateway.createGateway(activity, jsonObject)
                    "vcs" -> VcsCoZaGateway.createGateway(activity, jsonObject)
                    "dusupay" -> DusuPayGateway.createGateway(activity, jsonObject)
                    "tappay" -> TapPayGateway.createGateway(activity, jsonObject)
                    "senangpay" -> SenangPayGateway.createGateway(activity, jsonObject)
                    "mollie" -> MollieGateway.createGateway(activity, jsonObject)
                    "paytm" -> PayTMGateway.createGateway(activity, jsonObject)
                    "plugnpay" -> PlugnPayGateway.createGateway(activity, jsonObject)
                    "razorpay" -> RazorpayGateway.createGateway(activity, jsonObject)
                    "conektacard" -> ConektaGateway.createGateway(activity, jsonObject)
                    "satispay" -> SatispayGateway.createGateway(activity, jsonObject)
                    "sagepay_paynow" -> SagepayGateway.createGateway(activity, jsonObject)
                    "hesabe" -> HesabeGateway.createGateway(activity, jsonObject)
                    "payfort" -> PayfortGateway.createGateway(activity, jsonObject)
                    "bitbucket_eghl" -> BitbucketEghlGateway.createGateway(activity, jsonObject)
                    "twistpay" -> {
                        twistPayGateways.add(TwistPayGateway().create(activity, jsonObject))
                    }
                }
            } catch (e: JSONException) {
                Log.e("Error while parsing payments data")
                e.printStackTrace()
            }
        }
    }
}