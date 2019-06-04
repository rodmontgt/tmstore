package com.twist.tmstore.fragments;

import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.design.widget.FloatingActionButton;
import android.support.v4.content.ContextCompat;
import android.support.v4.graphics.drawable.DrawableCompat;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.app.ActionBar;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.TextPaint;
import android.text.TextUtils;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.animation.GlideAnimation;
import com.bumptech.glide.request.target.SimpleTarget;
import com.twist.dataengine.DataEngine;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.entities.SellerInfo;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.BaseActivity;
import com.twist.tmstore.adapters.Adapter_VendorProducts;
import com.twist.tmstore.config.MultiVendorConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.listeners.EndlessRecyclerOnScrollListener;
import com.utils.CContext;
import com.utils.Helper;
import com.utils.StringUtils;
import com.utils.customviews.RoundedImageView;
import com.utils.customviews.progressbar.CircleProgressBar;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class Fragment_SellerProducts extends BaseFragment {

    private CircleProgressBar progressBar;
    private View coordinatorLayout;
    private RecyclerView recyclerView;
    private Adapter_VendorProducts adapter = null;
    private RecyclerView.LayoutManager mLayoutManager;
    private SwipeRefreshLayout swipeRefreshLayout;

    private boolean enableParallaxScroll = false;

    private SellerInfo mSellerInfo;

    private final int MAX_PRODUCTS_TO_FETCH = 20;

    private int totalProductsCount = 0;

    private boolean shouldShowSellerInfo = true;

    private List<TM_ProductInfo> vendorProducts = new ArrayList<>();

    private String mVendorId = "";
    private boolean mShowOptions = false;

    private TextView nameView;
    private TextView locationView;
    private TextView shopNameView;
    private TextView vendorPhoneView;
    private TextView shopAddressView;

    public static Fragment_SellerProducts newInstance(SellerInfo sellerInfo, boolean shouldShowSellerInfo, boolean showOptions) {
        Fragment_SellerProducts fragment = new Fragment_SellerProducts();
        fragment.mSellerInfo = sellerInfo;
        fragment.shouldShowSellerInfo = shouldShowSellerInfo;
        fragment.mShowOptions = showOptions;
        return fragment;
    }

    @Override
    public void onResume() {
        super.onResume();
        if (adapter != null) {
            adapter.notifyDataSetChanged();
        }
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (MultiVendorConfig.isSellerApp()) {
            setHasOptionsMenu(true);
            ActionBar actionBar = getSupportActionBar();
            if (actionBar != null) {
                actionBar.setHomeButtonEnabled(true);
                actionBar.setDisplayHomeAsUpEnabled(true);
                Drawable upArrow = CContext.getDrawable(getActivity(), R.drawable.abc_ic_ab_back_material);
                upArrow.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_ATOP);
                actionBar.setHomeAsUpIndicator(upArrow);
            }
        }
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
        if (MultiVendorConfig.isSellerApp()) {
            menu.clear();
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        Helper.gc();
        View rootView = inflater.inflate(R.layout.fragment_vendor_products, container, false);
        initComponents(rootView);
        bindData();
        registerViewPagerKeyListenerOnView(rootView);
        return rootView;
    }

    void initComponents(final View rootView) {
        coordinatorLayout = rootView.findViewById(R.id.coordinatorLayout);
        recyclerView = (RecyclerView) rootView.findViewById(R.id.recyclerView);
        swipeRefreshLayout = (SwipeRefreshLayout) rootView.findViewById(R.id.swipeContainer);
        swipeRefreshLayout.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                swipeRefreshLayout.setRefreshing(true);
                loadProducts(false);
            }
        });
        swipeRefreshLayout.setColorSchemeResources(
                R.color.material_color_17,
                R.color.material_color_11,
                R.color.material_color_09,
                R.color.material_color_04);

        final int columnCount = 2;

        mLayoutManager = new GridLayoutManager(getActivity(), columnCount);
        if (shouldShowSellerInfo) {
            ((GridLayoutManager) mLayoutManager).setSpanSizeLookup(new GridLayoutManager.SpanSizeLookup() {
                @Override
                public int getSpanSize(int position) {
                    return position == 0 ? columnCount : 1;
                }
            });
        }
        recyclerView.setLayoutManager(mLayoutManager);
        recyclerView.setHasFixedSize(false);

        if (mSellerInfo != null) {
            mVendorId = mSellerInfo.getId();
        } else {
            mVendorId += AppUser.getUserId();
        }

        adapter = new Adapter_VendorProducts((BaseActivity) getActivity(), mVendorId, vendorProducts, mShowOptions);

        recyclerView.setAdapter(adapter);

        rootView.findViewById(R.id.text_empty).setVisibility(View.GONE);

        progressBar = (CircleProgressBar) rootView.findViewById(R.id.progress_bar);
        Helper.stylize(progressBar);

        showAddProductButton(rootView);

        resetTaskCount();

        totalProductsCount = MAX_PRODUCTS_TO_FETCH;

        if (mSellerInfo != null && shouldShowSellerInfo) {
            View headerView = View.inflate(getActivity(), R.layout.vendor_profile_header, null);
            adapter.addHeader(headerView);
            setVendorProfile(headerView);
        }
    }

    private void bindData() {
        adapter.setHasSubCategories(false);
        if (shouldShowSellerInfo) {
            recyclerView.addOnScrollListener(new RecyclerView.OnScrollListener() {
                @Override
                public void onScrolled(RecyclerView visibleRecyclerView, int dx, int dy) {
                    if (!enableParallaxScroll) {
                        super.onScrolled(visibleRecyclerView, dx, dy);
                        return;
                    }

                    View view = visibleRecyclerView.getChildAt(0);
                    if (view != null && visibleRecyclerView.getChildAdapterPosition(view) == 0) {
                        view.setTranslationY(-view.getTop() / 2);
                        return;
                    }
                    super.onScrolled(visibleRecyclerView, dx, dy);
                }
            });
        }
        recyclerView.addOnScrollListener(new EndlessRecyclerOnScrollListener(mLayoutManager) {
            @Override
            public void onLoadMore(final int current_page) {
                progressBar.setVisibility(View.VISIBLE);
                final int skipProductsCount = vendorProducts.size();
                if (skipProductsCount < totalProductsCount) {
                    addTaskCount();
                    int maxProducts = DataEngine.max_products_query_count_limit;
                    DataEngine.getDataEngine().getProductsOfCategory(-1, mVendorId, skipProductsCount, maxProducts, new DataQueryHandler<List<TM_ProductInfo>>() {
                        @Override
                        public void onSuccess(List<TM_ProductInfo> data) {
                            reduceTaskCount();
                            progressBar.setVisibility(View.GONE);
                            if (data != null && !data.isEmpty()) {
                                adapter.addProducts(data);
                            } else {
                                Helper.toast(coordinatorLayout, L.string.no_more_products_found);
                            }
                            notifyLoadCompleted();
                            totalProductsCount += MAX_PRODUCTS_TO_FETCH;

                        }

                        @Override
                        public void onFailure(Exception reason) {
                            reduceTaskCount();
                            notifyLoadCompleted();
                            progressBar.setVisibility(View.GONE);
                        }
                    });
                }
            }

            @Override
            public int getTotalItemCount() {
                return totalProductsCount;
            }
        });
        loadProducts(true);
    }

    public void removeProduct(int productId) {
        adapter.removeProduct(productId);
    }

    public void updateProduct(int productId) {
    }

    public void loadProducts(boolean showProgress) {
        if (!showProgress) {
            progressBar.setVisibility(View.GONE);
        } else {
            progressBar.setVisibility(View.VISIBLE);
        }
        int maxProducts = DataEngine.max_products_query_count_limit;

        DataEngine.getDataEngine().getProductsOfCategory(-1, mVendorId, 0, maxProducts, new DataQueryHandler<List<TM_ProductInfo>>() {
            @Override
            public void onSuccess(List<TM_ProductInfo> data) {

                reduceTaskCount();
                if (data != null && !data.isEmpty()) {
                    adapter.addProducts(data);
                } else {
                    Helper.toast(coordinatorLayout, L.string.no_more_products_found);
                }
                totalProductsCount += MAX_PRODUCTS_TO_FETCH;
                progressBar.setVisibility(View.GONE);
                swipeRefreshLayout.setRefreshing(false);

            }

            @Override
            public void onFailure(Exception reason) {
                progressBar.setVisibility(View.GONE);
                swipeRefreshLayout.setRefreshing(false);
                reduceTaskCount();
            }
        });
    }

    public void updateProducts(List<TM_ProductInfo> newProducts) {
        adapter.updateResult(newProducts);
    }

    void updateProgressStatus() {
        if (numTasks > 0)
            progressBar.setVisibility(View.VISIBLE);
        else
            progressBar.setVisibility(View.GONE);
    }

    private int numTasks = 0;

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

    private void showAddProductButton(final View rootView) {
        FloatingActionButton btn_add_new = (FloatingActionButton) rootView.findViewById(R.id.btn_add_new);
        Helper.stylize(btn_add_new);
        if (!mShowOptions) {
            btn_add_new.setVisibility(View.GONE);
            return;
        } else {
            btn_add_new.setVisibility(View.VISIBLE);
        }

        btn_add_new.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                MainActivity.mActivity.showUpdateProduct(-1);
            }
        });

        if (AppUser.isVendor()) {
            if (MultiVendorConfig.getScreenType() == MultiVendorConfig.ScreenType.VENDORS) {
                if (mSellerInfo != null && mVendorId.equals(String.valueOf(AppUser.getUserId()))) {
                    btn_add_new.setVisibility(View.VISIBLE);
                    return;
                }
            } else {
                btn_add_new.setVisibility(View.VISIBLE);
                return;
            }
        }
        btn_add_new.setVisibility(View.GONE);
    }

    private void setVendorProfile(View parentView) {
        View view = parentView.findViewById(R.id.vendor_profile_header);
        if (view == null) {
            return;
        }

        if (mSellerInfo == null) {
            view.setVisibility(View.GONE);
            return;
        }

        final String sellerName = mSellerInfo.getTitle();
        if (TextUtils.isEmpty(sellerName)) {
            view.setVisibility(View.GONE);
            return;
        }

        setTitle(sellerName);

        LinearLayout seller_detail = (LinearLayout) view.findViewById(R.id.seller_detail_section);
        seller_detail.setVisibility(View.VISIBLE);
        String[] layoutOrder = MultiVendorConfig.getLayoutOrder();
        if (layoutOrder != null && layoutOrder.length > 0) {
            for (String str : layoutOrder) {
                switch (str) {
                    case MultiVendorConfig.ID_NAME: {
                        nameView = addNewTextView(seller_detail);
                        nameView.setText(sellerName);
                        nameView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 20);
                        nameView.setTypeface(Typeface.DEFAULT_BOLD);
                        nameView.setTextColor(CContext.getColor(getContext(), R.color.normal_text_color));
                        break;
                    }

                    case MultiVendorConfig.ID_LOCATION: {
                        locationView = addNewTextView(seller_detail);
                        locationView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18);
                        locationView.setTextColor(CContext.getColor(getContext(), R.color.normal_text_color_lite));
                        String strLocation = mSellerInfo.getSellerFirstLocation();
                        if (TextUtils.isEmpty(strLocation)) {
                            locationView.setVisibility(View.GONE);
                        } else {
                            locationView.setVisibility(View.VISIBLE);
                            locationView.setText(strLocation);
                        }
                        break;
                    }

                    case MultiVendorConfig.ID_SHOP_NAME: {
                        shopNameView = addNewTextView(seller_detail);
                        shopNameView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18);
                        shopNameView.setTextColor(CContext.getColor(getContext(), R.color.normal_text_color_lite));
                        String strShopName = mSellerInfo.getShopName();
                        if (TextUtils.isEmpty(strShopName)) {
                            shopNameView.setVisibility(View.GONE);
                        } else {
                            shopNameView.setVisibility(View.VISIBLE);
                            shopNameView.setText(strShopName);
                        }
                        break;
                    }

                    case MultiVendorConfig.ID_PHONE_NUMBER: {
                        vendorPhoneView = addNewTextView(seller_detail);
                        vendorPhoneView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18);
                        vendorPhoneView.setTextColor(CContext.getColor(getContext(), R.color.normal_text_color_lite));
                        String phoneNumber = mSellerInfo.getPhoneNumber();
                        if (TextUtils.isEmpty(phoneNumber)) {
                            vendorPhoneView.setVisibility(View.GONE);
                        } else {
                            vendorPhoneView.setVisibility(View.VISIBLE);
                            vendorPhoneView.setText(phoneNumber);
                        }
                        break;
                    }

                    case MultiVendorConfig.ID_SHOP_ADDRESS: {
                        shopAddressView = addNewTextView(seller_detail);
                        shopAddressView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18);
                        shopAddressView.setTextColor(CContext.getColor(getContext(), R.color.normal_text_color_lite));
                        String strShopAddress = mSellerInfo.getShopAddress();
                        if (TextUtils.isEmpty(strShopAddress)) {
                            shopAddressView.setVisibility(View.GONE);
                        } else {
                            shopAddressView.setVisibility(View.VISIBLE);
                            shopAddressView.setText(strShopAddress);
                        }
                        break;
                    }
                }
            }
        }

        final ImageButton image_vendor_edit_shop_info = (ImageButton) view.findViewById(R.id.image_vendor_edit_shop_info);
        image_vendor_edit_shop_info.setVisibility(View.GONE);

        final RoundedImageView imageView = (RoundedImageView) view.findViewById(R.id.image_vendor_icon);

        if (TextUtils.isEmpty(mSellerInfo.getAvatarUrl())) {
            this.createSellerIconFromName(mSellerInfo, imageView, locationView);
        } else {
            Glide.with(getActivity())
                    .load(mSellerInfo.getAvatarUrl())
                    .asBitmap()
                    .placeholder(Helper.getPlaceholderColor())
                    .into(new SimpleTarget<Bitmap>() {
                        @Override
                        public void onResourceReady(Bitmap resource, GlideAnimation<? super Bitmap> glideAnimation) {
                            imageView.setImageBitmap(resource);
                        }
                    });
        }
    }

    public TextView addNewTextView(LinearLayout layout) {
        TextView labelText = new TextView(getActivity());
        labelText.setPadding(Helper.DP(12), Helper.DP(6), Helper.DP(12), Helper.DP(6));
        labelText.setGravity(Gravity.CENTER | Gravity.CENTER_HORIZONTAL);
        layout.addView(labelText, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        return labelText;
    }

    private void createSellerIconFromName(SellerInfo vendor, ImageView imageView, TextView locationView) {
        String sellerID = vendor.getId();
        if (TextUtils.isEmpty(sellerID)) {
            sellerID = "0";
        }

        Resources resources = getActivity().getResources();
        int[] colors = resources.getIntArray(R.array.material_colors);
        Random random = new Random();
        try {
            random.setSeed(Long.parseLong(sellerID));
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }

        int backgroundColor = colors[random.nextInt(colors.length - 1)];
        String strokeColor = String.format("#66%06X", 0xFFFFFF & backgroundColor);

        GradientDrawable drawable = new GradientDrawable();
        drawable.setShape(GradientDrawable.RECTANGLE);
        drawable.setCornerRadius(Helper.DP(4));
        drawable.setColor(backgroundColor);
        drawable.setStroke(Helper.DP(4), Color.parseColor(strokeColor));
        imageView.setBackground(drawable);

        int iconWidth = resources.getDimensionPixelSize(R.dimen.vendor_icon_large_width);
        int iconHeight = resources.getDimensionPixelSize(R.dimen.vendor_icon_large_height);

        Bitmap bitmap = Bitmap.createBitmap(iconWidth, iconHeight, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);

        final int textSize = resources.getDimensionPixelSize(R.dimen.vendor_icon_large_text_size);
        TextPaint paint = new TextPaint();
        paint.setTypeface(Typeface.create(Typeface.SANS_SERIF, Typeface.BOLD));
        paint.setColor(Color.WHITE);
        paint.setTextAlign(Paint.Align.CENTER);
        paint.setTextSize(textSize);
        paint.setAntiAlias(true);

        String sellerName;
        if (!TextUtils.isEmpty(vendor.getShopName())) {
            sellerName = vendor.getShopName();
        } else {
            sellerName = vendor.getTitle();
        }
        String initials = StringUtils.getInitials(sellerName, 2);

        Rect textBounds = new Rect();
        paint.getTextBounds(initials, 0, initials.length() - 1, textBounds);
        canvas.drawText(initials, iconWidth / 2, (iconHeight + textBounds.height()) / 2, paint);
        imageView.setImageBitmap(bitmap);
        if (locationView != null) {
            if (Helper.isValidString(vendor.getSellerFirstLocation())) {
                Drawable locationDrawable = ContextCompat.getDrawable(getContext(), R.drawable.ic_vc_location);
                DrawableCompat.setTint(locationDrawable, backgroundColor);
                locationView.setCompoundDrawablesWithIntrinsicBounds(locationDrawable, null, null, null);
                locationView.setText(vendor.getSellerFirstLocation());
                locationView.setVisibility(View.VISIBLE);
            } else {
                locationView.setVisibility(View.GONE);
            }
        }
    }
}