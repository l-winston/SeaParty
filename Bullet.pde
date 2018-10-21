class Bullet{
  Body body;
  Ship source;
  int created;
  public Bullet(float x, float y, float vx, float vy, Ship source){
    makeBody(new Vec2(x, y), new Vec2(vx, vy));
    this.source = source;
    created = frameCount;
  }
  
  void makeBody(Vec2 center, Vec2 vel){
    CircleShape sd = new CircleShape();
    sd.setRadius(box2d.scalarPixelsToWorld(bulletradius));

    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 0.5;

    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.setFixedRotation(true);
    bd.position.set(box2d.coordPixelsToWorld(center));
    bd.bullet = true;

    body = box2d.createBody(bd);
    body.createFixture(fd);
    body.setLinearVelocity(vel);
    body.setUserData(this);
  }
  
  void killBody() {
    bullets.remove(this);
    box2d.destroyBody(body);
  }

  // Drawing the box
  void display() {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation

    rectMode(CENTER);
    pushMatrix();

    translate(pos.x, pos.y);
    fill(175);
    stroke(0);

    ellipse(0, 0, 2*bulletradius, 2*bulletradius); 

    popMatrix();
  }
}
