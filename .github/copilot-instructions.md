# GitHub Copilot Instructions for OnlineBookstore

This document provides context and guidelines for AI agents working on the OnlineBookstore project.

## 🏗 Project Overview
- **Type**: Monolithic Web Application
- **Language**: Python 3.x
- **Framework**: Flask
- **Database**: Microsoft SQL Server (via `pyodbc`)
- **Frontend**: Server-side rendered HTML with Jinja2 templates

## 🏛 Architecture & Core Components
- **Entry Point**: `app.py` contains the entire application logic, including routes, database connection management, and configuration.
- **Database Access**: 
  - Uses raw SQL queries executed via `pyodbc`.
  - **Context Manager**: Always use the `get_db()` context manager to handle database connections. This ensures connections are properly opened, committed (or rolled back on error), and closed.
  - **Row Factory**: A custom `DictRow` class is used to allow accessing database rows like dictionaries (e.g., `row['column_name']`).
- **Templates**: Located in `templates/`.
  - `base.html`: The master layout file. All new pages should extend this template to maintain consistent layout and navigation.

## 💻 Development Workflow
- **Running the App**: Execute `python app.py`. The app runs in debug mode by default (check `app.run()` arguments).
- **Dependencies**: Key libraries include `flask`, `pyodbc`, and `bcrypt`. (Note: No `requirements.txt` exists currently; ensure these are installed).

## 📝 Coding Conventions & Patterns

### Database Interactions
- **Parameterization**: ALWAYS use `?` placeholders for SQL parameters to prevent SQL injection.
  - ✅ `cursor.execute("SELECT * FROM books WHERE id = ?", (book_id,))`
  - ❌ `cursor.execute(f"SELECT * FROM books WHERE id = {book_id}")`
- **Connection Handling**:
  ```python
  with get_db() as conn:
      cursor = conn.cursor()
      cursor.execute(...)
      # conn.commit() is handled automatically if no exception occurs
  ```

### Error Handling
- Wrap database operations in `try...except` blocks.
- Use `flash()` to display user-facing error messages or success notifications.
- Log technical errors to the console (or logging system) for debugging.

### Security
- **Secrets**: The application currently contains hardcoded secrets (e.g., `app.secret_key`, DB credentials). 
  - **AI Action**: When modifying configuration, suggest moving these to environment variables (`os.environ`) or a separate config file, but respect the existing pattern if a refactor is not requested.
- **Passwords**: Use `bcrypt` for hashing user passwords.

### Frontend
- Use Jinja2 inheritance: `{% extends 'base.html' %}`.
- Place content within `{% block content %}`.
- Use `url_for()` for all link generation, never hardcode paths.

## 📂 Key Files
- `app.py`: Main application logic.
- `templates/base.html`: Base template with common head, header, and footer.
- `OnlineBookstore.sql`: Database schema definition.
