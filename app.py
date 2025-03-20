from flask import Flask, render_template, redirect, url_for
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager
from flask_bcrypt import Bcrypt

app = Flask(__name__)

# Configurations
app.config['SECRET_KEY'] = 'your_secret_key_here'  # Make sure to replace with a real secret key
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///your_database_name.db'  # Replace with your database name
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Initialize extensions
db = SQLAlchemy(app)
bcrypt = Bcrypt(app)
login_manager = LoginManager(app)

from routes import *

@login_manager.user_loader
def load_user(user_id):
    from models import User, SensorData
    return User.query.get(int(user_id))

# Create all the tables in the database if they do not already exist
with app.app_context():
    db.create_all()

# Route for the home page (dashboard or welcome page)
@app.route('/')
def home():
    return redirect(url_for('tasks'))  # Redirect to the "Go to Tasks" page

# Route for the "Go to Tasks" page (listing tasks)
@app.route('/tasks')
def tasks():
    from models import Task  # Import Task model to fetch tasks
    tasks = Task.query.filter_by(done=False).all()  # Fetch tasks that are not done
    done_tasks = Task.query.filter_by(done=True).all()  # Fetch tasks that are done
    return render_template('tasks.html', tasks=tasks, done_tasks=done_tasks)

if __name__ == '__main__':
    app.run(debug=True)  # Start the app with debugging enabled

