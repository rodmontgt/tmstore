package com.twist.tmstore;

import android.Manifest;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.design.widget.Snackbar;
import android.support.v4.content.FileProvider;
import android.support.v7.app.ActionBar;
import android.support.v7.widget.CardView;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.SwitchCompat;
import android.text.Spanned;
import android.text.TextUtils;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.ScrollView;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import com.twist.dataengine.DataEngine;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.entities.RawAttribute;
import com.twist.dataengine.entities.RawCategory;
import com.twist.dataengine.entities.RawProductInfo;
import com.twist.dataengine.entities.RawShipping;
import com.twist.dataengine.entities.TM_Attribute;
import com.twist.dataengine.entities.TM_CommonInfo;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.adapters.Adapter_PickedImages;
import com.twist.tmstore.adapters.Adapter_SelectAttribute;
import com.twist.tmstore.config.MultiVendorConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.fragments.ImageChooserBottomSheetDialog;
import com.twist.tmstore.fragments.sellers.Fragment_SelectCategory;
import com.utils.Base64Utils;
import com.utils.CContext;
import com.utils.DataHelper;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.ImageUploadTask;
import com.utils.Log;

import org.json.JSONArray;

import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import eu.fiskur.chipcloud.ChipCloud;
import pl.tajchert.nammu.Nammu;
import pl.tajchert.nammu.PermissionCallback;

import static com.utils.ImageUpload.PICK_PHOTO_CODE;
import static com.utils.ImageUpload.REQUEST_IMAGE_CAPTURE;

public class ProductUploadActivity extends BaseActivity {

    private ScrollView coordinatorLayout;
    private Button btn_submit;
    private EditText edit_title;
    private EditText edit_short_desc;
    private EditText edit_full_desc;
    private EditText edit_regular_price;
    private EditText edit_sale_price;
    private EditText edit_stock_quantity;
    private EditText edit_weight;
    private EditText edit_msrp_price;
    private EditText edit_cost_of_good;

    private RecyclerView list_attributes;
    private RecyclerView list_shipping;
    private ProgressBar progress_attributes;
    private ProgressBar progress_categories;
    private ProgressBar progress_shippingType;

    private View sectionCategories;
    private View sectionAttributes;

    private RecyclerView list_images;
    private LinearLayout layout_other_option;
    private LinearLayout layout_msrp_price;
    private LinearLayout layout_cost_of_good;

    private CheckBox chk_reviews_allowed;
    private CheckBox chk_featured;
    private CheckBox chk_sold_individually;
    private CheckBox chk_backorders;
    private CheckBox chk_managing_stock;
    private CheckBox chk_virtual;
    private CheckBox chk_downloadable;
    private SwitchCompat btn_Switch_OtherOption;

    private Spinner select_tax_status;
    private Spinner select_type;
    private List<RawCategory> selected_categories = new ArrayList<>();

    //Data Part
    private RawProductInfo current_product = null;
    private Adapter_PickedImages<String> adapter_pickedImages;
    private Adapter_SelectAttribute<TM_Attribute> adapter_pickedAttributes;
    private Adapter_SelectAttribute<RawShipping> adapter_pickedShippingType;
    private List<EditText> editTextList = new ArrayList<>();

    private TextView txt_currency_regular_price;
    private TextView txt_currency_sale_price;
    private TextView txt_currency_msrp_price;
    private TextView txt_currency_cost_of_good;
    private ProgressDialog loading;

    private boolean needToUploadProduct = true;
    private boolean needToAssignSeller = true;
    private int providedProductId = -1;
    private boolean needToDeleteProduct = false;

    private TextView tv_select_category;
    private ChipCloud chipCloud;

    private ProgressDialog mProgressDialog;
    private CardView card_shipping_section;
    private String mCurrentPhotoPath;
    private boolean mIsLoadingAttributes = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_product_upload);
        Bundle bundle = getIntent().getExtras();
        if (bundle != null) {
            try {
                int productId = bundle.getInt(Extras.PRODUCT_ID, -1);
                if (productId != -1) {
                    providedProductId = productId;
                    TM_ProductInfo reference_product = TM_ProductInfo.findProductById(productId);
                    if (reference_product != null) {
                        current_product = reference_product.getReferenceProduct();
                    }
                    needToAssignSeller = false;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        mProgressDialog = new ProgressDialog(this);
        initUiComponents();
        updateUiComponents();
    }

    private void initUiComponents() {
        coordinatorLayout = (ScrollView) findViewById(R.id.coordinatorLayout);

        ((TextView) findViewById(R.id.label_basic_info)).setText(L.getString(L.string.label_basic_info));
        ((TextView) findViewById(R.id.label_product_image)).setText(L.getString(L.string.label_product_images));
        ((TextView) findViewById(R.id.label_category)).setText(L.getString(L.string.label_category));
        ((TextView) findViewById(R.id.label_fulldesc)).setText(L.getString(L.string.label_full_description));
        ((TextView) findViewById(R.id.label_pricing)).setText(L.getString(L.string.label_pricing));
        ((TextView) findViewById(R.id.label_attribute)).setText(L.getString(L.string.label_attributes));
        ((TextView) findViewById(R.id.label_shipping_types)).setText(L.getString(L.string.label_shipping_types));
        ((TextView) findViewById(R.id.label_stock_option)).setText(L.getString(L.string.label_stock_option));

        View manageStockSection = findViewById(R.id.section_manage_stock);
        if (MultiVendorConfig.shouldManageStock()) {
            manageStockSection.setVisibility(View.VISIBLE);
        } else {
            manageStockSection.setVisibility(View.GONE);
        }

        View otherOptionsSection = findViewById(R.id.section_other_options);
        if (MultiVendorConfig.shouldShowOtherOptions()) {
            otherOptionsSection.setVisibility(View.VISIBLE);
        } else {
            otherOptionsSection.setVisibility(View.GONE);
        }

        btn_submit = (Button) findViewById(R.id.btn_submit);
        btn_submit.setText(L.getString(L.string.submit));

        edit_title = (EditText) findViewById(R.id.edit_title);
        edit_title.setHint(L.getString(L.string.hint_product_title));
        edit_short_desc = (EditText) findViewById(R.id.edit_short_desc);
        edit_short_desc.setHint(L.getString(L.string.hint_short_description));

        edit_full_desc = (EditText) findViewById(R.id.edit_full_desc);
        edit_regular_price = (EditText) findViewById(R.id.edit_regular_price);
        edit_regular_price.setHint(L.getString(L.string.hint_regular_price));

        edit_sale_price = (EditText) findViewById(R.id.edit_sale_price);
        edit_sale_price.setHint(L.getString(L.string.hint_sale_price));

        layout_msrp_price = (LinearLayout) findViewById(R.id.layout_msrp_price);
        layout_msrp_price.setVisibility(MultiVendorConfig.shouldShowMsrpPrice() ? View.VISIBLE : View.GONE);

        edit_msrp_price = (EditText) findViewById(R.id.edit_msrp_price);
        edit_msrp_price.setHint(L.getString(L.string.hint_msrp_price));

        layout_cost_of_good = (LinearLayout) findViewById(R.id.layout_cost_of_good);
        layout_cost_of_good.setVisibility(MultiVendorConfig.shouldShowCostOfGood() ? View.VISIBLE : View.GONE);

        edit_cost_of_good = (EditText) findViewById(R.id.edit_cost_of_good);
        edit_cost_of_good.setHint(L.getString(L.string.hint_cost_of_good));

        edit_stock_quantity = (EditText) findViewById(R.id.stock_quantity);
        edit_stock_quantity.setHint(L.getString(L.string.hint_stock_quantity));

        edit_weight = (EditText) findViewById(R.id.edit_weight);
        edit_weight.setHint(L.getString(L.string.weight));

        txt_currency_regular_price = (TextView) findViewById(R.id.txt_currency_regular_price);
        txt_currency_sale_price = (TextView) findViewById(R.id.txt_currency_sale_price);
        txt_currency_msrp_price = (TextView) findViewById(R.id.txt_currency_msrp_price);
        txt_currency_cost_of_good = (TextView) findViewById(R.id.txt_currency_cost_of_good);

        tv_select_category = (TextView) findViewById(R.id.tv_select_category);
        tv_select_category.setText(getString(L.string.txt_select_category));
        tv_select_category.setVisibility(View.GONE);

        chipCloud = (ChipCloud) findViewById(R.id.chip_cloud);
        Helper.stylize(chipCloud);

        list_images = (RecyclerView) findViewById(R.id.list_images);
        list_attributes = (RecyclerView) findViewById(R.id.list_attributes);
        list_shipping = (RecyclerView) findViewById(R.id.list_shipping);

        progress_attributes = (ProgressBar) findViewById(R.id.progress_attributes);
        progress_attributes.setVisibility(View.GONE);

        progress_shippingType = (ProgressBar) findViewById(R.id.progress_shipping);
        progress_categories = (ProgressBar) findViewById(R.id.progress_categories);
        card_shipping_section = (CardView) findViewById(R.id.card_shipping_section);

        sectionCategories = findViewById(R.id.section_categories);
        sectionCategories.setVisibility(View.VISIBLE);

        sectionAttributes = findViewById(R.id.section_attributes);
        sectionAttributes.setVisibility(View.GONE);

        editTextList.add(edit_title);
        editTextList.add(edit_short_desc);
        editTextList.add(edit_full_desc);
        editTextList.add(edit_regular_price);
        editTextList.add(edit_stock_quantity);

        if (MultiVendorConfig.shouldShowMsrpPrice()) {
            editTextList.add(edit_msrp_price);
        }

        if (MultiVendorConfig.shouldShowCostOfGood()) {
            editTextList.add(edit_cost_of_good);
        }

        layout_other_option = (LinearLayout) findViewById(R.id.layout_other_option);

        btn_Switch_OtherOption = (SwitchCompat) findViewById(R.id.swt_other_option);
        Helper.stylizeSwitchCompact(btn_Switch_OtherOption);
        btn_Switch_OtherOption.setText(L.getString(L.string.label_other_options));
        btn_Switch_OtherOption.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (btn_Switch_OtherOption.isChecked()) {
                    layout_other_option.setVisibility(View.VISIBLE);
                } else {
                    layout_other_option.setVisibility(View.GONE);
                }
            }
        });

        chk_managing_stock = (CheckBox) findViewById(R.id.chk_managing_stock);
        chk_managing_stock.setText(L.getString(L.string.managing_stock));

        chk_downloadable = (CheckBox) findViewById(R.id.chk_downloadable);
        chk_downloadable.setText(L.getString(L.string.downloadable));

        chk_virtual = (CheckBox) findViewById(R.id.chk_virtual);
        chk_virtual.setText(L.getString(L.string.virtual));

        chk_backorders = (CheckBox) findViewById(R.id.chk_backorders);
        chk_backorders.setText(L.getString(L.string.back_order));

        chk_sold_individually = (CheckBox) findViewById(R.id.chk_sold_individually);
        chk_sold_individually.setText(L.getString(L.string.sold_individually));

        chk_featured = (CheckBox) findViewById(R.id.chk_featured);
        chk_featured.setText(L.getString(L.string.featured));

        chk_reviews_allowed = (CheckBox) findViewById(R.id.chk_reviews_allowed);
        chk_reviews_allowed.setText(L.getString(L.string.reviews));

        select_tax_status = (Spinner) findViewById(R.id.select_tax_status);
        select_type = (Spinner) findViewById(R.id.select_type);

        edit_stock_quantity.setVisibility(View.GONE);
        edit_weight.setVisibility(View.GONE);

        select_type.setVisibility(View.GONE);
        select_tax_status.setVisibility(View.GONE);

        tv_select_category.setPaintFlags(tv_select_category.getPaintFlags() | Paint.UNDERLINE_TEXT_FLAG);
        tv_select_category.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                // Don't allow selecting categories while attributes are loading.
                if (mIsLoadingAttributes) {
                    return;
                }
                Fragment_SelectCategory.newInstance(new Fragment_SelectCategory.OnCompleteListener() {
                    @Override
                    public void onCompletion(List<RawCategory> categories) {
                        selected_categories.clear();
                        selected_categories.addAll(categories);
                        printCategoryChips();
                        loadAttributes();
                    }
                }, selected_categories).show(getSupportFragmentManager(), Fragment_SelectCategory.class.getSimpleName());
            }
        });

        Helper.stylize(btn_submit);
        Helper.stylize(progress_attributes);
        Helper.stylize(progress_shippingType);
        Helper.stylize(progress_categories);

        /*
        Helper.stylize(edit_title);
        Helper.stylize(edit_short_desc);
        Helper.stylize(edit_full_desc);
        Helper.stylize(edit_price);
        Helper.stylize(edit_regular_price);
        Helper.stylize(edit_sale_price);
        Helper.stylize(stock_quantity);
        Helper.stylize(edit_weight);
        */

        Helper.stylize(chk_reviews_allowed);
        Helper.stylize(chk_featured);
        Helper.stylize(chk_sold_individually);
        Helper.stylize(chk_backorders);
        Helper.stylize(chk_managing_stock);
        Helper.stylize(chk_virtual);
        Helper.stylize(chk_downloadable);
    }

    private void updateUiComponents() {
        adapter_pickedImages = new Adapter_PickedImages<>(new Adapter_PickedImages.ImageListener() {
            @Override
            public void onImageSelected(Object object) {
                selectImage();
            }

            @Override
            public void onImageDeleted(Object object) {
            }
        });
        list_images.setAdapter(adapter_pickedImages);

        adapter_pickedAttributes = new Adapter_SelectAttribute<>(TM_Attribute.class.getSimpleName(), new ArrayList<TM_Attribute>(), getSupportFragmentManager());
        list_attributes.setAdapter(adapter_pickedAttributes);
        adapter_pickedShippingType = new Adapter_SelectAttribute<>(RawShipping.class.getSimpleName(), new ArrayList<RawShipping>(), getSupportFragmentManager());
        list_shipping.setAdapter(adapter_pickedShippingType);

        if (current_product != null) {
            edit_title.setText(current_product.title);
            edit_short_desc.setText(HtmlCompat.fromHtml(current_product.short_description));
            edit_full_desc.setText(HtmlCompat.fromHtml(current_product.description));
            edit_regular_price.setText(Float.toString(current_product.regular_price));
            edit_sale_price.setText(Float.toString(current_product.sale_price));
            edit_weight.setText(Float.toString(current_product.weight));
            chk_managing_stock.setChecked(current_product.in_stock);
            chk_downloadable.setChecked(current_product.downloadable);
            adapter_pickedImages.addItems(current_product.getImages());

            chk_reviews_allowed.setChecked(current_product.reviews_allowed);
            if (current_product.in_stock) {
                edit_stock_quantity.setVisibility(View.VISIBLE);
                edit_stock_quantity.setText(String.valueOf(current_product.stock_quantity));
            } else {
                edit_stock_quantity.setVisibility(View.GONE);
            }

            if (MultiVendorConfig.shouldShowMsrpPrice()) {
                edit_msrp_price.setText(Float.toString(current_product.msrp_price));
            }

            if (MultiVendorConfig.shouldShowCostOfGood()) {
                edit_msrp_price.setText(Float.toString(current_product.cost_of_good));
            }
        }
        btn_submit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (isDataValid() && isPricesValid()) {
                    assignProductInfo();
                    uploadProduct();
                }
            }
        });


        chk_managing_stock.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean isChecked) {
                edit_stock_quantity.setVisibility(isChecked ? View.VISIBLE : View.GONE);
            }
        });

        Spanned currencySymbol = HtmlCompat.fromHtml(TM_CommonInfo.currency_format);
        txt_currency_regular_price.setText(currencySymbol);
        txt_currency_sale_price.setText(currencySymbol);
        txt_currency_msrp_price.setText(currencySymbol);
        txt_currency_cost_of_good.setText(currencySymbol);

        loadCategories();
        loadShippingType();

        if (current_product != null) {
            /*int matchingCategoryIndex = -1;
            for (int i = 0; i < category_adapter.getCount(); i++) {
                if (((TM_CategoryInfo) category_adapter.getItem(i)).id == current_product.getFirstCategoryId()) {
                    matchingCategoryIndex = i;
                    break;
                }
            }
            if (matchingCategoryIndex != -1) {
                select_category.setSelection(matchingCategoryIndex);
            }*/

            //TODO set existing product category here
        }

        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setHomeButtonEnabled(true);
            actionBar.setDisplayHomeAsUpEnabled(true);

            Drawable upArrow = CContext.getDrawable(this, R.drawable.abc_ic_ab_back_material);
            upArrow.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_ATOP);
            getSupportActionBar().setHomeAsUpIndicator(upArrow);
        }

        if (current_product != null) {
            setTitleText(getString(L.string.title_edit_product));
        } else {
            setTitleText(getString(L.string.title_new_product));
        }
    }

    private void loadCategories() {
        tv_select_category.setVisibility(View.GONE);
        progress_categories.setVisibility(View.VISIBLE);
        DataEngine.getDataEngine().loadRawCategories(new DataQueryHandler<List<RawCategory>>() {
            @Override
            public void onSuccess(List<RawCategory> data) {
                if (current_product != null) {
                    selected_categories.clear();
                    selected_categories.addAll(current_product.categories);
                    printCategoryChips();
                    loadAttributes();
                }
                tv_select_category.setVisibility(View.VISIBLE);
                progress_categories.setVisibility(View.GONE);
            }

            @Override
            public void onFailure(Exception error) {
                tv_select_category.setVisibility(View.VISIBLE);
                progress_categories.setVisibility(View.GONE);
                error.printStackTrace();
            }
        });
    }

    private void printCategoryChips() {
        chipCloud.removeAllViewsInLayout();
        for (RawCategory category : selected_categories) {
            chipCloud.addChip(category.getName());
        }
    }

    private void loadAttributes() {
        List<Integer> categoryIds = new ArrayList<>();
        if (!selected_categories.isEmpty()) {
            for (RawCategory rawCategory : selected_categories) {
                categoryIds.add(rawCategory.getId());
            }
        }
        if (categoryIds.isEmpty()) {
            sectionAttributes.setVisibility(View.GONE);
            current_product.attributes = null;
            mIsLoadingAttributes = false;
            return;
        }
        sectionAttributes.setVisibility(View.VISIBLE);
        progress_attributes.setVisibility(View.VISIBLE);
        adapter_pickedAttributes.removeFooter();
        mIsLoadingAttributes = true;

        DataEngine.getDataEngine().loadRawAttributes(categoryIds, new DataQueryHandler<List<RawAttribute>>() {
            @Override
            public void onSuccess(List<RawAttribute> data) {
                adapter_pickedAttributes.addFooter(null);
                if (current_product != null) {
                    adapter_pickedAttributes.addItems(current_product.attributes);
                }
                progress_attributes.setVisibility(View.GONE);
                mIsLoadingAttributes = false;
            }

            @Override
            public void onFailure(Exception error) {
                progress_attributes.setVisibility(View.GONE);
                sectionAttributes.setVisibility(View.GONE);
                error.printStackTrace();
                mIsLoadingAttributes = false;
            }
        });
    }

    private void loadShippingType() {
        if (MultiVendorConfig.isEnabled() && MultiVendorConfig.isShippingRequired()) {
            card_shipping_section.setVisibility(View.VISIBLE);

            progress_shippingType.setVisibility(View.VISIBLE);
            DataEngine.getDataEngine().getProductShippingInfo(new DataQueryHandler<List<RawShipping>>() {
                @Override
                public void onSuccess(List<RawShipping> data) {
                    adapter_pickedShippingType.addFooter(null);
                    if (current_product != null) {
                        //ToDo. write logic to read previous product's picked shipping here..
                        //adapter_pickedShippingType.addItems(data);
                    }
                    progress_shippingType.setVisibility(View.GONE);
                }

                @Override
                public void onFailure(Exception error) {
                    progress_shippingType.setVisibility(View.GONE);
                    error.printStackTrace();
                }
            });
        } else {
            card_shipping_section.setVisibility(View.GONE);
        }
    }

    @Override
    public void onBackPressed() {
        setResult(RESULT_OK);
        finish();
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_empty, menu);
        return true;
    }

    @Override
    public boolean onPrepareOptionsMenu(Menu menu) {
        if (providedProductId != -1) {
            menu.clear();
            MenuItem item_delete = menu.add(0, Constants.ID_WISH_MENU_DELETE, 0, getString(L.string.delete));
            item_delete.setIcon(R.drawable.ic_vc_delete);
            item_delete.setShowAsAction(MenuItem.SHOW_AS_ACTION_IF_ROOM);
            Helper.stylizeActionMenuItem(item_delete);
        }
        return super.onPrepareOptionsMenu(menu);
    }

    private boolean isDataValid() {
        for (EditText editText : editTextList) {
            if (editText.getVisibility() == View.VISIBLE && TextUtils.isEmpty(editText.getText().toString())) {
                CharSequence hintText = editText.getHint();
                if (!TextUtils.isEmpty(hintText)) {
                    editText.setError(getString(L.string.invalid) + " : " + editText.getHint());
                } else {
                    editText.setError(getString(L.string.invalid));
                }
                return false;
            }
        }

        if (selected_categories.isEmpty()) {
            Helper.toast(coordinatorLayout, L.string.please_select_a_category);
            return false;
        }
        return true;
    }

    private boolean isPricesValid() {
        if (TextUtils.isEmpty(edit_sale_price.getText()))
            return true;
        String regularPriceText = edit_regular_price.getText().toString().trim();
        String salePriceText = edit_sale_price.getText().toString().trim();
        if (!salePriceText.isEmpty()) {
            try {
                float regularPrice = Float.parseFloat(regularPriceText);
                float salePrice = Float.parseFloat(salePriceText);
                if (salePrice >= regularPrice) {
                    edit_sale_price.setError(getString(L.string.error_high_sale_price));
                    edit_sale_price.requestFocus();
                    return false;
                }
            } catch (Exception e) {
                edit_regular_price.setError(getString(L.string.invalid) + " : " + edit_regular_price.getHint());
                return false;
            }
        }

        if (MultiVendorConfig.shouldShowMsrpPrice()) {
            String str = edit_msrp_price.getText().toString().trim();
            if (!TextUtils.isEmpty(str)) {
                boolean error = false;
                try {
                    float msrp_price = Float.parseFloat(str);
                    if (msrp_price <= 0) {
                        error = true;
                    }
                } catch (Exception e) {
                    error = true;
                }
                if (error) {
                    edit_msrp_price.setError(getString(L.string.error_msrp_price));
                    edit_msrp_price.requestFocus();
                    return false;
                }
            }
        }

        if (MultiVendorConfig.shouldShowCostOfGood()) {
            String str = edit_cost_of_good.getText().toString().trim();
            if (!TextUtils.isEmpty(str)) {
                boolean error = false;
                try {
                    float cost_of_good = Float.parseFloat(str);
                    if (cost_of_good <= 0) {
                        error = true;
                    }
                } catch (Exception e) {
                    error = true;
                }
                if (error) {
                    edit_cost_of_good.setError(getString(L.string.error_cost_of_good));
                    edit_cost_of_good.requestFocus();
                    return false;
                }
            }
        }
        return true;
    }


    private void assignProductInfo() {
        if (current_product == null) {
            current_product = new RawProductInfo();
        }
        current_product.title = edit_title.getText().toString().trim();
        current_product.short_description = edit_short_desc.getText().toString().trim();
        current_product.description = edit_full_desc.getText().toString().trim();
        current_product.reviews_allowed = chk_reviews_allowed.isChecked();
        current_product.featured = chk_featured.isChecked();
        current_product.sold_individually = chk_sold_individually.isChecked();

        //current_product.price = Float.parseFloat(edit_price.getText().toString().trim());
        current_product.regular_price = Float.parseFloat(edit_regular_price.getText().toString().trim());
        if (!TextUtils.isEmpty(edit_sale_price.getText())) {
            current_product.sale_price = Float.parseFloat(edit_sale_price.getText().toString().trim());
        }

        if (MultiVendorConfig.shouldShowMsrpPrice() && !TextUtils.isEmpty(edit_msrp_price.getText())) {
            current_product.msrp_price = Float.parseFloat(edit_msrp_price.getText().toString().trim());
        }

        if (MultiVendorConfig.shouldShowCostOfGood() && !TextUtils.isEmpty(edit_cost_of_good.getText())) {
            current_product.cost_of_good = Float.parseFloat(edit_cost_of_good.getText().toString().trim());
        }

        current_product.in_stock = true;
        if (chk_managing_stock.isChecked()) {
            current_product.managing_stock = true;
            current_product.stock_quantity = Integer.parseInt(edit_stock_quantity.getText().toString().trim());
            if (current_product.stock_quantity <= 0) {
                current_product.in_stock = false;
            }
        } else {
            current_product.managing_stock = false;
        }

//        if (stock_quantity.getVisibility() == View.VISIBLE) {
//            current_product.stock_quantity = Integer.parseInt(stock_quantity.getText().toString().trim());
//        }

        //current_product.weight = Integer.parseInt(edit_weight.getText().toString().trim());
        //current_product.backOrder = chk_backorders.isChecked();
        //current_product.mana = chk_managing_stock.isChecked();
        current_product.virtual = chk_virtual.isChecked();
        current_product.downloadable = chk_downloadable.isChecked();
        current_product.categories.clear();
        current_product.categories.addAll(selected_categories);
        //TODO Only SIMPLE product for the time being
        current_product.type = TM_ProductInfo.ProductType.values()[0];

        current_product.status = RawProductInfo.Status.from(MultiVendorConfig.getPublishStatus());

        current_product.removeAllImages();
        current_product.addImages(adapter_pickedImages.getItems());
        current_product.attributes.clear();
        current_product.attributes.addAll(adapter_pickedAttributes.getItems());
    }

    private void uploadProduct() {
        if (needToUploadProduct) {
            showProgress(getString(L.string.uploading_product_data));
            DataEngine.getDataEngine().createProductInBackground(current_product, new DataQueryHandler<TM_ProductInfo>() {
                @Override
                public void onSuccess(TM_ProductInfo productInfo) {
                    hideProgress();
                    needToUploadProduct = false;
                    current_product.id = productInfo.id;
                    providedProductId = productInfo.id;
                    uploadProductShippingInfo(providedProductId);
                    assignSeller(current_product);
                }

                @Override
                public void onFailure(Exception error) {
                    hideProgress();
                    Helper.showToast(coordinatorLayout, getString(L.string.product_upload_error) + "[" + error.toString() + "]");
                    Log.d("Product Upload Error: [" + error.toString() + "]");
                }
            });
        } else if (providedProductId != -1) {
            assignSeller(current_product);
        }
    }

    private void uploadProductShippingInfo(int providedProductId) {
        showProgress(getString(L.string.uploading_shipping_data));
        HashMap<String, String> params = new HashMap<>();
        List<RawShipping> listShipping = adapter_pickedShippingType.getItems();
        JSONArray jsArray = new JSONArray();
        for (RawShipping rawShipping : listShipping) {
            jsArray.put(rawShipping.getId());
        }
        params.put("pid", Base64Utils.encode(String.valueOf(providedProductId)));
        params.put("type", Base64Utils.encode("update"));
        params.put("shippings", Base64Utils.encode(jsArray.toString()));
        DataEngine.getDataEngine().updateProductShippingInfo(params, new DataQueryHandler() {
            @Override
            public void onSuccess(Object object) {
                hideProgress();
                Log.d("Product uploaded successfully.");
                needToUploadProduct = false;
            }

            @Override
            public void onFailure(Exception error) {
                hideProgress();
                Helper.toast(coordinatorLayout, L.string.product_upload_error);
                Log.d("Product Upload Error: [" + error.toString() + "]");
            }
        });
    }

    void deleteProduct() {
        showProgress(getString(L.string.please_wait));
        DataEngine.getDataEngine().deleteProductInBackground(providedProductId, new DataQueryHandler<Integer>() {
            @Override
            public void onSuccess(Integer productId) {
                hideProgress();
                Helper.showToast(getString(L.string.product_deleted));
                TM_ProductInfo.removeProductById(productId);
                Intent intent = new Intent();
                intent.setAction(Constants.ACTION_PRODUCT_DELETED);
                intent.putExtra(Extras.PRODUCT_ID, productId);
                setResult(RESULT_OK, intent);
                finish();
            }

            @Override
            public void onFailure(Exception error) {
                Helper.showToast(coordinatorLayout, getString(L.string.product_delete_error) + " [" + error.toString() + "]");
                hideProgress();
            }
        });
    }

    public void showProgress(String message) {
        mProgressDialog.setCancelable(false);
        mProgressDialog.setMessage(message);
        mProgressDialog.show();
    }

    public void hideProgress() {
        if (mProgressDialog.isShowing()) {
            mProgressDialog.dismiss();
        }
    }

    @Override
    protected void onActionBarRestored() {
    }

    private void assignSeller(final RawProductInfo productInfo) {
        if (needToAssignSeller) {
            showProgress(getString(L.string.uploading_product_data));
            Map<String, String> params = new HashMap<>();
            params.put("product_id", DataHelper.encrypt(productInfo.id));
            params.put("seller_id", DataHelper.encrypt(AppUser.getUserId()));

            if (MultiVendorConfig.shouldShowMsrpPrice()) {
                params.put("_msrp_price", DataHelper.encrypt(String.valueOf(productInfo.msrp_price)));
            }

            if (MultiVendorConfig.shouldShowCostOfGood()) {
                params.put("_wc_cog_cos", DataHelper.encrypt(String.valueOf(productInfo.cost_of_good)));
            }

            DataEngine.getDataEngine().assignProductToSellerInBackground(params, new DataQueryHandler() {
                @Override
                public void onSuccess(Object data) {
                    hideProgress();
                    Helper.showToast(getString(L.string.product_upload_successful));
                    Intent intent = new Intent();
                    intent.setAction(Constants.ACTION_PRODUCT_UPLOADED);
                    intent.putExtra(Extras.PRODUCT_ID, productInfo.id);
                    setResult(RESULT_OK, intent);
                    finish();
                }

                @Override
                public void onFailure(Exception error) {
                    hideProgress();
                    Helper.showToast(coordinatorLayout, getString(L.string.product_assign_seller_error) + " [" + error.toString() + "]");
                }
            });
        } else {
            Intent intent = new Intent();
            intent.setAction(Constants.ACTION_PRODUCT_UPDATED);
            intent.putExtra(Extras.PRODUCT_ID, productInfo.id);
            setResult(RESULT_OK, intent);
            finish();
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == REQUEST_IMAGE_CAPTURE && resultCode == RESULT_OK) {
            uploadImage(Helper.fixImageOrientation(mCurrentPhotoPath));
        }
        if (data != null && requestCode == PICK_PHOTO_CODE) {
            Uri photoUri = data.getData();
            try {
                Bitmap originalBitmap = MediaStore.Images.Media.getBitmap(getContentResolver(), photoUri);
                uploadImage(originalBitmap);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    private void uploadImage(Bitmap originalBitmap) {
        Bitmap scaledBitmap = resizeBitmap(originalBitmap, MultiVendorConfig.getUploadImageWidth(), MultiVendorConfig.getUploadImageHeight());
        loading = ProgressDialog.show(ProductUploadActivity.this, getString(L.string.uploading), getString(L.string.please_wait), false, false);
        ImageUploadTask imageUploadTask = new ImageUploadTask(new ImageUploadTask.ResponseListener() {
            @Override
            public void onResponse(String status, String url, String message) {
                loading.dismiss();
                if (status != null && status.equalsIgnoreCase("success") && !TextUtils.isEmpty(url) ) {
                    adapter_pickedImages.addItem(url);
                } else {
                    Helper.showToast(coordinatorLayout, getString(L.string.product_upload_error) + "[" + message + "]");
                    Log.d("Product Upload Error: [" + message + "]");
                    hideProgress();
                }
            }
        });
        imageUploadTask.execute(DataEngine.getDataEngine().url_image_upload, scaledBitmap);
    }

    private static Bitmap resizeBitmap(Bitmap originalBitmap, int maxWidth, int maxHeight) {
        int width = originalBitmap.getWidth();
        int height = originalBitmap.getHeight();
        float ratioBitmap = (float) width / (float) height;
        float ratioMax = (float) maxWidth / (float) maxHeight;

        int finalWidth = maxWidth;
        int finalHeight = maxHeight;
        if (ratioMax > ratioBitmap) {
            finalWidth = (int) ((float) maxHeight * ratioBitmap);
        } else {
            finalHeight = (int) ((float) maxWidth / ratioBitmap);
        }
        Bitmap bitmap = Bitmap.createScaledBitmap(originalBitmap, finalWidth, finalHeight, true);
        return bitmap;
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        Nammu.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                this.onBackPressed();
                return true;
            case Constants.ID_ACTION_MENU_EDIT:
                Toast.makeText(this, getString(L.string.delete), Toast.LENGTH_SHORT).show();
                return true;
            case Constants.ID_WISH_MENU_DELETE:
                Helper.getConfirmation(this, getString(L.string.are_you_sure), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        deleteProduct();
                    }
                });
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }

    final PermissionCallback permissionCameraCallback = new PermissionCallback() {
        @Override
        public void permissionGranted() {
            takeCameraPicture();
        }

        @Override
        public void permissionRefused() {
            Snackbar.make(coordinatorLayout, getString(L.string.you_need_to_allow_permission),
                    Snackbar.LENGTH_INDEFINITE)
                    .setAction(getString(L.string.ok), new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            Nammu.askForPermission(ProductUploadActivity.this, Manifest.permission.CAMERA, permissionCameraCallback);
                        }
                    }).show();
        }
    };

    final PermissionCallback permissionExternalStorageCallback = new PermissionCallback() {
        @Override
        public void permissionGranted() {
            Intent intent = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
            if (intent.resolveActivity(getPackageManager()) != null) {
                startActivityForResult(intent, PICK_PHOTO_CODE);
            }
        }

        @Override
        public void permissionRefused() {
            Snackbar.make(coordinatorLayout, getString(L.string.you_need_to_allow_permission),
                    Snackbar.LENGTH_INDEFINITE)
                    .setAction(getString(L.string.ok), new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            Nammu.askForPermission(ProductUploadActivity.this, Manifest.permission.WRITE_EXTERNAL_STORAGE, permissionExternalStorageCallback);
                        }
                    }).show();
        }
    };

    private void dispatchTakePictureIntent() {
        if (Nammu.checkPermission(Manifest.permission.CAMERA)) {
            takeCameraPicture();
        } else {
            if (Nammu.shouldShowRequestPermissionRationale(this, Manifest.permission.CAMERA)) {
                Snackbar.make(coordinatorLayout, getString(L.string.you_need_to_allow_permission), Snackbar.LENGTH_INDEFINITE)
                        .setAction(getString(L.string.ok), new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                Nammu.askForPermission(ProductUploadActivity.this, Manifest.permission.CAMERA, permissionCameraCallback);
                            }
                        }).show();
            } else {
                Nammu.askForPermission(this, Manifest.permission.CAMERA, permissionCameraCallback);
            }
        }
    }

    private void takeCameraPicture() {
        Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        if (takePictureIntent.resolveActivity(getPackageManager()) != null) {
            File photoFile = null;
            try {
                photoFile = createImageFile();
            } catch (IOException e) {
                e.printStackTrace();
            }
            if (photoFile != null) {
                String authority = getString(R.string.file_provider_authority);
                Uri photoUri = FileProvider.getUriForFile(this, authority, photoFile);
                if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.KITKAT) {
                    List<ResolveInfo> resolvedIntentActivities = getPackageManager().queryIntentActivities(takePictureIntent, PackageManager.MATCH_DEFAULT_ONLY);
                    for (ResolveInfo resolvedIntentInfo : resolvedIntentActivities) {
                        String packageName = resolvedIntentInfo.activityInfo.packageName;
                        grantUriPermission(packageName, photoUri, Intent.FLAG_GRANT_WRITE_URI_PERMISSION | Intent.FLAG_GRANT_READ_URI_PERMISSION);
                    }
                }
                takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, photoUri);
                startActivityForResult(takePictureIntent, REQUEST_IMAGE_CAPTURE);
            }
        }
    }

    private void selectImage() {
        ImageChooserBottomSheetDialog.newInstance(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (v.getId() == R.id.camera_section) {
                    dispatchTakePictureIntent();
                } else if (v.getId() == R.id.gallery_section) {
                    onPickPhoto();
                }
            }
        }).show(getSupportFragmentManager(), ImageChooserBottomSheetDialog.class.getSimpleName());
    }

    public void onPickPhoto() {
        if (!Nammu.checkPermission(android.Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
            Nammu.askForPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE, permissionExternalStorageCallback);
        } else {
            Intent intent = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
            if (intent.resolveActivity(getPackageManager()) != null) {
                startActivityForResult(intent, PICK_PHOTO_CODE);
            }
        }
    }

    private File createImageFile() throws IOException {
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String imageFileName = "JPEG_" + timeStamp + "_";
        File storageDir = getExternalFilesDir(Environment.DIRECTORY_PICTURES);
        File image = File.createTempFile(
                imageFileName,  /* prefix */
                ".jpg",         /* suffix */
                storageDir      /* directory */
        );
        mCurrentPhotoPath = image.getAbsolutePath();
        return image;
    }
}
