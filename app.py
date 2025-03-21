from flask import Flask, render_template, redirect, url_for
from extensions import db, bcrypt, login_manager, socketio
from flask_cors import CORS
from config import Config
from flask_migrate import Migrate



app = Flask(__name__)
migrate = Migrate(app, db)
app.config.from_object(Config) 
CORS(app)

# Initialize extensions
db.init_app(app)
bcrypt.init_app(app)  
login_manager.init_app(app)
socketio.init_app(app, cors_allowed_origins="*")

from routes import *  


@login_manager.user_loader
def load_user(user_id):
    from models import User
    return User.query.get(int(user_id))

# Create all database tables
with app.app_context():
    db.create_all()
    


if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=8080)

