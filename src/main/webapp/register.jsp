
<!DOCTYPE html>
<html>
<head>
    <title>User Registration</title>
     <link rel="stylesheet" href="css/style.css">
</head>
<body>

    <h1>Register</h1>

    <form action="register" method="post">

        <label>Name:</label>
        <input type="text" name="name" required>
        <br><br>

        <label>Email:</label>
        <input type="email" name="email" required>
        <br><br>

        <label>Password:</label>
        <input type="password" name="password" required>
        <br><br>

        <button type="submit">Register</button>

    </form>

    <p>Already have an account? <a href="login.jsp">Login here</a></p>

    <a href="index.jsp">Back to Home</a>

</body>
</html>
