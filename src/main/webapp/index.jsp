<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, quiz2.utils.DBConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CROD</title>
    <link rel="stylesheet" href="/pweb-quiz2/css/styles.css">
    <script defer src="/pweb-quiz2/js/script.js"></script>
</head>
<body>
    <header>
        <nav>
            <ul>
                <li><a href="/pweb-quiz2/">Home</a></li>
                <li><a href="/pweb-quiz2/profile.jsp">Profile</a></li>
                <li><a href="/pweb-quiz2/logout">Logout</a></li>
            </ul>
        </nav>
        <h1>CROD</h1>
    </header>
    <main>
        <h3>Create a Tweet</h3>
        <form id="createTweetForm" action="/pweb-quiz2/createTweet" method="post" enctype="multipart/form-data">
            <textarea name="content" rows="3" placeholder="What's happening?" required></textarea>
            <input type="file" name="image" accept="image/*">
            <div id="imagePreviewContainer" style="display: none;">
                <p>Image Preview:</p>
                <img id="imagePreview" src="" alt="Preview" style="max-width: 100%; height: auto;">
            </div>
            <button type="submit">Tweet</button>
        </form>

        <div id="tweetsContainer">
            <h3>All Tweets</h3>
            <%
                try (Connection conn = DBConnection.getConnection();
                     PreparedStatement ps = conn.prepareStatement(
                        "SELECT t.id, t.content, u.username, t.created_at, " +
                        "(SELECT COUNT(*) FROM likes WHERE likes.tweet_id = t.id) AS like_count, " +
                        "(SELECT COUNT(*) FROM replies WHERE replies.tweet_id = t.id) AS reply_count, " +
                        "(SELECT COUNT(*) FROM retweets WHERE retweets.tweet_id = t.id) AS retweet_count, " +
                        "t.image_path " + // Correctly concatenate this line
                        "FROM tweets t JOIN users u ON t.user_id = u.id ORDER BY t.created_at DESC"
                        )) {
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            int tweetId = rs.getInt("id");
                            String username = rs.getString("username");
                            String content = rs.getString("content");
                            String createdAt = rs.getString("created_at");
                            int likeCount = rs.getInt("like_count");
                            int replyCount = rs.getInt("reply_count");
                            int retweetCount = rs.getInt("retweet_count");
                            String imagePath = rs.getString("image_path");

            %>
                            <div class="tweet" id="tweet_<%= tweetId %>">
                                <h4>@<%= username %></h4>
                                <p><%= content %></p>
                                <% if (imagePath != null && !imagePath.isEmpty()) { %>
                                    <img src="/pweb-quiz2/<%= imagePath %>" alt="Tweet image" style="max-width: 100%; height: auto;">
                                <% } %>
                                <small>Posted at: <%= createdAt %></small>
                                <div class="actions">
                                    <button onclick="likeTweet('<%= tweetId %>')">Like (<span id="likeCount_<%= tweetId %>"><%= likeCount %></span>)</button>
                                    <button onclick="toggleReplyForm('<%= tweetId %>')">Reply (<span id="replyCount_<%= tweetId %>"><%= replyCount %></span>)</button>
                                    <button id="retweetButton_<%= tweetId %>" onclick="retweet('<%= tweetId %>')">Retweet (<span id="retweetCount_<%= tweetId %>"><%= retweetCount %></span>)</button>
                                </div>
                                <div id="replyForm_<%= tweetId %>" class="reply-form" style="display: none;">
                                    <textarea id="replyContent_<%= tweetId %>" rows="2" placeholder="Write a reply..." required></textarea>
                                    <button onclick="submitReply('<%= tweetId %>')">Submit</button>
                                    <button onclick="toggleReplyForm('<%= tweetId %>')">Cancel</button>
                                </div>
                            </div>
            <%
                        }
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                    out.println("<p>Error fetching tweets: " + e.getMessage() + "</p>");
                }
            %>
        </div>
        
        
    </main>
</body>
</html>
