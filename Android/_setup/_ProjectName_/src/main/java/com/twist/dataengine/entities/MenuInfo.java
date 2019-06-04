package com.twist.dataengine.entities;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 09-Jun-16.
 */
public class MenuInfo {

    private int id;

    private String name;

    private String slug;

    private List<MenuOption> menuOptions;

    private static List<MenuInfo> menuInfos = new ArrayList<>();

    private MenuInfo() {
        menuInfos.add(this);
    }

    private MenuInfo(int id) {
        this();
        this.id = id;
    }

    public static MenuInfo create(int id) {
        if (menuInfos != null) {
            for (MenuInfo menuInfo : menuInfos) {
                if (menuInfo.id == id) {
                    return menuInfo;
                }
            }
        }
        return new MenuInfo(id);
    }

    public static List<MenuInfo> getAll() {
        return menuInfos;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getSlug() {
        return slug;
    }

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public List<MenuOption> getMenuOptions(boolean removeNestedChild) {
        if(removeNestedChild) {
            List<MenuOption> menuOptions = new ArrayList<>();
            for (MenuOption menuOption : this.menuOptions) {
                if (menuOption.getParent().equals("0")) {
                    menuOptions.add(menuOption);
                }
            }
            return menuOptions;
        }  else {
            return this.menuOptions;
        }
    }

    public boolean addMenuOption(MenuOption menuOption) {
        if (menuOptions == null) {
            menuOptions = new ArrayList<>();
            menuOptions.add(menuOption);
            return true;
        }

        if (!menuOptions.contains(menuOption)) {
            menuOptions.add(menuOption);
            return true;
        }
        return false;
    }
}
