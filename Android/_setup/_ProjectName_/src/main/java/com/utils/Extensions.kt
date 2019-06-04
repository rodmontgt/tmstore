package com.utils

import android.app.Activity
import android.app.Fragment
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.PorterDuff
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Bundle
import android.support.annotation.DrawableRes
import android.support.annotation.StringRes
import android.support.v4.content.ContextCompat
import android.text.Html
import android.text.Spanned
import android.util.TypedValue
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import org.json.JSONArray
import org.json.JSONObject
import java.io.IOException
import java.text.DecimalFormat
import java.text.SimpleDateFormat
import java.util.*


class Extensions {}

// Global functions

inline fun <reified T : Activity> Activity.startActivity() {
    startActivity(Intent(this, T::class.java))
}

fun <T : View> View.findView(id: Int) = this.findViewById(id) as T

fun dpToPx(context: Context?, value: Int): Int {
    return (value * context!!.resources.displayMetrics.density).toInt()
}

fun <T> Boolean.trueIf(o1: T, o2: T): T {
    return if (this) o1 else o2
}

inline fun <T> T?.guard(block: T.() -> Unit): T? {
    if (this == null) block(); return this
}

inline infix fun <T> T.or(block: () -> T) = this ?: block()

/*
*  Extensions related to View, ViewGroup and Layout
* */

fun View.show() {
    this.visibility = View.VISIBLE
}

fun View.hide() {
    this.visibility = View.GONE
}

fun View.gone() {
    this.visibility = View.GONE
}

fun View.invisible() {
    this.visibility = View.INVISIBLE
}

fun View.setVisible(visible: Boolean) {
    this.visibility = if (visible) View.VISIBLE else View.GONE
}

fun View.isVisible(): Boolean {
    return this.visibility == View.VISIBLE
}

fun ViewGroup.inflate(resource: Int): View {
    return LayoutInflater.from(this.context).inflate(resource, this, false)
}

fun Fragment.allowWindowTouch(allow: Boolean) {
    activity?.window?.run {
        val flag = WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE
        when {
            allow -> clearFlags(flag)
            else -> setFlags(flag, flag)
        }
    }
}

/* Extensions related to String */

fun String.toSpanned(): Spanned {
    @Suppress("DEPRECATION")
    return when {
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.N -> Html.fromHtml(this, Html.FROM_HTML_MODE_LEGACY)
        else -> Html.fromHtml(this)
    }
}

fun String?.optIfNullOrEmpty(optional: String): String {
    return if (this != null && !this.isEmpty()) this else optional
}

/*
*   Extensions related to Context
* */

val Context.appName: String
    get() {
        return this.getString(this.applicationInfo.labelRes)
    }

fun Context.getAttribute(attributeId: Int): Int {
    val typedValue = TypedValue()
    theme.resolveAttribute(attributeId, typedValue, true)
    return typedValue.data
}

fun Context.getColorX(id: Int): Int {
    return ContextCompat.getColor(this, id)
}

fun Context.getDrawable(drawableResId: Int, mutate: Boolean = false): Drawable? {
    val drawable = ContextCompat.getDrawable(this, drawableResId)
    return if (mutate) drawable!!.mutate() else drawable
}

fun Context.getPrimaryDarkColor(): Int {
    val typedValue = TypedValue()
    val a = this.obtainStyledAttributes(typedValue.data, intArrayOf(R.attr.colorPrimaryDark))
    val color = a.getColor(0, 0)
    a.recycle()
    return color
}

fun Context.getAccentColor(): Int {
    val typedValue = TypedValue()
    val a = this.obtainStyledAttributes(typedValue.data, intArrayOf(R.attr.colorAccent))
    val color = a.getColor(0, 0)
    a.recycle()
    return color
}

fun Context.getAttributeColor(colorAttributeId: Int): Int {
    val typedValue = TypedValue()
    val a = this.obtainStyledAttributes(typedValue.data, intArrayOf(colorAttributeId))
    val color = a.getColor(0, 0)
    a.recycle()
    return color
}

fun Context.getTintedDrawable(@DrawableRes resId: Int, tintColor: Int, mutate: Boolean = true): Drawable {
    var drawable = ContextCompat.getDrawable(this, resId)!!
    if (mutate) {
        drawable = drawable.mutate()
    }
    drawable.setColorFilter(tintColor, PorterDuff.Mode.SRC_IN)
    return drawable
}

/* Extensions related to app specific modules */

fun <T> List<T>?.isNullOrEmpty(): Boolean {
    return this == null || this.isEmpty()
}

/*
*  Extensions related to JSONObject and JSONArray
* */

fun JSONObject.isNotNull(key: String): Boolean {
    return this.has(key) && !this.isNull(key)
}

fun String?.toInt(fallback: Int): Int {
    return if (this.isNullOrEmpty()) fallback else this!!.toInt()
}

fun Double?.toDecimalFormat(): String {
    return when {
        this != null && this != 0.0 -> DecimalFormat("#####0.00###").format(this).toString()
        else -> this.toString()
    }
}

fun getCurrentDate(): String {
    val df = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.US)
    val createdDate = df.format(Calendar.getInstance().time)
    return createdDate
}

fun Long?.getTimeByTimeStamp(): String {
    val gregorianCalendar = GregorianCalendar()
    gregorianCalendar.timeInMillis = this!!
//    val c = Calendar.getInstance()
//    c.time = Date().also{ it.time = this}
//    c.time = gregorianCalendar.time
    val sdf = SimpleDateFormat("dd-MM-yyyy HH:mm:ss", Locale.US)
    return sdf.format(gregorianCalendar.time)
}

fun Context.loadAssetFile(fileName: String, charsetName: String = "UTF-8"): String {
    return try {
        assets.open(fileName).readBytes().toString(charset(charsetName))
    } catch (e: IOException) {
        e.printStackTrace()
        ""
    }
}

/*
* Extensions for JSON
* */

inline fun <reified T : Any> JSONArray.forEach(action: (T) -> Unit) {
    for (i in 0 until length())
        action(get(i) as T)
}

inline fun JSONArray.forEachJSONObject(action: (JSONObject) -> Unit) {
    for (i in 0 until length())
        action(getJSONObject(i))
}

inline fun JSONArray.forEachJSONArray(action: (JSONArray) -> Unit) {
    for (i in 0 until length())
        action(getJSONArray(i))
}

/*
*  HashMap extensions
*
* */

fun HashMap<String, String>.putBundle(bundle: Bundle) {
    for (key in bundle.keySet())
        this[key] = bundle.getString(key)
}

/*
* Extensions for Preferences
* */

fun SharedPreferences.getString(context: Context, @StringRes stringResId: Int, @StringRes defaultResId: Int): String {
    return getString(context.getString(stringResId), context.getString(defaultResId))!!
}
