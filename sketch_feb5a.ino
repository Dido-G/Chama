
#include <WiFi.h>
#include <WebSocketsClient.h>

const char* ssid = "InnovationForumGuests";     // Replace with your WiFi name
const char* password = ""; // Replace with your WiFi password
const char* serverAddress = "10.1.171.89"; // Example: "192.168.1.100"
const int serverPort = 8080;
#define echoPin 25               // CHANGE PIN NUMBER HERE IF YOU WANT TO USE A DIFFERENT PIN
#define trigPin 14               // CHANGE PIN NUMBER HERE IF YOU WANT TO USE A DIFFERENT PIN
long duration, distance;
WebSocketsClient webSocket;

int myLEDPIN = 13 ; 
unsigned long previousMillis = 0;  // Variable to store last time data was sent
const long interval = 5000; 
void webSocketEvent(WStype_t type, uint8_t* payload, size_t length) {
    switch (type) {
        case WStype_CONNECTED:
            Serial.println("Connected to WebSocket server");
            webSocket.sendTXT("Hello from ESP32");  // Send a test message after connection
            break;
        case WStype_DISCONNECTED:
            Serial.println("Disconnected from WebSocket server");
            break;
        case WStype_TEXT:
            // This block will handle any text message received
            Serial.print("Received Message: ");
            Serial.println((char*)payload);  // Print received message

                if (strncmp((char*)payload, "HIGH", length) == 0) {
                digitalWrite(myLEDPIN, HIGH);  // Turn LED on
            } else if (strncmp((char*)payload, "LOW", length) == 0) {
                digitalWrite(myLEDPIN, LOW);  // Turn LED off
            }
            
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

void setup() {
    Serial.begin(115200);

 pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);

    WiFi.begin(ssid, password);
 pinMode(myLEDPIN, OUTPUT);
    // Connect to WiFi
    Serial.print("Connecting to WiFi");
    while (WiFi.status() != WL_CONNECTED) {
        delay(1000);
        Serial.print(".");
    }
    Serial.println("\nWiFi connected");
    Serial.print("ESP32 IP: ");
    Serial.println(WiFi.localIP());

    // Connect to WebSocket server
    Serial.println("Connecting to WebSocket server...");
    webSocket.begin(serverAddress, serverPort, "/");  // Connect to the WebSocket server
    webSocket.onEvent(webSocketEvent);  // Attach event handler
   
}

void loop() {
    webSocket.loop();  // Maintain WebSocket connection

    unsigned long currentMillis = millis();
    if (currentMillis - previousMillis >= interval) {
        // Save the last time we sent data
        previousMillis = currentMillis;

        // Measure distance
        digitalWrite(trigPin, LOW);
        delayMicroseconds(2);
        digitalWrite(trigPin, HIGH);
        delayMicroseconds(10);
        digitalWrite(trigPin, LOW);

        duration = pulseIn(echoPin, HIGH);
        distance = duration / 58.2;
        String disp = String(distance);

        // Send the measured distance
        Serial.print("Sending distance: ");
        Serial.println(disp);
        webSocket.sendTXT(disp);  // Send distance data via WebSocket
    }
    
}
