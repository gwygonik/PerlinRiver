class RiverLine {

  // based on the Vehicle class and behaviour by D.Shiffman
  
  PVector location;
  PVector oldLoc;
  float yLoc;
  PVector velocity;
  PVector acceleration;
  PVector avoidance;
  
  float startY;
  float r;
  float maxforce;
  float maxspeed;
  
  float rockSize;
  int curRock = 0;
  
  float maxLookAhead = 20.0;
  
  float noiseAmount = 30.0;
 
  RiverLine(float x, float y) {
    acceleration = new PVector(0,0);
    velocity = new PVector(0,0);
    location = new PVector(x,y);
    oldLoc = location.copy();
    yLoc = y;
    avoidance = new PVector(0,0);
    
    startY = y;
    
    r = 3.0;

    maxspeed = 5.0;
    maxforce = 0.7;

  }

  void update() {
    oldLoc = location.copy();
    oldLoc.y = yLoc;
    velocity.add(acceleration);
    velocity.add(avoidance);
    velocity.limit(maxspeed);
    location.add(velocity);
    acceleration.mult(0);
    avoidance.mult(0);
    yLoc = location.y + (noise(a0,b0)*noiseAmount);
  }
 
  void applyForce(PVector force) {
    acceleration.add(force);
  }
 
  // scoot around rocks
  void avoid(PVector target, int inRockSize, int rockIndex) {
    PVector vn = velocity.copy();
    vn.normalize();
    PVector ahead = location.copy().add(vn.mult(maxLookAhead));
    // note scaling of rock size to get closer to rock
    if (ahead.dist(target) < inRockSize*0.75 ) {
      // avoid!
      avoidance = PVector.sub(ahead, target);
      avoidance.normalize();
    }
    curRock = rockIndex;
  }

  void seek(PVector target) {
    PVector desired = PVector.sub(target,location);
    desired.normalize();
    desired.mult(maxspeed);
    PVector steer = PVector.sub(desired,velocity);
    steer.limit(maxforce);
    applyForce(steer);
  }
 
 
  boolean hasBeenDrawing = false;
  
  // NOTE! This creates lines that look continuous, but when plotted
  // will be made up of lots and lots of short line segments, each plotted on its own
  // There may be a better way (vertices in a shape?) but it works well enough as-is
  
  void display() {
    // draw within left/right margins
    if (location.x > 35 && location.x<width-35) {
      strokeWeight(2);
      noFill();
      stroke(0);
      
      // use perlin + random amount to create gaps in lines. Adjust the 1.25 for different FX
      if (noise(b0,a0) + noise(a0,b0) + random(0.25) < 1.25) {
        // draw line
        if (hasBeenDrawing) {
          // draw to old point;
          line(oldLoc.x,oldLoc.y,location.x,yLoc);
          hasBeenDrawing = true;
        } else {
          // start new point
          oldLoc = location.copy();
          hasBeenDrawing = true;
        }
      } else {
        // stop drawing
        if (hasBeenDrawing) {
          line(oldLoc.x,oldLoc.y,location.x,yLoc);
          hasBeenDrawing = false;
        } 
      }
    }
  }

}