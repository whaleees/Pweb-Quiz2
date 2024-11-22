<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        :root {
            --primary: #D9C8AD;
            --secondary: #F1EDE4;
            --accent: #8E7C71;
            --background: #FAF9F7;
            --text-primary: #3E3D3A;
            --text-secondary: #5C5B58;
            --button-bg: #D6C5A7;
            --button-text: #FFFFFF;
            --button-hover-bg: #C4B395;
        }
    </style>
</head>
<body class="bg-[var(--background)] flex items-center justify-center h-screen">
    <div class="bg-[var(--secondary)] shadow-lg rounded-lg p-8 w-full max-w-md">
        <h1 class="text-2xl font-bold text-center text-[var(--accent)] mb-6">Login</h1>
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
                <label for="email" class="block text-[var(--text-primary)] font-medium mb-2">Email:</label>
                <input 
                    type="text" 
                    id="email" 
                    name="email" 
                    class="w-full px-4 py-2 border border-[var(--accent)] rounded-lg focus:outline-none focus:ring-2 focus:ring-[var(--accent)]"
                    placeholder="Enter your email"
                    required
                >
            </div>

            <div>
                <label for="password" class="block text-[var(--text-primary)] font-medium mb-2">Password:</label>
                <input 
                    type="password" 
                    id="password" 
                    name="password" 
                    class="w-full px-4 py-2 border border-[var(--accent)] rounded-lg focus:outline-none focus:ring-2 focus:ring-[var(--accent)]"
                    placeholder="Enter your password"
                    required
                >
            </div>

            <button 
                type="submit" 
                class="w-full bg-[var(--button-bg)] text-[var(--button-text)] py-2 rounded-lg font-medium hover:bg-[var(--button-hover-bg)] transition duration-200"
            >
                Login
            </button>
        </form>
        <p class="text-center text-[var(--text-secondary)] mt-4">
            Don't have an account? 
            <a href="signup.jsp" class="text-[var(--accent)] hover:underline">Sign Up</a>
        </p>
    </div>
</body>
</html>
