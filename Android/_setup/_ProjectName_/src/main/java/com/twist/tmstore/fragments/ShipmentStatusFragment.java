package com.twist.tmstore.fragments;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.google.gson.Gson;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.Constants;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.listeners.BackKeyListener;
import com.twist.tmstore.shipping.ShippingStatusRajaongkir;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.customviews.progressbar.CircleProgressBar;

import org.json.JSONException;
import org.json.JSONObject;

public class ShipmentStatusFragment extends BaseFragment {

    public static ShipmentStatusFragment newInstance() {
        return new ShipmentStatusFragment();
    }

    private View rootView;
    private CircleProgressBar progressBar;
    private LinearLayout listView;
    private LinearLayout section_shipment_details;
    private TextView text_delivery_status;
    private TextView text_delivery_date;
    private TextView text_delivery_time;
    private TextView text_delivery_receiver;
    private TextView text_bill_number;
    private TextView text_bill_date;
    private TextView text_bill_time;
    private TextView text_order_weight;
    private TextView text_order_origin;
    private TextView text_order_destination;
    private TextView text_shipper_name;
    private TextView text_shipper_address;
    private TextView text_shipper_city;
    private TextView text_receiver_name;
    private TextView text_receiver_address;
    private TextView text_receiver_city;
    private TextView text_no_data;

    private ShippingStatusRajaongkir shippingStatusRajaongkir;

    private String mWayBillNumber;

    public ShipmentStatusFragment() {
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Bundle bundle = getArguments();
        if (bundle != null) {
            mWayBillNumber = bundle.getString(Constants.ARG_WAYBILL_NUMBER);
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        setActionBarHomeAsUpIndicator();
        getBaseActivity().restoreActionBar();

        rootView = inflater.inflate(R.layout.fragment_shipment_status_rajaongkir, container, false);

        section_shipment_details = (LinearLayout) rootView.findViewById(R.id.section_shipment_details);
        section_shipment_details.setVisibility(View.GONE);

        text_no_data = (TextView) rootView.findViewById(R.id.text_no_data);
        text_no_data.setVisibility(View.GONE);

        progressBar = (CircleProgressBar) rootView.findViewById(R.id.progress_bar);
        Helper.stylize(progressBar);
        initUI();

        loadOrderStatusData();
        setTitle(getString(L.string.shipping_details));

        addBackKeyListenerOnView(rootView, new BackKeyListener() {
            @Override
            public void onBackPressed() {
                ((MainActivity) getActivity()).showHomeFragment(true);
            }
        });
        return rootView;
    }

    public void loadOrderStatusData() {
        progressBar.setVisibility(View.VISIBLE);
        DataEngine.getDataEngine().getShipmentStatusDataInBackground(AppInfo.SHIPPING_TRACK_URL, mWayBillNumber, "jne", AppInfo.SHIPPING_KEY, new DataQueryHandler<String>() {
            @Override
            public void onSuccess(String data) {
                progressBar.setVisibility(View.GONE);
                JSONObject rootObj;
                try {
                    rootObj = new JSONObject(data);
                    JSONObject inner = rootObj.getJSONObject("rajaongkir");
                    if (inner.getJSONObject("status").getInt("code") == 200) {
                        shippingStatusRajaongkir = new Gson().fromJson(inner.toString(), ShippingStatusRajaongkir.class);
                        loadData();
                    } else {
                        text_no_data.setVisibility(View.VISIBLE);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                    progressBar.setVisibility(View.GONE);
                    text_no_data.setVisibility(View.VISIBLE);
                }
            }

            @Override
            public void onFailure(Exception error) {
                progressBar.setVisibility(View.GONE);
            }
        });
    }

    public void initUI() {
        listView = (LinearLayout) rootView.findViewById(R.id.list_manifest);
        text_delivery_status = (TextView) rootView.findViewById(R.id.text_delivery_status);
        text_delivery_date = (TextView) rootView.findViewById(R.id.text_delivery_date);
        text_delivery_time = (TextView) rootView.findViewById(R.id.text_delivery_time);
        text_delivery_receiver = (TextView) rootView.findViewById(R.id.text_delivery_receiver);
        text_bill_number = (TextView) rootView.findViewById(R.id.text_bill_number);
        text_bill_date = (TextView) rootView.findViewById(R.id.text_bill_date);
        text_bill_time = (TextView) rootView.findViewById(R.id.text_bill_time);
        text_order_weight = (TextView) rootView.findViewById(R.id.text_order_weight);
        text_order_origin = (TextView) rootView.findViewById(R.id.text_order_origin);
        text_order_destination = (TextView) rootView.findViewById(R.id.text_order_destination);
        text_shipper_name = (TextView) rootView.findViewById(R.id.text_shipper_name);
        text_shipper_address = (TextView) rootView.findViewById(R.id.text_shipper_address);
        text_shipper_city = (TextView) rootView.findViewById(R.id.text_shipper_city);
        text_receiver_name = (TextView) rootView.findViewById(R.id.text_receiver_name);
        text_receiver_address = (TextView) rootView.findViewById(R.id.text_receiver_address);
        text_receiver_city = (TextView) rootView.findViewById(R.id.text_receiver_city);


        text_delivery_status.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_delivery_status), getString(L.string.not_available))));
        text_delivery_date.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_delivery_date), getString(L.string.not_available))));
        text_delivery_time.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_delivery_time), getString(L.string.not_available))));
        text_delivery_receiver.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_delivery_receiver), getString(L.string.not_available))));
        text_bill_number.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_bill_number), getString(L.string.not_available))));
        text_bill_date.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_bill_date), getString(L.string.not_available))));
        text_bill_time.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_bill_time), getString(L.string.not_available))));
        text_order_weight.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_order_weight), getString(L.string.not_available))));
        text_order_origin.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_order_origin), getString(L.string.not_available))));
        text_order_destination.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_order_destination), getString(L.string.not_available))));
        text_shipper_name.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_shipper_name), getString(L.string.not_available))));
        text_shipper_address.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_shipper_address), getString(L.string.not_available))));
        text_shipper_city.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_shipper_city), getString(L.string.not_available))));
        text_receiver_name.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_receiver_name), getString(L.string.not_available))));
        text_receiver_address.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_receiver_address), getString(L.string.not_available))));
        text_receiver_city.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_receiver_city), getString(L.string.not_available))));
    }

    public void loadData() {
        section_shipment_details.setVisibility(View.VISIBLE);

        if (shippingStatusRajaongkir.getShippingDetails() != null) {
            ShippingStatusRajaongkir.DeliveryStatus status = shippingStatusRajaongkir.getShippingDeliveryStatus();
            text_delivery_status.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_delivery_status), status.status)));
            text_delivery_date.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_delivery_date), status.pod_date)));
            text_delivery_time.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_delivery_time), status.pod_time)));
            text_delivery_receiver.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_delivery_receiver), status.pod_receiver)));
        }

        if (shippingStatusRajaongkir.getShippingDetails() != null) {
            ShippingStatusRajaongkir.Details details = shippingStatusRajaongkir.getShippingDetails();
            text_bill_number.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_bill_number), details.waybill_number)));
            text_bill_date.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_bill_date), details.waybill_date)));
            text_bill_time.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_bill_time), details.waybill_time)));
            text_order_weight.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_order_weight), details.weight)));
            text_order_origin.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_order_origin), details.origin)));
            text_order_destination.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_order_destination), details.destination)));
            text_shipper_name.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_shipper_name), details.shippper_name)));
            text_shipper_address.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_shipper_address), details.shipper_address1)));
            text_shipper_city.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_shipper_city), details.shipper_city)));
            text_receiver_name.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_receiver_name), details.receiver_name)));
            text_receiver_address.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_receiver_address), details.receiver_address1)));
            text_receiver_city.setText(HtmlCompat.fromHtml(String.format(getString(L.string.text_receiver_city), details.receiver_city)));
        }

        ShippingStatusRajaongkir.Manifest manifest[] = shippingStatusRajaongkir.result.manifest;
        int totLength = manifest.length;
        for (int i = 0; i < totLength; i++) {
            View view = View.inflate(getContext(), R.layout.item_order_status, null);
            if (view != null) {
                View marker_top = view.findViewById(R.id.marker_top);
                marker_top.setVisibility(View.INVISIBLE);

                View marker_bottom = view.findViewById(R.id.marker_bottom);
                marker_bottom.setVisibility(View.INVISIBLE);

                if (i == 0) {
                    marker_top.setVisibility(View.VISIBLE);
                } else if (i == totLength - 1) {
                    View marker_track = view.findViewById(R.id.marker_track);
                    marker_track.setVisibility(View.INVISIBLE);
                    marker_top.setVisibility(View.VISIBLE);
                    marker_bottom.setVisibility(View.INVISIBLE);
                } else {
                    marker_top.setVisibility(View.VISIBLE);
                }

                ShippingStatusRajaongkir.Manifest item = manifest[i];
                TextView data = (TextView) view.findViewById(R.id.date);
                data.setText(item.getDate());

                TextView time = (TextView) view.findViewById(R.id.time);
                time.setText(item.getTime());

                TextView description = (TextView) view.findViewById(R.id.description);
                description.setText(item.getDescription());

                TextView city_name = (TextView) view.findViewById(R.id.city_name);
                city_name.setText(item.getCityName());
                listView.addView(view);
            }
        }
    }
}