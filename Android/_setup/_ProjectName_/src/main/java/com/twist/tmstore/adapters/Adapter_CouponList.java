package com.twist.tmstore.adapters;

import android.content.Context;
import android.graphics.Color;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.twist.dataengine.entities.TM_CategoryInfo;
import com.twist.dataengine.entities.TM_Coupon;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.entities.Cart;
import com.utils.AnalyticsHelper;
import com.utils.CContext;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.Log;

import java.util.ArrayList;
import java.util.List;

import static com.twist.tmstore.L.getString;

/**
 * Created by Twist Mobile on 11/29/2016.
 */

public class Adapter_CouponList extends RecyclerView.Adapter<Adapter_CouponList.CouponsViewHolder> {

    private List<TM_Coupon> couponList;
    private TM_Coupon tm_coupon_data;
    private View coordLayout;

    private Adapter_Tiny_Products adapterCouponProducts;
    private Adapter_Tiny_ExcludeProduct adapterCouponExcludeProducts;

    public Adapter_CouponList(List<TM_Coupon> couponList, View coordLayout) {
        this.couponList = couponList;
        this.coordLayout = coordLayout;
    }

    public class CouponsViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        private TextView txt_CouponCode;
        private TextView text_coupons_apply_on, text_show_more;
        private TextView txt_AvailableDiscount, txt_ExpiryDate;
        private TextView txt_DiscountOn, txt_ExcludeDiscountOn, txt_FreeShipping;
        private TextView txt_AllCouponDescription;
        private Button btn_apply;
        private RecyclerView coupons_productitems_recyclerview;
        private RecyclerView coupons_exclude_product_items_recyclerview;
        private RecyclerView coupons_categoriesitems_recyclerview;
        private RecyclerView coupons_exclude_categoriesitems_recyclerview;
        private TextView txt_CategoriesDiscountOn, txt_ExcludeCategoriesDiscountOn;

        private LinearLayout layout_more_content, coupons_product_listLL, coupons_exclude_product_list, coupons_categories_list, coupons_exclude_categories_list;

        private final int whiteColor;

        private CouponsViewHolder(View view) {
            super(view);

            txt_CouponCode = (TextView) view.findViewById(R.id.all_coupon_code);
            layout_more_content = (LinearLayout) view.findViewById(R.id.layout_more_content);
            coupons_product_listLL = (LinearLayout) view.findViewById(R.id.coupons_product_list);
            coupons_exclude_product_list = (LinearLayout) view.findViewById(R.id.coupons_exclude_product_list);
            coupons_categories_list = (LinearLayout) view.findViewById(R.id.coupons_categories_list);
            coupons_exclude_categories_list = (LinearLayout) view.findViewById(R.id.coupons_exclude_categories_list);

            txt_AllCouponDescription = (TextView) view.findViewById(R.id.all_coupon_description);
            txt_AllCouponDescription.setVisibility(View.VISIBLE);

            txt_AvailableDiscount = (TextView) view.findViewById(R.id.available_discount_txt);
            txt_ExpiryDate = (TextView) view.findViewById(R.id.expiry_date_txt);
            txt_DiscountOn = (TextView) view.findViewById(R.id.discount_on_txt);
            txt_ExcludeDiscountOn = (TextView) view.findViewById(R.id.discount_exclude_txt);
            txt_FreeShipping = (TextView) view.findViewById(R.id.free_shipping_txt);

            txt_CategoriesDiscountOn = (TextView) view.findViewById(R.id.discount_on_categories_txt);
            txt_ExcludeCategoriesDiscountOn = (TextView) view.findViewById(R.id.discount_exclude_categories_txt);

            coupons_productitems_recyclerview = (RecyclerView) view.findViewById(R.id.coupons_productitems_recyclerview);
            coupons_exclude_product_items_recyclerview = (RecyclerView) view.findViewById(R.id.coupons_exclude_productitems_recyclerview);

            coupons_categoriesitems_recyclerview = (RecyclerView) view.findViewById(R.id.coupons_categoriesitems_recyclerview);
            coupons_categoriesitems_recyclerview.setVisibility(View.GONE);

            coupons_exclude_categoriesitems_recyclerview = (RecyclerView) view.findViewById(R.id.coupons_exclude_categoriesitems_recyclerview);
            coupons_exclude_categoriesitems_recyclerview.setVisibility(View.GONE);

            text_coupons_apply_on = (TextView) view.findViewById(R.id.text_coupons_apply_on);
            text_coupons_apply_on.setText(getString(L.string.cannot_apply_coupons));

            text_show_more = (TextView) view.findViewById(R.id.text_show_more);
            text_show_more.setText(getString(L.string.show_more));
            text_show_more.setTextColor(CContext.getColor(getContext(), R.color.normal_text_color));

            whiteColor = CContext.getColor(getContext(), android.R.color.white);

            btn_apply = (Button) view.findViewById(R.id.button_apply);
            btn_apply.setText(getString(L.string.apply));
            Helper.stylize(btn_apply, whiteColor, whiteColor, Color.parseColor(AppInfo.normal_button_color));
            view.setOnClickListener(this);
            btn_apply.setOnClickListener(this);
            text_show_more.setOnClickListener(this);
        }

        @Override
        public void onClick(View view) {
            if (view.getId() == R.id.button_apply) {
                AnalyticsHelper.registerClickApplyCouponEvent(txt_CouponCode.getText().toString());
                tm_coupon_data = TM_Coupon.getWithCode(txt_CouponCode.getText().toString());
                String msg = verifyCoupon(tm_coupon_data, Cart.getAllProductIds(), Cart.getAllVariationIds(), Cart.getAllCategoryIds(), AppUser.getEmail(), Cart.getTotalPaymentExcludingCoupons());
                if (!AppUser.hasSignedIn()) {
                    Helper.toast(L.string.you_need_to_login_first);
                    ((MainActivity) view.getContext()).onLoginClick(true);
                } else {
                    if (msg.equals("success")) {
                        String msg2 = Cart.addCoupon(tm_coupon_data);
                        if (msg2.equals("success")) {
                            MainActivity.mActivity.getFM().popBackStack();
                        } else {
                            Helper.showToast(coordLayout, String.valueOf(HtmlCompat.fromHtml(msg2)));
                        }
                    } else {
                        Helper.showToast(coordLayout, String.valueOf(HtmlCompat.fromHtml(msg)));
                    }
                }
            } else if (view.getId() == R.id.text_show_more) {
                if (text_show_more.getText().toString().equals(getString(L.string.show_more))) {
                    layout_more_content.setVisibility(View.VISIBLE);
                    txt_AllCouponDescription.setEllipsize(null);
                    txt_AllCouponDescription.setMaxLines(Integer.MAX_VALUE);
                    text_show_more.setText(getString(L.string.show_less, true));
                    Helper.stylize(btn_apply);
                    Helper.setDrawableRight(text_show_more, R.drawable.ic_vc_arrow_up, CContext.getColor(getContext(), R.color.normal_text_color));
                } else if (text_show_more.getText().toString().equals(getString(L.string.show_less))) {
                    layout_more_content.setVisibility(View.GONE);
                    text_show_more.setText(getString(L.string.show_more));
                    Helper.stylize(btn_apply, whiteColor , whiteColor, Color.parseColor(AppInfo.normal_button_color));
                    Helper.setDrawableRight(text_show_more, R.drawable.ic_vc_arrow_down, CContext.getColor(getContext(), R.color.normal_text_color));
                }
            }
        }

        final protected Context getContext() {
            return itemView.getContext();
        }
    }

    @Override
    public CouponsViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_coupons_listrow, parent, false);
        return new CouponsViewHolder(itemView);
    }

    @Override
    public void onBindViewHolder(CouponsViewHolder holder, int position) {
        Helper.setDrawableRight(holder.text_show_more, R.drawable.ic_vc_arrow_down, CContext.getColor(holder.getContext(), R.color.normal_text_color));

        holder.txt_CouponCode.setBackground(Helper.getTextViewDashedBorder());
        tm_coupon_data = couponList.get(position);
        holder.txt_CouponCode.setText(tm_coupon_data.code);

        String expiryDate = Helper.getDateByPattern(tm_coupon_data.expiry_date);// Set Expiry Date
        if (!TextUtils.isEmpty(expiryDate)) {
            holder.txt_ExpiryDate.setVisibility(View.VISIBLE);
            String finalDate = String.format(getString(L.string.expiry_date, true), expiryDate);
            holder.txt_ExpiryDate.setText(HtmlCompat.fromHtml(finalDate));
        } else {
            holder.txt_ExpiryDate.setVisibility(View.GONE);
        }

        getCouponDescription(tm_coupon_data.description, holder.txt_AllCouponDescription);
        discountOnProductCart(tm_coupon_data.type, holder.txt_AvailableDiscount, holder.txt_DiscountOn, holder.coupons_product_listLL);//Discount Type % or currency, + Discount Apply On Show Hide product list
        enableFreeShipping(tm_coupon_data.enable_free_shipping, holder.txt_FreeShipping);// free shopping available

        if (!tm_coupon_data.product_ids.isEmpty()) {
            holder.coupons_product_listLL.setVisibility(View.VISIBLE);
            holder.txt_DiscountOn.setVisibility(View.VISIBLE);
            holder.coupons_productitems_recyclerview.setVisibility(View.VISIBLE);
            holder.coupons_productitems_recyclerview.setLayoutManager(new LinearLayoutManager(holder.getContext(), LinearLayoutManager.HORIZONTAL, false));
            adapterCouponProducts = new Adapter_Tiny_Products(new ArrayList<TM_ProductInfo>());
            holder.coupons_productitems_recyclerview.setAdapter(adapterCouponProducts);

            boolean isAnyProductMissing = false;
            List<TM_ProductInfo> productsForThisCoupon = new ArrayList<>();

            for (int id : tm_coupon_data.product_ids) {
                TM_ProductInfo productInfo = TM_ProductInfo.findProductById(id);
                if (productInfo == null) {
                    isAnyProductMissing = true;
                    break;
                }
                productsForThisCoupon.add(productInfo);
            }

            if (isAnyProductMissing) {
                DataEngine.getDataEngine().getPollProductsInBackground(tm_coupon_data.product_ids, new DataQueryHandler<List<TM_ProductInfo>>() {
                    @Override
                    public void onSuccess(List<TM_ProductInfo> data) {
                        adapterCouponProducts.addAll(data);
                    }

                    @Override
                    public void onFailure(Exception exception) {
                        exception.printStackTrace();
                    }
                });

            } else {
                adapterCouponProducts.addAll(productsForThisCoupon);
            }
        } else {
            holder.coupons_product_listLL.setVisibility(View.GONE);
            holder.txt_DiscountOn.setVisibility(View.GONE);
        }

        if (!tm_coupon_data.exclude_product_ids.isEmpty() && tm_coupon_data.exclude_product_ids.size() > 0) {
            holder.coupons_exclude_product_list.setVisibility(View.VISIBLE);
            holder.txt_ExcludeDiscountOn.setText(HtmlCompat.fromHtml(String.format(getString(L.string.discount_not_apply_on, true), getString(L.string.product))));
            loadExcludeProduct(holder);
        } else {
            holder.coupons_exclude_product_list.setVisibility(View.GONE);
        }

        if (!tm_coupon_data.product_category_ids.isEmpty() && tm_coupon_data.product_category_ids.size() > 0) {
            holder.coupons_categories_list.setVisibility(View.VISIBLE);
            holder.txt_CategoriesDiscountOn.setText(HtmlCompat.fromHtml(String.format(getString(L.string.discount_apply_on, true), getString(L.string.category))));
            loadCategories(holder);
        } else {
            holder.coupons_categories_list.setVisibility(View.GONE);
        }


        if (!tm_coupon_data.exclude_product_category_ids.isEmpty() && tm_coupon_data.exclude_product_category_ids.size() > 0) {
            holder.coupons_exclude_categories_list.setVisibility(View.VISIBLE);
            holder.txt_ExcludeCategoriesDiscountOn.setText(HtmlCompat.fromHtml(String.format(getString(L.string.discount_not_apply_on, true), getString(L.string.category))));
            setExcludeCategories(holder);
        } else {
            holder.coupons_exclude_categories_list.setVisibility(View.GONE);
        }
    }

    @Override
    public int getItemCount() {
        return couponList.size();
    }

    public void addItems(List<TM_Coupon> couponsList) {
        couponList.addAll(couponsList);
        notifyDataSetChanged();
    }

    private void getCouponDescription(String description, TextView txt_AllCouponDescription) {

        if (!TextUtils.isEmpty(description)) {
            txt_AllCouponDescription.setText(tm_coupon_data.description);
        } else {
            txt_AllCouponDescription.setVisibility(View.GONE);
        }
    }

    private void discountOnProductCart(String discountType, TextView txt_AvailableDiscount, TextView txt_DiscountOn, LinearLayout coupons_product_listLL) {
        if (discountType != null && !discountType.isEmpty()) {
            switch (discountType) {
                case "percent":
                    txt_AvailableDiscount.setText(HtmlCompat.fromHtml(String.format(getString(L.string.available_discount, true), tm_coupon_data.amount + " % ")));
                    txt_DiscountOn.setText(HtmlCompat.fromHtml(String.format(getString(L.string.discount_apply_on, true), getString(L.string.cart))));
                    coupons_product_listLL.setVisibility(View.GONE);
                    break;
                case "percent_product":
                    txt_AvailableDiscount.setText(HtmlCompat.fromHtml(String.format(getString(L.string.available_discount, true), tm_coupon_data.amount + " % ")));
                    txt_DiscountOn.setText(HtmlCompat.fromHtml(String.format(getString(L.string.discount_apply_on, true), "")));
                    coupons_product_listLL.setVisibility(View.VISIBLE);
                    break;
                case "fixed_product":
                    txt_AvailableDiscount.setText(HtmlCompat.fromHtml(String.format(getString(L.string.available_discount, true), Helper.appendCurrency(tm_coupon_data.amount))));
                    txt_DiscountOn.setText(HtmlCompat.fromHtml(String.format(getString(L.string.discount_apply_on, true), "")));
                    coupons_product_listLL.setVisibility(View.VISIBLE);
                    break;
                default:
                    txt_AvailableDiscount.setText(HtmlCompat.fromHtml(String.format(getString(L.string.available_discount, true), Helper.appendCurrency(tm_coupon_data.amount))));
                    txt_DiscountOn.setText(HtmlCompat.fromHtml(String.format(getString(L.string.discount_apply_on, true), getString(L.string.cart))));
                    coupons_product_listLL.setVisibility(View.GONE);
            }
        }
    }

    private void enableFreeShipping(boolean enable_free_shipping, TextView txt_FreeShipping) {
        if (!enable_free_shipping) {
            txt_FreeShipping.setVisibility(View.GONE);
        } else {
            txt_FreeShipping.setVisibility(View.VISIBLE);
            txt_FreeShipping.setText(HtmlCompat.fromHtml(getString(L.string.free_shipping_available, true)));
        }
    }


    private void loadExcludeProduct(CouponsViewHolder holder) {
        if (!tm_coupon_data.exclude_product_ids.isEmpty()) {
            holder.coupons_exclude_product_items_recyclerview.setVisibility(View.VISIBLE);
            holder.coupons_exclude_product_items_recyclerview.setLayoutManager(new LinearLayoutManager(holder.getContext(), LinearLayoutManager.HORIZONTAL, false));
            adapterCouponExcludeProducts = new Adapter_Tiny_ExcludeProduct(new ArrayList<TM_ProductInfo>());
            holder.coupons_exclude_product_items_recyclerview.setAdapter(adapterCouponExcludeProducts);
            {
                boolean isAnyProductMissing = false;
                List<TM_ProductInfo> productsForThisCoupon = new ArrayList<>();

                for (int id : tm_coupon_data.exclude_product_ids) {
                    TM_ProductInfo productInfo = TM_ProductInfo.findProductById(id);
                    if (productInfo == null) {
                        isAnyProductMissing = true;
                        break;
                    }
                    productsForThisCoupon.add(productInfo);
                }

                if (isAnyProductMissing) {
                    DataEngine.getDataEngine().getPollProductsInBackground(tm_coupon_data.exclude_product_ids, new DataQueryHandler<List<TM_ProductInfo>>() {
                        @Override
                        public void onSuccess(List<TM_ProductInfo> data) {
                            adapterCouponExcludeProducts.addAll(data);
                        }

                        @Override
                        public void onFailure(Exception exception) {
                            exception.printStackTrace();
                        }
                    });

                } else {
                    adapterCouponExcludeProducts.addAll(productsForThisCoupon);
                }
            }
        } else {
            holder.coupons_exclude_product_items_recyclerview.setVisibility(View.GONE);
        }
    }

    private void loadCategories(CouponsViewHolder holder) {
        if (!tm_coupon_data.product_category_ids.isEmpty()) {
            holder.coupons_categoriesitems_recyclerview.setVisibility(View.VISIBLE);
            holder.coupons_categoriesitems_recyclerview.setLayoutManager(new LinearLayoutManager(holder.getContext(), LinearLayoutManager.HORIZONTAL, false));
            Adapter_Tiny_Categories adapter = new Adapter_Tiny_Categories(new ArrayList<TM_CategoryInfo>(), true);
            holder.coupons_categoriesitems_recyclerview.setAdapter(adapter);
            boolean isAnyCategoryMissing = false;
            List<TM_CategoryInfo> categoryForThisCoupon = new ArrayList<>();
            for (int id : tm_coupon_data.product_category_ids) {
                TM_CategoryInfo categoryInfo = TM_CategoryInfo.getWithId(id);
                if (categoryInfo == null) {
                    isAnyCategoryMissing = true;
                    break;
                }
                categoryForThisCoupon.add(categoryInfo);
            }
            if (isAnyCategoryMissing) {
                adapter.addAll(categoryForThisCoupon);
            } else {
                adapter.addAll(categoryForThisCoupon);
            }
        } else {
            holder.coupons_categoriesitems_recyclerview.setVisibility(View.GONE);
        }
    }

    private void setExcludeCategories(CouponsViewHolder holder) {
        if (!tm_coupon_data.exclude_product_category_ids.isEmpty()) {
            holder.coupons_exclude_categoriesitems_recyclerview.setVisibility(View.VISIBLE);
            holder.coupons_exclude_categoriesitems_recyclerview.setLayoutManager(new LinearLayoutManager(holder.getContext(), LinearLayoutManager.HORIZONTAL, false));
            Adapter_Tiny_Categories adapter = new Adapter_Tiny_Categories(new ArrayList<TM_CategoryInfo>(), false);
            holder.coupons_exclude_categoriesitems_recyclerview.setAdapter(adapter);
            boolean isAnyCategoryMissing = false;
            List<TM_CategoryInfo> categoryForThisCoupon = new ArrayList<>();
            for (int id : tm_coupon_data.exclude_product_category_ids) {
                TM_CategoryInfo categoryInfo = TM_CategoryInfo.getWithId(id);
                if (categoryInfo == null) {
                    isAnyCategoryMissing = true;
                    break;
                }
                categoryForThisCoupon.add(categoryInfo);
            }
            if (isAnyCategoryMissing) {
                adapter.addAll(categoryForThisCoupon);
            } else {
                adapter.addAll(categoryForThisCoupon);
            }
        } else {
            holder.coupons_exclude_categoriesitems_recyclerview.setVisibility(View.GONE);
        }
    }

    private String verifyCoupon(TM_Coupon coupon, List<Integer> selectedProductIds, List<Integer> selectedVariationIds, List<Integer> selectedCategoryIds, String userEmail, float total_amount) {
        if (!coupon.product_ids.isEmpty()) {
            if (coupon.type.equals("fixed_product") || coupon.type.equals("percent_product")) {
                boolean applicableProductFound = false;
                for (int id : selectedProductIds) {
                    if (coupon.product_ids.contains(id)) {
                        applicableProductFound = true;
                        break;
                    }
                }
                if (!applicableProductFound) {
                    for (int id : selectedVariationIds) {
                        if (coupon.product_ids.contains(id)) {
                            applicableProductFound = true;
                            break;
                        }
                    }
                }
                if (!applicableProductFound) {
                    Log.d("== product [" + coupon.id + "] does not belongs to coupon's product_ids ==");
                    return getString(L.string.coupon_not_applicable_for_products);
                }
            }
        }

        if (!coupon.exclude_product_ids.isEmpty()) {
            if (coupon.type.equals("fixed_product") || coupon.type.equals("percent_product")) {
                boolean notApplicableProductFound = false;
                for (int id : selectedProductIds) {
                    if (!coupon.exclude_product_ids.contains(id)) {
                        notApplicableProductFound = true;
                        break;
                    }
                }
                if (!notApplicableProductFound) {
                    for (int id : selectedVariationIds) {
                        if (!coupon.exclude_product_ids.contains(id)) {
                            notApplicableProductFound = true;
                            break;
                        }
                    }
                }
                if (notApplicableProductFound) {
                    Log.d("== product [" + coupon.id + "] does not belongs to coupon's exclude_product_ids ==");
                    return getString(L.string.coupon_not_applicable_for_products);
                }
            } else {
                for (int id : selectedProductIds) {
                    if (coupon.exclude_product_ids.contains(id)) {
                        Log.d("== product [" + id + "] belongs to coupon's exclude_product_ids ==");
                        return String.format(getString(L.string.coupon_invalid_for_product), TM_ProductInfo.getProductWithId(id).title);
                    }
                }
            }
        }

        if (coupon.usage_limit <= 0 || coupon.usage_count > coupon.usage_limit) {
            return getString(L.string.coupon_surpasses_total_usage_limit);
        }

        if (coupon.usage_limit_per_user <= 0) {
            return getString(L.string.coupon_exceeds_usage_limit);
        }

        if (coupon.limit_usage_to_x_items > 0 && selectedProductIds.size() > coupon.limit_usage_to_x_items) {
            return String.format(getString(L.string.coupon_not_applicable_for_items), coupon.limit_usage_to_x_items);
        }

        if (!coupon.product_category_ids.isEmpty()) {
            for (int id : selectedCategoryIds) {
                if (!coupon.product_category_ids.contains(id)) {
                    Log.d("== product [" + id + "] does not belongs to coupon's product_category_ids ==");
                    return getString(L.string.coupon_not_applicable_for_category);
                }
            }
        }

        if (!coupon.exclude_product_category_ids.isEmpty()) {
            for (int id : selectedCategoryIds) {
                if (coupon.exclude_product_category_ids.contains(id)) {
                    Log.d("== product [" + id + "] belongs to coupon's exclude_product_category_ids ==");
                    return getString(L.string.coupon_not_applicable_for_category);
                }
            }
        }

        if (coupon.exclude_sale_items) {
            for (int id : selectedProductIds) {
                TM_ProductInfo productInfo = TM_ProductInfo.getProductWithId(id);
                if (productInfo != null && productInfo.on_sale) {
                    return getString(L.string.coupon_invalid_for_already_sale_items);
                }
            }
        }

        if (coupon.minimum_amount > 0 && total_amount < coupon.minimum_amount) {
            return String.format(getString(L.string.coupon_valid_for_min_purchase), Helper.appendCurrency(coupon.minimum_amount));
        }

        if (coupon.maximum_amount > 0 && total_amount > coupon.maximum_amount) {
            return String.format(getString(L.string.coupon_valid_for_max_purchase), Helper.appendCurrency(coupon.maximum_amount));
        }

        if (!coupon.customer_emails.isEmpty()) {
            if (!coupon.customer_emails.contains(userEmail)) {
                return getString(L.string.coupon_not_applicable_for_email);
            }
        }
        return "success";
    }
}