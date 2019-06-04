package com.twist.tmstore.listeners;

public interface TaskListener {
    void onTaskDone();

    void onTaskFailed(String error);
}
