package quiz2.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import quiz2.utils.DBConnection;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.json.JSONArray;
import org.json.JSONObject;

public class SearchServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        if (keyword == null || keyword.trim().isEmpty()) {
            response.setContentType("application/json");
            response.getWriter().write("{\"tweets\":[], \"users\":[]}");
            return;
        }

        keyword = "%" + keyword.trim() + "%";
        JSONArray tweetArray = new JSONArray();
        JSONArray userArray = new JSONArray();

        try (Connection conn = DBConnection.getConnection()) {
            // Fetch tweets
            String tweetQuery = "SELECT t.content, u.username FROM tweets t JOIN users u ON t.user_id = u.id WHERE t.content LIKE ?";
            try (PreparedStatement ps = conn.prepareStatement(tweetQuery)) {
                ps.setString(1, keyword);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        JSONObject tweet = new JSONObject();
                        tweet.put("content", rs.getString("content"));
                        tweet.put("username", rs.getString("username"));
                        tweetArray.put(tweet);
                    }
                }
            }

            // Fetch users
            String userQuery = "SELECT username FROM users WHERE username LIKE ?";
            try (PreparedStatement ps = conn.prepareStatement(userQuery)) {
                ps.setString(1, keyword);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        JSONObject user = new JSONObject();
                        user.put("username", rs.getString("username"));
                        userArray.put(user);
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        JSONObject result = new JSONObject();
        result.put("tweets", tweetArray);
        result.put("users", userArray);

        response.setContentType("application/json");
        response.getWriter().write(result.toString());
    }
}