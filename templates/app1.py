from flask import Flask, render_template, request, jsonify
import sqlite3

app = Flask(__name__)

# Database connection helper
def connect_db():
    return sqlite3.connect("tasks.db")

# Initialize databases
def init_db():
    with connect_db() as conn:
        cursor = conn.cursor()
        cursor.execute('''CREATE TABLE IF NOT EXISTS todo_tasks (
                            id INTEGER PRIMARY KEY AUTOINCREMENT,
                            name TEXT NOT NULL)''')
        cursor.execute('''CREATE TABLE IF NOT EXISTS done_tasks (
                            id INTEGER PRIMARY KEY AUTOINCREMENT,
                            name TEXT NOT NULL)''')
        conn.commit()

init_db()  # Initialize database on startup

@app.route('/')
def index():
    with connect_db() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM todo_tasks")
        todo_tasks = cursor.fetchall()
        cursor.execute("SELECT * FROM done_tasks")
        done_tasks = cursor.fetchall()
    return render_template("tasks.html", tasks=todo_tasks, done_tasks=done_tasks)

@app.route('/add_task', methods=['POST'])
def add_task():
    data = request.get_json()
    task_name = data.get("task")

    with connect_db() as conn:
        cursor = conn.cursor()
        cursor.execute("INSERT INTO todo_tasks (name) VALUES (?)", (task_name,))
        task_id = cursor.lastrowid
        conn.commit()
    
    return jsonify({"success": True, "task_id": task_id})

@app.route('/mark_done/<int:task_id>', methods=['POST'])
def mark_done(task_id):
    with connect_db() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT name FROM todo_tasks WHERE id = ?", (task_id,))
        task = cursor.fetchone()
        
        if task:
            cursor.execute("INSERT INTO done_tasks (name) VALUES (?)", (task[0],))
            cursor.execute("DELETE FROM todo_tasks WHERE id = ?", (task_id,))
            conn.commit()
            return jsonify({"success": True})
    
    return jsonify({"success": False})

if __name__ == '__main__':
    app.run(debug=True)

