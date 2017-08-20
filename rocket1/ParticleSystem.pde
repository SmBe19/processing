import java.util.Collections;

class ParticleSystem {

  public PImage image;
  public String texture;
  public final ArrayList<Particle> particles;
  public float stepDuration = 10;
  private int lastStep;
  private float availableEmit;

  public FloatRapper emitCount = new FloatRapper(1);
  public FloatRapper startX = new FloatRapper(0), startY = new FloatRapper(0), startRndX = new FloatRapper(0), startRndY = new FloatRapper(0);
  public FloatRapper speedX = new FloatRapper(1), speedY = new FloatRapper(1), speedRndX = new FloatRapper(0.5), speedRndY = new FloatRapper(0.5);
  public FloatRapper gravityX = new FloatRapper(0), gravityY = new FloatRapper(0.01);
  public FloatRapper scale = new FloatRapper(1), scaleRnd = new FloatRapper(0);
  public FloatRapper lifetime = new FloatRapper(100), lifetimeRnd = new FloatRapper(20);
  public FloatRapper tintRndR = new FloatRapper(0), tintRndG = new FloatRapper(0), tintRndB = new FloatRapper(0), tintRndA = new FloatRapper(0);
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
    o.setString("texture", texture);
    o.setFloat("emitCount", emitCount.v);
    o.setFloat("startX", startX.v);
    o.setFloat("startY", startY.v);
    o.setFloat("startRndX",startRndX.v);
    o.setFloat("startRndY", startRndY.v);
    o.setFloat("speedX", speedX.v);
    o.setFloat("speedY", speedY.v);
    o.setFloat("speedRndX", speedRndX.v);
    o.setFloat("speedRndY", speedRndY.v);
    o.setFloat("gravityX", gravityX.v);
    o.setFloat("gravityY", gravityY.v);
    o.setFloat("scale", scale.v);
    o.setFloat("scaleRnd", scaleRnd.v);
    o.setFloat("lifetime", lifetime.v);
    o.setFloat("lifetimeRnd", lifetimeRnd.v);
    o.setFloat("tintRndR", tintRndR.v);
    o.setFloat("tintRndG", tintRndG.v);
    o.setFloat("tintRndB", tintRndB.v);
    o.setFloat("tintRndA", tintRndA.v);
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
    load(loadJSONObject(file));
  }
  
  public void load(String file) {
    load(loadJSONObject(file));
  }
  
  public void load(JSONObject o){
    setTexture(o.getString("texture"));
    emitCount.v = o.getFloat("emitCount");
    startX.v = o.getFloat("startX");
    startY.v = o.getFloat("startY");
    startRndX.v = o.getFloat("startRndX");
    startRndY.v = o.getFloat("startRndY");
    speedX.v = o.getFloat("speedX");
    speedY.v = o.getFloat("speedY");
    speedRndX.v = o.getFloat("speedRndX");
    speedRndY.v = o.getFloat("speedRndY");
    gravityX.v = o.getFloat("gravityX");
    gravityY.v = o.getFloat("gravityY");
    scale.v = o.getFloat("scale");
    scaleRnd.v = o.getFloat("scaleRnd");
    gravityX.v = o.getFloat("gravityX");
    gravityY.v = o.getFloat("gravityY");
    scale.v = o.getFloat("scale");
    scaleRnd.v = o.getFloat("scaleRnd");
    lifetime.v = o.getFloat("lifetime");
    lifetimeRnd.v = o.getFloat("lifetimeRnd");
    tintRndR.v = o.getFloat("tintRndR");
    tintRndG.v = o.getFloat("tintRndG");
    tintRndB.v = o.getFloat("tintRndB");
    tintRndA.v = o.getFloat("tintRndA");
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
    availableEmit += emitCount.v;
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
      x = startX.v + randomGaussian() * startRndX.v;
      y = startY.v + randomGaussian() * startRndY.v;
      sx = speedX.v + randomGaussian() * speedRndX.v;
      sy = speedY.v + randomGaussian() * speedRndY.v;
      sc = scale.v + randomGaussian() * scaleRnd.v;
      li = lifetime.v + randomGaussian() * lifetimeRnd.v;
      trr = randomGaussian() * tintRndR.v;
      trg = randomGaussian() * tintRndG.v;
      trb = randomGaussian() * tintRndB.v;
      tra = randomGaussian() * tintRndA.v;
      age = 0;
    }

    public void step() {
      x += sx;
      y += sy;
      sx += gravityX.v;
      sy += gravityY.v;
      age += 1;

      if (age > li) {
        alive = false;
      }
    }

    public void draw() {
      if (!alive) {
        return;
      }
      float tr = tintR.get(age, 0, li) + trr;
      float tg = tintG.get(age, 0, li) + trg;
      float tb = tintB.get(age, 0, li) + trb;
      float ta = tintA.get(age, 0, li) + tra;
      float w = image.width * sc, h = image.height * sc;
      tint(tr, tg, tb, ta);
      image(image, x - w / 2, y - h / 2, w, h);
      noTint();
    }
  }
}

class FloatRapper {
  public float v;
  
  public FloatRapper(){
    v = 0;
  }
  
  public FloatRapper(float v){
    this.v = v;
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