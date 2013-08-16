class PowerUp 
{
  PVector position;
  float speed = 6;
  float size = 25;
  int type; /*
  0 - increase pad, 
   1 - decrease pad, 
   2 - increase speed ball, 
   3 - decreae speed ball,
   4 - fireball,
   5 - hardball,
   6 - x3 
   7 - increase speed pad
   8 - decrease speed pad*/

  PowerUp(float newX, float newY) {
    position = new PVector(newX, newY);
    type = (int)random(0, typesOfPowerUps);
  }

  void render(int powerUpNumber) {
    //powerup movement
    position.y += speed;
    //Pad collision
    if (position.x + size >= pad.getX() - pad.getLength()/2 && position.x - size <= pad.getX() + pad.getLength()/2) {
      if (position.y + size >= pad.getY() - pad.getHeight()/2) {
        switch(type) {
        case 0:
          pad.enlarge(50);
          break;
        case 1:
          pad.shrink(50);
          break;
        case 2:
          for (int i=padBall.size()-1; i>=0; i--) {
            padBall.get(i).accelerate();
          }
          break;
        case 3:
          for (int i=padBall.size()-1; i>=0; i--) {
            padBall.get(i).deccelerate();
          }
          break;
        case 4: 
          fireTimer = extendTime;
          break;
        case 5:
          hardTimer = extendTime;
          break;
        case 6:
          Ball ball = padBall.get(0);
          float speed = ball.getSpeed();
          float sin = ball.getVelocity().y/speed;
          float alpha = asin(sin);
          alpha += PI - PI/3;
          padBall.add(new Ball(ball.getRadius(), ball.getX(), ball.getY(), cos(alpha) * speed, sin(alpha) * speed));
          alpha += PI - PI/3;
          padBall.add(new Ball(ball.getRadius(), ball.getX(), ball.getY(), cos(alpha) * speed, sin(alpha) * speed));
          break;
        case 7:
          pad.accelerate();
          break;
        case 8:
          if (pad.getSpeed() > 4) {
            pad.deccelerate();
          }
          break;
        }
        powerUps.remove(powerUpNumber);
      }
    }
    //pad didnt catch it
    else if (position.y + size >= height) {
      powerUps.remove(powerUpNumber);
    }

    //powerup display
    imageMode(CENTER);
    image(powerUp[type], position.x, position.y, size*2, size*2);
  }
}

