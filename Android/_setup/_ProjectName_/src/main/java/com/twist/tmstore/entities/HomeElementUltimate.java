package com.twist.tmstore.entities;

import java.util.Arrays;

/**
 * Created by Twist Mobile on 6/21/2016.
 */

public class HomeElementUltimate {

    public HomeElementUltimate() {
    }

    public int col;
    public int row;
    public int size_x;
    public int size_y;
    public int id;
    public Variable variables;

    public static class Variable {

        public Variable() {
        }

        public String tileType;
        public String tileTitle;
        public String tileType_Id;
        public TileStyle tileStyle;
        public TextStyle textStyle;
        public String bannerType;
        public String bannerFor;
        public int bannerCount;
        public String bannerIds;
        public String scrollerType;
        public String scrollerFor;
        public int scrollerLimit = -1;
        public int scrollerCount;
        public String scrollerIds;
        public Content[] content;

        public static class TileStyle {
            public int[] padding;
            public int[] margin;
            public String color;
            public String bgcolor;
            public String textbgcolor;
            public String bgUrl;
            public int scaletype = 1;
            public int fontsize;
            public int fontWeight;

            @Override
            public String toString() {
                return "TileStyle{" +
                        "padding=" + Arrays.toString(padding) +
                        ", margin=" + Arrays.toString(margin) +
                        ", color='" + color + '\'' +
                        ", bgcolor='" + bgcolor + '\'' +
                        ", textbgcolor='" + textbgcolor + '\'' +
                        ", bgUrl='" + bgUrl + '\'' +
                        ", scaletype=" + scaletype +
                        ", fontsize=" + fontsize +
                        ", fontWeight=" + fontWeight +
                        '}';
            }
        }

        public static class TextStyle {
            public String position;
            public String alignment;

            @Override
            public String toString() {
                return "TextStyle{" +
                        "position='" + position + '\'' +
                        ", alignment='" + alignment + '\'' +
                        '}';
            }
        }

        public static class Content {
            public int id;
            public int type;
            public String name;
            public String img;
            public int redirect_id;
            public String redirect;
            public String redirect_url;
            public String bgUrl;
            public String bgcolor;

            @Override
            public String toString() {
                return "Content{" +
                        "id=" + id +
                        ", type=" + type +
                        ", name='" + name + '\'' +
                        ", img='" + img + '\'' +
                        ", redirect_id=" + redirect_id +
                        ", redirect='" + redirect + '\'' +
                        ", redirect_url='" + redirect_url + '\'' +
                        ", bgUrl='" + bgUrl + '\'' +
                        ", bgcolor='" + bgcolor + '\'' +
                        '}';
            }
        }

        @Override
        public String toString() {
            return "Variable{" +
                    "tileType='" + tileType + '\'' +
                    ", tileTitle='" + tileTitle + '\'' +
                    ", tileType_Id='" + tileType_Id + '\'' +
                    ", tileStyle=" + tileStyle +
                    ", textStyle=" + textStyle +
                    ", bannerType='" + bannerType + '\'' +
                    ", bannerFor='" + bannerFor + '\'' +
                    ", bannerCount=" + bannerCount +
                    ", bannerIds='" + bannerIds + '\'' +
                    ", scrollerType='" + scrollerType + '\'' +
                    ", scrollerFor='" + scrollerFor + '\'' +
                    ", scrollerLimit=" + scrollerLimit +
                    ", scrollerCount=" + scrollerCount +
                    ", scrollerIds='" + scrollerIds + '\'' +
                    ", content=" + Arrays.toString(content) +
                    '}';
        }
    }

    @Override
    public String toString() {
        return "HomeElementUltimate{" +
                "col=" + col +
                ", row=" + row +
                ", size_x=" + size_x +
                ", size_y=" + size_y +
                ", id=" + id +
                ", variables=" + variables +
                '}';
    }
}
