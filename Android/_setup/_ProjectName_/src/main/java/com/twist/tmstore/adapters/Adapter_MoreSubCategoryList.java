package com.twist.tmstore.adapters;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.twist.dataengine.entities.TM_CategoryInfo;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.listeners.TaskListener;
import com.utils.Helper;
import com.utils.HtmlCompat;

import java.util.ArrayList;
import java.util.List;

import static com.twist.tmstore.L.getString;

public class Adapter_MoreSubCategoryList<T> extends RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private List<T> data;
    private List<View> headers = new ArrayList<>();
    private List<View> footers = new ArrayList<>();

    private static final int HEADER_VIEW = 1;
    private static final int FOOTER_VIEW = 2;
    private static final int ITEM_VIEW = 3;

    private Context context;

    public static class HeaderFooterViewHolder extends RecyclerView.ViewHolder {
        FrameLayout base;

        public HeaderFooterViewHolder(View itemView) {
            super(itemView);
            this.base = (FrameLayout) itemView;
        }
    }

    public Adapter_MoreSubCategoryList(Context context, List<T> data) {
        this.data = data;
        this.context = context;
    }

    @Override
    public int getItemCount() {
        return (data.size() + headers.size() + footers.size());
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup viewGroup, int viewType) {
        switch (viewType) {
            case HEADER_VIEW:
            case FOOTER_VIEW:
                FrameLayout frameLayout = new FrameLayout(viewGroup.getContext());
                frameLayout.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
                return new Adapter_MoreSubCategoryList.HeaderFooterViewHolder(frameLayout);
            default:
                View view = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.item_category_sub_more, viewGroup, false);
                return new ListCategoryTileViewHolder(view);
        }
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {
        final int viewType = getItemViewType(position);
        switch (viewType) {
            case HEADER_VIEW:
                prepareHeaderFooter((Adapter_MoreSubCategoryList.HeaderFooterViewHolder) holder, headers.get(position));
                break;
            case FOOTER_VIEW:
                prepareHeaderFooter((Adapter_MoreSubCategoryList.HeaderFooterViewHolder) holder, footers.get(position - data.size() - headers.size()));
                break;
            default:
                prepareGeneric((ListCategoryTileViewHolder) holder, position - headers.size());
                break;
        }
    }

    private void prepareGeneric(ListCategoryTileViewHolder holder, int position) {
        TM_CategoryInfo category = (TM_CategoryInfo) data.get(position);
        holder.prepare(context, category);
    }

    private void prepareHeaderFooter(Adapter_MoreSubCategoryList.HeaderFooterViewHolder vh, View view) {
        vh.base.removeAllViews();
        vh.base.addView(view);
    }

    @Override
    public int getItemViewType(int position) {
        if (position < headers.size()) {
            return HEADER_VIEW;
        } else if (position >= headers.size() + data.size()) {
            return FOOTER_VIEW;
        }
        return ITEM_VIEW;
    }

    public void addItemsToList(List<T> newData) {
        if (newData != null)
            data.addAll(newData);
    }

    public void addHeader(View header) {
        if (!headers.contains(header)) {
            headers.add(header);
            notifyItemInserted(headers.size() - 1);
        }
    }

    public void removeHeader(View header) {
        if (headers.contains(header)) {
            notifyItemRemoved(headers.indexOf(header));
            headers.remove(header);
            if (header.getParent() != null) {
                ((ViewGroup) header.getParent()).removeView(header);
            }
        }
    }

    public void addFooter(View footer) {
        if (!footers.contains(footer)) {
            footers.add(footer);
            notifyItemInserted(headers.size() + data.size() + footers.size() - 1);
        }
    }

    //remove a footer from the adapter
    public void removeFooter(View footer) {
        if (footers.contains(footer)) {
            notifyItemRemoved(headers.size() + data.size() + footers.indexOf(footer));
            footers.remove(footer);
            if (footer.getParent() != null) {
                ((ViewGroup) footer.getParent()).removeView(footer);
            }
        }
    }


    class ListCategoryTileViewHolder extends RecyclerView.ViewHolder {

        private TextView text;
        private View view;

        private int index;

        public int getIndex() {
            return index;
        }

        public void setIndex(int index) {
            this.index = index;
        }

        public ListCategoryTileViewHolder(View vi) {
            super(vi);
            view = vi;
            text = (TextView) vi.findViewById(R.id.text);
        }

        public void prepare(Context context, final TM_CategoryInfo category) {
            if (category.getName() != null) {
                text.setText(HtmlCompat.fromHtml(category.getName()));
            } else {
                text.setText(category.id + "");
            }
            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    openCategory(category);
                }
            });
        }

        private void openCategory(final TM_CategoryInfo category) {
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
    }

}