package com.twist.tmstore.adapters;

import android.graphics.Color;
import android.graphics.Paint;
import android.location.Location;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.CardView;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.StaggeredGridLayoutManager;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.Filter;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ToggleButton;

import com.bumptech.glide.Glide;
import com.google.gson.Gson;
import com.twist.dataengine.DataEngine;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.entities.TM_Attribute;
import com.twist.dataengine.entities.TM_CommonInfo;
import com.twist.dataengine.entities.TM_FilterAttribute;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.dataengine.entities.UserFilter;
import com.twist.tmstore.BaseActivity;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.config.GuestUserConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.Cart;
import com.twist.tmstore.entities.FilterSortByComparator;
import com.twist.tmstore.entities.FilterSortType;
import com.twist.tmstore.entities.WishListGroup;
import com.twist.tmstore.entities.Wishlist;
import com.twist.tmstore.fragments.Fragment_Wishlist_Dialog;
import com.twist.tmstore.listeners.QuantityListener;
import com.twist.tmstore.listeners.ValueObserver;
import com.twist.tmstore.listeners.WishListDialogHandler;
import com.utils.CContext;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.ImageDownload;
import com.utils.ListUtils;
import com.utils.Log;
import com.utils.customviews.progressbar.CircleProgressBar;

import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;

import static com.twist.tmstore.L.getString;

public class Adapter_Products extends RecyclerView.Adapter<Adapter_Products.AbstractViewHolder> {

    public static int ID_LAYOUT_PRODUCTS = -1;

    private List<TM_ProductInfo> products;
    private List<TM_ProductInfo> original_data;

    private List<View> headers = new ArrayList<>();
    private List<View> footers = new ArrayList<>();
    public static HashMap<Integer, Boolean> mCheckedItem = new HashMap<>();

    private static final int TYPE_HEADER = 1;
    private static final int TYPE_FOOTER = 2;
    private static final int TYPE_ITEM = 3;
    private static final int TYPE_EMPTY = 4;

    private BaseActivity activity;
    private View.OnLongClickListener longClickListener;
    private View.OnClickListener checkBoxChangeListener;

    private View emptyView = null;

    public boolean checkMode = false;

    public void setHasSubCategories(boolean hasSubCategories) {
        this.hasSubCategories = hasSubCategories;
    }

    private boolean hasSubCategories = false;

    private View cordView = null;

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
        TextView txt_discount;
        ImageView image;
        CardView cardView;

        LinearLayout price_section;

        LinearLayout out_of_stock_section;
        TextView text_out_of_stock;
        TextView text_saletag;
        TextView text_newtag;
        int position;
        TextView text_distance;

        public BaseViewHolder(View itemView) {
            super(itemView);
            name = (TextView) itemView.findViewById(R.id.name);
            cardView = (CardView) itemView.findViewById(R.id.cv);
            image = (ImageView) itemView.findViewById(R.id.img);

            price_section = (LinearLayout) itemView.findViewById(R.id.price_section);
            regular_price = (TextView) itemView.findViewById(R.id.regular_price);
            txt_discount = (TextView) itemView.findViewById(R.id.txt_discount);
            txt_discount.setVisibility(View.INVISIBLE);

            sale_price = (TextView) itemView.findViewById(R.id.sale_price);
            Helper.stylizeRegularPriceText(regular_price);
            Helper.stylizeSalePriceText(sale_price);
            Helper.stylizeActionText(txt_discount);

            out_of_stock_section = (LinearLayout) itemView.findViewById(R.id.out_of_stock_section);
            text_out_of_stock = (TextView) itemView.findViewById(R.id.text_out_of_stock);
            text_saletag = (TextView) itemView.findViewById(R.id.text_saletag);
            text_newtag = (TextView) itemView.findViewById(R.id.text_newtag);

            if (ID_LAYOUT_PRODUCTS == 5) {
                Helper.stylizeActionText(text_out_of_stock);
                text_out_of_stock.setText(getString(L.string.out_of_stock_tag));
                text_out_of_stock.setVisibility(View.GONE);
            } else {
                if (out_of_stock_section != null) {
                    out_of_stock_section.setBackground(CContext.getDrawable(activity, R.drawable.border_layout_transperent));
                    out_of_stock_section.setVisibility(View.GONE);
                }
                text_out_of_stock.setBackground(CContext.getDrawable(activity, R.drawable.border_layout_white));
                text_out_of_stock.setText(getString(L.string.out_of_stock_tag));
                text_out_of_stock.setTextColor(Color.parseColor(AppInfo.color_actionbar_text));
                text_out_of_stock.setVisibility(View.GONE);
            }

            Helper.stylizeActionText(text_saletag);
            text_saletag.setText(getString(L.string.sale_tag));
            text_saletag.setVisibility(View.GONE);

            Helper.stylizeActionText(text_newtag);
            text_newtag.setText(getString(L.string.new_tag));
            text_newtag.setVisibility(View.GONE);

            cardView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    MainActivity.mActivity.openProductInfo(products.get(position));
                }
            });
			
            text_distance = (TextView) itemView.findViewById(R.id.filter_location_distance);
            if (text_distance != null) {
                text_distance.setVisibility(View.GONE);
            }
        }

        void bindView(Object object) {
            this.position = (int) object;
            TM_ProductInfo product = products.get(position);
            //Log.d("PRODUCT_THUMB_URL::", product.thumb);
            this.name.setText(HtmlCompat.fromHtml(product.title));
//          Helper.setProductPriceValueAndTags(product, regular_price, sale_price, txt_discount, out_of_stock_section, text_out_of_stock, text_saletag, text_newtag);
            txt_discount.setVisibility(View.INVISIBLE);
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

            if (ID_LAYOUT_PRODUCTS == 4) {
                image.setVisibility(View.GONE);
                regular_price.setVisibility(View.VISIBLE);
                regular_price.setPaintFlags(regular_price.getPaintFlags() & (~Paint.STRIKE_THRU_TEXT_FLAG));
                if (!TextUtils.isEmpty(product.getShortDescription())) {
                    regular_price.setText(HtmlCompat.fromHtml(product.getShortDescription()));
                } else {
                    regular_price.setText(HtmlCompat.fromHtml(product.title));
                }
            } else {
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

            if (AppInfo.SHOW_SALE_PRODUCT_TAG && sale_price.getVisibility() == View.VISIBLE) {
                regular_price.setPaintFlags(regular_price.getPaintFlags() | Paint.STRIKE_THRU_TEXT_FLAG);
                text_saletag.setVisibility(View.VISIBLE);
            } else {
                text_saletag.setVisibility(View.GONE);
            }

            if (AppInfo.SHOW_NEW_PRODUCT_TAG && Helper.getDaysDifference(product.created_at) < AppInfo.NEW_PRODUCT_DAYS_LIMIT) {
                this.text_saletag.setVisibility(View.GONE);
                this.text_newtag.setVisibility(View.VISIBLE);
            } else {
                text_newtag.setVisibility(View.GONE);
            }

            if (AppInfo.SHOW_OUTOFSTOCK_PRODUCT_TAG && !product.in_stock) {
                if (this.out_of_stock_section != null) {
                    this.out_of_stock_section.setVisibility(View.VISIBLE);
                }
                this.text_out_of_stock.setVisibility(View.VISIBLE);
                this.text_saletag.setVisibility(View.GONE);
                this.text_newtag.setVisibility(View.GONE);
            } else {
                if (this.out_of_stock_section != null) {
                    this.out_of_stock_section.setVisibility(View.GONE);
                }
                this.text_out_of_stock.setVisibility(View.GONE);
            }

            if (AppInfo.HIDE_PRODUCT_PRICE_TAG || GuestUserConfig.hidePriceTag()) {
                this.regular_price.setVisibility(View.GONE);
                this.txt_discount.setVisibility(View.INVISIBLE);
                this.sale_price.setVisibility(View.GONE);
            }

            if (text_distance != null) {
                if (AppInfo.ENABLE_LOCATION_IN_FILTERS && !TextUtils.isEmpty(product.distance) && userFilter != null) {
                    text_distance.setVisibility(View.VISIBLE);
                    text_distance.setText(HtmlCompat.fromHtml(String.format(getString(L.string.distance, true), product.distance)));
                } else {
                    text_distance.setVisibility(View.GONE);
                }
            }
        }
    }

    public class EmptyViewHolder extends AbstractViewHolder {
        TextView empty;

        public EmptyViewHolder(View view) {
            super(view);
            empty = (TextView) view.findViewById(R.id.text_empty);
        }

        @Override
        void bindData(Object object) {
            if (AppInfo.basic_content_loading) {
                empty.setText(getString(L.string.loading_products));
            } else {
                if (hasSubCategories) {
                    empty.setText("");
                } else {
                    empty.setText(getString(L.string.no_product_or_sub_category));
                }
            }
        }
    }

    public class HeaderFooterViewHolder extends AbstractViewHolder {
        FrameLayout base;

        public HeaderFooterViewHolder(View itemView) {
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

    private class ProductViewHolder1 extends BaseViewHolder {
        CompoundButton chk_wishlist;
        CardView cv;
        CheckBox btn_checkBox;
        ImageButton btn_download;

        ProductViewHolder1(View view) {
            super(view);
            chk_wishlist = (CompoundButton) view.findViewById(R.id.chk_wishlist);
            if (AppInfo.ENABLE_WISHLIST) {
                if (chk_wishlist instanceof ToggleButton) {
                    Helper.setStyleWithDrawables(chk_wishlist, R.drawable.ic_vc_wish_border, R.drawable.ic_vc_wish_selected, android.R.color.white);
                    ToggleButton toggleButton = (ToggleButton) chk_wishlist;
                    toggleButton.setTextOn(getString(L.string.toggle_wishlist_on));
                    toggleButton.setTextOff(getString(L.string.toggle_wishlist_off));
                    Helper.stylize(toggleButton);
                } else {
                    Helper.setStyleWithDrawables(chk_wishlist, R.drawable.ic_vc_wish_border, R.drawable.ic_vc_wish_selected);
                }
                chk_wishlist.setVisibility(View.VISIBLE);
            } else {
                chk_wishlist.setVisibility(View.GONE);
            }

            if (AppInfo.ENABLE_MULTIPLE_WISHLIST || (AppInfo.mImageDownloaderConfig != null && AppInfo.mImageDownloaderConfig.isShowInCategory())) {
                cv = (CardView) view.findViewById(R.id.cv);

                btn_checkBox = new CheckBox(activity);
                btn_checkBox.setVisibility(View.INVISIBLE);
                btn_checkBox.setChecked(false);
                Helper.stylize(btn_checkBox);

                RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(new ViewGroup.LayoutParams(
                        ViewGroup.LayoutParams.WRAP_CONTENT,
                        ViewGroup.LayoutParams.WRAP_CONTENT));
                params.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
                params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM, R.id.price_section);

                btn_checkBox.setLayoutParams(params); //causes layout update
                ((ViewGroup) price_section.getParent()).addView(btn_checkBox);

                cv.setOnLongClickListener(new View.OnLongClickListener() {
                    @Override
                    public boolean onLongClick(View view) {
                        btn_checkBox.setVisibility(View.VISIBLE);
                        btn_checkBox.setChecked(true);
                        longClickListener.onLongClick(view);
                        setCheckMode(true);
                        return true;
                    }
                });

                btn_download = new ImageButton(activity);
                btn_download.setBackgroundColor(Color.TRANSPARENT);
                btn_download.setImageDrawable(ContextCompat.getDrawable(activity, R.drawable.ic_download_black));
                btn_download.setLayoutParams(params); //causes layout update
                ((ViewGroup) price_section.getParent()).addView(btn_download);

                if (AppInfo.mImageDownloaderConfig == null || !AppInfo.mImageDownloaderConfig.isShowInCategory()) {
                    btn_checkBox.setVisibility(View.GONE);
                    btn_download.setVisibility(View.GONE);
                    cv.setLongClickable(false);
                }
            }
        }

        @Override
        void bindData(Object object) {
            checkMode = AppInfo.ENABLE_SINGLE_CHECK_WISHLIST || checkMode;
            this.bindView(object);

            if (AppInfo.ENABLE_WISHLIST) {
                TM_ProductInfo product = products.get(position);
                chk_wishlist.setVisibility(View.VISIBLE);
                chk_wishlist.setOnCheckedChangeListener(null);
                chk_wishlist.setChecked(Wishlist.hasItem(product));
                chk_wishlist.setOnCheckedChangeListener(new OnWishChkClickListener(position));
            }

            if (AppInfo.ENABLE_SINGLE_CHECK_WISHLIST) {
                chk_wishlist.setVisibility(View.GONE);
            }

            if (AppInfo.ENABLE_MULTIPLE_WISHLIST || (AppInfo.mImageDownloaderConfig != null && AppInfo.mImageDownloaderConfig.isShowInCategory())) {

                final TM_ProductInfo product = products.get(position);
                btn_checkBox.setOnCheckedChangeListener(null);
                btn_checkBox.setChecked(product.isChecked);
                btn_checkBox.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                    @Override
                    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                        //set your object's last status
                        product.isChecked = isChecked;
                        if (isChecked)
                            notifyDataSetChanged();

                        mCheckedItem.put(product.id, product.isChecked);
                        checkBoxChangeListener.onClick(buttonView);
                    }
                });

                btn_download.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        Toast.makeText(activity, getString(L.string.download_initiated), Toast.LENGTH_SHORT).show();
                        ImageDownload.downloadProductCatalog(view.getContext(), product);
                    }
                });

                if (checkMode) {
                    btn_checkBox.setVisibility(View.VISIBLE);
                    btn_download.setVisibility(View.GONE);
                } else {
                    btn_checkBox.setVisibility(View.GONE);
                    btn_checkBox.setOnCheckedChangeListener(null);
                    btn_checkBox.setChecked(false);
                    product.isChecked = false;
                }
            }
        }
    }

    private class ProductViewHolder2 extends BaseViewHolder implements View.OnClickListener {
        View quantitySection;

        ImageButton btnQtyPlus;
        ImageButton btnQtyMinus;
        Button btnAddToCart;
        EditText textQuantity;

        CircleProgressBar progressBar;
        CompoundButton chk_wishlist;

        ProductViewHolder2(View view) {
            super(view);

            textQuantity = (EditText) view.findViewById(R.id.quantity);
            if (ID_LAYOUT_PRODUCTS == 4) {
                textQuantity.addTextChangedListener(new QuantityListener(textQuantity, 0));
            } else {
                textQuantity.addTextChangedListener(new QuantityListener(textQuantity));
            }
            Helper.stylize(textQuantity);
            textQuantity.setFocusable(false);
            textQuantity.setFocusableInTouchMode(false);

            btnQtyPlus = (ImageButton) view.findViewById(R.id.btn_qty_plus);
            Helper.stylizeVector(btnQtyPlus);


            btnQtyMinus = (ImageButton) view.findViewById(R.id.btn_qty_minus);
            Helper.stylizeVector(btnQtyMinus);

            quantitySection = view.findViewById(R.id.quantity_section);

            progressBar = (CircleProgressBar) view.findViewById(R.id.progressbar);
            progressBar.setVisibility(View.GONE);
            Helper.stylize(progressBar);

            btnAddToCart = (Button) view.findViewById(R.id.btn_add_to_cart);
            Helper.styleRoundFlat(btnAddToCart);

            if (ID_LAYOUT_PRODUCTS == 4) {
                view.findViewById(R.id.extra_section).setVisibility(View.GONE);
            }

            chk_wishlist = (CompoundButton) view.findViewById(R.id.chk_wishlist);
            if (AppInfo.ENABLE_WISHLIST) {
                if (chk_wishlist instanceof ToggleButton) {
                    Helper.setStyleWithDrawables(chk_wishlist, R.drawable.ic_vc_wish_border, R.drawable.ic_vc_wish_selected, android.R.color.white);
                    ToggleButton toggleButton = (ToggleButton) chk_wishlist;
                    toggleButton.setTextOn(getString(L.string.toggle_wishlist_on));
                    toggleButton.setTextOff(getString(L.string.toggle_wishlist_off));
                    Helper.stylize(toggleButton);
                } else {
                    Helper.setStyleWithDrawables(chk_wishlist, R.drawable.ic_vc_wish_border, R.drawable.ic_vc_wish_selected);
                }
                chk_wishlist.setVisibility(View.VISIBLE);
            } else {
                chk_wishlist.setVisibility(View.GONE);
            }
        }

        @Override
        void bindData(Object object) {
            this.bindView(object);
            TM_ProductInfo product = products.get(position);
            if (AppInfo.ENABLE_WISHLIST) {
                chk_wishlist.setVisibility(View.VISIBLE);
                chk_wishlist.setOnCheckedChangeListener(null);
                chk_wishlist.setChecked(Wishlist.hasItem(product));
                chk_wishlist.setOnCheckedChangeListener(new OnWishChkClickListener(position));
            }

            if (AppInfo.ENABLE_SINGLE_CHECK_WISHLIST) {
                chk_wishlist.setVisibility(View.GONE);
            }

            btnAddToCart.setOnClickListener(this);
            btnAddToCart.setText(getString(L.string.add_to_cart));

            btnQtyMinus.setOnClickListener(new ValueObserver(textQuantity, ValueObserver.Type.DECREASE, new ValueObserver.OnChangeCallback() {
                @Override
                public void onChange(int value) {
                    addOrUpdateCart(value);
                }
            }, 0, 999));

            if (ID_LAYOUT_PRODUCTS == 4) {
                textQuantity.setText("0");
                btnQtyPlus.setOnClickListener(new ValueObserver(textQuantity, ValueObserver.Type.INCREASE, new ValueObserver.OnChangeCallback() {
                    @Override
                    public void onChange(int value) {
                        addOrUpdateCart(value);
                    }
                }, 0, 9999));
            } else if (ID_LAYOUT_PRODUCTS == 5) {
                textQuantity.setText("0");
                btnQtyPlus.setOnClickListener(this);
            } else {
                btnQtyPlus.setOnClickListener(new ValueObserver(textQuantity, ValueObserver.Type.INCREASE, new ValueObserver.OnChangeCallback() {
                    @Override
                    public void onChange(int value) {
                        addOrUpdateCart(value);
                    }
                }, product.getQuantityRules()));

                if (AppInfo.mProductDetailsConfig.show_quantity_rules) {
                    btnQtyMinus.setOnClickListener(new ValueObserver(textQuantity, ValueObserver.Type.DECREASE, new ValueObserver.OnChangeCallback() {
                        @Override
                        public void onChange(int value) {
                            addOrUpdateCart(value);
                        }
                    }, product.getQuantityRules()));
                }
            }

            if (AppInfo.ENABLE_CART && GuestUserConfig.isEnableCart()) {
                Cart cart = Cart.findCart(product.id);
                if (cart != null) {
                    if (product.full_data_loaded) {
                        if (product.hasVariations()) {
                            btnAddToCart.setVisibility(View.VISIBLE);
                            quantitySection.setVisibility(View.GONE);
                        } else {
                            btnAddToCart.setVisibility(View.GONE);
                            quantitySection.setVisibility(View.VISIBLE);
                            textQuantity.setText(String.valueOf(cart.count));
                        }
                    } else {
                        if (product.type == TM_ProductInfo.ProductType.VARIABLE) {
                            btnAddToCart.setVisibility(View.VISIBLE);
                            quantitySection.setVisibility(View.GONE);
                        } else {
                            btnAddToCart.setVisibility(View.GONE);
                            quantitySection.setVisibility(View.VISIBLE);
                        }
                        if (ID_LAYOUT_PRODUCTS != 4) {
                            textQuantity.setText(String.valueOf(cart.count));
                        }
                    }
                } else {
                    if (progressBar.getVisibility() == View.GONE) {
                        btnAddToCart.setVisibility(View.VISIBLE);
                        quantitySection.setVisibility(View.GONE);
                        if (ID_LAYOUT_PRODUCTS != 4) {
                            textQuantity.setText("1");
                        }
                    }
                }
            } else {
                btnAddToCart.setVisibility(View.GONE);
                quantitySection.setVisibility(View.GONE);
            }
//TODO check this for Booking product
//            if (AppInfo.SHOW_PRODUCTS_BOOKING_INFO && product.type == TM_ProductInfo.ProductType.BOOKING /*|| Cart.containsBookingProduct()*/) {
//                btnAddToCart.setVisibility(View.GONE);
//                quantitySection.setVisibility(View.GONE);
//            }
        }

        private void addOrUpdateCart(final int value) {
            final TM_ProductInfo product = products.get(position);
            if (product != null && product.full_data_loaded) {
                addOrUpdateCart(product, value);
            } else {

                progressBar.setVisibility(((quantitySection.getVisibility() == View.VISIBLE) ? View.GONE : View.VISIBLE));
                DataEngine.getDataEngine().getProductInfoInBackground(product.id, new DataQueryHandler<TM_ProductInfo>() {
                            @Override
                            public void onSuccess(TM_ProductInfo data) {
                                progressBar.setVisibility(((progressBar.getVisibility() == View.VISIBLE) ? View.GONE : View.VISIBLE));
                                addOrUpdateCart(data, value);
                            }

                            @Override
                            public void onFailure(Exception e) {
                                progressBar.setVisibility(((progressBar.getVisibility() == View.VISIBLE) ? View.GONE : View.VISIBLE));
                                e.printStackTrace();
                            }
                        }
                );
            }
        }

        private void addOrUpdateCart(TM_ProductInfo product, int value) {
            if (value > 0) {
                Cart cart = Cart.findCart(product.id);
                if (cart != null && product.hasVariations()) {
                    Cart.addProduct(product, cart.selected_variation_id, cart.selected_variation_index, value, cart.attributes);
                } else {
                    if (product.managing_stock) {
                        if (!product.backorders_allowed && !product.in_stock) {
                            Helper.toast(cordView, L.string.product_out_of_stock);
                            return;
                        }
                    } else if (!product.in_stock) {
                        Helper.toast(cordView, L.string.product_out_of_stock);
                        return;
                    }

                    Cart.addProduct(product, value);
                }
                //Helper.toast(cordView, L.string.item_added_to_cart);
                progressBar.setVisibility(View.GONE);
                btnAddToCart.setVisibility(View.GONE);
                quantitySection.setVisibility(View.VISIBLE);
            } else {
                Cart.removeProduct(product);
                progressBar.setVisibility(View.GONE);
                btnAddToCart.setVisibility(View.VISIBLE);
                quantitySection.setVisibility(View.GONE);
                textQuantity.setText(String.valueOf(1));
                //Helper.toast(cordView, L.string.item_removed_from_cart);
            }
            MainActivity.mActivity.reloadMenu();
        }

        @Override
        public void onClick(View v) {

            final TM_ProductInfo product = products.get(position);

            if (product.managing_stock) {
                if (!product.backorders_allowed && !product.in_stock) {
                    Helper.toast(cordView, L.string.product_out_of_stock);
                    btnAddToCart.setText(getString(L.string.out_of_stock));
                    btnAddToCart.setVisibility(View.VISIBLE);
                    quantitySection.setVisibility(View.GONE);
                    return;
                } else {
                    btnAddToCart.setVisibility(View.GONE);
                }
            } else {
                if (!product.in_stock) {
                    Helper.toast(cordView, L.string.product_out_of_stock);
                    btnAddToCart.setText(getString(L.string.out_of_stock));
                    btnAddToCart.setVisibility(View.VISIBLE);
                    quantitySection.setVisibility(View.GONE);
                    return;
                } else {
                    btnAddToCart.setVisibility(View.GONE);
                }
            }

            if (!AppInfo.ENABLE_ZERO_PRICE_ORDER) {
                if (product.getActualPrice() <= 0) {
                    Helper.toast(cordView, L.string.product_not_for_sale);
                    return;
                }
            } else {
                btnAddToCart.setVisibility(View.VISIBLE);
            }

            if (!product.full_data_loaded) {
                progressBar.setVisibility(View.VISIBLE);
                btnAddToCart.setVisibility(View.GONE);
                DataEngine.getDataEngine().getProductInfoInBackground(product.id, new DataQueryHandler() {
                            @Override
                            public void onSuccess(Object data) {
                                progressBar.setVisibility(View.GONE);
                                if (product.hasVariations()) {
                                    btnAddToCart.setVisibility(View.VISIBLE);
                                    MainActivity.mActivity.showProductInfoDialog(product.id);
                                } else {

                                    if (product.managing_stock) {
                                        if (!product.backorders_allowed && !product.in_stock) {
                                            Helper.toast(cordView, L.string.product_out_of_stock);
                                            return;
                                        }
                                    } else if (!product.in_stock) {
                                        //if (!product.in_stock && !product.back_order_allowed) {
                                        Helper.toast(cordView, L.string.product_out_of_stock);
                                        return;
                                    }

                                    Cart.addProduct(product, 1);
                                    btnAddToCart.setVisibility(View.GONE);
                                    quantitySection.setVisibility(View.VISIBLE);
                                    if (AppInfo.mProductDetailsConfig.show_quantity_rules) {
                                        QuantityListener mQuantityListener = new QuantityListener(textQuantity, new QuantityListener.OnChangeCallback() {
                                            @Override
                                            public void onChange(int value) {
                                                addOrUpdateCart(value);
                                            }
                                        }, product.getQuantityRules());
//TODO check for Booking product
//                                        textQuantity.removeTextChangedListener(mQuantityListener);
//                                        textQuantity.addTextChangedListener(mQuantityListener);
                                    }
                                    // Helper.toast(cordView, L.string.item_added_to_cart);
                                }
                                MainActivity.mActivity.reloadMenu();
                            }

                            @Override
                            public void onFailure(Exception e) {
                                quantitySection.setVisibility(View.GONE);
                                progressBar.setVisibility(View.GONE);
                                btnAddToCart.setVisibility(View.VISIBLE);
                                e.printStackTrace();
                            }
                        }
                );
            } else {
                progressBar.setVisibility(View.GONE);
                if (product.hasVariations()) {
                    btnAddToCart.setVisibility(View.VISIBLE);
                    quantitySection.setVisibility(View.GONE);
                    MainActivity.mActivity.showProductInfoDialog(product.id);
                } else {
                    Cart cart = Cart.findCart(product.id);
                    if (cart != null) {
                        btnAddToCart.setVisibility(View.GONE);
                        quantitySection.setVisibility(View.VISIBLE);
                        Cart.addProduct(product, 1);
                    } else {
                        if (product.managing_stock) {
                            if (!product.backorders_allowed && !product.in_stock) {
                                Helper.toast(cordView, L.string.product_out_of_stock);
                                return;
                            }
                        } else if (!product.in_stock) {
                            Helper.toast(cordView, L.string.product_out_of_stock);
                            return;
                        }

                        btnAddToCart.setVisibility(View.GONE);
                        quantitySection.setVisibility(View.VISIBLE);

                        if (AppInfo.mProductDetailsConfig.show_quantity_rules) {
                            QuantityListener mQuantityListener = new QuantityListener(textQuantity, new QuantityListener.OnChangeCallback() {
                                @Override
                                public void onChange(int value) {
                                    addOrUpdateCart(value);
                                }
                            }, product.getQuantityRules());
////TODO check for Booking product
//                            textQuantity.removeTextChangedListener(mQuantityListener);
//                            textQuantity.addTextChangedListener(mQuantityListener);
                        }
                        Cart.addProduct(product, 1);
                    }
                    // Helper.toast(cordView, L.string.item_added_to_cart);
                }
                MainActivity.mActivity.reloadMenu();
            }
        }
    }

    public void setCheckMode(boolean value) {
        checkMode = AppInfo.ENABLE_SINGLE_CHECK_WISHLIST || value;
        notifyDataSetChanged();
    }

    public void resetAdapterForCheckBox() {
        for (TM_ProductInfo product : TM_ProductInfo.getAll()) {
            if (product.isChecked)
                product.isChecked = false;
        }
        checkMode = false;
        mCheckedItem.clear();
        notifyDataSetChanged();
    }

    public boolean isCheckedMode() {
        return checkMode;
    }

    public HashMap<Integer, Boolean> getCheckedItems() {
        return mCheckedItem;
    }

    public Adapter_Products(BaseActivity activity, List<TM_ProductInfo> products, View.OnLongClickListener longClickListener, View.OnClickListener checkBoxChangeListener) {
        this.activity = activity;
        this.longClickListener = longClickListener;
        this.checkBoxChangeListener = checkBoxChangeListener;

        mCheckedItem.clear();

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
        original_data = this.products;
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

    public int getFullyLoadedItemCount() {
        int count = 0;
        for (TM_ProductInfo product : products) {
            if (product.full_data_loaded)
                count++;
        }
        return count;
    }

    @Override
    public AbstractViewHolder onCreateViewHolder(ViewGroup viewGroup, int type) {
        LayoutInflater inflater = LayoutInflater.from(viewGroup.getContext());
        switch (type) {
            case TYPE_EMPTY: {
                ViewGroup.LayoutParams layoutParams;
                if (ID_LAYOUT_PRODUCTS == 3) {
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
                if (ID_LAYOUT_PRODUCTS == 3) {
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
                View view = inflater.inflate(getProductLayoutId(true), viewGroup, false);
                return AppInfo.SHOW_CART_WITH_PRODUCT ?
                        new ProductViewHolder2(view) :
                        new ProductViewHolder1(view);
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
    public void onAttachedToRecyclerView(RecyclerView recyclerView) {
        super.onAttachedToRecyclerView(recyclerView);
        cordView = recyclerView;
    }

    private class OnWishChkClickListener implements CompoundButton.OnCheckedChangeListener {
        private int mPosition;

        OnWishChkClickListener(int position) {
            mPosition = position;
        }

        @Override
        public void onCheckedChanged(final CompoundButton chk_wishlist, boolean isChecked) {
            try {
                final TM_ProductInfo product = products.get(mPosition);
                if (isChecked) {
                    if (!AppInfo.ENABLE_MULTIPLE_WISHLIST) {
                        if (!Wishlist.addProduct(product, null)) {
                            chk_wishlist.setOnCheckedChangeListener(null);
                            chk_wishlist.setChecked(false);
                            chk_wishlist.setOnCheckedChangeListener(OnWishChkClickListener.this);
                        }
                        MainActivity.mActivity.reloadMenu();
                        return;
                    }

                    Fragment_Wishlist_Dialog.OpenWishGroupDialog(product, new WishListDialogHandler() {
                        @Override
                        public void onSelectGroupSuccess(final TM_ProductInfo product, final WishListGroup obj) {
                            MainActivity.mActivity.showProgress(getString(L.string.please_wait), false);
                            WishListGroup.addProductToWishList(obj.id, product.id, new DataQueryHandler() {
                                @Override
                                public void onSuccess(Object data) {
                                    MainActivity.mActivity.hideProgress();
                                    if (Wishlist.addProduct(product, obj)) {
                                        Helper.toast(cordView, getString(L.string.item_added_to_wishlist) + ": " + obj.title);
                                    } else {
                                        chk_wishlist.setOnCheckedChangeListener(null);
                                        chk_wishlist.setChecked(false);
                                        chk_wishlist.setOnCheckedChangeListener(OnWishChkClickListener.this);
                                    }
                                    MainActivity.mActivity.reloadMenu();
                                }

                                @Override
                                public void onFailure(Exception error) {
                                    Helper.toast(getString(L.string.generic_server_timeout));
                                    MainActivity.mActivity.hideProgress();
                                }
                            });
                        }

                        @Override
                        public void onSelectGroupFailed(String cause) {
                            chk_wishlist.setOnCheckedChangeListener(null);
                            chk_wishlist.setChecked(false);
                            chk_wishlist.setOnCheckedChangeListener(OnWishChkClickListener.this);
                            MainActivity.mActivity.reloadMenu();
                        }

                        @Override
                        public void onSkipDialog(TM_ProductInfo product, WishListGroup obj) {
                            if (!WishListGroup.hasChild(obj.id, product) && Wishlist.addProduct(product, obj)) {
                                Helper.toast(cordView, Helper.showItemAddedToWishListToast(obj));
                            } else {
                                chk_wishlist.setOnCheckedChangeListener(null);
                                chk_wishlist.setChecked(false);
                                chk_wishlist.setOnCheckedChangeListener(OnWishChkClickListener.this);
                            }
                            MainActivity.mActivity.reloadMenu();
                        }
                    });
                } else {
                    Wishlist.removeProduct(product);
                    MainActivity.mActivity.reloadMenu();
                }
            } catch (Exception e) {
                e.printStackTrace();
                MainActivity.mActivity.hideProgress();
            }
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

    public void addItemsToList(List<TM_ProductInfo> newProducts) {
        if (newProducts != null) {
            if (TM_CommonInfo.hide_out_of_stock) {
                for (TM_ProductInfo product : newProducts) {
                    if (product.in_stock)
                        this.products.add(product);
                }
            } else {
                products.addAll(newProducts);
            }
            reSortProducts();
        }
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

    private Filter filter = null;

    public Filter getFilter() {
        if (filter == null) {
            filter = new Filter() {
                final List<TM_ProductInfo> original = products;

                @Override
                protected FilterResults performFiltering(CharSequence constraint) {
                    Log.d("-- filter constraint: [" + constraint.toString() + "] --");
                    final FilterResults oReturn = new FilterResults();
                    final ArrayList<TM_ProductInfo> results = new ArrayList<>();
                    try {
                        Gson gson = new Gson();
                        UserFilter userFilter = gson.fromJson(constraint.toString(), UserFilter.class);
                        if (userFilter != null) {
                            if (original != null && original.size() > 0) {
                                for (final TM_ProductInfo product : original) {
                                    boolean conditionPriceMin = (product.getActualPrice() >= userFilter.getMinPrice());
                                    boolean conditionPriceMax = (product.getActualPrice() <= userFilter.getMaxPrice());
                                    boolean conditionStock = (!userFilter.chkStock || product.in_stock);
                                    boolean conditionAttribute = true;
                                    for (TM_FilterAttribute userAttribute : userFilter.getAttributes()) {
                                        if (userAttribute.options.isEmpty()) {
                                            continue;
                                        }
                                        TM_Attribute productAttribute = product.getAttributeWithName(userAttribute.attribute);
                                        if (!userAttribute.isSubsetOf(productAttribute)) {
                                            conditionAttribute = false;
                                        }
                                    }

                                    if (conditionPriceMin && conditionPriceMax && conditionStock && conditionAttribute) {
                                        results.add(product);
                                    }
                                }
                            }
                            Collections.sort(results, new FilterSortByComparator(FilterSortType.values()[userFilter.getSortOrder()]));
                            oReturn.values = results;
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    return oReturn;
                }

                @SuppressWarnings("unchecked")
                @Override
                protected void publishResults(CharSequence constraint, FilterResults results) {
                    products = (ArrayList<TM_ProductInfo>) results.values;
                    notifyDataSetChanged();
                }
            };
        }
        return filter;
    }

    private Filter textFilter = null;

    public Filter getTextFilter() {
        if (textFilter == null) {
            textFilter = new Filter() {
                @Override
                protected FilterResults performFiltering(CharSequence constraint) {
                    final FilterResults oReturn = new FilterResults();
                    final List<TM_ProductInfo> results = new ArrayList<>();
                    if (constraint != null) {
                        if (original_data != null && original_data.size() > 0) {
                            final String[] keyWords = constraint.toString().split(" ");
                            for (final TM_ProductInfo product : original_data) {
                                if (TM_CommonInfo.hide_out_of_stock && !product.in_stock) {
                                    Log.d("-- out of stock product omitted --");
                                    continue;
                                }
                                if (product.hasKeyWords(keyWords)) {
                                    results.add(product);
                                }
                            }
                        }
                        oReturn.values = results;
                    }
                    return oReturn;
                }

                @SuppressWarnings("unchecked")
                @Override
                protected void publishResults(CharSequence constraint, FilterResults results) {
                    products = (List<TM_ProductInfo>) results.values;
                    notifyDataSetChanged();
                }
            };
        }
        return textFilter;
    }

    public void clearFilter() {
        products = original_data;
    }

    public void clearResults() {
        products.clear();
        original_data = products;
    }

    public void updateResult(List<TM_ProductInfo> newData) {
        updateResult(newData, null);
    }


    private UserFilter userFilter;

    public void updateResult(List<TM_ProductInfo> newData, UserFilter currentFilter) {
        products.clear();
        if (TM_CommonInfo.hide_out_of_stock) {
            if (products == null) {
                products = new ArrayList<>();
            }
            for (TM_ProductInfo product : newData) {
                if (!hasProduct(product)) {
                    if (!(DataEngine.hide_blocked_items && product.isBlocked())) {
                        if (product.in_stock) {
                            setProductFilterLocationDistance(product, currentFilter);
                            if (!ListUtils.isEmpty(AppInfo.restrictedCategories)) {
                                if (!product.containedInCategories(AppInfo.restrictedCategories)) {
                                    products.add(product);
                                }
                            } else {
                                products.add(product);
                            }
                        }
                    }
                }
            }
        } else {
            for (TM_ProductInfo product : newData) {
                if (!hasProduct(product)) {
                    if (!(DataEngine.hide_blocked_items && product.isBlocked())) {
                        setProductFilterLocationDistance(product, currentFilter);
                        if (!ListUtils.isEmpty(AppInfo.restrictedCategories)) {
                            if (!product.containedInCategories(AppInfo.restrictedCategories)) {
                                products.add(product);
                            }
                        } else {
                            products.add(product);
                        }
                    }
                }
            }
        }

        reSortProducts();
        original_data = products;
        resetAdapterForCheckBox();
        notifyDataSetChanged();
    }

    private void setProductFilterLocationDistance(TM_ProductInfo product, UserFilter userFilter) {
        if (AppInfo.ENABLE_LOCATION_IN_FILTERS && userFilter != null) {
            UserFilter.GeoLocation geoLocation = userFilter.getGeoLocation();
            if (geoLocation != null && product.sellerInfo != null) {
                this.userFilter = userFilter;
                if (!TextUtils.isEmpty(geoLocation.latitude) && !TextUtils.isEmpty(geoLocation.longitude) && product.sellerInfo.getLatitude() != 0 && product.sellerInfo.getLongitude() != 0) {
                    double filterLatitude = Double.parseDouble(geoLocation.latitude);
                    double filterLongitude = Double.parseDouble(geoLocation.longitude);

                    Location startPointVendorLocation = new Location("");
                    startPointVendorLocation.setLatitude(product.sellerInfo.getLatitude());
                    startPointVendorLocation.setLongitude(product.sellerInfo.getLongitude());

                    Location endPointFilterLocation = new Location("");
                    endPointFilterLocation.setLatitude(filterLatitude);
                    endPointFilterLocation.setLongitude(filterLongitude);

                    double distance = startPointVendorLocation.distanceTo(endPointFilterLocation) / 1000;
                    product.distance = new DecimalFormat("##.##").format(distance);
                }
            }
        } else {
            this.userFilter = null;
        }
    }

    public void addProduct(TM_ProductInfo newProduct) {
        if (TM_CommonInfo.hide_out_of_stock && !newProduct.in_stock) {
            return;
        }
        this.products.add(newProduct);
        reSortProducts();
        notifyDataSetChanged();
    }

    public boolean addProducts(List<TM_ProductInfo> newProducts) {
        int oldSize = this.products.size();
        boolean isAnyNewProductAdded = false;
        for (TM_ProductInfo newProduct : newProducts) {
            if (TM_CommonInfo.hide_out_of_stock && !newProduct.in_stock) {
                continue;
            }
            if (!this.hasProduct(newProduct)) {
                this.products.add(newProduct);
                isAnyNewProductAdded = true;
            }
        }
        int range = this.products.size() - oldSize;
        if (range > 0) {
            reSortProducts();
            Log.d("-- range inserted from [" + oldSize + "] count [" + range + "] --");
            notifyItemRangeInserted(oldSize + headers.size(), range);
        }
        return isAnyNewProductAdded;
    }

    private void reSortProducts() {
        if (sort_type != -1) {
            Collections.sort(products, new FilterSortByComparator(FilterSortType.values()[this.sort_type]));
        }
    }

    public void setSortOrder(int sort_type) {
        this.sort_type = sort_type;
    }

    private int sort_type = -1;

    private boolean hasProduct(TM_ProductInfo newProduct) {
        for (TM_ProductInfo product : products) {
            if (newProduct.id == product.id)
                return true;
        }
        return false;
    }

    public static int getProductLayoutId(boolean showButtons) {
        boolean show_cart = AppInfo.SHOW_CART_WITH_PRODUCT && showButtons;
        switch (ID_LAYOUT_PRODUCTS) {
            case 1:
                return show_cart ? R.layout.item_product_tile_5 : R.layout.item_product_tile_1;
            case 2:
                return show_cart ? R.layout.item_product_tile_6 : R.layout.item_product_tile_2;
            case 3:
                return show_cart ? R.layout.item_product_tile_7 : R.layout.item_product_tile_3;
            case 4:
                return show_cart ? R.layout.item_product_tile_8 : R.layout.item_product_tile_9;
            case 5:
                return show_cart ? R.layout.item_product_tile_10 : R.layout.item_product_tile_10;
            default:
                return show_cart ? R.layout.item_product_tile_4 : R.layout.item_product_tile_0;
        }
    }

    public static int getProductLayoutColumnCount() {
        switch (ID_LAYOUT_PRODUCTS) {
            case 1:
            case 2:
            case 4:
            case 5:
                return 1;
        }
        return 2;
    }
}