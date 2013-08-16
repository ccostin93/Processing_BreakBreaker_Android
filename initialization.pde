int remaining()
{
  int k = 0;
  switch(level) {
  case 1:
  case 2: 
    k = bricks.size();    
    break;
  case 3:
  case 4:
  case 5: 
    k = balls.size();
    break;
  case 6:
  case 7:
    k = rectangles.size();
    break;
  default: 
    k = 1;
    break;
  }
  return k;
}

void init(int level) {
  fireTimer = hardTimer = 0;
  gravityTimer = maxGravityTimer;
  grav = false;
  if (gravity.size() != 0) {
    gravity.remove(0);
  }
  pad = new Pad();
  for (int i=padBall.size()-1; i>=0; i--) {
    padBall.remove(i);
  }
  padBall.add(new Ball(12, pad.getX(), pad.getY() - pad.getHeight()/2 - 12, 0, 0));
  newBall = true;
  switch(level) {
  case 1: 
    for (int i = bricks.size()-1; i>=0; i--) {
      bricks.remove(i);
    }
    for (int i=0; i<5; i++) {
      for (int j=0; j<7; j++) {
        bricks.add(new Brick(j*width/7 + width/14, 75 + i*height/23 + height/50, width/7 - 5, height/25 - 5, 100, 200));
      }
    }
    break;
  case 2:
    for (int i = bricks.size()-1; i>=0; i--) {
      bricks.remove(i);
    }
    for (int i=0; i<10; i++) {
      for (int j=0; j<5; j++) {
        bricks.add(new Brick(j*width/5 + width/14 + 16, 75 + i*height/23 + height/50, width/7 - 5, height/25 - 5, 100, 250));
      }
    }
    break;
  case 3: 
    for (int i=balls.size()-1; i>=0; i--) {
      balls.remove(i);
    }
    for (int i=0; i<3; i++) {
      for (int j=0; j<5; j++) {
        balls.add(new Balls(j*width/5 + width/10, 50 + i*100 + 50, 200, 0, 0, 30, 400));
      }
    }
    break;
  case 4:
    for (int i=balls.size()-1; i>=0; i--) {
      balls.remove(i);
    }
    for (int i=0; i<5; i++) {
      balls.add(new Balls(50, 75 + i*90, 250, 4, 0, 30, 350));
      balls.add(new Balls(width-50, 75 + i*90, 250, -4, 0, 30, 350));
    }
    break;
  case 5:
    for (int i=balls.size()-1; i>=0; i--) {
      balls.remove(i);
    }
    for (int i=0; i<10; i++) {
      balls.add(new Balls(width/2, height/2 - 30, 400, 0, 0, (i+1)*20, 500));
    }
    break;
  case 6: 
    for (int i=rectangles.size()-1; i>=0; i--) {
      rectangles.remove(i);
    }
    for (int i=0; i<7; i++) {
      rectangles.add(new Rectangle(i*width/7 + width/14, height * 2/3, width/10, width/8, 700, 650));
    }
    break;
  case 7: 
    for (int i=rectangles.size()-1; i>=0; i--) {
      rectangles.remove(i);
    }
    for (int i=0; i<5; i++) {
      rectangles.add(new Rectangle(i*width/6 + width/5, i*height/10 + 100, width/5, height/8, 300, 350));
      rectangles.add(new Rectangle(width-i*width/6-width/5, i*height/10 + 130, width/5, height/8, 300, 350));
    }
    break;
  default:
    break;
  }
}

void initSound() {
  maxim = new Maxim(this);
  impacts = new AudioPlayer[6];
  impacts[0] = maxim.loadFile("audio/impact0.wav"); //impact ball with pad
  impacts[1] = maxim.loadFile("audio/impact1.wav"); //impact ball with bricks
  impacts[2] = maxim.loadFile("audio/impact3.wav"); //impact ball with walls
  impacts[3] = maxim.loadFile("audio/impact4.wav"); //impact ball with balls
  impacts[4] = maxim.loadFile("audio/impact5.wav"); //ball explosion
  impacts[0].setLooping(false);
  impacts[1].setLooping(false);
  impacts[2].setLooping(false);
  impacts[3].setLooping(false);
  impacts[4].setLooping(false);
  impacts[0].volume(1.0);
  impacts[1].volume(1.0);
  impacts[2].volume(0.2);
  impacts[3].volume(1.5);
  impacts[4].volume(1.0);
}

