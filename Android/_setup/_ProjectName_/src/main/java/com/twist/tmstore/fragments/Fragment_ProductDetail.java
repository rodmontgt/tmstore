package com.twist.tmstore.fragments;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Point;
import android.graphics.PorterDuff;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.os.Build;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.preference.PreferenceManager;
import android.support.annotation.LayoutRes;
import android.support.design.widget.CoordinatorLayout;
import android.support.design.widget.TextInputLayout;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.FragmentManager;
import android.support.v4.content.ContextCompat;
import android.support.v4.content.res.ResourcesCompat;
import android.support.v4.graphics.drawable.DrawableCompat;
import android.support.v7.app.AlertDialog;
import android.support.v7.widget.CardView;
import android.support.v7.widget.RecyclerView;
import android.text.TextPaint;
import android.text.TextUtils;
import android.view.Display;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.inputmethod.EditorInfo;
import android.webkit.WebSettings.LayoutAlgorithm;
import android.webkit.WebView;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RatingBar;
import android.widget.RelativeLayout;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.animation.GlideAnimation;
import com.bumptech.glide.request.target.SimpleTarget;
import com.daimajia.slider.library.SliderLayout;
import com.daimajia.slider.library.SliderTypes.BaseSliderView;
import com.daimajia.slider.library.SliderTypes.DefaultSliderView;
import com.parse.FindCallback;
import com.parse.GetCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.parse.SaveCallback;
import com.shopgun.android.materialcolorcreator.Shade;
import com.twist.dataengine.DataEngine;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.entities.AuctionInfo;
import com.twist.dataengine.entities.PincodeSetting;
import com.twist.dataengine.entities.QuantityRule;
import com.twist.dataengine.entities.SellerInfo;
import com.twist.dataengine.entities.TM_Attribute;
import com.twist.dataengine.entities.TM_Bundle;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.dataengine.entities.TM_ProductReview;
import com.twist.dataengine.entities.TM_Variation;
import com.twist.dataengine.entities.TM_VariationAttribute;
import com.twist.dataengine.entities.TM_WaitList;
import com.twist.tmstore.BaseActivity;
import com.twist.tmstore.BuildConfig;
import com.twist.tmstore.Constants;
import com.twist.tmstore.Extras;
import com.twist.tmstore.L;
import com.twist.tmstore.ProductDetailActivity;
import com.twist.tmstore.ProductImagesActivity;
import com.twist.tmstore.ProductReviewActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.Adapter_BundledProduct;
import com.twist.tmstore.adapters.Adapter_MatchingProduct;
import com.twist.tmstore.adapters.Adapter_ProductReviewsList;
import com.twist.tmstore.adapters.Adapter_TrendingItems;
import com.twist.tmstore.adapters.Adapter_VariationStrings;
import com.twist.tmstore.adapters.Adapter_Variations;
import com.twist.tmstore.adapters.AttributeAdapter;
import com.twist.tmstore.adapters.PhoneNumberAdapter;
import com.twist.tmstore.config.ContactForm7Config;
import com.twist.tmstore.config.FreshChatConfig;
import com.twist.tmstore.config.GuestUserConfig;
import com.twist.tmstore.config.ImageDownloaderConfig;
import com.twist.tmstore.config.MultiVendorConfig;
import com.twist.tmstore.config.PinCodeSettingsConfig;
import com.twist.tmstore.config.ProductDetailsConfig;
import com.twist.tmstore.dialogs.ContactFormDialog;
import com.twist.tmstore.dialogs.WhatsappDialog;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.entities.Cart;
import com.twist.tmstore.entities.CartVariation;
import com.twist.tmstore.entities.DepositInfo;
import com.twist.tmstore.entities.ProductAddons;
import com.twist.tmstore.entities.RecentlyViewedItem;
import com.twist.tmstore.entities.WishListGroup;
import com.twist.tmstore.entities.Wishlist;
import com.twist.tmstore.listeners.CartEventListener;
import com.twist.tmstore.listeners.FragmentRefreshListener;
import com.twist.tmstore.listeners.OnAttributeOptionClickListener;
import com.twist.tmstore.listeners.OnFragmentPopListener;
import com.twist.tmstore.listeners.QuantityListener;
import com.twist.tmstore.listeners.ValueObserver;
import com.twist.tmstore.listeners.WishListDialogHandler;
import com.utils.AnalyticsHelper;
import com.utils.ArrayUtils;
import com.utils.CContext;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.ImageDownload;
import com.utils.JsonHelper;
import com.utils.ListUtils;
import com.utils.Log;
import com.utils.Preferences;
import com.utils.StringUtils;
import com.utils.customviews.ControllableCheckBox;
import com.utils.customviews.ObservableScrollView;
import com.utils.customviews.ScrollViewListener;
import com.utils.customviews.progressbar.CircleProgressBar;
import com.wdullaer.materialdatetimepicker.date.DatePickerDialog;

import org.json.JSONException;
import org.json.JSONObject;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Random;
import java.util.TimeZone;
import java.util.concurrent.TimeUnit;

import static com.twist.tmstore.L.getString;

public class Fragment_ProductDetail implements ScrollViewListener {

    private ObservableScrollView scroll_view;

    public void setFragmentRefreshListener(FragmentRefreshListener fragmentRefreshListener) {
        this.fragmentRefreshListener = fragmentRefreshListener;
    }

    private FragmentRefreshListener fragmentRefreshListener;
    private Fragment_Product_MapInfo fragment_product_mapInfo;
    private TM_ProductInfo product;

    private BaseActivity activity;

    public boolean mCanBuy;

    private boolean showAsDialog;

    private View product_vendor_profile_section;
    private View slider_layout;
    private View mBuyButtonSection;
    private View mCartButtonSection;
    private View ratings_section;
    private View reviews_section;
    private View mOpinionButtonSection;
    private View button_share_full_section;
    private LinearLayout mDetailsLayoutMain;

    private View img_desc_mask;
    private View section_upsell_products;
    private View section_related_products;
    private View section_best_deals;
    private View section_fresh_arrivals;
    private View section_trending_products;

    private LinearLayout mAdditionalInfoSection;
    private LinearLayout additional_info_attribute_section;

    private View mFullDescriptionSection;
    private RelativeLayout description_section;
    private TextView title_product_info;
    private RecyclerView recycler_related_products;
    private RecyclerView recycler_up_sales;
    private RecyclerView recycler_best_deals;
    private RecyclerView recycler_fresh_arrivals;
    private RecyclerView recycler_trending_products;

    private LinearLayout list_reviews;
    private LinearLayout layout_add_to_cart;
    private LinearLayout layout_wishlist;
    private LinearLayout buy_cart_sectionLayout;
    private LinearLayout buy_cart_section_bottomLayout;
    private LinearLayout cart_section_Overlay_footer;

    private View mRootView;
    private View mViewInflater;

    private TextView textTitle;
    private WebView textProductDesc;

    private TextView textProductSalePrice;
    private TextView textProductRegularPriceMRP;
    private TextView txt_discount;

    private TextView textShortDesc;
    private TextView textStockQty;
    private TextView txt_readmore_short_desc;
    private TextView textProductTitle;
    private TextView mProductPointsView;
    private TextView textLikes, textUnlikes;
    private TextView textBrandName;

    private ImageButton mShareButton;
    private ControllableCheckBox mCartButton;
    private ControllableCheckBox mWishListButton;

    private TextView textOutOfStock;
    private LinearLayout tagNewSale_section;
    private TextView text_saletag;
    private TextView text_newtag;

    private EditText editTextSelectDate;
    private TextView textSelectTime;
    private Spinner spinnerSelectTime;

    private Button btn_buy;
    private Button btn_ask_friend;
    private Button btn_share_full;
    private Button btn_load_comments;
    private Button mButtonAddToCart;

    private EditText mTextQuantity;

    private SliderLayout product_img_slider;
    private ProgressBar img_slider_progress_bar;

    private TextView toggle_desc;

    private ProgressBar progress_load_comments;

    private View variation_section_card;

    private TextView txt_rating;
    private RatingBar ratingBar1;

    private TextView title_average_user_ratings;
    private TextView title_reviews;
    private LinearLayout show_more_review_section;
    private TextView toggle_review_section;

    private ProgressDialog progressDialog;
    private CircleProgressBar progress_fulldata;

    private OnFragmentPopListener onFragmentPopListener = null;

    private CoordinatorLayout coordinatorLayout;

    private List<TM_ProductReview> productReviews = new ArrayList<>();

    private TM_Variation selected_variation;
    private Cart selected_cart;
    private List<TM_VariationAttribute> selected_variationAttributes = new ArrayList<>();

    private boolean preventButtonDisabling = true;
    private boolean lockButtonWhenRequired = true;

    private int mCartCount = 1;

    private QuantityListener mQuantityListener;

    private LinearLayout footer_cart;
    private RelativeLayout badge_section;
    private TextView txt_badgecount_cart;
    private ImageView icon_badge_cart;
    private TextView text_item_cart;
    private TextView text_total_cart;

    private boolean mQuantityRulesFetched = false;
    private Adapter_Variations adapterVariations;
    private AttributeAdapter adapterVariationsImages;
    private LinearLayout variationListLayout;
    private int considerableAttributeSize = 0;

    private LinearLayout expandable_description_section;
    private LinearLayout expandable_ratings_section;
    private LinearLayout expandable_reviews_section;

    private CardView cardViewAuction;
    private LinearLayout remaining_time_section;
    private TextView title_remaining_time;
    private LinearLayout remaining_time_counter_section;
    private TextView text_remaining_time_month;
    private TextView text_remaining_time_day;
    private TextView text_remaining_time_hours;
    private TextView text_remaining_time_min;
    private TextView text_remaining_time_sec;

    private LinearLayout auction_item_condition_section;
    private TextView text_item_condition;

    private LinearLayout auction_ends_section;
    private TextView text_auction_ends;

    private LinearLayout time_zone_section;
    private TextView text_time_zone;

    private LinearLayout current_bid_section;
    private TextView text_current_bid;

    private LinearLayout bid_button_section;
    private ImageButton btn_bid_qty_plus;
    private ImageButton btn_bid_qty_minus;
    private EditText edit_bid_quantity;
    private Button btn_bid;

    private LinearLayout auction_history_section;
    private TextView txt_auction_history_detail;
    private LinearLayout auction_history_list_section;


    private LinearLayout section_deposit_info;
    private TextView title_deposit_label;
    private TextView title_deposit_message;
    private Button btn_pay_deposit;
    private Button btn_pay_full;

    public String checkDeposit;

    private LinearLayout bookingLayout;
    private LinearLayout booking_info_date_section;
    private TextView txt_booking_date;
    private Button btn_check_booking_availability;
    private RelativeLayout booking_info_cost_section;
    private TextView title_booking_cost;
    private ProgressBar progress_bar_booking;
    private ControllableCheckBox btn_booking_wishlist;

    private boolean buyCartSectionIsVisible;

    private ProductDetailsConfig.QuickCartSectionConfig configQuickCart;

    private Adapter_MatchingProduct mAdapterMatchingProduct;

    public Fragment_ProductDetail(TM_ProductInfo product) {
        this.product = product;
        RecentlyViewedItem.create(this.product);
    }

    public Fragment_ProductDetail(TM_ProductInfo product, int variationId, int variationIndex, boolean canBuy) {
        this(product);
        this.selected_cart = Cart.findCart(product, variationId, variationIndex);
        this.mCanBuy = canBuy;
    }

    public void showProgress(final String msg) {
        showProgress(msg, true);
    }

    public void showProgress(final String msg, final boolean isCancellable) {
        activity.runOnUiThread(() -> {
            progressDialog.setMessage(msg);
            progressDialog.show();
            progressDialog.setCancelable(isCancellable);
        });
    }

    public void hideProgress() {
        progressDialog.dismiss();
    }

    public View onCreateView(final View rootView, final Activity activity, boolean isDialog) {
        this.mRootView = rootView;
        this.activity = (BaseActivity) activity;
        this.showAsDialog = isDialog;
        this.progressDialog = new ProgressDialog(activity);

        rootView.setFocusableInTouchMode(true);
        rootView.requestFocus();

        initComponents();
        showCartQuantityUI();
        updateTitleBar();
        updateProductImageSection();
        updateButtonSection();
        updateCommonDetailsAndPriceSection();
        updateAttributeSection();
        showNewTagSection();
        if (!showAsDialog) {
            updateProductShareSection();
            updateFullDescriptionSection();
            updateCommentSection();
            updatePollSection();
            updateFullShareSection();
            updatePollDataInBackground();
        } else {
            hideComponents();
        }
        showRuntimeSections();
        updateFullShareSection();
        showPinCodeLayout();
        updateUpSells();
        updateRelatedProducts();
        updateBestDeals();
        updateFreshArrivals();
        updateTrendingProducts();
        loadWaitListUI();
        loadBrandNames();
        loadPriceLabels();
        loadQuantityRule();
        loadMixMatchProducts();
        loadBundledProducts();
        loadPinCodeSettings();
        loadPRDDDeliveryInfo();
        showComponentByBackOrdersManagingStock();
        AnalyticsHelper.registerVisitProductEvent(product);
        return rootView;
    }

    @Override
    public void onBottomReached() {
        FreshChatConfig.showChatButton(activity, false);
    }

    private void initComponents() {
        coordinatorLayout = mRootView.findViewById(R.id.coordinatorLayout);
        scroll_view = mRootView.findViewById(R.id.scroll_view);
        scroll_view.setScrollViewListener(this);
        slider_layout = mRootView.findViewById(R.id.slider_layout);
        mOpinionButtonSection = mRootView.findViewById(R.id.button_opinion_section);
        button_share_full_section = mRootView.findViewById(R.id.button_share_full_section);
        int vendorLayoutId;
        if (MultiVendorConfig.isShowVendorLayoutCenter()) {
            vendorLayoutId = R.id.vendor_profile_card_center;
        } else {
            vendorLayoutId = R.id.vendor_profile_card;
        }

        initVendorProfileInfo(vendorLayoutId);

        buy_cart_sectionLayout = mRootView.findViewById(R.id.buy_cart_section);
        buy_cart_section_bottomLayout = mRootView.findViewById(R.id.buy_cart_section_bottom);
        buy_cart_sectionLayout.setVisibility(View.GONE);
        buy_cart_section_bottomLayout.setVisibility(View.GONE);

        /*To Show Buy Section Only*/

        if (AppInfo.mProductDetailsConfig.configBuyButton.enabled) {
            if (AppInfo.mProductDetailsConfig.configBuyButton.layoutPosition.equals(ProductDetailsConfig.LayoutPosition.BOTTOM)) {
                buy_cart_section_bottomLayout.setVisibility(View.VISIBLE);
                mViewInflater = LayoutInflater.from(activity).inflate(R.layout.fragment_product_buy_cart_section, buy_cart_section_bottomLayout, true);
            } else {
                buy_cart_sectionLayout.setVisibility(View.VISIBLE);
                mViewInflater = LayoutInflater.from(activity).inflate(R.layout.fragment_product_buy_cart_section, buy_cart_sectionLayout, true);
            }
            mBuyButtonSection = mViewInflater.findViewById(R.id.button_buy_section);
            mBuyButtonSection.setVisibility(View.VISIBLE);
            mBuyButtonSection.setBackground(Helper.getButtonSectionBorder());
            mCartButtonSection = mViewInflater.findViewById(R.id.button_cart_section);
            mCartButtonSection.setVisibility(View.GONE);
        } else {
            buy_cart_sectionLayout.setVisibility(View.VISIBLE);
            mViewInflater = LayoutInflater.from(activity).inflate(R.layout.fragment_product_buy_cart_section, buy_cart_sectionLayout, true);
            mCartButtonSection = mViewInflater.findViewById(R.id.button_cart_section);
            mCartButtonSection.setVisibility(View.GONE);
            mBuyButtonSection = mViewInflater.findViewById(R.id.button_buy_section);
            mBuyButtonSection.setVisibility(View.GONE);
        }

        // To Show Quick Cart Section Only
        configQuickCart = AppInfo.mProductDetailsConfig.configQuickCart;
        if (((configQuickCart != null && configQuickCart.enabled))) {
            if (configQuickCart.layoutPosition.equals(ProductDetailsConfig.LayoutPosition.BOTTOM)) {
                buy_cart_section_bottomLayout.setVisibility(View.VISIBLE);
                mViewInflater = LayoutInflater.from(activity).inflate(R.layout.fragment_product_buy_cart_section, buy_cart_section_bottomLayout, true);
            } else {
                buy_cart_sectionLayout.setVisibility(View.VISIBLE);
                mViewInflater = LayoutInflater.from(activity).inflate(R.layout.fragment_product_buy_cart_section, buy_cart_sectionLayout, true);
            }
            mCartButtonSection = mViewInflater.findViewById(R.id.button_cart_section);
            mCartButtonSection.setVisibility(View.VISIBLE);
            mBuyButtonSection = mViewInflater.findViewById(R.id.button_buy_section);
            mBuyButtonSection.setVisibility(View.GONE);
            mCartButtonSection.setBackground(Helper.getButtonSectionBorder());
        } else {
            buy_cart_sectionLayout.setVisibility(View.VISIBLE);
            mCartButtonSection.setVisibility(View.GONE);
        }

        buyCartSectionIsVisible = buy_cart_section_bottomLayout.getVisibility() != View.VISIBLE;

        if (AppInfo.SHOW_PRODUCTS_BOOKING_INFO && product.type == TM_ProductInfo.ProductType.BOOKING /*|| Cart.containsBookingProduct()*/) {
            buy_cart_sectionLayout.setVisibility(View.GONE);
            buy_cart_section_bottomLayout.setVisibility(View.GONE);
        }

        if (AppInfo.mProductDetailsConfig.show_opinion_section && AppInfo.ENABLE_OPINIONS) {
            mOpinionButtonSection.setVisibility(View.VISIBLE);
            mOpinionButtonSection.setBackground(Helper.getButtonSectionBorder());
        } else {
            mOpinionButtonSection.setVisibility(View.GONE);
        }

        if (AppInfo.mProductDetailsConfig.show_full_share_section) {
            button_share_full_section.setVisibility(View.VISIBLE);
            button_share_full_section.setBackground(Helper.getButtonSectionBorder());
            btn_share_full = mRootView.findViewById(R.id.btn_share_full);
            btn_share_full.setText(getString(L.string.share));
            Helper.styleFlat(btn_share_full);
        } else {
            button_share_full_section.setVisibility(View.GONE);
        }

        TextView textFreeDelivery = mRootView.findViewById(R.id.text_free_delivery);
        if (AppInfo.mProductDetailsConfig.show_buy_button_description) {
            textFreeDelivery.setText(getString(L.string.buy_button_description));
            textFreeDelivery.setVisibility(View.VISIBLE);
        } else {
            textFreeDelivery.setVisibility(View.GONE);
        }

        layout_add_to_cart = mViewInflater.findViewById(R.id.layout_add_to_cart);
        layout_wishlist = mViewInflater.findViewById(R.id.layout_wishlist);

        textTitle = mRootView.findViewById(R.id.text_page_title);
        textTitle.setBackgroundColor(Color.parseColor(AppInfo.color_theme));

        textProductSalePrice = mRootView.findViewById(R.id.text_product_price);
        Helper.stylizeSalePriceText(textProductSalePrice);

        textProductSalePrice.setText("");

        textOutOfStock = mRootView.findViewById(R.id.text_out_of_stock);
        Helper.stylizeActionText(textOutOfStock);
        textOutOfStock.setText(L.getString(L.string.out_of_stock));
        textOutOfStock.setVisibility(View.GONE);

        tagNewSale_section = mRootView.findViewById(R.id.sale_section);
        tagNewSale_section.setVisibility(View.GONE);
        text_saletag = mRootView.findViewById(R.id.text_saletag);
        text_newtag = mRootView.findViewById(R.id.text_newtag);

        Helper.stylizeActionText(text_saletag);
        text_saletag.setText(getString(L.string.sale_tag));
        text_saletag.setVisibility(View.GONE);

        Helper.stylizeActionText(text_newtag);
        text_newtag.setText(getString(L.string.new_tag));
        text_newtag.setVisibility(View.GONE);

        txt_discount = mRootView.findViewById(R.id.txt_discount);
        Helper.stylizeActionText(txt_discount);
        txt_discount.setVisibility(View.GONE);

        textProductRegularPriceMRP = mRootView.findViewById(R.id.text_product_mrp);
        Helper.stylizeRegularPriceText(textProductRegularPriceMRP);

        textProductRegularPriceMRP.setText("");
        textShortDesc = mRootView.findViewById(R.id.txt_name_desc_combo);
        textShortDesc.setText("");
        textStockQty = mRootView.findViewById(R.id.txt_stock_qty);
        textStockQty.setVisibility(View.GONE);
        txt_readmore_short_desc = mRootView.findViewById(R.id.text_show_more_short_desc);
        txt_readmore_short_desc.setVisibility(View.GONE);
        textProductTitle = mRootView.findViewById(R.id.text_product_title);
        textLikes = mRootView.findViewById(R.id.likes);
        textUnlikes = mRootView.findViewById(R.id.unlikes);

        textBrandName = mRootView.findViewById(R.id.text_brand_name);
        if (textBrandName != null) {
            textBrandName.setVisibility(View.GONE);
        }

        btn_buy = mViewInflater.findViewById(R.id.btn_buy);
        btn_buy.setText(getString(L.string.buy));
        Helper.styleFlat(btn_buy);

        mShareButton = mRootView.findViewById(R.id.btn_share);
        mCartButton = (ControllableCheckBox) mViewInflater.findViewById(R.id.btn_add_to_cart);
        Helper.setStyleWithDrawables(mCartButton, R.drawable.ic_vc_cart_unselected, R.drawable.ic_vc_cart_selected);

        if (AppInfo.mProductDetailsConfig.show_quantity_rules || (AppInfo.mProductDetailsConfig.configQuickCart != null && AppInfo.mProductDetailsConfig.configQuickCart.enabled)) {///|| AppInfo.mProductDetailsConfig.show_quick_cart_section
            mWishListButton = (ControllableCheckBox) mViewInflater.findViewById(R.id.btn_wishlist1);
        } else {
            mWishListButton = (ControllableCheckBox) mViewInflater.findViewById(R.id.btn_wishlist);
        }
        Helper.setStyleWithDrawables(mWishListButton, R.drawable.ic_vc_wish_border, R.drawable.ic_vc_wish_selected);

        btn_ask_friend = mRootView.findViewById(R.id.btn_poll);
        btn_ask_friend.setText(getString(L.string.title_poll));

        product_img_slider = (SliderLayout) mRootView.findViewById(R.id.product_img_slider);
        product_img_slider.stopAutoCycle();
        Helper.stylize(product_img_slider);

        img_slider_progress_bar = mRootView.findViewById(R.id.loading_bar);

        Display display = activity.getWindowManager().getDefaultDisplay();
        Point size = new Point();
        display.getSize(size);

        int windowHeight = (int) (AppInfo.PRODUCT_SLIDER_STANDARD_HEIGHT * size.x * AppInfo.mProductDetailsConfig.img_slider_height_ratio / AppInfo.PRODUCT_SLIDER_STANDARD_WIDTH);

        if (showAsDialog) {
            // Show slider image slightly smaller in dialog mode for better UX
            windowHeight = (int) ((float) windowHeight * 0.65f);
        }

        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, windowHeight);
        product_img_slider.setLayoutParams(params);

        ImageButton btn_zoom = mRootView.findViewById(R.id.btn_zoom);
        if (btn_zoom != null) {
            if (AppInfo.mProductDetailsConfig.show_zoom_button) {
                btn_zoom.setVisibility(View.VISIBLE);
                btn_zoom.setOnClickListener(view -> {
                    if (product_img_slider.getVisibility() == View.VISIBLE) {
                        final int position = product_img_slider.getCurrentPosition();
                        if (position >= 0) {
                            showFullScreenImage(position);
                        }
                    }
                });
                Helper.stylizeVector(btn_zoom);
            } else {
                btn_zoom.setVisibility(View.GONE);
            }
        }

        progress_fulldata = mRootView.findViewById(R.id.progress_fulldata);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Helper.stylize(progress_fulldata);
        } else {
            mRootView.findViewById(R.id.progress_fulldata).setVisibility(View.GONE);
        }
        progress_fulldata.setVisibility(View.GONE);

        variation_section_card = mRootView.findViewById(R.id.variation_section_card);
        variationListLayout = mRootView.findViewById(R.id.variationList);

        initComponentDetailSection();
        mProductPointsView = mRootView.findViewById(R.id.text_product_points);
        mProductPointsView.setVisibility(View.GONE);

        Helper.styleFlat(btn_ask_friend);
        Helper.stylizeVector(mShareButton);
        Helper.stylizeBtnSeparator(mRootView.findViewById(R.id.separator_1));
        Helper.stylizeBtnSeparator(mRootView.findViewById(R.id.separator_2));
        activity.setTextOnView(mRootView, R.id.txt_share_full, L.string.share_via_whatsapp);
        initAuctionInfo();

        initProductAddonsSection();
        initDepositInfoSection();
        initBookingInfoSection();

        showAdditionalInformationAttributeSection();
        initComponentsCartOverlayFooter(mRootView);
    }

    private void showAdditionalInformationAttributeSection() {
        mAdditionalInfoSection = mRootView.findViewById(R.id.additional_info_section);
        mAdditionalInfoSection.setVisibility(View.GONE);

        View view = LayoutInflater.from(activity).inflate(R.layout.product_info_addtional_info, mAdditionalInfoSection, true);
        additional_info_attribute_section = view.findViewById(R.id.additional_info_attribute_section);
        TextView title_additional_info = view.findViewById(R.id.title_additional_info);
        title_additional_info.setText(getString(L.string.title_additional_information));
    }

    private void initComponentDetailSection() {
        mDetailsLayoutMain = mRootView.findViewById(R.id.details_layout_main);
        final View view = LayoutInflater.from(activity).inflate(R.layout.product_info_details_card, mDetailsLayoutMain, true);

        mFullDescriptionSection = view.findViewById(R.id.full_description_section);
        description_section = view.findViewById(R.id.description_section);
        title_product_info = view.findViewById(R.id.title_product_info);
        title_product_info.setText(getString(L.string.title_product_info));
        textProductDesc = (WebView) view.findViewById(R.id.textProductDesc);
        img_desc_mask = view.findViewById(R.id.img_desc_mask);
        img_desc_mask.setVisibility(View.GONE);
        toggle_desc = view.findViewById(R.id.toggle_desc);
        toggle_desc.setText(getString(L.string.show_more));
        toggle_desc.setVisibility(View.GONE);

        ratings_section = view.findViewById(R.id.ratings_section);
        ratings_section.setVisibility(View.GONE);
        txt_rating = view.findViewById(R.id.txt_rating);
        ratingBar1 = (RatingBar) view.findViewById(R.id.ratingBar1);
        Helper.stylize(ratingBar1);

        title_average_user_ratings = view.findViewById(R.id.average_user_ratings);
        title_average_user_ratings.setText(getString(L.string.average_user_ratings));

        reviews_section = view.findViewById(R.id.reviews_section);
        reviews_section.setVisibility(View.GONE);
        title_reviews = view.findViewById(R.id.title_reviews);
        title_reviews.setText(getString(L.string.reviews));

        list_reviews = view.findViewById(R.id.list_reviews);
        progress_load_comments = view.findViewById(R.id.progress_load_comments);
        Helper.stylize(progress_load_comments);
        btn_load_comments = view.findViewById(R.id.btn_load_comments);
        btn_load_comments.setText(getString(L.string.load_comments));
        Helper.stylize(btn_load_comments);

        show_more_review_section = view.findViewById(R.id.show_more_review_section);
        show_more_review_section.setVisibility(View.GONE);
        toggle_review_section = view.findViewById(R.id.toggle_review_section);
        toggle_review_section.setText(getString(L.string.show_more));

        LinearLayout expandable_section_main = view.findViewById(R.id.expandable_section_main);
        expandable_section_main.setVisibility(View.GONE);
        if (AppInfo.mProductDetailsConfig.show_full_description_collapsed) {
            expandable_section_main.setVisibility(View.VISIBLE);
            expandable_description_section = addNewLinearLayout(expandable_section_main);
            ((ViewGroup) mFullDescriptionSection.getParent()).removeView(mFullDescriptionSection);
            final LinearLayout descSectionExpandableView = (LinearLayout) LayoutInflater.from(activity).inflate(R.layout.product_info_details_card_expandable, expandable_description_section, true);

            final RelativeLayout descExpandable = descSectionExpandableView.findViewById(R.id.expand_section);
            activity.setTextOnView(descSectionExpandableView, R.id.expand_title, L.string.title_product_info);
            final ImageView downArrowdescSection = descSectionExpandableView.findViewById(R.id.expand_img);

            descExpandable.setOnClickListener(v -> {
                if (mFullDescriptionSection.getParent() != descSectionExpandableView) {
                    descSectionExpandableView.addView(mFullDescriptionSection);
                    title_product_info.setVisibility(View.GONE);
                    downArrowdescSection.setImageDrawable(CContext.getDrawable(activity, R.drawable.ic_vc_up));
                } else {
                    ViewParent viewParent = mFullDescriptionSection.getParent();
                    if (viewParent != null) {
                        ((ViewGroup) viewParent).removeView(mFullDescriptionSection);
                        downArrowdescSection.setImageDrawable(CContext.getDrawable(activity, R.drawable.ic_vc_down));
                    }
                }
            });
        }

        if (AppInfo.mProductDetailsConfig.show_ratings_section_collapsed) {
            expandable_section_main.setVisibility(View.VISIBLE);
            expandable_ratings_section = addNewLinearLayout(expandable_section_main);
            ((ViewGroup) ratings_section.getParent()).removeView(ratings_section);
            final LinearLayout ratingsSectionExpandableView = (LinearLayout) LayoutInflater.from(activity).inflate(R.layout.product_info_details_card_expandable, expandable_ratings_section, true);
            final RelativeLayout ratingsExpandable = ratingsSectionExpandableView.findViewById(R.id.expand_section);
            final ImageView downArrowRatingsSection = ratingsSectionExpandableView.findViewById(R.id.expand_img);
            activity.setTextOnView(ratingsSectionExpandableView, R.id.expand_title, L.string.average_user_ratings);/*getString(L.string.average_user_ratings)*/
            ratingsExpandable.setOnClickListener(v -> {
                if (ratings_section.getParent() != ratingsSectionExpandableView) {
                    ratingsSectionExpandableView.addView(ratings_section);
                    title_average_user_ratings.setVisibility(View.GONE);
                    downArrowRatingsSection.setImageDrawable(CContext.getDrawable(activity, R.drawable.ic_vc_up));
                } else {
                    ViewParent viewParent = ratings_section.getParent();
                    if (viewParent != null) {
                        ((ViewGroup) viewParent).removeView(ratings_section);
                        downArrowRatingsSection.setImageDrawable(CContext.getDrawable(activity, R.drawable.ic_vc_down));
                    }
                }
            });
        }

        if (AppInfo.mProductDetailsConfig.show_reviews_section_collapsed) {
            expandable_section_main.setVisibility(View.VISIBLE);
            expandable_reviews_section = addNewLinearLayout(expandable_section_main);
            ((ViewGroup) reviews_section.getParent()).removeView(reviews_section);
            expandable_reviews_section.setVisibility(View.VISIBLE);
            final LinearLayout reviewsSectionExpandableView = (LinearLayout) LayoutInflater.from(activity).inflate(R.layout.product_info_details_card_expandable, expandable_reviews_section, true);

            final RelativeLayout reviewsExpandable = reviewsSectionExpandableView.findViewById(R.id.expand_section);
            final ImageView downArrowReviewsSection = reviewsSectionExpandableView.findViewById(R.id.expand_img);
            activity.setTextOnView(reviewsSectionExpandableView, R.id.expand_title, L.string.reviews);
            reviewsExpandable.setOnClickListener(v -> {
                if (reviews_section.getParent() != reviewsSectionExpandableView) {
                    reviewsSectionExpandableView.addView(reviews_section);
                    downArrowReviewsSection.setImageDrawable(CContext.getDrawable(activity, R.drawable.ic_vc_up));
                    title_reviews.setVisibility(View.GONE);
                } else {
                    ViewParent viewParent = reviews_section.getParent();
                    if (viewParent != null) {
                        ((ViewGroup) viewParent).removeView(reviews_section);
                        downArrowReviewsSection.setImageDrawable(CContext.getDrawable(activity, R.drawable.ic_vc_down));
                    }
                }
            });
        }

        section_upsell_products = view.findViewById(R.id.section_upsell_products);
        if (AppInfo.mProductDetailsConfig.show_upsell_section && AppInfo.SHOW_UPSELL_PRODUCTS) {
            section_upsell_products.setVisibility(View.VISIBLE);
        } else {
            section_upsell_products.setVisibility(View.GONE);
        }
        activity.setTextOnView(view, R.id.header_upsells_products, L.string.header_upsells_products);
        recycler_up_sales = (RecyclerView) view.findViewById(R.id.recycler_up_sales);


        section_related_products = view.findViewById(R.id.section_related_products);
        if (AppInfo.mProductDetailsConfig.show_related_section) {
            section_related_products.setVisibility(View.VISIBLE);
        } else {
            section_related_products.setVisibility(View.GONE);
        }
        activity.setTextOnView(view, R.id.header_related_products, L.string.header_related_products);
        recycler_related_products = (RecyclerView) view.findViewById(R.id.recycler_related_products);


        section_best_deals = view.findViewById(R.id.section_best_deals);
        if (AppInfo.mProductDetailsConfig.show_best_deals_section) {
            section_best_deals.setVisibility(View.VISIBLE);
        } else {
            section_best_deals.setVisibility(View.GONE);
        }
        activity.setTextOnView(view, R.id.header_best_deals, L.string.header_best_deals);
        recycler_best_deals = (RecyclerView) view.findViewById(R.id.recycler_best_deals);


        section_fresh_arrivals = view.findViewById(R.id.section_fresh_arrivals);
        if (AppInfo.mProductDetailsConfig.show_fresh_arrivals_section) {
            section_fresh_arrivals.setVisibility(View.VISIBLE);
        } else {
            section_fresh_arrivals.setVisibility(View.GONE);
        }
        activity.setTextOnView(view, R.id.header_fresh_arrivals, L.string.header_fresh_arrival);
        recycler_fresh_arrivals = view.findViewById(R.id.recycler_fresh_arrivals);


        section_trending_products = view.findViewById(R.id.section_trending_products);
        if (AppInfo.mProductDetailsConfig.show_trending_section) {
            section_trending_products.setVisibility(View.VISIBLE);
        } else {
            section_trending_products.setVisibility(View.GONE);
        }
        activity.setTextOnView(view, R.id.header_trending_products, L.string.header_related_products);
        recycler_trending_products = view.findViewById(R.id.recycler_trending_products);

    }

    public LinearLayout addNewLinearLayout(LinearLayout layout) {
        LinearLayout linearLayout = new LinearLayout(activity);
        linearLayout.setOrientation(LinearLayout.VERTICAL);
        LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        layoutParams.setMargins(10, 8, 10, 10);
        layout.addView(linearLayout, layoutParams);
        return linearLayout;
    }

    private void initComponentsCartOverlayFooter(View rootView) {
        cart_section_Overlay_footer = rootView.findViewById(R.id.cart_section_overlay_footer);
        if (AppInfo.SHOW_CART_FOOTER_OVERLAY) {
            cart_section_Overlay_footer.setVisibility(View.VISIBLE);
            View mCartOverlayView = LayoutInflater.from(activity).inflate(R.layout.overlay_footer_cart, cart_section_Overlay_footer, true);
            footer_cart = mCartOverlayView.findViewById(R.id.footer_cart);
            footer_cart.setVisibility(View.VISIBLE);
            footer_cart.setBackgroundColor(Color.parseColor(AppInfo.normal_button_color));

            badge_section = mCartOverlayView.findViewById(R.id.badge_section);
            ImageView main_icon = mCartOverlayView.findViewById(R.id.main_icon);
            main_icon.setColorFilter(Color.parseColor(AppInfo.normal_button_text_color), PorterDuff.Mode.SRC_IN);
            txt_badgecount_cart = mCartOverlayView.findViewById(R.id.text_badge_count);
            icon_badge_cart = mCartOverlayView.findViewById(R.id.icon_badge);
            Helper.stylizeBadgeView(icon_badge_cart, txt_badgecount_cart);
            ImageView icon_forward_arrow = mCartOverlayView.findViewById(R.id.icon_forward_arrow);
            icon_forward_arrow.setColorFilter(Color.parseColor(AppInfo.normal_button_text_color), PorterDuff.Mode.SRC_IN);

            View btn_panel_separator = mCartOverlayView.findViewById(R.id.btn_panel_separator);
            btn_panel_separator.setBackgroundColor(Color.parseColor(AppInfo.normal_button_text_color));
            TextView label_item_cart = mCartOverlayView.findViewById(R.id.label_item_cart);
            label_item_cart.setText(getString(L.string.label_item_cart_overlay));
            label_item_cart.setTextColor(Color.parseColor(AppInfo.normal_button_text_color));
            TextView label_total_cart = mCartOverlayView.findViewById(R.id.label_total_cart);
            label_total_cart.setText(getString(L.string.label_total_cart_overlay));
            label_total_cart.setTextColor(Color.parseColor(AppInfo.normal_button_text_color));

            text_item_cart = mCartOverlayView.findViewById(R.id.text_item_cart);
            text_item_cart.setTextColor(Color.parseColor(AppInfo.normal_button_text_color));
            text_total_cart = mCartOverlayView.findViewById(R.id.text_total_cart);
            text_total_cart.setTextColor(Color.parseColor(AppInfo.normal_button_text_color));

            badge_section.setVisibility(View.GONE);
            text_item_cart.setText("0");
            text_total_cart.setText("0");

            updateCartBadgeCount();

            Cart.setCartEventListener(new CartEventListener() {
                @Override
                public void onItemAdded(Cart cartItem) {
                    updateCartBadgeCount();
                }

                @Override
                public void onItemUpdated(Cart cartItem) {
                    updateCartBadgeCount();
                }

                @Override
                public void onItemRemoved() {
                    updateCartBadgeCount();
                }
            });
        } else {
            cart_section_Overlay_footer.setVisibility(View.GONE);
        }
    }

    int DP(int measure) {
        return Helper.DP(measure, activity.getResources());
    }

    private void hideComponents() {
        if (showAsDialog) {
            mShareButton.setVisibility(View.GONE);
            mOpinionButtonSection.setVisibility(View.GONE);
            mDetailsLayoutMain.setVisibility(View.GONE);
            textProductTitle.setVisibility(View.GONE);
        }
    }

    private void updateTitleBar() {
        if (showAsDialog) {
            textTitle.setVisibility(View.VISIBLE);
            textTitle.setText(HtmlCompat.fromHtml(product.title));
        } else {
            textTitle.setVisibility(View.GONE);
            activity.setTitleText(product.title);
        }
    }

    private void updateProductShareSection() {
        if (mShareButton != null) {
            if (AppInfo.mProductDetailsConfig.show_share_button) {
                mShareButton.setVisibility(View.VISIBLE);
                mShareButton.setOnClickListener(v -> shareProductWithFriends());
            } else {
                mShareButton.setVisibility(View.GONE);
            }
        }
    }

    private void updateProductImageSection() {
        if (!AppInfo.mProductDetailsConfig.show_top_section) {
            if (slider_layout != null) {
                slider_layout.setVisibility(View.GONE);
            }
            return;
        }
        product_img_slider.setVisibility(AppInfo.mProductDetailsConfig.show_image_slider ? View.VISIBLE : View.GONE);
        updateSliderImages(product.getImageUrls());
    }

    private void updateRelatedProducts() {
        if (!AppInfo.mProductDetailsConfig.show_related_section || !product.full_data_loaded) {
            section_related_products.setVisibility(View.GONE);
            return;
        }

        List<TM_ProductInfo> relatedProducts = this.product.getRelatedProducts();
        if (relatedProducts != null && !relatedProducts.isEmpty()) {
            section_related_products.setVisibility(View.VISIBLE);
            Adapter_TrendingItems adapter = new Adapter_TrendingItems(activity, relatedProducts, view -> {
            });
            recycler_related_products.setAdapter(adapter);
        } else {
            section_related_products.setVisibility(View.GONE);
        }
    }

    private void updateUpSells() {
        if (!AppInfo.mProductDetailsConfig.show_upsell_section || !AppInfo.SHOW_UPSELL_PRODUCTS || !product.full_data_loaded)
            return;

        List<TM_ProductInfo> upSellProducts = this.product.getUpSellProducts();
        if (upSellProducts != null && !upSellProducts.isEmpty()) {
            section_upsell_products.setVisibility(View.VISIBLE);
            Adapter_TrendingItems adapter = new Adapter_TrendingItems(activity, upSellProducts, view -> {
            });
            recycler_up_sales.setAdapter(adapter);
        } else {
            section_upsell_products.setVisibility(View.GONE);
        }
    }

    private void updateBestDeals() {
        if (!AppInfo.mProductDetailsConfig.show_best_deals_section || !product.full_data_loaded)
            return;

        List<TM_ProductInfo> relatedProducts = TM_ProductInfo.getBestDeals(AppInfo.MAX_ITEMS_COUNT_HOME);
        if (relatedProducts != null && !relatedProducts.isEmpty()) {
            section_best_deals.setVisibility(View.VISIBLE);
            Adapter_TrendingItems adapter = new Adapter_TrendingItems(activity, relatedProducts, view -> {
            });
            recycler_best_deals.setAdapter(adapter);
        } else {
            section_best_deals.setVisibility(View.GONE);
        }
    }

    private void updateFreshArrivals() {
        if (!AppInfo.mProductDetailsConfig.show_fresh_arrivals_section || !product.full_data_loaded)
            return;

        List<TM_ProductInfo> relatedProducts = TM_ProductInfo.getFreshArrivals(AppInfo.MAX_ITEMS_COUNT_HOME);
        if (relatedProducts != null && !relatedProducts.isEmpty()) {
            section_fresh_arrivals.setVisibility(View.VISIBLE);
            Adapter_TrendingItems adapter = new Adapter_TrendingItems(activity, relatedProducts, view -> {
            });
            recycler_fresh_arrivals.setAdapter(adapter);
        } else {
            section_fresh_arrivals.setVisibility(View.GONE);
        }
    }

    private void updateTrendingProducts() {
        if (!AppInfo.mProductDetailsConfig.show_trending_section || !product.full_data_loaded)
            return;

        List<TM_ProductInfo> relatedProducts = TM_ProductInfo.getTrending(AppInfo.MAX_ITEMS_COUNT_HOME);
        if (relatedProducts != null && !relatedProducts.isEmpty()) {
            section_trending_products.setVisibility(View.VISIBLE);
            Adapter_TrendingItems adapter = new Adapter_TrendingItems(activity, relatedProducts, view -> {
            });
            recycler_trending_products.setAdapter(adapter);
        } else {
            section_trending_products.setVisibility(View.GONE);
        }
    }

    private void updateCommonDetailsAndPriceSection() {
        if (AppInfo.mProductDetailsConfig.show_product_title) {
            textProductTitle.setVisibility(View.VISIBLE);
            textProductTitle.setText(HtmlCompat.fromHtml(product.title));
        } else {
            textProductTitle.setVisibility(View.GONE);
        }

        if (AppInfo.mProductDetailsConfig.show_combo_section) {
            textShortDesc.setVisibility(View.VISIBLE);
            if (!product.full_data_loaded) {
                int maxLinesShortDesc = AppInfo.mProductDetailsConfig.product_short_desc_max_line != 0 ? AppInfo.mProductDetailsConfig.product_short_desc_max_line : 2;
                textShortDesc.setMaxLines(maxLinesShortDesc);
            } else {
                textShortDesc.setMaxLines(Integer.MAX_VALUE);
            }
            String comboString = product.getShortDescription();
            //int maxLineCount = Helper.setTextAndGetLineCount(textShortDesc, comboString, textShortDesc.getLayoutParams().width);
            textShortDesc.setText(HtmlCompat.fromHtml(comboString));

            // Spanned string converts html <p> paragraphs into \n newline, hence ended up adding extra new lines wasting layout space.
            String text = textShortDesc.getText().toString();
            try {
                while (text.lastIndexOf("\n") == text.length() - 1) {
                    text = text.substring(0, text.length() - 2);
                }
            } catch (Exception ignored) {
            }
            textShortDesc.setText(HtmlCompat.fromHtml(text));
            if (TextUtils.isEmpty(text)) {
                textShortDesc.setVisibility(View.GONE);
                txt_readmore_short_desc.setVisibility(View.GONE);
            }
        } else {
            textShortDesc.setVisibility(View.GONE);
            txt_readmore_short_desc.setVisibility(View.GONE);
        }

        if (product.managing_stock && product.backorders_allowed && product.in_stock && product.stockQty > 0){
            textStockQty.setVisibility(View.VISIBLE);
            textStockQty.setText(HtmlCompat.fromHtml(String.format(Locale.getDefault(), L.getString(L.string.product_stock_quantity), product.stockQty)));
        } else {
            textStockQty.setVisibility(View.GONE);
        }

        //reconsiderShowMoreFeature();

        //textProductSalePrice.setText(HtmlCompat.fromHtml(Helper.appendCurrency(realSellingPrice)));
        updateProductPriceWithoutSelectedVariation();

        if (!AppInfo.mProductDetailsConfig.show_price || AppInfo.HIDE_PRODUCT_PRICE_TAG || GuestUserConfig.hidePriceTag()) {
            textProductSalePrice.setVisibility(View.GONE);
            textProductRegularPriceMRP.setVisibility(View.GONE);
            return;
        }

        float realSellingPrice = product.getActualPrice();
        if (realSellingPrice < product.regular_price) {
            textProductRegularPriceMRP.setVisibility(View.VISIBLE);
            if (AppInfo.SHOW_MIN_MAX_PRICE && product.type == TM_ProductInfo.ProductType.VARIABLE) {
                textProductRegularPriceMRP.setVisibility(View.GONE);
            }
            textProductRegularPriceMRP.setPaintFlags(textProductRegularPriceMRP.getPaintFlags() | Paint.STRIKE_THRU_TEXT_FLAG);
            textProductRegularPriceMRP.setText(HtmlCompat.fromHtml(Helper.appendCurrency(product.regular_price, product)));
            if (AppInfo.SHOW_DISCOUNT_PERCENTAGE_ON_PRODUCTS) {
                txt_discount.setVisibility(View.VISIBLE);
                txt_discount.setText("-" + product.getDiscountPercentage() + "%");
            } else {
                txt_discount.setVisibility(View.GONE);
            }
            if (AppInfo.SHOW_SALE_PRODUCT_TAG) {
                tagNewSale_section.setVisibility(View.VISIBLE);
                text_saletag.setVisibility(View.VISIBLE);
                text_newtag.setVisibility(View.GONE);
            } else {
                tagNewSale_section.setVisibility(View.GONE);
                text_saletag.setVisibility(View.GONE);
            }
        } else {
            textProductRegularPriceMRP.setVisibility(View.GONE);
            if (realSellingPrice == product.regular_price) {
                textProductSalePrice.setVisibility(View.VISIBLE);
                textProductSalePrice.setText(HtmlCompat.fromHtml(Helper.appendCurrency(realSellingPrice, product)));
            }
            txt_discount.setVisibility(View.GONE);
            tagNewSale_section.setVisibility(View.GONE);
            text_saletag.setVisibility(View.GONE);
        }
    }

    private void showNewTagSection() {
        if (AppInfo.SHOW_NEW_PRODUCT_TAG && Helper.getDaysDifference(product.created_at) < AppInfo.NEW_PRODUCT_DAYS_LIMIT) {
            tagNewSale_section.setVisibility(View.VISIBLE);
            text_saletag.setVisibility(View.GONE);
            text_newtag.setVisibility(View.VISIBLE);
        } else {
            tagNewSale_section.setVisibility(View.GONE);
        }
    }

    // Create And Set Product Variation / Attributes
    private void updateAttributeSection() {
        if (!AppInfo.mProductDetailsConfig.show_variation_section) {
            variation_section_card.setVisibility(View.GONE);
            return;
        }
        if (mCanBuy) {
            if (product.variations.size() > 0 || (product.attributes.size() > 0 && AppInfo.SHOW_NON_VARIATION_ATTRIBUTE)) {
                variation_section_card.setVisibility(View.VISIBLE);
                considerableAttributeSize = 0;
                if (AppInfo.AUTO_SELECT_VARIATION) {
                    for (TM_Attribute attribute : product.attributes) {
                        if (attribute.variation && !attribute.options.isEmpty()) {
                            TM_VariationAttribute variationAttribute = attribute.getVariationAttribute(0);
                            variationAttribute.extraPrice = attribute.getAdditionalPrice(variationAttribute.value);
                            selected_variationAttributes.add(variationAttribute);
                            considerableAttributeSize++;
                        }
                    }
                } else {
                    for (TM_Attribute attribute : product.attributes) {
                        if (attribute.variation && !attribute.options.isEmpty()) {
                            considerableAttributeSize++;
                        }
                    }
                }

                if (selected_variationAttributes.size() > 0 || AppInfo.AUTO_SELECT_VARIATION) {
                    selected_variation = product.variations.findVariationWithAttributes(selected_variationAttributes);
                    if (selected_variation == null && product.variations.size() > 0) {
                        //selected_variation = product.variations.get(0);
                        Helper.toast(coordinatorLayout, L.string.variation_out_of_stock);
                    }
                }

                OnAttributeOptionClickListener onAttributeOptionClickListener = new OnAttributeOptionClickListener() {
                    @Override
                    public void onClick(int id, int index) {
                        //selected_attributes.get(id).index = index;
                        //Log.d("updating value of : [" + selected_variationAttributes.get(id).name + "]:[" + selected_variationAttributes.get(id).value + "] --");
                        TM_Attribute selected_attribute = product.attributes.get(id);
                        //double additional_price = selected_attribute.additional_price;
                        if (selected_attribute.variation && !selected_attribute.options.isEmpty()) {
                            String value = selected_attribute.options.get(index);
                            // patch for space in options name
                            if (value != null) {
                                if (value.contains(" ")) {
                                    value = value.replace(" ", "-");
                                }
                                if (value.contains("/")) {
                                    value = value.replace("/", "");
                                }
                            }

                            if (AppInfo.AUTO_SELECT_VARIATION) {
                                for (TM_VariationAttribute variationAttribute : selected_variationAttributes) {
                                    //if (variationAttribute.slug.equals(selected_attribute.slug)) {
                                    if (variationAttribute.id.equals(selected_attribute.id)) {
                                        variationAttribute.value = value;
                                        variationAttribute.extraPrice = selected_attribute.getAdditionalPrice(value);
                                        break;
                                    }
                                }
                            } else {
                                boolean alreadyHasThisAttribute = false;
                                for (TM_VariationAttribute tva : selected_variationAttributes) {
                                    //if (tva.name.equals(selected_attribute.name)) {
                                    if (tva.id.equals(selected_attribute.id)) {
                                        alreadyHasThisAttribute = true;
                                        tva.value = value;
                                        tva.extraPrice = selected_attribute.getAdditionalPrice(value);
                                        break;
                                    }
                                }
                                if (!alreadyHasThisAttribute) {
                                    float extraPrice = selected_attribute.getAdditionalPrice(value);
                                    selected_variationAttributes.add(new TM_VariationAttribute(selected_attribute.id, selected_attribute.name, selected_attribute.slug, value, extraPrice));
                                }
                            }
                            //selected_variationAttributes.get(id).value = value;
                            if (selected_variationAttributes.size() >= considerableAttributeSize) {
                                selected_variation = product.variations.findVariationWithAttributes(selected_variationAttributes);
                                if (selected_variation == null && product.variations.size() > 0) {
                                    //selected_variation = product.variations.get(0);
                                    Helper.toast(coordinatorLayout, L.string.variation_out_of_stock);
                                }
                                updateButtonStateWithAttributes();
                                updateProductImagesWithSelectedVariation();
                                updateProductPriceWithSelectedVariation();
                                updateQuickCartInfo();
                                showComponentByBackOrdersManagingStock();
                            } else if (!AppInfo.AUTO_SELECT_VARIATION) {
                                updateProductPriceWithSelectedVariation();
                            }
                        }
                    }
                };

                if (AppInfo.mProductDetailsConfig.show_awesome_attribute_options) {
                    CardView cardView = (CardView) variation_section_card;
                    cardView.setUseCompatPadding(false);
                    cardView.setCardElevation(0);
                    adapterVariationsImages = new AttributeAdapter(activity, product.attributes);
                    adapterVariationsImages.setOptionSelectionListener(onAttributeOptionClickListener);
                    variationListLayout.removeAllViewsInLayout();
                    variationListLayout.setOrientation(LinearLayout.VERTICAL);
                    for (int i = 0; i < adapterVariationsImages.getItemCount(); i++) {
                        AttributeAdapter.AttributeViewHolder holder = adapterVariationsImages.onCreateViewHolder(variationListLayout, adapterVariationsImages.getItemViewType(i));
                        adapterVariationsImages.onBindViewHolder(holder, i);
                        variationListLayout.addView(holder.itemView);
                    }
                } else {
                    adapterVariations = new Adapter_Variations(product.attributes);
                    adapterVariations.setOptionSelectionListener(onAttributeOptionClickListener);
                    variationListLayout.removeAllViewsInLayout();
                    for (int i = 0; i < adapterVariations.getItemCount(); i++) {
                        Adapter_Variations.ViewHolder holder = adapterVariations.onCreateViewHolder(variationListLayout, adapterVariations.getItemViewType(i));
                        adapterVariations.onBindViewHolder(holder, i);
                        variationListLayout.addView(holder.itemView);
                    }
                }
            }
            showReadOnlyAttributeOptionsSection();
        } else {
            if (selected_cart != null && !selected_cart.attributes.isEmpty()) {
                List<String> attributeStrings = CartVariation.getAttributeStringList(selected_cart.attributes);
                Adapter_VariationStrings variationsAdapter = new Adapter_VariationStrings(attributeStrings, R.layout.item_spinner, R.id.text1);
                variationListLayout.removeAllViewsInLayout();
                for (int i = 0; i < variationsAdapter.getItemCount(); i++) {
                    Adapter_VariationStrings.ViewHolder holder = variationsAdapter.onCreateViewHolder(variationListLayout, variationsAdapter.getItemViewType(i));
                    variationsAdapter.onBindViewHolder(holder, i);
                    variationListLayout.addView(holder.itemView);
                }
            } else {
                variation_section_card.setVisibility(View.GONE);
            }
        }
    }

    private void updateButtonSection() {
        if (this.mCanBuy && (AppInfo.mProductDetailsConfig.configBuyButton != null && AppInfo.mProductDetailsConfig.configBuyButton.enabled)) {
            int selected_variation_id = selected_variation != null ? selected_variation.id : -1;
            int selected_variation_index = selected_variation != null ? selected_variation.index : -1;
            mCartButton.setChecked(Cart.hasItem(product, selected_variation_id, selected_variation_index), false);

            btn_buy.setOnClickListener(v -> buyProduct());

            if (AppInfo.ENABLE_WISHLIST) {
                mWishListButton.setVisibility(View.VISIBLE);
                mWishListButton.setChecked(Wishlist.hasItem(product), false);

                layout_wishlist.setVisibility(View.VISIBLE);
                btn_buy.setEnabled(preventButtonDisabling);
                mCartButton.setEnabled(preventButtonDisabling);

                mWishListButton.setEnabled(preventButtonDisabling);

                if (!preventButtonDisabling) {
                    btn_buy.setText(getString(L.string.loading_product_details));
                }
            } else {
                layout_wishlist.setVisibility(View.GONE);
                mWishListButton.setVisibility(View.GONE);
            }

            if (lockButtonWhenRequired) {
                if (!product.full_data_loaded) {
                    disableBuySection(getString(L.string.buy));
                } else if (!product.in_stock) {
                    enableOutOfStockSection(getString(L.string.out_of_stock));
                } else if (selected_variation != null) {
                    if (selected_variation.managing_stock) {
                        if (!selected_variation.backorders_allowed && !selected_variation.in_stock) {
                            enableOutOfStockSection(getString(L.string.out_of_stock));
                        } else {
                            enableBuySection(getString(L.string.buy));
                        }
                    } else {
                        if (!selected_variation.in_stock) {
                            enableOutOfStockSection(getString(L.string.out_of_stock));
                        } else {
                            enableBuySection(getString(L.string.buy));
                            textOutOfStock.setVisibility(View.GONE);
                            if (!AppInfo.mProductDetailsConfig.show_price || AppInfo.HIDE_PRODUCT_PRICE_TAG || GuestUserConfig.hidePriceTag()) {
                                textProductSalePrice.setVisibility(View.GONE);
                                textProductRegularPriceMRP.setVisibility(View.GONE);
                            } else {
                                textProductSalePrice.setVisibility(View.VISIBLE);
                                textProductSalePrice.setText(HtmlCompat.fromHtml(Helper.appendCurrency(product.getActualPrice(), product)));
                            }
                        }
                    }
                } else {
                    layout_add_to_cart.setClickable(true);
                    enableBuySection(getString(L.string.buy));
                }
            }

            if (!AppInfo.ENABLE_CART || !GuestUserConfig.isEnableCart()) {
                mCartButton.setVisibility(View.GONE);
                layout_add_to_cart.setVisibility(View.GONE);
                layout_wishlist.setVisibility(View.GONE);
                mWishListButton.setVisibility(View.GONE);
                if (AppInfo.ENABLE_WISHLIST) {
                    btn_buy.setClickable(true);
                    btn_buy.setText(getString(L.string.add_to_wishlist));
                    btn_buy.setOnClickListener(view -> addToWishList());
                } else {
                    buy_cart_sectionLayout.setVisibility(View.GONE);
                    buy_cart_section_bottomLayout.setVisibility(View.GONE);
                }
            }
        } else {
            mBuyButtonSection.setVisibility(View.GONE);
        }

        if (AppInfo.SHOW_PRODUCTS_BOOKING_INFO && product.type == TM_ProductInfo.ProductType.BOOKING /*|| Cart.containsBookingProduct()*/) {
            buy_cart_sectionLayout.setVisibility(View.GONE);
            buy_cart_section_bottomLayout.setVisibility(View.GONE);
        }

        if (!product.full_data_loaded) {
            loadProductInformation();
        } else if (DataEngine.load_extra_attrib_data && !product.extra_attribs_loaded) {
            loadExtraAttributesData();
        } else {
            showRewardPoints();
        }
    }

    private void updatePollSection() {
        if (!AppInfo.ENABLE_OPINIONS)
            return;

        btn_ask_friend.setOnClickListener(v -> {
            final SharedPreferences pf = PreferenceManager.getDefaultSharedPreferences(activity);
            final int count = pf.getInt("PollCount", 0);
            if (count < 3) {
                final WhatsappDialog alert = new WhatsappDialog();
                alert.showDialog(activity, getString(L.string.whatsapp_tutorial), true, v1 -> {
                    pf.edit().putInt("PollCount", count + 1).apply();
                    createOrFetchPoll();
                });
            } else {
                createOrFetchPoll();
            }
        });
        updatePollSectionTexts();
    }

    private void updateFullShareSection() {
        if (button_share_full_section.getVisibility() == View.VISIBLE) {
            btn_share_full.setOnClickListener(v -> shareProductOnWhatsApp());
        }
    }

    public void shareProductOnWhatsApp() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (ContextCompat.checkSelfPermission(activity, Manifest.permission.WRITE_EXTERNAL_STORAGE) != 0) {
                ActivityCompat.requestPermissions(activity, new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE}, 2);
                return;
            }
        }

        Glide.with(activity)
                .load(product.getFirstImageUrl())
                .asBitmap()
                .error(R.drawable.placeholder_product)
                .into(new SimpleTarget<Bitmap>() {
                    @Override
                    public void onResourceReady(Bitmap bitmap, GlideAnimation<? super Bitmap> glideAnimation) {
                        shareProductOnWhatsApp(bitmap);
                    }

                    @Override
                    public void onLoadFailed(Exception e, Drawable errorDrawable) {
                        Bitmap bitmap = ((BitmapDrawable) errorDrawable).getBitmap();
                        shareProductOnWhatsApp(bitmap);
                    }
                });
    }

    private void updatePollSectionTexts() {
        textLikes.setText(String.valueOf(Math.max(product.likes, 0)));
        textUnlikes.setText(String.valueOf(Math.max(product.unlikes, 0)));

        if (product.likes > 0) {
            textLikes.setTextColor(CContext.getColor(activity, R.color.highlight_text_color_2));
        }

        if (product.unlikes > 0) {
            textUnlikes.setTextColor(CContext.getColor(activity, R.color.highlight_text_color));
        }
    }

    private void updatePollDataInBackground() {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("PollData");
        query.whereEqualTo("product_id", product.id + "");
        query.whereEqualTo("user_id", ParseUser.getCurrentUser());
        query.getFirstInBackground(new GetCallback<ParseObject>() {
            @Override
            public void done(ParseObject pollObject, ParseException e) {
                if (e == null && pollObject != null) {
                    try {
                        product.likes = pollObject.getInt("likes");
                        product.unlikes = pollObject.getInt("unlikes");
                        updatePollSectionTexts();
                    } catch (IllegalStateException ex) {
                        ex.printStackTrace();
                    }
                }
            }
        });
    }

    @SuppressLint("SetJavaScriptEnabled")
    private void updateFullDescriptionSection() {
        if (!AppInfo.mProductDetailsConfig.show_details_section) {
            mDetailsLayoutMain.setVisibility(View.GONE);
            return;
        }
        if (AppInfo.mProductDetailsConfig.show_full_description) {
            mFullDescriptionSection.setVisibility(View.VISIBLE);
            if (product.hasDescription()) {
                textProductDesc.setVisibility(View.VISIBLE);
                textProductDesc.getSettings().setDefaultTextEncodingName("utf-8");
                textProductDesc.getSettings().setDefaultFontSize(12);
                textProductDesc.getSettings().setJavaScriptEnabled(true);
                textProductDesc.getSettings().setLayoutAlgorithm(LayoutAlgorithm.SINGLE_COLUMN);
                textProductDesc.loadDataWithBaseURL(
                        null,
                        Helper.appendDiv(product.getDescription(), CContext.getColor(activity, R.color.white), CContext.getColor(activity, R.color.normal_text_color)),
                        "text/html",
                        "UTF-8",
                        null
                );
                coordinatorLayout.requestLayout(); // because, when layout finish.the webview reload content. The contentHeight is consistent with measureHeight
                description_section.requestLayout();
                textProductDesc.addOnLayoutChangeListener(new View.OnLayoutChangeListener() {
                    @Override
                    public void onLayoutChange(View v, int left, int top, int right, int bottom, int oldLeft, int oldTop, int oldRight, int oldBottom) {
                        textProductDesc.removeOnLayoutChangeListener(this);
                        reconsiderShowMoreFeature();
                    }
                });
            } else {
                //String summary = Helper.appendDiv(getString(L.string.not_available), CContext.getColor(activity, R.color.white), CContext.getColor(activity, R.color.normal_text_color));
                //textProductDesc.loadDataWithBaseURL(null, summary, "text/html; charset=utf-8", "utf-8", null);
                mFullDescriptionSection.setVisibility(View.GONE);
            }
        } else {
            mFullDescriptionSection.setVisibility(View.GONE);
        }
    }

    private void reconsiderShowMoreFeature() {
        if (!product.full_data_loaded || !AppInfo.mProductDetailsConfig.show_show_more)
            return;

        if (AppInfo.mProductDetailsConfig.show_short_desc && AppInfo.mProductDetailsConfig.show_combo_section) {
            textShortDesc.post(() -> {
                if (TextUtils.isEmpty(textShortDesc.getText())) {
                    textShortDesc.setVisibility(View.GONE);
                    txt_readmore_short_desc.setVisibility(View.GONE);
                    return;
                }
                textShortDesc.setVisibility(View.VISIBLE);
                final int maxLinesShortDesc = AppInfo.mProductDetailsConfig.product_short_desc_max_line != 0 ? AppInfo.mProductDetailsConfig.product_short_desc_max_line : 2;
                textShortDesc.setMaxLines(Integer.MAX_VALUE);
                final int numLinesShortDesc = textShortDesc.getLineCount();
                textShortDesc.setMaxLines(maxLinesShortDesc);
                collapseShortDescription(maxLinesShortDesc);
                if (numLinesShortDesc > maxLinesShortDesc) {
                    final String strShowMore = getString(L.string.show_more);
                    txt_readmore_short_desc.setVisibility(View.VISIBLE);
                    txt_readmore_short_desc.setOnClickListener(v -> {
                        if (txt_readmore_short_desc.getText().toString().equalsIgnoreCase(strShowMore)) {
                            expandShortDescription(numLinesShortDesc);
                        } else {
                            collapseShortDescription(maxLinesShortDesc);
                        }
                    });
                } else {
                    txt_readmore_short_desc.setVisibility(View.GONE);
                }
            });
        } else {
            textShortDesc.setVisibility(View.GONE);
            txt_readmore_short_desc.setVisibility(View.GONE);
        }

        if (AppInfo.mProductDetailsConfig.show_full_description) {
            description_section.post(() -> {
                //final int descHeight = Helper.DP(description_section.getMeasuredHeight(), description_section.getResources());
                final int descHeight = description_section.getMeasuredHeight();
                final int minimumHeight = (int) description_section.getResources().getDimension(R.dimen.desc_section_min_collapse_height); // Helper.DP(100, description_section.getResources());
                final String strShowMore = getString(L.string.show_more);
                //final String strShowLess = description_section.getResources().getString(L.string.txt_product_desc_less);
                if (descHeight > minimumHeight) {
                    toggle_desc.setVisibility(View.VISIBLE);
                    collapseFullDescription(minimumHeight);
                    toggle_desc.setOnClickListener(v -> {
                        if (toggle_desc.getText().toString().equalsIgnoreCase(strShowMore)) {
                            expandFullDescription(descHeight);
                        } else {
                            collapseFullDescription(minimumHeight);
                        }
                    });
                } else {
                    toggle_desc.setVisibility(View.GONE);
                    img_desc_mask.setVisibility(View.GONE);
                }
            });
        }
    }

    private void collapseShortDescription(int lines) {
        textShortDesc.setMaxLines(lines);
        txt_readmore_short_desc.setText(getString(L.string.show_more));
    }

    private void expandShortDescription(int lines) {
        textShortDesc.setMaxLines(lines);
        txt_readmore_short_desc.setText(getString(L.string.show_less));
    }

    private void collapseFullDescription(int height) {
        description_section.getLayoutParams().height = height;
        img_desc_mask.setVisibility(View.VISIBLE);
        description_section.requestLayout();
        toggle_desc.setText(getString(L.string.show_more));
    }

    private void expandFullDescription(int height) {
        description_section.getLayoutParams().height = height;
        img_desc_mask.setVisibility(View.GONE);
        description_section.requestLayout();
        toggle_desc.setText(getString(L.string.show_less));
    }

    private void updateCommentSection() {
        Log.d("-- product.rating_count: [" + product.rating_count + "] --");
        //btn_load_comments.setVisibility(View.VISIBLE);
        //progress_load_comments.setVisibility(View.GONE);
        //ratings_section.setVisibility(View.GONE);

        if (AppInfo.mProductDetailsConfig.show_ratings_section) {
            ratings_section.setVisibility(View.VISIBLE);
            if (product.average_rating > 0) {
                ratingBar1.setVisibility(View.VISIBLE);
                txt_rating.setVisibility(View.VISIBLE);
                ratingBar1.setRating(product.average_rating);
                //ratingBar1.setEnabled(false);
                ratingBar1.setFocusable(false);

                txt_rating.setText(product.average_rating + "/5.0");
            } else {
                ratingBar1.setVisibility(View.GONE);
                //txt_rating.setVisibility(View.GONE);
                txt_rating.setVisibility(View.VISIBLE);
                txt_rating.setText(getString(L.string.ratings_not_available));
            }
        } else {
            ratings_section.setVisibility(View.GONE);
        }

        if (AppInfo.mProductDetailsConfig.show_reviews_section && product.reviews_allowed) {
            reviews_section.setVisibility(View.VISIBLE);
            if (product.rating_count > 0) {
                btn_load_comments.setOnClickListener(v -> loadComments());
                loadComments();
            } else {
                Log.d("-- This product has no review --");
                btn_load_comments.setVisibility(View.GONE);
                progress_load_comments.setVisibility(View.GONE);
                reviews_section.setVisibility(View.VISIBLE);
                Adapter_ProductReviewsList productReviewAdapter = new Adapter_ProductReviewsList(activity, productReviews);
                list_reviews.removeAllViewsInLayout();
                for (int i = 0; i < productReviewAdapter.getCount(); i++) {
                    if (i == 2) {
                        show_more_review_section.setVisibility(View.VISIBLE);
                        break;
                    }
                    View v = productReviewAdapter.getView(i, null, null);
                    list_reviews.addView(v, new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT));
                }
            }
        } else {
            btn_load_comments.setVisibility(View.GONE);
            progress_load_comments.setVisibility(View.GONE);
            reviews_section.setVisibility(View.GONE);
        }


        if (ratings_section.getVisibility() == View.VISIBLE) {
            ratings_section.setOnClickListener(v -> {
                Intent intent = new Intent(activity, ProductReviewActivity.class);
                intent.putExtra(Extras.PRODUCT_ID, product.id);
                activity.startActivity(intent);
            });
        }

        if (reviews_section.getVisibility() == View.VISIBLE) {
            reviews_section.setOnClickListener(v -> ((ProductDetailActivity) activity).openReviewRatingList(product, productReviews));
        }
    }

    private void loadProductInformation() {
        if (product.type == TM_ProductInfo.ProductType.EXTERNAL) {
            return;
        }
        progress_fulldata.setVisibility(View.VISIBLE);
        DataEngine.getDataEngine().getProductInfoInBackground(product.id, new DataQueryHandler<TM_ProductInfo>() {
                    @Override
                    public void onSuccess(TM_ProductInfo data) {
                        product = data;
                        productIsReadyNow();
                    }

                    @Override
                    public void onFailure(Exception reason) {
                        reason.printStackTrace();
                        Helper.showToast(coordinatorLayout, reason.getMessage());
                        progress_fulldata.setVisibility(View.GONE);
                    }
                }
        );
    }

    private void loadExtraAttributesData() {
        progress_fulldata.setVisibility(View.VISIBLE);
        DataEngine.getDataEngine().getExtraAttributesDataInBackground(product, new DataQueryHandler<TM_ProductInfo>() {
                    @Override
                    public void onSuccess(TM_ProductInfo data) {
                        product = data;
                        productIsReadyNow();
                    }

                    @Override
                    public void onFailure(Exception reason) {
                        reason.printStackTrace();
                        progress_fulldata.setVisibility(View.GONE);
                    }
                }
        );
    }

    private void productIsReadyNow() {
        if (!AppInfo.AUTO_SELECT_VARIATION || product.attributes.isEmpty()) {
            updateProductImageSection();
        }
        updateCommonDetailsAndPriceSection();
        updateAttributeSection();
        updateButtonSection();
        showRuntimeSections();
        updateFullDescriptionSection();
        updateCommentSection();
        chkAndRefreshWishList();
        updateUpSells();
        updateRelatedProducts();
        updateBestDeals();
        updateFreshArrivals();
        updateTrendingProducts();
        loadRewardPoints();
        loadMixMatchProducts();
        loadBundledProducts();
        loadPinCodeSettings();
        updateAuctionSection();
        showProductAddonsSection();
        updateDepositInfoSection();
        updateBookingInfoSection();
        showComponentByBackOrdersManagingStock();
        progress_fulldata.setVisibility(View.GONE);
    }

    private void chkAndRefreshWishList() {
        new Thread(() -> {
            try {
                if (Wishlist.hasItem(product)) {
                    Wishlist.refresh();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }).start();
    }

    private void loadComments() {
        productReviews.clear();
        btn_load_comments.setVisibility(View.GONE);
        progress_load_comments.setVisibility(View.VISIBLE);
        //ratings_section.setVisibility(View.GONE);

        DataEngine.getDataEngine().getCommentOnProductInBackground(product.id, new DataQueryHandler<List<TM_ProductReview>>() {
            @Override
            public void onSuccess(final List<TM_ProductReview> data) {
                productReviews = data;
                Adapter_ProductReviewsList productReviewAdapter = new Adapter_ProductReviewsList(activity, productReviews);

                progress_load_comments.setVisibility(View.GONE);
                //ratings_section.setVisibility(View.VISIBLE);

                list_reviews.removeAllViewsInLayout();
                for (int i = 0; i < productReviewAdapter.getCount(); i++) {
                    if (i == 2) {
                        show_more_review_section.setVisibility(View.VISIBLE);
                        break;
                    }
                    View v = productReviewAdapter.getView(i, null, null);
                    list_reviews.addView(v, new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT));
                }
            }

            @Override
            public void onFailure(Exception exception) {
                btn_load_comments.setVisibility(View.VISIBLE);
                progress_load_comments.setVisibility(View.GONE);
                //ratings_section.setVisibility(View.GONE);
            }
        });
    }

    private void updateButtonStateWithAttributes() {
        int selected_variation_id = selected_variation != null ? selected_variation.id : -1;
        int selected_variation_index = selected_variation != null ? selected_variation.index : -1;
        mCartButton.setChecked(Cart.hasItem(product, selected_variation_id, selected_variation_index), false);
        if (lockButtonWhenRequired) {
            if (!product.full_data_loaded) {
                disableBuySection(getString(L.string.buy));
            } else if (!product.in_stock) {
                enableOutOfStockSection(getString(L.string.out_of_stock));
            } else if (selected_variation != null) {
                if (selected_variation.managing_stock) {
                    if (!selected_variation.backorders_allowed && !selected_variation.in_stock) {
                        enableOutOfStockSection(getString(L.string.out_of_stock));
                    } else {
                        enableBuySection(getString(L.string.buy));
                    }
                } else {
                    if (!selected_variation.in_stock) {
                        enableOutOfStockSection(getString(L.string.out_of_stock));
                    } else {
                        enableBuySection(getString(L.string.buy));
                        textOutOfStock.setVisibility(View.GONE);
                        if (!AppInfo.mProductDetailsConfig.show_price || AppInfo.HIDE_PRODUCT_PRICE_TAG || GuestUserConfig.hidePriceTag()) {
                            textProductSalePrice.setVisibility(View.GONE);
                            textProductRegularPriceMRP.setVisibility(View.GONE);
                        } else {
                            textProductSalePrice.setVisibility(View.VISIBLE);
                            textProductSalePrice.setText(HtmlCompat.fromHtml(Helper.appendCurrency(product.getActualPrice(), product)));
                        }
                    }
                }
            } else {
                layout_add_to_cart.setClickable(true);
                enableBuySection(getString(L.string.buy));
            }

            if (!AppInfo.ENABLE_CART || !GuestUserConfig.isEnableCart()) {
                btn_buy.setText(getString(L.string.add_to_wishlist));
            }
        }
    }

    private void enableOutOfStockSection(String text_btn_buy) {
        mCartButton.setClickable(false);
        btn_buy.setClickable(false);
        btn_buy.setText(text_btn_buy);
        textOutOfStock.setVisibility(View.VISIBLE);
        tagNewSale_section.setVisibility(View.GONE);
    }

    private void enableBuySection(String text_btn_buy) {
        mCartButton.setClickable(true);
        btn_buy.setClickable(true);
        btn_buy.setText(text_btn_buy);
        textOutOfStock.setVisibility(View.GONE);
    }

    private void disableBuySection(String text_btn_buy) {
        mCartButton.setClickable(false);
        btn_buy.setClickable(false);
        btn_buy.setText(text_btn_buy);
    }

    public void updateButtonStateWithProductInfo() {
        if (product.in_stock) {
            btn_buy.setEnabled(true);
            mCartButton.setEnabled(true);
            layout_add_to_cart.setEnabled(true);
            mWishListButton.setEnabled(true);
            layout_wishlist.setEnabled(true);
            if (!preventButtonDisabling) {
                btn_buy.setText(getString(L.string.buy));
            }
            updateButtonStateWithAttributes();
        } else {
            btn_buy.setEnabled(preventButtonDisabling);
            mCartButton.setEnabled(preventButtonDisabling);
            layout_add_to_cart.setEnabled(preventButtonDisabling);
            mWishListButton.setEnabled(preventButtonDisabling);
            layout_wishlist.setEnabled(preventButtonDisabling);
            if (!preventButtonDisabling) {
                btn_buy.setText(getString(L.string.out_of_stock));
                textOutOfStock.setVisibility(View.VISIBLE);//Need to check
                tagNewSale_section.setVisibility(View.GONE);
            }
        }
    }

    private void updateProductImagesWithSelectedVariation() {
        if (selected_variation != null && selected_variation.id >= 0) {
            if (!selected_variation.images.isEmpty()) {
                updateSliderImages(selected_variation.getImageUrls());
            }
        } else {
            updateSliderImages(product.getImageUrls());
        }
    }

    private void updateSliderImages(String[] imageUrls) {
        final int count = product_img_slider.getSlidesCount();
        if (count > 0 && product.type != TM_ProductInfo.ProductType.VARIABLE) {
            styleSliderProgressIndicators();
            return;
        }

        if (!ArrayUtils.containsNull(imageUrls)) {
            product_img_slider.removeAllSliders();
            product_img_slider.setPresetTransformer(SliderLayout.Transformer.Fade);
            for (int i = 0; i < imageUrls.length; i++) {
                addNewSlider(i, imageUrls[i].replace("https", "http"));
            }
            product_img_slider.setPresetTransformer(SliderLayout.Transformer.Default);
        }
        styleSliderProgressIndicators();
    }

    private void styleSliderProgressIndicators() {
        Helper.stylize(product_img_slider);
        Helper.stylize(img_slider_progress_bar);
    }

    private void addNewSlider(final int index, final String img_url) {
        if (!TextUtils.isEmpty(img_url)) {
            DefaultSliderView sliderView = new DefaultSliderView(activity);
            if (AppInfo.mProductDetailsConfig.show_image_loading_bar) {
                sliderView.setShowProgress(true);
            } else {
                img_slider_progress_bar.setVisibility(View.GONE);
            }
            sliderView.description("").image(img_url).empty(AppInfo.ID_PLACEHOLDER_BANNER).setScaleType(BaseSliderView.ScaleType.CenterInside);
            sliderView.getBundle().putString("extra", img_url);
            sliderView.setOnImageLoadListener(new BaseSliderView.ImageLoadListener() {
                @Override
                public void onStart(BaseSliderView target) {
                    Helper.stylize(target.getProgressBar());
                }

                @Override
                public void onEnd(boolean result, BaseSliderView target) {
                    Helper.stylize(target.getProgressBar());
                }
            });
            sliderView.setOnSliderClickListener(new BaseSliderView.OnSliderClickListener() {
                @Override
                public void onSliderClick(BaseSliderView slider) {
                    showFullScreenImage(index);
                }
            });
            product_img_slider.addSlider(index, sliderView);
            Helper.stylize(sliderView.getProgressBar());
        } else {
            img_slider_progress_bar.setVisibility(View.GONE);
        }
    }

    private void showFullScreenImage(int index) {
        Intent i = new Intent(activity, ProductImagesActivity.class);
        i.putExtra(Extras.PRODUCT_ID, product.id);
        i.putExtra(Extras.PRODUCT_IMAGE_INDEX, index);
        activity.startActivity(i);
    }

    private void updateProductPriceWithoutSelectedVariation() {
        float realSellingPrice = product.getActualPrice();

        if (AppInfo.HIDE_PRODUCT_PRICE_TAG || GuestUserConfig.hidePriceTag()) {
            textProductSalePrice.setVisibility(View.GONE);
            textProductRegularPriceMRP.setVisibility(View.GONE);
            return;
        }

        if (realSellingPrice > 0) {
            if (AppInfo.SHOW_MIN_MAX_PRICE && product.type == TM_ProductInfo.ProductType.VARIABLE) {
                textProductRegularPriceMRP.setVisibility(View.GONE);
                textProductSalePrice.setVisibility(View.VISIBLE);
                if (product.hasPriceRange()) {
                    textProductSalePrice.setText(HtmlCompat.fromHtml(Helper.appendCurrency(product.price_min) + " - " + Helper.appendCurrency(product.price_max)));
                } else {
                    textProductSalePrice.setText(HtmlCompat.fromHtml(Helper.appendCurrency(realSellingPrice, product)));
                }
            } else {
                if (AppInfo.SHOW_MIN_MAX_PRICE && product.type == TM_ProductInfo.ProductType.VARIABLE && product.price_min != 0.00 && product.price_max != 0.00 && product.hasPriceRange()) {
                    textProductSalePrice.setText(HtmlCompat.fromHtml(Helper.appendCurrency(product.price_min) + " - " + Helper.appendCurrency(product.price_max)));
                } else {
                    textProductSalePrice.setText(HtmlCompat.fromHtml(Helper.appendCurrency(realSellingPrice, product)));
                }
            }
        } else {
            textProductSalePrice.setVisibility(View.VISIBLE);
            textProductSalePrice.setText(HtmlCompat.fromHtml(Helper.appendCurrency(realSellingPrice, product)));
        }
    }

    private void updateProductPriceWithSelectedVariation() {
        if (!AppInfo.mProductDetailsConfig.show_price || AppInfo.HIDE_PRODUCT_PRICE_TAG || GuestUserConfig.hidePriceTag()) {
            textProductSalePrice.setVisibility(View.GONE);
            textProductRegularPriceMRP.setVisibility(View.GONE);
            return;
        }

        if (AppInfo.AUTO_SELECT_VARIATION) {
            if (selected_variation == null) {
                updateProductPriceWithoutSelectedVariation();
                return;
            }

            if (selected_variation.managing_stock) {
                if (!selected_variation.backorders_allowed && !selected_variation.in_stock) {
                    textProductSalePrice.setText(getString(L.string.out_of_stock));
                    textProductRegularPriceMRP.setVisibility(View.GONE);
                    textOutOfStock.setVisibility(View.VISIBLE);
                    tagNewSale_section.setVisibility(View.GONE);
                }
            } else {
                if (!selected_variation.in_stock) {
                    textProductSalePrice.setText(getString(L.string.out_of_stock));
                    textProductRegularPriceMRP.setVisibility(View.GONE);
                    textOutOfStock.setVisibility(View.VISIBLE);
                    tagNewSale_section.setVisibility(View.GONE);
                }
            }

            float realSellingPrice = selected_variation.getActualPrice();

            if (!selected_variationAttributes.isEmpty()) {
                for (TM_VariationAttribute a : selected_variationAttributes) {
                    TM_Attribute tempAttribute = product.getAttributeWithName(a.name);
                    if (tempAttribute != null) {
                        float extraPrice = tempAttribute.getAdditionalPrice(a.value);
                        realSellingPrice += extraPrice;
                        break;
                    }
                }
            }

            textProductSalePrice.setText(HtmlCompat.fromHtml(Helper.appendCurrency(realSellingPrice, product)));

            if (realSellingPrice < selected_variation.regular_price) {
                textProductRegularPriceMRP.setVisibility(View.VISIBLE);
                if (AppInfo.SHOW_MIN_MAX_PRICE && product.type == TM_ProductInfo.ProductType.VARIABLE) {
                    textProductRegularPriceMRP.setVisibility(View.GONE);
                }
                textProductRegularPriceMRP.setPaintFlags(textProductRegularPriceMRP.getPaintFlags() | Paint.STRIKE_THRU_TEXT_FLAG);
                textProductRegularPriceMRP.setText(HtmlCompat.fromHtml(Helper.appendCurrency(selected_variation.regular_price, product)));
            } else {
                textProductRegularPriceMRP.setVisibility(View.GONE);
            }
        } else {
            float realSellingPrice = 0;
            if (selected_variation != null) {
                realSellingPrice = product.getActualPrice(selected_variation.id);
            } else {
                realSellingPrice = product.getActualPrice();
            }

            if (!selected_variationAttributes.isEmpty()) {
                for (TM_VariationAttribute a : selected_variationAttributes) {
                    TM_Attribute tempAttribute = product.getAttributeWithName(a.name);
                    if (tempAttribute != null) {
                        float extraPrice = tempAttribute.getAdditionalPrice(a.value);
                        realSellingPrice += extraPrice;
                    }
                }
            }

            textProductSalePrice.setText(HtmlCompat.fromHtml(Helper.appendCurrency(realSellingPrice, product)));

            if (realSellingPrice < product.regular_price) {
                textProductRegularPriceMRP.setVisibility(View.VISIBLE);
                if (AppInfo.SHOW_MIN_MAX_PRICE && product.type == TM_ProductInfo.ProductType.VARIABLE) {
                    textProductRegularPriceMRP.setVisibility(View.GONE);
                }
                textProductRegularPriceMRP.setPaintFlags(textProductRegularPriceMRP.getPaintFlags() | Paint.STRIKE_THRU_TEXT_FLAG);
                textProductRegularPriceMRP.setText(HtmlCompat.fromHtml(Helper.appendCurrency(product.regular_price, product)));
            } else {
                textProductRegularPriceMRP.setVisibility(View.GONE);
            }
        }
    }

    private void updateQuickCartInfo() {
        if ((AppInfo.mProductDetailsConfig.configQuickCart != null && AppInfo.mProductDetailsConfig.configQuickCart.enabled) || AppInfo.mProductDetailsConfig.show_quantity_rules) {
            if (selected_variation != null) {
                Cart cart = Cart.findCart(product.id, selected_variation.id, selected_variation.index);
                if (cart != null) {
                    mCartCount = cart.count;
                    mButtonAddToCart.setText(getString(L.string.view_cart));
                    mButtonAddToCart.setOnClickListener(mViewCartListener);
                } else {
                    mCartCount = 1;
                    mButtonAddToCart.setText(getString(L.string.add_to_cart));
                    mButtonAddToCart.setOnClickListener(mAddToCartListener);
                }
                mTextQuantity.setText(String.valueOf(mCartCount));
            }
        }
    }

    private void buyProduct() {
        if (addToCart(1) && onFragmentPopListener != null) {
            onFragmentPopListener.onFragmentPoped(OnFragmentPopListener.CODE_BUY);
        }
    }

    private boolean addToCart(int count) {
        if (!product.full_data_loaded || progress_fulldata.getVisibility() == View.VISIBLE) {
            Helper.toast(coordinatorLayout, L.string.loading_variations);
            return false;
        }

        if (AppInfo.ENABLE_PRODUCT_DELIVERY_DATE) {
            if (TextUtils.isEmpty(product.selectedDeliveryDate)) {
                Helper.toast(coordinatorLayout, L.string.select_delivery_date);
                return false;
            }

            if (TextUtils.isEmpty(product.selectedDeliveryTime)) {
                Helper.toast(coordinatorLayout, L.string.select_delivery_time);
                return false;
            }
        }

        if (AppInfo.SHOW_PRODUCTS_BOOKING_INFO && product.type == TM_ProductInfo.ProductType.BOOKING /*|| Cart.containsBookingProduct()*/) {
            String strDate = txt_booking_date.getText().toString();
            try {
                DateFormat sdf = new SimpleDateFormat("MM/dd/yyyy");
                sdf.parse(strDate);
            } catch (Exception e) {
                e.printStackTrace();
                Helper.toast(coordinatorLayout, L.string.toast_error_msg_select_booking_date);
                return false;
            }
        }

        if (AppInfo.ENABLE_PRODUCT_ADDONS && product.productAddons != null && !ListUtils.isEmpty(productAddonsTextFields)) {
            ProductAddons.GroupAddon groupAddon = product.productAddons.group_addon[0];
            for (int k = 0; k < productAddonsTextFields.size(); k++) {
                EditText editText = productAddonsTextFields.get(k);
                ProductAddons.GroupAddon.Option option = groupAddon.options[k];
                option.value = editText.getText().toString();
                if (TextUtils.isEmpty(option.value) && option.required) {
                    editText.setError(getString(L.string.error_option_is_required));
                    editText.requestFocus();
                    return false;
                }
            }
        }

        if (AppInfo.ENABLE_DEPOSIT_ADDONS && product.depositInfo != null && TextUtils.isEmpty(product.depositInfo.checkCartDepositType)) {

        }

        if (product.managing_stock) {
            if (!product.backorders_allowed && !product.in_stock) {
                Helper.toast(coordinatorLayout, L.string.product_out_of_stock);
                return false;
            }
        } else if (!product.in_stock) {
            Helper.toast(coordinatorLayout, L.string.product_out_of_stock);
            return false;
        }

        if (AppInfo.ENABLE_BUNDLED_PRODUCTS) {
            if (product.type == TM_ProductInfo.ProductType.BUNDLE || product.type == TM_ProductInfo.ProductType.BUNDLE_YITH) {
                for (TM_Bundle tm_bundle : product.mBundles) {
                    TM_ProductInfo product = tm_bundle.getProduct();
                    if (product.managing_stock) {
                        if (!product.in_stock) {
                            Helper.toast(coordinatorLayout, L.string.bundle_product_out_of_stock);
                            return false;
                        }
                    } else if (!product.in_stock) {
                        Helper.toast(coordinatorLayout, L.string.bundle_product_out_of_stock);
                        return false;
                    }
                }
            }
        }

        if (!AppInfo.ENABLE_ZERO_PRICE_ORDER) {
            if (product.getActualPrice() <= 0) {
                Helper.toast(coordinatorLayout, L.string.product_not_for_sale);
                return false;
            }
        }

        int selected_variation_id = selected_variation != null ? selected_variation.id : -1;
        int selected_variation_index = selected_variation != null ? selected_variation.index : -1;

        if ((AppInfo.mProductDetailsConfig.configQuickCart != null && AppInfo.mProductDetailsConfig.configQuickCart.enabled) || AppInfo.mProductDetailsConfig.show_quantity_rules) {
            if (selected_cart != null) {
                selected_variation_id = selected_cart.selected_variation_id;
                selected_variation = product.variations.getVariation(selected_variation_id);
            }
        }

        if (product.variations.size() > 0) { //&& product.attributes.size() > 0) {
            if (selected_variation_id < 0) {
                Helper.toast(coordinatorLayout, L.string.select_a_variation_first);
                for (TM_Attribute attribute : product.attributes) {
                    for (TM_VariationAttribute variationAttribute : selected_variationAttributes) {
                        //if (variationAttribute.slug.equals(attribute.slug)) {
                        if (variationAttribute.id.equals(attribute.id)) {
                            break;
                        }
                    }
                }
                //adapterVariations.promptSpinner(promptIndex);
                return false;
            }

            if (selected_variation.managing_stock) {
                if (!selected_variation.backorders_allowed && !selected_variation.in_stock) {
                    Helper.toast(coordinatorLayout, L.string.variation_out_of_stock);
                    return false;
                }
            } else {
                if (!selected_variation.in_stock) {
                    Helper.toast(coordinatorLayout, L.string.variation_out_of_stock);
                    return false;
                }
            }

            if (!AppInfo.ENABLE_ZERO_PRICE_ORDER && selected_variation.getActualPrice() <= 0) {
                Helper.toast(coordinatorLayout, L.string.variation_not_for_sale);
                return false;
            }

            if (Log.DEBUG) {
                Log.d("====== selected_variation =====");
                Log.d("  id1: [" + selected_variation_id + "]  ");
                Log.d("  id2: [" + selected_variation.id + "]  ");
                Log.d("  attr str: [" + selected_variation.getAttributeString() + "]  ");
                List<TM_VariationAttribute> temps = selected_variation.attributes;
                int i = 0;
                for (TM_VariationAttribute temp : temps) {
                    Log.d("- [" + i + "] " + temp.name + " = " + temp.value + " -");
                }
            }
        } else {
            if (!AppInfo.ENABLE_ZERO_PRICE_ORDER) {
                if (product.type == TM_ProductInfo.ProductType.MIXNMATCH && mAdapterMatchingProduct != null) {
                    int selectedCount = mAdapterMatchingProduct.getSelectedItemsCount();
                    int requiredCount = (int) product.mMixMatch.getContainerSize();
                    boolean error = true;
                    if (selectedCount != 0 && (requiredCount == 0 || requiredCount == selectedCount)) {
                        error = false;
                    }

                    if (requiredCount == 0) {
                        requiredCount = 1;
                    }

                    if (error) {
                        String message = String.format(Locale.getDefault(), getString(L.string.header_mixmatch_products), requiredCount);
                        Helper.showToast(coordinatorLayout, message);
                        mCartButton.setChecked(false, false);
                        return false;
                    }
                    if (!AppInfo.ENABLE_ZERO_PRICE_ORDER) {
                        if (product.getActualPrice() <= 0) {
                            Helper.toast(coordinatorLayout, L.string.product_not_for_sale);
                            return false;
                        }
                    }

                    Map<TM_ProductInfo, Integer> matchedItems = mAdapterMatchingProduct.getSelectedItems();
                    if (Cart.addProduct(product, selected_variation_id, selected_variation_index, count, selected_variationAttributes, matchedItems)) {
                        if (fragmentRefreshListener != null) {
                            fragmentRefreshListener.onFragmentRefreshed();
                        }
                        return true;
                    }
                    mCartButton.setChecked(false, false);
                    return false;
                } else {
                    if (product.getActualPrice() <= 0) {
                        Helper.toast(coordinatorLayout, L.string.product_not_for_sale);
                        return false;
                    }
                }
            }
        }

        // clear all cart products for booking product TODO uncomment product if enable multiple product in cart.
        if (AppInfo.SHOW_PRODUCTS_BOOKING_INFO /*&& product.type == TM_ProductInfo.ProductType.BOOKING*/ && Cart.containsBookingProduct(/*product*/)) {
            Cart.clearCart();
        }

        if (!Cart.addProduct(product, selected_variation_id, selected_variation_index, count, selected_variationAttributes)) {
            mCartButton.setChecked(false, false);
        }

        if (fragmentRefreshListener != null) {
            fragmentRefreshListener.onFragmentRefreshed();
        }
        return true;
    }

    private void removeFromCart() {
        int selected_variation_id = selected_variation != null ? selected_variation.id : -1;
        int selected_variation_index = selected_variation != null ? selected_variation.index : -1;

        if (product.variations.size() > 0) {
            if (selected_variation_id < 0) {
                Helper.toast(coordinatorLayout, L.string.select_a_variation_first);
                return;
            }
        }

        if (product.type == TM_ProductInfo.ProductType.MIXNMATCH) {
            //reset matching items cart data in adapter
            mAdapterMatchingProduct.resetAll();
        }

        Cart.removeProduct(product, selected_variation_id, selected_variation_index);

        if (fragmentRefreshListener != null) {
            fragmentRefreshListener.onFragmentRefreshed();
        }
    }

    private void addToWishList() {
        showWishListDialog(product, new WishListDialogHandler() {
            @Override
            public void onSelectGroupSuccess(final TM_ProductInfo product, final WishListGroup obj) {
                showProgress(getString(L.string.please_wait), false);
                WishListGroup.addProductToWishList(obj.id, product.id, new DataQueryHandler() {
                    @Override
                    public void onSuccess(Object data) {
                        hideProgress();
                        if (!Wishlist.hasItem(product) && Wishlist.addProduct(product, obj)) {
                            Helper.showToast(Helper.showItemAddedToWishListToast(obj));
                            updateButtonSection();
                            if (fragmentRefreshListener != null) {
                                fragmentRefreshListener.onFragmentRefreshed();
                            }
                        } else {
                            mWishListButton.setChecked(false, false);
                            Helper.showToast(Helper.showItemAddedToWishListToast(obj));
                        }

                    }

                    @Override
                    public void onFailure(Exception error) {
                        Helper.toast(getString(L.string.generic_server_timeout));
                    }
                });
            }

            @Override
            public void onSelectGroupFailed(String cause) {
                mWishListButton.setChecked(false, false);
            }

            @Override
            public void onSkipDialog(TM_ProductInfo product, WishListGroup obj) {

                if (!Wishlist.hasItem(product) && Wishlist.addProduct(product, obj)) {
                    Helper.showToast(Helper.showItemAddedToWishListToast(obj));
                    updateButtonSection();
                    if (fragmentRefreshListener != null) {
                        fragmentRefreshListener.onFragmentRefreshed();
                    }
                } else {
                    mWishListButton.setChecked(false, false);
                    Helper.showToast(Helper.showItemAddedToWishListToast(obj));
                }
            }
        });
    }

    private void removeFromWishlist() {

        Wishlist.removeProduct(product);

        Wishlist wish = Wishlist.findCart(product.id);
        if (wish == null)
            return;

        String note = wish.note;

        String parent_title = wish.parent_title;
        Wishlist.removeProduct(product);

        if (!AppInfo.ENABLE_ZERO_PRICE_ORDER) {
            if (product.getActualPrice() <= 0) {
                Helper.toast(coordinatorLayout, L.string.product_not_for_sale);
                return;
            }
        }

        Cart cart = Cart.findCart(product.id);
        if (cart != null && Helper.isValidString(note)) {
            cart.note = note;
            cart.save();
        }

        Helper.toast(coordinatorLayout, Helper.showItemRemovedToWishListToast(parent_title));
        if (fragmentRefreshListener != null) {
            fragmentRefreshListener.onFragmentRefreshed();
        }
    }

    public void setOnFragmentPopListener(OnFragmentPopListener onPopListener) {
        this.onFragmentPopListener = onPopListener;
    }

    public void createOrFetchPoll() {
        if (!Helper.hasWhatsApp(activity)) {
            Helper.toast(coordinatorLayout, getString(L.string.whatsapp_install_error));
            return;
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (ContextCompat.checkSelfPermission(activity, Manifest.permission.WRITE_EXTERNAL_STORAGE) != 0) {
                ActivityCompat.requestPermissions(activity, new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE}, 0);
                return;
            }
        }

        showProgress(getString(L.string.creating_opinion_poll));

        ParseQuery<ParseObject> query = ParseQuery.getQuery("PollData");
        query.whereEqualTo("product_id", product.id + "");
        query.whereEqualTo("user_id", ParseUser.getCurrentUser());
        query.setLimit(1);
        query.findInBackground(new FindCallback<ParseObject>() {
            @Override
            public void done(List<ParseObject> objects, ParseException e) {
                if (e == null) {
                    if (objects.size() > 0) {
                        sharePollOnWhatsApp(objects.get(0).getObjectId());
                    } else {
                        showProgress(getString(L.string.updating_opinion_data));
                        final ParseObject parseObject = new ParseObject("PollData");
                        parseObject.put("user_id", ParseUser.getCurrentUser());
                        parseObject.put("product_id", product.id + "");
                        parseObject.put("likes", 0); //Build.VERSION.SDK_INT >= 23 ? -1 : 0);
                        parseObject.put("unlikes", 0);
                        parseObject.put("operated", 0);
                        parseObject.put("is_active", true);
                        //parseObject.put("product_url", product.product_url);
                        parseObject.put("product_url", Helper.getProductPermalink(product));
                        parseObject.saveInBackground(new SaveCallback() {
                            @Override
                            public void done(ParseException e) {
                                if (e == null) {
                                    if (fragmentRefreshListener != null) {
                                        fragmentRefreshListener.onFragmentRefreshed();
                                    }
                                    sharePollOnWhatsApp(parseObject.getObjectId());
                                } else {
                                    Log.d("-- error 2 ---");
                                    hideProgress();
                                    e.printStackTrace();
                                }
                            }
                        });
                    }
                } else {
                    hideProgress();
                    e.printStackTrace();
                }
            }
        });
    }

    private void sharePollOnWhatsApp(final String pollId) {
        Glide.with(activity)
                .load(product.getFirstImageUrl())
                .asBitmap()
                .error(R.drawable.placeholder_product)
                .into(new SimpleTarget<Bitmap>() {
                    @Override
                    public void onResourceReady(Bitmap bitmap, GlideAnimation<? super Bitmap> glideAnimation) {
                        sharePollOnWhatsApp(pollId, bitmap);
                    }

                    @Override
                    public void onLoadFailed(Exception e, Drawable errorDrawable) {
                        Bitmap bitmap = ((BitmapDrawable) errorDrawable).getBitmap();
                        sharePollOnWhatsApp(pollId, bitmap);
                    }
                });
    }

    private String getSharableText() {
        String sharableText = "*" + product.title + "*";
        if (AppInfo.SHOW_PRICE_IN_SHARE_TEXT) {
            sharableText += "\n" + getString(L.string.price_prefix) + " " + HtmlCompat.fromHtml(Helper.appendCurrency(product.getActualPrice(), product)).toString();
        }

        if (AppInfo.SHOW_APP_URL_IN_SHARE_TEXT) {
            sharableText += "\n\n" + Helper.getPlayStoreUrl();
        } else {
            String permalink = Helper.getProductPermalink(product);
            if (BuildConfig.MULTI_STORE) {
                // Add Store name for Multi Store related deep link handling.
                if (!TextUtils.isEmpty(AppInfo.DEEP_LINK_URL)) {
                    permalink = AppInfo.DEEP_LINK_URL;
                    permalink += "?pid=" + product.id;
                } else {
                    String hostUrl = activity.getString(R.string.host_url);
                    permalink = permalink.replace(DataEngine.baseURL, hostUrl);
                }
                permalink += "&store=" + Preferences.getString(Constants.Key.MULTI_STORE_PLATFORM);
            } else if (BuildConfig.DEBUG) {
                // Change permalink to test in debug build variant.
                String hostUrl = activity.getString(R.string.host_url);
                permalink = permalink.replace(DataEngine.baseURL, hostUrl);
            }
            sharableText += "\n\n" + permalink;
        }

        if (product.hasShortDescription()) {
            sharableText += "\n\n" + Helper.getPlainText(product.getShortDescription());
        }
        return sharableText;
    }

    public void shareProductWithFriends() {
        AnalyticsHelper.registerShareProductEvent(product);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (ContextCompat.checkSelfPermission(activity, Manifest.permission.WRITE_EXTERNAL_STORAGE) != 0) {
                ActivityCompat.requestPermissions(activity, new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE}, 1);
                return;
            }
        }

        Glide.with(activity)
                .load(product.getFirstImageUrl())
                .asBitmap()
                .error(R.drawable.placeholder_product)
                .into(new SimpleTarget<Bitmap>() {
                    @Override
                    public void onResourceReady(Bitmap bitmap, GlideAnimation<? super Bitmap> glideAnimation) {
                        hideProgress();
                        Helper.shareImageWithText(bitmap, getSharableText());
                    }

                    @Override
                    public void onLoadFailed(Exception e, Drawable drawable) {
                        hideProgress();
                        Bitmap bitmap = ((BitmapDrawable) drawable).getBitmap();
                        Helper.shareImageWithText(bitmap, getSharableText());
                    }
                });
    }

    private void sharePollOnWhatsApp(String pollId, Bitmap bitmap) {
        hideProgress();
        final String extraText = product.title + "\n" +
                getString(L.string.price_prefix) + " " + HtmlCompat.fromHtml(Helper.appendCurrency(product.getActualPrice(), product)).toString()
                + "\n\n" + getString(L.string.msg_opinion_product)
                + "\n\n" + getString(L.string.msg_opinion_like) + " \uD83D\uDC4D\n"
                + "http://thetmstore.com/L/" + AppInfo.MERCHANT_ID + "/" + pollId
                + "\n\n" + getString(L.string.msg_opinion_dislike) + " \uD83D\uDC4E\n"
                + "http://thetmstore.com/U/" + AppInfo.MERCHANT_ID + "/" + pollId;
        Helper.shareOnWhatsApp(extraText, bitmap);
    }

    private void shareProductOnWhatsApp(Bitmap bitmap) {
        hideProgress();
        Helper.shareOnWhatsApp(getSharableText(), bitmap);
        AnalyticsHelper.registerShareProductEvent(product);
    }

    @Override
    public void onScrollChanged(ObservableScrollView scrollView, int x, int y, int oldx, int oldy) {
        if (y > 0 && y > oldy) {
            FreshChatConfig.showChatButton(activity, false);
        } else {
            FreshChatConfig.showChatButton(activity, true);
        }
    }

    private class OnWishListClickListener implements CompoundButton.OnCheckedChangeListener {
        public void onCheckedChanged(CompoundButton button, boolean isChecked) {
            if (isChecked) {
                addToWishList();
            } else {
                removeFromWishlist();
            }
        }
    }

    private OnClickListener mAddToCartListener = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            try {
                int qty = Integer.parseInt(mTextQuantity.getText().toString());
                if (addToCart(qty)) {
                    mButtonAddToCart.setText(getString(L.string.view_cart));
                    mButtonAddToCart.setOnClickListener(mViewCartListener);
                }
            } catch (Exception ignored) {
            }
        }
    };

    private OnClickListener mViewCartListener = v -> {
        if (onFragmentPopListener != null) {
            onFragmentPopListener.onFragmentPoped(OnFragmentPopListener.CODE_SHOW);
        }
    };

    private void loadWaitListUI() {
        LinearLayout layout = mRootView.findViewById(R.id.waitlist_layout);
        if (!AppInfo.mProductDetailsConfig.show_waitlist_section || !AppInfo.ENABLE_CUSTOM_WAITLIST) {
            layout.setVisibility(View.GONE);
            return;
        }

        if (product.in_stock) {
            layout.setVisibility(View.GONE);
            return;
        }

        layout.setVisibility(View.VISIBLE);

        Button button = mRootView.findViewById(R.id.btn_subscribe_waitlist);
        button.setOnClickListener(v -> {
            if (TextUtils.isEmpty(AppUser.getEmail())) {
                Helper.toast(L.string.not_signed_in);
                return;
            }

            showProgress(getString(L.string.please_wait), false);
            if (!TM_WaitList.hasProductId(product.id)) {
                DataEngine.getDataEngine().subscribeWaitListProductAsync(
                        AppUser.getUserId(),
                        AppUser.getEmail(),
                        product.id,
                        new DataQueryHandler() {
                            @Override
                            public void onSuccess(Object data) {
                                TM_WaitList.addProductId(product.id);
                                updateWaitListUI();
                                hideProgress();
                            }

                            @Override
                            public void onFailure(Exception reason) {
                                Log.d(reason.getMessage());
                                hideProgress();
                            }
                        });
            } else {
                DataEngine.getDataEngine().unsubscribeWaitListProductAsync(
                        AppUser.getUserId(),
                        AppUser.getEmail(),
                        product.id,
                        new DataQueryHandler() {
                            @Override
                            public void onSuccess(Object data) {
                                TM_WaitList.removeProductId(product.id);
                                updateWaitListUI();
                                hideProgress();
                            }

                            @Override
                            public void onFailure(Exception reason) {
                                Log.d(reason.getMessage());
                                hideProgress();
                            }
                        });
            }
        });
        Helper.styleFlat(button);
        updateWaitListUI();
    }

    private void updateWaitListUI() {
        if (AppInfo.ENABLE_CUSTOM_WAITLIST) {
            boolean subscribed = TM_WaitList.hasProductId(product.id);
            Button button = mRootView.findViewById(R.id.btn_subscribe_waitlist);
            button.setText(getString(subscribed ? L.string.unsubscribe_waitlist : L.string.subscribe_waitlist));

            TextView textView = mRootView.findViewById(R.id.text_subscribe_waitlist_desc);
            textView.setText(getString(subscribed ? L.string.unsubscribe_waitlist_desc : L.string.subscribe_waitlist_desc));
        }
    }

    private void showRewardPoints() {
        if (!AppInfo.mProductDetailsConfig.show_reward_points) {
            mProductPointsView.setVisibility(View.GONE);
            return;
        }

        if (!isRewardPointsCheck()) {
            return;
        }
        int points;
        if (selected_variation != null) {
            points = selected_variation.getRewardPoints();
        } else {
            points = product.getRewardPoints(-1);
        }
        if (points > 0) {
            mProductPointsView.setVisibility(View.VISIBLE);
            mProductPointsView.setText(HtmlCompat.fromHtml(String.format(getString(L.string.product_points), points)));
            Animation fadeInAnimation = AnimationUtils.loadAnimation(activity, R.anim.fade_in);
            mProductPointsView.startAnimation(fadeInAnimation);
        } else {
            mProductPointsView.setVisibility(View.GONE);
            if (points < 0) {
                loadRewardPoints();
            }
        }
    }

    private void loadRewardPoints() {
        if (!isRewardPointsCheck()) {
            return;
        }

        Map<String, String> params = new HashMap<>();
        params.put("user_id", "" + AppUser.getUserId());
        params.put("email_id", AppUser.getEmail());
        params.put("prod_id", "" + product.id);
        if (product.hasVariations()) {
            params.put("var_ids", "[" + product.getVariationsIds() + "]");
        }
        DataEngine.getDataEngine().getProductRewardPointsAsync(params, new DataQueryHandler<String>() {
            @Override
            public void onSuccess(String data) {
                showRewardPoints();
            }

            @Override
            public void onFailure(Exception reason) {
                Log.e(reason.getMessage());
                mProductPointsView.setVisibility(View.GONE);
            }
        });
    }

    private boolean isRewardPointsCheck() {
        return !(!AppInfo.ENABLE_CUSTOM_POINTS || !product.full_data_loaded);
    }

    private void loadBrandNames() {
        if (AppInfo.mProductDetailsConfig.show_brand_names) {
            if (TextUtils.isEmpty(product.getBrandName())) {
                DataEngine.getDataEngine().getProductsBrandNames(new int[]{product.id}, new DataQueryHandler() {
                    @Override
                    public void onSuccess(Object data) {
                        updateBrandNameUI();
                    }

                    @Override
                    public void onFailure(Exception error) {
                        textBrandName.setVisibility(View.GONE);
                    }
                });
            } else {
                updateBrandNameUI();
            }
        }
    }

    private void updateBrandNameUI() {
        if (AppInfo.mProductDetailsConfig.show_brand_names) {
            textBrandName.setVisibility(View.GONE);
            if (!TextUtils.isEmpty(product.getBrandName())) {
                String brand = "";
                String url = "";
                try {
                    String str = product.getBrandName();
                    int i, s;
                    String attr = "href=";
                    i = str.indexOf(attr);
                    if (i >= 0) {
                        s = i + attr.length() + 1;
                        url = str.substring(s, str.indexOf("\"", s));
                    }

                    i = str.indexOf(">");
                    if (i >= 0) {
                        s = i + 1;
                        brand = str.substring(s, str.indexOf("<", s));
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                if (!TextUtils.isEmpty(brand)) {
                    textBrandName.setText(HtmlCompat.fromHtml(getString(L.string.brand) + " " + brand));
                    textBrandName.setPaintFlags(textBrandName.getPaintFlags() | Paint.UNDERLINE_TEXT_FLAG);
                    textBrandName.setTag(url);
                    textBrandName.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            TextView textView = (TextView) view;
                            String title = textView.getText().toString();
                            String url = textView.getTag().toString();
                            if (!TextUtils.isEmpty(url)) {
                                activity.getFM().beginTransaction()
                                        .replace(R.id.content, WebViewFragment.create(title, url))
                                        .addToBackStack(WebViewFragment.class.getSimpleName())
                                        .commit();
                            }
                        }
                    });
                    textBrandName.setVisibility(View.VISIBLE);
                }
            }
        }
    }

    private void loadPriceLabels() {
        if (AppInfo.SHOW_PRICE_LABELS || AppInfo.mProductDetailsConfig.show_price_labels) {
            if (TextUtils.isEmpty(product.getPriceLabel())) {
                DataEngine.getDataEngine().getProductsPriceLabels(new int[]{product.id}, new DataQueryHandler() {
                    @Override
                    public void onSuccess(Object data) {
                        String text = textProductSalePrice.getText() + product.getPriceLabel();
                        Helper.setColorSpan(textProductSalePrice, text, product.getPriceLabel(), textProductSalePrice.getCurrentTextColor());
                    }

                    @Override
                    public void onFailure(Exception error) {
                        updatePriceLabelsUI();
                    }
                });
            }
        }
    }

    private void updatePriceLabelsUI() {
        if (AppInfo.SHOW_PRICE_LABELS || AppInfo.mProductDetailsConfig.show_price_labels) {
            if (!TextUtils.isEmpty(product.getPriceLabel())) {
                String text = textProductSalePrice.getText() + product.getPriceLabel();
                int color = Color.parseColor(AppInfo.color_theme);
                Helper.setColorSpan(textProductSalePrice, text, product.getPriceLabel(), color);
            }
        }
    }

    private void loadQuantityRule() {
        if (AppInfo.mProductDetailsConfig.show_quantity_rules) {
            mQuantityRulesFetched = (product.getQuantityRules() != null);
            if (!mQuantityRulesFetched) {
                mQuantityRulesFetched = false;
                progress_fulldata.setVisibility(View.VISIBLE);
                DataEngine.getDataEngine().getProductsQuantityRules(
                        new int[]{product.id},
                        new DataQueryHandler() {
                            @Override
                            public void onSuccess(Object data) {
                                progress_fulldata.setVisibility(View.GONE);
                                mQuantityRulesFetched = true;
                                // don't change order of textChangedlistener else it generate bug
                                mTextQuantity.removeTextChangedListener(mQuantityListener);
                                showCartQuantityUI();
                                mTextQuantity.removeTextChangedListener(mQuantityListener);
                                updateCartQuantityUI();
                                mTextQuantity.addTextChangedListener(mQuantityListener);
                            }

                            @Override
                            public void onFailure(Exception error) {
                                progress_fulldata.setVisibility(View.GONE);
                                mQuantityRulesFetched = false;
                            }
                        });
            } else {
                mTextQuantity.removeTextChangedListener(mQuantityListener);
                showCartQuantityUI();
                mTextQuantity.removeTextChangedListener(mQuantityListener);
                updateCartQuantityUI();
                mTextQuantity.addTextChangedListener(mQuantityListener);
            }
        }
    }

    private void updateCartQuantityUI() {
        if (AppInfo.mProductDetailsConfig.show_quantity_rules) {
            QuantityRule quantityRule = product.getQuantityRules();
            if (quantityRule != null) {
                if (quantityRule.isOverrideRule() && quantityRule.getMinQuantity() > mCartCount) {
                    mCartCount = quantityRule.getMinQuantity();
                    mTextQuantity.setText(String.valueOf(mCartCount));
                }
            }
        }
    }

    private void showCartQuantityUI() {
        // Text for minimum quantity when quantity rules are enabled
        TextView textMinimumQty = mRootView.findViewById(R.id.text_minimum_qty);
        if (textMinimumQty.getVisibility() == View.VISIBLE) {
            textMinimumQty.setVisibility(View.GONE);
        }

        if (AppInfo.mProductDetailsConfig.show_quantity_rules) {

            if (mBuyButtonSection.getVisibility() == View.VISIBLE) {
                mBuyButtonSection.setVisibility(View.GONE);
            }

            if (mCartButtonSection.getVisibility() == View.VISIBLE) {
                mCartButtonSection.setVisibility(View.GONE);
            }
        }
        configQuickCart = AppInfo.mProductDetailsConfig.configQuickCart;
        if (((configQuickCart != null && configQuickCart.enabled) || AppInfo.mProductDetailsConfig.show_quantity_rules) && (AppInfo.ENABLE_CART && GuestUserConfig.isEnableCart())) {
            mBuyButtonSection.setVisibility(View.GONE);

            if (configQuickCart != null && configQuickCart.layoutPosition.equals(ProductDetailsConfig.LayoutPosition.BOTTOM)) {
                buy_cart_section_bottomLayout.setVisibility(View.VISIBLE);
                mCartButtonSection.setVisibility(View.VISIBLE);
                mCartButtonSection.setBackground(Helper.getButtonSectionBorder());
            } else {
                buy_cart_sectionLayout.setVisibility(View.VISIBLE);
                mCartButtonSection.setVisibility(View.VISIBLE);
                mCartButtonSection.setBackground(Helper.getButtonSectionBorder());
            }

            mButtonAddToCart = mViewInflater.findViewById(R.id.btn_add_to_cart2);
//            if (AppUser.hasSignedIn()) {
            mButtonAddToCart.setEnabled(true);
//            } else {
//                mButtonAddToCart.setEnabled(false);
//            }
            mButtonAddToCart.setText(getString(L.string.add_to_cart));
            Helper.styleFlat(mButtonAddToCart);

            mTextQuantity = (EditText) mViewInflater.findViewById(R.id.quantity);
            Helper.stylize(mTextQuantity);
            //Helper.stylizeFlatEditText(mTextQuantity);
            mTextQuantity.setText(String.valueOf(mCartCount));
            mTextQuantity.setFocusable(false);
            mTextQuantity.setFocusableInTouchMode(false);

            ImageButton btnQtyPlus = mViewInflater.findViewById(R.id.btn_qty_plus);
            ImageButton btnQtyMinus = mViewInflater.findViewById(R.id.btn_qty_minus);
            Helper.stylizeVector(btnQtyMinus);
            //Helper.styleFlatImageButton(btnQtyMinus);
            Helper.stylizeVector(btnQtyPlus);
            //Helper.styleFlatImageButton(btnQtyPlus);

            //if (AppUser.hasSignedIn()) {
            btnQtyPlus.setEnabled(true);
            btnQtyMinus.setEnabled(true);
            mTextQuantity.setEnabled(true);
//            } else {
//                btnQtyPlus.setEnabled(false);
//                btnQtyMinus.setEnabled(false);
//                mTextQuantity.setEnabled(false);
//            }

            btnQtyPlus.setOnClickListener(new ValueObserver(mTextQuantity, ValueObserver.Type.INCREASE, this::updateCartQuantity, product.getQuantityRules()));

            btnQtyMinus.setOnClickListener(new ValueObserver(mTextQuantity, ValueObserver.Type.DECREASE, this::updateCartQuantity, product.getQuantityRules()));

            //updateQuickCartInfo();

            if (AppInfo.mProductDetailsConfig.show_quantity_rules) {
                mButtonAddToCart.setEnabled(mQuantityRulesFetched);
                mTextQuantity.setEnabled(mQuantityRulesFetched);
                btnQtyPlus.setEnabled(mQuantityRulesFetched);
                btnQtyMinus.setEnabled(mQuantityRulesFetched);
            }

            if (selected_cart != null) {
                mCartCount = selected_cart.count;
                mTextQuantity.setText(String.valueOf(mCartCount));
                mButtonAddToCart.setText(getString(L.string.view_cart));
                mButtonAddToCart.setOnClickListener(mViewCartListener);
            } else {
                if (product.variations.size() > 0 && selected_variation != null) {
                    Cart cart = Cart.findCart(product.id, selected_variation.id, selected_variation.index);
                    if (cart != null) {
                        mCartCount = cart.count;
                        mButtonAddToCart.setText(getString(L.string.view_cart));
                        mButtonAddToCart.setOnClickListener(mViewCartListener);
                    } else {
                        mButtonAddToCart.setText(getString(L.string.add_to_cart));
                        mButtonAddToCart.setOnClickListener(mAddToCartListener);
                    }
                } else {
                    mButtonAddToCart.setText(getString(L.string.add_to_cart));
                    mButtonAddToCart.setOnClickListener(mAddToCartListener);
                }
            }

            if (mQuantityListener == null) {
                mQuantityListener = new QuantityListener(mTextQuantity, new QuantityListener.OnChangeCallback() {
                    @Override
                    public void onChange(int value) {
                        updateCartQuantity(value);
                    }
                }, product.getQuantityRules());
            }

            if (AppInfo.ENABLE_WISHLIST) {
                mWishListButton.setVisibility(View.VISIBLE);
                layout_wishlist.setVisibility(View.VISIBLE);
                mWishListButton.setOnCheckedChangeListener(new OnWishListClickListener());
            } else {
                layout_wishlist.setVisibility(View.GONE);
                mWishListButton.setVisibility(View.GONE);
            }

            if (product.getQuantityRules() != null) {
                int minQty = product.getQuantityRules().getMinQuantity();
                if (product.getQuantityRules().isOverrideRule() && minQty > 0) {
                    textMinimumQty.setText(getString(L.string.minimum_qty) + " " + minQty);
                    textMinimumQty.setVisibility(View.VISIBLE);
                }
            }
        } else {
            mCartButtonSection.setVisibility(View.GONE);
            if (AppInfo.mProductDetailsConfig.configBuyButton.enabled) {
                if (AppInfo.mProductDetailsConfig.configBuyButton.layoutPosition.equals(ProductDetailsConfig.LayoutPosition.BOTTOM)) {

                    buy_cart_section_bottomLayout.setVisibility(View.VISIBLE);
                    buy_cart_sectionLayout.setVisibility(View.GONE);
                    mBuyButtonSection.setVisibility(View.VISIBLE);
                    mBuyButtonSection.setBackground(Helper.getButtonSectionBorder());
                } else {
                    buy_cart_section_bottomLayout.setVisibility(View.GONE);
                    buy_cart_sectionLayout.setVisibility(View.VISIBLE);
                    mBuyButtonSection.setVisibility(View.VISIBLE);
                    mBuyButtonSection.setBackground(Helper.getButtonSectionBorder());
                }

            } else {
                buy_cart_sectionLayout.setVisibility(View.GONE);
                buy_cart_section_bottomLayout.setVisibility(View.GONE);
                mBuyButtonSection.setVisibility(View.GONE);
            }

            if (mBuyButtonSection.getVisibility() == View.VISIBLE) {
                if (AppInfo.ENABLE_WISHLIST) {
                    mWishListButton.setVisibility(View.VISIBLE);
                    layout_wishlist.setVisibility(View.VISIBLE);
                    mWishListButton.setOnCheckedChangeListener(new OnWishListClickListener());

                } else {
                    mWishListButton.setVisibility(View.GONE);
                    layout_wishlist.setVisibility(View.GONE);
                }
                mCartButton.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                    public void onCheckedChanged(CompoundButton button, boolean isChecked) {
                        if (isChecked) {
                            addToCart(1);
                        } else {
                            removeFromCart();
                        }
                    }
                });

                layout_add_to_cart.setOnClickListener(v -> {
                    if (!mCartButton.isChecked()) {
                        if (addToCart(1)) {
                            mCartButton.setChecked(true);
                        } else {
                            mCartButton.setChecked(false);
                        }
                    } else {
                        removeFromCart();
                        mCartButton.setChecked(false);
                    }
                });
            } else {
                mBuyButtonSection.setVisibility(View.GONE);
            }
        }
    }

    private void updateCartQuantity(int count) {
        if ((AppInfo.mProductDetailsConfig.show_quantity_rules && !mQuantityRulesFetched) || count < 1) {
            // Don't update cart directly when overriding quantity rules or quantity is 0
            if (count <= 0) {
                Cart.removeProduct(product);
                mButtonAddToCart.setVisibility(View.VISIBLE);
                mButtonAddToCart.setText(getString(L.string.add_to_cart));
                mButtonAddToCart.setOnClickListener(mAddToCartListener);
                mTextQuantity.setText(String.valueOf(1));
            }
            return;
        }

        if (selected_variation != null) {
            Cart cart = Cart.findCart(product.id, selected_variation.id, selected_variation.index);
            if (cart != null) {
                Cart.addProduct(product, selected_variation.id, selected_variation.index, count, selected_variationAttributes);
            }
        } else {
            if (addToCart(count)) {
                mButtonAddToCart.setText(getString(L.string.view_cart));
                mButtonAddToCart.setOnClickListener(mViewCartListener);
            }
        }
    }

    private void loadMixMatchProducts() {
        View view = mRootView.findViewById(R.id.mixmatch_products_section);
        if (view == null)
            return;

        if (AppInfo.ENABLE_MIXMATCH_PRODUCTS) {
            if (product.type == TM_ProductInfo.ProductType.MIXNMATCH) {
                if (product.full_data_loaded && product.mMixMatch != null) {
                    view.setVisibility(View.VISIBLE);

                    if (selected_cart == null) {
                        selected_cart = Cart.findCart(product.id);
                    }

                    if (selected_cart != null) {
                        mBuyButtonSection.setVisibility(View.GONE);
                    }

                    mAdapterMatchingProduct = new Adapter_MatchingProduct(activity, product);
                    mAdapterMatchingProduct.setSelectedCart(selected_cart);
                    mAdapterMatchingProduct.setOnQuantityChangeListener(new Adapter_MatchingProduct.OnQuantityChangeListener() {
                        @Override
                        public void onQuantityChange() {
                            int selectedItemsCount = mAdapterMatchingProduct.getSelectedItemsCount();
                            if (selectedItemsCount == 0 && selected_cart != null) {
                                Fragment_ProductDetail.this.removeFromCart();
                                mBuyButtonSection.setVisibility(View.VISIBLE);
                            }
                            float price = mAdapterMatchingProduct.getSelectedItemsPrice();
                            if (price == 0) {
                                price = product.mMixMatch.getMinPrice();
                            }
                            textProductSalePrice.setText(HtmlCompat.fromHtml(Helper.appendCurrency(price, product)));
                        }
                    });

                    RecyclerView recyclerView = (RecyclerView) view.findViewById(R.id.mixmatch_products_recycler_view);
                    recyclerView.setAdapter(mAdapterMatchingProduct);

                    TextView textView = view.findViewById(R.id.header_mixmatch_products);
                    int leastSelected = (int) product.mMixMatch.getContainerSize();
                    if (leastSelected == 0) {
                        leastSelected = 1;
                    }
                    textView.setText(String.format(Locale.getDefault(), getString(L.string.header_mixmatch_products), leastSelected));

                    textProductSalePrice.setText(HtmlCompat.fromHtml(Helper.appendCurrency(product.mMixMatch.getMinPrice(), product)));
                    textShortDesc.setVisibility(View.GONE);
                    return;
                }
            }
        }
        view.setVisibility(View.GONE);
    }

    private void loadBundledProducts() {
        View view = mRootView.findViewById(R.id.bundled_products_section);
        if (view == null)
            return;

        if (AppInfo.ENABLE_BUNDLED_PRODUCTS && product.full_data_loaded) {
            view.setVisibility(View.VISIBLE);
            if (product.mBundles != null && !product.mBundles.isEmpty()) {
                Adapter_BundledProduct adapter = new Adapter_BundledProduct(activity, product.mBundles);
                RecyclerView recyclerView = (RecyclerView) view.findViewById(R.id.bundled_products_recycler_view);
                recyclerView.setAdapter(adapter);
            }
        } else {
            view.setVisibility(View.GONE);
        }
    }

    private void showWishListDialog(TM_ProductInfo product, WishListDialogHandler loginDialogHandler) {
        if (!AppInfo.ENABLE_MULTIPLE_WISHLIST) {
            loginDialogHandler.onSkipDialog(product, null);
            return;
        }

        if (!AppUser.hasSignedIn() && (AppInfo.mGuestUserConfig != null && AppInfo.mGuestUserConfig.isEnabled() && AppInfo.mGuestUserConfig.isPreventWishlist())) {
            Helper.toast(getString(L.string.you_need_to_login_first));
            loginDialogHandler.onSelectGroupFailed(getString(L.string.you_need_to_login_first));
            return;
        }

        if (WishListGroup.getDefaultItem() != null) {
            if (AppUser.hasSignedIn())
                loginDialogHandler.onSelectGroupSuccess(product, WishListGroup.getDefaultItem());
            else
                loginDialogHandler.onSkipDialog(product, WishListGroup.getDefaultItem());
            return;
        }

        Fragment_Wishlist_Dialog wishlist_dialog = new Fragment_Wishlist_Dialog();
        wishlist_dialog.setProduct(product);
        wishlist_dialog.setWishListDialogHandler(loginDialogHandler);
        activity.getFM().beginTransaction()
                .replace(R.id.content, wishlist_dialog)
                .addToBackStack(Fragment_Wishlist_Dialog.class.getSimpleName())
                .commit();
    }

    private void showPinCodeLayout() {
        PinCodeSettingsConfig pinCodeSettingsConfig = PinCodeSettingsConfig.getInstance();
        if (!pinCodeSettingsConfig.isEnabled()) {
            return;
        }

        if (pinCodeSettingsConfig.getCheckType() != PinCodeSettingsConfig.CheckType.CHECK_PER_PRODUCT) {
            return;
        }

        LinearLayout layout = mRootView.findViewById(R.id.pincode_settings_card);
        layout.setVisibility(View.VISIBLE);
        LayoutInflater inflater = LayoutInflater.from(activity);
        final View view = inflater.inflate(R.layout.product_pincode_availability_layout, layout, true);
        final LinearLayout layout_main = view.findViewById(R.id.layout_main);
        final LinearLayout pincode_layout_edit = view.findViewById(R.id.pincode_layout_edit);
        final LinearLayout avail_detail_layout = view.findViewById(R.id.avail_detail_layout);
        final LinearLayout avail_detail_layout2 = view.findViewById(R.id.avail_detail_layout2);
        final LinearLayout pincode_linear_layout = view.findViewById(R.id.pincode_linear_layout);
        Helper.stylizeBtnSeparator(view.findViewById(R.id.separator));
        pincode_linear_layout.setBackground(Helper.getButtonSectionBorder());
        layout_main.setVisibility(View.VISIBLE);
        pincode_layout_edit.setVisibility(View.GONE);
        avail_detail_layout.setVisibility(View.GONE);
        avail_detail_layout2.setVisibility(View.GONE);
        final EditText edit_pin_code_product = (EditText) view.findViewById(R.id.edit_pin_code_product);
        edit_pin_code_product.setHint(getString(L.string.enter_your_pincode));
        final ImageView iv_check_pincode = view.findViewById(R.id.iv_check_pincode);
        ImageView iv_edit = view.findViewById(R.id.iv_edit);
        final ImageView iv_status = view.findViewById(R.id.iv_status);
        final ImageView iv_status2 = view.findViewById(R.id.iv_status2);

        Helper.stylize(iv_status);
        Helper.stylize(iv_edit);
        Helper.stylize(iv_status2);
        final TextView label = view.findViewById(R.id.label);
        final TextView status = view.findViewById(R.id.status);
        final TextView label2 = view.findViewById(R.id.label2);
        final TextView status2 = view.findViewById(R.id.status2);
        final TextView tv_availability_at = view.findViewById(R.id.tv_availability_at);
        final TextView text_zip_not_found = view.findViewById(R.id.text_zip_not_found);
        text_zip_not_found.setVisibility(View.GONE);
        final ProgressBar progress_bar_pincode = view.findViewById(R.id.progress_bar_pincode);
        progress_bar_pincode.getIndeterminateDrawable().setColorFilter(ResourcesCompat.getColor(activity.getResources(), R.color.color_icon_overlay, null), PorterDuff.Mode.SRC_IN);

        tv_availability_at.setText(getString(L.string.check_availability));

        iv_edit.setOnClickListener(view12 -> {
            layout_main.setVisibility(View.VISIBLE);
            pincode_layout_edit.setVisibility(View.GONE);
            avail_detail_layout.setVisibility(View.GONE);
            avail_detail_layout2.setVisibility(View.GONE);
        });


        iv_check_pincode.setOnClickListener(view1 -> {
            final String pincode = edit_pin_code_product.getText().toString();
            Helper.hideKeyboard(view1);
            text_zip_not_found.setVisibility(View.GONE);
            if (pincode.isEmpty()) {
                edit_pin_code_product.setError(getString(L.string.pincode_is_blank));
                return;
            }

            edit_pin_code_product.setEnabled(false);
            progress_bar_pincode.setVisibility(View.VISIBLE);
            iv_check_pincode.setVisibility(View.GONE);
            DataEngine.getDataEngine().getProductsAvailabilityPincode(
                    new DataQueryHandler() {
                        @Override
                        public void onSuccess(Object data) {
                            progress_bar_pincode.setVisibility(View.GONE);
                            iv_check_pincode.setVisibility(View.VISIBLE);
                            edit_pin_code_product.setEnabled(true);
                            JSONObject pinCodeSettingJson;
                            try {
                                tv_availability_at.setText(String.format(Locale.getDefault(), getString(L.string.available_at), edit_pin_code_product.getText().toString()));
                                pinCodeSettingJson = new JSONObject(data.toString());
                                if (pinCodeSettingJson.has("status")) {
                                    String status1 = JsonHelper.getString(pinCodeSettingJson, "status", "");
                                    if (status1.equalsIgnoreCase("failed")) {
                                        String message = JsonHelper.getString(pinCodeSettingJson, "message", "");
                                        text_zip_not_found.setText(message);
                                        text_zip_not_found.setVisibility(View.VISIBLE);
                                        edit_pin_code_product.setText("");
                                        edit_pin_code_product.requestFocus();
                                    }
                                } else {
                                    pincode_layout_edit.setVisibility(View.VISIBLE);
                                    avail_detail_layout.setVisibility(View.VISIBLE);
                                    avail_detail_layout2.setVisibility(View.VISIBLE);
                                    text_zip_not_found.setVisibility(View.GONE);
                                    layout_main.setVisibility(View.GONE);
                                    Log.d(data + " Fragment_ProductDetail");

                                    if (pinCodeSettingJson.has("delivery")) {
                                        JSONObject deliveryJson = pinCodeSettingJson.getJSONObject("delivery");
                                        String deliveryLabel = JsonHelper.getString(deliveryJson, "label", "");
                                        String deliveryDate = JsonHelper.getString(deliveryJson, "date", "");
                                        label.setText(deliveryLabel);
                                        iv_status.setColorFilter(ResourcesCompat.getColor(activity.getResources(), R.color.highlight_text_color_2, null), PorterDuff.Mode.SRC_IN);
                                        status.setText(deliveryDate);
                                    }

                                    if (pinCodeSettingJson.has("shipping")) {
                                        JSONObject shippingJson = pinCodeSettingJson.getJSONObject("shipping");
                                        String shippingLabel = JsonHelper.getString(shippingJson, "label", "");
                                        String shippingStatus = JsonHelper.getString(shippingJson, "status", "");
                                        if (!shippingStatus.equalsIgnoreCase("Available")) {
                                            iv_status2.setImageResource(R.drawable.ic_vc_close);
                                            iv_status2.setColorFilter(ResourcesCompat.getColor(activity.getResources(), R.color.highlight_text_color, null), PorterDuff.Mode.SRC_IN);
                                        } else {
                                            iv_status2.setImageResource(R.drawable.ic_right);
                                            iv_status2.setColorFilter(ResourcesCompat.getColor(activity.getResources(), R.color.highlight_text_color_2, null), PorterDuff.Mode.SRC_IN);
                                        }
                                        label2.setText(shippingLabel);
                                        status2.setText(shippingStatus);
                                    }
                                }
                            } catch (JSONException e) {
                                e.printStackTrace();
                                text_zip_not_found.setText(getString(L.string.pincode_server_error));
                                text_zip_not_found.setVisibility(View.VISIBLE);
                            }
                        }

                        @Override
                        public void onFailure(Exception error) {
                            iv_check_pincode.setVisibility(View.VISIBLE);
                            progress_bar_pincode.setVisibility(View.GONE);
                            edit_pin_code_product.setEnabled(true);
                            text_zip_not_found.setText(getString(L.string.pincode_server_error));
                            text_zip_not_found.setVisibility(View.VISIBLE);
                            Log.d(error.toString());
                        }
                    }, pincode
            );
        });
    }

    private void loadPinCodeSettings() {
        PinCodeSettingsConfig pinCodeSettingsConfig = PinCodeSettingsConfig.getInstance();
        if (!pinCodeSettingsConfig.isEnabled()) {
            return;
        }

        if (pinCodeSettingsConfig.getCheckType() != PinCodeSettingsConfig.CheckType.CHECK_ALL_PRODUCT) {
            return;
        }

        if (!product.full_data_loaded) {
            return;
        }

        LinearLayout layout = mRootView.findViewById(R.id.pincode_settings_card);
        final PincodeSetting pincodeSetting = PincodeSetting.getInstance();
        if (!pincodeSetting.isFetched() || !pincodeSetting.isEnableOnProductPage()) {
            layout.setVisibility(View.GONE);
            return;
        }

        layout.setVisibility(View.VISIBLE);
        LayoutInflater inflater = LayoutInflater.from(activity);
        View view = inflater.inflate(R.layout.product_info_pincode_settings_card, layout, true);

        final TextView textZipTitle = view.findViewById(R.id.text_zip_title);
        textZipTitle.setText(pincodeSetting.getZipTitle());
        textZipTitle.setVisibility(View.VISIBLE);

        final TextView textZipNotFound = view.findViewById(R.id.text_zip_not_found);
        textZipNotFound.setText(pincodeSetting.getZipNotFoundMessage());
        textZipNotFound.setVisibility(View.GONE);

        final TextView textZipAvailable = view.findViewById(R.id.text_zip_available);
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

        final Button buttonCheckPinCode = view.findViewById(R.id.btn_check_pincode);
        buttonCheckPinCode.setText(pincodeSetting.getZipButtonText());
        Helper.styleRoundFlat(buttonCheckPinCode);
        buttonCheckPinCode.setVisibility(View.VISIBLE);

        final TextView textChangePinCode = view.findViewById(R.id.text_change_pincode);
        textChangePinCode.setText(getString(L.string.change_pincode));
        textChangePinCode.setPaintFlags(textChangePinCode.getPaintFlags() | Paint.UNDERLINE_TEXT_FLAG);
        textChangePinCode.setVisibility(View.GONE);
        textChangePinCode.setOnClickListener(view1 -> {
            editTextPinCode.setVisibility(View.VISIBLE);
            buttonCheckPinCode.setVisibility(View.VISIBLE);
            textChangePinCode.setVisibility(View.GONE);
            textZipNotFound.setVisibility(View.GONE);
            textZipAvailable.setVisibility(View.GONE);
        });

        buttonCheckPinCode.setOnClickListener(view12 -> {
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
        });
    }

    private void initVendorProfileInfo(int layoutId) {
        if (layoutId == 0) {
            return;
        }

        LinearLayout layout = mRootView.findViewById(layoutId);
        layout.setVisibility(View.VISIBLE);
        if (MultiVendorConfig.isShowVendorLayoutCenter()) {
            product_vendor_profile_section = (CardView) activity.getLayoutInflater().inflate(R.layout.product_info_vendor_profile_card_center, layout, false);
            product_vendor_profile_section.setVisibility(View.VISIBLE);
        } else {
            product_vendor_profile_section = activity.getLayoutInflater().inflate(R.layout.product_info_vendor_profile_card, null);
            product_vendor_profile_section.setVisibility(View.VISIBLE);
        }

        layout.addView(product_vendor_profile_section);
        String sellerName;

        if (!(MultiVendorConfig.isEnabled() && MultiVendorConfig.getScreenType() == MultiVendorConfig.ScreenType.PRODUCTS)) {
            product_vendor_profile_section.setVisibility(View.GONE);
            return;
        }

        if (product.sellerInfo == null) {
            product_vendor_profile_section.setVisibility(View.GONE);
            return;
        }

        if (!TextUtils.isEmpty(product.sellerInfo.getShopName())) {
            sellerName = product.sellerInfo.getShopName();
        } else if (!TextUtils.isEmpty(product.sellerInfo.getTitle())) {
            sellerName = product.sellerInfo.getTitle();
        } else {
            product_vendor_profile_section.setVisibility(View.GONE);
            return;
        }

        if (MultiVendorConfig.isShowVendorLayoutCenter()) {
            LinearLayout vendorSection = product_vendor_profile_section.findViewById(R.id.vendor_profile_card_section_center);
            final TextView titleView = vendorSection.findViewById(R.id.title_vendor_name);
            titleView.setText(getString(L.string.vendor_sold_by));

            final TextView nameView = vendorSection.findViewById(R.id.text_vendor_name);
            nameView.setPaintFlags(nameView.getPaintFlags() | Paint.UNDERLINE_TEXT_FLAG);
            nameView.setText(sellerName);

            final TextView shopView = vendorSection.findViewById(R.id.text_vendor_shop);
            shopView.setVisibility(View.GONE);
            shopView.setPaintFlags(nameView.getPaintFlags() | Paint.UNDERLINE_TEXT_FLAG);
            if (!TextUtils.isEmpty(product.sellerInfo.getShopName())) {
                shopView.setText(product.sellerInfo.getShopName());
            } else {
                shopView.setVisibility(View.GONE);
            }
        } else {
            final TextView nameView = product_vendor_profile_section.findViewById(R.id.text_vendor_name);
            nameView.setText(sellerName);

            final TextView locationView = product_vendor_profile_section.findViewById(R.id.text_vendor_location);

            final ImageView imageView = product_vendor_profile_section.findViewById(R.id.image_vendor_icon);

            if (TextUtils.isEmpty(product.sellerInfo.getAvatarUrl())) {
                this.createSellerIconFromName(product.sellerInfo, imageView, locationView);
            } else {
                Glide.with(activity)
                        .load(product.sellerInfo.getAvatarUrl())
                        .error(R.drawable.error_product)
                        .into(imageView);
            }
        }
        product_vendor_profile_section.setOnClickListener(view -> activity.getFM().beginTransaction()
                .replace(R.id.content, Fragment_SellerProducts.newInstance(product.sellerInfo, true, false))
                .addToBackStack(Fragment_SellerProducts.class.getSimpleName())
                .commit());
    }

    public void onViewCreated(View view, Bundle savedInstanceState) {
        double latitude = 0;
        double longitude = 0;
        if (MultiVendorConfig.shouldShowLocation() && product.sellerInfo != null) {
            latitude = product.sellerInfo.getLatitude();
            longitude = product.sellerInfo.getLongitude();
            if (latitude > 0 && longitude > 0) {
                Bundle bundle = new Bundle();
                bundle.putDouble(Fragment_Product_MapInfo.ARGS_LATITUDE, latitude);
                bundle.putDouble(Fragment_Product_MapInfo.ARGS_LONGITUDE, longitude);
                bundle.putBoolean(Fragment_Product_MapInfo.ARGS_SHOW_TITLE, true);
                fragment_product_mapInfo = new Fragment_Product_MapInfo();
                fragment_product_mapInfo.setArguments(bundle);
                fragment_product_mapInfo.onMapClickListener = new Fragment_Product_MapInfo.OnMapClickListener() {
                    @Override
                    public void onMapClick(boolean flag) {
                        scroll_view.requestDisallowInterceptTouchEvent(flag);
                    }
                };
                activity.getFM().beginTransaction().replace(R.id.product_map_layout, fragment_product_mapInfo).commit();
            }
        }
    }

    // Generate image from initials of seller name and show as profile icon.
    private void createSellerIconFromName(SellerInfo vendor, ImageView imageView, TextView locationView) {
        String sellerID = vendor.getId();
        if (TextUtils.isEmpty(sellerID)) {
            sellerID = "2";
        }

        Resources resources = activity.getResources();
        int[] colors = resources.getIntArray(R.array.material_colors);
        Random random = new Random();
        try {
            random.setSeed(Long.parseLong(sellerID));
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }

        int backgroundColor = colors[random.nextInt(colors.length - 1)];
        String strokeColor = String.format("#66%06X", 0xFFFFFF & backgroundColor);
        GradientDrawable drawable = new GradientDrawable();
        drawable.setShape(GradientDrawable.RECTANGLE);
        drawable.setCornerRadius(Helper.DP(4));
        drawable.setColor(backgroundColor);
        //drawable.setStroke(Helper.DP(2), CContext.getColor(activity, R.color.vendor_profile_icon_stroke));
        drawable.setStroke(Helper.DP(4), Color.parseColor(strokeColor));
        imageView.setBackground(drawable);

        int iconWidth = resources.getDimensionPixelSize(R.dimen.vendor_icon_width);
        int iconHeight = resources.getDimensionPixelSize(R.dimen.vendor_icon_height);

        Bitmap bitmap = Bitmap.createBitmap(iconWidth, iconHeight, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);

        final int textSize = resources.getDimensionPixelSize(R.dimen.vendor_icon_text_size);
        TextPaint paint = new TextPaint();
        paint.setTypeface(Typeface.create(Typeface.SANS_SERIF, Typeface.BOLD));
        paint.setColor(Color.WHITE);
        paint.setTextAlign(Paint.Align.CENTER);
        //paint.setTextSize(Helper.SP(textSize, resources));
        paint.setTextSize(textSize);
        paint.setAntiAlias(true);

        String sellerName;
        if (!TextUtils.isEmpty(vendor.getShopName())) {
            sellerName = vendor.getShopName();
        } else {
            sellerName = vendor.getTitle();
        }

        String initials = StringUtils.getInitials(sellerName, 2);

        Rect textBounds = new Rect();
        paint.getTextBounds(initials, 0, initials.length() - 1, textBounds);
        canvas.drawText(initials, iconWidth / 2, (iconHeight + textBounds.height()) / 2, paint);
        imageView.setImageBitmap(bitmap);
        if (Helper.isValidString(vendor.getSellerFirstLocation())) {
            Drawable locationDrawable = ContextCompat.getDrawable(activity, R.drawable.ic_vc_location);
            DrawableCompat.setTint(locationDrawable, backgroundColor);
            locationView.setCompoundDrawablesWithIntrinsicBounds(locationDrawable, null, null, null);
            locationView.setText(vendor.getSellerFirstLocation());
            locationView.setVisibility(View.VISIBLE);
        } else {
            locationView.setVisibility(View.GONE);
        }
    }

    private void loadPRDDDeliveryInfo() {
        CardView cardView = (CardView) mRootView.findViewById(R.id.delivery_info_section);

        if (!AppInfo.ENABLE_PRODUCT_DELIVERY_DATE) {
            cardView.setVisibility(View.GONE);
            return;
        }

        cardView.setVisibility(View.VISIBLE);

        View view = LayoutInflater.from(activity).inflate(R.layout.product_delivery_info_layout, cardView, true);
        editTextSelectDate = (EditText) view.findViewById(R.id.edit_delivery_date);
        editTextSelectDate.setHint(getString(L.string.hint_select_delivery_date));
        Helper.stylize(editTextSelectDate, true);

        TextView textSelectDate = view.findViewById(R.id.text_delivery_date);
        textSelectDate.setText(getString(L.string.delivery_date));

        textSelectTime = view.findViewById(R.id.text_delivery_time);
        textSelectTime.setVisibility(View.GONE);
        textSelectTime.setText(getString(L.string.delivery_time));

        //TextView textDeliveriesAvailable = view.findViewById(R.id.text_deliveries_available);
        //textDeliveriesAvailable.setVisibility(View.GONE);

        spinnerSelectTime = (Spinner) view.findViewById(R.id.spinner_select_time);
        spinnerSelectTime.setVisibility(View.GONE);
        Helper.stylize(spinnerSelectTime, true);

        if (product.deliveryInfo != null) {
            //String deliveriesAvailable = String.format(Locale.getDefault(), getString(L.string.deliveries_available), product.deliveryInfo.prdd_date_lockout, "25/11/1987");
            //textDeliveriesAvailable.setText(deliveriesAvailable);
            showPRDDDeliveryInfo();
        } else {
            progress_fulldata.setVisibility(View.VISIBLE);
            DataEngine.getDataEngine().getProductDeliveryInfo(product, new DataQueryHandler() {
                @Override
                public void onSuccess(Object data) {
                    progress_fulldata.setVisibility(View.GONE);
                    if (product.deliveryInfo != null) {
                        showPRDDDeliveryInfo();
                    }
                }

                @Override
                public void onFailure(Exception e) {
                    progress_fulldata.setVisibility(View.GONE);
                    e.printStackTrace();
                }
            });
        }
    }

    @SuppressLint("ClickableViewAccessibility")
    private void showPRDDDeliveryInfo() {
        textSelectTime.setVisibility(View.GONE);
        spinnerSelectTime.setVisibility(View.GONE);
        editTextSelectDate.setOnClickListener(v -> showPRDDDateDialog());
        editTextSelectDate.setOnTouchListener((v, event) -> {
            if (event.getAction() == MotionEvent.ACTION_UP) {
                if (event.getRawX() >= (editTextSelectDate.getRight() - editTextSelectDate.getCompoundDrawables()[2].getBounds().width())) {
                    showPRDDDateDialog();
                    return true;
                }
            }
            return false;
        });
    }

    private void showPRDDDateDialog() {
        final Calendar now = Calendar.getInstance();
        DatePickerDialog datePickerDialog = DatePickerDialog.newInstance(
                new DatePickerDialog.OnDateSetListener() {
                    @Override
                    public void onDateSet(DatePickerDialog view, int year, int monthOfYear, int dayOfMonth) {
                        //TODO don't use unformatted string in case of date or time. Date format is dd/mm/yyyy
                        String pickedDataString = String.format(Locale.US, "%02d/%02d/%d", (monthOfYear + 1), dayOfMonth, year);
                        editTextSelectDate.setText(pickedDataString);
                        textSelectTime.setVisibility(View.VISIBLE);
                        spinnerSelectTime.setVisibility(View.VISIBLE);

                        product.selectedDeliveryDate = editTextSelectDate.getText().toString();

                        String key_weekday = getDayNameByDate(editTextSelectDate.getText().toString(), year, monthOfYear, dayOfMonth);

                        final List<TM_ProductInfo.TM_DeliveryInfo.TimeSettings> timeSettingsList = product.deliveryInfo.prdd_weekday_time_slot.get(key_weekday);
                        List<String> timeSlots = product.deliveryInfo.getWeekDayTimeSlots(key_weekday);
                        spinnerSelectTime.setAdapter(new ArrayAdapter<>(activity, android.R.layout.simple_list_item_1, timeSlots));
                        spinnerSelectTime.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
                            @Override
                            public void onItemSelected(AdapterView<?> adapterView, View view, int selectedId, long l) {
                                if (selectedId >= 0) {
                                    TM_ProductInfo.TM_DeliveryInfo.TimeSettings timeSettings = timeSettingsList.get(selectedId);
                                    product.selectedDeliverySlotPrice = timeSettings.slot_price;
                                    product.selectedDeliveryTime = timeSettings.getSlotString();
                                }
                            }

                            @Override
                            public void onNothingSelected(AdapterView<?> adapterView) {
                                product.selectedDeliverySlotPrice = "0";
                                product.selectedDeliveryTime = "";
                            }
                        });
                    }
                },
                now.get(Calendar.YEAR),
                now.get(Calendar.MONTH),
                now.get(Calendar.DAY_OF_MONTH)
        );
        datePickerDialog.setTitle(getString(L.string.select_delivery_date));
        datePickerDialog.setOkText(getString(L.string.ok));
        datePickerDialog.setCancelText(getString(L.string.cancel));
        datePickerDialog.show(activity.getFragmentManager(), DatePickerDialog.class.getSimpleName());
        datePickerDialog.setMinDate(now);
        now.add(Calendar.DAY_OF_MONTH, product.deliveryInfo.prdd_maximum_number_days + 9);
        datePickerDialog.setMaxDate(now);
        setDisableWeekDay(datePickerDialog);
    }

    private void setDisableWeekDay(DatePickerDialog datePickerDialog) {
        int weeks = 55;
        List<Calendar> weekends = new ArrayList<>();
        if (TextUtils.equals("", product.deliveryInfo.prdd_weekday_0)) {
            Calendar sunday;
            for (int i = 0; i < (weeks * 7); i = i + 7) {
                sunday = Calendar.getInstance();
                sunday.add(Calendar.DAY_OF_YEAR, (Calendar.SUNDAY - sunday.get(Calendar.DAY_OF_WEEK) + i));
                weekends.add(sunday);
            }
            Calendar[] disabledDays = weekends.toArray(new Calendar[weekends.size()]);
            datePickerDialog.setDisabledDays(disabledDays);

        } else {
            Log.d(" prdd_recurring : prdd_weekday_0 : Weekday Getting ON");
        }

        if (TextUtils.equals("", product.deliveryInfo.prdd_weekday_1)) {
            Calendar monday;
            for (int i = 0; i < (weeks * 7); i = i + 7) {
                monday = Calendar.getInstance();
                monday.add(Calendar.DAY_OF_YEAR, (Calendar.MONDAY - monday.get(Calendar.DAY_OF_WEEK) + i));
                weekends.add(monday);
            }
            Calendar[] disabledDays = weekends.toArray(new Calendar[weekends.size()]);
            datePickerDialog.setDisabledDays(disabledDays);

        } else {
            Log.d(" prdd_recurring : prdd_weekday_1 : Weekday Getting ON");
        }

        if (TextUtils.equals("", product.deliveryInfo.prdd_weekday_2)) {
            Calendar tuesday;
            for (int i = 0; i < (weeks * 7); i = i + 7) {
                tuesday = Calendar.getInstance();
                tuesday.add(Calendar.DAY_OF_YEAR, (Calendar.TUESDAY - tuesday.get(Calendar.DAY_OF_WEEK) + i));
                weekends.add(tuesday);
            }
            Calendar[] disabledDays = weekends.toArray(new Calendar[weekends.size()]);
            datePickerDialog.setDisabledDays(disabledDays);

        } else {
            Log.d(" prdd_recurring : prdd_weekday_2 : Weekday Getting ON");
        }

        if (TextUtils.equals("", product.deliveryInfo.prdd_weekday_3)) {

            Calendar wednesday;
            for (int i = 0; i < (weeks * 7); i = i + 7) {
                wednesday = Calendar.getInstance();
                wednesday.add(Calendar.DAY_OF_YEAR, (Calendar.WEDNESDAY - wednesday.get(Calendar.DAY_OF_WEEK) + i));
                weekends.add(wednesday);
            }
            Calendar[] disabledDays = weekends.toArray(new Calendar[weekends.size()]);
            datePickerDialog.setDisabledDays(disabledDays);

        } else {
            Log.d(" prdd_recurring : prdd_weekday_3 : Weekday Getting ON");
        }

        if (TextUtils.equals("", product.deliveryInfo.prdd_weekday_4)) {
            Calendar thursday;
            for (int i = 0; i < (weeks * 7); i = i + 7) {
                thursday = Calendar.getInstance();
                thursday.add(Calendar.DAY_OF_YEAR, (Calendar.THURSDAY - thursday.get(Calendar.DAY_OF_WEEK) + i));
                weekends.add(thursday);
            }
            Calendar[] disabledDays = weekends.toArray(new Calendar[weekends.size()]);
            datePickerDialog.setDisabledDays(disabledDays);

        } else {
            Log.d(" prdd_recurring : prdd_weekday_4 : Weekday Getting ON");
        }

        if (TextUtils.equals("", product.deliveryInfo.prdd_weekday_5)) {
            Calendar friday;
            for (int i = 0; i < (weeks * 7); i = i + 7) {
                friday = Calendar.getInstance();
                friday.add(Calendar.DAY_OF_YEAR, (Calendar.FRIDAY - friday.get(Calendar.DAY_OF_WEEK) + i));
                weekends.add(friday);
            }
            Calendar[] disabledDays = weekends.toArray(new Calendar[weekends.size()]);
            datePickerDialog.setDisabledDays(disabledDays);

        } else {
            Log.d(" prdd_recurring : prdd_weekday_5 : Weekday Getting ON");
        }

        if (TextUtils.equals("", product.deliveryInfo.prdd_weekday_6)) {
            Calendar saturday;
            for (int i = 0; i < (weeks * 7); i = i + 7) {
                saturday = Calendar.getInstance();
                saturday.add(Calendar.DAY_OF_YEAR, (Calendar.SATURDAY - saturday.get(Calendar.DAY_OF_WEEK) + i));
                weekends.add(saturday);
            }
            Calendar[] disabledDays = weekends.toArray(new Calendar[weekends.size()]);
            datePickerDialog.setDisabledDays(disabledDays);
        } else {
            Log.d(" prdd_recurring : prdd_weekday_6 : Weekday Getting ON");
        }
    }


    private String getDayNameByDate(String text, int mYear, int mMonth, int mDay) {
        Calendar cal = new GregorianCalendar(mYear, mMonth, mDay - 1);
        int dayOfWeek = cal.get(Calendar.DAY_OF_WEEK);
        Log.d(" mDay = " + mDay + " mMonth =" + mMonth + " mYear = " + mYear + " " + "date = " + cal + " result =" + dayOfWeek + " dayOfTheWeek =" + dayOfWeek + " Edittext == " + text);
        switch (dayOfWeek) {
            case 0:
                Log.d("Sunday");
                return "prdd_weekday_7";
            case 1:
                Log.d("Monday");
                return "prdd_weekday_1";
            case 2:
                Log.d("Tuesday");
                return "prdd_weekday_2";
            case 3:
                Log.d("Wednesday");
                return "prdd_weekday_3";
            case 4:
                Log.d("Thursday");
                return "prdd_weekday_4";
            case 5:
                Log.d("Friday");
                return "prdd_weekday_5";
            case 6:
                Log.d("Saturday");
                return "prdd_weekday_6";
            default:
                return "Worng Day";
        }
    }

    public void updateCartBadgeCount() {
        if (AppInfo.SHOW_CART_FOOTER_OVERLAY && !showAsDialog) {
            cart_section_Overlay_footer.setVisibility(View.VISIBLE);
            badge_section.setVisibility(View.GONE);
            text_item_cart.setText("0");
            text_total_cart.setText("0");
            footer_cart.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (onFragmentPopListener != null) {
                        onFragmentPopListener.onFragmentPoped(OnFragmentPopListener.CODE_BUY);
                    }
                }
            });

            if (txt_badgecount_cart == null)
                return;

            if (Cart.getItemCount() > 0) {
                text_item_cart.setVisibility(View.VISIBLE);
                text_total_cart.setVisibility(View.VISIBLE);
                badge_section.setVisibility(View.VISIBLE);

/*
                try {
                    int oldValue = Integer.parseInt(txt_badgecount_cart.getText().toString());
                    int newValue = Cart.getItemCount();
                    if (oldValue != newValue) {
                        new ScaleInOutHeartBeatAnimation(icon_badge_cart).setDuration(200).animate();
                    }
                } catch (Exception ignored) {
                }
*/

                txt_badgecount_cart.setText(String.valueOf(Cart.getItemCount()));
                text_item_cart.setText(String.valueOf(Cart.getItemCount()));
                text_total_cart.setText((HtmlCompat.fromHtml(Helper.appendCurrency(String.valueOf(Cart.getTotalPayment())))));
            } else {
                badge_section.setVisibility(View.GONE);
                text_item_cart.setText("0");
                text_total_cart.setText("0");
            }

        } else {
            cart_section_Overlay_footer.setVisibility(View.GONE);
        }
    }

    private void showComponentByBackOrdersManagingStock() {
        if (product.managing_stock) {
            if (product.backorders_allowed) {
                enableBuySection(getString(L.string.buy));
                textOutOfStock.setVisibility(View.GONE);
                textProductSalePrice.setVisibility(View.VISIBLE);

                if (selected_variationAttributes.size() >= considerableAttributeSize) {
                    updateProductPriceWithSelectedVariation();
                } else {
                    textProductSalePrice.setText(HtmlCompat.fromHtml(Helper.appendCurrency(product.getActualPrice(), product)));
                }
            }
        }
    }

    private void showReadOnlyAttributeOptionsSection() {
        if (product.extraAttributes.size() == 0) {
            mAdditionalInfoSection.setVisibility(View.GONE);
            return;
        }

        if (AppInfo.mProductDetailsConfig != null && !AppInfo.mProductDetailsConfig.show_additional_info) {
            mAdditionalInfoSection.setVisibility(View.GONE);
            return;
        }

        mAdditionalInfoSection.setVisibility(View.VISIBLE);
        additional_info_attribute_section.setVisibility(View.VISIBLE);
        for (int i = 0; i < product.extraAttributes.size(); i++) {
            int layoutResId = R.layout.item_readonly_attribute_options;
            if (ProductDetailsConfig.isEnabled() && AppInfo.mProductDetailsConfig.extra_attributes_layout_type.equals(ProductDetailsConfig.EXTRA_ATTRIBUTE_LAYOUT_VT)) {
                layoutResId = R.layout.item_readonly_attribute_options_vertical;
            }
            View view = LayoutInflater.from(activity).inflate(layoutResId, null);

            TextView text_attribute_name = view.findViewById(R.id.text_readonly_attribute_name);
            TM_Attribute attribute = product.extraAttributes.get(i);
            text_attribute_name.setText(HtmlCompat.fromHtml(attribute.name));

            StringBuilder optionsString = new StringBuilder();
            final int totalOptions = attribute.options.size();
            for (int j = 0; j < totalOptions; j++) {
                optionsString.append(attribute.getOptions().get(j));
                if (j < (totalOptions - 1)) {
                    optionsString.append("&nbsp;<strong>|</strong>&nbsp;");
                }
            }
            //Log.d("listAttributesOptions --> ", product.extraAttributes.get(i).toString() + " " + attribute.name);
            TextView text_attribute_options = view.findViewById(R.id.text_readonly_attribute_options);
            text_attribute_options.setText(HtmlCompat.fromHtml(optionsString.toString()));
            additional_info_attribute_section.addView(view);
        }
    }

    private void showRuntimeSections() {
        LinearLayout runtime_section = mRootView.findViewById(R.id.runtime_section);
        runtime_section.setVisibility(View.GONE);
        runtime_section.removeAllViews();
        if (ImageDownloaderConfig.isEnabled() && AppInfo.mImageDownloaderConfig.isShowInProdDetail()) {
            runtime_section.setVisibility(View.VISIBLE);
            Button btn_download = new Button(activity);
            btn_download.setText(getString(getString(L.string.download)));
            Helper.styleFlat(btn_download);
            btn_download.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
            runtime_section.addView(btn_download);
            btn_download.setOnClickListener(view -> {
                Toast.makeText(activity, getString(L.string.download_initiated), Toast.LENGTH_SHORT).show();
                ImageDownload.downloadProductCatalog(activity, product);
            });
        }

        if (ContactForm7Config.isEnabled()) {
            runtime_section.setVisibility(View.VISIBLE);
            Button btn_send_quote = new Button(activity);
            LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
            btn_send_quote.setText(getString(getString(L.string.send_quote)));
            btn_send_quote.setBackgroundColor(Color.parseColor("#1FCC99"));
            btn_send_quote.setLayoutParams(params);
            btn_send_quote.setOnClickListener(view -> {
                if (TextUtils.isEmpty(ContactForm7Config.getSubmitUrl())) {
                    // Update submit url if it is not provided in application addons configuration.
                    ContactForm7Config.setSubmitUrl(DataEngine.getDataEngine().getContactForm7Url());
                }
                FragmentManager fragmentManager = activity.getSupportFragmentManager();
                ContactFormDialog contactFormFragmentDialog = new ContactFormDialog();
                contactFormFragmentDialog.setProduct(product);
                contactFormFragmentDialog.show(fragmentManager, ContactFormDialog.class.getSimpleName());
            });
            Helper.styleFlat(btn_send_quote);
            runtime_section.addView(btn_send_quote);
        }

        if (product.type == TM_ProductInfo.ProductType.EXTERNAL) {
            runtime_section.setVisibility(View.VISIBLE);
            Button btn_visit_product = new Button(activity);
            btn_visit_product.setText(getString(getString(L.string.visit_product)));
            Helper.styleFlat(btn_visit_product);
            LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
            params.setMargins(0, Helper.DP(0), 0, Helper.DP(8));
            btn_visit_product.setLayoutParams(params);
            btn_visit_product.setOnClickListener(view -> Helper.openExternalLink(activity, product.product_url));
            runtime_section.addView(btn_visit_product);
        }

        if (AppInfo.mProductDetailsConfig.contact_numbers != null && !AppInfo.mProductDetailsConfig.contact_numbers.isEmpty()) {
            runtime_section.setVisibility(View.VISIBLE);

            final LinearLayout linearLayout = new LinearLayout(runtime_section.getContext());
            linearLayout.setGravity(Gravity.LEFT | Gravity.START);
            linearLayout.setOrientation(LinearLayout.VERTICAL);
            LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            lp.setMargins(DP(0), DP(5), DP(0), DP(5));

            Button textCall = new Button(runtime_section.getContext());
            Drawable callDrawable = ContextCompat.getDrawable(activity, R.drawable.ic_vc_call);
            int width = callDrawable.getIntrinsicWidth();
            textCall.setPadding(textCall.getPaddingLeft(),
                    textCall.getPaddingTop(), textCall.getPaddingRight() + width,
                    textCall.getPaddingBottom());
            callDrawable.setColorFilter(Color.WHITE, PorterDuff.Mode.SRC_IN);
            textCall.setCompoundDrawablesWithIntrinsicBounds(callDrawable, null, null, null);
            Helper.styleFlat(textCall);

            textCall.setText(getString(L.string.call));
            linearLayout.addView(textCall, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
            textCall.setOnClickListener(view -> {
                if (AppInfo.mProductDetailsConfig.contact_numbers.size() > 1) {
                    Helper.openCallDialog(activity, AppInfo.mProductDetailsConfig.contact_numbers);
                } else {
                    String phoneNumber = AppInfo.mProductDetailsConfig.contact_numbers.get(0);
                    Helper.callTo(activity, phoneNumber);
                }
            });
            runtime_section.addView(linearLayout, lp);
        }
    }

    private void initAuctionInfo() {
        cardViewAuction = (CardView) mRootView.findViewById(R.id.auction_info_section);

        if (!AppInfo.mProductDetailsConfig.show_auction_section) {
            cardViewAuction.setVisibility(View.GONE);
            return;
        }

        if (product.type != TM_ProductInfo.ProductType.AUCTION) {
            cardViewAuction.setVisibility(View.GONE);
            return;
        }
        cardViewAuction.setVisibility(View.GONE);

        View view = LayoutInflater.from(activity).inflate(R.layout.product_auction_info_layout, cardViewAuction, true);

        remaining_time_section = view.findViewById(R.id.remaining_time_section);
        title_remaining_time = view.findViewById(R.id.title_remaining_time);
        title_remaining_time.setText(getString(L.string.title_remaining_time));
        remaining_time_counter_section = view.findViewById(R.id.remaining_time_counter_section);
        text_remaining_time_month = view.findViewById(R.id.text_remaining_time_month);
        text_remaining_time_day = view.findViewById(R.id.text_remaining_time_days);
        text_remaining_time_hours = view.findViewById(R.id.text_remaining_time_hours);
        text_remaining_time_min = view.findViewById(R.id.text_remaining_time_min);
        text_remaining_time_sec = view.findViewById(R.id.text_remaining_time_sec);

        auction_item_condition_section = view.findViewById(R.id.auction_item_condition_section);
        TextView title_item_condition = view.findViewById(R.id.title_item_condition);
        title_item_condition.setText(getString(L.string.title_item_condition));
        text_item_condition = view.findViewById(R.id.text_item_condition);

        auction_ends_section = view.findViewById(R.id.auction_ends_section);
        TextView title_auction_ends = view.findViewById(R.id.title_auction_ends);
        title_auction_ends.setText(getString(L.string.title_auction_ends));
        text_auction_ends = view.findViewById(R.id.text_auction_ends);

        time_zone_section = view.findViewById(R.id.time_zone_section);
        TextView title_time_zone = view.findViewById(R.id.title_time_zone);
        title_time_zone.setText(getString(L.string.title_time_zone));
        text_time_zone = view.findViewById(R.id.text_time_zone);

        current_bid_section = view.findViewById(R.id.current_bid_section);
        TextView title_current_bid = view.findViewById(R.id.title_current_bid);
        title_current_bid.setText(getString(L.string.title_Current_bid));
        text_current_bid = view.findViewById(R.id.text_current_bid);

        bid_button_section = view.findViewById(R.id.bid_button_section);
        bid_button_section.setBackground(Helper.getButtonSectionBorder());
        LinearLayout bid_qty_section = view.findViewById(R.id.bid_qty_section);
        btn_bid_qty_plus = view.findViewById(R.id.btn_bid_qty_plus);
        Helper.stylizeVector(btn_bid_qty_plus);
        btn_bid_qty_minus = view.findViewById(R.id.btn_bid_qty_minus);
        Helper.stylizeVector(btn_bid_qty_minus);
        edit_bid_quantity = (EditText) view.findViewById(R.id.bid_quantity);
        TextView bid_currency = view.findViewById(R.id.bid_currency);
        bid_currency.setText(HtmlCompat.fromHtml(Helper.appendCurrency("")));
        btn_bid = view.findViewById(R.id.btn_bid);
        btn_bid.setText(getString(L.string.btn_bid));
        Helper.styleFlat(btn_bid);

        auction_history_section = view.findViewById(R.id.auction_history_section);
        txt_auction_history_detail = view.findViewById(R.id.txt_auction_history_detail);
        txt_auction_history_detail.setVisibility(View.GONE);
        TextView title_auction_history = view.findViewById(R.id.title_auction_history);
        title_auction_history.setText(getString(L.string.title_auction_history));
        auction_history_list_section = view.findViewById(R.id.auction_history_list_section);

        getProductAuctionInfo();
    }

    private void getProductAuctionInfo() {
        if (!AppInfo.mProductDetailsConfig.show_auction_section) {
            cardViewAuction.setVisibility(View.GONE);
            return;
        }

        if (product.type != TM_ProductInfo.ProductType.AUCTION) {
            cardViewAuction.setVisibility(View.GONE);
            return;
        }
        progress_fulldata.setVisibility(View.VISIBLE);
        DataEngine.getDataEngine().getProductAuctionInfo(new int[]{product.id}, product, new DataQueryHandler<TM_ProductInfo>() {
            @Override
            public void onSuccess(TM_ProductInfo data) {
                product = data;
                if (data.auctionInfo != null) {
                    updateAuctionSection();
                    cardViewAuction.setVisibility(View.VISIBLE);
                }
            }

            @Override
            public void onFailure(Exception reason) {
                reason.printStackTrace();
                Helper.showToast(coordinatorLayout, reason.getMessage());
                cardViewAuction.setVisibility(View.GONE);
                progress_fulldata.setVisibility(View.GONE);
            }
        });

    }

    private void updateAuctionSection() {
        if (!AppInfo.mProductDetailsConfig.show_auction_section) {
            cardViewAuction.setVisibility(View.GONE);
            return;
        }

        if (product.type != TM_ProductInfo.ProductType.AUCTION) {
            cardViewAuction.setVisibility(View.GONE);
            return;
        }

        if (product.auctionInfo == null) {
            cardViewAuction.setVisibility(View.GONE);
            return;
        }

        cardViewAuction.setVisibility(View.VISIBLE);

        if (!TextUtils.isEmpty(product.auctionInfo.auction_item_condition)) {
            text_item_condition.setText(product.auctionInfo.auction_item_condition);
        } else {
            auction_item_condition_section.setVisibility(View.GONE);
        }

        if (!TextUtils.isEmpty(product.auctionInfo.auction_dates_to)) {
            text_auction_ends.setText(product.auctionInfo.auction_dates_to);
        } else {
            auction_ends_section.setVisibility(View.GONE);
        }

        if (!TextUtils.isEmpty(product.auctionInfo.timezone)) {
            text_time_zone.setText(product.auctionInfo.timezone);
        } else {
            time_zone_section.setVisibility(View.GONE);
        }

        if (!TextUtils.isEmpty(product.auctionInfo.auction_current_bid)) {
            text_current_bid.setText(HtmlCompat.fromHtml(Helper.appendCurrency(product.auctionInfo.auction_current_bid)));
        } else if (!TextUtils.isEmpty(product.auctionInfo.auction_start_price)) {
            text_current_bid.setText(HtmlCompat.fromHtml(Helper.appendCurrency(product.auctionInfo.auction_start_price)));
        } else {
            current_bid_section.setVisibility(View.GONE);
        }

        if (product.auctionInfo.auctionHistoryList != null && !product.auctionInfo.auctionHistoryList.isEmpty() && product.auctionInfo.auctionHistoryList.size() > 0) {
            auction_history_section.setVisibility(View.VISIBLE);
            auction_history_list_section.setVisibility(View.VISIBLE);
            auction_history_list_section.removeAllViews();
            for (AuctionInfo.AuctionHistory auctionHistory : product.auctionInfo.auctionHistoryList) {
                String strHistoryDetail = getAuctionHistoryDetail(auctionHistory);
                if (!TextUtils.isEmpty(HtmlCompat.fromHtml(strHistoryDetail))) {
                    TextView title_auction_history_detail = (TextView) LayoutInflater.from(activity).inflate(R.layout.item_auction_history, null);
                    title_auction_history_detail.setText(HtmlCompat.fromHtml(strHistoryDetail));
                    auction_history_list_section.addView(title_auction_history_detail);
                }
            }
        } else {
            auction_history_section.setVisibility(View.GONE);
        }

        edit_bid_quantity.setText(!TextUtils.isEmpty(product.auctionInfo.auction_current_bid) ? product.auctionInfo.auction_current_bid : product.auctionInfo.auction_start_price);

        btn_bid_qty_plus.setOnClickListener(new ValueObserver(edit_bid_quantity, ValueObserver.Type.INCREASE, new ValueObserver.OnChangeCallback() {
            @Override
            public void onChange(int value) {
            }
        }, null));

        btn_bid_qty_minus.setOnClickListener(new ValueObserver(edit_bid_quantity, ValueObserver.Type.DECREASE, new ValueObserver.OnChangeCallback() {
            @Override
            public void onChange(int value) {
                if (!TextUtils.isEmpty(product.auctionInfo.auction_current_bid) && value < Integer.parseInt(product.auctionInfo.auction_current_bid)) {
                    Helper.showToast(coordinatorLayout, getString(L.string.error_bid_qty));
                    edit_bid_quantity.setText(product.auctionInfo.auction_current_bid);

                } else if (!TextUtils.isEmpty(product.auctionInfo.auction_start_price) && value < Integer.parseInt(product.auctionInfo.auction_start_price)) {
                    Helper.showToast(coordinatorLayout, getString(L.string.error_bid_qty));
                    edit_bid_quantity.setText(product.auctionInfo.auction_start_price);
                }
            }
        }, null));


        setCountDownTimer(product.auctionInfo.auction_dates_from, product.auctionInfo.auction_dates_to);

        btn_bid.setOnClickListener(v -> postBidData(edit_bid_quantity.getText().toString()));
    }

    private String getAuctionHistoryDetail(AuctionInfo.AuctionHistory auctionHistory) {
        try {
            DateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
            Date formattedDate = sdf.parse(auctionHistory.date);
            final Calendar calendarDate = Calendar.getInstance();
            calendarDate.setTime(formattedDate);

            Date date1 = calendarDate.getTime();
            SimpleDateFormat simpleDateFormat = new SimpleDateFormat("MMM,dd,yyyy hh:mm aaa");
            String finalDate = simpleDateFormat.format(date1);

            StringBuilder strHistoryDetail = new StringBuilder();
            strHistoryDetail.append("<b>" + L.getString(L.string.title_date) + "</b> " + finalDate);
            strHistoryDetail.append("&nbsp;<strong>|</strong>&nbsp;");
            strHistoryDetail.append("<b>" + L.getString(L.string.title_bid) + "</b> " + Helper.appendCurrency(auctionHistory.bid));
            strHistoryDetail.append("&nbsp;<strong>|</strong>&nbsp;");
            strHistoryDetail.append("<b>" + L.getString(L.string.title_user) + "</b> " + auctionHistory.username);
            return strHistoryDetail.toString();
        } catch (Exception e) {
            e.printStackTrace();
            return "";
        }
    }

    private void setCountDownTimer(String startDate, String endDate) {
        if (!TextUtils.isEmpty(startDate) && !TextUtils.isEmpty(endDate)) {
            try {
                DateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");

                final Calendar startCalendarDate = Calendar.getInstance();
                startCalendarDate.setTimeZone(TimeZone.getTimeZone(product.auctionInfo.timezone));
                startCalendarDate.setTime(sdf.parse(startDate));
                startCalendarDate.add(Calendar.MONTH, 1);

                final Calendar endCalendarDate = Calendar.getInstance();
                endCalendarDate.setTimeZone(TimeZone.getTimeZone(product.auctionInfo.timezone));
                endCalendarDate.setTime(sdf.parse(endDate));
                endCalendarDate.add(Calendar.MONTH, 1);

                final Calendar presentCalendar = Calendar.getInstance();
                presentCalendar.setTimeZone(TimeZone.getTimeZone(product.auctionInfo.timezone));
                presentCalendar.add(Calendar.MONTH, 1);
                presentCalendar.add(Calendar.DATE, -1);
                if (presentCalendar.after(endCalendarDate)) {
                    remaining_time_section.setVisibility(View.GONE);
                    remaining_time_counter_section.setVisibility(View.GONE);
                    bid_button_section.setVisibility(View.GONE);
                    txt_auction_history_detail.setVisibility(View.VISIBLE);
                    txt_auction_history_detail.setText(HtmlCompat.fromHtml("<b>" + getString(L.string.bid_finish) + "</b>"));
                    return;
                }

                long start_millis = presentCalendar.getTimeInMillis(); //get the start time in milliseconds
                long end_millis = endCalendarDate.getTimeInMillis(); //get the end time in milliseconds
                long total_millis = (end_millis - start_millis); //total time in milliseconds

                //1000 = 1 second interval
                CountDownTimer cdt = new CountDownTimer(total_millis, 1000) {
                    @Override
                    public void onTick(long millisUntilFinished) {

                        long days = TimeUnit.MILLISECONDS.toDays(millisUntilFinished);
                        millisUntilFinished -= TimeUnit.DAYS.toMillis(days);

                        long hours = TimeUnit.MILLISECONDS.toHours(millisUntilFinished);
                        millisUntilFinished -= TimeUnit.HOURS.toMillis(hours);

                        long minutes = TimeUnit.MILLISECONDS.toMinutes(millisUntilFinished);
                        millisUntilFinished -= TimeUnit.MINUTES.toMillis(minutes);

                        long seconds = TimeUnit.MILLISECONDS.toSeconds(millisUntilFinished);

                        text_remaining_time_day.setText(String.valueOf(days) + "\n" + getString(L.string.days)); //You can compute the millisUntilFinished on days
                        text_remaining_time_hours.setText(String.valueOf(hours) + "\n" + getString(L.string.hours)); //You can compute the millisUntilFinished on hours
                        text_remaining_time_min.setText(String.valueOf(minutes) + "\n" + getString(L.string.minutes)); //You can compute the millisUntilFinished on minutes
                        text_remaining_time_sec.setText(String.valueOf(seconds) + "\n" + getString(L.string.seconds)); //You can compute the millisUntilFinished on seconds
                    }

                    @Override
                    public void onFinish() {
                        text_remaining_time_month.setVisibility(View.GONE);
                    }
                };
                cdt.start();
            } catch (Exception e) {
                e.printStackTrace();
                remaining_time_counter_section.setVisibility(View.GONE);
            }
        } else {
            remaining_time_section.setVisibility(View.GONE);
        }
    }

    private void postBidData(String bid_quantity) {
        if (!AppInfo.mProductDetailsConfig.show_auction_section) {
            cardViewAuction.setVisibility(View.GONE);
            return;
        }

        if (product.type != TM_ProductInfo.ProductType.AUCTION) {
            cardViewAuction.setVisibility(View.GONE);
            return;
        }

        if (!AppUser.hasSignedIn()) {
            Helper.showToast(coordinatorLayout, getString(L.string.you_need_to_login_first));
            return;
        }

        AppUser appUser = AppUser.getInstance();
        progress_fulldata.setVisibility(View.VISIBLE);
        DataEngine.getDataEngine().requestProductAuctionBid(product, bid_quantity, appUser.email, new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {
                getProductAuctionInfo();
                Helper.showToast(coordinatorLayout, data.toString());
                updateAuctionSection();
            }

            @Override
            public void onFailure(Exception reason) {
                reason.printStackTrace();
                Helper.showToast(coordinatorLayout, reason.getMessage());
                progress_fulldata.setVisibility(View.GONE);
            }
        });
    }


    public void initBookingInfoSection() {
        bookingLayout = mRootView.findViewById(R.id.booking_info_section);

        if (!AppInfo.SHOW_PRODUCTS_BOOKING_INFO && product.type != TM_ProductInfo.ProductType.BOOKING) {
            bookingLayout.setVisibility(View.GONE);
            return;
        }

        bookingLayout.setVisibility(View.GONE);

        View view = LayoutInflater.from(activity).inflate(R.layout.product_booking_info_layout, bookingLayout, true);

        View separator_3 = view.findViewById(R.id.separator_3);
        separator_3.setBackgroundColor(Helper.getColorShade(AppInfo.normal_button_color, Shade.Shade50));

        //View separator_4 = view.findViewById(R.id.separator_4);
        //separator_4.setBackgroundColor(Helper.getColorShade(AppInfo.normal_button_color, Shade.Shade300));

        booking_info_date_section = view.findViewById(R.id.booking_info_date_section);
        booking_info_date_section.setBackground(Helper.getButtonSectionBorder());
        txt_booking_date = view.findViewById(R.id.txt_booking_date);
        txt_booking_date.setText(L.getString(L.string.hint_booking_date));
        Helper.setDrawableRight(txt_booking_date, R.drawable.ic_vc_calendar, Color.parseColor(AppInfo.selected_button_text_color));
        Helper.styleFlat(txt_booking_date);

        btn_check_booking_availability = view.findViewById(R.id.btn_check_booking_availability);
        btn_check_booking_availability.setText(getString(L.string.btn_check_booking_availability));
        btn_check_booking_availability.setVisibility(View.GONE);
        Helper.styleFlat(btn_check_booking_availability);

        booking_info_cost_section = view.findViewById(R.id.booking_info_cost_section);
        booking_info_cost_section.setBackground(Helper.getButtonSectionBorder());
        title_booking_cost = view.findViewById(R.id.title_booking_cost);
        title_booking_cost.setVisibility(View.GONE);

        btn_booking_wishlist = (ControllableCheckBox) view.findViewById(R.id.btn_booking_wishlist);
        Helper.setStyleWithDrawables(btn_booking_wishlist, R.drawable.ic_vc_wish_border, R.drawable.ic_vc_wish_selected);

        progress_bar_booking = view.findViewById(R.id.progress_bar_booking);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Helper.stylize(progress_bar_booking);
        } else {
            mRootView.findViewById(R.id.progress_bar_booking).setVisibility(View.GONE);
        }
        progress_bar_booking.setVisibility(View.GONE);
        getProductBookingInfo();
    }

    private void getProductBookingInfo() {
        if (!AppInfo.SHOW_PRODUCTS_BOOKING_INFO && product.type != TM_ProductInfo.ProductType.BOOKING) {
            bookingLayout.setVisibility(View.GONE);
            return;
        }

        progress_fulldata.setVisibility(View.VISIBLE);
        DataEngine.getDataEngine().getProductBookingInfoDate(product, new DataQueryHandler<TM_ProductInfo>() {
            @Override
            public void onSuccess(TM_ProductInfo data) {
                product = data;
                if (data.bookingInfo != null) {
                    updateBookingInfoSection();
                    showBookingLocationInfo();
                    bookingLayout.setVisibility(View.VISIBLE);
                }
                progress_fulldata.setVisibility(View.GONE);
            }

            @Override
            public void onFailure(Exception reason) {
                reason.printStackTrace();
                Helper.showToast(coordinatorLayout, reason.getMessage());
                bookingLayout.setVisibility(View.GONE);
                progress_fulldata.setVisibility(View.GONE);
            }
        });
    }

    private void showBookingLocationInfo() {
        try {
            if (product.productLocation != null) {
                double latitude = Double.parseDouble(product.productLocation.latitude);
                double longitude = Double.parseDouble(product.productLocation.longitude);
                if (latitude > 0 && longitude > 0) {
                    StringBuilder locationDetails = new StringBuilder("");
                    locationDetails.append("<strong>").append(getString(L.string.product_map_adress)).append("</strong> ").append(product.productLocation.address != null ? product.productLocation.address : "").append("<br/><br/>");
                    locationDetails.append("<strong>").append(getString(L.string.product_map_phone)).append("</strong> ").append(HtmlCompat.fromHtml(product.productLocation.phone != null ? product.productLocation.phone : "")).append("<br/><br/>");
                    locationDetails.append("<strong>").append(getString(L.string.product_map_email)).append("</strong> ").append(HtmlCompat.fromHtml(product.productLocation.email != null ? product.productLocation.email : "")).append("<br/><br/>");
                    locationDetails.append("<strong>").append(getString(L.string.product_map_website)).append("</strong> ").append(HtmlCompat.fromHtml(product.productLocation.website != null ? product.productLocation.website : ""));
                    Bundle bundle = new Bundle();
                    bundle.putDouble(Fragment_Product_MapInfo.ARGS_LATITUDE, latitude);
                    bundle.putDouble(Fragment_Product_MapInfo.ARGS_LONGITUDE, longitude);
                    bundle.putBoolean(Fragment_Product_MapInfo.ARGS_SHOW_TITLE, false);
                    bundle.putString(Fragment_Product_MapInfo.ARGS_LOCATION_DETAILS, locationDetails.toString());

                    fragment_product_mapInfo = new Fragment_Product_MapInfo();
                    fragment_product_mapInfo.setArguments(bundle);
                    fragment_product_mapInfo.onMapClickListener = new Fragment_Product_MapInfo.OnMapClickListener() {
                        @Override
                        public void onMapClick(boolean flag) {
                            scroll_view.requestDisallowInterceptTouchEvent(flag);
                        }
                    };
                    activity.getFM().beginTransaction().replace(R.id.product_map_layout, fragment_product_mapInfo).commit();
                }
            }
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }
    }

    @SuppressLint("ClickableViewAccessibility")
    private void updateBookingInfoSection() {
        if (!AppInfo.SHOW_PRODUCTS_BOOKING_INFO && product.type != TM_ProductInfo.ProductType.BOOKING) {
            bookingLayout.setVisibility(View.GONE);
            return;
        }

        if (product.bookingInfo == null) {
            bookingLayout.setVisibility(View.GONE);
            return;
        }
        bookingLayout.setVisibility(View.VISIBLE);

        buyCartSectionIsVisible = buy_cart_section_bottomLayout.getVisibility() != View.VISIBLE;

        if (AppInfo.SHOW_PRODUCTS_BOOKING_INFO && product.type == TM_ProductInfo.ProductType.BOOKING /*|| Cart.containsBookingProduct()*/) {
            buy_cart_sectionLayout.setVisibility(View.GONE);
            buy_cart_section_bottomLayout.setVisibility(View.GONE);
        }

        txt_booking_date.setOnClickListener(v -> showProductBookingDateDialog());
        txt_booking_date.setOnTouchListener((v, event) -> {
            if (event.getAction() == MotionEvent.ACTION_UP) {
                if (event.getRawX() >= (txt_booking_date.getRight() - txt_booking_date.getCompoundDrawables()[2].getBounds().width())) {
                    showProductBookingDateDialog();
                    return true;
                }
            }
            return false;
        });

        btn_booking_wishlist.setChecked(Wishlist.hasItem(product), false);

        btn_booking_wishlist.setOnCheckedChangeListener(new OnWishListClickListener());

        if (!product.bookingInfo.enable_addtocart) {
            btn_check_booking_availability.setVisibility(View.VISIBLE);
            btn_check_booking_availability.setOnClickListener(v -> buyProduct());

            buy_cart_sectionLayout.setVisibility(View.GONE);
            buy_cart_section_bottomLayout.setVisibility(View.GONE);
        } else {
            btn_check_booking_availability.setVisibility(View.GONE);
            if (AppInfo.SHOW_PRODUCTS_BOOKING_INFO && product.type == TM_ProductInfo.ProductType.BOOKING /*|| Cart.containsBookingProduct()*/) {
                if (buyCartSectionIsVisible) {
                    buy_cart_sectionLayout.setVisibility(View.VISIBLE);
                } else {
                    buy_cart_section_bottomLayout.setVisibility(View.VISIBLE);
                }
            }
        }
    }

    private void showProductBookingDateDialog() {
        if (!AppInfo.SHOW_PRODUCTS_BOOKING_INFO && product.type != TM_ProductInfo.ProductType.BOOKING) {
            bookingLayout.setVisibility(View.GONE);
            return;
        }

        if (product.bookingInfo == null) {
            bookingLayout.setVisibility(View.GONE);
            return;
        }
        bookingLayout.setVisibility(View.VISIBLE);

        final Calendar calendar = Calendar.getInstance();
        DatePickerDialog datePickerDialog = DatePickerDialog.newInstance(
                new DatePickerDialog.OnDateSetListener() {
                    @Override
                    public void onDateSet(DatePickerDialog view, int year, int monthOfYear, int dayOfMonth) {
                        //TODO don't use unformatted string in case of date or time. Date format is mm/dd/yyyy
                        String pickedDataString = String.format(Locale.US, "%02d/%02d/%d", (monthOfYear + 1), dayOfMonth, year);
                        txt_booking_date.setText(pickedDataString);
                        product.selectedBookingDate = txt_booking_date.getText().toString();
                        if (!ArrayUtils.isEmpty(product.bookingInfo.partially_booked_days)) {
                            try {
                                List<Calendar> list = Arrays.asList(product.bookingInfo.partially_booked_days);
                                Calendar calendar = Calendar.getInstance();
                                DateFormat sdf = new SimpleDateFormat("MM/dd/yyyy");
                                Date date = sdf.parse(pickedDataString);
                                calendar.setTime(date);

                                if (list.contains(calendar)) {
                                    Helper.showToast(getString(L.string.msg_partially_booking_date));
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }

                        if (!TextUtils.isEmpty(product.selectedBookingDate)) {
                            getProductBookingInfoCost(product.selectedBookingDate);
                        }
                    }
                },
                calendar.get(Calendar.YEAR),
                calendar.get(Calendar.MONTH),
                calendar.get(Calendar.DAY_OF_MONTH)
        );
        datePickerDialog.setTitle(getString(L.string.title_select_booking_date_dialog));

        datePickerDialog.setOkText(getString(L.string.ok));

        datePickerDialog.setCancelText(getString(L.string.cancel));

        datePickerDialog.show(activity.getFragmentManager(), DatePickerDialog.class.getSimpleName());

        datePickerDialog.setMinDate(calendar);
        datePickerDialog.setAccentColor(AppInfo.color_theme);

        Calendar endDateCalendar = Calendar.getInstance();
        endDateCalendar.setTime(product.bookingInfo.end_date);
        datePickerDialog.setMaxDate(endDateCalendar);

        if (product.bookingInfo.partially_booked_days != null && product.bookingInfo.partially_booked_days.length > 0) {
            datePickerDialog.setHighlightedDays(product.bookingInfo.partially_booked_days);
        }

        if (product.bookingInfo.fully_booked_days != null && product.bookingInfo.fully_booked_days.length > 0) {
            datePickerDialog.setDisabledDays(product.bookingInfo.fully_booked_days);
        }
        if (product.bookingInfo.buffer_days != null && product.bookingInfo.buffer_days.length > 0) {
            datePickerDialog.setDisabledDays(product.bookingInfo.buffer_days);
        }
    }

    public void getProductBookingInfoCost(String bookingDate) {
        // only booking type of products are allowed
        if (!AppInfo.SHOW_PRODUCTS_BOOKING_INFO && product.type != TM_ProductInfo.ProductType.BOOKING) {
            bookingLayout.setVisibility(View.GONE);
            return;
        }

        if (product.bookingInfo == null) {
            bookingLayout.setVisibility(View.GONE);
            return;
        }
        bookingLayout.setVisibility(View.VISIBLE);

        progress_bar_booking.setVisibility(View.VISIBLE);
        title_booking_cost.setVisibility(View.GONE);
        DataEngine.getDataEngine().getProductBookingInfoCost(product, bookingDate, new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {
                progress_bar_booking.setVisibility(View.GONE);
                if (product.bookingInfo != null) {
                    if (product.bookingInfo.result.equalsIgnoreCase("success")) {
                        if (product.bookingInfo.product_id_booking == product.id) {
                            title_booking_cost.setVisibility(View.VISIBLE);
                            title_booking_cost.setText(String.format(Locale.getDefault(), getString(L.string.title_booking_cost), HtmlCompat.fromHtml(Helper.appendCurrency(product.bookingInfo.booking_price))));

                            product.selectedBookingCost = product.bookingInfo.booking_price;
                        }
                    } else {
                        Helper.toast(coordinatorLayout, product.bookingInfo.error);
                    }
                }
            }

            @Override
            public void onFailure(Exception e) {
                progress_bar_booking.setVisibility(View.GONE);
                title_booking_cost.setVisibility(View.GONE);
                e.printStackTrace();
            }
        });
    }

    private void initDepositInfoSection() {
        section_deposit_info = mRootView.findViewById(R.id.deposit_info_section);
        section_deposit_info.setVisibility(View.GONE);

        if (!AppInfo.ENABLE_DEPOSIT_ADDONS) {
            return;
        }

        View view = LayoutInflater.from(activity).inflate(R.layout.product_deposit_info_layout, section_deposit_info);

        title_deposit_label = view.findViewById(R.id.title_deposit_label);
        title_deposit_label.setHint(L.getString(L.string.label_deposit_percent));

        btn_pay_deposit = view.findViewById(R.id.btn_pay_deposit);
        btn_pay_deposit.setText(getString(L.string.pay_deposit));
        btn_pay_deposit.setVisibility(View.GONE);
        Helper.styleFlat(btn_pay_deposit);

        btn_pay_full = view.findViewById(R.id.btn_pay_full);
        btn_pay_full.setText(getString(L.string.pay_full));
        btn_pay_full.setVisibility(View.GONE);
        Helper.styleFlat(btn_pay_full);

        title_deposit_message = view.findViewById(R.id.title_deposit_message);
        title_deposit_message.setHint(L.getString(L.string.message_deposit_full));
        updateDepositInfoSection();
    }

    private void updateDepositInfoSection() {
        if (!AppInfo.ENABLE_DEPOSIT_ADDONS || product.depositInfo == null) {
            section_deposit_info.setVisibility(View.GONE);
            return;
        }

        if (!TextUtils.isEmpty(product.depositInfo.deposit_amount) && !TextUtils.isEmpty(product.depositInfo.deposit_type) && product.depositInfo.deposit_price >= 0) {
            section_deposit_info.setVisibility(View.VISIBLE);

            String stringLabel = "";
            if (product.depositInfo.deposit_type.equalsIgnoreCase("percent")) {
                stringLabel = L.string.label_deposit_percent;
            } else if (product.depositInfo.deposit_type.equalsIgnoreCase("fixed")) {
                stringLabel = L.string.label_deposit_fixed;
            }
            title_deposit_label.setText(HtmlCompat.fromHtml(String.format(getString(stringLabel, true), Helper.appendCurrency(product.depositInfo.deposit_price))));

            title_deposit_message.setText(getString(L.string.message_deposit_full));

            if (TextUtils.isEmpty(product.depositInfo.checkCartDepositType)) {
                product.depositInfo.checkCartDepositType = DepositInfo.PAY_FULL_DEPOSIT;
            }

            if (product.depositInfo.cartDepositAmount == 0) {
                product.depositInfo.cartDepositAmount = product.depositInfo.full_price;
            }

            btn_pay_deposit.setVisibility(View.VISIBLE);
            btn_pay_deposit.setOnClickListener(v -> {
                Helper.styleFlatSelected(btn_pay_deposit);
                Helper.styleFlat(btn_pay_full);
                product.depositInfo.checkCartDepositType = DepositInfo.PAY_DEPOSIT;
                product.depositInfo.cartDepositAmount = product.depositInfo.deposit_price;
                title_deposit_message.setText(getString(L.string.message_deposit));
            });
            btn_pay_full.setVisibility(View.VISIBLE);
            btn_pay_full.setOnClickListener(v -> {
                Helper.styleFlatSelected(btn_pay_full);
                Helper.styleFlat(btn_pay_deposit);
                product.depositInfo.checkCartDepositType = DepositInfo.PAY_FULL_DEPOSIT;
                product.depositInfo.cartDepositAmount = product.depositInfo.full_price;
                title_deposit_message.setText(getString(L.string.message_deposit_full));
            });
        }
    }

    private CardView section_product_addons;
    private LinearLayout product_addons_expand_section;
    private TextView title_product_addons_expand;
    private ImageView product_addons_expand_img;
    private ImageView option_measurements_img;
    private LinearLayout product_addons_option_section_main;
    private LinearLayout product_addons_option_section;
    private boolean collapseProductAddons;
    private ArrayList<EditText> productAddonsTextFields;

    private void initProductAddonsSection() {
        section_product_addons = (CardView) mRootView.findViewById(R.id.product_addons_section);
        section_product_addons.setVisibility(View.GONE);


        if (!AppInfo.ENABLE_PRODUCT_ADDONS) {
            return;
        }

        View view = LayoutInflater.from(activity).inflate(R.layout.product_addons_layout, section_product_addons, true);
        product_addons_expand_section = view.findViewById(R.id.product_addons_expand_section);
        title_product_addons_expand = view.findViewById(R.id.title_product_addons_expand);
        product_addons_expand_img = view.findViewById(R.id.expand_img);
        option_measurements_img = view.findViewById(R.id.option_measurements_img);
        product_addons_option_section_main = view.findViewById(R.id.product_addons_option_section);
        product_addons_option_section = view.findViewById(R.id.option_section);

        showProductAddonsSection();
    }

    private void showProductAddonsSection() {
        if (!AppInfo.ENABLE_PRODUCT_ADDONS
                || product.productAddons == null
                || product.productAddons.group_addon == null
                || product.productAddons.group_addon.length <= 0) {
            section_product_addons.setVisibility(View.GONE);
            return;
        }

        section_product_addons.setVisibility(View.VISIBLE);

        ProductAddons.GroupAddon groupAddon = product.productAddons.group_addon[0];
        title_product_addons_expand.setText(HtmlCompat.fromHtml(groupAddon.label));
        Glide.with(activity)
                .load(groupAddon.image)
                .error(R.drawable.error_product)
                .into(option_measurements_img);

        product_addons_option_section.removeAllViews();
        if (!ArrayUtils.isEmpty(groupAddon.options)) {
            if (productAddonsTextFields != null)
                productAddonsTextFields.clear();
            else
                productAddonsTextFields = new ArrayList<>();

            for (int i = 0; i < groupAddon.options.length; i++) {
                ProductAddons.GroupAddon.Option option = groupAddon.options[i];
                boolean required = option.required;
                View view = LayoutInflater.from(activity).inflate(R.layout.product_addons_options_layout, product_addons_option_section, false);
                TextInputLayout textInputLayout = (TextInputLayout) view.findViewById(R.id.label_option);
                textInputLayout.setHint(HtmlCompat.fromHtml(option.label).toString());
                Helper.stylize(textInputLayout);

                EditText editText_option = (EditText) view.findViewById(R.id.option);
                editText_option.setTag(i);
                //Helper.setDrawableLeft(editText_option, R.drawable.ic_vc_alert, Color.RED);
                productAddonsTextFields.add(editText_option);

                TextView text_options_price = view.findViewById(R.id.option_price);
                text_options_price.setVisibility(View.GONE);
//                    String finalPrice;
//                    if (!TextUtils.isEmpty(options.price)) {
//                        finalPrice = "+" + HtmlCompat.fromHtml(Helper.appendCurrency(options.price)).toString();
//                    } else {
//                        finalPrice = "+" + HtmlCompat.fromHtml(Helper.appendCurrency("00")).toString();
//                    }
//                    text_options_price.setText(finalPrice);
                product_addons_option_section.addView(view);
            }
        }

        product_addons_expand_section.setOnClickListener(v -> {
            if (collapseProductAddons && product_addons_option_section_main.getVisibility() == View.GONE) {
                collapseProductAddons = false;
                product_addons_option_section_main.setVisibility(View.VISIBLE);
                product_addons_expand_img.setImageDrawable(CContext.getDrawable(activity, R.drawable.ic_vc_down));

            } else {
                collapseProductAddons = true;
                product_addons_option_section_main.setVisibility(View.GONE);
                product_addons_expand_img.setImageDrawable(CContext.getDrawable(activity, R.drawable.ic_vc_up));
            }
        });
    }
}