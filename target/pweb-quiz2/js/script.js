function likeTweet(tweetId) {
    const formData = new URLSearchParams();
    formData.append('tweetId', tweetId);

    fetch('/pweb-quiz2/likeTweet', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: formData.toString(),
    })
    .then(response => response.json())
    .then(result => {
        if (result.success) {
            const likeCountElement = document.getElementById(`likeCount_${tweetId}`);
            
            if(result.liked){
                likeCountElement.textContent = parseInt(likeCountElement.textContent) + 1;
            }else{
                likeCountElement.textContent = parseInt(likeCountElement.textContent) - 1;
            }
        } else {
            alert(result.error || 'Failed to like the tweet.');
        }
    })
    .catch(error => {
        console.error('Error liking tweet:', error);
        alert('Something went wrong. Please try again.');
    });
}

function toggleReplyForm(tweetId) {
    const replyForm = document.getElementById(`replyForm_${tweetId}`);
    replyForm.style.display = replyForm.style.display === 'none' ? 'block' : 'none';
}

function submitReply(tweetId) {
    const replyContent = document.getElementById(`replyContent_${tweetId}`).value;
    const formData = new URLSearchParams();
    formData.append('tweetId', tweetId);
    formData.append('content', replyContent);

    fetch('/pweb-quiz2/replyTweet', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: formData.toString(),
    })
        .then((response) => response.json())
        .then((result) => {
            if (result.success) {
                const replyCountElement = document.getElementById(`replyCount_${tweetId}`);
                replyCountElement.textContent = parseInt(replyCountElement.textContent) + 1;
                toggleReplyForm(tweetId); 
            } else {
                alert(result.error || 'Failed to submit the reply.');
            }
        })
        .catch((error) => {
            console.error('Error submitting reply:', error);
            alert('Something went wrong. Please try again.');
        });
}

function retweet(tweetId) {
    const formData = new URLSearchParams();
    formData.append('tweetId', tweetId);

    fetch('/pweb-quiz2/retweet', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: formData.toString(),
    })
    .then(response => response.json())
    .then(result => {
        if (result.success) {
            const retweetCountElement = document.getElementById(`retweetCount_${tweetId}`);

            if (result.retweeted) {
                retweetCountElement.textContent = parseInt(retweetCountElement.textContent) + 1;
            } else {
                retweetCountElement.textContent = parseInt(retweetCountElement.textContent) - 1;
            }
        } else {
            alert(result.error || 'Failed to retweet the tweet.');
        }
    })
    .catch(error => {
        console.error('Error retweeting tweet:', error);
        alert('Something went wrong. Please try again.');
    });
}

document.querySelector('input[name="image"]').addEventListener('change', function (event) {
    const preview = document.createElement('img');
    preview.style.maxWidth = '100%';
    preview.style.height = 'auto';
    preview.src = URL.createObjectURL(event.target.files[0]);
    document.getElementById('createTweetForm').appendChild(preview);
});

function previewImage(event) {
    const preview = document.getElementById('imagePreview');
    const previewContainer = document.getElementById('imagePreviewContainer');
    const file = event.target.files[0];
    if (file) {
        const reader = new FileReader();
        reader.onload = function(e) {
            preview.src = e.target.result;
            previewContainer.style.display = 'block';
        };
        reader.readAsDataURL(file);
    } else {
        preview.src = '';
        previewContainer.style.display = 'none';
    }
}

function performSearch(keyword) {
    if (keyword.trim() === "") {
        document.getElementById("searchResults").classList.add("hidden");
        return;
    }

    const params = new URLSearchParams();
    params.append("keyword", keyword);

    fetch(`/pweb-quiz2/search?${params.toString()}`)
        .then((response) => response.json())
        .then((data) => {
            const searchResults = document.getElementById("searchResults");
            const tweetResults = document.getElementById("tweetResults");
            const userResults = document.getElementById("userResults");

            tweetResults.innerHTML = "";
            userResults.innerHTML = "";

            if (data.tweets && data.tweets.length > 0) {
                data.tweets.forEach((tweet) => {
                    const tweetItem = document.createElement("div");
                    tweetItem.className = "p-2 bg-gray-100 rounded";
                    tweetItem.innerHTML = `
                        <p class="text-gray-700"><strong>@${tweet.username}</strong>: ${tweet.content}</p>
                    `;
                    tweetResults.appendChild(tweetItem);
                });
                document.getElementById("tweetsSection").classList.remove("hidden");
            } else {
                document.getElementById("tweetsSection").classList.add("hidden");
            }

            if (data.users && data.users.length > 0) {
                data.users.forEach((user) => {
                    const userItem = document.createElement("div");
                    userItem.className = "p-2 bg-gray-100 rounded";
                    userItem.innerHTML = `<p class="text-gray-700"><strong>@${user.username}</strong></p>`;
                    userResults.appendChild(userItem);
                });
                document.getElementById("usersSection").classList.remove("hidden");
            } else {
                document.getElementById("usersSection").classList.add("hidden");
            }

            searchResults.classList.remove("hidden");
        })
        .catch((error) => {
            console.error("Error fetching search results:", error);
        });
}



