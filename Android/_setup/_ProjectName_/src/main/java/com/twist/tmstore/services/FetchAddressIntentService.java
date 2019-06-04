package com.twist.tmstore.services;

import android.app.IntentService;
import android.content.Intent;
import android.location.Address;
import android.location.Geocoder;
import android.os.Bundle;
import android.support.v4.os.ResultReceiver;
import android.text.TextUtils;
import android.util.Log;

import com.twist.tmstore.Constants;
import com.twist.tmstore.L;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;


/**
 * Created by Twist Mobile on 01-12-2016.
 */

public class FetchAddressIntentService extends IntentService {
    private static final String TAG = FetchAddressIntentService.class.getSimpleName();
    protected ResultReceiver mReceiver;
    private String errorMessage;
    private double latitude;
    private double longitude;

    public FetchAddressIntentService(String name) {
        super(name);
    }

    public FetchAddressIntentService() {
        super(TAG);
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        Geocoder geocoder = new Geocoder(this, Locale.getDefault());
        List<Address> addresses = null;
        latitude = intent.getDoubleExtra(Constants.LAT, 22.2);
        longitude = intent.getDoubleExtra(Constants.LNG, 33.3);
        mReceiver = intent.getParcelableExtra(Constants.RECEIVER);

        try {
            addresses = geocoder.getFromLocation(latitude, longitude, 1);
        } catch (IOException ioException) {
            errorMessage = getString(L.string.service_not_available);
            Log.e(TAG, errorMessage, ioException);
        } catch (IllegalArgumentException illegalArgumentException) {
            errorMessage = getString(L.string.invalid_lat_long_used);
            Log.e(TAG, errorMessage + ". " + "Latitude = " + latitude + ", Longitude = " + longitude, illegalArgumentException);
        }

        if (addresses == null || addresses.size() == 0) {
            if (errorMessage != null && errorMessage.isEmpty()) {
                errorMessage = getString(L.string.no_address_found);
                Log.e(TAG, errorMessage);
            }
            deliverResultToReceiver(Constants.FAILURE_RESULT, errorMessage);
        } else {
            Address address = addresses.get(0);
            ArrayList<String> addressFragments = new ArrayList<>();
            addressFragments.add(0, address.getLocality());
            addressFragments.add(1, address.getPostalCode());
            addressFragments.add(2, address.getAdminArea());
            addressFragments.add(3, address.getAddressLine(0));
            addressFragments.add(4, address.getCountryName());
            Log.i(TAG, getString(L.string.address_found));
            deliverResultToReceiver(Constants.SUCCESS_RESULT,
                    TextUtils.join(System.getProperty("line.separator"),
                            addressFragments));
        }
    }

    public String getString(String key) {
        return L.getString(key);
    }

    private void deliverResultToReceiver(int resultCode, String message) {
        Bundle bundle = new Bundle();
        bundle.putString(Constants.RESULT_DATA_KEY, message);
        mReceiver.send(resultCode, bundle);
    }
}
