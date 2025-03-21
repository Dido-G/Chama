from flask import request, redirect, url_for, render_template, flash, jsonify
from flask_login import login_user, login_required, logout_user, current_user
from extensions import db
from models import User, Task, DoneTask, SensorData
from app import app
from sqlalchemy import func
import math
from langchain_ollama import OllamaLLM
from langchain_core.prompts import ChatPromptTemplate
from google.auth.transport import requests
from google.oauth2 import id_token

app.secret_key = "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"  # Required for session handling

GOOGLE_CLIENT_ID = "1090982044497-fjqbk8nh6234ne3blkve1bpe2secit85.apps.googleusercontent.com"

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

#Get user info
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
@app.route('/google-login', methods=['POST'])
def google_login():
    try:
        data = request.get_json()
        token = data.get("token")

        # Verify the token
        id_info = id_token.verify_oauth2_token(token, requests.Request(), GOOGLE_CLIENT_ID)

        user = User.query.filter_by(username=id_info["email"]).first()
        if user:
            login_user(user)
            return jsonify({"success": True, "email": id_info['email']}), 200  # Explicit success response
        else:
            user = User(username=id_info["email"], password=1, age=1,height=1,weight=1)
            db.session.add(user)
            db.session.commit()      
            login_user(user)  
            return jsonify({"success": True, "email": id_info['email']}), 200  # Explicit success response

    except Exception as e:
        print("Error:", str(e))  # Log error to terminal
        return jsonify({"success": False, "error": str(e)}), 400  # Explicit error response

ai_model = OllamaLLM(model="llama3")

# Chatbot Route for Llama

@app.route('/chat', methods=['POST'])
@login_required
def chat():
    user_message = request.form.get('message')
    if not user_message:
        return jsonify({'error': 'Message cannot be empty!'}), 400

    # Extract all fields from the User model
    db_keywords = {
        'age': current_user.age,
        'height': current_user.height,
        'weight': current_user.weight
    }
    
    # Sensor data keywords - these don't need user_id filtering
    sensor_keywords = ['temperature', 'kilometers', 'latitude', 'longitude', 'steps', 
                      'acceleration_x', 'acceleration_y', 'acceleration_z', 
                      'rotation_x', 'rotation_y', 'rotation_z']

    # Function to check for each keyword in the message and return corresponding data
    def check_message_for_keywords(message, db_keywords, sensor_keywords):
        message = message.lower()

        # First check User-data keywords
        for keyword, value in db_keywords.items():
            if keyword in message and value is not None:
                return f"Your {keyword} is {value}."
        
        #check sensor data keywords
        for keyword in sensor_keywords:
            if keyword in message:
                sensor_data = SensorData.query.order_by(SensorData.timestamp.desc()).first()
                if sensor_data and hasattr(sensor_data, keyword) and getattr(sensor_data, keyword) is not None:
                    return f"Your {keyword} is {getattr(sensor_data, keyword)}."
                else:
                    return f"I couldn't find your {keyword} data."
        
        # If no relevant data is found, return None to indicate the AI should respond
        return None

    # Check if the message contains any relevant keywords
    db_response = check_message_for_keywords(user_message, db_keywords, sensor_keywords)
    
    if db_response:
        return jsonify({'response': db_response}), 200

    # If no data from db matched, use the AI model to generate a response
    prompt_template = ChatPromptTemplate.from_messages([
        ("system", "You are an assistant that helps with various tasks."),
        ("user", user_message)
    ])
    
    # Accessing the 'content' using the attribute/method
    prompt_str = "\n".join([message.content for message in prompt_template.format_messages()])

    try:
        response = ai_model.invoke(prompt_str)  # Pass the formatted string to invoke()

        # Check if the response is a string or a dictionary
        if isinstance(response, str):
            bot_reply = response  # If it's a string, use it directly
        else:
            bot_reply = response.get('text', 'No response text found')

        return jsonify({'response': bot_reply}), 200
    except Exception as e:
        print(f"Error with Llama model: {e}")
        return jsonify({'error': 'Error generating response from the model'}), 500

@app.route('/gps', methods=['GET', 'POST'])
@login_required
def gps():
    # Get the latest sensor data from the database
    sensor_data = SensorData.query.order_by(SensorData.timestamp.desc()).first()
    
    if sensor_data:
        latitude = sensor_data.latitude
        longitude = sensor_data.longitude
    else:
        # Handle the case where no sensor data is available
        flash('No sensor data available.', 'warning')
        latitude, longitude = None, None

    return render_template('map.html', latitude=latitude, longitude=longitude)


def geocode_place(place_name):
    API_KEY = '315682c906324e26811da4778ed6d002'  # Замени със своя API ключ
    url = f"https://api.opencagedata.com/geocode/v1/json?q={place_name.replace(' ', '+')}&key={API_KEY}"
    response = request.get(url)
    data = response.json()

    if data['results']:
        location = data['results'][0]
        return location['geometry']['lat'], location['geometry']['lng']
    
    return 48.8584, 2.2945