package com.twist.tmstore.listeners;

public interface DataTaskListener<T> {
    void onTaskDone(T data);

    void onTaskFailed(String error);
}
