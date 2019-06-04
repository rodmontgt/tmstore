package com.twist.tmstore.fragments;

import android.content.Intent;
import android.graphics.Color;
import android.graphics.Paint;
import android.os.Bundle;
import android.support.v7.widget.CardView;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.easyandroidanimations.library.Animation;
import com.easyandroidanimations.library.HighlightAnimation;
import com.easyandroidanimations.library.ShakeAnimation;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.twist.dataengine.entities.PincodeSetting;
import com.twist.dataengine.entities.RewardPoint;
import com.twist.dataengine.entities.TM_Coupon;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.dataengine.entities.TM_SimpleCart;
import com.twist.oauth.NetworkRequest;
import com.twist.oauth.NetworkResponse;
import com.twist.tmstore.BaseActivity;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.Constants;
import com.twist.tmstore.Extras;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.ShippingAddressPickerActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.Adapter_AppliedCoupons;
import com.twist.tmstore.adapters.Adapter_TrendingItems;
import com.twist.tmstore.adapters.CartAdapter;
import com.twist.tmstore.config.GuestUserConfig;
import com.twist.tmstore.config.PinCodeSettingsConfig;
import com.twist.tmstore.dialogs.CartUpdateDialog;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.entities.AppliedCoupon;
import com.twist.tmstore.entities.Cart;
import com.twist.tmstore.entities.CartBundleItem;
import com.twist.tmstore.entities.CartMeta;
import com.twist.tmstore.listeners.LoginDialogListener;
import com.twist.tmstore.listeners.ModificationListener;
import com.utils.CContext;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.JsonUtils;
import com.utils.ListUtils;
import com.utils.Log;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Fragment_Cart extends BaseFragment {

    private static final String ARG_COUPON_CODE = "coupon_code";

    View summarySection;
    View couponSection;
    View crossSellSection;
    View pointsSection;

    View empty;
    CartAdapter adapter = null;
    Adapter_AppliedCoupons adapter_appliedCoupons = null;
    TextView text_total_payment, txt_totalsavings;
    TextView txt_title_total_savings;

    Button mButtonPlaceOrder;
    Button mButtonKeepShopping;
    Button mButtonKeepShoppingCart;
    View appliedCouponsView;
    LinearLayout all_coupons;

    EditText textCouponCode;

    TextView all_discount_couponsTXT;
    Button button_apply;
    TextView txt_coupon_status;
    ProgressBar progress_coupon;
    ProgressBar progress_cross_sells;

    Adapter_TrendingItems adapter_cross_sells = null;

    View cart_footer;

    //AutoCoupons
    View meta_section_group;
    LinearLayout cart_meta_section;
    ProgressBar progress_auto_coupon;
    CartMeta cartMeta;

    private LinearLayout deposit_amount_section;
    private TextView label_deposit_amount, text_deposit_amount;

    private LinearLayout deposit_remaining_amount_section;
    private TextView label_deposit_remaining_amount, text_deposit_remaining_amount;

    private String errorMessage1 = "Some products are modified";
    private String errorMessage2 = "Prices of some items are updated";
    private String errorMessage3 = "'%s' is out of stock.";
    private String errorMessage4 = "Only %s of %s are available.";

    public Fragment_Cart() {
    }

    public static Fragment_Cart newInstance(String couponCode) {
        Fragment_Cart fragment = new Fragment_Cart();
        Bundle args = new Bundle();
        args.putString(ARG_COUPON_CODE, couponCode);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
        setActionBarHomeAsUpIndicator();
        getBaseActivity().restoreActionBar();
    }

    @Override
    public void onResume() {
        super.onResume();
        if (adapter != null) {
            adapter.updateData(Cart.getAll());
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_cart, container, false);

        RecyclerView recyclerview = (RecyclerView) rootView.findViewById(R.id.recyclerview_cart_products);
        adapter = new CartAdapter(getActivity(), new ArrayList<Cart>());
        recyclerview.setAdapter(adapter);
        mButtonKeepShoppingCart = (Button) rootView.findViewById(R.id.btn_keepshopping_cart);
        mButtonPlaceOrder = (Button) rootView.findViewById(R.id.btn_place_order);

        prepareEmptySection(rootView);
        cart_footer = View.inflate(getActivity(), R.layout.fragment_cart_footer, null);
        this.setRootView(cart_footer);
        prepareFooterSection(cart_footer);
        adapter.addFooter(cart_footer);

        adapter.setModificationListener(new ModificationListener() {
            @Override
            public void onModificationDone() {
                refreshCouponSection();
                resetCartSummary();
                resetCrossSells();
                showCartRewardPoints();
                MainActivity.mActivity.reloadMenu();
            }
        });

        return rootView;
    }

    private void prepareEmptySection(View rootView) {
        empty = rootView.findViewById(R.id.text_empty);

        mButtonPlaceOrder.setVisibility(View.GONE);
        mButtonKeepShoppingCart.setVisibility(View.GONE);

        this.setTextOnView(rootView, R.id.no_items_in_cart, L.string.no_items_in_cart);
        mButtonKeepShopping = (Button) rootView.findViewById(R.id.btn_keepshopping);
        mButtonKeepShopping.setText(getString(L.string.keep_shopping));
        Helper.stylize(mButtonKeepShopping);

        mButtonKeepShopping.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                MainActivity.mActivity.onNavigationDrawerItemSelected(Constants.MENU_ID_HOME, -1);
            }
        });
    }

    private void initDepositSection(View rootView) {
        deposit_amount_section = (LinearLayout) rootView.findViewById(R.id.deposit_amount_section);
        deposit_amount_section.setVisibility(View.GONE);
        label_deposit_amount = (TextView) rootView.findViewById(R.id.label_deposit_amount);
        label_deposit_amount.setText(getString(L.string.label_deposit_amount));
        text_deposit_amount = (TextView) rootView.findViewById(R.id.text_deposit_amount);

        deposit_remaining_amount_section = (LinearLayout) rootView.findViewById(R.id.deposit_remaining_amount_section);
        deposit_remaining_amount_section.setVisibility(View.GONE);
        label_deposit_remaining_amount = (TextView) rootView.findViewById(R.id.label_deposit_remaining_amount);
        label_deposit_remaining_amount.setText(getString(L.string.label_deposit_remaining_amount));
        text_deposit_remaining_amount = (TextView) rootView.findViewById(R.id.text_deposit_remaining_amount);
    }

    private void prepareFooterSection(View rootView) {
        crossSellSection = rootView.findViewById(R.id.crossSellSection);
        if (!AppInfo.SHOW_CROSSSEL_PRODUCTS) {
            crossSellSection.setVisibility(View.GONE);
        } else {
            RecyclerView recycler_cross_sales = (RecyclerView) rootView.findViewById(R.id.recycler_cross_sales);
            //adapter_cross_sells = new Adapter_TrendingItems(getContext(), getCrossSellsFromCart());
            adapter_cross_sells = new Adapter_TrendingItems(getContext(), new ArrayList<TM_ProductInfo>(), new OnClickListener() {
                @Override
                public void onClick(View view) {

                }
            });
            recycler_cross_sales.setAdapter(adapter_cross_sells);
        }

        initDepositSection(rootView);
        summarySection = rootView.findViewById(R.id.bottom_layout);

        if (!AppInfo.SHOW_KEEP_SHOPPING_IN_CART) {
            mButtonKeepShoppingCart.setVisibility(View.GONE);
        } else {
            mButtonKeepShoppingCart.setVisibility(View.VISIBLE);
            mButtonKeepShoppingCart.setText(getString(L.string.keep_shopping_cart));
            Helper.stylize(mButtonKeepShoppingCart);
            mButtonKeepShoppingCart.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    goBack();
                }
            });
        }

        mButtonPlaceOrder.setVisibility(View.VISIBLE);
        mButtonPlaceOrder.setText(getString(L.string.place_order));
        Helper.stylize(mButtonPlaceOrder);
        mButtonPlaceOrder.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                //TODO remove if you want to disable purchase in demo version
//                if (AppInfo.DEMO_APP) {
//                    Helper.toast(L.string.demo_version);
//                    return;
//                }

                if (GuestUserConfig.isGuestCheckout() && !AppUser.hasSignedIn()) {
                    if (GuestUserConfig.isGuestContinue()) {
                        showLoginDialog(true);
                    } else {
                        verifyCartProducts();
                        if (AppInfo.USE_MULTIPLE_SHIPPING_ADDRESSES) {
                            startActivity(new Intent(getActivity(), ShippingAddressPickerActivity.class));
                        } else {
                            MainActivity.mActivity.showEditProfile(false);
                        }
                    }
                    return;
                }
                if (AppUser.getInstance().user_type == AppUser.USER_TYPE.ANONYMOUS_USER) {
                    showLoginDialog(true);
                } else {
                    verifyCartProducts();
                }
            }
        });

        Cart.refresh();

        text_total_payment = (TextView) rootView.findViewById(R.id.text_total_payment);
        txt_totalsavings = (TextView) rootView.findViewById(R.id.txt_totalsavings);
        txt_title_total_savings = (TextView) rootView.findViewById(R.id.total_savings);

        if (!AppInfo.SHOW_TOTAL_SAVINGS) {
            txt_title_total_savings.setVisibility(View.GONE);
            txt_totalsavings.setVisibility(View.GONE);
        } else {
            txt_title_total_savings.setVisibility(View.VISIBLE);
            txt_totalsavings.setVisibility(View.VISIBLE);
        }
        txt_title_total_savings.setText(getString(L.string.total_savings));

        this.setTextOnView(R.id.cart_totals, L.string.cart_totals);
        this.setTextOnView(R.id.apply_new_coupon, L.string.apply_new_coupon);
        this.setTextOnView(R.id.text_applied_coupons, L.string.applied_coupons);
        this.setTextOnView(R.id.header_upsells_products, L.string.header_upsells_products);

        {
            couponSection = rootView.findViewById(R.id.coupon_section);
            appliedCouponsView = rootView.findViewById(R.id.applied_coupons);
            all_coupons = (LinearLayout) rootView.findViewById(R.id.all_coupons);
            all_coupons.setVisibility(View.GONE);

            textCouponCode = (EditText) rootView.findViewById(R.id.coupon_code);
            textCouponCode.setHint(getString(L.string.enter_coupon_code));

            button_apply = (Button) rootView.findViewById(R.id.button_apply);
            button_apply.setText(getString(L.string.apply));
            Helper.stylize(button_apply);

            txt_coupon_status = (TextView) rootView.findViewById(R.id.coupon_status);
            txt_coupon_status.setText(getString(L.string.coupon_applied_successfully));

            progress_coupon = (ProgressBar) rootView.findViewById(R.id.progress_coupon);
            progress_cross_sells = (ProgressBar) rootView.findViewById(R.id.progress_cross_sells);
            progress_coupon.setVisibility(View.GONE);
            progress_cross_sells.setVisibility(View.GONE);
            Helper.stylize(progress_coupon);
            Helper.stylize(progress_cross_sells);
            txt_coupon_status.setVisibility(View.GONE);

            all_discount_couponsTXT = (TextView) rootView.findViewById(R.id.all_applied_discount_coupons);
            if (AppInfo.HIDE_COUPON_LIST) {
                all_discount_couponsTXT.setVisibility(View.GONE);
            } else {
                all_discount_couponsTXT.setVisibility(View.VISIBLE);
            }

            String my_coupons = "<u>" + getString(L.string.my_coupons) + "</u>";
            all_discount_couponsTXT.setText(HtmlCompat.fromHtml(my_coupons));
            all_discount_couponsTXT.setTextColor(Color.parseColor(AppInfo.normal_button_color));
            all_discount_couponsTXT.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    MainActivity.mActivity.openCouponList();
                }
            });

            button_apply.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    getBaseActivity().hideKeyBoard();
                    if (!AppUser.hasSignedIn()) {
                        Helper.toast(L.string.you_need_to_login_first);
                        showLoginDialog(false);
                        return;
                    }

                    final String enteredCode = textCouponCode.getText().toString().trim();
                    if (TextUtils.isEmpty(enteredCode)) {
                        showCouponError(getString(L.string.invalid_coupon_code));
                        return;
                    }

                    TM_Coupon tm_coupon = TM_Coupon.getWithCode(enteredCode);
                    if (tm_coupon == null || TM_Coupon.getAll().isEmpty()) {
                        progress_coupon.setVisibility(View.VISIBLE);
                        txt_coupon_status.setVisibility(View.GONE);
                        DataEngine.getDataEngine().getCouponInfoInBackground(enteredCode, new DataQueryHandler<TM_Coupon>() {
                            @Override
                            public void onSuccess(TM_Coupon data) {
                                try {
                                    progress_coupon.setVisibility(View.GONE);
                                    applyCoupon(enteredCode);
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                            }

                            @Override
                            public void onFailure(Exception reason) {
                                try {
                                    progress_coupon.setVisibility(View.GONE);
                                    showCouponError(getString(L.string.coupon_details_error));
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                            }
                        });
                    } else {
                        applyCoupon(textCouponCode.getText().toString().trim());
                    }
                }
            });

            if (adapter_appliedCoupons == null) {
                adapter_appliedCoupons = new Adapter_AppliedCoupons((BaseActivity) getActivity(), new ArrayList<>());
                adapter_appliedCoupons.setCouponRemovalRequestListener(new Adapter_AppliedCoupons.CouponRemovalRequestListener() {
                    @Override
                    public void onRemovalRequested(int couponId) {
                        Cart.removeCoupon(couponId);
                        if (!Cart.isAnyCouponApplied()) {
                            txt_coupon_status.setVisibility(View.GONE);
                        }
                        refreshCouponSection();
                        resetCartSummary();
                    }
                });
            }
        }

        //autoCoupons section
        {
            meta_section_group = rootView.findViewById(R.id.meta_section_group);
            if (AppInfo.ENABLE_AUTO_COUPONS) {
                meta_section_group.setVisibility(View.VISIBLE);
                cart_meta_section = (LinearLayout) meta_section_group.findViewById(R.id.cart_meta_section);
                progress_auto_coupon = (ProgressBar) meta_section_group.findViewById(R.id.progress_auto_coupon);
                progress_auto_coupon.setVisibility(View.GONE);
                this.setTextOnView(rootView, R.id.title_meta_section_group, L.string.title_meta_section_group);
            } else {
                meta_section_group.setVisibility(View.GONE);
            }
        }

        String ids = Cart.getUnavailableProductIds();
        Log.d("-- getUnavailableProductIds: [" + ids + "] --");
        if (ids.equals("")) {
            refreshCouponSection();
            resetCartSummary();
            resetCrossSells();
            loadAutoCoupons();
        } else {
            fetchCartProducts(ids.substring(0, ids.length() - 1));
        }

        setTitle(getString(L.string.title_cart));
        // set coupon code received from notification
        String couponCode = getArguments().getString(ARG_COUPON_CODE);
        if (!TextUtils.isEmpty(couponCode)) {
            textCouponCode.setText(couponCode);
            if (Helper.copyToClipboard(getActivity(), couponCode)) {
                Helper.toast(getString(L.string.coupon_code_copied));
            }
        }
        pointsSection = findView(R.id.reward_points_section);
        pointsSection.setVisibility(View.GONE);
        loadCartRewardPoints();
        loadPinCodeSettings(rootView);
    }

    private void loadAutoCoupons() {
        if (!AppInfo.ENABLE_AUTO_COUPONS)
            return;

        if (Cart.getItemCount() == 0) {
            return;
        }

        if (AppUser.getInstance().user_type == AppUser.USER_TYPE.ANONYMOUS_USER) {
            addMessageLine(cart_meta_section, getString(L.string.not_signed_in));
            return;
        }

        if (!AppUser.getInstance().hasBasicDetails() || !Helper.isValidString(AppUser.getInstance().billing_address.postcode)) {
            addMessageLine(cart_meta_section, getString(L.string.add_billing_address));
            return;
        }

        generateSession();
    }

    public void generateSession() {
        progress_auto_coupon.setVisibility(View.VISIBLE);
        HashMap<String, String> params = new HashMap<>();
        params.put("user_platform", "Android");
        params.put("user_emailID", AppUser.getEmail());
        NetworkRequest.makeCommonPostRequest(DataEngine.getDataEngine().url_login_website, params, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse postResponse) {
                hideProgress();
                if (postResponse.succeed && postResponse.msg.contains("Login Successful")) {
                    try {
                        getAutoCouponDataInBackground();
                    } catch (Exception really) {
                        really.printStackTrace();
                    }
                } else {
                    progress_auto_coupon.setVisibility(View.GONE);
                    postResponse.error.printStackTrace();
                }
            }
        });
    }

    public void getAutoCouponDataInBackground() {
        progress_auto_coupon.setVisibility(View.VISIBLE);
        Map<String, String> postParams = new HashMap<>();
        postParams.put("cart_data", JsonUtils.prepareCartJson());
        postParams.put("ship_data", JsonUtils.prepareShippingJson());
        postParams.put("bill_data", JsonUtils.prepareBillingJson());
        postParams.put("coupon_data", "[]");
        NetworkRequest.makeCommonPostRequest(DataEngine.getDataEngine().url_cart_items, postParams, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                try {
                    progress_auto_coupon.setVisibility(View.GONE);
                    cartMeta = JsonUtils.parseJsonAndCreateCartMeta(response.msg);
                    if (cartMeta != null) {
                        meta_section_group.setVisibility(View.VISIBLE);
                        updateCartMetaUI(cartMeta);
                    } else {
                        meta_section_group.setVisibility(View.GONE);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });
    }

    void updateCartMetaUI(CartMeta cartMeta) {
        cart_meta_section.removeAllViewsInLayout();
        if (cartMeta.applied_coupons != null && cartMeta.applied_coupons.length > 0) {
            boolean isAnyAutoCouponFound = false;
            for (AppliedCoupon appliedCoupon : cartMeta.applied_coupons) {
                if (appliedCoupon.discount_amount > 0) {
                    isAnyAutoCouponFound = true;
                    addAutoCouponLine(cart_meta_section, appliedCoupon.title, appliedCoupon.discount_amount);
                }
            }
            if (!isAnyAutoCouponFound) {
                addMessageLine(cart_meta_section, getString(L.string.no_coupon_available));
            }
        } else {
            addMessageLine(cart_meta_section, getString(L.string.no_coupon_available));
        }
        resetCartSummary();
    }

    private void applyCoupon(String couponCode) {
        if (TM_Coupon.getAll().isEmpty()) {
            progress_coupon.setVisibility(View.GONE);
            showCouponError(getString(L.string.no_coupon_available));
            return;
        }
        TM_Coupon coupon = TM_Coupon.getWithCode(couponCode);
        if (coupon == null) {
            showCouponError(getString(L.string.invalid_coupon_code));
        } else {
            String msg = verifyCoupon(coupon, Cart.getAllProductIds(), Cart.getAllVariationIds(), Cart.getAllCategoryIds(), AppUser.getEmail(), Cart.getTotalPaymentExcludingCoupons());
            if (msg.equals("success")) {
                String msg2 = Cart.addCoupon(coupon);
                if (msg2.equals("success")) {
                    showCouponSuccess(getString(L.string.coupon_applied_successfully));
                    refreshCouponSection();
                    resetCartSummary();
                    loadAutoCoupons();
                } else {
                    showCouponError(msg2);
                }
            } else {
                showCouponError(msg);
            }
        }
    }

    private void showCouponError(String msg) {
        txt_coupon_status.setVisibility(View.VISIBLE);
        txt_coupon_status.setText(HtmlCompat.fromHtml(msg)); //);
        new ShakeAnimation(txt_coupon_status).setNumOfShakes(2).setDuration(Animation.DURATION_SHORT).animate();
    }

    private void showCouponSuccess(String msg) {
        txt_coupon_status.setVisibility(View.VISIBLE);
        txt_coupon_status.setText(HtmlCompat.fromHtml(msg)); //);
        new HighlightAnimation(txt_coupon_status).animate();
    }

    private void fetchCartProducts(String productIds) {
        showProgress(getString(L.string.retrieving_cart));
        couponSection.setVisibility(View.GONE);
        summarySection.setVisibility(View.GONE);
        DataEngine.getDataEngine().getPollProductsInBackground(productIds, new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {
                hideProgress();
                Cart.refresh();
                try {
                    refreshCouponSection();
                    resetCartSummary();
                    resetCrossSells();
                    showCartRewardPoints();
                    loadAutoCoupons();
                } catch (IllegalStateException ex) {
                    ex.printStackTrace();
                }
            }

            @Override
            public void onFailure(Exception exception) {
                hideProgress();
            }
        });
    }

    private void verifyCartProducts() {
        showProgress(getString(L.string.verifying_cart), false);
        try {
            String cartJson = JsonUtils.getCartStringForVerification();
            DataEngine.getDataEngine().updateCartItemsInBackground(cartJson, new DataQueryHandler<List<TM_SimpleCart>>() {
                @Override
                public void onSuccess(List<TM_SimpleCart> simpleCarts) {
                    hideProgress();

                    String errorMsg = "";
                    // First find a bundle product in cart then find its bundled products in simple cart.
                    // check for their stock related properties and then remove them from simple cart.
                    List<TM_SimpleCart> simpleBundleCarts = new ArrayList<>();
                    for (TM_SimpleCart simpleCart : simpleCarts) {
                        Cart cart = Cart.findCart(simpleCart.pid, simpleCart.vid, simpleCart.index);
                        if (cart != null && cart.bundledItems != null) {
                            for (CartBundleItem cartBundleItem : cart.bundledItems) {
                                for (TM_SimpleCart simpleBundleCart : simpleCarts) {
                                    if (cartBundleItem.getProductId() == simpleBundleCart.pid) {
                                        if (!simpleBundleCart.manage_stock.equals("no")) {
                                            if (!simpleBundleCart.backorders.equals("yes")) {
                                                if (!simpleBundleCart.stock_status.equals("instock")) {
                                                    if (!TextUtils.isEmpty(errorMsg)) {
                                                        errorMsg += "\n\n";
                                                    }
                                                    errorMsg += String.format(errorMessage3, simpleBundleCart.title);
                                                    continue;
                                                } else if (simpleBundleCart.total_stock < (cart.count * cartBundleItem.getQuantity())) {
                                                    if (!TextUtils.isEmpty(errorMsg)) {
                                                        errorMsg += "\n\n";
                                                    }
                                                    errorMsg += String.format(errorMessage4, simpleBundleCart.total_stock, simpleBundleCart.title);
                                                    continue;
                                                }
                                            }
                                        }
                                        simpleBundleCarts.add(simpleBundleCart);
                                        break;
                                    }
                                }
                            }
                        }
                    }

                    if (TextUtils.isEmpty(errorMsg)) {
                        for (TM_SimpleCart simpleCart : simpleCarts) {
                            Cart cart = Cart.findCart(simpleCart.pid, simpleCart.vid, simpleCart.index);
                            if (cart == null) {
                                boolean bundled = false;
                                for (TM_SimpleCart simpleBundleCart : simpleBundleCarts) {
                                    if (simpleCart.pid == simpleBundleCart.pid) {
                                        // it is bundled product and we have already
                                        // checked for stock related properties
                                        bundled = true;
                                        break;
                                    }
                                }

                                if (!bundled) {
                                    errorMsg = errorMessage1;
                                }
                                continue;
                            }

                            if (!ListUtils.isEmpty(cart.matchedItems)) {
                                //TODO implement verification for matched products
                                continue;
                            }

                            cart.img_url = simpleCart.img;
                            cart.title = simpleCart.title;
                            cart.weight = (float) simpleCart.weight;

                            if (cart.getActualPrice() != simpleCart.getActualPrice()) {
                                errorMsg = errorMessage2;
                                cart.updatePrice(simpleCart.getActualPrice());
                                try {
                                    cart.save();
                                } catch (Exception e) {
                                    e.printStackTrace();
                                }
                                continue;
                            }

                            if (!simpleCart.manage_stock.equals("no")) {
                                if (!simpleCart.backorders.equals("yes")) {
                                    if (!simpleCart.stock_status.equals("instock")) {
                                        errorMsg = String.format(errorMessage3, cart.title);
                                    } else if (simpleCart.total_stock < cart.count) {
                                        errorMsg = String.format(errorMessage4, simpleCart.total_stock, cart.title);
                                    }
                                }
                            }

                            try {
                                cart.save();
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    }

                    if (!TextUtils.isEmpty(errorMsg)) {
                        Cart.clearCoupons();
                        refreshCouponSection();
                        showCartRewardPoints();
                        resetCartSummary();
                        loadAutoCoupons();
                        showCartUpdateDialog(errorMsg);
                    } else {
                        showConfirmOrderDialog();
                    }
                }

                @Override
                public void onFailure(Exception reason) {
                    reason.printStackTrace();
                    hideProgress();
                    showConfirmOrderDialog();
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void showCartUpdateDialog(String msg) {
        new CartUpdateDialog().showDialog(getActivity(), msg, true, null);
    }

    private void showConfirmOrderDialog() {
        try {
            if (AppInfo.SHOW_PICKUP_LOCATION) {
                MainActivity.mActivity.openSelectPaymentPage(new String[]{});
            } else {
                getActivity().getSupportFragmentManager().beginTransaction()
                        .replace(R.id.content, Fragment_ConfirmOrder.newInstance())
                        .addToBackStack(Fragment_ConfirmOrder.class.getSimpleName())
                        .commit();
            }

        } catch (IllegalStateException ise) {
            ise.printStackTrace();
        }
    }

    private void showLoginDialog(final boolean shouldOpenConfirmOrder) {
        Fragment_Login_Dialog fragmentLoginDialog = new Fragment_Login_Dialog();
        fragmentLoginDialog.setLoginDialogHandler(new LoginDialogListener() {
            @Override
            public void onLoginSuccess() {
                if (shouldOpenConfirmOrder) {
                    verifyCartProducts();
                }
                MainActivity.mActivity.showEditProfile(false);
            }

            @Override
            public void onLoginFailed(String cause) {
                Log.e(cause);
            }
        });

        if (GuestUserConfig.isGuestContinue()) {
            Bundle args = new Bundle();
            args.putBoolean(Extras.GUEST_CONTINUE, true);
            fragmentLoginDialog.setArguments(args);
        }

        fragmentLoginDialog.show(getActivity().getSupportFragmentManager(), Fragment_Login_Dialog.class.getSimpleName());
    }

    private void refreshCouponSection() {
        if (!AppInfo.ENABLE_COUPONS || Cart.getAll().isEmpty()) {
            couponSection.setVisibility(View.GONE);
            return;
        }

        couponSection.setVisibility(View.VISIBLE);
        textCouponCode.setText("");

        if (!Cart.isAnyCouponApplied()) {
            appliedCouponsView.setVisibility(View.GONE);
        } else {
            appliedCouponsView.setVisibility(View.VISIBLE);
            all_coupons.setVisibility(View.VISIBLE);
            all_coupons.removeAllViews();
            all_coupons.removeAllViewsInLayout();

            adapter_appliedCoupons.resetList(Cart.applied_coupons);

            for (int i = 0; i < adapter_appliedCoupons.getCount(); i++) {
                View v = adapter_appliedCoupons.getView(i, null, null);
                all_coupons.addView(v, new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT));
            }
        }
    }

    private void resetCartSummary() {
        //if(Cart.getTotalPayment() > 0)
        if (Cart.getItemCount() > 0) {
            float totalPayment = Cart.getTotalPayment();
            float totalSaving = Cart.getTotalSavings();
            float totalAutoCouponDiscount = getAutoCouponDiscount();

            totalPayment = Math.max((totalPayment - totalAutoCouponDiscount), 0.0f);
            if (AppInfo.HIDE_PRODUCT_PRICE_TAG) {
                text_total_payment.setVisibility(View.GONE);
                summarySection.setVisibility(View.GONE);
            } else {
                summarySection.setVisibility(View.VISIBLE);
                text_total_payment.setVisibility(View.VISIBLE);
                if (totalPayment > 0) {
                    text_total_payment.setText(HtmlCompat.fromHtml(Helper.appendCurrency(totalPayment)));
                } else {
                    text_total_payment.setText(getString(L.string.not_available));
                }
            }
            if (totalSaving > 0) {
                txt_totalsavings.setText(HtmlCompat.fromHtml(Helper.appendCurrency(totalSaving)));
            } else {
                txt_totalsavings.setText(getString(L.string.not_available));
            }

            if (Cart.getTotalPayment(true) > 0) {
                deposit_amount_section.setVisibility(View.VISIBLE);
                text_deposit_amount.setText(HtmlCompat.fromHtml(Helper.appendCurrency(Cart.getTotalPayment(true))));//Cart.checkDepositAmount()
            } else {
                deposit_amount_section.setVisibility(View.GONE);
            }

            if (Cart.getTotalPayment(true) > 0 && Cart.applied_coupons != null && !Cart.applied_coupons.isEmpty()) {
                deposit_remaining_amount_section.setVisibility(View.VISIBLE);
                text_deposit_remaining_amount.setText(HtmlCompat.fromHtml(Helper.appendCurrency((totalPayment - Cart.getTotalPayment(true)))));/*Cart.checkDepositAmount()*/
            } else {
                deposit_remaining_amount_section.setVisibility(View.GONE);
            }

            empty.setVisibility(View.GONE);

            mButtonPlaceOrder.setVisibility(View.VISIBLE);

            if (AppInfo.SHOW_KEEP_SHOPPING_IN_CART) {
                mButtonKeepShoppingCart.setVisibility(View.VISIBLE);
            } else {
                mButtonKeepShoppingCart.setVisibility(View.GONE);
            }

        } else {
            summarySection.setVisibility(View.GONE);
            empty.setVisibility(View.VISIBLE);
            mButtonPlaceOrder.setVisibility(View.GONE);
            mButtonKeepShoppingCart.setVisibility(View.GONE);
        }
    }

    private float getAutoCouponDiscount() {
        float autoCouponDiscount = 0.0f;
        if (cartMeta != null && cartMeta.applied_coupons != null && cartMeta.applied_coupons.length > 0) {
            for (AppliedCoupon coupon : cartMeta.applied_coupons) {
                autoCouponDiscount += coupon.discount_amount;
            }
        }
        return autoCouponDiscount;
    }

    private void resetCrossSells() {
        if (!AppInfo.SHOW_CROSSSEL_PRODUCTS)
            return;

        adapter_cross_sells.removeAll();
        crossSellSection.setVisibility(View.GONE);

        if (Cart.getAllProductIds().isEmpty())
            return;

        progress_cross_sells.setVisibility(View.VISIBLE);

        List<Integer> cart_product_ids = Cart.getAllProductIds();
        if (cart_product_ids != null && !cart_product_ids.isEmpty()) {
            DataEngine.getDataEngine().getCrossSellProducts(cart_product_ids, new DataQueryHandler<List<Integer>>() {
                @Override
                public void onSuccess(List<Integer> cross_sell_ids) {
                    try {
                        progress_cross_sells.setVisibility(View.GONE);
                        if (cross_sell_ids != null && !cross_sell_ids.isEmpty()) {
                            List<TM_ProductInfo> products = new ArrayList<>();
                            for (int id : cross_sell_ids) {
                                if (Cart.hasItem(id))
                                    continue;
                                TM_ProductInfo product = TM_ProductInfo.getProductWithId(id);
                                if (product != null)
                                    products.add(product);
                            }
                            adapter_cross_sells.updateProducts(products);
                            crossSellSection.setVisibility(products.isEmpty() ? View.GONE : View.VISIBLE);
                        }
                    } catch (IllegalStateException oops) {
                        oops.printStackTrace();
                    }
                }

                @Override
                public void onFailure(Exception reason) {
                    reason.printStackTrace();
                    try {
                        crossSellSection.setVisibility(View.GONE);
                        progress_cross_sells.setVisibility(View.GONE);
                    } catch (IllegalStateException oops) {
                        oops.printStackTrace();
                    }
                }
            });
        } else {
            crossSellSection.setVisibility(View.GONE);
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

        if (coupon.expiry_date != null && coupon.expiry_date.before(new Date())) {
            return getString(L.string.coupon_expired);
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
                if (productInfo.on_sale) {
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

    private void loadCartRewardPoints() {
        if (!rewardPointsCheck()) {
            return;
        }

        String data = "";
        List<Cart> carts = Cart.getAll();
        for (int i = 0; i < carts.size(); i++) {
            Cart cart = carts.get(i);
            data += "{\"prod_id\":" + cart.product_id;
            if (cart.selected_variation_id != -1) {
                data += ",\"var_ids\":[" + cart.selected_variation_id + "]";
            }
            data += "}";
            if (i < carts.size() - 1) {
                data += ",";
            }
        }
        data = "[" + data + "]";

        Map<String, String> params = new HashMap<>();
        params.put("user_id", "" + AppUser.getUserId());
        params.put("email_id", AppUser.getEmail());
        params.put("prod_data", data);

        showProgress(getString(L.string.please_wait), false);
        DataEngine.getDataEngine().getCartProductsRewardPointsAsync(params, new DataQueryHandler<String>() {
            @Override
            public void onSuccess(String data) {
                try {
                    JSONObject jsonObject = new JSONObject(data).getJSONObject("user_data");
                    RewardPoint.getInstance().setRewardsPoints(jsonObject.getInt("total_reward_points"));
                    RewardPoint.getInstance().setRewardDiscount(Float.parseFloat(jsonObject.getString("total_reward_points_value")));
                    showCartRewardPoints();

                } catch (JSONException e) {
                    onFailure(e);
                }
                hideProgress();
            }

            @Override
            public void onFailure(Exception reason) {
                reason.printStackTrace();
                pointsSection.setVisibility(View.GONE);
                hideProgress();
            }
        });
    }

    private void showCartRewardPoints() {
        if (!rewardPointsCheck()) {
            pointsSection.setVisibility(View.GONE);
            return;
        }

        int totalRewardPoints = Cart.getTotalRewardPoints();
        if (totalRewardPoints > 0) {
            TextView textEarnPoints = findTextView(R.id.text_earn_points);
            textEarnPoints.setText(HtmlCompat.fromHtml(String.format(getString(L.string.earn_points_desc), totalRewardPoints)));
        } else {
            pointsSection.setVisibility(View.GONE);
            return;
        }

        LinearLayout layoutApplyDiscount = (LinearLayout) findView(R.id.layout_apply_discount);
        layoutApplyDiscount.setVisibility(View.GONE);

        LinearLayout layoutRemoveDiscount = (LinearLayout) findView(R.id.layout_remove_discount);
        layoutRemoveDiscount.setVisibility(View.GONE);

        if (RewardPoint.getInstance().getRewardPoints() > 0) { //&& AppUser.getRewardDiscount() > 0.0f) {
            //if (true) {  /* for test only */
            if (Cart.getPointsPriceDiscount() <= 0.0f) {
                final float priceDiscount = RewardPoint.getInstance().getRewardDiscount(); // AppUser.getRewardPoints() * AppUser.getRewardDiscount() / 100.0f; // * AppUser.getRewardDiscount();
                TextView textUsePoints = findTextView(R.id.text_use_points);
                textUsePoints.setText(HtmlCompat.fromHtml(String.format(
                        getString(L.string.use_points_desc),
                        RewardPoint.getInstance().getRewardPoints(),
                        Helper.appendCurrency(priceDiscount))));

                Button buttonApplyDiscount = findButton(R.id.btn_apply_discount);
                buttonApplyDiscount.setText(getString(L.string.apply_discount));
                buttonApplyDiscount.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Cart.setPointsPriceDiscount(priceDiscount);
                        showCartRewardPoints();
                        resetCartSummary();
                        new ShakeAnimation(findTextView(R.id.text_used_points))
                                .setNumOfShakes(2)
                                .setDuration(Animation.DURATION_SHORT)
                                .animate();
                    }
                });
                Helper.stylize(buttonApplyDiscount);
                layoutApplyDiscount.setVisibility(View.VISIBLE);
                layoutRemoveDiscount.setVisibility(View.GONE);
            } else {
                final float priceDiscount = RewardPoint.getInstance().getRewardDiscount();
                int usedPoints = (int) (Cart.calculatePointsUsed(RewardPoint.getInstance().getRewardPoints()));
                TextView textUsedPoints = findTextView(R.id.text_used_points);
                textUsedPoints.setText(HtmlCompat.fromHtml(String.format(
                        getString(L.string.used_points_desc),
                        usedPoints,
                        Helper.appendCurrency((float) Cart.getPointsPriceDiscount()))));

                Button buttonRemoveDiscount = findButton(R.id.btn_remove_discount);
                buttonRemoveDiscount.setText(getString(L.string.remove_discount));
                buttonRemoveDiscount.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Cart.removePointsPriceDiscount();
                        showCartRewardPoints();
                        resetCartSummary();
                        new ShakeAnimation(findTextView(R.id.text_use_points))
                                .setNumOfShakes(2)
                                .setDuration(Animation.DURATION_SHORT)
                                .animate();
                    }
                });
                Helper.styleRemove(buttonRemoveDiscount);
                layoutApplyDiscount.setVisibility(View.GONE);
                layoutRemoveDiscount.setVisibility(View.VISIBLE);
            }
        }
        pointsSection.setVisibility(View.VISIBLE);
    }

    private boolean rewardPointsCheck() {
        return (AppInfo.ENABLE_CUSTOM_POINTS && Cart.getItemCount() != 0 && AppUser.hasSignedIn());
    }

    private void addMessageLine(LinearLayout parent, String message) {

        LinearLayout dataLine = new LinearLayout(getContext());
        dataLine.setOrientation(LinearLayout.HORIZONTAL);
        dataLine.setPadding(DP(5), DP(5), DP(5), DP(5));

        {
            TextView txtLable = new TextView(getContext());
            txtLable.setText(HtmlCompat.fromHtml(message));
            txtLable.setTextColor(getResources().getColor(R.color.normal_text_color));
            txtLable.setGravity(Gravity.CENTER_HORIZONTAL | Gravity.CENTER_VERTICAL);
            //txtLable.setTextAlignment(View.TEXT_ALIGNMENT_CENTER);
            Helper.setTextAppearance(getContext(), txtLable, android.R.style.TextAppearance_Small);
            dataLine.addView(txtLable, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        }

        parent.addView(dataLine, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
    }

    private void addAutoCouponLine(LinearLayout parent, String label, float cost) {
        LinearLayout dataLine = new LinearLayout(getContext());
        dataLine.setOrientation(LinearLayout.HORIZONTAL);
        dataLine.setPadding(DP(5), DP(5), DP(5), DP(5));
        {
            TextView txtLable = new TextView(getContext());
            txtLable.setText(HtmlCompat.fromHtml(label));
            txtLable.setGravity(Gravity.START | Gravity.LEFT | Gravity.CENTER_VERTICAL);
            Helper.setTextAppearance(getContext(), txtLable, android.R.style.TextAppearance_Small);
            txtLable.setTextColor(CContext.getColor(this, R.color.normal_text_color));
            dataLine.addView(txtLable, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));

            TextView txtCost = new TextView(getContext());
            txtCost.setText("-" + HtmlCompat.fromHtml(Helper.appendCurrency(cost)));
            Helper.setTextAppearance(getContext(), txtCost, android.R.style.TextAppearance_Small);
            txtCost.setTextColor(CContext.getColor(this, R.color.highlight_text_color_2));
            txtCost.setGravity(Gravity.END | Gravity.RIGHT | Gravity.CENTER_VERTICAL);
            dataLine.addView(txtCost, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        }

        parent.addView(dataLine, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
    }

    int DP(int measure) {
        return Helper.DP(measure, getResources());
    }

    private void loadPinCodeSettings(View rootView) {
        CardView pincode_section = (CardView) rootView.findViewById(R.id.pincode_section);
        PinCodeSettingsConfig pinCodeSettingsConfig = PinCodeSettingsConfig.getInstance();
        if (!pinCodeSettingsConfig.isEnabled()) {
            pincode_section.setVisibility(View.GONE);
            return;
        }

        if (pinCodeSettingsConfig.getCheckType() != PinCodeSettingsConfig.CheckType.CHECK_ALL_PRODUCT) {
            pincode_section.setVisibility(View.GONE);
            return;
        }

        final PincodeSetting pincodeSetting = PincodeSetting.getInstance();
        if (!pincodeSetting.isFetched() || pincodeSetting.isEnableOnProductPage()) {
            pincode_section.setVisibility(View.GONE);
            return;
        }

        pincode_section.setVisibility(View.VISIBLE);
        View view = LayoutInflater.from(rootView.getContext()).inflate(R.layout.product_info_pincode_settings_card, pincode_section, true);

        final TextView textZipTitle = (TextView) view.findViewById(R.id.text_zip_title);
        textZipTitle.setText(pincodeSetting.getZipTitle());
        textZipTitle.setVisibility(View.VISIBLE);

        final TextView textZipNotFound = (TextView) view.findViewById(R.id.text_zip_not_found);
        textZipNotFound.setText(pincodeSetting.getZipNotFoundMessage());
        textZipNotFound.setVisibility(View.GONE);

        final TextView textZipAvailable = (TextView) view.findViewById(R.id.text_zip_available);
        textZipAvailable.setText("");
        textZipAvailable.setVisibility(View.GONE);

        final EditText editTextPinCode = (EditText) view.findViewById(R.id.edittext_pincode);
        editTextPinCode.setHint(getString(L.string.please_enter_pincode));
        editTextPinCode.setImeOptions(EditorInfo.IME_ACTION_DONE);
        editTextPinCode.setOnEditorActionListener(new EditText.OnEditorActionListener() {
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (actionId == EditorInfo.IME_ACTION_DONE) {
                    Helper.hideKeyboard(editTextPinCode);
                    return true;
                }
                return false;
            }
        });
        editTextPinCode.setVisibility(View.VISIBLE);
        Helper.stylize(editTextPinCode);

        final Button buttonCheckPinCode = (Button) view.findViewById(R.id.btn_check_pincode);
        buttonCheckPinCode.setText(pincodeSetting.getZipButtonText());
        Helper.styleRoundFlat(buttonCheckPinCode);
        buttonCheckPinCode.setVisibility(View.VISIBLE);

        final TextView textChangePinCode = (TextView) view.findViewById(R.id.text_change_pincode);
        textChangePinCode.setText(getString(L.string.change_pincode));
        textChangePinCode.setPaintFlags(textChangePinCode.getPaintFlags() | Paint.UNDERLINE_TEXT_FLAG);
        textChangePinCode.setVisibility(View.GONE);
        textChangePinCode.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                editTextPinCode.setVisibility(View.VISIBLE);
                buttonCheckPinCode.setVisibility(View.VISIBLE);
                textChangePinCode.setVisibility(View.GONE);
                textZipNotFound.setVisibility(View.GONE);
                textZipAvailable.setVisibility(View.GONE);
            }
        });

        buttonCheckPinCode.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                Helper.hideKeyboard(editTextPinCode);

                editTextPinCode.setVisibility(View.GONE);
                buttonCheckPinCode.setVisibility(View.GONE);
                textChangePinCode.setVisibility(View.VISIBLE);

                String pinCode = editTextPinCode.getText().toString();
                PincodeSetting.ZipSetting zipSetting = pincodeSetting.getZipSetting(pinCode);
                if (zipSetting != null) {
                    textZipNotFound.setVisibility(View.GONE);
                    textZipAvailable.setVisibility(View.VISIBLE);
                    textZipAvailable.setText(zipSetting.getMessage());
                } else {
                    textZipAvailable.setVisibility(View.GONE);
                    textZipNotFound.setVisibility(View.VISIBLE);
                }
            }
        });
    }

    public void goBack() {
        if (getFragmentManager().getBackStackEntryCount() > 0) {
            getFragmentManager().popBackStack();
        } else {
            MainActivity.mActivity.onNavigationDrawerItemSelected(Constants.MENU_ID_HOME, -1);
        }
    }
}