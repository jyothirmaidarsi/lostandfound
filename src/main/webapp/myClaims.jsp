<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="java.sql.*,com.lost.util.*" %>
<%
    String me = (String) session.getAttribute("userEmail");
    if (me == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Claims</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        body { max-width: 1000px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ccc; padding: 6px; text-align: left; vertical-align: top; }
        th { background: #e8eef5; }
    </style>
</head>
<body>
    <h1>My Claims</h1>

    <% if ("1".equals(request.getParameter("success"))) { %>
        <p class="success">Your claim was sent to the person who found the item. Please wait for their decision.</p>
    <% } %>

    <table>
        <tr>
            <th>Item</th><th>Location found</th><th>Your proof</th><th>Claimed on</th><th>Status</th>
        </tr>
<%
    int count = 0;
    String sql = "select i.item_name, i.location, c.proof_text, c.created_at, c.status, c.reject_reason, "
        + "f.full_name as finder_name, f.email as finder_email "
        + "from claims c join items i on c.item_id = i.item_id "
        + "join users f on f.email = i.reported_by "
        + "where c.claimant_email = ? order by c.created_at desc, c.claim_id desc";

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setString(1, me);
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                count++;
                String status = rs.getString("status");
%>
        <tr>
            <td><%= HtmlUtil.esc(rs.getString("item_name")) %></td>
            <td><%= HtmlUtil.esc(rs.getString("location")) %></td>
            <td><%= HtmlUtil.esc(rs.getString("proof_text")) %></td>
            <td><%= rs.getDate("created_at") %></td>
            <td>
                <%= HtmlUtil.esc(status) %>
                <% if ("Pending".equals(status)) { %>
                    <br><small>Waiting for the finder's decision</small>
                <% } %>
                <% if (rs.getString("reject_reason") != null) { %>
                    <br><small>Reason: <%= HtmlUtil.esc(rs.getString("reject_reason")) %></small>
                <% } %>
                <% if ("Approved".equals(status)) { %>
                    <br><small>Contact the finder to collect it:<br>
                    <%= HtmlUtil.esc(rs.getString("finder_name")) %><br>
                    <%= HtmlUtil.esc(rs.getString("finder_email")) %></small>
                <% } %>
            </td>
        </tr>
<%
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
%>
        <tr><td colspan="5" class="error">Could not load your claims. Please try again.</td></tr>
<%
    }
    if (count == 0) {
%>
        <tr><td colspan="5">You have not submitted any claims yet.</td></tr>
<%  } %>
    </table>

    <br>
    <a href="viewItems.jsp">Browse Items</a> |
    <a href="dashboard.jsp">Back to Dashboard</a>
</body>
</html>