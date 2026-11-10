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
    <title>Claim Requests</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        body { max-width: 1000px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ccc; padding: 6px; text-align: left; vertical-align: top; }
        th { background: #e8eef5; }
        .box { margin-bottom: 4px; }
    </style>
</head>
<body>
    <h1>Claim Requests on Items I Found</h1>

    <% if ("approved".equals(request.getParameter("done"))) { %>
        <p class="success">Claim approved. The item is marked as Returned.</p>
    <% } else if ("rejected".equals(request.getParameter("done"))) { %>
        <p class="success">Claim rejected.</p>
    <% } else if (request.getParameter("error") != null) { %>
        <p class="error">Could not complete the action. A reason is required to reject, and only Pending claims can be changed.</p>
    <% } %>

    <table>
        <tr>
            <th>Your found item</th><th>Claimant</th><th>Their proof of ownership</th>
            <th>Status</th><th>Action</th>
        </tr>
<%
    int count = 0;
    String sql = "select c.claim_id, c.proof_text, c.status, c.reject_reason, "
        + "u.full_name, c.claimant_email, i.item_name, i.category, i.description, i.location "
        + "from claims c join items i on c.item_id = i.item_id "
        + "join users u on u.email = c.claimant_email "
        + "where i.reported_by = ? "
        + "order by case when c.status = 'Pending' then 0 else 1 end, c.created_at desc, c.claim_id desc";

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setString(1, me);
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                count++;
                String status = rs.getString("status");
                int claimId = rs.getInt("claim_id");
%>
        <tr>
            <td>
                <b><%= HtmlUtil.esc(rs.getString("item_name")) %></b><br>
                <%= HtmlUtil.esc(rs.getString("category")) %><br>
                <%= HtmlUtil.esc(rs.getString("description")) %><br>
                Found at: <%= HtmlUtil.esc(rs.getString("location")) %>
            </td>
            <td>
                <%= HtmlUtil.esc(rs.getString("full_name")) %>
                <% if ("Approved".equals(status)) { %>
                    <br><%= HtmlUtil.esc(rs.getString("claimant_email")) %>
                <% } %>
            </td>
            <td><%= HtmlUtil.esc(rs.getString("proof_text")) %></td>
            <td><%= HtmlUtil.esc(status) %>
                <% if (rs.getString("reject_reason") != null) { %>
                    <br><small>Reason: <%= HtmlUtil.esc(rs.getString("reject_reason")) %></small>
                <% } %>
            </td>
            <td>
            <% if ("Pending".equals(status)) { %>
                <form action="claimDecision" method="post" class="box"
                      onsubmit="return confirm('Approve this claim and mark the item as Returned?');">
                    <input type="hidden" name="claimId" value="<%= claimId %>">
                    <input type="hidden" name="action" value="approve">
                    <button type="submit">Approve</button>
                </form>
                <form action="claimDecision" method="post">
                    <input type="hidden" name="claimId" value="<%= claimId %>">
                    <input type="hidden" name="action" value="reject">
                    <input type="text" name="reason" placeholder="Reason for rejection" maxlength="300" required>
                    <button type="submit">Reject</button>
                </form>
            <% } else { %>
                -
            <% } %>
            </td>
        </tr>
<%
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
%>
        <tr><td colspan="5" class="error">Could not load claim requests.</td></tr>
<%
    }
    if (count == 0) {
%>
        <tr><td colspan="5">No one has claimed your found items yet.</td></tr>
<%  } %>
    </table>

    <br>
    <a href="dashboard.jsp">Back to Dashboard</a>
</body>
</html>