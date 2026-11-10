<%@ page contentType="text/html;charset=UTF-8" language="java"
    import="java.util.List,java.util.ArrayList,java.sql.Connection,java.sql.PreparedStatement,java.sql.ResultSet,com.lost.util.DBConnection,com.lost.util.HtmlUtil" %><%
    String me = (String) session.getAttribute("userEmail");
    if (me == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String q = request.getParameter("q");
    String type = request.getParameter("type");
    if (q == null) q = "";
    q = q.trim();
    if (type == null || (!type.equals("LOST") && !type.equals("FOUND"))) type = "";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>View Lost and Found Items</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ccc; padding: 6px; text-align: left; }
        th { background: #e8eef5; }
    </style>
</head>
<body>
    <h1>Lost and Found Items</h1>

    <form action="viewItems.jsp" method="get">
        <input type="text" name="q" placeholder="Search name, category, location"
               value="<%= HtmlUtil.esc(q) %>">
        <select name="type">
            <option value="" <%= type.equals("") ? "selected" : "" %>>All</option>
            <option value="LOST" <%= type.equals("LOST") ? "selected" : "" %>>Lost</option>
            <option value="FOUND" <%= type.equals("FOUND") ? "selected" : "" %>>Found</option>
        </select>
        <button type="submit">Search</button>
    </form>
    <br>

    <table>
        <tr>
            <th>Type</th><th>Item</th><th>Category</th><th>Location</th>
            <th>Date</th><th>Status</th><th>Action</th>
        </tr>
<%
    StringBuilder sql = new StringBuilder(
        "select item_id, item_name, category, location, item_date, item_type, status, reported_by "
        + "from items where 1=1");
    List<String> params = new ArrayList<String>();

    if (!type.isEmpty()) {
        sql.append(" and item_type = ?");
        params.add(type);
    }
    if (!q.isEmpty()) {
        sql.append(" and (upper(item_name) like ? or upper(category) like ?"
                 + " or upper(location) like ? or upper(description) like ?)");
        String like = "%" + q.toUpperCase() + "%";
        params.add(like);
        params.add(like);
        params.add(like);
        params.add(like);
    }
    sql.append(" order by created_at desc, item_id desc");

    int count = 0;
    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql.toString())) {

        for (int i = 0; i < params.size(); i++) {
            ps.setString(i + 1, params.get(i));
        }

        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                count++;
                String itemType = rs.getString("item_type");
                String status = rs.getString("status");
                String owner = rs.getString("reported_by");
                boolean canClaim = "FOUND".equals(itemType)
                        && ("Found".equals(status) || "Claim Pending".equals(status))
                        && !me.equals(owner);
%>
        <tr>
            <td><%= HtmlUtil.esc(itemType) %></td>
            <td><%= HtmlUtil.esc(rs.getString("item_name")) %></td>
            <td><%= HtmlUtil.esc(rs.getString("category")) %></td>
            <td><%= HtmlUtil.esc(rs.getString("location")) %></td>
            <td><%= rs.getDate("item_date") %></td>
            <td><%= HtmlUtil.esc(status) %></td>
            <td>
                <% if (canClaim) { %>
                    <a href="claim.jsp?itemId=<%= rs.getInt("item_id") %>">Claim</a>
                <% } else if (me.equals(owner)) { %>
                    Your report
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
        <tr><td colspan="7" style="color:red;">Could not load items. Please try again.</td></tr>
<%
    }
    if (count == 0) {
%>
        <tr><td colspan="7">No items found.</td></tr>
<%  } %>
    </table>

    <br>
    <a href="dashboard.jsp">Back to Dashboard</a>
</body>
</html>