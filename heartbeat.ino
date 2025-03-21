#include <Wire.h>
#include "MAX3010x.h"

MAX30105 particleSensor;  

void setup() {
  Serial.begin(9600);
  Serial.println("Starting MAX30102 sensor...");

  Wire.begin(21, 22); 
  if (!particleSensor.begin(Wire)) {
    Serial.println("MAX30102 sensor not found. Check wiring!");
    while (1);
  }


  particleSensor.setup(); 
}
                   
void loop() {
  long irValue = particleSensor.getIR(); 
    if (irValue < 50000) {
    Serial.println("No finger detected");
  } else {
    Serial.print("IR Value: ");
    Serial.println(irValue);
  }


  int bpm;
  if (particleSensor.check() == true) { 
    bpm = particleSensor.getHeartRate(); 
    if (bpm > 0) { 
      Serial.print("💓 BPM: ");
      Serial.println(bpm);
    }
  }

  delay(200); 
}
