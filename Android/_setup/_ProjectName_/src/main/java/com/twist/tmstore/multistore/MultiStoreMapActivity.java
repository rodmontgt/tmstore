package com.twist.tmstore.multistore;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.IntentSender;
import android.content.pm.PackageManager;
import android.database.AbstractCursor;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.location.Location;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.BottomSheetBehavior;
import android.support.design.widget.CoordinatorLayout;
import android.support.design.widget.Snackbar;
import android.support.v4.app.ActivityCompat;
import android.support.v4.widget.SimpleCursorAdapter;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.SearchView;
import android.support.v7.widget.Toolbar;
import android.text.TextUtils;
import android.view.*;
import android.widget.*;
import com.bumptech.glide.Glide;
import com.bumptech.glide.request.animation.GlideAnimation;
import com.bumptech.glide.request.target.SimpleTarget;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.common.GooglePlayServicesRepairableException;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.PendingResult;
import com.google.android.gms.common.api.ResultCallback;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.location.*;
import com.google.android.gms.location.places.Place;
import com.google.android.gms.location.places.Places;
import com.google.android.gms.location.places.ui.PlaceAutocomplete;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.*;
import com.twist.tmstore.*;
import com.twist.tmstore.R;
import com.twist.tmstore.config.MultiStoreConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.views.MySearchView;
import com.utils.DirectionsJSONParser;
import com.utils.Helper;
import com.utils.ListUtils;
import com.utils.Log;
import com.utils.customviews.progressbar.CircleProgressBar;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import pl.tajchert.nammu.Nammu;
import pl.tajchert.nammu.PermissionCallback;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.*;

public class MultiStoreMapActivity extends AppCompatActivity implements
        OnMapReadyCallback, GoogleApiClient.ConnectionCallbacks,
        GoogleApiClient.OnConnectionFailedListener, GoogleMap.OnMarkerClickListener {

    private static final int DEFAULT_ZOOM = 10;
    private static final String KEY_CAMERA_POSITION = "camera_position";
    private static final String KEY_LOCATION = "location";
    private static final int REQUEST_CODE_AUTOCOMPLETE = 1001;
    private static final int REQUEST_GPS_PERMISSION = 1002;
    private static final int REQUEST_SEARCH_NEARBY = 1003;
    private final LatLng mDefaultLocation = new LatLng(0, 0);
    private GoogleMap mMap;
    private CameraPosition mCameraPosition;
    private GoogleApiClient mGoogleApiClient;
    private Location mLastKnownLocation;
    private PolylineOptions lineOptions = null;
    private List<MultiStoreConfig> multiStoreConfigs;
    private LinearLayout llBottomSheet;
    private ImageView iv_store;
    private Toolbar toolbar;
    private TextView tv_store_name;
    private TextView text_address;
    private TextView text_distance;
    private Button btn_visit;
    private CircleProgressBar progress_map;
    private MySearchView searchView;
    private CoordinatorLayout mLayout;
    private MultiStoreConfig selectedMultiStoreConfig;
    private MultiStoreMapActivity thisActivity;
    private Marker mMarker;

    final PermissionCallback permissionDeviceLocationCallback = new PermissionCallback() {
        @Override
        public void permissionGranted() {
            boolean hasAccess = Helper.hasLocationAccess(thisActivity);
            if (hasAccess) {
                if (ActivityCompat.checkSelfPermission(thisActivity, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(thisActivity, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
                    mLastKnownLocation = LocationServices.FusedLocationApi.getLastLocation(mGoogleApiClient);
                    plotMarker();
                }
            }
        }

        @Override
        public void permissionRefused() {
            Snackbar.make(mLayout, L.getString(L.string.allow_location_access), Snackbar.LENGTH_INDEFINITE).setAction(L.getString(L.string.ok), new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Nammu.askForPermission(thisActivity, Manifest.permission.ACCESS_FINE_LOCATION, permissionDeviceLocationCallback);
                }
            }).show();
        }
    };

    final PermissionCallback permissionLocationCallback = new PermissionCallback() {
        @Override
        public void permissionGranted() {
            if (ActivityCompat.checkSelfPermission(thisActivity, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(thisActivity, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
                mMap.setMyLocationEnabled(true);
                mMap.getUiSettings().setMyLocationButtonEnabled(true);
                getDeviceLocation();
                plotMarker();
            }
        }

        @Override
        public void permissionRefused() {
            Snackbar.make(mLayout, L.getString(L.string.allow_location_access), Snackbar.LENGTH_INDEFINITE).setAction(L.getString(L.string.ok), new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Nammu.askForPermission(thisActivity, Manifest.permission.ACCESS_FINE_LOCATION, permissionLocationCallback);
                }
            }).show();
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (savedInstanceState != null) {
            mLastKnownLocation = savedInstanceState.getParcelable(KEY_LOCATION);
            mCameraPosition = savedInstanceState.getParcelable(KEY_CAMERA_POSITION);
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Window window = getWindow();
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(Color.parseColor(AppInfo.color_theme_statusbar));
        }

        Nammu.init(this);

        setContentView(R.layout.activity_multi_store_map);

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        Helper.stylizeOverflowIcon(toolbar);

        thisActivity = this;

        for (int j = 0; j < MultiStoreConfig.getMultiStoreConfigs().size(); j++) {
            MultiStoreConfig multiStoreConfig = MultiStoreConfig.getMultiStoreConfigs().get(j);
            Log.D("Multistore " + multiStoreConfig.toString());
        }
        List<MultiStoreConfig> enableMultiStoreConfigs = MultiStoreConfig.getMultiStoreConfigList(true);
        /*List<MultiStoreConfig> defaultMultiStoreConfigs = MultiStoreConfig.getdefaultMultiStoreConfigList(true);
        if (!defaultMultiStoreConfigs.isEmpty()) {
            multiStoreConfigs = defaultMultiStoreConfigs;
        } else */if (!enableMultiStoreConfigs.isEmpty()) {
            multiStoreConfigs = enableMultiStoreConfigs;
        } else {
            multiStoreConfigs = MultiStoreConfig.getMultiStoreConfigs();
        }

        initComponents();
        initSearchView();
        showLocationSetting();
    }

    private void initComponents() {
        tv_store_name = (TextView) findViewById(R.id.tv_store_name);
        text_address = (TextView) findViewById(R.id.text_address);
        text_address.setVisibility(View.GONE);
        text_distance = (TextView) findViewById(R.id.text_distance);
        text_distance.setVisibility(View.GONE);
        mLayout = (CoordinatorLayout) findViewById(R.id.coordinatorLayout);
        toolbar = (Toolbar) findViewById(R.id.toolbar);
        searchView = (MySearchView) findViewById(R.id.search_view);
        llBottomSheet = (LinearLayout) findViewById(R.id.bottom_sheet);
        Helper.stylize(llBottomSheet);
        llBottomSheet.setVisibility(View.GONE);
        toolbar.setBackgroundColor(Color.parseColor(AppInfo.color_theme));
        Helper.stylizeOverflowIcon(toolbar);
        iv_store = (ImageView) findViewById(R.id.iv_store);
        btn_visit = (Button) findViewById(R.id.btn_visit);
        btn_visit.setTextColor(Color.parseColor(AppInfo.color_theme));
        btn_visit.setText(L.getString(L.string.get_direction));
        btn_visit.setScaleX(0.80f);
        btn_visit.setScaleY(0.80f);
        progress_map = (CircleProgressBar) findViewById(R.id.progress);
        Helper.stylize(progress_map);
        progress_map.setVisibility(View.GONE);

        BottomSheetBehavior bottomSheetBehavior = BottomSheetBehavior.from(llBottomSheet);
        bottomSheetBehavior.setHideable(false);
        btn_visit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String text = ((Button) v).getText().toString();
                if (text.compareTo(L.getString(L.string.get_direction)) == 0) {
                    btn_visit.setText(L.getString(L.string.show_stores));
                    clearAllMarkers();
                    getDirection(selectedMultiStoreConfig);
                } else {
                    btn_visit.setText(L.getString(L.string.get_direction));
                    text_distance.setVisibility(View.GONE);
                    text_address.setVisibility(View.GONE);
                    mMap.clear();
                    plotMarker();
                }
            }
        });
    }

    private void initSearchView() {
        searchView.setIconified(true);
        searchView.setIconifiedByDefault(false);
        searchView.setThemeColor(Color.parseColor(AppInfo.color_actionbar_text));
        String action = getIntent().getAction();
        if (BuildConfig.SEARCH_NEARBY && (action == null || !action.equals(Constants.ACTION_MULTI_STORE_LOCATE_ALL))) {
            searchView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    openSearchLocation();
                }
            });
            try {
                TextView mQueryTextView = (SearchView.SearchAutoComplete) findViewById(android.support.v7.appcompat.R.id.search_src_text);
                if (mQueryTextView != null) {
                    mQueryTextView.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            openSearchLocation();
                        }
                    });
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else {
            searchView.setSuggestionsAdapter(new SearchSuggestionsAdapter(this));
            searchView.setOnSuggestionListener(new SearchView.OnSuggestionListener() {
                @Override
                public boolean onSuggestionClick(int position) {
                    Cursor cursor = (Cursor) searchView.getSuggestionsAdapter().getItem(position);
                    String term = cursor.getString(1);
                    cursor.close();
                    searchView.setQuery(term, false);
                    searchView.clearFocus();
                    return true;
                }

                @Override
                public boolean onSuggestionSelect(int position) {
                    Cursor cursor = (Cursor) searchView.getSuggestionsAdapter().getItem(position);
                    String term = cursor.getString(1);
                    cursor.close();
                    searchView.setQuery(term, false);
                    searchView.clearFocus();
                    return true;
                }
            });
            searchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
                @Override
                public boolean onQueryTextSubmit(String query) {
                    for (MultiStoreConfig multiStoreConfig : multiStoreConfigs) {
                        if (multiStoreConfig.isEnabled() && multiStoreConfig.getTitle().startsWith(query) && !multiStoreConfig.getLatitudeString().isEmpty() && !multiStoreConfig.getLongitudeString().isEmpty()) {
                            LatLng latLng = new LatLng(multiStoreConfig.getLatitude(), multiStoreConfig.getLongitude());
                            final Marker marker = mMap.addMarker(new MarkerOptions()
                                    .title(L.getString(L.string.nearby_map_marker_title)/**/)
                                    .position(latLng));
                            searchView.setQuery(multiStoreConfig.getTitle() + ", " + multiStoreConfig.getDescription(), true);
                            Glide.with(thisActivity)
                                    .load(multiStoreConfig.getIcon_url())
                                    .asBitmap()
                                    .into(new SimpleTarget<Bitmap>(128, 128) {
                                        @Override
                                        public void onResourceReady(Bitmap resource, GlideAnimation<? super Bitmap> glideAnimation) {
                                            marker.setIcon(BitmapDescriptorFactory.fromBitmap(resource));
                                        }
                                    });
                            marker.setTag(multiStoreConfig);
                            mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(latLng, DEFAULT_ZOOM));
                            return true;
                        }
                    }
                    return true;
                }

                @Override
                public boolean onQueryTextChange(String newText) {
                    return false;
                }
            });
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        if (!ListUtils.isEmpty(MultiStoreConfig.getMapMenuOptions())) {
            int id = 0;
            for (MultiStoreConfig.MapMenuOption menuOption : MultiStoreConfig.getMapMenuOptions()) {
                MenuItem menuItem = menu.add(0, id++, 0, menuOption.title);
                menuItem.setShowAsAction(MenuItem.SHOW_AS_ACTION_NEVER);
            }
        }
        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        List<MultiStoreConfig.MapMenuOption> mapMenuOptions = MultiStoreConfig.getMapMenuOptions();
        if (!ListUtils.isEmpty(mapMenuOptions)) {
            for (MultiStoreConfig.MapMenuOption menuOption : mapMenuOptions) {
                if (item.getTitle().equals(menuOption.title)) {
                    Intent intent = new Intent(this, WebViewActivity.class);
                    intent.putExtra(Extras.ARG_URL, menuOption.url);
                    intent.putExtra(Extras.ARG_TITLE, menuOption.title);
                    startActivity(intent);
                    return true;
                }
            }
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onBackPressed() {
        if (llBottomSheet.getVisibility() == View.VISIBLE) {
            llBottomSheet.setVisibility(View.GONE);
        }
        Intent intent = new Intent();
        setResult(RESULT_CANCELED, intent);
        finish();
    }

    private void plotMarker() {
        plotMarker(null);
    }

    private void plotMarker(Place place) {
        String action = getIntent().getAction();
        if (BuildConfig.SEARCH_NEARBY && (action == null || !action.equals(Constants.ACTION_MULTI_STORE_LOCATE_ALL))) {
            LatLng latLng;
            MarkerOptions markerOptions = new MarkerOptions();
            if (place != null) {
                markerOptions.title(L.getString(L.string.nearby_map_marker_title));
                searchView.setQuery(place.getName().toString() + ", " + place.getAddress().toString(), true);
                latLng = place.getLatLng();
            } else if (mLastKnownLocation != null) {
                markerOptions.title(L.getString(L.string.nearby_map_marker_title));
                latLng = new LatLng(mLastKnownLocation.getLatitude(), mLastKnownLocation.getLongitude());
            } else {
                return;
            }
            removeMarker();
            markerOptions.position(latLng);
            Bitmap bitmap = Helper.vectorToBitmap(R.drawable.ic_vc_map_marker, Helper.getThemeColor());
            markerOptions.icon(BitmapDescriptorFactory.fromBitmap(bitmap));
            mMarker = mMap.addMarker(markerOptions);
            mMarker.showInfoWindow();
            if (place != null) {
                mMap.animateCamera(CameraUpdateFactory.newCameraPosition(new CameraPosition.Builder().target(place.getLatLng()).zoom(19f).tilt(70).build()));
            } else {
                mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(latLng, DEFAULT_ZOOM));
            }
        } else {
            for (MultiStoreConfig multiStoreConfig : multiStoreConfigs) {
                if (!multiStoreConfig.getLatitudeString().isEmpty() && !multiStoreConfig.getLongitudeString().isEmpty()) {
                    LatLng latLng = new LatLng(multiStoreConfig.getLatitude(), multiStoreConfig.getLongitude());
                    final Marker marker = mMap.addMarker(new MarkerOptions()
                            .title(L.getString(L.string.nearby_map_marker_title))
                            .position(latLng));
                    searchView.setQuery(multiStoreConfig.getTitle() + ", " + multiStoreConfig.getDescription(), true);
                    Glide.with(this)
                            .load(multiStoreConfig.getIcon_url())
                            .asBitmap()
                            .centerCrop()
                            .into(new SimpleTarget<Bitmap>(128, 128) {
                                @Override
                                public void onResourceReady(Bitmap resource, GlideAnimation<? super Bitmap> glideAnimation) {
                                    marker.setIcon(BitmapDescriptorFactory.fromBitmap(resource));
                                }
                            });
                    marker.setTag(multiStoreConfig);
                    if (multiStoreConfig.isEnabled()) {
                        mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(latLng, DEFAULT_ZOOM));
                    }
                }
            }
        }
    }

    private void clearAllMarkers() {
        mMap.clear();
    }

    private void getDirection(MultiStoreConfig selectedStore) {
        progress_map.setVisibility(View.VISIBLE);
        LatLng dest = new LatLng(selectedStore.getLatitude(), selectedStore.getLongitude());
        if (mLastKnownLocation == null) {
            mLastKnownLocation = new Location("");
            mLastKnownLocation.setLatitude(mDefaultLocation.latitude);
            mLastKnownLocation.setLongitude(mDefaultLocation.longitude);
        }

        LatLng origin = new LatLng(mLastKnownLocation.getLatitude(), mLastKnownLocation.getLongitude());
        String url = getDirectionsUrl(origin, dest);
        String urlDist = getDistanceMatrixUrl(origin, dest);
        FetchUrl downloadTask = new FetchUrl();
        downloadTask.execute(url);
        FetchDistUrl distTask = new FetchDistUrl();
        distTask.execute(urlDist);
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        if (mMap != null) {
            outState.putParcelable(KEY_CAMERA_POSITION, mMap.getCameraPosition());
            outState.putParcelable(KEY_LOCATION, mLastKnownLocation);
            super.onSaveInstanceState(outState);
        }
    }

    @Override
    public void onConnected(Bundle arg0) {
        SupportMapFragment mapFragment = (SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map);
        mapFragment.getMapAsync(this);
    }

    @Override
    public void onStart() {
        super.onStart();
        if (mGoogleApiClient != null) {
            mGoogleApiClient.connect();
        }
    }

    @Override
    public void onStop() {
        if (mGoogleApiClient != null && mGoogleApiClient.isConnected()) {
            mGoogleApiClient.disconnect();
        }
        super.onStop();
    }

    @Override
    public void onConnectionFailed(@NonNull ConnectionResult result) {
        Log.d("Play services connection failed: ConnectionResult.getErrorCode() = " + result.getErrorCode());
    }

    @Override
    public void onConnectionSuspended(int cause) {
        Log.d("Play services connection suspended");
    }

    @Override
    public void onMapReady(GoogleMap map) {
        mMap = map;
        mMap.setInfoWindowAdapter(new GoogleMap.InfoWindowAdapter() {
            @Override
            // Return null here, so that getInfoContents() is called next.
            public View getInfoWindow(Marker arg0) {
                return null;
            }

            @Override
            public View getInfoContents(Marker marker) {
                View infoWindow = getLayoutInflater().inflate(R.layout.custom_info_contents, (FrameLayout) findViewById(R.id.map), false);

                TextView title = ((TextView) infoWindow.findViewById(R.id.title));
                title.setText(marker.getTitle());

                TextView snippet = ((TextView) infoWindow.findViewById(R.id.snippet));
                snippet.setText(marker.getSnippet());
                snippet.setVisibility((!TextUtils.isEmpty(marker.getSnippet())) ? View.VISIBLE : View.GONE);
                return infoWindow;
            }
        });

        updateLocationUI();

        mMap.setOnMarkerClickListener(this);
    }

    private void showLocationSetting() {
        mGoogleApiClient = new GoogleApiClient.Builder(this)
                .enableAutoManage(this, this)
                .addConnectionCallbacks(this)
                .addApi(LocationServices.API)
                .addApi(Places.GEO_DATA_API)
                .addApi(Places.PLACE_DETECTION_API)
                .build();
        mGoogleApiClient.connect();

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
                        getDeviceLocation();
                        break;
                    case LocationSettingsStatusCodes.RESOLUTION_REQUIRED:
                        Log.d("Location settings are not satisfied.");
                        try {
                            status.startResolutionForResult(thisActivity, REQUEST_GPS_PERMISSION);
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

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_GPS_PERMISSION && resultCode == RESULT_OK) {
            getDeviceLocation();
        } else if (requestCode == REQUEST_CODE_AUTOCOMPLETE && resultCode == Activity.RESULT_OK) {
            Place place = PlaceAutocomplete.getPlace(this, data);
            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                return;
            }
            mMap.setMyLocationEnabled(true);
            plotMarker(place);
        } else if (resultCode == PlaceAutocomplete.RESULT_ERROR) {
            //Status status = PlaceAutocomplete.getStatus(this, data);
        }
    }

    private void getDeviceLocation() {
        if (Nammu.checkPermission(Manifest.permission.ACCESS_FINE_LOCATION)) {
            if (Helper.hasLocationAccess(this)) {
                mLastKnownLocation = LocationServices.FusedLocationApi.getLastLocation(mGoogleApiClient);
                plotMarker();
            }
        } else if (Nammu.shouldShowRequestPermissionRationale(this, Manifest.permission.ACCESS_FINE_LOCATION)) {
            Snackbar.make(mLayout, L.getString(L.string.allow_location_access), Snackbar.LENGTH_INDEFINITE).setAction(L.getString(L.string.ok), new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Nammu.askForPermission(thisActivity, Manifest.permission.ACCESS_FINE_LOCATION, permissionDeviceLocationCallback);
                }
            }).show();
        } else {
            Nammu.askForPermission(thisActivity, Manifest.permission.ACCESS_FINE_LOCATION, permissionDeviceLocationCallback);
        }

        // Set the map's camera position to the current location of the device.
        if (mCameraPosition != null) {
            mMap.moveCamera(CameraUpdateFactory.newCameraPosition(mCameraPosition));
        } else if (mLastKnownLocation != null) {
            mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(mLastKnownLocation.getLatitude(), mLastKnownLocation.getLongitude()), DEFAULT_ZOOM));
        } else {
            Log.d("Current location is null. Using defaults.");
            mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(mDefaultLocation, DEFAULT_ZOOM));
            mMap.getUiSettings().setMyLocationButtonEnabled(false);
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        Nammu.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    private void updateLocationUI() {
        if (mMap == null) {
            return;
        }
        removeMarker();

        if (Nammu.checkPermission(Manifest.permission.ACCESS_FINE_LOCATION)) {
            if (Helper.hasLocationAccess(this)) {
                mMap.setMyLocationEnabled(true);
                mMap.getUiSettings().setMyLocationButtonEnabled(true);
                mLastKnownLocation = LocationServices.FusedLocationApi.getLastLocation(mGoogleApiClient);
                plotMarker();
            } else {
                mMap.setMyLocationEnabled(false);
                mMap.getUiSettings().setMyLocationButtonEnabled(false);
                mLastKnownLocation = null;
            }
        } else if (Nammu.shouldShowRequestPermissionRationale(this, Manifest.permission.ACCESS_FINE_LOCATION)) {
            Snackbar.make(mLayout, L.getString(L.string.you_need_to_allow_permission), Snackbar.LENGTH_INDEFINITE).setAction(L.getString(L.string.ok), new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Nammu.askForPermission(thisActivity, Manifest.permission.ACCESS_FINE_LOCATION, permissionLocationCallback);
                }
            }).show();
        } else {
            Nammu.askForPermission(thisActivity, Manifest.permission.ACCESS_FINE_LOCATION, permissionLocationCallback);
        }
    }

    public void removeMarker() {
        if (mMarker != null) {
            mMarker.remove();
        }
    }

    @Override
    public boolean onMarkerClick(Marker marker) {
        String action = getIntent().getAction();
        if (BuildConfig.SEARCH_NEARBY && (action == null || !action.equals(Constants.ACTION_MULTI_STORE_LOCATE_ALL))) {
            Intent intent = new Intent(thisActivity, MultiStoreListActivity.class);
            intent.setAction(Constants.ACTION_MULTI_STORE_SEARCH_NEARBY);
            intent.putExtra("latitude", marker.getPosition().latitude);
            intent.putExtra("longitude", marker.getPosition().longitude);
            startActivityForResult(intent, REQUEST_SEARCH_NEARBY);
        } else {
            MultiStoreConfig multiStoreConfig = (MultiStoreConfig) marker.getTag();
            if (multiStoreConfig != null) {
                tv_store_name.setText(multiStoreConfig.getTitle());
                Glide.with(this)
                        .load(multiStoreConfig.getIcon_url()).placeholder(R.drawable.app_icon)
                        .into(iv_store);
                text_address.setVisibility(View.GONE);
                llBottomSheet.setVisibility(View.VISIBLE);
                selectedMultiStoreConfig = multiStoreConfig;
            } else {
                Log.d("This store is not yet open");
                Snackbar.make(mLayout, L.getString(L.string.store_is_not_yet_open), Snackbar.LENGTH_SHORT).show();
            }
        }
        return true;
    }

    private String getDistanceMatrixUrl(LatLng origin, LatLng dest) {
        return "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial" + "&origins=" + origin.latitude + "," + origin.longitude + "&destinations=" + dest.latitude + "," + dest.longitude + "&key=" + getString(R.string.google_android_geo_api_key);
    }

    private String getDirectionsUrl(LatLng origin, LatLng dest) {
        // Origin of route
        String str_origin = "origin=" + origin.latitude + "," + origin.longitude;

        // Destination of route
        String str_dest = "destination=" + dest.latitude + "," + dest.longitude;

        // Sensor enabled
        String sensor = "sensor=false";
        String mode = "mode=driving";

        // Building the parameters to the web service
        String parameters = str_origin + "&" + str_dest + "&" + sensor + "&" + mode;

        // Output format
        String output = "json";

        // Building the url to the web service
        String url = "https://maps.googleapis.com/maps/api/directions/" + output + "?" + parameters + "&key=" + getString(R.string.google_android_geo_api_key);;

        return url;
    }

    private String downloadUrl(String strUrl) throws IOException {
        String data = "";
        InputStream iStream;
        HttpURLConnection urlConnection;
        try {
            URL url = new URL(strUrl);
            urlConnection = (HttpURLConnection) url.openConnection();
            urlConnection.connect();
            iStream = urlConnection.getInputStream();
            BufferedReader br = new BufferedReader(new InputStreamReader(iStream));
            StringBuffer sb = new StringBuffer();
            String line = "";
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
            data = sb.toString();
            Log.d("downloadUrl", data);
            br.close();

        } catch (Exception e) {
            Log.d("Exception", e.toString());
        } finally {
        }
        return data;
    }

    public void openSearchLocation() {
        try {
            Intent intent = new PlaceAutocomplete.IntentBuilder(PlaceAutocomplete.MODE_OVERLAY)
                    //.setBoundsBias(new LatLngBounds(deviceLatLng, deviceLatLng))
                    .build(this);
            startActivityForResult(intent, REQUEST_CODE_AUTOCOMPLETE);
        } catch (GooglePlayServicesRepairableException e) {
            GoogleApiAvailability.getInstance().getErrorDialog(this, e.getConnectionStatusCode(), 0).show();
        } catch (GooglePlayServicesNotAvailableException e) {
            String message = "Google Play Services is not available: " + GoogleApiAvailability.getInstance().getErrorString(e.errorCode);
            Toast.makeText(this, message, Toast.LENGTH_SHORT).show();
        }
    }

    private static class SearchSuggestionsAdapter extends SimpleCursorAdapter {
        private static final String[] mFields = {"_id", "result"};
        private static final String[] mVisible = {"result"};
        private static final int[] mViewIds = {android.R.id.text1};

        public SearchSuggestionsAdapter(Context context) {
            super(context, R.layout.item_store, null, mVisible, mViewIds, 0);
        }

        @Override
        public Cursor runQueryOnBackgroundThread(CharSequence constraint) {
            return new SuggestionsCursor(constraint);
        }

        @Override
        public void bindView(View view, Context context, Cursor cursor) {
            TextView text_0 = (TextView) view.findViewById(R.id.text_0);
            text_0.setText(cursor.getString(1));
        }

        private static class SuggestionsCursor extends AbstractCursor {
            private ArrayList<String> mResults;

            public SuggestionsCursor(CharSequence constraint) {
                mResults = new ArrayList<>();
                for (MultiStoreConfig multiStoreConfig : MultiStoreConfig.getMultiStoreConfigs()) {
                    mResults.add(multiStoreConfig.getTitle());
                }
                if (!TextUtils.isEmpty(constraint)) {
                    String constraintString = constraint.toString().toLowerCase(Locale.ROOT);
                    Iterator<String> iterator = mResults.iterator();
                    while (iterator.hasNext()) {
                        if (!iterator.next().toLowerCase(Locale.ROOT).startsWith(constraintString)) {
                            iterator.remove();
                        }
                    }
                }
            }

            @Override
            public int getCount() {
                return mResults != null ? mResults.size() : 0;
            }

            @Override
            public String[] getColumnNames() {
                return mFields;
            }

            @Override
            public long getLong(int column) {
                if (column == 0) {
                    return mPos;
                }
                throw new UnsupportedOperationException("unimplemented");
            }

            @Override
            public String getString(int column) {
                if (column == 1) {
                    return mResults.get(mPos);
                }
                throw new UnsupportedOperationException("unimplemented");
            }

            @Override
            public short getShort(int column) {
                throw new UnsupportedOperationException("unimplemented");
            }

            @Override
            public int getInt(int column) {
                throw new UnsupportedOperationException("unimplemented");
            }

            @Override
            public float getFloat(int column) {
                throw new UnsupportedOperationException("unimplemented");
            }

            @Override
            public double getDouble(int column) {
                throw new UnsupportedOperationException("unimplemented");
            }

            @Override
            public boolean isNull(int column) {
                return false;
            }
        }
    }

    private class FetchUrl extends AsyncTask<String, Void, String> {
        @Override
        protected String doInBackground(String... url) {
            String data = "";
            try {
                data = downloadUrl(url[0]);
            } catch (Exception e) {
                Log.d("FetchUrl Task", e.toString());
            }
            return data;
        }

        @Override
        protected void onPostExecute(String result) {
            super.onPostExecute(result);
            ParserTask parserTask = new ParserTask();
            parserTask.execute(result);
        }
    }

    private class FetchDistUrl extends AsyncTask<String, Void, String> {
        @Override
        protected String doInBackground(String... url) {
            String data = "";
            try {
                data = downloadUrl(url[0]);
                Log.d("Background Task data", data);
            } catch (Exception e) {
                Log.d("Background Task", e.toString());
            }
            return data;
        }

        @Override
        protected void onPostExecute(String result) {
            super.onPostExecute(result);
            parseDistanceJson(result);
            Log.d("Background Task data", result);
        }
    }

    private void parseDistanceJson(String data) {
        JSONObject jObject;
        long distance = 0;
        String duration = "";
        try {
            jObject = new JSONObject(data);
            JSONArray jsonArray = jObject.getJSONArray("rows");

            JSONObject element = jsonArray.getJSONObject(0).getJSONArray("elements").getJSONObject(0);
            String status = element.getString("status");

            if (status.compareTo("OK") == 0) {
                if (element.has("distance")) {
                    distance = element.getJSONObject("distance").getLong("value");
                    // element.getJSONObject("distance").get("value");
                }

                if (element.has("duration")) {
                    duration = element.getJSONObject("duration").getString("text");
                    // element.getJSONObject("duration").get("value");
                }
            } else {
                Toast.makeText(thisActivity, L.getString(L.string.error_in_distance), Toast.LENGTH_SHORT).show();
            }

        } catch (JSONException e) {
            e.printStackTrace();
        }

        if (distance != 0) {
            text_distance.setText(Helper.convertMeterToKms(distance) + " km,\n" + duration);
            text_distance.setVisibility(View.VISIBLE);
        }
    }

    private class ParserTask extends AsyncTask<String, Integer, List<List<HashMap<String, String>>>> {
        @Override
        protected List<List<HashMap<String, String>>> doInBackground(String... jsonData) {
            JSONObject jObject;
            List<List<HashMap<String, String>>> routes = null;
            try {
                jObject = new JSONObject(jsonData[0]);
                Log.d("ParserTask", jsonData[0]);
                DirectionsJSONParser parser = new DirectionsJSONParser();
                Log.d("ParserTask", parser.toString());
                routes = parser.parse(jObject);
                Log.d("ParserTask", "Executing routes");
                Log.d("ParserTask", routes.toString());

            } catch (Exception e) {
                Log.d("ParserTask", e.toString());
                e.printStackTrace();
            }
            return routes;
        }

        @Override
        protected void onPostExecute(List<List<HashMap<String, String>>> result) {
            ArrayList<LatLng> points;
            for (int i = 0; i < result.size(); i++) {
                points = new ArrayList<>();
                lineOptions = new PolylineOptions();
                List<HashMap<String, String>> path = result.get(i);
                for (int j = 0; j < path.size(); j++) {
                    HashMap<String, String> point = path.get(j);
                    double lat = Double.parseDouble(point.get("lat"));
                    double lng = Double.parseDouble(point.get("lng"));
                    LatLng position = new LatLng(lat, lng);
                    points.add(position);
                }
                lineOptions.addAll(points);
                lineOptions.width(10);
                lineOptions.color(Color.RED);
            }

            if (lineOptions != null) {
                mMap.addPolyline(lineOptions);

            } else {
                Snackbar.make(mLayout, L.getString(L.string.error_in_route), Snackbar.LENGTH_SHORT).show();
            }
            progress_map.setVisibility(View.GONE);
        }
    }
}