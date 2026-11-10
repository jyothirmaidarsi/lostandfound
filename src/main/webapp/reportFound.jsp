<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session.getAttribute("userEmail") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Report Found Item</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <h1>Report Found Item</h1>

    <% if ("1".equals(request.getParameter("success"))) { %>
        <p style="color:green;">Thank you. The found item has been reported.</p>
    <% } %>
    <% if ("invalid".equals(request.getParameter("error"))) { %>
        <p style="color:red;">Please fill all required fields correctly. The date cannot be in the future.</p>
    <% } else if ("failed".equals(request.getParameter("error"))) { %>
        <p style="color:red;">Something went wrong. Please try again.</p>
    <% } %>

    <form action="reportFoundItem" method="post">
        <label>Item Name:</label>
        <input type="text" name="itemName" maxlength="100" required>
        <br><br>

        <label>Category:</label>
        <select name="category" required>
            <option value="">-- Select --</option>
            <option>Electronics</option>
            <option>Documents / ID Cards</option>
            <option>Bags</option>
            <option>Books / Stationery</option>
            <option>Keys</option>
            <option>Wallet / Money</option>
            <option>Clothing</option>
            <option>Jewellery</option>
            <option>Other</option>
        </select>
        <br><br>

        <label>Description:</label><br>
        <textarea name="description" rows="4" cols="40" maxlength="500"></textarea>
        <br><br>

        <label>Location where found:</label>
        <input type="text" name="location" maxlength="150" required>
        <br><br>

        <label>Date found:</label>
        <input type="date" name="itemDate" required>
        <br><br>

        <button type="submit">Report Found Item</button>
    </form>

    <br>
    <a href="dashboard.jsp">Back to Dashboard</a>
</body>
</html>