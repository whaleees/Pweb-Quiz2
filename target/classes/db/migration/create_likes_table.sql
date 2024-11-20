CREATE TABLE likes (
    id INT AUTO_INCREMENT PRIMARY KEY,         
    user_id INT NOT NULL,                      
    tweet_id INT NOT NULL,                     
    liked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE, 
    FOREIGN KEY (tweet_id) REFERENCES tweets(id) ON DELETE CASCADE,
    UNIQUE(user_id, tweet_id)
);
