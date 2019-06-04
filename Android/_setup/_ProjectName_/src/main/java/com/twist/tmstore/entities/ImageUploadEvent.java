package com.twist.tmstore.entities;

/**
 * Created by Twist Mobile on 08-12-2016.
 */

public class ImageUploadEvent {
    public  String url;
    public  String message;
    public  String status;


    public ImageUploadEvent(String status, String url,String message){
        this.status  = status;
        this.url = url;
        this.message = message;
    }
}
