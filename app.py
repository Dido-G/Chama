from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager
from flask_bcrypt import Bcrypt


app = Flask(__name__)

app.config['SECRET_KEY'] = 'your_secret_key_here'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///your_database_name.db' 
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)
bcrypt = Bcrypt(app)  
login_manager = LoginManager(app)

from routes import *  

@login_manager.user_loader
def load_user(user_id):
    from models import User, SensorData
    return User.query.get(int(user_id))

with app.app_context():
    db.create_all()

# Run the app
if __name__ == '__main__':
    app.run(debug=True)
