#include <Arduino.h>

#include "Wire.h"

//Maxbotix rangeSensorAD(A6, Maxbotix::AN, Maxbotix::HRLV, Maxbotix::BEST, 5);

int led = 13;  // blink if Bluettoth or MPU not working correctly

/*void sendInt16Valu( &int16_t value) {
  uint8_t length = 2;
  Serial.write(length);
  if(value < 0){
    Serial.write(1);
    value = -(value+1);
  } else {
    Serial.write(0);
  }
  memcpy(destination, &value, length);
  for (uint8_t i = 0; i < length; i++) {
    Serial.write(destination[i]);
  }
}
*/
void setup() {
  
    // for debuging
  pinMode(led, OUTPUT);
    Wire.begin();

    Serial.begin(57600); 
}

void loop() {
    //delay(1000);
     Serial.write(10);
  
}
