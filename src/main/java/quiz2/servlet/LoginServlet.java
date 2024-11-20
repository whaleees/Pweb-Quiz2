package quiz2.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;
import quiz2.utils.DBConnection;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class LoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT password FROM users WHERE email = ?")) {
            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String hashedPassword = rs.getString("password");

                    // Verify the password using BCrypt
                    if (BCrypt.checkpw(password, hashedPassword)) {
                        // response.getWriter().println("<h1>Login successful! Welcome, " + username + "!</h1>");
                        HttpSession session = request.getSession();
                        session.setAttribute("email", email);

                        // request.getSession().setAttribute("email", email);
                        response.sendRedirect("index.jsp");
                    } else {
                        request.setAttribute("errorMessage", "Invalid email or password!");
                        request.getRequestDispatcher("login.jsp").forward(request, response);
                        // response.sendRedirect("login.jsp");
                        // response.getWriter().println("<h1>Invalid email or password!</h1>");
                    }
                } else {
                    request.setAttribute("errorMessage", "User not found!");
                    request.getRequestDispatcher("login.jsp").forward(request, response);

                    // response.sendRedirect("login.jsp");
                    // response.getWriter().println("<h1>User not found!</h1>");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error during login: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);

            // response.getWriter().println("<h1>Error during login: " + e.getMessage() + "</h1>");
        }
    }
}
