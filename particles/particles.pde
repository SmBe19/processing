UI ui;
PSViewer psViewer;
ParticleSystem ps;

void setup() {
  size(1000, 600);

  ps = new ParticleSystem();
  psViewer = new PSViewer(50, 50, width - 600, height - 100, ps);
  ui = new UI();
  ui.add(new Button(50, 10, 100, 20, "save", new ClickListener() { 
    public void click() { 
      selectInput("Save system", "saveSelected");
    }
  }
  ));
  ui.add(new Button(170, 10, 100, 20, "load", new ClickListener() { 
    public void click() { 
      selectInput("Load system", "loadSelected");
    }
  }
  ));
  ui.add(new Button(290, 10, 100, 20, "reset", new ClickListener() {
    public void click() {
      ps.reset();
    }
  }
  ));
  ui.add(psViewer);
  ui.add(grid(0, new Button(0, 0, 180, 15, "select texture", new ClickListener() {
    public void click() {
      selectInput("Select texture", "textureSelected");
    }
  }
  )));

  ui.add(slider(1, 0, 255, 200, "r", new ChangeListener() { 
    public void change(float x) { 
      psViewer.r = x;
    }
  }
  ));
  ui.add(slider(2, 0, 255, 200, "g", new ChangeListener() { 
    public void change(float x) { 
      psViewer.g = x;
    }
  }
  ));
  ui.add(slider(3, 0, 255, 200, "b", new ChangeListener() { 
    public void change(float x) { 
      psViewer.b = x;
    }
  }
  ));
  ui.add(slider(5, 0, 2, 0.25f, "emit", new ChangeListener() { 
    public void change(float x) {
      ps.emitCount = x * abs(x);
    }
  }
  ));
  ui.add(slider(6, -100, 100, 0, "x", new ChangeListener() { 
    public void change(float x) {
      ps.startX = x;
    }
  }
  ));
  ui.add(slider(7, 0, 100, 0, "rx", new ChangeListener() { 
    public void change(float x) {
      ps.startRndX = x;
    }
  }
  ));
  ui.add(slider(8, -100, 100, 0, "y", new ChangeListener() { 
    public void change(float x) {
      ps.startY = x;
    }
  }
  ));
  ui.add(slider(9, 0, 100, 0, "ry", new ChangeListener() { 
    public void change(float x) {
      ps.startRndY = x;
    }
  }
  ));
  ui.add(slider(10, -3, 3, 0, "sx", new ChangeListener() { 
    public void change(float x) {
      ps.speedX = x * abs(x);
    }
  }
  ));
  ui.add(slider(11, 0, 3, 0, "rsx", new ChangeListener() { 
    public void change(float x) {
      ps.speedRndX = x * abs(x);
    }
  }
  ));
  ui.add(slider(12, -3, 3, 0, "sy", new ChangeListener() { 
    public void change(float x) {
      ps.speedY = x * abs(x);
    }
  }
  ));
  ui.add(slider(13, 0, 3, 0, "rsy", new ChangeListener() { 
    public void change(float x) {
      ps.speedRndY = x * abs(x);
    }
  }
  ));
  ui.add(slider(14, -1, 1, 0, "gx", new ChangeListener() { 
    public void change(float x) {
      ps.gravityX = x * abs(x);
    }
  }
  ));
  ui.add(slider(15, -1, 1, 0.005, "gy", new ChangeListener() { 
    public void change(float x) {
      ps.gravityY = x * abs(x);
    }
  }
  ));
  ui.add(slider(16, 0, 4, 1, "s", new ChangeListener() { 
    public void change(float x) {
      ps.scale = x * abs(x);
    }
  }
  ));
  ui.add(slider(17, 0, 4, 0, "rs", new ChangeListener() { 
    public void change(float x) {
      ps.scaleRnd = x * abs(x);
    }
  }
  ));
  ui.add(slider(18, 0, 100, 10, "li", new ChangeListener() { 
    public void change(float x) {
      ps.lifetime = x * abs(x);
    }
  }
  ));
  ui.add(slider(19, 0, 100, 0, "rli", new ChangeListener() { 
    public void change(float x) {
      ps.lifetimeRnd = x * abs(x);
    }
  }
  ));
  ui.add(slider(20, 0, 50, 0, "rtr", new ChangeListener() { 
    public void change(float x) {
      ps.tintRndR = x;
    }
  }
  ));
  ui.add(slider(21, 0, 50, 0, "rtg", new ChangeListener() { 
    public void change(float x) {
      ps.tintRndG = x;
    }
  }
  ));
  ui.add(slider(22, 0, 50, 0, "rtb", new ChangeListener() { 
    public void change(float x) {
      ps.tintRndB = x;
    }
  }
  ));
  ui.add(slider(23, 0, 50, 0, "rta", new ChangeListener() { 
    public void change(float x) {
      ps.tintRndA = x;
    }
  }
  ));

  ui.add(timefloat(25, 0, 255, 255, "tr", ps.tintR));
  ui.add(timefloat(29, 0, 255, 255, "tg", ps.tintG));
  ui.add(timefloat(33, 0, 255, 255, "tb", ps.tintB));
  ui.add(timefloat(37, 0, 255, 255, "ta", ps.tintA));
}

UIElement grid(int i, UIElement element) {
  return grid(i, 180, 15, element);
}

UIElement grid(int i, int w, int h, UIElement element) {
  int row = i % 20, col = i / 20;
  int xoff = col * 200, yoff = row * 20;
  element.x = width - 490 + xoff;
  element.y = 50 + yoff;
  element.w = w;
  element.h = h;
  return element;
}

UIElement slider(int i, float min, float max, float value, String text, ChangeListener changeListener) {
  return grid(i, new Slider(0, 0, 180, 15, min, max, value, text, changeListener));
}

UIElement timefloat(int i, float min, float max, float value, String text, TimeFloat timeFloat){
  return grid(i, 180, 75, new TimeFloatViewer(0, 0, 180, 75, min, max, value, text, timeFloat));
}

void saveSelected(File file) {
  if (file != null) {
    ps.save(file);
  }
}

void loadSelected(File file) {
  if (file != null) {
    ps.load(file);
  }
}

void textureSelected(File file) {
  if (file != null) {
    ps.setTexture(file);
  }
}

void draw() {    
  ui.update();
  background(255);
  ui.draw();
}