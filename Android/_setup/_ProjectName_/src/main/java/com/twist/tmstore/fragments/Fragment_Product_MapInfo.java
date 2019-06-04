package com.twist.tmstore.fragments;

import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.util.Linkify;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.animation.GlideAnimation;
import com.bumptech.glide.request.target.SimpleTarget;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.ProductDetailActivity;
import com.twist.tmstore.R;
import com.utils.GoogleApiHelper;
import com.utils.HtmlCompat;

/**
 * Created by Twist Mobile on 10/28/2017.
 */

public class Fragment_Product_MapInfo extends BaseFragment {

    private static final int DEFAULT_ZOOM = 15;

    public static final String ARGS_LATITUDE = "latitude";
    public static final String ARGS_LONGITUDE = "longitude";
    public static final String ARGS_SHOW_TITLE = "show_title";
    public static final String ARGS_LOCATION_DETAILS = "location_details";

    private double mLatitude = 0;
    private double mLongitude = 0;
    private boolean mShowTitle = true;

    public OnMapClickListener onMapClickListener;
    private GoogleMap googleMap;
    private Marker mMarker;

    private OnMapReadyCallback onMapReadyCallback = new OnMapReadyCallback() {
        @Override
        public void onMapReady(GoogleMap map) {
            googleMap = map;
            googleMap.getUiSettings().setScrollGesturesEnabled(false);
            googleMap.setOnMarkerClickListener(new GoogleMap.OnMarkerClickListener() {
                @Override
                public boolean onMarkerClick(Marker marker) {
                    return true;
                }
            });
            googleMap.setOnMapClickListener(new GoogleMap.OnMapClickListener() {
                @Override
                public void onMapClick(LatLng latLng) {
                    if (mMarker != null) {
                        Intent intent = new Intent(android.content.Intent.ACTION_VIEW, Uri.parse("http://maps.google.com/maps?f=d&daddr=" + mMarker.getPosition().latitude + "," + mMarker.getPosition().longitude));
                        getActivity().startActivity(intent);
                    }
                }
            });
            plotMarker();
        }
    };

    public Fragment_Product_MapInfo() {
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_product_map_info, container, false);

        String locationDetails = "";

        if (getArguments() != null) {
            mLatitude = getArguments().getDouble(ARGS_LATITUDE);
            mLongitude = getArguments().getDouble(ARGS_LONGITUDE);
            mShowTitle = getArguments().getBoolean(ARGS_SHOW_TITLE);
            locationDetails = getArguments().getString(ARGS_LOCATION_DETAILS);
        }

        ImageView transparentImageView = (ImageView) rootView.findViewById(R.id.transparent_image);
        transparentImageView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                int action = event.getAction();
                switch (action) {
                    case MotionEvent.ACTION_DOWN:
                        if (onMapClickListener != null)
                            onMapClickListener.onMapClick(true);
                        return false;

                    case MotionEvent.ACTION_UP:
                        if (onMapClickListener != null)
                            onMapClickListener.onMapClick(false);
                        return true;

                    case MotionEvent.ACTION_MOVE:
                        if (onMapClickListener != null)
                            onMapClickListener.onMapClick(false);
                        return false;
                }
                return true;
            }
        });

        TextView text_title = (TextView) rootView.findViewById(R.id.text_title);
        text_title.setText(getString(L.string.title_location));
        text_title.setVisibility(mShowTitle ? View.VISIBLE : View.GONE);

        TextView text_details = (TextView) rootView.findViewById(R.id.text_details);
        if (!TextUtils.isEmpty(locationDetails)) {
            text_details.setText(HtmlCompat.fromHtml(locationDetails));
            text_details.setVisibility(View.VISIBLE);
        } else {
            text_details.setVisibility(View.GONE);
        }
        Linkify.addLinks(text_details, Linkify.ALL);
        text_details.setMovementMethod(LinkMovementMethod.getInstance());
        return rootView;
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        if (ProductDetailActivity.getGoogleApiHelperInstance() != null) {
            ProductDetailActivity.getGoogleApiHelperInstance().setConnectionListener(new GoogleApiHelper.ConnectionListener() {
                @Override
                public void onConnectionFailed(@NonNull ConnectionResult connectionResult) {
                }

                @Override
                public void onConnectionSuspended(int i) {
                }

                @Override
                public void onConnected(Bundle bundle) {
                    SupportMapFragment mapFragment = (SupportMapFragment) getChildFragmentManager().findFragmentById(R.id.map);
                    mapFragment.getMapAsync(onMapReadyCallback);
                }
            });
            ProductDetailActivity.getGoogleApiHelperInstance().connect();
        }
    }

    private void plotMarker() {
        if (mLatitude > 0 && mLongitude > 0) {
            LatLng latLng = new LatLng(mLatitude, mLongitude);
            mMarker = googleMap.addMarker(new MarkerOptions()
                    .title("")
                    .position(latLng)
                    .snippet(""));
            Glide.with(this)
                    .load(R.drawable.ic_vc_location)
                    .asBitmap()
                    .into(new SimpleTarget<Bitmap>() {
                        @Override
                        public void onResourceReady(Bitmap resource, GlideAnimation<? super Bitmap> glideAnimation) {
                            mMarker.setIcon(BitmapDescriptorFactory.fromBitmap(resource));
                        }
                    });
            googleMap.moveCamera(CameraUpdateFactory.newLatLngZoom(latLng, DEFAULT_ZOOM));
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        if (ProductDetailActivity.getGoogleApiHelperInstance() != null) {
            ProductDetailActivity.getGoogleApiHelperInstance().disconnect();
        }
    }

    interface OnMapClickListener {
        void onMapClick(boolean flag);
    }
}








