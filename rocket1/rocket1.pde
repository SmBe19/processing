PImage dude, ship;
ParticleSystem rocketps, waterps;
TweenEngine tweenEngine;
FixedQueue<Float> xQueue;
int lastFrame, delta;
boolean[] keys = new boolean[256];
boolean[] oKeys = new boolean[256];

int waveCount, waveWidth = 4;
float[] waves, wavesSpeed;
Tween dudeX, dudeY, speedX, speedY, dudeA;
Tween fuel, uiA, rocketpsY;
Tween shipX, shipY, shipDestX;
boolean onShip, boom, resetting;
float rocketpsOrigEmit;
float usage = 0.03f, okVelo = 11;

void setup() {
  size(800, 480);
  // fullScreen();
  surface.setTitle("SpaceX Simulator");
  
  dude = loadImage("dude.png");
  ship = loadImage("ship.png");
  rocketps = new ParticleSystem();
  waterps = new ParticleSystem();
  tweenEngine = new TweenEngine();
  xQueue = new FixedQueue<Float>(20, width/2f);
  lastFrame = millis();
  
  initTweens();
  reset();
  rocketpsOrigEmit = rocketps.emitCount.v;
  waterps.load("water.json");
  waterps.startRndX.v = width / 3;
  waterps.reset();

  waveCount = width / waveWidth + 1;
  waves = new float[waveCount];
  wavesSpeed = new float[waveCount];
  usage = 14f / height;
}

void initTweens() {
  dudeX = tweenEngine.create(0);
  dudeY = tweenEngine.create(0);
  speedX = tweenEngine.create(0);
  speedY = tweenEngine.create(0);
  dudeA = tweenEngine.create(255);
  fuel = tweenEngine.create(0);
  uiA = tweenEngine.create(255);
  rocketpsY = tweenEngine.create(0);
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
  dudeA.v = 255;
  fuel.reset().set(100);
  uiA.reset().set(255);
  rocketpsY.reset().set(0);
  shipY.v = height - 100;
  shipDestX.v = shipX.v;
  onShip = false;
  boom = false;
  resetting = false;
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
  tint(255, 255, 255, dudeA.v);
  
  if (onShip) {
    rotate(PI * 0.04 * sin(millis() * 0.001f));
  } else {
    rotate(PI * 0.3 * diffX / 500f);
  }
  
  // dude
  image(dude, -dude.width / 2, -dude.height / 2);
  
  // ui
  pushMatrix();
  translate(0, -dude.height * 0.8);
  
  noStroke();
  fill(#DB0000, uiA.v);
  rect(-10, 12, 20, 5);
  fill(#00C90F, uiA.v);
  rect(-10, 12, map(fuel.v, 0, 100, 0, 20), 5);
  
  noFill();
  stroke(0, uiA.v);
  strokeWeight(2);
  arc(0, 0, 40, 40, -(PI + QUARTER_PI), QUARTER_PI, OPEN);
  noStroke();
  fill(#00C90F, uiA.v);
  arc(0, 0, 40, 40, -(HALF_PI + QUARTER_PI * 0.8), -QUARTER_PI * 1.2, PIE);
  
  float angle = constrain(map(speedY.v, -okVelo, okVelo, -QUARTER_PI * 0.8, QUARTER_PI * 0.8), -(HALF_PI + QUARTER_PI), HALF_PI + QUARTER_PI);
  rotate(angle);
  stroke(0, uiA.v);
  line(0, 0, 0, -20);
  popMatrix();
  
  // particle system
  noTint();
  pushMatrix();
  scale(0.5);
  rocketps.draw(0, (int)rocketpsY.v);
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
  waterps.update();
  pushMatrix();
  translate(0, height);
  waterps.draw(width / 2, -75);
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
  if(resetting){
    speedY.v -= delta * 0.05;
    rocketps.emitCount.v = rocketpsOrigEmit;
    if(boom && rocketpsY.v < 0.001){
      rocketpsY.linear(7000, dude.height * 4);
    }
    
    if(dudeY.v < -dude.height * 5 || rocketpsY.v >= dude.height * 3.8){
      reset();
    }
  }
  
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
  if (keys['W'] && fuel.v > 0) {
    speedY.v -= delta * 0.05;
    rocketps.emitCount.v = rocketpsOrigEmit;
    fuel.v = constrain(fuel.v - usage * delta, 0, 100);
  } else if (!resetting) {
    rocketps.emitCount.v = 0;
  }
  dudeX.v += speedX.v * delta * 0.001f;
  dudeY.v += speedY.v * delta * 0.001f;
  dudeX.v = constrain(dudeX.v, 0, width);

  if (abs(shipX.v + 5 - dudeX.v) < ship.width * 0.2f && abs(shipY.v - dudeY.v) < 10 && abs(speedY.v) < okVelo) {
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
  dudeA.linear(500, 0);
  uiA.linear(500, 0);
  if(onShip){
    dudeX.mirror(shipX);
    dudeY.mirror(shipY);
  }
}

void landDude() {
  if(resetting){
    return;
  }
  onShip = true;
  rocketps.emitCount.v = 0;
  uiA.linear(2000, 0);
  fuel.linear(1000, 100);
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

  if (!resetting && !oKeys['R'] && keys['R']) {
    resetting = true;
    dudeX.reset();
    dudeY.reset();
    onShip = false;
  }

  tweenEngine.update();

  updateDude();
  updateShip();

  background(#D6F8FF);
  drawShip();
  drawDude();
  drawWater();
  
  for(int i = 0; i < keys.length; i++){
    oKeys[i] = keys[i];
  }
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