package com.utils;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.design.widget.Snackbar;
import android.support.v4.app.FragmentActivity;
import android.support.v4.content.FileProvider;
import android.view.View;

import com.twist.dataengine.DataEngine;;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.twist.tmstore.fragments.ImageChooserBottomSheetDialog;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import pl.tajchert.nammu.Nammu;
import pl.tajchert.nammu.PermissionCallback;


/**
 * Created by Twist Mobile on 10/31/2017.
 */

public class ImageUpload {

    public static final int REQUEST_IMAGE_CAPTURE = 1045;
    public static final int PICK_PHOTO_CODE = 1046;

    private static final int UPLOAD_IMG_WIDTH = 512;
    private static final int UPLOAD_IMG_HEIGHT = 512;

    View rootView;
    Activity mContext;
    public String mCurrentPhotoPath;

    public ImageUpload(View rootView, Activity context) {
        this.rootView = rootView;
        this.mContext = context;
    }

    final PermissionCallback permissionCameraCallback = new PermissionCallback() {
        @Override
        public void permissionGranted() {
            takeCameraPicture();
        }

        @Override
        public void permissionRefused() {
            Snackbar.make(rootView, L.getString(L.string.you_need_to_allow_permission),
                    Snackbar.LENGTH_INDEFINITE)
                    .setAction(L.getString(L.string.ok), new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            Nammu.askForPermission((Activity) mContext, Manifest.permission.CAMERA, permissionCameraCallback);
                        }
                    }).show();
        }
    };

    private void dispatchTakePictureIntent() {
        if (Nammu.checkPermission(Manifest.permission.CAMERA)) {
            takeCameraPicture();
        } else {
            if (Nammu.shouldShowRequestPermissionRationale((Activity) mContext, Manifest.permission.CAMERA)) {
                Snackbar.make(rootView, L.getString(L.string.you_need_to_allow_permission), Snackbar.LENGTH_INDEFINITE)
                        .setAction(L.getString(L.string.ok), new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                Nammu.askForPermission((Activity) mContext, Manifest.permission.CAMERA, permissionCameraCallback);
                            }
                        }).show();
            } else {
                Nammu.askForPermission((Activity) mContext, Manifest.permission.CAMERA, permissionCameraCallback);
            }
        }
    }

    public void uploadImage(Bitmap originalBitmap, final ImageUploadListner imageUploadListner) {
        int w = UPLOAD_IMG_WIDTH;
        int h = UPLOAD_IMG_HEIGHT;
        float width = originalBitmap.getWidth();
        float height = originalBitmap.getHeight();
        if (width >= height) {
            w = (int) (UPLOAD_IMG_WIDTH * (width / height));
        } else {
            h = (int) (UPLOAD_IMG_HEIGHT * (height / width));
        }
        Bitmap scaledBitmap = Bitmap.createScaledBitmap(originalBitmap, w, h, false);
        ImageUploadTask imageUploadTask = new ImageUploadTask(new ImageUploadTask.ResponseListener() {
            @Override
            public void onResponse(String status, String url, String message) {
                if (status.equalsIgnoreCase("success")) {
                    imageUploadListner.UploadSuccess(url);
                } else {
                    Log.d("Image Upload Error: [" + message + "]");
                }
            }
        });
        String url = DataEngine.getDataEngine().url_image_upload;
        imageUploadTask.execute(url, scaledBitmap);
    }

    private File createImageFile() throws IOException {
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String imageFileName = "JPEG_" + timeStamp + "_";
        File storageDir = mContext.getExternalFilesDir(Environment.DIRECTORY_PICTURES);
        File image = File.createTempFile(
                imageFileName,  /* prefix */
                ".jpg",         /* suffix */
                storageDir      /* directory */
        );
        mCurrentPhotoPath = image.getAbsolutePath();
        return image;
    }

    private void takeCameraPicture() {
        Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        if (takePictureIntent.resolveActivity(mContext.getPackageManager()) != null) {
            File photoFile = null;
            try {
                photoFile = createImageFile();
            } catch (IOException e) {
                e.printStackTrace();
            }
            if (photoFile != null) {
                String authority = mContext.getString(R.string.file_provider_authority);
                Uri photoUri = FileProvider.getUriForFile((Activity) mContext, authority, photoFile);
                if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.KITKAT) {
                    List<ResolveInfo> resolvedIntentActivities = mContext.getPackageManager().queryIntentActivities(takePictureIntent, PackageManager.MATCH_DEFAULT_ONLY);
                    for (ResolveInfo resolvedIntentInfo : resolvedIntentActivities) {
                        String packageName = resolvedIntentInfo.activityInfo.packageName;
                        mContext.grantUriPermission(packageName, photoUri, Intent.FLAG_GRANT_WRITE_URI_PERMISSION | Intent.FLAG_GRANT_READ_URI_PERMISSION);
                    }
                }
                takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, photoUri);
                ((Activity) mContext).startActivityForResult(takePictureIntent, REQUEST_IMAGE_CAPTURE);
            }
        }
    }

    public void selectImage() {
        FragmentActivity activity = (FragmentActivity) mContext;
        ImageChooserBottomSheetDialog.newInstance(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (v.getId() == R.id.camera_section) {
                    dispatchTakePictureIntent();
                } else if (v.getId() == R.id.gallery_section) {
                    onPickPhoto();
                }
            }
        }).show(activity.getSupportFragmentManager(), ImageChooserBottomSheetDialog.class.getSimpleName());
    }

    final PermissionCallback permissionExternalStorageCallback = new PermissionCallback() {
        @Override
        public void permissionGranted() {
            Intent intent = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
            if (intent.resolveActivity(((Activity) mContext).getPackageManager()) != null) {
                ((Activity) mContext).startActivityForResult(intent, PICK_PHOTO_CODE);
            }
        }

        @Override
        public void permissionRefused() {
            Snackbar.make(rootView, L.getString(L.string.you_need_to_allow_permission),
                    Snackbar.LENGTH_INDEFINITE)
                    .setAction(L.getString(L.string.ok), new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            Nammu.askForPermission(((Activity) mContext), Manifest.permission.WRITE_EXTERNAL_STORAGE, permissionExternalStorageCallback);
                        }
                    }).show();
        }
    };

    public void onPickPhoto() {
        if (!Nammu.checkPermission(android.Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
            Nammu.askForPermission(((Activity) mContext), Manifest.permission.WRITE_EXTERNAL_STORAGE, permissionExternalStorageCallback);
        } else {
            Intent intent = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
            if (intent.resolveActivity(((Activity) mContext).getPackageManager()) != null) {
                ((Activity) mContext).startActivityForResult(intent, PICK_PHOTO_CODE);
            }
        }
    }

    public interface ImageUploadListner {
        void UploadSuccess(String url);
    }
}
