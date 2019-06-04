package com.twist.tmstore.entities;

/**
 * Created by Twist Mobile on 01/04/2018.
 */

public class ProductAddons {
    public Group group;
    public GroupAddon[] group_addon;

    public static class Group {
        public String id;
        public String name;
        public String user_id;
        public String products_id;
        public String categories_id;
        public String attributes_id;
        public String priority;
        public String visibility;
        public String reg_date;
        public String del;
        public String products_exclude_id;
    }

    public static class GroupAddon {
        public String id;
        public String group_id;
        public String type;
        public String label;
        public String image;
        public String description;
        public String depend;
        public Option[] options;
        public String required;
        public String sold_individually;
        public String step;
        public String priority;
        public String reg_date;
        public String del;
        public String max_item_selected;
        public String depend_variations;
        public String change_featured_image;
        public String calculate_quantity_sum;
        public String required_all_options;
        public String max_input_values_amount;
        public String min_input_values_amount;

        public static class Option {
            public String field_id;
            public String field_name;
            public String image;
            public String label;
            public String type;
            public String price;
            public String min;
            public String max;
            public String description;
            public boolean required;
            public String value;
        }
    }
}
