package com.twist.tmstore.adapters;

import android.support.v7.widget.CardView;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Filter;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import com.twist.dataengine.entities.SellerInfo;
import com.twist.tmstore.BaseActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.listeners.ModificationListener;
import com.twist.tmstore.listeners.VendorClickHandler;
import com.utils.HtmlCompat;

import java.util.ArrayList;
import java.util.List;

public class Adapter_Vendors extends RecyclerView.Adapter<Adapter_Vendors.AbstractViewHolder> {

    abstract class AbstractViewHolder extends RecyclerView.ViewHolder {
        AbstractViewHolder(View itemView) {
            super(itemView);
        }

        abstract void bindData(Object object);
    }

    public class HeaderFooterViewHolder extends Adapter_Vendors.AbstractViewHolder {
        FrameLayout base;

        public HeaderFooterViewHolder(View itemView) {
            super(itemView);
            this.base = (FrameLayout) itemView;
        }

        @Override
        void bindData(Object object) {
            View view = (View) object;
            base.removeAllViews();
            base.addView(view);
        }
    }

    private static final int TYPE_HEADER = 1;
    private static final int TYPE_FOOTER = 2;
    private static final int TYPE_ITEM = 3;
    private static final int TYPE_EMPTY = 4;
    private List<View> headers = new ArrayList<>();
    private List<View> footers = new ArrayList<>();
    private VendorClickHandler vendorClickHandler;

    public class ViewHolder extends Adapter_Vendors.AbstractViewHolder {
        ImageView thumb;
        TextView name;
        TextView details;
        CardView cv;
        //ImageView	icon_delete;

        public ViewHolder(final View view) {
            super(view);
            this.cv = (CardView) view.findViewById(R.id.cv);
            this.thumb = (ImageView) view.findViewById(R.id.thumb);
            this.name = (TextView) view.findViewById(R.id.name);
            this.details = (TextView) view.findViewById(R.id.details);
            this.cv.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (vendorClickHandler != null) {
                        vendorClickHandler.onVendorSelected(((SellerInfo) data.get(getAdapterPosition())));
                    }
                }
            });
        }

        @Override
        void bindData(Object object) {
            SellerInfo vendor = (SellerInfo) object; //data.get(position);
            this.name.setText(HtmlCompat.fromHtml(vendor.getTitle()));
            //            this.details.setText(HtmlCompat.fromHtml(merchant.getDescription()));
//            Glide.with(activity)
//                    .load(merchant.getImage_url())
//                    .placeholder(AppInfo.ID_PLACEHOLDER_PRODUCT)
//                    .error(R.drawable.error_product)
//                    .into(this.thumb);

            this.details.setVisibility(View.GONE);
            this.thumb.setVisibility(View.GONE);
        }
    }

    private BaseActivity activity;
    private List data;
    private ModificationListener mModificationListener = null;

    public void setModificationListener(ModificationListener obj) {
        mModificationListener = obj;
    }

    public Adapter_Vendors(BaseActivity activity, List<SellerInfo> data, VendorClickHandler vendorClickHandler) {
        this.activity = activity;
        this.data = data;
        this.vendorClickHandler = vendorClickHandler;
    }

    public void setData(List<SellerInfo> data) {
        this.data = data;
    }

    @Override
    public int getItemCount() {
        int count = data.size();
        count += headers.size();
        count += footers.size();
        return count;
    }

    public Object getItem(int position) {
        return position;
    }

    public long getItemId(int position) {
        return position;
    }

    @Override
    public AbstractViewHolder onCreateViewHolder(ViewGroup viewGroup, int type) {
        LayoutInflater inflater = LayoutInflater.from(viewGroup.getContext());
        switch (type) {
            case TYPE_HEADER:
            case TYPE_FOOTER: {
                FrameLayout frameLayout = new FrameLayout(viewGroup.getContext());
                ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                frameLayout.setLayoutParams(layoutParams);
                return new HeaderFooterViewHolder(frameLayout);
            }
            default: {
                View view = inflater.inflate(R.layout.item_vendor, viewGroup, false);
                return new ViewHolder(view);
            }
        }
    }

    @Override
    public void onBindViewHolder(AbstractViewHolder holder, int position) {
        if (position < headers.size()) {
            holder.bindData(headers.get(position));
        } else if (position >= (headers.size() + data.size())) {
            holder.bindData(footers.get(position - data.size() - headers.size()));
        } else {
            holder.bindData(data.get(position - headers.size()));
        }
    }

    @Override
    public int getItemViewType(int position) {
        //check what type our position is, based on the assumption that the order is headers > items > footers
        if (position < headers.size()) {
            return TYPE_HEADER;
        } else if (position >= headers.size() + data.size()) {
            return TYPE_FOOTER;
        }
        return TYPE_ITEM;
    }

    @Override
    public void onAttachedToRecyclerView(RecyclerView recyclerView) {
        super.onAttachedToRecyclerView(recyclerView);
    }


    //add a header to the adapter
    public void addHeader(View header) {
        if (!headers.contains(header)) {
            headers.add(header);
            //animate
            notifyItemInserted(headers.size() - 1);
        }
    }

    //remove a header from the adapter
    public void removeHeader(View header) {
        if (headers.contains(header)) {
            //animate
            notifyItemRemoved(headers.indexOf(header));
            headers.remove(header);
            if (header.getParent() != null) {
                ((ViewGroup) header.getParent()).removeView(header);
            }
        }
    }

    //add a footer to the adapter
    public void addFooter(View footer) {
        if (!footers.contains(footer)) {
            footers.add(footer);
            //animate
            notifyItemInserted(headers.size() + data.size() + footers.size() - 1);
        }
    }

    //remove a footer from the adapter
    public void removeFooter(View footer) {
        if (footers.contains(footer)) {
            //animate
            notifyItemRemoved(headers.size() + data.size() + footers.indexOf(footer));
            footers.remove(footer);
            if (footer.getParent() != null) {
                ((ViewGroup) footer.getParent()).removeView(footer);
            }
        }
    }


    private Filter filter = null;

    public Filter getFilter() {
        if (filter == null) {
            filter = new Filter() {
                @Override
                protected Filter.FilterResults performFiltering(CharSequence constraint) {
                    final FilterResults oReturn = new FilterResults();
                    final List<SellerInfo> results = new ArrayList<>();
                    if (constraint != null) {
                        if (data != null && data.size() > 0) {
                            final String[] keyWords = constraint.toString().split(" ");
                            for (Object object : data) {
                                SellerInfo vendor = (SellerInfo) object;
                                if(vendor.hasAnyKeyWord(keyWords)) {
                                    results.add(vendor);
                                }
//                                for (String keyWord : keyWords) {
//                                    if (vendor.getTitle().contains(keyWord)) {
//                                        results.add(vendor);
//                                    }
//                                }
                            }
                        }
                        oReturn.values = results;
                    }
                    return oReturn;
                }

                @SuppressWarnings("unchecked")
                @Override
                protected void publishResults(CharSequence constraint, FilterResults results) {
                    data = (List<SellerInfo>) results.values;
                    notifyDataSetChanged();
                }
            };
        }
        return filter;
    }

}