package com.twist.tmstore.listeners;

import android.content.Intent;

public interface ActivityResultHandler {
    void onActivityResult(int requestCode, int resultCode, Intent data);
}
