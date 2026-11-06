#!/bin/bash

# 1. Create a temporary Python script to inject the HTML
cat << 'PYEOF' > inject_analysis.py
import re

with open('index.html', 'r') as f:
    html = f.read()

# The new Analysis section to insert
analysis_html = """
            <!-- DETAILED DATABASE ANALYSIS SECTION -->
            <section id="db-analysis" class="section">
                <h3 style="margin-bottom: 10px;">Detailed Database Testing Analysis</h3>
                <p style="color: var(--text-light); margin-bottom: 30px;">
                    The screenshots in the gallery above demonstrate a comprehensive approach to database testing. 
                    Below is a breakdown of what is happening in each step, the purpose of the test, and how it validates the database structure.
                </p>

                <div class="analysis-grid">
                    <!-- Analysis 1 -->
                    <div class="analysis-card">
                        <h4>1. Schema Inspection (DESCRIBE)</h4>
                        <p><strong>What is happening:</strong> Running <code>DESCRIBE users;</code> and <code>DESCRIBE usage_logs;</code>.</p>
                        <p><strong>Why:</strong> To verify the database schema, checking that tables were created with correct columns, data types (INT, VARCHAR, TIMESTAMP), and default values.</p>
                        <p><strong>Validation:</strong> Proves the Python script (<code>setup_database.py</code>) successfully created the tables exactly as designed.</p>
                    </div>

                    <!-- Analysis 2 -->
                    <div class="analysis-card">
                        <h4>2. Verifying Primary Keys</h4>
                        <p><strong>What is happening:</strong> Querying <code>INFORMATION_SCHEMA.KEY_COLUMN_USAGE</code> for constraints named 'PRIMARY'.</p>
                        <p><strong>Why:</strong> To ensure every table has a Primary Key defined, guaranteeing uniqueness for each row.</p>
                        <p><strong>Validation:</strong> Confirms that all 6 tables (users, chat_sessions, etc.) have active Primary Keys, enforcing data integrity at the table level.</p>
                    </div>

                    <!-- Analysis 3 -->
                    <div class="analysis-card">
                        <h4>3. Verifying Foreign Keys</h4>
                        <p><strong>What is happening:</strong> Querying <code>INFORMATION_SCHEMA</code> for <code>REFERENCED_TABLE_NAME</code> (Foreign Keys).</p>
                        <p><strong>Why:</strong> To verify that relationships between tables (e.g., messages belonging to chat_sessions) are correctly mapped.</p>
                        <p><strong>Validation:</strong> Proves the database is relational and prevents orphaned data (e.g., a message cannot exist without a valid session).</p>
                    </div>

                    <!-- Analysis 4 -->
                    <div class="analysis-card">
                        <h4>4. Duplicate Email Test (Negative)</h4>
                        <p><strong>What is happening:</strong> Attempting to insert 'alice@example.com' a second time.</p>
                        <p><strong>Why:</strong> To test the <code>UNIQUE</code> constraint on the email column.</p>
                        <p><strong>Validation:</strong> The database rejects the insert with <code>Error 1062. Duplicate entry</code>. This proves the database prevents duplicate users (Pass).</p>
                    </div>

                    <!-- Analysis 5 -->
                    <div class="analysis-card">
                        <h4>5. Invalid Plan Test (Negative)</h4>
                        <p><strong>What is happening:</strong> Trying to insert a user with <code>plan = 'platinum'</code> (not in the ENUM list).</p>
                        <p><strong>Why:</strong> To test the <code>ENUM('free', 'pro', 'enterprise')</code> constraint.</p>
                        <p><strong>Validation:</strong> The database rejects it with <code>Error 1265. Data truncated</code>. This proves the database strictly enforces valid subscription tiers (Pass).</p>
                    </div>

                    <!-- Analysis 6 -->
                    <div class="analysis-card">
                        <h4>6. Updating a User's Plan (CRUD)</h4>
                        <p><strong>What is happening:</strong> Running <code>UPDATE users SET plan = 'pro' WHERE email = 'partb.user@example.com';</code>.</p>
                        <p><strong>Why:</strong> To test the <code>UPDATE</code> operation and verify data persistence.</p>
                        <p><strong>Validation:</strong> The subsequent select query shows the plan changed to 'pro', proving CRUD operations work correctly.</p>
                    </div>

                    <!-- Analysis 7 -->
                    <div class="analysis-card">
                        <h4>7. Testing CASCADE Delete</h4>
                        <p><strong>What is happening:</strong> Creating a user, session, and message, then deleting the user.</p>
                        <p><strong>Why:</strong> To test the <code>ON DELETE CASCADE</code> constraint.</p>
                        <p><strong>Validation:</strong> The query for the user's sessions/messages after deletion returns <code>0 rows</code>. This proves the database prevents orphaned data (Pass).</p>
                    </div>

                    <!-- Analysis 8 -->
                    <div class="analysis-card">
                        <h4>8. Transaction ROLLBACK</h4>
                        <p><strong>What is happening:</strong> Starting a transaction, updating a plan, then running <code>ROLLBACK</code>.</p>
                        <p><strong>Why:</strong> To test if the database correctly undoes changes when a transaction is cancelled.</p>
                        <p><strong>Validation:</strong> The final SELECT shows the original state. This proves data is only committed when explicitly told to do so (Pass).</p>
                    </div>

                    <!-- Analysis 9 -->
                    <div class="analysis-card">
                        <h4>9. Transaction COMMIT</h4>
                        <p><strong>What is happening:</strong> Starting a transaction, updating a plan, and running <code>COMMIT</code>.</p>
                        <p><strong>Why:</strong> To test if the database correctly saves changes permanently when instructed.</p>
                        <p><strong>Validation:</strong> The final SELECT shows the updated plan. This proves successful transactions are permanently saved (Pass).</p>
                    </div>

                    <!-- Analysis 10 -->
                    <div class="analysis-card">
                        <h4>10. Complex JOIN Query</h4>
                        <p><strong>What is happening:</strong> Writing a <code>LEFT JOIN</code> with <code>COUNT</code> to find the most active session.</p>
                        <p><strong>Why:</strong> To test the database's ability to handle complex reporting queries (aggregation, grouping, sorting).</p>
                        <p><strong>Validation:</strong> The output lists users, sessions, and message counts. This proves the data structure supports efficient analytics.</p>
                    </div>

                    <!-- Analysis 11 -->
                    <div class="analysis-card">
                        <h4>11. Debugging SQL Errors</h4>
                        <p><strong>What is happening:</strong> Trying to select <code>ak.revoked_at</code>, resulting in <code>Error 1054</code>.</p>
                        <p><strong>Why:</strong> To demonstrate troubleshooting and fixing a broken query.</p>
                        <p><strong>Validation:</strong> Running <code>DESCRIBE api_keys</code> revealed the correct column is <code>status</code>. The query was fixed, proving the ability to debug schema issues.</p>
                    </div>
                </div>
            </section>
"""

# Add CSS for the analysis grid
css_addition = """
        /* Analysis Grid */
        .analysis-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(350px, 1fr)); gap: 20px; margin-top: 20px; }
        .analysis-card { background: var(--card-bg); padding: 20px; border-radius: 12px; border: 1px solid var(--border); border-left: 4px solid var(--primary); box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
        .analysis-card h4 { margin-bottom: 10px; color: var(--primary); font-size: 1.05rem; }
        .analysis-card p { font-size: 0.9rem; color: var(--text-light); margin-bottom: 8px; line-height: 1.5; }
        .analysis-card code { background: #f1f5f9; padding: 2px 4px; border-radius: 4px; font-size: 0.85rem; color: #e11d48; }
"""

# Insert CSS before </style>
html = html.replace('</style>', css_addition + '\n    </style>')

# Insert the Analysis Section right after the Screenshots section
# We find the closing tag of the sql-screenshots section
screenshot_section_end = html.find('</section>', html.find('id="sql-screenshots"'))
html = html[:screenshot_section_end + 10] + analysis_html + html[screenshot_section_end + 10:]

# Add a nav link for the new section
nav_link = '<li><a class="nav-link" data-target="db-analysis">🔍 Database Analysis</a></li>'
html = html.replace('<li><a class="nav-link" data-target="sql-screenshots">📸 SQL Screenshots Gallery</a></li>', 
                    '<li><a class="nav-link" data-target="sql-screenshots">📸 SQL Screenshots Gallery</a></li>\n            ' + nav_link)

with open('index.html', 'w') as f:
    f.write(html)
print("Successfully injected the analysis section.")
PYEOF

# 2. Run the Python script
python3 inject_analysis.py

# 3. Clean up
rm inject_analysis.py

# 4. Push to GitHub
git add .
git commit -m "Added detailed breakdown and analysis of SQL testing to the UI"
git push

