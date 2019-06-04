package com.twist.tmstore.fragments;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.twist.dataengine.entities.TM_Order;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.Constants;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.BaseActivity;
import com.twist.tmstore.adapters.Adapter_OrdersList;
import com.twist.tmstore.config.TimeSlotConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.listeners.BackKeyListener;
import com.utils.DataHelper;
import com.utils.Helper;
import com.utils.ImageUpload;
import com.utils.JsonUtils;
import com.utils.Log;
import com.utils.Preferences;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class Fragment_Orders extends BaseFragment {

    private List<TM_Order> mOrderList = new ArrayList<>();
    private Adapter_OrdersList mOrderAdapter = null;

    TM_Order orderToUpdate;

    ImageUpload imageUpload;
    ProgressBar progressUploadImage;

    public static Fragment_Orders newInstance() {
        return new Fragment_Orders();
    }

    View rootView;

    public Fragment_Orders() {
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getBaseActivity().restoreActionBar();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        rootView = inflater.inflate(R.layout.fragment_orders, container, false);
        imageUpload = new ImageUpload(rootView, getActivity());
        setActionBarHomeAsUpIndicator();
        getBaseActivity().restoreActionBar();

        ListView listView = rootView.findViewById(R.id.list_orders);
        TextView textViewEmpty = rootView.findViewById(R.id.text_empty);
        textViewEmpty.setText(getString(L.string.no_orders));

        listView.setEmptyView(textViewEmpty);

        if (mOrderAdapter == null) {
            mOrderAdapter = new Adapter_OrdersList((BaseActivity) getActivity(), mOrderList, false, true, new Adapter_OrdersList.ImageUploadListener() {
                @Override
                public void onImageUploadSelected(TM_Order order, ProgressBar progressBar) {
                    orderToUpdate = order;
                    imageUpload.selectImage();
                    progressUploadImage = progressBar;
                }

                @Override
                public void onImageSelected(Object object) {
                }

                @Override
                public void onImageDeleted(Object object) {
                }
            });
        }
        listView.setAdapter(mOrderAdapter);

        mOrderAdapter.setCancelRequestListener(new Adapter_OrdersList.CancelRequestListener() {
            @Override
            public void onCancelRequested(int orderId) {
                requestOrderCancel(orderId);
            }

            @Override
            public void onStatusSelected(String status, TM_Order tm_order) {
            }
        });

        setTitle(getString(L.string.my_orders));
        addBackKeyListenerOnView(rootView, () -> ((MainActivity) getActivity()).showHomeFragment(true));
        fetchOrders();
        return rootView;
    }


    public void requestOrderCancel(final int orderId) {
        showProgress(getString(L.string.updating_order), false);
        try {
            String str = JsonUtils.createOrderStatusJsonString("cancelled");
            DataEngine.getDataEngine().updateOrderStatusInBackground(orderId, str, new DataQueryHandler<TM_Order>() {
                @Override
                public void onSuccess(TM_Order order) {
                    try {
                        hideProgress();
                        Helper.toast(L.string.cancellation_requested_successfully);
                        TM_Order tmOrder = findOrderById(orderId);
                        if (tmOrder != null) {
                            tmOrder.update(order);
                        }
                        mOrderAdapter.notifyDataSetChanged();
                        Helper.gc();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }

                @Override
                public void onFailure(Exception reason) {
                    hideProgress();
                    Helper.showToast(String.format(getString(L.string.unable_to_cancel_order), reason));
                }
            });
        } catch (Exception e) {
            hideProgress();
            Helper.showToast(String.format(getString(L.string.unable_to_cancel_order), e.getMessage()));
        }
    }

    public void fetchOrders() {
        final DataQueryHandler dataQueryHandler = new DataQueryHandler<List<TM_Order>>() {
            @Override
            public void onSuccess(List<TM_Order> data) {
                try {
                    mOrderList.clear();
                    mOrderList.addAll(data);
                    mOrderAdapter.notifyDataSetChanged();
                    getOrderPoints();
                    getOrdersDeliverySlot(data);
                    getOrdersMetaData(data);
                    getShipmentTrackingData(data);
                    getOrderPaymentProof(data);
                    getOrdersBookingInfoSlot(data);
                    hideProgress();
                } catch (IllegalStateException ex) {
                    ex.printStackTrace();
                    hideProgress();
                }
            }

            @Override
            public void onFailure(Exception exception) {
                hideProgress();
            }
        };

        showProgress(getString(L.string.fetching_orders));
        if (AppUser.hasSignedIn()) {
            DataEngine.getDataEngine().getOrdersInBackground(AppUser.getUserId(), dataQueryHandler);
        } else {
            String orderIds = Preferences.getString(Constants.GUEST_ORDER_ID, "");
            DataEngine.getDataEngine().getGuestOrdersInBackground(orderIds, dataQueryHandler);
        }
    }

    private void getOrdersDeliverySlot(List<TM_Order> data) {
        if (TimeSlotConfig.isEnabled() && TimeSlotConfig.getPluginType() == TimeSlotConfig.PluginType.DELIVERY_SLOTS) {
            showProgress(getString(L.string.fetching_orders));
            DataEngine.getDataEngine().getOrderDeliverySlots(data, new DataQueryHandler() {
                @Override
                public void onSuccess(Object obj) {
                    hideProgress();
                    mOrderAdapter.notifyDataSetChanged();
                }

                @Override
                public void onFailure(Exception error) {
                    error.printStackTrace();
                    hideProgress();
                }
            });
        } else {
            hideProgress();
        }
    }

    private void getOrdersBookingInfoSlot(List<TM_Order> data) {
        if (AppInfo.SHOW_PRODUCTS_BOOKING_INFO) {
            showProgress(getString(L.string.please_wait));
            DataEngine.getDataEngine().getOrderBookingInfoStatus(data, new DataQueryHandler() {
                @Override
                public void onSuccess(Object obj) {
                    hideProgress();
                    mOrderAdapter.notifyDataSetChanged();
                }

                @Override
                public void onFailure(Exception error) {
                    error.printStackTrace();
                    hideProgress();
                }
            });
        } else {
            hideProgress();
        }
    }

    private void getOrdersMetaData(final List<TM_Order> orderList) {
        if (!AppInfo.ENABLE_MULTI_STORE_CHECKOUT) {
            return;
        }

        showProgress(getString(L.string.please_wait));
        DataEngine.getDataEngine().getOrderMetaDataInBackground(orderList, new DataQueryHandler<String>() {
            @Override
            public void onSuccess(String data) {
                try {
                    JSONArray jsonArray = new JSONArray(data);
                    for (int i = 0; i < jsonArray.length(); i++) {
                        JSONObject jsonObject = jsonArray.getJSONObject(i);
                        if (jsonObject.has("meta_data")) {
                            Object metaDataObject = jsonObject.get("meta_data");
                            if (metaDataObject instanceof JSONObject) {
                                JSONObject metaDataJsonObject = (JSONObject) metaDataObject;
                                Iterator<String> keys = metaDataJsonObject.keys();
                                StringBuilder metaDataString = new StringBuilder();
                                while (keys.hasNext()) {
                                    String key = keys.next();
                                    String value = metaDataJsonObject.getString(key);
                                    metaDataString.append(key).append(" : ").append(value).append("\n");
                                }
                                String orderId = jsonObject.getString("order_id");
                                try {
                                    TM_Order order = findOrderById(Integer.parseInt(orderId));
                                    if (order != null) {
                                        order.metaData = metaDataString.toString();
                                    }
                                } catch (NumberFormatException e) {
                                    e.printStackTrace();
                                }
                            }
                        }
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
                mOrderAdapter.notifyDataSetChanged();
                hideProgress();
            }

            @Override
            public void onFailure(Exception error) {
                error.printStackTrace();
                hideProgress();
            }
        });
    }

    private void getOrderPaymentProof(final List<TM_Order> orderList) {
        if (!AppInfo.REQUIRE_ORDER_PAYMENT_PROOF) {
            return;
        }

        hideProgress();
        showProgress(getString(L.string.please_wait));
        DataEngine.getDataEngine().getOrderPaymentProofInBackground(orderList, new DataQueryHandler<String>() {
            @Override
            public void onSuccess(String data) {
                try {
                    JSONArray root = new JSONArray(data);
                    for (int i = 0; i < root.length(); i++) {
                        JSONObject obj = (JSONObject) root.get(i);
                        int id = obj.getInt("order_id");
                        String fileUrl = obj.getString("file_url");
                        TM_Order order = findOrderById(id);
                        if (order != null) {
                            order.imgUploadUrl = fileUrl;
                        }
                    }
                    mOrderAdapter.refresh();
                    hideProgress();
                } catch (JSONException e) {
                    e.printStackTrace();
                    hideProgress();
                }
            }

            @Override
            public void onFailure(Exception error) {
                error.printStackTrace();
                hideProgress();
            }
        });
    }

    private void getShipmentTrackingData(final List<TM_Order> orderList) {
        if (!AppInfo.ENABLE_SHIPMENT_TRACKING) {
            return;
        }

        showProgress(getString(L.string.please_wait));

        // Clear all shipment tracking ids
        for (TM_Order order : orderList) {
            if (order != null) {
                order.trackingIds.clear();
            }
        }

        DataEngine.getDataEngine().getShipmentTrackingData(Constants.Key.SHIPPING_AFTERSHIP, orderList, new DataQueryHandler<String>() {
            @Override
            public void onSuccess(String data) {
                try {
                    JSONArray jsonArray = new JSONArray(data);
                    for (int i = 0; i < jsonArray.length(); i++) {
                        JSONObject jsonObject = jsonArray.getJSONObject(i);
                        String orderId = jsonObject.getString("order_id");
                        try {
                            TM_Order order = findOrderById(Integer.parseInt(orderId));
                            if (order != null) {
                                order.provider = jsonObject.getString("provider");
                                order.trackingURL = jsonObject.getString("tracking_url");
                                order.trackingIds.add(jsonObject.getString("tracking_id"));
                            }
                        } catch (NumberFormatException e) {
                            e.printStackTrace();
                        }
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
                mOrderAdapter.refresh();
                hideProgress();
            }

            @Override
            public void onFailure(Exception error) {
                error.printStackTrace();
                hideProgress();
            }
        });
    }

    private void getOrderPoints() {
        if (!AppInfo.ENABLE_CUSTOM_POINTS) {
            hideProgress();
            return;
        }

        String orderIds = "";
        for (int i = 0; i < mOrderList.size(); i++) {
            orderIds += mOrderList.get(i).id;
            if (i < mOrderList.size() - 1) {
                orderIds += ",";
            }
        }
        orderIds = "[" + orderIds + "]";

        Map<String, String> params = new HashMap<>();
        params.put("user_id", "" + AppUser.getUserId());
        params.put("email_id", AppUser.getEmail());
        params.put("order_ids", orderIds);
        DataEngine.getDataEngine().getOrderRewardPointsAsync(params, new DataQueryHandler<String>() {
            @Override
            public void onSuccess(String data) {
                try {
                    JSONObject jsonObject = new JSONObject(data);
                    JSONArray orderDataArray = jsonObject.getJSONArray("order_data");
                    for (int i = 0; i < orderDataArray.length(); i++) {
                        JSONObject orderData = orderDataArray.getJSONObject(i);
                        TM_Order order = findOrderById(orderData.getInt("order_no"));
                        if (order != null) {
                            order.setPointsEarned(DataHelper.safeInt(orderData, "points_earned", 0));
                            order.setPointsRedeemed(DataHelper.safeInt(orderData, "points_redeemed", 0));
                        }
                    }
                    if (mOrderAdapter != null) {
                        mOrderAdapter.notifyDataSetChanged();
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                Log.d(data);
                hideProgress();
            }

            @Override
            public void onFailure(Exception error) {
                error.printStackTrace();
                hideProgress();
            }
        });
    }

    private TM_Order findOrderById(int orderId) {
        for (TM_Order order : mOrderList) {
            if (order.id == orderId)
                return order;
        }
        return null;
    }

    public void handleActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == ImageUpload.REQUEST_IMAGE_CAPTURE && resultCode == Activity.RESULT_OK) {
            Bitmap originalBitmap = BitmapFactory.decodeFile(imageUpload.mCurrentPhotoPath);
            imageUpload.uploadImage(originalBitmap, new ImageUpload.ImageUploadListner() {
                @Override
                public void UploadSuccess(String url) {
                    showUploadImageProgressBar();
                    DataEngine.getDataEngine().updateOrderPaymentProofInBackground(orderToUpdate.id, url, new DataQueryHandler() {
                        @Override
                        public void onSuccess(Object data) {
                            String response = (String) data;
                            if (response.equalsIgnoreCase("success")) {
                                mOrderAdapter.refresh();
                            } else {
                                Log.d("Image Upload Error: [" + response + "]");
                            }
                            hideUploadImageProgressBar();
                        }

                        @Override
                        public void onFailure(Exception error) {
                            Log.d("Image Upload Error: [" + error.getMessage() + "]");
                            hideUploadImageProgressBar();
                        }
                    });
                }
            });
        }
        if (data != null && requestCode == ImageUpload.PICK_PHOTO_CODE) {
            Uri photoUri = data.getData();
            try {
                Bitmap originalBitmap = MediaStore.Images.Media.getBitmap(getActivity().getContentResolver(), photoUri);
                imageUpload.uploadImage(originalBitmap, new ImageUpload.ImageUploadListner() {
                    @Override
                    public void UploadSuccess(String url) {
                        showUploadImageProgressBar();
                        DataEngine.getDataEngine().updateOrderPaymentProofInBackground(orderToUpdate.id, url, new DataQueryHandler() {
                            @Override
                            public void onSuccess(Object data) {
                                hideUploadImageProgressBar();
                                String response = (String) data;
                                if (response.equalsIgnoreCase("success")) {
                                    mOrderAdapter.refresh();
                                } else {
                                    Log.d("Image Upload Error: [" + response + "]");
                                }
                            }

                            @Override
                            public void onFailure(Exception error) {
                                Log.d("Image Upload Error: [" + error.getMessage() + "]");
                                hideUploadImageProgressBar();
                            }
                        });
                    }
                });
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    public void showUploadImageProgressBar() {
        if (progressUploadImage != null) {
            progressUploadImage.setVisibility(View.VISIBLE);
        }
    }

    public void hideUploadImageProgressBar() {
        if (progressUploadImage != null) {
            progressUploadImage.setVisibility(View.GONE);
        }
    }
}