//it complains about not finding library for virus, virus.Const, and virus.Var, just ignore that
import virus.*;
import static virus.Const.*;
import static virus.Var.*;


//This is just the project loader for Processing. Make sure to hook into events here, but keep all important code out of here.
//In IntelliJ this file does not have syntax highlighting (It's not valid java anyway)
void settings() {
  Method.impl = new Adaptor(this);
  size(ORIG_W_W, ORIG_W_H);
  noSmooth();
  //size & noSmooth are a bit special, cannot call is from anywhere but eva
}

void setup() {
  game.setup();
}

void draw() {
  game.draw();
}


void keyPressed() {
  input.keyPressed();
}

void mouseWheel(processing.event.MouseEvent event) {
  input.mouseWheel(event);
}
