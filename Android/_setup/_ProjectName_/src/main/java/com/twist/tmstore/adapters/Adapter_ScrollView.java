package com.twist.tmstore.adapters;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Paint;
import android.support.v7.widget.CardView;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.drawable.GlideDrawable;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.target.Target;
import com.twist.dataengine.DataEngine;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.entities.SellerInfo;
import com.twist.dataengine.entities.TM_CategoryInfo;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.HomeElementUltimate.Variable;
import com.twist.tmstore.entities.HomeElementUltimate.Variable.Content;
import com.twist.tmstore.entities.Wishlist;
import com.twist.tmstore.listeners.OnWishListChangeListener;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.ImageDownload;
import com.utils.customviews.progressbar.CircleProgressBar;

import java.util.List;

import static com.twist.tmstore.L.getString;

public class Adapter_ScrollView extends RecyclerView.Adapter<Adapter_ScrollView.BaseViewHolder> {

    private List items;

    private static final int ITEM_TYPE_CATEGORY = 0;
    private static final int ITEM_TYPE_PRODUCT = 1;
    private static final int ITEM_TYPE_SELLERS = 4;

    public static final int ITEM_TYPE_TINY_CATEGORY = 100;
    public static final int ITEM_TYPE_TINY_PRODUCT = 101;
    public static final int ITEM_TYPE_TINY_SELLER = 104;
    public static final int ITEM_ID_VIEW_MORE = -99;

    private Context context;
    private View cordView;
    public boolean checkMode = false;

    private View.OnClickListener checkBoxChangeListener;
    private int orientation = LinearLayoutManager.HORIZONTAL;

    abstract class BaseViewHolder extends RecyclerView.ViewHolder {
        public BaseViewHolder(View vi) {
            super(vi);
            if (orientation == LinearLayoutManager.VERTICAL) {
                vi.getLayoutParams().width = LinearLayout.LayoutParams.MATCH_PARENT;
                vi.getLayoutParams().height = Helper.DP(250);
            }
        }

        abstract void bindData(int position);
    }

    abstract class BaseProductViewHolder extends BaseViewHolder {
        TextView name;
        TextView regular_price;
        TextView sale_price;
        TextView txt_discount;
        ImageView img;
        CircleProgressBar progressBar;

        CardView cv;

        public BaseProductViewHolder(View vi) {
            super(vi);
            name = (TextView) vi.findViewById(R.id.name);
            cv = (CardView) vi.findViewById(R.id.cv);
            img = (ImageView) vi.findViewById(R.id.img);
            regular_price = (TextView) vi.findViewById(R.id.regular_price);
            txt_discount = (TextView) vi.findViewById(R.id.txt_discount);
            sale_price = (TextView) vi.findViewById(R.id.sale_price);
            progressBar = (CircleProgressBar) vi.findViewById(R.id.progress);
            Helper.stylize(progressBar);
            Helper.stylizeSalePriceText(sale_price);
            Helper.stylizeRegularPriceText(regular_price);
            Helper.stylizeActionText(txt_discount);
            regular_price.setPaintFlags(regular_price.getPaintFlags() | Paint.STRIKE_THRU_TEXT_FLAG);
            img.setScaleType(ImageView.ScaleType.CENTER_CROP);
        }

        final void bindData(int position) {
            Object item = items.get(position);
            if (item instanceof TM_ProductInfo) {
                TM_ProductInfo product = (TM_ProductInfo) item;
                bindData(product);
            } else {
                Content content = (Content) items.get(position);
                final TM_ProductInfo product = TM_ProductInfo.findProductById(content.id);
                if (product != null) {
                    bindData(product);
                } else {
                    progressBar.setVisibility(View.VISIBLE);
                    DataEngine.getDataEngine().getProductInfoInBackground(content.id, new DataQueryHandler<TM_ProductInfo>() {
                                @Override
                                public void onSuccess(TM_ProductInfo data) {
                                    progressBar.setVisibility(View.GONE);
                                    bindData(data);
                                }

                                @Override
                                public void onFailure(Exception e) {
                                    progressBar.setVisibility(View.GONE);
                                    e.printStackTrace();
                                }
                            }
                    );
                }
            }
        }


        void bindData(final TM_ProductInfo product) {
            if (product != null) {
                cv.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        MainActivity.mActivity.openProductInfo(product);
                    }
                });

                checkMode = AppInfo.ENABLE_SINGLE_CHECK_WISHLIST || checkMode;
                name.setText(HtmlCompat.fromHtml(product.title));

                txt_discount.setVisibility(View.GONE);
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
                        if (AppInfo.SHOW_DISCOUNT_PERCENTAGE_ON_PRODUCTS) {
                            this.txt_discount.setVisibility(View.VISIBLE);
                            this.txt_discount.setText("-" + product.getDiscountPercentage() + "%");
                        }
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

                Glide.with(context)
                        .load(product.thumb)
                        .placeholder(AppInfo.ID_PLACEHOLDER_PRODUCT)
                        .error(R.drawable.error_product)
                        .into(img);
            }
        }
    }

    private class CategoryViewHolder extends BaseViewHolder {
        View cv;
        ImageView item_icon;
        View name_section;
        TextView text_categoryname;

        CategoryViewHolder(View view) {
            super(view);
            cv = view.findViewById(R.id.cv);
            item_icon = (ImageView) view.findViewById(R.id.item_icon);
            name_section = view.findViewById(R.id.name_section);
            text_categoryname = (TextView) view.findViewById(R.id.text_categoryname);
        }

        @Override
        void bindData(int position) {
            final TM_CategoryInfo category = (TM_CategoryInfo) items.get(position);
            cv.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    expandCategory(category);
                }
            });

            if (!TextUtils.isEmpty(category.getName())) {
                name_section.setVisibility(View.VISIBLE);
                text_categoryname.setText(HtmlCompat.fromHtml(category.getName()));
            } else {
                name_section.setVisibility(View.INVISIBLE);
            }

            if (!TextUtils.isEmpty(category.image)) {
                Glide.with(context)
                        .load(category.image)
                        .placeholder(Helper.getPlaceholderColor())
                        .error(R.drawable.error_category)
                        .into(item_icon);
            }
        }
    }

    private class TinyViewHolder extends BaseViewHolder {
        int type;

        View cv;
        ImageView item_icon;
        View name_section;
        TextView text_categoryname;

        TinyViewHolder(View view) {
            super(view);
            type = (int) view.getTag();

            cv = view.findViewById(R.id.cv);
            item_icon = (ImageView) view.findViewById(R.id.item_icon);
            name_section = view.findViewById(R.id.name_section);
            text_categoryname = (TextView) view.findViewById(R.id.text_categoryname);
        }

        @Override
        void bindData(int position) {
            final Content content = (Content) items.get(position);
            TM_CategoryInfo categoryInfo;
            TM_ProductInfo productInfo;

            if (type == ITEM_TYPE_TINY_CATEGORY) {
                categoryInfo = TM_CategoryInfo.getWithId(content.id);

                if (!TextUtils.isEmpty(content.name)) {
                    name_section.setVisibility(View.VISIBLE);
                    text_categoryname.setText(HtmlCompat.fromHtml(content.name));
                } else if (categoryInfo != null && !TextUtils.isEmpty(categoryInfo.getName())) {
                    name_section.setVisibility(View.VISIBLE);
                    text_categoryname.setText(HtmlCompat.fromHtml(categoryInfo.getName()));
                } else {
                    name_section.setVisibility(View.INVISIBLE);
                }

                String imageUrl = null;
                if (!TextUtils.isEmpty(content.img)) {
                    imageUrl = content.img;
                } else if (categoryInfo != null && !TextUtils.isEmpty(categoryInfo.image)) {
                    imageUrl = categoryInfo.image;
                }
                if (imageUrl != null) {
                    Glide.with(context)
                            .load(imageUrl)
                            .placeholder(Helper.getPlaceholderColor())
                            .error(R.drawable.error_category)
                            .into(item_icon);
                }
            } else {
                productInfo = TM_ProductInfo.findProductById(content.id);
                if (!TextUtils.isEmpty(content.name)) {
                    name_section.setVisibility(View.VISIBLE);
                    text_categoryname.setText(HtmlCompat.fromHtml(content.name));
                } else if (productInfo != null && !TextUtils.isEmpty(productInfo.title)) {
                    name_section.setVisibility(View.VISIBLE);
                    text_categoryname.setText(HtmlCompat.fromHtml(productInfo.title));
                } else {
                    name_section.setVisibility(View.INVISIBLE);
                }

                String imageUrl = null;
                if (!TextUtils.isEmpty(content.img)) {
                    imageUrl = content.img;
                } else if (productInfo != null && !TextUtils.isEmpty(productInfo.thumb)) {
                    imageUrl = productInfo.thumb;
                }

                if (imageUrl != null) {
                    Glide.with(context)
                            .load(imageUrl)
                            .placeholder(Helper.getPlaceholderColor())
                            .error(R.drawable.error_category)
                            .into(item_icon);
                }
            }
            cv.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (content.id == ITEM_ID_VIEW_MORE) {
                        if (content.type == ITEM_TYPE_TINY_CATEGORY) {
                            showAllCategoryList();
                        } else if (content.type == ITEM_TYPE_TINY_SELLER) {
                            showAllSellerList();
                        }
                    } else {
                        if (content.type == ITEM_TYPE_TINY_CATEGORY) {
                            expandCategory(content.id);
                        } else if (content.type == ITEM_TYPE_TINY_PRODUCT) {
                            showProductInfo(content.id);
                        }
                    }
                }
            });

            if (Helper.isValidString(content.bgUrl)) {
                Glide.with(context)
                        .load(content.bgUrl)
                        .listener(new RequestListener<String, GlideDrawable>() {
                            @Override
                            public boolean onException(Exception e, String model, Target<GlideDrawable> target, boolean isFirstResource) {
                                return false;
                            }

                            @Override
                            public boolean onResourceReady(GlideDrawable resource, String model, Target<GlideDrawable> target, boolean isFromMemoryCache, boolean isFirstResource) {
                                return false;
                            }
                        });
            } else if (Helper.isValidString(content.bgcolor)) {
                try {
                    cv.setBackgroundColor(Color.parseColor(content.bgcolor));
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private class SellerViewHolder extends BaseViewHolder {
        View cv;
        View item_icon_container;
        ImageView item_bg;
        ImageView item_icon;
        View name_section;
        TextView text_categoryname;

        SellerViewHolder(View view) {
            super(view);
            cv = view.findViewById(R.id.cv);
            item_icon_container = view.findViewById(R.id.item_icon_container);
            item_bg = (ImageView) view.findViewById(R.id.item_bg);
            item_icon = (ImageView) view.findViewById(R.id.item_icon);
            name_section = view.findViewById(R.id.name_section);
            text_categoryname = (TextView) view.findViewById(R.id.text_categoryname);
        }

        @Override
        void bindData(int position) {
            final SellerInfo seller = (SellerInfo) items.get(position);
            this.cv.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    MainActivity.mActivity.showSellerInfo(seller);
                }
            });

            if (Helper.isValidString(seller.getTitle())) {
                name_section.setVisibility(View.VISIBLE);
                text_categoryname.setText(HtmlCompat.fromHtml(seller.getTitle()));
            } else {
                name_section.setVisibility(View.INVISIBLE);
            }

            if (Helper.isValidString(seller.getShopImageUrl())) {
                Glide.with(context)
                        .load(seller.getShopImageUrl())
                        .placeholder(Helper.getPlaceholderColor())
                        .error(R.drawable.error_category)
                        .into(item_bg);
            }

            if (Helper.isValidString(seller.getAvatarUrl())) {
                Glide.with(context)
                        .load(seller.getAvatarUrl())
                        .placeholder(Helper.getPlaceholderColor())
                        .into(item_icon);
                item_icon_container.setVisibility(View.VISIBLE);
            } else {
                item_icon_container.setVisibility(View.GONE);
            }
        }
    }

    private class TinySellerViewHolder extends BaseViewHolder {
        View cardView;
        View item_icon_container;
        ImageView item_bg;
        ImageView item_icon;
        View name_section;
        TextView text_categoryname;

        TinySellerViewHolder(View view) {
            super(view);
            cardView = view.findViewById(R.id.cv);
            item_icon_container = view.findViewById(R.id.item_icon_container);
            item_bg = (ImageView) view.findViewById(R.id.item_bg);
            item_icon = (ImageView) view.findViewById(R.id.item_icon);
            name_section = view.findViewById(R.id.name_section);
            text_categoryname = (TextView) view.findViewById(R.id.text_categoryname);
        }

        @Override
        void bindData(int position) {
            Object object = items.get(position);
            if (object instanceof Variable.Content) {
                final Variable.Content sellerContent = (Variable.Content) object;
                cardView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        ((MainActivity) view.getContext()).showSellerInfo(SellerInfo.findSellerById(sellerContent.redirect_id));
                    }
                });

                if (Helper.isValidString(sellerContent.name)) {
                    name_section.setVisibility(View.VISIBLE);
                    text_categoryname.setText(HtmlCompat.fromHtml(sellerContent.name));
                } else {
                    name_section.setVisibility(View.INVISIBLE);
                }

                if (Helper.isValidString(sellerContent.bgUrl)) {
                    Glide.with(context)
                            .load(sellerContent.bgUrl)
                            .placeholder(Helper.getPlaceholderColor())
                            .error(R.drawable.error_category)
                            .into(item_bg);
                }

                if (Helper.isValidString(sellerContent.img)) {
                    Glide.with(context)
                            .load(sellerContent.img)
                            .placeholder(Helper.getPlaceholderColor())
                            .into(item_icon);
                    item_icon_container.setVisibility(View.VISIBLE);
                } else {
                    item_icon_container.setVisibility(View.GONE);
                }
            }
        }
    }

    private class ProductViewHolder1 extends BaseProductViewHolder {
        CheckBox chk_wishlist;
        ImageButton btn_download;
        CheckBox checkBox_action;
        CircleProgressBar progress;

        ProductViewHolder1(View view) {
            super(view);
            chk_wishlist = (CheckBox) view.findViewById(R.id.chk_wishlist);
            btn_download = (ImageButton) view.findViewById(R.id.btn_download);
            checkBox_action = (CheckBox) view.findViewById(R.id.checkBox_action);
            checkBox_action.setVisibility(View.GONE);
            Helper.stylize(checkBox_action);
            Helper.stylizeVector(btn_download);
            if (AppInfo.ENABLE_WISHLIST) {
                chk_wishlist.setVisibility(View.VISIBLE);
            } else {
                chk_wishlist.setVisibility(View.GONE);
            }
            Helper.setStyleWithDrawables(chk_wishlist, R.drawable.ic_vc_wish_border, R.drawable.ic_vc_wish_selected);
        }

        @Override
        void bindData(final TM_ProductInfo product) {
            super.bindData(product);
            if (AppInfo.ENABLE_WISHLIST) {
                chk_wishlist.setVisibility(View.VISIBLE);
                chk_wishlist.setOnCheckedChangeListener(null);
                chk_wishlist.setChecked(Wishlist.hasItem(product));
                chk_wishlist.setOnCheckedChangeListener(new OnWishListChangeListener(product, cordView));
            }

            if ((AppInfo.mImageDownloaderConfig != null && AppInfo.mImageDownloaderConfig.isShowInHome())) {
                btn_download.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        Toast.makeText(context, getString(L.string.download_initiated), Toast.LENGTH_SHORT).show();
                        ImageDownload.downloadProductCatalog(view.getContext(), product);
                    }
                });
                btn_download.setVisibility(View.VISIBLE);
            } else {
                btn_download.setVisibility(View.GONE);
            }

            if ((AppInfo.mImageDownloaderConfig != null && AppInfo.mImageDownloaderConfig.isShowInHome())) {
                btn_download.setVisibility(View.GONE);
                chk_wishlist.setVisibility(View.GONE);
                checkBox_action.setVisibility(View.VISIBLE);

                checkBox_action.setOnCheckedChangeListener(null);
                checkBox_action.setChecked(product.isChecked);
                checkBox_action.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                    @Override
                    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                        product.isChecked = isChecked;
                        if (isChecked)
                            notifyDataSetChanged();
                        checkBoxChangeListener.onClick(buttonView);
                    }
                });
            }

            if (checkMode) {
                checkBox_action.setVisibility(View.VISIBLE);
                btn_download.setVisibility(View.GONE);
            } else {
                checkBox_action.setVisibility(View.GONE);
                checkBox_action.setOnCheckedChangeListener(null);
                checkBox_action.setChecked(false);
                product.isChecked = false;
            }
        }
    }

    public Adapter_ScrollView(Context context, List items, View.OnClickListener checkBoxChangeListener, int orientation) {
        this(context, items, checkBoxChangeListener);
        this.orientation = orientation;
    }

    public Adapter_ScrollView(Context context, List items, View.OnClickListener checkBoxChangeListener) {
        this.context = context;
        this.items = items;
        this.checkBoxChangeListener = checkBoxChangeListener;
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    @Override
    public BaseViewHolder onCreateViewHolder(ViewGroup viewGroup, int type) {
        switch (type) {
            case ITEM_TYPE_CATEGORY: {
                return new CategoryViewHolder(LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.item_horizontal_scroll_category_0, viewGroup, false));
            }
            case ITEM_TYPE_TINY_CATEGORY: {
                View view = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.item_horizontal_scroll_category_0, viewGroup, false);
                view.getLayoutParams().height = (int) mCardViewHeight;
                view.setTag(type);
                return new TinyViewHolder(view);
            }
            case ITEM_TYPE_TINY_SELLER: {
                return new TinySellerViewHolder(LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.item_horizontal_scroll_seller, viewGroup, false));
            }
            case ITEM_TYPE_SELLERS: {
                return new SellerViewHolder(LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.item_horizontal_scroll_seller, viewGroup, false));
            }
            default: {
                return new ProductViewHolder1(LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.item_horizontal_scroll_product_1, viewGroup, false));
            }
        }
    }

    @Override
    public void onBindViewHolder(BaseViewHolder viewHolder, final int position) {
        viewHolder.bindData(position);
    }

    @Override
    public void onAttachedToRecyclerView(RecyclerView recyclerView) {
        super.onAttachedToRecyclerView(recyclerView);
        cordView = recyclerView;
    }

    public void updateItems(List newItems, int limit) {
        items.clear();
        if (limit >= 0 && limit < newItems.size()) {
            items.addAll(newItems.subList(0, limit));
        } else {
            items.addAll(newItems);
        }
        notifyDataSetChanged();
    }

    @Override
    public int getItemViewType(int position) {
        Object item = items.get(position);
        if (item instanceof TM_CategoryInfo)
            return ITEM_TYPE_CATEGORY;
        if (item instanceof SellerInfo)
            return ITEM_TYPE_SELLERS;
        if (item instanceof Content) {
            return ((Content) item).type;
        }
        return ITEM_TYPE_PRODUCT;
    }

    private void showProductInfo(int productId) {
        ((MainActivity) context).openOrLoadProductInfo(productId);
    }

    private void expandCategory(int categoryId) {
        ((MainActivity) context).expandCategory(categoryId);
    }

    private void showAllCategoryList() {
        ((MainActivity) context).showAllCategoryList();
    }

    private void showAllSellerList() {
        ((MainActivity) context).showAllSellerList();
    }

    private void expandCategory(TM_CategoryInfo category) {
        ((MainActivity) context).expandCategory(category);
    }

    private float mCardViewHeight = 0;

    public void setCardViewHeight(float height) {
        mCardViewHeight = height;
    }
}