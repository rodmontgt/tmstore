package com.twist.dataengine.shippings;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import com.twist.dataengine.DataEngine;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.NoConnectionError;
import com.twist.dataengine.ShippingEngine;
import com.twist.dataengine.WooCommerceJSONHelper;
import com.twist.dataengine.entities.TM_Region;
import com.twist.dataengine.entities.TM_Shipping;
import com.twist.dataengine.entities.TM_StoreInfo;
import com.utils.DataHelper;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.twist.oauth.NetworkRequest;
import com.twist.oauth.NetworkResponse;

public class EpekenJneAllCountriesShipping extends ShippingEngine {
    private String key = "";
    private String androidKey = "";
    private String id = "";
    private TM_Region superCountry;

    public EpekenJneAllCountriesShipping(String baseURL, String key) {
        request_url_countries = baseURL + "/wp-tm-ext-store-notify/api/epeken_allcurir_list_of_province/";
        request_url_states = baseURL + "/wp-tm-ext-store-notify/api/epeken_allcurir_list_of_kecamatan/";
        request_url_sub_discricts = baseURL + "/wp-tm-ext-store-notify/api/epeken_allcurir_list_of_province/";
        request_url_cities = baseURL + "/wp-tm-ext-store-notify/api/epeken_allcurir_list_of_kota_kabupaten/";
        request_url_calculate_shipping = "http://pro.rajaongkir.com/api/cost";
        request_url_find_shippings = baseURL + "/wp-tm-ext-store-notify/api/epeken_allcurir_shipping_cost/";
        request_url_currency = "http://pro.rajaongkir.com/api/currency";
        request_store_destination = baseURL + "/wp-tm-ext-store-notify/api/ext_ship_plugin/";
        listCities = true;
        superCountry = TM_Region.getRegion("country", "ID", "Indonesia", null);
        citySelection = true;
        subDistrictSelection = true;
        this.key = key;
    }

    @Override
    public void getCountries(TM_Region parent, final DataQueryHandler dataQueryHandler) {
        if (dataQueryHandler != null) {
            List list = new ArrayList<>();
            list.add(superCountry);
            dataQueryHandler.onSuccess(list);
            return;
        }
    }

    @Override
    public void getStates(final TM_Region parent, final DataQueryHandler dataQueryHandler) {

        if (parent.regionsLoaded) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onSuccess(TM_Region.getRegions(parent));
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
                DataHelper.log("-- getStates::onResponseReceived:[" + postResponse.msg + "] --");
                if (postResponse.succeed) {
                    String response = postResponse.msg;
                    if (WooCommerceJSONHelper.hasResponseError(response, dataQueryHandler)) {
                        return;
                    }
                    dataQueryHandler.onSuccess(parseJsonAndCreateStates(parent, response));
                    parent.regionsLoaded = true;
                } else {
                    dataQueryHandler.onFailure(postResponse.error);
                }
            }
        };
        NetworkRequest.makeCommonPostRequest(request_url_cities, null, null, postResponseListener);

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
    public void getSubDistricts(final TM_Region parent, String state, final DataQueryHandler dataQueryHandler) {
        if (parent.regionsLoaded) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onSuccess(TM_Region.getRegions(parent));
            }
            return;
        }

        if (!DataEngine.getDataEngine().isNetworkAvailable()) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onFailure(new NoConnectionError(""));
            }
            return;
        }
        final Map<String, String> params = new HashMap<>();
        params.put("city", state);
        params.put("subdistrict", parent.toString());
        NetworkResponse.ResponseListener postResponseListener = new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse postResponse) {
                DataHelper.log("-- getStates::onResponseReceived:[" + postResponse.msg + "] --");
                if (postResponse.succeed) {
                    String response = postResponse.msg;
                    if (WooCommerceJSONHelper.hasResponseError(response, dataQueryHandler)) {
                        return;
                    }
                    dataQueryHandler.onSuccess(parseJsonAndCreateSubDistricts(parent, response));
                    parent.regionsLoaded = true;
                } else {
                    dataQueryHandler.onFailure(postResponse.error);
                }
            }
        };
        NetworkRequest.makeCommonPostRequest(request_url_sub_discricts, params, null, postResponseListener);
    }

    @Override
    public void getCities(final TM_Region parent, final DataQueryHandler dataQueryHandler) {

        if (parent.regionsLoaded) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onSuccess(TM_Region.getRegions(parent));
            }
            return;
        }

        if (!DataEngine.getDataEngine().isNetworkAvailable()) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onFailure(new NoConnectionError(""));
            }
            return;
        }
        final Map<String, String> params = new HashMap<>();
        params.put("city", parent.toString());
        NetworkResponse.ResponseListener postResponseListener = new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse postResponse) {
                DataHelper.log("-- getCities::onResponseReceived:[" + postResponse.msg + "] --");
                if (postResponse.succeed) {
                    String response = postResponse.msg;
                    if (WooCommerceJSONHelper.hasResponseError(response, dataQueryHandler)) {
                        return;
                    }
                    dataQueryHandler.onSuccess(parseJsonAndCreateCities(parent, response));
                    parent.regionsLoaded = true;
                } else {
                    dataQueryHandler.onFailure(postResponse.error);
                }
            }
        };
        NetworkRequest.makeCommonPostRequest(request_url_states, params, null, postResponseListener);

    }

    @Override
    public void calculateShipping(TM_Region origin, TM_Region destination, DataQueryHandler dataQueryHandler) {
        if (dataQueryHandler != null)
            dataQueryHandler.onFailure(new NoSuchMethodException());
    }

    @Override
    public void getAvailableShipping(TM_StoreInfo storeInfo, TM_Region destinationSubDistrict, float weight, final DataQueryHandler dataQueryHandler) {
        if (!DataEngine.getDataEngine().isNetworkAvailable()) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onFailure(new NoConnectionError(""));
            }
            return;
        }
        final Map<String, String> params = new HashMap<>();
        params.put("city", storeInfo.locations.get(0).title);
        params.put("subdistrict", destinationSubDistrict.title);
        NetworkResponse.ResponseListener postResponseListener = new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse postResponse) {
                DataHelper.log("-- getAvailableShipping::onResponseReceived:[" + postResponse.msg + "] --");
                if (postResponse.succeed) {
                    String response = postResponse.msg;
                    if (WooCommerceJSONHelper.hasResponseError(response, dataQueryHandler)) {
                        return;
                    }
                    dataQueryHandler.onSuccess(parseJsonAndCreateShipping(response));
                } else {
                    dataQueryHandler.onFailure(postResponse.error);
                }
            }
        };
        NetworkRequest.makeCommonPostRequest(request_url_find_shippings, params, null, postResponseListener);
    }

    @Override
    public void getCurrencyRate(final DataQueryHandler dataQueryHandler) {
        if (!DataEngine.getDataEngine().isNetworkAvailable()) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onFailure(new NoConnectionError(""));
            }
            return;
        }
        final Map<String, String> params = new HashMap<>();
        params.put("key", key);
        params.put("android-key", androidKey);
        NetworkResponse.ResponseListener postResponseListener = new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse postResponse) {
                DataHelper.log("-- getCurrencyRate::onResponseReceived:[" + postResponse.msg + "] --");
                if (postResponse.succeed) {
                    String response = postResponse.msg;
                    if (WooCommerceJSONHelper.hasResponseError(response, dataQueryHandler)) {
                        return;
                    }
                    dataQueryHandler.onSuccess(parseJsonAndFindCurrencyRate(response));
                } else {
                    dataQueryHandler.onFailure(postResponse.error);
                }
            }
        };
        NetworkRequest.makeCommonGetRequest(request_url_currency, params, postResponseListener);
    }

    @Override
    public void getStoreLocation(final DataQueryHandler dataQueryHandler) {

        if (dataQueryHandler != null) {
            dataQueryHandler.onSuccess(null);
            return;
        }

    }

    private List<TM_Region> parseJsonAndCreateStates(TM_Region parent, String jsonStringContent) {
        List<TM_Region> cities = new ArrayList<>();
        DataHelper.log("-- parseJsonAndCreateStates: [" + jsonStringContent + "] --");

        JSONObject jMainObject = null;
        JSONObject citiesObj = null;
        Map<String, Object> retMap = null;

        try {
            jMainObject = DataHelper.safeJsonObject(jsonStringContent);
            citiesObj = jMainObject.getJSONObject("cities");
            retMap = new Gson().fromJson(citiesObj.toString(), new TypeToken<HashMap<String, Object>>() {
            }.getType());
            for (Map.Entry<String, Object> entry : retMap.entrySet()) {
                System.out.println(entry.getKey() + "/" + entry.getValue());
                String type = "city"; //jsonSubDistricts.getString("type");
                String city_id = entry.getKey();
                String city_name = entry.getValue().toString();

                TM_Region state = TM_Region.getRegion(type, city_id, city_name, parent);
                cities.add(state);
            }
        } catch (JSONException e) {
        } catch (Exception e) {
        }

        return cities;
    }

    private List<TM_Region> parseJsonAndCreateCities(TM_Region parent, String jsonStringContent) {
        List<TM_Region> states = new ArrayList<>();
        DataHelper.log("-- parseJsonAndCreateCities: [" + jsonStringContent + "] --");

        JSONObject jMainObject = null;
        JSONObject subDistrict = null;
        Map<String, Object> retMap = null;

        try {
            jMainObject = DataHelper.safeJsonObject(jsonStringContent);
            subDistrict = jMainObject.getJSONObject("subdistrict");
            retMap = new Gson().fromJson(subDistrict.toString(), new TypeToken<HashMap<String, Object>>() {
            }.getType());
            for (Map.Entry<String, Object> entry : retMap.entrySet()) {
                System.out.println(entry.getKey() + "/" + entry.getValue());
                String type = "subdistrict"; //jsonSubDistricts.getString("type");
                String province_id = entry.getKey();
                String province = entry.getValue().toString();

                TM_Region state = TM_Region.getRegion(type, province_id, province, parent);
                states.add(state);
            }
        } catch (JSONException e) {
        } catch (Exception e) {
        }
        return states;
    }

    private List<TM_Region> parseJsonAndCreateSubDistricts(TM_Region parent, String jsonStringContent) {
        List<TM_Region> subdistricts = new ArrayList<>();
        DataHelper.log("-- parseJsonAndCreateSubDistricts: [" + jsonStringContent + "] --");
        JSONObject jMainObject = null;
        try {
            String type = "province"; //jsonSubDistricts.getString("type");
            jMainObject = DataHelper.safeJsonObject(jsonStringContent);
            JSONArray jsonProvince = jMainObject.getJSONArray("province");
            for (int i = 0; i < jsonProvince.length(); i++) {
                String province = jsonProvince.getString(i);
                TM_Region state = TM_Region.getRegion(type, province, province, parent);
                subdistricts.add(state);
            }
        } catch (JSONException e) {
        } catch (Exception e) {
        }
        return subdistricts;
    }

    public TM_StoreInfo parseJsonAndGetLocation(String jsonStringContent) throws JSONException {
        DataHelper.log("-- parseJsonAndGetLocation: [" + jsonStringContent + "] --");
        JSONObject jMainObject = DataHelper.safeJsonObject(jsonStringContent); //new JSONObject(jsonStringContent);
        JSONObject ship_data = jMainObject.getJSONObject("ship_data");
        JSONArray store_location = ship_data.getJSONArray("store_location");
        //String location = store_location.getString(0);
        JSONArray courier_type = ship_data.getJSONArray("courier_type");
        TM_StoreInfo storeInfo = new TM_StoreInfo();
        for (int i = 0; i < store_location.length(); i++) {
            storeInfo.locations.add(TM_Region.getRegionFromAll("city", store_location.getString(i)));
        }
        for (int i = 0; i < courier_type.length(); i++) {
            storeInfo.courier_types.add(courier_type.getString(i));
        }
        return storeInfo;
    }

    public float parseJsonAndFindCurrencyRate(String jsonStringContent) {
        DataHelper.log("-- parseJsonAndFindCurrencyRate: [" + jsonStringContent + "] --");
        JSONObject jMainObject = null;
        try {
            jMainObject = DataHelper.safeJsonObject(jsonStringContent); //new JSONObject(jsonStringContent);
            JSONObject rajaongkir = jMainObject.getJSONObject("rajaongkir");
            JSONObject result = rajaongkir.getJSONObject("result");
            return DataHelper.safeFloat(result.getString("value"));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 1.0f;
    }

    public List<TM_Shipping> parseJsonAndCreateShipping(String jsonStringContent) {
        List<TM_Shipping> shipping = new ArrayList<>();
        DataHelper.log("-- parseJsonAndCreateShipping: [" + jsonStringContent + "] --");
        JSONObject jMainObject;
        try {
            jMainObject = DataHelper.safeJsonObject(jsonStringContent);
            JSONArray results = jMainObject.getJSONArray("shipping_methods");
            for (int i = 0; i < results.length(); i++) {
                final JSONObject resultObject = results.getJSONObject(i);
                TM_Shipping shippingItem = new TM_Shipping();

                shippingItem.label = resultObject.getString("name");
                shippingItem.description = "";
                shippingItem.method_id = resultObject.getString("name");
                shippingItem.id = resultObject.getString("name");
                shippingItem.cost = resultObject.getDouble("cost");
                shipping.add(shippingItem);

            }
        } catch (Exception e2) {
            e2.printStackTrace();
        }
        return shipping;
    }
}