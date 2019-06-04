package com.twist.tmstore;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ProgressBar;

import com.alexvasilkov.gestures.views.GestureImageView;
import com.bumptech.glide.Glide;
import com.bumptech.glide.request.animation.GlideAnimation;
import com.bumptech.glide.request.target.SimpleTarget;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.entities.AppInfo;
import com.utils.CContext;
import com.utils.Helper;
import com.viewpagerindicator.CirclePageIndicator;

/**
 * Created by Twist Mobile on 11/18/2016.
 */

public class ProductImagesActivity extends AppCompatActivity {

    ViewPager viewPager;
    ProgressBar mProgressBar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        supportRequestWindowFeature(Window.FEATURE_ACTION_BAR_OVERLAY);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
        }
        ActionBar actionBar = this.getSupportActionBar();
        if (actionBar != null) {
            actionBar.setHomeButtonEnabled(true);
            actionBar.setDisplayHomeAsUpEnabled(true);
            actionBar.setDisplayShowTitleEnabled(false);
            ColorDrawable newColor = new ColorDrawable(CContext.getColor(this, android.R.drawable.screen_background_light_transparent));//your color from res
            newColor.setAlpha(0);
            actionBar.setBackgroundDrawable(newColor);
            Drawable upArrow = CContext.getDrawable(this, R.drawable.abc_ic_ab_back_material);
            upArrow.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_ATOP);
            getSupportActionBar().setHomeAsUpIndicator(upArrow);
        }
        setContentView(R.layout.activity_product_images);

        mProgressBar = (ProgressBar) findViewById(R.id.progress_bar);
        mProgressBar.setVisibility(View.VISIBLE);
        Helper.stylize(mProgressBar);

        viewPager = (ViewPager) findViewById(R.id.view_pager);
        CirclePageIndicator indicator = (CirclePageIndicator) findViewById(R.id.indicator);
        Intent intent = getIntent();
        if (getIntent() != null) {
            int productId = intent.getIntExtra(Extras.PRODUCT_ID, 0);
            int index = intent.getIntExtra(Extras.PRODUCT_IMAGE_INDEX, 0);
            TM_ProductInfo productInfo = TM_ProductInfo.findProductById(productId);
            if (productInfo != null) {
                String[] imageUrls = productInfo.getImageUrls();
                if (imageUrls.length != 0) {
                    viewPager.setAdapter(new ImageArrayAdapter(this, imageUrls));
                    indicator.setViewPager(viewPager, 0);
                    viewPager.setCurrentItem(index);
                    indicator.setFillColor((Color.parseColor(AppInfo.normal_button_color)));
                }
            }
        }
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                finish();
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }

    private class ImageArrayAdapter extends PagerAdapter {

        private Context mContext;
        String[] image_array;

        ImageArrayAdapter(Context mContext, String[] image_array) {
            this.mContext = mContext;
            this.image_array = image_array;
        }

        @Override
        public int getCount() {
            return image_array.length;
        }

        @Override
        public boolean isViewFromObject(View view, Object object) {
            return view == object;
        }

        @Override
        public Object instantiateItem(ViewGroup container, int position) {

            final GestureImageView gestureImageView = new GestureImageView(ProductImagesActivity.this);
            gestureImageView.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT));
            gestureImageView.getController().getSettings().setZoomEnabled(true).enableGestures().setMaxZoom(10f).setFillViewport(true);
            gestureImageView.getController().enableScrollInViewPager(viewPager);
            Glide.with(mContext).load(image_array[position]).asBitmap().error(R.drawable.placeholder_product).into(new SimpleTarget<Bitmap>() {
                @Override
                public void onResourceReady(Bitmap resource, GlideAnimation<? super Bitmap> glideAnimation) {
                    gestureImageView.setImageBitmap(resource);
                    if (mProgressBar.getVisibility() == View.VISIBLE) {
                        mProgressBar.setVisibility(View.GONE);
                    }
                }
            });
            container.addView(gestureImageView);
            return gestureImageView;
        }

        @Override
        public void destroyItem(View container, int position, Object obj) {
            ((ViewPager) container).removeView((View) obj);
        }
    }
}
