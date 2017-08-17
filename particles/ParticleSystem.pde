import java.util.Collections;

class ParticleSystem {

  public PImage image;
  public String texture;
  public final ArrayList<Particle> particles;
  public float stepDuration = 10;
  private int lastStep;
  private float availableEmit;

  public float emitCount = 1;
  public float startX = 0, startY = 0, startRndX = 0, startRndY = 0;
  public float speedX = 0, speedY = 0, speedRndX = 0, speedRndY = 0;
  public float gravityX = 0, gravityY = 0;
  public float scale = 1, scaleRnd = 0;
  public float lifetime = 100, lifetimeRnd = 10;
  public float tintRndR = 0, tintRndG = 0, tintRndB = 0, tintRndA = 0;
  public TimeFloat tintR, tintG, tintB, tintA;

  public ParticleSystem() {
    setTexture("particle.png");
    particles = new ArrayList<Particle>();
    lastStep = -1;
    tintR = new TimeFloat(255);
    tintG = new TimeFloat(255);
    tintB = new TimeFloat(255);
    tintA = new TimeFloat(255);
  }

  public void save(File file) {
    JSONObject o = new JSONObject();
    o.setFloat("emitCount", emitCount);
    o.setFloat("startX", startX);
    o.setFloat("startY", startY);
    o.setFloat("startRndX",startRndX);
    o.setFloat("startRndY", startRndY);
    o.setFloat("speedX", speedX);
    o.setFloat("speedY", speedY);
    o.setFloat("speedRndX", speedRndX);
    o.setFloat("speedRndY", speedRndY);
    o.setFloat("gravityX", gravityX);
    o.setFloat("gravityY", gravityY);
    o.setFloat("scale", scale);
    o.setFloat("scaleRnd", scaleRnd);
    o.setFloat("lifetime", lifetime);
    o.setFloat("lifetimeRnd", lifetimeRnd);
    o.setFloat("tintRndR", tintRndR);
    o.setFloat("tintRndG", tintRndG);
    o.setFloat("tintRndB", tintRndB);
    o.setFloat("tintRndA", tintRndA);
    o.setJSONArray("tintR", saveTimeFloat(tintR));
    o.setJSONArray("tintG", saveTimeFloat(tintG));
    o.setJSONArray("tintB", saveTimeFloat(tintB));
    o.setJSONArray("tintA", saveTimeFloat(tintA));
    saveJSONObject(o, file.getAbsolutePath());
  }
  
  private JSONArray saveTimeFloat(TimeFloat tf){
    JSONArray a = new JSONArray();
    for(int i = 0; i < tf.points.size(); i++){
      JSONObject o = new JSONObject();
      o.setFloat("time", tf.points.get(i).time);
      o.setFloat("value", tf.points.get(i).value);
      a.append(o);
    }
    return a;
  }

  public void load(File file) {
    JSONObject o = loadJSONObject(file);
    emitCount = o.getFloat("emitCount");
    startX = o.getFloat("startX");
    startY = o.getFloat("startY");
    startRndX = o.getFloat("startRndX");
    startRndY = o.getFloat("startRndY");
    speedX = o.getFloat("speedX");
    speedY = o.getFloat("speedY");
    speedRndX = o.getFloat("speedRndX");
    speedRndY = o.getFloat("speedRndY");
    gravityX = o.getFloat("gravityX");
    gravityY = o.getFloat("gravityY");
    scale = o.getFloat("scale");
    scaleRnd = o.getFloat("scaleRnd");
    gravityX = o.getFloat("gravityX");
    gravityY = o.getFloat("gravityY");
    scale = o.getFloat("scale");
    scaleRnd = o.getFloat("scaleRnd");
    lifetime = o.getFloat("lifetime");
    lifetimeRnd = o.getFloat("lifetimeRnd");
    tintRndR = o.getFloat("tintRndR");
    tintRndG = o.getFloat("tintRndG");
    tintRndB = o.getFloat("tintRndB");
    tintRndA = o.getFloat("tintRndA");
    loadTimeFloat(o.getJSONArray("tintR"), tintR);
    loadTimeFloat(o.getJSONArray("tintG"), tintG);
    loadTimeFloat(o.getJSONArray("tintB"), tintB);
    loadTimeFloat(o.getJSONArray("tintA"), tintA);
  }
  
  private void loadTimeFloat(JSONArray a, TimeFloat tf){
    tf.reset(0);
    for(int i = 0; i < a.size(); i++){
      tf.set(a.getJSONObject(i).getFloat("time"), a.getJSONObject(i).getFloat("value"));
    }
  }

  public void setTexture(File file) {
    setTexture(file.getName());
  }

  public void setTexture(String file) {
    texture = file;
    image = loadImage(file);
  }

  public void reset() {
    for (Particle particle : particles) {
      particle.alive = false;
    }
    lastStep = -1;
    availableEmit = 0;
  }

  public void update() {
    if (lastStep == -1) {
      lastStep = millis();
    }
    int now = millis();
    while (lastStep + stepDuration < now) {
      lastStep += stepDuration;
      step();
    }
  }

  private void step() {
    for (Particle particle : particles) {
      if (particle.alive) {
        particle.step();
      }
    }
    availableEmit += emitCount;
    while (availableEmit > 1) {
      availableEmit -= 1;
      addParticle();
    }
  }

  public void addParticle() {
    for (Particle particle : particles) {
      if (!particle.alive) {
        particle.init();
        return;
      }
    }
    particles.add(new Particle());
  }

  public void draw(int x, int y) {
    pushMatrix();
    translate(x, y);
    for (Particle particle : particles) {
      particle.draw();
    }
    popMatrix();
  }

  class Particle {
    public boolean alive;
    public float x, y, sx, sy, sc, li, trr, trg, trb, tra, age;

    public Particle() {
      init();
    }

    public void init() {
      alive = true;
      x = startX + randomGaussian() * startRndX;
      y = startY + randomGaussian() * startRndY;
      sx = speedX + randomGaussian() * speedRndX;
      sy = speedY + randomGaussian() * speedRndY;
      sc = scale + randomGaussian() * scaleRnd;
      li = lifetime + randomGaussian() * lifetimeRnd;
      trr = randomGaussian() * tintRndR;
      trg = randomGaussian() * tintRndG;
      trb = randomGaussian() * tintRndB;
      tra = randomGaussian() * tintRndA;
      age = 0;
    }

    public void step() {
      x += sx;
      y += sy;
      sx += gravityX;
      sy += gravityY;
      age += 1;

      if (age > li) {
        alive = false;
      }
    }

    public void draw() {
      if (!alive) {
        return;
      }
      pushMatrix();
      scale(sc);
      translate(x - image.width / 2, y - image.height / 2);
      float tr = tintR.get(age, 0, li) + trr;
      float tg = tintG.get(age, 0, li) + trg;
      float tb = tintB.get(age, 0, li) + trb;
      float ta = tintA.get(age, 0, li) + tra;
      tint(tr, tg, tb, ta);
      image(image, 0, 0);
      noTint();
      popMatrix();
    }
  }
}

class TimeFloat {

  public ArrayList<FloatPair> points;

  public TimeFloat() {
    this(0);
  }

  public TimeFloat(float value) {
    points = new ArrayList<FloatPair>();
    points.add(new FloatPair(0, value));
    points.add(new FloatPair(1, value));
  }
  
  public void reset(float value) {
    points.clear();
    points.add(new FloatPair(0, value));
    points.add(new FloatPair(1, value));
  }

  public void set(float time, float value) {
    for (FloatPair fp : points) {
      if (abs(fp.time - time) < 0.00001) {
        fp.value = value;
        return;
      }
    }
    points.add(new FloatPair(time, value));
    Collections.sort(points);
  }

  public void moveTime(int timepoint, float time) {
    if (timepoint != 0 && timepoint != points.size() - 1) {
      points.get(timepoint).time = time;
      Collections.sort(points);
    }
  }

  public void moveValue(int timepoint, float value) {
    points.get(timepoint).value = value;
  }

  public void unset(int timepoint) {
    if (timepoint != 0 && timepoint != points.size() - 1) {
      points.remove(timepoint);
    }
  }

  public float get(float a, float min, float max) {
    return get(map(a, min, max, 0, 1));
  }

  public float get(float time) {
    FloatPair last = points.get(0);
    FloatPair next = null;
    for (int i = 1; i < points.size(); i++) {
      if (points.get(i).time >= time) {
        next = points.get(i);
        break;
      }
      last = points.get(i);
    }
    if (next == null) {
      return points.get(points.size() - 1).value;
    }
    return lerp(last.value, next.value, map(time, last.time, next.time, 0, 1));
  }
}

class FloatPair implements Comparable {
  public float time, value;

  public FloatPair(float time, float value) {
    this.time = time;
    this.value = value;
  }

  public int compareTo(Object oo) {
    if (!(oo instanceof FloatPair)) {
      return 1;
    }
    FloatPair o = (FloatPair)oo;
    if (o.time > time) {
      return -1;
    }
    if (o.time < time) {
      return 1;
    }
    //o.time == time
    if (o.value > value) {
      return -1;
    }
    if (o.value < value) {
      return 1;
    }
    return 0;
  }
}