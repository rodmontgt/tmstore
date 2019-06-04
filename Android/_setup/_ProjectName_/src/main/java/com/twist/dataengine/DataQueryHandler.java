package com.twist.dataengine;

/**
 * Created by Twist Mobile on 12/30/2015.
 */
public interface DataQueryHandler<T> {
    void onSuccess(T data);
    void onFailure(Exception error);
}
