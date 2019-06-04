package com.twist.tmstore.fragments;

import android.content.DialogInterface;
import android.os.Bundle;
import android.support.v7.app.AlertDialog;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.twist.dataengine.entities.TM_LineItem;
import com.twist.dataengine.entities.TM_Order;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.Constants;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.Adapter_OrdersProduct;
import com.twist.tmstore.config.GuestUserConfig;
import com.twist.tmstore.config.MultiVendorConfig;
import com.twist.tmstore.config.TimeSlotConfig;
import com.twist.tmstore.dialogs.SimpleMessageDialog;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.entities.Cart;
import com.twist.tmstore.entities.CustomerData;
import com.twist.tmstore.entities.PickupLocation;
import com.twist.tmstore.entities.TimeSlot;
import com.twist.tmstore.payments.PaymentGateway;
import com.twist.tmstore.payments.gateways.WebPayGateway;
import com.utils.AnalyticsHelper;
import com.utils.Base64Utils;
import com.utils.CContext;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import com.twist.oauth.NetworkRequest;
import com.twist.oauth.NetworkResponse;

public class Fragment_OrderReceipt extends BaseFragment {
    public TM_Order order;
    public PaymentGateway paymentGateway;
    public int orderId;
    private TimeSlot timeSlot;
    private TextView txt_orderid;
    private LinearLayout layout_products;
    private TextView txt_totalitems;
    private TextView txt_total;
    private TextView txt_orderdate;
    private TextView txt_instructions;
    private LinearLayout order_total_tax_section;
    private TextView txt_totaltaxval;
    private TextView txt_totaltax;
    private TextView txt_accountdetails;
    private Button btn_my_orders;
    private View error_page;
    private View instruction_section;
    private ImageButton btn_retry;
    private LinearLayout shipping_cost_section;
    private TextView title_shipping_cost;
    private TextView txt_shipping_cost;
    private ImageView image_done_1;
    private ImageView image_done_2;
    private ImageView image_done_3;
    private ImageView image_done_4;
    private TextView step_onetxt;
    private TextView step_twotxt;
    private TextView step_threetxt;
    private TextView step_fourtxt;
    private View view_process_one;
    private View view_process_two;
    private View view_process_three;
    private View delivery_date_section;
    private TextView title_delivery_date;
    private TextView text_delivery_date;
    private View delivery_time_section;
    private TextView title_delivery_time;
    private TextView text_delivery_time;
    private FrameLayout order_status_layout;
    private boolean mOrderFetched = false;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
    }

    public static Fragment_OrderReceipt newInstance(TM_Order order, PaymentGateway paymentGateway, TimeSlot timeSlot) {
        Fragment_OrderReceipt fragment = Fragment_OrderReceipt.newInstance(order.id, paymentGateway, timeSlot);
        fragment.order = order;
        return fragment;
    }

    public static Fragment_OrderReceipt newInstance(int orderId, PaymentGateway paymentGateway, TimeSlot timeSlot) {
        Fragment_OrderReceipt fragment = new Fragment_OrderReceipt();
        fragment.order = null;
        fragment.orderId = orderId;
        fragment.timeSlot = timeSlot;
        fragment.paymentGateway = paymentGateway;
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_order_receipt, container, false);
        setActionBarHomeAsUpIndicator();
        setTitle(getString(L.string.order_placed));

        error_page = rootView.findViewById(R.id.error_page);
        instruction_section = rootView.findViewById(R.id.instruction_section);
        btn_retry = (ImageButton) rootView.findViewById(R.id.btn_retry);
        btn_retry.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                fetchOrder();
            }
        });

        txt_orderid = (TextView) rootView.findViewById(R.id.txt_order_id);
        layout_products = (LinearLayout) rootView.findViewById(R.id.layout_products);
        txt_totalitems = (TextView) rootView.findViewById(R.id.txt_totalitems);
        txt_total = (TextView) rootView.findViewById(R.id.txt_total);
        txt_orderdate = (TextView) rootView.findViewById(R.id.txt_order_date);
        txt_instructions = (TextView) rootView.findViewById(R.id.txt_instructions);
        txt_instructions.setText(getString(L.string.instructions));
        txt_accountdetails = (TextView) rootView.findViewById(R.id.txt_accountdetails);

        order_total_tax_section = (LinearLayout) rootView.findViewById(R.id.order_total_tax_section);
        order_total_tax_section.setVisibility(View.GONE);
        txt_totaltax = (TextView) rootView.findViewById(R.id.txt_totaltax);
        txt_totaltaxval = (TextView) rootView.findViewById(R.id.txt_totaltaxval);

        shipping_cost_section = (LinearLayout) rootView.findViewById(R.id.shipping_cost_section);
        shipping_cost_section.setVisibility(View.GONE);
        title_shipping_cost = (TextView) rootView.findViewById(R.id.title_shipping_cost);
        title_shipping_cost.setText(getString(L.string.total_shipping_cost));
        txt_shipping_cost = (TextView) rootView.findViewById(R.id.txt_shipping_cost);

        order_status_layout = (FrameLayout) rootView.findViewById(R.id.order_status_layout);
        order_status_layout.setVisibility(View.GONE);

        LinearLayout payment_proof_section = (LinearLayout) rootView.findViewById(R.id.payment_proof_section);
        payment_proof_section.setVisibility(View.GONE);

        image_done_1 = (ImageView) rootView.findViewById(R.id.image_done_1);
        image_done_2 = (ImageView) rootView.findViewById(R.id.image_done_2);
        image_done_3 = (ImageView) rootView.findViewById(R.id.image_done_3);
        image_done_4 = (ImageView) rootView.findViewById(R.id.image_done_4);

        step_onetxt = (TextView) rootView.findViewById(R.id.stepxtxt_one);
        step_twotxt = (TextView) rootView.findViewById(R.id.stepxtxt_two);
        step_threetxt = (TextView) rootView.findViewById(R.id.stepxtxt_three);
        step_fourtxt = (TextView) rootView.findViewById(R.id.stepxtxt_four);

        view_process_one = rootView.findViewById(R.id.view_process_one);
        view_process_two = rootView.findViewById(R.id.view_process_two);
        view_process_three = rootView.findViewById(R.id.view_process_three);

        TextView textViewYourOrderPlaced = (TextView) rootView.findViewById(R.id.your_order_placed);
        textViewYourOrderPlaced.setText(getString(L.string.your_order_placed));

        TextView textViewTrack = (TextView) rootView.findViewById(R.id.text_track);
        textViewTrack.setText(getString(L.string.track_order));

        TextView textViewCancel = (TextView) rootView.findViewById(R.id.text_cancel);
        textViewCancel.setText(getString(L.string.cancel_order));

        TextView textViewReturn = (TextView) rootView.findViewById(R.id.text_return);
        textViewReturn.setText(getString(L.string.title_return));

        TextView textViewErrorMessage = (TextView) rootView.findViewById(R.id.txt_error_msg);
        textViewErrorMessage.setText(getString(L.string.generic_error));

        TextView textViewYouCanNow = (TextView) rootView.findViewById(R.id.you_can_now);
        textViewYouCanNow.setText(getString(L.string.you_can_now));

        delivery_date_section = rootView.findViewById(R.id.delivery_date_section);
        delivery_time_section = rootView.findViewById(R.id.delivery_time_section);
        delivery_date_section.setVisibility(View.GONE);
        delivery_time_section.setVisibility(View.GONE);

        title_delivery_date = (TextView) rootView.findViewById(R.id.title_delivery_date);
        text_delivery_date = (TextView) rootView.findViewById(R.id.text_delivery_date);
        title_delivery_time = (TextView) rootView.findViewById(R.id.title_delivery_time);
        text_delivery_time = (TextView) rootView.findViewById(R.id.text_delivery_time);

        title_delivery_date.setText(getString(L.string.delivery_date));
        title_delivery_time.setText(getString(L.string.delivery_time));

        btn_my_orders = (Button) rootView.findViewById(R.id.btn_my_orders);
        if (AppInfo.mGuestUserConfig == null || !GuestUserConfig.isGuestCheckout() || AppUser.hasSignedIn())
            btn_my_orders.setText(getString(L.string.my_orders));
        else btn_my_orders.setText(getString(L.string.keep_shopping));

        Helper.stylize(btn_my_orders);
        btn_my_orders.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (AppInfo.mGuestUserConfig == null || !GuestUserConfig.isGuestCheckout() || AppUser.hasSignedIn())
                    MainActivity.mActivity.showOrdersFragment();
                else {
                    MainActivity.mActivity.onNavigationDrawerItemSelected(Constants.MENU_ID_HOME, -1);
                }
            }
        });

        if (order == null) {
            fetchOrder();
        } else {
            getOrderDeliverySlotInfo(order);
            handleOrderResponse();
        }

        clearCart();

        if (GuestUserConfig.isGuestCheckout() && !AppUser.hasSignedIn()) {
            Helper.saveGuestOrder(getActivity(), orderId);
        }

        showPickupLocationDialog();
        showOrderPlacedDialog();

        return rootView;
    }

    public void clearCart() {
        try {
            Cart.clearCart();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void fetchOrder() {
        error_page.setVisibility(View.GONE);
        showProgress(getString(L.string.please_wait));
        DataEngine.getDataEngine().getOrderInBackground(orderId, new DataQueryHandler<TM_Order>() {
            @Override
            public void onSuccess(TM_Order order) {
                Fragment_OrderReceipt.this.order = order;
                hideProgress();
                mOrderFetched = true;
                getOrderDeliverySlotInfo(order);
                handleOrderResponse();
                // register order event for Web payment gateway because update order is not called.
                if (paymentGateway instanceof WebPayGateway) {
                    try {
                        AnalyticsHelper.registerOrderEvent(order, true);
                    } catch (Exception ignored) {
                    }
                }
            }

            @Override
            public void onFailure(Exception exception) {
                hideProgress();
                error_page.setVisibility(View.VISIBLE);
            }
        });
    }

    void handleOrderResponse() {
        if (AppInfo.USE_PARSE_ANALYTICS) {
            CustomerData.getInstance().incrementCurrent_Day_Purchased_Amount(order.total);
            CustomerData.getInstance().incrementCurrent_Day_Purchased_Item(order.total_line_items_quantity);
            CustomerData.getInstance().saveInBackground();
        }
        if (timeSlot != null) {
            updateOrderTimeSlot(timeSlot, orderId);
        }
        getOrderProductData();
        if (MultiVendorConfig.isEnabled()) {
            assignOrderToVendor();
        }
    }

    private void assignOrderToVendor() {
        showProgress(getString(L.string.assign_order_to_vendor), false);
        DataEngine.getDataEngine().assignOrderToSellerInBackground(orderId, new DataQueryHandler<Void>() {
            @Override
            public void onSuccess(Void data) {
                hideProgress();
                mOrderFetched = true;
            }

            @Override
            public void onFailure(Exception error) {
                hideProgress();
                mOrderFetched = false;
                error.printStackTrace();
            }
        });
    }

    private void updateOrderTimeSlot(TimeSlot timeSlot, int orderId) {
        if (mOrderFetched) {
            return;
        }
        showProgress(getString(L.string.reservating_time_slots), false);
        HashMap<String, String> params = new HashMap<>();
        String url;
        if (TimeSlotConfig.getPluginType() == TimeSlotConfig.PluginType.DELIVERY_SLOTS) {
            url = DataEngine.getDataEngine().url_delivery_slots_copia;
            params.put("delivery_date", Base64Utils.encode(String.valueOf(timeSlot.getParent().getDateString())));
            params.put("cost", Base64Utils.encode(String.valueOf(timeSlot.getCost())));
            params.put("id", Base64Utils.encode(String.valueOf(timeSlot.getId())));
            params.put("order_id", Base64Utils.encode(String.valueOf(orderId)));
            params.put("type", Base64Utils.encode("order_slot"));
        } else {
            params.put("type", Base64Utils.encode("order_slot"));
            params.put("pickup_time", Base64Utils.encode(timeSlot.getId()));
            params.put("order_id", Base64Utils.encode(orderId));
            url = DataEngine.getDataEngine().url_local_pickup_time_select;
        }
        NetworkRequest.makeCommonPostRequest(url, params, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                hideProgress();
                mOrderFetched = true;
                Log.d("-- Fragment_OrderReceipt.updateOrderTimeSlot[" + response.msg + "] --");
                if (!response.succeed && response.error != null) {
                    mOrderFetched = false;
                    response.error.printStackTrace();
                }
            }
        });
    }

    public void fillOrderReceipt() {
        txt_orderid.setText(HtmlCompat.fromHtml(String.format(getString(L.string.order_id, true), order.order_number)));
        txt_totalitems.setText(HtmlCompat.fromHtml(String.format(getString(L.string.total_items), order.line_items.size())));

        if (AppInfo.HIDE_PRODUCT_PRICE_TAG) {
            txt_total.setVisibility(View.GONE);
        } else {
            txt_total.setVisibility(View.VISIBLE);
            txt_total.setText(HtmlCompat.fromHtml(Helper.appendCurrency(order.total)));
        }

        if (order.total_tax > 0 && !TextUtils.isEmpty(String.valueOf(order.total_tax))) {
            order_total_tax_section.setVisibility(View.VISIBLE);
            txt_totaltax.setText(getString(L.string.title_taxes));
            txt_totaltaxval.setText(HtmlCompat.fromHtml(Helper.appendCurrency(order.total_tax)));
        } else {
            order_total_tax_section.setVisibility(View.GONE);
        }

        String createdDate = Helper.getDateByPattern(order.created_at);
        if (!TextUtils.isEmpty(createdDate)) {
            txt_orderdate.setVisibility(View.VISIBLE);
            String finalDate = String.format(getString(L.string.order_created_date, true), createdDate);
            txt_orderdate.setText(HtmlCompat.fromHtml(finalDate));
        } else {
            txt_orderdate.setVisibility(View.GONE);
        }

        if (order.shipping_tax > 0 && !TextUtils.isEmpty(String.valueOf(order.shipping_tax))) {
            shipping_cost_section.setVisibility(View.VISIBLE);
            txt_shipping_cost.setText(HtmlCompat.fromHtml(Helper.appendCurrency(String.valueOf(order.total_shipping))));
        } else {
            shipping_cost_section.setVisibility(View.GONE);
        }

        Adapter_OrdersProduct adapter = new Adapter_OrdersProduct(getActivity(), order);
        adapter.setLayoutChangeListener(new Adapter_OrdersProduct.OnLayoutChangeListener() {
            @Override
            public void onLayoutChange() {
                fillOrderReceipt();
            }
        });

        layout_products.removeAllViews();
        for (int j = 0; j < adapter.getCount(); j++) {
            View v = adapter.getView(j, null, null);
            layout_products.addView(v, new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT));
        }

        setOrderDeliveryDateTimeSlot(order);

        boolean showInstructions = false;
        if (paymentGateway != null) {
            if (!TextUtils.isEmpty(paymentGateway.getInstructions())) {
                txt_instructions.setVisibility(View.VISIBLE);
                txt_instructions.setText(HtmlCompat.fromHtml(paymentGateway.getInstructions()));
                showInstructions = true;
            } else {
                txt_instructions.setVisibility(View.GONE);
            }

            String accountDetailsString = paymentGateway.getAccountDetailsString();
            if (!TextUtils.isEmpty(accountDetailsString)) {
                txt_accountdetails.setVisibility(View.VISIBLE);
                txt_accountdetails.setText(HtmlCompat.fromHtml(accountDetailsString));
                showInstructions = true;
            } else {
                txt_accountdetails.setVisibility(View.GONE);
            }
        }

        if (showInstructions) {
            instruction_section.setVisibility(View.VISIBLE);
        } else {
            instruction_section.setVisibility(View.GONE);
        }
        showOrderProgressView();
    }

    public void showOrderProgressView() {
        setOrderStatusStepEnabled(image_done_1, step_onetxt, L.string.approval);
        setOrderStatusStepEnabled(image_done_2, step_twotxt, L.string.processing);
        setOrderStatusStepDisabled(image_done_3, step_threetxt, L.string.shipping);
        setOrderStatusStepDisabled(image_done_4, step_fourtxt, L.string.delivered);
        view_process_one.setBackground(CContext.getDrawable(getActivity(), R.color.order_status_progress_bg_enable));
        view_process_two.setBackground(CContext.getDrawable(getActivity(), R.color.order_status_progress_bg_disable));
        view_process_three.setBackground(CContext.getDrawable(getActivity(), R.color.order_status_progress_bg_disable));
        order_status_layout.setVisibility(View.VISIBLE);
    }

    public void setOrderStatusStepEnabled(ImageView imageView, TextView textView, String textKey) {
        imageView.setBackground(Helper.getShapeRoundBG_Green());
        imageView.setImageResource(R.drawable.ic_check_circle);
        textView.setText(getString(textKey));
    }

    public void setOrderStatusStepDisabled(ImageView imageView, TextView textView, String textKey) {
        imageView.setBackground(Helper.getShapeRoundBG_Gray());
        imageView.setImageResource(R.drawable.ic_vc_more_horiz);
        textView.setText(getString(textKey));
    }


    private void getOrderDeliverySlotInfo(final TM_Order data) {
        if (mOrderFetched) {
            return;
        }
        if (TimeSlotConfig.isEnabled() && TimeSlotConfig.getPluginType() == TimeSlotConfig.PluginType.DELIVERY_SLOTS) {
            List<TM_Order> dataOrderList = new ArrayList<>();
            dataOrderList.add(data);
            showProgress(getString(L.string.fetching_orders));
            DataEngine.getDataEngine().getOrderDeliverySlots(dataOrderList, new DataQueryHandler() {
                @Override
                public void onSuccess(Object obj) {
                    hideProgress();
                    mOrderFetched = true;
                    setOrderDeliveryDateTimeSlot(data);
                }

                @Override
                public void onFailure(Exception error) {
                    error.printStackTrace();
                    mOrderFetched = false;
                    hideProgress();
                }
            });
        } else {
            hideProgress();
        }
    }

    private void setOrderDeliveryDateTimeSlot(TM_Order order) {
        if (TimeSlotConfig.isEnabled() && TimeSlotConfig.getPluginType() == TimeSlotConfig.PluginType.DELIVERY_SLOTS) {
            delivery_date_section.setVisibility(View.VISIBLE);
            delivery_time_section.setVisibility(View.VISIBLE);
            text_delivery_date.setText(order.deliveryDate);
            text_delivery_time.setText(order.deliveryTime);
            if (TextUtils.isEmpty(order.deliveryDate)) {
                delivery_date_section.setVisibility(View.GONE);
                Log.d("Order Delivery Date is empty");
            }
            if (TextUtils.isEmpty(order.deliveryTime)) {
                delivery_time_section.setVisibility(View.GONE);
                Log.d("Order Delivery Time is empty");
            }
        } else {
            delivery_date_section.setVisibility(View.GONE);
            delivery_time_section.setVisibility(View.GONE);
        }
    }

    private void getOrderProductData() {
        List<Integer> listProductId = new ArrayList<>();
        for (TM_LineItem line_items : order.line_items) {
            String thumbUrl = TM_ProductInfo.getThumbOfProduct(line_items.product_id);
            if (TextUtils.isEmpty(thumbUrl)) {
                listProductId.add(line_items.product_id);
            }
        }

        if (listProductId.size() > 0) {
            showProgress(getString(L.string.fetching_orders));
            DataEngine.getDataEngine().getPollProductsInBackground(listProductId, new DataQueryHandler<List<TM_ProductInfo>>() {
                @Override
                public void onSuccess(List<TM_ProductInfo> data) {
                    if (data != null) {
                        fillOrderReceipt();
                        hideProgress();
                    }
                }

                @Override
                public void onFailure(Exception error) {
                    error.printStackTrace();
                    fillOrderReceipt();
                    hideProgress();
                }
            });
        } else {
            fillOrderReceipt();
        }
    }

    public void showPickupLocationDialog() {
        if (AppInfo.SHOW_PICKUP_LOCATION) {
            String strPickupLocation = PickupLocation.getFirstPickupLocation();
            if (!TextUtils.isEmpty(strPickupLocation)) {
                AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
                String strAddress = getString(L.string.pickup_order_text) + " " + strPickupLocation;
                builder.setMessage(HtmlCompat.fromHtml(strAddress));
                builder.setCancelable(false);
                builder.setPositiveButton(getString(L.string.ok), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                    }
                });
                AlertDialog dialog = builder.create();
                dialog.show();
            }
        }
    }

    public void showOrderPlacedDialog() {
        if (AppInfo.SHOW_ORDER_PLACED_DIALOG) {
            final SimpleMessageDialog simpleMessageDialog = new SimpleMessageDialog();
            simpleMessageDialog.setTitle(getString(L.string.order_placed_dialog_title));
            simpleMessageDialog.setMessage(getString(L.string.order_placed_dialog_msg));
            simpleMessageDialog.setButtonText(getString(L.string.ok));
            simpleMessageDialog.setBtnOkClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    Helper.hideKeyboard(view);
                    simpleMessageDialog.dismiss();
                }
            });
            simpleMessageDialog.show(getFragmentManager(), SimpleMessageDialog.class.getSimpleName());
        }
    }
}