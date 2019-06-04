package com.twist.tmstore.fragments;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.annotation.Nullable;
import android.support.design.widget.TextInputLayout;
import android.support.v4.widget.NestedScrollView;
import android.support.v7.widget.CardView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.animation.GlideAnimation;
import com.bumptech.glide.request.target.SimpleTarget;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.common.GooglePlayServicesRepairableException;
import com.google.android.gms.location.places.Place;
import com.google.android.gms.location.places.ui.PlaceAutocomplete;
import com.twist.dataengine.DataEngine;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.entities.SellerInfo;
import com.twist.tmstore.BaseActivity;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.config.MultiVendorConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.utils.Helper;
import com.utils.ImageUpload;
import com.utils.Log;
import com.utils.customviews.RoundedImageView;

import java.io.IOException;
import java.util.HashMap;

import static android.app.Activity.RESULT_OK;
import static com.utils.ImageUpload.PICK_PHOTO_CODE;
import static com.utils.ImageUpload.REQUEST_IMAGE_CAPTURE;

/**
 * Created by Twist Mobile on 20-01-2017.
 */
public class Fragment_SellerStoreSettings extends BaseFragment {
    private SellerInfo currentSeller;
    private TextView label_first_name;
    private TextView label_last_name;
    private TextView label_shop_name;
    private TextView label_contact_number;
    private EditText last_name;
    private EditText first_name;
    private EditText shop_name;
    private EditText shop_address;
    private EditText contact;
    private int sellerId;

    ProgressDialog loading;
    private LinearLayout section_shop_icon;
    private ImageView shop_icon;
    private CardView section_avatar;
    private RoundedImageView img_avatar;
    RelativeLayout map_section;

    private ImageButton btn_delete_avatar;
    private ImageButton btn_delete_icon;
    View rootView;
    int img_upload_id;
    ImageUpload imageUpload;
    Fragment_Seller_MapInfo fragment_seller_mapInfo;

    TextInputLayout floating_label_first_name;
    TextInputLayout floating_label_last_name;
    TextInputLayout floating_label_shop_name;
    TextInputLayout floating_label_shop_address;
    TextInputLayout floating_label_contact;

    boolean isEdit;
    private HashMap<EditText, String> compulsoryFields = new HashMap<>();

    public static Fragment_SellerStoreSettings newInstance(SellerInfo currentSeller, boolean isEdit) {
        Fragment_SellerStoreSettings fragment_store_settings = new Fragment_SellerStoreSettings();
        fragment_store_settings.currentSeller = currentSeller;
        fragment_store_settings.isEdit = isEdit;
        fragment_store_settings.sellerId = Integer.parseInt(currentSeller.getId());
        return fragment_store_settings;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setActionBarHomeAsUpIndicator();
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
        if (MultiVendorConfig.isSellerApp()) {
            menu.clear();
        }
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        rootView = inflater.inflate(R.layout.fragment_store_settings, container, false);
        ScrollView storeSettingLayout = (ScrollView) rootView.findViewById(R.id.storeSettingLayout);
        map_section = (RelativeLayout) rootView.findViewById(R.id.map_section);
        map_section.setVisibility(View.GONE);
        label_first_name = (TextView) rootView.findViewById(R.id.label_first_name);
        label_last_name = (TextView) rootView.findViewById(R.id.label_last_name);
        label_shop_name = (TextView) rootView.findViewById(R.id.label_shop_name);
        label_contact_number = (TextView) rootView.findViewById(R.id.label_contact_number);
        TextView txt_first_name = (TextView) rootView.findViewById(R.id.txt_first_name);
        TextView txt_last_name = (TextView) rootView.findViewById(R.id.txt_last_name);
        TextView txt_shop_name = (TextView) rootView.findViewById(R.id.txt_shop_name);
        TextView txt_contact_number = (TextView) rootView.findViewById(R.id.txt_contact_number);
        View shop_settings_layout = rootView.findViewById(R.id.shop_settings_layout);
        localizeText();
        imageUpload = new ImageUpload(rootView, getActivity());
        if (currentSeller != null) {
            shop_settings_layout.setVisibility(View.VISIBLE);
            String _txt_phone_number = currentSeller.getPhoneNumber();
            if (!TextUtils.isEmpty(_txt_phone_number)) {
                label_contact_number.setVisibility(View.VISIBLE);
                txt_contact_number.setVisibility(View.VISIBLE);
                txt_contact_number.setText(_txt_phone_number);
            } else {
                label_contact_number.setVisibility(View.GONE);
                txt_contact_number.setVisibility(View.GONE);
            }

            String _txt_first_name = currentSeller.getTitle();
            if (!TextUtils.isEmpty(_txt_first_name)) {
                label_first_name.setVisibility(View.VISIBLE);
                txt_first_name.setVisibility(View.VISIBLE);
                txt_first_name.setText(_txt_first_name);
            } else {
                label_first_name.setVisibility(View.GONE);
                txt_first_name.setVisibility(View.GONE);
            }

            String _txt_last_name = currentSeller.getVendorLastName();
            if (!TextUtils.isEmpty(_txt_last_name)) {
                txt_last_name.setVisibility(View.VISIBLE);
                label_last_name.setVisibility(View.VISIBLE);
                txt_last_name.setText(_txt_last_name);
            } else {
                label_last_name.setVisibility(View.GONE);
                txt_last_name.setVisibility(View.GONE);
            }

            String _txt_shop_name = currentSeller.getShopName();
            if (!TextUtils.isEmpty(_txt_shop_name)) {
                label_shop_name.setVisibility(View.VISIBLE);
                txt_shop_name.setVisibility(View.VISIBLE);
                txt_shop_name.setText(_txt_shop_name);
            } else {
                label_shop_name.setVisibility(View.GONE);
                txt_shop_name.setVisibility(View.GONE);
            }
        } else {
            shop_settings_layout.setVisibility(View.GONE);
        }

        if (!isEdit) {
            shop_settings_layout.setVisibility(View.VISIBLE);
            storeSettingLayout.setVisibility(View.GONE);
        } else {
            shop_settings_layout.setVisibility(View.GONE);
            storeSettingLayout.setVisibility(View.VISIBLE);
        }

        Button button_submit = (Button) rootView.findViewById(R.id.button_submit);
        Helper.stylize(button_submit);
        button_submit.setText(L.getString(L.string.submit));
        floating_label_shop_name = ((TextInputLayout) rootView.findViewById(R.id.floating_label_shop_name));
        floating_label_shop_name.setHint(L.getString(L.string.label_shop_name));
        floating_label_first_name = ((TextInputLayout) rootView.findViewById(R.id.floating_label_first_name));
        floating_label_first_name.setHint(L.getString(L.string.first_name));
        floating_label_shop_address = ((TextInputLayout) rootView.findViewById(R.id.floating_label_shop_address));
        floating_label_shop_address.setHint(L.getString(L.string.label_shop_address));
        floating_label_last_name = ((TextInputLayout) rootView.findViewById(R.id.floating_label_last_name));
        floating_label_last_name.setHint(L.getString(L.string.last_name));
        floating_label_contact = ((TextInputLayout) rootView.findViewById(R.id.floating_label_contact));
        floating_label_contact.setHint(L.getString(L.string.contact_number));

        first_name = (EditText) rootView.findViewById(R.id.first_name);
        last_name = (EditText) rootView.findViewById(R.id.last_name);
        shop_name = (EditText) rootView.findViewById(R.id.shop_name);
        shop_address = (EditText) rootView.findViewById(R.id.shop_address);
        contact = (EditText) rootView.findViewById(R.id.contact);

        if (currentSeller != null) {
            if (!TextUtils.isEmpty(currentSeller.getTitle())) {
                first_name.setText(currentSeller.getTitle());
            }
            if (!TextUtils.isEmpty(currentSeller.getVendorLastName())) {
                last_name.setText(currentSeller.getVendorLastName());
            }
            if (!TextUtils.isEmpty(currentSeller.getPhoneNumber())) {
                contact.setText(currentSeller.getPhoneNumber());
            }
            if (!TextUtils.isEmpty(currentSeller.getShopName())) {
                shop_name.setText(currentSeller.getShopName());
            }
            if (!TextUtils.isEmpty(currentSeller.getShopAddress())) {
                shop_address.setText(currentSeller.getShopAddress());
            }

        }
        button_submit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                updateSellerInfo(view);
            }
        });

        TextView title_seller_icon = (TextView) rootView.findViewById(R.id.label_seller_icon);
        title_seller_icon.setText(getString(L.string.title_seller_icon));

        section_shop_icon = (LinearLayout) rootView.findViewById(R.id.section_shop_icon);
        shop_icon = (ImageView) rootView.findViewById(R.id.shop_icon);
        btn_delete_icon = (ImageButton) rootView.findViewById(R.id.btn_delete_icon);
        btn_delete_icon.setVisibility(View.GONE);
        if (!TextUtils.isEmpty(currentSeller.getIconUrl())) {
            btn_delete_icon.setVisibility(View.VISIBLE);
            updateImage(shop_icon, currentSeller.getIconUrl(), false);
        }
        shop_icon.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                img_upload_id = R.id.shop_icon;
                imageUpload.selectImage();
            }
        });

        btn_delete_icon.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                btn_delete_icon.setVisibility(View.GONE);
                isIconUpdate = true;
                updateImage(shop_icon, "", false);

            }
        });

        section_avatar = (CardView) rootView.findViewById(R.id.section_avatar);
        img_avatar = (RoundedImageView) rootView.findViewById(R.id.img_avatar);
        btn_delete_avatar = (ImageButton) rootView.findViewById(R.id.btn_delete_avatar);
        btn_delete_avatar.setVisibility(View.GONE);
        if (!TextUtils.isEmpty(currentSeller.getAvatarUrl())) {
            btn_delete_avatar.setVisibility(View.VISIBLE);
            updateImage(img_avatar, currentSeller.getAvatarUrl(), true);
        }
        img_avatar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                img_upload_id = R.id.img_avatar;
                imageUpload.selectImage();
            }
        });
        btn_delete_avatar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                img_avatar.setImageResource(AppInfo.ID_PLACEHOLDER_PRODUCT);
                btn_delete_avatar.setVisibility(View.GONE);
                isAvatarUpdate = true;
                avatarUrl = "";
            }
        });
        setTitle(getString(L.string.title_store_settings));

        final ImageView transparent_image = (ImageView) rootView.findViewById(R.id.transparent_image);

        transparent_image.setOnTouchListener(new View.OnTouchListener() {
            public boolean onTouch(View p_v, MotionEvent p_event) {
                // this will disallow the touch request for parent scroll on touch of child view
                p_v.getParent().requestDisallowInterceptTouchEvent(true);
                return false;
            }
        });

        final NestedScrollView nested_scroll_view = (NestedScrollView) rootView.findViewById(R.id.nested_scroll_view);
        nested_scroll_view.setOnTouchListener(new View.OnTouchListener() {
            public boolean onTouch(View p_v, MotionEvent p_event) {
                // this will disallow the touch request for parent scroll on touch of child view
                p_v.getParent().requestDisallowInterceptTouchEvent(true);
                return false;
            }
        });

        setupUIConfig();
        shop_address.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String google_android_geo_api_key = getString(R.string.google_android_geo_api_key);
                if (!google_android_geo_api_key.isEmpty()) {
                    openSearchLocation();
                }
            }
        });
        shop_address.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                String google_android_geo_api_key = getString(R.string.google_android_geo_api_key);
                if (!google_android_geo_api_key.isEmpty()) {
                    if (hasFocus) {
                        openSearchLocation();
                    }
                }
            }
        });
        return rootView;
    }

    public void setupUIConfig() {
        floating_label_first_name.setVisibility(View.GONE);
        floating_label_last_name.setVisibility(View.GONE);
        floating_label_shop_name.setVisibility(View.GONE);
        floating_label_shop_address.setVisibility(View.GONE);
        floating_label_contact.setVisibility(View.GONE);
        section_avatar.setVisibility(View.GONE);
        section_shop_icon.setVisibility(View.GONE);
        for (String str : MultiVendorConfig.getShopSettings()) {
            switch (str) {
                case MultiVendorConfig.SHOP_SETTING_FIRST_NAME:
                    floating_label_first_name.setVisibility(View.VISIBLE);
                    break;
                case MultiVendorConfig.SHOP_SETTING_LAST_NAME:
                    floating_label_last_name.setVisibility(View.VISIBLE);
                    break;
                case MultiVendorConfig.SHOP_SETTING_SHOP_NAME:
                    floating_label_shop_name.setVisibility(View.VISIBLE);
                    break;
                case MultiVendorConfig.SHOP_SETTING_SHOP_ADDRESS:
                    floating_label_shop_address.setVisibility(View.VISIBLE);
                    break;
                case MultiVendorConfig.SHOP_SETTING_SHOP_CONTACT:
                    floating_label_contact.setVisibility(View.VISIBLE);
                    break;
                case MultiVendorConfig.SHOP_SETTING_AVATAR_ICON:
                    section_avatar.setVisibility(View.VISIBLE);
                    break;
                case MultiVendorConfig.SHOP_SETTING_SHOP_ICON:
                    section_shop_icon.setVisibility(View.VISIBLE);
                    break;
            }
        }
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        if (MultiVendorConfig.shouldShowLocation()) {
            map_section.setVisibility(View.VISIBLE);
            fragment_seller_mapInfo = new Fragment_Seller_MapInfo();
            fragment_seller_mapInfo.setOnAddressChangeListener(new Fragment_Seller_MapInfo.OnAddressChangeListener() {
                @Override
                public void onChange(Double latitude, Double longitude, String country, String state, String postcode, String code, String city, String address1, String address2) {
                    currentSeller.setLatitude(latitude);
                    currentSeller.setLongitude(longitude);
                    shop_address.setText(address1);
                }
            });
            fragment_seller_mapInfo.setCurrentSeller(currentSeller);
            ((BaseActivity) getActivity()).getFM().beginTransaction()
                    .add(R.id.section_map_seller, fragment_seller_mapInfo)
                    .commit();
        } else {
            map_section.setVisibility(View.GONE);
        }
    }

    public void updateImage(final ImageView img, String url, boolean isBitmap) {
        if (!TextUtils.isEmpty(url))
            btn_delete_icon.setVisibility(View.VISIBLE);
        else
            btn_delete_icon.setVisibility(View.GONE);

        if (isBitmap) {
            avatarUrl = url;
            Glide.with(getActivity())
                    .load(url)
                    .asBitmap()
                    .placeholder(Helper.getPlaceholderColor())
                    .into(new SimpleTarget<Bitmap>() {
                        @Override
                        public void onResourceReady(Bitmap resource, GlideAnimation<? super Bitmap> glideAnimation) {
                            img.setImageBitmap(resource);
                        }
                    });
        } else {
            iconUrl = url;
            Glide.with(getActivity())
                    .load(url)
                    .placeholder(Helper.getPlaceholderColor())
                    .into(img);
        }
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
        return true;
    }

    private void localizeText() {
        label_first_name.setText(L.getString(L.string.first_name));
        label_last_name.setText(L.getString(L.string.last_name));
        label_shop_name.setText(L.getString(L.string.label_shop_name));
        label_contact_number.setText(L.getString(L.string.contact_number));
    }

    private void updateSellerInfo(View view) {
        final String _first_name = first_name.getText().toString();
        final String _last_name = last_name.getText().toString();
        final String _shop_name = shop_name.getText().toString();
        final String _shop_address = shop_address.getText().toString();
        final String _phone = contact.getText().toString();
        if (checkSellerCredentials(_first_name, _last_name, _shop_name, _shop_address, _phone)) {
            submitEditSellerInfo(view, _first_name, _last_name, _shop_name, _shop_address, _phone);
        }
    }

    private void submitEditSellerInfo(final View view, String _first_name, String _last_name, String _shop_name, String _shop_address, String _phone) {
        HashMap<String, String> params = new HashMap<>();
        params.put("type", "view");
        params.put("seller_id", String.valueOf(sellerId));
        params.put("seller_first_name", _first_name);
        params.put("seller_last_name", _last_name);
        params.put("seller_phone", _phone);
        params.put("shop_name", _shop_name);
        params.put("shop_address", _shop_address);
        params.put("seller_info", "");
        params.put("store_description", "");
        params.put("type", "update");
        params.put("banner_url", "");
        params.put("latitude", String.valueOf(currentSeller.getLatitude()));
        params.put("longitude", String.valueOf(currentSeller.getLongitude()));
        params.put("icon_url", iconUrl);
        params.put("avatar_url", avatarUrl);
        Helper.hideKeyboard(view);
        MainActivity.mActivity.showProgress(getString(L.string.please_wait));
        DataEngine.getDataEngine().updateSellerInBackground(new DataQueryHandler<String>() {
            @Override
            public void onSuccess(String data) {
                MainActivity.mActivity.hideProgress();
                Helper.toast(getString(L.string.seller_zone_shop_settings_updated));
                AppUser.getInstance().avatar_url = avatarUrl;
                MainActivity.mActivity.resetDrawer();
                MainActivity.mActivity.updateUserInfoInBackground();
                getActivity().getSupportFragmentManager().beginTransaction().remove(Fragment_SellerStoreSettings.this).commit();
                getActivity().getSupportFragmentManager().popBackStack();
            }

            @Override
            public void onFailure(Exception exception) {
                MainActivity.mActivity.hideProgress();
                Log.d(exception.toString());

            }
        }, params);
    }

    private boolean checkSellerCredentials(String first_name_text, String last_name_text, String shop_name_text, String shop_address_text, String phone_text) {
        if (floating_label_first_name.getVisibility() == View.VISIBLE && !Helper.isValidString(first_name_text)) {
            first_name.setError(getString(L.string.invalid_first_name));
            first_name.requestFocus();
            return false;
        }
        if (floating_label_last_name.getVisibility() == View.VISIBLE && !Helper.isValidString(last_name_text)) {
            last_name.setError(getString(L.string.invalid_last_name));
            last_name.requestFocus();
            return false;
        }
        if (floating_label_shop_name.getVisibility() == View.VISIBLE && !Helper.isValidString(shop_name_text)) {
            shop_name.setError(getString(L.string.invalid_shop_name));
            shop_name.requestFocus();
            return false;
        }
        if (floating_label_shop_address.getVisibility() == View.VISIBLE && !Helper.isValidString(shop_address_text)) {
            shop_address.setError(getString(L.string.invalid_shop_address));
            shop_address.requestFocus();
            return false;
        }
        if (floating_label_contact.getVisibility() == View.VISIBLE && !Helper.isValidPhoneNumber(phone_text)) {
            contact.setError(getString(L.string.invalid_contact_number));
            contact.requestFocus();
            return false;
        }
        return true;
    }

    boolean isIconUpdate = false;
    boolean isAvatarUpdate = false;
    String iconUrl = "";
    String avatarUrl = "";

    public void refreshImage(String url) {
        switch (img_upload_id) {
            case R.id.shop_icon:
                currentSeller.setIconUrl(url);
                isIconUpdate = true;
                updateImage(shop_icon, url, false);
                break;

            case R.id.img_avatar:
                currentSeller.setAvatarUrl(url);
                isAvatarUpdate = true;
                updateImage(img_avatar, url, true);
                break;
        }
    }

    public void handleActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_IMAGE_CAPTURE && resultCode == RESULT_OK) {
            loading = ProgressDialog.show(getActivity(), getString(L.string.uploading_image), getString(L.string.please_wait), false, false);
            Bitmap fixedBitmap = Helper.fixImageOrientation(imageUpload.mCurrentPhotoPath);
            imageUpload.uploadImage(fixedBitmap, new ImageUpload.ImageUploadListner() {
                @Override
                public void UploadSuccess(String url) {
                    loading.dismiss();
                    refreshImage(url);
                }
            });
        }
        if (data != null && requestCode == PICK_PHOTO_CODE) {
            Uri photoUri = data.getData();
            try {
                Bitmap originalBitmap = MediaStore.Images.Media.getBitmap(getActivity().getContentResolver(), photoUri);
                loading = ProgressDialog.show(getActivity(), getString(L.string.uploading_image), getString(L.string.please_wait), false, false);
                imageUpload.uploadImage(originalBitmap, new ImageUpload.ImageUploadListner() {
                    @Override
                    public void UploadSuccess(String url) {
                        loading.dismiss();
                        refreshImage(url);
                    }
                });
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    private static final int REQUEST_CODE_AUTOCOMPLETE = 1001;

    public void openSearchLocation() {
        try {
            Intent intent = new PlaceAutocomplete.IntentBuilder(PlaceAutocomplete.MODE_OVERLAY)
                    //.setBoundsBias(new LatLngBounds(deviceLatLng, deviceLatLng))
                    .build(getActivity());
            startActivityForResult(intent, REQUEST_CODE_AUTOCOMPLETE);
        } catch (GooglePlayServicesRepairableException e) {
            GoogleApiAvailability.getInstance().getErrorDialog(getActivity(), e.getConnectionStatusCode(), 0).show();
        } catch (GooglePlayServicesNotAvailableException e) {
            String message = "Google Play Services is not available: " + GoogleApiAvailability.getInstance().getErrorString(e.errorCode);
            Toast.makeText(getActivity(), message, Toast.LENGTH_SHORT).show();
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE_AUTOCOMPLETE && resultCode == Activity.RESULT_OK) {
            Place place = PlaceAutocomplete.getPlace(getActivity(), data);
            if (place != null) {
                currentSeller.setLatitude(place.getLatLng().latitude);
                currentSeller.setLongitude(place.getLatLng().longitude);
                shop_address.setText(place.getName().toString() + ", " + place.getAddress().toString());
                if (fragment_seller_mapInfo != null) {
                    fragment_seller_mapInfo.moveMap(place.getLatLng(), true);
                }
            }
        } else if (resultCode == PlaceAutocomplete.RESULT_ERROR) {
            //Status status = PlaceAutocomplete.getStatus(this, data);
        }
    }
}

