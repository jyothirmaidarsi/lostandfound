package com.lost.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.lost.util.DBConnection;

@WebServlet("/submitClaim")
public class SubmitClaimServlet extends HttpServlet {
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

        int itemId;
        try {
            itemId = Integer.parseInt(request.getParameter("itemId"));
        } catch (Exception e) {
            response.sendRedirect("viewItems.jsp");
            return;
        }

        String proof = request.getParameter("proof");
        if (proof == null || proof.trim().isEmpty() || proof.length() > 500) {
            response.sendRedirect("claim.jsp?itemId=" + itemId + "&error=invalid");
            return;
        }

        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            String itemType = null, status = null, owner = null;

            // Lock the item row so two people cannot change it at the same time
            try (PreparedStatement ps = con.prepareStatement(
                    "select item_type, status, reported_by from items where item_id = ? for update")) {
                ps.setInt(1, itemId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        itemType = rs.getString("item_type");
                        status = rs.getString("status");
                        owner = rs.getString("reported_by");
                    }
                }
            }

            boolean allowed = itemType != null && "FOUND".equals(itemType)
                    && ("Found".equals(status) || "Claim Pending".equals(status))
                    && !me.equals(owner);

            if (!allowed) {
                con.rollback();
                response.sendRedirect("viewItems.jsp");
                return;
            }

            try (PreparedStatement ps = con.prepareStatement(
                    "insert into claims (claim_id, item_id, claimant_email, proof_text, status) "
                    + "values (claims_seq.nextval, ?, ?, ?, 'Pending')")) {
                ps.setInt(1, itemId);
                ps.setString(2, me);
                ps.setString(3, proof.trim());
                ps.executeUpdate();
            }

            try (PreparedStatement ps = con.prepareStatement(
                    "update items set status = 'Claim Pending' where item_id = ?")) {
                ps.setInt(1, itemId);
                ps.executeUpdate();
            }

            con.commit();
            response.sendRedirect("myClaims.jsp?success=1");

        } catch (SQLException e) {
            rollbackQuietly(con);
            if (e.getErrorCode() == 1) {   // ORA-00001: same user claimed the same item twice
                response.sendRedirect("claim.jsp?itemId=" + itemId + "&error=duplicate");
            } else {
                e.printStackTrace();
                response.sendRedirect("claim.jsp?itemId=" + itemId + "&error=failed");
            }
        } catch (Exception e) {
            rollbackQuietly(con);
            e.printStackTrace();
            response.sendRedirect("claim.jsp?itemId=" + itemId + "&error=failed");
        } finally {
            if (con != null) {
                try {
                    con.close();
                } catch (Exception ignored) {
                }
            }
        }
    }

    private void rollbackQuietly(Connection con) {
        if (con != null) {
            try {
                con.rollback();
            } catch (Exception ignored) {
            }
        }
    }
}