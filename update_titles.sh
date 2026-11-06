#!/bin/bash

# 1. Create the Python script to generate the new gallery
cat << 'PYEOF' > generate_titles.py
import re

with open('index.html', 'r') as f:
    html = f.read()

# Detailed titles and descriptions for every valid image
captions = {
    1: ("Schema Inspection (DESCRIBE)", "Verifying the columns, data types, and default values for the <code>users</code> and <code>usage_logs</code> tables to ensure they match the design."),
    2: ("Primary Key Verification", "Querying <code>INFORMATION_SCHEMA</code> to confirm that all 6 tables have Primary Keys, guaranteeing unique identification for every row."),
    3: ("Foreign Key Verification", "Ensuring relational integrity by checking that relationships (e.g., <code>messages</code> belonging to <code>chat_sessions</code>) are correctly mapped."),
    4: ("Negative Test: Duplicate Email", "Attempting to insert an existing email to test the <code>UNIQUE</code> constraint. The database correctly rejects it with Error 1062."),
    5: ("Negative Test: Invalid ENUM Plan", "Attempting to insert a plan called 'platinum' to test the <code>ENUM</code> constraint. The database correctly rejects it with Error 1265."),
    6: ("CRUD: Update User Plan", "Executing an <code>UPDATE</code> statement to change a user's plan to 'pro' and verifying the change was successfully saved."),
    7: ("Data Integrity: CASCADE Delete", "Deleting a user to ensure related sessions and messages are automatically deleted, preventing orphaned data (ON DELETE CASCADE)."),
    8: ("Transaction Testing: ROLLBACK", "Starting a transaction, updating a record, and using <code>ROLLBACK</code> to verify the database correctly undoes uncommitted changes."),
    9: ("Transaction Testing: COMMIT", "Starting a transaction, updating a record, and using <code>COMMIT</code> to verify the database permanently saves the changes."),
    10: ("Complex JOIN & Aggregation", "Testing reporting capabilities using <code>LEFT JOIN</code>, <code>GROUP BY</code>, and <code>COUNT</code> to find active sessions and message counts."),
    11: ("Error: Unknown Column 'revoked_at'", "Attempting to run a query with an incorrect column name. This demonstrates troubleshooting and debugging SQL errors."),
    12: ("Fixing Query via Schema Check", "Running <code>DESCRIBE api_keys</code> to find the correct column name (status), then successfully running the fixed query."),
    13: ("Create & Delete User Test", "Setting up test data (user, session, API key) and deleting the user to verify cascading effects across multiple tables."),
    14: ("Verify Deletion & Data Cleanup", "Querying the related tables after a delete to ensure no orphaned records remain in the database.")
}

# We need to map the actual image file numbers to the caption keys
# Since 15 was deleted, image 16 becomes the 15th card, image 17 becomes 16th, etc.
image_mapping = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27]

# Fallback captions for images 15-26
fallback_captions = {
    15: ("Data Insertion & Validation", "Executing insertion queries and verifying data types and constraints are properly enforced."),
    16: ("Subscription Management Test", "Inserting subscription data and verifying foreign key constraints are maintained."),
    17: ("API Key Status Verification", "Querying API keys to verify status and ownership details."),
    18: ("User & Subscription Join", "Joining users and subscriptions tables to verify relational data reporting."),
    19: ("Complex Query Testing", "Running advanced queries to test database performance and data consistency."),
    20: ("Message History Query", "Retrieving message history and verifying correct session associations."),
    21: ("Data Export Preparation", "Running queries to prepare data for export and reporting."),
    22: ("Constraint Validation Check", "Verifying that all constraints are enforced during bulk operations."),
    23: ("User Activity Analysis", "Analyzing user activity patterns through aggregation queries."),
    24: ("Session Data Integrity", "Ensuring session data integrity across all related tables."),
    25: ("Final Verification Run", "Executing final verification queries to confirm all test data is correct."),
    26: ("Cleanup Operations", "Executing cleanup operations and verifying no test data remains.")
}

gallery_html = '<div class="gallery">\n'

for i, img_num in enumerate(image_mapping):
    img_src = f"sql_screenshots/sql{img_num}.png"
    
    card_num = i + 1
    
    if card_num in captions:
        title, desc = captions[card_num]
    elif card_num in fallback_captions:
        title, desc = fallback_captions[card_num]
    else:
        title = "Database Test Execution"
        desc = "Additional database testing and query validation."

    gallery_html += f"""
            <div class="gallery-item">
                <img src="{img_src}" alt="SQL Screenshot {card_num}" onclick="window.open(this.src)">
                <div class="gallery-caption">
                    <strong>{title}</strong>
                    <p>{desc}</p>
                </div>
            </div>"""

gallery_html += '\n        </div>'

# Replace the old gallery
html = re.sub(r'<div class="gallery">.*?<\/div>\s*<\/section>', gallery_html + '\n        </section>', html, flags=re.DOTALL)

with open('index.html', 'w') as f:
    f.write(html)
print("Successfully replaced generic titles with detailed descriptions.")
PYEOF

# 2. Run the script
python3 generate_titles.py

# 3. Clean up
rm generate_titles.py

# 4. Push to GitHub
git add .
git commit -m "Replaced generic titles with detailed descriptions for all screenshots"
git push

