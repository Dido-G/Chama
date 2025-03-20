import requests

def get_weather(latitude, longitude):
    """Fetches the current weather data and returns it as a dictionary."""
    url = f"https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&current_weather=true"
    
    response = requests.get(url)
    
    if response.status_code == 200:
        data = response.json()
        weather = data["current_weather"]
        return {
            "temperature": weather["temperature"],
            "wind_speed": weather["windspeed"],
            "weather_code": weather["weathercode"]
        }
    else:
        return {"error": "Failed to retrieve weather data"}

def weather_today(latitude, longitude):
    """Fetches today's weather data in 3-hour intervals and returns it as a dictionary."""
    url = f"https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&hourly=temperature_2m,windspeed_10m,weathercode&timezone=auto"
    
    response = requests.get(url)

    if response.status_code == 200:
        data = response.json()
        hours = data["hourly"]["time"]
        temperatures = data["hourly"]["temperature_2m"]
        wind_speeds = data["hourly"]["windspeed_10m"]
        weather_codes = data["hourly"]["weathercode"]
        weather_data = {}
        for i in range(0, len(hours), 3): 
            weather_data[hours[i]] = {
                "temperature": temperatures[i],
                "wind_speed": wind_speeds[i],
                "weather_code": weather_codes[i]
            }

        return weather_data
    else:
        return {"error": "Failed to retrieve weather data"}

def weather_expected(latitude, longitude):
    url = f"https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&daily=temperature_2m_max,windspeed_10m_max&timezone=auto"
    
    response = requests.get(url)
    
    if response.status_code == 200:
        data = response.json()
        return {
            "date": data["daily"]["time"][1], 
            "temperature_max": data["daily"]["temperature_2m_max"][1],  
            "wind_speed_max": data["daily"]["windspeed_10m_max"][1]    
        }
    else:
        return {"error": "Failed to retrieve weather forecast"}


latitude, longitude = 42.82,23.23  

current_weather = get_weather(latitude, longitude)
today_weather = weather_today(latitude, longitude)
expected_weather = weather_expected(latitude, longitude)

print("Current Weather:", current_weather)
print("Today's Weather (Every 3 Hours):", today_weather)
print("Expected Weather:", expected_weather)
