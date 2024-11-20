<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, quiz2.utils.DBConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CROD</title>
    <link rel="stylesheet" href="css/styles.css">
    <script defer src="js/scripts.js"></script>
</head>
<body>
    <header>
        <nav>
            <ul>
                <li><a href="/pweb-quiz2/">Home</a></li>
                <li><a href="/pweb-quiz2/profile.jsp">Profile</a></li>
                <li><a href="/logout">Logout</a></li>
            </ul>
        </nav>
        <h1>CROD</h1>
    </header>
    <main>
        <!-- Create Tweet Form -->
        <h3>Create a Tweet</h3>
        <form id="createTweetForm" action="/pweb-quiz2/createTweet" method="post">
            <textarea name="content" rows="3" placeholder="What's happening?" required></textarea>
            <button type="submit">Tweet</button>
        </form>

        <div id="tweetsContainer">
            <h3>All Tweets</h3>
            <%
                try (Connection conn = DBConnection.getConnection();
                     PreparedStatement ps = conn.prepareStatement(
                             "SELECT t.content, u.username, t.created_at " +
                             "FROM tweets t JOIN users u ON t.user_id = u.id ORDER BY t.created_at DESC")) {
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            String username = rs.getString("username");
                            String content = rs.getString("content");
                            String createdAt = rs.getString("created_at");
            %>
                            <div class="tweet">
                                <h4>@<%= username %></h4>
                                <p><%= content %></p>
                                <small>Posted at: <%= createdAt %></small>
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
    <script>
        // Example JavaScript for client-side functionality
        function editTweet(tweetId) {
            // Show edit form
            const editForm = document.getElementById("editTweetFormContainer");
            editForm.style.display = "block";

            // Populate form with tweet data (you would fetch this from the server in a real app)
            document.getElementById("tweetId").value = tweetId;
            editForm.querySelector("textarea").value = "This is an example tweet. It can be edited.";
        }

        function deleteTweet(tweetId) {
            // Confirm and send delete request (you would call the server here)
            if (confirm("Are you sure you want to delete this tweet?")) {
                alert("Tweet " + tweetId + " deleted!");
                // Remove tweet from UI or refresh the page
            }
        }

        function cancelEdit() {
            // Hide edit form
            const editForm = document.getElementById("editTweetFormContainer");
            editForm.style.display = "none";
        }
    </script>
</body>
</html>
