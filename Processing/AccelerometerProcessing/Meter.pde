/*
Meter 1.1
written by M. Kratochvil, January 2013

This code is released as Apathyware:
"The code doesn't care what you do with it, and neither do I."

Needed a dial indicator, so I wrote one. Here it is.

- Has a nice dial of 270 degrees (3/4 PI)
- Has an array for past 100 samples
- Indicates min and max values (taken from current and past 100 samples)
- Samples over max and under min values will be clipped to max or min.

Fixes:
 v1.1 Now works correctly also with negative measurements..

*/

class Meter {

  private String label; // on-screen label
  private float minimum, maximum; // value range
  private int x, y; // on-screen coordinates top left
  private float measurement; // measurement value
  private float minMeasurement;
  private float maxMeasurement;

  // previousMeasurements
  private final int previousMeasurementsCount = 100;
  private float previousMeasurements[] = new float[ previousMeasurementsCount];
  private int previousMeasurementsIndex = 0; // keeps track of array filling up

  // screen size
  private final int meterHeight = 200;
  private final int meterWidth = 200;

  // Constructor...
  // assert minimum < maximum
  public Meter( String label, float minimum, float maximum, float currentMeasurement, int x, int y) {
    this.label = label;
    this.minimum = minimum;
    this.maximum = maximum;
    this.x = x;
    this.y = y;
    this.measurement = currentMeasurement;
    
    // in case we're measuring out of range
    this.measurement = constrain( this.measurement, minimum, maximum);
    
    // continue initializing..
    this.minMeasurement = this.measurement;
    this.maxMeasurement = this.measurement;
  }


  public void setMeasurement( float currentMeasurement) {
    
    // keep array in order by advancing it - it's slow, but keeps things simple
    for( int i = previousMeasurements.length - 2; i >= 0; i--) {
      previousMeasurements[ i+1] = previousMeasurements[ i];
    }
    
    // now the head of the array can be used to store the new value
    previousMeasurements[ 0] = this.measurement;
    
    // increase the fill-up counter if necessary
    if( previousMeasurementsIndex < previousMeasurements.length) previousMeasurementsIndex++;
    
    // now, lets deal with the new measurement
    this.measurement = constrain( currentMeasurement, minimum, maximum);
  }


  public void drawToScreen() {
    // MEMO: Color settings: background, fill, stroke
    
    int centerX = x + meterWidth /2;
    int centerY = y + meterHeight /2;

    smooth();
    drawFrame( x, y, meterWidth, meterHeight);
    drawRim( centerX, centerY, meterHeight /4);
    drawPreviousMeasurementsOnRim( centerX, centerY, meterHeight /4); // History in Rim (phosphorous effect)
    drawNeedle( centerX, centerY, meterHeight /4);
    drawLabelText();
    drawMeasurementText( centerX, centerY, meterHeight /4); // measurement as text
    drawMinMaxMeasurementText( centerX, centerY, meterHeight /4); // Min Max measurements in history as text

  }    


  private void drawFrame( int x, int y, int xLen, int yLen) {

    stroke( 0);
    fill( 230);
    
    strokeWeight( 3);
    strokeJoin( ROUND);

    beginShape(); // instead of just using: rect( x, y, xLen, yLen);
    vertex( x, y);
    vertex( x + xLen, y);
    vertex( x + xLen, y + yLen);
    vertex( x, y + yLen);
    vertex( x, y);
    endShape();
  }


  private void drawRim( int centerX, int centerY, int radius) {

    stroke( 0);
    noFill();
    strokeWeight( 10);
    strokeCap( ROUND);
    arc( centerX, centerY, radius *2, radius *2, HALF_PI + QUARTER_PI, TWO_PI + QUARTER_PI);
  }


  private void drawPreviousMeasurementsOnRim( int centerX, int centerY, int radius) {

    // I want to draw the "phosphorous effect" as arc segments.. The rims total arc length is:
    float rimsArcLength = (PI + HALF_PI) * radius; // [pixels]
    
    // Need to find out how thick the needle is..
    int needleThickness = 8; // [pixels]

    // needlesArc / needleThickness =(is approximately equal to)= rimsArc / rimsArcLenght
    float needlesArc =  needleThickness / rimsArcLength; // [radians]

    // go through previous measurements starting from the last element
    strokeWeight( 10);
    strokeCap( ROUND);
    for( int i = previousMeasurementsIndex - 1; i>=0; i--) {
      
      float angleOfOldMeasurement = HALF_PI + QUARTER_PI + ( (previousMeasurements[i] - minimum) / (maximum - minimum) * (PI + HALF_PI));
      
      stroke( 200 - i*2);
      arc( centerX, centerY, radius *2, radius *2, angleOfOldMeasurement - needlesArc/2, angleOfOldMeasurement + needlesArc/2);
    }
  }


  private void drawNeedle( int centerX, int centerY, int radius) {
    
    // figure out the end point on the dial
    float measurementRange = maximum - minimum;
    float dialRange = PI + HALF_PI;
    float pointOnDialRange = (measurement - minimum) * dialRange / measurementRange;
    float pointAsArcEndPoint = HALF_PI + QUARTER_PI + pointOnDialRange;
    
    int pointX = (int)( cos(pointAsArcEndPoint) * (radius)) + centerX;
    int pointY = (int)( sin(pointAsArcEndPoint) * (radius)) + centerY;

    stroke( 0);
    fill( 230);
    strokeWeight( 8);
    line( centerX, centerY, pointX, pointY);
  }


  private void drawLabelText() {

    stroke( 0);
    fill( 40);
    textSize( 15); // TODO: might be nice to change this dynamically
    textAlign( CENTER);
    text( this.label, this.x + meterWidth /2, this.y + meterHeight / 8);
  }

  private void drawMeasurementText( int centerX, int centerY, int radius) {

    String t = formatMeasurementValue_2Decimals( this.measurement); // form a string with 2 decimal points. rounds ok.
    //String t = formatMeasurementValue_TrimZerosAfterDecimalPoint( this.measurement); // another formating option..
    
    stroke( 0);
    fill( 40);
    textSize( 20); // TODO: might be nice to change this dynamically
    textAlign( CENTER);
    text( t, centerX, centerY + radius);
  }

  private void drawMinMaxMeasurementText( int centerX, int centerY, int radius) {
   
    float smallest = this.measurement; // include current measurement
    float largest = this.measurement;
    for( int i=0; i<previousMeasurementsIndex; i++) {
      if( previousMeasurements[i] < smallest) smallest = previousMeasurements[i];
      if( previousMeasurements[i] > largest) largest = previousMeasurements[i];
    }
    
    // create the strings
    String tMin = formatMeasurementValue_2Decimals( smallest);
    String tMax = formatMeasurementValue_2Decimals( largest);
    
    stroke( 0);
    textSize( 12); // TODO: might be nice to change this dynamically
    textAlign( LEFT);
    
    if( smallest == minimum) fill( 0);
    else fill( 100);
    text( "min: " + tMin, this.x + meterWidth * 1/8, y + meterHeight * 7/8);
    
    if( largest == maximum) fill( 0);
    else fill( 100);
    text( "max: " + tMax, this.x + meterWidth * 5/8, y + meterHeight * 7/8);
  }

  //
  // next: a couple of methods to format float values to String
  // more on string formating, see: http://stackoverflow.com/questions/703396/how-to-nicely-format-floating-types-to-string
  //

  private String formatMeasurementValue_2Decimals( float f) {
    return String.format("%.2f", f);
    
    // Note: Could perhaps also be
    // new DecimalFormat("#.##").format(1.199);
    // gives "1.2"
  }

  private String formatMeasurementValue_TrimZerosAfterDecimalPoint( float f) {
    String t = Float.toString( f);
    if(!t.contains(".")) {
        return t;
    }

    return t.replaceAll(".?0*$", "");
  }

}

