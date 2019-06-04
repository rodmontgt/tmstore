package com.twist.tmstore.listeners;

import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.StaggeredGridLayoutManager;

public abstract class EndlessRecyclerOnScrollListener extends RecyclerView.OnScrollListener {
    public static String TAG = EndlessRecyclerOnScrollListener.class.getSimpleName();

    private int previousTotal = 0; // The total number of items in the dataset after the last load
    private boolean loading = false; // True if we are still waiting for the last set of data to load.
    private int visibleThreshold = 5; // The minimum amount of items to have below your current scroll position before loading more.
    int firstVisibleItem, visibleItemCount, totalItemCount, totalItemCountLoadable;

    private int current_page = 1;

    private RecyclerView.LayoutManager mLayoutManager;

    public EndlessRecyclerOnScrollListener(RecyclerView.LayoutManager layoutManager) {
        this.mLayoutManager = layoutManager;
    }

    @Override
    public void onScrolled(RecyclerView recyclerView, int dx, int dy) {
        super.onScrolled(recyclerView, dx, dy);

        //visibleItemCount = recyclerView.getChildCount();
        visibleItemCount = mLayoutManager.getChildCount();
        totalItemCount = mLayoutManager.getItemCount();
        totalItemCountLoadable = getTotalItemCount(); //mLayoutManager.getItemCount();
        //firstVisibleItem = ((LinearLayoutManager) mLayoutManager).findFirstVisibleItemPosition();

        if (mLayoutManager instanceof StaggeredGridLayoutManager) {
            int[] firstVisibleItems = null;
            firstVisibleItems = ((StaggeredGridLayoutManager) mLayoutManager).findFirstVisibleItemPositions(firstVisibleItems);
            if (firstVisibleItems != null && firstVisibleItems.length > 0) {
                firstVisibleItem = firstVisibleItems[0];
            }
        } else {
            firstVisibleItem = ((LinearLayoutManager) mLayoutManager).findFirstVisibleItemPosition();
        }

//        if (loading) {
//            if (totalItemCountLoadable > previousTotal) {
//                loading = false;
//                previousTotal = totalItemCountLoadable;
//            }
//        }

        if (!loading && (totalItemCount - visibleItemCount)
                <= (firstVisibleItem + visibleThreshold)) {
            // End has been reached

            // Do something
            current_page++;

            onLoadMore(current_page++);

            loading = true;
        }
    }

    public abstract void onLoadMore(int current_page);
    public abstract int getTotalItemCount();

    public void notifyLoadCompleted() {
        loading = false;
    }
}