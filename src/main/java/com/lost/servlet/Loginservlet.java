package com.lost.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.*;
import com.lost.util.DBConnection;

@WebServlet("/login")
public class Loginservlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    
    public Loginservlet() {
        super();
    }

		protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
	}

	
	protected void doPost(HttpServletRequest request, HttpServletResponse response) 
			throws ServletException, IOException {
		response.setContentType("Text/HTML");
		PrintWriter webout=response.getWriter();
		
		String email=request.getParameter("email");
		String password=request.getParameter("password");
		
		try {
			Connection con=DBConnection.getConnection();
			String qry1 = "select * from users where email=? and password_hash=?";
			
			PreparedStatement pstmt=con.prepareStatement(qry1);
			
			pstmt.setString(1, email);
			pstmt.setString(2, password);
			
			ResultSet rs=pstmt.executeQuery();
			
			if(rs.next()) {
				HttpSession session = request.getSession();
				session.setAttribute("userName", rs.getString("full_name"));
				session.setAttribute("userEmail", rs.getString("email"));
				response.sendRedirect("dashboard.jsp");			}
			else {
				webout.print("invalid user or password");
			}
			
			con.close();
		}
		catch(Exception e) {
			webout.print(e);
		
		}
	}

}
