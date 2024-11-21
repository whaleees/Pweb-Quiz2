<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, quiz2.utils.DBConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>K Platform</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script defer src="js/script.js"></script>
    <style>
        :root {
            --primary: #D9C8AD; 
            --secondary: #F1EDE4;
            --accent: #8E7C71; 
            --background: #FAF9F7; 
            --text-primary: #3E3D3A; 
            --text-secondary: #5C5B58; 
            --reply-bg: #E9E4D9;
            --button-bg: #D6C5A7;
            --button-text: #5C5B58;
            --button-hover-bg: #C4B395;
        }
    </style>
</head>
<body class="bg-[var(--background)] text-[var(--text-primary)]">

    <header class="bg-[var(--primary)] text-[var(--text-primary)] shadow-md">
        <div class="container mx-auto flex items-center justify-between py-6 px-8">
            <h1 class="text-4xl font-extrabold">
                <a href="/pweb-quiz2/" class="hover:text-[var(--accent)]">K</a>
            </h1>
            <nav class="flex space-x-12 text-lg font-medium">
                <a href="/pweb-quiz2/" class="hover:text-[var(--accent)]">Home</a>
                <a href="/pweb-quiz2/profile.jsp" class="hover:text-[var(--accent)]">Profile</a>
                <a href="/pweb-quiz2/logout" class="hover:text-[var(--accent)]">Logout</a>
            </nav>
            <div class="relative w-64">
                <input
                    type="text"
                    id="searchInput"
                    oninput="performSearch(this.value)"
                    placeholder="Search..."
                    class="w-full px-4 py-2 text-lg rounded-lg border border-[var(--accent)] text-[var(--text-primary)] focus:outline-none focus:ring-4 focus:ring-[var(--accent)]"
                />
                <div
                    id="searchResults"
                    class="absolute bg-white text-gray-800 shadow-md rounded-lg w-full mt-2 z-10 hidden p-4"
                >
                    <div id="tweetsSection">
                        <h3 class="text-[var(--accent)] font-bold">Tweets:</h3>
                        <div id="tweetResults"></div>
                    </div>
                    <div id="usersSection" class="mt-4">
                        <h3 class="text-[var(--accent)] font-bold">Users:</h3>
                        <div id="userResults"></div>
                    </div>
                </div>
            </div>
        </div>
    </header>

    <main class="container mx-auto mt-8 px-6">
        <section class="mb-8">
            <h2 class="text-2xl font-semibold mb-4 text-[var(--accent)]">Create a Tweet</h2>
            <form action="/pweb-quiz2/createTweet" method="post" enctype="multipart/form-data" class="bg-[var(--secondary)] shadow-lg rounded-lg p-6">
                <textarea
                    name="content"
                    rows="3"
                    placeholder="What's happening?"
                    required
                    class="w-full px-4 py-2 border border-[var(--accent)] rounded-lg focus:outline-none focus:ring-2 focus:ring-[var(--primary)]"
                ></textarea>
                <div class="mt-4">
                    <label class="block text-sm font-medium text-[var(--text-primary)] mb-2">Upload an Image</label>
                    <input
                        type="file"
                        name="image"
                        accept="image/*"
                        onchange="previewImage(event)"
                        class="block w-full text-sm text-[var(--text-secondary)] file:mr-4 file:py-2 file:px-4 file:border file:border-[var(--accent)] file:rounded-lg file:bg-[var(--primary)] file:text-[var(--text-primary)] hover:file:bg-[var(--accent)]"
                    />
                    <div id="imagePreviewContainer" style="display: none;">
                        <p>Image Preview:</p>
                        <img id="imagePreview" src="" alt="Preview" style="max-width: 100%; height: auto;">
                    </div>
                </div>
                <button
                    type="submit"
                    class="mt-4 px-6 py-2 rounded-lg bg-[var(--button-bg)] text-[var(--text-primary)] hover:bg-[var(--button-hover-bg)] hover:text-[var(--text-secondary)] border border-[var(--accent)] transition duration-200"
                >
                    Tweet
                </button>
            </form>
        </section>

        <section>
            <h2 class="text-2xl font-semibold mb-4 text-[var(--accent)]">All Tweets</h2>
            <div id="tweetsContainer" class="space-y-6">
                <%
                    boolean hasTweets = false;
                    try (Connection conn = DBConnection.getConnection();
                         PreparedStatement ps = conn.prepareStatement(
                            "SELECT t.id, t.content, u.username, t.created_at, " +
                            "(SELECT COUNT(*) FROM likes WHERE likes.tweet_id = t.id) AS like_count, " +
                            "(SELECT COUNT(*) FROM replies WHERE replies.tweet_id = t.id) AS reply_count, " +
                            "(SELECT COUNT(*) FROM retweets WHERE retweets.tweet_id = t.id) AS retweet_count, " +
                            "t.image_path " +
                            "FROM tweets t JOIN users u ON t.user_id = u.id ORDER BY t.created_at DESC"
                         )) {
                        try (ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) {
                                hasTweets = true;
                                int tweetId = rs.getInt("id");
                                String username = rs.getString("username");
                                String content = rs.getString("content");
                                String createdAt = rs.getString("created_at");
                                int likeCount = rs.getInt("like_count");
                                int replyCount = rs.getInt("reply_count");
                                int retweetCount = rs.getInt("retweet_count");
                                String imagePath = rs.getString("image_path");
                %>
                                <div class="bg-[var(--secondary)] shadow-lg p-6 rounded-lg">
                                    <h3 class="text-lg font-bold text-[var(--accent)]">@<%= username %></h3>
                                    <p class="text-[var(--text-primary)] mt-2"><%= content %></p>
                                    <% if (imagePath != null && !imagePath.isEmpty()) { %>
                                        <img src="/pweb-quiz2/<%= imagePath %>" alt="Tweet image" class="mt-4 rounded-lg shadow max-w-full"/>
                                    <% } %>
                                    <small class="text-[var(--text-secondary)] mt-2 block">Posted at: <%= createdAt %></small>
                                    <div class="flex items-center space-x-4 mt-4">
                                        <button onclick="likeTweet('<%= tweetId %>')" class="flex items-center space-x-2 text-[var(--accent)] hover:text-[var(--primary)]">
                                            <img src="/pweb-quiz2/asset/like.svg" alt="Like" class="w-5 h-5" />
                                            <span>(<span id="likeCount_<%= tweetId %>"><%= likeCount %></span>)</span>
                                        </button>
                                        <button onclick="toggleReplyForm('<%= tweetId %>')" class="flex items-center space-x-2 text-[var(--accent)] hover:text-[var(--primary)]">
                                            <img src="/pweb-quiz2/asset/comment.svg" alt="Reply" class="w-5 h-5" />
                                            <span>(<span id="replyCount_<%= tweetId %>"><%= replyCount %></span>)</span>
                                        </button>
                                        <button onclick="retweet('<%= tweetId %>')" class="flex items-center space-x-2 text-[var(--accent)] hover:text-[var(--primary)]">
                                            <img src="/pweb-quiz2/asset/retweet.svg" alt="Retweet" class="w-5 h-5" />
                                            <span>(<span id="retweetCount_<%= tweetId %>"><%= retweetCount %></span>)</span>
                                        </button>
                                    </div>
                                    <div id="replyForm_<%= tweetId %>" style="display: none;" class="mt-4 bg-[var(--reply-bg)] p-4 rounded shadow">
                                        <textarea
                                            id="replyContent_<%= tweetId %>"
                                            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-accent-400"
                                            rows="2"
                                            placeholder="Write your reply..."
                                        ></textarea>
                                        <div class="mt-3 flex justify-end">
                                            <button id="submitReplyButton_<%= tweetId %>" onclick="submitReply('<%= tweetId %>')" class="px-4 py-2 rounded-lg bg-[var(--accent)] text-white hover:bg-[var(--primary)]">
                                                Submit
                                            </button>
                                        </div>
                                    </div>
                                                                    
                                </div>
                <%
                            }
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }

                    if (!hasTweets) {
                %>
                    <div class="bg-[var(--primary)] text-[var(--text-primary)] text-center p-4 rounded-lg">
                        No tweets available. Be the first to post!
                    </div>
                <%
                    }
                %>
            </div>
        </section>
        
    </main>
</body>
</html>

