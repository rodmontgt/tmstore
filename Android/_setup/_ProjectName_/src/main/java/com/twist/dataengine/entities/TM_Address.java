package com.twist.dataengine.entities;

public class TM_Address {
    public String first_name = "";
    public String last_name = "";
    public String company = "";
    public String address_1 = "";
    public String address_2 = "";
    public String city = "";
    public String state = "";
    public String postcode = "";
    public String country = "";
    public String email = "";
    public String phone = "";
    public String latitude = "";
    public String longitude = "";

    public String getAddressLine() {
        return getAddressLine("\n");
    }

    public String getAddressLine(String saperator) {
        String str_address = "";
        if (!company.equals(""))
            str_address += company + saperator;
        if (!address_1.equals(""))
            str_address += address_1 + saperator;
        if (!address_2.equals(""))
            str_address += address_2 + saperator;
        if (!city.equals(""))
            str_address += city + " - ";
        if (!state.equals(""))
            str_address += state + saperator;
        if (!postcode.equals(""))
            str_address += postcode + " - ";
        if (!country.equals(""))
            str_address += country + saperator;
        if (!email.equals(""))
            str_address += email + saperator;
        if (!phone.equals(""))
            str_address += phone;
        if (!latitude.equals(""))
            str_address += latitude;
        if (!longitude.equals(""))
            str_address += longitude;
        return str_address;
    }
}
