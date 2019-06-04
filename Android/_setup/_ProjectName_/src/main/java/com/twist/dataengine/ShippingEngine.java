package com.twist.dataengine;

import com.twist.dataengine.entities.TM_Region;
import com.twist.dataengine.entities.TM_StoreInfo;

/**
 * Created by Twist Mobile on 8/18/2016.
 */

public abstract class ShippingEngine {

    public String request_url_countries = "";
    public String request_url_states = "";
    public String request_url_districts = "";
    public String request_url_sub_discricts = "";
    public String request_url_cities = "";
    public String request_url_calculate_shipping = "";
    public String request_url_find_shippings = "";
    public String request_url_currency = "";
    public String request_store_destination = "";

    protected boolean citySelection = false;
    protected boolean districtSelection = false;

    public boolean hasSubDistrictSelection() {
        return subDistrictSelection;
    }

    public boolean hasDistrictSelection() {
        return districtSelection;
    }

    public boolean hasCitySelection() {
        return citySelection;
    }

    protected boolean subDistrictSelection = false;

    public static boolean areCitiesListed() {
        return listCities;
    }

    protected static boolean listCities = false;

    public abstract void getCountries(TM_Region parent, DataQueryHandler dataQueryHandler);

    public abstract void getStates(TM_Region parent, DataQueryHandler dataQueryHandler);

    public abstract void getDistricts(TM_Region parent, DataQueryHandler dataQueryHandler);

    public abstract void getSubDistricts(TM_Region parent, DataQueryHandler dataQueryHandler);

    public abstract void getSubDistricts(TM_Region parent,String state, DataQueryHandler dataQueryHandler);

    public abstract void getCities(TM_Region parent, DataQueryHandler dataQueryHandler);

    public abstract void calculateShipping(TM_Region origin, TM_Region destination, DataQueryHandler dataQueryHandler);

    public abstract void getAvailableShipping(TM_StoreInfo origin, TM_Region destination, float weight, DataQueryHandler dataQueryHandler);

    //public abstract void getAvailableShipping(String city,String state, DataQueryHandler dataQueryHandler);

    public abstract void getCurrencyRate(DataQueryHandler dataQueryHandler);

    public abstract void getStoreLocation(final DataQueryHandler dataQueryHandler);
}
