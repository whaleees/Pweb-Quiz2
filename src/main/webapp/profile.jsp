<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.ArrayList, java.util.List, java.util.Map, java.util.HashMap, quiz2.utils.DBConnection" %>
<%
    String email = (String) session.getAttribute("email");
    if (email == null) {
        response.sendRedirect("login.jsp");
        return;
    }

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

    List<Map<String, String>> tweets = new ArrayList<>();
    List<Map<String, String>> replies = new ArrayList<>();
    List<Map<String, String>> likes = new ArrayList<>();
    List<Map<String, String>> retweets = new ArrayList<>();

    try (Connection conn = DBConnection.getConnection()) {
        try (PreparedStatement ps = conn.prepareStatement(
            "SELECT content, image_path FROM tweets WHERE user_id = (SELECT id FROM users WHERE email = ?)")) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> tweet = new HashMap<>();
                    tweet.put("content", rs.getString("content"));
                    tweet.put("image_path", rs.getString("image_path"));
                    tweets.add(tweet);
                }
            }
        }

        try (PreparedStatement ps = conn.prepareStatement(
            "SELECT r.content AS reply_content, t.content AS tweet_content, u.username AS tweet_author, t.image_path " +
            "FROM replies r " +
            "JOIN tweets t ON r.tweet_id = t.id " +
            "JOIN users u ON t.user_id = u.id " +
            "WHERE r.user_id = (SELECT id FROM users WHERE email = ?)")) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> reply = new HashMap<>();
                    reply.put("reply_content", rs.getString("reply_content"));
                    reply.put("tweet_content", rs.getString("tweet_content"));
                    reply.put("tweet_author", rs.getString("tweet_author"));
                    reply.put("image_path", rs.getString("image_path"));
                    replies.add(reply);
                }
            }
        }

        try (PreparedStatement ps = conn.prepareStatement(
            "SELECT t.content, u.username, t.created_at, t.image_path " +
            "FROM likes l " +
            "JOIN tweets t ON l.tweet_id = t.id " +
            "JOIN users u ON t.user_id = u.id " +
            "WHERE l.user_id = (SELECT id FROM users WHERE email = ?)")) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> like = new HashMap<>();
                    like.put("content", rs.getString("content"));
                    like.put("username", rs.getString("username"));
                    like.put("created_at", rs.getString("created_at"));
                    like.put("image_path", rs.getString("image_path"));
                    likes.add(like);
                }
            }
        }

        try (PreparedStatement ps = conn.prepareStatement(
            "SELECT t.content, u.username, t.created_at, t.image_path " +
            "FROM retweets r " +
            "JOIN tweets t ON r.tweet_id = t.id " +
            "JOIN users u ON t.user_id = u.id " +
            "WHERE r.user_id = (SELECT id FROM users WHERE email = ?)")) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> retweet = new HashMap<>();
                    retweet.put("content", rs.getString("content"));
                    retweet.put("username", rs.getString("username"));
                    retweet.put("created_at", rs.getString("created_at"));
                    retweet.put("image_path", rs.getString("image_path"));
                    retweets.add(retweet);
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
            <button onclick="showTab('repliesTab')">Replies</button>
            <button onclick="showTab('likesTab')">Likes</button>
            <button onclick="showTab('retweetsTab')">Retweets</button>
        </nav>

        <section id="tweetsTab">
            <h2>Your Tweets</h2>
            <% for (Map<String, String> tweet : tweets) { %>
                <div class="tweet">
                    <p><%= tweet.get("content") %></p>
                    <% if (tweet.get("image_path") != null) { %>
                        <img src="/pweb-quiz2/<%= tweet.get("image_path") %>" alt="Tweet image" style="max-width: 100%; height: auto;">
                    <% } %>
                </div>
            <% } %>
            <% if (tweets.isEmpty()) { %>
                <p>No tweets yet.</p>
            <% } %>
        </section>

        <section id="repliesTab" style="display: none;">
            <h2>Your Replies</h2>
            <% for (Map<String, String> reply : replies) { %>
                <div class="reply">
                    <p>Replied to "<%= reply.get("tweet_content") %>" by @<%= reply.get("tweet_author") %>: <%= reply.get("reply_content") %></p>
                    <% if (reply.get("image_path") != null) { %>
                        <img src="/pweb-quiz2/<%= reply.get("image_path") %>" alt="Tweet image" style="max-width: 100%; height: auto;">
                    <% } %>
                </div>
            <% } %>
            <% if (replies.isEmpty()) { %>
                <p>No replies yet.</p>
            <% } %>
        </section>

        <section id="likesTab" style="display: none;">
            <h2>Your Liked Tweets</h2>
            <% for (Map<String, String> like : likes) { %>
                <div class="like">
                    <p><%= like.get("content") %> by @<%= like.get("username") %> (Posted at: <%= like.get("created_at") %>)</p>
                    <% if (like.get("image_path") != null) { %>
                        <img src="/pweb-quiz2/<%= like.get("image_path") %>" alt="Tweet image" style="max-width: 100%; height: auto;">
                    <% } %>
                </div>
            <% } %>
            <% if (likes.isEmpty()) { %>
                <p>No liked tweets yet.</p>
            <% } %>
        </section>

        <section id="retweetsTab" style="display: none;">
            <h2>Your Retweets</h2>
            <% for (Map<String, String> retweet : retweets) { %>
                <div class="retweet">
                    <p><%= retweet.get("content") %> by @<%= retweet.get("username") %> (Posted at: <%= retweet.get("created_at") %>)</p>
                    <% if (retweet.get("image_path") != null) { %>
                        <img src="/pweb-quiz2/<%= retweet.get("image_path") %>" alt="Tweet image" style="max-width: 100%; height: auto;">
                    <% } %>
                </div>
            <% } %>
            <% if (retweets.isEmpty()) { %>
                <p>No retweets yet.</p>
            <% } %>
        </section>
    </main>
</body>
</html>
