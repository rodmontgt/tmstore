package com.twist.tmstore.entities;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 6/21/2016.
 */

public class TileGroupHorizontal extends HomeElement {
    public List<Tile> tiles = new ArrayList<>();

    public int getMaxColumns() {
        return maxColumns;
    }

    public void setMaxColumns(int maxColumns) {
        this.maxColumns = maxColumns;
    }

    int maxColumns = 2;
    public TileGroupHorizontal() {
        type = 1;
    }
}
