package com.twist.tmstore.fragments;

import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.os.Bundle;
import android.support.design.widget.TextInputLayout;
import android.support.v7.app.AlertDialog;
import android.support.v7.widget.CardView;
import android.support.v7.widget.RecyclerView;
import android.text.InputFilter;
import android.text.InputType;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.Spinner;
import android.widget.TextView;

import com.twist.dataengine.DataEngine;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.entities.TM_CommonInfo;
import com.twist.dataengine.entities.TM_Coupon;
import com.twist.dataengine.entities.TM_Order;
import com.twist.dataengine.entities.TM_PaymentGateway;
import com.twist.dataengine.entities.TM_Region;
import com.twist.dataengine.entities.TM_Response;
import com.twist.dataengine.entities.TM_Shipping;
import com.twist.dataengine.entities.TM_Shipping_Pickup_Location;
import com.twist.dataengine.entities.TM_StoreInfo;
import com.twist.dataengine.entities.TM_Tax;
import com.twist.oauth.NetworkRequest;
import com.twist.oauth.NetworkResponse;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.BuildConfig;
import com.twist.tmstore.Constants;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.Adapter_HtmlString;
import com.twist.tmstore.adapters.Adapter_PaymentGateway;
import com.twist.tmstore.adapters.ShippingMetaAdapter;
import com.twist.tmstore.config.GuestUserConfig;
import com.twist.tmstore.config.TimeSlotConfig;
import com.twist.tmstore.dialogs.ShippingMethodPickupLocationDialog;
import com.twist.tmstore.entities.Address;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.entities.AppliedCoupon;
import com.twist.tmstore.entities.Cart;
import com.twist.tmstore.entities.CartMeta;
import com.twist.tmstore.entities.DateTimeSlot;
import com.twist.tmstore.entities.DummyUser;
import com.twist.tmstore.entities.FeeData;
import com.twist.tmstore.entities.MinOrderData;
import com.twist.tmstore.entities.PickupLocation;
import com.twist.tmstore.entities.TimeSlot;
import com.twist.tmstore.listeners.LoginListener;
import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.PaymentManager;
import com.twist.tmstore.payments.gateways.CashOnDeliveryGateway;
import com.twist.tmstore.payments.gateways.CashOnPickupGateway;
import com.twist.tmstore.payments.gateways.WebPayGateway;
import com.twist.tmstore.views.DividerItemDecorationView;
import com.utils.AnalyticsHelper;
import com.utils.ArrayUtils;
import com.utils.Base64Utils;
import com.utils.CContext;
import com.utils.DataHelper;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.JsonUtils;
import com.utils.ListUtils;
import com.utils.Log;
import com.utils.TaxHelper;
import com.wdullaer.materialdatetimepicker.date.DatePickerDialog;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import static com.utils.StringUtils._STRING_;

public class PaymentFragment extends BaseFragment {
    private RadioGroup radioGroupShipping;
    private Spinner spinnerTimeSlots;
    private TextView textTotalPayment;
    private TextView txt_total_basic;
    private TextView textTotalTaxes;
    private TextView textErrorMessage;
    private TextView textShippingTitle;
    private ImageButton buttonSelectDate;
    private ImageButton buttonSelectTime;

    private CardView error_section;
    private TextView text_error;
    private TM_Order currentOrder;
    private Button btn_proceed;

    private List<TM_Shipping> shippingMethods = new ArrayList<>();
    private List<FeeData> feeDatas = new ArrayList<>();
    private CartMeta cartMeta;
    private MinOrderData minOrder = null;

    //private int checkedGatewayId = -1;
    private String checkedGatewayId = null;
    private int checkedShippingId = -1;

    private boolean shippingFound = false;
    private View mRootView;

    private View shipping_section;
    private LinearLayout fee_data_section;
    private LinearLayout cart_meta_section;
    private View payment_options_section;
    private View meta_section_group;
    private View cart_tax_section;
    private EditText editOrderNote;
    private View deliverySlotsSection;

    private DatePickerDialog timeSlotPickerDialog;
    private TextView textSelectDate;
    private View dateSlotSection;
    private View timeSlotSection;

    private RecyclerView deliveryInfoRecyclerView;

    private double shippingCost;
    private List<TM_Shipping> shippingList;
    private String shippingString;
    private String mMetaDataString;
    private String mSelectedDeliveryTypeId;

    private View cart_checkout_note_section;
    private TextView title_cart_checkout_note;
    private CardView cardview_checkout_addon;
    private CheckBox checkbox_checkout_addon;
    private CompoundButton lastCheckedRB = null;
    private LinearLayout paymentOptionsLayout;

    private AlertDialog alertOtpDialog;
    private AlertDialog alertDialogDummyUserUpdate;

    private TimeSlot selectedTimeSlot;
    private DateTimeSlot selectedDateTimeSlot;
    private List<TimeSlot> availableTimeSlots;
    private Map<String, List<DateTimeSlot>> shippingDateTimeSlotsMap;
    private boolean timeSlotsFound = false;

    private CardView pickup_location_section;

    CardView shipping_pickup_location_section;
    TextView title_shipping_pickup_location;
    TextView text_shipping_pickup_location;
    private String pickup_location_id = "-1";

    private int registerOrderBookingID = 0;
    private boolean orderBooking;

    public PaymentFragment() {
    }

    public static PaymentFragment newInstance(String[] args) {
        PaymentFragment fragment = new PaymentFragment();
        if (args != null) {
            if (args.length != 0)
                fragment.mMetaDataString = args[0];
            if (args.length == 2)
                fragment.mSelectedDeliveryTypeId = args[1];
        }
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        mRootView = inflater.inflate(R.layout.fragment_payment, container, false);
        initComponents(mRootView);
        getOrderForPayment();
        updateBasicSection();
        updateTotalSection();
        updatePaymentGateways();
        syncCartItems();
        setLocalityInfo();
        return mRootView;
    }

    void initComponents(View rootView) {
        setTitle(L.string.select_payment);
        fee_data_section = rootView.findViewById(R.id.fee_data_section);
        cart_meta_section = rootView.findViewById(R.id.cart_meta_section);
        meta_section_group = rootView.findViewById(R.id.cart_meta_section_view);
        meta_section_group.setVisibility(View.GONE);
        cart_tax_section = rootView.findViewById(R.id.cart_tax_section);
        cart_tax_section.setVisibility(View.GONE);

        CardView cart_summary_section = rootView.findViewById(R.id.cart_summary_section);
        LinearLayout grand_total_layout = rootView.findViewById(R.id.grand_total_layout);

        radioGroupShipping = rootView.findViewById(R.id.radio_group_shipping);
        textErrorMessage = rootView.findViewById(R.id.text_error_message);
        textErrorMessage.setVisibility(View.GONE);
        textShippingTitle = rootView.findViewById(R.id.text_shipping_title);
        shipping_section = rootView.findViewById(R.id.shipping_section);
        shipping_section.setVisibility(View.GONE);

        txt_total_basic = rootView.findViewById(R.id.txt_total_basic);
        textTotalPayment = rootView.findViewById(R.id.txt_totalpayment);
        textTotalTaxes = rootView.findViewById(R.id.text_total_taxes);

        payment_options_section = rootView.findViewById(R.id.payment_options_section);
        payment_options_section.setVisibility(View.GONE);
        paymentOptionsLayout = rootView.findViewById(R.id.payment_options_layout);

        // Delivery slot section components
        TextView title_available_time_slots = rootView.findViewById(R.id.title_available_time_slots);
        title_available_time_slots.setText(getString(L.string.title_available_time_slots));

        deliverySlotsSection = rootView.findViewById(R.id.section_delivery_slots);
        deliverySlotsSection.setVisibility(View.GONE);

        dateSlotSection = rootView.findViewById(R.id.section_date_slot);
        dateSlotSection.setVisibility(View.GONE);

        timeSlotSection = rootView.findViewById(R.id.section_time_slot);
        timeSlotSection.setVisibility(View.GONE);

        buttonSelectDate = rootView.findViewById(R.id.button_select_date);
        Helper.stylizeVector(buttonSelectDate);

        textSelectDate = rootView.findViewById(R.id.text_select_date);
        textSelectDate.setText(getString(L.string.select_date));

        buttonSelectTime = rootView.findViewById(R.id.button_select_time);
        Helper.stylizeVector(buttonSelectTime);

        spinnerTimeSlots = rootView.findViewById(R.id.spinner_time_slots);

        // Order note section components
        editOrderNote = rootView.findViewById(R.id.edit_order_note);
        editOrderNote.setHint(getString(L.string.order_note_placeholder));
        Helper.stylize(editOrderNote, false);

        ImageView iconOrderNote = rootView.findViewById(R.id.icon_order_note);
        Helper.stylizeVector(iconOrderNote);

        cart_checkout_note_section = rootView.findViewById(R.id.cart_checkout_note_section);
        cart_checkout_note_section.setVisibility(View.GONE);

        title_cart_checkout_note = rootView.findViewById(R.id.title_cart_checkout_note);

        cardview_checkout_addon = rootView.findViewById(R.id.cardview_checkout_addon);
        cardview_checkout_addon.setVisibility(View.GONE);
        checkbox_checkout_addon = rootView.findViewById(R.id.checkbox_checkout_addon);
        Helper.stylize(checkbox_checkout_addon);
        checkbox_checkout_addon.setChecked(false);
        checkbox_checkout_addon.setVisibility(View.GONE);

        if (AppInfo.HIDE_PRODUCT_PRICE_TAG) {
            cart_summary_section.setVisibility(View.GONE);
            grand_total_layout.setVisibility(View.GONE);
        } else {
            cart_summary_section.setVisibility(View.VISIBLE);
            grand_total_layout.setVisibility(View.VISIBLE);
        }

        View orderNoteSectionView = rootView.findViewById(R.id.section_order_note);
        if (AppInfo.mOrderNoteConfig == null || !AppInfo.mOrderNoteConfig.isEnabled()) {
            orderNoteSectionView.setVisibility(View.GONE);
        } else {
            orderNoteSectionView.setVisibility(View.VISIBLE);
            if (Helper.isValidString(AppInfo.mOrderNoteConfig.getCharType())) {
                switch (AppInfo.mOrderNoteConfig.getCharType()) {
                    case "numeric":
                        editOrderNote.setInputType(InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_FLAG_DECIMAL);
                        break;
                    case "alphanumeric":
                        editOrderNote.setInputType(InputType.TYPE_TEXT_VARIATION_PERSON_NAME);
                        break;
                    default:
                        editOrderNote.setInputType(InputType.TYPE_NULL);
                        Log.d("Please check char_type in order note configuration.");
                        break;
                }
            }

            if (AppInfo.mOrderNoteConfig.getCharLimit() > 0) {
                InputFilter[] filterArray = new InputFilter[1];
                filterArray[0] = new InputFilter.LengthFilter(AppInfo.mOrderNoteConfig.getCharLimit());
                editOrderNote.setFilters(filterArray);
            }
        }

        this.setTextOnView(rootView, R.id.cart_totals, L.string.cart_totals);
        this.setTextOnView(rootView, R.id.title_meta_section_group, L.string.title_meta_section_group);
        this.setTextOnView(rootView, R.id.text_shipping_title, L.string.title_shipping_section);
        this.setTextOnView(rootView, R.id.title_cart_summary, L.string.title_cart_summary);
        this.setTextOnView(rootView, R.id.label_total_taxes, L.string.label_total_taxes);
        this.setTextOnView(rootView, R.id.title_order_note, L.string.order_note);

        error_section = rootView.findViewById(R.id.error_section);
        error_section.setVisibility(View.GONE);
        text_error = rootView.findViewById(R.id.text_error);
        text_error.setTextColor(CContext.getColor(getContext(), R.color.white));
        text_error.setVisibility(View.GONE);

        radioGroupShipping.setOnCheckedChangeListener((group, checkedId) -> {
            if (checkedId != -1) {
                checkedShippingId = checkedId;
                TM_Shipping tm_shipping = shippingMethods.get(checkedShippingId);
                if (tm_shipping.id.equalsIgnoreCase("local_pickup_plus") && !tm_shipping.locations.isEmpty() && tm_shipping.locations.size() > 0) {
                    showPickupLocation(tm_shipping);
                } else {
                    shipping_pickup_location_section.setVisibility(View.GONE);
                }

                String methodId = tm_shipping.method_id;
                if (shippingDateTimeSlotsMap != null) {
                    try {
                        selectedTimeSlot = null;
                        setDeliverySlotsData(shippingDateTimeSlotsMap.get(methodId));
                        setDeliverySlotsUIVisibility(timeSlotsFound);
                        addTimeSlotFee();
                        updateFeeDataUI();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                updatePaymentOptions();
                updateTotalSection();
            }
        });

        if (TimeSlotConfig.isEnabled()) {
            spinnerTimeSlots.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
                @Override
                public void onItemSelected(AdapterView<?> adapterView, View view, int selectedId, long id) {
                    if (selectedId >= 0) {
                        selectedTimeSlot = (TimeSlot) adapterView.getItemAtPosition(selectedId);
                        if (shippingDateTimeSlotsMap != null) {
                            addTimeSlotFee();
                            updateFeeDataUI();
                        }
                        updateTotalSection();
                    }
                }

                @Override
                public void onNothingSelected(AdapterView<?> adapterView) {
                }
            });
        }

        btn_proceed = rootView.findViewById(R.id.btn_proceed);
        btn_proceed.setText(getString(L.string.proceed));
        btn_proceed.setEnabled(false);
        btn_proceed.setOnClickListener(v -> performProceed());
        Helper.stylize(btn_proceed);

        TextView textViewGrandTotal = rootView.findViewById(R.id.grand_total);
        textViewGrandTotal.setText(getString(L.string.grand_total));

        TextView textViewPaymentOptions = rootView.findViewById(R.id.available_payment_options);
        textViewPaymentOptions.setText(getString(L.string.available_payment_options));

        deliveryInfoRecyclerView = rootView.findViewById(R.id.delivery_info_recycler_view);

        pickup_location_section = rootView.findViewById(R.id.pickup_location_section);
        pickup_location_section.setVisibility(View.GONE);

        shipping_pickup_location_section = (CardView) rootView.findViewById(R.id.shipping_pickup_location_section);
        shipping_pickup_location_section.setVisibility(View.GONE);
        title_shipping_pickup_location = (TextView) rootView.findViewById(R.id.title_shipping_pickup_location);
        title_shipping_pickup_location.setText(getString(L.string.title_shipping_pickup_location));
        text_shipping_pickup_location = (TextView) rootView.findViewById(R.id.text_shipping_pickup_location);
    }

    private void updatePaymentGateways() {
        this.updatePaymentGateways(true);
    }

    private void updatePaymentGateways(boolean hideProgress) {
        PaymentManager.INSTANCE.initialize(new PaymentGateway.PaymentListener() {
            @Override
            public void onPaymentSucceed(int orderId) {
                if (hideProgress) {
                    hideProgress();
                }
                //PaymentGateway paymentGateway = PaymentManager.INSTANCE.getPaymentGateway(checkedGatewayId);
                PaymentGateway paymentGateway = PaymentManager.INSTANCE.getPaymentGateway(checkedGatewayId);
                if (paymentGateway instanceof WebPayGateway) {
                    ((MainActivity) requireActivity()).generateOrderReceipt(orderId, paymentGateway, selectedTimeSlot);
                } else {
                    updateOrderStatusInBackground(currentOrder, paymentGateway);
                    try {
                        AnalyticsHelper.registerOrderEvent(currentOrder, true);
                    } catch (Exception ignored) {
                    }
                }
            }

            @Override
            public void onPaymentFailed() {
                hideProgress();
                MainActivity.mActivity.generateOrderFailure("");
                try {
                    AnalyticsHelper.registerOrderEvent(currentOrder, false);
                } catch (Exception ignored) {
                }
            }
        }, requireActivity());
    }

    void updatePaymentOptions() {
        boolean isLocalPickupSelected = false;
        if (checkedShippingId >= 0 && !ListUtils.isEmpty(shippingMethods)) {
            String methodId = shippingMethods.get(checkedShippingId).method_id;
            isLocalPickupSelected = methodId.equalsIgnoreCase("local_pickup");
        }

        List<PaymentGateway> allPaymentGateways = PaymentManager.INSTANCE.getAllPaymentGateway();
        List<PaymentGateway> paymentGateways = new ArrayList<>();
        if (allPaymentGateways.size() > 0) {
            for (PaymentGateway paymentGateway : allPaymentGateways) {
                boolean enabled = true;
                // Check for Local Pickup settings.
                if (isLocalPickupSelected) {
                    enabled = !(paymentGateway instanceof CashOnDeliveryGateway);

                } else {
                    if (paymentGateway instanceof CashOnDeliveryGateway) {
                        TM_PaymentGateway.GatewaySettings gatewaySettings = paymentGateway.getGatewaySettings();
                        if (gatewaySettings != null) {
                            try {
                                // Check for PinCode Settings
                                if (!TextUtils.isEmpty(gatewaySettings.cod_pincodes)) {
                                    String[] pinCodes = gatewaySettings.cod_pincodes.split(",");
                                    String pinCode = AppUser.getShippingAddress().postcode;
                                    enabled = ArrayUtils.contains(pinCodes, pinCode);
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                                Log.e("Error in PinCode for cash on delivery");
                            }

                            // Check for cash on delivery min max price
                            if (!TextUtils.isEmpty(gatewaySettings.min_amount) && !TextUtils.isEmpty(gatewaySettings.max_amount)) {
                                try {
                                    float minPrice = Float.parseFloat(gatewaySettings.min_amount);
                                    float maxPrice = Float.parseFloat(gatewaySettings.max_amount);
                                    float grandTotal = calculateGrandTotal();
                                    enabled = (grandTotal >= minPrice && grandTotal <= maxPrice);
                                } catch (Exception e) {
                                    e.printStackTrace();
                                    Log.e("Error in min and max price for cash on delivery");
                                }
                            }
                        }
                    } else if (paymentGateway instanceof CashOnPickupGateway) {
                        enabled = false;
                    }
                }
                paymentGateway.setEnabled(enabled);
                if (enabled) {
                    paymentGateways.add(paymentGateway);
                } else {
                    checkedGatewayId = null;
                }
            }
        }

        Adapter_PaymentGateway adapter = new Adapter_PaymentGateway(paymentGateways);
        adapter.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (lastCheckedRB != null) {
                lastCheckedRB.setChecked(false);
            }
            lastCheckedRB = buttonView;
            checkedGatewayId = (String) buttonView.getTag();
            updateTotalSection();
        });
        paymentOptionsLayout.removeAllViewsInLayout();
        for (int i = 0; i < adapter.getItemCount(); i++) {
            Adapter_PaymentGateway.PaymentGatewayViewHolder holder = adapter.onCreateViewHolder(paymentOptionsLayout, adapter.getItemViewType(i));
            adapter.onBindViewHolder(holder, i);
            paymentOptionsLayout.addView(holder.itemView);
        }
        payment_options_section.setVisibility(View.VISIBLE);
        if (adapter.getItemCount() == 0) {
            payment_options_section.setVisibility(View.GONE);
        }
    }

    private void updateBasicSection() {
        if (Cart.getTotalPayment() > 0) {
            txt_total_basic.setText(HtmlCompat.fromHtml(Helper.appendCurrency(Cart.getTotalPayment())));
        } else {
            txt_total_basic.setText(getString(L.string.not_available));
        }
    }

    private void updateTotalSection() {
        Animation fadeInAnimation = AnimationUtils.loadAnimation(requireActivity(), R.anim.fade_in);
        textTotalPayment.setText(HtmlCompat.fromHtml(Helper.appendCurrency(calculateGrandTotal())));
        textTotalPayment.startAnimation(fadeInAnimation);
        if (calculateTaxOnCart() > 0) {
            cart_tax_section.setVisibility(View.VISIBLE);
            textTotalTaxes.setText(HtmlCompat.fromHtml(Helper.appendCurrency(calculateTaxOnCart())));
            textTotalTaxes.startAnimation(fadeInAnimation);
        } else {
            cart_tax_section.setVisibility(View.GONE);
        }
    }

    private void addTimeSlotFee() {
        if (shippingDateTimeSlotsMap == null) {
            return;
        }

        // First remove existing time slot fee.
        final String title = "time_slot_fee";
        for (FeeData feeData : feeDatas) {
            if (feeData.plugin_title.equals(title)) {
                feeDatas.remove(feeData);
                break;
            }
        }

        if (selectedTimeSlot != null && selectedTimeSlot.getCost() > 0) {
            FeeData feeData = new FeeData();
            feeData.plugin_title = title;
            feeData.label = "Time Slot Fee";
            feeData.cost = selectedTimeSlot.getCost();
            //feeData.taxable = false;
            //feeData.minorder = 0.0f;
            feeDatas.add(feeData);
        }
    }

    private void updateFeeDataUI() {
        if (feeDatas.isEmpty()) {
            fee_data_section.setVisibility(View.GONE);
        } else {
            fee_data_section.setVisibility(View.VISIBLE);
            fee_data_section.removeAllViewsInLayout();
            float cartTotal = Cart.getTotalPayment();
            for (FeeData fee : feeDatas) {
                if (fee.minorder == 0 || fee.minorder > cartTotal) {
                    addFeeDataLine(fee_data_section, fee.label, fee.cost, fee.type);
                }
            }
        }
        updateTotalSection();
    }

    private void updateCartMetaUI() {
        cart_meta_section.removeAllViewsInLayout();
        if (!ArrayUtils.isEmpty(cartMeta.applied_coupons)) {
            boolean visible = false;
            for (AppliedCoupon appliedCoupon : cartMeta.applied_coupons) {
                if (appliedCoupon.discount_amount > 0) {
                    visible = true;
                    addAutoCouponLine(cart_meta_section, appliedCoupon.title, appliedCoupon.discount_amount);
                }
            }
            meta_section_group.setVisibility(visible ? View.VISIBLE : View.GONE);
        }
        updateTotalSection();
    }


    private void performProceed() {
        if (minOrder != null && calculateGrandTotalWithoutShipping() < minOrder.minOrderAmount) {
            Helper.showToast(minOrder.minOrderMessage);
            return;
        }

        if (!shippingFound && TM_Shipping.SHIPPING_REQUIRED) {
            Helper.toast(mRootView, L.string.no_shipping_method_found);
            return;
        }

        if (checkedGatewayId == null) {
            Helper.toast(mRootView, L.string.select_payment_method);
            return;
        }

        if (checkedShippingId >= 0 && TM_Shipping.SHIPPING_REQUIRED) {
            TM_Shipping shipping = shippingMethods.get(checkedShippingId);
            if (shipping.isFree() && Cart.isAnyCouponApplied()) {
                for (TM_Coupon coupon : Cart.applied_coupons) {
                    if (!coupon.enable_free_shipping) {
                        Helper.showToast(mRootView, String.format(getString(L.string.free_shipping_unavailable, true), coupon.code));
                        return;
                    }
                }
            }
        }

        final String deliveryDate = textSelectDate.getText().toString().trim();
        if (TimeSlotConfig.isEnabled()) {
            if (TimeSlotConfig.getPluginType() == TimeSlotConfig.PluginType.PICK_TIME_SELECT && timeSlotSection.getVisibility() == View.VISIBLE) {
                if (selectedTimeSlot == null) {
                    Helper.toast(mRootView, L.string.select_time_slot);
                    return;
                }
            }

            if (TimeSlotConfig.getPluginType() == TimeSlotConfig.PluginType.DELIVERY_SLOTS && dateSlotSection.getVisibility() == View.VISIBLE) {
                if (selectedDateTimeSlot == null) {
                    Helper.toast(mRootView, L.string.select_delivery_time);
                    return;
                }

                if (deliveryDate.equals(getString(L.string.select_date))) {
                    Helper.toast(mRootView, L.string.select_delivery_date);
                    return;
                }

                if (TextUtils.isEmpty(deliveryDate)) {
                    Helper.toast(mRootView, L.string.select_delivery_date);
                    return;
                }

                if (timeSlotsFound) {
                    if (selectedTimeSlot == null) {
                        Helper.toast(mRootView, L.string.select_delivery_time);
                        return;
                    }

                    if (TextUtils.isEmpty(selectedTimeSlot.toString())) {
                        Helper.toast(mRootView, L.string.select_delivery_time);
                        return;
                    }
                }
            }
        }

        PaymentGateway paymentGateway = PaymentManager.INSTANCE.getPaymentGateway(checkedGatewayId);
        PaymentManager.INSTANCE.setSelectedGateway(paymentGateway);

        if (currentOrder != null) {
            if (TimeSlotConfig.isEnabled() && TimeSlotConfig.getPluginType() == TimeSlotConfig.PluginType.DELIVERY_SLOTS && dateSlotSection.getVisibility() == View.VISIBLE) {
                Map<String, String> params = new HashMap<>();
                params.put("type", "order_slot");
                params.put("order_id", String.valueOf(currentOrder.id));
                params.put("delivery_date", deliveryDate);

                if (timeSlotsFound) {
                    params.put("id", selectedTimeSlot.getId());
                    params.put("cost", _STRING_(selectedTimeSlot.getCost()));
                }

                showProgress(getString(L.string.please_wait));
                DataEngine.getDataEngine().postOrderDateTimeDeliverySlots(params, new DataQueryHandler<String>() {
                    @Override
                    public void onSuccess(String data) {
                        hideProgress();
                        proceedPaymentGateway();
                    }

                    @Override
                    public void onFailure(Exception error) {
                        hideProgress();
                        error.printStackTrace();
                        btn_proceed.performClick();
                    }
                });
            } else {
                proceedPaymentGateway();
            }
        } else if (paymentGateway instanceof WebPayGateway) {
            proceedPaymentGateway();
        } else {
            if (AppInfo.ENABLE_WISHLIST_NOTE) {
                registerOrderInSite(paymentGateway, Helper.getWishListNote());
                return;
            }

            StringBuilder noteString = new StringBuilder(editOrderNote.getText().toString().trim());
            if (AppInfo.ENABLE_MULTIPLE_WISHLIST) {
                JSONArray cartArray = new JSONArray();
                for (Cart cart : Cart.getAll()) {
                    JSONObject cartNote = new JSONObject();
                    try {
                        cartNote.put("prod_name", cart.product.title);
                        cartNote.put("note", cart.note);
                        cartArray.put(cartNote);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
                JSONObject orderNote = new JSONObject();
                try {
                    orderNote.put("cartnotes", cartArray);
                    orderNote.put("ordernote", noteString.toString());
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                registerOrderInSite(paymentGateway, orderNote.toString());
            } else {
                if (AppInfo.ENABLE_SPECIAL_ORDER_NOTE) {
                    JSONObject orderNote = new JSONObject();
                    try {
                        noteString.append("***");
                        noteString.append(getString(L.string.special_order_note));
                        noteString.append("***");
                        orderNote.put("ordernote", noteString.toString());
                        noteString = new StringBuilder(orderNote.toString());
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }

                if (AppInfo.ENABLE_OTP_IN_COD_PAYMENT && paymentGateway instanceof CashOnDeliveryGateway) {
                    showOTPDialog(getString(L.string.otp_verification), getString(L.string.cod_otp_dialog_msg), "", noteString.toString(), true);
                } else if (AppInfo.SHOW_PRODUCTS_BOOKING_INFO && Cart.containsBookingProduct() && !orderBooking) {
                    createOrderBookingInfo(paymentGateway, noteString.toString());
                } else {
                    registerOrderInSite(paymentGateway, noteString.toString());
                }
            }
        }
    }

    private void proceedPaymentGateway() {
        final PaymentGateway paymentGateway = PaymentManager.INSTANCE.getSelectedGateway();
        if (paymentGateway instanceof WebPayGateway) {
            showProgress(getString(L.string.contacting_website), false);
            final LoginListener loginListener = new LoginListener() {
                @Override
                public void onLoginSuccess(String data) {
                    hideProgress();
                    ((WebPayGateway) paymentGateway).launch();
                    AnalyticsHelper.registerVisitWebPageEvent("Checkout");
                }

                @Override
                public void onLoginFailed(String cause) {
                    hideProgress();
                    Helper.showToast(mRootView, cause);
                }
            };

            if (AppInfo.AUTO_SIGNIN_IN_HIDDEN_WEBVIEW) {
                ((MainActivity) requireActivity()).signInWebInBackground(loginListener);
            } else {
                Fragment_WebLogin fragment = new Fragment_WebLogin();
                fragment.setLoginListener(loginListener);
                fragment.show(getSupportFM(), fragment.getClass().getSimpleName());
            }
        } else {
            paymentGateway.setOrder(currentOrder);
            paymentGateway.open(currentOrder.id, currentOrder.total);
            AnalyticsHelper.registerVisitWebPageEvent("Checkout");
        }
    }

    private void syncCartItems() {
        if (GuestUserConfig.isGuestCheckout()) {
            addAllItemsToCart();
            return;
        }
        if (AppInfo.USE_HTTPTASK_WITH_COOKIES || Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            syncCartUsingHttp();
        } else {
            addAllItemsToCart();
        }
    }


    private void setLocalityInfo() {
        //For Tax Calculation based on Locality.
        Address billingAddress = AppUser.getBillingAddress();
        Address shippingAddress = AppUser.getShippingAddress();

        TM_CommonInfo.billingLocalityInfo.countryCode = billingAddress.countryCode;
        TM_CommonInfo.billingLocalityInfo.stateCode = billingAddress.stateCode;
        TM_CommonInfo.billingLocalityInfo.city = billingAddress.city;
        TM_CommonInfo.billingLocalityInfo.pinCode = billingAddress.postcode;

        TM_CommonInfo.shippingLocalityInfo.countryCode = shippingAddress.countryCode;
        TM_CommonInfo.shippingLocalityInfo.stateCode = shippingAddress.stateCode;
        TM_CommonInfo.shippingLocalityInfo.city = shippingAddress.city;
        TM_CommonInfo.shippingLocalityInfo.pinCode = shippingAddress.postcode;
    }

    private void syncCartUsingHttp() {
        Log.d("-- PaymentFragment::syncCartUsingHttp --");
        showProgress(getString(L.string.syncing_cart), false);
        HashMap<String, String> params = new HashMap<>();
        params.put("user_platform", "Android");
        params.put("user_emailID", AppUser.getEmail());

        Log.d("-- cart sync url : [" + DataEngine.getDataEngine().url_login_website + "] --");
        Log.d("-- cart sync params : [" + params.toString() + "] --");

        NetworkRequest.makeCommonPostRequest(DataEngine.getDataEngine().url_login_website, params, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                hideProgress();
                Log.d("-- PaymentFragment::syncCartUsingHttp.onResponseReceived[" + response.msg + "] --");
                if (response.succeed && response.msg.contains("Login Successful")) {
                    addAllItemsToCart();
                } else {
                    showShippingErrorMsg(getString(L.string.unable_to_create_order_now));
                    if (response.error != null) {
                        response.error.printStackTrace();
                    }
                }
            }
        });
    }

    public void addAllItemsToCart() {
        String url = DataEngine.getDataEngine().url_cart_items;
        final String cart_data = JsonUtils.prepareCartJson();
        String ship_data = JsonUtils.prepareShippingJson();
        String bill_data = JsonUtils.prepareBillingJson();
        String coupon_data = JsonUtils.prepareCartSynqCouponJson();
        Log.d("== addAllItemsToCart: [" + cart_data + "] [" + ship_data + "] [" + coupon_data + "] ==");
        Map<String, String> params = new HashMap<>();
        params.put("cart_data", cart_data);
        params.put("ship_data", ship_data);
        params.put("bill_data", bill_data);
        params.put("coupon_data", coupon_data);

        if (AppInfo.SHOW_PRODUCTS_BOOKING_INFO) {
            String booking_id = JsonUtils.prepareBookingJson();
            if (!TextUtils.isEmpty(booking_id)) {
                params.put("order_booking_id", booking_id);
                orderBooking = true;
            }
        }

        showProgress(getString(L.string.loading_payment_details), false);
        NetworkRequest.makeCommonPostRequest(url, params, null, response -> {
            if (!response.succeed) {
                try {
                    hideProgress();
                    showShippingErrorMsg(getString(L.string.unable_to_create_order_now));
                    response.error.printStackTrace();
                } catch (Exception e) {
                    e.printStackTrace();
                }
                return;
            }

            boolean shippingError = false;
            try {
                shippingMethods.clear();
                shippingMethods.addAll(JsonUtils.parseJsonAndCreateOrderData(response.msg));
                if (Helper.isValidString(AppInfo.SHIPPING_PROVIDER)) {
                    // clear shipping methods for custom shipping provider
                    shippingMethods.clear();
                    hideProgress();
                    loadShippingData(cart_data);
                } else {
                    updateShippingMethodList(cart_data);
                }
            } catch (JSONException je) {
                je.printStackTrace();
                try {
                    TM_Response tm_response = DataHelper.parseJsonAndCreateTMResponse(response.msg);
                    hideProgress();
                    if (!tm_response.status && !TextUtils.isEmpty(tm_response.message)) {
                        showShippingErrorMsg(tm_response.message);
                    } else
                        shippingError = true;
                } catch (Exception e) {
                    shippingError = true;
                }
            } catch (Exception e) {
                shippingError = true;
            }

            if (shippingError) {
                hideProgress();
                showShippingErrorMsg(getString(L.string.shipping_unavailable_for_region));
            }

            if (AppInfo.SHOW_PICKUP_LOCATION) {
                try {
                    JsonUtils.parseAndCreatePickupLocations(response.msg);
                    String strPickupLocation = PickupLocation.getFirstPickupLocation();
                    if (!TextUtils.isEmpty(strPickupLocation)) {
                        pickup_location_section.setVisibility(View.VISIBLE);

                        TextView title_pickup_location = pickup_location_section.findViewById(R.id.title_pickup_location);
                        title_pickup_location.setText(getString(L.string.title_pickup_location));

                        TextView text_pickup_location = pickup_location_section.findViewById(R.id.text_pickup_location);
                        text_pickup_location.setText(HtmlCompat.fromHtml(strPickupLocation));
                    } else {
                        pickup_location_section.setVisibility(View.GONE);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    pickup_location_section.setVisibility(View.GONE);
                }
            }

            try {
                cart_checkout_note_section.setVisibility(View.GONE);
                JSONObject jsonObject = new JSONObject(response.msg);
                if (jsonObject.has("cart_note")) {
                    String text = jsonObject.getString("cart_note");
                    title_cart_checkout_note.setText(text);
                    Helper.stylizeActionText(title_cart_checkout_note);
                    cart_checkout_note_section.setVisibility(View.VISIBLE);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            try {
                PaymentManager.INSTANCE.reset();
                updatePaymentGateways(false);
            } catch (Exception e) {
                e.printStackTrace();
            }

            try {
                updatePaymentOptions();
            } catch (Exception e) {
                e.printStackTrace();
            }

            feeDatas = JsonUtils.parseJsonAndCreateFees(response.msg);
            if (!feeDatas.isEmpty()) {
                if (BuildConfig.MULTI_STORE) {
                    // only for multi-store checkout plugin
                    if (AppInfo.ENABLE_MULTI_STORE_CHECKOUT) {
                        if (mSelectedDeliveryTypeId.equals("2")) {
                            // filter fee data
                            FeeData excludeFeeData = null;
                            for (FeeData feeData : feeDatas) {
                                if (!TextUtils.isEmpty(feeData.plugin_title) && feeData.plugin_title.equals("woocommerce-checkout-manager")) {
                                    excludeFeeData = feeData;
                                    break;
                                }
                            }
                            if (excludeFeeData != null) {
                                feeDatas.remove(excludeFeeData);
                            }
                        }
                    }
                }
                updateFeeDataUI();
            }

            if (AppInfo.ENABLE_AUTO_COUPONS) {
                cartMeta = JsonUtils.parseJsonAndCreateCartMeta(response.msg);
                if (cartMeta != null) {
                    updateCartMetaUI();
                }
            }

            if (AppInfo.CHECK_MIN_ORDER_DATA) {
                minOrder = JsonUtils.parseJsonAndCreateMinOrderData(response.msg);
                //if (minOrder != null && Cart.getTotalPayment() < minOrder.minOrderAmount) {
                float grandTotalWithoutShipping = calculateGrandTotalWithoutShipping();
                if (minOrder != null && grandTotalWithoutShipping < minOrder.minOrderAmount) {
                    String message = minOrder.minOrderMessage;
                    message = message.replaceFirst("%s", Helper.appendCurrency(minOrder.minOrderAmount));
                    message = message.replaceFirst("%s", Helper.appendCurrency(grandTotalWithoutShipping));
                    minOrder.minOrderMessage = message;
                    showShippingErrorMsg(minOrder.minOrderMessage);
                }
            }
            updateTaxesUI();
            updateCheckoutAddonUI(parseCheckoutAddonData(response.msg));
            //hide progress bar
            hideProgress();
        });
    }

    private FeeData parseCheckoutAddonData(String msg) {
        try {
            JSONObject jsonObject = new JSONObject(msg);
            if (jsonObject.has("checkout_addon")) {
                JSONArray checkout_addonArray = jsonObject.getJSONArray("checkout_addon");
                if (checkout_addonArray != null && checkout_addonArray.length() > 0) {
                    JSONObject checkout_addonJsonObject = checkout_addonArray.getJSONObject(0);
                    FeeData feeData = new FeeData();
                    feeData.label = checkout_addonJsonObject.getString("name");
                    feeData.plugin_title = checkout_addonJsonObject.getString("label");
                    feeData.cost = JsonUtils.safeFloat(checkout_addonJsonObject.getString("total_cost"));
                    feeData.taxable = checkout_addonJsonObject.getBoolean("istaxable");
                    return feeData;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private void updateCheckoutAddonUI(final FeeData feeData) {
        if (feeData != null && !feeData.toString().isEmpty()) {
            cardview_checkout_addon.setVisibility(View.VISIBLE);
            checkbox_checkout_addon.setVisibility(View.VISIBLE);
            checkbox_checkout_addon.setText(feeData.plugin_title);
            checkbox_checkout_addon.setTag(checkbox_checkout_addon.getId(), feeData);
            //checkout_total_cost = feeData.cost;
            checkbox_checkout_addon.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                    FeeData feeData = (FeeData) buttonView.getTag(buttonView.getId());
                    if (isChecked) {
                        feeDatas.add(feeData);
                    } else {
                        feeDatas.remove(feeData);
                    }
                    updateTotalSection();
                }
            });
        } else {
            cardview_checkout_addon.setVisibility(View.GONE);
        }
    }

    private void updateShippingMethodList(String cartData) {
        shipping_section.setVisibility(View.VISIBLE);

        if (AppInfo.SHOW_PICKUP_LOCATION) {
            shipping_section.setVisibility(View.GONE);
            return;
        }

        if (!TM_Shipping.SHIPPING_REQUIRED) {
            showShippingWarningMsg(getString(L.string.shipping_not_required));
            return;
        }

        if (shippingMethods.isEmpty()) {
            showShippingErrorMsg(getString(L.string.shipping_unavailable_for_region));
            return;
        }


        shippingFound = true;
        if (AppInfo.ENABLE_PRODUCT_DELIVERY_DATE) {
            radioGroupShipping.setVisibility(View.GONE);
            ShippingMetaAdapter adapter = new ShippingMetaAdapter(shippingMethods, cartData);
            adapter.setOnShippingMethodListener((shippingList, shippingString, shippingCost) -> {
                PaymentFragment.this.shippingList = shippingList;
                PaymentFragment.this.shippingString = shippingString;
                PaymentFragment.this.shippingCost = shippingCost;
                updateTotalSection();
            });
            Drawable dividerDrawable = CContext.getDrawable(getContext(), R.drawable.item_recyclerview_decorator);
            deliveryInfoRecyclerView.addItemDecoration(new DividerItemDecorationView(dividerDrawable));
            deliveryInfoRecyclerView.setAdapter(adapter);
        } else {
            textErrorMessage.setVisibility(View.GONE);
            radioGroupShipping.removeAllViewsInLayout();
            radioGroupShipping.setVisibility(View.VISIBLE);
            textShippingTitle.setVisibility(View.VISIBLE);
            int index = 0;
            for (TM_Shipping shipping : shippingMethods) {
                RadioButton radioButton = new RadioButton(getContext());
                Helper.setTextAppearance(getContext(), radioButton, android.R.style.TextAppearance_Small);
                radioButton.setId(index++);
                String title = shipping.label.trim();
                float totalWeightCost = (float) shipping.cost;
                if (AppInfo.SHIPPING_PROVIDER.equals(Constants.Key.SHIPPING_EPEKEN_JNE)) {
                    totalWeightCost = getShippingTotalFromCartWeight(totalWeightCost, Cart.getTotalWeight());
                }

                if (totalWeightCost > 0) {
                    title += " : " + Helper.appendCurrency(totalWeightCost);
                }

                //Add shipping tax if available
                float totalTax = 0;
                for (String str : shipping.taxes) {
                    try {
                        totalTax += Float.parseFloat(str);
                    } catch (NumberFormatException e) {
                        e.printStackTrace();
                    }
                }
                if (totalTax > 0) {
                    title += ",\n" + String.format(Locale.getDefault(), getString(L.string.shipping_tax), Helper.appendCurrency(totalTax));
                }

                if (title.contains("<") || title.contains(">")) {
                    radioButton.setText(title);
                } else {
                    radioButton.setText(HtmlCompat.fromHtml(title));
                }

                Helper.stylize(radioButton);
                radioGroupShipping.addView(radioButton);
            }
            radioGroupShipping.check(0);
        }
    }

    private void updateTaxesUI() {
        if (TM_Tax.all_Tax.size() == 0) {
            cart_tax_section.setVisibility(View.GONE);
            btn_proceed.setEnabled(true);
            btn_proceed.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    performProceed();
                }
            });
            if (TimeSlotConfig.isEnabled()) {
                if (TimeSlotConfig.getPluginType() == TimeSlotConfig.PluginType.PICK_TIME_SELECT) {
                    updatePickTimeSelect();
                } else {
                    updateDeliverySlots();
                }
            }
            return;
        } else {
            cart_tax_section.setVisibility(View.VISIBLE);
        }

        btn_proceed.setEnabled(true);
        btn_proceed.setOnClickListener(view -> performProceed());

        updateTotalSection();
        if (TimeSlotConfig.isEnabled()) {
            if (TimeSlotConfig.getPluginType() == TimeSlotConfig.PluginType.PICK_TIME_SELECT) {
                updatePickTimeSelect();
            } else {
                updateDeliverySlots();
            }
        }
    }

    private void updatePickTimeSelect() {
        showProgress(getString(L.string.calculating_time_slots), false);
        HashMap<String, String> params = new HashMap<>();
        params.put("type", Base64Utils.encode("slot_list"));
        NetworkRequest.makeCommonPostRequest(DataEngine.getDataEngine().url_local_pickup_time_select, params, null, response -> {
            hideProgress();
            Log.d("-- PaymentFragment::updatePickTimeSelect[" + response.msg + "] --");
            if (response.succeed) {
                boolean visibility = false;
                try {
                    availableTimeSlots = JsonUtils.parseJsonAndCreateTimeSlots(response.msg);
                    spinnerTimeSlots.setAdapter(new Adapter_HtmlString(requireActivity(), availableTimeSlots));
                    visibility = true;
                } catch (JSONException e) {
                    e.printStackTrace();
                }

                deliverySlotsSection.setVisibility(visibility ? View.VISIBLE : View.GONE);
                timeSlotSection.setVisibility(visibility ? View.VISIBLE : View.GONE);
                dateSlotSection.setVisibility(View.GONE);
            } else {
                hideProgress();
                if (response.error != null) {
                    response.error.printStackTrace();
                }
            }
        });
    }

    private void updateDeliverySlots() {
        showProgress(getString(L.string.calculating_time_slots), false);
        DataEngine.getDataEngine().getDeliverySlotsInBackground(new DataQueryHandler<String>() {
            @Override
            public void onSuccess(String data) {
                hideProgress();
                try {
                    setDeliverySlotsData(JsonUtils.createDateTimeSlots(data));
                } catch (JSONException e1) {
                    try {
                        // check if data contains shipping methods date time slots
                        shippingDateTimeSlotsMap = JsonUtils.createShippingDateTimeSlotsMap(shippingMethods, data);
                        String key = shippingMethods.get(checkedShippingId).method_id;
                        setDeliverySlotsData(shippingDateTimeSlotsMap.get(key));
                    } catch (JSONException e2) {
                        e1.printStackTrace();
                        e2.printStackTrace();
                        timeSlotsFound = false;
                    }
                }
                setDeliverySlotsUIVisibility(timeSlotsFound);
            }

            @Override
            public void onFailure(Exception error) {
                hideProgress();
                error.printStackTrace();
            }
        });
    }

    private void setDeliverySlotsData(final List<DateTimeSlot> dateTimeSlots) {
        View.OnClickListener selectDateClickListener = v -> timeSlotPickerDialog.show(requireActivity().getFragmentManager(), DatePickerDialog.class.getSimpleName());
        textSelectDate.setOnClickListener(selectDateClickListener);
        buttonSelectDate.setOnClickListener(selectDateClickListener);

        textSelectDate.setText(getString(L.string.select_date));
        timeSlotsFound = dateTimeSlots.size() > 0;
        Calendar now = Calendar.getInstance();
        timeSlotPickerDialog = DatePickerDialog.newInstance(
                new DatePickerDialog.OnDateSetListener() {
                    @Override
                    public void onDateSet(DatePickerDialog view, int year, int monthOfYear, int dayOfMonth) {
                        timeSlotSection.setVisibility(View.VISIBLE);
                        //TODO don't use unformatted string in case of date or time. // Date format is dd/mm/yyyy
                        String pickedDataString = String.format(Locale.US, "%02d/%02d/%d", dayOfMonth, (monthOfYear + 1), year);
                        textSelectDate.setText(pickedDataString);
                        for (int i = 0; i < dateTimeSlots.size(); i++) {
                            DateTimeSlot dateTimeSlot = dateTimeSlots.get(i);
                            if (dateTimeSlot.getDateString().equalsIgnoreCase(pickedDataString)) {
                                timeSlotsFound = !ListUtils.isEmpty(dateTimeSlot.getTimeSlots());
                                selectedDateTimeSlot = dateTimeSlot;
                                spinnerTimeSlots.setAdapter(new Adapter_HtmlString(requireActivity(), selectedDateTimeSlot.getTimeSlots()));
                                break;
                            }
                        }

                        if (!timeSlotsFound) {
                            timeSlotSection.setVisibility(View.GONE);
                        }
                    }
                },
                now.get(Calendar.YEAR),
                now.get(Calendar.MONTH),
                now.get(Calendar.DAY_OF_MONTH)
        );
        timeSlotPickerDialog.setTitle(getString(L.string.select_delivery_date));
        timeSlotPickerDialog.setOkText(getString(L.string.ok));
        timeSlotPickerDialog.setCancelText(getString(L.string.cancel));

        Calendar[] days = new Calendar[dateTimeSlots.size()];
        for (int i = 0; i < days.length; i++) {
            days[i] = dateTimeSlots.get(i).getCalendarDay();
        }
        timeSlotPickerDialog.setSelectableDays(days);
    }

    private void setDeliverySlotsUIVisibility(boolean visibility) {
        deliverySlotsSection.setVisibility(visibility ? View.VISIBLE : View.GONE);
        dateSlotSection.setVisibility(visibility ? View.VISIBLE : View.GONE);
        timeSlotSection.setVisibility(View.GONE);
    }

    void showShippingWarningMsg(String msg) {
        try {
            Log.d(msg);
            radioGroupShipping.removeAllViewsInLayout();
            radioGroupShipping.setVisibility(View.GONE);
            textShippingTitle.setVisibility(View.VISIBLE);
            textErrorMessage.setText(msg);
            textErrorMessage.setTextColor(CContext.getColor(getContext(), R.color.error_text_color));
            textErrorMessage.setVisibility(View.VISIBLE);
            shipping_section.setVisibility(View.VISIBLE);
            shippingFound = false;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    void showShippingErrorMsg(String message) {
        try {
            Helper.showToastLong(message);
            radioGroupShipping.removeAllViewsInLayout();
            radioGroupShipping.setVisibility(View.GONE);
            if (TextUtils.isEmpty(textErrorMessage.getText())) {
                textErrorMessage.setVisibility(View.VISIBLE);
                textErrorMessage.setText(HtmlCompat.fromHtml(message));
                textErrorMessage.setTextColor(CContext.getColor(getContext(), R.color.error_text_color));
                textShippingTitle.setVisibility(View.GONE);
                shipping_section.setVisibility(View.VISIBLE);
            } else {
                error_section.setVisibility(View.VISIBLE);
                text_error.setVisibility(View.VISIBLE);
                text_error.setText(HtmlCompat.fromHtml(message));
            }
            shippingFound = false;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void registerOrderInSite(final PaymentGateway paymentGateway, String note) {
        try {
            showProgress(getString(L.string.registering_order), false);
            String cartJsonString = JsonUtils.getCartItemsJSONString(getShippingList(), paymentGateway, feeDatas, note);
            DataEngine.getDataEngine().registerOrderInBackground(cartJsonString, new DataQueryHandler<TM_Order>() {
                @Override
                public void onSuccess(final TM_Order order) {
                    if (AppInfo.SHOW_PRODUCTS_BOOKING_INFO && Cart.containsBookingProduct() && registerOrderBookingID > 0 && !orderBooking) {
                        updateOrderBookingInfo(order);
                    }

                    if (AppInfo.ENABLE_PRODUCT_DELIVERY_DATE) {
                        DataEngine.getDataEngine().postOrderShippingDeliveryInfo(order.id, shippingString, new DataQueryHandler() {
                            @Override
                            public void onSuccess(Object data) {
                                currentOrder = order;
                                hideProgress();
                                AnalyticsHelper.registerPaymentEvent(paymentGateway);
                                AnalyticsHelper.registerPaymentEvent(currentOrder, paymentGateway);
                                btn_proceed.performClick();
                            }

                            @Override
                            public void onFailure(Exception error) {
                                hideProgress();
                                MainActivity.mActivity.generateOrderFailure(error.getMessage());
                            }
                        });
                    } else {
                        currentOrder = order;
                        hideProgress();
                        AnalyticsHelper.registerPaymentEvent(paymentGateway);
                        AnalyticsHelper.registerPaymentEvent(currentOrder, paymentGateway);
                        btn_proceed.performClick();
                    }
                }

                @Override
                public void onFailure(Exception error) {
                    hideProgress();
                    MainActivity.mActivity.generateOrderFailure(error.getMessage());
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private List<TM_Shipping> getShippingList() {
        if (AppInfo.ENABLE_PRODUCT_DELIVERY_DATE) {
            return shippingList;
        } else if (checkedShippingId >= 0) {
            List<TM_Shipping> shipping_Methods = new ArrayList<>();
            shipping_Methods.add(shippingMethods.get(checkedShippingId));
            return shipping_Methods;
        }
        return null;
    }

    private void addFeeDataLine(LinearLayout parent, String label, float cost, FeeData.Type type) {
        LinearLayout dataLine = new LinearLayout(getContext());
        dataLine.setOrientation(LinearLayout.HORIZONTAL);

        int padding = Helper.DP(5, getResources());
        dataLine.setPadding(padding, padding, padding, padding);

        TextView textLabel = new TextView(getContext());
        textLabel.setText(HtmlCompat.fromHtml(label));
        Helper.setTextAppearance(getContext(), textLabel, android.R.style.TextAppearance_Small);
        textLabel.setTextColor(CContext.getColor(requireActivity(), R.color.normal_text_color));
        textLabel.setGravity(Gravity.LEFT | Gravity.CENTER_VERTICAL);
        dataLine.addView(textLabel, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        TextView textCost = new TextView(getContext());
        String strCost = Helper.appendCurrency(cost);
        if (type.equals(FeeData.Type.PERCENT)) {
            strCost = cost + "%";
        }
        textCost.setText(HtmlCompat.fromHtml(strCost));
        Helper.setTextAppearance(getContext(), textCost, android.R.style.TextAppearance_Small);
        textCost.setTextColor(CContext.getColor(requireActivity(), R.color.normal_text_color));
        textCost.setGravity(Gravity.RIGHT | Gravity.CENTER_VERTICAL);
        dataLine.addView(textCost, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        parent.addView(dataLine, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
    }

    private void addAutoCouponLine(LinearLayout parent, String label, float cost) {
        LinearLayout dataLine = new LinearLayout(getContext());
        dataLine.setOrientation(LinearLayout.HORIZONTAL);
        int padding = Helper.DP(5, getResources());
        dataLine.setPadding(padding, padding, padding, padding);
        {
            TextView textLabel = new TextView(getContext());
            textLabel.setText(HtmlCompat.fromHtml(label));
            Helper.setTextAppearance(getContext(), textLabel, android.R.style.TextAppearance_Small);
            textLabel.setTextColor(CContext.getColor(requireActivity(), R.color.normal_text_color));
            textLabel.setGravity(Gravity.LEFT | Gravity.CENTER_VERTICAL);
            dataLine.addView(textLabel, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));

            TextView textCost = new TextView(getContext());
            textCost.setText("-" + HtmlCompat.fromHtml(Helper.appendCurrency(cost)));
            Helper.setTextAppearance(getContext(), textCost, android.R.style.TextAppearance_Small);
            textCost.setTextColor(CContext.getColor(requireActivity(), R.color.highlight_text_color_2));
            textCost.setGravity(Gravity.RIGHT | Gravity.CENTER_VERTICAL);
            dataLine.addView(textCost, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        }
        parent.addView(dataLine, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
    }

    float getFeesTotal() {
        float feesTotal = 0;
        float cartTotal = Cart.getTotalPayment();
        for (FeeData feeData : feeDatas) {
            if (feeData.type == FeeData.Type.FIXED) {
                if (feeData.minorder == 0 || feeData.minorder > cartTotal) {
                    feesTotal += feeData.cost;
                }
            }
        }
        return feesTotal;
    }

    private float getShippingTotalFromCartWeight(float shippingTotal, float carttotWeight) {
        carttotWeight = carttotWeight < 1 ? 1 : (float) Math.floor(carttotWeight);
        return shippingTotal * carttotWeight;
    }

    private float calculateGrandTotalWithoutTax() {
        float grandTotalWithoutShipping = calculateGrandTotalWithoutShipping();
        float shippingTotal = 0.0f;

        if (AppInfo.ENABLE_PRODUCT_DELIVERY_DATE) {
            shippingTotal = (float) shippingCost;
        } else {
            if (checkedShippingId >= 0 && checkedShippingId < shippingMethods.size()) {
                TM_Shipping shipping = shippingMethods.get(checkedShippingId);
                shippingTotal = (float) shipping.cost;
                if (AppInfo.SHIPPING_PROVIDER.equals(Constants.Key.SHIPPING_EPEKEN_JNE)) {
                    shippingTotal = getShippingTotalFromCartWeight(shippingTotal, Cart.getTotalWeight());
                }

                //Add shipping tax if available
                for (String tax : shipping.taxes) {
                    try {
                        shippingTotal += Float.parseFloat(tax);
                    } catch (NumberFormatException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
        return grandTotalWithoutShipping + shippingTotal;
    }

    private float calculateShippingCost() {
        float shippingTotal = 0.0f;

        if (AppInfo.ENABLE_PRODUCT_DELIVERY_DATE) {
            shippingTotal = (float) shippingCost;
        } else {
            if (checkedShippingId >= 0 && checkedShippingId < shippingMethods.size()) {
                TM_Shipping shipping = shippingMethods.get(checkedShippingId);
                shippingTotal = (float) shipping.cost;
                if (AppInfo.SHIPPING_PROVIDER.equals(Constants.Key.SHIPPING_EPEKEN_JNE)) {
                    shippingTotal = getShippingTotalFromCartWeight(shippingTotal, Cart.getTotalWeight());
                }

                //Add shipping tax if available
                for (String tax : shipping.taxes) {
                    try {
                        shippingTotal += Float.parseFloat(tax);
                    } catch (NumberFormatException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
        return shippingTotal;
    }

    private float calculateGrandTotalWithoutShipping() {
        float cartTotal = Cart.getTotalPayment();
        float feesTotal = getFeesTotal();
        for (FeeData feeData : feeDatas) {
            if (feeData.type == FeeData.Type.PERCENT) {
                feesTotal += (cartTotal) * feeData.cost / 100.0f;
            }
        }
        float extraPaymentCharges = 0.0f;
        PaymentGateway paymentGateway = PaymentManager.INSTANCE.getPaymentGateway(checkedGatewayId);
        if (paymentGateway != null && paymentGateway.isEnabled()) {
            TM_PaymentGateway.GatewaySettings gatewaySettings = paymentGateway.getGatewaySettings();
            if (gatewaySettings != null && !TextUtils.isEmpty(gatewaySettings.extra_charges)) {
                try {
                    extraPaymentCharges = Float.parseFloat(gatewaySettings.extra_charges);
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
        }
        float total = (cartTotal + feesTotal + extraPaymentCharges - getAutoCouponDiscount());
//        // Don't confuse here, we are are already adding shipping time slot in fee.
//        if (selectedTimeSlot != null && shippingDateTimeSlotsMap == null) {
//            total = total + selectedTimeSlot.getCost();
//        }
        return Math.max(total, 0.0f);
    }

    private float calculateTaxTotalApplied() {
        float grandTotalBasicPrice = Cart.getTotalBasicPaymentPrice();
        float grandTotalShippingTax = calculateShippingTax();
        return Math.max((calculateGrandTotalWithoutShipping() - grandTotalBasicPrice) + grandTotalShippingTax, 0.0f);
    }

    private float calculateGrandTotal() {
        float grandTotalWithoutTax = calculateGrandTotalWithoutTax();
        if (TM_CommonInfo.addTaxToProductPrice)
            return grandTotalWithoutTax + calculateShippingTax();
        else
            return grandTotalWithoutTax + calculateShippingTax() + calculateTaxOnCart();
    }

    private float calculateTaxOnCart() {
        float total = 0.0f;
        if (TM_CommonInfo.woocommerce_prices_include_tax.equals("") || TM_CommonInfo.woocommerce_prices_include_tax.equals("yes"))
            return total;

        if (TM_CommonInfo.addTaxToProductPrice)
            return calculateTaxTotalApplied();

        for (Cart cart : Cart.getAll()) {
            Log.d("calculateTaxOnCart PRICE IS: " + cart.getTotalPaymentExcludingTax(cart));
            cart.taxOnProduct = (float) TaxHelper.calculateTaxProduct(cart.getTotalPaymentExcludingTax(cart), cart.product.taxClass, true, false);
            total += cart.taxOnProduct;
        }
        return total;
    }

    private float calculateShippingTax() {
        float taxAmount = 0.0f;
        taxAmount += TaxHelper.calculateTotalTax(calculateShippingCost());
        return taxAmount;
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

    private void updateOrderStatusInBackground(TM_Order order, final PaymentGateway gateway) {
        try {
            showProgress(getString(L.string.updating_order), false);

            String status;
            if (gateway.getId().equals("cheque") || gateway.getId().equals("bacs") || gateway.getId().contains("jetpack_custom_gateway")) {
                status = "on-hold";
            } else if (AppInfo.SHOW_PRODUCTS_BOOKING_INFO && gateway.getId().equals("wc-booking-gateway")) {
                status = "pending";
            } else {
                status = "processing";
            }

            String str = JsonUtils.createOrderStatusJsonString(status, gateway.getId(), gateway.getTitle(), gateway.isPrepaid());
            Log.d("Updating Order : [" + str + "] --");

            DataEngine.getDataEngine().updateOrderStatusInBackground(order.id, str, new DataQueryHandler<TM_Order>() {
                @Override
                public void onSuccess(TM_Order order) {
                    hideProgress();

                    ((MainActivity) requireActivity()).generateOrderReceipt(order, gateway, selectedTimeSlot);

                    if (AppInfo.ENABLE_MULTI_STORE_CHECKOUT) {
                        updateOrderMetaData(order);
                    }

                    if (AppInfo.ENABLE_CUSTOM_POINTS) {
                        updateOrderRewardPoints(order);
                    }

                    if (AppInfo.USE_LAT_LONG_IN_ORDER) {
                        updateOrderLatLong(order);
                    }
                }

                @Override
                public void onFailure(Exception reason) {
                    hideProgress();
                    ((MainActivity) requireActivity()).generateOrderFailure(reason.getMessage());
                }
            });
        } catch (Exception e) {
            hideProgress();
            ((MainActivity) requireActivity()).generateOrderFailure(e.getMessage());
        }
    }

    private void updateOrderMetaData(TM_Order order) {
        if (!AppInfo.ENABLE_MULTI_STORE_CHECKOUT) {
            return;
        }

        HashMap<String, String> params = new HashMap<>();
        params.put("type", Base64Utils.encode("update"));
        params.put("orderid", Base64Utils.encode(order.id));
        params.put("meta_data", mMetaDataString);
        DataEngine.getDataEngine().updateOrderMetaDataInBackground(params, new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {
            }

            @Override
            public void onFailure(Exception error) {
                error.printStackTrace();
            }
        });
    }

    private void updateOrderRewardPoints(TM_Order order) {
        if (!AppInfo.ENABLE_CUSTOM_POINTS) {
            return;
        }
        int pointsRedeemed = (int) (Cart.getPointsUsed());
        Map<String, String> params = new HashMap<>();
        params.put("user_id", "" + AppUser.getUserId());
        params.put("email_id", AppUser.getEmail());
        params.put("points_redeemed", "" + pointsRedeemed);
        params.put("order_ids", "[" + order.id + "]");
        DataEngine.getDataEngine().updateOrderRewardPointsAsync(params, new DataQueryHandler<String>() {
            @Override
            public void onSuccess(String data) {
                Log.d("");
            }

            @Override
            public void onFailure(Exception reason) {
                Log.e(reason.getMessage());
            }
        });
    }

    private void loadShippingData(final String cart_data) {
        showProgress(getString(L.string.loading_payment_details), false);
        DataEngine.getDataEngine().getShippingEngine().getStoreLocation(new DataQueryHandler<TM_StoreInfo>() {
            @Override
            public void onSuccess(TM_StoreInfo storeInfo) {
                Address address = AppUser.hasSignedIn()
                        ? AppUser.getInstance().shipping_address
                        : AppInfo.dummyUser.shipping_address;
                TM_Region destinationRegion = TM_Region.fromJson(address.region);
                if (AppInfo.SHIPPING_PROVIDER.equals(Constants.Key.SHIPPING_EPEKEN_JNE) || AppInfo.SHIPPING_PROVIDER.equals(Constants.Key.SHIPPING_JNE_ALL_COURIER)) {
                    storeInfo = new TM_StoreInfo();
                    storeInfo.locations.add(TM_Region.getRegionFromAll("city", AppUser.getBillingAddress().city));
                }

                DataEngine.getDataEngine().getShippingEngine().getAvailableShipping(storeInfo, destinationRegion, Cart.getTotalWeight(),
                        new DataQueryHandler<List<TM_Shipping>>() {
                            @Override
                            public void onSuccess(List<TM_Shipping> shippingList) {
                                shippingMethods.addAll(shippingList);
                                updateShippingMethodList(cart_data);
                                hideProgress();
                            }

                            @Override
                            public void onFailure(Exception error) {
                                error.printStackTrace();
                                hideProgress();
                            }
                        }
                );
            }

            @Override
            public void onFailure(Exception error) {
                error.printStackTrace();
                hideProgress();
            }
        });
    }

    public void showOTPDialog(String title, String message, String mobileNumber, final String note, final boolean forUpdate) {
        AlertDialog.Builder builder = new AlertDialog.Builder(requireContext());
        View view = LayoutInflater.from(requireContext()).inflate(R.layout.dialog_cod_otp, null);

        LinearLayout header_box = view.findViewById(R.id.header_box);
        header_box.setBackgroundColor(Color.parseColor(AppInfo.color_theme));
        TextView header_msg = view.findViewById(R.id.header_msg);
        Helper.stylizeActionBar(header_msg);
        ImageView iv_close = view.findViewById(R.id.iv_close);
        Helper.stylizeActionBar(iv_close);

        header_msg.setText(title);

        TextView txt_msg = view.findViewById(R.id.txt_msg);
        txt_msg.setText(message);

        TextInputLayout labelMobileNumber = view.findViewById(R.id.label_mobile_number);
        labelMobileNumber.setHint(L.getString(L.string.mobile_number));
        Helper.stylize(labelMobileNumber);
        final EditText edit_mobile_number = view.findViewById(R.id.edit_mobile_number);
        if (forUpdate) {
            Address address = AppUser.getBillingAddress();
            mobileNumber = address.phone;
        }
        edit_mobile_number.setText(mobileNumber);

        Button btn_ok = view.findViewById(R.id.btn_ok);
        Helper.stylize(btn_ok);

        if (forUpdate) {
            labelMobileNumber.setVisibility(View.VISIBLE);
            btn_ok.setText(getString(L.string.ok));
        } else {
            labelMobileNumber.setVisibility(View.GONE);
            btn_ok.setText(getString(L.string.update));
        }
        builder.setView(view).setCancelable(true);
        if (forUpdate) {
            alertOtpDialog = builder.create();
            alertOtpDialog.setCancelable(forUpdate);
        } else {
            alertDialogDummyUserUpdate = builder.create();
            alertDialogDummyUserUpdate.setCancelable(!forUpdate);
        }

        btn_ok.setOnClickListener(view1 -> {
            Helper.hideKeyboard(view1);
            String mobileNumber1 = edit_mobile_number.getText().toString();
            edit_mobile_number.setError(null);
            if (TextUtils.isEmpty(mobileNumber1)) {
                edit_mobile_number.setError(L.string.invalid_contact_number);
                return;
            }
            if (!Helper.isValidPhoneNumber(mobileNumber1)) {
                Helper.toast(L.string.invalid_contact_number);
                return;
            }

            if (!forUpdate) {
                DummyUser dummyUser = AppUser.createDummyUser(mobileNumber1);
                postCustomerDataOnSite(alertDialogDummyUserUpdate, dummyUser, note);
            } else {
                Address address = AppUser.getBillingAddress();
                String address_phone = address.phone;
                if (!mobileNumber1.equals(address_phone)) {
                    showOTPDialog(getString(L.string.update_billing_mobile_no_dialog_header), getString(L.string.update_billing_mobile_no_dialog_msg) + " " + mobileNumber1, mobileNumber1, note, false);
                    return;
                }
                showOtpDialog(alertOtpDialog, mobileNumber1, note);
            }
        });

        iv_close.setOnClickListener(v -> {
            Helper.hideKeyboard(v);
            if (forUpdate) {
                alertOtpDialog.dismiss();
            } else {
                alertDialogDummyUserUpdate.dismiss();
            }
        });
        if (forUpdate) {
            alertOtpDialog.show();
        } else {
            alertDialogDummyUserUpdate.show();
        }
    }

    private void showOtpDialog(final AlertDialog alertDialog, final String mobile_number, final String noteString) {
        showProgress(L.getString(L.string.please_wait), false);
        DataEngine.getDataEngine().requestCheckoutOTPInBackground(mobile_number, new DataQueryHandler<String>() {
            @Override
            public void onSuccess(String data) {
                hideProgress();
                OtpVerifyFragment otpVerifyFragment = OtpVerifyFragment.newInstance(() -> {
                    PaymentGateway paymentGateway = PaymentManager.INSTANCE.getPaymentGateway(checkedGatewayId);
                    PaymentManager.INSTANCE.setSelectedGateway(paymentGateway);
                    registerOrderInSite(paymentGateway, noteString);
                    alertDialog.dismiss();
                    alertOtpDialog.dismiss();
                }, MainActivity.mActivity, mobile_number);
                otpVerifyFragment.show(requireActivity().getSupportFragmentManager(), PaymentFragment.class.getSimpleName());
            }

            @Override
            public void onFailure(Exception error) {
                hideProgress();
                Helper.toast(error.getMessage());
            }
        });
    }

    private void postCustomerDataOnSite(final AlertDialog alertDialog, final DummyUser dummyUser, final String noteString) {
        try {
            showProgress(getString(L.string.updating));
            String customerJsonString = JsonUtils.getCustomerJSON(dummyUser);
            Log.d("-- customerDataJsonString: [" + customerJsonString + "] --");
            DataEngine.getDataEngine().editCustomerDataInBackground(AppUser.getUserId() + "", customerJsonString, new DataQueryHandler<String>() {
                @Override
                public void onSuccess(String data) {
                    alertDialogDummyUserUpdate.dismiss();
                    showOtpDialog(alertOtpDialog, dummyUser.billing_address.phone, noteString);
                    hideProgress();
                }

                @Override
                public void onFailure(Exception reason) {
                    hideProgress();
                    Helper.toast(mRootView, L.string.error_updating_customer_data);
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
            hideProgress();
            Helper.toast(mRootView, L.string.error_updating_customer_data);
        }
    }

    private void updateOrderLatLong(TM_Order order) {
        if (!AppInfo.USE_LAT_LONG_IN_ORDER) {
            return;
        }

        AppUser appUser;
        if (AppInfo.mGuestUserConfig == null || !GuestUserConfig.isGuestCheckout() || AppUser.hasSignedIn()) {
            appUser = AppUser.getInstance();
        } else {
            appUser = new AppUser();
            appUser.billing_address = AppInfo.dummyUser.billing_address;
            appUser.shipping_address = AppInfo.dummyUser.shipping_address;
        }

        Map<String, String> params = new HashMap<>();
        params.put("type", "update");
        params.put("order_id", String.valueOf(order.id));
        params.put("latitude", appUser.billing_address.latitude);
        params.put("longitude", appUser.billing_address.longitude);
        DataEngine.getDataEngine().postOrdersMeta(params, new DataQueryHandler<String>() {
            @Override
            public void onSuccess(String data) {
                Log.d(data);
            }

            @Override
            public void onFailure(Exception error) {
                error.printStackTrace();
            }
        });
    }

    private void createOrderBookingInfo(final PaymentGateway paymentGateway, final String noteString) {
        if (!AppInfo.SHOW_PRODUCTS_BOOKING_INFO && !Cart.containsBookingProduct()) {
            return;
        }

        String cart_data = JsonUtils.prepareCartJson();
        showProgress(getString(L.string.please_wait));
        DataEngine.getDataEngine().postOrderCreateBookingInfo(cart_data, new DataQueryHandler<String>() {
            @Override
            public void onSuccess(String data) {
                hideProgress();
                try {
                    JSONObject jsonObject = new JSONObject(data);
                    String result = jsonObject.getString("result");
                    String error = String.valueOf(jsonObject.getInt("error"));
                    int bookingId = jsonObject.getInt("booking_id");

                    if (!TextUtils.isEmpty(result) && result.equalsIgnoreCase("success") && bookingId > 0) {
                        registerOrderBookingID = bookingId;
                        registerOrderInSite(paymentGateway, noteString);
                    } else {
                        Helper.showErrorToast(error, true);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onFailure(Exception error) {
                hideProgress();
                error.printStackTrace();
            }
        });
    }

    private void updateOrderBookingInfo(final TM_Order order) {
        showProgress(getString(L.string.please_wait));
        DataEngine.getDataEngine().postOrderUpdateBookingInfo(order.id, registerOrderBookingID, new DataQueryHandler<String>() {
            @Override
            public void onSuccess(String data) {
                hideProgress();
                hideProgress();
                try {
                    JSONObject jsonObject = new JSONObject(data);
                    String result = jsonObject.getString("result");
                    String error = String.valueOf(jsonObject.getInt("error"));
                    String message = jsonObject.getString("message");

                    if (!TextUtils.isEmpty(result) && result.equalsIgnoreCase("success")) {
                        Helper.showToast(mRootView, message);
                    } else {
                        Helper.showErrorToast(error, true);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onFailure(Exception error) {
                hideProgress();
                error.printStackTrace();
            }
        });
    }

    public void getOrderForPayment() {
        for (Cart cart : Cart.getAll()) {
            if (AppInfo.SHOW_PRODUCTS_BOOKING_INFO && cart.order_id <= 0) {
                break;
            }

            showProgress(getString(L.string.please_wait));
            DataEngine.getDataEngine().getOrderInBackground(cart.order_id, new DataQueryHandler<TM_Order>() {
                @Override
                public void onSuccess(TM_Order order) {
                    hideProgress();
                    currentOrder = order;
                }

                @Override
                public void onFailure(Exception error) {
                    hideProgress();
                    error.printStackTrace();
                }
            });
        }
    }

    private void showPickupLocation(final TM_Shipping tm_shipping) {

        ShippingMethodPickupLocationDialog shippingMethodPickupLocationDialog = ShippingMethodPickupLocationDialog.newInstance(tm_shipping, new ShippingMethodPickupLocationDialog.PickupLocationSelectionListener() {
            @Override
            public void locationSelected(int value) {
                shipping_pickup_location_section.setVisibility(View.VISIBLE);
                text_shipping_pickup_location.setVisibility(View.VISIBLE);
                int count = tm_shipping.locations.size();
                for (int i = 0; i < count; i++) {
                    TM_Shipping_Pickup_Location tm_shipping_pickup_location = tm_shipping.locations.get(i);
                    if (value == i) {
                        text_shipping_pickup_location.setText(setPickupLocation(tm_shipping_pickup_location));
                        pickup_location_id = tm_shipping_pickup_location.id;
                    }
                }
            }
        });

        shippingMethodPickupLocationDialog.show(requireActivity().getSupportFragmentManager(), ShippingMethodPickupLocationDialog.class.getSimpleName());
    }

    private String setPickupLocation(TM_Shipping_Pickup_Location tm_shipping_pickup_location) {
        String title = "";
        if (!TextUtils.isEmpty(tm_shipping_pickup_location.company))
            title = tm_shipping_pickup_location.company.trim();

        if (!TextUtils.isEmpty(tm_shipping_pickup_location.address_1))
            title += ", " + tm_shipping_pickup_location.address_1.trim();

        if (!TextUtils.isEmpty(tm_shipping_pickup_location.city))
            title += ", " + tm_shipping_pickup_location.city.trim();

        if (!TextUtils.isEmpty(tm_shipping_pickup_location.postcode))
            title += ", " + tm_shipping_pickup_location.postcode;

        if (!TextUtils.isEmpty(tm_shipping_pickup_location.state))
            title += ", " + tm_shipping_pickup_location.state;

        if (!TextUtils.isEmpty(tm_shipping_pickup_location.phone))
            title += ", " + tm_shipping_pickup_location.phone;

        return title;
    }
}
