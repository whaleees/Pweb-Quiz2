function showTab(tabId) {
    document.getElementById("tweetsTab").style.display = "none";
    document.getElementById("repliesTab").style.display = "none";
    document.getElementById("likesTab").style.display = "none";
    document.getElementById("retweetsTab").style.display = "none";
    document.getElementById(tabId).style.display = "block";
}

function performSearch(keyword) {
    if (keyword.trim() === "") {
        document.getElementById("searchResults").style.display = "none";
        return;
    }

    fetch('/pweb-quiz2/search?keyword=' + encodeURIComponent(keyword))
        .then(response => {
            if (!response.ok) throw new Error("Network response was not ok");
            return response.json();
        })
        .then(result => {
            console.log("Search Result:", result);
            const resultsContainer = document.getElementById("searchResults");
            resultsContainer.innerHTML = "";

            if (result.tweets.length === 0 && result.users.length === 0) {
                resultsContainer.innerHTML = "<div>No results found.</div>";
            } else {
                if (result.tweets.length > 0) {
                    const tweetHeading = document.createElement("h3");
                    tweetHeading.textContent = "Tweets:";
                    resultsContainer.appendChild(tweetHeading);

                    result.tweets.forEach(tweet => {
                        const tweetDiv = document.createElement("div");
                        tweetDiv.innerHTML = `<strong>@${tweet.username}</strong>: ${tweet.content}`;
                        resultsContainer.appendChild(tweetDiv);
                    });
                }

                if (result.users.length > 0) {
                    const userHeading = document.createElement("h3");
                    userHeading.textContent = "Users:";
                    resultsContainer.appendChild(userHeading);

                    result.users.forEach(user => {
                        const userDiv = document.createElement("div");
                        userDiv.innerHTML = `<strong>@${user.username}</strong>`;
                        resultsContainer.appendChild(userDiv);
                    });
                }
            }

            resultsContainer.style.display = "block";
        })
        .catch(error => {
            console.error("Error fetching search results:", error);
            alert("Something went wrong. Please try again.");
        });
}

function toggleEditForm(tweetId){
    const editForm = document.getElementById(`editForm_${tweetId}`);
    editForm.style.display = editForm.style.display === 'none' ? 'block' : 'none';
}

function submitEdit(button) {
    const tweetId = button.getAttribute("data-id");
    const content = document.getElementById(`editContent_${tweetId}`).value;

    if (!content.trim()) {
        alert("Content cannot be empty.");
        return;
    }

    console.log("Tweet ID:", tweetId);
    console.log("Content:", content); 

    fetch(`/pweb-quiz2/createTweet`, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
            id: tweetId,
            content: content,
        }),
    })
    .then(response => {
        if (!response.ok) {
            throw new Error("Failed to update tweet");
        }
        return response.json();
    })
    .then(result => {
        if (result.success) {
            document.getElementById(`tweetContent_${tweetId}`).textContent = content;
            alert("Tweet updated successfully!");
            document.getElementById(`editForm_${tweetId}`).style.display = 'none';
        } else {
            alert(result.error || "Failed to update tweet.");
        }
    })
    .catch(error => {
        console.error("Error updating tweet:", error);
        alert("Something went wrong. Please try again.");
    });
}



function deleteTweet(button) {
    const tweetId = button.getAttribute("data-id");

    if (!confirm("Are you sure you want to delete this tweet?")) {
        return;
    }

    fetch('/pweb-quiz2/createTweet', {
        method: 'DELETE',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
            id: tweetId,
        }),
    })
        .then(response => {
            console.log(tweetId);
            if (response.ok) {
                alert("Tweet deleted successfully!");
                document.getElementById(`tweet_${tweetId}`).remove();
            } else {
                alert("Failed to delete tweet.");
            }
        })
        .catch(error => console.error("Error:", error));
}


