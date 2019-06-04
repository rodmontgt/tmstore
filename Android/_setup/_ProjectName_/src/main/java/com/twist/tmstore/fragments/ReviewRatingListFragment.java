package com.twist.tmstore.fragments;

import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;

import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.dataengine.entities.TM_ProductReview;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.Adapter_ProductReviewsList;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.listeners.BackKeyListener;
import com.utils.CContext;
import com.utils.Helper;
import com.utils.customviews.progressbar.CircleProgressBar;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 7/18/2017.
 */

public class ReviewRatingListFragment extends BaseFragment {

    private View rootView;
    private ListView layout_reviews;
    private CircleProgressBar progressReviewData;
    private TM_ProductInfo productInfo;

    private List<TM_ProductReview> productReviews = new ArrayList<>();

    public static ReviewRatingListFragment newInstance() {
        return new ReviewRatingListFragment();
    }

    public static ReviewRatingListFragment newInstance(TM_ProductInfo productInfo, List<TM_ProductReview> productReviews) {
        ReviewRatingListFragment reviewRatingListFragment = new ReviewRatingListFragment();
        reviewRatingListFragment.productInfo = productInfo;
        reviewRatingListFragment.productReviews = productReviews;
        return reviewRatingListFragment;
    }

    public ReviewRatingListFragment() {
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (productReviews != null && productReviews.size() > 0) {
            productInfo = TM_ProductInfo.findProductById(productInfo.id);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        rootView = inflater.inflate(R.layout.fragment_review_rating_list, container, false);
        setActionBarHomeAsUpIndicator();
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setHomeButtonEnabled(true);
            actionBar.setDisplayHomeAsUpEnabled(true);

            Drawable upArrow = CContext.getDrawable(getActivity(), R.drawable.abc_ic_ab_back_material);
            upArrow.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_ATOP);
            actionBar.setHomeAsUpIndicator(upArrow);
        }
        getBaseActivity().restoreActionBar();

        layout_reviews = (ListView) rootView.findViewById(R.id.layout_reviews);
        progressReviewData = (CircleProgressBar) rootView.findViewById(R.id.progress_reviewdata);
        Helper.stylize(progressReviewData);
        if (!TextUtils.isEmpty(productInfo.title)) {
            setTitle(productInfo.title);
        }

        if (productReviews != null && productReviews.size() > 0) {
            Adapter_ProductReviewsList productReviewAdapter = new Adapter_ProductReviewsList(getActivity(), productReviews);
            layout_reviews.setAdapter(productReviewAdapter);
        } else {
            loadComments();
        }

        addBackKeyListenerOnView(rootView, new BackKeyListener() {
            @Override
            public void onBackPressed() {
                getSupportFM().popBackStack();
            }
        });

        return rootView;
    }

    private void loadComments() {
        productReviews.clear();
        if (productInfo.id == 0) {
            return;
        }
        progressReviewData.setVisibility(View.VISIBLE);
        DataEngine.getDataEngine().getCommentOnProductInBackground(productInfo.id, new DataQueryHandler<List<TM_ProductReview>>() {
            @Override
            public void onSuccess(final List<TM_ProductReview> data) {
                productReviews = data;
                progressReviewData.setVisibility(View.GONE);
                Adapter_ProductReviewsList productReviewAdapter = new Adapter_ProductReviewsList(getActivity(), productReviews);
                layout_reviews.setAdapter(productReviewAdapter);
            }

            @Override
            public void onFailure(Exception exception) {
                progressReviewData.setVisibility(View.GONE);
                exception.printStackTrace();
                Helper.showToast(rootView, exception.getMessage());
            }
        });
    }
}
