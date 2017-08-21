class TweenEngine {

  ArrayList<Tween> tweens;
  int lastFrame;

  public TweenEngine() {
    tweens = new ArrayList<Tween>();
    lastFrame = millis();
  }

  public void update() {
    int now = millis();
    int delta = now - lastFrame;
    for (Tween tween : tweens) {
      tween.update(delta);
    }
    lastFrame = now;
  }

  public void reset() {
    for (Tween tween : tweens) {
      tween.reset();
    }
    lastFrame = millis();
  }

  public Tween create(float v) {
    Tween t = new Tween(v);
    tweens.add(t);
    return t;
  }
}

class Tween {

  public float v;
  private ArrayList<TweenAction> actions;

  public Tween (float v) {
    this.v = v;
    actions = new ArrayList<TweenAction>();
  }

  public void update(int delta) {
    if (actions.size() > 0) {
      actions.get(0).update(this, delta);
      if (actions.get(0).isDone()) {
        actions.remove(0);
      }
    }
  }

  public Tween reset() {
    actions.clear();
    return this;
  }
  
  public Tween set(float v){
    actions.add(new TweenActionSet(v));
    return this;
  }

  public Tween wait(int time) {
    actions.add(new TweenActionWait(time));
    return this;
  }

  public Tween linear(int time, float dest) {
    actions.add(new TweenActionLinear(time, dest));
    return this;
  }

  public Tween linear(int time, float start, float dest) {
    actions.add(new TweenActionLinear(time, start, dest));
    return this;
  }

  public Tween mirror(Tween mirror) {
    actions.add(new TweenActionMirror(mirror));
    return this;
  }

  public Tween align(int time, Tween align) {
    actions.add(new TweenActionAlign(time, align));
    return this;
  }

  public Tween align(int time, Tween align, float offset) {
    actions.add(new TweenActionAlign(time, align, offset));
    return this;
  }
}

abstract class TweenAction {
  public abstract boolean isDone();
  public abstract void update(Tween tween, int delta);
}

class TweenActionSet extends TweenAction {
  float v;
  
  public TweenActionSet(float v){
    this.v = v;
  }
  
  public boolean isDone(){
    return true;
  }
  
  public void update(Tween tween, int delta){
    tween.v = v;
  }
}

class TweenActionWait extends TweenAction {

  int time;

  public TweenActionWait(int time) {
    this.time = time;
  }

  public boolean isDone() {
    return time <= 0;
  }

  public void update(Tween tween, int delta) {
    time -= delta;
  }
}

class TweenActionLinear extends TweenAction {

  int time, usedTime;
  float start, dest;
  boolean infereStart, started;

  public TweenActionLinear(int time, float dest) {
    this.time = time;
    this.start = 0;
    this.dest = dest;
    this.infereStart = true;
    this.started = false;
    this.usedTime = 0;
  }

  public TweenActionLinear(int time, float start, float dest) {
    this.time = time;
    this.start = start;
    this.dest = dest;
    this.infereStart = false;
    this.started = false;
  }

  public boolean isDone() {
    return usedTime >= time;
  }

  public void update(Tween tween, int delta) {
    if (!started) {
      usedTime = 0;
      if (infereStart) {
        start = tween.v;
      }
      started = true;
    }

    tween.v = map(usedTime, 0, time, start, dest);

    usedTime += delta;

    if (usedTime >= time) {
      tween.v = dest;
    }
  }
}

class TweenActionMirror extends TweenAction {
  float offset;
  boolean started;
  Tween mirror;

  public TweenActionMirror(Tween mirror) {
    this.mirror = mirror;
    this.started = false;
  }

  public boolean isDone() {
    return false;
  }

  public void update(Tween tween, int delta) {
    if (!started) {
      offset = mirror.v - tween.v;
      started = true;
    }
    tween.v = mirror.v - offset;
  }
}

class TweenActionAlign extends TweenAction {
  int time, usedTime;
  float start, offset;
  boolean started;
  Tween align;

  public TweenActionAlign(int time, Tween align, float offset) {
    this.time = time;
    this.align = align;
    this.offset = offset;
    this.started = false;
    this.usedTime = 0;
  }

  public TweenActionAlign(int time, Tween align) {
    this(time, align, 0);
  }

  public boolean isDone() {
    return usedTime >= time;
  }

  public void update(Tween tween, int delta) {
    if (!started) {
      start = tween.v;
      usedTime = 0;
      started = true;
    }

    tween.v = map(usedTime, 0, time, start, align.v + offset);

    usedTime += delta;

    if (usedTime >= time) {
      tween.v = align.v + offset;
    }
  }
}