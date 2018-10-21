
class Crate {
  int size = 3;

  Body body;
  float w, h;

  Crate(float x, float y) {
    w = crate.width*size/3f;
    h = crate.height*size/3f;
    makeBody(x, y);
  }
  Crate(float x, float y, int size) {
    this.size = size;
    w = crate.width*size/3f;
    h = crate.height*size/3f;
    makeBody(x, y);
  }

  void hit() {
    Vec2 pixelpos = box2d.getBodyPixelCoord(body);
    powerups.add(new Powerup(pixelpos.x, pixelpos.y));
    destroy.add(this);
  }
  
  void killBody(){
    crates.remove(this);
    box2d.destroyBody(body);
  }
    
    
 void display() {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(a);
    // Let's add a line so we can see the rotation
    image(crate, 0, 0, w, h);
    popMatrix();
  }

  void makeBody(float x, float y) {
    // Define a body
    BodyDef bd = new BodyDef();
    // Set its position
    bd.position = box2d.coordPixelsToWorld(x, y);
    bd.type = BodyType.DYNAMIC;
    body = box2d.createBody(bd);

    // Make the body's shape a circle
    PolygonShape sd = new PolygonShape();
    // Figure out the box2d coordinates
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    // We're just a box
    sd.setAsBox(box2dW, box2dH);

    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 0.01;
    fd.restitution = 1;

    // Attach fixture to body
    body.createFixture(fd);

    body.setAngularVelocity(random(-10, 10));
    body.setLinearVelocity(new Vec2(random(-10, 10), random(-10, 10)));
    body.setUserData(this);
  }
}
