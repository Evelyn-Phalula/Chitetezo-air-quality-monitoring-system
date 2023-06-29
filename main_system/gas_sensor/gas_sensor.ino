//Define the analog pin to which the sensor is connected
#define MQ135_PIN A0

void setup() {
  //Initialize serial communication at 9600 baud
  Serial.begin(9600);
}

void loop() {
  //Read the analog value from the sensor
  int sensorValue = analogRead(MQ135_PIN);

  //Convert the analog  reading to a concentration value
  float ppm = sensorValue * 100.0 / 1023.0;

  
  //Print the ppm value to the serial monitor
  Serial.println(ppm);
  

  //Wait for 1 second before taking the next reading
  delay(1000);
}
