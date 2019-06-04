package com.twist.tmstore;

import android.Manifest;
import android.content.Intent;
import android.content.IntentSender;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.location.Geocoder;
import android.location.Location;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.design.widget.CoordinatorLayout;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v4.app.ActivityCompat;
import android.support.v4.os.ResultReceiver;
import android.support.v7.app.ActionBar;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.common.GooglePlayServicesRepairableException;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.PendingResult;
import com.google.android.gms.common.api.ResultCallback;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.LocationSettingsRequest;
import com.google.android.gms.location.LocationSettingsResult;
import com.google.android.gms.location.LocationSettingsStatusCodes;
import com.google.android.gms.location.places.Place;
import com.google.android.gms.location.places.Places;
import com.google.android.gms.location.places.ui.PlaceAutocomplete;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.twist.dataengine.DataEngine;
import com.twist.dataengine.DataQueryHandler;
import com.twist.tmstore.config.GuestUserConfig;
import com.twist.tmstore.entities.Address;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.services.GeocodeAddressIntentService;
import com.twist.tmstore.services.GeocodeLocationIntentService;
import com.utils.CContext;
import com.utils.Helper;
import com.utils.JsonHelper;
import com.utils.Log;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.List;

import pl.tajchert.nammu.Nammu;
import pl.tajchert.nammu.PermissionCallback;

/**
 * Created by Twist Mobile on 21-04-2017.
 */

public class ShippingAddressPickerActivity extends BaseActivity implements
        OnMapReadyCallback, GoogleApiClient.ConnectionCallbacks,
        GoogleApiClient.OnConnectionFailedListener, com.google.android.gms.location.LocationListener {

    private static final int REQUEST_CODE_AUTOCOMPLETE = 1;
    private static final int DEFAULT_ZOOM = 15;
    private static int REQUESTCODE_GPS_PERMISSION = 999;
    private GoogleApiClient mGoogleApiClient;
    private GoogleMap mMap;
    private Button btn_add_shipping_add;
    private TextView text_address;
    private TextView text_search_location;
    private CoordinatorLayout mLayout;
    final PermissionCallback permissionLocationCallback = new PermissionCallback() {
        @Override
        public void permissionGranted() {
            if (ActivityCompat.checkSelfPermission(ShippingAddressPickerActivity.this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(ShippingAddressPickerActivity.this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                return;
            }
            boolean hasAccess = Helper.accessLocation(getApplicationContext());
            if (hasAccess) {
                mMap.setMyLocationEnabled(true);
                mMap.getUiSettings().setMyLocationButtonEnabled(true);
            } else {
                Nammu.askForPermission(ShippingAddressPickerActivity.this, Manifest.permission.ACCESS_FINE_LOCATION,
                        permissionLocationCallback);
            }
        }

        @Override
        public void permissionRefused() {
            Snackbar.make(mLayout, getString(L.string.you_need_to_allow_permission),
                    Snackbar.LENGTH_INDEFINITE).setAction(getString(L.string.ok), new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Nammu.askForPermission(ShippingAddressPickerActivity.this, Manifest.permission.ACCESS_FINE_LOCATION,
                            permissionLocationCallback);
                }
            }).show();
        }
    };
    private String code = "";
    private String state = "";
    private String city = "";
    private String address1 = "";
    private String address2 = "";
    private LatLng latLong;
    private LatLng mCenterLatLong;
    private String country = "";
    private String postcode = "";
    private LinearLayout map_address_section;
    private LinearLayout addnew_section;
    private FloatingActionButton btn_addnew;
    private LinearLayout locationMarker_Section;
    private Location mLastKnownLocation;
    final PermissionCallback permissionDeviceLocationCallback = new PermissionCallback() {
        @Override
        public void permissionGranted() {
            boolean hasAccess = Helper.accessLocation(getApplicationContext());
            if (hasAccess)
                if (ActivityCompat.checkSelfPermission(ShippingAddressPickerActivity.this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(ShippingAddressPickerActivity.this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                    return;
                }
            mLastKnownLocation = LocationServices.FusedLocationApi.getLastLocation(mGoogleApiClient);
            moveMap(mLastKnownLocation);
        }

        @Override
        public void permissionRefused() {
            Snackbar.make(mLayout, getString(L.string.you_need_to_allow_permission),
                    Snackbar.LENGTH_INDEFINITE).setAction(getString(L.string.ok), new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Nammu.askForPermission(ShippingAddressPickerActivity.this, Manifest.permission.ACCESS_FINE_LOCATION,
                            permissionDeviceLocationCallback);
                }
            }).show();
        }
    };

    @Override
    public void onStart() {
        super.onStart();
        if (mGoogleApiClient != null)
            mGoogleApiClient.connect();
    }

    @Override
    protected void onActionBarRestored() {
    }

    @Override
    public void onLocationChanged(Location location) {
        try {
            if (location != null)
                moveMap(location);
            LocationServices.FusedLocationApi.removeLocationUpdates(mGoogleApiClient, this);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_shipping_address_picker);

        mGoogleApiClient = new GoogleApiClient.Builder(this)
                .enableAutoManage(this, this)
                .addConnectionCallbacks(this).addApi(LocationServices.API)
                .addApi(Places.GEO_DATA_API).addApi(Places.PLACE_DETECTION_API)
                .build();
        mGoogleApiClient.connect();

        setActionBarComponents();
        initComponents();

        if (GuestUserConfig.isGuestCheckout() && !AppUser.hasSignedIn()) {
            displayLocationSettingsRequest();
        } else {
            getShippingAddress();
        }
    }

    private void initComponents() {
        btn_add_shipping_add = (Button) findViewById(R.id.btn_add_shipping_add);
        Helper.stylize(btn_add_shipping_add,
                Color.parseColor(AppInfo.color_actionbar_text),
                Color.parseColor(AppInfo.disable_button_color),
                Color.parseColor(AppInfo.color_theme));
        btn_add_shipping_add.setText(getString(L.string.add_shipping_address));

        text_address = (TextView) findViewById(R.id.text_address);
        text_address.setText(getString(L.string.address));

        locationMarker_Section = (LinearLayout) findViewById(R.id.locationMarker);
        locationMarker_Section.setVisibility(View.GONE);

        TextView text_location_marker = (TextView) findViewById(R.id.text_location_marker);
        text_location_marker.setText(getString(L.string.select_shipping_address));

        ImageView imageMarker = (ImageView) findViewById(R.id.image_Marker);
        imageMarker.setColorFilter(Color.parseColor(AppInfo.normal_button_color));

        map_address_section = (LinearLayout) findViewById(R.id.map_address_section);
        Helper.stylize(map_address_section);
        map_address_section.setVisibility(View.GONE);

        mLayout = (CoordinatorLayout) findViewById(R.id.main_content);
        text_search_location.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                openAutocompleteActivity();
            }
        });

        btn_add_shipping_add.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mCenterLatLong != null) {
                    Address address = new Address();
                    address.state = state;
                    address.city = city;
                    address.postcode = code;
                    address.address_1 = address1;
                    address.address_2 = address2;
                    address.latitude = String.valueOf(mCenterLatLong.latitude);
                    address.longitude = String.valueOf(mCenterLatLong.longitude);
                    address.country = country;
                    address.postcode = postcode;
                    MainActivity.mActivity.showEditProfile(false, address);
                    finish();
                }
            }
        });

        addnew_section = (LinearLayout) findViewById(R.id.addnew_section);
        btn_addnew = (FloatingActionButton) findViewById(R.id.btn_addnew);
        Helper.stylize(btn_addnew);
        TextView text_addnew = (TextView) findViewById(R.id.text_addnew);
        text_addnew.setBackgroundColor(CContext.getColor(this, R.color.color_icon_overlay));
        addnew_section.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                addnew_section.setVisibility(View.GONE);
                locationMarker_Section.setVisibility(View.VISIBLE);
                map_address_section.setVisibility(View.VISIBLE);
                displayLocationSettingsRequest();
            }
        });
    }

    private void setActionBarComponents() {
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setHomeButtonEnabled(true);
            actionBar.setDisplayHomeAsUpEnabled(true);
            actionBar.setDisplayShowCustomEnabled(true);
            actionBar.setDisplayShowTitleEnabled(false);
            actionBar.setBackgroundDrawable(new ColorDrawable(Color.parseColor(AppInfo.color_theme)));
            Drawable upArrow = CContext.getDrawable(this, R.drawable.abc_ic_ab_back_material);
            upArrow.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_ATOP);
            getSupportActionBar().setHomeAsUpIndicator(upArrow);

            View actionBarView = LayoutInflater.from(this).inflate(R.layout.search_location, null);
            text_search_location = (TextView) actionBarView.findViewById(R.id.text_search_location);
            text_search_location.setText(getString(L.string.search_location));
            Helper.stylizeActionBar(text_search_location);
            ImageView icon_search = (ImageView) actionBarView.findViewById(R.id.icon_search);
            Helper.stylizeActionBar(icon_search);
            actionBar.setCustomView(actionBarView);
        }
    }

    private void displayLocationSettingsRequest() {
        LocationRequest locationRequest = createLocationRequest();
        LocationSettingsRequest.Builder builder = new LocationSettingsRequest.Builder().addLocationRequest(locationRequest);
        builder.setAlwaysShow(true);

        PendingResult<LocationSettingsResult> result = LocationServices.SettingsApi.checkLocationSettings(mGoogleApiClient, builder.build());
        result.setResultCallback(new ResultCallback<LocationSettingsResult>() {
            @Override
            public void onResult(LocationSettingsResult result) {
                final Status status = result.getStatus();
                switch (status.getStatusCode()) {
                    case LocationSettingsStatusCodes.SUCCESS:
                        startLocationUpdates();
                        updateLocationUI();
                        getDeviceLocation();
                        locationMarker_Section.setVisibility(View.VISIBLE);
                        map_address_section.setVisibility(View.VISIBLE);
                        Log.d("All location settings are satisfied.");

                        break;
                    case LocationSettingsStatusCodes.RESOLUTION_REQUIRED:
                        Log.d("Location settings are not satisfied. Show the user a dialog to upgrade location settings ");
                        try {
                            status.startResolutionForResult(ShippingAddressPickerActivity.this, REQUESTCODE_GPS_PERMISSION);
                        } catch (IntentSender.SendIntentException e) {
                            Log.d("PendingIntent unable to execute request.");
                            e.printStackTrace();
                        }
                        break;
                    case LocationSettingsStatusCodes.SETTINGS_CHANGE_UNAVAILABLE:
                        Log.d("Location settings are inadequate, and cannot be fixed here. Dialog not created.");
                        break;
                }
            }
        });
    }

    // Get Shipping Address To Show Marker On Map
    private void getShippingAddress() {
        showProgress(getString(L.string.updating));
        DataEngine.getDataEngine().getShippingAddressesInBackground(AppUser.getUserId(), new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {
                hideProgress();
                try {
                    JSONArray jsonArray = new JSONArray(data.toString());
                    AppUser.getInstance().setAddressJson(jsonArray.toString());
                    for (int i = 0; i < jsonArray.length(); i++) {
                        if (jsonArray.get(i) == null) {
                            continue;
                        }
                        JSONObject jo = jsonArray.getJSONObject(i);
                        String label = JsonHelper.getString(jo, "label");

                        Address address = new Address(label);
                        address.first_name = JsonHelper.getString(jo, "shipping_first_name");
                        address.last_name = JsonHelper.getString(jo, "shipping_last_name");
                        address.city = JsonHelper.getString(jo, "shipping_city");
                        address.state = JsonHelper.getString(jo, "shipping_state");
                        address.address_1 = JsonHelper.getString(jo, "shipping_address_1");
                        address.address_2 = JsonHelper.getString(jo, "shipping_address_2");
                        address.company = JsonHelper.getString(jo, "shipping_company");
                        address.postcode = JsonHelper.getString(jo, "shipping_postcode");
                        address.latitude = JsonHelper.getString(jo, "latitude");
                        address.longitude = JsonHelper.getString(jo, "longitude");

                        Intent intent = new Intent(ShippingAddressPickerActivity.this, GeocodeAddressIntentService.class);
                        AddressLatLngResultReceiver mLatLngResultReceiver = new AddressLatLngResultReceiver(new Handler());
                        intent.putExtra(Constants.RECEIVER, mLatLngResultReceiver);
                        intent.putExtra(Constants.LOCATION_NAME_DATA_EXTRA, address.postcode + " " + address.country + " " + address.city + " " + address.address_2 + " " + address.address_1);
                        startService(intent);
                    }

                    Address finalAddress = Address.getLastModifiedAddress();
                    if (finalAddress != null && !TextUtils.isEmpty(finalAddress.toString())) {
                        if (!TextUtils.isEmpty(finalAddress.latitude) && !TextUtils.isEmpty(finalAddress.longitude)) {
                            latLong = new LatLng(Double.parseDouble(finalAddress.latitude), Double.parseDouble(finalAddress.longitude));
                            CameraPosition cameraPosition = new CameraPosition.Builder().target(latLong).zoom(10f).tilt(70).build();
                            mMap.animateCamera(CameraUpdateFactory.newCameraPosition(cameraPosition));

                        } else {
                            String finalSavedAddress = finalAddress.address_1 + " " + finalAddress.address_2 + " " + finalAddress.city + " " + finalAddress.country + " - " + finalAddress.postcode;
                            getLocationFromAddress(finalSavedAddress, finalAddress.postcode);
                        }
                    } else {
                        latLong = new LatLng(0, 0);
                        CameraPosition cameraPosition = new CameraPosition.Builder().target(latLong).zoom(10f).tilt(70).build();
                        mMap.animateCamera(CameraUpdateFactory.newCameraPosition(cameraPosition));
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                    displayLocationSettingsRequest();
                    locationMarker_Section.setVisibility(View.VISIBLE);
                    map_address_section.setVisibility(View.VISIBLE);
                }
            }

            @Override
            public void onFailure(Exception error) {
                error.printStackTrace();
                hideProgress();
                displayLocationSettingsRequest();
                locationMarker_Section.setVisibility(View.VISIBLE);
                map_address_section.setVisibility(View.VISIBLE);
            }
        });
    }

    private void openAutocompleteActivity() {
        try {
            Intent intent = new PlaceAutocomplete.IntentBuilder(PlaceAutocomplete.MODE_OVERLAY).build(this);
            startActivityForResult(intent, REQUEST_CODE_AUTOCOMPLETE);
        } catch (GooglePlayServicesRepairableException e) {
            GoogleApiAvailability.getInstance().getErrorDialog(this, e.getConnectionStatusCode(), 0).show();
        } catch (GooglePlayServicesNotAvailableException e) {
            String message = "Google Play Services is not available: " + GoogleApiAvailability.getInstance().getErrorString(e.errorCode);
            Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_CODE_AUTOCOMPLETE) {
            if (resultCode == RESULT_OK) {
                Place place = PlaceAutocomplete.getPlace(this, data);
                LatLng latLong = place.getLatLng();
                CameraPosition cameraPosition = new CameraPosition.Builder().target(latLong).zoom(19f).tilt(70).build();
                if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                    return;
                }
                mMap.setMyLocationEnabled(true);
                mMap.animateCamera(CameraUpdateFactory.newCameraPosition(cameraPosition));
            }
        } else if (requestCode == REQUESTCODE_GPS_PERMISSION) {
            startLocationUpdates();
            updateLocationUI();
            getDeviceLocation();
        }
    }

    protected void startLocationUpdates() {
        LocationRequest locationRequest = createLocationRequest();
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return;
        }
        LocationServices.FusedLocationApi.requestLocationUpdates(mGoogleApiClient, locationRequest, this).setResultCallback(new ResultCallback<Status>() {
            @Override
            public void onResult(Status status) {
            }
        });
    }

    @Override
    public void onMapReady(GoogleMap googleMap) {
        mMap = googleMap;
        mMap.getUiSettings().setZoomControlsEnabled(true);
        updateLocationUI();
        getDeviceLocation();
        if (ActivityCompat.checkSelfPermission(ShippingAddressPickerActivity.this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(ShippingAddressPickerActivity.this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return;
        }
        mMap.setOnCameraChangeListener(new GoogleMap.OnCameraChangeListener() {
            @Override
            public void onCameraChange(CameraPosition cameraPosition) {
                Log.d("Camera postion change" + "", cameraPosition + "");
                mCenterLatLong = cameraPosition.target;
                try {
                    Location mLocation = new Location("");
                    mLocation.setLatitude(mCenterLatLong.latitude);
                    mLocation.setLongitude(mCenterLatLong.longitude);
                    startIntentService(mLocation);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });

        mMap.setOnMarkerClickListener(new GoogleMap.OnMarkerClickListener() {
            @Override
            public boolean onMarkerClick(Marker marker) {
                map_address_section.setVisibility(View.VISIBLE);
                btn_add_shipping_add.setText(getString(L.string.proceed));
                marker.showInfoWindow();
                CameraPosition cameraPosition = new CameraPosition.Builder().target(marker.getPosition()).zoom(19f).tilt(70).build();
                mMap.animateCamera(CameraUpdateFactory.newCameraPosition(cameraPosition));
                return true;
            }
        });
    }

    private void updateLocationUI() {
        if (mMap == null) {
            return;
        }
        if (Nammu.checkPermission(Manifest.permission.ACCESS_FINE_LOCATION)) {
            boolean hasAccess = Helper.accessLocation(ShippingAddressPickerActivity.this);
            if (hasAccess) {
                mMap.setMyLocationEnabled(true);
                mMap.getUiSettings().setMyLocationButtonEnabled(true);
            } else {
                mMap.setMyLocationEnabled(false);
                mMap.getUiSettings().setMyLocationButtonEnabled(false);
                mLastKnownLocation = null;
            }
        } else {
            if (Nammu.shouldShowRequestPermissionRationale(this, Manifest.permission.ACCESS_FINE_LOCATION)) {
                Snackbar.make(mLayout, getString(L.string.you_need_to_allow_permission),
                        Snackbar.LENGTH_INDEFINITE).setAction(getString(L.string.ok), new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        Nammu.askForPermission(ShippingAddressPickerActivity.this, Manifest.permission.ACCESS_FINE_LOCATION,
                                permissionLocationCallback);
                    }
                }).show();
            } else {
                Nammu.askForPermission(ShippingAddressPickerActivity.this, Manifest.permission.ACCESS_FINE_LOCATION,
                        permissionLocationCallback);
            }
        }
    }

    private void getDeviceLocation() {
        if (Nammu.checkPermission(Manifest.permission.ACCESS_FINE_LOCATION)) {
            boolean hasAccess = Helper.accessLocation(getApplicationContext());
            if (hasAccess) {
                mLastKnownLocation = LocationServices.FusedLocationApi.getLastLocation(mGoogleApiClient);
                moveMap(mLastKnownLocation);
            }
        } else {
            if (Nammu.shouldShowRequestPermissionRationale(ShippingAddressPickerActivity.this,
                    Manifest.permission.ACCESS_FINE_LOCATION)) {
                Snackbar.make(mLayout, getString(L.string.you_need_to_allow_permission),
                        Snackbar.LENGTH_INDEFINITE).setAction(getString(L.string.ok), new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        Nammu.askForPermission(ShippingAddressPickerActivity.this, Manifest.permission.ACCESS_FINE_LOCATION,
                                permissionDeviceLocationCallback);
                        startLocationUpdates();
                        updateLocationUI();
                        getDeviceLocation();
                    }
                }).show();
            } else {
                Nammu.askForPermission(ShippingAddressPickerActivity.this, Manifest.permission.ACCESS_FINE_LOCATION,
                        permissionDeviceLocationCallback);
                startLocationUpdates();
                updateLocationUI();
                getDeviceLocation();
            }
        }

        if (mLastKnownLocation != null) {
            mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(
                    new LatLng(mLastKnownLocation.getLatitude(),
                            mLastKnownLocation.getLongitude()), DEFAULT_ZOOM));
            moveMap(mLastKnownLocation);
        } else {
            Log.d("Current location is null. Using defaults.");

            boolean hasAccess = Helper.accessLocation(getApplicationContext());
            if (hasAccess) {
                mLastKnownLocation = LocationServices.FusedLocationApi.getLastLocation(mGoogleApiClient);
                moveMap(mLastKnownLocation);
            }
        }
    }

    private void moveMap(Location location) {
        if (location != null) {
            latLong = new LatLng(location.getLatitude(), location.getLongitude());
            CameraPosition cameraPosition = new CameraPosition.Builder().target(latLong).zoom(19f).tilt(70).build();
            mMap.animateCamera(CameraUpdateFactory.newCameraPosition(cameraPosition));
            startIntentService(location);
        }
    }

    private void startIntentService(Location location) {
        Intent intent = new Intent(this, GeocodeLocationIntentService.class);
        intent.putExtra(Constants.RECEIVER, new AddressResultReceiver(new Handler()));
        intent.putExtra(Constants.LAT, location.getLatitude());
        intent.putExtra(Constants.LNG, location.getLongitude());
        this.startService(intent);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        Nammu.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    protected LocationRequest createLocationRequest() {
        LocationRequest locationRequest = LocationRequest.create();
        locationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);
        locationRequest.setInterval(10000);
        locationRequest.setFastestInterval(10000 / 2);
        return locationRequest;
    }

    @Override
    public void onConnected(@Nullable Bundle bundle) {
        SupportMapFragment mapFragment = (SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map);
        mapFragment.getMapAsync(ShippingAddressPickerActivity.this);
    }

    @Override
    public void onConnectionSuspended(int i) {
    }

    @Override
    public void onConnectionFailed(@NonNull ConnectionResult connectionResult) {
    }

    @Override
    public void onStop() {
        if (mGoogleApiClient != null && mGoogleApiClient.isConnected()) {
            mGoogleApiClient.stopAutoManage(ShippingAddressPickerActivity.this);
            mGoogleApiClient.disconnect();
        }
        super.onStop();
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                this.finish();
                return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onBackPressed() {
        setResult(RESULT_CANCELED);
        finish();
    }

    public void getLocationFromAddress(String strAddress, String strPostcode) {
        Geocoder coder = new Geocoder(this);
        try {
            List<android.location.Address> addressList = coder.getFromLocationName(strAddress, 5);
            if (addressList == null || addressList.size() == 0) {
                getLocationFromPostCode(strPostcode);
                return;
            }

            android.location.Address location = addressList.get(0);
            location.getLatitude();
            location.getLongitude();

            latLong = new LatLng(location.getLatitude(), location.getLongitude());

            CameraPosition cameraPosition = new CameraPosition.Builder()
                    .target(latLong).zoom(10f).tilt(70).build();

            mMap.animateCamera(CameraUpdateFactory
                    .newCameraPosition(cameraPosition));
            map_address_section.setVisibility(View.VISIBLE);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void getLocationFromPostCode(String strPostcode) {
        Geocoder coder = new Geocoder(this);
        List<android.location.Address> address;
        try {
            address = coder.getFromLocationName(strPostcode, 15);
            if (address == null || address.size() == 0) {
                latLong = new LatLng(0, 0);
                CameraPosition cameraPosition = new CameraPosition.Builder().target(latLong).zoom(10f).tilt(70).build();
                mMap.animateCamera(CameraUpdateFactory.newCameraPosition(cameraPosition));
                return;
            }
            android.location.Address location = address.get(0);
            location.getLatitude();
            location.getLongitude();

            latLong = new LatLng(location.getLatitude(), location.getLongitude());
            CameraPosition cameraPosition = new CameraPosition.Builder().target(latLong).zoom(10f).tilt(70).build();
            mMap.animateCamera(CameraUpdateFactory.newCameraPosition(cameraPosition));
            map_address_section.setVisibility(View.VISIBLE);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private class AddressLatLngResultReceiver extends ResultReceiver {
        public AddressLatLngResultReceiver(Handler handler) {
            super(handler);
        }

        @Override
        protected void onReceiveResult(int resultCode, final Bundle resultData) {
            if (resultCode == Constants.SUCCESS_RESULT) {
                final android.location.Address address = resultData.getParcelable(Constants.RESULT_ADDRESS);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        LatLng latLngOld = new LatLng(address.getLatitude(), address.getLongitude());
                        if (mMap != null) {
                            Marker marker = mMap.addMarker(new MarkerOptions().position(latLngOld).title(address.getAddressLine(0) + " " + address.getAddressLine(1)));
                            marker.showInfoWindow();
                            text_address.setText(marker.getTitle());
                            btn_add_shipping_add.setText(getString(L.string.proceed));
                        }
                    }
                });
            }
        }
    }

    private class AddressResultReceiver extends ResultReceiver {
        AddressResultReceiver(Handler handler) {
            super(handler);
        }

        @Override
        protected void onReceiveResult(int resultCode, Bundle resultData) {
            if (resultCode == Constants.SUCCESS_RESULT) {
                final android.location.Address address = resultData.getParcelable(Constants.RESULT_ADDRESS);
                if (address != null) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if (!TextUtils.isEmpty(address.getPostalCode()))
                                code = address.getPostalCode();
                            if (!TextUtils.isEmpty(address.getCountryName()))
                                country = address.getCountryName();
                            if (!TextUtils.isEmpty(address.getAddressLine(0)))
                                address1 = address.getAddressLine(0);
                            if (!TextUtils.isEmpty(address.getAddressLine(1)))
                                address2 = address.getAddressLine(1);
                            if (!TextUtils.isEmpty(address.getAdminArea()))
                                state = address.getAdminArea();
                            if (!TextUtils.isEmpty(address.getLocality()))
                                city = address.getLocality();
                            if (!TextUtils.isEmpty(address.getPostalCode()))
                                postcode = address.getPostalCode();

                            text_address.setText(address1 + ", " + address2 + ", " + city);
                            btn_add_shipping_add.setText(getString(L.string.proceed));
                        }
                    });
                    map_address_section.setVisibility(View.VISIBLE);
                }
            }
        }
    }
}
