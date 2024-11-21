CREATE TABLE tweets (
    id INT AUTO_INCREMENT PRIMARY KEY,         
    content VARCHAR(280) NOT NULL,             
    user_id INT NOT NULL,                      
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    image_path VARCHAR(255) DEFAULT NULL
);
