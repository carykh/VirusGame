import processing.core.PApplet;
import processing.core.PFont;
import processing.core.PGraphics;
import processing.core.PImage;
import virusgame.Method;
import static virusgame.Const.*;
import static virusgame.Var.*;

public class JavaLoader extends PApplet implements Method.MethodImpl {
  public static void main(String args[]) {
    PApplet.main(JavaLoader.class.getCanonicalName());
  }

  public JavaLoader() {
    Method.impl = this;
  }


  @Override
  public void settings() {
    size(ORIG_W_W, ORIG_W_H);  //size(ORIG_W_W, ORIG_W_H); //apprrently used a static const is not allowed lol
    noSmooth();
    //size & noSmooth are a bit special, cannot call is from anywhere but eva
  }

  @Override
  public void setup() {
    game.setup();
  }

  @Override
  public void draw() {
    game.draw();
  }


  @Override
  public void keyPressed() {
    key = input.keyPressed();
  }

  @Override
  public void mouseWheel(processing.event.MouseEvent event) {
    input.mouseWheel(event);
  }

  public int getFrameCount() {
    return frameCount;
  }

  public int getMouseX() {
    return mouseX;
  }

  public int getMouseY() {
    return mouseY;
  }

  public char getKey() {
    return key;
  }

  public int getAppletWidth() {
    return width;
  }

  public int getAppletHeight() {
    return height;
  }

  public float getFrameRate() {
    return frameRate;
  }


  public int getKeyCode() {
    return keyCode;
  }
  public boolean getMousePressed() {
    return mousePressed;
  }


  //dist
  //ellipseMode
  //concat
  //join
  //loadFont
  //println
  //loadJSONObject
  //
  //##Var
  //getFrameCount()
  //getMouseX()
  //getMouseY()
  //getKey()
  //surface
  //
  //getAppletWidth() -> getAppletWidth
  //getAppletHeight()

}
