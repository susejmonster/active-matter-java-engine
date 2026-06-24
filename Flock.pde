class Flock {
  ArrayList<Boid> boids; // An ArrayList for all the boids
  color[] col_arr = new color[351];
    Flock() {
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
  }
  
  

  public void run() {
    colorMode(HSB, 360, 100, 100);
    for (int i = 0; i < col_arr.length; i++) {
        int val = i + 10;
        float divisor = 2.0; 
        float hueValue = (val / divisor) % 360;
        col_arr[i] = color(hueValue, 70, 90);
    }
    
    for (int i = 0; i < boids.size(); i++){//coloring function
        Boid b1 = boids.get(i);
        if (b1.size <= 1.0){//active
          float angleDegrees = degrees(b1.velocity.heading());
          if (angleDegrees < 0) angleDegrees += 360;
          int index = (int)constrain(angleDegrees, 10, 360);
          b1.col = col_arr[index - 10];
        }else{//solvent
          b1.col = color(0);
        }
    }
    
    Boid lead = boids.get(0);
    lead.view(boids);


    for (Boid b : boids) {
      b.flock(boids);  // Passing the entire list of boids to each boid individually
    }

    for (Boid b : boids) {
      b.run(boids);  // Passing the entire list of boids to each boid individually
    }
  }

  public void addBoid(Boid b) {
    boids.add(b);
  }
  
}