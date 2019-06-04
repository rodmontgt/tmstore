package com.twist.tmstore.entities;

public class DummyUser
{
	public AppUser.USER_TYPE user_type = AppUser.USER_TYPE.ANONYMOUS_USER;
	public String validated_id = ""; //": "john.doe@example.com",
	public String email = ""; //": "john.doe@example.com",
	public String username = ""; //": "john.doe",
	public String password = ""; //": "john.doe",
	public String first_name = ""; //": "James",
	public String last_name = ""; //": "Doe",
    public String avatar_url = ""; //": "https://secure.gravatar.com/avatar/ad516503a11cd5ca435acc9bb6523536?s=96",

	public Address billing_address = null;
	public Address shipping_address = null;
}
