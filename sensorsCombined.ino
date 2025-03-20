#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>
#include <TinyGPS++.h>

#define GPS_BAUD 9600
#define GPSRx 16
#define GPSTx 17
Adafruit_MPU6050 mpu;
TinyGPSPlus gps;
sensors_event_t accel, gyro, temp;
HardwareSerial gpsSerial(2);
void setup(void) {
  Serial.begin(115200);
  while (!Serial)
    delay(10);

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
}

void loop() {
  /* Get new sensor events with the readings */
  readMpu6050();
  gpsRead();
  delay(500);
}
