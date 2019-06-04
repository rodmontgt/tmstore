package com.twist.tmstore.views;

import android.content.Context;
import android.graphics.Color;
import android.support.v7.widget.CardView;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.GridLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.daimajia.slider.library.Indicators.PagerIndicator;
import com.daimajia.slider.library.SliderLayout;
import com.daimajia.slider.library.SliderTypes.BaseSliderView;
import com.daimajia.slider.library.SliderTypes.DefaultSliderView;
import com.twist.dataengine.DataEngine;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.entities.SellerInfo;
import com.twist.dataengine.entities.TM_CategoryInfo;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.Adapter_ScrollView;
import com.twist.tmstore.config.MultiVendorConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.CategoryItem;
import com.twist.tmstore.entities.HomeElementUltimate;
import com.twist.tmstore.entities.RecentlyViewedItem;
import com.twist.tmstore.listeners.TaskListener;
import com.utils.CContext;
import com.utils.Helper;
import com.utils.HtmlCompat;

import java.util.ArrayList;
import java.util.List;

import static com.twist.tmstore.L.getString;


/**
 * Created by Twist Mobile on 9/7/2016.
 */

public class TileView {

    private static void setBgImageInView(View view, HomeElementUltimate element) {
        ImageView img = (ImageView) view.findViewById(R.id.img);
        img.setVisibility(View.GONE);
        if (element.variables != null) {
            if (element.variables.tileStyle != null) {
                if (Helper.isValidString(element.variables.tileStyle.bgUrl)) {
                    img.setVisibility(View.VISIBLE);
                    Glide.with(img.getContext())
                            .load(element.variables.tileStyle.bgUrl)
                            .into(img);
                } else if (Helper.isValidString(element.variables.tileStyle.bgcolor)) {
                    img.setVisibility(View.VISIBLE);
                    try {
                        img.setBackgroundColor(Color.parseColor(element.variables.tileStyle.bgcolor));
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        }
    }

    private static void setBgImageInView(ImageView img, HomeElementUltimate element) {
        if (element.variables.tileStyle != null) {
            if (Helper.isValidString(element.variables.tileStyle.bgUrl)) {
                img.setVisibility(View.VISIBLE);
                Glide.with(img.getContext())
                        .load(element.variables.tileStyle.bgUrl)
                        .into(img);
            } else if (Helper.isValidString(element.variables.tileStyle.bgcolor)) {
                img.setVisibility(View.VISIBLE);
                try {
                    img.setBackgroundColor(Color.parseColor(element.variables.tileStyle.bgcolor));
                } catch (Exception e) {
                    e.printStackTrace();
                }
            } else {
                img.setVisibility(View.GONE);
            }
        } else {
            img.setVisibility(View.GONE);
        }
    }

    public static View generateEmptyTile(Context context, HomeElementUltimate element) {
        View view = View.inflate(context, R.layout.tile_empty_0, null);
        setBgImageInView(view, element);
        return view;
    }

    public static View generateSliderTile(Context context, HomeElementUltimate element) {
        FrameLayout rootView = new FrameLayout(context);

        RelativeLayout view = new RelativeLayout(context);

        ImageView img = new ImageView(context);
        img.setScaleType(ImageView.ScaleType.CENTER_CROP);
        view.addView(img, new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        setBgImageInView(img, element);

        try {
            LinearLayout name_section = new LinearLayout(context);
            name_section.setId(R.id.name_section);
            name_section.setPadding(Helper.DP(5), Helper.DP(5), Helper.DP(5), Helper.DP(5));
            RelativeLayout.LayoutParams textSectionLayoutParam = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            if (element.variables.tileStyle != null) {
                try {
                    name_section.setBackgroundColor(Color.parseColor(element.variables.tileStyle.textbgcolor));
                } catch (Exception e) {
                }
            }

            LinearLayout.LayoutParams textLayoutParam = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            TextView title = new TextView(context);
            title.setPadding(Helper.DP(5), Helper.DP(5), Helper.DP(5), Helper.DP(5));
            if (Helper.isValidString(element.variables.tileTitle)) {
                title.setVisibility(View.VISIBLE);
                name_section.setVisibility(View.VISIBLE);
                title.setText(HtmlCompat.fromHtml(element.variables.tileTitle));
                if (element.variables.tileStyle != null) {
                    try {
                        title.setTextColor(Color.parseColor(element.variables.tileStyle.color));
                    } catch (Exception e) {
                    }
                }
            } else {
                title.setVisibility(View.GONE);
                name_section.setVisibility(View.GONE);
            }
            name_section.addView(title, textLayoutParam);

            SliderLayout slider = new SliderLayout(context);
            slider.setBackgroundColor(Color.parseColor(AppInfo.color_theme));
            slider.stopAutoCycle();
            slider.setBackground(CContext.getDrawable(context, AppInfo.ID_PLACEHOLDER_BANNER));
            //slider.setBackgroundColor(Helper.getPlaceholderColor());
            slider.setPresetTransformer(SliderLayout.Transformer.Fade);
            slider.setIndicatorVisibility(PagerIndicator.IndicatorVisibility.Gone);
            Helper.stylize(slider);

            if (element.variables.content != null && element.variables.content.length > 0) {
                for (final HomeElementUltimate.Variable.Content content : element.variables.content) {
                    DefaultSliderView defaultSliderView = new DefaultSliderView(context);
                    defaultSliderView.setShowProgress(false);
                    defaultSliderView.description("").image(content.img).setScaleType(BaseSliderView.ScaleType.CenterCrop);
                    if (content.redirect != null) {
                        defaultSliderView.setOnSliderClickListener(new BaseSliderView.OnSliderClickListener() {
                            @Override
                            public void onSliderClick(BaseSliderView slider) {
                                switch (content.redirect) {
                                    case "redirect":
                                        ((MainActivity) slider.getContext()).openWebFragment("", content.redirect_url);
                                        break;
                                    case "category":
                                        ((MainActivity) slider.getContext()).expandCategory(content.redirect_id);
                                        break;
                                    case "product":
                                        ((MainActivity) slider.getContext()).openOrLoadProductInfo(content.redirect_id);
                                        break;
                                    case "cart":
                                        ((MainActivity) slider.getContext()).openCartFragment();
                                        break;
                                    case "wishlist":
                                        ((MainActivity) slider.getContext()).openWishlistFragment(false);
                                        break;
                                }
                            }
                        });
                    }
                    slider.addSlider(defaultSliderView);
                }
            } else {
                int numSlides = 0;
                for (final TM_ProductInfo product : TM_ProductInfo.getAll()) {
                    if (product.hasAnyImage()) {
                        DefaultSliderView defaultSliderView = new DefaultSliderView(context);
                        defaultSliderView.setShowProgress(false);
                        defaultSliderView.description("").image(product.getFirstImageUrl()).setScaleType(BaseSliderView.ScaleType.CenterCrop);
                        defaultSliderView.setOnSliderClickListener(new BaseSliderView.OnSliderClickListener() {
                            @Override
                            public void onSliderClick(BaseSliderView slider) {
                                ((MainActivity) slider.getContext()).openProductInfo(product);
                            }
                        });
                        slider.addSlider(defaultSliderView);
                        numSlides++;
                    }
                    if (numSlides > 5)
                        break;
                }
            }

            if (slider.getSlidesCount() > 1) {
                if (AppInfo.ENABLE_AUTO_SLIDE_BANNER) {
                    slider.startAutoCycle();
                }
                slider.setPresetTransformer(SliderLayout.Transformer.Default);
                slider.setIndicatorVisibility(PagerIndicator.IndicatorVisibility.Visible);
            }

            RelativeLayout.LayoutParams sliderLayoutParam = new RelativeLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT);

            if (element.variables.textStyle != null) {
                if (element.variables.textStyle.alignment != null) {
                    switch (element.variables.textStyle.alignment) {
                        case "top":
                            textSectionLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_TOP);
                            sliderLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_TOP);
                            sliderLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
                            break;
                        case "center":
                            textSectionLayoutParam.addRule(RelativeLayout.CENTER_VERTICAL);
                            sliderLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_TOP);
                            sliderLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
                            break;
                        case "hide":
                            name_section.setVisibility(View.GONE);
                            sliderLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_TOP);
                            sliderLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
                            break;
                        case "above":
                            textSectionLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_TOP);
                            sliderLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
                            sliderLayoutParam.addRule(RelativeLayout.BELOW, name_section.getId());
                            break;
                        case "below":
                            textSectionLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
                            sliderLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_TOP);
                            sliderLayoutParam.addRule(RelativeLayout.ABOVE, name_section.getId());
                            break;
                        case "bottom":
                        default:
                            textSectionLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
                            sliderLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_TOP);
                            sliderLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
                            break;
                    }
                } else {
                    textSectionLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
                    sliderLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_TOP);
                    sliderLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
                }

                if (element.variables.textStyle.position != null) {
                    switch (element.variables.textStyle.position) {
                        case "left":
                            name_section.setGravity(Gravity.LEFT);
                            title.setGravity(Gravity.LEFT);
                            break;
                        case "right":
                            name_section.setGravity(Gravity.RIGHT);
                            title.setGravity(Gravity.RIGHT);
                            break;
                        case "center":
                        default:
                            name_section.setGravity(Gravity.CENTER);
                            title.setGravity(Gravity.CENTER);
                            break;
                    }
                } else {
                    name_section.setGravity(Gravity.CENTER);
                    title.setGravity(Gravity.CENTER);
                }
            }

            view.addView(slider, sliderLayoutParam);
            view.addView(name_section, textSectionLayoutParam);

        } catch (Exception e) {
            e.printStackTrace();
        }

        rootView.addView(view, new CardView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        return rootView;
    }

    public static View createRecyclerViewTile(final Context context, final HomeElementUltimate element, int orientation, int tileWidth) {
        float tileHeight = 0;
        if (element.variables.tileType.equals("8")) {
            tileHeight = GridLayout.LayoutParams.WRAP_CONTENT;
        } else {
            tileHeight = tileWidth * element.size_y;
        }

        FrameLayout rootView = new FrameLayout(context);

        RelativeLayout view = new RelativeLayout(context);

        ImageView img = new ImageView(context);
        img.setScaleType(ImageView.ScaleType.CENTER_CROP);
        view.addView(img, new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        setBgImageInView(img, element);

        try {
            LinearLayout name_section = new LinearLayout(context);
            name_section.setId(R.id.name_section);
            name_section.setPadding(Helper.DP(5), Helper.DP(5), Helper.DP(5), Helper.DP(5));
            RelativeLayout.LayoutParams textSectionLayoutParam = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            if (element.variables.tileStyle != null) {
                try {
                    name_section.setBackgroundColor(Color.parseColor(element.variables.tileStyle.textbgcolor));
                    //name_section.setBackgroundColor(Color.parseColor("#550000"));
                } catch (Exception e) {
                }
            }

            LinearLayout.LayoutParams textLayoutParam = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            TextView title = new TextView(context);
            title.setPadding(Helper.DP(5), Helper.DP(5), Helper.DP(5), Helper.DP(5));
            if (Helper.isValidString(element.variables.tileTitle)) {
                name_section.setVisibility(View.VISIBLE);
                title.setVisibility(View.VISIBLE);
                title.setText(HtmlCompat.fromHtml(element.variables.tileTitle));
                if (element.variables.tileStyle != null) {
                    try {
                        title.setTextColor(Color.parseColor(element.variables.tileStyle.color));
                    } catch (Exception e) {
                    }
                }
            } else {
                title.setVisibility(View.GONE);
                name_section.setVisibility(View.GONE);
            }
            name_section.addView(title, textLayoutParam);

            final RecyclerView recycler = new RecyclerView(context);
            recycler.setId(R.id.recycler);

            RelativeLayout.LayoutParams layoutRecycler = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            layoutRecycler.addRule(RelativeLayout.BELOW, name_section.getId());

            RecyclerView.LayoutManager layoutManager;
            if (orientation == LinearLayoutManager.VERTICAL) {
                recycler.setNestedScrollingEnabled(false);
                int columns = 2;
                layoutManager = new GridLayoutManager(context, columns, LinearLayoutManager.VERTICAL, false);
                recycler.setLayoutManager(layoutManager);
                layoutRecycler.addRule(RelativeLayout.CENTER_HORIZONTAL);
            } else {
                layoutManager = new LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false);
            }
            recycler.setLayoutManager(layoutManager);

            if (element.variables.textStyle != null) {
                if (element.variables.textStyle.alignment != null) {
                    switch (element.variables.textStyle.alignment) {
                        case "top":
                            textSectionLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_TOP);
                            layoutRecycler.addRule(RelativeLayout.ALIGN_PARENT_TOP);
                            layoutRecycler.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
                            break;
                        case "center":
                            textSectionLayoutParam.addRule(RelativeLayout.CENTER_VERTICAL);
                            layoutRecycler.addRule(RelativeLayout.ALIGN_PARENT_TOP);
                            layoutRecycler.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
                            break;
                        case "hide":
                            name_section.setVisibility(View.GONE);
                            layoutRecycler.addRule(RelativeLayout.ALIGN_PARENT_TOP);
                            layoutRecycler.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
                            break;
                        case "above":
                            textSectionLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_TOP);
                            //layoutRecycler.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
                            layoutRecycler.addRule(RelativeLayout.BELOW, name_section.getId());
                            break;
                        case "below":
                            textSectionLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
                            layoutRecycler.addRule(RelativeLayout.ALIGN_PARENT_TOP);
                            layoutRecycler.addRule(RelativeLayout.ABOVE, name_section.getId());
                            break;
                        case "bottom":
                        default:
                            textSectionLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
                            layoutRecycler.addRule(RelativeLayout.ALIGN_PARENT_TOP);
                            layoutRecycler.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
                            break;
                    }
                } else {
                    textSectionLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
                    layoutRecycler.addRule(RelativeLayout.ALIGN_PARENT_TOP);
                    layoutRecycler.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
                }

                if (element.variables.textStyle.position != null) {
                    switch (element.variables.textStyle.position) {
                        case "left":
                            name_section.setGravity(Gravity.LEFT);
                            title.setGravity(Gravity.LEFT);
                            break;
                        case "right":
                            name_section.setGravity(Gravity.RIGHT);
                            title.setGravity(Gravity.RIGHT);
                            break;
                        case "center":
                        default:
                            name_section.setGravity(Gravity.CENTER);
                            title.setGravity(Gravity.CENTER);
                            break;
                    }
                } else {
                    name_section.setGravity(Gravity.CENTER);
                    title.setGravity(Gravity.CENTER);
                }
            }

            final Adapter_ScrollView adapter = new Adapter_ScrollView(context, new ArrayList<>(), new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                }
            }, orientation);
            adapter.setCardViewHeight(tileHeight);

            if (element.variables.scrollerFor != null) {
                switch (element.variables.scrollerFor) {
                    case "category": {
                        int categoryId = Integer.parseInt(element.variables.scrollerIds);
                        if (categoryId == CategoryItem.ID_TRENDING_ITEMS) {
                            adapter.updateItems(TM_ProductInfo.getTrending(AppInfo.MAX_ITEMS_COUNT_HOME), element.variables.scrollerLimit);
                        } else if (categoryId == CategoryItem.ID_BEST_DEALS) {
                            adapter.updateItems(TM_ProductInfo.getBestDeals(AppInfo.MAX_ITEMS_COUNT_HOME), element.variables.scrollerLimit);
                        } else if (categoryId == CategoryItem.ID_FRESH_ARRIVALS) {
                            adapter.updateItems(TM_ProductInfo.getFreshArrivals(AppInfo.MAX_ITEMS_COUNT_HOME), element.variables.scrollerLimit);
                        } else if (categoryId == CategoryItem.ID_RECENTLY_VIEWED) {
                            adapter.updateItems(RecentlyViewedItem.getAllProducts(), element.variables.scrollerLimit);
                        } else {
                            final TM_CategoryInfo category = TM_CategoryInfo.getWithId(categoryId);
                            if (category != null) {
                                List<TM_ProductInfo> productList = TM_ProductInfo.getAllForCategory(category);

                                if (element.variables.scrollerCount > 0 && productList.size() < element.variables.scrollerCount) {
                                    final ProgressBar progress = new ProgressBar(context);
                                    RelativeLayout.LayoutParams progressLayoutParam = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                                    progressLayoutParam.addRule(RelativeLayout.CENTER_IN_PARENT);
                                    view.addView(progress, progressLayoutParam);
                                    Helper.stylize(progress);
                                    progress.setVisibility(View.VISIBLE);

                                    ((MainActivity) context).getProductsOfCategory(category, new TaskListener() {
                                        @Override
                                        public void onTaskDone() {
                                            ((MainActivity) context).runOnUiThread(new Runnable() {
                                                @Override
                                                public void run() {
                                                    progress.setVisibility(View.GONE);
                                                    List<TM_ProductInfo> productList = TM_ProductInfo.getAllForCategory(category);
                                                    adapter.updateItems(productList, element.variables.scrollerCount);
                                                }
                                            });
                                        }

                                        @Override
                                        public void onTaskFailed(String reason) {
                                            progress.setVisibility(View.GONE);
                                        }
                                    });
                                } else {
                                    adapter.updateItems(productList, element.variables.scrollerCount);
                                }
                            }
                        }
                    }
                    break;
                    case "categories": {
                        if (element.variables.content == null || element.variables.content.length == 0) {
                            adapter.updateItems(TM_CategoryInfo.getAll(), element.variables.scrollerLimit);
                        } else {
                            List<HomeElementUltimate.Variable.Content> contents = new ArrayList<>();
                            for (HomeElementUltimate.Variable.Content content : element.variables.content) {
                                content.type = Adapter_ScrollView.ITEM_TYPE_TINY_CATEGORY;
                                contents.add(content);
                            }
                            adapter.updateItems(contents, element.variables.scrollerLimit);
                        }
                    }
                    break;
                    case "vendor":
                    case "vendors": {
                        if (MultiVendorConfig.isEnabled() && MultiVendorConfig.getScreenType() == MultiVendorConfig.ScreenType.PRODUCTS) {
                            if (element.variables.content == null || element.variables.content.length == 0) {
                                List<SellerInfo> allSellers = SellerInfo.getAllSellers();
                                if (!allSellers.isEmpty()) {
                                    adapter.updateItems(allSellers, element.variables.scrollerLimit);
                                } else {
                                    final ProgressBar progress = new ProgressBar(context);
                                    RelativeLayout.LayoutParams progressLayoutParam = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                                    progressLayoutParam.addRule(RelativeLayout.CENTER_IN_PARENT);
                                    view.addView(progress, progressLayoutParam);
                                    progress.setVisibility(View.VISIBLE);
                                    DataEngine.getDataEngine().fetchSellersInBackground(new DataQueryHandler<List<SellerInfo>>() {
                                        @Override
                                        public void onSuccess(List<SellerInfo> vendors) {
                                            for (SellerInfo vendor : vendors) {
                                                vendor.commit();
                                            }
                                            adapter.updateItems(vendors, element.variables.scrollerLimit);
                                            recycler.getLayoutParams().height = ViewGroup.LayoutParams.WRAP_CONTENT;
                                            progress.setVisibility(View.GONE);
                                        }

                                        @Override
                                        public void onFailure(Exception exception) {
                                            exception.printStackTrace();
                                            progress.setVisibility(View.GONE);
                                        }
                                    });
                                }
                            } else {
                                if (SellerInfo.getAllSellers().isEmpty()) {
                                    final ProgressBar progress = new ProgressBar(context);
                                    RelativeLayout.LayoutParams progressLayoutParam = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                                    progressLayoutParam.addRule(RelativeLayout.CENTER_IN_PARENT);
                                    view.addView(progress, progressLayoutParam);
                                    progress.setVisibility(View.VISIBLE);
                                    DataEngine.getDataEngine().fetchSellersInBackground(new DataQueryHandler<List<SellerInfo>>() {
                                        @Override
                                        public void onSuccess(List<SellerInfo> vendors) {
                                            for (SellerInfo vendor : vendors) {
                                                vendor.commit();
                                            }
                                            List<HomeElementUltimate.Variable.Content> contents = new ArrayList<>();
                                            for (HomeElementUltimate.Variable.Content content : element.variables.content) {
                                                content.type = Adapter_ScrollView.ITEM_TYPE_TINY_SELLER;
                                                contents.add(content);
                                            }
                                            adapter.updateItems(contents, element.variables.scrollerLimit);
                                            recycler.getLayoutParams().height = ViewGroup.LayoutParams.WRAP_CONTENT;
                                            progress.setVisibility(View.GONE);
                                        }

                                        @Override
                                        public void onFailure(Exception e) {
                                            e.printStackTrace();
                                            progress.setVisibility(View.GONE);
                                        }
                                    });
                                } else {
                                    List<HomeElementUltimate.Variable.Content> contents = new ArrayList<>();
                                    for (HomeElementUltimate.Variable.Content content : element.variables.content) {
                                        content.type = Adapter_ScrollView.ITEM_TYPE_TINY_SELLER;
                                        contents.add(content);
                                    }
                                    adapter.updateItems(contents, element.variables.scrollerLimit);
                                }
                            }
                        }
                    }
                    break;
                    case "product":
                    case "products": {
                        List<HomeElementUltimate.Variable.Content> contents = new ArrayList<>();
                        for (HomeElementUltimate.Variable.Content content : element.variables.content) {
                            content.type = Adapter_ScrollView.ITEM_TYPE_TINY_PRODUCT;
                            contents.add(content);
                        }
                        adapter.updateItems(contents, element.variables.scrollerLimit);
                    }
                    break;
                    default: {
                        adapter.updateItems(TM_ProductInfo.getTrending(AppInfo.MAX_ITEMS_COUNT_HOME), element.variables.scrollerLimit);
                    }
                }
            } else {
                adapter.updateItems(TM_ProductInfo.getTrending(AppInfo.MAX_ITEMS_COUNT_HOME), element.variables.scrollerLimit);
            }
            recycler.setAdapter(adapter);

            view.addView(recycler, layoutRecycler);
            view.addView(name_section, textSectionLayoutParam);

            if (orientation == LinearLayoutManager.VERTICAL) {
                if (Helper.isValidString(element.variables.tileStyle.bgcolor)) {
                    try {
                        view.setBackgroundColor(Color.parseColor(element.variables.tileStyle.bgcolor));
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        rootView.addView(view, new CardView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        return rootView;
    }

    public static View generateTagsTile(Context context, HomeElementUltimate element) {
        View view = View.inflate(context, R.layout.tile_horizontal_recycler_0, null);
        try {
            setBgImageInView(view, element);
            TextView title = (TextView) view.findViewById(R.id.title);
            RecyclerView recycler = (RecyclerView) view.findViewById(R.id.recycler);

            if (Helper.isValidString(element.variables.tileTitle)) {
                title.setVisibility(View.VISIBLE);
                title.setText(HtmlCompat.fromHtml(element.variables.tileTitle));
            } else {
                title.setVisibility(View.GONE);
            }

            RecyclerView.LayoutManager layoutManager = new LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false);
            recycler.setLayoutManager(layoutManager);
            Adapter_ScrollView adapter = new Adapter_ScrollView(context, TM_ProductInfo.getBestDeals(AppInfo.MAX_ITEMS_COUNT_HOME), new View.OnClickListener() {
                @Override
                public void onClick(View view) {

                }
            });
            recycler.setAdapter(adapter);

        } catch (Exception e) {
            e.printStackTrace();
        }
        return view;
    }

    public static View generateCategoryTile(Context context, HomeElementUltimate element) {
        CardView rootView = new CardView(context);
        rootView.setUseCompatPadding(true);
        rootView.setClickable(true);
        rootView.setFocusable(true);
        //rootView.setForeground(context.getResources().getDrawable(android.R.attr.selectableItemBackground));

        RelativeLayout view = new RelativeLayout(context);

        ImageView img = new ImageView(context);
        img.setScaleType(ImageView.ScaleType.CENTER_CROP);
        view.addView(img, new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        setBgImageInView(img, element);

        ImageView item_icon = new ImageView(context);
        item_icon.setId(R.id.item_icon);
        item_icon.setAdjustViewBounds(true);

        switch (element.variables.tileStyle.scaletype) {
            case 0:
                item_icon.setScaleType(ImageView.ScaleType.CENTER);
                break;
            case 2:
                item_icon.setScaleType(ImageView.ScaleType.CENTER_INSIDE);
                break;
            case 3:
                item_icon.setScaleType(ImageView.ScaleType.FIT_CENTER);
                break;
            case 4:
                item_icon.setScaleType(ImageView.ScaleType.FIT_END);
                break;
            case 5:
                item_icon.setScaleType(ImageView.ScaleType.FIT_START);
                break;
            case 6:
                item_icon.setScaleType(ImageView.ScaleType.FIT_XY);
                break;
            default:
                item_icon.setScaleType(ImageView.ScaleType.CENTER_CROP);
                break;
        }

        RelativeLayout.LayoutParams imageLayoutParams = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);

        LinearLayout name_section = new LinearLayout(context);
        name_section.setId(R.id.name_section);
        name_section.setPadding(Helper.DP(5), Helper.DP(5), Helper.DP(5), Helper.DP(5));
        RelativeLayout.LayoutParams textSectionLayoutParam = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        if (element.variables.tileStyle != null) {
            try {
                name_section.setBackgroundColor(Color.parseColor(element.variables.tileStyle.textbgcolor));
            } catch (Exception e) {
            }
        }

        LinearLayout.LayoutParams textLayoutParam = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        TextView title = new TextView(context);
        title.setPadding(Helper.DP(5), Helper.DP(5), Helper.DP(5), Helper.DP(5));
        if (element.variables.tileStyle != null) {
            try {
                title.setTextColor(Color.parseColor(element.variables.tileStyle.color));
            } catch (Exception e) {
            }
        }
        name_section.addView(title, textLayoutParam);

        if (element.variables.textStyle != null) {
            if (element.variables.textStyle.alignment != null) {
                switch (element.variables.textStyle.alignment) {
                    case "top":
                        textSectionLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_TOP);
                        break;
                    case "center":
                        textSectionLayoutParam.addRule(RelativeLayout.CENTER_VERTICAL);
                        break;
                    case "hide":
                        name_section.setVisibility(View.GONE);
                        break;
                    case "above":
                        imageLayoutParams.height = RelativeLayout.LayoutParams.WRAP_CONTENT;
                        imageLayoutParams.addRule(RelativeLayout.BELOW, name_section.getId());
                        textSectionLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_TOP);
                        break;
                    case "below":
                        textSectionLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
                        imageLayoutParams.height = RelativeLayout.LayoutParams.WRAP_CONTENT;
                        imageLayoutParams.addRule(RelativeLayout.ABOVE, name_section.getId());
                        break;
                    case "bottom":
                    default:
                        textSectionLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
                        break;
                }
            } else {
                textSectionLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
            }

            if (element.variables.textStyle.position != null) {
                switch (element.variables.textStyle.position) {
                    case "left":
                        name_section.setGravity(Gravity.LEFT);
                        title.setGravity(Gravity.LEFT);
                        break;
                    case "right":
                        name_section.setGravity(Gravity.RIGHT);
                        title.setGravity(Gravity.RIGHT);
                        break;
                    case "center":
                    default:
                        name_section.setGravity(Gravity.CENTER);
                        title.setGravity(Gravity.CENTER);
                        break;
                }
            } else {
                name_section.setGravity(Gravity.CENTER);
                title.setGravity(Gravity.CENTER);
            }
        }
        view.addView(name_section, textSectionLayoutParam);
        view.addView(item_icon, imageLayoutParams);

        try {
            final TM_CategoryInfo category = TM_CategoryInfo.getWithId(Integer.parseInt(element.variables.tileType_Id));
            title.setText(HtmlCompat.fromHtml(category.getName()));
            rootView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    final Context context = v.getContext();
                    if (category.isProductRefreshed) {
                        ((MainActivity) context).expandCategory(category);
                    } else {
                        ((MainActivity) context).showProgress(getString(L.string.loading));
                        ((MainActivity) context).getProductsOfCategory(category, new TaskListener() {
                            @Override
                            public void onTaskDone() {
                                ((MainActivity) context).hideProgress();
                                ((MainActivity) context).expandCategory(category);
                            }

                            @Override
                            public void onTaskFailed(String reason) {
                                ((MainActivity) context).hideProgress();
                                Helper.showToast(reason);
                            }
                        });
                    }
                }
            });
            if (Helper.isValidString(category.image)) {
                String bgColor = element.variables.tileStyle.bgcolor;
                if (TextUtils.isEmpty(bgColor)) {
                    bgColor = "#ffffff"; // default background color is white.
                }
                Glide.with(context)
                        .load(category.image)
                        .placeholder(Color.parseColor(bgColor))
                        .error(R.drawable.error_category)
                        .into(item_icon);

            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        rootView.addView(view, new CardView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        return rootView;
    }

    public static View generateProductTile(Context context, HomeElementUltimate element) {

        CardView rootView = new CardView(context);
        rootView.setUseCompatPadding(true);
        rootView.setClickable(true);
        rootView.setFocusable(true);
        //rootView.setForeground(context.getResources().getDrawable(android.R.attr.selectableItemBackground));

        RelativeLayout view = new RelativeLayout(context);

        ImageView img = new ImageView(context);
        img.setScaleType(ImageView.ScaleType.CENTER_CROP);
        view.addView(img, new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        setBgImageInView(img, element);

        ImageView item_icon = new ImageView(context);
        item_icon.setId(R.id.item_icon);
        item_icon.setScaleType(ImageView.ScaleType.CENTER_CROP);
        item_icon.setImageResource(AppInfo.ID_PLACEHOLDER_PRODUCT);
        RelativeLayout.LayoutParams imageLayoutParams = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        view.addView(item_icon, imageLayoutParams);

        LinearLayout name_section = new LinearLayout(context);
        name_section.setId(R.id.name_section);
        name_section.setPadding(Helper.DP(5), Helper.DP(5), Helper.DP(5), Helper.DP(5));
        RelativeLayout.LayoutParams textSectionLayoutParam = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        if (element.variables.tileStyle != null) {
            try {
                name_section.setBackgroundColor(Color.parseColor(element.variables.tileStyle.textbgcolor));
            } catch (Exception e) {
            }
        }

        LinearLayout.LayoutParams textLayoutParam = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        TextView title = new TextView(context);
        title.setPadding(Helper.DP(5), Helper.DP(5), Helper.DP(5), Helper.DP(5));
        if (element.variables.tileStyle != null) {
            try {
                title.setTextColor(Color.parseColor(element.variables.tileStyle.color));
            } catch (Exception e) {
            }
        }
        name_section.addView(title, textLayoutParam);

        if (element.variables.textStyle != null) {
            if (element.variables.textStyle.alignment != null) {
                switch (element.variables.textStyle.alignment) {
                    case "top":
                        textSectionLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_TOP);
                        break;
                    case "center":
                        textSectionLayoutParam.addRule(RelativeLayout.CENTER_VERTICAL);
                        break;
                    case "hide":
                        name_section.setVisibility(View.GONE);
                        break;
                    case "below":
                        imageLayoutParams.height = RelativeLayout.LayoutParams.WRAP_CONTENT;
                        imageLayoutParams.addRule(RelativeLayout.ABOVE, name_section.getId());
                        textSectionLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
                        break;
                    case "bottom":
                    default:
                        textSectionLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
                        break;
                }
            } else {
                textSectionLayoutParam.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
            }

            if (element.variables.textStyle.position != null) {
                switch (element.variables.textStyle.position) {
                    case "left":
                        name_section.setGravity(Gravity.LEFT);
                        title.setGravity(Gravity.LEFT);
                        break;
                    case "right":
                        name_section.setGravity(Gravity.RIGHT);
                        title.setGravity(Gravity.RIGHT);
                        break;
                    case "center":
                    default:
                        name_section.setGravity(Gravity.CENTER);
                        title.setGravity(Gravity.CENTER);
                        break;
                }
            } else {
                name_section.setGravity(Gravity.CENTER);
                title.setGravity(Gravity.CENTER);
            }
        }

        view.addView(name_section, textSectionLayoutParam);

        try {
            final TM_ProductInfo product = TM_ProductInfo.getProductWithId(Integer.parseInt(element.variables.tileType_Id));
            title.setText(HtmlCompat.fromHtml(product.title));
            rootView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    ((MainActivity) v.getContext()).openProductInfo(product);
                }
            });
            if (Helper.isValidString(product.thumb)) {
                Glide.with(context)
                        .load(product.thumb)
                        .placeholder(Helper.getPlaceholderColor())
                        .error(R.drawable.error_category)
                        .into(item_icon);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        rootView.addView(view, new CardView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        return rootView;
    }


    public static View generateCartTile(Context context, HomeElementUltimate element) {
        View view = View.inflate(context, R.layout.tile_empty_1, null);
        try {
            setBgImageInView(view, element);
            View cv = view.findViewById(R.id.cv);
            TextView title = (TextView) view.findViewById(R.id.title);
            if (Helper.isValidString(element.variables.tileTitle)) {
                title.setText(HtmlCompat.fromHtml(element.variables.tileTitle));
            } else {
                title.setText(getString(L.string.title_cart));
            }
            cv.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    ((MainActivity) v.getContext()).openCartFragment();
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
        return view;
    }

    public static View generateWishlistTile(Context context, HomeElementUltimate element) {
        View view = View.inflate(context, R.layout.tile_empty_1, null);
        try {
            setBgImageInView(view, element);
            View cv = view.findViewById(R.id.cv);
            TextView title = (TextView) view.findViewById(R.id.title);
            if (Helper.isValidString(element.variables.tileTitle)) {
                title.setText(HtmlCompat.fromHtml(element.variables.tileTitle));
            } else {
                title.setText(getString(L.string.title_wishlist));
            }
            cv.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    ((MainActivity) v.getContext()).openWishlistFragment(false);
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
        return view;
    }

    private static void openCategory(final Context context, final TM_CategoryInfo category) {

    }
}
