final int DOUBLE = 0;
final int REVERSE = 1;
final int SCATTER = 2;


final int powerupw = 15;
final int poweruph = 15;

class Powerup {
  float x, y;
  int type;

  Powerup(float x_, float y_) {
    x= x_;
    y = y_;
    type = (int) random(3);
  }

  void display() {
    pushMatrix();
    translate(x, y);
    imageMode(CENTER);
    switch(type) {
    case DOUBLE:
      image(doubleshot, 0, 0, powerupw, poweruph);
      break;
    case REVERSE:
      image(reverseicon, 0, 0, powerupw, poweruph);
      break;
    case SCATTER:
      image(scatter, 0, 0, powerupw, poweruph);
      break;
    }
    popMatrix();
  }
}
