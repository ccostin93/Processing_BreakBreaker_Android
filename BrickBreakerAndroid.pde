Accelerometer accel;

PImage background;
PImage button;
PImage[] powerUp;
Pad pad;
ArrayList<Ball> padBall = new ArrayList();
ArrayList<Brick> bricks = new ArrayList();
ArrayList<Balls> balls = new ArrayList();
ArrayList<Rectangle> rectangles = new ArrayList();
ArrayList<Gravity> gravity = new ArrayList();
final int maxAge = 150; //the time for which the gravity ball exists
final int maxGravityTimer = 300; //the time for which the player needs to wait before acivating the gravity ball again
int gravityTimer;
boolean grav;

Maxim maxim;
AudioPlayer[] impacts;

int level, Score, lives;
final int maxLevel = 7;
boolean play = false, pause = false;
boolean menu = true, help = false, settings = false;
boolean playButtonPress = false;

boolean newBall = true; //at the beginning when the ball needs to be launched and when you lose a ball and need to start again

final int chanceOfPowerUps = 6;
final int typesOfPowerUps = 9; //total number of powerUps
final int extendTime = 300; //the time of any powerup
int fireTimer, hardTimer; //the remaining time for fireball, hardball
ArrayList<PowerUp> powerUps  = new ArrayList();

boolean touch = true; //if touch == true, then pad follows touch; if touch == false then tilding using accelerometer

void setup() {
  background = loadImage("background.jpg");
  button = loadImage("button.png");
  orientation(PORTRAIT);
  smooth();
  Score = 0;
  frameRate(30);

  accel = new Accelerometer();
  powerUp = new PImage[8];
  powerUp = loadImages("powerup/powerup", ".png", 9);
  initSound();
}

void draw() {
  imageMode(CORNER);
  image(background, 0, 0, width, height);
  //image(background, width, width * background.height/background.width);
  if (play) {
    if (level == 0) {
      play = false;
    }
    if (lives == 0 || level > maxLevel) {
      showResult();
    }
    else if (lives > 0 && !pause) {
      pad.render(); //render pad
      for (int i=padBall.size()-1; i>=0; i--) {
        padBall.get(i).render(i);
      }
      //ball.render(); //render ball
      if (powerUps.size() > 0) {
        for (int i = 0; i < powerUps.size(); i++) {
          powerUps.get(i).render(i); //Renders all power ups
        }
      }

      switch(level) {
      case 1:
      case 2: 
        for (int i=bricks.size()-1; i>=0; i--) {
          bricks.get(i).render(i);
        }
        break;
      case 3:
      case 4:
      case 5:
        for (int i=balls.size()-1; i>=0; i--) {
          for (int j=padBall.size()-1; j>=0; j--) {
            balls.get(i).checkCollision(padBall.get(j));
          }
          balls.get(i).render(i);
        }
        break;
      case 6:
      case 7:
        for (int i=rectangles.size()-1; i>=0; i--) {
          rectangles.get(i).render(i);
        }
        break;
      }
      //gravity control
      fill(#5499E8);
      stroke(255);
      float time = maxGravityTimer - gravityTimer;
      if (gravityTimer == maxGravityTimer) {
        time = maxGravityTimer;
      }
      arc(width - 30, height - 30, 30, 30, -PI/2, map(time, 0, 300, -PI/2, TWO_PI-PI/2));
      if (grav) {
        gravityTimer--;
        if (gravityTimer == 0) {
          grav = false;
          gravityTimer = maxGravityTimer;
        }
      }
      if (gravity.size() != 0) {
        for (int i=padBall.size()-1; i>=0; i--) {
          if (gravity.get(0).getPosition().dist(padBall.get(i).getPosition()) > 75) {
            applyAttractiveForce(gravity.get(0), padBall.get(i), 700, 10);
          }
        }
        gravity.get(0).render();
      }

      textAlign(CORNER);
      textSize(15);
      fill(255);
      text("Score: " + Score, 8, 18);
      text("Level: " + level, width - 100, 18);
      textAlign(CENTER);
      text("Lives: " + lives, width/2, 18);
      imageMode(CENTER);
      image(button, width - 25, 15, 20, 20);

      if (remaining() == 0) {
        level++;
        init(level);
      }
    }
    else if (pause) {
      showSettings();
    }
  }
  else {
    if (help) {
      showHelp();
    }
    else if (settings) {
      showSettings();
    }
    else {
      showMenu();
    }
  }
}

void mousePressed() {
  if (pause || settings) {
    rect(width/2, height/4, 200, 60, 10);
    rect(width/2, height/4 + 70, 200, 60, 10);
    if (mouseX >= width/2 - 100 && mouseX <= width/2 + 100 
      && mouseY >= height/4 - 30 && mouseY <= height/4 + 30) {
      touch = true;
    }
    else if (mouseX >= width/2 - 100 && mouseX <= width/2 + 100 
      && mouseY >= height/4 + 40 && mouseY <= height/4 + 100) {
      touch = false;
    }
    else {
      pause = false;
      settings = false;
    }
  }
  else if (play) {
    if (mouseX >= width - 40 && mouseX <= width &&
      mouseY >= 0 && mouseY <= 30) {
      pause = true;
    }
    else if (mouseY < height*2/3 && !newBall && !grav) {
      gravity.add(new Gravity());
      grav = true;
    }
    if (newBall) {
      playButtonPress = false;
    }
    if (lives == 0 || level > maxLevel) {
      play = false;
    }
  }
  else if (help || settings) {
    help = false;
    settings = false;
  }
  else if (mouseX > width/2 - 130 && mouseX < width/2 + 130 
    && mouseY > height/4 - 30 && mouseY < height/4 + 30) { //play button
    play = true;
    playButtonPress = true;
    level = 1;
    init(level);
    lives = 3;
    Score = 0;
  }
  else if (mouseX > width/2 - 130 && mouseX < width/2 + 130 
    && mouseY > height/4 + 40 && mouseY < height/4 + 110) { //help button
    help = true;
  }
  else if (mouseX > width/2 - 130 && mouseX < width/2 + 130 
    && mouseY > height/4 + 110 && mouseY < height/4 + 170) { //settings button
    settings = true;
  }
  else if (mouseX > width/2 - 130 && mouseX < width/2 + 130 
    && mouseY > height/4 + 180 && mouseY < height/4 + 240) { //exit button
    exit();
  }
}

void mouseReleased() {
  if (play) { 
    if (newBall && !playButtonPress) {
      padBall.get(0).setVelocity(0, -10);
      newBall = false;
    }
  }
}

void applyAttractiveForce(Gravity a, Ball b, float strength, float minDistance) {
  PVector dir = PVector.sub(a.position, b.position);
  float d = dir.mag();
  if (d < minDistance) d = minDistance;
  dir.normalize();
  float force = (strength * a.mass * b.mass) / (d * d);
  dir.mult(force);
  b.applyForce(dir);
}

void showSettings() {
  rectMode(CENTER);
  stroke(20);
  if (touch) { 
    fill(120, 160);
  }
  else {
    fill(40, 160);
  }
  rect(width/2, height/4, 200, 60, 10);
  if (!touch) { 
    fill(120, 160);
  }
  else {
    fill(40, 160);
  }
  rect(width/2, height/4 + 70, 200, 60, 10);
  textAlign(CENTER, CENTER);
  if (pause) {
    textSize(40);
    fill(255);
    text("PAUSE", width/2, height/4 - 65);
  }
  textSize(34);
  if (touch) { 
    fill(20);
  }
  else {
    fill(255);
  }
  text("TOUCH", width/2, height/4 - 3);
  if (!touch) { 
    fill(20);
  }
  else {
    fill(255);
  }
  text("TILT", width/2, height/4 + 67);
}

void showMenu() {
  rectMode(CENTER);
  stroke(20);
  fill(40, 160);
  rect(width/2, height/4, 270, 60, 10);
  rect(width/2, height/4 + 70, 270, 60, 10);
  rect(width/2, height/4 + 140, 270, 60, 10);
  rect(width/2, height/4 + 210, 270, 60, 10);
  textAlign(CENTER, CENTER);
  textSize(34);
  fill(255);
  text("PLAY", width/2, height/4 - 3);
  text("HELP", width/2, height/4 + 67);
  text("SETTINGS", width/2, height/4 + 137);
  text("QUIT", width/2, height/4 + 207);
}

void showHelp() {
  rectMode(CENTER);
  stroke(20);
  fill(40, 160);
  rect(width/2, height/2, 400, 455, 10);
  String[] instrunction = {
    " - enlarge pad", " - shrink pad", " - increase ball speed", " - decrease ball speed", " - fireball (explosion)", 
    " - hardball (double damage)", " - x 3 balls", " - increase pad speed", " - decrease pad speed"
  };
  textAlign(CORNER);
  fill(255);
  textSize(25);
  for (int i=0; i<9; i++) {
    image(powerUp[i], width/2 - 190, height/2 - 220 + i*50, 40, 40);
    text(instrunction[i], width/2 - 147, height/2 - 196 + i*50);
  }
}

void showResult() {
  textSize(32);
  textAlign(CENTER, CENTER);
  if (lives == 0) {
    text("GAME OVER", width/2, height/2 - 16);
  }
  else {
    text("CONGRATULATIONS", width/2, height/2 - 16);
  }
  text("SCORE: " + Score, width/2, height/2 + 16);
}

void keyPressed()
{
  if (key == CODED)
  {
    if (keyCode == 24) {
      level++;
      init(level);
    }
    else if (keyCode == 25) {
      level--;
      init(level);
    }
  }
}

