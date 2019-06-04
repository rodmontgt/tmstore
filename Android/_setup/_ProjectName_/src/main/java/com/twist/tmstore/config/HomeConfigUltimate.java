package com.twist.tmstore.config;

import com.twist.tmstore.entities.HomeElementUltimate;

/**
 * Created by Twist Mobile on 5/13/2016.
 */
public class HomeConfigUltimate {

    private int numColumns;

    private int numRows;

    public HomeElementUltimate[] homeElements;

    public HomeConfigUltimate() {
    }

    public int getNumRows() {
        return numRows;
    }

    public int getNumColumns() {
        return numColumns;
    }

    public void calculateDimensions() {
        numRows = 0;
        numColumns = 0;
        if (homeElements != null) {
            for (HomeElementUltimate homeElement : homeElements) {
                numRows = Math.max(numRows, (homeElement.row-1) + homeElement.size_y);
                numColumns = Math.max(numColumns, (homeElement.col-1) + homeElement.size_x);
            }
        }
    }
}
