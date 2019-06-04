package com.twist.tmstore.adapters;

import android.content.Context;
import android.support.annotation.NonNull;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.bignerdranch.expandablerecyclerview.Adapter.ExpandableRecyclerAdapter;
import com.bignerdranch.expandablerecyclerview.Model.ParentListItem;
import com.bignerdranch.expandablerecyclerview.ViewHolder.ChildViewHolder;
import com.bignerdranch.expandablerecyclerview.ViewHolder.ParentViewHolder;
import com.twist.tmstore.R;
import com.twist.tmstore.entities.NavDrawItem;
import com.twist.dataengine.entities.SellerInfo;
import com.twist.tmstore.listeners.VendorClickHandler;
import com.utils.HtmlCompat;

import java.util.List;

public class Adapter_ExpandableVendors extends ExpandableRecyclerAdapter<Adapter_ExpandableVendors.CommonParentViewHolder, Adapter_ExpandableVendors.CommonChildViewHolder> {


    public class CommonParentViewHolder extends ParentViewHolder {

        private final TextView title;
        private final ImageView expand;
        private final ImageView image;
        //private final View view;

        public CommonParentViewHolder(View itemView) {
            super(itemView);
            //view = itemView.findViewById(R.id.main);
            title = (TextView) itemView.findViewById(R.id.title);
            image = (ImageView) itemView.findViewById(R.id.image);
            expand = (ImageView) itemView.findViewById(R.id.expand);
        }

        public void bind(final Object object) {
            title.setText(HtmlCompat.fromHtml(object.toString()));
            image.setVisibility(View.GONE);
        }
    }

    public class CommonChildViewHolder extends ChildViewHolder {
        private final TextView title;
        private final View view;

        public CommonChildViewHolder(View itemView) {
            super(itemView);
            view = itemView.findViewById(R.id.main);
            title = (TextView) itemView.findViewById(R.id.title);
        }

        public void bind(final Object object) {
            title.setText(HtmlCompat.fromHtml(object.toString()));
            if (object instanceof SellerInfo) {
                //details.setVisibility(View.GONE);
                //thumb.setVisibility(View.GONE);
                //expand.setVisibility(View.GONE);
                view.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (mCallback != null) {
                            mCallback.onVendorSelected((SellerInfo) object);
                        }
                    }
                });
            }
        }
    }

    private LayoutInflater mInflator;
    private Context mContext;
    private VendorClickHandler mCallback;

    public Adapter_ExpandableVendors(Context context, @NonNull List<? extends ParentListItem> parentItemList, VendorClickHandler callback) {
        super(parentItemList);
        this.mContext = context;
        this.mCallback = callback;
        mInflator = LayoutInflater.from(context);
    }

    public List<? extends ParentListItem> getAll() {
        return super.getParentItemList();
    }

    public Object get(int index) {
        return super.getParentItemList().get(index);
    }

    public void remove(int index) {
        if (super.getParentItemList().remove(index) != null) {
            notifyItemRemoved(index);
        }
    }

    public void clear() {
        super.getParentItemList().clear();
        notifyDataSetChanged();
    }

    public void remove(NavDrawItem item) {
        int index = super.getParentItemList().indexOf(item);
        if (super.getParentItemList().remove(item)) {
            notifyItemRemoved(index);
        }
    }

    public <T1 extends ParentListItem> void removeAll(List<? extends ParentListItem> items) {
        if (super.getParentItemList().removeAll(items)) {
            notifyDataSetChanged();
        }
    }

    public void notifyLastItemInserted() {
        int index = super.getParentItemList().size();
        if (index > 0) {
            notifyItemInserted(index - 1);
        }
    }

    // onCreate ...
    @Override
    public CommonParentViewHolder onCreateParentViewHolder(ViewGroup parentViewGroup) {
        View recipeView = mInflator.inflate(R.layout.item_common_expandablelist_parent, parentViewGroup, false);
        return new CommonParentViewHolder(recipeView);
    }

    @Override
    public CommonChildViewHolder onCreateChildViewHolder(ViewGroup childViewGroup) {
        View ingredientView = mInflator.inflate(R.layout.item_common_expandablelist_child, childViewGroup, false);
        return new CommonChildViewHolder(ingredientView);
    }

    @Override
    public void onBindParentViewHolder(CommonParentViewHolder parentViewHolder, int position, ParentListItem parentListItem) {
        SellerInfo.ExpandableSeller expandableSeller = (SellerInfo.ExpandableSeller) parentListItem;
        parentViewHolder.bind(expandableSeller);
    }

    @Override
    public void onBindChildViewHolder(CommonChildViewHolder childViewHolder, int position, Object childListItem) {
        childViewHolder.bind(childListItem);
    }


//    private Filter filter = null;
//
//    public Filter getFilter() {
//        if (filter == null) {
//            filter = new Filter() {
//                @Override
//                protected Filter.FilterResults performFiltering(CharSequence constraint) {
//                    final FilterResults oReturn = new FilterResults();
//                    final List<SellerInfo.ExpandableSeller> results = new ArrayList<>();
//                    if (constraint != null) {
//
//                        List<SellerInfo.ExpandableSeller> expandableVendors = (List<SellerInfo.ExpandableSeller>) getAll();
//                        if (expandableVendors != null && expandableVendors.size() > 0) {
//                            final String[] keyWords = constraint.toString().split(" ");
//                            for (SellerInfo.ExpandableSeller expandableVendor : expandableVendors) {
//                                if (expandableVendor.hasAnyKeyWord(keyWords))
//                                    results.add(expandableVendor);
//                            }
//                        }
//                        oReturn.values = results;
//                    }
//                    return oReturn;
//                }
//
//                @SuppressWarnings("unchecked")
//                @Override
//                protected void publishResults(CharSequence constraint, FilterResults results) {
//                    //ToDo
//                    parents(List<SellerInfo>) results.values;
//                    notifyDataSetChanged();
//                }
//            };
//        }
//        return filter;
//    }

}