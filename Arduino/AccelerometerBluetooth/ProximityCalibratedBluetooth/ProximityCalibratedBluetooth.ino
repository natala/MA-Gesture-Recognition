#include <Arduino.h>
#include "I2Cdev.h"
#include "MPU6050_6Axis_MotionApps20.h"
//#include "MPU6050_9Axis_MotionApps41.h"
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
float yawPitchRoll[3];

int16_t ax, ay, az;
int16_t gx, gy, gz;

boolean initialized = 0;
long previousMillis = 0;
long interval = 25;  // send with frequency 40 Hrz 
bool isSendAcceleration = true;
bool isSendOrientation = false;
byte currentCommand;

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

void sendOrientationData() {
   
    uint8_t length = sizeof(int16_t);
    uint8_t destination[length]; 
    
    // header[0] - length[1] - sign[2] - value[3 ; sizeof(float)+3]
  
  // ORIENTATION: YAW PITCH ROLL
  
  // send yaw
  Serial.write('w');
  Serial.write(length);
  float yaw = yawPitchRoll[0];
  // the precision is anyway 0.xx
  //sendInt16Valu( (int16_t)(yaw*10) );
  //Serial.println("YAW");
  //Serial.println(yaw);
  int16_t intVal = (int16_t)(yaw*100);
  //Serial.println("INT YAW");
  //Serial.println(intVal);
  if(intVal < 0){
    Serial.write(1);
    intVal = -(intVal+1);
  } else {
    Serial.write(0);
  }
  //Serial.println(yaw);
  memcpy(destination, &intVal, length);
  for (uint8_t i = 0; i < length; i++) {
    Serial.write(destination[i]);
  }
  
  // send pitch
  Serial.write('p');
  Serial.write(length);
  float pitch = yawPitchRoll[1];
  //sendInt16Valu( (int16_t)(pitch*10) );
 // Serial.println("PITCH");
 // Serial.println(pitch);
  intVal = (int16_t)(pitch*100);
  //Serial.println("INT PITCH");
  //Serial.println(intVal);
  if(intVal < 0){
    Serial.write(1);
    intVal = -(intVal+1);
  } else {
    Serial.write(0);
  }
  //Serial.println(yaw);
  memcpy(destination, &intVal, length);
  for (uint8_t i = 0; i < length; i++) {
    Serial.write(destination[i]);
  }
  
  // send roll
  Serial.write('r');
  Serial.write(length);
  float roll = yawPitchRoll[2];
  //sendInt16Valu( (int16_t)(roll*10) );
  //Serial.println("ROLL");
  //Serial.println(roll);
  intVal = (int16_t)(roll*100);
  //Serial.println("INT ROLL");
  //Serial.println(intVal);
  if(intVal < 0){
    Serial.write(1);
    intVal = -(intVal+1);
  } else {
    Serial.write(0);
  }
  //Serial.println(yaw);
  memcpy(destination, &intVal, length);
  for (uint8_t i = 0; i < length; i++) {
    Serial.write(destination[i]);
  }

}

void sendLinearAccelerationData(){
  //TEST
  //int16_t minT = -32768;
  //int16_t maxT = 32767;
  //uint16_t uMinT, uMaxT;
 
  // header[0] - length[1] - sign[2] - value[3 - sizeof(uint16_t)+3]
 
  // LINEAR ACCELERATION
  uint8_t length = sizeof(int16_t);
  uint8_t destination[length]; 

   Serial.write('x');
   Serial.write(2);   // the length of the value to be send
   if(aaReal.x < 0){
      Serial.write(1);
     aaReal.x = -(aaReal.x+1); 
   }
   else{
      Serial.write(0); 
   }
   memcpy(destination, &aaReal.x, length);
  for (uint8_t i = 0; i < length; i++) {
    Serial.write(destination[i]);
  }
   //Serial.write(lowByte(aaReal.y));
  //Serial.write(highByte(aaReal.y));
  
  Serial.write('y');
  Serial.write(2);   // the length of the value to be send
   if(aaReal.y < 0){
      Serial.write(1);
     aaReal.y = -(aaReal.y+1); 
   }
   else{
      Serial.write(0); 
   } 
  memcpy(destination, &aaReal.y, length);
  for (uint8_t i = 0; i < length; i++) {
    Serial.write(destination[i]);
  }

  Serial.write('z');
  Serial.write(2);   // the length of the value to be send
   if(aaReal.z < 0){
      Serial.write(1);
     aaReal.z = -(aaReal.z+1); 
   }
   else{
      Serial.write(0); 
   }
  memcpy(destination, &aaReal.z, length);
  for (uint8_t i = 0; i < length; i++) {
    Serial.write(destination[i]);
  }
  // Serial.write(lowByte(aaReal.z));
  //Serial.write(highByte(aaReal.z));
 
  
  /****** OLD CODE ******/
 /*
  // move bits to change signed to unsigned by adding pow(2,15)-1 = 32767;
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
  */
}

void loop() {
    if(initialized){
      
      digitalWrite(led, HIGH);

        // get current FIFO count
        fifoCount = mpu.getFIFOCount();
    
       if (fifoCount == 1024) {
            // reset so we can continue cleanly
            mpu.resetFIFO();
            //Serial.println(F("FIFO overflow!"));
            
        } else {
            // wait for correct available data length, should be a VERY short wait
            while (fifoCount < packetSize) fifoCount = mpu.getFIFOCount();

            // read a packet from FIFO
            mpu.getFIFOBytes(fifoBuffer, packetSize);
            fifoCount -= packetSize;
            
            mpu.dmpGetQuaternion(&q, fifoBuffer);
            //mpu.dmpGetGyro(&gyro,fifoBuffer);
            mpu.dmpGetAccel(&aa, fifoBuffer);
            mpu.dmpGetGravity(&gravity, &q);
            mpu.dmpGetLinearAccel(&aaReal, &aa, &gravity);
            mpu.dmpGetYawPitchRoll(yawPitchRoll, &q, &gravity);
            //mpu.dmpGetLinearAccelInWorld(&aaWorld, &aaReal, &q);
            
            // read raw accel/gyro measurements from device
            //mpu.getMotion6(&ax, &ay, &az, &gx, &gy, &gz);
            
            unsigned long currentMillis = millis();
            if(currentMillis - previousMillis > interval) {
                previousMillis = currentMillis;
                if (isSendAcceleration) {
                  sendLinearAccelerationData();
                }
                if (isSendOrientation) {
                  sendOrientationData();
                }
                isSendAcceleration = !isSendAcceleration;
                isSendOrientation = !isSendOrientation;
             }
     }
   } else {
     // when MPU not working properly
     // send an error
     Serial.write('e');
   }
  
}
