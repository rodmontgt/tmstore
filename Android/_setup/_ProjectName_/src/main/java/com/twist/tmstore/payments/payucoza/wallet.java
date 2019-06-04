package com.twist.tmstore.payments.payucoza;

//------------------------------------------------------------------------------
// <wsdl2code-generated>
//    This code was generated by http://www.wsdl2code.com version  2.5
//
// Date Of Creation: 7/4/2014 4:34:19 PM
//    Please dont change this code, regeneration will override your changes
//</wsdl2code-generated>
//
//------------------------------------------------------------------------------
//
//This source code was auto-generated by Wsdl2Code  Version
//

import org.ksoap2.serialization.KvmSerializable;
import org.ksoap2.serialization.PropertyInfo;
import org.ksoap2.serialization.SoapObject;
import org.ksoap2.serialization.SoapPrimitive;

import java.util.Hashtable;

public class wallet implements KvmSerializable {

    public String amountInCents;
    public String availableBalance;
    public String loayltyBalance;
    public String loyaltyAmountInCents;
    public String reservedBalance;
    public String sufficientFunds;
    public walletBalance walletBalance;
    public String defaultPM;
    public String pmId;

    public wallet() {
    }

    public wallet(SoapObject soapObject) {
        if (soapObject == null)
            return;
        if (soapObject.hasProperty("amountInCents")) {
            Object obj = soapObject.getProperty("amountInCents");
            if (obj != null && obj.getClass().equals(SoapPrimitive.class)) {
                SoapPrimitive j = (SoapPrimitive) obj;
                amountInCents = j.toString();
            } else if (obj != null && obj instanceof String) {
                amountInCents = (String) obj;
            }
        }
        if (soapObject.hasProperty("availableBalance")) {
            Object obj = soapObject.getProperty("availableBalance");
            if (obj != null && obj.getClass().equals(SoapPrimitive.class)) {
                SoapPrimitive j = (SoapPrimitive) obj;
                availableBalance = j.toString();
            } else if (obj != null && obj instanceof String) {
                availableBalance = (String) obj;
            }
        }
        if (soapObject.hasProperty("loayltyBalance")) {
            Object obj = soapObject.getProperty("loayltyBalance");
            if (obj != null && obj.getClass().equals(SoapPrimitive.class)) {
                SoapPrimitive j = (SoapPrimitive) obj;
                loayltyBalance = j.toString();
            } else if (obj != null && obj instanceof String) {
                loayltyBalance = (String) obj;
            }
        }
        if (soapObject.hasProperty("loyaltyAmountInCents")) {
            Object obj = soapObject.getProperty("loyaltyAmountInCents");
            if (obj != null && obj.getClass().equals(SoapPrimitive.class)) {
                SoapPrimitive j = (SoapPrimitive) obj;
                loyaltyAmountInCents = j.toString();
            } else if (obj != null && obj instanceof String) {
                loyaltyAmountInCents = (String) obj;
            }
        }
        if (soapObject.hasProperty("reservedBalance")) {
            Object obj = soapObject.getProperty("reservedBalance");
            if (obj != null && obj.getClass().equals(SoapPrimitive.class)) {
                SoapPrimitive j = (SoapPrimitive) obj;
                reservedBalance = j.toString();
            } else if (obj != null && obj instanceof String) {
                reservedBalance = (String) obj;
            }
        }
        if (soapObject.hasProperty("sufficientFunds")) {
            Object obj = soapObject.getProperty("sufficientFunds");
            if (obj != null && obj.getClass().equals(SoapPrimitive.class)) {
                SoapPrimitive j = (SoapPrimitive) obj;
                sufficientFunds = j.toString();
            } else if (obj != null && obj instanceof String) {
                sufficientFunds = (String) obj;
            }
        }
        if (soapObject.hasProperty("WalletBalance")) {
            SoapObject j = (SoapObject) soapObject.getProperty("WalletBalance");
            walletBalance = new walletBalance(j);

        }
        if (soapObject.hasProperty("defaultPM")) {
            Object obj = soapObject.getProperty("defaultPM");
            if (obj != null && obj.getClass().equals(SoapPrimitive.class)) {
                SoapPrimitive j = (SoapPrimitive) obj;
                defaultPM = j.toString();
            } else if (obj != null && obj instanceof String) {
                defaultPM = (String) obj;
            }
        }
        if (soapObject.hasProperty("pmId")) {
            Object obj = soapObject.getProperty("pmId");
            if (obj != null && obj.getClass().equals(SoapPrimitive.class)) {
                SoapPrimitive j = (SoapPrimitive) obj;
                pmId = j.toString();
            } else if (obj != null && obj instanceof String) {
                pmId = (String) obj;
            }
        }
    }

    @Override
    public Object getProperty(int arg0) {
        switch (arg0) {
            case 0:
                return amountInCents;
            case 1:
                return availableBalance;
            case 2:
                return loayltyBalance;
            case 3:
                return loyaltyAmountInCents;
            case 4:
                return reservedBalance;
            case 5:
                return sufficientFunds;
            case 6:
                return walletBalance;
            case 7:
                return defaultPM;
            case 8:
                return pmId;
        }
        return null;
    }

    @Override
    public int getPropertyCount() {
        return 9;
    }

    @Override
    public void getPropertyInfo(int index, @SuppressWarnings("rawtypes") Hashtable arg1, PropertyInfo info) {
        switch (index) {
            case 0:
                info.type = PropertyInfo.STRING_CLASS;
                info.name = "amountInCents";
                break;
            case 1:
                info.type = PropertyInfo.STRING_CLASS;
                info.name = "availableBalance";
                break;
            case 2:
                info.type = PropertyInfo.STRING_CLASS;
                info.name = "loayltyBalance";
                break;
            case 3:
                info.type = PropertyInfo.STRING_CLASS;
                info.name = "loyaltyAmountInCents";
                break;
            case 4:
                info.type = PropertyInfo.STRING_CLASS;
                info.name = "reservedBalance";
                break;
            case 5:
                info.type = PropertyInfo.STRING_CLASS;
                info.name = "sufficientFunds";
                break;
            case 6:
                info.type = walletBalance.class;
                info.name = "WalletBalance";
                break;
            case 7:
                info.type = PropertyInfo.STRING_CLASS;
                info.name = "defaultPM";
                break;
            case 8:
                info.type = PropertyInfo.STRING_CLASS;
                info.name = "pmId";
                break;
        }
    }

    @Override
    public void setProperty(int arg0, Object arg1) {
    }

}