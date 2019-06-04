package com.twist.tmstore.adapters;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.twist.tmstore.R;

import java.util.ArrayList;
import java.util.List;

public class Adapter_PickedImages<T> extends RecyclerView.Adapter<Adapter_PickedImages.AppViewHolder> {

    private static final int ITEM_EMPTY = -1;
    private static final int ITEM_DATA = 0;
    private static final int TYPE_HEADER = -2;
    private static final int TYPE_FOOTER = -3;
    private final ImageListener mImageListener;
    private List<T> mValues;
    private List<View> mHeaders = new ArrayList<>();
    private List<View> mFooters = new ArrayList<>();
    private boolean enableEmptyView = false;
    private Context mContext;

    public Adapter_PickedImages(ImageListener imageListener) {
        mValues = new ArrayList<>();
        mImageListener = imageListener;
        mFooters.add(null);
    }

    public void addFooter(View view) {
        mFooters.add(view);
        notifyItemInserted(mHeaders.size() + mValues.size() + mFooters.size() - 1);
    }

    public void hideFooters() {
        for (View view : mFooters) {
            view.setVisibility(View.GONE);
        }
    }

    public void showFooters() {
        for (View view : mFooters) {
            view.setVisibility(View.VISIBLE);
        }
    }

    public boolean remove(T item) {
        int index = mValues.indexOf(item);
        if (index >= 0) {
            if (mValues.remove(item)) {
                notifyItemRemoved(index + mHeaders.size());
                return true;
            }
        }
        return false;
    }

    @Override
    public AppViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        mContext = parent.getContext();
        View view;
        switch (viewType) {
            case TYPE_HEADER:
                view = LayoutInflater.from(parent.getContext()).inflate(R.layout.upload_image_header, parent, false);
                return new RecyclerHeaderViewHolder(view);
            case ITEM_DATA:
            case TYPE_FOOTER:
                view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_picked_image, parent, false);
                return new DataViewHolder(view);
            case ITEM_EMPTY:
            default:
                view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_empty, parent, false);
                ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
                view.setLayoutParams(layoutParams);
                return new EmptyViewHolder(view);
        }
    }

    @Override
    public int getItemViewType(int position) {
        int firstDataIndex = mHeaders.size();
        int firstFooterIndex = mHeaders.size() + mValues.size();
        int totalItemCount = mHeaders.size() + mFooters.size() + mValues.size();
        if (position < firstDataIndex) {
            return TYPE_HEADER;
        } else if (position < firstFooterIndex) {
            return ITEM_DATA;
        } else if (position < totalItemCount) {
            return TYPE_FOOTER;
        } else {
            return ITEM_EMPTY;
        }
    }

    @Override
    public void onBindViewHolder(final AppViewHolder holder, int position) {
        if (mValues.isEmpty() || position < mHeaders.size() || (position >= mValues.size() + mHeaders.size()))
            holder.onBind(null);
        else
            holder.onBind(mValues.get(position - mHeaders.size()));
    }

    @Override
    public int getItemCount() {
        if (enableEmptyView && mValues.isEmpty()) {
            return 1;
        }
        return mValues.size() + mHeaders.size() + mFooters.size();
    }

    public void addItems(List<T> data) {
        if (data != null) {
            int previousSize = mValues.size();
            mValues.addAll(data);
            int newSize = mValues.size();
            notifyItemRangeInserted(previousSize + mHeaders.size(), (newSize - previousSize));
        }
    }

    public boolean isEnableEmptyView() {
        return enableEmptyView;
    }

    public void setEnableEmptyView(boolean enableEmptyView) {
        this.enableEmptyView = enableEmptyView;
    }

    public void addItem(T item) {
        int indexToAdd = mValues.size();
        if (mValues.add(item)) {
            notifyItemInserted(indexToAdd + mHeaders.size());
        }
    }

    public void addItem(int position, T item) {
        if (position < mValues.size()) {
            mValues.add(position, item);
            notifyItemInserted(position + mHeaders.size());
        } else {
            addItem(item);
        }
    }

    public List<T> getItems() {
        return new ArrayList<>(mValues);
    }

    public boolean isAnyImagePicked() {
        return !mValues.isEmpty();
    }

    private void removeEntity(T entity) {
        remove(entity);
    }

    public interface ImageListener<T1> {
        void onImageSelected(T1 object);

        void onImageDeleted(T1 object);
    }

    public abstract class AppViewHolder<T> extends RecyclerView.ViewHolder {
        public T mItem;

        public AppViewHolder(View itemView) {
            super(itemView);
        }

        public abstract void onBind(T item);
    }

    public class RecyclerHeaderViewHolder extends AppViewHolder<Object> {
        public RecyclerHeaderViewHolder(View itemView) {
            super(itemView);
        }

        @Override
        public void onBind(Object item) {
        }
    }

    public class DataViewHolder extends AppViewHolder<T> {

        public final ImageView img;
        public final ImageButton btn_delete;

        public DataViewHolder(View view) {
            super(view);
            img = (ImageView) view.findViewById(R.id.img);
            btn_delete = (ImageButton) view.findViewById(R.id.btn_delete);
        }

        @Override
        public void onBind(final T data) {
            if (data != null) {
                String file = (String) data;
                Glide.with(mContext)
                        .load(file)
                        .placeholder(R.drawable.placeholder_product)
                        .override(mContext.getResources().getDimensionPixelSize(R.dimen.image_thumb_size_list), mContext.getResources().getDimensionPixelSize(R.dimen.image_thumb_size_list))
                        .fitCenter()
                        .into(this.img);
                this.btn_delete.setVisibility(View.VISIBLE);
                this.img.setOnClickListener(null);
                this.btn_delete.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        removeEntity(data);
                    }
                });
            } else {
                Glide.with(mContext)
                        .load(R.drawable.img_select_image)
                        .into(this.img);
                this.btn_delete.setOnClickListener(null);
                this.btn_delete.setVisibility(View.GONE);
                this.img.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (null != mImageListener) {
                            mImageListener.onImageSelected(data);
                        }
                    }
                });
            }
        }
    }

    public class EmptyViewHolder extends AppViewHolder {
        TextView empty;

        public EmptyViewHolder(View view) {
            super(view);
            empty = (TextView) view.findViewById(R.id.empty);
        }

        @Override
        public void onBind(Object object) {
        }
    }
}
