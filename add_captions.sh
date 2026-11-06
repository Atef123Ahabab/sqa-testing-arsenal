#!/bin/bash

# 1. Run a Python script to inject the captions and update the HTML structure
cat << 'PYEOF' > inject_captions.py
import re

with open('index.html', 'r') as f:
    html = f.read()

# Add CSS for the new cards
css_addition = """
        /* Updated Gallery Cards */
        .gallery { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; margin-top: 20px; }
        .gallery-item { background: var(--card-bg); border-radius: 12px; border: 1px solid var(--border); overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.05); transition: transform 0.2s ease, box-shadow 0.2s ease; display: flex; flex-direction: column; }
        .gallery-item:hover { transform: translateY(-5px); box-shadow: 0 10px 15px rgba(0,0,0,0.1); }
        .gallery-item img { width: 100%; height: auto; cursor: pointer; border-bottom: 1px solid var(--border); }
        .gallery-caption { padding: 15px; font-size: 0.9rem; color: var(--text-main); flex-grow: 1; }
        .gallery-caption strong { display: block; margin-bottom: 5px; color: var(--primary); font-size: 1.05rem; }
        .gallery-caption span { color: var(--text-light); font-size: 0.85rem; display: block; margin-top: 4px;}
"""

# Insert CSS before </style>
html = html.replace('</style>', css_addition + '\n    </style>')

# Define the captions for the first 10 most important screenshots
captions = {
    1: ("Schema Inspection", "Verifying columns and data types for users and usage logs."),
    2: ("Primary Keys Check", "Ensuring all 6 tables have a Primary Key for unique row identification."),
    3: ("Foreign Keys Check", "Verifying relational integrity between tables (e.g., messages to sessions)."),
    4: ("Duplicate Email Test", "Negative testing: Attempting to insert a duplicate email to test UNIQUE constraint."),
    5: ("Invalid Plan Test", "Negative testing: Attempting to insert a non-existent plan to test ENUM constraint."),
    6: ("Update User Plan", "CRUD testing: Updating a user's plan to 'pro' and verifying persistence."),
    7: ("CASCADE Delete Test", "Data integrity: Deleting a user to verify related sessions/messages are also removed."),
    8: ("Transaction ROLLBACK", "Testing transaction safety by rolling back a plan change."),
    9: ("Transaction COMMIT", "Testing successful transaction saving by committing a plan change."),
    10: ("Complex JOIN Query", "Performance testing: Aggregating data across multiple tables for analytics.")
}

# Build the new HTML for the gallery
gallery_html = '<div class="gallery">\n'
for i in range(1, 28): # Loop through all 27 images
    img_src = f"sql_screenshots/sql{i}.png"
    
    if i in captions:
        title, desc = captions[i]
    else:
        title = f"Test Execution {i}"
        desc = "Additional database execution screenshots and query validations."

    gallery_html += f"""
            <div class="gallery-item">
                <img src="{img_src}" alt="SQL Screenshot {i}" onclick="window.open(this.src)">
                <div class="gallery-caption">
                    <strong>{title}</strong>
                    {desc}
                </div>
            </div>"""
gallery_html += '\n        </div>'

# Replace the old simple gallery with the new detailed one
# Find the start of the <div class="gallery"> and the end of the images section
html = re.sub(r'<div class="gallery">.*?<\/div>', gallery_html, html, flags=re.DOTALL)

with open('index.html', 'w') as f:
    f.write(html)
print("Successfully added brief details below each image.")
PYEOF

# 2. Execute Python script
python3 inject_captions.py

# 3. Clean up
rm inject_captions.py

# 4. Push to GitHub
git add .
git commit -m "Upgraded SQL gallery to detailed cards with descriptions"
git push

