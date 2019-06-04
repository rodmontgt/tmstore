package com.twist.tmstore.adapters;

import android.graphics.Color;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.DrawableRequestBuilder;
import com.bumptech.glide.Glide;
import com.twist.dataengine.entities.TM_CategoryInfo;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.listeners.TaskListener;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.customviews.CustomFontTextView;

import java.util.ArrayList;
import java.util.List;

import static com.twist.tmstore.L.getString;

public class CategoryAdapter<T1> extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private static final int HEADER_VIEW = 1;
    private static final int FOOTER_VIEW = 2;
    private static final int ITEM_VIEW_1 = 3;
    private static final int ITEM_VIEW_2 = 4;
    private List<T1> data;
    private List<View> headers = new ArrayList<>();
    private List<View> footers = new ArrayList<>();
    private int layoutId = 0;

    public CategoryAdapter(List<T1> data, int layoutType) {
        this.data = data;
        this.layoutId = getLayoutId(layoutType);
    }

    public CategoryAdapter(List<T1> data) {
        this.data = data;
        this.layoutId = getLayoutId(AppInfo.ID_LAYOUT_CATEGORIES);
    }

    private int getLayoutId(int type) {
        switch (type) {
            case 1:
                return R.layout.item_category_home_1;
            case 2:
                return R.layout.item_category_home_2;
            case 3:
                return R.layout.item_category_home_3;
            case 4:
                return R.layout.item_category_home_4;
            default:
                return R.layout.item_category_home_0;
        }
    }

    @Override
    public int getItemCount() {
        return (data.size() + headers.size() + footers.size());
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup viewGroup, int viewType) {
        if (viewType == ITEM_VIEW_1) {
            View view = LayoutInflater.from(viewGroup.getContext()).inflate(this.layoutId, viewGroup, false);
            return new CategoryTileViewHolder(view);
        } else if (viewType == ITEM_VIEW_2) {
            View view = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.item_category_home_2, viewGroup, false);
            return new CategoryTileViewHolder(view);
        } else if (viewType == FOOTER_VIEW) {
            FrameLayout frameLayout = new FrameLayout(viewGroup.getContext());
            FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.WRAP_CONTENT);
            layoutParams.setMargins(0, Helper.DP(8), 0, 0);
            frameLayout.setLayoutParams(layoutParams);
            return new HeaderFooterViewHolder(frameLayout);
        } else {
            FrameLayout frameLayout = new FrameLayout(viewGroup.getContext());
            frameLayout.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
            return new HeaderFooterViewHolder(frameLayout);
        }
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {
        final int viewType = getItemViewType(position);
        if (viewType == HEADER_VIEW) {
            View v = headers.get(position);
            prepareHeaderFooter((HeaderFooterViewHolder) holder, v);
        } else if (viewType == FOOTER_VIEW) {
            View v = footers.get(position - data.size() - headers.size());
            prepareHeaderFooter((HeaderFooterViewHolder) holder, v);
        } else {
            prepareGeneric((CategoryTileViewHolder) holder, position - headers.size());
        }
    }

    private void prepareGeneric(CategoryTileViewHolder holder, int position) {
        holder.prepare((TM_CategoryInfo) data.get(position));
    }

    private void prepareHeaderFooter(HeaderFooterViewHolder viewHolder, View view) {
        viewHolder.base.removeAllViews();
        if (view.getParent() != null) {
            ((ViewGroup) view.getParent()).removeView(view);
        }
        viewHolder.base.addView(view);
    }

    @Override
    public int getItemViewType(int position) {
        if (position < headers.size()) {
            return HEADER_VIEW;
        } else if (position >= (headers.size() + data.size())) {
            return FOOTER_VIEW;
        }

        if (AppInfo.ID_LAYOUT_CATEGORIES == 3) {
            if ((position - headers.size()) % 2 == 0) {
                return ITEM_VIEW_2;
            }
        }
        return ITEM_VIEW_1;
    }

    public void addHeader(View header) {
        if (!headers.contains(header)) {
            headers.add(header);
            notifyItemInserted(headers.size() - 1);
        }
    }

    public void addFooter(View footer) {
        if (!footers.contains(footer)) {
            footers.add(footer);
            notifyItemInserted(headers.size() + data.size() + footers.size() - 1);
        }
    }

    public class CategoryTileViewHolder extends RecyclerView.ViewHolder {

        private TextView text_name;
        private ImageView item_icon;
        private View cardView;

        public CategoryTileViewHolder(View view) {
            super(view);
            cardView = view.findViewById(R.id.cv);
            text_name = (TextView) view.findViewById(R.id.text_categoryname);
            text_name.setAllCaps(AppInfo.CATEGORY_TITLE_ALL_CAPS);
            item_icon = (ImageView) view.findViewById(R.id.item_icon);
            if (AppInfo.ID_LAYOUT_CATEGORIES == 2 || AppInfo.ID_LAYOUT_CATEGORIES == 3) {
                CustomFontTextView textView = (CustomFontTextView) view.findViewById(R.id.text_explore_now);
                textView.setBackgroundColor(Color.parseColor(AppInfo.color_theme));
                textView.setText(getString(L.string.explore_now));
                textView.setTextColor(Helper.getTxtCommon1());
            }
        }

        public void prepare(final TM_CategoryInfo category) {
            if (category.getName() != null) {
                text_name.setText(HtmlCompat.fromHtml(category.getName()));
                if (!TextUtils.isEmpty(category.image)) {
                    //Log.d("CATEGORY_IMAGE => " + category.image);
                    int placeholderColor = Helper.getPlaceholderColor();
                    DrawableRequestBuilder requestBuilder = Glide.with(itemView.getContext())
                            .load(category.image)
                            .placeholder(placeholderColor)
                            .error(placeholderColor);
                    if (AppInfo.ID_LAYOUT_CATEGORIES == 0) {
                        requestBuilder.fitCenter();
//                        try {
//                            View view = itemView.findViewById(R.id.name_section);
//                            if (view != null) {
//                                view.setBackgroundColor(CContext.getColor(itemView.getContext(), placeholderColor));
//                            }
//                        } catch (Exception ignored) {
//                        }
                    } else {
                        requestBuilder.centerCrop();
                    }
                    requestBuilder.into(item_icon);
                }
                cardView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (category.isProductRefreshed) {
                            MainActivity.mActivity.expandCategory(category);
                        } else {
                            MainActivity.mActivity.showProgress(getString(L.string.loading));
                            MainActivity.mActivity.getProductsOfCategory(category, new TaskListener() {
                                @Override
                                public void onTaskDone() {
                                    MainActivity.mActivity.hideProgress();
                                    MainActivity.mActivity.expandCategory(category);
                                }

                                @Override
                                public void onTaskFailed(String reason) {
                                    MainActivity.mActivity.hideProgress();
                                    Helper.showToast(reason);
                                }
                            });
                        }
                    }
                });
            }
        }
    }

    public class HeaderFooterViewHolder extends RecyclerView.ViewHolder {
        FrameLayout base;

        public HeaderFooterViewHolder(View itemView) {
            super(itemView);
            this.base = (FrameLayout) itemView;
        }
    }
}