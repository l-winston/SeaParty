final int TRIPLESHOT = 0;

class Ship {
  int ammo;
  boolean triple;
  boolean jousters;
  int powerup;
  boolean pilot;
  int deadsince;
  Body body;
  float w, h;
  float turn;


  Ship(float x, float y) {
    w = ship.width/2;
    h = ship.height/2;
    pilot = false;
    powerup = -1;
    deadsince = -1;
    turn = 0;
    triple = false;
    ammo = 3;
    makeBody(new Vec2(x, y));
  }

  void hit() {
    if (pilot) {
      destroy.add(this);
    } else {
      pilot = true;
      powerup = -1;
      body.setLinearVelocity(new Vec2(0, 0));
      deadsince = frameCount;
    }
  }

  void pickup(Powerup p) {
    destroy.add(p);
    if (p.type == REVERSE)
      reverse ^= true;
    else if(p.type == DOUBLE)
      triple = true;
    else
      powerup = p.type;
  }

  void shoot() {
    if (pilot) {
      //add some speed
    } else if (powerup == -1) {
      if (ammo <= 0)
        return;
      ammo --;

      if (!triple) {
        bullets.add(create(PI/2));
        bullets.add(create(-PI/2));
      } else { 
        bullets.add(create(PI/2+PI/18));
        bullets.add(create(PI/2-PI/18));
        bullets.add(create(-PI/2+PI/18));
        bullets.add(create(-PI/2-PI/18));
      }
    } else if (powerup == SCATTER){
      powerup = -1;
      for(int i = 0; i < 8; i++){
        bullets.add(create(i*2*PI/8));
      }
    }
  }

  Bullet create(float a) {
    float angle = body.getAngle();
    float converted = ship.height/4;
    Vec2 vec = box2d.getBodyPixelCoord(body).add(new Vec2(converted*cos(angle+a), converted*-sin(angle+a)));
    return new Bullet(vec.x, vec.y, bulletspeed*cos(angle+a), bulletspeed*sin(angle+a), this);
  }

  void killBody() {
    players.remove(this);
    box2d.destroyBody(body);
  }

  void display() {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get its angle of rotation
    float a = body.getAngle();

    rectMode(CENTER);
    imageMode(CENTER);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a);

    if (!pilot)
      image(ship, 0, 0, w, h);
    else
      image(liferaft, 0, 0, w/2, h/2);
    popMatrix();
  }

  void makeBody(Vec2 center) {

    // Define the body and make it from the shape


    PolygonShape sd = new PolygonShape();
    Vec2[] vertices = new Vec2[4];
    //float box2dW = box2d.scalarPixelsToWorld(w/2);
    //float box2dH = box2d.scalarPixelsToWorld(h/2);
    //sd.setAsBox(box2dW, box2dH);
    vertices[0] = box2d.vectorPixelsToWorld(new Vec2(-ship.width/4.25f, 0));
    vertices[1] = box2d.vectorPixelsToWorld(new Vec2(0, ship.height/5.5f));
    vertices[2] = box2d.vectorPixelsToWorld(new Vec2(ship.width/4.25f, 0));
    vertices[3] = box2d.vectorPixelsToWorld(new Vec2(0, -ship.height/5.5f));
    sd.set(vertices, vertices.length);

    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    fd.density = 1;
    fd.friction = 0.5;
    fd.restitution = 0.2;

    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(center));
    bd.setFixedRotation(true);

    body = box2d.createBody(bd);
    body.createFixture(fd);

    body.setLinearDamping(0.5f);
    body.setLinearVelocity(new Vec2(random(-5, 5), random(-5, 5)));
    body.setUserData(this);
  }
}
