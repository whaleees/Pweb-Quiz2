package quiz2.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import jakarta.servlet.annotation.MultipartConfig;
import quiz2.utils.DBConnection;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, 
    maxFileSize = 1024 * 1024 * 10,      
    maxRequestSize = 1024 * 1024 * 50    
)
public class TweetsServlet extends HttpServlet {
    private static final String UPLOAD_DIR = "uploads";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String methodOverride = request.getParameter("_method");
    
        if ("PUT".equalsIgnoreCase(methodOverride)) {
            doPut(request, response);
            return;
        }
    
        if ("DELETE".equalsIgnoreCase(methodOverride)) {
            doDelete(request, response);
            return;
        }
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("email") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String content = request.getParameter("content");
        String email = (String) session.getAttribute("email");

        if (content == null || content.trim().isEmpty()) {
            response.getWriter().println("<h1>Error: Content cannot be empty!</h1>");
            return;
        }

        String imagePath = null;

        try {
            Part filePart = request.getPart("image"); 
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = System.currentTimeMillis() + "_" + filePart.getSubmittedFileName(); 
                String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
    
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdir(); 
                }
    
                File imageFile = new File(uploadDir, fileName);
                filePart.write(imageFile.getAbsolutePath()); 
                imagePath = UPLOAD_DIR + "/" + fileName; 
            }

            try (Connection conn = DBConnection.getConnection()) {
                int userId;

                try (PreparedStatement ps = conn.prepareStatement("SELECT id FROM users WHERE email = ?")) {
                    ps.setString(1, email);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            userId = rs.getInt("id");
                        } else {
                            response.getWriter().println("<h1>Error: User not found!</h1>");
                            return;
                        }
                    }
                }

                String insertTweet = "INSERT INTO tweets (user_id, content, image_path) VALUES (?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(insertTweet)) {
                    ps.setInt(1, userId);
                    ps.setString(2, content);
                    ps.setString(3, imagePath);
                    ps.executeUpdate();
                }
            }

            response.sendRedirect("index.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("<h1>Error creating tweet: " + e.getMessage() + "</h1>");
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String tweetId = request.getParameter("id");
        String content = request.getParameter("content");
    
        if (tweetId == null || content == null || content.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().println("{\"success\": false, \"error\": \"Invalid tweet ID or content.\"}");
            return;
        }
    
        try (Connection conn = DBConnection.getConnection()) {
            String updateQuery = "UPDATE tweets SET content = ? WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateQuery)) {
                ps.setString(1, content);
                ps.setInt(2, Integer.parseInt(tweetId));
    
                int rowsUpdated = ps.executeUpdate();
                if (rowsUpdated > 0) {
                    response.setStatus(HttpServletResponse.SC_OK);
                    response.sendRedirect("/pweb-quiz2/profile.jsp");
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    response.sendRedirect("/pweb-quiz2/profile.jsp");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().println("{\"success\": false, \"error\": \"Database error.\"}");
        }
    }
    
    

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String tweetId = request.getParameter("id");

        if (tweetId == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().println("Invalid tweet ID.");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            String deleteTweet = "DELETE FROM tweets WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(deleteTweet)) {
                ps.setInt(1, Integer.parseInt(tweetId));
                int rowsDeleted = ps.executeUpdate();

                if (rowsDeleted > 0) {
                    response.setStatus(HttpServletResponse.SC_OK);
                    response.sendRedirect("/pweb-quiz2/profile.jsp");
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    response.sendRedirect("/pweb-quiz2/profile.jsp");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().println("{\"success\": false, \"error\": \"Database error.\"}");
        }
    }
}
