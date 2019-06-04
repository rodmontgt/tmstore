package com.twist.tmstore.fragments;

import android.content.Intent;
import android.graphics.Paint;
import android.os.Bundle;
import android.support.v7.widget.AppCompatSpinner;
import android.support.v7.widget.CardView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.ScrollView;
import android.widget.Spinner;
import android.widget.TextView;

import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.ShippingAddressPickerActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.Adapter_HtmlString;
import com.twist.tmstore.adapters.AddressListAdapter;
import com.twist.tmstore.config.MultiStoreCheckoutConfig;
import com.twist.tmstore.entities.Address;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.listeners.OnProfileEditListener;
import com.utils.ArrayUtils;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.JsonHelper;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class Fragment_ConfirmOrder extends BaseFragment {
    ListView list_address;
    TextView txt_username, txt_email, txt_name;
    ArrayList<Address> addressArray = new ArrayList<>();
    AddressListAdapter adapter = null;
    ScrollView scrollView_address;
    TextView txt_change;
    private Button mSelectPaymentButton;
    private View rootView;

    private MultiStoreCheckoutConfig mMultiStoreCheckoutConfig;

    public static Fragment_ConfirmOrder newInstance() {
        return new Fragment_ConfirmOrder();
    }

    public Fragment_ConfirmOrder() {
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        if (rootView == null) {
            // Update shipping & billing address titles if locale changed
            Address billing_address = AppUser.getInstance().billing_address;
            if (billing_address != null) {
                billing_address.title = getString(L.string.billing_address);
            }

            Address shipping_address = AppUser.getInstance().shipping_address;
            if (shipping_address != null) {
                shipping_address.title = getString(L.string.shipping_address);
            }

            rootView = inflater.inflate(R.layout.fragment_confirmorder, container, false);
            list_address = (ListView) rootView.findViewById(R.id.list_address);
            txt_username = (TextView) rootView.findViewById(R.id.txt_username);
            txt_email = (TextView) rootView.findViewById(R.id.txt_email);
            txt_name = (TextView) rootView.findViewById(R.id.txt_name);
            txt_change = (TextView) rootView.findViewById(R.id.txt_change);
            txt_change.setText(getString(L.string.change));

            scrollView_address = (ScrollView) rootView.findViewById(R.id.scrollView_address);

            ImageButton btn_edit = (ImageButton) rootView.findViewById(R.id.btn_edit);
            Helper.stylizeVector(btn_edit);
            btn_edit.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    openEditProfileFragment();
                }
            });

            txt_change.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    openEditProfileFragment();
                }
            });
            txt_change.setPaintFlags(txt_change.getPaintFlags() | Paint.UNDERLINE_TEXT_FLAG);
            txt_change.setText(HtmlCompat.fromHtml(getString(L.string.change)));

            TextView textViewSavedAddresses = (TextView) rootView.findViewById(R.id.saved_addresses);
            textViewSavedAddresses.setText(getString(L.string.saved_addresses));

            TextView textViewSelectFromSavedAddresses = (TextView) rootView.findViewById(R.id.select_from_saved_addresses);
            textViewSelectFromSavedAddresses.setText(getString(L.string.select_from_saved_addresses));

            mSelectPaymentButton = (Button) rootView.findViewById(R.id.btn_selectpayment);
            mSelectPaymentButton.setText(getString(L.string.select_payment));
            Helper.stylize(mSelectPaymentButton);

            adapter = new AddressListAdapter(addressArray);
            list_address.setAdapter(adapter);

            ImageView img_indication_1 = (ImageView) rootView.findViewById(R.id.img_indication_1);
            img_indication_1.setBackground(Helper.getTransparentRoundBackground(AppInfo.color_theme));
            Helper.stylizeDynamically(img_indication_1);

            ImageView img_indication_2 = (ImageView) rootView.findViewById(R.id.img_indication_2);
            img_indication_2.setBackground(Helper.getTransparentRoundBackground(AppInfo.color_theme));
            Helper.stylizeDynamically(img_indication_2);

            setTitle(getString(L.string.confirm_order));
            if (AppInfo.USE_MULTIPLE_SHIPPING_ADDRESSES) {
                startActivity(new Intent(getActivity(), ShippingAddressPickerActivity.class));
            }
            loadMultiStoreCheckoutData(rootView);
        }
        return rootView;
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        refresh();
    }

    public void refresh() {
        txt_username.setText(AppUser.getInstance().username);
        txt_email.setText(AppUser.getEmail());
        txt_name.setText(String.format("%s %s", AppUser.getInstance().first_name, AppUser.getInstance().last_name));
        addressArray.clear();
        addressArray.add(AppUser.getInstance().billing_address);
        //addressArray.add(AppUser.getInstance().shipping_address); //this address is useless
        adapter.notifyDataSetChanged();
        Helper.setListViewHeightBasedOnChildren(list_address);

        if (AppUser.getInstance().isProfileComplete()) {
            mSelectPaymentButton.setText(getString(L.string.select_payment));
            mSelectPaymentButton.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    String metaDataString = getCheckoutMetadataString();
                    MainActivity.mActivity.openSelectPaymentPage(new String[]{metaDataString, selectedDeliveryTypeId});
                }
            });
        } else {
            mSelectPaymentButton.setText(getString(L.string.complete_profile));
            mSelectPaymentButton.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    openEditProfileFragment();
                }
            });
        }
    }

    public void openEditProfileFragment() {
        MainActivity activity = (MainActivity) getActivity();
        activity.setOnProfileEditListener(new OnProfileEditListener() {
            @Override
            public void done() {
                refresh();
            }

            @Override
            public void canceled() {
            }
        });
        activity.showEditProfile(false);
    }

    private void loadMultiStoreCheckoutData(View parentView) {
        final CardView cardView = (CardView) parentView.findViewById(R.id.card_view_checkout_detail);
        final LinearLayout checkout_detail = (LinearLayout) parentView.findViewById(R.id.checkout_detail);
        if (!AppInfo.ENABLE_MULTI_STORE_CHECKOUT) {
            cardView.setVisibility(View.GONE);
            checkout_detail.setVisibility(View.GONE);
            return;
        }

        showProgress(getString(L.string.please_wait));
        DataEngine.getDataEngine().getMultiStoreCheckoutDataInBackground(new DataQueryHandler<String>() {
            @Override
            public void onSuccess(String data) {
                if (getContext() == null)
                    return;
                mMultiStoreCheckoutConfig = new MultiStoreCheckoutConfig();
                MultiStoreCheckoutConfig.DeliverSlot deliverSlot;
                try {
                    cardView.setVisibility(View.VISIBLE);
                    checkout_detail.setVisibility(View.VISIBLE);
                    JSONArray jsonArray = new JSONArray(data);
                    for (int i = 0; i < jsonArray.length(); i++) {
                        JSONObject jsonObject = jsonArray.getJSONObject(i);
                        String label = jsonObject.getString("label");
                        String cow = jsonObject.getString("cow");
                        String chosen_valt = jsonObject.getString("chosen_valt");
                        String conditional_tie = jsonObject.getString("conditional_tie");
                        String force_title2 = jsonObject.getString("force_title2");
                        String[] option_array = null;
                        try {
                            option_array = jsonObject.getString("option_array").trim().split("\\|\\|"); // separate by ||
                        } catch (Exception e) {
                            e.printStackTrace();
                        }

                        if (cow.equalsIgnoreCase("myfield1")) {
                            mMultiStoreCheckoutConfig.deliveryTypeLabel = label;
                            mMultiStoreCheckoutConfig.deliveryTypeOptions = option_array;
                            mMultiStoreCheckoutConfig.selectedDeliveryType = chosen_valt;
                            mMultiStoreCheckoutConfig.deliveryTypeField = "myfield1";
                            if (JsonHelper.getString(jsonObject, "add_amount").equals("true")) {
                                mMultiStoreCheckoutConfig.deliveryFee = JsonHelper.getString(jsonObject, "add_amount_field");
                            }
                        } else if (cow.equalsIgnoreCase("myfield2")) {
                            mMultiStoreCheckoutConfig.clusterDestinationsLabel = label;
                            mMultiStoreCheckoutConfig.clusterDestinationsOptions = option_array;
                            mMultiStoreCheckoutConfig.selectedClusterDestination = chosen_valt;
                            mMultiStoreCheckoutConfig.clusterDestinationsField = "myfield2";
                        } else if (cow.equalsIgnoreCase("myfield3")) {
                            mMultiStoreCheckoutConfig.deliveryDaysLabel = label;
                            mMultiStoreCheckoutConfig.deliveryDaysOptions = option_array;
                            mMultiStoreCheckoutConfig.selectedDeliveryDay = chosen_valt;
                            mMultiStoreCheckoutConfig.deliveryDaysField = "myfield3";
                        } else if (cow.equalsIgnoreCase("myfield6")) {
                            mMultiStoreCheckoutConfig.homeDestinationLabel = label;
                            mMultiStoreCheckoutConfig.homeDestinationOptions = option_array;
                            mMultiStoreCheckoutConfig.selectedHomeDestination = chosen_valt;
                            mMultiStoreCheckoutConfig.homeDestinationField = "myfield6";
                        } else if (cow.equalsIgnoreCase("myfield4")
                                || cow.equalsIgnoreCase("myfield5")
                                || cow.equalsIgnoreCase("myfield7")
                                || cow.equalsIgnoreCase("myfield8")
                                || cow.equalsIgnoreCase("myfield9")
                                || cow.equalsIgnoreCase("myfield10")
                                || cow.equalsIgnoreCase("myfield11")) {
                            deliverSlot = new MultiStoreCheckoutConfig.DeliverSlot();
                            deliverSlot.label = label;
                            deliverSlot.options = option_array;
                            deliverSlot.chosen_valt = chosen_valt;
                            deliverSlot.field = cow;
                            mMultiStoreCheckoutConfig.deliverSlots.add(deliverSlot);
                        }
                    }
                    hideProgress();
                } catch (JSONException e) {
                    e.printStackTrace();
                    cardView.setVisibility(View.GONE);
                    checkout_detail.setVisibility(View.GONE);
                    hideProgress();
                }
                setAllSpinners(checkout_detail, mMultiStoreCheckoutConfig);
            }

            @Override
            public void onFailure(Exception error) {
                error.printStackTrace();
                cardView.setVisibility(View.GONE);
                checkout_detail.setVisibility(View.GONE);
                hideProgress();
            }
        });
    }

    private Spinner spinnerClusterDestinations;
    private String selectedDeliveryType;
    private String selectedHomeDestination;
    private String selectedClusterDestinations;
    private String selectedDeliveryDays;
    private String selectedDeliverSlots;
    private String selectedDeliveryTypeId = "";

    private void setAllSpinners(final LinearLayout checkout_detail, final MultiStoreCheckoutConfig config) {
        final TextView textViewDeliveryType = addNewTextView(checkout_detail, config.deliveryTypeLabel);
        final Spinner spinnerDeliveryType = addNewSpinner(checkout_detail, ArrayUtils.asList(config.deliveryTypeOptions));
        //final Spinner spinnerDeliveryType = addNewSpinner(checkout_detail, getMergedList(config.deliveryTypeLabel, config.deliveryTypeOptions));

        final TextView textViewClusterDestinations = addNewTextView(checkout_detail, config.clusterDestinationsLabel);
        spinnerClusterDestinations = addNewSpinner(checkout_detail, ArrayUtils.asList(config.clusterDestinationsOptions));
        //spinnerClusterDestinations = addNewSpinner(checkout_detail, getMergedList(config.clusterDestinationsLabel, config.clusterDestinationsOptions));
        spinnerClusterDestinations.setVisibility(View.GONE);

        final TextView textViewHomeDestination = addNewTextView(checkout_detail, config.homeDestinationLabel);
        final Spinner spinnerHomeDestination = addNewSpinner(checkout_detail, ArrayUtils.asList(config.homeDestinationOptions));
        //final Spinner spinnerHomeDestination = addNewSpinner(checkout_detail, getMergedList(config.homeDestinationLabel, config.homeDestinationOptions));

        final TextView textViewDeliveryDays = addNewTextView(checkout_detail, config.deliveryDaysLabel);
        final Spinner spinnerDeliveryDays = addNewSpinner(checkout_detail, ArrayUtils.asList(config.deliveryDaysOptions));
        //final Spinner spinnerDeliveryDays = addNewSpinner(checkout_detail, getMergedList(config.deliveryDaysLabel, config.deliveryDaysOptions));

        final TextView textViewDeliverSlots = addNewTextView(checkout_detail, "");
        textViewDeliverSlots.setVisibility(View.GONE);
        final AppCompatSpinner spinnerDeliverSlots = new AppCompatSpinner(getActivity());
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        checkout_detail.addView(spinnerDeliverSlots, lp);
        spinnerDeliverSlots.setVisibility(View.GONE);
        spinnerDeliveryType.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> adapterView, View view, int position, long id) {
                if (adapterView.getSelectedItem().toString().equalsIgnoreCase(config.selectedClusterDestination)) {
                    textViewClusterDestinations.setVisibility(View.VISIBLE);
                    spinnerClusterDestinations.setVisibility(View.VISIBLE);
                } else {
                    textViewClusterDestinations.setVisibility(View.GONE);
                    spinnerClusterDestinations.setVisibility(View.GONE);
                }
                if (position >= 0) {
                    selectedDeliveryTypeId = String.valueOf(position);
                    selectedDeliveryType = adapterView.getItemAtPosition(position).toString();
                }
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
                selectedDeliveryType = "";
            }
        });

        spinnerHomeDestination.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if (position >= 0) {
                    selectedHomeDestination = parent.getItemAtPosition(position).toString();
                }
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
                selectedHomeDestination = "";
            }
        });

        spinnerClusterDestinations.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if (position >= 0) {
                    selectedClusterDestinations = parent.getItemAtPosition(position).toString();
                }
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
                selectedClusterDestinations = "";
            }
        });

        spinnerDeliveryDays.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                for (int i = 0; i < config.deliverSlots.size(); i++) {
                    MultiStoreCheckoutConfig.DeliverSlot deliverSlot1 = config.deliverSlots.get(i);
                    String t = deliverSlot1.chosen_valt.trim();
                    if (t.equalsIgnoreCase(parent.getSelectedItem().toString().trim())) {
                        textViewDeliverSlots.setVisibility(View.VISIBLE);
                        textViewDeliverSlots.setText(deliverSlot1.label);
                        spinnerDeliverSlots.setVisibility(View.VISIBLE);
                        spinnerDeliverSlots.setAdapter(new Adapter_HtmlString(getActivity(), ArrayUtils.asList(deliverSlot1.options)));
                        break;
                    }
                }
                if (position >= 0) {
                    selectedDeliveryDays = parent.getItemAtPosition(position).toString();
                }
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
                selectedDeliveryDays = "";
            }
        });

        spinnerDeliverSlots.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                if (position >= 0) {
                    selectedDeliverSlots = parent.getItemAtPosition(position).toString();
                }
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {
                selectedDeliverSlots = "";
            }
        });
    }

    public TextView addNewTextView(LinearLayout layout, String label) {
        TextView labelText = new TextView(getActivity());
        labelText.setText(HtmlCompat.fromHtml(label));
        labelText.setPadding(Helper.DP(12), Helper.DP(6), Helper.DP(12), Helper.DP(6));
        layout.addView(labelText, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        return labelText;
    }

    public Spinner addNewSpinner(LinearLayout layout, List<String> options) {
        AppCompatSpinner spinner = new AppCompatSpinner(getActivity());
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        layout.addView(spinner, lp);
        spinner.setAdapter(new Adapter_HtmlString(getActivity(), options));
        return spinner;
    }

    private String getCheckoutMetadataString() {
        if (AppInfo.ENABLE_MULTI_STORE_CHECKOUT) {
            try {
                JSONObject metadata = new JSONObject();
                metadata.put(mMultiStoreCheckoutConfig.deliveryTypeField, selectedDeliveryType);
                metadata.put(mMultiStoreCheckoutConfig.homeDestinationField, selectedHomeDestination);
                metadata.put(mMultiStoreCheckoutConfig.clusterDestinationsField, selectedClusterDestinations);
                metadata.put(mMultiStoreCheckoutConfig.deliveryDaysField, selectedDeliveryDays);
                metadata.put(mMultiStoreCheckoutConfig.deliverSlots.get(0).field, selectedDeliverSlots);
                return metadata.toString();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return "";
    }
}
