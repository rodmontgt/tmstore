package com.twist.tmstore.payments.web

import android.annotation.SuppressLint
import android.app.Activity
import android.app.ProgressDialog
import android.content.Intent
import android.os.AsyncTask
import android.os.Bundle
import android.widget.Toast
import com.payumoney.core.PayUmoneyConfig
import com.payumoney.core.PayUmoneyConstants.*
import com.payumoney.core.PayUmoneySdkInitializer
import com.payumoney.core.entity.TransactionResponse
import com.payumoney.sdkui.ui.utils.PayUmoneyFlowManager
import com.payumoney.sdkui.ui.utils.ResultModel
import com.twist.tmstore.BasePaymentActivity
import com.twist.tmstore.L
import com.twist.tmstore.R
import com.utils.Log
import java.lang.ref.WeakReference
import java.math.BigDecimal
import java.math.RoundingMode
import java.net.HttpURLConnection
import java.net.URL
import java.util.*

private fun StringBuilder.append(key: String, value: String?): StringBuilder {
    return if (value == null) this else this.append("$key=$value&")
}

class PayUMoneyActivity : BasePaymentActivity() {

    private var mMerchantKey: String? = null
    private var mMerchantId: String? = null
    private var mSuccessUrl: String? = ""
    private var mFailedUrl: String? = ""
    private var mHashUrl: String? = ""
    private var mSalt: String? = ""
    private var mTitle = ""
    private val mProductName = "My Product"
    private var mTxnId: String? = null
    private var mFirstName: String? = null
    private var mEmailId: String? = null
    private var mAmount: Double = 0.toDouble()
    private var mPhone: String? = null

    private lateinit var mPaymentParams: PayUmoneySdkInitializer.PaymentParam

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val bundle = intent.extras ?: return
        mTitle = bundle.getString("title", "PayUmoney")
        setupActionBarHomeAsUp(mTitle)
        mMerchantKey = bundle.getString("merchant_key")
        mMerchantId = bundle.getString("merchant_id")
        mFirstName = bundle.getString("name")
        mEmailId = bundle.getString("email")
        mAmount = bundle.getFloat("amount").toDouble()
        mPhone = bundle.getString("phone")
        mSuccessUrl = bundle.getString("surl")
        mFailedUrl = bundle.getString("furl")
        mHashUrl = bundle.getString("hurl")
        mSalt = bundle.getString("salt")

        val id = Random().nextInt() + System.currentTimeMillis() / 1000L
        mTxnId = hashCal("SHA-256", id.toString()).substring(0, 20)
        mAmount = BigDecimal(mAmount).setScale(0, RoundingMode.UP).toInt().toDouble()
        launchPayUMoneyFlow()
    }

    override fun onActionBarRestored() {}

    private fun launchPayUMoneyFlow() {
        PayUmoneyConfig.getInstance().apply {
            doneButtonText = getString(L.string.done)
            payUmoneyActivityTitle = mTitle
        }
        var amount = 0.0
        try {
            amount = mAmount
        } catch (e: Exception) {
        }

        val builder = PayUmoneySdkInitializer.PaymentParam.Builder()
                .setAmount(amount.toString())
                .setTxnId(mTxnId)
                .setPhone(mPhone)
                .setProductName(mProductName)
                .setFirstName(mFirstName)
                .setEmail(mEmailId)
                .setUdf1("")
                .setUdf2("")
                .setUdf3("")
                .setUdf4("")
                .setUdf5("")
                .setUdf6("")
                .setUdf7("")
                .setUdf8("")
                .setUdf9("")
                .setUdf10("")
                .setsUrl(mSuccessUrl)
                .setfUrl(mFailedUrl)
                .setKey(mMerchantKey)
                .setMerchantId(mMerchantId)
                .setIsDebug(false)
        try {
            mPaymentParams = builder.build()
            if (mHashUrl.isNullOrBlank()) {
                mPaymentParams = calculateHashAndInitiatePayment(mPaymentParams)
            } else {
                PayUmoneyFlowManager.startPayUMoneyFlow(mPaymentParams, this, R.style.PayUmoneyTheme, true)
                getHashFromServer(mPaymentParams.params)
            }
        } catch (e: Exception) {
            e.printStackTrace()
            onPaymentError()
        }
    }

    private fun calculateHashAndInitiatePayment(paymentParam: PayUmoneySdkInitializer.PaymentParam): PayUmoneySdkInitializer.PaymentParam {
        val hash = hashCal("SHA-512", paymentParam.params.let { params ->
            StringBuilder().apply {
                append(params[KEY]).append("|")
                append(params[TXNID]).append("|")
                append(params[AMOUNT]).append("|")
                append(params[PRODUCT_INFO]).append("|")
                append(params[FIRSTNAME]).append("|")
                append(params[EMAIL]).append("|")
                append(params[UDF1]).append("|")
                append(params[UDF2]).append("|")
                append(params[UDF3]).append("|")
                append(params[UDF4]).append("|")
                append(params[UDF5]).append("||||||")
                append(mSalt)
            }.toString()
        })
        paymentParam.setMerchantHash(hash)
        return paymentParam
    }


    private fun getHashFromServer(params: HashMap<String, String>) {
        GetHashesFromServerTask(this).execute(mHashUrl, StringBuilder().apply {
            append("type", "request")
            append(KEY, params[KEY])
            append(AMOUNT, params[AMOUNT])
            append(TXNID, params[TXNID])
            append(EMAIL, params[EMAIL])
            append(PRODUCT_INFO_STRING, params[PRODUCT_INFO])
            append(FIRST_NAME_STRING, params[FIRSTNAME])
            append(UDF1, params[UDF1])
            append(UDF2, params[UDF2])
            append(UDF3, params[UDF3])
            append(UDF4, params[UDF4])
            append(UDF5, params[UDF5])
        }.dropLastWhile { it == '&' }.toString())
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        Log.d("PayUmoney => request code $requestCode resultcode $resultCode")
        if (requestCode != PayUmoneyFlowManager.REQUEST_CODE_PAYMENT) {
            Log.d(TAG, "PayUmoney =>  Transaction cancelled, back key pressed.")
            onBackPressed()
            return
        }

        if (resultCode == Activity.RESULT_OK && data != null) {
            val transactionResponse = data.getParcelableExtra<TransactionResponse>(PayUmoneyFlowManager.INTENT_EXTRA_TRANSACTION_RESPONSE)
            val resultModel = data.getParcelableExtra<ResultModel>(PayUmoneyFlowManager.ARG_RESULT)
            when {
                transactionResponse?.getPayuResponse() != null -> {
                    val payuResponse = transactionResponse.getPayuResponse()
                    Log.d(TAG, "PayUmoney => Payu's Data : $payuResponse\n\n\n Merchant's Data: $transactionResponse.transactionDetails")
                    when (transactionResponse.transactionStatus) {
                        TransactionResponse.TransactionStatus.SUCCESSFUL -> onPaymentSuccess()
                        else -> onPaymentError()
                    }
                }
                resultModel?.error != null -> {
                    Log.d(TAG, "PayUmoney =>  Error response : " + resultModel.error.transactionResponse)
                    onPaymentError()
                }
                else -> {
                    Log.d(TAG, "PayUmoney =>  Transaction cancelled, no errors, no response. Data => " + data.toString())
                    onPaymentError()
                }
            }
        } else {
            Log.d(TAG, "PayUmoney =>  Transaction cancelled, no data returned.")
            onPaymentError()
        }
    }

    companion object {
        private const val TAG = "PayUMoneyActivity"

        private class GetHashesFromServerTask(activity: PayUMoneyActivity) : AsyncTask<String, String, String>() {

            private val activityReference: WeakReference<PayUMoneyActivity> = WeakReference(activity)
            private var progressDialog: ProgressDialog? = null

            override fun onPreExecute() {
                super.onPreExecute()
                activityReference.get()?.let { activity ->
                    progressDialog = ProgressDialog(activity)
                    progressDialog?.setMessage(activity.getString(L.string.please_wait))
                    progressDialog?.show()
                }
            }

            override fun doInBackground(vararg postParams: String): String {
                return try {
                    val url = URL(postParams[0])
                    val postParamsByte = postParams[1].toByteArray(charset("UTF-8"))
                    val connection = url.openConnection() as HttpURLConnection
                    connection.apply {
                        requestMethod = "POST"
                        setRequestProperty("Content-Type", "application/x-www-form-urlencoded")
                        setRequestProperty("Content-Length", postParamsByte.size.toString())
                        doOutput = true
                        outputStream.write(postParamsByte)
                    }.inputStream.bufferedReader().use { it.readText() }
                } catch (e: Exception) {
                    e.printStackTrace()
                    ""
                }
            }

            override fun onPostExecute(merchantHash: String) {
                super.onPostExecute(merchantHash)
                activityReference.get()?.let { activity ->
                    progressDialog?.dismiss()
                    if (merchantHash.isNotEmpty()) {
                        activity.mPaymentParams.setMerchantHash(merchantHash)
                        PayUmoneyFlowManager.startPayUMoneyFlow(activity.mPaymentParams, activity, R.style.PayUmoneyTheme, true)
                    } else {
                        Toast.makeText(activity, "Could not generate hash", Toast.LENGTH_SHORT).show()
                    }
                }
            }
        }
    }
}