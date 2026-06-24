class Boid {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  int curr_t;
  int col;
  int size;//changed
  public int bernoulli() {
    float p = random(1.0); 
  
    if (p > 0.5) {
      return 10;
    } else {
      return 1;
    }
  }
  PVector cellCM;
  PVector cellVel;

  Boid(float x, float y) { //constructor
    acceleration = new PVector(0, 0);
    velocity = new PVector(random(-1, 1), random(-1, 1));
    position = new PVector(x, y);
    r = 5.0;
    maxspeed = 3;
    maxforce = 0.05;
    //col = color(175);//here
    size = bernoulli();
    cellCM = new PVector(0, 0);
    cellVel = new PVector(0, 0);
  }

  void run(ArrayList<Boid> boids) { 
    flock(boids);
    curr_t = millis();
    update();
    borders();
    render();
   // MPCD(boids);
    //validate();
  }

  void applyForce(PVector force) {
    acceleration.add(force); 
  }

  void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector wca = WCA(boids);   // Cohesion
    PVector inertia = Momentum(boids); //inertia
    PVector MPCD = MPCD(boids,cellCM,cellVel); //solvent to solvent rotation

    sep.mult(1.0);
    ali.mult(1.0);
    wca.mult(1.0);
    //if boids.size[i]==1->solvent: apply rotation based on velocity of cm of bounding box
    
    //if boids.size[i]==0->active: apply LJ seperation force
    applyForce(sep);
    applyForce(MPCD);
    applyForce(ali);
    applyForce(wca);//convert to wca between all active to solute particles
    applyForce(inertia);
  }

  void update() {
    velocity.add(acceleration);
    velocity.limit(maxspeed);
    position.add(velocity);
    acceleration.mult(0);
  }

  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);  
    desired.normalize();
    desired.mult(maxspeed);
    
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  
    return steer;
  }

  void render() {
    float theta = velocity.heading() + radians(90);
    fill(col);
    stroke(0);
    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);
    if (size <= 1.0){
        beginShape(TRIANGLES);
        vertex(0, -r*2);
        vertex(-r, r*2);
        vertex(r, r*2);
        endShape();
    }
    else{
        circle(0, 0, r * 2);
    }
    popMatrix();
  }

  void borders() {
    if (position.x < -r) position.x = width+r;
    if (position.y < -r) position.y = height+r;
    if (position.x > width+r) position.x = -r;
    if (position.y > height+r) position.y = -r;
  }
  //LJ Potential calc
  float exp1(float dis){
    return pow((1/dis),12);
  }
  float exp2(float dis){
    return pow((1/dis),6);
  }
  float du(float dis,float eps){
    return ((-24*eps)/dis)*(2*exp1(dis) - exp2(dis));
  }
  float LJ(float dis){
    float eps = 1;
    float sigma = 1;
    float rc = 2.5*sigma;
    float U_r = du(rc,eps) + du(dis,eps); 
    return U_r;
  }
  float WCA_2(float dis){
    float eps = 1;
    float sigma = 1;
    float rc = 0.56*sigma;
    float U_r = du(rc,eps) + du(dis,eps)+0.25; 
    return U_r;
  }
  float WCA(float dis){
    float eps = 1;
    float sigma = 1;
    float rc = pow(2,1.667)*sigma;
    float U_r = du(rc,eps) + du(dis,eps) + 0.25; 
    return U_r;
  }
  //active-active
  PVector separate(ArrayList<Boid> boids) {
    float neighbordist = 2.5;
    PVector totalForce = new PVector(0,0,0);
    //int count = 0;
    for (Boid other : boids) {
      PVector dir = PVector.sub(this.position, other.position);
      float d = dir.mag();
      if ((d > 0) && (d < neighbordist) && other.size <= 1.0 && this.size <=1.0) {
        float forceMag = LJ(d);
      
        dir.normalize();         
        dir.mult(forceMag);      
        totalForce.add(dir);        
        //count++;            
      }
    }
     return totalForce;
  }
  //active-solute WCAPOTENTIAL
   PVector WCA(ArrayList<Boid> boids) {
    float neighbordist = 2.5;
    PVector totalForce = new PVector(0,0,0);  
     for (Boid other : boids) {
      PVector dir = PVector.sub(this.position, other.position);
      float d = dir.mag();
      if ((d > 0) && (d < neighbordist) && other.size > 1.0 && this.size <=1.0) {
        float forceMag = WCA(d);
        dir.normalize();        
        dir.mult(forceMag);      
        totalForce.add(dir);        
        //count++;            
      }
    }
    return totalForce;
  }
  
  //MPCD
  void updateGridData(PVector cm,PVector cellVel) {
    this.cellCM = cm.copy();
    this.cellVel = cellVel.copy();
  }
  //solute to solute interaction
  PVector MPCD(ArrayList<Boid> boids,PVector cm, PVector cellVel){
    this.cellCM = cm.copy();
    this.cellVel = cellVel.copy();
    //get time
    PVector steer = new PVector(0,0,0);
    //get velocity of particle
    PVector del_vel = velocity;
    if(this.size>=1.0){
      //get boids of size == 0
      for(Boid other : boids){
        //edge case
        if(other == this){
          continue;
        }
        //draw bounding box
      boolean xOverlap = this.position.x < other.position.x + 2.5 && 
                         this.position.x + 2.5 > other.position.x;
                         
      boolean yOverlap = this.position.y < other.position.y + 2.5 && 
                         this.position.y + 2.5 > other.position.y;
      if(xOverlap && yOverlap){
          //matrix->
          PVector rel_vel = PVector.sub(this.velocity, this.cellVel);
          float[][] Rot_mat = {  {-0.6428,-0.7660}, 
                                 {0.7660,-0.6428}  };
          float x = del_vel.x * Rot_mat[0][0]+ del_vel.y*Rot_mat[0][1];
          float y = del_vel.x * Rot_mat[1][0]+ del_vel.y*Rot_mat[1][1]; 
          PVector sec = new PVector(x,y);                      
          PVector first = rel_vel;
          //apply rotation 
          steer = PVector.add(first,sec);
        } 
      }
    }
    
    return steer;
  }
  PVector align(ArrayList<Boid> boids) {
    float neighbordist = mouse_xrad;
    PVector V_T = new PVector(0, 0);
    int count = 0;
    float eta = random(0,1);
    PVector noise = PVector.random2D();
    float magnitude = 0.1 * (eta - 0.5); 
    noise.setMag(magnitude);
    
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        PVector v_t = PVector.fromAngle(other.velocity.heading()); 
        V_T.add(v_t);
        V_T.add(noise);
        count++;
      }
    }
    if (count > 0) {
      float dt = (curr_t - lasttime) / 1000.0;
      V_T.div((float)count); 
      V_T.mult(dt);
      V_T.normalize();
      V_T.mult(maxspeed); 
      PVector steer = PVector.sub(V_T, velocity);
      steer.limit(maxforce);
      return steer;
    } else {
      return new PVector(0, 0);
    }
  }
  //validate(){
  //}
 
public PVector Momentum(ArrayList<Boid> boids) {
  float neighbordist = mouse_xrad; 
  PVector desiredVelocitySum = new PVector(0, 0);
  int count = 0;
  
  
  float myMass = this.r; 
  if (myMass <= 0) myMass = 1.0; 

  for (Boid other : boids) {
    float d = PVector.dist(this.position, other.position);
    if ((d > 0) && (d < neighbordist)) {
      PVector neighborMomentum = PVector.mult(other.velocity, other.r);
      PVector matchedVelocity = PVector.div(neighborMomentum, myMass);
      desiredVelocitySum.add(matchedVelocity);
      count++;
    }
  }

  if (count > 0) {
    // Average all the desired velocities from the neighbors
    desiredVelocitySum.div((float)count);
    desiredVelocitySum.limit(maxspeed);
    PVector steer = PVector.sub(desiredVelocitySum, this.velocity);
    steer.limit(maxforce);  
    
    return steer;
  } else {
    // Return an empty vector if there are no neighbors
    return new PVector(0, 0);
  }
}
  PVector view(ArrayList<Boid> boids) {
    float sightDistance = mouse_xrad;
    float periphery = 2*PI;

    for (Boid other : boids) {
      PVector comparison = PVector.sub(other.position, position);
      float d = PVector.dist(position, other.position);
      float diff = PVector.angleBetween(comparison, velocity);

      if (diff < periphery && d > 0 && d < sightDistance) {
        other.highlight();
      }
    }

    float currentHeading = velocity.heading();
    pushMatrix();
    translate(position.x, position.y);
    rotate(currentHeading);
    fill(0, 100);
    arc(0, 0, sightDistance*2, sightDistance*2, -periphery, periphery);
    popMatrix();

    return new PVector();
  }

  //validation table
  void Validate(ArrayList<Boid> boids,Table table,int i) {
    float cluster_Size = 5.0;
    float mass = this.size;
    TableRow newRow = table.addRow();
    newRow.setInt("id", i);
    Boid b_measure = null;
    // --- PASS 1: Count the neighbors to find the total mass ---
    for (Boid other : boids) {
      if (other == this) continue; 
      float d = PVector.dist(position, other.position);
      if (d < cluster_Size && d > 0) {
        mass = mass + other.size;
        b_measure = other;
      }
    } 
    
    if (b_measure != null) {
      float cvv = b_measure.velocity.dot(this.velocity);
      newRow.setFloat("CVV", cvv);
    }
   
       
  }
  
  void highlight() {
    col = color(255, 0, 0);
  }
}