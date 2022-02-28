import grafica.*;
import processing.serial.*;

Serial myPort;        // The serial port
int xPos = 1;         // horizontal position of the graph
float height_old = 0;
float height_new = 0;
float inByte = 0;
int BPM = 0;
int beat_old = 0;
float[] beats = new float[500];  // Used to calculate average BPM
int beatIndex;
float threshold = 620.0;  //Threshold at which BPM calculation occurs
boolean belowThreshold = true;
PFont font;
GPlot plot1;
GPlot plot2;
int x,y;
GPointsArray p1 = new GPointsArray(2000);
GPointsArray p2 = new GPointsArray(2000);
char[] arr;
String val;     // Data received from the serial port


void setup () {
  // set the window size:
  size(1200, 1000);        

  // List all the available serial ports
  println(Serial.list());
  // Open whatever port is the one you're using.
  myPort = new Serial(this, Serial.list()[2], 115200);
  // don't generate a serialEvent() unless you get a newline character:
  //myPort.bufferUntil('\n');
  // set inital background:
  background(0xff);
  font = createFont("Times New Roman", 12, true);
}


void draw () {
     //Map and draw the line for new data point
     //inByte = map(inByte, 0, 1023, 0, height);
     //height_new = height - inByte; 
     //line(xPos - 1, height_old, xPos, height_new);
     //height_old = height_new;
     
     
      // at the edge of the screen, go back to the beginning:
      if (xPos >= width) {
        xPos = 0;
        background(0xff);
      } 
      else {
        // increment the horizontal position:
        xPos++;
      }
      
     long y = millis();
      if ( myPort.available() > 0) {  // If data is available,
          val = myPort.readStringUntil('\n');         // read it and store it in val
        } 
      // draw text for BPM periodically
      if (millis() % 128 == 0){
        fill(0xFF);
        rect(600, 700, 200, 30);
        fill(0x00);
        text("BPM: " + inByte, 610, 720);
      }
      //val = inByte;
       boolean skip = true;
        try {
          val = val.replace("\n", "").replace("\r", "");
          val.trim();
          arr = val.toCharArray();
          if(!Character.isDigit(arr[0])){
             skip = false;
          }
            
        }
         catch (NullPointerException e) {
         skip = false;  
        } 
        if(skip) {
          x = Integer.parseInt(new String(arr));
        }
        x = (int)inByte;
      println(val);
      
//PLOT 1 
     
      plot1 = new GPlot(this);
      plot1.setPos(0,0);
      plot1.setDim(500, 500);
      //plot1.setPointColor(color(255, 0, 255, 0));
      plot1.setPointSize(2);
      plot1.getXAxis().setAxisLabelText("Time");
      plot1.getYAxis().setAxisLabelText("Respiration");
      plot1.setTitleText("Respiration over Time");
      plot1.setPointSize(5);
      
      p1.add(y,x);
      
      plot1.addLayer("blue", p1);
      plot1.getLayer("blue").setPointColor(color(30,144,255,255));
      plot1.beginDraw();
      plot1.drawBackground();
      plot1.drawBox();
      plot1.drawXAxis();
      plot1.drawYAxis();
      plot1.drawTitle();
      plot1.drawGridLines(GPlot.BOTH);
      plot1.drawPoints();
      plot1.endDraw();
      
//Plot 1 Ends above this line     
      
//PLOT 2 
      
      plot2 = new GPlot(this);
      plot2.setPos(550,0);
      plot2.setDim(500, 500);
      //plot1.setPointColor(color(255, 0, 255, 0));
      plot2.setPointSize(2);
      plot2.getXAxis().setAxisLabelText("Time");
      plot2.getYAxis().setAxisLabelText("Heart Rate");
      plot2.setTitleText("Heart Rate over Time");
      plot2.setPointSize(5);
      
      p2.add(y,x);
      
      plot2.addLayer("red", p1);
      plot2.getLayer("red").setPointColor(color(140,12,3,255));
      plot2.beginDraw();
      plot2.drawBackground();
      plot2.drawBox();
      plot2.drawXAxis();
      plot2.drawYAxis();
      plot2.drawTitle();
      plot2.drawGridLines(GPlot.BOTH);
      plot2.drawPoints();
      plot2.endDraw();
      
 
//Plot 2 Ends above this line
      
//Fitness Zones

 
 
  fill(140, 12, 3);
  rect(50, 650, 200, 40);
  fill(0);
  text("Maximum: 90-100% ", 55, 670);
  fill(240, 16, 0);
  rect(50, 690, 200, 40);
  fill(0);
  text("Hard: 80-90%", 55, 710);
  fill(240, 152, 0);
  rect(50, 730, 200, 40);
  fill(0);
  text("Moderate: 70-80%", 55, 750);
  fill(255, 255, 0);
  rect(50, 770, 200, 40);
  fill(0);
  text("Light: 60-70%", 55, 790);
  fill(0, 255, 8);
  rect(50, 810, 200, 40);
  fill(0);
  text("Very Light: 50-60%", 55, 830);
  fill(153);
  rect(50, 850, 200, 40);
  fill(0);
  text("No Data", 55, 870);
}

// FItness Zone Ends above this line

void serialEvent (Serial myPort) 
{
  // get the ASCII string:
  String inString = myPort.readStringUntil('\n');

  if (inString != null) 
  {
    // trim off any whitespace:
    inString = trim(inString);

    // If leads off detection is true notify with blue line
    if (inString.equals("!")) 
    { 
      stroke(0, 0, 0xff); //Set stroke to blue ( R, G, B)
      inByte = 512;  // middle of the ADC range (Flat Line)
    }
    // If the data is good let it through
    else 
    {
      stroke(0xff, 0, 0); //Set stroke to red ( R, G, B)
      inByte = float(inString); 
      
      // BPM calculation check
      if (inByte > threshold && belowThreshold == true)
      {
        calculateBPM();
        belowThreshold = false;
      }
      else if(inByte < threshold)
      {
        belowThreshold = true;
      }
    }
  }
}
  
void calculateBPM () 
{  
  int beat_new = millis();    // get the current millisecond
  int diff = beat_new - beat_old;    // find the time between the last two beats
  float currentBPM = 60000 / diff;    // convert to beats per minute
  beats[beatIndex] = currentBPM;  // store to array to convert the average
  float total = 0.0;
  for (int i = 0; i < 500; i++){
    total += beats[i];
  }
  BPM = int(total / 500);
  beat_old = beat_new;
  beatIndex = (beatIndex + 1) % 500;  // cycle through the array instead of using FIFO queue
  }
