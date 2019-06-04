package com.twist.tmstore;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.location.Location;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.design.widget.Snackbar;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v4.os.ResultReceiver;
import android.support.v7.app.ActionBar;
import android.support.v7.widget.CardView;
import android.text.InputType;
import android.text.TextUtils;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.common.GooglePlayServicesRepairableException;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.location.places.Place;
import com.google.android.gms.location.places.ui.PlaceAutocomplete;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.twist.dataengine.DataEngine;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.entities.TM_Region;
import com.twist.tmstore.adapters.Adapter_HtmlString;
import com.twist.tmstore.config.GuestUserConfig;
import com.twist.tmstore.config.MultiVendorConfig;
import com.twist.tmstore.entities.Address;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.entities.DummyUser;
import com.twist.tmstore.listeners.DataTaskListener;
import com.twist.tmstore.services.FetchAddressIntentService;
import com.twist.tmstore.services.LocationTracker;
import com.utils.AnalyticsHelper;
import com.utils.AppLocationService;
import com.utils.CContext;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.JsonUtils;
import com.utils.LocationAddress;
import com.utils.Log;
import com.utils.customviews.AwesomeSpinner;

import org.json.JSONException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import pl.tajchert.nammu.Nammu;
import pl.tajchert.nammu.PermissionCallback;

public class ProfileActivity extends BaseActivity {

    private Button btn_update;
    private EditText txt_name_first, txt_name_last, txt_email, txt_mobile;
    private EditText firstname_1, lastname_1, address_1_1, address_2_1, city_1, postcode_1, email_1, phone_1;
    private EditText firstname_2, lastname_2, address_1_2, address_2_2, city_2, postcode_2;

    private TextView txt_copyabove;
    private TextView text_autofill;

    private static String[] countriesForNumericPinCodes = {"IN"};

    private View coordinatorLayout;
    private CheckBox checkBox;

    private boolean showFullProfileSection = false;

    private TM_Region selected_country_1;
    private TM_Region selected_country_2;
    private TM_Region selected_state_1;
    private TM_Region selected_state_2;
    private TM_Region selected_city_1;
    private TM_Region selected_city_2;
    private TM_Region selected_subdistrict_1;
    private TM_Region selected_subdistrict_2;

    private LocationTracker gps;
    private String mAddressOutput;
    private AddressResultReceiver mResultReceiver;

    private boolean showAutoFillAddress = true;

    Spinner spinnerCountry1;
    Spinner spinnerState1;
    Spinner spinnerCity1;
    Spinner spinnerSubDistrict1;

    Spinner spinnerCountry2;
    Spinner spinnerState2;
    Spinner spinnerCity2;
    Spinner spinnerSubDistrict2;
    private View card_view_basic_detail;

    public Address address;

    private static final int REQUEST_CODE_AUTOCOMPLETE = 1;

    private LatLng deviceLatLng = new LatLng(0, 0);
    private LatLng addressLatLng = new LatLng(0, 0);

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_edit_profile);

        Bundle bundle = getIntent().getExtras();
        if (bundle != null) {
            try {
                showFullProfileSection = bundle.getBoolean(Extras.SHOW_FULL_PROFILE);
                if (bundle.containsKey(Extras.LOCATION_DATA_EXTRA)) {
                    address = (Address) bundle.getSerializable(Extras.LOCATION_DATA_EXTRA);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        coordinatorLayout = findViewById(R.id.scroll_view);
        coordinatorLayout.requestFocus();

        card_view_basic_detail = findViewById(R.id.card_view_basic_detail);

        ((TextView) findViewById(R.id.text_basic_details)).setText(getString(L.string.basic_details));
        ((TextView) findViewById(R.id.shipping_address)).setText(getString(L.string.shipping_address));
        ((TextView) findViewById(R.id.billing_address)).setText(getString(L.string.billing_address));

        initComponents();

        if (address != null) {
            setShippingAddressFromMap(address);
        }
        initCompulsoryFields();

        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setHomeButtonEnabled(true);
            actionBar.setDisplayHomeAsUpEnabled(true);
            Drawable upArrow = CContext.getDrawable(this, R.drawable.abc_ic_ab_back_material);
            upArrow.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_ATOP);
            actionBar.setHomeAsUpIndicator(upArrow);
        }

        if (AppInfo.AUTO_DETECT_ADDRESS) {
            initAutoLocationService();
            fetchAndFillLocation();
        }
        setTitleText(getString(L.string.edit_profile));
        AnalyticsHelper.registerVisitScreenEvent(Constants.PROFILE);
    }

    public void getMyLocation() {
        if (Nammu.checkPermission(android.Manifest.permission.ACCESS_FINE_LOCATION)) {
            setLocation();
        } else {
            final PermissionCallback permissionLocationCallback = new PermissionCallback() {
                @Override
                public void permissionGranted() {
                    Helper.hasLocationAccess(ProfileActivity.this);
                    setLocation();
                }

                @Override
                public void permissionRefused() {
                    Helper.toast(coordinatorLayout, getString(L.string.permission_denied));
                }
            };
            if (Nammu.shouldShowRequestPermissionRationale(this, android.Manifest.permission.ACCESS_FINE_LOCATION)) {
                Snackbar.make(coordinatorLayout, getString(L.string.allow_location_access), Snackbar.LENGTH_INDEFINITE)
                        .setAction(getString(L.string.ok), new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                Nammu.askForPermission(ProfileActivity.this, android.Manifest.permission.ACCESS_FINE_LOCATION, permissionLocationCallback);
                            }
                        }).show();
            } else {
                Nammu.askForPermission(ProfileActivity.this, android.Manifest.permission.ACCESS_FINE_LOCATION, permissionLocationCallback);
            }
        }
    }

    private void setLocation() {
        gps = new LocationTracker(ProfileActivity.this);
        // check if GPS enabled
        if (gps.canGetLocation()) {
            double latitude = gps.getLatitude();
            double longitude = gps.getLongitude();
            Intent intent = new Intent(this, FetchAddressIntentService.class);
            mResultReceiver = new AddressResultReceiver(new Handler());
            intent.putExtra(Constants.RECEIVER, mResultReceiver);
            intent.putExtra(Constants.LAT, latitude);
            intent.putExtra(Constants.LNG, longitude);
            startService(intent);
        } else {
            gps.showSettingsAlert();
        }
    }


    private class AddressResultReceiver extends ResultReceiver {
        AddressResultReceiver(Handler handler) {
            super(handler);
        }

        @Override
        protected void onReceiveResult(int resultCode, Bundle resultData) {
            mAddressOutput = resultData.getString(Constants.RESULT_DATA_KEY);
            if (mAddressOutput != null) {
                String[] strings = mAddressOutput.split("\n");
                try {
                    city_1.setText(strings[0]);
                } catch (Exception e) {
                    e.printStackTrace();
                }

                try {
                    postcode_1.setText(strings[1]);
                } catch (Exception e) {
                    e.printStackTrace();
                }

                try {
                    String state = strings[2];
                    if (Helper.isValidString(state)) {
                        int matchingStateId = ((Adapter_HtmlString) spinnerState1.getAdapter()).findItem(state);
                        if (matchingStateId != -1) {
                            spinnerState1.setSelection(matchingStateId);
                            spinnerState1.setVisibility(View.VISIBLE);
                        }
                    } else {
                        spinnerState1.setVisibility(View.GONE);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }

                try {
                    address_1_1.setText(strings[3]);
                } catch (Exception e) {
                    e.printStackTrace();
                }

                try {
                    String country = strings[4];
                    int matchingCountryId = ((Adapter_HtmlString) spinnerCountry1.getAdapter()).findItem(country);
                    if (matchingCountryId != -1) {
                        spinnerCountry1.setSelection(matchingCountryId);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private void fetchAndFillLocation() {
        getLocation(new DataTaskListener<Location>() {
            @Override
            public void onTaskDone(Location location) {
                if (location != null) {
                    LocationAddress.getAddressFromCoords(location.getLatitude(), location.getLongitude(), getApplicationContext(), new Handler() {
                        @Override
                        public void handleMessage(Message message) {
                            String locationAddress = null;
                            if (message.what == 1) {
                                Bundle bundle = message.getData();
                                locationAddress = bundle.getString("address");
                            }
                            address_2_1.setText(locationAddress);
                            address_2_2.setText(locationAddress);
                        }
                    });
                }
            }

            @Override
            public void onTaskFailed(String error) {
            }
        });
    }

    AppLocationService appLocationService;

    private void initAutoLocationService() {
        appLocationService = new AppLocationService(ProfileActivity.this);
    }

    private void getLocation(final DataTaskListener<Location> taskListener) {
        if (ActivityCompat.checkSelfPermission(this, android.Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED || ActivityCompat.checkSelfPermission(this, android.Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            String[] requiredPermissions = {android.Manifest.permission.ACCESS_FINE_LOCATION, android.Manifest.permission.ACCESS_COARSE_LOCATION};
            Nammu.askForPermission(MainActivity.mActivity, requiredPermissions, new PermissionCallback() {
                @Override
                public void permissionGranted() {
                    if (taskListener != null)
                        taskListener.onTaskDone(appLocationService.getLocation(LocationManager.GPS_PROVIDER));
                }

                @Override
                public void permissionRefused() {
                    if (taskListener != null)
                        taskListener.onTaskFailed(getString(L.string.permission_denied));
                }
            });
        } else {
            if (taskListener != null)
                taskListener.onTaskDone(appLocationService.getLocation(LocationManager.GPS_PROVIDER));
        }
    }

    private void initComponents() {
        btn_update = (Button) findViewById(R.id.btn_update);
        btn_update.setText(getString(L.string.update));
        Helper.stylize(btn_update);

        txt_copyabove = (TextView) findViewById(R.id.txt_copyabove);
        txt_copyabove.setText(getString(L.string.add_billing_address));

        text_autofill = (TextView) findViewById(R.id.text_autofill);
        text_autofill.setText(getString(L.string.text_autofill));

        /* basic details */
        txt_name_first = (EditText) findViewById(R.id.txt_name_first);
        txt_name_first.setHint(getString(L.string.first_name));

        txt_name_last = (EditText) findViewById(R.id.txt_name_last);
        txt_name_last.setHint(getString(L.string.last_name));

        txt_email = (EditText) findViewById(R.id.txt_email);
        txt_email.setHint(getString(L.string.email_address));

        txt_mobile = (EditText) findViewById(R.id.txt_mobile);
        txt_mobile.setHint(getString(L.string.mobile_number));

        /* for billing address */
        firstname_1 = (EditText) findViewById(R.id.firstname_1);
        firstname_1.setHint(getString(L.string.first_name));

        lastname_1 = (EditText) findViewById(R.id.lastname_1);
        lastname_1.setHint(getString(L.string.last_name));

        //company_1 = (EditText) findViewById(R.id.company_1);

        address_1_1 = (EditText) findViewById(R.id.address_1_1);
        address_1_1.setHint(getString(L.string.address1));

        address_2_1 = (EditText) findViewById(R.id.address_2_1);
        address_2_1.setHint(getString(L.string.address2));

        if (AppInfo.USE_LAT_LONG_IN_ORDER) {
            Helper.setDrawableLeft(address_2_1, R.drawable.ic_vc_location);
            address_2_1.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    getCurrentLocation();
                }
            });
            address_2_1.setOnFocusChangeListener(new View.OnFocusChangeListener() {
                @Override
                public void onFocusChange(View v, boolean hasFocus) {
                    if (hasFocus) {
                        getCurrentLocation();
                    }
                }
            });
        }

        city_1 = (EditText) findViewById(R.id.city_1);
        city_1.setHint(getString(L.string.city));

        postcode_1 = (EditText) findViewById(R.id.postcode_1);
        postcode_1.setHint(getString(L.string.postcode));

        email_1 = (EditText) findViewById(R.id.email_1);
        email_1.setHint(getString(L.string.email));

        phone_1 = (EditText) findViewById(R.id.phone_1);
        phone_1.setHint(getString(L.string.contact_number));

        /* for shipping address */
        firstname_2 = (EditText) findViewById(R.id.firstname_2);
        firstname_2.setHint(getString(L.string.first_name));

        lastname_2 = (EditText) findViewById(R.id.lastname_2);
        lastname_2.setHint(getString(L.string.last_name));

        address_1_2 = (EditText) findViewById(R.id.address_1_2);
        address_1_2.setHint(getString(L.string.address1));

        address_2_2 = (EditText) findViewById(R.id.address_2_2);
        address_2_2.setHint(getString(L.string.address2));

        city_2 = (EditText) findViewById(R.id.city_2);
        city_2.setHint(getString(L.string.city));

        postcode_2 = (EditText) findViewById(R.id.postcode_2);
        postcode_2.setHint(getString(L.string.postcode));

        final CardView billingAddressCardView = (CardView) findViewById(R.id.billing_address_card);
        billingAddressCardView.setVisibility(View.GONE);
        checkBox = (CheckBox) findViewById(R.id.checkbox_shipping_as_billing);
        checkBox.setText(getString(L.string.shipping_as_billing_address));
        Helper.stylize(checkBox);
        checkBox.setChecked(true);
        checkBox.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {
                    billingAddressCardView.setVisibility(View.GONE);
                } else {
                    copyAddress();
                    billingAddressCardView.setVisibility(View.VISIBLE);
                }
            }
        });

        //txt_mobile.setText(AppUser.getInstance().username);
        txt_mobile.setVisibility(View.GONE); //this is not available in WooCommerce

        txt_email.setText(AppUser.getEmail());
        txt_email.setActivated(false);
        txt_email.setFocusable(false);
        txt_email.setClickable(false);
        txt_email.setKeyListener(null);

        txt_name_first.setText(AppUser.getInstance().first_name);
        txt_name_last.setText(AppUser.getInstance().last_name);

        LinearLayout region_section_1 = (LinearLayout) findViewById(R.id.region_section_1);
        LinearLayout region_section_2 = (LinearLayout) findViewById(R.id.region_section_2);

        boolean isRajaOngkir = AppInfo.SHIPPING_PROVIDER.equals(Constants.Key.SHIPPING_RAJAONGKIR);
        spinnerCountry1 = addRegionSpinner(region_section_1, getString(L.string.country));
        spinnerState1 = addRegionSpinner(region_section_1, getString(L.string.state));
        spinnerCity1 = addRegionSpinner(region_section_1, !isRajaOngkir ? getString(L.string.city) : getString(L.string.subdistrict));
        spinnerSubDistrict1 = addRegionSpinner(region_section_1, !isRajaOngkir ? getString(L.string.subdistrict) : getString(L.string.province));
        spinnerCountry2 = addRegionSpinner(region_section_2, !isRajaOngkir ? getString(L.string.country) : getString(L.string.country));
        spinnerState2 = addRegionSpinner(region_section_2, !isRajaOngkir ? getString(L.string.state) : getString(L.string.city));
        spinnerCity2 = addRegionSpinner(region_section_2, !isRajaOngkir ? getString(L.string.city) : getString(L.string.subdistrict));
        spinnerSubDistrict2 = addRegionSpinner(region_section_2, !isRajaOngkir ? getString(L.string.subdistrict) : getString(L.string.province));

        spinnerState1.setVisibility(View.GONE);
        spinnerCity1.setVisibility(View.GONE);
        spinnerSubDistrict1.setVisibility(View.GONE);

        spinnerState2.setVisibility(View.GONE);
        spinnerCity2.setVisibility(View.GONE);
        spinnerSubDistrict2.setVisibility(View.GONE);

        if (!AppInfo.EXCLUDED_ADDRESSES.contains(Constants.Key.BILLING_COUNTRY) && !AppInfo.EXCLUDED_ADDRESSES.contains(Constants.Key.SHIPPING_COUNTRY)) {
            showProgress(getString(L.string.loading_available_countries));
            DataEngine.getDataEngine().getShippingEngine().getCountries(null, new DataQueryHandler<List<TM_Region>>() {
                @Override
                public void onSuccess(List<TM_Region> data) {
                    hideProgress();
                    if (!AppInfo.EXCLUDED_ADDRESSES.contains(Constants.Key.BILLING_COUNTRY)) {
                        spinnerCountry1.setSelection(-1);
                        ((Adapter_HtmlString) spinnerCountry1.getAdapter()).updateItems(data);
                        ((AwesomeSpinner) spinnerCountry1).notifyItemsUpdated();
                        if (!data.isEmpty()) {
                            if (AppUser.getInstance().billing_address != null) {
                                int matchingCountryId = -1;
                                String previouslySelectedCountryCode = AppUser.getInstance().billing_address.countryCode;
                                for (int i = 0; i < data.size(); i++) {
                                    if (data.get(i).id.equals(previouslySelectedCountryCode)) {
                                        matchingCountryId = i;
                                        break;
                                    }
                                }
                                if (matchingCountryId != -1) {
                                    spinnerCountry1.setSelection(matchingCountryId);
                                }
                            }
                        }
                    } else {
                        spinnerCountry1.setVisibility(View.GONE);
                    }

                    if (!AppInfo.EXCLUDED_ADDRESSES.contains(Constants.Key.SHIPPING_COUNTRY)) {
                        spinnerCountry2.setSelection(-1);
                        ((Adapter_HtmlString) spinnerCountry2.getAdapter()).updateItems(data);
                        ((AwesomeSpinner) spinnerCountry2).notifyItemsUpdated();
                        if (!data.isEmpty()) {
                            if (AppUser.getInstance().shipping_address != null) {
                                int matchingCountryId = -1;
                                String previouslySelectedCountryCode = AppUser.getInstance().shipping_address.countryCode;
                                for (int i = 0; i < data.size(); i++) {
                                    if (data.get(i).id.equals(previouslySelectedCountryCode)) {
                                        matchingCountryId = i;
                                        break;
                                    }
                                }
                                if (matchingCountryId != -1) {
                                    spinnerCountry2.setSelection(matchingCountryId);
                                }
                            }
                        }
                    } else {
                        spinnerCountry2.setVisibility(View.GONE);
                    }
                }

                @Override
                public void onFailure(Exception error) {
                    error.printStackTrace();
                    hideProgress();
                }
            });
        } else {
            spinnerCountry1.setVisibility(View.GONE);
            spinnerCountry2.setVisibility(View.GONE);
        }

        spinnerCountry1.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if (position < 0) {
                    selected_country_1 = null;
                    return;
                }
                selected_country_1 = (TM_Region) spinnerCountry1.getAdapter().getItem(position);
                // not required to check it unless we have full list of countries
                // adjustPostalCodeEditText(postcode_1, selected_country_1.id);

                if (AppInfo.SHIPPING_PROVIDER.equals(Constants.Key.SHIPPING_RAJAONGKIR))
                    showProgress(getString(L.string.loading_available_states));
                else
                    showProgress(getString(L.string.loading_available_cities));

                DataEngine.getDataEngine().getShippingEngine().getStates(selected_country_1, new DataQueryHandler<List<TM_Region>>() {
                    @Override
                    public void onSuccess(List<TM_Region> data) {
                        hideProgress();
                        spinnerState1.setSelection(-1);
                        ((Adapter_HtmlString) spinnerState1.getAdapter()).updateItems(data);
                        ((AwesomeSpinner) spinnerState1).notifyItemsUpdated();
                        boolean showStates = !(data.isEmpty() || AppInfo.EXCLUDED_ADDRESSES.contains(Constants.Key.BILLING_STATE));
                        spinnerState1.setVisibility(showStates ? View.VISIBLE : View.GONE);
                        if (showStates) {
                            if (AppUser.getInstance().billing_address != null) {
                                int matchingStateId = -1;
                                String previouslySelectedStateCode = AppUser.getInstance().billing_address.stateCode;
                                for (int i = 0; i < data.size(); i++) {
                                    if (data.get(i).id.equals(previouslySelectedStateCode)) {
                                        matchingStateId = i;
                                        break;
                                    }
                                }
                                if (matchingStateId != -1) {
                                    spinnerState1.setSelection(matchingStateId);
                                }
                            }
                        }
                    }

                    @Override
                    public void onFailure(Exception error) {
                        error.printStackTrace();
                        hideProgress();
                    }
                });
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
                selected_country_1 = null;
            }
        });

        spinnerState1.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if (position < 0) {
                    selected_state_1 = null;
                    return;
                }
                selected_state_1 = (TM_Region) spinnerState1.getAdapter().getItem(position);
                if (AppInfo.SHIPPING_PROVIDER == Constants.Key.SHIPPING_RAJAONGKIR)
                    showProgress(getString(L.string.loading_available_cities));
                else
                    showProgress(getString(L.string.loading_available_subdistricts));

                DataEngine.getDataEngine().getShippingEngine().getCities(selected_state_1, new DataQueryHandler<List<TM_Region>>() {
                    @Override
                    public void onSuccess(List<TM_Region> data) {
                        hideProgress();
                        spinnerCity1.setSelection(-1);
                        ((Adapter_HtmlString) spinnerCity1.getAdapter()).updateItems(data);
                        ((AwesomeSpinner) spinnerCity1).notifyItemsUpdated();
                        spinnerCity1.setVisibility(data.isEmpty() ? View.GONE : View.VISIBLE);
                    }

                    @Override
                    public void onFailure(Exception error) {
                        error.printStackTrace();
                        hideProgress();
                    }
                });
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
                selected_state_1 = null;
            }
        });

        spinnerCity1.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if (position < 0) {
                    selected_city_1 = null;
                    return;
                }
                selected_city_1 = (TM_Region) spinnerCity1.getAdapter().getItem(position);
                if (AppInfo.SHIPPING_PROVIDER.equals(Constants.Key.SHIPPING_RAJAONGKIR)) {
                    showProgress(getString(L.string.loading_available_subdistricts));
                    DataEngine.getDataEngine().getShippingEngine().getSubDistricts(selected_city_1, new DataQueryHandler<List<TM_Region>>() {
                        @Override
                        public void onSuccess(List<TM_Region> data) {
                            hideProgress();
                            spinnerSubDistrict1.setSelection(-1);
                            ((Adapter_HtmlString) spinnerSubDistrict1.getAdapter()).updateItems(data);
                            ((AwesomeSpinner) spinnerSubDistrict1).notifyItemsUpdated();
                            spinnerSubDistrict1.setVisibility(data.isEmpty() ? View.GONE : View.VISIBLE);
                        }

                        @Override
                        public void onFailure(Exception error) {
                            error.printStackTrace();
                            hideProgress();
                        }
                    });
                } else {
                    showProgress(getString(L.string.loading_available_province));
                    DataEngine.getDataEngine().getShippingEngine().getSubDistricts(selected_city_1, selected_state_1.toString(), new DataQueryHandler<List<TM_Region>>() {
                        @Override
                        public void onSuccess(List<TM_Region> data) {
                            hideProgress();
                            spinnerSubDistrict1.setSelection(-1);
                            ((Adapter_HtmlString) spinnerSubDistrict1.getAdapter()).updateItems(data);
                            ((AwesomeSpinner) spinnerSubDistrict1).notifyItemsUpdated();
                            spinnerSubDistrict1.setVisibility(data.isEmpty() ? View.GONE : View.VISIBLE);
                        }

                        @Override
                        public void onFailure(Exception error) {
                            error.printStackTrace();
                            hideProgress();
                        }
                    });
                }
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
                selected_city_1 = null;
            }
        });

        spinnerSubDistrict1.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if (position < 0) {
                    selected_subdistrict_1 = null;
                    return;
                }
                selected_subdistrict_1 = (TM_Region) spinnerSubDistrict1.getAdapter().getItem(position);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
                selected_subdistrict_1 = null;
            }
        });

        spinnerCountry2.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if (position < 0) {
                    selected_country_2 = null;
                    return;
                }
                selected_country_2 = (TM_Region) spinnerCountry2.getAdapter().getItem(position);
                // not required to check it unless we have full list of countries
                //adjustPostalCodeEditText(postcode_2, selected_country_2.id);
                showProgress(getString(L.string.loading_available_states));
                DataEngine.getDataEngine().getShippingEngine().getStates(selected_country_2, new DataQueryHandler<List<TM_Region>>() {
                    @Override
                    public void onSuccess(List<TM_Region> data) {
                        hideProgress();
                        spinnerState2.setSelection(-1);
                        ((Adapter_HtmlString) spinnerState2.getAdapter()).updateItems(data);
                        ((AwesomeSpinner) spinnerState2).notifyItemsUpdated();
                        boolean showStates = !(data.isEmpty() || AppInfo.EXCLUDED_ADDRESSES.contains(Constants.Key.SHIPPING_STATE));
                        spinnerState2.setVisibility(showStates ? View.VISIBLE : View.GONE);
                        if (showStates) {
                            if (AppUser.getInstance().shipping_address != null) {
                                int matchingStateId = -1;
                                String previouslySelectedStateCode = AppUser.getInstance().shipping_address.stateCode;
                                for (int i = 0; i < data.size(); i++) {
                                    if (data.get(i).id.equals(previouslySelectedStateCode)) {
                                        matchingStateId = i;
                                        break;
                                    }
                                }
                                if (matchingStateId != -1) {
                                    spinnerState2.setSelection(matchingStateId);
                                }
                            }
                        }
                    }

                    @Override
                    public void onFailure(Exception error) {
                        error.printStackTrace();
                        hideProgress();
                    }
                });
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
                selected_country_2 = null;
            }
        });

        spinnerState2.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if (position < 0) {
                    selected_state_2 = null;
                    return;
                }
                selected_state_2 = (TM_Region) spinnerState2.getAdapter().getItem(position);
                showProgress(getString(L.string.loading_available_cities));
                DataEngine.getDataEngine().getShippingEngine().getCities(selected_state_2, new DataQueryHandler<List<TM_Region>>() {
                    @Override
                    public void onSuccess(List<TM_Region> data) {
                        hideProgress();
                        spinnerCity2.setSelection(-1);
                        ((Adapter_HtmlString) spinnerCity2.getAdapter()).updateItems(data);
                        ((AwesomeSpinner) spinnerCity2).notifyItemsUpdated();
                        spinnerCity2.setVisibility(data.isEmpty() ? View.GONE : View.VISIBLE);
                    }

                    @Override
                    public void onFailure(Exception error) {
                        error.printStackTrace();
                        hideProgress();
                    }
                });
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
                selected_state_2 = null;
            }
        });

        spinnerCity2.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if (position < 0) {
                    selected_city_2 = null;
                    return;
                }
                selected_city_2 = (TM_Region) spinnerCity2.getAdapter().getItem(position);
                showProgress(getString(L.string.loading_available_subdistricts));
                DataEngine.getDataEngine().getShippingEngine().getSubDistricts(selected_city_2, new DataQueryHandler<List<TM_Region>>() {
                    @Override
                    public void onSuccess(List<TM_Region> data) {
                        hideProgress();
                        spinnerSubDistrict2.setSelection(-1);
                        ((Adapter_HtmlString) spinnerSubDistrict2.getAdapter()).updateItems(data);
                        ((AwesomeSpinner) spinnerSubDistrict2).notifyItemsUpdated();
                        spinnerSubDistrict2.setVisibility(data.isEmpty() ? View.GONE : View.VISIBLE);
                    }

                    @Override
                    public void onFailure(Exception error) {
                        error.printStackTrace();
                        hideProgress();
                    }
                });
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
                selected_city_2 = null;
            }
        });

        spinnerSubDistrict2.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if (position < 0) {
                    selected_subdistrict_2 = null;
                    return;
                }
                selected_subdistrict_2 = (TM_Region) spinnerSubDistrict2.getAdapter().getItem(position);
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
                selected_subdistrict_2 = null;
            }
        });


        if (AppUser.getInstance().billing_address != null) {
            Address billingAddress = AppUser.getInstance().billing_address;
            if (!billingAddress.first_name.equals("")) {
                firstname_1.setText(billingAddress.first_name);
            } else if (!AppUser.getInstance().first_name.equals("")) {
                firstname_1.setText(AppUser.getInstance().first_name);
            }

            if (!billingAddress.last_name.equals("")) {
                lastname_1.setText(billingAddress.last_name);
            } else if (!AppUser.getInstance().last_name.equals("")) {
                lastname_1.setText(AppUser.getInstance().last_name);
            }

            //company_1.setText(billingAddress.company);
            address_1_1.setText(billingAddress.address_1);
            address_2_1.setText(billingAddress.address_2);

            city_1.setText(billingAddress.city);
            postcode_1.setText(billingAddress.postcode);
            // country_1.setText(billingAddress.country);
            email_1.setText(billingAddress.email);
            phone_1.setText(billingAddress.phone);
        } else {
            if (!AppUser.getInstance().first_name.equals("")) {
                firstname_1.setText(AppUser.getInstance().first_name);
            }
            if (!AppUser.getInstance().last_name.equals("")) {
                lastname_1.setText(AppUser.getInstance().last_name);
            }
        }

        if (AppUser.getInstance().shipping_address != null) {
            Address shippingAddress = AppUser.getInstance().shipping_address;
            firstname_2.setText(shippingAddress.first_name);
            lastname_2.setText(shippingAddress.last_name);
            //company_2.setText(shippingAddress.company);
            address_1_2.setText(shippingAddress.address_1);
            address_2_2.setText(shippingAddress.address_2);
            city_2.setText(shippingAddress.city);
            // state_2.setText(shippingAddress.state);
            postcode_2.setText(shippingAddress.postcode);
        }

        txt_copyabove.setPaintFlags(txt_copyabove.getPaintFlags() | Paint.UNDERLINE_TEXT_FLAG);
        txt_copyabove.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                copyAddress();
            }
        });
        txt_copyabove.setVisibility(View.GONE);

        text_autofill.setPaintFlags(text_autofill.getPaintFlags() | Paint.UNDERLINE_TEXT_FLAG);
        text_autofill.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                getMyLocation();
            }
        });
        text_autofill.setVisibility(showAutoFillAddress ? View.VISIBLE : View.GONE);


        firstname_1.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                if (hasFocus) {
                    if (isTextBoxEmpty(firstname_1) && !isTextBoxEmpty(txt_name_first)) {
                        firstname_1.setText(txt_name_first.getText());
                    }
                }
            }
        });

        lastname_1.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                if (hasFocus) {
                    if (isTextBoxEmpty(lastname_1) && !isTextBoxEmpty(txt_name_last)) {
                        lastname_1.setText(txt_name_last.getText());
                    }
                }
            }
        });

        if (isTextBoxEmpty(email_1)) {
            email_1.setText(AppUser.getEmail());
        }

        btn_update.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!showFullProfileSection && !AppUser.getInstance().hasBasicDetails()) {
                    copyShippingDetailsToBasicDetails();
                }
                if (checkBox.isChecked()) {
                    copyAddress();
                }

                if (AppInfo.mGuestUserConfig == null || !GuestUserConfig.isGuestCheckout() || AppUser.hasSignedIn()) {
                    updateAddress();
                } else {
                    if (!isValid()) {
                        showCompulsoryFields();
                        return;
                    }

                    AppInfo.dummyUser = createDummyUser();
                    hideProgress();
                    setResult(Constants.RESULT_EDIT_PROFILE_SKIP_LOGIN);
                    if (MultiVendorConfig.isSellerApp()) {
                        MainActivity.mActivity.showVendorSection();
                    } else {
                        finish();
                    }
                }
            }
        });

        if (!showFullProfileSection) {
            card_view_basic_detail.setVisibility(View.GONE);
        } else {
            card_view_basic_detail.setVisibility(View.VISIBLE);
        }

        hideExcludedFields();
        tagIgnoredFields();

        Helper.stylizeEdit(txt_name_first);
        Helper.stylizeEdit(txt_name_last);
        Helper.stylizeEdit(txt_email);
        Helper.stylizeEdit(txt_mobile);
        Helper.stylizeEdit(firstname_1);
        Helper.stylizeEdit(lastname_1);
        Helper.stylizeEdit(address_1_1);
        Helper.stylizeEdit(address_2_1);
        Helper.stylizeEdit(city_1);
        Helper.stylizeEdit(postcode_1);
        Helper.stylizeEdit(email_1);
        Helper.stylizeEdit(phone_1);
        Helper.stylizeEdit(firstname_2);
        Helper.stylizeEdit(lastname_2);
        Helper.stylizeEdit(address_1_2);
        Helper.stylizeEdit(address_2_2);
        Helper.stylizeEdit(city_2);
        Helper.stylizeEdit(postcode_2);
    }

    private void updateMultipleShippingAddress(Address address) {
        try {
            String addressJson = JsonUtils.getShippingString(address);
            if (!AppUser.getInstance().getAddressJson().equals(addressJson)) {
                showProgress(getString(L.string.updating));
                DataEngine.getDataEngine().updateShippingAddressesInBackground(AppUser.getUserId(), addressJson, new DataQueryHandler() {
                    @Override
                    public void onSuccess(Object data) {
                        hideProgress();
                        setResult(RESULT_OK);
                        if (MultiVendorConfig.isSellerApp()) {
                            MainActivity.mActivity.showVendorSection();
                        } else {
                            finish();
                        }

                    }

                    @Override
                    public void onFailure(Exception error) {
                        hideProgress();
                        Helper.toast(coordinatorLayout, L.string.error_updating_customer_data);
                    }
                });
            } else {
                setResult(RESULT_OK);
                Helper.toast(coordinatorLayout, L.string.already_have_same_shipping_address);
                if (MultiVendorConfig.isSellerApp()) {
                    MainActivity.mActivity.showVendorSection();
                } else {
                    finish();
                }
            }

        } catch (JSONException e) {
            e.printStackTrace();
            Helper.toast(coordinatorLayout, L.string.error_updating_customer_data);
        }
    }

    private void hideExcludedFields() {
        if (AppInfo.EXCLUDED_ADDRESSES != null) {
            for (String excludeKey : AppInfo.EXCLUDED_ADDRESSES) {
                switch (excludeKey) {
                    case Constants.Key.FIRST_NAME:
                        txt_name_first.setVisibility(View.GONE);
                        break;
                    case Constants.Key.LAST_NAME:
                        txt_name_last.setVisibility(View.GONE);
                        break;
                    case Constants.Key.EMAIL:
                        txt_email.setVisibility(View.GONE);
                        break;
                    case Constants.Key.BILLING_FIRST_NAME:
                        firstname_1.setVisibility(View.GONE);
                        break;
                    case Constants.Key.BILLING_LAST_NAME:
                        lastname_1.setVisibility(View.GONE);
                        break;
                    case Constants.Key.BILLING_ADDRESS_1:
                        address_1_1.setVisibility(View.GONE);
                        break;
                    case Constants.Key.BILLING_ADDRESS_2:
                        address_2_1.setVisibility(View.GONE);
                        break;
                    case Constants.Key.BILLING_CITY:
                        city_1.setVisibility(View.GONE);
                        break;
//                    case Constants.Key.BILLING_STATE:
//                        state_1.setVisibility(View.GONE);
//                        title_state_1.setVisibility(View.GONE);
//                        break;
                    case Constants.Key.BILLING_POSTCODE:
                        postcode_1.setVisibility(View.GONE);
                        break;
//                    case Constants.Key.BILLING_COUNTRY:
//                        country_1.setVisibility(View.GONE);
//                        title_country_1.setVisibility(View.GONE);
//                        break;
                    case Constants.Key.BILLING_EMAIL:
                        email_1.setVisibility(View.GONE);
                        break;
                    case Constants.Key.BILLING_PHONE:
                        phone_1.setVisibility(View.GONE);
                        break;
                    case Constants.Key.SHIPPING_FIRST_NAME:
                        firstname_2.setVisibility(View.GONE);
                        break;
                    case Constants.Key.SHIPPING_LAST_NAME:
                        lastname_2.setVisibility(View.GONE);
                        break;
                    case Constants.Key.SHIPPING_ADDRESS_1:
                        address_1_2.setVisibility(View.GONE);
                        break;
                    case Constants.Key.SHIPPING_ADDRESS_2:
                        address_2_2.setVisibility(View.GONE);
                        break;
                    case Constants.Key.SHIPPING_CITY:
                        city_2.setVisibility(View.GONE);
                        break;
//                    case Constants.Key.SHIPPING_STATE:
//                        state_2.setVisibility(View.GONE);
//                        title_state_2.setVisibility(View.GONE);
//                        break;
                    case Constants.Key.SHIPPING_POSTCODE:
                        postcode_2.setVisibility(View.GONE);
                        break;
//                    case Constants.Key.SHIPPING_COUNTRY:
//                        country_2.setVisibility(View.GONE);
//                        title_country_2.setVisibility(View.GONE);
//                        break;
                }
            }
        }

        if (DataEngine.getDataEngine().getShippingEngine().hasCitySelection()) {
            city_1.setVisibility(View.GONE);
            city_2.setVisibility(View.GONE);
        }
    }

    private void tagIgnoredFields() {
        if (AppInfo.OPTIONAL_ADDRESSES != null) {
            for (String excludeKey : AppInfo.OPTIONAL_ADDRESSES) {
                switch (excludeKey) {
                    case Constants.Key.FIRST_NAME:
                        txt_name_first.setTag("ignored");
                        break;
                    case Constants.Key.LAST_NAME:
                        txt_name_last.setTag("ignored");
                        break;
                    case Constants.Key.EMAIL:
                        txt_email.setTag("ignored");
                        break;
                    case Constants.Key.BILLING_FIRST_NAME:
                        firstname_1.setTag("ignored");
                        break;
                    case Constants.Key.BILLING_LAST_NAME:
                        lastname_1.setTag("ignored");
                        break;
                    case Constants.Key.BILLING_ADDRESS_1:
                        address_1_1.setTag("ignored");
                        break;
                    case Constants.Key.BILLING_ADDRESS_2:
                        address_2_1.setTag("ignored");
                        break;
                    case Constants.Key.BILLING_CITY:
                        city_1.setTag("ignored");
                        break;
//                    case Constants.Key.BILLING_STATE:
//                        state_1.setTag("ignored");
//                        title_state_1.setTag("ignored");
//                        break;
                    case Constants.Key.BILLING_POSTCODE:
                        postcode_1.setTag("ignored");
                        break;
//                    case Constants.Key.BILLING_COUNTRY:
//                        country_1.setTag("ignored");
//                        title_country_1.setTag("ignored");
//                        break;
                    case Constants.Key.BILLING_EMAIL:
                        email_1.setTag("ignored");
                        break;
                    case Constants.Key.BILLING_PHONE:
                        phone_1.setTag("ignored");
                        break;
                    case Constants.Key.SHIPPING_FIRST_NAME:
                        firstname_2.setTag("ignored");
                        break;
                    case Constants.Key.SHIPPING_LAST_NAME:
                        lastname_2.setTag("ignored");
                        break;
                    case Constants.Key.SHIPPING_ADDRESS_1:
                        address_1_2.setTag("ignored");
                        break;
                    case Constants.Key.SHIPPING_ADDRESS_2:
                        address_2_2.setTag("ignored");
                        break;
                    case Constants.Key.SHIPPING_CITY:
                        city_2.setTag("ignored");
                        break;
                    case Constants.Key.SHIPPING_STATE:
//                        state_2.setTag("ignored");
//                        title_state_2.setTag("ignored");
                        break;
                    case Constants.Key.SHIPPING_POSTCODE:
                        postcode_2.setTag("ignored");
                        break;
                    case Constants.Key.SHIPPING_COUNTRY:
//                        country_2.setTag("ignored");
//                        title_country_2.setTag("ignored");
                        break;
                }
            }
        }
    }

    private void copyShippingDetailsToBasicDetails() {
        txt_name_first.setText(firstname_1.getText());
        txt_name_last.setText(lastname_1.getText());
    }

    private void copyAddress() {
        firstname_2.setText(firstname_1.getText());
        lastname_2.setText(lastname_1.getText());
        //company_2.setText(company_1.getText());
        address_1_2.setText(address_1_1.getText());
        address_2_2.setText(address_2_1.getText());
        city_2.setText(city_1.getText());

        //country_2.setSelection(country_1.getSelectedItemPosition());
        //selected_country2 = selected_country1;

//        adapter_states2.clear();
//        //adapter_states1.addAll(adapter_states1.ite);
//        for (int i = 0; i < adapter_states1.getCount(); i++) {
//            adapter_states2.add(adapter_states1.getItem(i));
//        }
        //state_2.setSelection(state_1.getSelectedItemPosition());
        //state_2.setText(state_1.getText());
        postcode_2.setText(postcode_1.getText());
        //email_2.setText(email_1.getText());
        //phone_2.setText(phone_1.getText());

        selected_country_2 = selected_country_1;
        selected_state_2 = selected_state_1;
        selected_city_2 = selected_city_1;
        selected_subdistrict_2 = selected_subdistrict_1;

    }

    private void setShippingAddressFromMap(Address address) {

        List<Address> addressList = Address.getAddress1ByAddress2FromDB(address.address_2, address.postcode);

        if (addressList != null && !addressList.isEmpty()) {
            Address address1 = addressList.get(0);

            if (!TextUtils.isEmpty(address1.address_1)) {
                address_1_1.setText(address1.address_1);
                address_1_2.setText(address1.address_1);
            } else {
                address_1_1.setText("");
                address_1_2.setText("");
            }

        } else {
            address_1_1.setText(address.address_1);
            address_1_2.setText(address.address_1);
        }
        address_2_1.setText(address.address_2);
        address_2_2.setText(address.address_2);
        address_2_1.setEnabled(false);
        address_2_2.setEnabled(false);

        city_1.setText(address.city);
        city_2.setText(address.city);

        postcode_1.setText(address.postcode);
        postcode_2.setText(address.postcode);

        int matchingCountryId = ((Adapter_HtmlString) spinnerCountry1.getAdapter()).findItem(address.country);
        if (matchingCountryId != -1) {
            spinnerCountry2.setSelection(matchingCountryId);
        }

        if (Helper.isValidString(address.postcode)) {
            String autoDetectedState = address.state;
            int matchingStateId = ((Adapter_HtmlString) spinnerState1.getAdapter()).findItem(autoDetectedState);
            if (matchingStateId != -1) {
                spinnerState2.setSelection(matchingStateId);
                spinnerState2.setVisibility(View.VISIBLE);
            }
        } else {
            spinnerState2.setVisibility(View.GONE);
        }
    }

    private boolean isTextBoxEmpty(EditText editText) {
        return (editText.getText() == null || editText.getText().toString().trim().equals(""));
    }

    private void updateAddress() {
        if (!isValid()) {
            showCompulsoryFields();
            return;
        }
        showProgress(getString(L.string.updating));
        final DummyUser dummyUser = createDummyUser();
        try {
            String customerJsonString = JsonUtils.getCustomerJSON(dummyUser);
            Log.d("-- customerJsonString: [" + customerJsonString + "] --");
            DataEngine.getDataEngine().editCustomerDataInBackground(AppUser.getUserId() + "", customerJsonString, new DataQueryHandler<String>() {
                @Override
                public void onSuccess(String data) {
                    updateUserInfo(dummyUser);
                    hideProgress();
                    if (AppInfo.USE_MULTIPLE_SHIPPING_ADDRESSES) {
                        updateMultipleShippingAddress(dummyUser.shipping_address);
                        dummyUser.shipping_address.save();
                    } else {
                        setResult(RESULT_OK);
                        if (MultiVendorConfig.isSellerApp()) {
                            MainActivity.mActivity.showVendorSection();
                        } else {
                            finish();
                        }
                    }
                }

                @Override
                public void onFailure(Exception reason) {
                    hideProgress();
                    Helper.toast(coordinatorLayout, L.string.error_updating_customer_data);
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
            hideProgress();
            Helper.toast(coordinatorLayout, L.string.error_updating_customer_data);
        }
    }


    private DummyUser createDummyUser() {
        DummyUser dummyUser = new DummyUser();

        dummyUser.first_name = txt_name_first.getText().toString();
        dummyUser.last_name = txt_name_last.getText().toString();

        dummyUser.billing_address = new Address(getString(L.string.billing_address));
        dummyUser.billing_address.first_name = firstname_1.getText().toString();
        dummyUser.billing_address.last_name = lastname_1.getText().toString();
        dummyUser.billing_address.company = ""; //company_1.getText().toString();
        dummyUser.billing_address.address_1 = address_1_1.getText().toString();
        dummyUser.billing_address.address_2 = address_2_1.getText().toString();

        if (DataEngine.getDataEngine().getShippingEngine().hasCitySelection() && selected_city_1 != null) {
            if (AppInfo.SHIPPING_PROVIDER == Constants.Key.SHIPPING_EPEKEN_JNE || AppInfo.SHIPPING_PROVIDER == Constants.Key.SHIPPING_JNE_ALL_COURIER) {
                dummyUser.billing_address.city = selected_state_1.title;
            } else {
                dummyUser.billing_address.city = selected_city_1.toString();
            }
        } else {
            dummyUser.billing_address.city = city_1.getText().toString();
        }

        try {
            if (AppInfo.SHIPPING_PROVIDER == Constants.Key.SHIPPING_EPEKEN_JNE || AppInfo.SHIPPING_PROVIDER == Constants.Key.SHIPPING_JNE_ALL_COURIER) {
                dummyUser.billing_address.state = selected_subdistrict_1.title;
                dummyUser.billing_address.stateCode = selected_subdistrict_1.id;
            } else {
                dummyUser.billing_address.state = selected_state_1.title;
                dummyUser.billing_address.stateCode = selected_state_1.id;
            }
        } catch (Exception e) {
            dummyUser.billing_address.state = "";
            dummyUser.billing_address.stateCode = "";
        }
        //dummyUser.billing_address.state = state_1.getText().toString();
        dummyUser.billing_address.postcode = postcode_1.getText().toString();

        try {
            dummyUser.billing_address.country = selected_country_1.title;
            dummyUser.billing_address.countryCode = selected_country_1.id;
        } catch (Exception e) {
            dummyUser.billing_address.country = "";
            dummyUser.billing_address.countryCode = "";
        }
        dummyUser.billing_address.email = email_1.getText().toString();
        dummyUser.billing_address.phone = phone_1.getText().toString();

        {
            dummyUser.shipping_address = new Address(getString(L.string.shipping_address));
            dummyUser.shipping_address.first_name = firstname_2.getText().toString();
            dummyUser.shipping_address.last_name = lastname_2.getText().toString();
            dummyUser.shipping_address.company = ""; //company_2.getText().toString();
            dummyUser.shipping_address.address_1 = address_1_2.getText().toString();
            dummyUser.shipping_address.address_2 = address_2_2.getText().toString();


            if (DataEngine.getDataEngine().getShippingEngine().hasCitySelection() && selected_city_2 != null) {
                if (AppInfo.SHIPPING_PROVIDER == Constants.Key.SHIPPING_EPEKEN_JNE || AppInfo.SHIPPING_PROVIDER == Constants.Key.SHIPPING_JNE_ALL_COURIER) {
                    dummyUser.shipping_address.city = selected_city_2.title;
                } else {
                    dummyUser.shipping_address.city = selected_city_2.toString();
                }
            } else {
                dummyUser.shipping_address.city = city_2.getText().toString();
            }

            try {
                if (AppInfo.SHIPPING_PROVIDER == Constants.Key.SHIPPING_EPEKEN_JNE || AppInfo.SHIPPING_PROVIDER == Constants.Key.SHIPPING_JNE_ALL_COURIER) {
                    dummyUser.shipping_address.state = selected_subdistrict_2.title;
                    dummyUser.shipping_address.stateCode = selected_subdistrict_2.id;
                } else {
                    dummyUser.shipping_address.state = selected_state_2.title;
                    dummyUser.shipping_address.stateCode = selected_state_2.id;
                }

            } catch (Exception e) {
                dummyUser.shipping_address.state = "";
                dummyUser.shipping_address.stateCode = "";
            }
            //dummyUser.shipping_address.state = state_2.getText().toString();
            dummyUser.shipping_address.postcode = postcode_2.getText().toString();

            try {
                dummyUser.shipping_address.country = selected_country_2.title;
                dummyUser.shipping_address.countryCode = selected_country_2.id;
            } catch (Exception e) {
                dummyUser.shipping_address.country = "";
                dummyUser.shipping_address.countryCode = "";
            }
            dummyUser.shipping_address.email = "";//email_2.getText().toString();
            dummyUser.shipping_address.phone = "";//phone_2.getText().toString();
        }

        if (selected_subdistrict_1 != null && AppInfo.SHIPPING_PROVIDER != Constants.Key.SHIPPING_EPEKEN_JNE && AppInfo.SHIPPING_PROVIDER != Constants.Key.SHIPPING_JNE_ALL_COURIER)
            dummyUser.billing_address.region = selected_subdistrict_1.toJson();
        else if (selected_city_1 != null)
            dummyUser.billing_address.region = selected_city_1.toJson();
        else if (selected_state_1 != null)
            dummyUser.billing_address.region = selected_state_1.toJson();
        else if (selected_country_1 != null)
            dummyUser.billing_address.region = selected_country_1.toJson();


        if (selected_subdistrict_2 != null && AppInfo.SHIPPING_PROVIDER != Constants.Key.SHIPPING_EPEKEN_JNE && AppInfo.SHIPPING_PROVIDER != Constants.Key.SHIPPING_JNE_ALL_COURIER)
            dummyUser.shipping_address.region = selected_subdistrict_2.toJson();
        else if (selected_city_2 != null)
            dummyUser.shipping_address.region = selected_city_2.toJson();
        else if (selected_state_2 != null)
            dummyUser.shipping_address.region = selected_state_2.toJson();
        else if (selected_country_2 != null)
            dummyUser.shipping_address.region = selected_country_2.toJson();

        if (address != null) {
            dummyUser.shipping_address.latitude = address.latitude;
            dummyUser.shipping_address.longitude = address.longitude;
        }

        if (AppInfo.USE_LAT_LONG_IN_ORDER) {
            double valueLat, valueLng;
            valueLat = addressLatLng.latitude == 0 ? deviceLatLng.latitude : addressLatLng.latitude;
            dummyUser.billing_address.latitude = String.valueOf(valueLat);
            dummyUser.shipping_address.latitude = String.valueOf(valueLat);

            valueLng = addressLatLng.longitude == 0 ? deviceLatLng.longitude : addressLatLng.longitude;
            dummyUser.billing_address.longitude = String.valueOf(valueLng);
            dummyUser.shipping_address.longitude = String.valueOf(valueLng);
        }

        long currentTime = System.currentTimeMillis();
        dummyUser.shipping_address.lastModifiedTimeStamp = String.valueOf(currentTime);
        return dummyUser;
    }

    private void updateUserInfo(DummyUser dummyUser) {
        AppUser.getInstance().first_name = dummyUser.first_name;
        AppUser.getInstance().last_name = dummyUser.last_name;
        if (AppUser.getInstance().billing_address != null) {
            AppUser.getInstance().billing_address.copyFrom(dummyUser.billing_address);
        } else {
            AppUser.getInstance().billing_address = dummyUser.billing_address;
        }

        if (AppInfo.USE_LAT_LONG_IN_ORDER) {
            double valueLat = (addressLatLng.latitude == 0 && TextUtils.isEmpty(dummyUser.billing_address.latitude)) ? deviceLatLng.latitude : addressLatLng.latitude;
            AppUser.getInstance().billing_address.latitude = dummyUser.billing_address.latitude = AppUser.getInstance().shipping_address.latitude = dummyUser.shipping_address.latitude = String.valueOf(valueLat);
            double valueLng = (addressLatLng.longitude == 0 && TextUtils.isEmpty(dummyUser.billing_address.longitude)) ? deviceLatLng.longitude : addressLatLng.longitude;
            AppUser.getInstance().billing_address.longitude = AppUser.getInstance().shipping_address.longitude = dummyUser.billing_address.longitude = dummyUser.shipping_address.longitude = String.valueOf(valueLng);
        }

        if (selected_subdistrict_1 != null && AppInfo.SHIPPING_PROVIDER != Constants.Key.SHIPPING_EPEKEN_JNE && AppInfo.SHIPPING_PROVIDER != Constants.Key.SHIPPING_JNE_ALL_COURIER)
            AppUser.getInstance().billing_address.region = selected_subdistrict_1.toJson();
        else if (selected_city_1 != null)
            AppUser.getInstance().billing_address.region = selected_city_1.toJson();
        else if (selected_state_1 != null)
            AppUser.getInstance().billing_address.region = selected_state_1.toJson();
        else if (selected_country_1 != null)
            AppUser.getInstance().billing_address.region = selected_country_1.toJson();

        AppUser.getInstance().billing_address.save();

        if (AppUser.getInstance().shipping_address != null) {
            AppUser.getInstance().shipping_address.copyFrom(dummyUser.shipping_address);
        } else {
            AppUser.getInstance().shipping_address = dummyUser.shipping_address;
        }

        if (selected_subdistrict_2 != null && AppInfo.SHIPPING_PROVIDER != Constants.Key.SHIPPING_EPEKEN_JNE && AppInfo.SHIPPING_PROVIDER != Constants.Key.SHIPPING_JNE_ALL_COURIER)
            AppUser.getInstance().shipping_address.region = selected_subdistrict_2.toJson();
        else if (selected_city_2 != null)
            AppUser.getInstance().shipping_address.region = selected_city_2.toJson();
        else if (selected_state_2 != null)
            AppUser.getInstance().shipping_address.region = selected_state_2.toJson();
        else if (selected_country_2 != null)
            AppUser.getInstance().shipping_address.region = selected_country_2.toJson();

        AppUser.getInstance().shipping_address.save();
        AppUser.getInstance().sync();
        AppUser.getInstance().saveAll();
    }

    private boolean compulsoryFieldsShown = false;

    // Map keeps EditText and their default error messages
    private HashMap<EditText, String> compulsoryFields = new HashMap<>();

    private void initCompulsoryFields() {
        if (!compulsoryFields.isEmpty()) {
            compulsoryFields.clear();
        }

        //compulsoryFields.put(txt_mobile, L.string.invalid_contact_number);
        //compulsoryFields.put(txt_email, L.string.invalid_email);

        if (showFullProfileSection) {
            compulsoryFields.put(txt_name_first, L.string.invalid_first_name);
            compulsoryFields.put(txt_name_last, L.string.invalid_last_name);
        }

        compulsoryFields.put(firstname_1, L.string.invalid_first_name);
        compulsoryFields.put(lastname_1, L.string.invalid_last_name);
        compulsoryFields.put(address_1_1, L.string.invalid_address);
        compulsoryFields.put(address_2_1, L.string.invalid_address);
        compulsoryFields.put(city_1, L.string.invalid_city);
        compulsoryFields.put(postcode_1, L.string.invalid_postal_code);
        compulsoryFields.put(email_1, L.string.invalid_email);
        compulsoryFields.put(phone_1, L.string.invalid_contact_number);
    }

    private void showCompulsoryFields() {
        if (compulsoryFieldsShown)
            return;

        Drawable x = ContextCompat.getDrawable(this, R.drawable.img_star);
        x.setBounds(0, 0, x.getIntrinsicWidth(), x.getIntrinsicHeight());
        x.setAlpha(100);

        for (EditText text : compulsoryFields.keySet()) {
            text.setCompoundDrawables(null, null, x, null);
        }
        compulsoryFieldsShown = true;
    }

    private boolean isValid() {
        for (HashMap.Entry<EditText, String> entry : compulsoryFields.entrySet()) {
            EditText editText = entry.getKey();
            Log.d(" - tag: [" + editText.getTag() + "] -");
            if (editText.getVisibility() != View.VISIBLE)
                continue;
            if (editText.getTag() != null && editText.getTag().toString().equals("ignored"))
                continue;
            if (TextUtils.isEmpty(editText.getText().toString())) {
                editText.setError(getString(entry.getValue()));
                editText.requestFocus();
                return false;
            }
        }

        if (email_1.getVisibility() == View.VISIBLE && !Helper.isValidEmail(email_1.getText().toString())) {
            email_1.setError(getString(L.string.invalid_email));
            email_1.requestFocus();
            return false;
        }
        if (phone_1.getVisibility() == View.VISIBLE && !Helper.isValidPhoneNumber(phone_1.getText().toString())) {
            phone_1.setError(getString(L.string.invalid_contact_number));
            phone_1.requestFocus();
            return false;
        }

        return true;
    }


    private boolean validateView(List<View> views) {
        for (View view : views) {
            if (view instanceof EditText) {
                EditText editText = (EditText) view;
                boolean isEditBoxVisible = editText.getVisibility() == View.VISIBLE;
                boolean isEditBoxIgnored = editText.getTag() != null && editText.getTag().toString().equals("ignored");
                if (isEditBoxVisible && !isEditBoxIgnored) {
                    String text = editText.getText().toString().trim();
                    int editBoxInputType = editText.getInputType();
                    switch (editBoxInputType) {
                        case InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS: {
                            if (!Helper.isValidEmail(text)) {
                                editText.setError(getString(L.string.invalid_email));
                                editText.requestFocus();
                                return false;
                            }
                            break;
                        }
                        case InputType.TYPE_CLASS_NUMBER: {
                            if (!Helper.isValidNumber(text)) {
                                editText.setError(getString(L.string.invalid_contact_number));
                                editText.requestFocus();
                                return false;
                            }
                            break;
                        }
                        case InputType.TYPE_CLASS_PHONE: {
                            if (!Helper.isValidPhoneNumber(text)) {
                                editText.setError(getString(L.string.invalid_contact_number));
                                editText.requestFocus();
                                return false;
                            }
                            break;
                        }
                        default: {
                            if (!Helper.isValidString(text)) {
                                editText.setError(editText.getHint());
                                editText.requestFocus();
                                return false;
                            }
                            break;
                        }
                    }
                }
            } else if (view instanceof Spinner) {
                Spinner spinner = (Spinner) view;
                boolean isSpinnerVisible = spinner.getVisibility() == View.VISIBLE;
                boolean isSpinnerIgnored = spinner.getTag() != null && spinner.getTag().toString().equals("ignored");
                if (isSpinnerVisible && isSpinnerIgnored && spinner.getSelectedItemPosition() < 0) {
                    Helper.toast(coordinatorLayout, L.string.select_a_variation_first);
                    return false;
                }
            }
        }
        return true;
    }

    @Override
    public void onBackPressed() {
        setResult(RESULT_CANCELED);
        finish();
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
    protected void onActionBarRestored() {
    }

    private static boolean isValidPostalCodeForCountry(String countryCode, String text) {
        if (hasNumericPostalCode(countryCode)) {
            return Helper.isValidNumber(text);
        } else {
            return Helper.isValidString(text);
        }
    }

    private void adjustPostalCodeEditText(EditText editText, String countryCode) {
        if (hasNumericPostalCode(countryCode)) {
            editText.setInputType(InputType.TYPE_CLASS_NUMBER);
        } else {
            editText.setInputType(InputType.TYPE_TEXT_VARIATION_PERSON_NAME);
        }
    }

    private static boolean hasNumericPostalCode(String countryCode) {
        for (String code : countriesForNumericPinCodes) {
            if (code.equalsIgnoreCase(countryCode))
                return true;
        }
        return false;
    }

    public Spinner addRegionSpinner(LinearLayout parentView, String titleText) {
        TextView title = new TextView(this);
        title.setText(HtmlCompat.fromHtml(titleText));
        title.setPadding(Helper.DP(12), Helper.DP(0), Helper.DP(12), Helper.DP(0));
        parentView.addView(title, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        AwesomeSpinner spinner = new AwesomeSpinner(this);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        //lp.setMargins(Helper.DP(6), Helper.DP(6), Helper.DP(6), Helper.DP(6));
        parentView.addView(spinner, lp);
        spinner.setAdapter(new Adapter_HtmlString(this, new ArrayList<TM_Region>()));
        spinner.attachView(title);
        spinner.setTitle(HtmlCompat.fromHtml(titleText).toString());
        return spinner;
    }


    public void openAutocompleteActivity() {
        if (deviceLatLng.latitude == 0.0f && deviceLatLng.longitude == 0.0f) {
            getCurrentLocation();
        }

        try {
            Intent intent = new PlaceAutocomplete.IntentBuilder(PlaceAutocomplete.MODE_OVERLAY)
                    .setBoundsBias(new LatLngBounds(deviceLatLng, deviceLatLng))
                    .build(this);
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
        if (requestCode == 1) {
            if (resultCode == RESULT_OK) {
                Place place = PlaceAutocomplete.getPlace(this, data);
                //Log.d("Tag", "Place: " + place.getAddress() + ", " + place.getPhoneNumber() + ", " + place.getLatLng());
                address_2_1.setText(place.getName() + ", " + place.getAddress() /*+ ", " + place.getPhoneNumber()*/);
                addressLatLng = place.getLatLng();
            } else if (resultCode == PlaceAutocomplete.RESULT_ERROR) {
                Status status = PlaceAutocomplete.getStatus(this, data);
                // TODO: Handle the error.
                //Log.e("Tag", status.getStatusMessage());
            } else if (resultCode == RESULT_CANCELED) {
                // The user canceled the operation.
            }
        }
    }

    public void getCurrentLocation() {
        if (!AppInfo.USE_LAT_LONG_IN_ORDER) {
            return;
        }
        if (Nammu.checkPermission(android.Manifest.permission.ACCESS_FINE_LOCATION)) {
            setSearchLocation();
        } else {
            final PermissionCallback permissionSearchLocationCallback = new PermissionCallback() {
                @Override
                public void permissionGranted() {
                    setSearchLocation();
                }

                @Override
                public void permissionRefused() {
                    Helper.toast(getString(L.string.permission_denied));
                }
            };

            if (Nammu.shouldShowRequestPermissionRationale(this, android.Manifest.permission.ACCESS_FINE_LOCATION)) {
                Snackbar.make(coordinatorLayout, getString(L.string.allow_location_access), Snackbar.LENGTH_INDEFINITE)
                        .setAction(getString(L.string.ok), new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                Nammu.askForPermission(ProfileActivity.this, android.Manifest.permission.ACCESS_FINE_LOCATION, permissionSearchLocationCallback);
                            }
                        }).show();
            } else {
                Nammu.askForPermission(ProfileActivity.this, android.Manifest.permission.ACCESS_FINE_LOCATION, permissionSearchLocationCallback);
            }
        }
    }

    private void setSearchLocation() {
        gps = new LocationTracker(this);
        if (gps.canGetLocation()) {
            deviceLatLng = new LatLng(gps.getLatitude(), gps.getLongitude());
            if (deviceLatLng.latitude != 0.0f && deviceLatLng.longitude != 0.0f) {
                openAutocompleteActivity();
            } else {
                Helper.toast(getString(L.string.turn_on_high_accuracy_location));
            }
        } else {
            gps.showSettingsAlert();
        }
    }
}