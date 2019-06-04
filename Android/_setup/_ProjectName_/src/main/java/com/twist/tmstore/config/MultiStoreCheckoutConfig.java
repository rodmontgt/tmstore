package com.twist.tmstore.config;

import java.util.ArrayList;

/**
 * Created by Twist Mobile on 15-05-2017.
 */

public class MultiStoreCheckoutConfig {
    public String deliveryTypeLabel;
    public String deliveryTypeField;
    public String selectedDeliveryType;
    public String[] deliveryTypeOptions;

    public String homeDestinationLabel;
    public String homeDestinationField;
    public String selectedHomeDestination;
    public String[] homeDestinationOptions;

    public String clusterDestinationsLabel;
    public String clusterDestinationsField;
    public String selectedClusterDestination;
    public String[] clusterDestinationsOptions;

    public String deliveryDaysLabel;
    public String deliveryDaysField;
    public String selectedDeliveryDay;
    public String[] deliveryDaysOptions;

    public String deliveryFee;

    public ArrayList<DeliverSlot> deliverSlots = new ArrayList<>();

    public static class DeliverSlot {
        public String label;
        public String[] options;
        public String chosen_valt;
        public String field;
    }
}
