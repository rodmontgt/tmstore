package com.twist.tmstore.fragments;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.design.widget.BottomSheetDialogFragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.twist.tmstore.config.MultiVendorConfig;

/**
 * Created by Twist Mobile on 19-04-2017.
 */

public class ImageChooserBottomSheetDialog extends BottomSheetDialogFragment implements View.OnClickListener {
    private View.OnClickListener listener;

    public static ImageChooserBottomSheetDialog newInstance(View.OnClickListener imageSelectionListener) {
        ImageChooserBottomSheetDialog f = new ImageChooserBottomSheetDialog();
        f.listener = imageSelectionListener;
        return f;
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.image_chooser_bottomsheet_dialog, container, false);
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        View camera_section = view.findViewById(R.id.camera_section);
        camera_section.setOnClickListener(this);

        TextView tv_camera = camera_section.findViewById(R.id.tv_camera);
        tv_camera.setText(L.getString(L.string.title_camera));

        if (!MultiVendorConfig.isCameraUploadEnabled()){
            camera_section.setVisibility(View.GONE);
        }

        View gallery_section = view.findViewById(R.id.gallery_section);
        gallery_section.setOnClickListener(this);

        TextView tv_gallery = gallery_section.findViewById(R.id.tv_gallery);
        tv_gallery.setText(L.getString(L.string.title_gallery));
    }

    @Override
    public void onClick(View v) {
        listener.onClick(v);
        dismiss();
    }
}