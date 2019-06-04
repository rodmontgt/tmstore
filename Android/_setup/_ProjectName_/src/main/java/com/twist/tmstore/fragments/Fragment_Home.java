package com.twist.tmstore.fragments;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.content.DialogInterface;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.Typeface;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.design.widget.FloatingActionButton;
import android.support.v7.widget.CardView;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.SearchView;
import android.text.InputType;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.AccelerateInterpolator;
import android.view.animation.DecelerateInterpolator;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.daimajia.slider.library.Indicators.PagerIndicator;
import com.daimajia.slider.library.SliderLayout;
import com.daimajia.slider.library.SliderTypes.BaseSliderView;
import com.daimajia.slider.library.SliderTypes.DefaultSliderView;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.entities.SellerInfo;
import com.twist.dataengine.entities.TM_CategoryInfo;
import com.twist.dataengine.entities.TM_CommonInfo;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.BaseActivity;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.TMStoreApp;
import com.twist.tmstore.adapters.Adapter_Products;
import com.twist.tmstore.adapters.Adapter_TrendingItems;
import com.twist.tmstore.adapters.CategoryAdapter;
import com.twist.tmstore.config.FreshChatConfig;
import com.twist.tmstore.config.ImageDownloaderConfig;
import com.twist.tmstore.config.MultiVendorConfig;
import com.twist.tmstore.dialogs.ConsentDialog;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.entities.Banner;
import com.twist.tmstore.entities.Cart;
import com.twist.tmstore.entities.CategoryItem;
import com.twist.tmstore.entities.RecentlyViewedItem;
import com.twist.tmstore.entities.WishListGroup;
import com.twist.tmstore.entities.Wishlist;
import com.twist.tmstore.listeners.BackKeyListener;
import com.twist.tmstore.listeners.WishGroupCreatedListener;
import com.twist.tmstore.listeners.WishListDialogHandler;
import com.utils.CContext;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.ImageDownload;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Fragment_Home extends BaseFragment implements BackKeyListener {

    SliderLayout intro_images;

    RecyclerView recyclerView;
    RecyclerView.LayoutManager mLayoutManager;
    View list_header;
    View list_footer;
    LinearLayout extra_section;

    TextView selected_product_count_text;
    ImageView icon_badge_item_count;

    RecyclerView.Adapter mAdapter;
    Adapter_TrendingItems adapterTrendingItems;
    View coordinatorLayout;

    List<TM_CategoryInfo> rootCategories = new ArrayList<>();
    List<TM_ProductInfo> fewTrendingProducts = new ArrayList<>();
    List<TM_ProductInfo> fewFreshArrivalProducts = new ArrayList<>();
    List<TM_ProductInfo> fewBestDealProducts = new ArrayList<>();
    List<TM_ProductInfo> recentlyViewProducts = new ArrayList<>();

    private LinearLayout section_layout_list_footer;

    private List<Adapter_TrendingItems> dynamicAdapters = new ArrayList<>();
    ViewGroup downloadPanel;
    View rootView;

    public static Fragment_Home newInstance() {
        Fragment_Home fragment = new Fragment_Home();
        fragment.prepareLists();
        return fragment;
    }

    void prepareLists() {
        rootCategories = TM_CategoryInfo.getAllRootCategories();
        fewTrendingProducts.addAll(TM_ProductInfo.getTrending(AppInfo.MAX_ITEMS_COUNT_HOME));
        fewFreshArrivalProducts.addAll(TM_ProductInfo.getFreshArrivals(AppInfo.MAX_ITEMS_COUNT_HOME));
        fewBestDealProducts.addAll(TM_ProductInfo.getBestDeals(AppInfo.MAX_ITEMS_COUNT_HOME));
        recentlyViewProducts.addAll(RecentlyViewedItem.getAllProducts());
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ConsentDialog.show(this);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        rootView = inflater.inflate(R.layout.fragment_home, container, false);

        initCoreFragment(rootView);

        initSeasonalElements(rootView);

        initImageSlideShow(list_header);

        initNotificationView(list_header);

        initSellerInfo(list_header, SellerInfo.getSelectedSeller());

        initCenterCategories(rootView);

        initBarcodeSection(list_footer);

        initDownloadPanel();

        loadProducts();

        return rootView;
    }

    @Override
    public void onResume() {
        super.onResume();
        refreshAllAdapters();
        setBadgeCount();
    }

    void initDownloadPanel() {
        if (AppInfo.ENABLE_MULTIPLE_WISHLIST || AppInfo.ENABLE_SINGLE_CHECK_WISHLIST || ImageDownloaderConfig.isEnabled()) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                downloadPanel = ((ViewGroup) rootView.findViewById(R.id.dynamic_panel));
                FloatingActionButton btn_action = ((FloatingActionButton) rootView.findViewById(R.id.btn_action));
                Helper.stylize(btn_action);
                downloadPanel.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        Helper.showSelectMultipleActionButtons(downloadPanel, false, new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                initDownloadTask();
                            }
                        }, new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                initAddtoMultipleList();
                            }
                        }, new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                initAddToCart();
                            }
                        }, new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                initAddtoSingleList();
                            }
                        }, new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {

                            }
                        }, new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                initShare();
                            }
                        });
                    }
                });
            } else {
                downloadPanel = (ViewGroup) getDownloadPanel((ViewGroup) rootView.findViewById(R.id.dynamic_panel_v20));
            }

            selected_product_count_text = (TextView) downloadPanel.findViewById(R.id.selected_product_count_text);
            icon_badge_item_count = (ImageView) downloadPanel.findViewById(R.id.icon_badge);
            Helper.stylizeBadgeView(icon_badge_item_count, selected_product_count_text);
            downloadPanel.setVisibility(View.GONE);
        }
    }

    void initCoreFragment(View view) {
        addBackKeyListenerOnView(view, this);
        coordinatorLayout = view.findViewById(R.id.coordinatorLayout);

        list_header = View.inflate(getActivity(), R.layout.item_header_home, null);
        list_footer = View.inflate(getActivity(), R.layout.item_footer_home, null);

        if (rootCategories != null && !rootCategories.isEmpty()) {
            mAdapter = new CategoryAdapter<>(rootCategories);
            ((CategoryAdapter) mAdapter).addHeader(list_header);
            ((CategoryAdapter) mAdapter).addFooter(list_footer);
        } else {
            mAdapter = new Adapter_Products((BaseActivity) getActivity(), TM_ProductInfo.getAll(), null, null);
            ((Adapter_Products) mAdapter).addHeader(list_header);
            ((Adapter_Products) mAdapter).addFooter(list_footer);
        }
    }

    void initSeasonalElements(View view) {
        ImageView img_theme_3 = (ImageView) view.findViewById(R.id.img_theme_3);
        if (AppInfo.SHOW_SEASONAL_GREETINGS) {
            img_theme_3.setVisibility(View.VISIBLE);
        } else {
            img_theme_3.setVisibility(View.GONE);
        }
    }

    void initImageSlideShow(View view) {
        intro_images = (SliderLayout) view.findViewById(R.id.intro_images);
        Helper.stylize(intro_images);
        int windowHeight = (int) (AppInfo.HOME_SLIDER_STANDARD_HEIGHT * Helper.getDisplaySize(getActivity()).x * 1.0f / AppInfo.HOME_SLIDER_STANDARD_WIDTH);
        intro_images.setLayoutParams(new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, windowHeight));
        if (AppInfo.SHOW_HOME_PAGE_BANNER) {
            intro_images.setVisibility(View.VISIBLE);
        } else {
            intro_images.setVisibility(View.GONE);
        }
    }

    void initNotificationView(View view) {
        final TextView textView = (TextView) view.findViewById(R.id.text_notification);
        if (!TextUtils.isEmpty(TM_CommonInfo.home_notification_label)) {
            textView.setText(HtmlCompat.fromHtml(TM_CommonInfo.home_notification_label));
            textView.post(new Runnable() {
                @Override
                public void run() {
                    if (textView.getLineCount() >= 2) {
                        textView.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                Helper.showToast(((TextView) view).getText().toString());
                            }
                        });
                    }
                }
            });
            textView.setVisibility(View.VISIBLE);
        } else {
            textView.setVisibility(View.GONE);
        }
    }

    private void initSellerInfo(View view, SellerInfo vendor) {
        if (!MultiVendorConfig.isEnabled() || vendor == null || MultiVendorConfig.getScreenType() != MultiVendorConfig.ScreenType.VENDORS) {
            return;
        }

        if (MultiVendorConfig.getScreenType() != MultiVendorConfig.ScreenType.VENDORS || true) {
            //this feature is useless for now
            return;
        }

        CardView sellerSection = new CardView(getContext());
        sellerSection.setUseCompatPadding(true);
        sellerSection.setPadding(Helper.DP(10), Helper.DP(10), Helper.DP(10), Helper.DP(10));
        {
            LinearLayout sellerInfoLayout = new LinearLayout(getContext());
            sellerInfoLayout.setOrientation(LinearLayout.VERTICAL);
            {
                TextView titleVendorInfo = new TextView(getContext());
                titleVendorInfo.setText("");
                titleVendorInfo.setPadding(Helper.DP(10), Helper.DP(10), Helper.DP(10), Helper.DP(10));

                LinearLayout.LayoutParams lp1 = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                sellerInfoLayout.addView(titleVendorInfo, lp1);

                TextView vendorTitle = new TextView(getContext());
                vendorTitle.setText(vendor.getTitle());
                vendorTitle.setTypeface(null, Typeface.BOLD);
                vendorTitle.setPadding(Helper.DP(10), Helper.DP(10), Helper.DP(10), Helper.DP(10));

                LinearLayout.LayoutParams lp2 = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                sellerInfoLayout.addView(vendorTitle, lp2);
            }
            sellerSection.addView(sellerInfoLayout);
        }
        ((ViewGroup) view).addView(sellerSection);
    }

    void updateImageSlideShow() {
        if (intro_images.getVisibility() == View.VISIBLE) {
            intro_images.stopAutoCycle();
            intro_images.setPresetTransformer(SliderLayout.Transformer.Fade);
            intro_images.setIndicatorVisibility(PagerIndicator.IndicatorVisibility.Gone);
            intro_images.removeAllSliders();

            if (AppInfo.banners != null && !AppInfo.banners.isEmpty()) {
                for (final Banner banner : AppInfo.banners) {
                    DefaultSliderView defaultSliderView = new DefaultSliderView(getActivity());
                    defaultSliderView.setShowProgress(false);
                    defaultSliderView.description("").image(banner.img_url).setScaleType(BaseSliderView.ScaleType.CenterCrop);
                    defaultSliderView.setOnSliderClickListener(new BaseSliderView.OnSliderClickListener() {
                        @Override
                        public void onSliderClick(BaseSliderView slider) {
                            banner.onClick(slider.getView()
                            );
                        }
                    });
                    intro_images.addSlider(defaultSliderView);
                }
            } else if (AppInfo.ENABLE_AUTOMATIC_BANNERS) {
                int numSlides = 0;
                for (final TM_ProductInfo product : TM_ProductInfo.getAll()) {
                    if (product.hasAnyImage()) {
                        DefaultSliderView defaultSliderView = new DefaultSliderView(getActivity());
                        defaultSliderView.setShowProgress(false);
                        defaultSliderView.description("").image(product.getFirstImageUrl()).setScaleType(BaseSliderView.ScaleType.CenterCrop);
                        defaultSliderView.setOnSliderClickListener(new BaseSliderView.OnSliderClickListener() {
                            @Override
                            public void onSliderClick(BaseSliderView slider) {
                                if (product.type == TM_ProductInfo.ProductType.EXTERNAL) {
                                    Helper.openExternalLink(getContext(), product.product_url);
                                } else {
                                    MainActivity.mActivity.openProductInfo(product);
                                }
                            }
                        });
                        intro_images.addSlider(defaultSliderView);
                        numSlides++;
                    }
                    if (numSlides > 5)
                        break;
                }
            }

            if (intro_images.getSlidesCount() > 1) {
                if (AppInfo.ENABLE_AUTO_SLIDE_BANNER) {
                    intro_images.startAutoCycle();
                }
                intro_images.setPresetTransformer(SliderLayout.Transformer.Default);
                intro_images.setIndicatorVisibility(PagerIndicator.IndicatorVisibility.Visible);
            }
        } else {
            intro_images.setVisibility(View.GONE);
        }
    }

    void initCenterCategories(View view) {
        extra_section = (LinearLayout) view.findViewById(R.id.extra_section);
        recyclerView = (RecyclerView) view.findViewById(R.id.recyclerview_home_category);

        if (AppInfo.ADD_SEARCH_IN_HOME) {
            Helper.stylize(extra_section);
            extra_section.setVisibility(View.VISIBLE);
            SearchView extraSearchView = new SearchView(getContext());
            extraSearchView.setIconifiedByDefault(false);
            extraSearchView.setInputType(InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS);
            extraSearchView.setQueryHint(getString(L.string.txt_search_hint_home));
            extra_section.addView(extraSearchView, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
            extraSearchView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    MainActivity.mActivity.openSearchFragment();
                }
            });
            extraSearchView.setOnQueryTextFocusChangeListener(new View.OnFocusChangeListener() {
                @Override
                public void onFocusChange(View view, boolean hasFocus) {
                    if (hasFocus) {
                        MainActivity.mActivity.openSearchFragment();
                    }
                }
            });
            stylizeSearchView(extraSearchView);
        } else {
            extra_section.setVisibility(View.GONE);
        }
    }

    private void stylizeSearchView(final SearchView searchView) {
        try {
            int color = Color.parseColor(AppInfo.color_theme);
            if (Helper.isLightColor(color)) {
                color = Color.parseColor(AppInfo.color_actionbar_text);
            }

            searchView.setBackground(CContext.getDrawable(getActivity(), R.drawable.round_rect_search_bg));

            ImageView searchMagIcon = (ImageView) searchView.findViewById(android.support.v7.appcompat.R.id.search_mag_icon);
            searchMagIcon.setColorFilter(color, PorterDuff.Mode.SRC_ATOP);

            ImageView searchCloseBtn = (ImageView) searchView.findViewById(android.support.v7.appcompat.R.id.search_close_btn);
            searchCloseBtn.setColorFilter(CContext.getColor(this, R.color.color_icon_close), PorterDuff.Mode.SRC_ATOP);

            View searchPlate = searchView.findViewById(android.support.v7.appcompat.R.id.search_plate);
            searchPlate.setBackgroundColor(CContext.getColor(this, android.R.color.transparent));

            EditText searchEditText = (EditText) searchView.findViewById(android.support.v7.appcompat.R.id.search_src_text);
            searchEditText.setHintTextColor(color);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void hideViews() {
        if (extra_section != null && extra_section.getVisibility() == View.VISIBLE) {
            extra_section.animate().translationY(-extra_section.getHeight()).setInterpolator(new AccelerateInterpolator(2));
        }
    }

    private void showViews() {
        if (extra_section.getVisibility() == View.VISIBLE) {
            extra_section.animate().translationY(0).setInterpolator(new DecelerateInterpolator(2));
        }
    }

    void updateCenterCategories() {
        final int columns = Helper.getCategoryLayoutColumns();
        if (columns > 1 && rootCategories.size() > 1) {
            mLayoutManager = new GridLayoutManager(getActivity(), columns);
            ((GridLayoutManager) mLayoutManager).setSpanSizeLookup(new GridLayoutManager.SpanSizeLookup() {
                @Override
                public int getSpanSize(int position) {
                    if (position == 0 || position > rootCategories.size()) {
                        return columns;
                    }
                    return 1;
                }
            });
        } else {
            mLayoutManager = new LinearLayoutManager(getActivity());
        }

        recyclerView.setHasFixedSize(false);
        recyclerView.setLayoutManager(mLayoutManager);
        recyclerView.setAdapter(mAdapter);
        if (mAdapter.getItemCount() > 1) {
            recyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
                @Override
                public void onScrolled(RecyclerView visibleRecyclerView, int dx, int dy) {
                    boolean show = dy <= 0;
                    FreshChatConfig.showChatButton(getActivity(), show);
                    View view = visibleRecyclerView.getChildAt(0);
                    if (view != null && visibleRecyclerView.getChildAdapterPosition(view) == 0) {
                        view.setTranslationY(-view.getTop() / 2);
                        return;
                    }

                    super.onScrolled(visibleRecyclerView, dx, dy);
                }
            });
        }
    }

    void initBarcodeSection(View view) {
        section_layout_list_footer = (LinearLayout) view.findViewById(R.id.section_layout_list_footer);
    }

    public void updateBarcodeSections() {
        dynamicAdapters.clear();
        section_layout_list_footer.removeAllViewsInLayout();
        section_layout_list_footer.removeAllViews();

        if (AppInfo.front_page_categories != null) {
            for (CategoryItem categoryItem : AppInfo.front_page_categories) {
                switch (categoryItem.id) {
                    case CategoryItem.ID_TRENDING_ITEMS: {
                        if (!fewTrendingProducts.isEmpty()) {
                            View view = LayoutInflater.from(getActivity()).inflate(R.layout.item_footer_home_dynamic, null);
                            applyStyleOnHeaderLayout(view);

                            TextView title_best_deals = (TextView) view.findViewById(R.id.title_best_deals);
                            title_best_deals.setText(!TextUtils.isEmpty(categoryItem.title) ? categoryItem.title : getString(L.string.header_trending_items));

                            Button btn_view_all = (Button) view.findViewById(R.id.btn_view_all);
                            btn_view_all.setVisibility(View.GONE);

                            adapterTrendingItems = new Adapter_TrendingItems(getContext(), fewTrendingProducts, new View.OnClickListener() {
                                @Override
                                public void onClick(View view) {
                                    setBadgeCount();
                                }
                            });
                            RecyclerView recyclerView = (RecyclerView) view.findViewById(R.id.recycler_best_deals);
                            recyclerView.setAdapter(adapterTrendingItems);
                            section_layout_list_footer.addView(view);
                            dynamicAdapters.add(adapterTrendingItems);
                        }
                        break;
                    }
                    case CategoryItem.ID_BEST_DEALS: {
                        if (!fewBestDealProducts.isEmpty()) {
                            View view = LayoutInflater.from(getActivity()).inflate(R.layout.item_footer_home_dynamic, null);
                            applyStyleOnHeaderLayout(view);

                            TextView title_best_deals = (TextView) view.findViewById(R.id.title_best_deals);
                            title_best_deals.setText(!TextUtils.isEmpty(categoryItem.title) ? categoryItem.title : getString(L.string.header_best_deals));

                            Button btn_view_all = (Button) view.findViewById(R.id.btn_view_all);
                            btn_view_all.setVisibility(View.GONE);

                            adapterTrendingItems = new Adapter_TrendingItems(getContext(), fewBestDealProducts, new View.OnClickListener() {
                                @Override
                                public void onClick(View view) {
                                    setBadgeCount();
                                }
                            });
                            RecyclerView recyclerView = (RecyclerView) view.findViewById(R.id.recycler_best_deals);
                            recyclerView.setAdapter(adapterTrendingItems);
                            section_layout_list_footer.addView(view);
                            dynamicAdapters.add(adapterTrendingItems);
                        }
                        break;
                    }
                    case CategoryItem.ID_FRESH_ARRIVALS: {
                        if (!fewFreshArrivalProducts.isEmpty()) {
                            View view = LayoutInflater.from(getActivity()).inflate(R.layout.item_footer_home_dynamic, null);
                            applyStyleOnHeaderLayout(view);

                            TextView title_best_deals = (TextView) view.findViewById(R.id.title_best_deals);
                            title_best_deals.setText(!TextUtils.isEmpty(categoryItem.title) ? categoryItem.title : getString(L.string.header_fresh_arrival));

                            Button btn_view_all = (Button) view.findViewById(R.id.btn_view_all);
                            btn_view_all.setVisibility(View.GONE);

                            adapterTrendingItems = new Adapter_TrendingItems(getContext(), fewFreshArrivalProducts, new View.OnClickListener() {
                                @Override
                                public void onClick(View view) {
                                    setBadgeCount();
                                }
                            });
                            RecyclerView recyclerView = (RecyclerView) view.findViewById(R.id.recycler_best_deals);
                            recyclerView.setAdapter(adapterTrendingItems);
                            section_layout_list_footer.addView(view);
                            dynamicAdapters.add(adapterTrendingItems);
                        }
                        break;
                    }
                    case CategoryItem.ID_RECENTLY_VIEWED: {
                        if (!recentlyViewProducts.isEmpty()) {
                            View view = LayoutInflater.from(getActivity()).inflate(R.layout.item_footer_home_dynamic, null);
                            applyStyleOnHeaderLayout(view);

                            TextView title_best_deals = (TextView) view.findViewById(R.id.title_best_deals);
                            title_best_deals.setText(!TextUtils.isEmpty(categoryItem.title) ? categoryItem.title : getString(L.string.header_recently_viewed));

                            Button btn_view_all = (Button) view.findViewById(R.id.btn_view_all);
                            btn_view_all.setVisibility(View.GONE);

                            adapterTrendingItems = new Adapter_TrendingItems(getContext(), recentlyViewProducts, new View.OnClickListener() {
                                @Override
                                public void onClick(View view) {
                                    setBadgeCount();
                                }
                            });
                            RecyclerView recyclerView = (RecyclerView) view.findViewById(R.id.recycler_best_deals);
                            recyclerView.setAdapter(adapterTrendingItems);
                            section_layout_list_footer.addView(view);
                            dynamicAdapters.add(adapterTrendingItems);
                        }
                        break;
                    }
                    default: {
                        if (TM_CategoryInfo.hasCategory(categoryItem.id)) {
                            final TM_CategoryInfo categoryInfo = TM_CategoryInfo.getWithId(categoryItem.id);
                            if (categoryInfo != null && categoryInfo.count > 0) {
                                View view = LayoutInflater.from(getActivity()).inflate(R.layout.item_footer_home_dynamic, null);
                                applyStyleOnHeaderLayout(view);

                                TextView title_best_deals = (TextView) view.findViewById(R.id.title_best_deals);
                                title_best_deals.setText(!TextUtils.isEmpty(categoryItem.title) ? categoryItem.title : categoryInfo.getName());

                                Button btn_view_all = (Button) view.findViewById(R.id.btn_view_all);
                                btn_view_all.setText(getString(L.string.view_all));
                                Helper.stylize(btn_view_all);
                                btn_view_all.setOnClickListener(new View.OnClickListener() {
                                    @Override
                                    public void onClick(View view) {
                                        MainActivity.mActivity.expandCategory(categoryInfo);
                                    }
                                });
                                adapterTrendingItems = new Adapter_TrendingItems(getContext(), TM_ProductInfo.get10ForCategory(categoryInfo), new View.OnClickListener() {
                                    @Override
                                    public void onClick(View view) {
                                        setBadgeCount();
                                    }
                                });
                                RecyclerView recyclerView = (RecyclerView) view.findViewById(R.id.recycler_best_deals);
                                recyclerView.setAdapter(adapterTrendingItems);
                                section_layout_list_footer.addView(view);
                                dynamicAdapters.add(adapterTrendingItems);
                            }
                        }
                    }
                }
            }
        }
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        updateImageSlideShow();
        updateCenterCategories();
        updateBarcodeSections();
        Helper.gc();
        resetTitleBar();
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

    public void loadProducts() {
        new Thread(new Runnable() {
            @Override
            public void run() {
                Cart.refresh();
            }
        }).start();
        MainActivity.mActivity.loadInitialProducts();
    }


    public void updateAdapter() {
        mAdapter.notifyDataSetChanged();
    }

    private void resetTitleBar() {
        if ((MultiVendorConfig.isEnabled()) && SellerInfo.getSelectedSeller() != null) {
            setTitle(SellerInfo.getSelectedSeller().getTitle());
            ((MainActivity) getActivity()).reloadMenu();
        } else {
            ((MainActivity) getActivity()).resetTitleBar();
            ((MainActivity) getActivity()).restoreActionBar();
            ((MainActivity) getActivity()).reloadMenu();
        }
    }

    private int getItemCount() {
        int count = 0;
        for (Boolean value : Adapter_TrendingItems.mCheckedItem.values()) {
            if (value) {
                count++;
            }
        }
        return count;
    }

    private void setBadgeCount() {
        if (AppInfo.ENABLE_MULTIPLE_WISHLIST && AppInfo.ENABLE_SINGLE_CHECK_WISHLIST && ImageDownloaderConfig.isEnabled()) {
            int count = getItemCount();
            selected_product_count_text.setText(String.valueOf(count));
            selected_product_count_text.setVisibility(count > 0 ? View.VISIBLE : View.GONE);
            icon_badge_item_count.setVisibility(count > 0 ? View.VISIBLE : View.GONE);
            if (count > 0)
                showDownloadPanel();
            else
                hideDownloadPanel();
        }
    }

    private void showDownloadChkBoxesInAdapter() {
        dynamicAdapters.get(0).setCheckMode(true);
    }

    private void hideDownloadPanel() {
        if (downloadPanel.getVisibility() != View.GONE) {
            downloadPanel.animate()
                    .translationY(0)
                    //.translationY(-downloadPanel.getHeight())
                    .alpha(0.0f)
                    .setDuration(300)
                    .setListener(new AnimatorListenerAdapter() {
                        @Override
                        public void onAnimationEnd(Animator animation) {
                            super.onAnimationEnd(animation);
                            downloadPanel.setVisibility(View.GONE);
                        }
                    });
        }
        Helper.hideSelectMultipleActionButtons(downloadPanel);
    }

    private void showDownloadPanel() {
        if (downloadPanel.getVisibility() != View.VISIBLE) {
            downloadPanel.setVisibility(View.VISIBLE);
            downloadPanel.animate()
                    .translationY(0)
                    .alpha(1.0f)
                    .setDuration(300)
                    .setListener(new AnimatorListenerAdapter() {
                        @Override
                        public void onAnimationEnd(Animator animation) {
                            super.onAnimationEnd(animation);
                        }
                    });
        }
        Helper.hideSelectMultipleActionButtons(downloadPanel);
    }

    private View getDownloadPanel(final ViewGroup parent) {
        return Helper.getDownloadPanel(parent, new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                showDownloadChkBoxesInAdapter();
            }
        }, new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                Helper.showSelectMultipleMenu(downloadPanel, false, new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        initDownloadTask();
                    }
                }, new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        initAddtoMultipleList();
                    }
                }, new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        initAddToCart();
                    }
                }, new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        initAddtoSingleList();
                    }
                }, new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                    }
                }, new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        initShare();
                    }
                });
            }
        });
    }

    private void openWishGroupListAndAddProduct() {
        HashMap<Integer, Boolean> map = dynamicAdapters.get(0).mCheckedItem;
        for (Map.Entry<Integer, Boolean> entry : map.entrySet()) {
            Integer key = entry.getKey();
            Boolean value = entry.getValue();
            TM_ProductInfo product = TM_ProductInfo.getProductWithId(key);
            if (product != null && value) {
                WishListGroup.selectedProductToAddInWishList.add(product);
            }
        }
        refreshAllAdapters();
        //downloadPanel.setVisibility(View.GONE);
    }

    public void refreshAllAdapters() {
        for (Adapter_TrendingItems adapter : dynamicAdapters) {
            if (adapter != null) {
                adapter.resetAdapterForCheckBox();
            }
        }
        setBadgeCount();
    }

    private void initDownloadTask() {
        boolean isStarted = false;
        for (Map.Entry<Integer, Boolean> entry : dynamicAdapters.get(0).mCheckedItem.entrySet()) {
            TM_ProductInfo product = TM_ProductInfo.getProductWithId(entry.getKey());
            if (product != null && entry.getValue()) {
                isStarted = true;
                ImageDownload.downloadProductCatalog(getActivity(), product);
            }
        }
        Toast.makeText(getActivity(), isStarted ? getString(L.string.download_initiated) : getString(L.string.no_products), Toast.LENGTH_SHORT).show();
        refreshAllAdapters();
    }

    public void initAddtoMultipleList() {
        openWishGroupListAndAddProduct();
        if (WishListGroup.selectedProductToAddInWishList.size() == 0) {
            Helper.toast(L.string.no_products);
            refreshAllAdapters();
            return;
        }

        Fragment_Wishlist_Dialog.OpenWishGroupDialogWishCheckbox(WishListGroup.selectedProductToAddInWishList, new WishListDialogHandler() {
            @Override
            public void onSelectGroupSuccess(TM_ProductInfo product, WishListGroup obj) {
                WishListGroup.selectedProductToAddInWishList.clear();
                refreshAllAdapters();
            }

            @Override
            public void onSelectGroupFailed(String cause) {
            }

            @Override
            public void onSkipDialog(TM_ProductInfo product, WishListGroup obj) {
            }
        });
    }

    public void initShare() {
        new AsyncTask<Void, Void, ArrayList<Uri>>() {
            @Override
            protected ArrayList<Uri> doInBackground(Void... voids) {
                MainActivity.mActivity.showProgress(getString(L.string.loading), false);
                return Helper.getImageUriList(getActivity(), dynamicAdapters.get(0).mCheckedItem);
            }

            @Override
            protected void onPostExecute(ArrayList<Uri> result) {
                super.onPostExecute(result);
                Helper.shareOnWhatsApp("", result);
                MainActivity.mActivity.hideProgress();
                (dynamicAdapters.get(0)).checkMode = false;
                refreshAllAdapters();
            }
        }.execute();
    }

    private void addProductstoWishList(final WishListGroup wishListGroup) {
        List<WishListGroup> mylist = new ArrayList<>();
        wishListGroup.isChecked = true;
        mylist.add(wishListGroup);

        String str = WishListGroup.getPidsArrayString(mylist, WishListGroup.selectedProductToAddInWishList);
        MainActivity.mActivity.showProgress(getString(L.string.please_wait));
        WishListGroup.addProductsToMultipleWishList(str, new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {
                MainActivity.mActivity.hideProgress();
                refreshAllAdapters();
                WishListGroup.selectedProductToAddInWishList.clear();
                Helper.toast(Helper.showItemAddedToWishListToast(wishListGroup));
                MainActivity.mActivity.popBackWishFragment();
            }

            @Override
            public void onFailure(Exception error) {
                MainActivity.mActivity.hideProgress();
                MainActivity.mActivity.showProgress(getString(L.string.retry));
            }
        });
    }

    public void initAddtoSingleList() {
        openWishGroupListAndAddProduct();
        if (WishListGroup.selectedProductToAddInWishList.size() == 0) {
            Helper.toast(L.string.no_products);
            refreshAllAdapters();
            return;
        }

        final WishListGroup wishListGroup = WishListGroup.getWishListGroupById(WishListGroup.getdefaultWishGroupID());
        if (AppUser.hasSignedIn() && AppInfo.ENABLE_MULTIPLE_WISHLIST) {
            if (wishListGroup != null) {
                addProductstoWishList(wishListGroup);
            } else {
                MainActivity.mActivity.openWishlistFragment(false);
                Fragment_Wishlist_Dialog.setOnWishGroupCreatedListener(new WishGroupCreatedListener() {
                    @Override
                    public boolean onSuccess(WishListGroup wg) {
                        addProductstoWishList(wg);
                        return false;
                    }
                });
            }
        } else {
            if (AppInfo.ENABLE_SINGLE_CHECK_WISHLIST) {

                if (WishListGroup.allwishListGroup.size() > 0) {
                    for (TM_ProductInfo product : WishListGroup.selectedProductToAddInWishList) {
                        if (!WishListGroup.hasChild(wishListGroup.id, product) && Wishlist.addProduct(product, wishListGroup)) {
                        }
                    }
                    WishListGroup.selectedProductToAddInWishList.clear();
                    Helper.toast(getString(L.string.item_added_to_wishlist));
                    refreshAllAdapters();
                    MainActivity.mActivity.reloadMenu();
                    MainActivity.mActivity.popBackWishFragment();
                } else {
                    MainActivity.mActivity.openWishlistFragment(false);
                    Fragment_Wishlist_Dialog.setOnWishGroupCreatedListener(new WishGroupCreatedListener() {
                        @Override
                        public boolean onSuccess(WishListGroup wishListGroup) {
                            for (TM_ProductInfo product : WishListGroup.selectedProductToAddInWishList) {
                                if (!WishListGroup.hasChild(wishListGroup.id, product) && Wishlist.addProduct(product, wishListGroup)) {
                                }
                            }
                            WishListGroup.selectedProductToAddInWishList.clear();
                            Helper.toast(getString(L.string.item_added_to_wishlist));
                            refreshAllAdapters();
                            MainActivity.mActivity.reloadMenu();
                            MainActivity.mActivity.popBackWishFragment();
                            return false;
                        }
                    });
                }
            } else {
                for (TM_ProductInfo product : WishListGroup.selectedProductToAddInWishList) {
                    if (Wishlist.addProduct(product, wishListGroup)) {

                    }
                }
                WishListGroup.selectedProductToAddInWishList.clear();
                Helper.toast(getString(L.string.item_added_to_wishlist));
                refreshAllAdapters();
                MainActivity.mActivity.reloadMenu();
            }
        }
    }

    public void initAddToCart() {
        if (AppInfo.mGuestUserConfig != null && AppInfo.mGuestUserConfig.isEnabled() && AppInfo.mGuestUserConfig.isPreventCart() && AppUser.isAnonymous()) {
            Helper.toast(L.string.you_need_to_login_first);
            refreshAllAdapters();
            return;
        }
        openWishGroupListAndAddProduct();

        if (WishListGroup.selectedProductToAddInWishList.size() == 0) {
            Helper.toast(L.string.no_products);
            refreshAllAdapters();
            return;
        }
        final List<TM_ProductInfo> addprodtocart = new ArrayList<>();
        boolean isAdded = false;
        boolean isOutOfStock = false;
        boolean hasAttributes = false;
        for (TM_ProductInfo product : WishListGroup.selectedProductToAddInWishList) {

            boolean bisAdded = false;
            boolean bisOutOfStock = false;
            boolean bhasAttributes = false;

            if (!product.hasAttributes()) {
                if (product.in_stock) {
                    if (Cart.hasItem(product)) {
                        isAdded = true;
                        bisAdded = true;
                    }
                } else {
                    isOutOfStock = true;
                    bisOutOfStock = true;
                }
            } else {
                hasAttributes = true;
                bhasAttributes = true;
            }

            if (!bisAdded && !bisOutOfStock && !bhasAttributes) {
                addprodtocart.add(product);
            }
        }
        if (hasAttributes || isOutOfStock || isAdded) {
            String msg = "";
            String title = "";
            if (hasAttributes) {
                msg = getString(L.string.adding_attribute_error);
                title = getString(L.string.title_contains_attribute);
            }
            if (isOutOfStock) {
                msg = Helper.changeLine(msg) + getString(L.string.adding_outofstock_error);
                title = getString(L.string.title_out_of_stock);
            }
            if (isAdded) {
                msg = Helper.changeLine(msg) + getString(L.string.adding_alredyadded_error);
                title = getString(L.string.title_already_in_cart);
            }

            Helper.showAlertDialog(title, msg, getString(L.string.continue_anyway), true, new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View view) {
                    boolean isAnyAdded = false;
                    for (TM_ProductInfo product : addprodtocart) {
                        Cart.addProduct(product);
                        isAnyAdded = true;
                    }
                    if (isAnyAdded) Helper.toast(getString(L.string.item_added_to_cart));
                    WishListGroup.selectedProductToAddInWishList.clear();
                    refreshAllAdapters();
                    ((MainActivity) getActivity()).restoreActionBar();
                    return false;
                }
            });
        } else {
            for (TM_ProductInfo product : addprodtocart) {
                Cart.addProduct(product);
            }
            WishListGroup.selectedProductToAddInWishList.clear();
            Helper.toast(getString(L.string.item_added_to_cart));
            refreshAllAdapters();
            ((MainActivity) getActivity()).restoreActionBar();
        }
    }

    private void applyStyleOnHeaderLayout(View view) {
        int customBackgroundColorColor = Color.parseColor(AppInfo.color_home_section_header_bg);
        View cardView = view.findViewById(R.id.home_best_deals_section);
        cardView.setBackgroundColor(customBackgroundColorColor);

        TextView title_best_deals = (TextView) view.findViewById(R.id.title_best_deals);
        title_best_deals.setTextColor(Color.parseColor(AppInfo.color_home_section_header_text));

        // if default and custom colors are different then style and remove margins or hide separator
        int defaultBackgroundColor = CContext.getColor(this, R.color.color_home_section_header_bg);
        if (defaultBackgroundColor != customBackgroundColorColor) {
            View separatorView = view.findViewById(R.id.home_best_deals_separator);
            if (separatorView.getLayoutParams() instanceof ViewGroup.MarginLayoutParams) {
                int color = Helper.getPressedColor(customBackgroundColorColor);
                separatorView.setBackgroundColor(color);
                ViewGroup.MarginLayoutParams params = (ViewGroup.MarginLayoutParams) separatorView.getLayoutParams();
                params.setMargins(0, 0, 0, 0);
                separatorView.requestLayout();
            } else {
                separatorView.setVisibility(View.GONE);
            }
        }
    }
}