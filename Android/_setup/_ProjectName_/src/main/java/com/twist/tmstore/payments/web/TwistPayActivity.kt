package com.twist.tmstore.payments.web

import android.annotation.SuppressLint
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.webkit.WebSettings
import android.webkit.WebView
import android.widget.LinearLayout
import com.twist.tmstore.BasePaymentActivity
import com.utils.appName
import com.utils.putBundle
import java.util.*

class TwistPayActivity : BasePaymentActivity() {

    companion object {
        const val EXTRA_TITLE = "title"
        const val EXTRA_ORDER_ID = "order_id"
        const val EXTRA_AMOUNT = "amount"
        const val EXTRA_CONFIG_DATA = "config_data"
        const val EXTRA_USER_DATA = "user_data"
        const val EXTRA_BASE_URL = "base_url"
        const val EXTRA_SUCCESS_URL = "success_url"
        const val EXTRA_FAILURE_URL = "failure_url"

        const val PARAM_ORDER_ID = "order_id"
        const val PARAM_AMOUNT = "amount"
    }

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val webView = WebView(this)
        webView.layoutParams = LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
        setContentView(webView)
        intent.extras?.let { bundle ->
            val title = bundle.getString(EXTRA_TITLE)
            val baseUrl = bundle.getString(EXTRA_BASE_URL)
            val successUrl = bundle.getString(EXTRA_SUCCESS_URL)
            val failureUrl = bundle.getString(EXTRA_FAILURE_URL)
            val amount = bundle.getString(EXTRA_AMOUNT)
            val orderId = bundle.getString(EXTRA_ORDER_ID)
            val configData = bundle.getBundle(EXTRA_CONFIG_DATA)
            val userData = bundle.getBundle(EXTRA_USER_DATA)

            setupActionBarHomeAsUp(if (title.isNotBlank()) title else appName)

            webView.apply {
                this.settings.builtInZoomControls = true
                this.settings.cacheMode = WebSettings.LOAD_NO_CACHE
                this.settings.domStorageEnabled = true
                this.settings.javaScriptEnabled = true
                this.settings.setSupportZoom(true)
                this.settings.useWideViewPort = false
                this.settings.loadWithOverviewMode = false
                this.visibility = View.VISIBLE
                this.clearHistory()
                this.clearCache(true)
                this.webViewClient = PaymentWebClient(baseUrl, object : PaymentWebResponseHandler() {
                    override fun onFinished(view: WebView, url: String) {
                        if (url.startsWith(successUrl)) {
                            onPaymentSuccess()
                        } else if (url.startsWith(failureUrl)) {
                            onPaymentError()
                        }
                    }
                })
            }
            val args = HashMap<String, String>().apply {
                put(PARAM_ORDER_ID, orderId)
                put(PARAM_AMOUNT, amount)
                putBundle(configData)
                putBundle(userData)
            }
            postWebRequest(webView, baseUrl, args.entries)
        }
    }

    override fun onActionBarRestored() {}
}