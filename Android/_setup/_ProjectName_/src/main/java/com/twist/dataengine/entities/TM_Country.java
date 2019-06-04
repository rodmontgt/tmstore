package com.twist.dataengine.entities;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 2/16/2016.
 */
public class TM_Country {
    public boolean statesLoaded = false;
    public List<TM_State> states = new ArrayList<>();
    public String name;
    public String id;

    private static List<TM_Country> allCountries = new ArrayList<>();
    private static List<String> allCountryNames = new ArrayList<>();


    public TM_Country() {
        allCountries.add(this);
    }

    public static List<TM_Country> getAllCountries() {
        return allCountries;
    }

    public static List<String> getAllCountryNames() {
        if(allCountryNames.size() != allCountries.size()) {
            allCountryNames.clear();
            for (TM_Country country : allCountries) {
                allCountryNames.add(country.name);
            }
        }
        return allCountryNames;
    }

    public List<String> getStateNames() {
        List<String> stateNames = new ArrayList<>();
        for(TM_State state : states) {
            stateNames.add(state.name);
        }
        return stateNames;
    }

    public static int getIndexOf(String countryName) {
        for(int i=0; i<allCountries.size(); i++) {
            if(allCountries.get(i).name.equals(countryName)){
                return i;
            }
        }
        return 0;
    }

    public int getIndexOfState(String stateName) {
        for(int i=0; i<states.size(); i++) {
            if(states.get(i).name.equals(stateName)){
                return i;
            }
        }
        return 0;
    }

    public int getIndexOfStateId(String stateId) {
        for(int i=0; i<states.size(); i++) {
            if(states.get(i).id.equals(stateId)){
                return i;
            }
        }
        return 0;
    }

    public boolean equals(TM_Country other) {
        return this.name.equals(other.name);
    }

    public static TM_Country getByName(String givenName) {
        for (TM_Country country : allCountries) {
            if(country.name.equalsIgnoreCase(givenName)){
                return country;
            }
        }
        return null;
    }

    public static String getCountryCode(String countryName){
        for(TM_Country country : allCountries){
            if(country.name.equalsIgnoreCase(countryName)){
                return country.id;
            }
        }
        return "";
    }

    public static String getStateCode(String stateName){
        for(TM_Country country : allCountries){
            for (TM_State state: country.states){
                if(state.name.equalsIgnoreCase(stateName)){
                    return state.id;
                }
            }
        }
        return "";
    }

    @Override
    public String toString() {
        return this.name;
    }
}
