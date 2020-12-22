package virusgame;

import processing.core.PFont;
import processing.core.PGraphics;
import processing.core.PImage;
import processing.core.PSurface;
import processing.data.JSONObject;

public class Method {
  public static MethodImpl impl;
  //regex
  //((\w+)\((\w+ (\w+,? ?))?(\w+ (\w+,? ?))?(\w+ (\w+,? ?))?(\w+ (\w+,? ?))?(\) ?\{))(\W+)\}
  //$1\nimpl.$2($4$6$8$10);\n}

  public static void fill(float red, float green, float blue) {
    impl.fill(red, green, blue);
  }


  public static void fill(float color) {
    impl.fill(color);
  }

  public static void noStroke() {
    impl.noStroke();
  }

  public static void pushMatrix() {
    impl.pushMatrix();
  }

  public static void popMatrix() {
    impl.popMatrix();
  }

  public static void strokeWeight(float i) {
    impl.strokeWeight(i);
  }

  public static void stroke(float i) {
    impl.stroke(i);
  }
  public static void rotate(float angle) {
    impl.rotate(angle);
  }

  public static void translate(float left, float top) {
    impl.translate(left, top);
  }

  public static void rect(float left, float top, float width, float height) {
    impl.rect(left, top, width, height);
  }

  public static void beginShape() {
    impl.beginShape();
  }

  public static void endShape(int mode) {
    impl.endShape(mode);
  }

  public static void endShape() {
    impl.endShape();
  }

  public static void vertex(float left, float top) {
    impl.vertex(left, top);
  }

  public static void scale(float scale) {
    impl.scale(scale);
  }

  public static void ellipse(float i, float j, float l, float k) {
    impl.ellipse(i, j, l, k);
  }

  public static int color(float red, float green, float blue, float transparity) {
    return impl.color(red, green, blue, transparity);
  }

  public static int color(int red, int green, int blue) {
    return impl.color(red, green, blue);
  }

  public static float red(int col) {
    return impl.red(col);
  }
  public static float green(int col) {
    return impl.green(col);
  }
  public static float blue(int col) {
    return impl.blue(col);
  }


  public static PFont loadFont(String filename) {
    return impl.loadFont(filename);
  }

  public static void ellipseMode(int mode) {
    impl.ellipseMode(mode);
  }

  public static JSONObject loadJSONObject(String filename) {
    return impl.loadJSONObject(filename);
  }

  public static int getFrameCount() {
    return impl.getFrameCount();
  }

  public static int getMouseX() {
    return impl.getMouseX();
  }

  public static int getMouseY() {
    return impl.getMouseY();
  }

  public static char getKey() {
    return impl.getKey();
  }

  public static PSurface getSurface() {
    return impl.getSurface();
  }

  public static int getAppletWidth() {
    return impl.getAppletWidth();
  }

  public static int getAppletHeight() {
    return impl.getAppletHeight();
  }

  public static void textAlign(int alignX) {
    impl.textAlign(alignX);
  }


  public static void textFont(PFont which, float size) {
    impl.textFont(which, size);
  }

  public static void text(String str, float x, float y) {
    impl.text(str, x, y);
  }

  public static void line(float x1, float y1, float x2, float y2) {
    impl.line(x1, y1, x2, y2);
  }

  public static void background(int rgb) {
    impl.background(rgb);
  }

  public static void noFill() {
    impl.noFill();
  }

  public static PGraphics createGraphics(int w, int h) {
    return impl.createGraphics(w, h);
  }

  public static float getFrameRate() {
    return impl.getFrameRate();
  }


  public static int getKeyCode() {
    return impl.getKeyCode();
  }
  public static boolean getMousePressed() {
    return impl.getMousePressed();
  }

  public static void image(PImage img, float a, float b) {
    impl.image(img, a, b);
  }

  public static int millis() {
    return impl.millis();
  }


  public static void stroke(float v1, float v2, float v3) {
    impl.stroke(v1, v2, v3);
  }

  public static void stroke(float v1, float v2, float v3, float alpha) {
    impl.stroke(v1, v2, v3, alpha);
  }

  public static void fill(float v1, float v2, float v3, float alpha) {
    impl.fill(v1, v2, v3, alpha);
  }

  public static void textAlign(int alignX, int alignY) {
    impl.textAlign(alignX, alignY);
  }

  public interface MethodImpl {
     void fill(float red, float green, float blue);


     void fill(float color);

     void noStroke();

     void pushMatrix();

     void popMatrix();

     void strokeWeight(float i);

     void stroke(float i);
     void rotate(float angle);

     void translate(float left, float top);

     void rect(float left, float top, float width, float height);

     void beginShape();

     void endShape(int mode);
     void endShape();

     void vertex(float left, float top);

     void scale(float scale);

     void ellipse(float i, float j, float l, float k);

    int color(float red, float green, float blue, float transparity);

    int color(int red, int green, int blue);

    float red(int col);
    float green(int col);
    float blue(int col);


    PFont loadFont(String filename);

    void ellipseMode(int mode);

    JSONObject loadJSONObject(String filename);

    int getFrameCount();

    int getMouseX();

    int getMouseY();

    char getKey();

    PSurface getSurface();

    int getAppletWidth();

    int getAppletHeight();

    void textAlign(int alignX);


    void textFont(PFont which, float size);

    void text(String str, float x, float y);

    void line(float x1, float y1, float x2, float y2);

    void background(int rgb);

    void noFill();

    PGraphics createGraphics(int w, int h);

    float getFrameRate();


    int getKeyCode();
    boolean getMousePressed();

    void image(PImage img, float a, float b);

    int millis();


    void stroke(float v1, float v2, float v3);

    void stroke(float v1, float v2, float v3, float alpha);

    void fill(float v1, float v2, float v3, float alpha);

    void textAlign(int alignX, int alignY);
  }
}
