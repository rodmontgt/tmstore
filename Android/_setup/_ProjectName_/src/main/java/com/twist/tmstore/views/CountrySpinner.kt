package com.twist.tmstore.views;

import android.annotation.SuppressLint
import android.content.Context
import android.content.res.Resources
import android.support.v7.widget.AppCompatSpinner
import android.support.v7.widget.ThemedSpinnerAdapter
import android.telephony.TelephonyManager
import android.util.AttributeSet
import android.view.View
import android.view.ViewGroup
import android.widget.AdapterView
import android.widget.ArrayAdapter
import com.google.gson.Gson
import com.google.gson.annotations.SerializedName
import com.twist.tmstore.L
import com.twist.tmstore.R
import com.utils.Log
import kotlinx.android.synthetic.main.country_spinner_dropdown_item.view.*
import kotlinx.android.synthetic.main.country_spinner_item.view.*
import java.util.*

data class Country(val id: Int,
                   val iso: String,
                   val iso3: String,
                   val name: String,
                   @SerializedName("display_name") val displayName: String,
                   @SerializedName("num_code") val numCode: Int,
                   @SerializedName("phone_code") @JvmField val phoneCode: Int)

private val LETTERS = arrayOf(
        "\uD83C\uDDE6",
        "\uD83C\uDDE7",
        "\uD83C\uDDE8",
        "\uD83C\uDDE9",
        "\uD83C\uDDEA",
        "\uD83C\uDDEB",
        "\uD83C\uDDEC",
        "\uD83C\uDDED",
        "\uD83C\uDDEE",
        "\uD83C\uDDEF",
        "\uD83C\uDDF0",
        "\uD83C\uDDF1",
        "\uD83C\uDDF2",
        "\uD83C\uDDF3",
        "\uD83C\uDDF4",
        "\uD83C\uDDF5",
        "\uD83C\uDDF6",
        "\uD83C\uDDF7",
        "\uD83C\uDDF8",
        "\uD83C\uDDF9",
        "\uD83C\uDDFA",
        "\uD83C\uDDFB",
        "\uD83C\uDDFC",
        "\uD83C\uDDFD",
        "\uD83C\uDDFE",
        "\uD83C\uDDFF")

private fun getFlag(iso: String): String =
        StringBuilder().apply {
            iso.forEach {
                append(LETTERS[it.toInt() - 65])
            }
        }.toString()


class CountrySpinner : AppCompatSpinner {

    constructor(context: Context) : super(context)

    constructor(context: Context, attrs: AttributeSet) : super(context, attrs)

    private lateinit var mCountries: List<Country>

    @JvmField
    var onCountrySelectedListener: OnCountrySelectedListener? = null


    fun getDefaultCountryName(): String {
        return Locale("",
                (context.applicationContext.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager)
                        .let {
                            if (it.simState == TelephonyManager.SIM_STATE_READY)
                                it.simCountryIso.toUpperCase()
                            else Locale.getDefault().country
                        }
        ).displayName
    }

//	private val countryList: Array<Country>
//		get() {
//			return Gson().fromJson(
//				context.applicationContext.assets.open(L.getInstance().language.defaultLocale + "countries.json")
//					.bufferedReader()
//					.use { it.readText() }, Array<Country>::class.java
//			)
//		}

    private fun getCountryList(fileName: String): Array<Country> {
        val countryFile = try {
            context.applicationContext.assets.open(fileName)
        } catch (e: Exception) {
            context.applicationContext.assets.open("countries.json")
        }
        return Gson().fromJson(
                countryFile
                        .bufferedReader()
                        .use { it.readText() }, Array<Country>::class.java
        )
    }

    interface OnCountrySelectedListener {
        fun onCountrySelected(country: Country)
    }

    fun setCountries(defaultCountryName: String) {
        val defaultLocale = L.getInstance().language.defaultLocale
        Log.D("Default Locale ${defaultLocale}")

        mCountries = getCountryList("${defaultLocale}_countries.json").toList()

        var isCountryFound = false
        for (country in mCountries) {
            if (isCountryFound) {
                break
            }
            isCountryFound = country.displayName.equals(defaultCountryName, true)
        }

        val countryList = if (isCountryFound && !getSortedCountryList(defaultLocale, defaultCountryName).isEmpty()) {
            getSortedCountryList(defaultLocale, defaultCountryName)
        } else {
            getCountryList("countries.json").toList()
        }

        adapter = CountrySpinnerAdapter(context, countryList)
        onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(adapterView: AdapterView<*>, view: View, position: Int, id: Long) {
                val countryObj = adapterView.getItemAtPosition(position) as Country
                val country = mCountries.first { it.id == countryObj.id }
                onCountrySelectedListener?.onCountrySelected(country)
            }

            override fun onNothingSelected(adapterView: AdapterView<*>) {}
        }
    }

    private fun getSortedCountryList(defaultLocale: String, myCountry: String): List<Country> {
        val countryNameList = getCountryList("${defaultLocale}_countries.json").toList().asSequence()
                .map { it.displayName }
                .toMutableList()
                .apply {
                    sort() // sort countryList.toList() in ascending order (A to Z)
                    remove(myCountry) // remove country from list
                    add(0, myCountry) // add it to top in the list
                }

        val countryList = mutableListOf<Country>()
        for (country_name in countryNameList) {
            for (country in mCountries) {
                if (country.displayName.equals(country_name, true)) {
                    countryList.add(country)
                }
            }
        }
        return countryList
    }

    inner class CountrySpinnerAdapter(context: Context, objects: List<Country>) :
            ArrayAdapter<Country>(context, R.layout.country_spinner_item, R.id.text_country_code, objects), ThemedSpinnerAdapter {

        private val mDropDownHelper: ThemedSpinnerAdapter.Helper = ThemedSpinnerAdapter.Helper(context)

        @SuppressLint("SetTextI18n")
        override fun getView(position: Int, convertView: View?, parent: ViewGroup?): View {
            val view = super.getView(position, convertView, parent)
                    ?: mDropDownHelper.dropDownViewInflater.inflate(R.layout.country_spinner_item, parent, false)

            val countryObj = getItem(position) as Country
            val country = mCountries.first { it.id == countryObj.id }
            view.text_country_code.text = "+${country.phoneCode}"//${getFlag(country.iso)}
            return view
        }

        @SuppressLint("SetTextI18n")
        override fun getDropDownView(position: Int, convertView: View?, parent: ViewGroup): View {
            val view = convertView
                    ?: mDropDownHelper.dropDownViewInflater.inflate(R.layout.country_spinner_dropdown_item, parent, false)

            val countryObj = getItem(position) as Country
            val country = mCountries.first { it.id == countryObj.id }

            view.text_country.text = countryObj.displayName
            view.text_flag.text = getFlag(country.iso)
            view.text_code.text = "+${country.phoneCode}"
            return view
        }

        override fun getDropDownViewTheme(): Resources.Theme? {
            return mDropDownHelper.dropDownViewTheme
        }

        override fun setDropDownViewTheme(theme: Resources.Theme?) {
            mDropDownHelper.dropDownViewTheme = theme
        }
    }
}
