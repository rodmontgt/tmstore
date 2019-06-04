package com.utils.glide;

import android.content.Context;

import com.bumptech.glide.Glide;
import com.bumptech.glide.GlideBuilder;
import com.bumptech.glide.load.DecodeFormat;
import com.bumptech.glide.load.model.GlideUrl;
import com.bumptech.glide.module.GlideModule;
import com.twist.tmstore.entities.AppInfo;

import java.io.InputStream;

import com.twist.oauth.libs.okhttp.UnsafeOkHttpClient;
import okhttp3.OkHttpClient;

public class UnsafeOkHttpGlideModule implements GlideModule {
    @Override
    public void applyOptions(Context context, GlideBuilder builder) {
        if(AppInfo.SHOW_CATEGORY_BANNER_FULL) {
            builder.setDecodeFormat(DecodeFormat.PREFER_ARGB_8888);
        }
    }

    @Override
    public void registerComponents(Context context, Glide glide) {
        OkHttpClient client = UnsafeOkHttpClient.getUnsafeOkHttpClient();
        glide.register(GlideUrl.class, InputStream.class, new OkHttpUrlLoader.Factory(client));
    }
}