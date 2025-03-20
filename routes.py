from flask import request, redirect, url_for, render_template
from flask_login import login_user, login_required, logout_user, current_user
from app import app, db
from models import User


# Home route
@app.route('/')
def home():
    return render_template('home.html')


# Register page
@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        age = request.form['age']
        height = request.form['height']
        weight = request.form['weight']

        user = User(username=username, age=age, height=height, weight=weight)
        user.set_password(password)  # Hash the password before saving
        db.session.add(user)
        db.session.commit()
        
        return redirect(url_for('login'))
    
    return render_template('register.html')  # Show register form

# Login Route
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        user = User.query.filter_by(username=username).first()
        if user and user.check_password(password): 
            login_user(user)
            return redirect(url_for('profile'))  # Redirect to profile
        
        return "Invalid login!" 

    return render_template('login.html')  # Show login form

# Profile Route
@app.route('/profile')
@login_required 
def profile():
    return render_template('profile.html', user=current_user)
