package com.utils;

import android.graphics.Bitmap;
import android.graphics.Color;
import android.support.annotation.ColorInt;

/**
 * Created by Twist Mobile on 3/7/2017.
 */

public class GraphicsToText {

    public static String getString(Bitmap bitmap, String separator) {
        StringBuilder str = new StringBuilder();
        try {
            int width = bitmap.getWidth();
            int height = bitmap.getHeight();
            int totalPixels = width * height;
            int[] argbPixels = new int[totalPixels];
            int componentsPerPixel = 3;
            int totalBytes = totalPixels * componentsPerPixel;

            for (int i = 0; i < height; i++) {
                for (int j = 0; j < width; j++) {
                    int intColor = bitmap.getPixel(j, i);
                    if (intColor != 0) {
                        int red = Color.red(intColor);
                        str.append((char) red);
                    }
                    //int green = Color.green(intColor);
                    //int blue = Color.blue(intColor);
                }
                if (i < height - 1) {
                    str.append(separator);
                }
            }

            byte[] rgbValues = new byte[totalBytes];
            for (int i = 0; i < totalPixels; i++) {
                @ColorInt int argbPixel = argbPixels[i];
                int red = Color.red(argbPixel);
                int green = Color.green(argbPixel);
                int blue = Color.blue(argbPixel);
                if (red != 0) {
                    str.append((char) red);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return "";
        }
        return str.toString();
    }
}
