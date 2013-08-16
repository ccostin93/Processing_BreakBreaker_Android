class Pad
{
  float x, y; //coordonates
  float l, h; //length, height
  float speed;
  float m;

  Pad() {
    x = width/2; //in the middle
    l = 4.2 * width / 15; //the length of the pad
    h = height/23; //the height of the pad
    y = height - 2*h/3; //the y-axis coordonate
    speed = 8; //the speed of the pad
    m = 0;
  }

  float getX() {
    return x;
  }
  float getY() {
    return y;
  }
  float getLength() {
    return l + m;
  }
  float getHeight() {
    return h;
  }
  float getSpeed() {
    return speed;
  }
  void enlarge(float value) {
    m += value;
  }
  void shrink(float value) {
    m -= value;
  }
  void accelerate() {
    speed += 4;
  }
  void deccelerate() {
    speed -= 4;
  }

  void render() {
    //pad movement
    if (mousePressed) {
      if (newBall) {//the ball is attached to pad
        padBall.get(0).setPosition(x, y);
      }
      else if (mouseY >= height*3/4 && touch) {//dragging
        if (x < mouseX) {
          x += speed;
          if (x > mouseX) {
            x = mouseX;
          }
        }
        else if (x > mouseX) {
          x -= speed;
          if (x <= mouseX) {
            x = mouseX;
          }
        }
        if (x >= width) {
          x = width;
        }
        else if (x <= 0) {
          x = 0;
        }
      }
    }
    if (!touch) {//tilting
     if (newBall) {//the ball is attached to pad
     padBall.get(0).setPosition(x, y);
     }
     if (accel.getX() > 1.1) {
     x -= speed;
     }
     else if (accel.getX() < -0.8) {
     x += speed;
     }
     if (x >= width) {
     x = width;
     }
     else if (x <= 0) {
     x = 0;
     }
     }

    //pad drawing
    noStroke();
    fill(129, 230, 200);
    rectMode(CENTER);
    if (l+m > width/2) { //enlarge limit
      m = width/2 - l;
    }
    else if (l+m < 80) { //shrink limit
      m = 100 - l;
    }
    rect(x, y, l+m, h);
  }
}

class Gravity {
  PVector position;
  float mass;
  float age;

  Gravity() {
    position = new PVector(mouseX, mouseY);
    mass = 30;
    age = 0;
  }
  PVector getPosition() {
    return position;
  }

  void render() {
    age++;
    ellipseMode(CENTER);
    fill(255);
    ellipse(position.x, position.y, 12, 12);
    if (age > maxAge) {
      gravity.remove(0);
    }
  }
}

class Ball //the main ball which destroy the bricks and the ball balls
{
  PVector position;
  PVector velocity;
  PVector acceleration;
  float radius, m; //ball radius
  float damage; //the damage it does on impact
  float fire = 30;
  float mass;

  Ball(float rad, float newX, float newY, float velX, float velY) {
    radius = rad;
    m = radius*.1;
    position = new PVector(newX, newY);
    velocity = new PVector(velX, velY);
    damage = 100;
    mass = 1;
    acceleration = new PVector(0, 0);
  }

  float getX() {
    return position.x;
  }
  float getY() {
    return position.y;
  }
  PVector getPosition() {
    return position;
  }
  PVector getVelocity() {
    return velocity;
  }
  float getRadius() {
    return radius;
  }
  float getExplosionRadius() {//when fireball explodes
    return radius + 30;
  }
  float getDamage() {
    if (hardTimer > 0) {
      return damage*2;
    }
    else return damage;
  }
  float getSpeed() {
    return velocity.mag();
  }

  void setPosition(float padX, float padY) {
    position.x = pad.getX();
    position.y = pad.getY() - pad.getHeight()/2 - radius;
  }
  void setVelocity(float xVel, float yVel) {
    velocity = new PVector(xVel, yVel);
  }
  void invVelX() {
    velocity.x *= -1;
  }
  void invVelY() {
    velocity.y *= -1;
  }
  void accelerate() {
    float currentSpeed = velocity.mag();
    velocity.setMag(currentSpeed * 1.5);
  }
  void deccelerate() {
    float currentSpeed = velocity.mag();
    velocity.setMag(currentSpeed * 2/3);
  }
  void applyForce(PVector force) {
    acceleration.add(PVector.div(force, mass));
  }

  void render(int number) {
    //ball movement
    float speed = velocity.mag();
    velocity.add(acceleration);
    velocity.setMag(speed);
    position.add(velocity);
    acceleration.mult(0);
    if (position.x + radius >= width) {
      position.x = width - radius;
      velocity.x *= -1;
      impacts[2].cue(0);
      impacts[2].play();
    }
    else if (position.x - radius <= 0) {
      position.x = radius;
      velocity.x *= -1;
      impacts[2].cue(0);
      impacts[2].play();
    }

    if (position.y - radius <= 0) {
      position.y = radius;
      velocity.y *= -1;
      impacts[2].cue(0);
      impacts[2].play();
    }
    else if (position.y + radius >= height) {
      padBall.remove(number);
      if (padBall.size() == 0) {//if it was the last ball
        init(0);
        lives--;
        fireTimer = 0;
        hardTimer = 0;
      }
    }

    //Pad collision
    if (position.x + radius >= pad.getX() - pad.getLength()/2 && position.x - radius <= pad.getX() + pad.getLength()/2) {
      if (position.y + radius >= pad.getY() - pad.getHeight()/2) {
        //calculate angle of reflection
        float alpha = map(position.x, pad.getX() - pad.getLength()/2, pad.getX() + pad.getLength()/2, 30, 150);
        speed = sqrt(velocity.x * velocity.x + velocity.y * velocity.y);
        velocity.x = -speed * cos(radians(alpha));
        velocity.y = -speed * sin(radians(alpha));
        if (speed > 0) {
          impacts[0].cue(0);
          impacts[0].play();
        }
      }
    }

    //ball drawing
    noStroke();
    textSize(12);
    ellipseMode(CENTER);
    if (fireTimer > 0) {
      fill(221, 100, 53);    
      ellipse(position.x, position.y, radius*2+20, radius*2+20);
      fireTimer--;
    }
    if (hardTimer > 0) {
      fill(200);
      hardTimer--;
    }
    else {
      fill(255, 255, 102);
    }
    ellipse(position.x, position.y, radius*2, radius*2);
  }
}

