PImage dude, fire, ship, boomImg;
FixedQueue<Float> xQueue;
int lastFrame, delta;
boolean[] keys = new boolean[256];

int waveCount;
float[] waves, wavesSpeed;
float dudeX, dudeY, speedX, speedY, shipX, shipY, shipDestX;
boolean onShip, boom;

void setup() {
  size(800, 480);
  dude = loadImage("dude.png");
  fire = loadImage("fire.png");
  ship = loadImage("ship.png");
  boomImg = loadImage("boom.png");
  xQueue = new FixedQueue<Float>(20, width/2f);
  lastFrame = millis();
  reset();
  waveCount = width / 5 + 1;
  waves = new float[waveCount];
  wavesSpeed = new float[waveCount];
  shipX = random(ship.width, width - ship.width / 2);
}

void reset() {
  dudeX = width / 2;
  dudeY = - dude.height / 2;
  speedX = 0;
  speedY = 20;
  shipY = height - 100;
  shipDestX = shipX;
  onShip = false;
  boom = false;
  for (int i = 0; i < xQueue.capacity; i++) {
    xQueue.push(dudeX);
  }
}

void drawDude() {
  xQueue.push(dudeX);
  float diffX = constrain(dudeX - xQueue.peek(), -500, 500);

  pushMatrix();
  if (onShip) {
    translate(shipX, shipY);
    rotate(PI * 0.04 * sin(millis() * 0.001f));
    image(dude, -dude.width / 2, -dude.height / 2 - 10);
  } else if (boom) {
    translate(dudeX, dudeY);
    rotate(TWO_PI * millis() * 0.0005f);
    image(boomImg, -boomImg.width / 2, -boomImg.height / 2);
  } else {
    translate(dudeX, dudeY);
    rotate(PI * 0.3 * diffX / 500f);
    image(dude, -dude.width / 2, -dude.height / 2);
    if (keys['W']) {
      image(fire, -fire.width / 2, -fire.height / 2);
    }
    
    fill(0);
    textSize(20);
    text(""+ceil(speedY), dude.width / 2, 0);
  }
  popMatrix();
}

void drawShip() {
  pushMatrix();
  translate(shipX, shipY);
  rotate(PI * 0.04 * sin(millis() * 0.001f));
  image(ship, -ship.width / 2, -ship.height / 2);
  popMatrix();
}

void drawWater() {
  pushMatrix();
  translate(0, height);
  noStroke();
  fill(#537BE5);
  rect(0, -75, width, 100);
  for (int i = 0; i < waveCount; i++) {
    waves[i] += wavesSpeed[i] * delta * 0.001f;
    waves[i] = constrain(waves[i], -5, 5);
    wavesSpeed[i] *= pow(0.99, delta);
    wavesSpeed[i] += randomGaussian();
    ellipse(i * 5, -70 + waves[i], 20, 20);
  }
  popMatrix();
}

void updateDude() {
  if (onShip || boom) {
    return;
  }

  speedX *= pow(0.998, delta);
  speedY += delta * 0.01;
  if (keys['A']) {
    speedX -= delta;
  }
  if (keys['D']) {
    speedX += delta;
  }
  if (keys['W']) {
    speedY -= delta * 0.05;
  }
  dudeX += speedX * delta * 0.001f;
  dudeY += speedY * delta * 0.001f;
  dudeX = constrain(dudeX, 0, width);

  if (abs(shipX - dudeX) < ship.width * 0.2f && abs(shipY - dudeY) < 10 && abs(speedY) < 11) {
    onShip = true;
    return;
  } 
  
  if (abs(shipX - dudeX) < ship.width / 2 && dudeY > shipY - 5) {
    boom = true;
    return;
  }
  
  if (dudeY > height - 80){
    boom = true;
    return;
  }
}

void updateShip() {
  if (abs(shipX - shipDestX) < 10) {
    shipDestX = random(ship.width, width - ship.width);
  }
  
  shipX += (shipDestX > shipX ? 1 : -1) * 0.01f * delta;
}

void draw() {
  int newLastFrame = millis();
  delta = newLastFrame - lastFrame;
  lastFrame = newLastFrame;

  if (keys['R']) {
    reset();
  }

  updateDude();
  updateShip();

  background(#D6F8FF);
  drawShip();
  drawDude();
  drawWater();
}

void keyPressed() {
  if (keyCode < 256) {
    keys[keyCode] = true;
  }
}

void keyReleased() {
  if (keyCode < 256) {
    keys[keyCode] = false;
  }
}