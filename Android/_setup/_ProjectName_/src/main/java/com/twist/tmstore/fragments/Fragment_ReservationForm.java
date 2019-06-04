package com.twist.tmstore.fragments;

import android.os.Bundle;
import android.support.design.widget.TextInputLayout;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Spinner;
import android.widget.TextView;

import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.utils.DataHelper;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.config.ReservationFormConfig;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.JsonHelper;
import com.wdullaer.materialdatetimepicker.date.DatePickerDialog;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * Created by Twist Mobile on 4/17/2017.
 */

public class Fragment_ReservationForm extends BaseFragment {
    private View rootView;
    private LinearLayout time_section;
    private TextView txt_reservation_desc;

    private TextInputLayout label_name_booking;
    private TextInputLayout label_email;
    private TextInputLayout label_date;
    private TextInputLayout label_pers;
    private TextInputLayout label_phone_number;
    private TextInputLayout label_optional_message;
    private TextView text_time_hour;

    private EditText text_name;
    private EditText text_email;
    private EditText text_date;
    private EditText text_pers;
    private EditText text_phone_number;
    private EditText text_optional_message;
    private Button btnMakeReservation;

    private Spinner spinnerSelectTime;
    private Spinner spinner_TimePeriod;

    String selectTimeString;
    String selectTimePeriodString;
    List<String> listTimeData;
    List<String> listTimePeriodData;

    public static Fragment_ReservationForm newInstance() {
        return new Fragment_ReservationForm();
    }

    public Fragment_ReservationForm() {
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        rootView = inflater.inflate(R.layout.fragment_reservation_form, container, false);

        setActionBarHomeAsUpIndicator();
        getBaseActivity().restoreActionBar();

        listTimeData = new ArrayList<>();
        getReservationFormData();
        return rootView;
    }

    /*Fetch Reservation Form Data*/
    private void getReservationFormData() {
        if (ReservationFormConfig.mReservationFormConfig != null && ReservationFormConfig.mReservationFormConfig.enabled) {
            if (ReservationFormConfig.mReservationFormConfig.reservationFormMap.size() != 0) {
                initComponents(rootView);
            } else {
                MainActivity.mActivity.showProgress(getString(L.string.please_wait));
                DataEngine.getDataEngine().getReservationFormInBackground(new DataQueryHandler<String>() {
                    @Override
                    public void onSuccess(String data) {
                        try {
                            parseJsonAndCreateReservationForm(data);
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                        MainActivity.mActivity.hideProgress();
                    }

                    @Override
                    public void onFailure(Exception reason) {
                        Helper.showToast(rootView, reason.getMessage());
                        MainActivity.mActivity.hideProgress();
                    }
                });
            }
        }
    }

    public void parseJsonAndCreateReservationForm(String jsonStringContent) throws Exception {
        JSONObject jMainObject = DataHelper.safeJsonObject(jsonStringContent);
        JSONArray reservationFormArray = jMainObject.getJSONArray("input");
        for (int i = 0; i < reservationFormArray.length(); i++) {
            JSONObject reservationInfoJson = reservationFormArray.getJSONObject(i);
            ReservationFormConfig.ReservationForm form = new ReservationFormConfig.ReservationForm();
            form.shortcode = reservationInfoJson.getString("shortcode");
            form.label = reservationInfoJson.getString("label");
            if (reservationInfoJson.has("options")) {
                form.options = JsonHelper.getStringArray(reservationInfoJson, "options");
            }
            form.submit_mess = jMainObject.getString("submit_mess");
            ReservationFormConfig.mReservationFormConfig.reservationFormMap.put(form.shortcode, form);
        }
        initComponents(rootView);
    }

    private void initComponents(View rootView) {

        txt_reservation_desc = (TextView) rootView.findViewById(R.id.txt_reservation_desc);
        txt_reservation_desc.setText(L.getString(L.string.reservation_form_desc));

        label_name_booking = ((TextInputLayout) rootView.findViewById(R.id.label_name_booking));
        Helper.stylize(label_name_booking);

        label_email = ((TextInputLayout) rootView.findViewById(R.id.label_email));
        Helper.stylize(label_email);

        label_date = ((TextInputLayout) rootView.findViewById(R.id.label_date));
        Helper.stylize(label_date);
        label_pers = ((TextInputLayout) rootView.findViewById(R.id.label_pers));
        Helper.stylize(label_pers);

        label_phone_number = ((TextInputLayout) rootView.findViewById(R.id.label_phone_number));
        Helper.stylize(label_phone_number);
        label_optional_message = ((TextInputLayout) rootView.findViewById(R.id.label_optional_message));
        Helper.stylize(label_optional_message);

        text_name = (EditText) rootView.findViewById(R.id.text_name_booking);
        text_email = (EditText) rootView.findViewById(R.id.text_email);
        text_date = (EditText) rootView.findViewById(R.id.text_date);
        text_pers = (EditText) rootView.findViewById(R.id.text_pers);

        time_section = (LinearLayout) rootView.findViewById(R.id.time_section);
        time_section.setVisibility(View.GONE);
        text_time_hour = (TextView) rootView.findViewById(R.id.text_time_hour);
        spinnerSelectTime = (Spinner) rootView.findViewById(R.id.spinner_time_hour);
        spinnerSelectTime.setVisibility(View.GONE);
        Helper.stylize(spinnerSelectTime, true);
        spinner_TimePeriod = (Spinner) rootView.findViewById(R.id.spinner_time_period);
        spinner_TimePeriod.setVisibility(View.GONE);
        Helper.stylize(spinner_TimePeriod, true);

        text_phone_number = (EditText) rootView.findViewById(R.id.text_phone_number);
        text_optional_message = (EditText) rootView.findViewById(R.id.text_optional_message);

        text_date.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                showDateDialog();
            }
        });
        text_date.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                final int DRAWABLE_RIGHT = 2;
                if (event.getAction() == MotionEvent.ACTION_UP) {
                    if (event.getRawX() >= (text_date.getRight() - text_date.getCompoundDrawables()[DRAWABLE_RIGHT].getBounds().width())) {
                        showDateDialog();
                        return true;
                    }
                }
                return false;
            }
        });

        btnMakeReservation = (Button) rootView.findViewById(R.id.btn_make_reservation);
        btnMakeReservation.setText(L.getString(L.string.btn_make_a_reservation));
        Helper.stylize(btnMakeReservation);
        btnMakeReservation.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                final String _name = text_name.getText().toString().trim();
                final String _email = text_email.getText().toString().trim();
                final String _date = text_date.getText().toString();
                final String _date_pers = text_pers.getText().toString();
                final String _phone = text_phone_number.getText().toString().trim();
                final String _message = text_optional_message.getText().toString().trim();
                mCheckAndPostReservationCredentials(_name, _email, _date, _date_pers, selectTimeString, selectTimePeriodString, _phone, _message);
            }
        });

        for (Map.Entry<String, ReservationFormConfig.ReservationForm> entry : ReservationFormConfig.mReservationFormConfig.reservationFormMap.entrySet()) {
            ReservationFormConfig.ReservationForm value = entry.getValue();
            String key = entry.getKey();
            if (key.equals("nomdelareservation")) {
                label_name_booking.setHint(HtmlCompat.fromHtml(value.label));
            } else if (key.equals("adresseemail")) {
                label_email.setHint(HtmlCompat.fromHtml(value.label));
            } else if (key.equals("date")) {
                label_date.setHint(HtmlCompat.fromHtml(value.label));
            } else if (key.equals("pers")) {
                label_pers.setHint(HtmlCompat.fromHtml(value.label));
            } else if (key.equals("heure")) {
                text_time_hour.setHint(value.label);
                listTimeData = Arrays.asList(value.options);
            } else if (key.equals("t332")) {
                listTimePeriodData = Arrays.asList(value.options);
            } else if (key.equals("numerodetel")) {
                label_phone_number.setHint(HtmlCompat.fromHtml(value.label));
            } else if (key.equals("message")) {
                label_optional_message.setHint(HtmlCompat.fromHtml(value.label));
            } else {
                label_name_booking.setHint(L.getString(L.string.label_name_booking_reservation));
                label_email.setHint(L.getString(L.string.email_address));
                label_date.setHint(L.getString(L.string.label_select_reservation_date));
                label_pers.setHint(L.getString(L.string.label_pers));
                label_phone_number.setHint(L.getString(L.string.label_phone_number_reservation));
                text_time_hour.setHint(L.getString(L.string.label_hour_reservation));
                label_optional_message.setHint(L.getString(L.string.label_message_reservation));
            }
            btnMakeReservation.setText(value.submit_mess);
        }
    }

    /*Check And Post ReservationForm Data*/
    private void mCheckAndPostReservationCredentials(final String name, final String email, final String date, final String date_pers, String time, String timePeriod, final String phone, final String message) {
        if (!Helper.isValidString(name)) {
            this.setErrorText(text_name, getString(L.string.invalid_name));
            return;
        }
        if (!android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
            this.setErrorText(text_email, getString(L.string.invalid_email));
            return;
        }

        if (TextUtils.isEmpty(date)) {
            this.setErrorText(text_date, getString(L.string.select_delivery_date));
            return;
        }
        if (!Helper.isValidString(date_pers)) {
            this.setErrorText(text_pers, getString(L.string.invalid_pers));
            return;
        }

        if (TextUtils.isEmpty(time)) {
            Helper.toast(rootView, L.string.select_delivery_time);
            return;
        }

        if (TextUtils.isEmpty(timePeriod)) {
            Helper.toast(rootView, L.string.select_delivery_time);
            return;
        }

        if (!Helper.isValidPhoneNumber(phone)) {
            this.setErrorText(text_phone_number, getString(L.string.invalid_contact_number));
            return;
        }

        if (!Helper.isValidString(message)) {
            this.setErrorText(text_optional_message, getString(L.string.invalid_message));
            return;
        }
        if (message.length() > 1024) {
            this.setErrorText(text_optional_message, getString(L.string.optional_message_too_large));
            return;
        }

        Map<String, String> params = new HashMap<>();
        params.put("type", "submit_reservation_form");
        params.put("form_id", "25");
        params.put("nomdelareservation", name);
        params.put("adresseemail", email);
        params.put("date", date);
        params.put("pers", date_pers);
        params.put("heure", time);
        params.put("t332", timePeriod);
        params.put("numerodetel", phone);
        params.put("message", message);

        MainActivity.mActivity.showProgress(getString(L.string.please_wait));
        DataEngine.getDataEngine().postReservationFormInBackground(params, new DataQueryHandler<String>() {
            @Override
            public void onSuccess(String data) {
                text_name.setText("");
                text_name.requestFocus();
                text_email.setText("");
                text_date.setText("");
                text_pers.setText("");
                time_section.setVisibility(View.GONE);
                text_phone_number.setText("");
                text_optional_message.setText("");
                Helper.showToast(rootView, data);
                MainActivity.mActivity.hideProgress();
            }

            @Override
            public void onFailure(Exception error) {
                text_name.setText(name);
                text_name.requestFocus();
                text_email.setText(email);
                text_date.setText(date);
                text_pers.setText(date_pers);
                time_section.setVisibility(View.VISIBLE);
                text_phone_number.setText(phone);
                text_optional_message.setText(message);
                error.printStackTrace();
                MainActivity.mActivity.hideProgress();
            }
        });
    }

    /*Date Picker And Time Picker*/
    private void showDateDialog() {
        final Calendar now = Calendar.getInstance();
        DatePickerDialog datePickerDialog = DatePickerDialog.newInstance(
                new DatePickerDialog.OnDateSetListener() {
                    @Override
                    public void onDateSet(DatePickerDialog view, int year, int monthOfYear, int dayOfMonth) {
                        //TODO don't use unformatted string in case of date or time. Date format is dd/mm/yyyy
                        String pickedDataString = String.format(Locale.US, "%02d/%02d/%d", (monthOfYear + 1), dayOfMonth, year);
                        text_date.setText(pickedDataString);
                        time_section.setVisibility(View.VISIBLE);
                        spinnerSelectTime.setVisibility(View.VISIBLE);
                        spinner_TimePeriod.setVisibility(View.VISIBLE);

                        spinnerSelectTime.setAdapter(new ArrayAdapter<>(getActivity(), android.R.layout.simple_list_item_1, listTimeData));
                        spinnerSelectTime.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
                            @Override
                            public void onItemSelected(AdapterView<?> adapterView, View view, int selectedId, long l) {
                                if (selectedId >= 0) {
                                    selectTimeString = adapterView.getItemAtPosition(selectedId).toString();
                                }
                            }

                            @Override
                            public void onNothingSelected(AdapterView<?> adapterView) {
                                selectTimeString = "";
                            }
                        });

                        spinner_TimePeriod.setAdapter(new ArrayAdapter<>(getActivity(), android.R.layout.simple_spinner_dropdown_item, listTimePeriodData));
                        spinner_TimePeriod.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
                            @Override
                            public void onItemSelected(AdapterView<?> adapterView, View view, int selectedId, long l) {
                                if (selectedId >= 0) {
                                    selectTimePeriodString = adapterView.getItemAtPosition(selectedId).toString();
                                }
                            }

                            @Override
                            public void onNothingSelected(AdapterView<?> adapterView) {
                                selectTimePeriodString = "";
                            }
                        });
                    }
                },
                now.get(Calendar.YEAR),
                now.get(Calendar.MONTH),
                now.get(Calendar.DAY_OF_MONTH)
        );
        datePickerDialog.setTitle(getString(L.string.select_reservation_date));
        datePickerDialog.setOkText(getString(L.string.ok));
        datePickerDialog.setCancelText(getString(L.string.cancel));
        datePickerDialog.show(getActivity().getFragmentManager(), DatePickerDialog.class.getSimpleName());
        datePickerDialog.setMinDate(now);
    }

    private void setErrorText(EditText editText, String error) {
        editText.setError(error);
        this.requestFocus(editText);
    }
}