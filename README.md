# OSTAD SQA Practical Assessment - Comprehensive QA Portfolio

Welcome to my Software Quality Assurance (SQA) portfolio project. This repository contains a complete, end-to-end QA assessment covering Web UI testing, API test design, Database testing, and Exploratory defect reporting for AI-based applications (Claude.ai & Thaura.ai).

## 🌟 Live Interactive Dashboard
Instead of just reading raw PDFs, this project includes a custom-built, user-friendly Web UI Dashboard.

**To view the dashboard locally:**
1. Clone the repository.
2. Run `npm install` (if needed).
3. Run `npm run dev` to open the dashboard in your browser.

## 📁 Project Structure & Scope

### 1. Exploratory & Scripted Testing (Claude.ai Web UI)
- Conducted a 60-minute session-based exploratory testing.
- Identified 4 major/minor bugs (e.g., whitespace prompt validation, stop-generation lag).
- Executed 19 scripted test cases across Authentication, Core Chat, and Response Controls.
- **Artifacts:** `Part_C_Report.pdf`, `bug_report.pdf`

### 2. API Test Design (`/v1/chat/completions`)
- Designed 17 test cases covering:
  - Positive paths (200 OK)
  - Authentication (401, 403)
  - Validation (400, invalid roles, max_tokens limits)
  - Schema Validation
  - Rate Limiting (429)
- Includes a Postman Collection demonstrating basic API testing execution.
- **Artifacts:** `Q3B_API_Test_Design.xlsx`, `Api testing.postman_collection.json`

### 3. Database Testing (`ai_saas_db`)
- Designed and executed MySQL tests for a 6-table AI SaaS schema.
- Tested Foreign Keys, CASCADE deletes, CRUD operations, and Transaction Rollbacks.
- **Features:**
  - **SQL Screenshots Gallery:** View 27 high-quality screenshots of actual test executions with detailed captions explaining each step.
  - **Database Analysis:** A dedicated section breaking down the "Why" and "How" behind every database test (Negative testing, Transaction safety, etc.).
- **Artifacts:** `Question_2_DB.pdf`, `setup_database.py`

## 🛠️ Tools & Technologies Used
- **Testing Tools:** Postman, Manual Testing
- **Database:** MySQL
- **Scripting:** Python (Database setup)
- **Frontend UI:** HTML5, CSS3, Vanilla JavaScript (SPA layout with dark mode)
- **Automation Tooling:** Node.js, http-server, Playwright
- **Version Control:** Git, GitHub

---
*Note: The interactive UI was built from scratch to present QA artifacts professionally, demonstrating both testing skills and frontend development capabilities.*
