import mysql.connector
from mysql.connector import Error

# Database configuration
DB_CONFIG = {
    'host': '127.0.0.1',
    'port': 3306,
    'user': 'root',
    'password': '',  # Use your MySQL password if set
    'database': 'ai_saas_db'
}

def create_database():
    try:
        # Connect without database selected
        conn = mysql.connector.connect(
            host=DB_CONFIG['host'],
            user=DB_CONFIG['user'],
            password=DB_CONFIG['password']
        )
        cursor = conn.cursor()
        
        # Drop database if exists and recreate
        cursor.execute("DROP DATABASE IF EXISTS ai_saas_db")
        cursor.execute("CREATE DATABASE ai_saas_db")
        cursor.execute("USE ai_saas_db")
        
        # Create users table
        cursor.execute("""
            CREATE TABLE users (
                user_id INT AUTO_INCREMENT PRIMARY KEY,
                email VARCHAR(255) NOT NULL UNIQUE,
                full_name VARCHAR(255) NOT NULL,
                plan ENUM('free', 'pro', 'enterprise') NOT NULL DEFAULT 'free',
                status ENUM('active', 'suspended', 'deleted') NOT NULL DEFAULT 'active',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        
        # Create subscriptions table
        cursor.execute("""
            CREATE TABLE subscriptions (
                subscription_id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                plan ENUM('pro', 'enterprise') NOT NULL,
                start_date DATE NOT NULL,
                end_date DATE,
                status ENUM('active', 'cancelled', 'expired') NOT NULL DEFAULT 'active',
                FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
                UNIQUE KEY unique_active_subscription (user_id, status)
            )
        """)
        
        # Create chat_sessions table
        cursor.execute("""
            CREATE TABLE chat_sessions (
                session_id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                title VARCHAR(255) DEFAULT 'New Chat',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
            )
        """)
        
        # Create messages table
        cursor.execute("""
            CREATE TABLE messages (
                message_id INT AUTO_INCREMENT PRIMARY KEY,
                session_id INT NOT NULL,
                role ENUM('user', 'assistant', 'system') NOT NULL,
                content TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (session_id) REFERENCES chat_sessions(session_id) ON DELETE CASCADE
            )
        """)
        
        # Create api_keys table
        cursor.execute("""
            CREATE TABLE api_keys (
                api_key_id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                key_value VARCHAR(64) NOT NULL UNIQUE,
                name VARCHAR(255) NOT NULL,
                status ENUM('active', 'revoked') NOT NULL DEFAULT 'active',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                last_used TIMESTAMP NULL,
                FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
            )
        """)
        
        # Create usage_logs table
        cursor.execute("""
            CREATE TABLE usage_logs (
                log_id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                session_id INT NULL,
                api_key_id INT NULL,
                tokens_used INT NOT NULL,
                cost DECIMAL(10, 6) NOT NULL,
                endpoint VARCHAR(255) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
                FOREIGN KEY (session_id) REFERENCES chat_sessions(session_id) ON DELETE SET NULL,
                FOREIGN KEY (api_key_id) REFERENCES api_keys(api_key_id) ON DELETE SET NULL
            )
        """)
        
        # Insert sample data
        sample_users = [
            ("alice@example.com", "Alice Johnson", "free", "active"),
            ("bob@example.com", "Bob Smith", "pro", "active"),
            ("carol@example.com", "Carol Davis", "enterprise", "active"),
            ("dave@example.com", "Dave Wilson", "free", "suspended"),
        ]
        
        cursor.executemany(
            "INSERT INTO users (email, full_name, plan, status) VALUES (%s, %s, %s, %s)",
            sample_users
        )
        
        # Get user IDs for subscriptions
        cursor.execute("SELECT user_id, plan FROM users WHERE plan IN ('pro', 'enterprise')")
        users_with_plans = cursor.fetchall()
        
        for user_id, plan in users_with_plans:
            cursor.execute(
                "INSERT INTO subscriptions (user_id, plan, start_date, status) VALUES (%s, %s, CURDATE(), 'active')",
                (user_id, plan)
            )
        
        # Add chat sessions
        cursor.execute("SELECT user_id FROM users WHERE status = 'active' LIMIT 2")
        active_users = cursor.fetchall()
        
        for (user_id,) in active_users:
            cursor.execute(
                "INSERT INTO chat_sessions (user_id, title) VALUES (%s, %s)",
                (user_id, f"Chat session for user {user_id}")
            )
            
            # Get session ID and add messages
            session_id = cursor.lastrowid
            messages_data = [
                (session_id, "user", "Hello, how can you help me?"),
                (session_id, "assistant", "I can help you with various tasks!"),
            ]
            cursor.executemany(
                "INSERT INTO messages (session_id, role, content) VALUES (%s, %s, %s)",
                messages_data
            )
        
        # Add API keys
        for (user_id,) in active_users:
            cursor.execute(
                "INSERT INTO api_keys (user_id, key_value, name, status) VALUES (%s, %s, %s, %s)",
                (user_id, f"key_{user_id}_123456", f"Key for user {user_id}", "active")
            )
        
        # Add usage logs
        for (user_id,) in active_users:
            cursor.execute(
                "INSERT INTO usage_logs (user_id, tokens_used, cost, endpoint) VALUES (%s, %s, %s, %s)",
                (user_id, 150, 0.0015, "/api/chat")
            )
            cursor.execute(
                "INSERT INTO usage_logs (user_id, tokens_used, cost, endpoint) VALUES (%s, %s, %s, %s)",
                (user_id, 300, 0.0030, "/api/completion")
            )
        
        conn.commit()
        print("[SUCCESS] Database 'ai_saas_db' is ready.")
        
    except Error as e:
        print(f"[ERROR] {e}")
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    create_database()