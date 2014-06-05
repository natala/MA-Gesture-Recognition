/*
  MPU-6050 accelerometer demo - the Processing part
  by M. Kratochvil, 2013
  
  Reads the accelerometer data from the serial port and displays it
  using Meter objects. The received data should be in the format:

  "A" + x,x + ";" + y,y + ";" + z,z + "\n"
  
  ..where x,x, y,y and z,z are the 2 bytes for each axis respectively.
  (The measurements are x, y and z are as 16-bit integers.)
  
  Receiving is done in the draw() function. However, there is also
  another way: serialEvent(). It Just Works like so:
  
  void serialEvent(Serial port) {
    while (port.available() > 0) {
      int ch = port.read();
      ..do you thing here..
    }
  }
  
  For deails, see:
  http://processing.org/reference/libraries/serial/index.html
  http://processing.org/reference/libraries/serial/serialEvent_.html
*/


import processing.serial.*;

// Serial
Serial serialPort;
int serialDataBuffer[] = new int[10];
int serialDataIndex = 0;

// Meter
Meter meterX;
Meter meterY;
Meter meterZ;

Meter meterAbs;
void setup() {

  size( 550, 550);
  frameRate( 30); // 60 by default (Changed it just because I can :)
  
  // Meter's constructor: name, miminal value, maximum value, current measurement, x position, y position.
  // Note to self: unsigned int 0, 65535, 32767. signed int -32768, 32767, 0
  meterX = new Meter( "X-axis", -32768, 32767, 0, 50, 50);
  meterY = new Meter( "Y-axis", -32768, 32767, 0, 300, 50);
  meterZ = new Meter( "Z-axis", -32768, 32767, 0, 50, 300);
  meterAbs = new Meter( "Accel. vector length upward and forward", -32768, 32767, 0, 300, 300); // (4^2 + 4^2 + 4^2) ^(1/2) ~ 6.9

  // Open 2nd visible serial port  
  //String portName = "/dev/tty.usbmodem1421";
  String portName = "/dev/tty.usbserial-A900fu94";
  serialPort = new Serial(this, portName, 57600);//115200);

}


void draw() {

  while( serialPort.available() > 0) {
    serialDataBuffer[ serialDataIndex] = serialPort.read();
    
    if( serialDataIndex <= 0 && serialDataBuffer[ serialDataIndex] != 'A') {
      serialDataIndex = 0; // ..not really necessary at this point
      continue;
    }

    if( serialDataIndex == 3 && serialDataBuffer[ serialDataIndex] != ';') {
      serialDataIndex = 0;
      continue;
    }

    if( serialDataIndex == 6 && serialDataBuffer[ serialDataIndex] != ';') {
      serialDataIndex = 0;
      continue;
    }

    if( serialDataIndex == 9 && serialDataBuffer[ serialDataIndex] == '\n') {
      println("Here:" + serialDataBuffer[ serialDataIndex] );
      // Looks like we've reached the end of a data packet. Let's make sense of it.
      // The MPU sends 16-bit signed integers. Casting to short (16-bit) to recreate "signedness".
      int x = (short)((serialDataBuffer[1] << 8) | serialDataBuffer[2]);
      int y = (short)((serialDataBuffer[4] << 8) | serialDataBuffer[5]);
      int z = (short)((serialDataBuffer[7] << 8) | serialDataBuffer[8]);

      // put it out on display      
      meterX.setMeasurement( x);
      meterY.setMeasurement( y);
      meterZ.setMeasurement( z);
        float total = sqrt( y*y + z*z);
        println("X: " + x);
          println("Y: " + y);
            println("Z: " + z);
      meterAbs.setMeasurement(total);
      
      // Then look for more.
      serialDataIndex = 0;
      continue;
    }

    serialDataIndex++;
    if( serialDataIndex >= 10) serialDataIndex = 0;
  } // while
    

  

  // clear screen  
  background( 200);

  // (uses values given in constructor on 1st call)
  meterX.drawToScreen();
  meterY.drawToScreen();
  meterZ.drawToScreen();
  meterAbs.drawToScreen();
}


