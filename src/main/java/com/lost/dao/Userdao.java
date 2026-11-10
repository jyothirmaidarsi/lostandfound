package com.lost.dao;

import java.sql.PreparedStatement;
import java.sql.Connection;

import com.lost.util.DBConnection;

public class Userdao{
	    public boolean register(String name , String email,String password) {
	    try {
            Connection con = DBConnection.getConnection();
	    	String qry="insert into users values(?,?,?) ";
	    	PreparedStatement pstmt=con.prepareStatement(qry);
	    	pstmt.setString(1,name);
	    	pstmt.setString(2,email);
	    	pstmt.setString(3,password);
	    	int i=pstmt.executeUpdate();
	    	 
	    	con.close();

	    	
	    	if(i>0)
	    		return true;
	    	else
	    		return false;
	    }
	    catch(Exception e) {
	    	System.out.println(e);
	    	return false;
	    }
	    }
	
}