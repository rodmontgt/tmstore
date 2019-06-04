package com.twist.tmstore.adapters;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Paint;
import android.support.v7.widget.CardView;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.config.GuestUserConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.Cart;
import com.twist.tmstore.entities.Wishlist;
import com.twist.tmstore.listeners.OnWishListChangeListener;
import com.twist.tmstore.listeners.QuantityListener;
import com.twist.tmstore.listeners.ValueObserver;
import com.utils.CContext;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.Log;
import com.utils.customviews.progressbar.CircleProgressBar;

import java.util.HashMap;
import java.util.List;

import static com.twist.tmstore.L.getString;


public class Adapter_TrendingItems extends RecyclerView.Adapter<Adapter_TrendingItems.BaseProductViewHolder> {

    private List<TM_ProductInfo> products;

    private Context context;

    private View cordView;
    public static HashMap<Integer, Boolean> mCheckedItem = new HashMap<>();
    public boolean checkMode = false;
    private View.OnClickListener checkBoxChangeListener;


    abstract class BaseProductViewHolder extends RecyclerView.ViewHolder {
        TextView name;
        TextView regular_price;
        TextView sale_price;
        TextView txt_discount;
        ImageView img;

        LinearLayout out_of_stock_section;
        TextView text_out_of_stock;
        TextView text_saletag;
        TextView text_newtag;

        CardView cv;
        LinearLayout price_section;

        public BaseProductViewHolder(View vi) {
            super(vi);
            name = (TextView) vi.findViewById(R.id.name);
            cv = (CardView) vi.findViewById(R.id.cv);
            img = (ImageView) vi.findViewById(R.id.img);
            price_section = (LinearLayout) vi.findViewById(R.id.price_section);
            regular_price = (TextView) vi.findViewById(R.id.regular_price);
            txt_discount = (TextView) vi.findViewById(R.id.txt_discount);
            txt_discount.setVisibility(View.GONE);
            sale_price = (TextView) vi.findViewById(R.id.sale_price);
            Helper.stylizeSalePriceText(sale_price);
            Helper.stylizeRegularPriceText(regular_price);
            Helper.stylizeActionText(txt_discount);
            img.setScaleType(ImageView.ScaleType.CENTER_CROP);

            out_of_stock_section = (LinearLayout) itemView.findViewById(R.id.out_of_stock_section);
            out_of_stock_section.setBackground(CContext.getDrawable(context, R.drawable.border_layout_transperent));
            text_out_of_stock = (TextView) itemView.findViewById(R.id.text_out_of_stock);
            text_out_of_stock.setBackground(CContext.getDrawable(context, R.drawable.border_layout_white));
            text_out_of_stock.setText(getString(L.string.out_of_stock_tag));
            text_out_of_stock.setTextColor(Color.parseColor(AppInfo.color_actionbar_text));
            out_of_stock_section.setVisibility(View.GONE);

            text_saletag = (TextView) itemView.findViewById(R.id.text_saletag);
            Helper.stylizeActionText(text_saletag);
            text_saletag.setText(getString(L.string.sale_tag));
            text_saletag.setVisibility(View.GONE);

            text_newtag = (TextView) itemView.findViewById(R.id.text_newtag);
            Helper.stylizeActionText(text_newtag);
            text_newtag.setText(getString(L.string.new_tag));
            text_newtag.setVisibility(View.GONE);
        }

        final void bindData(int position) {
            TM_ProductInfo product = products.get(position);
            bindData(product);
        }

        void bindData(final TM_ProductInfo product) {

            cv.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    MainActivity.mActivity.openProductInfo(product);
                }
            });

            checkMode = AppInfo.ENABLE_SINGLE_CHECK_WISHLIST || checkMode;
            if (product == null)
                return;
            name.setText(HtmlCompat.fromHtml(product.title));

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

            if (AppInfo.SHOW_SALE_PRODUCT_TAG && sale_price.getVisibility() == View.VISIBLE) {
                regular_price.setPaintFlags(regular_price.getPaintFlags() | Paint.STRIKE_THRU_TEXT_FLAG);
                this.text_saletag.setVisibility(View.VISIBLE);
            } else {
                this.text_saletag.setVisibility(View.GONE);
            }

            if (AppInfo.SHOW_NEW_PRODUCT_TAG && Helper.getDaysDifference(product.created_at) < AppInfo.NEW_PRODUCT_DAYS_LIMIT) {
                this.text_saletag.setVisibility(View.GONE);
                this.text_newtag.setVisibility(View.VISIBLE);
            } else {
                this.text_newtag.setVisibility(View.GONE);
            }

            if (AppInfo.SHOW_OUTOFSTOCK_PRODUCT_TAG && !product.in_stock) {
                this.out_of_stock_section.setVisibility(View.VISIBLE);
                this.text_saletag.setVisibility(View.GONE);
                this.text_newtag.setVisibility(View.GONE);
            } else {
                this.out_of_stock_section.setVisibility(View.GONE);
            }

            if (AppInfo.HIDE_PRODUCT_PRICE_TAG || GuestUserConfig.hidePriceTag()) {
                this.regular_price.setVisibility(View.GONE);
                this.txt_discount.setVisibility(View.GONE);
                this.sale_price.setVisibility(View.GONE);
            }

            Glide.with(context)
                    .load(product.thumb)
                    .placeholder(Helper.getPlaceholderColor())
                    .error(R.drawable.error_product)
                    .fitCenter()
                    .into(img);
        }
    }

    private class ProductViewHolder1 extends BaseProductViewHolder {
        CheckBox chk_wishlist;
        CheckBox chk_actions;

        ProductViewHolder1(View view) {
            super(view);
            chk_wishlist = (CheckBox) view.findViewById(R.id.chk_wishlist);
            chk_actions = (CheckBox) view.findViewById(R.id.chk_actions);
            chk_actions.setVisibility(View.GONE);
            Helper.stylize(chk_actions);
            chk_wishlist.setVisibility(AppInfo.ENABLE_WISHLIST ? View.VISIBLE : View.GONE);
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

            if (AppInfo.ENABLE_MULTIPLE_WISHLIST || AppInfo.mImageDownloaderConfig != null && AppInfo.mImageDownloaderConfig.isShowInHome()) {
                chk_wishlist.setVisibility(View.GONE);
                chk_actions.setVisibility(View.VISIBLE);
                chk_actions.setOnCheckedChangeListener(null);
                chk_actions.setChecked(product.isChecked);
                chk_actions.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
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
            }

            if (checkMode) {
                chk_actions.setVisibility(View.VISIBLE);
            } else {
                chk_actions.setVisibility(View.GONE);
                chk_actions.setOnCheckedChangeListener(null);
                chk_actions.setChecked(false);
                product.isChecked = false;
            }
        }
    }

    private class ProductViewHolder2 extends BaseProductViewHolder {
        View quantitySection;
        ImageButton btnQtyPlus;
        ImageButton btnQtyMinus;
        Button btnAddToCart;
        EditText textQuantity;
        CheckBox chk_actions;
        CheckBox chk_wishlist;
        CircleProgressBar progressBar;

        ProductViewHolder2(View view) {
            super(view);

            textQuantity = (EditText) view.findViewById(R.id.quantity);
            textQuantity.addTextChangedListener(new QuantityListener(textQuantity));
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
            btnAddToCart.setText(getString(L.string.add_to_cart));
            Helper.styleRoundFlat(btnAddToCart);

            chk_actions = (CheckBox) view.findViewById(R.id.chk_actions);
            chk_actions.setVisibility(View.GONE);
            Helper.stylize(chk_actions);

            chk_wishlist = (CheckBox) view.findViewById(R.id.chk_wishlist);
            chk_wishlist.setVisibility(AppInfo.ENABLE_WISHLIST ? View.VISIBLE : View.GONE);
            Helper.setStyleWithDrawables(chk_wishlist, R.drawable.ic_vc_wish_border, R.drawable.ic_vc_wish_selected);
        }

        @Override
        void bindData(final TM_ProductInfo product) {
            super.bindData(product);

            btnQtyPlus.setOnClickListener(new ValueObserver(textQuantity, ValueObserver.Type.INCREASE, new ValueObserver.OnChangeCallback() {
                @Override
                public void onChange(int value) {
                    addOrUpdateCart(product, value);
                }
            }));

            btnQtyMinus.setOnClickListener(new ValueObserver(textQuantity, ValueObserver.Type.DECREASE, new ValueObserver.OnChangeCallback() {
                @Override
                public void onChange(int value) {
                    addOrUpdateCart(product, value);
                }
            }, 0, 999));

            if (AppInfo.mProductDetailsConfig.show_quantity_rules) {
                btnQtyPlus.setOnClickListener(new ValueObserver(textQuantity, ValueObserver.Type.INCREASE, new ValueObserver.OnChangeCallback() {
                    @Override
                    public void onChange(int value) {
                        addOrUpdateCart(product, value);
                    }
                }, product.getQuantityRules()));

                btnQtyMinus.setOnClickListener(new ValueObserver(textQuantity, ValueObserver.Type.DECREASE, new ValueObserver.OnChangeCallback() {
                    @Override
                    public void onChange(int value) {
                        addOrUpdateCart(product, value);
                    }
                }, product.getQuantityRules()));
            }

            btnAddToCart.setOnClickListener(new QuickCartButtonClickListener(product));

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
                    textQuantity.setText(String.valueOf(cart.count));
                }
            } else {
                if (progressBar.getVisibility() == View.GONE) {
                    btnAddToCart.setVisibility(View.VISIBLE);
                    quantitySection.setVisibility(View.GONE);
                    textQuantity.setText("1");
                }
            }

            if (AppInfo.ENABLE_WISHLIST) {
                chk_wishlist.setVisibility(View.VISIBLE);
                chk_wishlist.setOnCheckedChangeListener(null);
                chk_wishlist.setChecked(Wishlist.hasItem(product));
                chk_wishlist.setOnCheckedChangeListener(new OnWishListChangeListener(product, cordView));
            }

            if (AppInfo.ENABLE_MULTIPLE_WISHLIST || (AppInfo.mImageDownloaderConfig != null && AppInfo.mImageDownloaderConfig.isShowInHome())) {
                chk_wishlist.setVisibility(View.GONE);
                chk_actions.setVisibility(View.VISIBLE);
                chk_actions.setOnCheckedChangeListener(null);
                chk_actions.setChecked(product.isChecked);
                chk_actions.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
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
            }

            if (checkMode) {
                chk_actions.setVisibility(View.VISIBLE);
            } else {
                chk_actions.setVisibility(View.GONE);
                chk_actions.setOnCheckedChangeListener(null);
                chk_actions.setChecked(false);
                product.isChecked = false;
            }

//            if (AppInfo.SHOW_PRODUCTS_BOOKING_INFO && product.type == TM_ProductInfo.ProductType.BOOKING /*|| Cart.containsBookingProduct()*/) {
//                btnAddToCart.setVisibility(View.GONE);
//                quantitySection.setVisibility(View.GONE);
//            }
        }

        private void addOrUpdateCart(TM_ProductInfo product, int value) {
            if (product != null && product.full_data_loaded) {
                if (value > 0) {
                    if (!AppInfo.ENABLE_ZERO_PRICE_ORDER) {
                        if (product.getActualPrice() <= 0) {
                            Helper.toast(cordView, L.string.product_not_for_sale);
                            return;
                        }
                    }

                    Cart cart = Cart.findCart(product.id);
                    if (cart != null && product.hasVariations()) {
                        Cart.addProduct(product, cart.selected_variation_id, cart.selected_variation_index, value, cart.attributes);
                    } else {
                        Cart.addProduct(product, value);
                    }
                    progressBar.setVisibility(View.GONE);
                    btnAddToCart.setVisibility(View.GONE);
                    quantitySection.setVisibility(View.VISIBLE);
                } else {
                    Cart.removeProduct(product);
                    progressBar.setVisibility(View.GONE);
                    btnAddToCart.setVisibility(View.VISIBLE);
                    quantitySection.setVisibility(View.GONE);
                    textQuantity.setText(String.valueOf(1));
                }
                MainActivity.mActivity.reloadMenu();
            } else {
                Log.d("Product full data is not yet loaded.");
            }
        }

        class QuickCartButtonClickListener implements View.OnClickListener {

            TM_ProductInfo product;

            QuickCartButtonClickListener(TM_ProductInfo product) {
                this.product = product;
            }

            @Override
            public void onClick(View v) {

                if (!AppInfo.ENABLE_ZERO_PRICE_ORDER) {
                    if (product.getActualPrice() <= 0) {
                        Helper.toast(cordView, L.string.product_not_for_sale);
                        return;
                    }
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
                                        Cart.addProduct(product, 1);
                                        btnAddToCart.setVisibility(View.GONE);
                                        quantitySection.setVisibility(View.VISIBLE);

                                        if (AppInfo.mProductDetailsConfig.show_quantity_rules) {
                                            QuantityListener mQuantityListener = new QuantityListener(textQuantity, new QuantityListener.OnChangeCallback() {
                                                @Override
                                                public void onChange(int value) {
                                                    addOrUpdateCart(product, value);
                                                }
                                            }, product.getQuantityRules());

//                                            textQuantity.removeTextChangedListener(mQuantityListener);
//                                            textQuantity.addTextChangedListener(mQuantityListener);
                                        }
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
                            if (AppInfo.mProductDetailsConfig.show_quantity_rules) {
                                QuantityListener mQuantityListener = new QuantityListener(textQuantity, new QuantityListener.OnChangeCallback() {
                                    @Override
                                    public void onChange(int value) {
                                        addOrUpdateCart(product, value);
                                    }
                                }, product.getQuantityRules());

//                                textQuantity.removeTextChangedListener(mQuantityListener);
//                                textQuantity.addTextChangedListener(mQuantityListener);
                            }
                            Cart.addProduct(product, 1);
                        } else {
                            btnAddToCart.setVisibility(View.GONE);
                            quantitySection.setVisibility(View.VISIBLE);
                            if (AppInfo.mProductDetailsConfig.show_quantity_rules) {
                                QuantityListener mQuantityListener = new QuantityListener(textQuantity, new QuantityListener.OnChangeCallback() {
                                    @Override
                                    public void onChange(int value) {
                                        addOrUpdateCart(product, value);
                                    }
                                }, product.getQuantityRules());

//                                textQuantity.removeTextChangedListener(mQuantityListener);
//                                textQuantity.addTextChangedListener(mQuantityListener);
                            }
                            Cart.addProduct(product, 1);
                        }
                    }
                    MainActivity.mActivity.reloadMenu();
                }
            }
        }
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

    public Adapter_TrendingItems(Context context, List<TM_ProductInfo> products, View.OnClickListener checkBoxChangeListener) {
        this.context = context;
        this.products = products;
        this.checkBoxChangeListener = checkBoxChangeListener;
        mCheckedItem.clear();
    }

    @Override
    public int getItemCount() {
        return products.size();
    }

    @Override
    public BaseProductViewHolder onCreateViewHolder(ViewGroup viewGroup, int type) {
        if (AppInfo.SHOW_CART_WITH_PRODUCT) {
            return new ProductViewHolder2(LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.item_trending_2, viewGroup, false));
        } else {
            return new ProductViewHolder1(LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.item_trending_1, viewGroup, false));
        }
    }

    @Override
    public void onBindViewHolder(BaseProductViewHolder viewHolder, final int position) {
        viewHolder.bindData(position);
    }

    @Override
    public void onAttachedToRecyclerView(RecyclerView recyclerView) {
        super.onAttachedToRecyclerView(recyclerView);
        cordView = recyclerView;
    }

    public void updateProducts(List<TM_ProductInfo> newProducts) {
        products.clear();
        products.addAll(newProducts);
        notifyDataSetChanged();
    }

    public void removeAll() {
        products.clear();
        notifyDataSetChanged();
    }

    public void setCheckMode(boolean value) {
        checkMode = AppInfo.ENABLE_SINGLE_CHECK_WISHLIST || value;
        notifyDataSetChanged();
    }
}