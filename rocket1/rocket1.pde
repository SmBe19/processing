PImage dude, ship;
ParticleSystem rocketps;
TweenEngine tweenEngine;
FixedQueue<Float> xQueue;
int lastFrame, delta;
boolean[] keys = new boolean[256];

int waveCount, waveWidth = 5;
float[] waves, wavesSpeed;
Tween dudeX, dudeY, speedX, speedY, rocketA;
Tween shipX, shipY, shipDestX;
boolean onShip, boom;
float rocketpsOrigEmit;

void setup() {
  size(800, 480);
  dude = loadImage("dude.png");
  ship = loadImage("ship.png");
  rocketps = new ParticleSystem();
  tweenEngine = new TweenEngine();
  initTweens();
  xQueue = new FixedQueue<Float>(20, width/2f);
  lastFrame = millis();
  reset();
  rocketpsOrigEmit = rocketps.emitCount.v;

  waveCount = width / waveWidth + 1;
  waves = new float[waveCount];
  wavesSpeed = new float[waveCount];
}

void initTweens() {
  dudeX = tweenEngine.create(0);
  dudeY = tweenEngine.create(0);
  speedX = tweenEngine.create(0);
  speedY = tweenEngine.create(0);
  rocketA = tweenEngine.create(255);
  shipX = tweenEngine.create(0);
  shipY = tweenEngine.create(0);
  shipDestX = tweenEngine.create(random(ship.width, width - ship.width / 2));
}

void reset() {
  tweenEngine.reset();
  dudeX.v = width / 2;
  dudeY.v = - dude.height / 2;
  speedX.v = 0;
  speedY.v = 20;
  rocketA.v = 255;
  shipY.v = height - 100;
  shipDestX.v = shipX.v;
  onShip = false;
  boom = false;
  for (int i = 0; i < xQueue.capacity; i++) {
    xQueue.push(dudeX.v);
  }
  rocketps.load("rocketfly.json");
  rocketps.reset();
}

void drawDude() {
  rocketps.update();
  xQueue.push(dudeX.v);
  float diffX = constrain(dudeX.v - xQueue.peek(), -500, 500);

  pushMatrix();
  translate(dudeX.v, dudeY.v);
  tint(255, 255, 255, rocketA.v);
  if (onShip) {
    rotate(PI * 0.04 * sin(millis() * 0.001f));
    image(dude, -dude.width / 2, -dude.height / 2);
  } else {
    rotate(PI * 0.3 * diffX / 500f);
    image(dude, -dude.width / 2, -dude.height / 2);
    if (!boom) {
      fill(0);
      textSize(20);
      text(""+ceil(speedY.v), dude.width / 2, 0);
    }
  }
  noTint();
  pushMatrix();
  scale(0.5);
  rocketps.draw(0, 0);
  popMatrix();
  popMatrix();
}

void drawShip() {
  pushMatrix();
  translate(shipX.v, shipY.v);
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
    waves[i] = constrain(waves[i], -waveWidth, waveWidth);
    wavesSpeed[i] *= pow(0.99, delta);
    wavesSpeed[i] += randomGaussian();
    ellipse(i * waveWidth, -70 + waves[i], 20, 20);
  }
  popMatrix();
}

void updateDude() {
  if (onShip || boom) {
    return;
  }

  speedX.v *= pow(0.998, delta);
  speedY.v += delta * 0.01;
  if (keys['A']) {
    speedX.v -= delta;
  }
  if (keys['D']) {
    speedX.v += delta;
  }
  if (keys['W']) {
    speedY.v -= delta * 0.05;
    rocketps.emitCount.v = rocketpsOrigEmit;
  } else {
    rocketps.emitCount.v = 0;
  }
  dudeX.v += speedX.v * delta * 0.001f;
  dudeY.v += speedY.v * delta * 0.001f;
  dudeX.v = constrain(dudeX.v, 0, width);

  if (abs(shipX.v + 5 - dudeX.v) < ship.width * 0.2f && abs(shipY.v - dudeY.v) < 15 && abs(speedY.v) < 11) {
    landDude();
    return;
  } 

  if (abs(shipX.v - dudeX.v) < ship.width / 2 && dudeY.v > shipY.v - 5) {
    onShip = true;
    explodeDude();
    return;
  }

  if (dudeY.v > height - 80) {
    explodeDude();
    return;
  }
}

void explodeDude() {
  boom = true;
  rocketps.load("rocketboom.json");
  rocketps.reset();
  rocketA.linear(500, 0);
  if(onShip){
    dudeX.mirror(shipX);
    dudeY.mirror(shipY);
  }
}

void landDude() {
  onShip = true;
  rocketps.emitCount.v = 0;
  dudeX.align(500, shipX, 5).mirror(shipX);
  dudeY.align(500, shipY, -10).mirror(shipY);
}

void updateShip() {
  if (abs(shipX.v - shipDestX.v) < 10) {
    shipDestX.v = random(ship.width, width - ship.width);
  }

  shipX.v += (shipDestX.v > shipX.v ? 1 : -1) * 0.01f * delta;
}

void draw() {
  int newLastFrame = millis();
  delta = newLastFrame - lastFrame;
  lastFrame = newLastFrame;

  if (keys['R']) {
    reset();
  }

  tweenEngine.update();

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