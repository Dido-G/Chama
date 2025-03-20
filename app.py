from flask import Flask, render_template, redirect, url_for
from extensions import db, bcrypt, login_manager, socketio
from flask_cors import CORS


app = Flask(__name__)
CORS(app)
# App configurations
app.config['SECRET_KEY'] = 'your_secret_key_here'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///your_database_name.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Initialize extensions
db.init_app(app)
bcrypt.init_app(app)  # Only initialize bcrypt once
login_manager.init_app(app)
socketio.init_app(app, cors_allowed_origins="*")  # Ensure CORS is allowed

# Import models and routes
from routes import *  

# User loader for flask-login
@login_manager.user_loader
def load_user(user_id):
    from models import User
    return User.query.get(int(user_id))

# Create all database tables
with app.app_context():
    db.create_all()

# Run the app with socketio
if __name__ == '__main__':
    socketio.run(app, debug=True, host="0.0.0.0", port=8080)

