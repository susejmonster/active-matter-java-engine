import processing.core.*;
import processing.data.*;
import processing.event.*;
import processing.opengl.*;

import java.util.HashMap;
import java.util.ArrayList;
import java.io.File;
import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;

int lasttime = 0;
float mouse_xrad = 5;
float mouse_yrad = 5;
Flock flock;
// Grid parameters
int cols = 6;
int rows = 6;
float cellW, cellH;
Table table;
// Shifting offsets
float xOffset = 0;
float yOffset = 0;
float shiftSpeed = 0.5; 

void setup() {
  size(540, 540); // Moved from settings() back to setup() where it belongs in .pde
  flock = new Flock();
  cellW = width / (float)cols;
  cellH = height / (float)rows;
  // Add an initial set of boids into the system
  for (int i = 0; i < 200; i++) {
    Boid b = new Boid(width/2 + random(0,75), height/2 + random(0,75));
    flock.addBoid(b);
  }
  table = new Table();
  table.addColumn("id");
  table.addColumn("CVV");
  table.addColumn("mass");
  
  //make grid of rectangles
  //find center of each rectangle as public variable
  //pass to boids within rectangle bounds and calc CM
  //shift grid an repeat each time frame
}

void draw() {
  background(255);
  //noFill();
 // stroke(200, 100);
  xOffset = (xOffset + shiftSpeed) % cellW;
  yOffset = (yOffset + shiftSpeed) % cellH;
  for (int c = -1; c <= cols; c++) {
    for (int r = -1; r <= rows; r++) {
      
      // Calculate absolute bounds of this cell
      float cellX = xOffset + (c * cellW);
      float cellY = yOffset + (r * cellH);
      
      // Calculate the public center coordinates
      float centerX = cellX + (cellW / 2f);
      float centerY = cellY + (cellH / 2f);
      
      ArrayList<Boid> boidsInCell = new ArrayList<Boid>();
      PVector sumPositions = new PVector(0, 0);
      for (Boid b : flock.boids) {
        if (b.position.x >= cellX && b.position.x < cellX + cellW &&
            b.position.y >= cellY && b.position.y < cellY + cellH) {
          boidsInCell.add(b);
          sumPositions.add(b.position);
        }
      }
      
      
      if (boidsInCell.size() > 0) {
        PVector centerOfMass = PVector.div(sumPositions, boidsInCell.size());
        PVector cellVel = new PVector(shiftSpeed,shiftSpeed);
        for (Boid b : boidsInCell) {
    
          b.updateGridData(centerOfMass, cellVel);
        }
      }
      
      // DEBUG
      noFill();
      stroke(200, 100);
      rect(cellX, cellY, cellW, cellH);
      
      // Draw center debug dots
      fill(255, 0, 0, 150);
      noStroke(); // Keeps the dots looking clean
      ellipse(centerX, centerY, 4, 4);
    }
  }
  
  flock.run();
  int i = 0;
  for (Boid b : flock.boids) {
    i += 1;
    b.Validate(flock.boids,table,i); 
  }
  saveTable(table, "data/output.csv");
  println("CSV file saved successfully!");
}

// Add a new boid into the System
void mouseDragged() {
  flock.addBoid(new Boid(mouseX, mouseY));
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  println(e);
  if (e > 0) {
    mouse_xrad = mouse_xrad + 1;
    mouse_yrad = mouse_yrad + 1;
  }
  if (e < 0) {
    mouse_xrad = mouse_xrad - 1;
    mouse_yrad = mouse_yrad - 1;
  }
}


