#include <SoftwareSerial.h>

// I2Cdev and MPU6050 must be installed as libraries, or else the .cpp/.h files
// for both classes must be in the include path of your project
#include "I2Cdev.h"
#include "MPU6050.h"

// Arduino Wire library is required if I2Cdev I2CDEV_ARDUINO_WIRE implementation
// is used in I2Cdev.h
#if I2CDEV_IMPLEMENTATION == I2CDEV_ARDUINO_WIRE
    #include "Wire.h"
#endif

// class default I2C address is 0x68
// specific I2C addresses may be passed as a parameter here
// AD0 low = 0x68 (default for InvenSense evaluation board)
// AD0 high = 0x69
//MPU6050 accelgyro;
//MPU6050 accelgyro(0x69); // <-- use for AD0 high
MPU6050 accelgyro(0x68);

int16_t ax, ay, az;
int16_t gx, gy, gz;
int count = 0;

#define LED_PIN 13

SoftwareSerial bleShield(2, 3);

long previousMillis = 0;
long interval = 25;  // send with frequency 40 Hrz 
bool blinkState = true;

void setup()
{
  
  /***************
  **** MPU6959 ***
  ***************/
  // join I2C bus (I2Cdev library doesn't do this automatically)
    #if I2CDEV_IMPLEMENTATION == I2CDEV_ARDUINO_WIRE
        Wire.begin();
    #elif I2CDEV_IMPLEMENTATION == I2CDEV_BUILTIN_FASTWIRE
        Fastwire::setup(400, true);
    #endif

    // initialize serial communication
    // (38400 chosen because it works as well at 8MHz as it does at 16MHz, but
    // it's really up to you depending on your project)
    //Serial.begin(57600);
    //Serial.begin(38400);

    // initialize device
    Serial.println("Initializing I2C devices...");
    accelgyro.initialize();
    Serial.println("bla bla");
    // verify connection
    Serial.println("Testing device connections...");
    Serial.println(accelgyro.testConnectionN() );
    Serial.println(accelgyro.testConnection() ? "MPU6050 connection successful" : "MPU6050 connection failed");

    accelgyro.setXGyroOffset(15);
    accelgyro.setYGyroOffset(-5);
    accelgyro.setZGyroOffset(5);
    
    accelgyro.setXAccelOffset(-270);
    accelgyro.setYAccelOffset(-360);
    accelgyro.setZAccelOffset(1788);
     
    // blink LED to indicate activity
    blinkState = !blinkState;
    digitalWrite(LED_PIN, blinkState);
  
  /***************
  ** BLE SHIELD **
  ***************/
  // set the data rate for the SoftwareSerial port
  bleShield.begin(19200);
  Serial.begin(19200);
}

void loop() // run over and over
{ 
  unsigned long currentMillis = millis();
  if(currentMillis - previousMillis > interval) {
    previousMillis = currentMillis;   

      // read raw accel/gyro measurements from device
    //accelgyro.getMotion6(&ax, &ay, &az, &gx, &gy, &gz);
    // these methods (and a few others) are also available
   uint8_t accXYZ[6];
   accelgyro.getAcceleration(&ax, &ay, &az);
   //accelgyro.getAcceleration(accXYZ);
   //accelgyro.getRotation(&gx, &gy, &gz);


    // blink LED to indicate activity
    blinkState = !blinkState;
    digitalWrite(LED_PIN, blinkState);
    
    // rozlozmy ay na na czesci
    /*int8_t tab[4];
    tab[0] = (int8_t)ay;
    tab[1] = (int8_t)(ay >> 8);
    tab[2] = (int8_t)(ay >> 16);
    tab[3] = (int8_t)(ay >> 24); 
   Serial.println(ay); 
    Serial.println(ay,BIN);
  Serial.println((uint8_t)tab[0],BIN);  
    Serial.println((uint8_t)tab[1],BIN);  
      Serial.println((uint8_t)tab[2],BIN);
      Serial.println((uint8_t)tab[3],BIN);    
    bleShield.write((uint8_t)ax);
    bleShield.write((uint8_t)ay);
    bleShield.write((uint8_t)az);
    */ 
    int16_t tab[3];
    tab[0] = ax;
    tab[1] = ay;
    tab[2] = az;
    unsigned char header[3];
    header[0] = 'x';
    header[1] = 'y';
    header[2] = 'z';
    //Serial.println("*****");
    for( int i = 0; i < 3; i++ ){
     // Serial.println(header[i]);      
      Serial.println(tab[i]);      
      bleShield.write( header[i] );
      unsigned short uVal = tab[i] + 32768;//pow(2,15);
      bleShield.write(lowByte(uVal));      
      bleShield.write(highByte(uVal));

      
    //  for( int k = 0; k < 4; k++ ){
    //    bleShield.write( (uint8_t)( tab[i] >> (8+8*(k-1)) ));
        //Serial.println( (uint8_t)( tab[i] >> (8+8*(k-1)) ), BIN );
    //  }
    }
  //  bleShield.write(tail);
    
  }

  if (bleShield.available()) {
    Serial.write(bleShield.read());
  }
}
