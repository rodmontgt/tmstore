package com.twist.tmstore.adapters;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.twist.dataengine.entities.BlogItem;
import com.twist.tmstore.R;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

/**
 * Created by Twist Mobile on 10/25/2017.
 */

public class BlogAdapter extends RecyclerView.Adapter<BlogAdapter.ViewHolder> {

    public interface OnBlogItemClickListener {
        void onClick(BlogItem blogItem);
    }

    private List<BlogItem> blogItems;
    private Context mContext;
    private OnBlogItemClickListener mOnBlogItemClickListener;

    public BlogAdapter(List<BlogItem> list) {
        this.blogItems = list;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        mContext = parent.getContext();
        View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_blog, parent, false);
        return new BlogAdapter.ViewHolder(itemView);
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        final BlogItem blogItem = blogItems.get(position);

        if (!TextUtils.isEmpty(blogItem.getPostTitle())) {
            holder.tv_title.setVisibility(View.VISIBLE);
            holder.tv_blog_date.setVisibility(View.VISIBLE);
            holder.tv_title.setText(blogItem.getPostTitle());
        } else {
            holder.tv_title.setVisibility(View.GONE);
            holder.tv_blog_date.setVisibility(View.GONE);
        }

        if (!TextUtils.isEmpty(blogItem.getPostDate())) {
            holder.tv_blog_date.setVisibility(View.VISIBLE);
            SimpleDateFormat dateFormat1 = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            SimpleDateFormat dateFormat2 = new SimpleDateFormat("MMMM dd, yyyy");
            Date convertedDate;
            try {
                convertedDate = dateFormat1.parse(blogItem.getPostDate());
                String date = dateFormat2.format(convertedDate);
                holder.tv_blog_date.setText(date);
            } catch (ParseException e) {
                e.printStackTrace();
            }
        } else {
            holder.tv_blog_date.setVisibility(View.GONE);
        }

        if (!TextUtils.isEmpty(blogItem.getFeaturedImage())) {
            Glide.with(mContext).load(blogItem.getFeaturedImage())
                    .placeholder(R.drawable.placeholder_banner)
                    .error(R.drawable.placeholder_banner)
                    .centerCrop()
                    .into(holder.imageFeatured);
            holder.imageFeatured.setVisibility(View.VISIBLE);
        } else {
            holder.imageFeatured.setVisibility(View.GONE);
        }

        holder.itemView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mOnBlogItemClickListener != null) {
                    mOnBlogItemClickListener.onClick(blogItem);
                }
            }
        });
    }

    @Override
    public int getItemCount() {
        return blogItems.size();
    }

    public void setOnBlogItemClickListener(OnBlogItemClickListener listener) {
        this.mOnBlogItemClickListener = listener;
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        ImageView imageFeatured;
        TextView tv_title;
        TextView tv_blog_date;

        public ViewHolder(View itemView) {
            super(itemView);
            tv_blog_date = (TextView) itemView.findViewById(R.id.tv_blog_date);
            tv_title = (TextView) itemView.findViewById(R.id.tv_title);
            imageFeatured = (ImageView) itemView.findViewById(R.id.image_view_featured);
        }
    }
}
