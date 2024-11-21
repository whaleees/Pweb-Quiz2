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

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class TweetsServlet extends HttpServlet {
    private static final String UPLOAD_DIR = "uploads";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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
                filePart.write(imageFile.getAbsolutePath()); // Save the file to the directory
                imagePath = UPLOAD_DIR + "/" + fileName; // Store the relative path
            }

            // Insert tweet into database
            try (Connection conn = DBConnection.getConnection()) {
                int userId;

                // Get user ID
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

                // Insert tweet into the database
                String insertTweet = "INSERT INTO tweets (user_id, content, image_path) VALUES (?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(insertTweet)) {
                    ps.setInt(1, userId);
                    ps.setString(2, content);
                    ps.setString(3, imagePath);
                    ps.executeUpdate();
                }
            }

            // Redirect to home page
            response.sendRedirect("index.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("<h1>Error creating tweet: " + e.getMessage() + "</h1>");
        }
    }
}
