<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.ArrayList, java.util.List, quiz2.utils.DBConnection" %>
<%
    // Check if the user is logged in
    String email = (String) session.getAttribute("email");
    if (email == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Fetch user details from the database
    String username = "";
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement("SELECT username FROM users WHERE email = ?")) {
        ps.setString(1, email);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                username = rs.getString("username");
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }

    // Fetch tweets, replies, and likes
    List<String> tweets = new ArrayList<>();
    List<String> replies = new ArrayList<>();
    List<String> likes = new ArrayList<>();
    List<String> retweets = new ArrayList<>();
    try (Connection conn = DBConnection.getConnection()) {
        // Fetch user tweets
        try (PreparedStatement ps = conn.prepareStatement("SELECT content FROM tweets WHERE user_id = (SELECT id FROM users WHERE email = ?)")) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    tweets.add(rs.getString("content"));
                }
            }
        }

        try (PreparedStatement ps = conn.prepareStatement(
            "SELECT r.content AS reply_content, t.content AS tweet_content, u.username AS tweet_author " +
            "FROM replies r " +
            "JOIN tweets t ON r.tweet_id = t.id " +
            "JOIN users u ON t.user_id = u.id " +
            "WHERE r.user_id = (SELECT id FROM users WHERE email = ?)")) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String replyContent = rs.getString("reply_content");
                    String tweetContent = rs.getString("tweet_content");
                    String tweetAuthor = rs.getString("tweet_author");
        
                    replies.add("Replied to \"" + tweetContent + "\" by @" + tweetAuthor + ": " + replyContent);
                }
            }
        }
        

        try (PreparedStatement ps = conn.prepareStatement(
            "SELECT t.content, u.username, t.created_at " +
            "FROM likes l " +
            "JOIN tweets t ON l.tweet_id = t.id " +
            "JOIN users u ON t.user_id = u.id " +
            "WHERE l.user_id = (SELECT id FROM users WHERE email = ?)")) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String likeContent = rs.getString("content");
                    String likeAuthor = rs.getString("username");
                    String likeCreatedAt = rs.getString("created_at");

                    likes.add(likeContent + " by @" + likeAuthor + " (Posted at: " + likeCreatedAt + ")");
                }
            }
        }

        try (PreparedStatement ps = conn.prepareStatement(
            "SELECT t.content, u.username, t.created_at " +
            "FROM retweets r " +
            "JOIN tweets t ON r.tweet_id = t.id " +
            "JOIN users u ON t.user_id = u.id " +
            "WHERE r.user_id = (SELECT id FROM users WHERE email = ?)")) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String retweetContent = rs.getString("content");
                    String retweetAuthor = rs.getString("username");
                    String retweetCreatedAt = rs.getString("created_at");

                    retweets.add(retweetContent + " by @" + retweetAuthor + " (Posted at: " + retweetCreatedAt + ")");
                }
            }
        }

    } catch (SQLException e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile</title>
    <link rel="stylesheet" href="css/profile.css">
    <script>
        function showTab(tabId) {
            document.getElementById("tweetsTab").style.display = "none";
            document.getElementById("repliesTab").style.display = "none";
            document.getElementById("likesTab").style.display = "none";
            document.getElementById("retweetsTab").style.display = "none";

            document.getElementById(tabId).style.display = "block";
        }
    </script>
</head>
<body>
    <header>
        <h1>Welcome, <%= username %>!</h1>
        <nav>
            <ul>
                <li><a href="/pweb-quiz2/">Home</a></li>
                <li><a href="/pweb-quiz2/profile.jsp">Profile</a></li>
                <li><a href="/pweb-quiz2/logout">Logout</a></li>
            </ul>
        </nav>
    </header>
    <main>
        <nav>
            <button onclick="showTab('tweetsTab')">Tweets</button>
            <button onclick="showTab('retweetsTab')">Retweets</button>
            <button onclick="showTab('repliesTab')">Replies</button>
            <button onclick="showTab('likesTab')">Likes</button>
        </nav>

        <section id="tweetsTab">
            <h2>Your Tweets</h2>
            <% for (String tweet : tweets) { %>
                <div class="tweet">
                    <p><%= tweet %></p>
                </div>
            <% } %>
            <% if (tweets.isEmpty()) { %>
                <p>No tweets yet.</p>
            <% } %>
        </section>


        <section id="repliesTab" style="display: none;">
            <h2>Your Replies</h2>
            <% for (String reply : replies) { %>
                <div class="reply">
                    <p><%= reply %></p>
                </div>
            <% } %>
            <% if (replies.isEmpty()) { %>
                <p>No replies yet.</p>
            <% } %>
        </section>

        <section id="likesTab" style="display: none;">
            <h2>Your Liked Tweets</h2>
            <% for (String like : likes) { %>
                <div class="like">
                    <p><%= like %></p>
                </div>
            <% } %>
            <% if (likes.isEmpty()) { %>
                <p>No liked tweets yet.</p>
            <% } %>
        </section>

        <section id="retweetsTab" style="display: none;">
            <h2>Your Retweets</h2>
            <% for (String retweet : retweets) { %>
                <div class="retweet">
                    <p><%= retweet %></p>
                </div>
            <% } %>
            <% if (retweets.isEmpty()) { %>
                <p>No retweets yet.</p>
            <% } %>
        </section>
    </main>
</body>
</html>
