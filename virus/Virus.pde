class VirusGame {


  //###VAR
  int lastEditTimeStamp = 0;
  int displayFormattingError = -1;


  void setup() {

    surface.setTitle("The Game Of Life, Death And Viruses");
    surface.setResizable(true);
    surface.setSize(ORIG_W_W, ORIG_W_H);


    font = loadFont("Jygquip1-96.vlw");
    settings = new Settings();
    world = new World( settings );
    renderer = new Renderer( settings );
    editor = new Editor( settings );
graph = new Graph( settings.graph_length, width - height - 20, height - 300 );
    graph.setRescan( settings.graph_downscale );

    println("Ready!");
  }

  void draw() {
    //####Fixing Aspect ratio
    enforceAspectRatio();


    //####Actually tick code
    scale((float)scalefactor);
    input.inputCheck();
    world.updateParticleCount();
    world.tick();


    //####Actually render code
    renderer.drawBackground();
    renderer.drawCells();
    renderer.drawParticles();
    renderer.drawExtras();
    renderer.drawUI();
    renderer.drawSpeedControl();
    renderer.drawCredits();
    if (wasWindowMax) {
      renderer.drawOverEmpty();
    }
    if (displayFormattingError-- > 0) {
      renderer.drawFormattingError();
    }
  }

  boolean isMaximised() {
    javax.swing.JFrame jframe = (javax.swing.JFrame)((processing.awt.PSurfaceAWT.SmoothCanvas)getSurface().getNative()).getFrame();
    return (jframe.getExtendedState()&MAX_WINDOW)==MAX_WINDOW;
  }
  int getRealWidth() {
    javax.swing.JFrame jframe = (javax.swing.JFrame)((processing.awt.PSurfaceAWT.SmoothCanvas)getSurface().getNative()).getFrame();
    return jframe.getWidth()+widthSizeDiff;
  }
  int getRealHeight() {
    javax.swing.JFrame jframe = (javax.swing.JFrame)((processing.awt.PSurfaceAWT.SmoothCanvas)getSurface().getNative()).getFrame();
    return jframe.getHeight()+heightSizeDiff;
  }
  void forceSize(int ORIG_W_W, int ORIG_W_H) {
    javax.swing.JFrame jframe = (javax.swing.JFrame)((processing.awt.PSurfaceAWT.SmoothCanvas)getSurface().getNative()).getFrame();
    jframe.setPreferredSize(new java.awt.Dimension(ORIG_W_W-widthSizeDiff, ORIG_W_H-heightSizeDiff));
  }


  int lastResized;
  boolean wasWindowMax = false;
  int widthSizeDiff = 0;
  int heightSizeDiff = 0;
  int lastWidth = W_W;
  int lastHeight = W_H;
  int lastDiffWidth = 0;
  int lastDiffHeight = 0;
  private void enforceAspectRatio() {
    if (frameCount == 10) {//wait 10 frames for everything to properly init
      widthSizeDiff = width - getRealWidth(); //calibrate getRealWidth
      heightSizeDiff = height - getRealHeight(); //calibrate getRealHeight
      lastWidth = width;
      lastHeight= height;
    } else if (frameCount > 10) {
      boolean isWindowMax = isMaximised();
      int newWidth = getRealWidth();
      int newHeight = getRealHeight();
      if ((isWindowMax != wasWindowMax) || (lastWidth != newWidth || lastHeight != newHeight) && (lastDiffWidth != lastWidth - newWidth || lastDiffHeight != lastHeight - newHeight)) {
        lastDiffWidth = lastWidth - newWidth; //diff diff conparisons are for detecting bugged window state: bugged window state means async between JFrame and OS windows size
        lastDiffHeight = lastHeight - newHeight;
        //println(String.format("%b != %b && %d != %d &&  %d != %d, info: diff=%d, %d", isWindowMax, wasWindowMax, lastWidth, newWidth, lastHeight, newHeight, widthSizeDiff, heightSizeDiff)); //jyou might want to add diff diff debug here
        wasWindowMax = isWindowMax;
        if (isWindowMax) { //in a maximized window there is little point is resizing it, we just have to accept
          scalefactor = Math.min(width/(float)ORIG_W_W,height/(float)ORIG_W_H); //dont use newWidth border might be different
          W_W = (int)(ORIG_W_W*scalefactor);
          W_H = (int)(ORIG_W_H*scalefactor);
        } else if (lastWidth != newWidth) { //user changed width
          scalefactor = newWidth/(float)ORIG_W_W;
          W_W = newWidth;
          W_H = (int)(ORIG_W_H*scalefactor);
        } else { //user changed height
          scalefactor = newHeight/(float)ORIG_W_H;
          W_W = (int)(ORIG_W_W*scalefactor);
          W_H = newHeight;
        }
        if (!isWindowMax)  {
          lastResized = 30; //in 30 frames force it!
        }
        lastWidth = newWidth;
        lastHeight = newHeight;
      }
      lastResized--;
      if (!isWindowMax && lastResized == 0) {
        forceSize(W_W+1, W_H+1); //invalidate cache that probably is invalid
        forceSize(W_W, W_H); //set actual size
        surface.setSize(W_W, W_H); //update processing
        lastWidth = W_W; //this was an intended change, lets not recognise this as user trying to change window size
        lastHeight = W_H;
      }
    }
  }
}
