package com.twist.tmstore.shipping;

/**
 * Created by Twist Mobile on 20/11/2017.
 */
public class ShippingStatusRajaongkir {

    public boolean delivered;
    public Result result;

    public Details getShippingDetails() {
        return result.details;
    }

    public DeliveryStatus getShippingDeliveryStatus() {
        return result.delivery_status;
    }

    public class Result {
        public Summary summary;
        public Details details;
        public DeliveryStatus delivery_status;
        public Manifest manifest[];
    }

    public class Summary {

        private String courier_code;
        private String courier_name;
        private String waybill_number;
        private String service_code;
        private String waybill_date;
        private String shipper_name;
        private String receiver_name;
        private String origin;
        private String destination;
        private String status;
    }

    public class Details {

        public String waybill_number;
        public String waybill_date;
        public String waybill_time;
        public String weight;
        public String origin;
        public String destination;
        public String shippper_name;
        public String shipper_address1;
        public String shipper_address2;
        public String shipper_address3;
        public String shipper_city;
        public String receiver_name;
        public String receiver_address1;
        public String receiver_address2;
        public String receiver_address3;
        public String receiver_city;
    }

    public class DeliveryStatus {

        public String status;
        public String pod_receiver;
        public String pod_date;
        public String pod_time;

    }

    public class Manifest {
        public String getCityName() {
            return city_name;
        }

        public String getDate() {
            return manifest_date;
        }

        public String getDescription() {
            return manifest_description;
        }

        public String getCode() {
            return manifest_code;
        }

        public String getTime() {
            return manifest_time;
        }

        public String city_name;
        public String manifest_date;
        public String manifest_description;
        public String manifest_code;
        public String manifest_time;
    }
}
