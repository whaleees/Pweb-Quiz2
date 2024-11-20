package quiz2.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import quiz2.utils.DBConnection;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class ReplyServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        try {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("email") == null) {
                out.println("{\"success\": false, \"error\": \"Unauthorized\"}");
                return;
            }

            String email = (String) session.getAttribute("email");

            String tweetIdParam = request.getParameter("tweetId");
            String content = request.getParameter("content");

            if (tweetIdParam == null || content == null || content.trim().isEmpty()) {
                out.println("{\"success\": false, \"error\": \"Invalid input\"}");
                return;
            }

            int tweetId = Integer.parseInt(tweetIdParam);

            try (Connection conn = DBConnection.getConnection()) {
                int userId = getUserIdByEmail(email, conn);

                String query = "INSERT INTO replies (user_id, tweet_id, content) VALUES (?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setInt(1, userId);
                    ps.setInt(2, tweetId);
                    ps.setString(3, content);
                    ps.executeUpdate();
                }
            }

            out.println("{\"success\": true}");
        } catch (Exception e) {
            e.printStackTrace();
            out.println("{\"success\": false, \"error\": \"" + e.getMessage() + "\"}");
        }
    }

    private int getUserIdByEmail(String email, Connection conn) throws Exception {
        String query = "SELECT id FROM users WHERE email = ?";
        try (PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, email);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id");
                } else {
                    throw new Exception("User not found for email: " + email);
                }
            }
        }
    }
}
