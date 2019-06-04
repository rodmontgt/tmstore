package com.twist.tmstore.multistore;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.hardware.Camera;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.Snackbar;
import android.support.v13.app.ActivityCompat;
import android.support.v7.app.AppCompatActivity;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.ScaleGestureDetector;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Toast;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.common.api.CommonStatusCodes;
import com.google.android.gms.vision.Detector;
import com.google.android.gms.vision.MultiProcessor;
import com.google.android.gms.vision.Tracker;
import com.google.android.gms.vision.barcode.Barcode;
import com.google.android.gms.vision.barcode.BarcodeDetector;
import com.twist.tmstore.R;
import com.twist.tmstore.multistore.vision.CameraSource;
import com.twist.tmstore.multistore.vision.CameraSourcePreview;
import com.twist.tmstore.multistore.vision.GraphicOverlay;
import com.utils.Log;

import java.io.IOException;


public class BarcodeReaderActivity extends AppCompatActivity {

    // intent request code to handle updating play services if needed.
    private static final int RC_HANDLE_GMS = 9001;

    // permission request codes need to be < 256
    private static final int RC_HANDLE_CAMERA_PERM = 2;

    // constants used to pass extra data in the intent
    public static final String AutoFocus = "AutoFocus";
    public static final String UseFlash = "UseFlash";
    public static final String BarcodeObject = "Barcode";

    private CameraSource mCameraSource;
    private CameraSourcePreview mPreview;
    private GraphicOverlay<BarcodeGraphic> mGraphicOverlay;

    // helper objects for detecting taps and pinches.
    private ScaleGestureDetector scaleGestureDetector;
    private GestureDetector gestureDetector;

    @Override
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Window window = getWindow();
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(Color.parseColor("#00ffffff"));
        }
        //hideStatusBar();
        setContentView(R.layout.activity_barcode_reader);
        mPreview = (CameraSourcePreview) findViewById(R.id.preview);
        mGraphicOverlay = (GraphicOverlay<BarcodeGraphic>) findViewById(R.id.graphicOverlay);

        // read parameters from the intent used to launch the activity.
        boolean autoFocus = getIntent().getBooleanExtra(AutoFocus, false);
        boolean useFlash = getIntent().getBooleanExtra(UseFlash, false);

        // Check for the camera permission before accessing the camera.  If the
        // permission is not granted yet, request permission.
        int rc = ActivityCompat.checkSelfPermission(this, Manifest.permission.CAMERA);
        if (rc == PackageManager.PERMISSION_GRANTED) {
            createCameraSource(autoFocus, useFlash);
        } else {
            requestCameraPermission();
        }

        gestureDetector = new GestureDetector(this, new CaptureGestureListener());
        scaleGestureDetector = new ScaleGestureDetector(this, new ScaleListener());
    }

    void hideStatusBar() {
        View decorView = getWindow().getDecorView();
        int uiOptions = View.SYSTEM_UI_FLAG_FULLSCREEN;
        decorView.setSystemUiVisibility(uiOptions);
    }

    private void requestCameraPermission() {
        Log.w("Camera permission is not granted. Requesting permission");

        final String[] permissions = new String[]{android.Manifest.permission.CAMERA};

        if (!ActivityCompat.shouldShowRequestPermissionRationale(this,
                android.Manifest.permission.CAMERA)) {
            ActivityCompat.requestPermissions(this, permissions, RC_HANDLE_CAMERA_PERM);
            return;
        }

        final Activity activity = this;

        View.OnClickListener listener = new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                ActivityCompat.requestPermissions(activity, permissions,
                        RC_HANDLE_CAMERA_PERM);
            }
        };

        findViewById(R.id.topLayout).setOnClickListener(listener);
        Snackbar.make(mGraphicOverlay, R.string.permission_camera_rationale,
                Snackbar.LENGTH_INDEFINITE)
                .setAction(R.string.ok, listener)
                .show();
    }

    @Override
    public boolean onTouchEvent(MotionEvent e) {
        boolean b = scaleGestureDetector.onTouchEvent(e);
        boolean c = gestureDetector.onTouchEvent(e);
        return b || c || super.onTouchEvent(e);
    }

    @SuppressLint("InlinedApi")
    private void createCameraSource(boolean autoFocus, boolean useFlash) {
        Context context = getApplicationContext();

        // A barcode detector is created to track barcodes.  An associated multi-processor instance
        // is set to receive the barcode detection results, track the barcodes, and maintain
        // graphics for each barcode on screen.  The factory is used by the multi-processor to
        // create a separate tracker instance for each barcode.
        BarcodeDetector barcodeDetector = new BarcodeDetector.Builder(context).build();
        BarcodeTrackerFactory barcodeFactory = new BarcodeTrackerFactory(mGraphicOverlay, new BarcodeAutoDetectionListener() {
            @Override
            public void onNewBarcodeDetection(Barcode barcode) {
                if (barcode != null) {
                    Intent data = new Intent();
                    data.putExtra(BarcodeObject, barcode.displayValue);
                    setResult(CommonStatusCodes.SUCCESS, data);
                    finish();
                }
                Log.d("BarcodeDetected", barcode.displayValue);
            }
        });

        barcodeDetector.setProcessor(
                new MultiProcessor.Builder<>(barcodeFactory).build());

        if (!barcodeDetector.isOperational()) {
            // Note: The first time that an app using the barcode or face API is installed on a
            // device, GMS will download a native libraries to the device in order to do detection.
            // Usually this completes before the app is run for the first time.  But if that
            // download has not yet completed, then the above call will not detect any barcodes
            // and/or faces.
            //
            // isOperational() can be used to check if the required native libraries are currently
            // available.  The detectors will automatically become operational once the library
            // downloads complete on device.
            Log.w("Detector dependencies are not yet available.");

            // Check for low storage.  If there is low storage, the native library will not be
            // downloaded, so detection will not become operational.
            IntentFilter lowStorageFilter = new IntentFilter(Intent.ACTION_DEVICE_STORAGE_LOW);
            boolean hasLowStorage = registerReceiver(null, lowStorageFilter) != null;

            if (hasLowStorage) {
                Toast.makeText(this, R.string.low_storage_error, Toast.LENGTH_LONG).show();
                Log.w(getString(R.string.low_storage_error));
            }
        }

        // Creates and starts the camera.  Note that this uses a higher resolution in comparison
        // to other detection examples to enable the barcode detector to detect small barcodes
        // at long distances.
        CameraSource.Builder builder = new CameraSource.Builder(getApplicationContext(), barcodeDetector)
                .setFacing(CameraSource.CAMERA_FACING_BACK)
                .setRequestedPreviewSize(1600, 1224)
                .setRequestedFps(15.0f);
        // make sure that auto focus is an available option
        builder = builder.setFocusMode(Camera.Parameters.FOCUS_MODE_CONTINUOUS_PICTURE);
        mCameraSource = builder.setFlashMode(Camera.Parameters.FLASH_MODE_AUTO)
                .build();
    }

    @Override
    protected void onResume() {
        super.onResume();
        startCameraSource();
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (mPreview != null) {
            mPreview.stop();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mPreview != null) {
            mPreview.release();
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        if (requestCode != RC_HANDLE_CAMERA_PERM) {
            Log.d("Got unexpected permission result: " + requestCode);
            super.onRequestPermissionsResult(requestCode, permissions, grantResults);
            return;
        }

        if (grantResults.length != 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            Log.d("Camera permission granted - initialize the camera source");
            // we have permission, so create the camerasource
            boolean autoFocus = getIntent().getBooleanExtra(AutoFocus, false);
            boolean useFlash = getIntent().getBooleanExtra(UseFlash, false);
            createCameraSource(autoFocus, useFlash);
            return;
        }

        Log.e("Permission not granted: results len = " + grantResults.length +
                " Result code = " + (grantResults.length > 0 ? grantResults[0] : "(empty)"));
    }


    private void startCameraSource() throws SecurityException {
        // check that the device has play services available.
        int code = GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(
                getApplicationContext());
        if (code != ConnectionResult.SUCCESS) {
            Dialog dlg =
                    GoogleApiAvailability.getInstance().getErrorDialog(this, code, RC_HANDLE_GMS);
            dlg.show();
        }

        if (mCameraSource != null) {
            try {
                mPreview.start(mCameraSource, mGraphicOverlay);
            } catch (IOException e) {
                Log.e("Unable to start camera source.");
                mCameraSource.release();
                mCameraSource = null;
            }
        }
    }

    private boolean onTap(float rawX, float rawY) {
        // Find tap point in preview frame coordinates.
        int[] location = new int[2];
        mGraphicOverlay.getLocationOnScreen(location);
        float x = (rawX - location[0]) / mGraphicOverlay.getWidthScaleFactor();
        float y = (rawY - location[1]) / mGraphicOverlay.getHeightScaleFactor();

        // Find the barcode whose center is closest to the tapped point.
        Barcode best = null;
        float bestDistance = Float.MAX_VALUE;
        for (BarcodeGraphic graphic : mGraphicOverlay.getGraphics()) {
            Barcode barcode = graphic.getBarcode();
            if (barcode.getBoundingBox().contains((int) x, (int) y)) {
                // Exact hit, no need to keep looking.
                best = barcode;
                break;
            }
            float dx = x - barcode.getBoundingBox().centerX();
            float dy = y - barcode.getBoundingBox().centerY();
            float distance = (dx * dx) + (dy * dy);  // actually squared distance
            if (distance < bestDistance) {
                best = barcode;
                bestDistance = distance;
            }
        }

        if (best != null) {
            Intent data = new Intent();
            data.putExtra(BarcodeObject, best.displayValue);
            setResult(CommonStatusCodes.SUCCESS, data);
            finish();
            return true;
        }
        return false;
    }

    private class CaptureGestureListener extends GestureDetector.SimpleOnGestureListener {
        @Override
        public boolean onSingleTapConfirmed(MotionEvent e) {
            return onTap(e.getRawX(), e.getRawY()) || super.onSingleTapConfirmed(e);
        }
    }

    private class ScaleListener implements ScaleGestureDetector.OnScaleGestureListener {

        @Override
        public boolean onScale(ScaleGestureDetector detector) {
            return false;
        }

        @Override
        public boolean onScaleBegin(ScaleGestureDetector detector) {
            return true;
        }

        @Override
        public void onScaleEnd(ScaleGestureDetector detector) {
            mCameraSource.doZoom(detector.getScaleFactor());
        }
    }

    private class BarcodeGraphic extends GraphicOverlay.Graphic {

        private int mId;

        private final int COLOR_CHOICES[] = {
                Color.BLUE,
                Color.CYAN,
                Color.GREEN
        };

        private int mCurrentColorIndex = 0;

        private Paint mRectPaint;
        private Paint mTextPaint;
        private volatile Barcode mBarcode;

        BarcodeGraphic(GraphicOverlay overlay) {
            super(overlay);

            mCurrentColorIndex = (mCurrentColorIndex + 1) % COLOR_CHOICES.length;
            final int selectedColor = COLOR_CHOICES[mCurrentColorIndex];

            mRectPaint = new Paint();
            mRectPaint.setColor(selectedColor);
            mRectPaint.setStyle(Paint.Style.STROKE);
            mRectPaint.setStrokeWidth(4.0f);

            mTextPaint = new Paint();
            mTextPaint.setColor(selectedColor);
            mTextPaint.setTextSize(36.0f);
        }

        public int getId() {
            return mId;
        }

        public void setId(int id) {
            this.mId = id;
        }

        public Barcode getBarcode() {
            return mBarcode;
        }

        void updateItem(Barcode barcode) {
            mBarcode = barcode;
            postInvalidate();
        }

        @Override
        public void draw(Canvas canvas) {
            Barcode barcode = mBarcode;
            if (barcode == null) {
                return;
            }

            // Draws the bounding box around the barcode.
            RectF rect = new RectF(barcode.getBoundingBox());
            rect.left = translateX(rect.left);
            rect.top = translateY(rect.top);
            rect.right = translateX(rect.right);
            rect.bottom = translateY(rect.bottom);
            canvas.drawRect(rect, mRectPaint);

            // Draws a label at the bottom of the barcode indicate the barcode value that was detected.
            canvas.drawText(barcode.rawValue, rect.left, rect.bottom, mTextPaint);
        }
    }

    private class BarcodeGraphicTracker extends Tracker<Barcode> {
        private GraphicOverlay<BarcodeGraphic> mOverlay;
        private BarcodeGraphic mGraphic;
        private BarcodeAutoDetectionListener barcodeAutoDetectionListener;

        BarcodeGraphicTracker(GraphicOverlay<BarcodeGraphic> overlay, BarcodeGraphic graphic) {
            mOverlay = overlay;
            mGraphic = graphic;
        }

        /**
         * Start tracking the detected item instance within the item overlay.
         */
        @Override
        public void onNewItem(int id, Barcode item) {
            mGraphic.setId(id);
            if (barcodeAutoDetectionListener != null) {
                barcodeAutoDetectionListener.onNewBarcodeDetection(item);
            }
        }

        public void setNewDetectionListener(BarcodeAutoDetectionListener barcodeAutoDetectionListener) {
            this.barcodeAutoDetectionListener = barcodeAutoDetectionListener;
        }

        /**
         * Update the position/characteristics of the item within the overlay.
         */
        @Override
        public void onUpdate(Detector.Detections<Barcode> detectionResults, Barcode item) {
            mOverlay.add(mGraphic);
            mGraphic.updateItem(item);
        }

        @Override
        public void onMissing(Detector.Detections<Barcode> detectionResults) {
            mOverlay.remove(mGraphic);
        }

        @Override
        public void onDone() {
            mOverlay.remove(mGraphic);
        }
    }

    public interface BarcodeAutoDetectionListener {
        void onNewBarcodeDetection(Barcode barcode);
    }
    private class BarcodeTrackerFactory implements MultiProcessor.Factory<Barcode> {
        private GraphicOverlay<BarcodeGraphic> mGraphicOverlay;
        BarcodeAutoDetectionListener barcodeAutoDetectionListener;
        BarcodeTrackerFactory(GraphicOverlay<BarcodeGraphic> barcodeGraphicOverlay, BarcodeAutoDetectionListener barcodeAutoDetectionListener) {
            mGraphicOverlay = barcodeGraphicOverlay;
            this.barcodeAutoDetectionListener = barcodeAutoDetectionListener;
        }

        @Override
        public Tracker<Barcode> create(Barcode barcode) {
            BarcodeGraphic graphic = new BarcodeGraphic(mGraphicOverlay);
            BarcodeGraphicTracker tracker = new BarcodeGraphicTracker(mGraphicOverlay, graphic);
            if (barcodeAutoDetectionListener != null) {
                tracker.setNewDetectionListener(barcodeAutoDetectionListener);
            }
            return tracker;
        }
    }
}