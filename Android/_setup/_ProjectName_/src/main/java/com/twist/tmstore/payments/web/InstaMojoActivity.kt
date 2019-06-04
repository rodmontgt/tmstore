package com.twist.tmstore.payments.web

import android.annotation.SuppressLint
import android.os.Bundle
import android.util.Base64
import android.view.View
import android.view.ViewGroup
import android.webkit.WebSettings
import android.webkit.WebView
import android.widget.LinearLayout
import com.twist.tmstore.BasePaymentActivity
import java.util.*

fun String.toBase64(): String {
    return Base64.encodeToString(this.toByteArray(), Base64.NO_WRAP)
}

class InstaMojoActivity : BasePaymentActivity() {
    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val webView = WebView(this)
        webView.layoutParams = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
        setContentView(webView)
        setupActionBarHomeAsUp("InstaMojo")

        val bundle = intent.extras
        if (bundle != null) {
            // Minimum amount value is 9 .
            val amount = bundle.getString("amount")
            val orderid = bundle.getString("orderid")
            val phone = bundle.getString("phone")
            val name = bundle.getString("name")
            val email = bundle.getString("email")

            val baseUrl = bundle.getString("baseurl")
            val successUrl = bundle.getString("surl")
            val failureUrl = bundle.getString("furl")

            webView.apply {
                webViewClient = PaymentWebClient(baseUrl, object : PaymentWebResponseHandler() {
                    override fun onFinished(view: WebView, url: String) {
                        if (url.startsWith(successUrl)) {
                            onPaymentSuccess()
                        } else if (url.startsWith(failureUrl)) {
                            onPaymentError()
                        }
                    }
                })
                settings.builtInZoomControls = true
                settings.cacheMode = WebSettings.LOAD_NO_CACHE
                settings.domStorageEnabled = true
                settings.javaScriptEnabled = true
                settings.setSupportZoom(true)
                settings.useWideViewPort = false
                settings.loadWithOverviewMode = false
                visibility = View.VISIBLE
                clearHistory()
                clearCache(true)
            }
            val params = HashMap<String, String>().apply {
                this["purpose"] = "orderId : $orderid".toBase64()
                this["amount"] = amount.toBase64()
                this["phone"] = phone.toBase64()
                this["buyer_name"] = name.toBase64()
                this["email"] = email.toBase64()
            }
            postWebRequest(webView, baseUrl, params.entries)
        }
    }

    override fun onActionBarRestored() {}
}