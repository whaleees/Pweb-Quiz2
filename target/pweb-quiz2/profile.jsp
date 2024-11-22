<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.ArrayList, java.util.List, java.util.Map, java.util.HashMap, quiz2.utils.DBConnection" %>
<%
    String email = (String) session.getAttribute("email");
    if (email == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String username = "";
    int tweetCount = 0;
    try (Connection conn = DBConnection.getConnection()) {
        // Retrieve username
        try (PreparedStatement ps = conn.prepareStatement("SELECT username FROM users WHERE email = ?")) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    username = rs.getString("username");
                }
            }
        }

        // Count tweets
        try (PreparedStatement ps = conn.prepareStatement(
            "SELECT COUNT(*) AS tweet_count FROM tweets WHERE user_id = (SELECT id FROM users WHERE email = ?)"
        )) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    tweetCount = rs.getInt("tweet_count");
                }
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
            "SELECT id, content, image_path FROM tweets WHERE user_id = (SELECT id FROM users WHERE email = ?)")) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, String> tweet = new HashMap<>();
                    tweet.put("content", rs.getString("content"));
                    tweet.put("image_path", rs.getString("image_path"));
                    tweet.put("id", rs.getString("id"));
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
    <script src="https://cdn.tailwindcss.com"></script>
    <script defer src="js/profile.js"></script>
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
    <header class="bg-[var(--primary)] text-[var(--text-primary)] shadow-lg">
        <div class="container mx-auto flex items-center justify-between py-6 px-8">
            <h1 class="text-4xl font-extrabold">
                <a href="/pweb-quiz2/" class="hover:text-[var(--accent)]">K</a>
            </h1>
            <nav>
                <ul class="flex space-x-12 text-lg font-medium">
                    <li><a href="/pweb-quiz2/" class="hover:text-[var(--accent)]">Home</a></li>
                    <li><a href="/pweb-quiz2/profile.jsp" class="hover:text-[var(--accent)]">Profile</a></li>
                    <li><a href="/pweb-quiz2/logout" class="hover:text-[var(--accent)]">Logout</a></li>
                </ul>
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
        <section class="bg-[var(--secondary)] shadow-md rounded-lg p-8 mb-8 text-center">
            <h2 class="text-3xl font-bold text-[var(--accent)] mb-4"><%= username %></h2>
            <h2 class="text-lg text-[var(--text-secondary)] mb-4"><%= email %></h2>
            <div class="flex justify-center mt-4 space-x-8">
                <div>
                    <p class="text-2xl font-bold text-[var(--accent)]"><%= tweetCount %></p>
                    <p class="text-[var(--text-secondary)]">Tweets</p>
                </div>
            </div>
        </section>

        <nav class="flex justify-center space-x-4 mb-6">
            <button onclick="showTab('tweetsTab')" class="px-4 py-2 rounded-lg bg-[var(--button-bg)] text-[var(--text-primary)] hover:bg-[var(--button-hover-bg)]">Tweets</button>
            <button onclick="showTab('repliesTab')" class="px-4 py-2 rounded-lg bg-[var(--button-bg)] text-[var(--text-primary)] hover:bg-[var(--button-hover-bg)]">Replies</button>
            <button onclick="showTab('likesTab')" class="px-4 py-2 rounded-lg bg-[var(--button-bg)] text-[var(--text-primary)] hover:bg-[var(--button-hover-bg)]">Likes</button>
            <button onclick="showTab('retweetsTab')" class="px-4 py-2 rounded-lg bg-[var(--button-bg)] text-[var(--text-primary)] hover:bg-[var(--button-hover-bg)]">Retweets</button>
        </nav>

        <section id="tweetsTab">
            <h2 class="text-xl font-bold mb-4 text-[var(--accent)]">Your Tweets</h2>
            <% for (Map<String, String> tweet : tweets) { %>
                <div id="tweet_<%= tweet.get("id") %>" class="bg-[var(--secondary)] shadow p-6 rounded-lg mb-4">
                    <p id="tweetContent_<%= tweet.get("id") %>" class="text-[var(--text-primary)]">
                        <%= tweet.get("content") %>
                    </p>
        
                    <% if (tweet.get("image_path") != null) { %>
                        <img
                            src="/pweb-quiz2/<%= tweet.get("image_path") %>"
                            alt="Tweet image"
                            class="mt-4 rounded-lg shadow max-w-full"
                        />
                    <% } %>
                        
                    <div class="flex items-center space-x-4 mt-4">
                        <form action="/pweb-quiz2/createTweet" method="POST" onsubmit="return confirm('Are you sure you want to delete this tweet?')">
                            <input type="hidden" name="_method" value="DELETE" /> 
                            <input type="hidden" name="id" value="<%= tweet.get("id") %>" />
                            <button
                                type="submit"
                                class="mt-4 px-6 py-2 rounded-lg bg-[var(--button-bg)] text-[var(--text-primary)] hover:bg-[var(--button-hover-bg)] hover:text-[var(--text-secondary)] border border-[var(--accent)] transition duration-200"
                            >
                                Delete
                            </button>
                        </form>
                        
                        <button 
                            class="mt-4 px-6 py-2 rounded-lg bg-[var(--button-bg)] text-[var(--text-primary)] hover:bg-[var(--button-hover-bg)] hover:text-[var(--text-secondary)] border border-[var(--accent)] transition duration-200" 
                            onclick="toggleEditForm('<%= tweet.get("id") %>')"
                        >
                        Edit
                        </button>
                    </div>

                    <form 
                        action="/pweb-quiz2/createTweet" 
                        method="POST" 
                        id="editForm_<%= tweet.get("id") %>" 
                        class="bg-[var(--secondary)] shadow-lg rounded-lg p-6" 
                        style="display: none;"
                    >
                    <input type="hidden" name="_method" value="PUT" /> 
                    <input type="hidden" name="id" value="<%= tweet.get("id") %>" />

                    <textarea
                        name="content"
                        id="editContent_<%= tweet.get("id") %>"
                        class="w-full px-4 py-2 border border-[var(--accent)] rounded-lg mt-4"
                        required
                    ><%= tweet.get("content") %></textarea>
                    <div class="mt-3 flex justify-end">
                        <button
                            type="submit"
                            class="px-6 py-2 rounded-lg bg-[var(--button-bg)] text-[var(--text-primary)] hover:bg-[var(--button-hover-bg)] hover:text-[var(--text-secondary)] border border-[var(--accent)] transition duration-200"
                        >
                            Save
                        </button>
                    </div>
                    </form>
                </div>
            <% } %>
        
            <% if (tweets.isEmpty()) { %>
                <p class="text-[var(--text-secondary)] text-center">No tweets yet.</p>
            <% } %>
        </section>
        
               

        <section id="repliesTab" style="display: none;">
            <h2 class="text-xl font-bold mb-4 text-[var(--accent)]">Your Replies</h2>
            <% for (Map<String, String> reply : replies) { %>
                <div class="bg-[var(--secondary)] shadow p-6 rounded-lg mb-4">
                    <p class="text-[var(--text-primary)]"><%= reply.get("content") %></p>
                    <% if (reply.get("image_path") != null) { %>
                        <img    
                            src="/pweb-quiz2/<%= reply.get("image_path") %>" 
                            alt="Tweet image" 
                            class="mt-4 rounded shadow max-w-full"
                        />
                    <% } %>
                </div>
            <% } %>
            <% if (replies.isEmpty()) { %>
                <p class="text-[var(--text-secondary)] text-center">No replies yet.</p>
            <% } %>
        </section>

        <section id="likesTab" style="display: none;">
            <h2 class="text-xl font-bold mb-4 text-[var(--accent)]">Your Liked Tweets</h2>
            <% for (Map<String, String> like : likes) { %>
                <div class="bg-[var(--secondary)] shadow p-6 rounded-lg mb-4">
                    <p class="text-[var(--text-primary)]">
                        <%= like.get("content") %> by 
                        <span class="font-bold">@<%= like.get("username") %></span> 
                        <small class="text-gray-500">(Posted at: <%= like.get("created_at") %>)</small>
                    </p>
                    <% if (like.get("image_path") != null) { %>
                        <img 
                            src="/pweb-quiz2/<%= like.get("image_path") %>" 
                            alt="Tweet image" 
                            class="mt-4 rounded shadow max-w-full"
                        />
                    <% } %>
                </div>
            <% } %>
            <% if (likes.isEmpty()) { %>
                <p class="text-[var(--text-secondary)] text-center">No liked tweets yet.</p>
            <% } %>
        </section>

        <section id="retweetsTab" style="display: none;">
            <h2 class="text-xl font-bold mb-4 text-[var(--accent)]">Your Retweets</h2>
            <% for (Map<String, String> retweet : retweets) { %>
                <div class="bg-[var(--secondary)] shadow p-6 rounded-lg mb-4">
                    <p class="text-[var(--text-primary)]">
                        <%= retweet.get("content") %> by 
                        <span class="font-bold">@<%= retweet.get("username") %></span> 
                        <small class="text-gray-500">(Posted at: <%= retweet.get("created_at") %>)</small>
                    </p>
                    <% if (retweet.get("image_path") != null) { %>
                        <img 
                            src="/pweb-quiz2/<%= retweet.get("image_path") %>" 
                            alt="Tweet image" 
                            class="mt-4 rounded shadow max-w-full"
                        />
                    <% } %>
                </div>
            <% } %>
            <% if (retweets.isEmpty()) { %>
                <p class="text-[var(--text-secondary)] text-center">No retweets yet.</p>
            <% } %>
        </section>
    </main>
</body>
</html>



