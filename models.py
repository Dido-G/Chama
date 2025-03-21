import datetime
from extensions import db, bcrypt
from flask_login import UserMixin

class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(150), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)
    age = db.Column(db.Integer, nullable=False)
    height = db.Column(db.Float, nullable=False)
    weight = db.Column(db.Float, nullable=False)

    def set_password(self, password):
        self.password = bcrypt.generate_password_hash(password).decode('utf-8')

    def check_password(self, password):
        return bcrypt.check_password_hash(self.password, password)

    def __repr__(self):
        return f'<User {self.username}>'

class SensorData(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    #heart_rate = db.Column(db.Integer, nullable=False)

    temperature = db.Column(db.Float, nullable=False)
    kilometers = db.Column(db.Float, default=0.0)
    timestamp = db.Column(db.DateTime, default=datetime.datetime.utcnow)
    latitude = db.Column(db.Float, nullable=False)
    longitude = db.Column(db.Float, nullable=False)
    steps = db.Column(db.Integer, nullable=False)

    acceleration_x = db.Column(db.Float, nullable=True)
    acceleration_y = db.Column(db.Float, nullable=True)
    acceleration_z = db.Column(db.Float, nullable=True)
    rotation_x = db.Column(db.Float, nullable=True)
    rotation_y = db.Column(db.Float, nullable=True)
    rotation_z = db.Column(db.Float, nullable=True)

    @property
    def timestamp_str(self):
        """Return the timestamp as an ISO format string"""
        return self.timestamp.isoformat() if self.timestamp else None

    def __repr__(self):
        return f'<SensorData {self.id}>'

# To-Do Task Model
class Task(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    task = db.Column(db.String(255), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    timestamp = db.Column(db.DateTime, default=datetime.datetime.utcnow)
    
    def __repr__(self):
        return f'<Task {self.task}>'

# Completed Task Model
class DoneTask(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    task = db.Column(db.String(255), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False) 
    timestamp = db.Column(db.DateTime, default=datetime.datetime.utcnow)

    def __repr__(self):
        return f'<DoneTask {self.task}>'