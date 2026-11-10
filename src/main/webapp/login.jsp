
<!DOCTYPE html>
<html>
<head>
    <title>User Login</title>
     <link rel="stylesheet" href="css/style.css">
</head>
<body>

    <h1>Login</h1>

    <form action="login" method="post">

        <label>Email:</label>
        <input type="email" name="email" required>
        <br><br>

        <label>Password:</label>
        <input type="password" name="password" required>
        <br><br>

        <button type="submit">Login</button>

    </form>

    <p>Don't have an account? <a href="register.jsp">Register here</a></p>

    <a href="index.jsp">Back to Home</a>

</body>
</html>
