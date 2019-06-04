package com.utils;

import android.graphics.Bitmap;
import android.os.AsyncTask;

import org.apache.http.HttpResponse;
import org.apache.http.HttpVersion;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.mime.HttpMultipartMode;
import org.apache.http.entity.mime.MultipartEntity;
import org.apache.http.entity.mime.content.StringBody;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.CoreProtocolPNames;
import org.apache.http.params.HttpParams;
import org.apache.http.util.EntityUtils;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;

/**
 * Created by Twist Mobile on 07-12-2016.
 */

public class ImageUploadTask extends AsyncTask<Object, Object, String> {

    private DefaultHttpClient mHttpClient;

    private ResponseListener responseListener;

    public interface ResponseListener {
        void onResponse(String status, String url, String message);
    }

    public ImageUploadTask(ResponseListener listener) {
        responseListener = listener;
        HttpParams params = new BasicHttpParams();
        params.setParameter(CoreProtocolPNames.PROTOCOL_VERSION, HttpVersion.HTTP_1_1);
        mHttpClient = new DefaultHttpClient(params);
    }

    @Override
    protected String doInBackground(Object... params) {
        String uploadResponse;
        try {
            HttpPost httppost = new HttpPost((String) params[0]);
            MultipartEntity multipartEntity = new MultipartEntity(HttpMultipartMode.BROWSER_COMPATIBLE);
            Long timeStamp = System.currentTimeMillis() / 1000;
            String fileName = timeStamp.toString() + ".png";
            multipartEntity.addPart("name", new StringBody(fileName));
            multipartEntity.addPart("image", new StringBody(Helper.bitmapToBase64((Bitmap) params[1])));
            httppost.setEntity(multipartEntity);
            uploadResponse = mHttpClient.execute(httppost, new PhotoUploadResponseHandler());
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
        return uploadResponse;
    }

    @Override
    protected void onPostExecute(String result) {
        super.onPostExecute(result);
        Log.d("Image upload response: " + result);
        String url = "";
        String message = "";
        String status = "";
        try {
            JSONObject jsonObject = new JSONObject(result);
            status = jsonObject.getString("status");
            url = jsonObject.getString("url");
            message = jsonObject.getString("message");
        } catch (JSONException e) {
            e.printStackTrace();
        }

        if (responseListener != null) {
            responseListener.onResponse(status, url, message);
        }
    }

    private class PhotoUploadResponseHandler implements ResponseHandler<String> {
        @Override
        public String handleResponse(HttpResponse response) throws IOException {
            return EntityUtils.toString(response.getEntity());
        }
    }
}