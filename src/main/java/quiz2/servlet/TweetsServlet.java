package quiz2.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import quiz2.utils.DBConnection;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class TweetsServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("email") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String content = request.getParameter("content");
        String email = (String) session.getAttribute("email");

        try (Connection conn = DBConnection.getConnection()) {
            int userId;
            try (PreparedStatement ps = conn.prepareStatement("SELECT id FROM users WHERE email = ?")) {
                ps.setString(1, email);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        userId = rs.getInt("id");
                    } else {
                        response.getWriter().println("User not found!");
                        return;
                    }
                }
            }

            String insertTweet = "INSERT INTO tweets (user_id, content) VALUES (?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(insertTweet)) {
                ps.setInt(1, userId);
                ps.setString(2, content);
                ps.executeUpdate();
            }

            response.sendRedirect("index.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("<h1>Error creating tweet: " + e.getMessage() + "</h1>");
        }
    }
}
