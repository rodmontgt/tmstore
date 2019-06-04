package com.twist.tmstore;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.preference.ListPreference;
import android.preference.Preference;
import android.preference.PreferenceCategory;
import android.preference.PreferenceManager;
import android.preference.PreferenceScreen;
import android.preference.SwitchPreference;
import android.support.v7.app.ActionBar;
import android.view.MenuItem;

import com.twist.dataengine.entities.TM_CommonInfo;
import com.twist.tmstore.config.NotificationConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.notifications.MyFcmRegistrationService;
import com.utils.ArrayUtils;
import com.utils.CContext;
import com.utils.CurrencyHelper;
import com.utils.Helper;
import com.utils.ListUtils;

import java.util.List;

public class SettingsActivity extends BaseActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settings);
        this.setTitleText(getString(L.string.title_settings));
        ActionBar actionBar = this.getSupportActionBar();
        if (actionBar != null) {
            actionBar.setHomeButtonEnabled(true);
            actionBar.setDisplayHomeAsUpEnabled(true);
            Drawable upArrow = CContext.getDrawable(this, R.drawable.abc_ic_ab_back_material);
            upArrow.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_ATOP);
            actionBar.setHomeAsUpIndicator(upArrow);
            restoreActionBar();
        }
    }

    @Override
    protected void onActionBarRestored() {
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (item.getItemId() == android.R.id.home) {
            this.onBackPressed();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    public static class FragmentSettings extends BasePreferenceFragment implements Preference.OnPreferenceChangeListener {

        @Override
        public void onCreate(Bundle savedInstanceState) {
            super.onCreate(savedInstanceState);
            PreferenceScreen screen = getPreferenceManager().createPreferenceScreen(getActivity());
            SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(getActivity());
            L.Language language = L.getInstance().getLanguage();
            if (language != null && !ArrayUtils.isEmpty(language.getLocales())) {
                ListPreference languagePreference = new ListPreference(getActivity());
                languagePreference.setKey(getString(R.string.key_app_lang));
                languagePreference.setTitle(L.getString(L.string.title_language));
                languagePreference.setEntryValues(L.getInstance().getLanguage().getLocales());
                languagePreference.setEntries(L.getInstance().getLanguage().getTitles());

                String languagePreferenceValue = sharedPreferences.getString(getString(R.string.key_app_lang), L.getInstance().getLanguage().defaultLocale);
                languagePreference.setValue(languagePreferenceValue);
                languagePreference.setDefaultValue(L.getInstance().getLanguage().defaultLocale);
                setPreferenceSummary(languagePreference);
                screen.addPreference(languagePreference);
                languagePreference.setOnPreferenceChangeListener(this);
            }

            if (AppInfo.ENABLE_CURRENCY_SWITCHER) {
                Preference currencyPreference = new Preference(getActivity());
                currencyPreference.setKey(getString(R.string.key_app_currency));
                currencyPreference.setTitle(L.getString(L.string.title_currency));
                String currencyPreferenceValue = sharedPreferences.getString(getString(R.string.key_app_currency), TM_CommonInfo.currency);
                currencyPreference.setDefaultValue(currencyPreferenceValue);
                currencyPreference.setSummary(currencyPreferenceValue);
                screen.addPreference(currencyPreference);
                currencyPreference.setOnPreferenceClickListener(new Preference.OnPreferenceClickListener() {
                    @Override
                    public boolean onPreferenceClick(Preference preference) {
                        if (!ListUtils.isEmpty(CurrencyHelper.getAllCurrency())) {
                            Intent intent = new Intent(getActivity(), ChangeCurrencyActivity.class);
                            startActivity(intent);
                        }
                        return false;
                    }
                });
            }

            if (NotificationConfig.isEnabled() && NotificationConfig.hasSettings() && AppUser.hasSignedIn()) {
                final SwitchPreference notificationPreference = new SwitchPreference(getActivity());
                notificationPreference.setKey(getString(R.string.key_app_notification));
                notificationPreference.setTitle(L.getString(L.string.title_notification));
                notificationPreference.setDefaultValue(true);
                notificationPreference.setOnPreferenceChangeListener(new Preference.OnPreferenceChangeListener() {
                    @Override
                    public boolean onPreferenceChange(Preference preference, Object o) {
                        final boolean enabled = (boolean) o;
                        if (NotificationConfig.getType() == NotificationConfig.Type.FCM) {
                            List<NotificationConfig.Channel> channels = NotificationConfig.getChannels();
                            if (channels != null) {
                                for (NotificationConfig.Channel channel : channels) {
                                    if (channel.setting) {
                                        SwitchPreference channelPreference = (SwitchPreference) findPreference(channel.id);
                                        mPreferenceChangeListener.onPreferenceChange(preference, o);
                                        channelPreference.setEnabled(enabled);
                                    }
                                }
                            }
                        }

                        Intent intent = new Intent(getActivity(), MyFcmRegistrationService.class);
                        intent.setAction(enabled ? Constants.ACTION_REGISTER_NOTIFICATION : Constants.ACTION_UNREGISTER_NOTIFICATION);
                        getActivity().startService(intent);
                        return true;
                    }
                });

                PreferenceCategory category = new PreferenceCategory(getActivity());
                category.setTitle(Helper.getThemedString(L.getString(L.string.title_notification), AppInfo.color_theme));
                screen.addPreference(category);
                category.addPreference(notificationPreference);

                List<NotificationConfig.Channel> channels = NotificationConfig.getChannels();
                if (channels != null) {
                    for (NotificationConfig.Channel channel : channels) {
                        if (channel.setting) {
                            boolean enabled = notificationPreference.isChecked();
                            final SwitchPreference channelPreference = new SwitchPreference(getActivity());
                            channelPreference.setKey(channel.id);
                            channelPreference.setTitle(channel.name);
                            channelPreference.setDefaultValue(true);
                            channelPreference.setEnabled(enabled);
                            category.addPreference(channelPreference);
                            channelPreference.setOnPreferenceChangeListener(mPreferenceChangeListener);
                        }
                    }
                }
            }
            this.setPreferenceScreen(screen);
        }

        Preference.OnPreferenceChangeListener mPreferenceChangeListener = new Preference.OnPreferenceChangeListener() {
            @Override
            public boolean onPreferenceChange(Preference preference, Object value) {
                boolean isEnabled = (boolean) value;
                Intent intent = new Intent(getActivity(), MyFcmRegistrationService.class);
                intent.setAction(Constants.ACTION_MANAGE_CHANNEL_SUBSCRIPTION);
                if (isEnabled) {
                    intent.putExtra(Extras.SUBSCRIBE_CHANNEL, preference.getKey());
                } else {
                    intent.putExtra(Extras.UNSUBSCRIBE_CHANNEL, preference.getKey());
                }
                getActivity().startService(intent);
                return true;
            }
        };

        @Override
        public boolean onPreferenceChange(Preference preference, Object value) {
            if (preference instanceof ListPreference) {
                preference.setSummary(findEntry(preference, value));
                String key = preference.getKey();
                if (key.equals(getString(R.string.key_app_lang))) {
                    TMStoreApp application = (TMStoreApp) getActivity().getApplication();
                    String locale = value.toString();
                    if (application.setLocale(locale)) {
                        if (L.getInstance().isWPMLEnabled(locale)) {
                            restartActivity(LauncherActivity.class);
                        } else {
                            restartActivity(MainActivity.class);
                        }
                    }
                }
            }
            return true;
        }

        private void restartActivity(Class<?> cls) {
            Activity activity = getActivity();
            Intent i = new Intent(activity, cls);
            i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            activity.startActivity(i);
            activity.finish();
        }


    }
}
