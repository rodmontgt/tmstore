package com.utils;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.support.v7.widget.SearchView;
import android.view.View;
import android.view.inputmethod.InputMethodManager;

import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.common.GooglePlayServicesRepairableException;
import com.google.android.gms.common.api.Status;
import com.google.android.gms.location.places.AutocompleteFilter;
import com.google.android.gms.location.places.Place;
import com.google.android.gms.location.places.ui.PlaceAutocomplete;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.listeners.ActivityResultHandler;

public class SearchHandler {

    private static final int PLACE_AUTOCOMPLETE_REQUEST_CODE = 4589;

    public void handleSearchViewFocus(View view, boolean hasFocus) {
        if (hasFocus) {
            if (AppInfo.GEO_LOC_SEARCH_IN_HOME) {
                view.clearFocus();
                findPlace(view);
            } else {
                showInputMethod(view.findFocus());
            }
        }
    }

    private void showInputMethod(View view) {
        InputMethodManager imm = (InputMethodManager) view.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        if (imm != null) {
            imm.showSoftInput(view, 0);
        }
    }

    public void findPlace(final View view) {
        MainActivity.mActivity.setActivityResultHandler(new ActivityResultHandler() {
            @Override
            public void onActivityResult(int requestCode, int resultCode, Intent data) {
                if (requestCode == PLACE_AUTOCOMPLETE_REQUEST_CODE) {
                    if (resultCode == Activity.RESULT_OK) {
                        Place place = PlaceAutocomplete.getPlace(view.getContext(), data);
                        Log.d("Place: " + place.getName());
                        try {
                            SearchView searchView = (SearchView) view;
                            searchView.setQuery(place.getName(), true);
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    } else if (resultCode == PlaceAutocomplete.RESULT_ERROR) {
                        Status status = PlaceAutocomplete.getStatus(view.getContext(), data);
                        Log.d(status.getStatusMessage());
                        Helper.toast(status.getStatusMessage());
                    } else if (resultCode == Activity.RESULT_CANCELED) {
                        // The user canceled the operation.
                    }
                }
            }
        });
        try {
            AutocompleteFilter typeFilter = new AutocompleteFilter.Builder()
                    .setTypeFilter(AutocompleteFilter.TYPE_FILTER_CITIES | AutocompleteFilter.TYPE_FILTER_REGIONS | AutocompleteFilter.TYPE_FILTER_ADDRESS)
                    .build();
            Intent intent = new PlaceAutocomplete.IntentBuilder(PlaceAutocomplete.MODE_OVERLAY)
                    .setFilter(typeFilter)
                    .build(MainActivity.mActivity);
            MainActivity.mActivity.startActivityForResult(intent, PLACE_AUTOCOMPLETE_REQUEST_CODE);
        } catch (GooglePlayServicesRepairableException e) {
            Helper.showToast(e.getMessage());
        } catch (GooglePlayServicesNotAvailableException e) {
            Helper.showToast(e.getMessage());
        }
    }
}