from flask import request, redirect, url_for, render_template, flash
from flask_login import login_user, login_required, logout_user, current_user
from app import app, db
from models import User, Task, DoneTask


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
            return redirect(url_for('profile'))  # Redirect to profile
        
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
    return redirect(url_for('profile'))


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
    return redirect(url_for('profile'))
