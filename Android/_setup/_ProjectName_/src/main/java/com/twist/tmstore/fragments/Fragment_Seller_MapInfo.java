package com.twist.tmstore.fragments;

import android.content.Intent;
import android.content.IntentSender;
import android.content.pm.PackageManager;
import android.location.Location;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.design.widget.Snackbar;
import android.support.v4.app.ActivityCompat;
import android.support.v4.os.ResultReceiver;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.PendingResult;
import com.google.android.gms.common.api.ResultCallback;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.LocationSettingsRequest;
import com.google.android.gms.location.LocationSettingsResult;
import com.google.android.gms.location.LocationSettingsStatusCodes;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.twist.dataengine.entities.SellerInfo;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.Constants;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.config.MultiVendorConfig;
import com.twist.tmstore.services.GeocodeLocationIntentService;
import com.utils.GoogleApiHelper;
import com.utils.Helper;
import com.utils.Log;

import pl.tajchert.nammu.Nammu;
import pl.tajchert.nammu.PermissionCallback;

/**
 * Created by Twist Mobile on 10/28/2017.
 */

public class Fragment_Seller_MapInfo extends BaseFragment {

    private static final int REQUEST_GPS_PERMISSION = 1002;
    private static final int DEFAULT_ZOOM = 15;
    private OnAddressChangeListener mOnAddressChangeListener;
    private GoogleMap googleMap;
    PermissionCallback permissionLocationCallback = new PermissionCallback() {
        @Override
        public void permissionGranted() {
            if (ActivityCompat.checkSelfPermission(getActivity(), android.Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(getActivity(), android.Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                return;
            }
            boolean hasAccess = Helper.accessLocation(getActivity().getApplicationContext());
            if (hasAccess) {
                googleMap.setMyLocationEnabled(true);
                googleMap.getUiSettings().setMyLocationButtonEnabled(true);
                googleMap.getUiSettings().setScrollGesturesEnabled(false);
            } else {
                Nammu.askForPermission(getActivity(), android.Manifest.permission.ACCESS_FINE_LOCATION, permissionLocationCallback);
            }
        }

        @Override
        public void permissionRefused() {
            Snackbar.make(getActivity().findViewById(android.R.id.content), getString(L.string.you_need_to_allow_permission),
                    Snackbar.LENGTH_INDEFINITE).setAction(getString(L.string.ok), new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Nammu.askForPermission(getActivity(), android.Manifest.permission.ACCESS_FINE_LOCATION, permissionLocationCallback);
                }
            }).show();
        }
    };
    private GoogleApiClient mGoogleApiClient;
    private SellerInfo currentSeller;
    private Location mLastKnownLocation;
    PermissionCallback permissionDeviceLocationCallback = new PermissionCallback() {
        @Override
        public void permissionGranted() {
            boolean hasAccess = Helper.accessLocation(getActivity().getApplicationContext());
            if (hasAccess)
                if (ActivityCompat.checkSelfPermission(getActivity(), android.Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(getActivity(), android.Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
                    mLastKnownLocation = LocationServices.FusedLocationApi.getLastLocation(mGoogleApiClient);
                    moveMap(mLastKnownLocation);
                }
        }

        @Override
        public void permissionRefused() {
            Snackbar.make(getActivity().findViewById(android.R.id.content), getString(L.string.you_need_to_allow_permission),
                    Snackbar.LENGTH_INDEFINITE).setAction(getString(L.string.ok), new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Nammu.askForPermission(getActivity(), android.Manifest.permission.ACCESS_FINE_LOCATION, permissionDeviceLocationCallback);
                }
            }).show();
        }
    };
    private LatLng mCenterLatLong;
    OnMapReadyCallback onMapReadyCallback = new OnMapReadyCallback() {
        @Override
        public void onMapReady(GoogleMap map) {
            googleMap = map;
            updateLocationUI();
            if (currentSeller.getLatitude() != 0 && currentSeller.getLongitude() != 0) {
                Location targetLocation = new Location("");
                targetLocation.setLatitude(currentSeller.getLatitude());
                targetLocation.setLongitude(currentSeller.getLongitude());
                moveMap(targetLocation);
            } else {
                getDeviceLocation();
            }

            googleMap.setOnCameraChangeListener(new GoogleMap.OnCameraChangeListener() {
                @Override
                public void onCameraChange(CameraPosition cameraPosition) {
                    Log.d("Camera position change" + "", cameraPosition + "");
                    mCenterLatLong = cameraPosition.target;
                    //startIntentService(mCenterLatLong);
                }
            });

            googleMap.setOnMarkerClickListener(new GoogleMap.OnMarkerClickListener() {
                @Override
                public boolean onMarkerClick(Marker marker) {
                    marker.showInfoWindow();
                    CameraPosition cameraPosition = new CameraPosition.Builder().target(marker.getPosition()).zoom(DEFAULT_ZOOM)/*.tilt(70)*/.build();
                    googleMap.animateCamera(CameraUpdateFactory.newCameraPosition(cameraPosition));
                    return true;
                }
            });

        }
    };

    public Fragment_Seller_MapInfo() {
    }

    public void setCurrentSeller(SellerInfo currentSeller) {
        this.currentSeller = currentSeller;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_seller_map_info, (FrameLayout) container.findViewById(R.id.seller_map), false);
        ImageView imageMarker = (ImageView) rootView.findViewById(R.id.image_marker);
        //imageMarker.setVisibility(View.GONE);
        Helper.stylizeVector(imageMarker);
        return rootView;
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        if (MultiVendorConfig.shouldShowLocation())
            showLocationSetting();
    }

    private void showLocationSetting() {
        GoogleApiHelper googleApiHelper = ((MainActivity) getActivity()).getGoogleApiHelper();
        mGoogleApiClient = googleApiHelper.getGoogleApiClient();
        if (mGoogleApiClient != null) {
            googleApiHelper.setConnectionListener(new GoogleApiHelper.ConnectionListener() {
                @Override
                public void onConnectionFailed(@NonNull ConnectionResult connectionResult) {
                }

                @Override
                public void onConnectionSuspended(int i) {
                }

                @Override
                public void onConnected(Bundle bundle) {
                    SupportMapFragment mapFragment = (SupportMapFragment) getChildFragmentManager().findFragmentById(R.id.seller_map);
                    mapFragment.getMapAsync(onMapReadyCallback);
                }
            });
            googleApiHelper.connect();
        }

        LocationRequest locationRequest = LocationRequest.create();
        locationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);
        locationRequest.setInterval(10000);
        locationRequest.setFastestInterval(10000 / 2);

        LocationSettingsRequest.Builder builder = new LocationSettingsRequest.Builder().addLocationRequest(locationRequest);
        builder.setAlwaysShow(true);

        PendingResult<LocationSettingsResult> result = LocationServices.SettingsApi.checkLocationSettings(mGoogleApiClient, builder.build());
        result.setResultCallback(new ResultCallback<LocationSettingsResult>() {
            @Override
            public void onResult(LocationSettingsResult result) {
                final Status status = result.getStatus();
                switch (status.getStatusCode()) {
                    case LocationSettingsStatusCodes.SUCCESS:
                        Log.d("All location settings are satisfied.");
                        break;
                    case LocationSettingsStatusCodes.RESOLUTION_REQUIRED:
                        Log.d("Location settings are not satisfied. Show the user a dialog to upgrade location settings ");
                        try {
                            status.startResolutionForResult(getActivity(), REQUEST_GPS_PERMISSION);
                        } catch (IntentSender.SendIntentException e) {
                            Log.d("PendingIntent unable to execute request.");
                        }
                        break;
                    case LocationSettingsStatusCodes.SETTINGS_CHANGE_UNAVAILABLE:
                        Log.d("Location settings are inadequate, and cannot be fixed here. Dialog not created.");
                        break;
                }
            }
        });
    }

    private void updateLocationUI() {
        if (googleMap == null) {
            return;
        }
        if (Nammu.checkPermission(android.Manifest.permission.ACCESS_FINE_LOCATION)) {
            boolean hasAccess = Helper.accessLocation(getActivity().getApplicationContext());
            if (hasAccess) {
                googleMap.setMyLocationEnabled(true);
                googleMap.getUiSettings().setMyLocationButtonEnabled(true);
            } else {
                googleMap.setMyLocationEnabled(false);
                googleMap.getUiSettings().setMyLocationButtonEnabled(false);
                mLastKnownLocation = null;
            }
        } else {
            if (Nammu.shouldShowRequestPermissionRationale(this, android.Manifest.permission.ACCESS_FINE_LOCATION)) {
                Snackbar.make(getActivity().findViewById(android.R.id.content), getString(L.string.you_need_to_allow_permission),
                        Snackbar.LENGTH_INDEFINITE).setAction(getString(L.string.ok), new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        Nammu.askForPermission(getActivity(), android.Manifest.permission.ACCESS_FINE_LOCATION,
                                permissionLocationCallback);
                    }
                }).show();
            } else {
                Nammu.askForPermission(this, android.Manifest.permission.ACCESS_FINE_LOCATION,
                        permissionLocationCallback);
            }
        }
    }

    private void getDeviceLocation() {
        if (Nammu.checkPermission(android.Manifest.permission.ACCESS_FINE_LOCATION)) {
            if (Helper.accessLocation(getActivity().getApplicationContext())) {
                mLastKnownLocation = LocationServices.FusedLocationApi.getLastLocation(mGoogleApiClient);
                moveMap(mLastKnownLocation);
            }
        } else {
            if (Nammu.shouldShowRequestPermissionRationale(this, android.Manifest.permission.ACCESS_FINE_LOCATION)) {
                Snackbar.make(getActivity().findViewById(android.R.id.content), getString(L.string.you_need_to_allow_permission), Snackbar.LENGTH_INDEFINITE).setAction(getString(L.string.ok), new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        Nammu.askForPermission(getActivity(), android.Manifest.permission.ACCESS_FINE_LOCATION, permissionDeviceLocationCallback);
                    }
                }).show();
            } else {
                Nammu.askForPermission(this, android.Manifest.permission.ACCESS_FINE_LOCATION, permissionDeviceLocationCallback);
            }
        }

        if (mLastKnownLocation != null) {
            googleMap.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(mLastKnownLocation.getLatitude(), mLastKnownLocation.getLongitude()), DEFAULT_ZOOM));
            moveMap(mLastKnownLocation);
        } else {
            Log.d("Current location is null. Using defaults.");
            if (Helper.accessLocation(getActivity().getApplicationContext())) {
                mLastKnownLocation = LocationServices.FusedLocationApi.getLastLocation(mGoogleApiClient);
                moveMap(mLastKnownLocation);
            }
        }
    }

    public void moveMap(Location location) {
        if (location != null) {
            LatLng latLong = new LatLng(location.getLatitude(), location.getLongitude());
            moveMap(latLong, false);
        }
    }

    public void moveMap(LatLng latLng, boolean service) {
        if (latLng != null) {
            CameraPosition cameraPosition = new CameraPosition.Builder().target(latLng).zoom(DEFAULT_ZOOM).build();
            googleMap.getUiSettings().setScrollGesturesEnabled(false);
            googleMap.animateCamera(CameraUpdateFactory.newCameraPosition(cameraPosition));
            if (service)
                startGeocodeService(latLng);
            else
                stopGeocodeService();
        }
    }

    private void startGeocodeService(LatLng latLng) {
        try {
            Intent intent = new Intent(getActivity(), GeocodeLocationIntentService.class);
            intent.putExtra(Constants.RECEIVER, new AddressResultReceiver(new Handler()));
            intent.putExtra(Constants.LAT, latLng.latitude);
            intent.putExtra(Constants.LNG, latLng.longitude);
            getActivity().startService(intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void stopGeocodeService() {
        try {
            getActivity().stopService(new Intent(getActivity(), GeocodeLocationIntentService.class));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        GoogleApiHelper googleApiHelper = ((MainActivity) getActivity()).getGoogleApiHelper();
        if (googleApiHelper != null) {
            googleApiHelper.disconnect();
        }
    }

    public void setOnAddressChangeListener(OnAddressChangeListener addressChangeListener) {
        this.mOnAddressChangeListener = addressChangeListener;
    }

    interface OnAddressChangeListener {
        void onChange(Double latitude, Double longitude, String country, String state, String postcode, String code, String city, String address1, String address2);
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
                    getActivity().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            handleAddressResult(address);
                        }
                    });
                }
            }
        }

        private void handleAddressResult(android.location.Address address) {
            String country = "";
            String state = "";
            String postcode = "";
            String code = "";
            String city = "";
            String address1 = "";
            String address2 = "";
            Double latitude = 0.0;
            Double longitude = 0.0;
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
            if (address.getLatitude() != 0)
                latitude = address.getLatitude();
            if (address.getLongitude() != 0)
                longitude = address.getLongitude();
            mOnAddressChangeListener.onChange(latitude, longitude, country, state, postcode, code, city, address1, address2);
        }
    }
}








