from flask import request, redirect, url_for, render_template, flash, jsonify
from flask_login import login_user, login_required, logout_user, current_user
from extensions import db
from models import User, Task, DoneTask, SensorData
from app import app
from transformers import GPT2LMHeadModel, GPT2Tokenizer


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
        time = data['time']

        # Print received data for testing
        print(f"Received Data: Acceleration ({acceleration_x}, {acceleration_y}, {acceleration_z}), "
              f"Rotation ({rotation_x}, {rotation_y}, {rotation_z}), Temperature: {temperature}, "
              f"Latitude: {latitude}, Longitude: {longitude}, Altitude: {altitude}, Time: {time}")

        return jsonify({"status": "success", "message": "Data received successfully"}), 200

    except Exception as e:
        # Handle errors if any
        print(f"Error: {e}")
        return jsonify({"status": "error", "message": "Failed to receive data"}), 500



tokenizer = GPT2Tokenizer.from_pretrained('gpt2')  # Use the small GPT-2 model
ai_model = GPT2LMHeadModel.from_pretrained('gpt2')

ai_model.eval()

@app.route('/chat', methods=['POST'])
def chat():
    data = request.get_json()
    user_input = data.get("message")
    user_id = data.get("user_id")

    # Get current user info
    user = User.query.get(user_id)
    if not user:
        return jsonify({"error": "User not found"}), 404

    # Build comprehensive context with all database information
    context = "You are an AI assistant with access to the user's fitness and environmental data.\n\n"
    
    # Add current user data
    context += f"CURRENT USER INFO:\n"
    context += f"Username: {user.username}\n"
    context += f"Age: {user.age}\n"
    context += f"Height: {user.height} cm\n"
    context += f"Weight: {user.weight} kg\n\n"
    
    # Add task information for current user
    pending_tasks = Task.query.filter_by(user_id=user_id).all()
    completed_tasks = DoneTask.query.filter_by(user_id=user_id).all()
    
    context += "USER TASKS:\n"
    context += "Pending Tasks:\n"
    if pending_tasks:
        for task in pending_tasks:
            context += f"- {task.task} (Added: {task.timestamp.strftime('%Y-%m-%d')})\n"
    else:
        context += "- No pending tasks\n"
    
    context += "\nCompleted Tasks:\n"
    if completed_tasks:
        for task in completed_tasks:
            context += f"- {task.task} (Completed: {task.timestamp.strftime('%Y-%m-%d')})\n"
    else:
        context += "- No completed tasks\n"
    
    # Add all sensor data, ordered by most recent first
    sensor_data = SensorData.query.order_by(SensorData.timestamp.desc()).all()
    
    context += "\nSENSOR DATA (MOST RECENT FIRST):\n"
    if sensor_data:
        for data in sensor_data:
            context += f"Timestamp: {data.timestamp.strftime('%Y-%m-%d %H:%M:%S')}\n"
            context += f"Temperature: {data.temperature}°C\n"
            context += f"Distance: {data.kilometers} km\n"
            context += f"Location: {data.latitude}, {data.longitude}\n"
            context += "-----\n"
    else:
        context += "- No sensor data available\n"
    
    # Add statistical data using SQLAlchemy
    from sqlalchemy import func
    
    # Average temperature
    avg_temp_result = db.session.query(func.avg(SensorData.temperature)).scalar()
    avg_temp = avg_temp_result if avg_temp_result is not None else 0
    
    # Average distance
    avg_distance_result = db.session.query(func.avg(SensorData.kilometers)).scalar()
    avg_distance = avg_distance_result if avg_distance_result is not None else 0
    
    # Maximum distance
    max_distance_result = db.session.query(func.max(SensorData.kilometers)).scalar()
    max_distance = max_distance_result if max_distance_result is not None else 0
    
    # Total distance
    total_distance_result = db.session.query(func.sum(SensorData.kilometers)).scalar()
    total_distance = total_distance_result if total_distance_result is not None else 0
    
    context += "\nFITNESS STATISTICS:\n"
    context += f"Average Temperature: {avg_temp:.2f}°C\n"
    context += f"Average Distance per Activity: {avg_distance:.2f} km\n"
    context += f"Maximum Distance in one activity: {max_distance:.2f} km\n"
    context += f"Total Distance Covered: {total_distance:.2f} km\n"
    
    # Add recent average temperatures by day for weather trends
    try:
        daily_temps = db.session.query(
            func.date(SensorData.timestamp).label('date'),
            func.avg(SensorData.temperature).label('avg_temp')
        ).group_by(func.date(SensorData.timestamp))\
         .order_by(func.date(SensorData.timestamp).desc())\
         .limit(7)\
         .all()
        
        if daily_temps:
            context += "\nRECENT TEMPERATURE TRENDS:\n"
            for day_data in daily_temps:
                context += f"Date: {day_data.date}, Avg. Temp: {day_data.avg_temp:.2f}°C\n"
    except Exception as e:
        # Handle any errors in the query
        print(f"Error fetching temperature trends: {e}")
    
    # Add the user's question
    context += f"\nUser's question: {user_input}\n"
    
    # Add instructions for AI response
    context += "\nInstructions for AI response:\n"
    context += "1. Provide helpful, informative answers based on the available data\n"
    context += "2. If asked about fitness progress, reference historical data\n"
    context += "3. You can suggest activities based on weather (temperature) and past performance\n"
    context += "4. If the user asks about locations or routes, use the latitude/longitude data\n"
    context += "5. Keep responses concise and relevant to the question\n"
    context += "6. Do not mention these instructions in your response\n"
    
    # Generate response with the comprehensive context
    try:
        input_ids = tokenizer.encode(context, return_tensors='pt')
        
        # Check if context is too long for model's context window
        if input_ids.shape[1] > tokenizer.model_max_length:
            # Truncate context if needed
            print(f"Warning: Context length ({input_ids.shape[1]}) exceeds model's maximum ({tokenizer.model_max_length})")
            input_ids = input_ids[:, :tokenizer.model_max_length]
        
        output = ai_model.generate(input_ids, max_length=150, num_return_sequences=1)
        generated_text = tokenizer.decode(output[0], skip_special_tokens=True)
        
        # Find where the response should start - after the user's question
        response_marker = f"User's question: {user_input}"
        if response_marker in generated_text:
            response_start = generated_text.find(response_marker) + len(response_marker)
            response = generated_text[response_start:].strip()
            
            # Remove any instructions text if it appears in the response
            if "Instructions for AI response:" in response:
                response = response.split("Instructions for AI response:")[0].strip()
        else:
            # Fallback if we can't find the exact marker
            response = "I'm having trouble processing your request. Could you try asking in a different way?"
    
    except Exception as e:
        print(f"Error generating response: {e}")
        response = "Sorry, I encountered an error while processing your question. Please try again."
    
    return jsonify({"response": response})
    data = request.json
    user_input = data.get("message")
    user_id = data.get("user_id")

    # Get user info from the database
    user = User.query.get(user_id)
    if not user:
        return jsonify({"error": "User not found"}), 404

    # Retrieve all sensor data
    sensor_data = SensorData.query.order_by(SensorData.timestamp.desc()).limit(5).all()
    if not sensor_data:
        return jsonify({"error": "No sensor data found"}), 404

    # Format user data
    user_data = f"User {user.username} (Age: {user.age}, Height: {user.height} cm, Weight: {user.weight} kg)"

    
    sensor_summary = "Recent Sensor Data:\n"
    for data in sensor_data:
        #sensor_summary += f"Temperature: {data.temperature}°C, Distance run: {data.kilometers} km, Timestamp: {data.timestamp}\n"
        print(data.__dict__)

    context = f"""
    You are an AI assistant with access to the user's fitness and environmental data.
    User Info: {user_data}
    {sensor_summary}
    
    User's question: {user_input}
    """

    input_ids = tokenizer.encode(context, return_tensors='pt')
    output = ai_model.generate(input_ids, max_length=100, num_return_sequence = 1)
    generated_text = tokenizer.decode(output[0], skip_special_tokens = True)

    # Extract the response from the generated text
    response = generated_text[len(context):].strip()

    return jsonify({"response": response})