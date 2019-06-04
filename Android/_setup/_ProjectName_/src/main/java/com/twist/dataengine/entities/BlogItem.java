package com.twist.dataengine.entities;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 10/25/2017.
 */

public class BlogItem {
    private static List<BlogItem> allItems = new ArrayList<>();
    String post_name;
    String post_content;
    String postTitle;
    String post_author;
    int id;
    private String guid;
    private String postDate;
    private String featuredImage;


    public int getId() {
        return id;
    }

    public String getPostDate() {
        return postDate;
    }

    public void setPostDate(String postDate) {
        this.postDate = postDate;
    }

    public void setId(int id) {
        this.id = id;
    }

    public static List<BlogItem> getAll() {
        return allItems;
    }

    public static BlogItem getBlog(int id) {
        for (BlogItem blogItem : allItems) {
            if (blogItem.getId() == id) {
                return blogItem;
            }
        }
        return null;
    }

    public static BlogItem createBlog(int id) {
        for (BlogItem blogItem : allItems) {
            if (blogItem.getId() == id) {
                return blogItem;
            }
        }
        return new BlogItem();
    }


    public BlogItem() {
        allItems.add(this);
    }

    public String getPostName() {
        return post_name;
    }

    public void setPostName(String post_name) {
        this.post_name = post_name;
    }

    public String getPostTitle() {
        return postTitle;
    }

    public void setPostTitle(String postTitle) {
        this.postTitle = postTitle;
    }

    public String getPostAuthor() {
        return post_author;
    }

    public void setPostAuthor(String post_author) {
        this.post_author = post_author;
    }

    public String getPostContent() {
        return post_content;
    }

    public void setPostContent(String post_content) {
        this.post_content = post_content;
    }
    
    public String getGuid() {
        return guid;
    }

    public void setGuid(String navigationUrl) {
        this.guid = navigationUrl;
    }

    public String getFeaturedImage() {
        return featuredImage;
    }

    public void setFeaturedImage(String featuredImage) {
        this.featuredImage = featuredImage;
    }
}
