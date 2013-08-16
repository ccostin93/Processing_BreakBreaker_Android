class Rectangle 
{ 
  PVector position, speed = new PVector(0, 0);
  float l, h; //brick length & height
  float Hp; //brick hp
  float score;

  Rectangle(float newX, float newY, float newLength, float newHeight, float newHp, float newScore) {
    position = new PVector(newX, newY);
    l = newLength;
    h = newHeight;
    Hp = newHp;
    score = newScore;
  }
  float getHp() {
    return Hp;
  }

  void render(int number) {
    if (position.y <= 80 || position.y >= height * 2/3) {
      speed.y *= -1;
    }
    position.y += speed.y;

    for (int i=padBall.size()-1; i>=0; i--) {
      Ball ball = padBall.get(i);
      if (ball.getX() + ball.getRadius() >= position.x - l/2 && ball.getX() - ball.getRadius() <= position.x + l/2
        && ball.getY() + ball.getRadius() >= position.y - h/2 && ball.getY() - ball.getRadius() <= position.y + h/2) {
        if ((ball.getX() < position.x - l/2 && ball.getVelocity().x > 0)
          || (ball.getX() > position.x + l/2 && ball.getVelocity().x < 0)) {
          ball.invVelX();
        }
        if ((ball.getY() < position.y - h/2 && ball.getVelocity().y > 0)
          || (ball.getY() > position.y + h/2 && ball.getVelocity().y < 0)) {
          ball.invVelY();
        }

        Hp -= ball.getDamage();
        if (level == 6) {
          if (speed.y >= 0) {
            speed.y += 2;
          }
          else {
            speed.y -= 2;
          }
        }

        if (fireTimer > 0) {
          impacts[4].cue(0);
          impacts[4].play();
        }
        else {
          impacts[3].cue(0);
          impacts[3].play();
        }

        if (fireTimer > 0) {
          for (int j=rectangles.size()-1; j>=0; j--) {
            if (j != number) {
              Rectangle rect = rectangles.get(j);
              if (ball.getX() + ball.getExplosionRadius() >= rect.position.x - l/2 && ball.getX() - ball.getExplosionRadius() <= rect.position.x + l/2
                && ball.getY() + ball.getExplosionRadius() >= rect.position.y - h/2 && ball.getY() - ball.getExplosionRadius() <= rect.position.y + h/2) {
                rect.Hp -= ball.getDamage();
              }
            }
          }
        }

        //powerUp
        if (int(random(chanceOfPowerUps)) == 0) {//If the random chance happens in which a power-up should be dropped
          powerUps.add(new PowerUp(position.x, position.y));
        }
      }
    }

    //brick display
    rectMode(CENTER);
    stroke(255);
    noFill();
    rect(position.x, position.y, l, h);

    if (Hp <= 0) {
      Score += score;
      rectangles.remove(number);
    }
  }
}

class Brick
{
  PVector position;
  float l, h; //brick length & height
  float Hp; //brick hp
  float score;
  float r=random(0, 255), b=random(0, 255), g=random(0, 255); //brick red,blue,green color

  Brick(float newX, float newY, float newLength, float newHeight, float newHp, float newScore) {
    position = new PVector(newX, newY);
    l = newLength;
    h = newHeight;
    Hp = newHp;
    score = newScore;
  }
  float getHp() {
    return Hp;
  }

  void render(int number) {
    for (int i=padBall.size()-1; i>=0; i--) {
      Ball ball = padBall.get(i);
      if (ball.getX() + ball.getRadius() >= position.x - l/2 && ball.getX() - ball.getRadius() <= position.x + l/2
        && ball.getY() + ball.getRadius() >= position.y - h/2 && ball.getY() - ball.getRadius() <= position.y + h/2) {
        if ((ball.getX() < position.x - l/2 && ball.getVelocity().x > 0)
          || (ball.getX() > position.x + l/2 && ball.getVelocity().x < 0)) {
          ball.invVelX();
        }
        if ((ball.getY() < position.y - h/2 && ball.getVelocity().y > 0)
          || (ball.getY() > position.y + h/2 && ball.getVelocity().y < 0)) {
          ball.invVelY();
        }

        Hp -= ball.getDamage();
        if (fireTimer > 0) {
          impacts[4].cue(0);
          impacts[4].play();
        }
        else {
          impacts[1].cue(0);
          impacts[1].play();
        }

        if (fireTimer > 0) {
          for (int j=bricks.size()-1; j>=0; j--) {
            if (j != number) {
              Brick brick = bricks.get(j);
              if (ball.getX() + ball.getExplosionRadius() >= brick.position.x - l/2 && ball.getX() - ball.getExplosionRadius() <= brick.position.x + l/2
                && ball.getY() + ball.getExplosionRadius() >= brick.position.y - h/2 && ball.getY() - ball.getExplosionRadius() <= brick.position.y + h/2) {
                brick.Hp -= ball.getDamage();
              }
            }
          }
        }

        //powerUp
        if (int(random(chanceOfPowerUps)) == 0) {//If the random chance happens in which a power-up should be dropped
          powerUps.add(new PowerUp(position.x, position.y));
        }
      }
    }

    //brick display
    rectMode(CENTER);
    noStroke();
    fill(r, b, g);
    rect(position.x, position.y, l, h);

    if (Hp <= 0) {
      Score += score;
      bricks.remove(number);
    }
  }
}

class Balls
{
  PVector position = new PVector(0, 0);
  PVector velocity = new PVector(0, 0);
  float radius, m; //radius
  float Hp, score;
  float bounciness = 0.9; //every time the ball bounces off a wall is loses some of its impuls

  Balls(float newX, float newY, float newHp, float velX, float velY, float newRadius, float newScore) {
    position = new PVector(newX, newY);
    velocity = new PVector(velX, velY);
    radius = newRadius;
    m = radius * .1;
    Hp = newHp;
    score = newScore;
  }

  float getHp() {
    return Hp;
  }
  void setVelocity(float velX, float velY) {
    velocity = new PVector(velX, velY);
  }

  void checkCollision(Ball ball) {
    if (Hp > 0) {
      // get distances between the balls components
      PVector bVect = PVector.sub(ball.position, position);

      // calculate magnitude of the vector separating the balls
      float bVectMag = bVect.mag();
      float dx = ball.position.x - position.x;
      float dy = ball.position.y - position.y;
      float distance = sqrt(dx*dx + dy*dy);
      float minDist = ball.radius + radius + 6;
      if (distance < minDist) { 
        // get angle of bVect
        float theta  = bVect.heading();
        // precalculate trig values
        float sine = sin(theta);
        float cosine = cos(theta);

        /* bTemp will hold rotated ball positions. You 
         just need to worry about bTemp[1] position*/
        PVector[] bTemp = {
          new PVector(), new PVector()
          };

          /* this ball's position is relative to the ball
           so you can use the vector between them (bVect) as the 
           reference point in the rotation expressions.
           bTemp[0].position.x and bTemp[0].position.y will initialize
           automatically to 0.0, which is what you want
           since b[1] will rotate around b[0] */
          bTemp[1].x  = cosine * bVect.x + sine * bVect.y;
        bTemp[1].y  = cosine * bVect.y - sine * bVect.x;

        // rotate Temporary velocities
        PVector[] vTemp = {
          new PVector(), new PVector()
          };

          vTemp[0].x  = cosine * velocity.x + sine * velocity.y;
        vTemp[0].y  = cosine * velocity.y - sine * velocity.x;
        vTemp[1].x  = cosine * ball.velocity.x + sine * ball.velocity.y;
        vTemp[1].y  = cosine * ball.velocity.y - sine * ball.velocity.x;

        /* Now that velocities are rotated, you can use 1D
         conservation of momentum equations to calculate 
         the final velocity along the x-axis. */
        PVector[] vFinal = {  
          new PVector(), new PVector()
          };

          // final rotated velocity for b[0]
          vFinal[0].x = ((m - ball.m) * vTemp[0].x + 2 * ball.m * vTemp[1].x) / (m + ball.m);
        vFinal[0].y = vTemp[0].y;

        // final rotated velocity for b[0]
        vFinal[1].x = ((ball.m - m) * vTemp[1].x + 2 * m * vTemp[0].x) / (m + ball.m);
        vFinal[1].y = vTemp[1].y;

        // hack to avoid clumping
        bTemp[0].x += vFinal[0].x;
        bTemp[1].x += vFinal[1].x;

        /* Rotate ball positions and velocities back
         Reverse signs in trig expressions to rotate 
         in the opposite direction */
        // rotate balls
        PVector[] bFinal = { 
          new PVector(), new PVector()
          };

          bFinal[0].x = cosine * bTemp[0].x - sine * bTemp[0].y;
        bFinal[0].y = cosine * bTemp[0].y + sine * bTemp[0].x;
        bFinal[1].x = cosine * bTemp[1].x - sine * bTemp[1].y;
        bFinal[1].y = cosine * bTemp[1].y + sine * bTemp[1].x;

        // update velocities
        if (level == 3) {
          position.add(bFinal[0]);
          velocity.x = cosine * vFinal[0].x - sine * vFinal[0].y;
          velocity.y = cosine * vFinal[0].y + sine * vFinal[0].x;
        }
        float speed = ball.velocity.mag();
        ball.velocity.x = cosine * vFinal[1].x - sine * vFinal[1].y;
        ball.velocity.y = cosine * vFinal[1].y + sine * vFinal[1].x;
        ball.velocity.setMag(speed);

        //decrease Hp
        if (hardTimer > 0) {
          Hp -= ball.damage*2;
        }
        else {
          Hp -= ball.damage;
        }

        //audio
        if (fireTimer > 0) {
          impacts[4].cue(0);
          impacts[4].play();
        }
        else {
          impacts[3].cue(0);
          impacts[3].play();
        }

        //powerup
        if (int(random(chanceOfPowerUps)) == 0) {//If the random chance happens in which a power-up should be dropped
          powerUps.add(new PowerUp(position.x, position.y));
        }
      }
    }
  }

  void render(int number) {
    //ball movement
    position.add(velocity);
    //collision with wall
    if (position.x+radius >= width) {
      velocity.x *= -bounciness;
      position.x = width - radius;
    }
    else if (position.x-radius <= 0) {
      velocity.x *= -bounciness;
      position.x = radius;
    }
    if (position.y-radius < 0) {
      velocity.y *= -bounciness;
      position.y = radius;
    }
    else if (position.y+radius > height - pad.getHeight()) {
      velocity.y *= -bounciness;
      position.y = height - pad.getHeight() - radius;
    }

    //ball display
    stroke(255);
    strokeWeight(2);
    noFill();
    ellipse(position.x, position.y, radius*2, radius*2);

    if (Hp <= 0) {
      Score += score;
      balls.remove(number);
    }
  }
}

