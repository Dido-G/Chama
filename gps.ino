#include <SoftwareSerial.h>
#include <TinyGPS++.h>

// Create GPS and Serial objects
TinyGPSPlus gps;
SoftwareSerial gpsSerial(A3, A4); // RX, TX (Connect TX of GPS to pin A4, RX to pin A3)

void setup() {
  Serial.begin(9600);       
  gpsSerial.begin(9600);    
  Serial.println("GPS module is starting...");
}

void loop() {
  while (gpsSerial.available() > 0) {
    if (gps.encode(gpsSerial.read())) { 
      displayGPSInfo(); 
    }
  }

  if (millis() > 5000 && gps.charsProcessed() < 10) {
    Serial.println("No GPS detected. Check connections and retry.");
    delay(2000);
  }
}

void displayGPSInfo() {
  Serial.print("Latitude: "); 
  Serial.print(gps.location.isValid() ? gps.location.lat() : 0.0, 6);
  Serial.print(" Longitude: "); 
  Serial.print(gps.location.isValid() ? gps.location.lng() : 0.0, 6);
  Serial.print(" Altitude: "); 
  Serial.print(gps.altitude.isValid() ? gps.altitude.meters() : 0.0);
  Serial.print(" meters");
  Serial.println();

  Serial.print("Satellites: "); 
  Serial.println(gps.satellites.value());
}
