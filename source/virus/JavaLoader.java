package virus;

import processing.core.PApplet;

import static virus.Const.ORIG_W_H;
import static virus.Const.ORIG_W_W;
import static virus.Var.game;
import static virus.Var.input;

//This is just the project loader for native Java projects. Make sure to hook into events here, but keep all important code out of here.
public class JavaLoader extends PApplet {
  public static void main(String[] args) {
    PApplet.main(JavaLoader.class.getName());
  }

  public JavaLoader() {
    Method.impl = new Adaptor(this);
  }


  @Override
  public void settings() {
    size(ORIG_W_W, ORIG_W_H);
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


}
