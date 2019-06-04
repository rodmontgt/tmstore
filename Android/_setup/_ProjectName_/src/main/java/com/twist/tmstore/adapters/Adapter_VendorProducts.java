package com.twist.tmstore.adapters;

import android.app.ProgressDialog;
import android.graphics.Paint;
import android.support.v7.widget.CardView;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.StaggeredGridLayoutManager;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;
import com.twist.dataengine.entities.TM_CommonInfo;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.BaseActivity;
import com.twist.tmstore.config.GuestUserConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.listeners.OnOverflowSelectedListener;
import com.utils.Helper;
import com.utils.HtmlCompat;

import java.util.ArrayList;
import java.util.List;

import static com.twist.tmstore.L.getString;

public class Adapter_VendorProducts extends RecyclerView.Adapter<Adapter_VendorProducts.AbstractViewHolder> {

    private List<TM_ProductInfo> products;

    private List<View> headers = new ArrayList<>();
    private List<View> footers = new ArrayList<>();

    private static final int TYPE_HEADER = 1;
    private static final int TYPE_FOOTER = 2;
    private static final int TYPE_ITEM = 3;
    private static final int TYPE_EMPTY = 4;

    private BaseActivity activity;

    private View emptyView = null;

    private boolean showOptions = false;

    public void setHasSubCategories(boolean hasSubCategories) {
        this.hasSubCategories = hasSubCategories;
    }

    private boolean hasSubCategories = false;

    private String selectedVendorId = "-1";

    public void removeProduct(int productId) {
        for (TM_ProductInfo product : products) {
            if (productId == product.id) {
                products.remove(product);
                notifyDataSetChanged();
                break;
            }
        }
    }

    abstract class AbstractViewHolder extends RecyclerView.ViewHolder {
        AbstractViewHolder(View itemView) {
            super(itemView);
        }

        abstract void bindData(Object object);
    }

    abstract class BaseViewHolder extends AbstractViewHolder {
        TextView name;
        TextView regular_price;
        TextView sale_price;
        ImageView image;
        CardView cardView;
        LinearLayout price_section;
        int position;

        BaseViewHolder(View itemView) {
            super(itemView);
            name = (TextView) itemView.findViewById(R.id.name);
            cardView = (CardView) itemView.findViewById(R.id.cv);
            image = (ImageView) itemView.findViewById(R.id.img);

            price_section = (LinearLayout) itemView.findViewById(R.id.price_section);
            regular_price = (TextView) itemView.findViewById(R.id.regular_price);
            sale_price = (TextView) itemView.findViewById(R.id.sale_price);
            cardView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    MainActivity.mActivity.openProductInfo(products.get(position));
                }
            });
            regular_price.setPaintFlags(regular_price.getPaintFlags() | Paint.STRIKE_THRU_TEXT_FLAG);
            Helper.stylizeSalePriceText(sale_price);
            Helper.stylizeRegularPriceText(regular_price);
        }

        void bindView(Object object) {
            this.position = (int) object;
            TM_ProductInfo product = products.get(position);
            name.setText(HtmlCompat.fromHtml(product.title));
            regular_price.setVisibility(View.GONE);
            sale_price.setVisibility(View.INVISIBLE);
            regular_price.setVisibility(View.VISIBLE);
            // DON"T CHANGE
            // Clear old flags of text view when order of a products changes in list but view don't gets refreshed.
            regular_price.setPaintFlags(regular_price.getPaintFlags() & (~Paint.STRIKE_THRU_TEXT_FLAG));
            regular_price.setText(String.format("%s", product.regular_price));

            if (product.type == TM_ProductInfo.ProductType.VARIABLE) {
                if (product.hasPriceRange()) {
                    StringBuilder price = new StringBuilder(Helper.appendCurrency(product.price_min));
                    price.append(AppInfo.ID_LAYOUT_PRODUCTS == 5 ? "\n- " : " - ");
                    price.append(Helper.appendCurrency(product.price_max));
                    regular_price.setText(HtmlCompat.fromHtml(price));
                } else if (product.hasPriceRangeEqual() && product.price_max > 0) {
                    regular_price.setText(HtmlCompat.fromHtml(Helper.appendCurrency(product.price_max, product)));
                } else if (product.regular_price > 0) {
                    regular_price.setText(HtmlCompat.fromHtml(Helper.appendCurrency(product.regular_price, product)));
                } else {
                    regular_price.setVisibility(View.INVISIBLE);
                }
            } else {
                float actualPrice = product.getActualPrice();
                if (product.regular_price > actualPrice) {
                    this.regular_price.setText(HtmlCompat.fromHtml(Helper.appendCurrency(product.regular_price, product)));
                } else if (actualPrice > 0) {
                    this.regular_price.setText(HtmlCompat.fromHtml(Helper.appendCurrency(actualPrice, product)));
                } else {
                    this.regular_price.setVisibility(View.INVISIBLE);
                }
            }

            if (product.sale_price <= 0 || product.sale_price > product.regular_price) {
                sale_price.setVisibility(View.INVISIBLE);
            } else {
                sale_price.setVisibility(View.VISIBLE);
                sale_price.setText(HtmlCompat.fromHtml(Helper.appendCurrency(product.sale_price, product)));
                regular_price.setPaintFlags(regular_price.getPaintFlags() | Paint.STRIKE_THRU_TEXT_FLAG);
            }

            if (GuestUserConfig.hidePriceTag()) {
                this.regular_price.setVisibility(View.GONE);
                this.sale_price.setVisibility(View.GONE);
            } else if (AppInfo.HIDE_PRODUCT_PRICE_TAG) {
                if (product.regular_price <= 0.0f) {
                    this.regular_price.setVisibility(View.GONE);
                }
                if (product.sale_price <= 0.0f) {
                    this.sale_price.setVisibility(View.GONE);
                }
            }

            if (!TextUtils.isEmpty(product.thumb)) {
                Glide.with(activity)
                        .load(product.thumb)
                        .placeholder(Helper.getPlaceholderColor())
                        .error(R.drawable.error_product)
                        .fitCenter()
                        .into(image);
            } else {
                Glide.with(activity)
                        .load(R.drawable.error_product)
                        .into(image);
            }
        }
    }

    private class EmptyViewHolder extends AbstractViewHolder {
        TextView empty;

        private EmptyViewHolder(View view) {
            super(view);
            empty = (TextView) view.findViewById(R.id.text_empty);
        }

        @Override
        void bindData(Object object) {
            if (AppInfo.basic_content_loading) {
                empty.setText(getString(L.string.loading_products));
            } else {
                empty.setText(hasSubCategories ? "" : getString(L.string.no_product_or_sub_category));
            }
        }
    }

    private class HeaderFooterViewHolder extends AbstractViewHolder {
        FrameLayout base;

        private HeaderFooterViewHolder(View itemView) {
            super(itemView);
            this.base = (FrameLayout) itemView;
        }

        @Override
        void bindData(Object object) {
            View view = (View) object;
            //TODO Don't add view before removing it from parent as well
            base.removeAllViews();
            if (view.getParent() != null) {
                ((ViewGroup) view.getParent()).removeView(view);
            }
            base.addView(view);
        }
    }

    private class ProductViewHolder extends BaseViewHolder {
        ImageButton btn_popup;

        ProductViewHolder(View view) {
            super(view);
            btn_popup = (ImageButton) view.findViewById(R.id.btn_popup);
            if (showOptions && selectedVendorId.equals(String.valueOf(AppUser.getUserId()))) {
                btn_popup.setVisibility(View.VISIBLE);
                Helper.stylizeVector(btn_popup);
            } else {
                btn_popup.setVisibility(View.GONE);
            }
        }

        @Override
        void bindData(Object object) {
            this.bindView(object);
            final ProgressDialog progressDialog = new ProgressDialog(activity);
            if (selectedVendorId.equals(String.valueOf(AppUser.getUserId()))) {
                final TM_ProductInfo product = products.get(position);
                btn_popup.setVisibility(View.VISIBLE);
                btn_popup.setOnClickListener(new OnOverflowSelectedListener(activity, product, new DataQueryHandler() {
                    @Override
                    public void onSuccess(Object data) {
                        products.remove(product);
                        progressDialog.dismiss();
                        notifyDataSetChanged();
                    }

                    @Override
                    public void onFailure(Exception error) {
                        progressDialog.dismiss();
                        error.printStackTrace();
                    }
                }, progressDialog));
            } else {
                btn_popup.setVisibility(View.GONE);
            }
        }
    }

    public Adapter_VendorProducts(BaseActivity activity, String selectedVendorId, List<TM_ProductInfo> products, boolean showOptions) {
        this.activity = activity;
        this.selectedVendorId = selectedVendorId;
        this.showOptions = showOptions;

        if (TM_CommonInfo.hide_out_of_stock) {
            if (this.products == null) {
                this.products = new ArrayList<>();
            }
            for (TM_ProductInfo product : products) {
                if (product.in_stock)
                    this.products.add(product);
            }
        } else {
            this.products = products;
        }
    }

    @Override
    public int getItemCount() {
        int count = getDataItemCount();
        if (count == 0 && emptyView != null) {
            return 1;
        }
        count += headers.size();
        count += footers.size();
        return count;
    }

    public int getDataItemCount() {
        return products.size();
    }

    @Override
    public AbstractViewHolder onCreateViewHolder(ViewGroup viewGroup, int type) {
        LayoutInflater inflater = LayoutInflater.from(viewGroup.getContext());
        switch (type) {
            case TYPE_EMPTY: {
                ViewGroup.LayoutParams layoutParams;
                if (AppInfo.ID_LAYOUT_PRODUCTS == 3) {
                    layoutParams = new StaggeredGridLayoutManager.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                    ((StaggeredGridLayoutManager.LayoutParams) layoutParams).setFullSpan(true);
                } else {
                    layoutParams = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                }
                View view = inflater.inflate(R.layout.item_empty_category, viewGroup, false);
                view.setLayoutParams(layoutParams);
                return new EmptyViewHolder(view);
            }
            case TYPE_HEADER: {
                FrameLayout frameLayout = new FrameLayout(viewGroup.getContext());
                ViewGroup.LayoutParams layoutParams;
                if (AppInfo.ID_LAYOUT_PRODUCTS == 3) {
                    layoutParams = new StaggeredGridLayoutManager.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                    ((StaggeredGridLayoutManager.LayoutParams) layoutParams).setFullSpan(true);
                } else {
                    layoutParams = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                }
                frameLayout.setLayoutParams(layoutParams);
                return new HeaderFooterViewHolder(frameLayout);
            }
            case TYPE_FOOTER: {
                FrameLayout frameLayout = new FrameLayout(viewGroup.getContext());
                ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
                frameLayout.setLayoutParams(layoutParams);
                return new HeaderFooterViewHolder(frameLayout);
            }
            default: {
                View view = inflater.inflate(R.layout.item_product_vendor, viewGroup, false);
                return new ProductViewHolder(view);
            }
        }
    }

    @Override
    public void onBindViewHolder(AbstractViewHolder holder, int position) {
        if (position < headers.size()) {
            holder.bindData(headers.get(position));
        } else if (position >= (headers.size() + products.size())) {
            holder.bindData(footers.get(position - products.size() - headers.size()));
        } else if (!products.isEmpty()) {
            holder.bindData(position - headers.size());
        } else {
            holder.bindData(null);
        }
    }

    @Override
    public int getItemViewType(int position) {
        if (position < headers.size())
            return TYPE_HEADER;
        else if (products.isEmpty())
            return TYPE_EMPTY;
        else if (position >= headers.size() + products.size())
            return TYPE_FOOTER;
        return TYPE_ITEM;
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
            notifyItemInserted(headers.size() + products.size() + footers.size() - 1);
        }
    }

    public void removeFooter(View footer) {
        if (footers.contains(footer)) {
            notifyItemRemoved(headers.size() + products.size() + footers.indexOf(footer));
            footers.remove(footer);
            if (footer.getParent() != null) {
                ((ViewGroup) footer.getParent()).removeView(footer);
            }
        }
    }

    public void updateResult(List<TM_ProductInfo> newData) {
        products.clear();
        for (TM_ProductInfo product : newData) {
            if (!hasProduct(product)) {
                if (!(DataEngine.hide_blocked_items && product.isBlocked())) {
                    products.add(product);
                }
            }
        }
        notifyDataSetChanged();
    }

    public void addProduct(TM_ProductInfo newProduct) {
        if (TM_CommonInfo.hide_out_of_stock && !newProduct.in_stock) {
            return;
        }
        products.add(newProduct);
        notifyDataSetChanged();
    }

    public boolean addProducts(List<TM_ProductInfo> newProducts) {
        int oldSize = this.products.size();
        boolean isAnyNewProductAdded = false;
        for (TM_ProductInfo newProduct : newProducts) {
            if (!this.hasProduct(newProduct)) {
                if (newProduct.getStatus() == null || !newProduct.getStatus().equals("trash")) {
                    this.products.add(newProduct);
                }
                isAnyNewProductAdded = true;
            }
        }
        int range = this.products.size() - oldSize;
        if (range > 0) {
            notifyItemRangeInserted(oldSize + headers.size(), range);
        }
        return isAnyNewProductAdded;
    }

    public boolean hasProduct(TM_ProductInfo newProduct) {
        for (TM_ProductInfo product : products) {
            if (newProduct.id == product.id)
                return true;
        }
        return false;
    }
}