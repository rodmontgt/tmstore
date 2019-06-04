package com.twist.tmstore.fragments;

import android.content.Context;
import android.content.DialogInterface;
import android.content.res.ColorStateList;
import android.graphics.Color;
import android.graphics.Point;
import android.graphics.PorterDuff;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.TabLayout;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.text.TextUtilsCompat;
import android.support.v4.view.ViewCompat;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AlertDialog;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.shopgun.android.materialcolorcreator.Shade;
import com.twist.dataengine.DataEngine;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.entities.TM_CategoryInfo;
import com.twist.dataengine.entities.TM_ProductFilter;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.dataengine.entities.UserFilter;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.config.FreshChatConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.Cart;
import com.twist.tmstore.fragments.filters.Fragment_FilterGroup;
import com.twist.tmstore.listeners.CartEventListener;
import com.twist.tmstore.listeners.OnFragmentCreateListener;
import com.utils.AnalyticsHelper;
import com.utils.CContext;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.customviews.CustomViewPager;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;


public class CategoryFragment extends BaseFragment {
    TM_CategoryInfo thisCategory;
    List<TM_CategoryInfo> subCategories = new ArrayList<>();

    CustomViewPager mViewPager;
    CategoryPagesAdapter adapter;

    View section_filter;
    FloatingActionButton btn_filter;
    TextView txt_filter;

    public static boolean filter_prices_loading = false;
    public static boolean filter_attribs_loading = false;

    public static boolean isShowingDownloadPanel = false;
    boolean setDialogEnable = true;
    boolean setIsSwipe;

    int globalSortType = 0;
    TabLayout tabLayout;
    ImageButton btn_switchlist_grid;
    int selectedLayoutIndex = 0;
    boolean isFabShowing = true;
    private LinearLayout cart_section_Overlay_footer;
    private LinearLayout footer_cart;
    private RelativeLayout badge_section;
    private TextView txt_badgecount_cart;
    private ImageView icon_badge_cart;
    private TextView text_item_cart;
    private TextView text_total_cart;

    public static CategoryFragment newInstance(TM_CategoryInfo category) {
        CategoryFragment f = new CategoryFragment();
        f.initCategory(category);
        return f;
    }

    public void initCategory(TM_CategoryInfo category) {
        thisCategory = category;
        //if (thisCategory.getStrictProductCount() > 0) {
        if (!subCategories.contains(thisCategory)) {
            subCategories.add(thisCategory);
        }
        //}
        subCategories.addAll(thisCategory.getSubCategories());
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        final View rootView = inflater.inflate(R.layout.fragment_category, container, false);
        rootView.setFocusableInTouchMode(true);

        setActionBarHomeAsUpIndicator();
        getBaseActivity().restoreActionBar();

        mViewPager = (CustomViewPager) rootView.findViewById(R.id.pager);
        adapter = new CategoryPagesAdapter(getChildFragmentManager());
        mViewPager.setAdapter(adapter);
        mViewPager.addOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {
            }

            @Override
            public void onPageSelected(final int position) {
                TM_CategoryInfo c = subCategories.get(position);
                setTitle(c.getName());
                loadFilterPrices();
                updateChildFilter(position);
                AnalyticsHelper.registerVisitCategoryEvent(c);
                mViewPager.setCurrentItem(position);
            }

            @Override
            public void onPageScrollStateChanged(int state) {
                switch (state) {
                    case ViewPager.SCROLL_STATE_SETTLING:
                        break;
                    case ViewPager.SCROLL_STATE_DRAGGING:
                        if (isShowingDownloadPanel) {
                            setDialogEnable = false;
                            showAlertDialogViewPager(getContext(), setIsSwipe, mViewPager);
                        }
                        break;
                    case ViewPager.SCROLL_STATE_IDLE:
                        break;
                }
            }
        });
        if (subCategories.size() > 0) {
            if (!TextUtils.isEmpty(thisCategory.getName())) {
                setTitle(thisCategory.getName());
            }
            AnalyticsHelper.registerVisitCategoryEvent(thisCategory);
        } else {
            if (thisCategory != null) {
                if (!TextUtils.isEmpty(thisCategory.getName())) {
                    setTitle(thisCategory.getName());
                }
            }
        }

        tabLayout = (TabLayout) rootView.findViewById(R.id.sub_category_tabs);
        tabLayout.setupWithViewPager(mViewPager);
        if (Helper.isLightColor(AppInfo.color_theme)) {
            tabLayout.setBackgroundColor(Color.parseColor(AppInfo.color_actionbar_text));
            tabLayout.setTabTextColors(ColorStateList.valueOf(Color.parseColor(AppInfo.color_theme)));
            tabLayout.setSelectedTabIndicatorColor(Helper.getColorShade(AppInfo.color_actionbar_text, Shade.Shade300));
        } else {
            tabLayout.setBackgroundColor(Color.parseColor(AppInfo.color_actionbar_text));
            tabLayout.setTabTextColors(ColorStateList.valueOf(Color.parseColor(AppInfo.color_theme)));
            tabLayout.setSelectedTabIndicatorColor(Color.parseColor(AppInfo.color_theme));
        }

        // Set category tabs title text in normal or capital case.
        ViewGroup parent = (ViewGroup) tabLayout.getChildAt(0);
        for (int j = 0; j < parent.getChildCount(); j++) {
            ViewGroup child = (ViewGroup) parent.getChildAt(j);
            for (int i = 0; i < child.getChildCount(); i++) {
                View tabViewChild = child.getChildAt(i);
                if (tabViewChild instanceof TextView) {
                    ((TextView) tabViewChild).setAllCaps(AppInfo.CATEGORY_TITLE_ALL_CAPS);
                }
            }
        }

        LinearLayout layout = (LinearLayout) rootView.findViewById(R.id.category_layout_switch);
        if (AppInfo.mCategoryLayoutsConfig != null && AppInfo.mCategoryLayoutsConfig.isEnabled()) {
            layout.setVisibility(View.VISIBLE);

            View view = inflater.inflate(R.layout.category_layout_listgrid_switch, layout, true);
            View separatorView = view.findViewById(R.id.btn_separator);
            btn_switchlist_grid = (ImageButton) view.findViewById(R.id.btn_switchlist_grid);
            btn_switchlist_grid.setVisibility(View.VISIBLE);
            btn_switchlist_grid.setImageDrawable(CContext.getDrawable(getActivity(), AppInfo.ID_LAYOUT_PRODUCTS == 3
                    ? R.drawable.ic_vc_view_list
                    : R.drawable.ic_vc_view_grid));

            if (Helper.isLightColor(AppInfo.color_theme)) {
                layout.setBackgroundColor(Color.parseColor(AppInfo.color_actionbar_text));
                btn_switchlist_grid.setColorFilter(Color.parseColor(AppInfo.color_theme), PorterDuff.Mode.SRC_IN);
                btn_switchlist_grid.setBackgroundColor(Color.parseColor(AppInfo.color_actionbar_text));
                separatorView.setBackgroundColor(Color.parseColor(AppInfo.color_theme));
            } else {
                tabLayout.setBackgroundColor(Color.parseColor(AppInfo.color_actionbar_text));
                btn_switchlist_grid.setColorFilter(Color.parseColor(AppInfo.color_theme), PorterDuff.Mode.SRC_IN);
                btn_switchlist_grid.setBackgroundColor(Color.parseColor(AppInfo.color_actionbar_text));
                separatorView.setBackgroundColor(Color.parseColor(AppInfo.color_actionbar_text));
            }

            btn_switchlist_grid.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    selectedLayoutIndex++;
                    if (selectedLayoutIndex >= AppInfo.mCategoryLayoutsConfig.getLayoutIds().length) {
                        selectedLayoutIndex = 0;
                    }
                    //ToDo - replace logic (because this will change the layout of just one child fragment)
                    try {
                        String childTag = getViewPagerTag(mViewPager);
                        if (childTag != null) {
                            CategoryChildFragment fragment = null;
                            fragment = (CategoryChildFragment) findChildFragment(childTag);
                            if (fragment != null) {
                                fragment.setLM(AppInfo.mCategoryLayoutsConfig.getLayoutIds()[selectedLayoutIndex], btn_switchlist_grid);
                            }
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            });
        } else {
            layout.setVisibility(View.GONE);
        }

        if (AppInfo.SHOW_IOS_STYLE_SUB_CATEGORIES) {
            layout.setVisibility(View.GONE);
            tabLayout.setVisibility(View.GONE);
            mViewPager.setPagingEnabled(false);
        }

        section_filter = rootView.findViewById(R.id.section_filter);
        txt_filter = (TextView) rootView.findViewById(R.id.txt_filter);
        txt_filter.setText(getString(L.string.filter_details));

        btn_filter = (FloatingActionButton) rootView.findViewById(R.id.btn_filter);
        section_filter.setVisibility(View.GONE);
        txt_filter.setVisibility(View.GONE);
        if (AppInfo.ENABLE_FILTERS) {
            Helper.stylize((View) txt_filter);
            Helper.stylize(btn_filter);
            Helper.stylizeActionBar(txt_filter);
            loadFilterPrices();
            btn_filter.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    handleFilterClick(mViewPager.getCurrentItem());
                }
            });
        } else if (AppInfo.SHOW_SORTING_IF_FILTER_UNAVAILABLE) {
            section_filter.setVisibility(View.VISIBLE);
            Helper.stylize((View) txt_filter);
            Helper.stylize(btn_filter);
            Helper.stylizeActionBar(txt_filter);
            btn_filter.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    handleFilterClick(mViewPager.getCurrentItem());
                }
            });
        } else {
            section_filter.setVisibility(View.GONE);
        }
        initComponentsCartOverlayFooter(rootView);
        return rootView;
    }

    private void initComponentsCartOverlayFooter(View rootView) {
        cart_section_Overlay_footer = (LinearLayout) rootView.findViewById(R.id.cart_section_overlay_footer);
        if (AppInfo.SHOW_CART_FOOTER_OVERLAY) {
            cart_section_Overlay_footer.setVisibility(View.VISIBLE);
            View mCartOverlayView = LayoutInflater.from(getActivity()).inflate(R.layout.overlay_footer_cart, cart_section_Overlay_footer, true);
            footer_cart = (LinearLayout) mCartOverlayView.findViewById(R.id.footer_cart);
            footer_cart.setVisibility(View.VISIBLE);
            footer_cart.setBackgroundColor(Color.parseColor(AppInfo.normal_button_color));

            badge_section = (RelativeLayout) mCartOverlayView.findViewById(R.id.badge_section);
            ImageView main_icon = (ImageView) mCartOverlayView.findViewById(R.id.main_icon);
            main_icon.setColorFilter(Color.parseColor(AppInfo.normal_button_text_color), PorterDuff.Mode.SRC_IN);
            txt_badgecount_cart = (TextView) mCartOverlayView.findViewById(R.id.text_badge_count);
            txt_badgecount_cart.setTextColor(Color.parseColor(AppInfo.normal_button_text_color));
            icon_badge_cart = (ImageView) mCartOverlayView.findViewById(R.id.icon_badge);
            Helper.stylizeBadgeView(icon_badge_cart, txt_badgecount_cart);
            ImageView icon_forward_arrow = (ImageView) mCartOverlayView.findViewById(R.id.icon_forward_arrow);
            icon_forward_arrow.setColorFilter(Color.parseColor(AppInfo.normal_button_text_color), PorterDuff.Mode.SRC_IN);

            View btn_panel_separator = mCartOverlayView.findViewById(R.id.btn_panel_separator);
            btn_panel_separator.setBackgroundColor(Color.parseColor(AppInfo.normal_button_text_color));
            TextView label_item_cart = (TextView) mCartOverlayView.findViewById(R.id.label_item_cart);
            label_item_cart.setText(getString(L.string.label_item_cart_overlay));
            label_item_cart.setTextColor(Color.parseColor(AppInfo.normal_button_text_color));
            TextView label_total_cart = (TextView) mCartOverlayView.findViewById(R.id.label_total_cart);
            label_total_cart.setText(getString(L.string.label_total_cart_overlay));
            label_total_cart.setTextColor(Color.parseColor(AppInfo.normal_button_text_color));

            text_item_cart = (TextView) mCartOverlayView.findViewById(R.id.text_item_cart);
            text_item_cart.setTextColor(Color.parseColor(AppInfo.normal_button_text_color));
            text_total_cart = (TextView) mCartOverlayView.findViewById(R.id.text_total_cart);
            text_total_cart.setTextColor(Color.parseColor(AppInfo.normal_button_text_color));

            badge_section.setVisibility(View.GONE);
            text_item_cart.setText("0");
            text_total_cart.setText("0");

            updateCartBadgeCount();

            Cart.setCartEventListener(new CartEventListener() {
                @Override
                public void onItemAdded(Cart cartItem) {
                    updateCartBadgeCount();
                }

                @Override
                public void onItemUpdated(Cart cartItem) {
                    updateCartBadgeCount();
                }

                @Override
                public void onItemRemoved() {
                    updateCartBadgeCount();
                }
            });
        } else {
            cart_section_Overlay_footer.setVisibility(View.GONE);
        }
    }

    private RecyclerView.OnScrollListener mRecyclerViewScrollListener = new RecyclerView.OnScrollListener() {
        @Override
        public void onScrolled(RecyclerView recyclerView, int scrollX, int scrollY) {
            super.onScrolled(recyclerView, scrollX, scrollY);
            if (scrollY > 0) {
                Animation slideDownAnimation = AnimationUtils.loadAnimation(getContext(), R.anim.slide_down);
                setSlidAnimCartOverlayDelay(slideDownAnimation, false);
                hideFloatingButtons();
            } else {
                cart_section_Overlay_footer.setVisibility(View.VISIBLE);
                showFloatingButtons();
            }
        }

        @Override
        public void onScrollStateChanged(RecyclerView recyclerView, int newState) {
            super.onScrollStateChanged(recyclerView, newState);
        }
    };

    private void setSlidAnimCartOverlayDelay(final Animation animation, final boolean isVisible) {
        if (!isVisible) {
            cart_section_Overlay_footer.startAnimation(animation);
            animation.setAnimationListener(new Animation.AnimationListener() {
                @Override
                public void onAnimationStart(Animation animation) {
                }

                @Override
                public void onAnimationEnd(Animation animation) {
                    cart_section_Overlay_footer.setVisibility(View.GONE);
                }

                @Override
                public void onAnimationRepeat(Animation animation) {
                }
            });
        } else {
            cart_section_Overlay_footer.startAnimation(animation);
            cart_section_Overlay_footer.setVisibility(View.VISIBLE);
        }
    }

    private void hideFloatingButtons() {
        if (isFabShowing) {
            isFabShowing = false;
            Point point = new Point();
            getActivity().getWindow().getWindowManager().getDefaultDisplay().getSize(point);
            float translation = section_filter.getX() - point.x;
            if (TextUtilsCompat.getLayoutDirectionFromLocale(Locale.getDefault()) != ViewCompat.LAYOUT_DIRECTION_LTR) {
                section_filter.animate().translationX(translation).start();
            } else {
                section_filter.animate().translationXBy(-translation).start();
            }
        }
        FreshChatConfig.showChatButton(getActivity(), false);
    }

    private void showFloatingButtons() {
        if (!isFabShowing) {
            isFabShowing = true;
            if (TextUtilsCompat.getLayoutDirectionFromLocale(Locale.getDefault()) != ViewCompat.LAYOUT_DIRECTION_LTR) {
                section_filter.animate().translationX(0).start();
            } else {
                section_filter.animate().translationX(0).start();
            }
        }
        FreshChatConfig.showChatButton(getActivity(), true);
    }

    private OnFragmentCreateListener mOnFragmentCreateListener = new OnFragmentCreateListener() {
        @Override
        public void onFragmentCreated(Fragment fragment) {
            if (AppInfo.SHOW_CART_FOOTER_OVERLAY) {
                updateCartBadgeCount();
            }
            if (fragment != null && fragment instanceof CategoryChildFragment) {
                CategoryChildFragment f = (CategoryChildFragment) fragment;
                f.recyclerView.removeOnScrollListener(mRecyclerViewScrollListener);
                f.recyclerView.addOnScrollListener(mRecyclerViewScrollListener);
            }
        }
    };

    private void handleFilterClick(int pageIndex) {
        Fragment page = getChildFragmentManager().findFragmentByTag("android:switcher:" + R.id.pager + ":" + pageIndex);
        if (page != null && page instanceof CategoryChildFragment) {
            final int categoryId = subCategories.get(pageIndex).id;
            final CategoryChildFragment fragment = (CategoryChildFragment) page;

            Fragment_FilterGroup fragmentFilterGroup = Fragment_FilterGroup.newInstance();
            fragmentFilterGroup.setFilterData(TM_ProductFilter.getForCategory(categoryId), fragment.getUserFilter(), globalSortType);
            fragmentFilterGroup.setFilterCallback(new Fragment_FilterGroup.FilterCallback() {
                @Override
                public void onFilterApplied(UserFilter filter) {
                    if (filter != null) {
                        globalSortType = filter.getSortOrder();
                        loadProductsWithFilter(fragment, filter);
                    } else {
                        fragment.clearUserFilter();
                        fragment.loadAvailableProductsInAdapter();
                    }
                    fragment.updateUiFromFilter(filter);
                    updateChildFilter(fragment);
                }
            });
            fragmentFilterGroup.show(getActivity().getSupportFragmentManager(), Fragment_FilterGroup.class.getSimpleName());
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        updateCartBadgeCount();
    }

    void updateChildFilter(int pageIndex) {
        Fragment page = getChildFragmentManager().findFragmentByTag("android:switcher:" + R.id.pager + ":" + pageIndex);
        if (page != null) {
            final CategoryChildFragment fragment = (CategoryChildFragment) page;
            updateChildFilter(fragment);
            fragment.refreshAdapter();
        }
    }

    void updateChildFilter(CategoryChildFragment fragment) {
        UserFilter filter = fragment.getUserFilter();
        if (filter != null) {
            String filterString = filter.getFilterString();
            if (filterString.length() > 0) {
                txt_filter.setVisibility(View.VISIBLE);
                txt_filter.setText(HtmlCompat.fromHtml(filterString));
            } else {
                txt_filter.setVisibility(View.GONE);
            }
            if (globalSortType > 0) {
                filter.setSortOrder(globalSortType);
            }
        } else {
            txt_filter.setVisibility(View.GONE);
        }
    }

    public void loadProductsWithFilter(final CategoryChildFragment fragment, final UserFilter filter) {
        fragment.addTaskCount();
        filter.setOffset(0);
        fragment.updateProducts(new ArrayList<TM_ProductInfo>());
        DataEngine.getDataEngine().getProductsByFilter(filter, new DataQueryHandler<List<TM_ProductInfo>>() {
            @Override
            public void onSuccess(List<TM_ProductInfo> products) {
                fragment.reduceTaskCount();
                thisCategory.loadedPageCount = 1;
                fragment.resetRecyclerView();
                fragment.updateProducts(products);
            }

            @Override
            public void onFailure(Exception reason) {
                fragment.reduceTaskCount();
            }
        });
    }

    public void loadFilterPrices() {
        if (filter_prices_loading)
            return;

        if (AppInfo.ENABLE_FILTERS_PER_CATEGORY) {
            loadFiltersByCategory();
            return;
        }

        if (!TM_ProductFilter.getAll().isEmpty()) {
            loadFilterAttributes();
            return;
        }

        filter_prices_loading = true;
        DataEngine.getDataEngine().getFilterPricesInBackground(new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {
                filter_prices_loading = false;
                if (!TM_ProductFilter.attribsLoaded) {
                    loadFilterAttributes();
                }
            }

            @Override
            public void onFailure(Exception reason) {
                filter_prices_loading = false;
            }
        });
    }

    public void loadFilterAttributes() {
        if (filter_attribs_loading)
            return;

        if (TM_ProductFilter.attribsLoaded) {
            section_filter.setVisibility(View.VISIBLE);
            return;
        }

        if (thisCategory.count == 0) {
            section_filter.setVisibility(View.GONE);
            return;
        }

        filter_attribs_loading = true;
        DataEngine.getDataEngine().getFilterAttributesInBackground(new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {
                filter_attribs_loading = false;
                section_filter.setVisibility(View.VISIBLE);
            }

            @Override
            public void onFailure(Exception reason) {
                filter_attribs_loading = false;
            }
        });
    }

    public void loadFiltersByCategory() {
        if (thisCategory.count == 0) {
            section_filter.setVisibility(View.GONE);
            return;
        }

        int categoryId = getSubCategoryId();
        section_filter.setVisibility(View.GONE);
        filter_prices_loading = true;
        filter_attribs_loading = true;
        TM_ProductFilter.clearAll();
        DataEngine.getDataEngine().getFiltersByCategoryInBackground(categoryId, new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {
                filter_prices_loading = false;
                filter_attribs_loading = false;
                section_filter.setVisibility(View.VISIBLE);
            }

            @Override
            public void onFailure(Exception reason) {
                filter_prices_loading = false;
                filter_attribs_loading = false;
            }
        });
    }

    public void loadProductsInAdapter() {
        int totalPages = subCategories.size();
        for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
            Fragment page = getChildFragmentManager().findFragmentByTag("android:switcher:" + R.id.pager + ":" + pageIndex);
            if (page != null) {
                try {
                    final CategoryChildFragment fragment = (CategoryChildFragment) page;
                    fragment.loadAvailableProductsInAdapter();
                    fragment.reduceTaskCount();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public static void showAlertDialogViewPager(Context context, final boolean setIsSwipe, final CustomViewPager mViewPager) {
        AlertDialog.Builder alertDialog = new AlertDialog.Builder(context);
        alertDialog.setTitle(L.getString(L.string.dialog_title_caution));
        alertDialog.setMessage(L.getString(L.string.dialog_msg_caution));
        alertDialog.setCancelable(false);
        alertDialog.setPositiveButton(L.getString(L.string.ok), new DialogInterface.OnClickListener() {
            public void onClick(DialogInterface dialog, int which) {
                mViewPager.setCurrentItem(mViewPager.getCurrentItem(), true);
                mViewPager.getAdapter().notifyDataSetChanged();
                dialog.dismiss();
            }
        });
        alertDialog.show();
    }

    private class CategoryPagesAdapter extends FragmentPagerAdapter {
        CategoryPagesAdapter(FragmentManager fm) {
            super(fm);
        }

        @Override
        public CharSequence getPageTitle(int position) {
            StringBuilder title = new StringBuilder();
            if (!subCategories.isEmpty()) {
                TM_CategoryInfo category = subCategories.get(position);
                title.append(category.getName());
                if (AppInfo.SHOW_CATEGORY_PRODUCTS_COUNT) {
                    String format = L.getString(L.string.category_products_count_format);
                    title.append(" ").append(String.format(Locale.getDefault(), format, category.count));
                }
            }
            return HtmlCompat.fromHtml(title.toString()).toString();
        }

        @Override
        public int getCount() {
            return subCategories.isEmpty() ? 1 : subCategories.size();
        }

        @Override
        public Fragment getItem(int position) {
            if (subCategories.isEmpty()) {
                return Fragment_Placeholder.newInstance(getString(L.string.no_product_or_sub_category));
            } else {
                TM_CategoryInfo c = subCategories.get(position);
                CategoryChildFragment fragment;
                if (AppInfo.SHOW_IOS_STYLE_SUB_CATEGORIES) {
                    fragment = CategoryChildFragment.newInstance(c, true);
                } else {
                    fragment = CategoryChildFragment.newInstance(c, !c.equals(thisCategory));
                }
                fragment.setOnFragmentCreateListener(mOnFragmentCreateListener);
                return fragment;
            }
        }
    }

    public void updateCartBadgeCount() {
        if (AppInfo.SHOW_CART_FOOTER_OVERLAY) {
            cart_section_Overlay_footer.setVisibility(View.VISIBLE);
            badge_section.setVisibility(View.GONE);
            text_item_cart.setText("0");
            text_total_cart.setText("0");
            footer_cart.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    MainActivity.mActivity.openCartFragment();
                }
            });

            if (txt_badgecount_cart == null)
                return;

            if (Cart.getItemCount() > 0) {
                text_item_cart.setVisibility(View.VISIBLE);
                text_total_cart.setVisibility(View.VISIBLE);
                badge_section.setVisibility(View.VISIBLE);

				/*
                try {
                    int oldValue = Integer.parseInt(txt_badgecount_cart.getText().toString());
                    int newValue = Cart.getItemCount();
                    if (oldValue != newValue) {
                        new ScaleInOutHeartBeatAnimation(icon_badge_cart).setDuration(200).animate();
                    }
                } catch (Exception ignored) {
                }
				*/

                txt_badgecount_cart.setText(String.valueOf(Cart.getItemCount()));
                text_item_cart.setText(String.valueOf(Cart.getItemCount()));
                text_total_cart.setText((HtmlCompat.fromHtml(Helper.appendCurrency(String.valueOf(Cart.getTotalPayment())))));
            } else {
                badge_section.setVisibility(View.GONE);
                text_item_cart.setText("0");
                text_total_cart.setText("0");
            }
        } else {
            cart_section_Overlay_footer.setVisibility(View.GONE);
        }
    }

    public int getSubCategoryId() {
        int categoryId = thisCategory.id;
        if (subCategories != null && subCategories.size() > 0) {
            TM_CategoryInfo tm_categoryInfo = subCategories.get(mViewPager.getCurrentItem());
            if (tm_categoryInfo != null && tm_categoryInfo.id > 0) {
                categoryId = tm_categoryInfo.id;
            }
        }
        return categoryId;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (AppInfo.SHOW_CART_FOOTER_OVERLAY) {
            Cart.setCartEventListener(null);
        }
    }
}