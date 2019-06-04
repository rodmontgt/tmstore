package com.twist.tmstore.adapters;

import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import com.twist.tmstore.R;
import com.twist.tmstore.entities.MyProfileItem;
import com.twist.tmstore.listeners.MyProfileItemClickListener;
import com.utils.HtmlCompat;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 05-12-2016.
 */

public class Adapter_MyProfile extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    private List<View> headers = new ArrayList<>();
    private List<MyProfileItem> navDrawItems;
    private MyProfileItemClickListener myProfileItemClickListener;

    private static final int HEADER_VIEW = 1;
    private static final int ITEM_VIEW = 2;

    public Adapter_MyProfile(List<MyProfileItem> navDrawItems) {
        this.navDrawItems = navDrawItems;
    }

    @Override
    public int getItemViewType(int position) {
        if (position < headers.size()) {
            return HEADER_VIEW;
        } else {
            return ITEM_VIEW;
        }
    }

    @Override
    public int getItemCount() {
        int itemCount = (null != navDrawItems ? navDrawItems.size() : 0);
        return itemCount + headers.size();
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup viewGroup, int viewType) {
        if (viewType == ITEM_VIEW) {
            View view = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.my_profile_items, viewGroup, false);
            return new ItemViewHolder(view);
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
        } else {
            prepareGeneric((ItemViewHolder) holder, position - headers.size());
        }
    }

    public void setMyProfileItemClickListener(MyProfileItemClickListener myProfileItemClickListener) {
        this.myProfileItemClickListener = myProfileItemClickListener;
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

    public void removeAllHeaders() {
        int numHeaders = headers.size();
        headers.clear();
        if (numHeaders > 0)
            notifyItemRangeRemoved(0, numHeaders);
    }

    private void prepareHeaderFooter(HeaderFooterViewHolder vh, View view) {
        //empty out our FrameLayout and replace with our header/footer
        vh.base.removeAllViews();
        vh.base.addView(view);
    }

    private void prepareGeneric(final ItemViewHolder viewHolder, int position) {
        final MyProfileItem navDrawItem = navDrawItems.get(position);
        if (navDrawItem.getIconId() != -1) {
            viewHolder.image.setImageResource(navDrawItem.getIconId());
            viewHolder.image.setVisibility(View.VISIBLE);
        } else {
            viewHolder.image.setVisibility(View.GONE);
        }
        viewHolder.title.setText(HtmlCompat.fromHtml(navDrawItem.getName()));
        viewHolder.itemView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (myProfileItemClickListener != null) {
                    myProfileItemClickListener.onMyProfileItemClick(navDrawItem.getId(), viewHolder.getAdapterPosition());
                }
            }
        });
    }

    public class HeaderFooterViewHolder extends RecyclerView.ViewHolder {
        FrameLayout base;

        public HeaderFooterViewHolder(View itemView) {
            super(itemView);
            this.base = (FrameLayout) itemView;
        }
    }

    class ItemViewHolder extends RecyclerView.ViewHolder {
        protected ImageView image;
        protected TextView title;

        public ItemViewHolder(View view) {
            super(view);
            this.image = (ImageView) view.findViewById(R.id.image);
            this.title = (TextView) view.findViewById(R.id.title);
        }
    }
}