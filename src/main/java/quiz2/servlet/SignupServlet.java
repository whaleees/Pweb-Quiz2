package quiz2.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import quiz2.utils.DBConnection;
import org.mindrot.jbcrypt.BCrypt;

public class SignupServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String email = request.getParameter("email");

        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "INSERT INTO users (username, password, email) VALUES (?, ?, ?)")) {
            ps.setString(1, username);
            ps.setString(2, hashedPassword); 
            ps.setString(3, email);
            ps.executeUpdate();
            response.sendRedirect("login.jsp");

            // response.getWriter().println("<h1>User registered successfully!</h1>");
        } catch (SQLException e) {
            e.printStackTrace();
            response.getWriter().println("<h1>Error during sign-up: " + e.getMessage() + "</h1>");
        }
    }
}
