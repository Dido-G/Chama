#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>
#include <TinyGPS++.h>
#include <WiFi.h>
#include <WebSocketsClient.h>
#include <ArduinoJson.h>
#include <HTTPClient.h>
#define GPS_BAUD 9600
#define GPSRx 16
#define GPSTx 17

Adafruit_MPU6050 mpu;

TinyGPSPlus gps;

const char* ssid = "TP-LINK_7516";
const char* password = "e0887714303";
const char* serverAddress = "192.168.0.110";
const char* webSocketIp = "192.168.0.111";
const int websocketPort=8080;
const int serverPort = 8080;
WebSocketsClient webSocket;
unsigned long previousMillis = 0;  // Variable to store last time data was sent
const long interval = 2000; 

sensors_event_t accel, gyro, temp;
double longtitude,latitude,altitude;
uint8_t timeHour,timeMinute,timeSecond;
HardwareSerial gpsSerial(2);
void webSocketEvent(WStype_t type, uint8_t* payload, size_t length) {
    switch (type) {
        case WStype_CONNECTED:
            Serial.println("Connected to WebSocket server");
            // webSocket.sendTXT("Hello from ESP32");  // Send a test message after connection
            break;
        case WStype_DISCONNECTED:
            Serial.println("Disconnected from WebSocket server");
            break;
        case WStype_TEXT:
            // This block will handle any text message received
            Serial.print("Received Message: ");
            Serial.println((char*)payload);  // Print received message
            delay(10);
            break;
        case WStype_BIN:
            Serial.println("Received binary data");
            break;
        case WStype_ERROR:
            Serial.println("WebSocket error occurred");
            break;
    }
}
void readMpu6050(){
  mpu.getEvent(&accel, &gyro, &temp);

  /* Print out the values */
  Serial.print("Acceleration X: ");
  Serial.print(accel.acceleration.x);
  Serial.print(", Y: ");
  Serial.print(accel.acceleration.y);
  Serial.print(", Z: ");
  Serial.print(accel.acceleration.z);
  Serial.println(" m/s^2");

  Serial.print("Rotation X: ");
  Serial.print(gyro.gyro.x);
  Serial.print(", Y: ");
  Serial.print(gyro.gyro.y);
  Serial.print(", Z: ");
  Serial.print(gyro.gyro.z);
  Serial.println(" rad/s");

  Serial.print("Temperature: ");
  Serial.print(temp.temperature);
  Serial.println(" degC");

  Serial.println("");
}
void gpsRead(){

  unsigned long start = millis();

  while (gpsSerial.available() > 0) {
    gps.encode(gpsSerial.read());
  }
  if (gps.location.isUpdated()) {
      latitude=gps.location.isValid() ? gps.location.lat() : 0.0;
      Serial.print("Latitude: "); 
      Serial.print(latitude);
      longtitude=gps.location.isValid() ? gps.location.lng() : 0.0;
      Serial.print(" Longitude: "); 
      Serial.print(longtitude);
      altitude=gps.altitude.isValid() ? gps.altitude.meters() : 0.0;
      Serial.print(" Altitude: "); 
      Serial.print(altitude);
      Serial.print(" meters");
      Serial.println();

      Serial.print("Satellites: "); 
      Serial.println(gps.satellites.value());
      timeHour=gps.time.hour();
      timeHour+=2;
      timeMinute=gps.time.minute();
      timeSecond=gps.time.second();
      Serial.print("Time: ");
      Serial.print(timeHour);
      Serial.print(":");
      Serial.print(timeMinute);
      Serial.print(":");
      Serial.print(timeSecond);
      Serial.println();
    }
}
void readSensors(void *params){
  while(1){
    readMpu6050();
    gpsRead();
    vTaskDelay(100 / portTICK_PERIOD_MS);
  }
}
void sendWebsocket(void *params){
  while(1){
    webSocket.loop();  // Maintain WebSocket connection
    unsigned long currentMillis = millis();
    if (currentMillis - previousMillis >= interval) {
      // Save the last time we sent data
      previousMillis = currentMillis;
      String disp="Acceleration: ";
      disp+=String(accel.acceleration.x)+" ";
      disp+=String(accel.acceleration.y)+" ";
      disp+=String(accel.acceleration.z)+" ";
      disp+=" rad/s^2\n\n";
      disp+="Rotation: ";
      disp+=String(gyro.gyro.x)+ " ";
      disp+=String(gyro.gyro.y)+ " ";
      disp+=String(gyro.gyro.z)+ " ";
      disp+=" m/s^2\n\n";
      disp+="Temperature: ";
      disp+=String(temp.temperature);
      disp+=" degC\n\n";
      disp+="Latitude: ";
      disp+=String(latitude)+"\n\n";
      disp+="Longtitude: ";
      disp+=String(longtitude)+"\n\n";
      disp+="Altitude: ";
      disp+=String(altitude)+"\n\n";
      disp+="Time: ";
      disp+=String(timeHour)+":"+String(timeMinute)+":"+String(timeSecond)+"\n\n";
      webSocket.sendTXT(disp);  // Send distance data via WebSocket
    }
    vTaskDelay(10 / portTICK_PERIOD_MS);
  }
}
void sendHttpRequest(void *params) {
  while (1) {
    unsigned long currentMillis = millis();
    if (currentMillis - previousMillis >= interval) {
      previousMillis = currentMillis;

      // Create JSON object
      StaticJsonDocument<256> jsonDoc;
      jsonDoc["acceleration_x"] = accel.acceleration.x;
      jsonDoc["acceleration_y"] = accel.acceleration.y;
      jsonDoc["acceleration_z"] = accel.acceleration.z;
      jsonDoc["rotation_x"] = gyro.gyro.x;
      jsonDoc["rotation_y"] = gyro.gyro.y;
      jsonDoc["rotation_z"] = gyro.gyro.z;
      jsonDoc["temperature"] = temp.temperature;
      jsonDoc["latitude"] = latitude;
      jsonDoc["longitude"] = longtitude;
      jsonDoc["altitude"] = altitude;

      char timeString[9];
      snprintf(timeString, sizeof(timeString), "%02d:%02d:%02d", timeHour, timeMinute, timeSecond);
      jsonDoc["time"] = timeString;

      // Serialize JSON to string
      String jsonPayload;
      serializeJson(jsonDoc, jsonPayload);

      // Send HTTP POST request
      HTTPClient http;
      String serverURL = "http://" + String(serverAddress) + ":" + String(serverPort) + "/data";  // Adjust endpoint
      http.begin(serverURL);
      http.addHeader("Content-Type", "application/json");

      int httpResponseCode = http.POST(jsonPayload);
      if (httpResponseCode > 0) {
        Serial.print("HTTP Response code: ");
        Serial.println(httpResponseCode);
      } else {
        Serial.print("HTTP Error: ");
        Serial.println(httpResponseCode);
      }
      http.end();
      HTTPClient http2;
      serverURL = "http://" + String(webSocketIp) + ":" + String(websocketPort) + "/data";  // Adjust endpoint
      http2.begin(serverURL);
      http2.addHeader("Content-Type", "application/json");

      httpResponseCode = http2.POST(jsonPayload);
      if (httpResponseCode > 0) {
        Serial.print("HTTP Response code: ");
        Serial.println(httpResponseCode);
      } else {
        Serial.print("HTTP Error: ");
        Serial.println(httpResponseCode);
      }
      http2.end();
    }
    vTaskDelay(100 / portTICK_PERIOD_MS);
  }
}

void setup(void) {
  Serial.begin(115200);
  WiFi.begin(ssid, password);
  // Connect to WiFi
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
      delay(1000);
      Serial.print(".");
  }
  Serial.println("\nWiFi connected");
  Serial.print("ESP32 IP: ");
  Serial.println(WiFi.localIP());

  webSocket.begin(webSocketIp, websocketPort, "/");  // Connect to the WebSocket server
  webSocket.onEvent(webSocketEvent);  // Attach event handler
  Serial.println("Adafruit MPU6050 test!");

  // Try to initialize!
  if (!mpu.begin()) {
    Serial.println("Failed to find MPU6050 chip");
    while (1) {
      delay(10);
    }
  }
  Serial.println("MPU6050 Found!");

  mpu.setAccelerometerRange(MPU6050_RANGE_16_G);
  mpu.setGyroRange(MPU6050_RANGE_500_DEG);
  mpu.setFilterBandwidth(MPU6050_BAND_5_HZ);
  
  gpsSerial.begin(GPS_BAUD,SERIAL_8N1,GPSRx,GPSTx);
  xTaskCreatePinnedToCore(readSensors,"Reading sensors function",2000,NULL, 1, NULL, 0);
  xTaskCreatePinnedToCore(sendHttpRequest,"Sends data to website",10000,NULL, 2, NULL, 1);
  // xTaskCreatePinnedToCore(sendWebsocket,"Sends data to website with websocket",10000,NULL, 1, NULL, 1);
}
void loop() {
  /* Get new sensor events with the readings */
  vTaskDelay(10 / portTICK_PERIOD_MS);

}
