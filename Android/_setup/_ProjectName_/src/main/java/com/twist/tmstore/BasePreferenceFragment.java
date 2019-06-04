package com.twist.tmstore;

import android.preference.CheckBoxPreference;
import android.preference.ListPreference;
import android.preference.Preference;
import android.preference.PreferenceFragment;
import android.preference.SwitchPreference;

/**
 * Created by Twist Mobile on 19-03-2016.
 */
public abstract class BasePreferenceFragment extends PreferenceFragment {

    protected Preference findPreference(int resId) {
        return findPreference(getString(resId));
    }

    protected ListPreference findListPreference(int resourceId) {
        return (ListPreference) findPreference(getString(resourceId));
    }

    protected CheckBoxPreference findCheckBoxPreference(int resId) {
        return (CheckBoxPreference) findPreference(getString(resId));
    }

    protected SwitchPreference findSwitchPreference(int resId) {
        return (SwitchPreference) findPreference(getString(resId));
    }

    protected void addOnPreferenceChangeListener(Preference.OnPreferenceChangeListener listener, int resIds[]) {
        for (int resId : resIds) {
            Preference preference = findPreference(getString(resId));
            preference.setOnPreferenceChangeListener(listener);
        }
    }

    protected void setListPreferenceSummary(int resIds[]) {
        for (int resId : resIds) {
            ListPreference preference = findListPreference(resId);
            String value = preference.getValue();
            if (value != null) {
                preference.setSummary(findEntry(preference, value));
            }
        }
    }

    protected void setListPreferenceSummary(int resId) {
        ListPreference preference = findListPreference(resId);
        String value = preference.getValue();
        if (value != null) {
            preference.setSummary(findEntry(preference, value));
        }
    }

    protected void setPreferenceSummary(ListPreference preference) {
        String value = preference.getValue();
        if (value != null) {
            preference.setSummary(findEntry(preference, value));
        }
    }

    public static String findEntry(Preference preference, Object value) {
        String entry = "";
        try {
            ListPreference listPreference = (ListPreference) preference;
            if (listPreference != null) {
                int index = listPreference.findIndexOfValue(value.toString());
                if (index != -1) {
                    entry = listPreference.getEntries()[index].toString();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return entry;
    }
}
