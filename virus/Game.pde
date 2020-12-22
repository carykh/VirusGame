//class c{

import static virusgame.Const.*;
import static virusgame.Var.*;

  void settings() {
    size(ORIG_W_W, ORIG_W_H);  //size(ORIG_W_W, ORIG_W_H); //apprrently used a static const is not allowed lol
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
//}
