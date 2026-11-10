
<!DOCTYPE html>
<html>
<head>
    <title>Lost and Found Dashboard</title>
     <link rel="stylesheet" href="css/style.css">
</head>
<body>

    <h1>Lost and Found Management System</h1>

    <h2>Welcome to Dashboard!</h2>

    <h3>What would you like to do?</h3>

    <p><a href="reportLost.jsp">Report Lost Item</a></p>

    <p><a href="reportFound.jsp">Report Found Item</a></p>

    <p><a href="viewItems.jsp">View Lost and Found Items</a></p>

    <p><a href="myClaims.jsp">My Claims</a></p>
    <p><a href="claimRequests.jsp">Claim Requests (on items I found)</a></p>

    <form action="logout" method="post">
        <button type="submit">Logout</button>
    </form>

    <br>

    <a href="index.jsp">Home</a>

</body>
</html>
