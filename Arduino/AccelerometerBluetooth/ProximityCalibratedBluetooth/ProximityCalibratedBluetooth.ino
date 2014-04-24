#include <Arduino.h>
#include "I2Cdev.h"
#include "MPU6050_6Axis_MotionApps20.h"
#include "Wire.h"

//Maxbotix rangeSensorAD(A6, Maxbotix::AN, Maxbotix::HRLV, Maxbotix::BEST, 5);
MPU6050 mpu;

uint8_t devStatus;      // return status after each device operation (0 = success, !0 = error)
uint16_t packetSize;    // expected DMP packet size (default is 42 bytes)
uint16_t fifoCount;     // count of all bytes currently in FIFO
uint8_t fifoBuffer[64]; // FIFO storage buffer

VectorInt16 gyro;
VectorInt16 aa;
VectorInt16 aaReal;
VectorInt16 aaWorld;
VectorFloat gravity;
Quaternion q;

boolean initialized = 0;
long previousMillis = 0;
long interval = 25;  // send with frequency 40 Hrz
byte currentCommand;

int led = 13;  // blink if Bluettoth or MPU not working correctly

void setup() {
  
    // for debuging
  pinMode(led, OUTPUT);
digitalWrite(led, HIGH);
    Wire.begin();
    TWBR = 24; // 400kHz I2C clock (200kHz if CPU is 8MHz)

    Serial.begin(57600); 
    
    //pinMode(RED_LED,OUTPUT);
    //pinMode(GREEN_LED,OUTPUT);
        
    mpu.initialize();
    devStatus = mpu.dmpInitialize();   
    
    mpu.setXAccelOffset(-2153);
    mpu.setYAccelOffset(1333);
    mpu.setZAccelOffset(1455);
   
    mpu.setXGyroOffset(29);
    mpu.setYGyroOffset(18);
    mpu.setZGyroOffset(-16);
    
    // make sure it worked (returns 0 if so)
    if (devStatus == 0) {
        mpu.setDMPEnabled(true);
        packetSize = mpu.dmpGetFIFOPacketSize();
        initialized = 1;
        
    } else {
        // ERROR!
        // 1 = initial memory load failed
        // 2 = DMP configuration updates failed
        // (if it's going to break, usually the code will be 1)
        Serial.write(-1);
        initialized = 0;
    }
}


void sendData(){

    // move bits to change signed to unsigned by adding pow(2,15) = 32768;
  unsigned short gx = (gravity.x + 1.0) * 32768;
  unsigned short gy = (gravity.y + 1.0) * 32768;
  unsigned short gz = (gravity.z + 1.0) * 32768;
 
 // send the header first and than the data
  Serial.write('x');
  Serial.write(lowByte(gx));
  Serial.write(highByte(gx));
  
  Serial.write('y');
  Serial.write(lowByte(gy));
  Serial.write(highByte(gy));
  
  Serial.write('z');
  Serial.write(lowByte(gz));
  Serial.write(highByte(gz));
}

/*
void processCommand(byte currentCommand){
  
  switch(currentCommand){
  
    case 0:
    //  digitalWrite(GREEN_LED,LOW);
    break;
    
    case 1:
    //  digitalWrite(GREEN_LED,HIGH);
    break;
  }
}
*/

void loop() {
  
 // read data
/* 
  while(Serial.available()){
      
      currentCommand = Serial.read();
      processCommand(currentCommand);
    }
    */

    if(initialized){

        // get current FIFO count
        fifoCount = mpu.getFIFOCount();
    
       if (fifoCount == 1024) {
            // reset so we can continue cleanly
            mpu.resetFIFO();
            //Serial.println(F("FIFO overflow!"));
            
        } else {
          digitalWrite(led, LOW);  // turn off the led, everythink is fine
            // wait for correct available data length, should be a VERY short wait
            while (fifoCount < packetSize) fifoCount = mpu.getFIFOCount();

            // read a packet from FIFO
            mpu.getFIFOBytes(fifoBuffer, packetSize);
            fifoCount -= packetSize;
            
            mpu.dmpGetQuaternion(&q, fifoBuffer);
            //mpu.dmpGetGyro(&gyro,fifoBuffer);
            //mpu.dmpGetAccel(&aa, fifoBuffer);
            mpu.dmpGetGravity(&gravity, &q);
            //mpu.dmpGetLinearAccel(&aaReal, &aa, &gravity);
            //mpu.dmpGetLinearAccelInWorld(&aaWorld, &aaReal, &q);
            
            unsigned long currentMillis = millis();
        
            if(currentMillis - previousMillis > interval) {
                previousMillis = currentMillis;
                sendData();
            }
     }
   } else {
     // when MPU not working properly
     digitalWrite(led, HIGH);
     // send an error
     Serial.write('e');
   }
  
}
