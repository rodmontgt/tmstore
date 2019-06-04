package com.twist.tmstore.fragments;

import android.content.Context;
import android.content.DialogInterface;
import android.content.res.Configuration;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.GridLayout;

import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.TMStoreApp;
import com.twist.tmstore.config.FreshChatConfig;
import com.twist.tmstore.config.HomeConfigUltimate;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.Cart;
import com.twist.tmstore.entities.HomeElementUltimate;
import com.twist.tmstore.entities.HomeElementUltimate.Variable.TileStyle;
import com.twist.tmstore.listeners.BackKeyListener;
import com.twist.tmstore.views.TileView;
import com.utils.Helper;
import com.utils.customviews.ObservableScrollView;
import com.utils.customviews.ScrollViewListener;

public class Fragment_HomeUltimate extends BaseFragment implements BackKeyListener, ScrollViewListener {

    private GridLayout content;

    public Fragment_HomeUltimate() {
    }

    public static Fragment_HomeUltimate newInstance() {
        return new Fragment_HomeUltimate();
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setRetainInstance(true);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_home_ultimate, container, false);
        addBackKeyListenerOnView(rootView, this);
        content = (GridLayout) rootView.findViewById(R.id.grid_layout);
        ObservableScrollView scroll_view = (ObservableScrollView) rootView.findViewById(R.id.scroll_view);
        scroll_view.setScrollViewListener(this);
        createFragments();
        return rootView;
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        ((MainActivity) getActivity()).resetTitleBar();
        ((MainActivity) getActivity()).restoreActionBar();
        ((MainActivity) getActivity()).reloadMenu();
        createTiles(getResources().getConfiguration());
        Helper.gc();
    }

    private void initTiles(final HomeConfigUltimate homeConfig) {
        content.removeAllViews();
        content.removeAllViewsInLayout();
        content.setRowCount(homeConfig.getNumRows());
        content.setColumnCount(homeConfig.getNumColumns());
        content.getViewTreeObserver().addOnPreDrawListener(new ViewTreeObserver.OnPreDrawListener() {
            public boolean onPreDraw() {
                content.getViewTreeObserver().removeOnPreDrawListener(this);
                int contentWidth = content.getMeasuredWidth();
                int totalColumnsRequired = homeConfig.getNumColumns();
                int unitWidth = (int) (contentWidth * 1.0f / totalColumnsRequired);
                //Log.d("Fragment_HomeUltimate::contentWidth => " + contentWidth);
                //Log.d("Fragment_HomeUltimate::unitWidth => " + unitWidth);
                for (HomeElementUltimate homeElement : homeConfig.homeElements) {
                    if (homeElement.variables == null || homeElement.variables.tileType == null) {
                        continue;
                    }

                    View view = generateTile(homeElement, unitWidth);

                    if (view != null) {
                        GridLayout.LayoutParams params = new GridLayout.LayoutParams(
                                GridLayout.spec(homeElement.row - 1, homeElement.size_y),
                                GridLayout.spec(homeElement.col - 1, homeElement.size_x));
                        params.width = unitWidth * homeElement.size_x;
                        //Log.d("Fragment_HomeUltimate::params.width => " + params.width);
                        if (homeElement.variables != null && homeElement.variables.tileType != null) {
                            if (homeElement.variables.tileType.equals("8")) {
                                params.height = GridLayout.LayoutParams.WRAP_CONTENT;
                                //Log.d("GridLayout::" + " Width { " + unitWidth +  " }, Height { " + params.height + " }");
                            } else {
                                params.height = unitWidth * homeElement.size_y;
                                //Log.d("GridLayout::" + " Width { " + unitWidth +  " }, Height { " + params.height + " }");
                            }
                        } else {
                            params.height = unitWidth * homeElement.size_y;
                            //Log.d("GridLayout::" + " Width { " + unitWidth +  " }, Height { " + params.height + " }");
                        }
                        if (homeElement.size_y + homeElement.size_x > 2) {
                            params.setGravity(Gravity.FILL | Gravity.CENTER_HORIZONTAL);
                        } else {
                            params.setGravity(Gravity.START | Gravity.END);
                        }

                        if (homeElement.variables != null) {
                            TileStyle tileStyle = homeElement.variables.tileStyle;
                            if (tileStyle != null && tileStyle.margin != null) {
                                params.setMargins(
                                        Helper.DP(tileStyle.margin[1]),
                                        Helper.DP(tileStyle.margin[2]),
                                        Helper.DP(tileStyle.margin[3]),
                                        Helper.DP(tileStyle.margin[0])
                                );
                            }

                            if (tileStyle != null && tileStyle.padding != null) {
                                view.setPadding(
                                        Helper.DP(tileStyle.padding[1]),
                                        Helper.DP(tileStyle.padding[2]),
                                        Helper.DP(tileStyle.padding[3]),
                                        Helper.DP(tileStyle.padding[0])
                                );
                            }
                        }
                        content.addView(view, params);
                    }
                }
                return true;
            }
        });
    }

    private View generateTile(HomeElementUltimate homeElement, int tileWidth) {
        final Context context = getActivity();
        if (context == null) {
            return null;
        }
        if (homeElement.variables != null) {
            switch (homeElement.variables.tileType) {
                case "1":
                    return TileView.generateCategoryTile(context, homeElement);
                case "2":
                    return TileView.generateProductTile(context, homeElement);
                case "3":
                    return TileView.generateSliderTile(context, homeElement);
                case "4":
                    return TileView.createRecyclerViewTile(context, homeElement, LinearLayoutManager.HORIZONTAL, tileWidth);
                case "5":
                    return TileView.generateTagsTile(context, homeElement);
                case "6":
                    return TileView.generateCartTile(context, homeElement);
                case "7":
                    return TileView.generateWishlistTile(context, homeElement);
                case "8":
                    return TileView.createRecyclerViewTile(context, homeElement, LinearLayoutManager.VERTICAL, tileWidth);
                default:
                    return TileView.generateEmptyTile(context, homeElement);
            }
        }
        return TileView.generateEmptyTile(context, homeElement);
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        createTiles(newConfig);
    }

    private void createTiles(Configuration newConfig) {
        initTiles(newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE
                ? AppInfo.homeConfigUltimateLand
                : AppInfo.homeConfigUltimate);
    }

    @Override
    public void onBackPressed() {
        Helper.getConfirmation(
                getActivity(),
                getString(L.string.exit_message),
                false,
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        TMStoreApp.exit(getActivity());
                    }
                },
                null);
    }

    public void createFragments() {
        new Thread(new Runnable() {
            @Override
            public void run() {
                Cart.refresh();
            }
        }).start();
        MainActivity.mActivity.loadInitialProducts();
        MainActivity.mActivity.hideProgress();
    }

    @Override
    public void onScrollChanged(ObservableScrollView scrollView, int x, int y, int oldx, int oldy) {
        if (y > 0 && y > oldy) {
            FreshChatConfig.showChatButton(getActivity(), false);
        } else {
            FreshChatConfig.showChatButton(getActivity(), true);
        }
    }

    @Override
    public void onBottomReached() {
        FreshChatConfig.showChatButton(getActivity(), false);
    }
}