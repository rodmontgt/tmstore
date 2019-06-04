package com.twist.dataengine.shippings;

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

public class RajaOngkirShipping extends ShippingEngine {
    private String key = "";
    private String androidKey = "";
    private String id = "";
    private TM_Region superCountry;

    public RajaOngkirShipping(String baseURL, String key) {
        request_url_countries = "http://pro.rajaongkir.com/api/province";
        request_url_states = "http://pro.rajaongkir.com/api/province";
        request_url_sub_discricts = "http://pro.rajaongkir.com/api/subdistrict";
        request_url_cities = "http://pro.rajaongkir.com/api/city";
        request_url_calculate_shipping = "http://pro.rajaongkir.com/api/cost";
        request_url_find_shippings = "http://pro.rajaongkir.com/api/cost";
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
        final Map<String, String> params = new HashMap<>();
        params.put("key", key);
        params.put("android-key", androidKey);
        //params.put("city", androidKey));
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
        NetworkRequest.makeCommonGetRequest(request_url_states, params, postResponseListener);

    }

    @Override
    public void getDistricts(TM_Region parent, DataQueryHandler dataQueryHandler) {
        if (dataQueryHandler != null)
            dataQueryHandler.onFailure(new NoSuchMethodException());
    }

    @Override
    public void getSubDistricts(final TM_Region parent, final DataQueryHandler dataQueryHandler) {
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
        params.put("key", key);
        params.put("android-key", androidKey);
        params.put("city", parent.id);
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
        NetworkRequest.makeCommonGetRequest(request_url_sub_discricts, params, postResponseListener);
    }

    @Override
    public void getSubDistricts(TM_Region parent, String state, DataQueryHandler dataQueryHandler) {
        if (dataQueryHandler != null)
            dataQueryHandler.onFailure(new NoSuchMethodException());
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
        params.put("key", key);
        params.put("android-key", androidKey);
        params.put("province", parent.id);
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
        NetworkRequest.makeCommonGetRequest(request_url_cities, params, postResponseListener);
    }

    @Override
    public void calculateShipping(TM_Region origin, TM_Region destination, DataQueryHandler dataQueryHandler) {
        if (dataQueryHandler != null)
            dataQueryHandler.onFailure(new NoSuchMethodException());
    }

    @Override
    public void getAvailableShipping(TM_StoreInfo storeInfo, TM_Region destination, float weight, final DataQueryHandler dataQueryHandler) {
        if (!DataEngine.getDataEngine().isNetworkAvailable()) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onFailure(new NoConnectionError(""));
            }
            return;
        }

        TM_Region origin = storeInfo.locations.get(0);

        final Map<String, String> params = new HashMap<>();
        params.put("key", key);
        params.put("android-key", androidKey);
        params.put("origin", origin.id);
        params.put("originType", origin.type);
        params.put("destination", destination.id);
        params.put("destinationType", destination.type);
        params.put("weight", weight + "");

        String courier = "";
        for (String courier_type : storeInfo.courier_types) {
            courier += courier_type + ":";
        }
        if (courier.length() > 0) {
            courier = courier.substring(0, courier.length() - 1);
        }
        params.put("courier", courier);

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
        if (!DataEngine.getDataEngine().isNetworkAvailable()) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onFailure(new NoConnectionError(""));
            }
            return;
        }
        final Map<String, String> params = new HashMap<>();
        params.put("ship_type", DataHelper.encrypt("plugin_ongkos_kirim"));
        NetworkResponse.ResponseListener responseListener = new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse postResponse) {
                DataHelper.log("-- getStoreLocation::onResponseReceived:[" + postResponse.msg + "] --");
                if (postResponse.succeed) {
                    String response = postResponse.msg;
                    if (WooCommerceJSONHelper.hasResponseError(response, dataQueryHandler)) {
                        return;
                    }
                    try {
                        dataQueryHandler.onSuccess(parseJsonAndGetLocation(response));
                    } catch (JSONException e) {
                        dataQueryHandler.onFailure(e);
                    }
                } else {
                    dataQueryHandler.onFailure(postResponse.error);
                }
            }
        };
        NetworkRequest.makeCommonPostRequest(request_store_destination, params, null, responseListener);
    }


    private List<TM_Region> parseJsonAndCreateStates(TM_Region parent, String jsonStringContent) {
        List<TM_Region> states = new ArrayList<>();
        DataHelper.log("-- parseJsonAndCreateStates: [" + jsonStringContent + "] --");
        JSONObject jMainObject = null;
        try {
            jMainObject = DataHelper.safeJsonObject(jsonStringContent); //new JSONObject(jsonStringContent);
            JSONObject rajaongkir = jMainObject.getJSONObject("rajaongkir");
            JSONArray results = rajaongkir.getJSONArray("results");
            for (int i = 0; i < results.length(); i++) {
                try {
                    JSONObject jsonSubDistricts = results.getJSONObject(i);
                    String type = "province"; //jsonSubDistricts.getString("type");
                    String province_id = jsonSubDistricts.getString("province_id");
                    String province = jsonSubDistricts.getString("province");

                    TM_Region state = TM_Region.getRegion(type, province_id, province, parent);
                    states.add(state);
                } catch (JSONException je) {
                    je.printStackTrace();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return states;
    }

    private List<TM_Region> parseJsonAndCreateCities(TM_Region parent, String jsonStringContent) {
        List<TM_Region> cities = new ArrayList<>();
        DataHelper.log("-- parseJsonAndCreateCities: [" + jsonStringContent + "] --");
        JSONObject jMainObject = null;
        try {
            jMainObject = DataHelper.safeJsonObject(jsonStringContent); //new JSONObject(jsonStringContent);
            JSONObject rajaongkir = jMainObject.getJSONObject("rajaongkir");
            JSONArray results = rajaongkir.getJSONArray("results");
            for (int i = 0; i < results.length(); i++) {
                try {
                    JSONObject jsonSubDistricts = results.getJSONObject(i);
                    String type = "city"; //jsonSubDistricts.getString("type");
                    //String province_id = jsonSubDistricts.getString("province_id");
                    // String province = jsonSubDistricts.getString("province");
                    String city_id = jsonSubDistricts.getString("city_id");
                    String city = jsonSubDistricts.getString("city_name");
                    //String subdistrict_name = jsonSubDistricts.getString("subdistrict_name");
                    //String subdistrict_id = jsonSubDistricts.getString("subdistrict_id");

                    //TM_Region aProvince = TM_Region.getRegion("province", province_id, province, superCountry);
                    TM_Region aCity = TM_Region.getRegion(type, city_id, city, parent);
                    //TM_Region aDistrict = TM_Region.getRegion(type, subdistrict_id, subdistrict_name, aCity);

                    cities.add(aCity);
                } catch (JSONException je) {
                    je.printStackTrace();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return cities;
    }

    private List<TM_Region> parseJsonAndCreateSubDistricts(TM_Region parent, String jsonStringContent) {
        List<TM_Region> subdistricts = new ArrayList<>();
        DataHelper.log("-- parseJsonAndCreateSubDistricts: [" + jsonStringContent + "] --");
        JSONObject jMainObject = null;
        try {
            jMainObject = DataHelper.safeJsonObject(jsonStringContent); //new JSONObject(jsonStringContent);
            JSONObject rajaongkir = jMainObject.getJSONObject("rajaongkir");
            JSONArray results = rajaongkir.getJSONArray("results");
            for (int i = 0; i < results.length(); i++) {
                try {
                    JSONObject jsonSubDistricts = results.getJSONObject(i);
                    String type = "subdistrict"; //jsonSubDistricts.getString("type");
                    //String province_id = jsonSubDistricts.getString("province_id");
                    //String province = jsonSubDistricts.getString("province");
                    //String city_id = jsonSubDistricts.getString("city_id");
                    //String city = jsonSubDistricts.getString("city");
                    String subdistrict_name = jsonSubDistricts.getString("subdistrict_name");
                    String subdistrict_id = jsonSubDistricts.getString("subdistrict_id");

                    //TM_Region aProvince = TM_Region.getRegion("province", province_id, province, superCountry);
                    //TM_Region aCity = TM_Region.getRegion("city", city_id, city, aProvince);
                    TM_Region subDistrict = TM_Region.getRegion(type, subdistrict_id, subdistrict_name, parent);

                    subdistricts.add(subDistrict);
                } catch (JSONException je) {
                    je.printStackTrace();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
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
        JSONObject jMainObject = null;
        try {
            jMainObject = DataHelper.safeJsonObject(jsonStringContent); //new JSONObject(jsonStringContent);
            JSONObject rajaongkir = jMainObject.getJSONObject("rajaongkir");
            JSONArray results = rajaongkir.getJSONArray("results");
            for (int i = 0; i < results.length(); i++) {
                final JSONObject resultObject = results.getJSONObject(i);
                JSONArray costs = resultObject.getJSONArray("costs");
                for (int j = 0; j < costs.length(); j++) {
                    try {
                        TM_Shipping shippingItem = new TM_Shipping();
                        shippingItem.id = resultObject.getString("code");
                        //shippingItem.label = resultObject.getString("name");

                        JSONObject costsJSONObject = costs.getJSONObject(j);
                        shippingItem.method_id = costsJSONObject.getString("service");
                        shippingItem.label = resultObject.getString("code").toUpperCase() + " " + shippingItem.method_id;
                        shippingItem.description = costsJSONObject.getString("description");
                        {
                            JSONArray cost = costsJSONObject.getJSONArray("cost");
                            JSONObject faltuKaObject = cost.getJSONObject(0);
                            shippingItem.cost = faltuKaObject.getDouble("value");
                            shippingItem.etd = faltuKaObject.getString("etd");
                        }
                        shipping.add(shippingItem);
                    } catch (Exception e1) {
                        e1.printStackTrace();
                    }
                }
            }
        } catch (Exception e2) {
            e2.printStackTrace();
        }
        return shipping;
    }


}
