import processing.pdf.*;

RiverLine riverLine;
PVector target;
PVector rock;
PVector noiseForce;
float curY;
float a0,b0;
float yInc = 15.0;

int numRocks = 3;
int numRockVertices = 14;
PVector rocks[];
int rockSize[];
PVector rockVerts[][];

PGraphics canvas;

boolean hasDrawnRocks = false;
boolean hasSaved = false;

void setup() {
  size(1400,700,P2D);
  pixelDensity(2);
  
  smooth(8);
  noiseDetail(2,1);
  background(255);
  
  curY = 60.0; // starting Y location
  
  // for perlin noise
  a0 = curY/width;
  b0 = curY/height;
  
  riverLine = new RiverLine(0, curY);
  target = new PVector(width,curY);
  
  rocks = new PVector[3];
  rockSize = new int[4];
  rockVerts = new PVector[4][14];
  // generate random rocks
  for (int i=0;i<numRocks;i++) {
    rocks[i] = new PVector(random(400+i*300,650+i*300), random(120.0,height-170.0));
    rockSize[i] = floor(random(100,130));
    // generate random rock vertices
    for (int j=0;j<numRockVertices;j++) {
      float rnd = random(rockSize[i]*.5,rockSize[i]*.6);
      rockVerts[i][j] = new PVector(sin(TWO_PI/numRockVertices * j) * rnd, cos(TWO_PI/numRockVertices * j) * rnd);
    }
  }
  
  ellipseMode(RADIUS);
  
  String fn = "perlinRiver_"+millis()+".pdf";
  println("output : " + fn);
  beginRecord(PDF, fn);

}

void draw() {
  if (curY < height - 100) {
    // draw until near bottom. Note different between top and bottom margins - it's intentional
    stroke(0);
    noFill();
    
    a0 += 0.025;
    
    // first, draw the rocks, but only once
    if (!hasDrawnRocks) {
      for (int i=0;i<numRocks;i++) {
        stroke(90);
        strokeWeight(3);
        noFill();
        pushMatrix();
        translate(rocks[i].x,rocks[i].y+20); // offset intentional to counteract lookahead
        beginShape();
        curveVertex(rockVerts[i][0].x,rockVerts[i][0].y);
        for (int j=0;j<numRockVertices;j++) {
          curveVertex(rockVerts[i][j].x,rockVerts[i][j].y);
        }
        curveVertex(rockVerts[i][0].x,rockVerts[i][0].y);
        endShape(CLOSE);
        popMatrix();
      }
      hasDrawnRocks = true;
    }
    
    riverLine.update();
    riverLine.seek(new PVector(riverLine.location.x + 150.0, target.y));
    for (int i=0;i<numRocks;i++) {
      riverLine.avoid(rocks[i],rockSize[i],i);
    }
    riverLine.display();
    
    if (( target.dist(riverLine.location) < 2) || (riverLine.location.x > target.x)) {
      curY += yInc;
      riverLine = new RiverLine(0, curY);
      target = new PVector(width,curY);
      a0 = curY/width;
      b0 = curY/height;
    }
  } else {
    if (!hasSaved) {
      hasSaved = true;
      endRecord();
      // show non-recorded green dot in top left
      noStroke();
      fill(0,255,0);
      rect(0,0,5,5);
    }
  }
}