#include <Wire.h>
#include <MPU6050.h>

MPU6050 mpu;

float gyroX_offset = 0, gyroY_offset = 0, gyroZ_offset = 0;
bool isCalibrated = false;

void setup() {
  Serial.begin(9600);
  Wire.begin();

  Serial.println("Initializing MPU6050...");

  mpu.initialize();

  if (!mpu.testConnection()) {
    Serial.println("MPU6050 connection failed!");
    while (1);
  }

  Serial.println("MPU6050 connected successfully!");
  
  calibrateGyro();  
}

void calibrateGyro() {
  Serial.println("Calibrating... Keep the sensor **still**.");
  
  int numSamples = 500;
  float sumX = 0, sumY = 0, sumZ = 0;

  for (int i = 0; i < numSamples; i++) {
    int16_t gx, gy, gz;
    mpu.getRotation(&gx, &gy, &gz);

    sumX += gx;
    sumY += gy;
    sumZ += gz;
    
    delay(3);
  }

  gyroX_offset = sumX / numSamples;
  gyroY_offset = sumY / numSamples;
  gyroZ_offset = sumZ / numSamples;

  Serial.println("Calibration Complete!");
  Serial.print("Offsets - X: "); Serial.print(gyroX_offset);
  Serial.print(" Y: "); Serial.print(gyroY_offset);
  Serial.print(" Z: "); Serial.println(gyroZ_offset);

  isCalibrated = true;
}

void loop() {
  int16_t ax, ay, az;
  int16_t gx, gy, gz;

  mpu.getAcceleration(&ax, &ay, &az);
  mpu.getRotation(&gx, &gy, &gz);

  float accelX = ax / 16384.0;
  float accelY = ay / 16384.0;
  float accelZ = az / 16384.0;

  float gyroX = (gx - gyroX_offset) / 131.0;
  float gyroY = (gy - gyroY_offset) / 131.0;
  float gyroZ = (gz - gyroZ_offset) / 131.0;

  Serial.print("Accel (g): X="); Serial.print(accelX, 2);
  Serial.print(" Y="); Serial.print(accelY, 2);
  Serial.print(" Z="); Serial.println(accelZ, 2);

  Serial.print("Gyro (°/s): X="); Serial.print(gyroX, 2);
  Serial.print(" Y="); Serial.print(gyroY, 2);
  Serial.print(" Z="); Serial.println(gyroZ, 2);

  Serial.println("----------------------");
  delay(500);
}
