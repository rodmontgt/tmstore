package com.twist.tmstore

import android.webkit.JavascriptInterface

class WebLoginInterface {

    private var webResponseListener: WebResponseListener? = null

    fun setWebResponseListener(webResponseListener: WebResponseListener) {
        this.webResponseListener = webResponseListener
    }

    @JavascriptInterface
    fun showToast(msgLogin: String) {
        webResponseListener?.onResponseReceived(100, msgLogin)
    }

    interface WebResponseListener {
        fun onResponseReceived(code: Int, response: String)
    }
}