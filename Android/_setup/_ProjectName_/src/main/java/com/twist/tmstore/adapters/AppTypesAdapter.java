package com.twist.tmstore.adapters;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.twist.tmstore.R;
import com.twist.tmstore.entities.AppType;

import java.util.List;

/**
 * Created by Twist Mobile on 11/27/2017.
 */

public class AppTypesAdapter extends
        RecyclerView.Adapter<AppTypesAdapter.ViewHolder> {
    private List<AppType> mAppTypes;
    private OnItemClickListener listener;

    // Define the listener interface
    public interface OnItemClickListener {
        void onItemClick(int position);
    }

    // Define the method that allows the parent activity or fragment to define the listener
    public void setOnItemClickListener(OnItemClickListener listener) {
        this.listener = listener;
    }

    public AppTypesAdapter(List<AppType> appTypes) {
        mAppTypes = appTypes;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        Context context = parent.getContext();
        LayoutInflater inflater = LayoutInflater.from(context);
        // Inflate the custom layout
        View appTypeView = inflater.inflate(R.layout.item_app_type, parent, false);
        // Return a new holder instance
        return new ViewHolder(appTypeView);
    }

    @Override
    public void onBindViewHolder(ViewHolder viewHolder, int position) {
// Get the data model based on position
        AppType appType = mAppTypes.get(position);

        // Set item views based on your views and data model
        TextView textView = viewHolder.titleTextView;
        textView.setText(appType.getTitle());
        TextView textViewAppDescription = viewHolder.app_description;
        textViewAppDescription.setText(appType.getDescription());
        ImageView iconImageView = viewHolder.iconImageView;
        iconImageView.setImageResource(appType.getIconId());
    }

    @Override
    public int getItemCount() {
        return mAppTypes == null ? 0 : mAppTypes.size();
    }

    // Provide a direct reference to each of the views within a data item
    // Used to cache the views within the item layout for fast access
    public class ViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        // Your holder should contain a member variable
        // for any view that will be set as you render a row
        TextView titleTextView;
        TextView app_description;
        ImageView iconImageView;

        // We also create a constructor that accepts the entire item row
        // and does the view lookups to find each subview
        public ViewHolder(View itemView) {
            // Stores the itemView in a public final member variable that can be used
            // to access the context from any ViewHolder instance.
            super(itemView);

            titleTextView = (TextView) itemView.findViewById(R.id.app_name);
            app_description = (TextView) itemView.findViewById(R.id.app_description);
            iconImageView = (ImageView) itemView.findViewById(R.id.icon_img);
            itemView.setOnClickListener(this);
        }

        @Override
        public void onClick(View v) {
            listener.onItemClick(getAdapterPosition());
        }
    }
}