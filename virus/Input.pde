class Input {

  boolean canDragWorld = false;
  boolean doubleClick = false; // not realy double click - find better name
  boolean wasMouseDown = false;
  double clickWorldX = -1;
  double clickWorldY = -1;
  boolean scrollLocked = true;
  int windowSizeX = 0; // used for resize detection //todo: do we need that because we are already doign that?
  int windowSizeY = 0;

  public void keyPressed() {
    char keyL = Character.toLowerCase(key);

    // disable/enable GUI
    if (keyL == 'x') {
      settings.show_ui = !settings.show_ui;
      renderer.maxRight = settings.show_ui ? ORIG_W_H : ORIG_W_W;
    } else if (keyL == 'q') {
      PLAY_SPEED = Math.max(0.1, PLAY_SPEED-1);
    } else if (keyL == 'w') {
      PLAY_SPEED = Math.max(0.1, PLAY_SPEED-0.1);
    } else if (keyL == 'e') {
      PLAY_SPEED += 0.1;
    } else if (keyL == 'r') {
      PLAY_SPEED += 1;
    } else if( key == '\t' ) {   // disable/enble debug screen
      settings.show_debug = !settings.show_debug;
    } else if( key == ' ' ) {
      renderer.camX = 0;
      renderer.camY = 0;
      renderer.camS = ((float) height) / settings.world_size;
    } else if( key == ESC ) { // make ESC key close the editor, and not the entire game
      editor.close();
      key = 0;
    }

    if(editor.selected != null) { //todo move to editor, check edior open
      if (keyCode == 67 && (int) key == 3) { //ctrl c
        String memory = "";
        for (int pos = 0; pos < editor.selected.genome.codons.size(); pos++) {
          if (pos > 0) {
            memory = memory + "-";
          }
          Codon c = editor.selected.genome.codons.get(pos);
          memory = memory + util.infoToString(c);
        }
        copyStringToClipboard(memory);
      } else if (keyCode == 86 && (int) key == 22) { //ctrl v
        String memory = getStringFromClipboard();
        try {
          editor.selected.genome = new Genome(memory, false);
        } catch (Exception e) {
          game.displayFormattingError = 30;
        }
      }
    }
  }


  public void mouseWheel(processing.event.MouseEvent event) {
    float e = event.getCount();
    if ((mouseX/scalefactor) > ORIG_W_H) {
      double UIX =  (mouseX/scalefactor) - ORIG_W_H;
      double UIY = (mouseY/scalefactor);
      if (editor.selected != null & util.dimWithinBox(GENOME_LIST_DIMS, UIX, UIY)) {
        Genome g = editor.selected.genome;
        int GENOME_LENGTH = g.codons.size();
        int scrollValue = max(1,(int)abs(e)/3)*(int)Math.signum(e);

        g.scrollOffset = Math.max(0, Math.min(g.scrollOffset + scrollValue , GENOME_LENGTH-VIEW_FIELD_DIS_CNT));

        if (editor.codonToEdit[1] >= 0) {
          if (scrollLocked &&editor.codonToEdit[1] < g.scrollOffset) {
            g.scrollOffset =editor.codonToEdit[1];
            renderer.flashCursorRed++;
          } else if (scrollLocked &&editor.codonToEdit[1] >= g.scrollOffset+VIEW_FIELD_DIS_CNT) {
            g.scrollOffset = Math.max(editor.codonToEdit[1]-VIEW_FIELD_DIS_CNT+1, 0);
            renderer.flashCursorRed++;
          }
          if (renderer.flashCursorRed==1) {
            renderer.activeCursorRed = millis();
          }
          if (renderer.flashCursorRed>5&(millis()-renderer.activeCursorRed)>200) {
            scrollLocked = false;
            renderer.activeCursorRed = 0;
            renderer.flashCursorRed = 0;

          }
        } else {
          scrollLocked = true;
        }
      }

      return;
    }

    double ZOOM_F = 1.05f;
    double thisZoomF = event.getCount() == 1 ? 1 / ZOOM_F : ZOOM_F;
    double worldX = (mouseX/scalefactor) / renderer.camS + renderer.camX;
    double worldY = (mouseY/scalefactor) / renderer.camS + renderer.camY;
    renderer.camX = (renderer.camX - worldX) / thisZoomF + worldX;
    renderer.camY = (renderer.camY - worldY) / thisZoomF + worldY;
    renderer.camS *= thisZoomF;

  }


  double dragStartX;
  double dragStartY;

  void windowResized() {
    graph.resize( ORIG_W_W - ORIG_W_H - 20, ORIG_W_H - 300 );
}

void inputCheck(){

    if( width != windowSizeX || height != windowSizeY ) {
         /*windowSizeX = width;
         windowSizeY = height;
         windowResized();*/
    }
    if (mousePressed) {
      editor.arrow = null;
      if (!wasMouseDown) {
        dragStartX = (mouseX/scalefactor);
        dragStartY = (mouseY/scalefactor);

        if ((mouseX/scalefactor) < renderer.maxRight) { //renderer.maxRight == ORIG_W_H
          boolean buttonPressed = true;
          if((mouseX/scalefactor)>=10 && (mouseX/scalefactor) <=75 && (mouseY/scalefactor)>=10 && (mouseY/scalefactor) <=50) {//speed down
            if(PLAY_SPEED>0.1) {
              PLAY_SPEED-=0.1;
            }
          }
          else if((mouseX/scalefactor)>=10+2*75 && (mouseX/scalefactor) <=75+2*75 && (mouseY/scalefactor)>=10 && (mouseY/scalefactor) <=50) {//speed up
            if(PLAY_SPEED<99.9) {
              PLAY_SPEED+=0.1;
            }
          } else {
            buttonPressed = false;
            editor.codonToEdit[0] = editor.codonToEdit[1] = -1;
            clickWorldX = renderer.appXtoTrueX(mouseX/scalefactor);
            clickWorldY = renderer.appYtoTrueY(mouseY/scalefactor);
            canDragWorld = true;
          }
          if (buttonPressed) {
            canDragWorld = false;
            wasMouseDown = true;
            return; //fix bug that moven screen when pressing button
          }
        } else {
          editor.checkInput();
          canDragWorld = false;
        }
        doubleClick = true;
      } else {
        double dragDistSQ = (dragStartX-(mouseX/scalefactor))*(dragStartX-(mouseX/scalefactor))+(dragStartY-(mouseY/scalefactor))*(dragStartY-(mouseY/scalefactor)); //this is squared, always compare with sqaured number

        if (canDragWorld) {

          double newCX = renderer.appXtoTrueX(mouseX/scalefactor);
          double newCY = renderer.appYtoTrueY(mouseY/scalefactor);

          if (newCX != clickWorldX || newCY != clickWorldY) {
            doubleClick = false;
          }
          if (CellType.UGO_Editor.isType(editor.selected)) {
            stroke(0, 0, 0);
            editor.arrow = new double[]{clickWorldX, clickWorldY, newCX, newCY};
          } else {
            renderer.camX -= (newCX - clickWorldX);
            renderer.camY -= (newCY - clickWorldY);
          }
        } else if (editor.selected != null && dragDistSQ > 10 && editor.dragAndDropCodonId < 0) {
          editor.checkGLdrag();
        }
      }

    } else { //mouse not pressed
      if (wasMouseDown) {
        if (editor.dragAndDropCodonId >= 0) {
          editor.releaseGLdrag();
        } else if (CellType.UGO_Editor.isType(editor.selected) && editor.arrow != null) {
          if (util.euclidLength(editor.arrow) > settings.min_length_to_produce) {
            editor.produce();
          }
        }
        if (doubleClick && canDragWorld) {

          if (!CellType.UGO_Editor.isType(editor.selected)) {
            editor.close();
          }
          if (world.isCellValid( clickWorldX, clickWorldY) ){
            editor.select( (int) clickWorldX, (int) clickWorldY);
          }

          checkUGOclick();
        }
      }
      clickWorldX = -1;
      clickWorldY = -1;
      editor.arrow = null;
    }
    wasMouseDown = mousePressed;
  }

  void checkUGOclick(){
    clickWorldX = renderer.appXtoTrueX((mouseX/scalefactor));
    clickWorldY = renderer.appYtoTrueY((mouseY/scalefactor));
    for(Particle ugo: world.pc.get(ParticleType.UGO)){
      double dis= util.euclidLength(new double[]{ugo.coor[0],ugo.coor[1], clickWorldX, clickWorldY});
      if(dis<=0.15){
        editor.openUGO((UGO)ugo);
        break;
      }
    }
  }


}
