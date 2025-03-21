const int uvPin = 34; 
const float referenceVoltage = 3.3; 

void setup() {
  Serial.begin(115200);  
}
//Test it in daylight, i wrote it at 3:57
void loop() {
  int uvReading = analogRead(uvPin); 
  float voltage = (uvReading / 4095.0) * referenceVoltage;  
  float uvIntensity = (voltage - 0.99) * (15.0 / 1.8);  

if(uvIntensity<0){
  uvIntensity=0;
}
  Serial.print("UV Voltage: ");
  Serial.print(voltage);
  Serial.println(" V");

  Serial.print("UV Intensity: ");
  Serial.print(uvIntensity);
  Serial.println(" mW/cm²");

  delay(1000); 
}
