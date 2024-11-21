<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 flex items-center justify-center h-screen">
    <div class="bg-white shadow-lg rounded-lg p-8 w-full max-w-md">
        <h1 class="text-2xl font-bold text-center text-blue-600 mb-6">Login</h1>
        <form action="/pweb-quiz2/login" method="post" class="space-y-4">
            <% 
                String errorMessage = (String) request.getAttribute("errorMessage");
                if (errorMessage != null) {
            %>
                <p class="text-red-500 text-sm"><%= errorMessage %></p>
            <% 
                }
            %>
            <div>
                <label for="email" class="block text-gray-700 font-medium">Email:</label>
                <input 
                    type="text" 
                    id="email" 
                    name="email" 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="Enter your email"
                    required
                >
            </div>

            <div>
                <label for="password" class="block text-gray-700 font-medium">Password:</label>
                <input 
                    type="password" 
                    id="password" 
                    name="password" 
                    class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="Enter your password"
                    required
                >
            </div>

            <button 
                type="submit" 
                class="w-full bg-blue-600 text-white py-2 rounded-lg font-medium hover:bg-blue-700 transition duration-200"
            >
                Login
            </button>
        </form>
        <p class="text-center text-gray-600 mt-4">
            Don't have an account? 
            <a href="signup.jsp" class="text-blue-600 hover:underline">Sign Up</a>
        </p>
    </div>
</body>
</html>
