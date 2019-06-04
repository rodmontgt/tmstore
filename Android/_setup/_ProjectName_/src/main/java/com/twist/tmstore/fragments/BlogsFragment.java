package com.twist.tmstore.fragments;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.twist.dataengine.entities.BlogItem;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.BlogAdapter;
import com.utils.Helper;

/**
 * Created by Twist Mobile on 10/25/2017.
 */

public class BlogsFragment extends BaseFragment {
    private RecyclerView recyclerView;
    private SwipeRefreshLayout swipeRefreshLayout;
    private ProgressBar progress;
    private BlogAdapter blogAdapter;
    private static boolean blogsLoaded = false;
    private View text_empty;

    public static BlogsFragment newInstance() {
        BlogsFragment fragment = new BlogsFragment();
        return fragment;
    }

    @Override
    public void onResume() {
        super.onResume();
        if (!blogsLoaded) {
            loadBlogs();
        }
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_blogs, container, false);
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        setActionBarHomeAsUpIndicator();
        setTitle(getString(L.string.title_news_feed));
        recyclerView = (RecyclerView) view.findViewById(R.id.recyclerView);
        progress = (ProgressBar) view.findViewById(R.id.progress);
        TextView new_feed_unavailable = (TextView) view.findViewById(R.id.new_feed_unavailable);
        new_feed_unavailable.setText(getString(L.string.new_feed_unavailable));
        text_empty = view.findViewById(R.id.text_empty);
        Helper.stylize(progress);
        progress.setVisibility(View.GONE);
        swipeRefreshLayout = (SwipeRefreshLayout) view.findViewById(R.id.swipeContainer);
        swipeRefreshLayout.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                swipeRefreshLayout.setRefreshing(true);
                loadBlogs();
            }
        });
        swipeRefreshLayout.setColorSchemeResources(
                android.R.color.holo_blue_bright,
                android.R.color.holo_green_light,
                android.R.color.holo_orange_light,
                android.R.color.holo_red_light);
        blogAdapter = new BlogAdapter(BlogItem.getAll());
        recyclerView.setAdapter(blogAdapter);
        blogAdapter.setOnBlogItemClickListener(new BlogAdapter.OnBlogItemClickListener() {
            @Override
            public void onClick(BlogItem blogItem) {
                loadSingleBlog(blogItem);
            }
        });
        getBaseActivity().restoreActionBar();
    }

    private void resetBlogSummary() {
        if (blogAdapter.getItemCount() > 0) {
            text_empty.setVisibility(View.GONE);
            recyclerView.setVisibility(View.VISIBLE);
            progress.setVisibility(View.GONE);
        } else {
            text_empty.setVisibility(View.VISIBLE);
            recyclerView.setVisibility(View.GONE);
            progress.setVisibility(View.GONE);
        }
    }

    private void loadSingleBlog(BlogItem blogItem) {
        MainActivity.mActivity.openBlogDetail(blogItem);
    }

    private void loadBlogs() {
        if (!blogsLoaded) {
            progress.setVisibility(View.VISIBLE);
        }
        DataEngine.getDataEngine().getBlogsInBackground(new DataQueryHandler<String>() {
            @Override
            public void onSuccess(String data) {
                blogAdapter.notifyDataSetChanged();
                resetBlogSummary();
                if (!blogsLoaded) {
                    progress.setVisibility(View.GONE);
                    blogsLoaded = true;
                } else {
                    swipeRefreshLayout.setRefreshing(false);
                }
            }

            @Override
            public void onFailure(Exception error) {
                resetBlogSummary();
                if (!blogsLoaded) {
                    progress.setVisibility(View.GONE);
                }
            }
        });
    }
}
