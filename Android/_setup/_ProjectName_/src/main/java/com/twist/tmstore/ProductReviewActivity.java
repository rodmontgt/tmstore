package com.twist.tmstore;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Point;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.design.widget.TextInputLayout;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AlertDialog;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RatingBar;
import android.widget.TextView;

import com.daimajia.slider.library.SliderLayout;
import com.daimajia.slider.library.SliderTypes.BaseSliderView;
import com.daimajia.slider.library.SliderTypes.DefaultSliderView;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.utils.CContext;
import com.utils.Helper;
import com.utils.HtmlCompat;

import java.util.HashMap;
import java.util.Map;

public class ProductReviewActivity extends BaseActivity {

    private SliderLayout product_img_slider;

    private LinearLayout ratings_section;
    private RatingBar average_ratingBar;
    private TextView txt_rating;

    private TextView lable_user_ratings;
    private TextView lable_average_user_ratings;

    private TextInputLayout label_name;
    private TextInputLayout label_email;
    private TextInputLayout label_review_message;

    private EditText text_name;
    private EditText text_email;
    private EditText text_review_message;
    private RatingBar user_ratingBar;
    private Button btn_submit;

    private TM_ProductInfo productInfo;

    @Override
    protected void onActionBarRestored() {
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_product_review);

        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setHomeButtonEnabled(true);
            actionBar.setDisplayHomeAsUpEnabled(true);

            Drawable upArrow = CContext.getDrawable(this, R.drawable.abc_ic_ab_back_material);
            upArrow.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_ATOP);
            getSupportActionBar().setHomeAsUpIndicator(upArrow);
        }
        restoreActionBar();

        Intent intent = getIntent();
        if (getIntent() != null) {
            int productId = intent.getIntExtra(Extras.PRODUCT_ID, 0);
            productInfo = TM_ProductInfo.findProductById(productId);
        }
        setTitleText(productInfo.title);

        initProductSliderComponent();

        ratings_section = (LinearLayout) findViewById(R.id.ratings_section);
        lable_average_user_ratings = (TextView) findViewById(R.id.lable_average_user_ratings);
        lable_average_user_ratings.setText(getString(L.string.average_user_ratings));

        txt_rating = (TextView) findViewById(R.id.txt_rating);
        average_ratingBar = (RatingBar) findViewById(R.id.ratingBar1);
        Helper.stylize(average_ratingBar);

        if (AppInfo.mProductDetailsConfig.show_ratings_section) {
            ratings_section.setVisibility(View.VISIBLE);
            if (productInfo.average_rating > 0) {
                average_ratingBar.setVisibility(View.VISIBLE);
                txt_rating.setVisibility(View.VISIBLE);
                average_ratingBar.setRating(productInfo.average_rating);
                average_ratingBar.setFocusable(false);
                txt_rating.setText(productInfo.average_rating + "/5.0");
            } else {
                average_ratingBar.setVisibility(View.GONE);
                average_ratingBar.setVisibility(View.VISIBLE);
                txt_rating.setText(getString(L.string.ratings_not_available));
            }
        } else {
            ratings_section.setVisibility(View.GONE);
        }

        label_name = ((TextInputLayout) findViewById(R.id.label_name));
        label_name.setHint(getString(L.string.name));
        Helper.stylize(label_name);
        label_email = ((TextInputLayout) findViewById(R.id.label_email));
        label_email.setHint(getString(L.string.email));
        Helper.stylize(label_email);
        label_review_message = ((TextInputLayout) findViewById(R.id.label_review_message));
        label_review_message.setHint(L.getString(L.string.hint_your_review));
        Helper.stylize(label_review_message);

        text_name = (EditText) findViewById(R.id.text_name);
        text_email = (EditText) findViewById(R.id.text_email);
        text_review_message = (EditText) findViewById(R.id.text_review_message);

        if (AppUser.hasSignedIn()) {
            text_name.setText(AppUser.getInstance().getDisplayName());
            text_email.setText(AppUser.getEmail());
        }

        user_ratingBar = (RatingBar) findViewById(R.id.user_ratingBar);
        user_ratingBar.setRating(0);
        user_ratingBar.setNumStars(5);
        user_ratingBar.setStepSize(0);
        user_ratingBar.setIsIndicator(false);

        btn_submit = (Button) findViewById(R.id.btn_submit);
        Helper.stylize(btn_submit);
        btn_submit.setText(L.getString(L.string.submit));
        btn_submit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                postReviewRating();
            }
        });
    }

    private void initProductSliderComponent() {
        product_img_slider = (SliderLayout) findViewById(R.id.product_img_slider);
        product_img_slider.stopAutoCycle();
        Helper.stylize(product_img_slider);

        Display display = this.getWindowManager().getDefaultDisplay();
        Point size = new Point();
        display.getSize(size);

        int windowHeight = (int) (AppInfo.PRODUCT_SLIDER_STANDARD_HEIGHT * size.x * 1.0f / AppInfo.PRODUCT_SLIDER_STANDARD_WIDTH);

        LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, windowHeight);
        product_img_slider.setLayoutParams(params);

        product_img_slider.setVisibility(AppInfo.mProductDetailsConfig.show_image_slider ? View.VISIBLE : View.GONE);
        updateSliderImages(productInfo.getImageUrls());

        TextView text_product_title = (TextView) findViewById(R.id.text_product_title);
        text_product_title.setText(HtmlCompat.fromHtml(productInfo.title));

        lable_user_ratings = (TextView) findViewById(R.id.lable_user_ratings);
        lable_user_ratings.setText(getString(L.string.lable_ratings));
    }

    private void updateSliderImages(String[] imageUrls) {
        int currentSlideCount = product_img_slider.getSlidesCount();
        if (currentSlideCount > imageUrls.length) {
            for (int i = imageUrls.length - 1; i < currentSlideCount; i++) {
                product_img_slider.removeSliderAt(0);
            }
            currentSlideCount = product_img_slider.getSlidesCount();
        }

        for (int i = 0; i < imageUrls.length; i++) {
            if (i >= currentSlideCount) {
                addNewSlider(i, imageUrls[i]);
                currentSlideCount++;
            } else {
                updateSliderImage(i, imageUrls[i]);
            }
        }
    }

    private void addNewSlider(final int index, final String img_url) {
        if (img_url != null && !img_url.equals("")) {
            DefaultSliderView sliderView = new DefaultSliderView(this);
            sliderView.description("").image(img_url).empty(AppInfo.ID_PLACEHOLDER_BANNER).setScaleType(BaseSliderView.ScaleType.CenterInside);
            sliderView.getBundle().putString("extra", img_url);
            product_img_slider.addSlider(index, sliderView);
        }
    }

    private void updateSliderImage(int index, String img_url) {
        if (img_url != null && !img_url.equals("")) {
            DefaultSliderView slide = (DefaultSliderView) product_img_slider.getSlideAt(index);
            if (slide != null) {
                slide.setUrl(img_url);
                product_img_slider.notifyDataSetChanged();
            }
        }
    }

    private void postReviewRating() {
        String name = text_name.getText().toString().trim();
        String email = text_email.getText().toString().trim();
        String message = text_review_message.getText().toString().trim();

        if (!Helper.isValidString(message)) {
            setErrorText(text_review_message, getString(L.string.invalid_review_message));
            return;
        }

        if (!Helper.isValidString(name)) {
            setErrorText(text_name, getString(L.string.invalid_name));
            return;
        }
        if (!android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
            setErrorText(text_email, getString(L.string.invalid_email));
            return;
        }

        float rating = user_ratingBar.getRating();

        if (rating <= 0) {
            Helper.showToast(getString(L.string.invalid_rating));
            return;
        }

        Map<String, String> params = new HashMap<>();
        params.put("user_name", name);
        params.put("user_email", email);
        params.put("userid", String.valueOf(AppUser.getUserId()));
        params.put("product_id", String.valueOf(productInfo.id));
        params.put("rating", String.valueOf(rating));
        params.put("comment", message);
        showProgress(getString(L.string.please_wait));
        DataEngine.getDataEngine().postReviewRatingInBackground(params, new DataQueryHandler<String>() {
            @Override
            public void onSuccess(String data) {
                Helper.showToast(data);
                hideProgress();
                showDialog(ProductReviewActivity.this, getString(L.string.review_dialog_title), getString(L.string.review_dialog_msg));
            }

            @Override
            public void onFailure(Exception error) {
                hideProgress();
                Helper.showToast(getString(L.string.error_failed_to_submit_review));
            }
        });
    }

    private void setErrorText(EditText editText, String error) {
        editText.setError(error);
        requestFocus(editText);
    }

    protected void requestFocus(View view) {
        if (view != null && view.requestFocus()) {
            getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_VISIBLE);
        }
    }

    public void showDialog(final Activity activity, String headerTitle, String msg) {
        AlertDialog.Builder builder = new AlertDialog.Builder(activity);
        View view = LayoutInflater.from(activity).inflate(R.layout.dialog_cod_otp, null);

        LinearLayout header_box = (LinearLayout) view.findViewById(R.id.header_box);
        header_box.setBackgroundColor(Color.parseColor(AppInfo.color_theme));
        TextView header_msg = (TextView) view.findViewById(R.id.header_msg);
        Helper.stylizeActionBar(header_msg);
        ImageView iv_close = (ImageView) view.findViewById(R.id.iv_close);
        Helper.stylizeActionBar(iv_close);

        header_msg.setText(headerTitle);

        TextView txt_msg = (TextView) view.findViewById(R.id.txt_msg);
        txt_msg.setText(msg);

        Button btn_ok = (Button) view.findViewById(R.id.btn_ok);
        Helper.stylize(btn_ok);

        builder.setView(view).setCancelable(false);
        final AlertDialog alertDialog = builder.create();

        btn_ok.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Helper.hideKeyboard(view);
                MainActivity.mActivity.openProductInfo(productInfo);
                finish();
                alertDialog.dismiss();
            }
        });

        iv_close.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Helper.hideKeyboard(v);
                alertDialog.dismiss();

            }
        });
        alertDialog.show();
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

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        finish();
    }
}
