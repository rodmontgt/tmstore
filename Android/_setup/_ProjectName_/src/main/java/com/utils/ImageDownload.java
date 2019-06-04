package com.utils;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.DialogInterface;
import android.os.AsyncTask;
import android.os.Environment;
import android.support.v7.app.AlertDialog;
import android.text.TextUtils;

import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.L;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.URL;
import java.net.URLConnection;
import java.text.SimpleDateFormat;
import java.util.Date;

import pl.tajchert.nammu.Nammu;
import pl.tajchert.nammu.PermissionCallback;

import static com.twist.tmstore.L.getString;


public class ImageDownload {

    public static void ImageDownloadTask(final Context context, final String url, final String catName, final String prodName, final String wishGroup) {
        final String[] params = {url, catName, prodName, wishGroup};
        if (!Nammu.checkPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
            Nammu.askForPermission((Activity) context, Manifest.permission.WRITE_EXTERNAL_STORAGE, new PermissionCallback() {
                @Override
                public void permissionGranted() {
                    new ImageDownloadTask(context).execute(params);
                }

                @Override
                public void permissionRefused() {
                    Helper.toast(L.string.image_download_error);
                }
            });
        } else {
            new ImageDownloadTask(context).execute(params);
        }
    }

    public static void downloadProductCatalog(Context context, TM_ProductInfo product) {
        for (String url : product.getImageUrls()) {
            String prodName = product.sku != null && !TextUtils.isEmpty(product.sku) ? product.sku : product.title;
            ImageDownloadTask(context, url, product.getCategoryName(), prodName, "");
        }
    }

    public static void downloadWishListGroupProductCatalog(Context context, TM_ProductInfo productInfo, String wishListGroupTitle) {
        for (String url : productInfo.getImageUrls()) {
            String prodName = productInfo.title;
            if (!TextUtils.isEmpty(productInfo.sku))
                prodName = productInfo.sku;
            ImageDownload.ImageDownloadTask(context, url, productInfo.getCategoryName(), prodName, wishListGroupTitle);
        }
    }

    private static class ImageDownloadTask extends AsyncTask<String, Integer, Boolean> {
        private Context mContext;
        private String appName = Helper.getApplicationName();

        ImageDownloadTask(Context context) {
            mContext = context;
        }

        @Override
        protected Boolean doInBackground(String... params) {
            int count;
            try {
                final URL url = new URL(params[0]);
                //String catName = params[1];
                String prodName = params[2];
                String wishGroup = params[3];
                //catName = catName.replaceAll("/", "_");
                //prodName = prodName.replaceAll("/", "_");
                prodName = prodName.substring(0, Math.min(prodName.length(), 4));
                appName = appName.replaceAll(" ", "");
                if (!Helper.isValidString(prodName)) {
                    SimpleDateFormat formatter = new SimpleDateFormat("yyyy_MM_dd_HH_mm_ss");
                    Date now = new Date();
                    prodName = formatter.format(now);
                }

                URLConnection connection = url.openConnection();
                connection.connect();

                final String targetFileName = prodName + ".jpg"; //Change name and sub name
                //int fileLength = connection.getContentLength();

                String path = Environment.getExternalStorageDirectory() + "/" + appName + "/";
                if (wishGroup.compareTo("") != 0)
                    path = path + wishGroup + "/";

                final File folder = new File(path);
                InputStream input = new BufferedInputStream(url.openStream());
                if (!folder.exists()) {
                    folder.mkdirs();
                }
                File outputFile = new File(folder, targetFileName);
                FileOutputStream output = new FileOutputStream(outputFile);
                byte data[] = new byte[1024];
                long total = 0;
                while ((count = input.read(data)) != -1) {
                    total += count;
                    //publishProgress((int) (total * 100 / fileLength));
                    output.write(data, 0, count);
                }
                output.flush();
                output.close();
                input.close();
                return true;
            } catch (Exception e) {
                e.printStackTrace();
            }
            return false;
        }

        protected void onPostExecute(Boolean result) {
            if (mContext != null) {
                if (result) {
                    Helper.toast(L.string.image_download_success);
                } else {
                    AlertDialog.Builder builder = new AlertDialog.Builder(mContext);
                    builder.setTitle(getString(L.string.restart_app_dialog_title));
                    builder.setMessage(getString(L.string.restart_app_confirm_msg));
                    builder.setPositiveButton(getString(L.string.button_reload), new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int whichButton) {
                            dialog.dismiss();
                        }
                    });
                    builder.setNegativeButton(getString(L.string.button_later), new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int whichButton) {
                            dialog.cancel();
                        }
                    });
                    builder.show();
                }
            } else {
                Helper.toast(L.string.image_download_error);
            }
            cancel(true);
        }
    }
}