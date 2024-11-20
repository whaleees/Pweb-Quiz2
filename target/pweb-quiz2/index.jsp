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
                <li><a href="/profile">Profile</a></li>
                <li><a href="/logout">Logout</a></li>
            </ul>
        </nav>
        <h1>CROD</h1>
    </header>
    <main>
        <!-- Create Tweet Form -->
        <h3>Create a Tweet</h3>
        <form id="createTweetForm" action="/createTweet" method="post">
            <textarea name="content" rows="3" placeholder="What's happening?" required></textarea>
            <button type="submit">Tweet</button>
        </form>

        <!-- Tweets Section -->
        <h3>All Tweets</h3>
        <div id="tweetsContainer">
            <!-- Example Tweet -->
            <div class="tweet">
                <h4>@username</h4>
                <p>This is an example tweet. It can be edited or deleted.</p>
                <button class="edit" onclick="editTweet(1)">Edit</button>
                <button class="delete" onclick="deleteTweet(1)">Delete</button>
            </div>
        </div>

        <!-- Edit Tweet Form (hidden by default) -->
        <div id="editTweetFormContainer" style="display: none;">
            <h3>Edit Tweet</h3>
            <form id="editTweetForm" action="/editTweet" method="post">
                <textarea name="content" rows="3" required></textarea>
                <input type="hidden" name="tweetId" id="tweetId">
                <button type="submit">Save Changes</button>
                <button type="button" onclick="cancelEdit()">Cancel</button>
            </form>
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
