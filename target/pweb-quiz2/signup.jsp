<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<html>
<head>
    <title>Sign Up</title>
    <link rel="stylesheet" href="/css/register.css">
</head>
<body>
    <h1>Sign Up</h1>
    <form action="/pweb-quiz2/signup" method="post">
        <label for="username">Username:</label>
        <input type="text" id="username" name="username" required><br><br>

        <label for="password">Password:</label>
        <input type="password" id="password" name="password" required><br><br>

        <label for="email">Email:</label>
        <input type="email" id="email" name="email" required><br><br>

        <button type="submit">Sign Up</button>
    </form>
    <p>Already have an account? <a href="login.jsp">Login</a></p>
</body>
</html>
