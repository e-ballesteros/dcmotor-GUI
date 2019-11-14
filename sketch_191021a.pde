import processing.serial.*;// serial library (default on Arduino)
Serial ArduinoSerial; // define the serial port

PImage gauge; PImage arrow; PImage baseKnob; PImage knob;// image definitions of dial, arrow, and knob (
int knobRot, graycol=125, trimmer=100, Vcc=5, tsize=14, xshift=20, yshift=50, speed=1;
String res, DIR="F", PWM, MOT="ON", SPD="OFF"; // chardatatype for only 1 character, String for a word (initial capital letter!)
float resf,speedang,resang;
int x1=100, y1=100, Dx=100, Dy=100, R=10; // size of Voltage button, origin (top left), width and curvature of rounded edges
int x2=500, y2=100; int x3=400, y3=350; int x4=200, y4=350; // Resistance button, LED switch button, PWM knob

String input_speed = "";  // Speed introduced with keyboard
String spd = "1";

void setup(){
  ArduinoSerial = new Serial(this,"COM8",9600); // Starts the serial communication (specify COM port and baud rate of Arduino)
  size(700,500); background(150); // window’s size and background color(grayscale or RGB colors)
  fill(0,0,255); stroke(33); strokeWeight(0); rect(x1,y1,Dx,Dy,R); // Button1: filled color, edge width, edge color, origin (top-left), width, edge curvature
  fill(255,0,0); stroke(33); strokeWeight(0); rect(x2,y2,Dx,Dy,R); // Button2: filled color, edge width, edge color, origin (top-left), width, edge curvature
  fill(0,255,0); stroke(33); strokeWeight(0); rect(x3,y3,Dx,Dy,R); // Button3: filled color, edge width, edge color, origin (top-left), width, edge curvature
  textSize(tsize); fill(0); text("Speed",x1+xshift,y1-10); // Button1 label: char size, char color, text, starting position
  textSize(tsize); fill(0); text("Direction",x2+xshift,y2-10); // Button2 label: char size, char color, text, starting position
  textSize(tsize); fill(0); text("Motor "+MOT,x3+xshift,y3+yshift); // Button3 label: char size, char color, text, starting position
  gauge = loadImage("gauge2.png"); arrow = loadImage("arrow2.png"); // load images (dial and arrow) of analog multimeter
  baseKnob = loadImage("baseKnob.png"); knob = loadImage("Knob.png"); // load images of knob
  image(gauge,200,0); image(baseKnob,x4,y4); image(knob,x4+10,y4+10); // images placement on window
  translate(350,150); rotate(radians(-160)); // translation of the reference system origin on the rotation center and rotation of the reference system to minimum value
  image(arrow,-60,-100); // arrow image placement on window
  rotate(radians(160)); translate(-350,-150); 
} // reset reference system

void draw() {
  
  if(SPD=="ON" && keyPressed){  // We only want to attend the keyboard when the Button 1 is pressed
    input_speed += key;
  }
  
  if(MOT=="OFF"){
    textSize(tsize); fill(0); text("0",x1+xshift,y1+yshift);           // write the speed value on the button label
  }
  else{
    textSize(tsize); fill(0); text(spd,x1+xshift,y1+yshift);   // write the speed value on the button label
  }
  
  if (mousePressed && mouseX>x1 && mouseX<x1+Dx && mouseY>y1 && mouseY<y1+Dy) { // when mouse clicks inside button1
    image(gauge,200,0); // copre la vecchia lancetta
    if(SPD == "OFF"){
      fill(255,255,0); stroke(33); strokeWeight(0); rect(x1,y1,Dx,Dy,R); // Button1 becomes yellow
      //textSize(tsize); fill(0,0,255); text("Introduce\nspeed",x1+xshift,y1-10); // Button1 label: char size, char color, text, starting position
      SPD = "ON";
    }
    else{
      ArduinoSerial.write('B');                                   // B character for begining sending the speed value
      for (int i = 0; i < input_speed.length(); i = i+1) {        // Send character by character the value of the speed written
        ArduinoSerial.write(input_speed.charAt(i)); delay(100);
      }
      ArduinoSerial.write('E');                                   // E character for ending sending the speed value
      input_speed = "";                                           // Reset of input_speed
      SPD = "OFF";
    }
    
    //ArduinoSerial.write('V'); delay(200); // send to Arduino a char to request a resistance measand wait for Arduino to receive command and sends back the meas
    //spd=ArduinoSerial.readString(); // read speed value coming from Arduino on the receiving buffer of the serial port
    
    textSize(tsize); fill(0); text(spd,x1+xshift,y1+yshift); // write the speed value on the button label
    
    speed=int(spd);
    speedang = map(speed, 0, Vcc, -160, 160); // convert string and map value into rotation angles of the arrow
    
    translate(350,150); rotate(radians(speedang));// translation of the reference system origin on the rotation center and rotation of the reference system to the measured value
    image(arrow,-60,-100); // arrow image placement on window
    rotate(radians(-speedang)); translate(-350,-150); 
  }// reset reference system
  
  if (mousePressed && mouseX>x2 && mouseX<x2+Dx && mouseY>y2 && mouseY<y2+Dy) {// when mouse clicks inside button2
      
    if (DIR=="F") {
      ArduinoSerial.write('R'); DIR="R";// send to Arduino a char to request to change direction to R
      fill(graycol); stroke(33); strokeWeight(0); rect(x3,y3,Dx,Dy,R); 
    } // Button2 becomes gray
    else {
      ArduinoSerial.write('F'); DIR="F";// send to Arduino a char to request to change direction to F
      fill(0,255,0); stroke(33); strokeWeight(0); rect(x3,y3,Dx,Dy,R); 
    } // Button3 returns to be green
    
    textSize(tsize); fill(0); text("DIR "+DIR,x3+xshift,y3+yshift); 
  }// edit button2 label
  
  if (mousePressed && mouseX>x3 && mouseX<x3+Dx && mouseY>y3 && mouseY<y3+Dy) { // when mouse clicks inside button 3
  
      if (MOT=="ON") {
      ArduinoSerial.write('N'); MOT="OFF";                              // Send to Arduino a char to request to switch off the motor
      fill(255,0,0); stroke(33); strokeWeight(0); rect(x3,y3,Dx,Dy,R);  // Button 3 becomes red
    }
    else {
      ArduinoSerial.write('Y'); MOT="ON";                               // Send to Arduino a char to request to switch on the motor
      textSize(tsize); fill(0); text(input_speed,x1+xshift,y1+yshift);  // write the speed value on the button label
      fill(0,255,0); stroke(33); strokeWeight(0); rect(x3,y3,Dx,Dy,R);  // Button 3 becomes green
    }
    textSize(tsize); fill(0); text("MOTOR "+MOT,x3+xshift,y3+yshift); 
  /*
    image(gauge,200,0); // copre la vecchia lancetta
    fill(255,0,0); stroke(33); strokeWeight(0); rect(x2,y2,Dx,Dy,R); // Button2 becomes red
    fill(graycol); stroke(33); strokeWeight(0); rect(x1,y1,Dx,Dy,R); // Button1 returns to be gray
    ArduinoSerial.write('R'); delay(200); // send to Arduino a char to request a resistance meas and wait for Arduino to receive command and sends back the meas
    res=ArduinoSerial.readString(); // read resistance valuecoming from Arduino on the receiving buffer of the serial port
    textSize(tsize); fill(0); text(res+" k",x2+xshift,y2+yshift); // write the resistance value on the button label
    resf=float(res); resang = map(resf,0,trimmer,-160,160); // convert string and map value into rotation angles of the arrow
    translate(350,150); rotate(radians(resang));// translation of the reference system origin on the rotation center and rotation of the reference system to the measured value
    image(arrow,-60,-100); // arrow image placement on window
    rotate(radians(-resang)); translate(-350,-150); */
  }
  /*
  if (mousePressed && mouseX>x4+10 && mouseX<x4+Dx-10 && mouseY>y4+10 && mouseY<y4+Dy-10) { // when mouse clicks inside button 3
    knobRot = int(map(mouseX,x4+10,x4+90,-130,130)); // map mouse x position into rotation angles of the knob
    translate(x4+Dx/2,y4+Dy/2); rotate(radians(knobRot)); // translation of the reference system origin on the rotation center and rotation of the reference system to the measured value
    image(knob,-Dx/2+10,-Dy/2+10); // knob image placement on window
    rotate(radians(-knobRot)); translate(-x4-Dx/2,-y4-Dy/2); // reset reference system
    PWM = str(int(map(knobRot,-130,130,0,255))); // map knob angles into PWM duty-cycle
    ArduinoSerial.write('P'); ArduinoSerial.write(PWM); // send PWM notice to Arduino and then duty-cycle value
    DIR="R"; fill(0); stroke(33); strokeWeight(0); rect(x3,y3,Dx,Dy,R); // button of LED switch becomes red because LED is ON
    textSize(tsize); fill(0); text("DIR "+DIR,x3+xshift,y3+yshift); 
  }// change label to ON of LED switch button
  */
  
  delay(200); 
}
