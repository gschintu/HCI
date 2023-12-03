import java.util.ArrayList;
import java.util.Collections;

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window, set later
int trialCount = 12; //this will be set higher for the bakeoff
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float logoX = 500;
float logoY = 500;
float logoZ = 50f;
float logoRotation = 0;

/* START bakeoff challenge extra variables */
boolean gameStarted = false;

//button config to Start game
int btnWidth = 190;
int btnHeight = 50;
int btnX = 0;
int btnY = 0;


//Button Next Trial
int btnNTWidth = 190;
int btnNTHeight = 50;
int btnNTX = 0;
float btnNTY = 0;
float btnNTDelay = 10; // How long the buton color stays the same
long btnNTn;

int ccwPressTime = 0; // Time when CCW button is pressed
int cwPressTime = 0;  // Time when CW button is pressed

PVector rotationHandle;
PVector scalingHandle;

boolean isDragging  = false;
boolean isRotating  = false;
boolean isScaling   = false;

/* END bakeoff challenge extra variables */


private class Destination
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Destination> destinations = new ArrayList<Destination>();

void setup() {
  size(1000, 800);  
  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);
  rectMode(CENTER); //draw rectangles not from upper left, but from the center outwards
  
  //don't change this! 
  border = inchToPix(2f); //padding of 1.0 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Destination d = new Destination();
    d.x = random(border, width-border); //set a random x with some padding
    d.y = random(border, height-border); //set a random y with some padding
    d.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    d.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0" 
    destinations.add(d);
    println("created target with " + d.x + "," + d.y + "," + d.rotation + "," + d.z);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
  
  // Initialize control handles relative to the square's position and size
  rotationHandle = new PVector(logoZ/2, 0); // For rotation, at the right side of the square
  scalingHandle = new PVector(-logoZ/2, -logoZ/2); // For scaling, at the top left corner

}



void draw() {

  background(40); //background is dark grey
  fill(200);
  noStroke();
  
   if(!gameStarted) {
    int instructionsHeight = (80);
    fill(255); //set fill color to white
    text("**Instructions**", width / 2, instructionsHeight); 
    text("* You need to get and fit the blue square inside the red squared area *", width / 2, instructionsHeight + 40); 
    text("* For a perfect score you will need match the blue square area and angle with the red square *", width / 2, instructionsHeight + 80); 
    text("**- You can Drag&Drop the blue square in any direction  -**", width / 2, instructionsHeight + 120);
    text("**- You can Click the `Red circle` to rotate and the `Green circle` to resize the blue square -**", width / 2, instructionsHeight + 160);
    fill(255, 0, 0, 200); // set fill color to translucent red
    text("**- Make sure you press Next Trial button only when flashing, this way you know it is a match -**", width / 2, instructionsHeight + 200);
    fill(255);
    
    // Start Challenge Button
    fill(0, 0, 255); // blue color for the button background
    rect((width / 2), instructionsHeight+240, btnWidth, btnHeight,28);
    fill(255); // black color for the text
    text("Start Challenge", width / 2, instructionsHeight + 248);
    btnX = (width / 2) - (btnWidth / 2);
    btnY = (instructionsHeight + 220); // is not quite aligned with how the rect is built.
    
    return; // Don't proceed with the game logic
  }
  
  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  //===========DRAW DESTINATION SQUARES=================
  for (int i = trialIndex; i < trialCount; i++) // reduces over time
  {
    if (i == trialIndex) // Only draw the active trial
    {
      pushMatrix();
      Destination d = destinations.get(i); //get destination trial
      translate(d.x, d.y); //center the drawing coordinates to the center of the destination trial
      rotate(radians(d.rotation)); //rotate around the origin of the destination trial
      noFill();
      strokeWeight(3f);
      stroke(255, 0, 0, 192); //set color to semi translucent
      rect(0, 0, d.z, d.z);
      //for refinement 2 & 3, perhaps the showing the angle is not efficient as it tricks the user to match angles perfectly...
      //fill(255); //color for text
      //text(round(d.rotation) + "°", 0, 4); // Adding 4 for a slight vertical adjustment
      popMatrix();
    }
  }
  
  

  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  //scaffoldControlLogic(); //you are going to want to replace this! We don't need this anymore.

  //Move to next Trial Button
  if(checkForSuccess()){
    fill(255, 165, 0); // if so, fill orange
    if (frameCount%(2*btnNTDelay)<btnNTDelay) {
      //fill(255, 0, 0);
      fill(0, 0, 255); // blue color for the button background
    }
    if (millis() - btnNTn < 6000) // If 6 seconds haven't yet passed, show the rectangle
    {
      rect(((width / 2) - (btnNTWidth)), inchToPix(.7f), btnNTWidth, btnNTHeight, 28);
    }
    else if (millis() - btnNTn > 6000) // If 6 seconds have passed, reset timer
    {
      btnNTn = millis(); // reset flash counter
    }
  }
  else{
    fill(0, 0, 255); // blue color for the button background
    rect(((width / 2) - (btnNTWidth)), inchToPix(.7f), btnNTWidth, btnNTHeight, 28);
  }
  fill(255); // black color for the text
  text("Next Trial", ((width / 2) - (btnNTWidth)), inchToPix(.8f));
  btnNTX = (width / 2) - (btnNTWidth) - 100; // need to subtract 100 to offset; not sure why!
  btnNTY = inchToPix(.7f) - 20; // need to subtract 20 to offset; not sure why!
  
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
  
  
  //===========DRAW LOGO SQUARE=================
  pushMatrix();
  translate(logoX, logoY); //translate draw center to the center oft he logo square
  rotate(radians(logoRotation)); //rotate using the logo square as the origin
  noStroke();
  fill(60, 60, 192, 192);
  rect(0, 0, logoZ, logoZ);
  
  //for refinement 2 & 3, perhaps the showing the angle is not efficient as it tricks to match angles...
  //fill(255); //color for text
  //text(round(logoRotation) + "°", 0, 4); // Adding 4 for a slight vertical adjustment

  // Update and draw the rotation handle
  rotationHandle.set(logoZ/2+10, 0); // Place it at the right center edge of the square
  fill(255, 0, 0); // Red color for rotation
  ellipse(rotationHandle.x, rotationHandle.y, 20, 20); // Draw rotation handle
  drawRotationSymbol(rotationHandle.x, rotationHandle.y);

  // Update and draw the scaling handle
  scalingHandle.set(-logoZ/2-10, -logoZ/2-10); // Place it at the top left corner of the square
  fill(0, 255, 0); // Green color for scaling
  ellipse(scalingHandle.x, scalingHandle.y, 20, 20); // Draw scaling handle
  drawScalingSymbol(scalingHandle.x, scalingHandle.y);

  popMatrix(); // Make sure to popMatrix after drawing the square and its handles  
}

void drawRotationSymbol(float x, float y) {
  pushMatrix();
  translate(x, y);
  stroke(255); // White color for the arrow symbol
  strokeWeight(2);
  noFill();
  arc(0, 0, 14, 14, PI/4, PI - PI/4); // Draw a curved arrow
  
  line(-3, -5, 0, -8); // Arrow tail
  line(0, -8, 3, -5); // Arrow head
  popMatrix();
}

void drawScalingSymbol(float x, float y) {
  pushMatrix();
  translate(x, y);
  stroke(255); // White color for the arrow symbol
  strokeWeight(2);
  noFill();
  rotate(PI/-4.0);
  
  line(-3, 0, 0, -5); // Arrow
  line(0, -5, 3, 0); // Arrow

  line(-3, 0, 0, 5); // Arrow
  line(0, 5, 3, 0); // Arrow
  popMatrix();
}

//After a few more iterations in the bakeoff with the drag&drop, resize and rotation buttons, the scaffolding is a pretty bad solution.
/*
void scaffoldControlLogic() {
  // Calculate base positions
  float baseX = width - inchToPix(1f);  // 1 inch from the right edge
  float baseY = height - inchToPix(1f); // 1 inch from the bottom edge

  // Set the positions for CCW and CW buttons
  text("CCW", baseX - inchToPix(1f), baseY + inchToPix(0.5f)); // Move CCW button to the left of CW
  if (mousePressed && dist(baseX - inchToPix(1f), baseY + inchToPix(0.5f), mouseX, mouseY) < inchToPix(.4f)) {
    logoRotation -= 1;
  }

  text("CW", baseX, baseY + inchToPix(0.5f)); // CW button remains at the base position
  if (mousePressed && dist(baseX, baseY + inchToPix(0.5f), mouseX, mouseY) < inchToPix(.4f)) {
    logoRotation += 1;
  }

  // Set the positions for left and right buttons
  text("<", baseX - inchToPix(1f), baseY - inchToPix(.5f)); // Above the CCW button
  if (mousePressed && dist(baseX - inchToPix(1f), baseY - inchToPix(.5f), mouseX, mouseY) < inchToPix(.4f)) {
    logoX -= inchToPix(.02f);
  }

  text(">", baseX, baseY - inchToPix(.5f)); // Above the CW button
  if (mousePressed && dist(baseX, baseY - inchToPix(.5f), mouseX, mouseY) < inchToPix(.4f)) {
    logoX += inchToPix(.02f);
  }

  // Set the positions for + and - buttons
  text("-", baseX - inchToPix(1f), baseY - inchToPix(1.5f)); // Above the left button
  if (mousePressed && dist(baseX - inchToPix(1f), baseY - inchToPix(1.5f), mouseX, mouseY) < inchToPix(.4f)) {
    logoZ = constrain(logoZ - inchToPix(.02f), inchToPix(.1f), inchToPix(4f));
  }

  text("+", baseX, baseY - inchToPix(1.5f)); // Above the right button
  if (mousePressed && dist(baseX, baseY - inchToPix(1.5f), mouseX, mouseY) < inchToPix(.4f)) {
    logoZ = constrain(logoZ + inchToPix(.02f), inchToPix(.1f), inchToPix(4f));
  }

  // Set the positions for up and down buttons
  text("^", baseX - inchToPix(.5f), baseY - inchToPix(1f)); // Above the - button
  if (mousePressed && dist(baseX - inchToPix(.5f), baseY - inchToPix(1f), mouseX, mouseY) < inchToPix(.4f)) {
    logoY -= inchToPix(.02f);
  }

  text("v", baseX - inchToPix(.5f), baseY); // Below the up button, aligned horizontally
  if (mousePressed && dist(baseX - inchToPix(.5f), baseY, mouseX, mouseY) < inchToPix(.4f)) {
    logoY += inchToPix(.02f);
  }
}
*/

/*
//my example design for control, which is terrible
void scaffoldControlLogic()
{
  //upper left corner, rotate counterclockwise
  text("CCW", inchToPix(.4f), inchToPix(.4f));
 // if (mousePressed && dist(0, 0, mouseX, mouseY)<inchToPix(.8f))
 //   logoRotation--;
  if (ccwPressTime != 0 && dist(0, 0, mouseX, mouseY) < inchToPix(.8f)) {
      if (millis() - ccwPressTime < 2000) { // Pressed for less than 2 seconds
          logoRotation -= 1; // Rotate by 1 degree
      } else {
          logoRotation--; // Existing rotation logic for long press
      }
      ccwPressTime = 0; // Reset the press time
  }

  //upper right corner, rotate clockwise
  text("CW", width-inchToPix(.4f), inchToPix(.4f));
  //if (mousePressed && dist(width, 0, mouseX, mouseY)<inchToPix(.8f))
  //  logoRotation++;
  if (cwPressTime != 0 && dist(width, 0, mouseX, mouseY) < inchToPix(.8f)) {
      if (millis() - cwPressTime < 2000) { // Pressed for less than 2 seconds
          logoRotation += 1; // Rotate by 1 degree
      } else {
          logoRotation++; // Existing rotation logic for long press
      }
      cwPressTime = 0; // Reset the press time
  }

  //lower left corner, decrease Z
  text("-", inchToPix(.4f), height-inchToPix(.4f));
  if (mousePressed && dist(0, height, mouseX, mouseY)<inchToPix(.8f))
    logoZ = constrain(logoZ-inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone!

  //lower right corner, increase Z
  text("+", width-inchToPix(.4f), height-inchToPix(.4f));
  if (mousePressed && dist(width, height, mouseX, mouseY)<inchToPix(.8f))
    logoZ = constrain(logoZ+inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone! 

  //left middle, move left
  text("left", inchToPix(.4f), height/2);
  if (mousePressed && dist(0, height/2, mouseX, mouseY)<inchToPix(.8f))
    logoX-=inchToPix(.02f);

  text("right", width-inchToPix(.4f), height/2);
  if (mousePressed && dist(width, height/2, mouseX, mouseY)<inchToPix(.8f))
    logoX+=inchToPix(.02f);

  text("up", width/2, inchToPix(.4f));
  if (mousePressed && dist(width/2, 0, mouseX, mouseY)<inchToPix(.8f))
    logoY-=inchToPix(.02f);

  text("down", width/2, height-inchToPix(.4f));
  if (mousePressed && dist(width/2, height, mouseX, mouseY)<inchToPix(.8f))
    logoY+=inchToPix(.02f);
}
*/

void mousePressed()
{
  
  // only start the game if user clicks in the button range...
  if (!gameStarted) {
    return;
  }
  
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
  
  if (dist(0, 0, mouseX, mouseY) < inchToPix(.8f)) {
      ccwPressTime = millis(); // Save the time when CCW is pressed
  } else if (dist(width, 0, mouseX, mouseY) < inchToPix(.8f)) {
      cwPressTime = millis();  // Save the time when CW is pressed
  }
  
  // Transform the mouse coordinates into the square's coordinate space
  PVector mouseVec = new PVector(mouseX, mouseY);
  PVector squareCenter = new PVector(logoX, logoY);
  mouseVec.sub(squareCenter); // Translate
  mouseVec.rotate(-radians(logoRotation)); // Rotate in the opposite direction of the square's rotation

  // Check if the mouse is within the bounds of the blue square
  if (mouseVec.mag() < logoZ / 2) {
    isDragging = true;
  }
  // Check for rotation handle click
  else if (PVector.dist(mouseVec, rotationHandle) < 10) {
    isRotating = true;
  }
  // Check for scaling handle click
  else if (PVector.dist(mouseVec, scalingHandle) < 10) {
    isScaling = true;
  }
  
}


void mouseDragged() {
  
  // We need to calculate the offset of the mouse from the center of the square,
  // both for the current position and for the previous position.
  //https://forum.processing.org/two/discussion/25253/store-the-start-and-end-position-of-a-mousedrag.html
  
  PVector currentMouse = new PVector(mouseX, mouseY); //per frame
  PVector previousMouse = new PVector(pmouseX, pmouseY); // when actually moved
  PVector center = new PVector(logoX, logoY);

  currentMouse.sub(center);
  previousMouse.sub(center);

  if (isDragging) {
    logoX = mouseX;
    logoY = mouseY;
  } else if (isRotating) {
    // Calculate the angle of the mouse in relation to the square's center for both the current and previous frames
    float currentAngle = atan2(currentMouse.y, currentMouse.x);
    float previousAngle = atan2(previousMouse.y, previousMouse.x);

    // Determine the angle of rotation based on the mouse movement
    float angleDelta = currentAngle - previousAngle;

    // Adjust the square's rotation
    logoRotation += degrees(angleDelta);
    // Normalize the angle to be within 0 - 360 degrees or it goes crazy at each rotation.
    logoRotation = (logoRotation + 360) % 360;
  } else if (isScaling) {
    
    // Use the previous mouse position (pmouseX, pmouseY) and the current mouse position
    // to calculate the scaling factor based on the distance from the square's center
    //In this particular case, instead of the mouse coordinates only we can use vector magnitude to detect real movement.
    //https://processing.org/reference/mag_.html
    float previousDist = previousMouse.mag();
    float currentDist = currentMouse.mag();
    
    // somehow the mouse is very sensitive, and even slight vibrations affect the drag and it makes the square vibrate
    //So we need to calculated only when there is a 'real' vector movement
    float scaleDelta = currentDist - previousDist;

    // Apply the scaling factor
    logoZ += scaleDelta;
    logoZ = constrain(logoZ, inchToPix(0.1f), inchToPix(4f));
  }
}

void mouseReleased()
{
  
  // only start the game if user clicks in the button range...
  if (!gameStarted) {
    if (mouseX > btnX && mouseX < btnX + btnWidth && mouseY > btnY && mouseY < btnY + btnHeight) {
        gameStarted = true;
    }
    return;
  }
  
  isDragging = false;
  isRotating = false;
  isScaling = false;
  
  //check to see if user clicked middle of screen within 3 inches, which this code uses as a submit button
  if (mouseX > btnNTX && mouseX < btnNTX + btnNTWidth && mouseY > btnNTY && mouseY < btnNTY + btnNTHeight)
  //if (dist(width/2, height/2, mouseX, mouseY)<inchToPix(3f))
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);	
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"	

  println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation)+")");
  println("Close Enough Z: " +  closeZ + " (logo Z = " + d.z + ", destination Z = " + logoZ +")");
  println("Close enough all: " + (closeDist && closeRotation && closeZ));

  return closeDist && closeRotation && closeZ;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}
