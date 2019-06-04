package com.twist.tmstore.fragments.filters;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.location.Geocoder;
import android.os.Bundle;
import android.support.design.widget.Snackbar;
import android.support.design.widget.TextInputLayout;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.common.GooglePlayServicesRepairableException;
import com.google.android.gms.location.places.Place;
import com.google.android.gms.location.places.ui.PlaceAutocomplete;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.twist.dataengine.entities.TM_ProductFilter;
import com.twist.dataengine.entities.UserFilter;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.services.LocationTracker;
import com.utils.Helper;
import com.utils.Log;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import pl.tajchert.nammu.Nammu;
import pl.tajchert.nammu.PermissionCallback;

/**
 * Created by Twist Mobile on 9/18/2017.
 */

public class Fragment_FilterByLocation extends BaseFilterFragment {

    private Context mContext;

    private UserFilter.GeoLocation geoLocation;

    private View geoLocationViewMain;
    private EditText textFindLocation;

    private LocationTracker gps;
    private static final int REQUEST_CODE_AUTOCOMPLETE = 1001;

    private LatLng deviceLatLng = new LatLng(0, 0);

    private static final String[] DISTANCE_UNITS = {
            "metric",
            //"imperial"
    };

    String selectLocationRange;

    public static Fragment_FilterByLocation newInstance(TM_ProductFilter productFilter, UserFilter userFilter, FilterUpdateListener filterUpdateListener) {
        Fragment_FilterByLocation fragment = new Fragment_FilterByLocation();
        fragment.setFilterUpdateListener(filterUpdateListener);
        fragment.productFilter = productFilter;
        fragment.userFilter = userFilter;
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_filter_bylocation, container, false);

        mContext = view.getContext();
        if (geoLocation == null) {
            geoLocation = userFilter.createGeoLocation();
        }

        geoLocationViewMain = view.findViewById(R.id.geolocation_viewmain);
        Button btnMyLocation = (Button) view.findViewById(R.id.btn_my_location);
        btnMyLocation.setText(getString(L.string.text_autofill));
        Helper.stylize(btnMyLocation);
        Helper.setDrawableLeftOnButton(((Activity) mContext), btnMyLocation, R.drawable.ic_vc_my_location, true);
        btnMyLocation.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                getCurrentLocation(true);
            }
        });

        TextInputLayout labelLocation = ((TextInputLayout) view.findViewById(R.id.label_loca));
        Helper.stylize(labelLocation);
        labelLocation.setHint(getString(L.string.search_location));

        textFindLocation = (EditText) view.findViewById(R.id.text_find_loc);
        Helper.setDrawableLeft(textFindLocation, R.drawable.ic_vc_location);
        if (!TextUtils.isEmpty(AppUser.getInstance().mylocation)) {
            textFindLocation.setText(AppUser.getInstance().mylocation);
        }
        textFindLocation.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                getCurrentLocation(false);
            }
        });
        textFindLocation.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                if (hasFocus) {
                    getCurrentLocation(false);
                }
            }
        });

        TextView titleRange = (TextView) view.findViewById(R.id.title_range);
        titleRange.setText(getString(L.string.title_range));

        TextInputLayout labelLocationRange = ((TextInputLayout) view.findViewById(R.id.label_loc_range));
        Helper.stylize(labelLocationRange);
        labelLocationRange.setHint(getString(L.string.title_range));

        EditText textLocationRange = (EditText) view.findViewById(R.id.text_loc_range);
        if (!TextUtils.isEmpty(geoLocation.radius)) {
            textLocationRange.setText(geoLocation.radius);
        }
        textLocationRange.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                geoLocation.radius = !TextUtils.isEmpty(s.toString().trim()) ? s.toString().trim() : "";
            }

            @Override
            public void afterTextChanged(Editable s) {
            }
        });


        TextView titleLocRangeIn = (TextView) view.findViewById(R.id.title_range_in);
        titleLocRangeIn.setText(getString(L.string.title_range_in));

        Spinner spinnerLocRangeIn = (Spinner) view.findViewById(R.id.spinner_loc_range);
        List<String> rangeOptions = new ArrayList<>();
        rangeOptions.add(getString(L.string.kilometer));
//        rangeOptions.add(getString(L.string.miles));
        spinnerLocRangeIn.setAdapter(new ArrayAdapter<>(getActivity(), android.R.layout.simple_list_item_1, rangeOptions));
        spinnerLocRangeIn.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int selectedId, long l) {
                if (selectedId >= 0) {
                    selectLocationRange = adapterView.getItemAtPosition(selectedId).toString();
                    geoLocation.unit = DISTANCE_UNITS[selectedId];
                }
            }

            @Override
            public void onNothingSelected(AdapterView<?> adapterView) {
                selectLocationRange = "";
            }
        });

        return view;
    }

    public void getCurrentLocation(final boolean showMyLocation) {
        if (Nammu.checkPermission(android.Manifest.permission.ACCESS_FINE_LOCATION)) {
            setSearchLocation(showMyLocation);
        } else {
            final PermissionCallback permissionSearchLocationCallback = new PermissionCallback() {
                @Override
                public void permissionGranted() {
                    setSearchLocation(showMyLocation);
                }

                @Override
                public void permissionRefused() {
                    Helper.toast(getString(L.string.permission_denied));
                }
            };

            if (Nammu.shouldShowRequestPermissionRationale(this, android.Manifest.permission.ACCESS_FINE_LOCATION)) {
                Snackbar.make(geoLocationViewMain, getString(L.string.allow_location_access), Snackbar.LENGTH_INDEFINITE)
                        .setAction(getString(L.string.ok), new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                Nammu.askForPermission((Activity) mContext, android.Manifest.permission.ACCESS_FINE_LOCATION, permissionSearchLocationCallback);
                            }
                        }).show();
            } else {
                Nammu.askForPermission((Activity) mContext, android.Manifest.permission.ACCESS_FINE_LOCATION, permissionSearchLocationCallback);
            }
        }
    }

    private void setSearchLocation(boolean showMyLocation) {
        gps = new LocationTracker(mContext);
        if (gps.canGetLocation()) {
            deviceLatLng = new LatLng(gps.getLatitude(), gps.getLongitude());
            if (deviceLatLng.latitude != 0.0f && deviceLatLng.longitude != 0.0f) {
                if (showMyLocation) {
                    getLocationFromAddress(deviceLatLng);
                } else {
                    openAutocompleteActivity();
                }
            } else {
                Helper.toast(getString(L.string.turn_on_high_accuracy_location));
            }
        } else {
            gps.showSettingsAlert();
        }
    }

    public void openAutocompleteActivity() {
        if (deviceLatLng.latitude == 0.0f && deviceLatLng.longitude == 0.0f) {
            getCurrentLocation(false);
        }

        try {
            Intent intent = new PlaceAutocomplete.IntentBuilder(PlaceAutocomplete.MODE_OVERLAY)
                    .setBoundsBias(new LatLngBounds(deviceLatLng, deviceLatLng))
                    .build((Activity) mContext);
            startActivityForResult(intent, REQUEST_CODE_AUTOCOMPLETE);
        } catch (GooglePlayServicesRepairableException e) {
            GoogleApiAvailability.getInstance().getErrorDialog((Activity) mContext, e.getConnectionStatusCode(), 0).show();
        } catch (GooglePlayServicesNotAvailableException e) {
            String message = "Google Play Services is not available: " + GoogleApiAvailability.getInstance().getErrorString(e.errorCode);
            Toast.makeText(mContext, message, Toast.LENGTH_SHORT).show();
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE_AUTOCOMPLETE) {
            if (resultCode == Activity.RESULT_OK) {
                Place place = PlaceAutocomplete.getPlace(mContext, data);
                //Log.d("Tag", "Place: " + place.getAddress() + ", " + place.getPhoneNumber() + ", " + place.getLatLng());
                textFindLocation.setText(place.getName() + ", " + place.getAddress() /*+ ", " + place.getPhoneNumber()*/);
                AppUser.getInstance().mylocation = place.getName() + ", " + place.getAddress();
                geoLocation.latitude = String.valueOf(place.getLatLng().latitude);
                geoLocation.longitude = String.valueOf(place.getLatLng().longitude);
                Log.d("Place LatLng: " + place.getAddress() + ", " + place.getLatLng());
                Log.d("Device LatLng: " + deviceLatLng.toString());
            }
        }
    }

    public void getLocationFromAddress(LatLng deviceLatLng) {
        Geocoder coder = new Geocoder(getActivity());
        try {
            List<android.location.Address> addressList = coder.getFromLocation(deviceLatLng.latitude, deviceLatLng.longitude, 5);
            if (addressList == null || addressList.size() == 0) {
                return;
            }

            android.location.Address location = addressList.get(0);
            location.getLatitude();
            location.getLongitude();

            StringBuilder stringBuilder = new StringBuilder();
            stringBuilder.append(location.getAddressLine(0)).append(", ")
                    .append(location.getAddressLine(1)).append(", ")
                    .append(location.getAddressLine(2)).append(", ")
                    .append(location.getAddressLine(3));

            textFindLocation.setText(stringBuilder.toString());
            AppUser.getInstance().mylocation = stringBuilder.toString();
            geoLocation.latitude = String.valueOf(location.getLatitude());
            geoLocation.longitude = String.valueOf(location.getLongitude());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
