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

void sendTest() {

  uint8_t package[5];
 // package[0] = 'b';
 // package[1] = '1';
 // package[2] = 'e';
 // Serial.write('a');
 // Serial.write('m');
  int16_t val = 10;
  uint8_t dest[2];
  memcpy(dest, &val, 2);
 // Serial.write(dest[0]);
 // Serial.write(dest[1]);
 // Serial.write('b');
  package[0] = 'a';
  package[1] = 'm';
  package[2] = dest[0];
  package[3] = dest[1];
  package[4] = 'b';
  Serial.write(package, 5);
  
  
}

void sendQuaternions() {
    uint8_t length = sizeof(int16_t);
    uint8_t destination[length]; 
    uint8_t packageLength = 14;
    uint8_t package[packageLength];
    uint8_t signs[4];
    uint8_t destX[2];
    uint8_t destY[2];
    uint8_t destZ[2];
    uint8_t destW[2];
    
  int16_t intVal = (int16_t)(q.w);
  if(intVal < 0){
    signs[0] = 'm';
    intVal = -(intVal+1);
  } else {
    signs[0] = 'p';
  }
  memcpy(destW, &intVal, 2);
  
  intVal = (int16_t)(q.x);
  if(intVal < 0){
    signs[1] = 'm';
    intVal = -(intVal+1);
  } else {
    signs[1] = 'p';
  }
  memcpy(destX, &intVal, 2);
  
  intVal = (int16_t)(q.y);
  if(intVal < 0){
    signs[2] = 'm';
    intVal = -(intVal+1);
  } else {
    signs[2] = 'p';
  }
  memcpy(destY, &intVal, 2);

  intVal = (int16_t)(q.z);
  if(intVal < 0){
    signs[3] = 'm';
    intVal = -(intVal+1);
  } else {
    signs[3] = 'p';
  }
  memcpy(destZ, &intVal, 2);
  
  //begin
  package[0] = 'a';
  //w
  package[1] = signs[0];
  package[2] = destW[0];
  package[3] = destW[1];
  //x
  package[4] = signs[1];
  package[5] = destX[0];
  package[6] = destX[1];
  //y
  package[7] = signs[2];
  package[8] = destY[0];
  package[9] = destY[1];
  //z
  package[10] = signs[3];
  package[11] = destZ[0];
  package[12] = destZ[1];
  //end
  package[13] = 'b';
  
  Serial.write(package,packageLength);
}

 
  
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
           // Serial.println("bla bla");
            //mpu.dmpGetLinearAccelInWorld(&aaWorld, &aaReal, &q);
            
            // read raw accel/gyro measurements from device
            //mpu.getMotion6(&ax, &ay, &az, &gx, &gy, &gz);
            
            unsigned long currentMillis = millis();
            if(currentMillis - previousMillis > interval) {
                previousMillis = currentMillis;
                //sendQuaternions();
                sendTest();
             }
     }
   } else {
   //  Serial.write('e');
   }
  
}
