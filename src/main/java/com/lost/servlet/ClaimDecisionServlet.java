package com.lost.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.lost.util.DBConnection;

@WebServlet("/claimDecision")
public class ClaimDecisionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        String me = (String) session.getAttribute("userEmail");

        int claimId;
        try {
            claimId = Integer.parseInt(request.getParameter("claimId"));
        } catch (Exception e) {
            response.sendRedirect("claimRequests.jsp?error=1");
            return;
        }

        String action = request.getParameter("action");
        String reason = request.getParameter("reason");
        if (reason != null) {
            reason = reason.trim();
        }

        boolean approve = "approve".equals(action);
        boolean reject = "reject".equals(action);
        if (!approve && !reject) {
            response.sendRedirect("claimRequests.jsp?error=1");
            return;
        }
        if (reject && (reason == null || reason.isEmpty() || reason.length() > 300)) {
            response.sendRedirect("claimRequests.jsp?error=1");
            return;
        }

        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            int itemId = 0;
            String status = null;
            String owner = null;

            try (PreparedStatement ps = con.prepareStatement(
                    "select item_id, status from claims where claim_id = ? for update")) {
                ps.setInt(1, claimId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        itemId = rs.getInt("item_id");
                        status = rs.getString("status");
                    }
                }
            }

            if (status != null) {
                try (PreparedStatement ps = con.prepareStatement(
                        "select reported_by from items where item_id = ?")) {
                    ps.setInt(1, itemId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            owner = rs.getString("reported_by");
                        }
                    }
                }
            }

            // Only the person who posted the found item may decide, and only on Pending claims
            if (status == null || !"Pending".equals(status) || owner == null || !owner.equals(me)) {
                con.rollback();
                response.sendRedirect("claimRequests.jsp?error=1");
                return;
            }

            if (approve) {
                try (PreparedStatement ps = con.prepareStatement(
                        "update claims set status = 'Approved' where claim_id = ?")) {
                    ps.setInt(1, claimId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = con.prepareStatement(
                        "update claims set status = 'Rejected', "
                        + "reject_reason = 'Another claim for this item was approved' "
                        + "where item_id = ? and claim_id <> ? and status = 'Pending'")) {
                    ps.setInt(1, itemId);
                    ps.setInt(2, claimId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = con.prepareStatement(
                        "update items set status = 'Returned' where item_id = ?")) {
                    ps.setInt(1, itemId);
                    ps.executeUpdate();
                }
            } else {
                try (PreparedStatement ps = con.prepareStatement(
                        "update claims set status = 'Rejected', reject_reason = ? where claim_id = ?")) {
                    ps.setString(1, reason);
                    ps.setInt(2, claimId);
                    ps.executeUpdate();
                }
                int pending = 0;
                try (PreparedStatement ps = con.prepareStatement(
                        "select count(*) from claims where item_id = ? and status = 'Pending'")) {
                    ps.setInt(1, itemId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            pending = rs.getInt(1);
                        }
                    }
                }
                if (pending == 0) {
                    try (PreparedStatement ps = con.prepareStatement(
                            "update items set status = 'Found' where item_id = ?")) {
                        ps.setInt(1, itemId);
                        ps.executeUpdate();
                    }
                }
            }

            con.commit();
            response.sendRedirect("claimRequests.jsp?done=" + (approve ? "approved" : "rejected"));

        } catch (Exception e) {
            if (con != null) {
                try {
                    con.rollback();
                } catch (Exception ignored) {
                }
            }
            e.printStackTrace();
            response.sendRedirect("claimRequests.jsp?error=1");
        } finally {
            if (con != null) {
                try {
                    con.close();
                } catch (Exception ignored) {
                }
            }
        }
    }
}