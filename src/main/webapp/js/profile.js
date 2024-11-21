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