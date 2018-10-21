import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;


Box2DProcessing box2d;

Ship player1, player2;

color darkwater = color(0, 0, 128);
color medwater = color(70, 130, 180);
color lightwater = color(176, 196, 222);

boolean reverse;

final int boundwidth = 5;
final float TURNSPEED = 0.1;
final float bulletspeed = 50;
final float bulletradius = 2.5;
final int respawnframes = 200;
final int fireimmunetime = 10;

ArrayList<Boundary> boundaries;
ArrayList<Bullet> bullets;
ArrayList<Ship> players;
ArrayList<Object> destroy;
ArrayList<Crate> crates;
ArrayList<Powerup> powerups;

void setup() {
  size(750, 750);
  smooth();

  loadImages();

  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.listenForCollisions();

  bullets = new ArrayList<Bullet>();
  players = new ArrayList<Ship>();
  destroy = new ArrayList<Object>();
  crates = new ArrayList<Crate>();
  powerups = new ArrayList<Powerup>();

  boundaries = new ArrayList<Boundary>();
  boundaries.add(new Boundary(0, height/2, boundwidth, height, 0));
  boundaries.add(new Boundary(width, height/2, boundwidth, height, 0));
  boundaries.add(new Boundary(width/2, 0, width, boundwidth, 0));
  boundaries.add(new Boundary(width/2, height, width, boundwidth, 0));
  boundaries.add(new CircleBoundary(width/2, height/2, width/4));

  crates.add(new Crate(width/2, height/2));
  crates.add(new Crate(width/2, height/2));
  crates.add(new Crate(width/2, height/2));
  crates.add(new Crate(width/2, height/2));
  crates.add(new Crate(width/2, height/2));
  crates.add(new Crate(width/2, height/2));
  crates.add(new Crate(width/2, height/2));
  crates.add(new Crate(width/2, height/2));
  crates.add(new Crate(width/2, height/2));
  crates.add(new Crate(width/2, height/2));

  player1 = new Ship(width/4, height/2);
  player2 = new Ship(width*3/4, height/2);
  players.add(player1);
  players.add(player2);


  box2d.setGravity(0, 0);

  reverse = false;

  /*
  BodyDef bd = new BodyDef();
   Vec2 center = box2d.coordPixelsToWorld(width/2,height/2);
   bd.position.set(center);
   bd.fixedRotation = true;
   bd.linearDamping = 0.8;
   bd.angularDamping = 0.9;
   bd.bullet = true;
   Body body = box2d.createBody(bd);
   body.setLinearVelocity(new Vec2(0,3));
   body.setAngularVelocity(1.2);
   PolygonShape ps = new PolygonShape();
   float box2Dw = box2d.scalarPixelsToWorld(150);
   float box2Dh = box2d.scalarPixelsToWorld(100);
   ps.setAsBox(box2Dw, box2Dh);
   FixtureDef fd = new FixtureDef();
   fd.shape = ps;
   fd.friction = 0.3;
   fd.restitution = 0.5;
   fd.density = 1.0;
   body.createFixture(fd);
   */
}

void draw() {
  background(medwater);

  box2d.step();
  
  look();

  for (Object o : destroy) {
    if (o instanceof Bullet)
      ((Bullet)o).killBody();
    if (o instanceof Ship)
      ((Ship)o).killBody();
    if (o instanceof Crate)
      ((Crate)o).killBody();
    if (o instanceof Powerup)
      powerups.remove((Powerup) o);
  }
  destroy.clear();

  for (Boundary wall : boundaries) {
    wall.display();
  }  

  for (Ship p : players) {
    p.display();
  }

  for (Bullet b : bullets) {
    b.display();
  }

  for (Crate c : crates) {
    c.display();
  }

  for (Powerup p : powerups) {
    p.display();
  }

  for (Ship p : players) {
    if (frameCount % 100 == 0 && p.ammo < 3)
      p.ammo++;
    Body body = p.body;
    Vec2 pos = body.getPosition();
    float angle = body.getAngle();
    body.setTransform(pos, angle + p.turn);
    p.body.applyLinearImpulse(new Vec2(cos(angle), sin(angle)).mul(25), pos, true);
    Vec2 v = p.body.getLinearVelocity();
    if (p.pilot)
      p.body.setLinearVelocity(new Vec2(v.x*0.6f, v.y*0.6f));
    else
      p.body.setLinearVelocity(new Vec2(v.x*0.8f, v.y*0.8f));

    if (p.pilot) {
      if (frameCount - p.deadsince > respawnframes) {
        p.deadsince = -1;
        p.pilot = false;
      }
    }
    Vec2 pixelloc = box2d.coordWorldToPixels(pos.x, pos.y);
    for (Powerup power : powerups) {
      if ((power.x-pixelloc.x)*(power.x-pixelloc.x) + (power.y-pixelloc.y)*(power.y-pixelloc.y) < 50*50) {
        p.pickup(power);
      }
    }
  }

  for (int i = players.size()-1; i >= 0; i--) {
    Ship p = players.get(i);
  }
}

void mousePressed() {
  Ship p = new Ship(mouseX, mouseY);
  players.add(p);
}

void keyPressed() {
  if (key == 'd') {
    player1.turn = reverse ? TURNSPEED : -TURNSPEED;
  }

  if (key == CODED) {

    if (keyCode == RIGHT) {
      player2.turn = reverse ? TURNSPEED : -TURNSPEED;
    }
  }
}

void keyReleased() {
  if (key == 'd') {
    player1.turn = 0;
  }

  if (key == 'w') {
    player1.shoot();
  }

  if (key == CODED) {

    if (keyCode == RIGHT) {
      player2.turn = 0;
    }

    if (keyCode == UP) {
      player2.shoot();
    }
  }
}

void beginContact(Contact cp) {
  // Get both fixtures
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  // Get both bodies
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();

  // Get our objects that reference these bodies
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();

  if (o1 == null || o2 == null)
    return;


  if (o1.getClass() ==  Ship.class && o2.getClass() == Ship.class) {
    Ship p1 = (Ship) o1;
    if (p1.pilot)
      p1.hit();
    Ship p2 = (Ship) o2;
    if (p2.pilot)
      p2.hit();
  } else if (o1.getClass() ==  Bullet.class && o2.getClass() == Boundary.class) {
    Bullet p1 = (Bullet) o1;
    destroy.add(p1);
  } else if (o1.getClass() == Boundary.class && o2.getClass() == Bullet.class) {
    Bullet p1 = (Bullet) o2;
    destroy.add(p1);
  } else if (o1.getClass() ==  Bullet.class && o2.getClass() == Ship.class) {
    Bullet p1 = (Bullet) o1;
    destroy.add(p1);
    Ship p2 = (Ship) o2;
    if (p1.source != p2 || frameCount - p1.created > 10)
      p2.hit();
  } else if (o1.getClass() == Ship.class && o2.getClass() == Bullet.class) {
    Bullet p1 = (Bullet) o2;
    Ship p2 = (Ship) o1;
    if (p1.source != p2 || frameCount - p1.created > 10) {
      p2.hit();
      destroy.add(p1);
    }
  } else if (o1.getClass() ==  Bullet.class && o2.getClass() == Crate.class) {
    Bullet p1 = (Bullet) o1;
    destroy.add(p1);
    Crate p2 = (Crate) o2;
    p2.hit();
  } else if (o1.getClass() == Crate.class && o2.getClass() == Bullet.class) {
    Bullet p1 = (Bullet) o2;
    destroy.add(p1);
    Crate p2 = (Crate) o1;
    p2.hit();
  } else {
    if (o1.getClass() == Bullet.class) {
      Bullet p1 = (Bullet)o1;
      destroy.add(p1);
    }
    if (o2.getClass() == Bullet.class) {
      Bullet p2 = (Bullet)o2;
      destroy.add(p2);
    }
  }
}

void endContact(Contact cp) {
}
