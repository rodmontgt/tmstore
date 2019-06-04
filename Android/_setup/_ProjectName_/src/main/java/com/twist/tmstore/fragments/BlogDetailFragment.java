package com.twist.tmstore.fragments;


import android.os.Bundle;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebView;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.twist.dataengine.entities.BlogItem;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.utils.CContext;
import com.utils.Helper;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Created by Twist Mobile on 10/25/2017.
 */

public class BlogDetailFragment extends BaseFragment {

    private BlogItem blogItem;

    public static BlogDetailFragment newInstance(BlogItem blogItem) {
        BlogDetailFragment fragment = new BlogDetailFragment();
        fragment.blogItem = blogItem;
        return fragment;
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_blog_detail, container, false);
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        setTitle(blogItem.getPostTitle());
        setActionBarHomeAsUpIndicator();
        getBaseActivity().restoreActionBar();
        TextView blogTitleTextView = (TextView) view.findViewById(R.id.text_blog_title);
        TextView text_blog_author_date = (TextView) view.findViewById(R.id.text_blog_author_date);
        ImageView featuredImageView = (ImageView) view.findViewById(R.id.image_view_featured);
        WebView descriptionWebView = (WebView) view.findViewById(R.id.web_view_description);
        if (blogItem != null) {
            blogTitleTextView.setText(blogItem.getPostTitle());

            if (!TextUtils.isEmpty(blogItem.getFeaturedImage())) {
                Glide.with(getActivity()).load(blogItem.getFeaturedImage())
                        .placeholder(R.drawable.placeholder_banner)
                        .error(R.drawable.placeholder_banner)
                        .centerCrop()
                        .into(featuredImageView);
            } else {
                featuredImageView.setVisibility(View.GONE);
            }
            String authorDateText = "";
            if (!TextUtils.isEmpty(blogItem.getPostAuthor())) {
                authorDateText = getString(L.string.posted_by) + " " + blogItem.getPostAuthor();
            }
            if (!TextUtils.isEmpty(blogItem.getPostDate())) {
                text_blog_author_date.setVisibility(View.VISIBLE);
                SimpleDateFormat dateFormat1 = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                SimpleDateFormat dateFormat2 = new SimpleDateFormat("MMMM dd, yyyy");
                Date convertedDate;
                try {
                    convertedDate = dateFormat1.parse(blogItem.getPostDate());
                    String date = dateFormat2.format(convertedDate);
                    authorDateText = authorDateText + ", " + date;
                } catch (ParseException e) {
                    e.printStackTrace();
                }
            }
            if (!TextUtils.isEmpty(authorDateText)) {
                text_blog_author_date.setText(authorDateText);
            } else {
                text_blog_author_date.setVisibility(View.GONE);
            }

            descriptionWebView.getSettings().setLoadsImagesAutomatically(true);
            descriptionWebView.getSettings().setJavaScriptEnabled(true);
            descriptionWebView.setScrollBarStyle(View.SCROLLBARS_INSIDE_OVERLAY);
            descriptionWebView.setVisibility(View.VISIBLE);
            descriptionWebView.loadDataWithBaseURL(
                    null,
                    Helper.appendDiv(blogItem.getPostContent(), CContext.getColor(getActivity(), R.color.white), CContext.getColor(getActivity(), R.color.normal_text_color)),
                    "text/html",
                    "UTF-8",
                    null
            );
        }
    }
}
