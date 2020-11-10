import processing.serial.*;              // import the Serial library
import java.awt.Rectangle;               // import Java's Rectangle class
import processing.sound.*;
import ddf.minim.*;
import ddf.minim.ugens.*;

// declare global variables for sound
Minim minim;
Oscil wave;
Pan pan;
AudioOutput out;

float panValue;

Serial myPort;        // The serial port

SoundFile sfxPaddle, sfxWallHit, left1, left2, left3, left4, left5, mid1, mid2, mid3, mid4, mid5, right1, right2, right3, right4, right5;

Rectangle leftPaddle, rightPaddle;       // Rectangles for the paddles

int paddleHeight = 250;            // vertical dimension of the paddles
int paddleWidth = 10;             // horizontal dimension of the paddles

int ballSize = 10;     // the size of the ball
int xDirection = 2;    // the ball's horizontal direction. left is –2, right is 2.
int yDirection = 2;    // the ball's vertical direction. up is –2, down is 2.
int xPos, yPos;        // the ball's horizontal and vertical positions
boolean moveLeftPaddle = false;
boolean moveRightPaddle = false;

float i = 0;
float oldTime = 0;

float leftScore = 0;      // score for left player
float rightScore = 0;     // score for right player

int fontSize = 40;      // size of the fonts on the screen


void setup() {
    size(640, 480);       // set the size of the applet window

    // initialize the paddles:
    leftPaddle = new Rectangle(50, height/2, paddleWidth, paddleHeight);
    rightPaddle = new Rectangle(620, 0, 20, 480);
 
    noStroke(); // no borders on drawn shapes
    fill(255);  // drawn shapes are white

    resetBall();

    // create a font with the third font available to the system:
    PFont myFont = createFont(PFont.list()[2], fontSize);
    textFont(myFont);
    
    // List all the available serial ports
    println(Serial.list());
    myPort = new Serial(this, Serial.list()[3], 9600);
    myPort.bufferUntil('\n');
    
    // minim
    minim = new Minim(this);
    
    
    
    // Sound files
    sfxPaddle = new SoundFile(this, "sfxPaddle.mp3");
    sfxWallHit = new SoundFile(this, "sfxWallHit.mp3");
    
    left1 = new SoundFile(this, "Left1.mp3");
    left2 = new SoundFile(this, "Left2.mp3");
    left3 = new SoundFile(this, "Left3.mp3");
    left4 = new SoundFile(this, "Left4.mp3");
    left5 = new SoundFile(this, "Left5.mp3");
    
    mid1 = new SoundFile(this, "Mid1.mp3");
    mid2 = new SoundFile(this, "Mid2.mp3");
    mid3 = new SoundFile(this, "Mid3.mp3");
    mid4 = new SoundFile(this, "Mid4.mp3");
    mid5 = new SoundFile(this, "Mid5.mp3");
    
    right1 = new SoundFile(this, "Right1.mp3");
    right2 = new SoundFile(this, "Right2.mp3");
    right3 = new SoundFile(this, "Right3.mp3");
    right4 = new SoundFile(this, "Right4.mp3");
    right5 = new SoundFile(this, "Right5.mp3");
}


void draw() {
    // clear the screen:
    background(0);

    // draw the paddles:
    rect(leftPaddle.x, leftPaddle.y, leftPaddle.width, leftPaddle.height);
    //rect(620, 0, 20, 480);

    // calculate the ball's position and draw it
    animateBall();
    
    // print the scores
    text(leftScore, fontSize, fontSize);
    text(rightScore, 540, fontSize);
}


void serialEvent(Serial thisPort) { 
    // read the serial buffer:
    String inputString = thisPort.readStringUntil('\n');

    i = millis();
    rightScore = ((i - oldTime) / 1000);
    
    if (inputString != null) {
        // trim the carrige return and linefeed from the input string:
        inputString = trim(inputString);
        int sensors[] = int(split(inputString, ','));

        // if we have received all the sensor values, use them:
        if (sensors.length == 4) {
          // scale the sliders' results to the paddles' range:
          if (sensors[0] > 500 && sensors[1] > 500) {
             moveLeftPaddle = false; 
          }
      
      //    if (sensors[2] > 500 && sensors[3] > 500) {
      //       moveRightPaddle = false; 
      //    }
      
          if (moveLeftPaddle) {      
            if (sensors[1] > sensors[0]) {
              leftPaddle.y += 4;
            } else if (sensors[2] > sensors[1]) {
              leftPaddle.y -= 4;
            }
          }

          //if (moveRightPaddle) {
          //  if (sensors[3] > sensors[2]) {
          //    rightPaddle.y += 4;
          //  } else {
          //    rightPaddle.y -= 4;
          //  }
          //}
      
          if (leftPaddle.y > 230){
             leftPaddle.y = 230; 
          }
          
          if (leftPaddle.y < 0) {
             leftPaddle.y = 0; 
          }
      
          //if (rightPaddle.y > 440){
          //  rightPaddle.y = 440;
          //}
      
          //if (rightPaddle.y < 0) {
          //  rightPaddle.y = 0;
          //}
      
          moveLeftPaddle = true;
          //moveRightPaddle = true;
        }
    }
}


void animateBall() {
  if (leftPaddle.contains(xPos, yPos)) {
     sfxPaddle.play();
     xDirection = -xDirection;
   }
   
  if (rightPaddle.contains(xPos, yPos)) {
     sfxWallHit.play();
     xDirection = -xDirection;
   }
   
   // if the ball goes off the screen left:
   if (xPos < 0 ) {
     if (rightScore > leftScore) {
       leftScore = rightScore;
       resetBall();
     } 
     resetBall();      
     }
  
    if ((yPos <= 0) || (yPos >=height)) {
      yDirection = -yDirection;
    }
    // update the ball position:
    xPos = xPos + xDirection;
    yPos = yPos + yDirection;

    // Draw the ball:
    rect(xPos, yPos, ballSize, ballSize);
    
    // Play sound based on ball location
    if ((xPos >= 0) && (xPos <= 128) && (yPos >= 0) && (yPos <= 180) && (!left1.isPlaying())) {
      left1.play();
    }
    if ((xPos > 128) && (xPos <= 256) && (yPos >= 0) && (yPos <= 180) && (!left2.isPlaying())){
      left2.play();
    }
    if ((xPos > 256) && (xPos <= 384) && (yPos >= 0) && (yPos <= 180) && (!left3.isPlaying())){
      left3.play();
    }
    if ((xPos > 384) && (xPos <= 512) && (yPos >= 0) && (yPos <= 180) && (!left4.isPlaying())){
      left4.play();
    }
    if ((xPos > 512) && (xPos <= 640) && (yPos >= 0) && (yPos <= 180) && (!left5.isPlaying())){
      left5.play();
    }
    
    
    if ((xPos >= 0) && (xPos <= 128) && (yPos > 180) && (yPos <= 300) && (!mid1.isPlaying())) {
      mid1.play();
    }
    if ((xPos > 128) && (xPos <= 256) && (yPos > 180) && (yPos <= 300) && (!mid2.isPlaying())) {
      mid2.play();
    }
    if ((xPos > 256) && (xPos <= 384) && (yPos > 180) && (yPos <= 300) && (!mid3.isPlaying())) {
      mid3.play();
    }
    if ((xPos > 384) && (xPos <= 512) && (yPos > 180) && (yPos <= 300) && (!mid4.isPlaying())) {
      mid4.play();
    }
    if ((xPos > 512) && (xPos <= 640) && (yPos > 180) && (yPos <= 300) && (!mid5.isPlaying())) {
      mid5.play();
    }
    
    
    if ((xPos >= 0) && (xPos <= 128) && (yPos > 300) && (yPos <= 480) && (!right1.isPlaying())) {
      right1.play();
    }
    if ((xPos > 128) && (xPos <= 256) && (yPos > 300) && (yPos <= 480) && (!right2.isPlaying())) {
      right2.play();
    }
    if ((xPos > 256) && (xPos <= 384) && (yPos > 300) && (yPos <= 480) && (!right3.isPlaying())) {
      right3.play();
    }
    if ((xPos > 384) && (xPos <= 512) && (yPos > 300) && (yPos <= 480) && (!right4.isPlaying())) {
      right4.play();
    }
    if ((xPos > 512) && (xPos <= 640) && (yPos > 300) && (yPos <= 480) && (!right5.isPlaying())) {
      right5.play();
    }
}



void resetBall() {
    // initialize the ball in the center of the screen:
    xPos = width/2;
    yPos = height/2;
    oldTime = i;
}
