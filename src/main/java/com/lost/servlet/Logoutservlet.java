package com.lost.servlet;
import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/logout")
public class Logoutservlet extends HttpServlet {

    protected void doPost(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html");
        PrintWriter webout = response.getWriter();

        HttpSession session = request.getSession(false);

        if (session != null) {
            session.invalidate();
        }

        webout.print("Logout successful!<br>");
        webout.print("<a href='login.jsp'>Login Again</a>");
    }
}
