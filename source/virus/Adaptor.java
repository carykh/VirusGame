package virus;

import processing.core.*;
import processing.data.JSONObject;

public class Adaptor implements Method.MethodImpl {
  private final PApplet applet;

  public Adaptor(PApplet applet) {
    this.applet = applet;
  }

  public void fill(float red, float green, float blue) {
    applet.fill(red, green, blue);
  }


  public void fill(int col) {
    applet.fill(col);
  }

  public void fill(float col) {
    applet.fill(col);
  }

  public void noStroke() {
    applet.noStroke();
  }

  public void pushMatrix() {
    applet.pushMatrix();
  }

  public void popMatrix() {
    applet.popMatrix();
  }

  public void strokeWeight(float i) {
    applet.strokeWeight(i);
  }

  public void stroke(int i) {
    applet.stroke(i);
  }

  public void rotate(float angle) {
    applet.rotate(angle);
  }

  public void translate(float left, float top) {
    applet.translate(left, top);
  }

  public void rect(float left, float top, float width, float height) {
    applet.rect(left, top, width, height);
  }

  public void beginShape() {
    applet.beginShape();
  }

  public void endShape(int mode) {
    applet.endShape(mode);
  }

  public void endShape() {
    applet.endShape();
  }

  public void vertex(float left, float top) {
    applet.vertex(left, top);
  }

  public void scale(float scale) {
    applet.scale(scale);
  }

  public void ellipse(float i, float j, float l, float k) {
    applet.ellipse(i, j, l, k);
  }

  public int color(float red, float green, float blue, float transparity) {
    return applet.color(red, green, blue, transparity);
  }

  public int color(int red, int green, int blue) {
    return applet.color(red, green, blue);
  }

  public float red(int col) {
    return applet.red(col);
  }

  public float green(int col) {
    return applet.green(col);
  }

  public float blue(int col) {
    return applet.blue(col);
  }


  public PFont loadFont(String filename) {
    return applet.loadFont(filename);
  }

  public void ellipseMode(int mode) {
    applet.ellipseMode(mode);
  }

  public JSONObject loadJSONObject(String filename) {
    return applet.loadJSONObject(filename);
  }

  public int getFrameCount() {
    return applet.frameCount;
  }

  public int getMouseX() {
    return applet.mouseX;
  }

  public int getMouseY() {
    return applet.mouseY;
  }

  public char getKey() {
    return applet.key;
  }

  public PSurface getSurface() {
    return applet.getSurface();
  }

  public int getAppletWidth() {
    return applet.width;
  }

  public int getAppletHeight() {
    return applet.height;
  }

  public void textAlign(int alignX) {
    applet.textAlign(alignX);
  }


  public void textFont(PFont which, float size) {
    applet.textFont(which, size);
  }

  public void text(String str, float x, float y) {
    applet.text(str, x, y);
  }

  public void line(float x1, float y1, float x2, float y2) {
    applet.line(x1, y1, x2, y2);
  }

  public void background(int rgb) {
    applet.background(rgb);
  }

  public void noFill() {
    applet.noFill();
  }

  public PGraphics createGraphics(int w, int h) {
    return applet.createGraphics(w, h);
  }

  public float getFrameRate() {
    return applet.frameRate;
  }


  public int getKeyCode() {
    return applet.keyCode;
  }

  public boolean getMousePressed() {
    return applet.mousePressed;
  }

  public void image(PImage img, float a, float b) {
    applet.image(img, a, b);
  }

  public int millis() {
    return applet.millis();
  }


  public void stroke(float v1, float v2, float v3) {
    applet.stroke(v1, v2, v3);
  }

  public void stroke(float v1, float v2, float v3, float alpha) {
    applet.stroke(v1, v2, v3, alpha);
  }

  public void fill(float v1, float v2, float v3, float alpha) {
    applet.fill(v1, v2, v3, alpha);
  }

  public void textAlign(int alignX, int alignY) {
    applet.textAlign(alignX, alignY);
  }

}