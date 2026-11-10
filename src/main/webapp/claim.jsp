<%@ page contentType="text/html;charset=UTF-8" language="java"
         import="java.sql.*,com.lost.util.*" %>
<%
    String me = (String) session.getAttribute("userEmail");
    if (me == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int itemId = 0;
    try {
        itemId = Integer.parseInt(request.getParameter("itemId"));
    } catch (Exception e) {
        response.sendRedirect("viewItems.jsp");
        return;
    }

    String itemName = null, category = null, location = null, itemType = null, status = null, owner = null;
    Date itemDate = null;

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(
             "select item_name, category, location, item_date, item_type, status, reported_by "
             + "from items where item_id = ?")) {
        ps.setInt(1, itemId);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                itemName = rs.getString("item_name");
                category = rs.getString("category");
                location = rs.getString("location");
                itemDate = rs.getDate("item_date");
                itemType = rs.getString("item_type");
                status = rs.getString("status");
                owner = rs.getString("reported_by");
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    boolean allowed = itemName != null && "FOUND".equals(itemType)
            && ("Found".equals(status) || "Claim Pending".equals(status))
            && !me.equals(owner);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Claim Item</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <h1>Claim Item</h1>

<% if (!allowed) { %>
    <p style="color:red;">This item cannot be claimed.</p>
<% } else { %>

    <% if ("invalid".equals(request.getParameter("error"))) { %>
        <p style="color:red;">Please describe your proof of ownership (maximum 500 characters).</p>
    <% } else if ("duplicate".equals(request.getParameter("error"))) { %>
        <p style="color:red;">You have already claimed this item.</p>
    <% } else if ("failed".equals(request.getParameter("error"))) { %>
        <p style="color:red;">Something went wrong. Please try again.</p>
    <% } %>

    <p><b>Item:</b> <%= HtmlUtil.esc(itemName) %></p>
    <p><b>Category:</b> <%= HtmlUtil.esc(category) %></p>
    <p><b>Found at:</b> <%= HtmlUtil.esc(location) %> on <%= itemDate %></p>

    <p>To prove this is yours, describe something only the owner would know
       (colour, brand, marks, what is inside, serial number).</p>

    <form action="submitClaim" method="post">
        <input type="hidden" name="itemId" value="<%= itemId %>">
        <label>Proof of ownership:</label><br>
        <textarea name="proof" rows="5" cols="45" maxlength="500" required></textarea>
        <br><br>
        <button type="submit">Submit Claim</button>
    </form>

<% } %>

    <br>
    <a href="viewItems.jsp">Back to Items</a>
</body>
</html>