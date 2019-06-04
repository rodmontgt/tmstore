package com.twist.dataengine.entities;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TM_Tax {

    public int id;
    public String country;
    public String state;
    public String postcode;
    public String city;
    public double rate;
    public String name;
    public int priority;
    public Boolean compound;
    public Boolean shipping;
    public int order;
    public String taxClass;
    public float netTax;

    private Map<String, Object> additionalProperties = new HashMap<>();

    public static List<TM_Tax> all_Tax = new ArrayList<>();
    public static List<TM_Tax> all_TaxesApplied = new ArrayList<>();


    public TM_Tax(int id) {
        this.id = id;
    }

    /**
     * @return The country
     */
    public String getCountry() {
        return country;
    }

    /**
     * @param country The country
     */
    public void setCountry(String country) {
        this.country = country;
    }

    /**
     * @return The state
     */
    public String getState() {
        return state;
    }

    /**
     * @param state The state
     */
    public void setState(String state) {
        this.state = state;
    }

    /**
     * @return The postcode
     */
    public String getPostcode() {
        return postcode;
    }

    /**
     * @param postcode The postcode
     */
    public void setPostcode(String postcode) {
        this.postcode = postcode;
    }

    /**
     * @return The city
     */
    public String getCity() {
        return city;
    }

    /**
     * @param city The city
     */
    public void setCity(String city) {
        this.city = city;
    }

    /**
     * @return The rate
     */
    public double getRate() {
        return rate;
    }

    /**
     * @param rate The rate
     */
    public void setRate(String rate) {
        try {
            this.rate = Double.parseDouble(rate);
        } catch (NumberFormatException nfe) {
            this.rate = 0.0;
        }
    }

    /**
     * @param rate The rate
     */
    public void setRate(double rate) {
        this.rate = rate;
    }

    /**
     * @return The name
     */
    public String getName() {
        return name;
    }

    /**
     * @param name The name
     */
    public void setName(String name) {
        this.name = name;
    }

    /**
     * @return The priority
     */
    public Integer getPriority() {
        return priority;
    }

    /**
     * @param priority The priority
     */
    public void setPriority(Integer priority) {
        this.priority = priority;
    }

    /**
     * @return The compound
     */
    public Boolean getCompound() {
        return compound;
    }

    /**
     * @param compound The compound
     */
    public void setCompound(Boolean compound) {
        this.compound = compound;
    }

    /**
     * @return The shipping
     */
    public Boolean getShipping() {
        return shipping;
    }

    /**
     * @param shipping The shipping
     */
    public void setShipping(Boolean shipping) {
        this.shipping = shipping;
    }

    /**
     * @return The order
     */
    public Integer getOrder() {
        return order;
    }

    /**
     * @param order The order
     */
    public void setOrder(Integer order) {
        this.order = order;
    }

    /**
     * @return The taxClass
     */
    public String getTaxClass() {
        return taxClass;
    }

    /**
     * @param taxClass The class
     */
    public void setTaxClass(String taxClass) {
        this.taxClass = taxClass;
    }

    public Map<String, Object> getAdditionalProperties() {
        return this.additionalProperties;
    }

    public void setAdditionalProperty(String name, Object value) {
        this.additionalProperties.put(name, value);
    }

    public List<TM_Tax> getAllTaxesApplied() {
        if (all_TaxesApplied == null) {
            all_TaxesApplied = new ArrayList<>();
        }
        return all_TaxesApplied;
    }

    public static TM_Tax copy(TM_Tax taxObj) {

        TM_Tax taxApplied = new TM_Tax(taxObj.id);
        taxApplied.city = taxObj.city;
        taxApplied.state = taxObj.state;
        taxApplied.country = taxObj.country;
        taxApplied.postcode = taxObj.postcode;
        taxApplied.name = taxObj.name;
        taxApplied.taxClass = taxObj.taxClass;
        taxApplied.id = taxObj.id;
        taxApplied.priority = taxObj.priority;
        taxApplied.order = taxObj.order;
        taxApplied.rate = taxObj.rate;
        taxApplied.compound = taxObj.compound;
        taxApplied.shipping = taxObj.shipping;

        taxApplied.additionalProperties = taxObj.additionalProperties;
        return taxApplied;
    }
}
