boolean pMousePressed, mouseJustPressed;

class UI {
  final ArrayList<UIElement> elements;

  public UI() {
    elements = new ArrayList<UIElement>();
  }

  public void add(UIElement element) {
    elements.add(element);
  }

  public void draw() {
    for (UIElement element : elements) {
      element.draw();
    }
  }

  public void update() {
    mouseJustPressed = mousePressed && !pMousePressed;

    for (UIElement element : elements) {
      element.update();
    }

    pMousePressed = mousePressed;
  }
}

abstract class UIElement {
  public int x, y, w, h;

  public UIElement(int x, int y, int w, int h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  protected boolean mouseInside() {
    return x <= mouseX && mouseX <= x + w && y <= mouseY && mouseY <= y + h;
  }

  public final void draw() {
    pushMatrix();
    translate(x, y);
    doDraw();
    popMatrix();
  }

  public final void update() {
    doUpdate();
  }

  abstract void doDraw();

  abstract void doUpdate();
}

class Button extends UIElement {

  public String text;
  public ClickListener clickListener;

  public Button(int x, int y, int w, int h, String text) {
    super(x, y, w, h);
    this.text = text;
  }

  public Button(int x, int y, int w, int h, String text, ClickListener clickListener) {
    this(x, y, w, h, text);
    this.clickListener = clickListener;
  }

  void doDraw() {
    fill(mouseInside() ? 200 : 255);
    stroke(0);
    rect(0, 0, w, h);
    fill(0);
    textSize(12);
    text(text, (w - textWidth(text)) / 2, (h + 12) / 2);
  }

  void doUpdate() {
    if (mouseJustPressed && mouseInside()) {
      if (clickListener != null) {
        clickListener.click();
      }
    }
  }
}

interface ClickListener {
  void click();
}

class Slider extends UIElement {

  public String text;
  public float min, max, slidersize, left, right;
  public boolean quadratic;
  public float initValue;
  public FloatRapper value;

  private boolean clicked;

  public Slider(int x, int y, int w, int h, float min, float max, float initValue, boolean quadratic, FloatRapper value, String text) {
    super(x, y, w, h);
    this.min = min;
    this.max = max;
    this.initValue = initValue;
    this.quadratic = quadratic;
    this.value = value;
    this.text = text;
    this.slidersize = h / 2;
    this.left = slidersize + (text.length() > 0 ? slidersize + textWidth(text) : 0);
    this.right = w - slidersize;
  }

  void doDraw() {
    fill(255);
    stroke(0);
    rect(0, 0, w, h);
    fill(0);
    textSize(10);
    text(text, slidersize, (h + 10) / 2);
    line(left, h / 2, right, h / 2);
    ellipse(map(untransformValue(value.v), min, max, left, right), h / 2, slidersize, slidersize);
  }
  
  float transformValue(float x){
    return quadratic ? x * abs(x) : x;
  }
  
  float untransformValue(float x){
    return quadratic ? sqrt(abs(x)) * (x < 0 ? -1 : 1) : x;
  }

  void doUpdate() {
    if (mouseJustPressed && mouseInside()) {
      clicked = true;
    }
    if (clicked && pMousePressed && !mousePressed) {
      clicked = false;
      if (mouseButton == RIGHT && mouseInside()) {
        value.v = transformValue(initValue);
      }
    }
    if (clicked) {
      value.v = transformValue(constrain(map(mouseX, x + left, x + right, min, max), min, max));
    }
  }
}

class PSViewer extends UIElement {
  public ParticleSystem ps;
  public FloatRapper r, g, b;

  public PSViewer(int x, int y, int w, int h, ParticleSystem ps) {
    super(x, y, w, h);
    this.ps = ps;
    this.r = new FloatRapper(200);
    this.g = new FloatRapper(200);
    this.b = new FloatRapper(200);
  }

  void doDraw() {
    clip(-1, -1, w+2, h+2);
    fill(r.v, g.v, b.v);
    stroke(0);
    rect(0, 0, w, h);
    ps.draw(w/2, h/2);
    noClip();
  }

  void doUpdate() {
    ps.update();
  }
}

class TimeFloatViewer extends UIElement {
  public String text;
  public TimeFloat timeFloat;
  public float min, max, value;

  private int currentPoint;
  private boolean clicked;

  public TimeFloatViewer(int x, int y, int w, int h, float min, float max, float value, String text, TimeFloat timeFloat) {
    super(x, y, w, h);
    this.text = text;
    this.timeFloat = timeFloat;
    this.min = min;
    this.max = max;
    this.value = value;
    this.currentPoint = -1;

    for (int i = 0; i < timeFloat.points.size(); i++) {
      timeFloat.moveValue(i, value);
    }
  }

  void doDraw() {
    fill(255);
    stroke(0);
    rect(0, 0, w, h);

    stroke(100);
    for (int i = 0; i < timeFloat.points.size() - 1; i++) {
      FloatPair p1 = timeFloat.points.get(i);
      FloatPair p2 = timeFloat.points.get(i+1);
      line(getX(p1), getY(p1), getX(p2), getY(p2));
    }

    for (int i = 0; i < timeFloat.points.size(); i++) {
      FloatPair p1 = timeFloat.points.get(i);
      fill(i == currentPoint ? 200 : 255);
      ellipse(getX(p1), getY(p1), 4, 4);
    }
  }

  float getX(FloatPair p) {
    return map(p.time, 0, 1, 5, w - 10);
  }

  float getY(FloatPair p) {
    return map(p.value, min, max, h - 10, 5);
  }

  float ungetX(float x) {
    return map(x, 5, w - 10, 0, 1);
  }

  float ungetY(float y) {
    return map(y, h - 10, 5, min, max);
  }

  void doUpdate() {
    int mx = constrain(mouseX - x, 5, w - 10);
    int my = constrain(mouseY - y, 5, h - 10);
    if (mouseInside() && !clicked) {
      calcCurrentPoint(mx);
    }
    if (mouseJustPressed && mouseInside()) {
      clicked = true;
      if (currentPoint == -1) {
        timeFloat.set(ungetX(mx), ungetY(my));
        calcCurrentPoint(mx);
      }
    }
    if (clicked && pMousePressed && !mousePressed) {
      clicked = false;
      if (mouseButton == RIGHT && mouseInside()) {
        timeFloat.unset(currentPoint);
        currentPoint = -1;
      }
    }
    if (clicked) {
      timeFloat.moveTime(currentPoint, ungetX(mx));
      timeFloat.moveValue(currentPoint, ungetY(my));
    }
  }
  
  void calcCurrentPoint(float mx) {
      currentPoint = -1;
      for (int i = 0; i < timeFloat.points.size(); i++) {
        if (abs(mx - getX(timeFloat.points.get(i))) < 10) {
          currentPoint = i;
          if (i > 0){
            break;
          }
        }
      }
  }
}