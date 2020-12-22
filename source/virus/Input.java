package virus;

import static processing.core.PConstants.*;
import static virus.Const.*;
import static virus.Var.*;
import static virus.Method.*;
import static virus.Util.*;
import static java.lang.Math.*;
import static virus.ClipboardHelper.*;

public class Input {

  public boolean canDragWorld = false;
  public boolean doubleClick = false; // not realy double click - find better name
  public boolean wasMouseDown = false;
  public double clickWorldX = -1;
  public double clickWorldY = -1;
  public boolean scrollLocked = true;
  public int windowSizeX = 0; // used for resize detection //todo: do we need that because we are already doign that?
  public int windowSizeY = 0;

  public char keyPressed() {
    char keyL = Character.toLowerCase(getKey());

    // disable/enable GUI
    if (keyL == 'x') {
      settings.show_ui = !settings.show_ui;
      renderer.maxRight = settings.show_ui ? ORIG_W_H : ORIG_W_W;
    } else if (keyL == 'q') {
      PLAY_SPEED = Math.max(0.1f, PLAY_SPEED - 1);
    } else if (keyL == 'w') {
      PLAY_SPEED = Math.max(0.1f, PLAY_SPEED - 0.1f);
    } else if (keyL == 'e') {
      PLAY_SPEED += 0.1;
    } else if (keyL == 'r') {
      PLAY_SPEED += 1;
    } else if (getKey() == '\t') {   // disable/enble debug screen
      settings.show_debug = !settings.show_debug;
    } else if (getKey() == ' ') {
      renderer.camX = 0;
      renderer.camY = 0;
      renderer.camS = ((float) getAppletHeight()) / settings.world_size;
    } else if (getKey() == ESC) { // make ESC getKey() close the editor, and not the entire game
      editor.close();
      return 0;
    }

    if (editor.selected != null) { //todo move to editor, check edior open
      if (getKeyCode() == 67 && (int) getKey() == 3) { //ctrl c
        String memory = "";
        for (int pos = 0; pos < editor.selected.genome.codons.size(); pos++) {
          if (pos > 0) {
            memory = memory + "-";
          }
          Codon c = editor.selected.genome.codons.get(pos);
          memory = memory + infoToString(c);
        }
        copyStringToClipboard(memory);
      } else if (getKeyCode() == 86 && (int) getKey() == 22) { //ctrl v
        String memory = getStringFromClipboard();
        try {
          editor.selected.genome = new Genome(memory, false);
        } catch (Exception e) {
          game.displayFormattingError = 30;
        }
      }
    }

    return keyL;
  }


  public void mouseWheel(processing.event.MouseEvent event) {
    float e = event.getCount();
    if ((getMouseX() / scalefactor) > ORIG_W_H) {
      double UIX = (getMouseX() / scalefactor) - ORIG_W_H;
      double UIY = (getMouseY() / scalefactor);
      if (editor.selected != null & dimWithinBox(GENOME_LIST_DIMS, UIX, UIY)) {
        Genome g = editor.selected.genome;
        int GENOME_LENGTH = g.codons.size();
        int scrollValue = max(1, (int) abs(e) / 3) * (int) Math.signum(e);

        g.scrollOffset = Math.max(0, Math.min(g.scrollOffset + scrollValue, GENOME_LENGTH - VIEW_FIELD_DIS_CNT));

        if (editor.codonToEdit[1] >= 0) {
          if (scrollLocked && editor.codonToEdit[1] < g.scrollOffset) {
            g.scrollOffset = editor.codonToEdit[1];
            renderer.flashCursorRed++;
          } else if (scrollLocked && editor.codonToEdit[1] >= g.scrollOffset + VIEW_FIELD_DIS_CNT) {
            g.scrollOffset = Math.max(editor.codonToEdit[1] - VIEW_FIELD_DIS_CNT + 1, 0);
            renderer.flashCursorRed++;
          }
          if (renderer.flashCursorRed == 1) {
            renderer.activeCursorRed = millis();
          }
          if (renderer.flashCursorRed > 5 & (millis() - renderer.activeCursorRed) > 200) {
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
    double worldX = (getMouseX() / scalefactor) / renderer.camS + renderer.camX;
    double worldY = (getMouseY() / scalefactor) / renderer.camS + renderer.camY;
    renderer.camX = (renderer.camX - worldX) / thisZoomF + worldX;
    renderer.camY = (renderer.camY - worldY) / thisZoomF + worldY;
    renderer.camS *= thisZoomF;

  }


  double dragStartX;
  double dragStartY;

  void windowResized() {
    graph.resize(ORIG_W_W - ORIG_W_H - 20, ORIG_W_H - 300);
  }

  void inputCheck() {

    if (getAppletWidth() != windowSizeX || getAppletHeight() != windowSizeY) {
         /*windowSizeX = getAppletWidth();
         windowSizeY = getAppletHeight();
         windowResized();*/
    }
    if (getMousePressed()) {
      editor.arrow = null;
      if (!wasMouseDown) {
        dragStartX = (getMouseX() / scalefactor);
        dragStartY = (getMouseY() / scalefactor);

        if ((getMouseX() / scalefactor) < renderer.maxRight) { //renderer.maxRight == ORIG_W_H
          boolean buttonPressed = true;
          if ((getMouseX() / scalefactor) >= 10 && (getMouseX() / scalefactor) <= 75 && (getMouseY() / scalefactor) >= 10 && (getMouseY() / scalefactor) <= 50) {//speed down
            if (PLAY_SPEED > 0.1) {
              PLAY_SPEED -= 0.1;
            }
          } else if ((getMouseX() / scalefactor) >= 10 + 2 * 75 && (getMouseX() / scalefactor) <= 75 + 2 * 75 && (getMouseY() / scalefactor) >= 10 && (getMouseY() / scalefactor) <= 50) {//speed up
            if (PLAY_SPEED < 99.9) {
              PLAY_SPEED += 0.1;
            }
          } else {
            buttonPressed = false;
            editor.codonToEdit[0] = editor.codonToEdit[1] = -1;
            clickWorldX = renderer.appXtoTrueX(getMouseX() / scalefactor);
            clickWorldY = renderer.appYtoTrueY(getMouseY() / scalefactor);
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
        double dragDistSQ = (dragStartX - (getMouseX() / scalefactor)) * (dragStartX - (getMouseX() / scalefactor)) + (dragStartY - (getMouseY() / scalefactor)) * (dragStartY - (getMouseY() / scalefactor)); //this is squared, always compare with sqaured number

        if (canDragWorld) {

          double newCX = renderer.appXtoTrueX(getMouseX() / scalefactor);
          double newCY = renderer.appYtoTrueY(getMouseY() / scalefactor);

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
          if (euclidLength(editor.arrow) > settings.min_length_to_produce) {
            editor.produce();
          }
        }
        if (doubleClick && canDragWorld) {

          if (!CellType.UGO_Editor.isType(editor.selected)) {
            editor.close();
          }
          if (world.isCellValid(clickWorldX, clickWorldY)) {
            editor.select((int) clickWorldX, (int) clickWorldY);
          }

          checkUGOclick();
        }
      }
      clickWorldX = -1;
      clickWorldY = -1;
      editor.arrow = null;
    }
    wasMouseDown = getMousePressed();
  }

  void checkUGOclick() {
    clickWorldX = renderer.appXtoTrueX((getMouseX() / scalefactor));
    clickWorldY = renderer.appYtoTrueY((getMouseY() / scalefactor));
    for (Particle ugo : world.pc.get(ParticleType.UGO)) {
      double dis = euclidLength(new double[]{ugo.coor[0], ugo.coor[1], clickWorldX, clickWorldY});
      if (dis <= 0.15) {
        editor.openUGO((UGO) ugo);
        break;
      }
    }
  }


}
