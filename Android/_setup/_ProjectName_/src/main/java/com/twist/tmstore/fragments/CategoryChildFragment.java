package com.twist.tmstore.fragments;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.graphics.Point;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.v7.widget.CardView;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.StaggeredGridLayoutManager;
import android.text.TextUtils;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CompoundButton;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.twist.dataengine.DataEngine;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.entities.SellerInfo;
import com.twist.dataengine.entities.TM_CategoryInfo;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.dataengine.entities.UserFilter;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.BaseActivity;
import com.twist.tmstore.adapters.Adapter_MoreSubCategoryList;
import com.twist.tmstore.adapters.Adapter_Products;
import com.twist.tmstore.adapters.CategoryAdapter;
import com.twist.tmstore.config.GuestUserConfig;
import com.twist.tmstore.config.ImageDownloaderConfig;
import com.twist.tmstore.config.MultiVendorConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.entities.Cart;
import com.twist.tmstore.entities.WishListGroup;
import com.twist.tmstore.entities.Wishlist;
import com.twist.tmstore.listeners.EndlessRecyclerOnScrollListener;
import com.twist.tmstore.listeners.OnFragmentCreateListener;
import com.twist.tmstore.listeners.TaskListener;
import com.twist.tmstore.listeners.WishGroupCreatedListener;
import com.twist.tmstore.listeners.WishListDialogHandler;
import com.utils.CContext;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.ImageDownload;
import com.utils.Log;
import com.utils.customviews.progressbar.CircleProgressBar;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CategoryChildFragment extends BaseFragment {
    private final List<TM_CategoryInfo> mSubCategories = new ArrayList<>();
    public RecyclerView recyclerView;
    boolean slideAnimationInProgress = false;
    boolean isDownloadPanelAnimRunning = false;
    private View list_header;
    private View list_footer;
    private RecyclerView recycler_view_sub_categories;
    private CircleProgressBar progressBar1;
    private ImageView cat_image;
    private TM_CategoryInfo thisCategory;
    private boolean shouldShowMoreSubCategories = true;
    private View coordinatorLayout;
    private ViewGroup downloadPanel;
    private TextView selected_product_count_text;
    private ImageView icon_badge_item_count;
    private Adapter_Products adapter = null;
    private RecyclerView.LayoutManager mLayoutManager;
    private boolean enableParallaxScroll = true;
    private boolean hasHeader = true;
    private String requestedTitle = null;
    private UserFilter currentFilter = null;
    private EndlessRecyclerOnScrollListener scrollListener;
    private OnFragmentCreateListener mOnFragmentCreateListener;
    private int numTasks = 0;

    public CategoryChildFragment() {
        if (Adapter_Products.ID_LAYOUT_PRODUCTS == -1) {
            Adapter_Products.ID_LAYOUT_PRODUCTS = AppInfo.ID_LAYOUT_PRODUCTS;
        }
    }

    public static CategoryChildFragment newInstance(TM_CategoryInfo category, boolean shouldShowMoreSubCategories) {
        CategoryChildFragment f = new CategoryChildFragment();
        f.initCategory(category, shouldShowMoreSubCategories);
        return f;
    }

    public static CategoryChildFragment newInstance(String title, TM_CategoryInfo category, boolean shouldShowMoreSubCategories) {
        CategoryChildFragment fragment = new CategoryChildFragment();
        fragment.requestedTitle = title;
        fragment.initCategory(category, shouldShowMoreSubCategories);
        return fragment;
    }

    public UserFilter getUserFilter() {
        return this.currentFilter;
    }

    public void initCategory(TM_CategoryInfo category, boolean shouldShowMoreSubCategories) {
        this.thisCategory = category;
        this.shouldShowMoreSubCategories = shouldShowMoreSubCategories;
        if (this.shouldShowMoreSubCategories) {
            this.mSubCategories.addAll(thisCategory.getSubCategories());
        }
    }

    @Override
    public void onStop() {
        Helper.gc();
        super.onStop();
    }

    @Override
    public void onResume() {
        super.onResume();
        if (adapter != null) {
            adapter.notifyDataSetChanged();
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        Helper.gc();
        View rootView = inflater.inflate(R.layout.fragment_category_child, container, false);
        initComponents(rootView);
        bindData();
        return rootView;
    }

    public void setOnFragmentCreateListener(OnFragmentCreateListener onFragmentCreateListener) {
        this.mOnFragmentCreateListener = onFragmentCreateListener;
    }

    void initComponents(final View rootView) {
        coordinatorLayout = rootView.findViewById(R.id.coordinatorLayout);
        recyclerView = (RecyclerView) rootView.findViewById(R.id.recyclerView);

        final int columnCount = Adapter_Products.getProductLayoutColumnCount();
        if (Adapter_Products.ID_LAYOUT_PRODUCTS == 3) {
            mLayoutManager = new StaggeredGridLayoutManager(columnCount, StaggeredGridLayoutManager.VERTICAL);
            ((StaggeredGridLayoutManager) mLayoutManager).setGapStrategy(StaggeredGridLayoutManager.GAP_HANDLING_MOVE_ITEMS_BETWEEN_SPANS);
            recyclerView.setLayoutManager(mLayoutManager);
        } else {
            mLayoutManager = new GridLayoutManager(getActivity(), columnCount);
            if (hasHeader) {
                ((GridLayoutManager) mLayoutManager).setSpanSizeLookup(new GridLayoutManager.SpanSizeLookup() {
                    @Override
                    public int getSpanSize(int position) {
                        return position == 0 ? columnCount : 1;
                    }
                });
            }
            recyclerView.setLayoutManager(mLayoutManager);
        }
        recyclerView.setHasFixedSize(false);

        adapter = new Adapter_Products((BaseActivity) getActivity(), new ArrayList<TM_ProductInfo>(), new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View view) {
                if (downloadPanel != null) {
                    showDownloadPanel();
                }
                return false;
            }
        }, new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                setBadgeCount();
            }
        });
        if (AppInfo.ENABLE_MULTIPLE_WISHLIST || AppInfo.ENABLE_SINGLE_CHECK_WISHLIST || ImageDownloaderConfig.isEnabled()) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                downloadPanel = ((ViewGroup) rootView.findViewById(R.id.dynamic_panel));
                FloatingActionButton btn_action = ((FloatingActionButton) rootView.findViewById(R.id.btn_action));
                Helper.stylize(btn_action);
                btn_action.setOnClickListener(new View.OnClickListener() {
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
                                initAddtoCart();
                            }
                        }, new View.OnClickListener() {

                            @Override
                            public void onClick(View view) {
                                initAddToSingleList();
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
                downloadPanel = (ViewGroup) getDownloadPanel(((ViewGroup) rootView.findViewById(R.id.dynamic_panel_v20)));
            }
            selected_product_count_text = (TextView) downloadPanel.findViewById(R.id.selected_product_count_text);
            icon_badge_item_count = (ImageView) downloadPanel.findViewById(R.id.icon_badge);
            Helper.stylizeBadgeView(icon_badge_item_count, selected_product_count_text);
            setBadgeCount();
        }
        //header
        {
            list_header = View.inflate(getActivity(), R.layout.item_header_productlist, null);
            recycler_view_sub_categories = (RecyclerView) list_header.findViewById(R.id.recycler_view_sub_categories);
            recycler_view_sub_categories.setHasFixedSize(false);
            recycler_view_sub_categories.setNestedScrollingEnabled(false);
            adapter.addHeader(list_header);
        }

        //footer
        if (AppInfo.ENABLE_PROMO_BUTTON) {
            list_footer = View.inflate(getActivity(), Adapter_Products.getProductLayoutId(false), null);
            TextView name = (TextView) list_footer.findViewById(R.id.name);
            TextView regular_price = (TextView) list_footer.findViewById(R.id.regular_price);
            TextView sale_price = (TextView) list_footer.findViewById(R.id.sale_price);
            ImageView img = (ImageView) list_footer.findViewById(R.id.img);
            CompoundButton chk_wishlist = (CompoundButton) list_footer.findViewById(R.id.chk_wishlist);
            CardView cv = (CardView) list_footer.findViewById(R.id.cv);
            cv.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Helper.openPromotionUrl(v.getContext());
                }
            });

            name.setText(HtmlCompat.fromHtml(AppInfo.PROMO_TITLE));
            regular_price.setText(HtmlCompat.fromHtml(AppInfo.PROMO_DESC));

            sale_price.setVisibility(View.INVISIBLE);
            chk_wishlist.setVisibility(View.GONE);
            Glide.with(getActivity())
                    .load(AppInfo.PROMO_IMG_URL)
                    .placeholder(R.drawable.ic_promotion)
                    .into(img);

            adapter.addFooter(list_footer);

            if (AppInfo.HIDE_PRODUCT_PRICE_TAG || GuestUserConfig.hidePriceTag()) {
                regular_price.setVisibility(View.GONE);
                sale_price.setVisibility(View.GONE);
            }
        }

        recyclerView.setAdapter(adapter);

        rootView.findViewById(R.id.text_empty).setVisibility(View.GONE);

        progressBar1 = (CircleProgressBar) rootView.findViewById(R.id.progress_bar);
        Helper.stylize(progressBar1);
        resetTaskCount();

        cat_image = (ImageView) list_header.findViewById(R.id.cat_image);
    }

    void bindData() {
        if (shouldShowMoreSubCategories && !mSubCategories.isEmpty()) {
            adapter.setHasSubCategories(true);
            recycler_view_sub_categories.setVisibility(View.VISIBLE);
            RecyclerView.Adapter adapterMoreSubCategories;
            if (!AppInfo.SHOW_IOS_STYLE_SUB_CATEGORIES) {
                adapterMoreSubCategories = new Adapter_MoreSubCategoryList<>(getActivity(), mSubCategories);
                recycler_view_sub_categories.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false));
            } else {
                adapterMoreSubCategories = new CategoryAdapter<>(mSubCategories);
                final int columns = Helper.getCategoryLayoutColumns();
                if (columns > 1) {
                    GridLayoutManager mLayoutManager = new GridLayoutManager(getActivity(), columns);
                    mLayoutManager.setSpanSizeLookup(new GridLayoutManager.SpanSizeLookup() {
                        @Override
                        public int getSpanSize(int position) {
                            if (position > mSubCategories.size()) {
                                return columns;
                            }
                            return 1;
                        }
                    });
                    recycler_view_sub_categories.setLayoutManager(mLayoutManager);
                } else {
                    recycler_view_sub_categories.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false));
                }
            }
            recycler_view_sub_categories.setAdapter(adapterMoreSubCategories);
        } else {
            adapter.setHasSubCategories(false);
            recycler_view_sub_categories.setVisibility(View.GONE);
        }

        if (Helper.isValidString(requestedTitle)) {
            setTitle(requestedTitle);
        }

        if (AppInfo.SHOW_CATEGORY_BANNER && hasHeader && !TextUtils.isEmpty(thisCategory.image)) {
            cat_image.setVisibility(View.VISIBLE);
            if (AppInfo.SHOW_CATEGORY_BANNER_FULL) {
                cat_image.setScaleType(ImageView.ScaleType.FIT_XY);
            } else {
                cat_image.setScaleType(ImageView.ScaleType.CENTER_CROP);
                Display display = getActivity().getWindowManager().getDefaultDisplay();
                Point size = new Point();
                display.getSize(size);

                int windowHeight = (int) (AppInfo.HOME_SLIDER_STANDARD_HEIGHT * size.x * 1.0f / AppInfo.HOME_SLIDER_STANDARD_WIDTH);
                LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, windowHeight);
                cat_image.setLayoutParams(params);
            }
            Glide.with(getActivity())
                    .load(thisCategory.image)
                    .error(Helper.getPlaceholderColor())
                    .into(cat_image);
        } else {
            cat_image.setVisibility(View.GONE);
        }

        if (hasHeader) {
            recyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
                @Override
                public void onScrolled(RecyclerView visibleRecyclerView, int dx, int dy) {
                    if (!enableParallaxScroll) {
                        super.onScrolled(visibleRecyclerView, dx, dy);
                        return;
                    }

                    View view = visibleRecyclerView.getChildAt(0);
                    if (view != null && visibleRecyclerView.getChildAdapterPosition(view) == 0) {
                        view.setTranslationY(-view.getTop() / 2);// or use view.animate().translateY();
                        return;
                    }
                    super.onScrolled(visibleRecyclerView, dx, dy);
                }
            });
        }
        hideDownloadPanelInitially();
        createScrollListener();
        recyclerView.addOnScrollListener(scrollListener);
        loadAvailableProductsInAdapter();
    }

    private void createScrollListener() {
        scrollListener = new EndlessRecyclerOnScrollListener(mLayoutManager) {
            @Override
            public void onLoadMore(final int current_page) {
                // stop auto load after removing it.
                if (getContext() == null) {
                    return;
                }
                final int skipProductsCount;
                if (currentFilter != null) {
                    if (currentFilter.getOffset() > 0) {
                        skipProductsCount = thisCategory.loadedPageCount * currentFilter.getLimit();
                    } else {
                        skipProductsCount = currentFilter.getLimit();
                    }
                    if (skipProductsCount < thisCategory.getStrictProductCount()) {
                        addTaskCount();
                        currentFilter.setOffset(skipProductsCount);
                        DataEngine.getDataEngine().getProductsByFilter(currentFilter, new DataQueryHandler<List<TM_ProductInfo>>() {
                            @Override
                            public void onSuccess(List<TM_ProductInfo> products) {
                                reduceTaskCount();
                                thisCategory.loadedPageCount++;
                                if (products != null && !products.isEmpty()) {
                                    addProducts(products);
                                    if (AppInfo.AUTO_LOAD_MORE_ITEMS && adapter.getDataItemCount() > adapter.getFullyLoadedItemCount()) {
                                        onLoadMore(current_page);
                                    }
                                }
                                notifyLoadCompleted();
                            }

                            @Override
                            public void onFailure(Exception reason) {
                                reduceTaskCount();
                                notifyLoadCompleted();
                            }
                        });
                    }
                } else {
                    if (DataEngine.use_plugin_for_pagging) {
                        skipProductsCount = thisCategory.officiallyLoadedProductsCount;
                    } else {
                        skipProductsCount = thisCategory.loadedPageCount * DataEngine.max_products_query_count_limit;
                    }
                    if (skipProductsCount < thisCategory.getStrictProductCount()) {
                        addTaskCount();
                        int maxProducts = DataEngine.max_products_query_count_limit;
                        if (MultiVendorConfig.isEnabled() && MultiVendorConfig.getScreenType() == MultiVendorConfig.ScreenType.VENDORS) {
                            DataEngine.getDataEngine().getProductsOfCategory(thisCategory.id, SellerInfo.getSelectedSeller().getId(), skipProductsCount, maxProducts, new DataQueryHandler<List<TM_ProductInfo>>() {
                                @Override
                                public void onSuccess(List<TM_ProductInfo> data) {
                                    reduceTaskCount();
                                    thisCategory.loadedPageCount++;
                                    if (data != null && !data.isEmpty()) {
                                        updateProducts(data);
                                    } else {
                                        Helper.toast(coordinatorLayout, L.string.no_more_products_found);
                                    }
                                    notifyLoadCompleted();
                                }

                                @Override
                                public void onFailure(Exception reason) {
                                    reduceTaskCount();
                                    notifyLoadCompleted();
                                }
                            });
                        } else {
                            DataEngine.getDataEngine().getProductsOfCategory(thisCategory.id, skipProductsCount, 0, maxProducts, new DataQueryHandler<List<TM_ProductInfo>>() {
                                @Override
                                public void onSuccess(List<TM_ProductInfo> data) {
                                    reduceTaskCount();
                                    thisCategory.loadedPageCount++;
                                    if (data != null && !data.isEmpty()) {
                                        if (currentFilter == null) {
                                            addProducts(data);
                                            if (AppInfo.AUTO_LOAD_MORE_ITEMS && adapter.getDataItemCount() > adapter.getFullyLoadedItemCount()) {
                                                onLoadMore(current_page);
                                            }
                                        }
                                    } else {
                                        Helper.toast(coordinatorLayout, L.string.no_more_products_found);
                                    }
                                    notifyLoadCompleted();
                                }

                                @Override
                                public void onFailure(Exception reason) {
                                    reduceTaskCount();
                                    notifyLoadCompleted();
                                }
                            });
                        }
                    }
                }
            }

            @Override
            public int getTotalItemCount() {
                if (DataEngine.use_plugin_for_pagging) {
                    return thisCategory.officiallyLoadedProductsCount;
                } else {
                    return thisCategory.loadedPageCount * DataEngine.max_products_query_count_limit;
                }
            }
        };
    }

    public void loadAvailableProductsInAdapter() {
        if (!shouldShowMoreSubCategories) {
            if (thisCategory.isProductRefreshed) {
                if (DataEngine.show_child_cat_products_in_parent_cat) {
                    updateProducts(TM_ProductInfo.getAllForCategory(thisCategory));
                } else {
                    updateProducts(TM_ProductInfo.getOnlyForCategory(thisCategory));
                }
            } else {
                MainActivity.mActivity.getProductsOfCategory(thisCategory, new TaskListener() {
                    @Override
                    public void onTaskDone() {
                        if (DataEngine.show_child_cat_products_in_parent_cat) {
                            updateProducts(TM_ProductInfo.getAllForCategory(thisCategory));
                        } else {
                            updateProducts(TM_ProductInfo.getOnlyForCategory(thisCategory));
                        }
                    }

                    @Override
                    public void onTaskFailed(String err_string) {
                        Log.d("-- getProductsOfCategory::onTaskFailed [ " + err_string + " ] --");
                    }
                });
            }
        } else {
            if (thisCategory.getStrictProductCount() == 0 && DataEngine.show_child_cat_products_in_parent_cat) {
                updateProducts(TM_ProductInfo.getAllForCategory(thisCategory));
            } else {
                updateProducts(TM_ProductInfo.getOnlyForCategory(thisCategory));
            }
        }

        if (AppInfo.AUTO_LOAD_MORE_ITEMS && thisCategory.isProductRefreshed && adapter.getDataItemCount() < thisCategory.getStrictProductCount()) {
            scrollListener.onLoadMore(-1);
        }
    }

    void updateProducts(List<TM_ProductInfo> newProducts) {
        adapter.setSortOrder(currentFilter != null ? currentFilter.getSortOrder() : -1);
        adapter.updateResult(newProducts, currentFilter);
    }

    void addProducts(List<TM_ProductInfo> newProducts) {
        adapter.setSortOrder(currentFilter != null ? currentFilter.getSortOrder() : -1);
        adapter.addProducts(newProducts);
    }

    void clearUserFilter() {
        this.currentFilter = null;
    }

    void updateUiFromFilter(UserFilter filter) {
        currentFilter = filter;
        if (currentFilter != null) {
            list_header.setVisibility(View.GONE);
        } else if (list_header.getVisibility() != View.VISIBLE && !slideAnimationInProgress) {
            list_header.setVisibility(View.VISIBLE);
        }
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        resetTitleBar();
        enableParallaxScroll = mSubCategories.isEmpty();
        if (mOnFragmentCreateListener != null) {
            mOnFragmentCreateListener.onFragmentCreated(this);
        }
    }

    private void resetTitleBar() {
        ((MainActivity) getActivity()).reloadMenu();
    }

    @Override
    public void onStart() {
        super.onStart();
        if (AppInfo.basic_content_loading) {
            addTaskCount();
        }
    }

    void updateProgressStatus() {
        if (numTasks > 0)
            progressBar1.setVisibility(View.VISIBLE);
        else
            progressBar1.setVisibility(View.GONE);
    }

    private void resetTaskCount() {
        numTasks = 0;
        updateProgressStatus();
    }

    public void addTaskCount() {
        numTasks++;
        updateProgressStatus();
    }

    public void reduceTaskCount() {
        numTasks--;
        updateProgressStatus();
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
                        initAddtoCart();
                    }
                }, new View.OnClickListener() {

                    @Override
                    public void onClick(View view) {
                        initAddToSingleList();
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

    public void refreshAdapter() {
        if (AppInfo.ENABLE_MULTIPLE_WISHLIST || AppInfo.ENABLE_SINGLE_CHECK_WISHLIST || ImageDownloaderConfig.isEnabled()) {
            adapter.resetAdapterForCheckBox();
            setBadgeCount();
        }
    }

    private void showDownloadChkBoxesInAdapter() {
        adapter.setCheckMode(true);
    }

    private void openWishGroupListAndAddProduct() {
        HashMap<Integer, Boolean> map = Adapter_Products.mCheckedItem;
        for (Map.Entry<Integer, Boolean> entry : map.entrySet()) {
            Integer key = entry.getKey();
            Boolean value = entry.getValue();
            TM_ProductInfo product = TM_ProductInfo.getProductWithId(key);
            if (product != null && value) {
                WishListGroup.selectedProductToAddInWishList.add(product);
            }
        }
        refreshAdapter();
    }

    private void setBadgeCount() {
        int count = getItemCount();
        selected_product_count_text.setText(String.valueOf(count));
        selected_product_count_text.setVisibility(count > 0 ? View.VISIBLE : View.GONE);
        icon_badge_item_count.setVisibility(count > 0 ? View.VISIBLE : View.GONE);
        if (count > 0) {
            showDownloadPanel();
            CategoryFragment.isShowingDownloadPanel = true;
        } else {
            hideDownloadPanel();
            CategoryFragment.isShowingDownloadPanel = false;
        }
    }

    private int getItemCount() {
        HashMap<Integer, Boolean> map = Adapter_Products.mCheckedItem;
        int count = 0;
        for (Map.Entry<Integer, Boolean> entry : map.entrySet()) {
            Integer key = entry.getKey();
            Boolean value = entry.getValue();
            if (value) {
                count++;
            }
        }
        return count;
    }

    private void hideDownloadPanelInitially() {
        if (downloadPanel != null) {
            downloadPanel.setVisibility(View.GONE);
            isDownloadPanelAnimRunning = false;
        }
    }

    private void hideDownloadPanel() {
        if (downloadPanel.getVisibility() != View.GONE) {
            isDownloadPanelAnimRunning = true;
            downloadPanel.animate()
                    .translationY(0)
                    .alpha(0.0f)
                    .setDuration(300)
                    .setListener(new AnimatorListenerAdapter() {
                        @Override
                        public void onAnimationEnd(Animator animation) {
                            super.onAnimationEnd(animation);
                            downloadPanel.setVisibility(View.GONE);
                            isDownloadPanelAnimRunning = false;
                        }
                    });
        }
        Helper.hideSelectMultipleActionButtons(downloadPanel);
    }

    private void showDownloadPanel() {
        if (downloadPanel.getVisibility() != View.VISIBLE) {
            isDownloadPanelAnimRunning = true;
            downloadPanel.setVisibility(View.VISIBLE);
            downloadPanel.animate()
                    .translationY(0)
                    .alpha(1.0f)
                    .setDuration(300)
                    .setListener(new AnimatorListenerAdapter() {
                        @Override
                        public void onAnimationEnd(Animator animation) {
                            super.onAnimationEnd(animation);
                            isDownloadPanelAnimRunning = false;
                        }
                    });
        }
        Helper.hideSelectMultipleActionButtons(downloadPanel);
    }

    public void setLM(int layoutId, ImageButton btn_switchlist_grid) {
        Adapter_Products.ID_LAYOUT_PRODUCTS = layoutId;

        if (Adapter_Products.ID_LAYOUT_PRODUCTS == 1 || Adapter_Products.ID_LAYOUT_PRODUCTS == 2 || Adapter_Products.ID_LAYOUT_PRODUCTS == 4) {
            btn_switchlist_grid.setImageDrawable(CContext.getDrawable(getActivity(), R.drawable.ic_vc_view_list));
        } else {
            btn_switchlist_grid.setImageDrawable(CContext.getDrawable(getActivity(), R.drawable.ic_vc_view_grid));
        }

        if (recyclerView != null) {
            RecyclerView.LayoutManager mLayoutManager;
            final int columnCount = Adapter_Products.getProductLayoutColumnCount();
            if (Adapter_Products.ID_LAYOUT_PRODUCTS == 3) {
                mLayoutManager = new StaggeredGridLayoutManager(columnCount, StaggeredGridLayoutManager.VERTICAL);
                ((StaggeredGridLayoutManager) mLayoutManager).setGapStrategy(StaggeredGridLayoutManager.GAP_HANDLING_MOVE_ITEMS_BETWEEN_SPANS);
                recyclerView.setLayoutManager(mLayoutManager);
                //mLayoutManager = layoutManager2;
            } else {
                mLayoutManager = new GridLayoutManager(getActivity(), columnCount);
                if (hasHeader) {
                    ((GridLayoutManager) mLayoutManager).setSpanSizeLookup(new GridLayoutManager.SpanSizeLookup() {
                        @Override
                        public int getSpanSize(int position) {
                            return position == 0 ? columnCount : 1;
                        }
                    });
                }
                recyclerView.setLayoutManager(mLayoutManager);
            }
            recyclerView.setHasFixedSize(false);

            adapter.notifyDataSetChanged();
            recyclerView.setAdapter(adapter);
            adapter.notifyDataSetChanged();
        }
    }

    private void initShare() {
        new AsyncTask<Void, Void, ArrayList<Uri>>() {
            @Override
            protected ArrayList<Uri> doInBackground(Void... voids) {
                MainActivity.mActivity.showProgress(getString(L.string.loading), false);
                return Helper.getImageUriList(getActivity(), Adapter_Products.mCheckedItem);
            }

            @Override
            protected void onPostExecute(ArrayList<Uri> result) {
                super.onPostExecute(result);
                Helper.shareOnWhatsApp("", result);
                MainActivity.mActivity.hideProgress();
                adapter.checkMode = false;
                refreshAdapter();
            }
        }.execute();

    }

    private void initAddToSingleList() {
        openWishGroupListAndAddProduct();
        if (WishListGroup.selectedProductToAddInWishList.size() == 0) {
            Helper.toast(L.string.no_products);
            refreshAdapter();
            return;
        }

        WishListGroup wishListGroup = WishListGroup.getWishListGroupById(WishListGroup.getdefaultWishGroupID());
        if (AppInfo.ENABLE_MULTIPLE_WISHLIST && AppUser.hasSignedIn()) {
            if (wishListGroup != null) {
                addProductInSingleWishList(wishListGroup);
            } else {
                MainActivity.mActivity.openWishlistFragment(false);
                Fragment_Wishlist_Dialog.setOnWishGroupCreatedListener(new WishGroupCreatedListener() {
                    @Override
                    public boolean onSuccess(WishListGroup wg) {

                        addProductInSingleWishList(wg);
                        MainActivity.mActivity.popBackWishFragment();
                        return true;
                    }
                });
            }
        } else if (AppInfo.ENABLE_SINGLE_CHECK_WISHLIST) {
            if (WishListGroup.allwishListGroup.size() > 0) {
                for (TM_ProductInfo product : WishListGroup.selectedProductToAddInWishList) {
                    if (!WishListGroup.hasChild(wishListGroup.id, product)) {
                        Wishlist.addProduct(product, wishListGroup);
                    }
                }
                WishListGroup.selectedProductToAddInWishList.clear();
                Helper.toast(getString(L.string.item_added_to_wishlist));
                refreshAdapter();
                MainActivity.mActivity.reloadMenu();
            } else {
                MainActivity.mActivity.openWishlistFragment(false);
                Fragment_Wishlist_Dialog.setOnWishGroupCreatedListener(new WishGroupCreatedListener() {
                    @Override
                    public boolean onSuccess(WishListGroup wishListGroup) {
                        for (TM_ProductInfo product : WishListGroup.selectedProductToAddInWishList) {
                            if (!WishListGroup.hasChild(wishListGroup.id, product)) {
                                Wishlist.addProduct(product, wishListGroup);
                            }
                        }
                        WishListGroup.selectedProductToAddInWishList.clear();
                        Helper.toast(getString(L.string.item_added_to_wishlist));
                        refreshAdapter();
                        MainActivity.mActivity.reloadMenu();
                        MainActivity.mActivity.popBackWishFragment();
                        return true;
                    }
                });
            }
        } else {
            for (TM_ProductInfo product : WishListGroup.selectedProductToAddInWishList) {
                Wishlist.addProduct(product, wishListGroup);
            }

            WishListGroup.selectedProductToAddInWishList.clear();
            Helper.toast(getString(L.string.item_added_to_wishlist));
            refreshAdapter();
            MainActivity.mActivity.reloadMenu();
        }
    }

    private void initAddtoCart() {
        if (AppInfo.mGuestUserConfig != null && AppInfo.mGuestUserConfig.isEnabled() && AppInfo.mGuestUserConfig.isPreventCart() && AppUser.isAnonymous()) {
            Helper.toast(L.string.you_need_to_login_first);
            return;
        }
        openWishGroupListAndAddProduct();

        if (WishListGroup.selectedProductToAddInWishList.size() == 0) {
            Helper.toast(L.string.no_products);
            refreshAdapter();
            return;
        }
        final List<TM_ProductInfo> addprodtocart = new ArrayList<>();
        boolean isAdded = false;
        boolean isoutofstock = false;
        boolean isAttributes = false;
        for (TM_ProductInfo product : WishListGroup.selectedProductToAddInWishList) {
            if (!product.hasAttributes()) {
                if (product.in_stock) {
                    if (Cart.hasItem(product)) {
                        isAdded = true;
                    } else
                        addprodtocart.add(product);
                } else {
                    isoutofstock = true;
                }
            } else {
                isAttributes = true;
            }
        }
        if (isAttributes || isoutofstock || isAdded) {
            String msg = "";
            String title = "";
            if (isAttributes) {
                msg = getString(L.string.adding_attribute_error);
                title = getString(L.string.title_contains_attribute);
            }
            if (isoutofstock) {
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
                    if (isAnyAdded)
                        Helper.toast(getString(L.string.item_added_to_cart));
                    WishListGroup.selectedProductToAddInWishList.clear();
                    return false;
                }
            });
        } else {
            for (TM_ProductInfo product : addprodtocart) {
                Cart.addProduct(product);
            }
            WishListGroup.selectedProductToAddInWishList.clear();
            Helper.toast(getString(L.string.item_added_to_cart));
        }
    }

    private void initAddtoMultipleList() {
        openWishGroupListAndAddProduct();
        if (WishListGroup.selectedProductToAddInWishList.size() == 0) {
            Helper.toast(L.string.no_products);
            refreshAdapter();
            return;
        }

        Fragment_Wishlist_Dialog.OpenWishGroupDialogWishCheckbox(WishListGroup.selectedProductToAddInWishList, new WishListDialogHandler() {
            @Override
            public void onSelectGroupSuccess(TM_ProductInfo product, WishListGroup obj) {

                WishListGroup.selectedProductToAddInWishList.clear();
            }

            @Override
            public void onSelectGroupFailed(String cause) {

            }

            @Override
            public void onSkipDialog(TM_ProductInfo product, WishListGroup obj) {

            }
        });
    }

    private void initDownloadTask() {
        boolean isStarted = false;
        for (Map.Entry<Integer, Boolean> entry : Adapter_Products.mCheckedItem.entrySet()) {
            TM_ProductInfo product = TM_ProductInfo.getProductWithId(entry.getKey());
            if (product != null && entry.getValue()) {
                isStarted = true;
                ImageDownload.downloadProductCatalog(getActivity(), product);
            }
        }
        Toast.makeText(getActivity(), isStarted ? getString(L.string.download_initiated) : getString(L.string.no_products), Toast.LENGTH_SHORT).show();
        refreshAdapter();
    }

    public void addProductInSingleWishList(final WishListGroup wishListGroup) {
        List<WishListGroup> mylist = new ArrayList<>();
        wishListGroup.isChecked = true;
        mylist.add(wishListGroup);

        String str = WishListGroup.getPidsArrayString(mylist, WishListGroup.selectedProductToAddInWishList);
        MainActivity.mActivity.showProgress(getString(L.string.please_wait));
        WishListGroup.addProductsToMultipleWishList(str, new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {

                MainActivity.mActivity.hideProgress();
                refreshAdapter();
                WishListGroup.selectedProductToAddInWishList.clear();
                Helper.toast(Helper.showItemAddedToWishListToast(wishListGroup));
            }

            @Override
            public void onFailure(Exception error) {
                MainActivity.mActivity.hideProgress();
                MainActivity.mActivity.showProgress(getString(L.string.retry));
            }
        });
    }

    public void resetRecyclerView() {
        recyclerView.removeOnScrollListener(scrollListener);
        createScrollListener();
        recyclerView.addOnScrollListener(scrollListener);
    }
}