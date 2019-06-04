package com.twist.dataengine.shippings;

import com.twist.dataengine.DataEngine;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.NoConnectionError;
import com.twist.dataengine.ShippingEngine;
import com.twist.dataengine.WooCommerceJSONHelper;
import com.twist.dataengine.entities.TM_Region;
import com.twist.dataengine.entities.TM_StoreInfo;
import com.twist.oauth.NetworkRequest;
import com.twist.oauth.NetworkResponse;
import com.utils.DataHelper;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class DefaultWooComShipping extends ShippingEngine {

    private static boolean countriesLoaded = false;

    public DefaultWooComShipping(String baseUrl) {
        request_url_countries = DataEngine.getDataEngine().url_countries_list;
    }

    @Override
    public void getCountries(final TM_Region parent, final DataQueryHandler dataQueryHandler) {
        if (countriesLoaded) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onSuccess(TM_Region.getRegions(null));
            }
            return;
        }

        if (!DataEngine.getDataEngine().isNetworkAvailable()) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onFailure(new NoConnectionError(""));
            }
            return;
        }

        NetworkResponse.ResponseListener postResponseListener = new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse postResponse) {
                DataHelper.log("-- getCountries::onResponseReceived:[" + postResponse.msg + "] --");
                if (postResponse.succeed) {
                    String response = postResponse.msg;
                    if (WooCommerceJSONHelper.hasResponseError(response, dataQueryHandler)) {
                        return;
                    }
                    if (dataQueryHandler != null) {
                        dataQueryHandler.onSuccess(parseJsonAndCreateCountries(response));
                        countriesLoaded = true;
                    }
                } else if (dataQueryHandler != null) {
                    dataQueryHandler.onFailure(postResponse.error);
                }
            }
        };
        NetworkRequest.makeCommonGetRequest(request_url_countries, null, postResponseListener);
    }

    @Override
    public void getStates(TM_Region regionCode, final DataQueryHandler dataQueryHandler) {
        if (dataQueryHandler != null)
            dataQueryHandler.onSuccess(TM_Region.getRegions(regionCode));
    }

    @Override
    public void getDistricts(TM_Region parent, DataQueryHandler dataQueryHandler) {
        if (dataQueryHandler != null)
            dataQueryHandler.onFailure(new NoSuchMethodException());
    }

    @Override
    public void getSubDistricts(TM_Region parent, DataQueryHandler dataQueryHandler) {
        if (dataQueryHandler != null)
            dataQueryHandler.onFailure(new NoSuchMethodException());
    }

    @Override
    public void getSubDistricts(TM_Region parent, String state, DataQueryHandler dataQueryHandler) {
        if (dataQueryHandler != null)
            dataQueryHandler.onFailure(new NoSuchMethodException());
    }

    @Override
    public void getCities(TM_Region parent, DataQueryHandler dataQueryHandler) {
        if (dataQueryHandler != null)
            dataQueryHandler.onFailure(new NoSuchMethodException());
    }

    @Override
    public void calculateShipping(TM_Region origin, TM_Region destination, DataQueryHandler dataQueryHandler) {
        if (dataQueryHandler != null)
            dataQueryHandler.onFailure(new NoSuchMethodException());
    }

    @Override
    public void getAvailableShipping(TM_StoreInfo origin, TM_Region destination, float weight, DataQueryHandler dataQueryHandler) {
        if (dataQueryHandler != null)
            dataQueryHandler.onFailure(new NoSuchMethodException());
    }

    @Override
    public void getCurrencyRate(final DataQueryHandler dataQueryHandler) {
        if (dataQueryHandler != null)
            dataQueryHandler.onFailure(new NoSuchMethodException());
    }

    @Override
    public void getStoreLocation(DataQueryHandler dataQueryHandler) {
        if (dataQueryHandler != null)
            dataQueryHandler.onFailure(new NoSuchMethodException());
    }

    public List<TM_Region> parseJsonAndCreateCountries(String jsonStringContent) {
        List<TM_Region> countryList = new ArrayList<>();
        DataHelper.log("-- parseJsonAndCreateCountries: [" + jsonStringContent + "] --");
        JSONObject jMainObject;
        try {
            jMainObject = DataHelper.safeJsonObject(jsonStringContent);
            JSONArray countries = jMainObject.getJSONArray("list");
            for (int i = 0; i < countries.length(); i++) {
                try {
                    JSONObject jsonObjectCountry = countries.getJSONObject(i);
                    String countryName = DataHelper.safeString(jsonObjectCountry, "n");
                    String countryId = DataHelper.safeString(jsonObjectCountry, "id");
                    TM_Region countryRegion = TM_Region.getRegion("country", countryId, countryName, null);
                    countryList.add(countryRegion);
                    JSONArray jsonStates = jsonObjectCountry.getJSONArray("s");
                    for (int j = 0; j < jsonStates.length(); j++) {
                        String stateName = DataHelper.safeString(jsonStates.getJSONObject(j), "n");
                        String stateId = DataHelper.safeString(jsonStates.getJSONObject(j), "id");
                        TM_Region.getRegion("state", stateId, stateName, countryRegion);
                    }
                } catch (JSONException je) {
                    je.printStackTrace();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return countryList;
    }
}
