#!/bin/bash

# 1. We use a Python script to perfectly reconstruct the gallery HTML
cat << 'PYEOF' > fix_gallery.py
import re

with open('index.html', 'r') as f:
    html = f.read()

# We will only define captions for the real, existing images
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

# Build the new HTML for the gallery (1 to 14, then 16 to 27)
gallery_html = '<div class="gallery">\n'
count = 1
for i in range(1, 28):
    if i == 15:
        continue  # Skip the deleted image
        
    img_src = f"sql_screenshots/sql{i}.png"
    
    if count in captions:
        title, desc = captions[count]
    else:
        title = f"Test Execution {count}"
        desc = "Additional database execution screenshots and query validations."

    gallery_html += f"""
            <div class="gallery-item">
                <img src="{img_src}" alt="SQL Screenshot {count}" onclick="window.open(this.src)">
                <div class="gallery-caption">
                    <strong>{title}</strong>
                    {desc}
                </div>
            </div>"""
    count += 1

gallery_html += '\n        </div>'

# Replace the old gallery
html = re.sub(r'<div class="gallery">.*?<\/div>\s*<\/section>', gallery_html + '\n        </section>', html, flags=re.DOTALL)

with open('index.html', 'w') as f:
    f.write(html)
print("Successfully removed the broken image and rebuilt the gallery.")
PYEOF

# 2. Run the script
python3 fix_gallery.py

# 3. Clean up
rm fix_gallery.py

# 4. Push to GitHub
git add .
git commit -m "Removed missing sql15.png from gallery and fixed layout"
git push

