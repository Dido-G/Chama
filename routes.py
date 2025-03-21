from flask import request, redirect, url_for, render_template, flash, jsonify
from flask_login import login_user, login_required, logout_user, current_user
from extensions import db
from models import User, Task, DoneTask, SensorData
from app import app
from sqlalchemy import func
import math
from langchain_ollama import OllamaLLM
from langchain_core.prompts import ChatPromptTemplate


# Home route
@app.route('/')
def home():
    return render_template('home.html')

# Register page
@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        age = request.form.get('age')
        height = request.form.get('height')
        weight = request.form.get('weight')

        if User.query.filter_by(username=username).first():
            flash('Username already exists!', 'danger')
            return redirect(url_for('register'))

        user = User(username=username, age=age, height=height, weight=weight)
        user.set_password(password)  # Hash the password before saving
        db.session.add(user)
        db.session.commit()
        
        flash('Registration successful! Please login.', 'success')
        return redirect(url_for('login'))
    
    return render_template('register.html')

# Login Route
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        user = User.query.filter_by(username=username).first()
        if user and user.check_password(password): 
            login_user(user)
            flash('Login successful!', 'success')
            return redirect(url_for('profile'))  
        
        flash('Invalid username or password!', 'danger')
        return redirect(url_for('login'))

    return render_template('login.html')

# Profile Route
@app.route('/profile')
@login_required 
def profile():
    tasks = Task.query.filter_by(user_id=current_user.id).all()
    done_tasks = DoneTask.query.filter_by(user_id=current_user.id).all()
    return render_template('profile.html', user=current_user, tasks=tasks, done_tasks=done_tasks)

# Logout Route
@app.route('/logout')
@login_required
def logout():
    logout_user()
    flash('Logged out successfully!', 'info')
    return redirect(url_for('login'))

# Add Task
@app.route('/add_task', methods=['POST'])
@login_required
def add_task():
    task_text = request.form.get('task')
    if task_text.strip():
        new_task = Task(task=task_text, user_id=current_user.id)
        db.session.add(new_task)
        db.session.commit()
        flash('Task added!', 'success')
    else:
        flash('Task cannot be empty!', 'danger')

    return redirect(url_for('profile'))  # Reload page

# Mark Task as Done
@app.route('/mark_done/<int:task_id>', methods=['POST'])
@login_required
def mark_done(task_id):
    task = Task.query.filter_by(id=task_id, user_id=current_user.id).first()
    if task:
        done_task = DoneTask(task=task.task, user_id=current_user.id)
        db.session.add(done_task)
        db.session.delete(task)
        db.session.commit()
        flash('Task marked as done!', 'success')
    else:
        flash('Task not found!', 'danger')

    return redirect(url_for('profile'))  

# Clear All Completed Tasks
@app.route('/clear_done_tasks', methods=['POST'])
@login_required
def clear_done_tasks():
    DoneTask.query.filter_by(user_id=current_user.id).delete()
    db.session.commit()
    flash('All completed tasks have been cleared!', 'success')

    return redirect(url_for('profile'))  # Reload page


@app.route('/tasks')
@login_required
def tasks():
    tasks = Task.query.filter_by(user_id=current_user.id).all()
    return render_template('tasks.html', tasks=tasks)

@app.route('/data', methods=['POST'])
def sensor_data():
    try:
        # Get the incoming JSON data
        data = request.get_json()

        # Extract individual data points (for example)
        acceleration_x = data['acceleration_x']
        acceleration_y = data['acceleration_y']
        acceleration_z = data['acceleration_z']
        rotation_x = data['rotation_x']
        rotation_y = data['rotation_y']
        rotation_z = data['rotation_z']
        temperature = data['temperature']
        latitude = data['latitude']
        longitude = data['longitude']
        altitude = data['altitude']
        

        # Print received data for testing
        print(f"Received Data: Acceleration ({acceleration_x}, {acceleration_y}, {acceleration_z}), "
              f"Rotation ({rotation_x}, {rotation_y}, {rotation_z}), Temperature: {temperature}, "
              f"Latitude: {latitude}, Longitude: {longitude}, Altitude: {altitude}")

        return jsonify({"status": "success", "message": "Data received successfully"}), 200

    except Exception as e:
        # Handle errors if any
        print(f"Error: {e}")
        return jsonify({"status": "error", "message": "Failed to receive data"}), 500

# Get user info
@app.route("/api/user/<username>", methods=['GET'])
def get_user(username):
    user = User.query.filter_by(username=username).first()
    if not user:
        return jsonify({"error": "User not found"}), 404

    return jsonify({
        'id': user.id,
        'username': user.username,
        'age': user.age,
        'height': user.height,
        'weight': user.weight
    })

# Get latest sensor data
@app.route('/api/sensor/latest', methods=['GET'])
def get_latest_sensor_data():
    sensor_data = SensorData.query.order_by(SensorData.timestamp.desc()).first()
    if not sensor_data:
        return jsonify({'error': 'No sensor data found'}), 404

    return jsonify({
        'id': sensor_data.id,
        'temperature': sensor_data.temperature,
        'latitude': sensor_data.latitude,
        'longitude': sensor_data.longitude,
        'steps': sensor_data.steps,
        'acceleration_x': sensor_data.acceleration_x,
        'acceleration_y': sensor_data.acceleration_y,
        'acceleration_z': sensor_data.acceleration_z,
        'rotation_x': math.degrees(sensor_data.rotation_x) if sensor_data.rotation_x is not None else None,
        'rotation_y': math.degrees(sensor_data.rotation_y) if sensor_data.rotation_y is not None else None,
        'rotation_z': math.degrees(sensor_data.rotation_z) if sensor_data.rotation_z is not None else None,
        'timestamp_str': sensor_data.timestamp.isoformat()
    })

# Get all tasks for a user
@app.route('/api/tasks/<int:user_id>', methods=['GET'])
def get_tasks(user_id):
    tasks = Task.query.filter_by(user_id=user_id).all()
    return jsonify([{'id': task.id, 'task': task.task, 'timestamp': task.timestamp.isoformat()} for task in tasks])

template = """
    Answer the question bellow.

    Heres the conversation history: {context}

    Question {question}

    Answer:
 """

ai_model = OllamaLLM(model="llama3")

# Chatbot Route for Llama
@app.route('/chat', methods=['POST'])
@login_required
def chat():
    user_message = request.form.get('message')  # Get the user's message from the form
    if not user_message:
        return jsonify({'error': 'Message cannot be empty!'}), 400
    
    # Create the chat prompt template
    prompt_template = ChatPromptTemplate.from_messages([
        ("system", "You are an assistant that helps with various tasks."),
        ("user", user_message)
    ])
    
    # Send the message to the Llama model
    try:
        response = ai_model.generate_response(prompt_template)
        bot_reply = response['text']
        return jsonify({'response': bot_reply}), 200
    except Exception as e:
        print(f"Error with Llama model: {e}")
        return jsonify({'error': 'Error generating response from the model'}), 500

@app.route('/gps', methods=['GET', 'POST'])
@login_required
def gps():
    latitude, longitude = 48.8584, 2.2945 
    place_name = "Eiffel Tower, Paris"

    if request.method == 'POST':
        place_name = request.form.get('place')
        latitude, longitude = geocode_place(place_name)

    return render_template('gps_location.html', latitude=latitude, longitude=longitude, place=place_name)

def geocode_place(place_name):
    API_KEY = '315682c906324e26811da4778ed6d002'  # Замени със своя API ключ
    url = f"https://api.opencagedata.com/geocode/v1/json?q={place_name.replace(' ', '+')}&key={API_KEY}"
    response = request.get(url)
    data = response.json()

    if data['results']:
        location = data['results'][0]
        return location['geometry']['lat'], location['geometry']['lng']
    
    return 48.8584, 2.2945