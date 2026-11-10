package com.lost.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.lost.util.DBConnection;

@WebServlet("/reportFoundItem")
public class ReportFoundServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        String userEmail = (String) session.getAttribute("userEmail");

        String itemName = request.getParameter("itemName");
        String category = request.getParameter("category");
        String description = request.getParameter("description");
        String location = request.getParameter("location");
        String dateText = request.getParameter("itemDate");

        if (itemName == null || itemName.trim().isEmpty() || itemName.length() > 100
                || category == null || category.trim().isEmpty()
                || location == null || location.trim().isEmpty() || location.length() > 150
                || dateText == null || dateText.trim().isEmpty()
                || (description != null && description.length() > 500)) {
            response.sendRedirect("reportFound.jsp?error=invalid");
            return;
        }

        java.sql.Date itemDate;
        try {
            itemDate = java.sql.Date.valueOf(dateText.trim());
        } catch (IllegalArgumentException e) {
            response.sendRedirect("reportFound.jsp?error=invalid");
            return;
        }
        if (itemDate.after(new java.util.Date())) {
            response.sendRedirect("reportFound.jsp?error=invalid");
            return;
        }

        String qry = "insert into items "
                + "(item_id, item_name, category, description, location, item_date, item_type, status, reported_by) "
                + "values (items_seq.nextval, ?, ?, ?, ?, ?, 'FOUND', 'Found', ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement pstmt = con.prepareStatement(qry)) {

            pstmt.setString(1, itemName.trim());
            pstmt.setString(2, category.trim());
            pstmt.setString(3, description == null ? null : description.trim());
            pstmt.setString(4, location.trim());
            pstmt.setDate(5, itemDate);
            pstmt.setString(6, userEmail);
            pstmt.executeUpdate();

            response.sendRedirect("reportFound.jsp?success=1");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("reportFound.jsp?error=failed");
        }
    }
}