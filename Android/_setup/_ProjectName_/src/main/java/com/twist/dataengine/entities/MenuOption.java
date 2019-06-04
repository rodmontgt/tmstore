package com.twist.dataengine.entities;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 09-Jun-16.
 */
public class MenuOption {
    private int id;

    private String parent;

    private int menuOrder;

    private int categoryId;

    private String url;

    private String name;

    private static List<MenuOption> menuOptionList;

    private MenuOption() {
        if (menuOptionList == null) {
            menuOptionList = new ArrayList<>();
        }
        menuOptionList.add(this);
    }

    private MenuOption(int id) {
        this();
        this.id = id;
    }

    public static MenuOption create(int id) {
        if (menuOptionList != null) {
            for (MenuOption menuOption : menuOptionList) {
                if (menuOption.id == id) {
                    return menuOption;
                }
            }
        }
        return new MenuOption(id);
    }

    public static List<MenuOption> getAll() {
        return menuOptionList;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getParent() {
        return parent;
    }

    public void setParent(String parent) {
        this.parent = parent;
    }

    public int getMenuOrder() {
        return menuOrder;
    }

    public void setMenuOrder(int menuOrder) {
        this.menuOrder = menuOrder;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public List<MenuOption> getAllChild() {
        List<MenuOption> menuOptions = new ArrayList<>();
        final String id = String.valueOf(getId());
        for (MenuOption menuOption : MenuOption.getAll()) {
            if (menuOption.parent.equals(id)) {
                menuOptions.add(menuOption);
            }
        }
        return menuOptions;
    }
}
